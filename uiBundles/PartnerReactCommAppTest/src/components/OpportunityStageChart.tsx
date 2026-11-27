import { useId } from 'react';
import { ArrowRight } from 'lucide-react';
import { Link } from 'react-router';
import { fetchOpportunityStageAmounts } from '../api/opportunityStageAmounts';
import { useAsyncData } from '../hooks/useAsyncData';
import { Card, CardContent, CardHeader } from './ui/card';
import { usePartnerAccount } from '../features/partner/context/PartnerAccountContext';
import { HomeDashboardCards } from './HomeDashboardCards';

export function OpportunityStageChart({
  showPartnerCards = false,
}: {
  showPartnerCards?: boolean;
}) {
  const id = useId();
  const partner = usePartnerAccount();
  const account = partner.account?.kind === 'ready' ? partner.account : null;
  const accountId =
    account?.opportunityScope === 'all-accessible' ? null : account?.accountId;
  const result = useAsyncData(
    async () =>
      accountId !== undefined ? fetchOpportunityStageAmounts(accountId) : null,
    [accountId]
  );
  const { data } = result;
  const loading =
    partner.loading || (accountId !== undefined && result.loading);
  const error = partner.error || result.error;
  const totals = data?.stages ?? [];
  const width = Math.max(360, totals.length * 100 + 65);
  const left = 55;
  const right = width - 10;
  const top = 24;
  const bottom = 124;
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
        />
      )}
      <Card
        role="region"
        aria-labelledby={`${id}-heading`}
        className="mb-6 min-w-0 gap-2 rounded-lg bg-white py-3 text-[#0b2340] shadow-sm"
      >
        <CardHeader className="flex items-center justify-between gap-3">
          <h2 id={`${id}-heading`} className="text-base font-bold">
            Opportunity Pipeline
          </h2>
          <Link to="/opportunities" className={linkClass}>
            View all <ArrowRight aria-hidden="true" className="size-3" />
          </Link>
        </CardHeader>
        <CardContent className="min-w-0">
          {!loading && !error && account?.fallbackReason && (
            <p
              role="status"
              className="mb-2 text-xs text-amber-800"
              title={account.fallbackReason}
            >
              Using default account for partner details and opportunities.
            </p>
          )}
          {loading ? (
            <p role="status">Loading opportunity stage totals...</p>
          ) : error ? (
            <p role="alert" className="text-sm text-red-800">
              Could not load opportunity chart: {error}
            </p>
          ) : !account ? (
            <p>Sign in to view account opportunities.</p>
          ) : totals.length === 0 ? (
            <p>No opportunities to chart.</p>
          ) : (
            <>
              <div className="grid min-w-0 gap-4 md:grid-cols-[minmax(0,1.6fr)_minmax(0,1fr)] md:gap-0">
                <div className="min-w-0 md:pr-4">
                  <div
                    className="overflow-x-auto rounded-sm focus-visible:outline-2 focus-visible:outline-sky-700"
                    tabIndex={0}
                    role="region"
                    aria-label="Opportunity stage bar chart, scroll horizontally for more stages"
                  >
                    <svg
                      width={width}
                      height={185}
                      role="img"
                      aria-labelledby={`${id}-chart-title ${id}-chart-description`}
                      className="block text-slate-600"
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
                          <stop offset="100%" stopColor="#0875b5" />
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
                        const barWidth = Math.min(58, columnWidth * 0.65);
                        const closedWon =
                          total.stage?.toLowerCase() === 'closed won';
                        return (
                          <g key={total.stage ?? `${id}-unspecified`}>
                            <rect
                              x={center - barWidth / 2}
                              y={Math.min(y(total.amount), baseline)}
                              width={barWidth}
                              height={Math.abs(y(total.amount) - baseline)}
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
                              fontWeight={600}
                              fill="#0b2340"
                            >
                              {total.displayAmount}
                            </text>
                            <foreignObject
                              x={left + columnWidth * index + 3}
                              y={bottom + 7}
                              width={columnWidth - 6}
                              height={53}
                            >
                              <div className="text-center text-[10px] leading-3 text-slate-600">
                                <span
                                  className="line-clamp-2 min-h-6 break-words"
                                  title={total.label}
                                >
                                  {total.label}
                                </span>
                                <span
                                  className="mt-1 block font-semibold text-[#0b2340]"
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
                <div className="flex min-w-0 flex-col justify-center gap-4 rounded-md bg-linear-to-br from-slate-50 to-sky-50 p-4 md:rounded-l-none md:border-l md:border-slate-100">
                  <div>
                    <p
                      className="break-words text-2xl font-bold tracking-tight"
                      title={data?.displayTotalAmount}
                      aria-label={`Total pipeline value: ${data?.displayTotalAmount}`}
                    >
                      {data?.displayTotalAmount}
                    </p>
                    <p className="mt-1 text-xs text-slate-500">
                      Total Pipeline Value
                    </p>
                  </div>
                  <div>
                    <p className="text-2xl font-bold">
                      {data?.opportunityCount.toLocaleString()}
                    </p>
                    <p className="mt-1 text-xs text-slate-500">
                      Total Opportunities
                    </p>
                    <p className="mt-1 text-[10px] text-slate-500">
                      {account?.opportunityScope === 'all-accessible'
                        ? 'Across all stages, visible to you'
                        : 'For the selected account, across all stages'}
                    </p>
                  </div>
                  <Link to="/opportunities" className={`${linkClass} self-end`}>
                    View opportunities{' '}
                    <ArrowRight aria-hidden="true" className="size-3" />
                  </Link>
                </div>
              </div>
              <details className="mt-2 text-xs">
                <summary className="cursor-pointer font-medium text-sky-700">
                  View stage totals
                </summary>
                <div className="mt-2 overflow-x-auto">
                  <table className="w-full text-left">
                    <caption className="sr-only">
                      Exact opportunity amount totals by stage
                    </caption>
                    <thead>
                      <tr>
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
                          className="border-t"
                        >
                          <th scope="row" className="p-2 font-normal">
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
    </>
  );
}
