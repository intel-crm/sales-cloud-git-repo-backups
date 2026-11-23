import { act, cleanup, render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { PartnerAccountProvider } from '../features/partner/context/PartnerAccountContext';
import HomePage from './Home';
import OpportunitiesPage from './Opportunities';

const mocks = vi.hoisted(() => ({ query: vi.fn(), auth: vi.fn() }));
vi.mock('@salesforce/platform-sdk', () => ({
  createDataSDK: vi.fn(async () => ({ graphql: { query: mocks.query } })),
}));
vi.mock('../features/authentication/context/AuthContext', () => ({
  useAuth: mocks.auth,
}));

const defaultId = '0018A00000UdIm5QAF';
interface Request {
  query: string;
  variables: {
    userId?: string;
    accountId?: string;
    where?: { AccountId: { eq: string } } | null;
  };
}

function response({ query, variables }: Request) {
  const accountId = variables.accountId ?? variables.where?.AccountId.eq;
  const amount =
    accountId === defaultId
      ? 5000
      : accountId === 'second-account'
        ? 8000
        : 2000;
  const displayValue = `$${amount.toLocaleString('en-US')}.00`;
  const count =
    accountId === defaultId ? 3 : accountId === 'second-account' ? 4 : 2;
  if (query.includes('GetPartnerUserAccount')) {
    return {
      data: {
        uiapi: {
          query: {
            User: {
              edges: [
                {
                  node: {
                    Id: variables.userId,
                    IsPartner: { value: true },
                    AccountId: {
                      value:
                        variables.userId === 'user-2'
                          ? 'second-account'
                          : 'linked-account',
                    },
                  },
                },
              ],
            },
          },
        },
      },
    };
  }
  if (query.includes('GetPartnerAccountTier')) {
    return {
      data: {
        uiapi: {
          query: {
            Account: {
              edges: [
                {
                  node: {
                    Id: accountId,
                    Core_IPA_Badge_Tier__c: {
                      value:
                        accountId === defaultId
                          ? 'Default Tier'
                          : 'Linked Tier',
                    },
                    Core_IPA_Partner_Role__c: { value: 'Distributor;Reseller' },
                  },
                },
              ],
            },
          },
        },
      },
    };
  }
  if (query.includes('GetOpportunityStageAmounts')) {
    return {
      data: {
        uiapi: {
          aggregate: {
            Opportunity: {
              edges: [
                {
                  node: {
                    aggregate: {
                      StageName: {
                        value: 'Qualification',
                        label: 'Qualification',
                      },
                      Amount: { sum: { value: amount, displayValue } },
                      Id: { count: { value: count } },
                    },
                  },
                },
              ],
              pageInfo: { hasNextPage: false, endCursor: null },
            },
            pipelineTotal: {
              edges: [
                {
                  node: {
                    aggregate: {
                      Amount: { sum: { value: amount, displayValue } },
                    },
                  },
                },
              ],
            },
          },
        },
      },
    };
  }
  return {
    data: {
      uiapi: {
        query: {
          Opportunity: {
            totalCount: count,
            edges: [
              {
                node: {
                  Id: `opportunity-${accountId}`,
                  Name: { value: `Opportunity for ${accountId}` },
                  StageName: { value: 'Qualification' },
                  Amount: { value: amount },
                  CloseDate: { value: '2026-12-01' },
                  Account: null,
                },
              },
            ],
          },
        },
      },
    },
  };
}

function content(page: 'Home' | 'Opportunities') {
  return (
    <MemoryRouter>
      <PartnerAccountProvider>
        {page === 'Home' ? <HomePage /> : <OpportunitiesPage />}
      </PartnerAccountProvider>
    </MemoryRouter>
  );
}

function opportunityCalls() {
  return mocks.query.mock.calls
    .map(([request]) => request as Request)
    .filter(
      request =>
        request.query.includes('getOpportunities') ||
        request.query.includes('GetOpportunityStageAmounts')
    );
}

beforeEach(() => {
  mocks.auth.mockReset().mockReturnValue({
    user: { id: 'user-1', name: 'Partner User' },
    isAuthenticated: true,
    loading: false,
    error: null,
  });
  mocks.query.mockReset().mockImplementation(response);
  vi.spyOn(console, 'warn').mockImplementation(() => {});
  vi.spyOn(console, 'error').mockImplementation(() => {});
});
afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

describe('shared partner account opportunity scope', () => {
  it.each(['Home', 'Opportunities'] as const)(
    'scopes every %s opportunity request to the linked Account and resolves it only once',
    async page => {
      render(content(page));
      await screen.findByLabelText('Total pipeline value: $2,000.00');
      await waitFor(() =>
        expect(opportunityCalls()).toHaveLength(page === 'Home' ? 1 : 2)
      );
      for (const request of opportunityCalls()) {
        expect(request.variables.where).toEqual({
          AccountId: { eq: 'linked-account' },
        });
        expect(request.query).toContain('where: $where');
      }
      expect(
        mocks.query.mock.calls.filter(([request]) =>
          request.query.includes('GetPartnerUserAccount')
        )
      ).toHaveLength(1);
      expect(
        mocks.query.mock.calls.filter(([request]) =>
          request.query.includes('GetPartnerAccountTier')
        )
      ).toHaveLength(1);
      if (page === 'Home') {
        expect(screen.getByText('Linked Tier')).toBeInTheDocument();
        const overview = screen.getByRole('region', {
          name: 'Partner overview',
        });
        expect(overview).toHaveTextContent('$2,000.00');
        expect(opportunityCalls()[0].query).toContain(
          'GetOpportunityStageAmounts'
        );
      } else
        expect(
          await screen.findByText('Opportunity for linked-account')
        ).toBeInTheDocument();
    }
  );

  it.each(['Home', 'Opportunities'] as const)(
    'uses the default Account for both %s views after a GraphQL partner lookup failure',
    async page => {
      mocks.query.mockImplementation((request: Request) =>
        request.query.includes('GetPartnerUserAccount')
          ? { errors: [{ message: 'User field access denied' }] }
          : response(request)
      );
      render(content(page));
      await screen.findByLabelText('Total pipeline value: $5,000.00');
      expect(
        screen.getByText(
          'Using default account for partner details and opportunities.'
        )
      ).toBeInTheDocument();
      await waitFor(() =>
        expect(opportunityCalls()).toHaveLength(page === 'Home' ? 1 : 2)
      );
      expect(
        opportunityCalls().every(
          request => request.variables.where?.AccountId.eq === defaultId
        )
      ).toBe(true);
      expect(console.warn).toHaveBeenCalledTimes(1);
      if (page === 'Home')
        expect(screen.getByText('Default Tier')).toBeInTheDocument();
      else
        expect(
          await screen.findByText(`Opportunity for ${defaultId}`)
        ).toBeInTheDocument();
    }
  );

  it.each(['Home', 'Opportunities'] as const)(
    'shows the default tier but all accessible opportunities on %s for non-partners',
    async page => {
      mocks.query.mockImplementation((request: Request) => {
        const result = response(request);
        if (request.query.includes('GetPartnerUserAccount')) {
          const user = result.data.uiapi.query?.User?.edges[0]?.node;
          if (!user) throw new Error('Missing mock User');
          user.IsPartner.value = false;
        }
        return result;
      });
      render(content(page));
      await screen.findByLabelText('Total pipeline value: $2,000.00');
      await waitFor(() =>
        expect(opportunityCalls()).toHaveLength(page === 'Home' ? 1 : 2)
      );
      for (const request of opportunityCalls()) {
        expect(request.variables.where).toBeNull();
        expect(request.query).toContain('where: $where');
      }
      const accountCalls = mocks.query.mock.calls.filter(([request]) =>
        request.query.includes('GetPartnerAccountTier')
      );
      expect(accountCalls).toHaveLength(1);
      expect(accountCalls[0][0].variables.accountId).toBe(defaultId);
      expect(
        screen.queryByText(
          'Using default account for partner details and opportunities.'
        )
      ).not.toBeInTheDocument();
      expect(
        screen.getAllByText('Across all stages, visible to you')
      ).toHaveLength(2);
      if (page === 'Home')
        expect(screen.getByText('Default Tier')).toBeInTheDocument();
      else
        expect(
          screen.getByText('Opportunity for undefined')
        ).toBeInTheDocument();
    }
  );

  it('does not issue unscoped opportunity requests while account resolution is pending', () => {
    mocks.query.mockReturnValue(new Promise(() => {}));
    render(content('Home'));
    expect(opportunityCalls()).toHaveLength(0);
    expect(screen.queryByText('Default Tier')).not.toBeInTheDocument();
    expect(
      screen.getByText('Loading opportunity stage totals...')
    ).toBeInTheDocument();
  });

  it('does not load opportunities when the default Account is also inaccessible', async () => {
    mocks.query.mockImplementation((request: Request) =>
      request.query.includes('GetPartnerUserAccount')
        ? { errors: [{ message: 'User access denied' }] }
        : { errors: [{ message: 'Default account access denied' }] }
    );
    render(content('Home'));
    await waitFor(() =>
      expect(screen.getAllByRole('alert').length).toBeGreaterThan(0)
    );
    expect(
      screen
        .getAllByRole('alert')
        .some(alert =>
          alert.textContent?.includes('Default account access denied')
        )
    ).toBe(true);
    expect(opportunityCalls()).toHaveLength(0);
    expect(mocks.query).toHaveBeenCalledTimes(2);
  });

  it('leaves guests not applicable without querying accounts or opportunities', async () => {
    mocks.auth.mockReturnValue({
      user: null,
      isAuthenticated: false,
      loading: false,
      error: null,
    });
    render(content('Home'));
    expect(await screen.findByText('Not applicable')).toBeInTheDocument();
    expect(
      screen.getAllByText('Sign in to view account opportunities.')
    ).toHaveLength(1);
    expect(mocks.query).not.toHaveBeenCalled();
  });

  it('discards late list and chart responses belonging to a previous user', async () => {
    let resolveList: ((data: ReturnType<typeof response>) => void) | undefined;
    let resolveChart: ((data: ReturnType<typeof response>) => void) | undefined;
    mocks.query.mockImplementation((request: Request) => {
      if (
        request.variables.where?.AccountId.eq === 'linked-account' &&
        request.query.includes('getOpportunities')
      ) {
        return new Promise<ReturnType<typeof response>>(resolve => {
          resolveList = resolve;
        });
      }
      if (
        request.variables.where?.AccountId.eq === 'linked-account' &&
        request.query.includes('GetOpportunityStageAmounts')
      ) {
        return new Promise<ReturnType<typeof response>>(resolve => {
          resolveChart = resolve;
        });
      }
      return response(request);
    });
    const { rerender } = render(content('Opportunities'));
    await waitFor(() => expect(opportunityCalls()).toHaveLength(2));
    mocks.auth.mockReturnValue({
      user: { id: 'user-2', name: 'Second User' },
      isAuthenticated: true,
      loading: false,
      error: null,
    });
    rerender(content('Opportunities'));
    await screen.findByText('Opportunity for second-account');
    await screen.findByLabelText('Total pipeline value: $8,000.00');
    await act(async () => {
      if (!resolveList || !resolveChart)
        throw new Error('Old account requests did not start');
      resolveList(
        response({
          query: 'getOpportunities',
          variables: { accountId: 'linked-account' },
        })
      );
      resolveChart(
        response({
          query: 'GetOpportunityStageAmounts',
          variables: { accountId: 'linked-account' },
        })
      );
    });
    expect(
      screen.queryByText('Opportunity for linked-account')
    ).not.toBeInTheDocument();
    expect(
      screen.queryByLabelText('Total pipeline value: $2,000.00')
    ).not.toBeInTheDocument();
    expect(
      screen.getByLabelText('Total pipeline value: $8,000.00')
    ).toBeInTheDocument();
  });
});
