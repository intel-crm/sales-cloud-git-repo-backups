import {
  act,
  cleanup,
  render,
  screen,
  waitFor,
  within,
} from '@testing-library/react';
import { MemoryRouter } from 'react-router';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { HomeDashboardCards } from './HomeDashboardCards';
import { PartnerAccountProvider } from '../features/partner/context/PartnerAccountContext';

const mocks = vi.hoisted(() => ({ query: vi.fn(), useAuth: vi.fn() }));
vi.mock('@salesforce/platform-sdk', () => ({
  createDataSDK: vi.fn(async () => ({ graphql: { query: mocks.query } })),
}));
vi.mock('../features/authentication/context/AuthContext', () => ({
  useAuth: mocks.useAuth,
}));

function userResponse(
  isPartner = true,
  accountId: string | null = 'account-1'
) {
  return {
    data: {
      uiapi: {
        query: {
          User: {
            edges: [
              {
                node: {
                  Id: 'user-1',
                  IsPartner: { value: isPartner },
                  AccountId: { value: accountId },
                },
              },
            ],
          },
        },
      },
    },
  };
}

function accountResponse(
  tier: string | null = 'Elite',
  roles: string | null = 'Distributor;Reseller;Integrator',
  accountId = 'account-1'
) {
  return {
    data: {
      uiapi: {
        query: {
          Account: {
            edges: [
              {
                node: {
                  Id: accountId,
                  Core_IPA_Badge_Tier__c: { value: tier },
                  Core_IPA_Partner_Role__c: { value: roles },
                },
              },
            ],
          },
        },
      },
    },
  };
}

function mockUser(isPartner = true, accountId: string | null = 'account-1') {
  mocks.query.mockReset();
  mocks.query.mockResolvedValueOnce(userResponse(isPartner, accountId));
  mocks.query.mockResolvedValueOnce(accountResponse());
}

function cards() {
  return (
    <MemoryRouter
      basename="/MyReactCommunityApp"
      initialEntries={['/MyReactCommunityApp']}
    >
      <PartnerAccountProvider>
        <HomeDashboardCards
          pipelineValue="$42,000.00"
          loading={false}
          error={null}
        />
      </PartnerAccountProvider>
    </MemoryRouter>
  );
}

beforeEach(() => {
  vi.spyOn(console, 'warn').mockImplementation(() => {});
  mocks.useAuth.mockReset();
  mocks.useAuth.mockReturnValue({
    user: { id: 'user-1', name: 'Ravi' },
    isAuthenticated: true,
    loading: false,
    error: null,
  });
  mockUser();
});

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

describe('live Prestige card', () => {
  it("queries only the signed-in user's partner flag and linked Account, then displays its tier and first role", async () => {
    render(cards());
    const card = screen.getByRole('region', { name: 'Partner-Tier' });
    expect(await within(card).findByText('Elite')).toBeInTheDocument();
    const role = within(card).getByText('Distributor');
    expect(role).toHaveAttribute('title', 'Distributor; Reseller; Integrator');
    expect(role).toHaveAccessibleName(
      'Partner roles: Distributor; Reseller; Integrator'
    );
    expect(role).toHaveAttribute('tabindex', '0');
    expect(
      within(card).queryByText('Reseller', { exact: true })
    ).not.toBeInTheDocument();
    expect(within(card).getByRole('heading', { name: 'Partner-Tier' })).toBeInTheDocument();
    expect(
      within(card).getByRole('link', { name: 'View account details' })
    ).toHaveAttribute('href', '/MyReactCommunityApp/accounts/account-1');
    expect(mocks.query).toHaveBeenCalledTimes(2);
    expect(mocks.query.mock.calls[0][0]).toEqual(
      expect.objectContaining({
        query: expect.stringContaining('IsPartner'),
        variables: { userId: 'user-1' },
      })
    );
    expect(mocks.query.mock.calls[1][0]).toEqual(
      expect.objectContaining({
        query: expect.stringContaining('Core_IPA_Badge_Tier__c'),
        variables: { accountId: 'account-1' },
      })
    );
    expect(mocks.query.mock.calls[1][0].query).toContain(
      'Core_IPA_Partner_Role__c'
    );
  });

  it('trims roles and displays the first nonempty value', async () => {
    mocks.query
      .mockReset()
      .mockResolvedValueOnce(userResponse())
      .mockResolvedValueOnce(
        accountResponse(' Gold ', ' ; Distributor ; ; Reseller ; ')
      );
    render(cards());
    const card = screen.getByRole('region', { name: 'Partner-Tier' });
    expect(await within(card).findByText('Gold')).toBeInTheDocument();
    expect(within(card).getByText('Distributor')).toHaveAttribute(
      'title',
      'Distributor; Reseller'
    );
  });

  it.each([null, 'another-account'])(
    'uses the designated Account for non-partners regardless of their AccountId (%s)',
    async userAccountId => {
      mocks.query
        .mockReset()
        .mockResolvedValueOnce(userResponse(false, userAccountId))
        .mockResolvedValueOnce(
          accountResponse('Gold', 'Reseller;Distributor', '0018A00000UdIm5QAF')
        );
      render(cards());
      const card = screen.getByRole('region', { name: 'Partner-Tier' });
      expect(await within(card).findByText('Gold')).toBeInTheDocument();
      expect(within(card).getByText('Reseller')).toHaveAttribute(
        'title',
        'Reseller; Distributor'
      );
      expect(
        within(card).getByRole('link', { name: 'View account details' })
      ).toHaveAttribute(
        'href',
        '/MyReactCommunityApp/accounts/0018A00000UdIm5QAF'
      );
      expect(mocks.query).toHaveBeenCalledTimes(2);
      expect(mocks.query.mock.calls[1][0].variables).toEqual({
        accountId: '0018A00000UdIm5QAF',
      });
      expect(
        within(card).queryByText('Not applicable')
      ).not.toBeInTheDocument();
    }
  );

  it.each([
    { errors: [{ message: 'Account access denied' }] },
    { data: { uiapi: { query: { Account: { edges: [] } } } } },
  ])(
    'shows an explicit error if the non-partner Account is inaccessible',
    async accountResult => {
      vi.spyOn(console, 'error').mockImplementation(() => {});
      mocks.query
        .mockReset()
        .mockResolvedValueOnce(userResponse(false, null))
        .mockResolvedValueOnce(accountResult);
      render(cards());
      const card = screen.getByRole('region', { name: 'Partner-Tier' });
      expect(await within(card).findByRole('alert')).not.toBeEmptyDOMElement();
      expect(within(card).getByText('Unavailable')).toBeInTheDocument();
      expect(
        within(card).queryByText('Not applicable')
      ).not.toBeInTheDocument();
      expect(within(card).queryByRole('link')).not.toBeInTheDocument();
    }
  );

  it('does not query Salesforce for guests', async () => {
    mocks.useAuth.mockReturnValue({
      user: null,
      isAuthenticated: false,
      loading: false,
      error: null,
    });
    render(cards());
    expect(await screen.findByText('Not applicable')).toBeInTheDocument();
    expect(mocks.query).not.toHaveBeenCalled();
  });

  it('waits for authentication before querying partner information', () => {
    mocks.useAuth.mockReturnValue({
      user: null,
      isAuthenticated: false,
      loading: true,
      error: null,
    });
    render(cards());
    const card = screen.getByRole('region', { name: 'Partner-Tier' });
    expect(within(card).getByText('Loading...')).toBeInTheDocument();
    expect(within(card).queryByText('Not applicable')).not.toBeInTheDocument();
    expect(mocks.query).not.toHaveBeenCalled();
  });

  it('uses the default Account when the partner has no linked Account', async () => {
    mocks.query
      .mockReset()
      .mockResolvedValueOnce(userResponse(true, null))
      .mockResolvedValueOnce(
        accountResponse('Gold', 'Reseller', '0018A00000UdIm5QAF')
      );
    render(cards());
    expect(await screen.findByText('Gold')).toBeInTheDocument();
    expect(screen.getByText('Using default account')).toBeInTheDocument();
    expect(mocks.query.mock.calls[1][0].variables).toEqual({
      accountId: '0018A00000UdIm5QAF',
    });
    expect(console.warn).toHaveBeenCalledTimes(1);
  });

  it.each([
    [null, 'Distributor'],
    ['Gold', null],
    ['  ', 'Distributor'],
    ['Gold', '; ;'],
  ])(
    'uses the default Account if either partner field is blank (%s, %s)',
    async (tier, roles) => {
      mocks.query
        .mockReset()
        .mockResolvedValueOnce(userResponse())
        .mockResolvedValueOnce(accountResponse(tier, roles))
        .mockResolvedValueOnce(
          accountResponse('Default Tier', 'Reseller', '0018A00000UdIm5QAF')
        );
      render(cards());
      expect(await screen.findByText('Default Tier')).toBeInTheDocument();
      expect(screen.getByText('Using default account')).toBeInTheDocument();
      expect(screen.getByRole('heading', { name: 'Partner-Tier' })).toBeInTheDocument();
      expect(mocks.query.mock.calls[2][0].variables).toEqual({
        accountId: '0018A00000UdIm5QAF',
      });
    }
  );

  it.each([
    { errors: [{ message: 'Field access denied' }] },
    { data: { uiapi: { query: { Account: { edges: [] } } } } },
    {
      data: {
        uiapi: {
          query: { Account: { edges: [{ node: { Id: 'account-1' } }] } },
        },
      },
    },
  ])(
    'falls back with a visible notice when linked Account data cannot be read',
    async accountResult => {
      vi.spyOn(console, 'error').mockImplementation(() => {});
      mocks.query
        .mockReset()
        .mockResolvedValueOnce(userResponse())
        .mockResolvedValueOnce(accountResult)
        .mockResolvedValueOnce(
          accountResponse('Default Tier', 'Reseller', '0018A00000UdIm5QAF')
        );
      render(cards());
      const card = screen.getByRole('region', { name: 'Partner-Tier' });
      expect(await within(card).findByText('Default Tier')).toBeInTheDocument();
      expect(within(card).getByRole('status')).toHaveTextContent(
        'Using default account'
      );
      expect(mocks.query).toHaveBeenCalledTimes(3);
      expect(within(card).getByRole('heading', { name: 'Partner-Tier' })).toBeInTheDocument();
      expect(
        screen.getByRole('region', { name: 'Opportunity Pipeline' })
      ).toHaveTextContent('$42,000.00');
    }
  );

  it("uses the default Account when the user's partner status is inaccessible", async () => {
    vi.spyOn(console, 'error').mockImplementation(() => {});
    mocks.query
      .mockReset()
      .mockResolvedValueOnce({
        data: { uiapi: { query: { User: { edges: [] } } } },
      })
      .mockResolvedValueOnce(
        accountResponse('Default Tier', 'Reseller', '0018A00000UdIm5QAF')
      );
    render(cards());
    expect(await screen.findByText('Default Tier')).toBeInTheDocument();
    expect(screen.getByRole('status')).toHaveAttribute(
      'title',
      "The current user's partner status could not be read."
    );
    expect(mocks.query).toHaveBeenCalledTimes(2);
  });

  it('surfaces default Account failures without retrying indefinitely', async () => {
    vi.spyOn(console, 'error').mockImplementation(() => {});
    mocks.query
      .mockReset()
      .mockResolvedValueOnce(userResponse())
      .mockResolvedValueOnce({ errors: [{ message: 'Partner access denied' }] })
      .mockResolvedValueOnce({
        errors: [{ message: 'Default access denied' }],
      });
    render(cards());
    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Default access denied'
    );
    expect(
      screen.queryByRole('link', { name: 'View account details' })
    ).not.toBeInTheDocument();
    expect(mocks.query).toHaveBeenCalledTimes(3);
  });

  it('discards a late Account response if the user signs out', async () => {
    let resolveAccount:
      ((result: ReturnType<typeof accountResponse>) => void) | undefined;
    const pending = new Promise<ReturnType<typeof accountResponse>>(resolve => {
      resolveAccount = resolve;
    });
    mocks.query
      .mockReset()
      .mockResolvedValueOnce(userResponse())
      .mockReturnValueOnce(pending);
    const { rerender } = render(cards());
    await waitFor(() => expect(mocks.query).toHaveBeenCalledTimes(2));
    mocks.useAuth.mockReturnValue({
      user: null,
      isAuthenticated: false,
      loading: false,
      error: null,
    });
    rerender(cards());
    expect(await screen.findByText('Not applicable')).toBeInTheDocument();
    await act(async () => {
      if (!resolveAccount) throw new Error('Account request did not start');
      resolveAccount(accountResponse());
    });
    expect(screen.getByText('Not applicable')).toBeInTheDocument();
    expect(screen.queryByText('Elite')).not.toBeInTheDocument();
  });
});
