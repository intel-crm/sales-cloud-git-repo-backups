import { beforeEach, describe, expect, it, vi } from 'vitest';
import { executeGraphQL } from './graphqlClient';
import { fetchOpportunityStageAmounts } from './opportunityStageAmounts';

vi.mock('./graphqlClient', () => ({ executeGraphQL: vi.fn() }));
const query = vi.mocked(executeGraphQL);

function stage(
  name: string | null,
  amount: number | null,
  label: string | null = name,
  displayValue: string | null = null,
  opportunityCount: number | null = 1
) {
  return {
    node: {
      aggregate: {
        StageName: { value: name, label },
        Amount: { sum: { value: amount, displayValue } },
        Id: { count: { value: opportunityCount } },
      },
    },
  };
}

function response(
  edges: unknown[],
  hasNextPage = false,
  endCursor: string | null = null,
  totalAmount: number | null = 0,
  displayTotalAmount = '0'
) {
  return {
    uiapi: {
      aggregate: {
        Opportunity: { edges, pageInfo: { hasNextPage, endCursor } },
        pipelineTotal: {
          edges: [
            {
              node: {
                aggregate: {
                  Amount: {
                    sum: {
                      value: totalAmount,
                      displayValue: displayTotalAmount,
                    },
                  },
                },
              },
            },
          ],
        },
      },
    },
  };
}

beforeEach(() => {
  query.mockReset();
});

describe('opportunity stage aggregation', () => {
  it('uses server-side sums for all opportunities rather than adding a limited record list', async () => {
    query.mockResolvedValue(
      response(
        [
          stage('Qualification', 1250000.5, 'Qualified', '$1,250,000.50', 40),
          stage('Closed Won', 300, 'Closed Won', '$300.00', 5),
        ],
        false,
        null,
        1250300.5,
        '$1,250,300.50'
      )
    );
    expect(await fetchOpportunityStageAmounts('account-1')).toEqual({
      stages: [
        {
          stage: 'Qualification',
          label: 'Qualified',
          amount: 1250000.5,
          displayAmount: '$1,250,000.50',
          opportunityCount: 40,
        },
        {
          stage: 'Closed Won',
          label: 'Closed Won',
          amount: 300,
          displayAmount: '$300.00',
          opportunityCount: 5,
        },
      ],
      totalAmount: 1250300.5,
      displayTotalAmount: '$1,250,300.50',
      opportunityCount: 45,
    });
    expect(query).toHaveBeenCalledTimes(1);
    const [document, variables] = query.mock.calls[0];
    expect(document).toContain('aggregate');
    expect(document).toContain('groupBy: { StageName: { group: true } }');
    expect(document).toContain('Amount { sum { value displayValue } }');
    expect(document).toContain('Id { count { value } }');
    expect(document).toContain('pipelineTotal: Opportunity');
    expect(document.match(/where: \$where/g)).toHaveLength(2);
    expect(variables).toEqual({
      where: { AccountId: { eq: 'account-1' } },
      after: null,
    });
  });

  it('uses no Account filter for all-accessible opportunity totals on every page', async () => {
    query
      .mockResolvedValueOnce(
        response([stage('Qualification', 500)], true, 'next-page')
      )
      .mockResolvedValueOnce(
        response([stage('Closed Won', 900)], false, null, 1400, '1,400')
      );
    const result = await fetchOpportunityStageAmounts(null);
    expect(result.stages).toHaveLength(2);
    expect(result.totalAmount).toBe(1400);
    expect(query.mock.calls[0][1]).toEqual({ where: null, after: null });
    expect(query.mock.calls[1][1]).toEqual({ where: null, after: 'next-page' });
  });

  it('retrieves every aggregate page without dropping stage totals', async () => {
    query
      .mockResolvedValueOnce(
        response(
          [stage('Qualification', 500, null, null, 3)],
          true,
          'next-page'
        )
      )
      .mockResolvedValueOnce(
        response(
          [stage('Closed Won', 900, null, null, 5)],
          false,
          null,
          1400,
          '1,400'
        )
      );
    const totals = await fetchOpportunityStageAmounts('account-1');
    expect(totals.stages.map(total => total.amount)).toEqual([500, 900]);
    expect(totals.opportunityCount).toBe(8);
    expect(totals.totalAmount).toBe(1400);
    expect(query.mock.calls[1][1]).toEqual({
      where: { AccountId: { eq: 'account-1' } },
      after: 'next-page',
    });
  });

  it('preserves negative amounts and treats null sums as zero', async () => {
    query.mockResolvedValue(
      response(
        [stage('Adjustment', -20), stage(null, null)],
        false,
        null,
        -20,
        '-20'
      )
    );
    expect(await fetchOpportunityStageAmounts('account-1')).toEqual({
      stages: [
        {
          stage: 'Adjustment',
          label: 'Adjustment',
          amount: -20,
          displayAmount: '-20',
          opportunityCount: 1,
        },
        {
          stage: null,
          label: 'Unspecified stage',
          amount: 0,
          displayAmount: '0',
          opportunityCount: 1,
        },
      ],
      totalAmount: -20,
      displayTotalAmount: '-20',
      opportunityCount: 2,
    });
  });

  it('returns an empty result only for a valid empty aggregate connection', async () => {
    query.mockResolvedValue(response([]));
    expect(await fetchOpportunityStageAmounts('account-1')).toEqual({
      stages: [],
      totalAmount: 0,
      displayTotalAmount: '0',
      opportunityCount: 0,
    });
  });

  it.each([
    {},
    { uiapi: { aggregate: { Opportunity: { edges: [] } } } },
    response([
      { node: { aggregate: { StageName: { value: 'Qualification' } } } },
    ]),
    response([{ node: { aggregate: { Amount: { sum: { value: 100 } } } } }]),
    response([stage('Qualification', Number.NaN)]),
    response([stage('Qualification', Infinity)]),
    response([stage('Qualification', 100, null, null, null)]),
    response([stage('Qualification', 100, null, null, -1)]),
    response([stage('Qualification', 100)], false, null, Infinity),
    {
      uiapi: {
        aggregate: {
          Opportunity: { edges: [], pageInfo: { hasNextPage: false } },
        },
      },
    },
    response([stage('Qualification', 100), stage('Qualification', 100)]),
    response([stage('Qualification', 100)], true),
  ])(
    'rejects incomplete or invalid data instead of presenting partial totals',
    async result => {
      query.mockResolvedValue(result);
      await expect(fetchOpportunityStageAmounts('account-1')).rejects.toThrow();
    }
  );

  it('rejects repeated pagination cursors', async () => {
    query
      .mockResolvedValueOnce(
        response([stage('Qualification', 100)], true, 'same')
      )
      .mockResolvedValueOnce(
        response([stage('Closed Won', 200)], true, 'same')
      );
    await expect(fetchOpportunityStageAmounts('account-1')).rejects.toThrow(
      'all opportunity stage totals'
    );
    expect(query).toHaveBeenCalledTimes(2);
  });

  it('propagates access errors rather than returning an empty chart', async () => {
    query.mockRejectedValue(new Error('GraphQL Error: Access denied'));
    await expect(fetchOpportunityStageAmounts('account-1')).rejects.toThrow(
      'Access denied'
    );
  });
});
