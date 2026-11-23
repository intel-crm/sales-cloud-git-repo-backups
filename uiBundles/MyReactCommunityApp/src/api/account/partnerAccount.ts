import { executeGraphQL } from '../graphqlClient';

const DEFAULT_PARTNER_ACCOUNT_ID = '0018A00000UdIm5QAF';

const PARTNER_USER_QUERY = `
  query GetPartnerUserAccount($userId: ID!) {
    uiapi {
      query {
        User(first: 1, where: { Id: { eq: $userId } }) {
          edges { node { Id IsPartner { value } AccountId { value } } }
        }
      }
    }
  }
`;

const PARTNER_ACCOUNT_QUERY = `
  query GetPartnerAccountTier($accountId: ID!) {
    uiapi {
      query {
        Account(first: 1, where: { Id: { eq: $accountId } }) {
          edges {
            node {
              Id
              Core_IPA_Badge_Tier__c { value }
              Core_IPA_Partner_Role__c { value }
            }
          }
        }
      }
    }
  }
`;

export type PartnerAccount =
  | { kind: 'not-applicable' }
  | {
      kind: 'ready';
      accountId: string;
      badgeTier: string;
      roles: string[];
      opportunityScope: 'account' | 'all-accessible';
      fallbackReason?: string;
    };

interface PartnerUserResponse {
  uiapi?: {
    query?: {
      User?: {
        edges?: {
          node?: {
            Id?: string;
            IsPartner?: { value?: boolean | null } | null;
            AccountId?: { value?: string | null } | null;
          };
        }[];
      };
    };
  };
}

interface PartnerAccountResponse {
  uiapi?: {
    query?: {
      Account?: {
        edges?: {
          node?: {
            Id?: string;
            Core_IPA_Badge_Tier__c?: { value?: string | null } | null;
            Core_IPA_Partner_Role__c?: { value?: string | null } | null;
          };
        }[];
      };
    };
  };
}

export async function fetchPartnerAccount(
  userId: string
): Promise<PartnerAccount> {
  let fallbackReason: string | undefined;
  try {
    const userData = await executeGraphQL<
      PartnerUserResponse,
      { userId: string }
    >(PARTNER_USER_QUERY, { userId });
    const user = userData.uiapi?.query?.User?.edges?.[0]?.node;
    if (user?.Id !== userId || typeof user.IsPartner?.value !== 'boolean') {
      throw new Error("The current user's partner status could not be read.");
    }
    if (user.IsPartner.value) {
      const accountId = user.AccountId?.value;
      if (typeof accountId !== 'string' || !accountId.trim()) {
        throw new Error("The partner user's linked account could not be read.");
      }
      const account = await fetchAccountDetails(accountId);
      if (!account.badgeTier || account.roles.length === 0) {
        throw new Error(
          'The linked account has no badge tier or partner roles.'
        );
      }
      return account;
    }
  } catch (error: unknown) {
    fallbackReason =
      error instanceof Error ? error.message : 'Partner account lookup failed.';
    console.warn(
      'Using the default partner account after a failed partner lookup:',
      error
    );
  }

  const account = await fetchAccountDetails(DEFAULT_PARTNER_ACCOUNT_ID);
  return {
    ...account,
    opportunityScope: fallbackReason ? 'account' : 'all-accessible',
    fallbackReason,
  };
}

async function fetchAccountDetails(
  accountId: string
): Promise<Extract<PartnerAccount, { kind: 'ready' }>> {
  const accountData = await executeGraphQL<
    PartnerAccountResponse,
    { accountId: string }
  >(PARTNER_ACCOUNT_QUERY, { accountId });
  const account = accountData.uiapi?.query?.Account?.edges?.[0]?.node;
  if (account?.Id !== accountId) {
    throw new Error('The account is unavailable or inaccessible.');
  }
  const badgeTier = account.Core_IPA_Badge_Tier__c?.value;
  const roles = account.Core_IPA_Partner_Role__c?.value;
  if (
    (badgeTier !== null && typeof badgeTier !== 'string') ||
    (roles !== null && typeof roles !== 'string')
  ) {
    throw new Error('The partner account tier or roles could not be read.');
  }
  return {
    kind: 'ready',
    opportunityScope: 'account',
    accountId,
    badgeTier: badgeTier?.trim() ?? '',
    roles: (roles ?? '')
      .split(';')
      .map(role => role.trim())
      .filter(Boolean),
  };
}
