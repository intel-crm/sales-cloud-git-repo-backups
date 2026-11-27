import { executeGraphQL } from '../api/graphqlClient';
import { Card, CardContent, CardHeader } from './ui/card';
import { useAsyncData } from '../hooks/useAsyncData';
import { usePartnerAccount } from '../features/partner/context/PartnerAccountContext';

const GET_OPPORTUNITIES_QUERY = `
  query getOpportunities($first: Int, $where: Opportunity_Filter) {
    uiapi {
      query {
        Opportunity(first: $first, where: $where) {
          totalCount
          edges {
            node {
              Id
              Name {
                value
              }
              StageName {
                value
              }
              Amount {
                value
              }
              CloseDate {
                value
              }
              Account {
                Id
                Name {
                  value
                }
              }
            }
          }
        }
      }
    }
  }
`;

// Define typed interface for the records
interface OpportunityRecord {
  Id: string;
  Name: { value: string };
  StageName: { value: string };
  Amount: { value: number | null };
  CloseDate: { value: string };
  Account: {
    Id: string;
    Name: { value: string };
  } | null;
}

export function NativeOpportunityList() {
  const partner = usePartnerAccount();
  const account = partner.account?.kind === 'ready' ? partner.account : null;
  const accountId =
    account?.opportunityScope === 'all-accessible' ? null : account?.accountId;
  const result = useAsyncData(async () => {
    if (accountId === undefined) return null;
    const data = await executeGraphQL<
      {
        uiapi?: {
          query?: {
            Opportunity?: {
              totalCount?: number;
              edges?: { node: OpportunityRecord }[];
            };
          };
        };
      },
      { first: number; where: { AccountId: { eq: string } } | null }
    >(GET_OPPORTUNITIES_QUERY, {
      first: 10,
      where: accountId === null ? null : { AccountId: { eq: accountId } },
    });
    const connection = data.uiapi?.query?.Opportunity;
    if (
      !connection ||
      !Number.isInteger(connection.totalCount) ||
      connection.totalCount === undefined ||
      connection.totalCount < 0 ||
      !Array.isArray(connection.edges)
    ) {
      throw new Error(
        'Salesforce returned an incomplete opportunity response.'
      );
    }

    return {
      totalCount: connection.totalCount,
      opportunities: connection.edges.map(edge => edge.node),
    };
  }, [accountId]);
  const loading =
    partner.loading || (accountId !== undefined && result.loading);
  const error = partner.error || result.error;
  const totalCount =
    !loading && !error && account ? (result.data?.totalCount ?? null) : null;
  const opportunities = result.data?.opportunities ?? [];

  if (loading)
    return (
      <>
        <div role="status">Loading opportunity records...</div>
      </>
    );
  if (error)
    return (
      <>
        <div role="alert" className="error-banner">
          {error}
        </div>
      </>
    );
  if (!account)
    return (
      <>
        <p>Sign in to view account opportunities.</p>
      </>
    );

  return (
    <>
      <div className="p-4 bg-white rounded shadow">
        <Card
          className="mb-6"
          role="region"
          aria-labelledby="opportunity-count-title"
        >
          <CardHeader>
            <h2
              id="opportunity-count-title"
              className="text-sm font-medium text-muted-foreground"
            >
              Total Opportunities
            </h2>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold">{totalCount?.toLocaleString()}</p>
            <p className="mt-1 text-sm text-muted-foreground">
              {account.opportunityScope === 'all-accessible'
                ? 'Across all stages, visible to you'
                : 'For the selected account, across all stages'}
            </p>
          </CardContent>
        </Card>
        <h2 className="text-xl font-bold mb-4">Opportunity Pipeline</h2>
        {opportunities.length === 0 && <p>No opportunities found.</p>}
        <ul className="space-y-2">
          {opportunities.map(opp => (
            <li key={opp.Id} className="border-b pb-2">
              <div className="font-semibold">{opp.Name.value}</div>
              <div className="text-sm text-gray-600">
                Stage: {opp.StageName.value} | Amount:{' '}
                {opp.Amount.value ? `$${opp.Amount.value}` : 'N/A'} | Account:{' '}
                {opp.Account?.Name?.value || 'None'}
              </div>
            </li>
          ))}
        </ul>
      </div>
    </>
  );
}
