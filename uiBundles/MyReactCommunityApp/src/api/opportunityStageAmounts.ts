import { executeGraphQL } from './graphqlClient';

const STAGE_AMOUNTS_QUERY = `
  query GetOpportunityStageAmounts($where: Opportunity_Filter, $after: String) {
    uiapi {
      aggregate {
        Opportunity(first: 2000, after: $after, where: $where, groupBy: { StageName: { group: true } }) {
          edges {
            node {
              aggregate {
                StageName { value label }
                Amount { sum { value displayValue } }
                Id { count { value } }
              }
            }
          }
          pageInfo { hasNextPage endCursor }
        }
        pipelineTotal: Opportunity(where: $where) {
          edges { node { aggregate { Amount { sum { value displayValue } } } } }
        }
      }
    }
  }
`;

export interface OpportunityStageAmount {
  stage: string | null;
  label: string;
  amount: number;
  displayAmount: string;
  opportunityCount: number;
}

export interface OpportunityPipeline {
  stages: OpportunityStageAmount[];
  totalAmount: number;
  displayTotalAmount: string;
  opportunityCount: number;
}

interface StageAmountsResponse {
  uiapi?: {
    aggregate?: {
      Opportunity?: {
        edges?: {
          node?: {
            aggregate?: {
              StageName?: { value?: string | null; label?: string | null };
              Amount?: {
                sum?: { value?: number | null; displayValue?: string | null };
              };
              Id?: { count?: { value?: number | null } };
            };
          };
        }[];
        pageInfo?: { hasNextPage?: boolean; endCursor?: string | null };
      };
      pipelineTotal?: {
        edges?: {
          node?: {
            aggregate?: {
              Amount?: {
                sum?: { value?: number | null; displayValue?: string | null };
              };
            };
          };
        }[];
      };
    };
  };
}

export async function fetchOpportunityStageAmounts(
  accountId: string | null
): Promise<OpportunityPipeline> {
  const totals: OpportunityStageAmount[] = [];
  const stages = new Set<string | null>();
  const cursors = new Set<string>();
  const numberFormat = new Intl.NumberFormat(undefined, {
    maximumFractionDigits: 2,
  });
  const cleanDisplay = (raw?: string | null) => {
    if (!raw) return undefined;
    const cleaned = raw.replace(/&nbsp;/gi, ' ').replace(/\u00a0/g, ' ').trim();
    return cleaned || undefined;
  };
  let after: string | null = null;

  while (true) {
    const data: StageAmountsResponse = await executeGraphQL<
      StageAmountsResponse,
      { where: { AccountId: { eq: string } } | null; after: string | null }
    >(STAGE_AMOUNTS_QUERY, {
      where: accountId === null ? null : { AccountId: { eq: accountId } },
      after,
    });
    const connection = data.uiapi?.aggregate?.Opportunity;
    if (
      !connection ||
      !Array.isArray(connection.edges) ||
      typeof connection.pageInfo?.hasNextPage !== 'boolean'
    ) {
      throw new Error(
        'Salesforce returned incomplete opportunity stage totals.'
      );
    }

    for (const edge of connection.edges) {
      const aggregate = edge.node?.aggregate;
      const stage = aggregate?.StageName?.value;
      const value = aggregate?.Amount?.sum?.value;
      const opportunityCount = aggregate?.Id?.count?.value;
      if (
        (stage !== null && typeof stage !== 'string') ||
        (value !== null &&
          (typeof value !== 'number' || !Number.isFinite(value)))
      ) {
        throw new Error(
          'Salesforce returned an unreadable opportunity stage or amount.'
        );
      }
      if (
        typeof opportunityCount !== 'number' ||
        !Number.isSafeInteger(opportunityCount) ||
        opportunityCount < 0
      ) {
        throw new Error(
          'Salesforce returned an unreadable opportunity stage count.'
        );
      }
      if (stages.has(stage)) {
        throw new Error(
          'Salesforce returned duplicate opportunity stage totals.'
        );
      }
      stages.add(stage);
      const amount = value ?? 0;
      totals.push({
        stage,
        label:
          aggregate?.StageName?.label?.trim() || stage || 'Unspecified stage',
        amount,
        displayAmount:
          cleanDisplay(aggregate?.Amount?.sum?.displayValue) ||
          numberFormat.format(amount),
        opportunityCount,
      });
    }

    if (!connection.pageInfo.hasNextPage) {
      const summaryEdges = data.uiapi?.aggregate?.pipelineTotal?.edges;
      if (
        !Array.isArray(summaryEdges) ||
        summaryEdges.length > 1 ||
        (totals.length > 0 && summaryEdges.length !== 1)
      ) {
        throw new Error('Salesforce returned an incomplete pipeline total.');
      }
      const sum = summaryEdges[0]?.node?.aggregate?.Amount?.sum;
      const value = summaryEdges.length === 0 ? null : sum?.value;
      if (
        value !== null &&
        (typeof value !== 'number' || !Number.isFinite(value))
      ) {
        throw new Error('Salesforce returned an unreadable pipeline total.');
      }
      return {
        stages: totals,
        totalAmount: value ?? 0,
        displayTotalAmount:
          cleanDisplay(sum?.displayValue) || numberFormat.format(value ?? 0),
        opportunityCount: totals.reduce(
          (count, total) => count + total.opportunityCount,
          0
        ),
      };
    }
    const cursor = connection.pageInfo.endCursor;
    if (!cursor || cursors.has(cursor)) {
      throw new Error(
        'Salesforce could not retrieve all opportunity stage totals.'
      );
    }
    cursors.add(cursor);
    after = cursor;
  }
}
