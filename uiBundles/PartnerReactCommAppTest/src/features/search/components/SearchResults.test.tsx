import { cleanup, render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { SearchResults } from './SearchResults';
import { config } from '../loadConfig';
import type { SearchHandle, SourceController, SourceConfig } from '../types';

vi.mock('./filters/DefaultFilterPanel', () => ({
  DefaultFilterPanel: () => <div>Object filters</div>,
}));
vi.mock('../adapters/cms/api/orgApiVersionService', () => ({
  isCmsSearchSupported: () => true,
}));

afterEach(cleanup);

function controller(source: SourceConfig): SourceController {
  return {
    config: source,
    result: {
      nodes:
        source.kind === 'cms'
          ? [{ managedContentId: 'content-1', title: 'Content example' }]
          : [
              {
                Id: `${source.key}-1`,
                Name: { value: `${source.label} example` },
              },
            ],
      totalCount: 1,
      pageInfo: null,
    },
    loading: false,
    error: null,
    filters: { active: [], set: vi.fn(), remove: vi.fn() },
    sort: {
      current: source.kind === 'sobject' ? (source.defaultSort ?? null) : null,
      set: vi.fn(),
    },
    pagination: {
      pageSize: 10,
      pageSizeOptions: [5, 10, 20],
      pageIndex: 0,
      hasNextPage: true,
      hasPreviousPage: false,
      setPageSize: vi.fn(),
      goToNextPage: vi.fn(),
      goToPreviousPage: vi.fn(),
    },
  };
}

function handle(scope = 'all'): SearchHandle {
  const sources = Object.fromEntries(
    config.sources.map(source => [source.key, controller(source)])
  );
  return {
    q: 'example',
    setQ: vi.fn(),
    scope,
    setScope: vi.fn(),
    scopeLocked: false,
    sources,
    inScopeSources: Object.values(sources),
    mergedResults: [],
    loading: false,
    error: null,
    discoveredContentTypes: [],
    resetAll: vi.fn(),
    globalPagination: {
      pageIndex: 0,
      pageCount: 1,
      pageSize: 10,
      pageSizeOptions: [5, 10, 20],
      hasNextPage: false,
      hasPreviousPage: false,
      totalCount: 4,
      goToNextPage: vi.fn(),
      goToPreviousPage: vi.fn(),
      goToPage: vi.fn(),
      setPageSize: vi.fn(),
    },
  };
}

describe('grouped search results', () => {
  it('groups all SObjects into separate tables using their configured columns and retains CMS content', () => {
    render(
      <MemoryRouter>
        <SearchResults handle={handle()} resultLayout="table" />
      </MemoryRouter>
    );
    for (const label of ['Accounts', 'Contacts', 'Opportunities']) {
      expect(screen.getByRole('heading', { name: label })).toBeInTheDocument();
      expect(
        screen.getByRole('table', { name: `${label} search results` })
      ).toBeInTheDocument();
    }
    const accounts = screen.getByRole('table', {
      name: 'Accounts search results',
    });
    expect(
      within(accounts)
        .getAllByRole('columnheader')
        .map(header => header.textContent)
    ).toEqual([
      'Account Name',
      'Industry',
      'Type',
      'Phone',
      'Annual Revenue',
      'Owner Name',
    ]);
    const opportunities = screen.getByRole('table', {
      name: 'Opportunities search results',
    });
    expect(
      within(opportunities)
        .getAllByRole('columnheader')
        .map(header => header.textContent)
    ).toEqual([
      'Opportunity Name',
      'Stage',
      'Amount',
      'Close Date',
      'Account Name',
    ]);
    expect(screen.getAllByRole('table')).toHaveLength(3);
    expect(screen.getByText('Content example')).toBeInTheDocument();
  });

  it('retains scoped filters, sorting, and independent pagination', async () => {
    const user = userEvent.setup();
    const state = handle('accounts');
    render(
      <MemoryRouter>
        <SearchResults handle={state} resultLayout="table" />
      </MemoryRouter>
    );
    expect(screen.getAllByRole('table')).toHaveLength(1);
    expect(screen.getByText('Object filters')).toBeInTheDocument();
    expect(
      screen.getByRole('combobox', { name: 'Sort by' })
    ).toBeInTheDocument();
    await user.click(
      screen.getByRole('button', { name: 'Sort Account Name ascending' })
    );
    expect(state.sources.accounts.sort.set).toHaveBeenCalledWith({
      field: 'Name',
      direction: 'ASC',
    });
    await user.click(screen.getByRole('button', { name: 'Go to next page' }));
    expect(
      state.sources.accounts.pagination.goToNextPage
    ).toHaveBeenCalledOnce();
  });

  it('preserves custom row renderers and the default list layout', () => {
    const { rerender } = render(
      <MemoryRouter>
        <SearchResults
          handle={handle('accounts')}
          resultLayout="table"
          renderResult={{ accounts: () => <p>Custom account row</p> }}
        />
      </MemoryRouter>
    );
    expect(screen.getByText('Custom account row')).toBeInTheDocument();
    expect(screen.queryByRole('table')).not.toBeInTheDocument();
    rerender(
      <MemoryRouter>
        <SearchResults handle={handle('accounts')} />
      </MemoryRouter>
    );
    expect(screen.queryByRole('table')).not.toBeInTheDocument();
    expect(
      screen.getByRole('link', { name: 'View: Accounts example' })
    ).toBeInTheDocument();
  });

  it.each(['loading', 'empty', 'error'])(
    'keeps the existing %s state rather than showing stale table rows',
    status => {
      const state = handle('accounts');
      if (status === 'loading') state.sources.accounts.loading = true;
      if (status === 'empty')
        state.sources.accounts.result = {
          nodes: [],
          totalCount: 0,
          pageInfo: null,
        };
      if (status === 'error') state.sources.accounts.error = 'Access denied';
      render(
        <MemoryRouter>
          <SearchResults handle={state} resultLayout="table" />
        </MemoryRouter>
      );
      expect(screen.queryByRole('table')).not.toBeInTheDocument();
      if (status === 'loading')
        expect(screen.getByRole('status')).toHaveTextContent('Searching');
      if (status === 'empty')
        expect(screen.getByText('No accounts found.', { selector: 'p:not(.sr-only)' })).toBeInTheDocument();
      if (status === 'error')
        expect(screen.getByRole('alert')).toHaveTextContent('Access denied');
    }
  );
});
