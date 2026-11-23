import { useId, type ReactNode } from 'react';
import { ArrowRight } from 'lucide-react';
import { Link } from 'react-router';
import {
  fetchOpportunityStageAmounts,
  type OpportunityStageTotals,
} from '../api/opportunityStageAmounts';
import { useAsyncData } from '../hooks/useAsyncData';
import { Card, CardContent, CardHeader } from './ui/card';
import { usePartnerAccount } from '../features/partner/context/PartnerAccountContext';
import { HomeDashboardCards } from './HomeDashboardCards';
import type { LiveHomeCardsData } from '../hooks/usePartnerPortalOverview';

const DUMMY_OPPORTUNITY_STAGE_DATA: OpportunityStageTotals = {
  stages: [
    {
      stage: 'Qualify',
      label: 'Qualify',
      amount: 0,
      displayAmount: '0',
      opportunityCount: 2,
    },
    {
      stage: 'Define',
      label: 'Define',
      amount: 150,
      displayAmount: '$150.00',
      opportunityCount: 1,
    },
    {
      stage: 'Design',
      label: 'Design',
      amount: 0,
      displayAmount: '0',
      opportunityCount: 2,
    },
  ],
  totalAmount: 150,
  displayTotalAmount: '$150.00',
  opportunityCount: 5,
};

export function OpportunityStageChart({
  showPartnerCards = false,
  liveCards,
  betweenCardsAndChart,
  besideChart,
}: {
  showPartnerCards?: boolean;
  liveCards?: LiveHomeCardsData | null;
  betweenCardsAndChart?: ReactNode;
  besideChart?: ReactNode;
}) {
  const id = useId();
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
  const result = useAsyncData(
    async () =>
      isPartnerAuthFailed
        ? DUMMY_OPPORTUNITY_STAGE_DATA
        : accountId !== undefined
          ? fetchOpportunityStageAmounts(accountId)
          : null,
    [accountId, isPartnerAuthFailed]
  );
  const isResultAuthFailed = Boolean(
    isPartnerAuthFailed || result.error?.includes('Authentication failed')
  );
  const data = isResultAuthFailed ? DUMMY_OPPORTUNITY_STAGE_DATA : result.data;
  const loading =
    partner.loading ||
    (!isPartnerAuthFailed && accountId !== undefined && result.loading);
  const error = isResultAuthFailed ? null : partner.error || result.error;
  const totals = data?.stages ?? [];
  const minChartWidth = besideChart ? 360 : 500;
  const perStageWidth = besideChart ? 100 : 140;
  const width = Math.max(minChartWidth, totals.length * perStageWidth + 65);
  const left = 55;
  const right = width - 10;
  const top = 24;
  const bottom = 124;
  const totalCount = data?.opportunityCount ?? 0;
  const topStage =
    totals.length > 0
      ? totals.reduce((best, current) =>
          current.amount > best.amount ||
          (current.amount === best.amount &&
            current.opportunityCount > best.opportunityCount)
            ? current
            : best
        )
      : null;
  const lowest = Math.min(0, ...totals.map(total => total.amount));
  const highest = Math.max(0, ...totals.map(total => total.amount));
  const rawStep = (highest - lowest || 1) / 3;
  const magnitude = 10 ** Math.floor(Math.log10(rawStep));
  const step =
    (rawStep / magnitude <= 1
      ? 1
      : rawStep / magnitude <= 2
        ? 2
        : rawStep / magnitude <= 5
          ? 5
          : 10) * magnitude;
  const minimum = Math.floor(lowest / step) * step;
  const maximum =
    Math.ceil(highest / step) * step || (minimum === 0 ? step : 0);
  const y = (value: number) =>
    bottom - ((value - minimum) / (maximum - minimum)) * (bottom - top);
  const baseline = y(0);
  const columnWidth = (right - left) / Math.max(totals.length, 1);
  const tickFormat = new Intl.NumberFormat(undefined, {
    notation: 'compact',
    maximumFractionDigits: 1,
  });
  const ticks = Array.from(
    { length: Math.round((maximum - minimum) / step) + 1 },
    (_, index) => minimum + index * step
  );
  const linkClass =
    'inline-flex shrink-0 items-center gap-1 rounded-sm text-xs font-semibold text-sky-700 hover:underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-sky-700';

  const chartCard = (
    <Card
      role="region"
      aria-labelledby={`${id}-heading`}
      className={`${besideChart ? '' : 'mb-3 '}flex min-w-0 flex-col gap-2.5 rounded-xl border border-slate-200/90 bg-white py-3.5 text-[#0b2340] shadow-xs`}
    >
      <CardHeader className="flex flex-wrap items-center justify-between gap-2 border-b border-slate-100 px-4 pb-2.5">
        <div className="flex items-center gap-2.5">
          <span
            aria-hidden="true"
            className="inline-block h-4 w-1 rounded-full bg-[#0068b5]"
          />
          <div>
            <h2 id={`${id}-heading`} className="text-sm font-bold text-[#0b2340]">
              Opportunity Pipeline
            </h2>
            <p className="text-[11px] text-slate-500">
              Stage-by-stage pipeline value and opportunity volume
            </p>
          </div>
        </div>
        <div className="flex items-center gap-3">
          {!loading && !error && totals.length > 0 && (
            <div
              aria-hidden="true"
              className="hidden items-center gap-3 text-[11px] text-slate-500 sm:flex"
            >
              <span className="inline-flex items-center gap-1.5">
                <span className="size-2.5 rounded-xs bg-[#0875b5]" />
                Active Stage
              </span>
              <span className="inline-flex items-center gap-1.5">
                <span className="size-2.5 rounded-xs bg-[#4a9b70]" />
                Closed Won
              </span>
            </div>
          )}
          <Link to="/opportunities" className={linkClass}>
            View all <ArrowRight aria-hidden="true" className="size-3" />
          </Link>
        </div>
      </CardHeader>
      <CardContent className="min-w-0 px-4">
          {!loading && !error && account?.fallbackReason && (
            <p
              role="status"
              className="mb-2 rounded-md border border-amber-200 bg-amber-50/70 px-2.5 py-1 text-[11px] text-amber-800"
              title={account.fallbackReason}
            >
              Using default account for partner details and opportunities.
            </p>
          )}
          {loading ? (
            <p role="status" className="py-6 text-center text-xs text-slate-500">
              Loading opportunity stage totals...
            </p>
          ) : error ? (
            <p role="alert" className="rounded-md bg-red-50 p-3 text-xs text-red-800">
              Could not load opportunity chart: {error}
            </p>
          ) : !account ? (
            <p className="py-6 text-center text-xs text-slate-500">
              Sign in to view account opportunities.
            </p>
          ) : totals.length === 0 ? (
            <p className="py-6 text-center text-xs text-slate-500">
              No opportunities to chart.
            </p>
          ) : (
            <>
              <div className="grid min-w-0 items-stretch gap-3.5 md:grid-cols-[minmax(0,1.45fr)_minmax(0,1fr)]">
                <div className="flex min-w-0 flex-col justify-between rounded-lg border border-slate-100 bg-slate-50/50 p-3">
                  <div className="mb-1 flex items-center justify-between gap-2 px-1">
                    <span className="text-[11px] font-semibold tracking-wide text-slate-500 uppercase">
                      Amount by Stage
                    </span>
                    <span className="text-[11px] text-slate-500">
                      Deal count shown in badge below each stage
                    </span>
                  </div>
                  <div
                    className="overflow-x-auto rounded-sm focus-visible:outline-2 focus-visible:outline-sky-700"
                    tabIndex={0}
                    role="region"
                    aria-label="Opportunity stage bar chart, scroll horizontally for more stages"
                  >
                    <svg
                      width={width}
                      height={185}
                      viewBox={`0 0 ${width} 185`}
                      role="img"
                      aria-labelledby={`${id}-chart-title ${id}-chart-description`}
                      className="mx-auto block h-[185px] w-full max-w-[640px] text-slate-600"
                    >
                      <title id={`${id}-chart-title`}>
                        Opportunity amounts by stage
                      </title>
                      <desc id={`${id}-chart-description`}>
                        Stages on the X-axis and sum of Amount on the Y-axis.
                        Opportunity counts appear below each stage. Exact
                        amounts and counts are available in View stage totals.
                      </desc>
                      <defs>
                        <linearGradient
                          id={`${id}-blue`}
                          x1="0"
                          y1="0"
                          x2="0"
                          y2="1"
                        >
                          <stop offset="0%" stopColor="#38a8d7" />
                          <stop offset="100%" stopColor="#0068b5" />
                        </linearGradient>
                        <linearGradient
                          id={`${id}-green`}
                          x1="0"
                          y1="0"
                          x2="0"
                          y2="1"
                        >
                          <stop offset="0%" stopColor="#8ac69a" />
                          <stop offset="100%" stopColor="#4a9b70" />
                        </linearGradient>
                      </defs>
                      {ticks.map(value => (
                        <g key={value}>
                          <line
                            x1={left}
                            x2={right}
                            y1={y(value)}
                            y2={y(value)}
                            stroke="#e2e8f0"
                            strokeDasharray={value === 0 ? undefined : '3 3'}
                          />
                          <text
                            x={left - 8}
                            y={y(value) + 4}
                            textAnchor="end"
                            fontSize={10}
                            fill="currentColor"
                          >
                            {tickFormat.format(value)}
                          </text>
                        </g>
                      ))}
                      <line
                        x1={left}
                        x2={right}
                        y1={baseline}
                        y2={baseline}
                        stroke="#94a3b8"
                      />
                      {totals.map((total, index) => {
                        const center = left + columnWidth * (index + 0.5);
                        const barWidth = Math.min(56, columnWidth * 0.58);
                        const closedWon =
                          total.stage?.toLowerCase() === 'closed won';
                        return (
                          <g key={total.stage ?? `${id}-unspecified`}>
                            <rect
                              x={center - barWidth / 2}
                              y={Math.min(y(total.amount), baseline)}
                              width={barWidth}
                              height={Math.abs(y(total.amount) - baseline)}
                              rx={4}
                              fill={
                                total.amount < 0
                                  ? '#e11d48'
                                  : `url(#${id}-${closedWon ? 'green' : 'blue'})`
                              }
                              tabIndex={0}
                              role="img"
                              aria-label={`${total.label}: ${total.displayAmount}, ${total.opportunityCount.toLocaleString()} opportunities`}
                            >
                              <title>
                                {total.label}: {total.displayAmount};{' '}
                                {total.opportunityCount.toLocaleString()}{' '}
                                opportunities
                              </title>
                            </rect>
                            <text
                              x={center}
                              y={
                                total.amount < 0
                                  ? Math.min(y(total.amount) + 13, bottom - 4)
                                  : y(total.amount) - 7
                              }
                              textAnchor="middle"
                              fontSize={10}
                              fontWeight={700}
                              fill="#0b2340"
                            >
                              {total.displayAmount}
                            </text>
                            <foreignObject
                              x={left + columnWidth * index + 3}
                              y={bottom + 6}
                              width={columnWidth - 6}
                              height={54}
                            >
                              <div className="flex flex-col items-center justify-start gap-1 text-center text-[10px] leading-3 text-slate-600">
                                <span
                                  className="line-clamp-2 font-medium break-words text-slate-700"
                                  title={total.label}
                                >
                                  {total.label}
                                </span>
                                <span
                                  className="inline-flex min-w-5 items-center justify-center rounded-full bg-sky-100/90 px-1.5 py-0.5 text-[10px] font-bold text-[#0068b5]"
                                  aria-label={`${total.label}: ${total.opportunityCount.toLocaleString()} opportunities`}
                                >
                                  {total.opportunityCount.toLocaleString()}
                                </span>
                              </div>
                            </foreignObject>
                          </g>
                        );
                      })}
                    </svg>
                  </div>
                </div>
                <div className="flex min-w-0 flex-col justify-between gap-2.5 rounded-lg border border-sky-100 bg-linear-to-br from-slate-50 via-white to-sky-50/70 p-3.5">
                  <div className="grid grid-cols-1 gap-2.5 sm:grid-cols-2">
                    <div className="rounded-lg border border-sky-100 bg-white p-2.5 shadow-2xs">
                      <p
                        className="break-words text-lg font-extrabold tracking-tight text-[#0068b5] lg:text-xl"
                        title={data?.displayTotalAmount}
                        aria-label={`Total pipeline value: ${data?.displayTotalAmount}`}
                      >
                        {data?.displayTotalAmount}
                      </p>
                      <p className="mt-0.5 text-[11px] font-medium text-slate-500">
                        Total Pipeline Value
                      </p>
                    </div>
                    <div className="rounded-lg border border-slate-200/80 bg-white p-2.5 shadow-2xs">
                      <p className="text-lg font-extrabold text-[#0b2340] lg:text-xl">
                        {data?.opportunityCount.toLocaleString()}
                      </p>
                      <p className="mt-0.5 text-[11px] font-medium text-slate-500">
                        Total Opportunities
                      </p>
                      <p className="mt-0.5 text-[10px] text-slate-400">
                        {account?.opportunityScope === 'all-accessible'
                          ? 'Across all stages, visible to you'
                          : 'For the selected account, across all stages'}
                      </p>
                    </div>
                  </div>
                  <div className="rounded-lg border border-slate-200/70 bg-white/90 p-2.5">
                    <div className="mb-1.5 flex items-center justify-between gap-2 text-[11px]">
                      <span className="font-semibold text-slate-600">
                        Stage Share ({totals.length})
                      </span>
                      {topStage && (
                        <span className="truncate text-[10px] text-slate-500">
                          Top stage:{' '}
                          <strong className="font-semibold text-[#0b2340]">
                            {topStage.label}
                          </strong>
                        </span>
                      )}
                    </div>
                    <div className="flex flex-col gap-1.5">
                      {totals.slice(0, 4).map(stageItem => {
                        const pct =
                          totalCount > 0
                            ? Math.round(
                                (stageItem.opportunityCount / totalCount) * 100
                              )
                            : 0;
                        const isWon =
                          stageItem.stage?.toLowerCase() === 'closed won';
                        return (
                          <div
                            key={`share-${stageItem.stage ?? stageItem.label}`}
                            className="flex flex-col gap-0.5"
                          >
                            <div className="flex items-center justify-between gap-2 text-[11px]">
                              <span className="truncate font-medium text-slate-700">
                                {stageItem.label}
                              </span>
                              <span className="shrink-0 tabular-nums text-[10px] text-slate-500">
                                {stageItem.opportunityCount} ({pct}%)
                              </span>
                            </div>
                            <div className="h-1.5 w-full overflow-hidden rounded-full bg-slate-100">
                              <div
                                className={`h-full rounded-full ${
                                  isWon ? 'bg-[#4a9b70]' : 'bg-[#0068b5]'
                                }`}
                                style={{ width: `${Math.max(pct, 6)}%` }}
                              />
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                  <div className="flex items-center justify-between gap-2 pt-0.5">
                    <span className="text-[11px] text-slate-500">
                      {totals.filter(t => t.amount > 0).length} of{' '}
                      {totals.length} stages with valued pipeline
                    </span>
                    <Link to="/opportunities" className={linkClass}>
                      View opportunities{' '}
                      <ArrowRight aria-hidden="true" className="size-3" />
                    </Link>
                  </div>
                </div>
              </div>
              <details className="mt-2 rounded-lg border border-slate-100 bg-slate-50/60 px-3 py-1.5 text-xs">
                <summary className="cursor-pointer font-medium text-sky-700 select-none">
                  View stage totals
                </summary>
                <div className="mt-2 overflow-x-auto">
                  <table className="w-full text-left">
                    <caption className="sr-only">
                      Exact opportunity amount totals by stage
                    </caption>
                    <thead>
                      <tr className="border-b border-slate-200 text-[11px] text-slate-500 uppercase">
                        <th scope="col" className="p-2">
                          Stage
                        </th>
                        <th scope="col" className="p-2 text-right">
                          Sum of Amount
                        </th>
                        <th scope="col" className="p-2 text-right">
                          Opportunities
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      {totals.map(total => (
                        <tr
                          key={total.stage ?? `${id}-unspecified`}
                          className="border-t border-slate-200/70"
                        >
                          <th scope="row" className="p-2 font-medium text-[#0b2340]">
                            {total.label}
                          </th>
                          <td className="p-2 text-right tabular-nums">
                            {total.displayAmount}
                          </td>
                          <td className="p-2 text-right tabular-nums">
                            {total.opportunityCount.toLocaleString()}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </details>
            </>
          )}
        </CardContent>
      </Card>
  );

  return (
    <>
      {showPartnerCards && (
        <HomeDashboardCards
          pipelineValue={
            !loading && !error && account
              ? (data?.displayTotalAmount ?? null)
              : null
          }
          loading={loading}
          error={
            error ||
            (!loading && !account
              ? 'Sign in to view account opportunities.'
              : null)
          }
          liveCards={liveCards}
        />
      )}
      {betweenCardsAndChart}
      {besideChart ? (
        <div className="grid shrink-0 grow grid-cols-1 items-stretch gap-3 lg:grid-cols-[minmax(0,1.85fr)_minmax(0,1fr)]">
          {chartCard}
          <div className="flex min-w-0 flex-col justify-between gap-3">
            {besideChart}
          </div>
        </div>
      ) : (
        chartCard
      )}
    </>
  );
}
