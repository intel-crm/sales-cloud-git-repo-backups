import { cleanup, render, screen, within } from '@testing-library/react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { NativeOpportunityList } from './OpportunityList';

const query = vi.hoisted(() => vi.fn());
vi.mock('@salesforce/platform-sdk', () => ({
  createDataSDK: vi.fn(async () => ({ graphql: { query } })),
}));
vi.mock('../features/partner/context/PartnerAccountContext', () => ({
  usePartnerAccount: () => ({
    account: {
      kind: 'ready',
      accountId: 'account-1',
      badgeTier: 'Gold',
      roles: ['Distributor'],
    },
    loading: false,
    error: null,
  }),
}));

beforeEach(() => {
  query.mockReset();
});

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

function response(totalCount: number | undefined, edges: unknown[] = []) {
  return { data: { uiapi: { query: { Opportunity: { totalCount, edges } } } } };
}

describe('opportunity count card', () => {
  it('uses the total count, not the number of loaded records, and retains the list', async () => {
    query.mockResolvedValue(
      response(42, [
        {
          node: {
            Id: 'opp-1',
            Name: { value: 'Example opportunity' },
            StageName: { value: 'Qualification' },
            Amount: { value: 100 },
            CloseDate: { value: '2026-12-01' },
            Account: null,
          },
        },
      ])
    );
    render(<NativeOpportunityList />);
    const card = await screen.findByRole('region', {
      name: 'Total Opportunities',
    });
    expect(within(card).getByText('42')).toBeInTheDocument();
    expect(screen.getByText('Example opportunity')).toBeInTheDocument();
    const request = query.mock.calls[0][0];
    expect(request.variables).toEqual({
      first: 10,
      where: { AccountId: { eq: 'account-1' } },
    });
    expect(request.query).toContain('totalCount');
    expect(request.query).toContain('where: $where');
  });

  it('shows zero and an empty state for a successful empty response', async () => {
    query.mockResolvedValue(response(0));
    render(<NativeOpportunityList />);
    const card = await screen.findByRole('region', {
      name: 'Total Opportunities',
    });
    expect(within(card).getByText('0')).toBeInTheDocument();
    expect(screen.getByText('No opportunities found.')).toBeInTheDocument();
  });

  it('shows loading rather than a zero count while the request is pending', () => {
    query.mockReturnValue(new Promise(() => {}));
    render(<NativeOpportunityList />);
    expect(
      screen.getByText('Loading opportunity records...')
    ).toBeInTheDocument();
    expect(screen.queryByRole('region')).not.toBeInTheDocument();
  });

  it.each([
    { errors: [{ message: 'Access denied' }] },
    response(undefined),
    { data: null },
  ])(
    'shows an error instead of an invented count for a failed response',
    async result => {
      vi.spyOn(console, 'error').mockImplementation(() => {});
      query.mockResolvedValue(result);
      render(<NativeOpportunityList />);
      expect(await screen.findByRole('alert')).not.toBeEmptyDOMElement();
      expect(screen.queryByRole('region')).not.toBeInTheDocument();
    }
  );
});
