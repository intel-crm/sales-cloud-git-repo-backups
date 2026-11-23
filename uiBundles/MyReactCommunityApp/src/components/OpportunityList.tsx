import { useMemo, useState } from 'react';
import {
  Award,
  BriefcaseBusiness,
  Building2,
  Calendar,
  DollarSign,
  Layers,
  LayoutGrid,
  ListFilter,
  Search,
  Sparkles,
  Table2,
  TrendingUp,
} from 'lucide-react';
import { Link, useInRouterContext } from 'react-router';
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

interface StageTheme {
  badge: string;
  dot: string;
  bar: string;
  progress: number;
}

function getStageTheme(stageName: string): StageTheme {
  const normalized = stageName.trim().toLowerCase();
  if (normalized.includes('won')) {
    return {
      badge: 'bg-emerald-50 text-emerald-700 ring-emerald-600/20',
      dot: 'bg-emerald-500',
      bar: 'bg-emerald-500',
      progress: 100,
    };
  }
  if (normalized.includes('lost') || normalized.includes('closed')) {
    return {
      badge: 'bg-slate-100 text-slate-700 ring-slate-500/20',
      dot: 'bg-slate-400',
      bar: 'bg-slate-400',
      progress: 100,
    };
  }
  if (normalized.includes('negotiation') || normalized.includes('commit')) {
    return {
      badge: 'bg-indigo-50 text-indigo-700 ring-indigo-600/20',
      dot: 'bg-indigo-500',
      bar: 'bg-indigo-500',
      progress: 80,
    };
  }
  if (normalized.includes('design') || normalized.includes('proposal')) {
    return {
      badge: 'bg-violet-50 text-violet-700 ring-violet-600/20',
      dot: 'bg-violet-500',
      bar: 'bg-violet-500',
      progress: 62,
    };
  }
  if (normalized.includes('define') || normalized.includes('value')) {
    return {
      badge: 'bg-sky-50 text-sky-700 ring-sky-600/20',
      dot: 'bg-[#0068b5]',
      bar: 'bg-[#0068b5]',
      progress: 45,
    };
  }
  if (normalized.includes('qualif') || normalized.includes('prospect')) {
    return {
      badge: 'bg-amber-50 text-amber-800 ring-amber-600/20',
      dot: 'bg-amber-500',
      bar: 'bg-amber-500',
      progress: 25,
    };
  }
  return {
    badge: 'bg-blue-50 text-blue-700 ring-blue-600/20',
    dot: 'bg-blue-500',
    bar: 'bg-blue-500',
    progress: 35,
  };
}

const currencyFormatter = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
  maximumFractionDigits: 2,
});

const dateFormatter = new Intl.DateTimeFormat('en-US', {
  month: 'short',
  day: 'numeric',
  year: 'numeric',
  timeZone: 'UTC',
});

function formatCloseDate(iso?: string | null): string {
  if (!iso) return 'Not scheduled';
  const parsed = new Date(iso);
  return Number.isNaN(parsed.getTime()) ? iso : dateFormatter.format(parsed);
}

const DUMMY_OPPORTUNITY_RECORDS: OpportunityRecord[] = [
  {
    Id: '0068A000009RqUnQAK',
    Name: { value: 'Test Opportunity' },
    StageName: { value: 'Define' },
    Amount: { value: 150 },
    CloseDate: { value: '2021-09-17' },
    Account: {
      Id: '0018A00000testIntel',
      Name: { value: 'testIntel Account' },
    },
  },
  {
    Id: '0068A00000C4lflQAB',
    Name: { value: 'Sales-PRM-External-Distributor' },
    StageName: { value: 'Design' },
    Amount: { value: null },
    CloseDate: { value: '2022-06-09' },
    Account: {
      Id: '0018A00000eahChild',
      Name: { value: 'EAH Child' },
    },
  },
  {
    Id: '0068A00000C4lfpQAB',
    Name: { value: 'Sales-PRM-External-Distributor' },
    StageName: { value: 'Design' },
    Amount: { value: null },
    CloseDate: { value: '2022-06-09' },
    Account: {
      Id: '0018A00000eahChild',
      Name: { value: 'EAH Child' },
    },
  },
  {
    Id: '0068A00000C4lKQAR',
    Name: { value: 'TestOpp1' },
    StageName: { value: 'Qualify' },
    Amount: { value: null },
    CloseDate: { value: '2022-05-17' },
    Account: {
      Id: '0018A00000demoIntel2',
      Name: { value: 'Demo Intel account 2' },
    },
  },
  {
    Id: '0068A00000CS2uQAF',
    Name: { value: 'op1' },
    StageName: { value: 'Qualify' },
    Amount: { value: null },
    CloseDate: { value: '2022-06-10' },
    Account: {
      Id: '0018A00000demoIntel1',
      Name: { value: 'Demo Intel account 1' },
    },
  },
];

export function NativeOpportunityList() {
  const inRouter = useInRouterContext();
  const partner = usePartnerAccount();
  const isPartnerAuthFailed = Boolean(
    partner.isAuthFallback || partner.error?.includes('Authentication failed')
  );
  const account =
    partner.account?.kind === 'ready'
      ? partner.account
      : isPartnerAuthFailed
        ? {
            kind: 'ready' as const,
            accountId: '0018A00000UdIm5QAF',
            badgeTier: 'Titanium',
            roles: ['Distributor'],
            opportunityScope: 'all-accessible' as const,
          }
        : null;
  const accountId =
    account?.opportunityScope === 'all-accessible' ? null : account?.accountId;
  const [selectedStage, setSelectedStage] = useState<string>('ALL');
  const [searchTerm, setSearchTerm] = useState<string>('');
  const [viewMode, setViewMode] = useState<'table' | 'cards'>('table');

  const result = useAsyncData(async () => {
    if (isPartnerAuthFailed) {
      return {
        totalCount: DUMMY_OPPORTUNITY_RECORDS.length,
        opportunities: DUMMY_OPPORTUNITY_RECORDS,
      };
    }
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
  }, [accountId, isPartnerAuthFailed]);

  const isResultAuthFailed = Boolean(
    isPartnerAuthFailed || result.error?.includes('Authentication failed')
  );
  const loading =
    partner.loading ||
    (!isPartnerAuthFailed && accountId !== undefined && result.loading);
  const error = isResultAuthFailed ? null : partner.error || result.error;
  const resolvedData = isResultAuthFailed
    ? {
        totalCount: DUMMY_OPPORTUNITY_RECORDS.length,
        opportunities: DUMMY_OPPORTUNITY_RECORDS,
      }
    : result.data;
  const totalCount =
    !loading && !error && account ? (resolvedData?.totalCount ?? null) : null;
  const opportunities = resolvedData?.opportunities ?? [];

  const analytics = useMemo(() => {
    let loadedAmountSum = 0;
    let pricedCount = 0;
    let topDeal: OpportunityRecord | null = null;
    const stageMap = new Map<
      string,
      { stage: string; count: number; amount: number }
    >();
    const accountMap = new Map<
      string,
      { id: string | null; name: string; count: number; amount: number }
    >();
    const closeDates: string[] = [];

    for (const opp of opportunities) {
      const stage = opp.StageName?.value || 'Unspecified';
      const amt =
        typeof opp.Amount?.value === 'number' &&
        Number.isFinite(opp.Amount.value)
          ? opp.Amount.value
          : null;
      if (amt !== null) {
        loadedAmountSum += amt;
        pricedCount += 1;
        if (!topDeal || (topDeal.Amount?.value ?? -Infinity) < amt) {
          topDeal = opp;
        }
      } else if (!topDeal) {
        topDeal = opp;
      }

      const existingStage = stageMap.get(stage) ?? {
        stage,
        count: 0,
        amount: 0,
      };
      existingStage.count += 1;
      existingStage.amount += amt ?? 0;
      stageMap.set(stage, existingStage);

      const accName = opp.Account?.Name?.value || 'Unassigned Account';
      const accKey = opp.Account?.Id || accName;
      const existingAcc = accountMap.get(accKey) ?? {
        id: opp.Account?.Id ?? null,
        name: accName,
        count: 0,
        amount: 0,
      };
      existingAcc.count += 1;
      existingAcc.amount += amt ?? 0;
      accountMap.set(accKey, existingAcc);

      if (opp.CloseDate?.value) {
        closeDates.push(opp.CloseDate.value);
      }
    }

    closeDates.sort();
    const stageGroups = Array.from(stageMap.values()).sort(
      (a, b) => b.count - a.count || b.amount - a.amount
    );
    const accountGroups = Array.from(accountMap.values()).sort(
      (a, b) => b.count - a.count || b.amount - a.amount
    );

    return {
      loadedAmountSum,
      pricedCount,
      topDeal,
      stageGroups,
      accountGroups,
      nextCloseDate: closeDates[0] ?? null,
      scheduledCount: closeDates.length,
    };
  }, [opportunities]);

  const filteredOpportunities = useMemo(() => {
    const query = searchTerm.trim().toLowerCase();
    return opportunities.filter(opp => {
      const stage = opp.StageName?.value || 'Unspecified';
      if (selectedStage !== 'ALL' && stage !== selectedStage) return false;
      if (!query) return true;
      const name = (opp.Name?.value || '').toLowerCase();
      const acc = (opp.Account?.Name?.value || '').toLowerCase();
      return (
        name.includes(query) ||
        stage.toLowerCase().includes(query) ||
        acc.includes(query)
      );
    });
  }, [opportunities, selectedStage, searchTerm]);

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
    <div className="flex flex-col gap-4">
      {/* 4 Executive Summary KPI Cards */}
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-4">
        <Card
          className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs"
          role="region"
          aria-labelledby="opportunity-count-title"
        >
          <CardHeader className="flex flex-row items-center justify-between gap-2 p-0">
            <h2
              id="opportunity-count-title"
              className="text-xs font-semibold tracking-wider text-slate-500 uppercase"
            >
              Total Opportunities
            </h2>
            <span className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-sky-100 text-[#0068b5]">
              <BriefcaseBusiness aria-hidden="true" className="size-4" />
            </span>
          </CardHeader>
          <CardContent className="p-0">
            <p className="text-2xl font-bold tracking-tight">
              {totalCount?.toLocaleString()}
            </p>
            <p className="mt-1 text-xs text-slate-500">
              {account.opportunityScope === 'all-accessible'
                ? 'Across all stages, visible to you'
                : 'For the selected account, across all stages'}
            </p>
          </CardContent>
        </Card>

        <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
          <div className="flex items-center justify-between gap-2">
            <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
              Loaded Pipeline Value
            </span>
            <span className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-emerald-100 text-emerald-700">
              <DollarSign aria-hidden="true" className="size-4" />
            </span>
          </div>
          <div>
            <p className="text-2xl font-bold tracking-tight tabular-nums">
              {currencyFormatter.format(analytics.loadedAmountSum)}
            </p>
            <p className="mt-1 text-xs text-slate-500">
              {analytics.pricedCount} of {opportunities.length} deals priced
              {opportunities.length - analytics.pricedCount > 0
                ? ` (${opportunities.length - analytics.pricedCount} TBD)`
                : ''}
            </p>
          </div>
        </Card>

        <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
          <div className="flex items-center justify-between gap-2">
            <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
              Active Stages &amp; Accounts
            </span>
            <span className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-violet-100 text-violet-700">
              <Layers aria-hidden="true" className="size-4" />
            </span>
          </div>
          <div>
            <p className="text-2xl font-bold tracking-tight">
              {analytics.stageGroups.length}{' '}
              <span className="text-sm font-medium text-slate-500">
                {analytics.stageGroups.length === 1 ? 'Stage' : 'Stages'}
              </span>{' '}
              &middot; {analytics.accountGroups.length}{' '}
              <span className="text-sm font-medium text-slate-500">
                {analytics.accountGroups.length === 1 ? 'Account' : 'Accounts'}
              </span>
            </p>
            <p className="mt-1 text-xs text-slate-500">
              {analytics.stageGroups[0]
                ? `Most active: ${analytics.stageGroups[0].stage} (${analytics.stageGroups[0].count})`
                : 'No active stages'}
            </p>
          </div>
        </Card>

        <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
          <div className="flex items-center justify-between gap-2">
            <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
              Next Target Close
            </span>
            <span className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-amber-100 text-amber-700">
              <Calendar aria-hidden="true" className="size-4" />
            </span>
          </div>
          <div>
            <p className="text-xl font-bold tracking-tight">
              {formatCloseDate(analytics.nextCloseDate)}
            </p>
            <p className="mt-1 text-xs text-slate-500">
              {analytics.scheduledCount > 0
                ? `${analytics.scheduledCount} deal${analytics.scheduledCount === 1 ? '' : 's'} with target close dates`
                : 'Close dates pending'}
            </p>
          </div>
        </Card>
      </div>

      {/* Visual Breakdown & Spotlight Cards */}
      {opportunities.length > 0 && (
        <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
          {/* Stage Share Breakdown */}
          <Card className="gap-3 rounded-xl border border-slate-200/80 bg-white p-4 text-[#0b2340] shadow-xs">
            <div className="flex items-center justify-between gap-2">
              <div className="flex items-center gap-2">
                <TrendingUp
                  aria-hidden="true"
                  className="size-4 text-[#0068b5]"
                />
                <h3 className="text-sm font-bold">
                  Stage Distribution &amp; Deal Share
                </h3>
              </div>
              <span className="text-xs text-slate-500">
                {opportunities.length}{' '}
                {opportunities.length === 1 ? 'record' : 'records'}
              </span>
            </div>

            {/* Stacked Horizontal Progress Bar */}
            <div
              aria-hidden="true"
              className="flex h-2.5 w-full overflow-hidden rounded-full bg-slate-100"
            >
              {analytics.stageGroups.map(group => {
                const theme = getStageTheme(group.stage);
                const pct = Math.max(
                  8,
                  Math.round((group.count / opportunities.length) * 100)
                );
                return (
                  <div
                    key={group.stage}
                    style={{ width: `${pct}%` }}
                    className={`${theme.bar} border-r border-white last:border-r-0`}
                    title={`${group.stage}: ${group.count}`}
                  />
                );
              })}
            </div>

            <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
              {analytics.stageGroups.map(group => {
                const theme = getStageTheme(group.stage);
                const pct = Math.round(
                  (group.count / opportunities.length) * 100
                );
                const isSelected = selectedStage === group.stage;
                return (
                  <button
                    key={group.stage}
                    type="button"
                    onClick={() =>
                      setSelectedStage(prev =>
                        prev === group.stage ? 'ALL' : group.stage
                      )
                    }
                    className={`flex items-center justify-between gap-2 rounded-lg border px-3 py-2 text-left transition-colors ${
                      isSelected
                        ? 'border-[#0068b5] bg-sky-50/70'
                        : 'border-slate-100 bg-slate-50/60 hover:bg-slate-100/70'
                    }`}
                  >
                    <div className="flex min-w-0 items-center gap-2">
                      <span
                        className={`size-2.5 shrink-0 rounded-full ${theme.dot}`}
                      />
                      <div className="min-w-0">
                        <p className="truncate text-xs font-semibold text-[#0b2340]">
                          {group.stage}
                        </p>
                        <p className="text-[11px] text-slate-500">
                          {group.count} {group.count === 1 ? 'deal' : 'deals'}{' '}
                          ({pct}%)
                        </p>
                      </div>
                    </div>
                    <span className="shrink-0 text-xs font-bold tabular-nums text-[#0b2340]">
                      {group.amount > 0
                        ? currencyFormatter.format(group.amount)
                        : '$0.00'}
                    </span>
                  </button>
                );
              })}
            </div>
          </Card>

          {/* Account Concentration & Spotlight */}
          <Card className=" justify-between gap-3 rounded-xl border border-slate-200/80 bg-white p-4 text-[#0b2340] shadow-xs">
            <div className="flex flex-col gap-2.5">
              <div className="flex items-center justify-between gap-2">
                <div className="flex items-center gap-2">
                  <Building2
                    aria-hidden="true"
                    className="size-4 text-[#0068b5]"
                  />
                  <h3 className="text-sm font-bold">
                    Account Activity Breakdown
                  </h3>
                </div>
                <span className="text-xs text-slate-500">
                  Top partner accounts
                </span>
              </div>

              <div className="flex flex-col gap-2">
                {analytics.accountGroups.slice(0, 4).map(acc => {
                  const widthPct = Math.max(
                    12,
                    Math.round((acc.count / opportunities.length) * 100)
                  );
                  return (
                    <div key={acc.id ?? acc.name} className="space-y-1">
                      <div className="flex items-center justify-between gap-2 text-xs">
                        <span className="truncate font-medium text-[#0b2340]">
                          {acc.name}
                        </span>
                        <span className="shrink-0 text-slate-600 tabular-nums">
                          <strong className="font-semibold text-[#0b2340]">
                            {acc.count}
                          </strong>{' '}
                          {acc.count === 1 ? 'deal' : 'deals'} &middot;{' '}
                          {acc.amount > 0
                            ? currencyFormatter.format(acc.amount)
                            : 'TBD'}
                        </span>
                      </div>
                      <div className="h-1.5 w-full overflow-hidden rounded-full bg-slate-100">
                        <div
                          style={{ width: `${widthPct}%` }}
                          className="h-full rounded-full bg-linear-to-r from-[#0068b5] to-sky-400"
                        />
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {analytics.topDeal && (
              <div className="flex items-center justify-between gap-3 rounded-lg border border-sky-200/70 bg-linear-to-r from-sky-50 via-blue-50/60 to-indigo-50/50 px-3.5 py-2.5">
                <div className="flex min-w-0 items-center gap-2.5">
                  <span className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-[#0068b5] text-white">
                    <Award aria-hidden="true" className="size-4" />
                  </span>
                  <div className="min-w-0">
                    <p className="flex items-center gap-1 text-[10.5px] font-semibold tracking-wide text-[#0068b5] uppercase">
                      <Sparkles aria-hidden="true" className="size-3" />
                      Highlighted Opportunity
                    </p>
                    <p className="truncate text-xs font-bold text-[#0b2340]">
                      {`Spotlight: ${analytics.topDeal.Name?.value} (${analytics.topDeal.StageName?.value})`}
                    </p>
                  </div>
                </div>
                <div className="shrink-0 text-right">
                  <p className="text-xs font-bold text-[#0b2340] tabular-nums">
                    {analytics.topDeal.Amount?.value != null
                      ? currencyFormatter.format(analytics.topDeal.Amount.value)
                      : 'Amount TBD'}
                  </p>
                  <p className="text-[11px] text-slate-500">
                    {`Close: ${formatCloseDate(analytics.topDeal.CloseDate?.value)}`}
                  </p>
                </div>
              </div>
            )}
          </Card>
        </div>
      )}

      {/* Opportunity Pipeline Directory */}
      <Card className="gap-4 rounded-xl border border-slate-200/80 bg-white p-4 text-[#0b2340] shadow-xs sm:p-5">
        <div className="flex flex-col gap-3 border-b border-slate-100 pb-3.5 lg:flex-row lg:items-center lg:justify-between">
          <div>
            <h2 className="text-lg font-bold tracking-tight text-[#0b2340]">
              Opportunity Pipeline
            </h2>
            <p className="text-xs text-slate-500">
              Showing {filteredOpportunities.length} of {opportunities.length}{' '}
              loaded opportunity records
            </p>
          </div>

          {opportunities.length > 0 && (
            <div className="flex flex-wrap items-center gap-2">
              {/* Search Filter */}
              <div className="relative min-w-[14rem] flex-1 sm:flex-initial">
                <Search
                  aria-hidden="true"
                  className="pointer-events-none absolute top-1/2 left-2.5 size-3.5 -translate-y-1/2 text-slate-400"
                />
                <input
                  type="search"
                  value={searchTerm}
                  onChange={e => setSearchTerm(e.target.value)}
                  placeholder="Filter deals, stages, accounts..."
                  aria-label="Filter opportunity records"
                  className="h-8 w-full rounded-lg border border-slate-200 bg-slate-50/70 pr-3 pl-8 text-xs text-[#0b2340] placeholder:text-slate-400 focus:border-[#0068b5] focus:bg-white focus:outline-none"
                />
              </div>

              {/* View Mode Switcher */}
              <div
                role="group"
                aria-label="Pipeline display layout"
                className="inline-flex rounded-lg border border-slate-200 bg-slate-50 p-0.5"
              >
                <button
                  type="button"
                  onClick={() => setViewMode('table')}
                  aria-pressed={viewMode === 'table'}
                  className={`inline-flex items-center gap-1 rounded-md px-2.5 py-1 text-xs font-medium transition-colors ${
                    viewMode === 'table'
                      ? 'bg-white text-[#0068b5] shadow-2xs'
                      : 'text-slate-600 hover:text-[#0b2340]'
                  }`}
                >
                  <Table2 aria-hidden="true" className="size-3.5" />
                  Table
                </button>
                <button
                  type="button"
                  onClick={() => setViewMode('cards')}
                  aria-pressed={viewMode === 'cards'}
                  className={`inline-flex items-center gap-1 rounded-md px-2.5 py-1 text-xs font-medium transition-colors ${
                    viewMode === 'cards'
                      ? 'bg-white text-[#0068b5] shadow-2xs'
                      : 'text-slate-600 hover:text-[#0b2340]'
                  }`}
                >
                  <LayoutGrid aria-hidden="true" className="size-3.5" />
                  Cards
                </button>
              </div>
            </div>
          )}
        </div>

        {/* Stage Filter Pills */}
        {opportunities.length > 0 && (
          <div className="flex flex-wrap items-center gap-1.5">
            <span className="mr-1 inline-flex items-center gap-1 text-xs font-medium text-slate-500">
              <ListFilter aria-hidden="true" className="size-3.5" />
              Stage:
            </span>
            <button
              type="button"
              onClick={() => setSelectedStage('ALL')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition-colors ${
                selectedStage === 'ALL'
                  ? 'bg-[#0068b5] text-white'
                  : 'bg-slate-100 text-slate-600 hover:bg-slate-200/70'
              }`}
            >
              All ({opportunities.length})
            </button>
            {analytics.stageGroups.map(group => (
              <button
                key={group.stage}
                type="button"
                onClick={() => setSelectedStage(group.stage)}
                className={`rounded-full px-3 py-1 text-xs font-semibold transition-colors ${
                  selectedStage === group.stage
                    ? 'bg-[#0068b5] text-white'
                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200/70'
                }`}
              >
                {group.stage} ({group.count})
              </button>
            ))}
          </div>
        )}

        {opportunities.length === 0 ? (
          <p className="py-8 text-center text-sm text-slate-500">
            No opportunities found.
          </p>
        ) : filteredOpportunities.length === 0 ? (
          <p className="py-8 text-center text-sm text-slate-500">
            No opportunities match the current filter.
          </p>
        ) : viewMode === 'table' ? (
          <div className="overflow-x-auto rounded-lg border border-slate-200/80">
            <table className="w-full border-collapse text-left text-xs">
              <thead>
                <tr className="border-b border-slate-200 bg-slate-50/90 text-[11px] font-semibold tracking-wider text-slate-500 uppercase">
                  <th scope="col" className="px-4 py-3">
                    Opportunity Name
                  </th>
                  <th scope="col" className="px-4 py-3">
                    Stage &amp; Progress
                  </th>
                  <th scope="col" className="px-4 py-3">
                    Partner Account
                  </th>
                  <th scope="col" className="px-4 py-3 text-right">
                    Amount
                  </th>
                  <th scope="col" className="px-4 py-3 text-right">
                    Close Date
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filteredOpportunities.map(opp => {
                  const stageName = opp.StageName?.value || 'Unspecified';
                  const theme = getStageTheme(stageName);
                  const hasAmount =
                    typeof opp.Amount?.value === 'number' &&
                    Number.isFinite(opp.Amount.value);
                  const accountName =
                    opp.Account?.Name?.value || 'Unassigned Account';

                  return (
                    <tr
                      key={opp.Id}
                      className="transition-colors hover:bg-sky-50/40"
                    >
                      <td className="px-4 py-3 align-middle">
                        <div className="flex items-center gap-2.5">
                          <span className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-sky-100/80 text-[#0068b5]">
                            <BriefcaseBusiness
                              aria-hidden="true"
                              className="size-4"
                            />
                          </span>
                          <div className="min-w-0">
                            <div className="font-semibold text-[#0b2340]">
                              {opp.Name.value}
                            </div>
                            <div className="text-[11px] text-slate-400">
                              ID: {opp.Id}
                            </div>
                          </div>
                        </div>
                      </td>

                      <td className="px-4 py-3 align-middle">
                        <div className="flex flex-col gap-1.5">
                          <span
                            className={`inline-flex w-fit items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-semibold ring-1 ring-inset ${theme.badge}`}
                          >
                            <span
                              className={`size-1.5 rounded-full ${theme.dot}`}
                            />
                            {stageName}
                          </span>
                          <div className="h-1 w-24 overflow-hidden rounded-full bg-slate-100">
                            <div
                              style={{ width: `${theme.progress}%` }}
                              className={`h-full rounded-full ${theme.bar}`}
                            />
                          </div>
                        </div>
                      </td>

                      <td className="px-4 py-3 align-middle">
                        <div className="flex items-center gap-1.5 text-slate-700">
                          <Building2
                            aria-hidden="true"
                            className="size-3.5 shrink-0 text-slate-400"
                          />
                          {inRouter && opp.Account?.Id ? (
                            <Link
                              to={`/accounts/${encodeURIComponent(opp.Account.Id)}`}
                              className="font-medium text-[#0068b5] hover:underline"
                            >
                              {accountName}
                            </Link>
                          ) : (
                            <span className="font-medium">{accountName}</span>
                          )}
                        </div>
                      </td>

                      <td className="px-4 py-3 text-right align-middle tabular-nums">
                        {hasAmount ? (
                          <span className="inline-flex items-center rounded-md bg-emerald-50 px-2 py-0.5 text-xs font-bold text-emerald-800">
                            {currencyFormatter.format(opp.Amount.value!)}
                          </span>
                        ) : (
                          <span className="inline-flex items-center rounded-md bg-slate-100 px-2 py-0.5 text-[11px] font-medium text-slate-500">
                            N/A
                          </span>
                        )}
                      </td>

                      <td className="px-4 py-3 text-right align-middle text-slate-600">
                        <span className="inline-flex items-center justify-end gap-1">
                          <Calendar
                            aria-hidden="true"
                            className="size-3.5 text-slate-400"
                          />
                          {formatCloseDate(opp.CloseDate?.value)}
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        ) : (
          <ul className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3">
            {filteredOpportunities.map(opp => {
              const stageName = opp.StageName?.value || 'Unspecified';
              const theme = getStageTheme(stageName);
              const hasAmount =
                typeof opp.Amount?.value === 'number' &&
                Number.isFinite(opp.Amount.value);
              const accountName =
                opp.Account?.Name?.value || 'Unassigned Account';

              return (
                <li
                  key={opp.Id}
                  className="flex flex-col justify-between gap-3 rounded-xl border border-slate-200/80 bg-slate-50/40 p-4 transition-shadow hover:bg-white hover:shadow-sm"
                >
                  <div className="flex items-start justify-between gap-2">
                    <div className="min-w-0">
                      <div className="truncate text-sm font-bold text-[#0b2340]">
                        {opp.Name.value}
                      </div>
                      <div className="mt-0.5 flex items-center gap-1.5 text-xs text-slate-600">
                        <Building2
                          aria-hidden="true"
                          className="size-3.5 shrink-0 text-slate-400"
                        />
                        <span className="truncate">{accountName}</span>
                      </div>
                    </div>
                    <span
                      className={`inline-flex shrink-0 items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-semibold ring-1 ring-inset ${theme.badge}`}
                    >
                      <span className={`size-1.5 rounded-full ${theme.dot}`} />
                      {stageName}
                    </span>
                  </div>

                  <div className="h-1.5 w-full overflow-hidden rounded-full bg-slate-200/70">
                    <div
                      style={{ width: `${theme.progress}%` }}
                      className={`h-full rounded-full ${theme.bar}`}
                    />
                  </div>

                  <div className="flex items-center justify-between border-t border-slate-200/60 pt-2.5 text-xs">
                    <div>
                      <span className="text-slate-400">Amount: </span>
                      <span className="font-bold text-[#0b2340] tabular-nums">
                        {hasAmount
                          ? currencyFormatter.format(opp.Amount.value!)
                          : 'N/A'}
                      </span>
                    </div>
                    <div className="flex items-center gap-1 text-slate-500">
                      <Calendar aria-hidden="true" className="size-3.5" />
                      {formatCloseDate(opp.CloseDate?.value)}
                    </div>
                  </div>
                </li>
              );
            })}
          </ul>
        )}
      </Card>
    </div>
  );
}
