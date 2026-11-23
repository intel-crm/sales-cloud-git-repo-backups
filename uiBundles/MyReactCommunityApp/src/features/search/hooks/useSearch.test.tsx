import {
  act,
  cleanup,
  render,
  renderHook,
  screen,
  waitFor,
} from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import {
  MemoryRouter,
  Outlet,
  Route,
  Routes,
  useLocation,
  useNavigate,
} from 'react-router';
import type { ReactNode } from 'react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { useSearch } from './useSearch';
import { Search } from '../components/Search';
import { GlobalSearchBox } from '../components/GlobalSearchBox';
import type { SourceRequest } from '../adapters/types';
import type { RunSearchOutcome } from '../api/searchService';
import type { SearchConfig } from '../types';

const mocks = vi.hoisted(() => ({ runSearch: vi.fn() }));
vi.mock('../api/searchService', () => ({ runSearch: mocks.runSearch }));
vi.mock('../adapters/cms/searchChannel', () => ({
  getUIBundleId: async () => '',
  getUserLanguage: async () => 'en-US',
  isConfiguredUIBundleId: () => false,
}));
vi.mock('../adapters/cms/api/orgApiVersionService', () => ({
  getOrgSupportsCmsSearch: async () => false,
  isCmsSearchSupported: () => false,
}));
vi.mock('../adapters/cms/hooks/useSearchableContentTypes', () => {
  const contentTypes: [] = [];
  return { useSearchableContentTypes: () => ({ contentTypes }) };
});

const config: SearchConfig = {
  pagination: { mode: 'per-source', pageSize: 10, pageSizeOptions: [5, 10] },
  sources: [
    {
      kind: 'sobject',
      key: 'accounts',
      objectName: 'Account',
      label: 'Accounts',
      searchableFields: ['Name'],
      displayFields: ['Name'],
      sortBy: [{ field: 'Name', label: 'Name' }],
    },
    {
      kind: 'sobject',
      key: 'contacts',
      objectName: 'Contact',
      label: 'Contacts',
      searchableFields: ['Name'],
      displayFields: ['Name'],
    },
  ],
};

function outcome(requests: SourceRequest[]): RunSearchOutcome {
  return {
    results: Object.fromEntries(
      requests.map(request => [
        request.source.key,
        {
          nodes: [
            {
              Id: `${request.source.key}-${request.q}`,
              Name: { value: `${request.q} ${request.source.label}` },
            },
          ],
          totalCount: 20,
          pageInfo: {
            hasNextPage: true,
            hasPreviousPage: false,
            endCursor: `${request.q}-cursor`,
            startCursor: null,
          },
        },
      ])
    ),
    errors: {},
  };
}

function Navigation() {
  const navigate = useNavigate();
  const location = useLocation();
  return (
    <>
      <GlobalSearchBox hideSubmitButton />
      <button onClick={() => navigate(-1)}>Back</button>
      <button onClick={() => navigate(1)}>Forward</button>
      <output aria-label="Current URL">
        {location.pathname}
        {location.search}
      </output>
    </>
  );
}

function Wrapper({ children }: { children: ReactNode }) {
  return (
    <MemoryRouter
      basename="/MyReactCommunityApp"
      initialEntries={['/MyReactCommunityApp/search?q=Alpha']}
    >
      <Navigation />
      {children}
    </MemoryRouter>
  );
}

beforeEach(() => {
  mocks.runSearch.mockReset();
  mocks.runSearch.mockImplementation(async (requests: SourceRequest[]) =>
    outcome(requests)
  );
});

afterEach(cleanup);

async function submit(user: ReturnType<typeof userEvent.setup>, text: string) {
  const input = screen.getByRole('textbox', { name: 'Search' });
  await user.clear(input);
  await user.type(input, text);
  await user.keyboard('{Enter}');
}

describe('same-route search navigation', () => {
  it('replaces displayed object rows when the header submits another term on the results route', async () => {
    const user = userEvent.setup();
    render(
      <Wrapper>
        <Routes>
          <Route element={<Outlet />}>
            <Route
              path="search"
              element={
                <Search
                  as="main"
                  config={config}
                  showSearchBar={false}
                  resultLayout="table"
                />
              }
            />
          </Route>
        </Routes>
      </Wrapper>
    );
    expect(await screen.findByText('Alpha Accounts')).toBeInTheDocument();
    await submit(user, 'Beta');
    expect(await screen.findByText('Beta Accounts')).toBeInTheDocument();
    expect(screen.queryByText('Alpha Accounts')).not.toBeInTheDocument();
    expect(screen.getByText('Beta Contacts')).toBeInTheDocument();
    expect(screen.getByLabelText('Current URL')).toHaveTextContent(
      '/search?q=Beta'
    );
  });

  it('restores queries and header text through browser back and forward', async () => {
    const user = userEvent.setup();
    const { result } = renderHook(() => useSearch(config), {
      wrapper: Wrapper,
    });
    await waitFor(() => expect(result.current.loading).toBe(false));
    expect(screen.getByRole('textbox', { name: 'Search' })).toHaveValue(
      'Alpha'
    );
    await submit(user, 'Beta');
    await waitFor(() => expect(result.current.q).toBe('Beta'));
    await user.click(screen.getByRole('button', { name: 'Back' }));
    await waitFor(() => expect(result.current.q).toBe('Alpha'));
    expect(screen.getByRole('textbox', { name: 'Search' })).toHaveValue(
      'Alpha'
    );
    await user.click(screen.getByRole('button', { name: 'Forward' }));
    await waitFor(() => expect(result.current.q).toBe('Beta'));
    expect(screen.getByRole('textbox', { name: 'Search' })).toHaveValue('Beta');
  });

  it('does not restore an old query from a pending sort URL update', async () => {
    const user = userEvent.setup();
    const { result } = renderHook(() => useSearch(config), {
      wrapper: Wrapper,
    });
    await waitFor(() => expect(result.current.loading).toBe(false));
    act(() =>
      result.current.sources.accounts.sort.set({
        field: 'Name',
        direction: 'DESC',
      })
    );
    await submit(user, 'Beta');
    await waitFor(() => expect(result.current.q).toBe('Beta'));
    await act(async () => {
      await new Promise(resolve => setTimeout(resolve, 350));
    });
    expect(result.current.q).toBe('Beta');
    expect(result.current.sources.accounts.sort.current).toBeNull();
    expect(screen.getByLabelText('Current URL')).toHaveTextContent(
      '/search?q=Beta'
    );
  });

  it('preserves scope, sorting, and cursors when the hook writes its own URL', async () => {
    const { result } = renderHook(() => useSearch(config), {
      wrapper: Wrapper,
    });
    await waitFor(() => expect(result.current.loading).toBe(false));
    act(() => result.current.setScope('accounts'));
    await waitFor(() => expect(result.current.loading).toBe(false));
    act(() =>
      result.current.sources.accounts.sort.set({
        field: 'Name',
        direction: 'ASC',
      })
    );
    await waitFor(() => expect(result.current.loading).toBe(false));
    act(() => result.current.sources.accounts.pagination.goToNextPage());
    await waitFor(() =>
      expect(result.current.sources.accounts.pagination.pageIndex).toBe(1)
    );
    await act(async () => {
      await new Promise(resolve => setTimeout(resolve, 350));
    });
    expect(result.current.scope).toBe('accounts');
    expect(result.current.sources.accounts.sort.current).toEqual({
      field: 'Name',
      direction: 'ASC',
    });
    expect(result.current.sources.accounts.pagination.pageIndex).toBe(1);
    expect(mocks.runSearch).toHaveBeenLastCalledWith([
      expect.objectContaining({ q: 'Alpha', afterCursor: 'Alpha-cursor' }),
    ]);
  });

  it('resets prior scope, sort, and cursors for a fresh header submission', async () => {
    const user = userEvent.setup();
    const { result } = renderHook(() => useSearch(config), {
      wrapper: Wrapper,
    });
    await waitFor(() => expect(result.current.loading).toBe(false));
    act(() => result.current.setScope('accounts'));
    await waitFor(() => expect(result.current.loading).toBe(false));
    act(() =>
      result.current.sources.accounts.sort.set({
        field: 'Name',
        direction: 'ASC',
      })
    );
    await waitFor(() => expect(result.current.loading).toBe(false));
    act(() => result.current.sources.accounts.pagination.goToNextPage());
    await waitFor(() =>
      expect(result.current.sources.accounts.pagination.pageIndex).toBe(1)
    );
    await submit(user, 'Beta');
    await waitFor(() => expect(result.current.q).toBe('Beta'));
    await waitFor(() => expect(result.current.loading).toBe(false));
    expect(result.current.scope).toBe('all');
    expect(result.current.sources.accounts.sort.current).toBeNull();
    expect(result.current.sources.accounts.pagination.pageIndex).toBe(0);
    expect(mocks.runSearch).toHaveBeenLastCalledWith([
      expect.objectContaining({
        q: 'Beta',
        sort: null,
        afterCursor: undefined,
      }),
      expect.objectContaining({
        q: 'Beta',
        sort: null,
        afterCursor: undefined,
      }),
    ]);
  });

  it('does not replace new results with a late response from the previous term', async () => {
    let resolveAlpha: (() => void) | undefined;
    mocks.runSearch.mockImplementation((requests: SourceRequest[]) => {
      if (requests[0].q === 'Alpha') {
        return new Promise<RunSearchOutcome>(resolve => {
          resolveAlpha = () => resolve(outcome(requests));
        });
      }
      return Promise.resolve(outcome(requests));
    });
    const user = userEvent.setup();
    const { result } = renderHook(() => useSearch(config), {
      wrapper: Wrapper,
    });
    await waitFor(() => expect(mocks.runSearch).toHaveBeenCalledOnce());
    await submit(user, 'Beta');
    await waitFor(() => expect(result.current.loading).toBe(false));
    expect(result.current.sources.accounts.result?.nodes).toEqual([
      { Id: 'accounts-Beta', Name: { value: 'Beta Accounts' } },
    ]);
    await act(async () => {
      if (!resolveAlpha)
        throw new Error('Initial search request was not started');
      resolveAlpha();
    });
    expect(result.current.sources.accounts.result?.nodes).toEqual([
      { Id: 'accounts-Beta', Name: { value: 'Beta Accounts' } },
    ]);
  });

  it('resets merged pagination and retains an explicitly locked scope', async () => {
    const user = userEvent.setup();
    const mergedConfig: SearchConfig = {
      ...config,
      pagination: { mode: 'merged', pageSize: 10, pageSizeOptions: [5, 10] },
    };
    const { result } = renderHook(
      () => useSearch(mergedConfig, { lockedScope: 'accounts' }),
      { wrapper: Wrapper }
    );
    await waitFor(() => expect(result.current.loading).toBe(false));
    act(() => result.current.globalPagination.goToNextPage());
    await waitFor(() =>
      expect(result.current.globalPagination.pageIndex).toBe(1)
    );
    await waitFor(() => expect(result.current.loading).toBe(false));
    expect(mocks.runSearch).toHaveBeenLastCalledWith([
      expect.objectContaining({ q: 'Alpha', pageSize: 20 }),
    ]);
    await submit(user, 'Beta');
    await waitFor(() => expect(result.current.q).toBe('Beta'));
    await waitFor(() => expect(result.current.loading).toBe(false));
    expect(result.current.scope).toBe('accounts');
    expect(result.current.globalPagination.pageIndex).toBe(0);
    expect(mocks.runSearch).toHaveBeenLastCalledWith([
      expect.objectContaining({ q: 'Beta', pageSize: 10 }),
    ]);
  });
});
