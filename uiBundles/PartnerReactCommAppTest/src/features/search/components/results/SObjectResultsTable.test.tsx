import { cleanup, render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { SObjectResultsTable } from './SObjectResultsTable';
import { DefaultResultRow } from './DefaultResultRow';
import { readPath, resolveRoute } from '../../utils/resultUtils';
import type { SObjectSourceConfig } from '../../types';

afterEach(cleanup);

const source: SObjectSourceConfig = {
  kind: 'sobject',
  key: 'accounts',
  objectName: 'Account',
  label: 'Accounts',
  routePattern: '/accounts/:id',
  searchableFields: ['Name'],
  displayFields: [
    'Name',
    'AnnualRevenue',
    { name: 'Enabled', raw: true },
    {
      name: 'Owner',
      subfields: ['Name', { name: 'Manager', subfields: ['Name'] }],
    },
    'Phone',
  ],
  sortBy: [
    { field: 'Name', label: 'Name' },
    { field: 'AnnualRevenue', label: 'Annual Revenue' },
  ],
};

const record = {
  Id: 'a/b',
  Name: { value: 'Raw account', displayValue: 'Display account' },
  AnnualRevenue: { value: 0 },
  Enabled: false,
  Owner: {
    Name: { value: 'Owner name' },
    Manager: { Name: { value: 'Manager name' } },
  },
  Phone: null,
};

describe('object result tables', () => {
  it('shows one column per retrieved field, including nested fields and raw values', () => {
    render(
      <MemoryRouter
        basename="/MyReactCommunityApp"
        initialEntries={['/MyReactCommunityApp/search']}
      >
        <SObjectResultsTable
          source={source}
          nodes={[record]}
          sort={null}
          onSortChange={vi.fn()}
        />
      </MemoryRouter>
    );
    const table = screen.getByRole('table', {
      name: 'Accounts search results',
    });
    const headers = within(table).getAllByRole('columnheader');
    expect(headers.map(header => header.textContent)).toEqual([
      'Account Name',
      'Annual Revenue',
      'Enabled',
      'Owner Name',
      'Owner Manager Name',
      'Phone',
    ]);
    expect(
      within(table)
        .getAllByRole('cell')
        .map(cell => cell.textContent)
    ).toEqual([
      'Display account',
      '0',
      'false',
      'Owner name',
      'Manager name',
      '—',
    ]);
    expect(
      screen.getByRole('link', { name: 'Display account' })
    ).toHaveAttribute('href', '/MyReactCommunityApp/accounts/a%2Fb');
  });

  it('uses the existing sort callback only for configured sortable columns', async () => {
    const user = userEvent.setup();
    const setSort = vi.fn();
    const { rerender } = render(
      <MemoryRouter>
        <SObjectResultsTable
          source={source}
          nodes={[record]}
          sort={null}
          onSortChange={setSort}
        />
      </MemoryRouter>
    );
    expect(screen.getAllByRole('button')).toHaveLength(2);
    await user.click(
      screen.getByRole('button', { name: 'Sort Account Name ascending' })
    );
    expect(setSort).toHaveBeenLastCalledWith({
      field: 'Name',
      direction: 'ASC',
    });
    rerender(
      <MemoryRouter>
        <SObjectResultsTable
          source={source}
          nodes={[record]}
          sort={{ field: 'Name', direction: 'ASC' }}
          onSortChange={setSort}
        />
      </MemoryRouter>
    );
    const header = screen.getAllByRole('columnheader')[0];
    expect(header).toHaveAttribute('aria-sort', 'ascending');
    await user.click(
      screen.getByRole('button', { name: 'Sort Account Name descending' })
    );
    expect(setSort).toHaveBeenLastCalledWith({
      field: 'Name',
      direction: 'DESC',
    });
  });

  it('shows missing relationship values without inventing record links', () => {
    render(
      <MemoryRouter>
        <SObjectResultsTable
          source={source}
          nodes={[{ Name: { value: 'No ID' }, Owner: null }]}
          sort={null}
          onSortChange={vi.fn()}
        />
      </MemoryRouter>
    );
    expect(screen.queryByRole('link')).not.toBeInTheDocument();
    expect(
      screen
        .getAllByRole('cell')
        .slice(1)
        .every(cell => cell.textContent === '—')
    ).toBe(true);
  });

  it("preserves the default list renderer's display values and links after helper extraction", () => {
    render(
      <MemoryRouter>
        <DefaultResultRow node={record} source={source} />
      </MemoryRouter>
    );
    const link = screen.getByRole('link', { name: 'View: Display account' });
    expect(link).toHaveAttribute('href', '/accounts/a%2Fb');
    expect(link).toHaveTextContent('0 · false · Owner name');
  });

  it('handles missing paths and route tokens without throwing', () => {
    expect(readPath(null, 'Owner.Name')).toBeNull();
    expect(readPath({ Owner: null }, 'Owner.Name')).toBeNull();
    expect(
      resolveRoute('/accounts/:id', { Name: { value: 'No ID' } }, 'Id')
    ).toBeNull();
  });
});
