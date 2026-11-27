import { cleanup, render, screen } from '@testing-library/react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Search } from './Search';
import type { SearchConfig } from '../types';

const mocks = vi.hoisted(() => ({
  useSearch: vi.fn(),
  results: vi.fn(),
  mergedResults: vi.fn(),
}));

vi.mock('../hooks/useSearch', () => ({ useSearch: mocks.useSearch }));
vi.mock('./SearchResults', () => ({
  SearchResults: (props: unknown) => {
    mocks.results(props);
    return <section aria-label="Search results">Example account</section>;
  },
}));
vi.mock('./MergedSearchResults', () => ({
  MergedSearchResults: (props: unknown) => {
    mocks.mergedResults(props);
    return <section aria-label="Merged results">Example merged result</section>;
  },
}));

const config: SearchConfig = {
  sources: [
    {
      kind: 'sobject',
      key: 'accounts',
      objectName: 'Account',
      label: 'Accounts',
      searchableFields: ['Name'],
      displayFields: ['Name'],
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

beforeEach(() => {
  vi.clearAllMocks();
  mocks.useSearch.mockReturnValue({
    q: 'EAH Child',
    setQ: vi.fn(),
    scope: 'all',
    setScope: vi.fn(),
    scopeLocked: false,
    discoveredContentTypes: [],
    sources: { accounts: { result: { totalCount: 6 } } },
    loading: false,
    error: null,
  });
});

afterEach(cleanup);

describe('search query input placement', () => {
  it('keeps the query input by default for other search consumers', () => {
    render(<Search config={config} />);
    expect(screen.getByRole('textbox', { name: 'Unified search' })).toHaveValue(
      'EAH Child'
    );
    expect(
      screen.getByRole('combobox', { name: 'Search scope' })
    ).toBeInTheDocument();
  });

  it('hides only the body query input while retaining scope, counts, and result/filter wiring', () => {
    const renderFilters = { accounts: () => <div>Account filters</div> };
    render(
      <Search
        as="main"
        config={config}
        title="Search Results"
        showSearchBar={false}
        resultLayout="table"
        renderFilters={renderFilters}
      />
    );
    expect(
      screen.getByRole('heading', { name: 'Search Results', level: 1 })
    ).toBeInTheDocument();
    expect(
      screen.queryByRole('textbox', { name: 'Unified search' })
    ).not.toBeInTheDocument();
    expect(screen.getByRole('main')).toContainElement(
      screen.getByRole('region', { name: 'Search results' })
    );
    expect(
      screen.getByRole('combobox', { name: 'Search scope' })
    ).toBeInTheDocument();
    expect(screen.getByRole('status')).toHaveTextContent('6 total results');
    expect(mocks.results).toHaveBeenCalledWith(
      expect.objectContaining({
        handle: mocks.useSearch.mock.results[0].value,
        renderFilters,
        resultLayout: 'table',
      })
    );
  });

  it('can hide both the query input and scope without hiding results', () => {
    render(
      <Search config={config} showSearchBar={false} showScopeSelector={false} />
    );
    expect(screen.queryByRole('textbox')).not.toBeInTheDocument();
    expect(screen.queryByRole('combobox')).not.toBeInTheDocument();
    expect(
      screen.getByRole('region', { name: 'Search results' })
    ).toBeInTheDocument();
  });

  it('retains the merged results layout when the query input is hidden', () => {
    render(
      <Search
        config={{
          ...config,
          pagination: {
            mode: 'merged',
            pageSize: 10,
            pageSizeOptions: [10, 25],
          },
        }}
        showSearchBar={false}
      />
    );
    expect(screen.queryByRole('textbox')).not.toBeInTheDocument();
    expect(
      screen.getByRole('region', { name: 'Merged results' })
    ).toBeInTheDocument();
    expect(mocks.results).not.toHaveBeenCalled();
  });
});
