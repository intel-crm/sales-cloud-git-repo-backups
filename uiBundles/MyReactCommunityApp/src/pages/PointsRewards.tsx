import { Link } from 'react-router';
import {
  AlertCircle,
  ArrowRight,
  CalendarClock,
  CheckCircle2,
  Coins,
  Gift,
  TrendingUp,
} from 'lucide-react';
import { ComingSoonThreeScene } from '../components/ComingSoonThreeScene';
import { Card, CardContent } from '../components/ui/card';
import { Skeleton } from '../components/ui/skeleton';
import { useAsyncData } from '../hooks/useAsyncData';
import { useOptionalPartnerAccount } from '../features/partner/context/PartnerAccountContext';
import {
  DUMMY_POINTS_SUMMARY,
  fetchPartnerPointsData,
  isAuthFailureMessage,
} from '../api/partnerPortalData';

export function ComingSoonPage({ title }: { title: string }) {
  return (
    <main className="flex w-full shrink-0 grow flex-col items-center justify-center px-6 pt-6 pb-16 text-center sm:px-8 lg:px-12 xl:px-16">
      <title>{`${title} | Partner experience`}</title>
      <h1 className="mb-2 text-[clamp(1.5rem,2.2vw,2.25rem)] font-bold text-[#0b2340]">
        {title}
      </h1>
      <ComingSoonThreeScene />
      <p className="mt-2 text-[clamp(1rem,1.2vw,1.25rem)] font-medium text-slate-600">
        Coming soon...Page under Construction
      </p>
    </main>
  );
}

function fmt(n: number): string {
  return new Intl.NumberFormat('en-US').format(Math.round(n));
}

export default function PointsRewardsPage() {
  const partner = useOptionalPartnerAccount();
  const isAuthFailed = Boolean(
    partner?.isAuthFallback || isAuthFailureMessage(partner?.error)
  );
  const readyAccount =
    partner?.account?.kind === 'ready' ? partner.account : null;
  const accountId =
    readyAccount?.opportunityScope === 'all-accessible'
      ? null
      : readyAccount?.accountId ?? null;

  const { data: rawData, loading, error: rawError } = useAsyncData(
    async () =>
      isAuthFailed
        ? DUMMY_POINTS_SUMMARY
        : fetchPartnerPointsData(accountId),
    [accountId, isAuthFailed]
  );

  const useFallback = Boolean(isAuthFailed || isAuthFailureMessage(rawError));
  const summary = useFallback
    ? DUMMY_POINTS_SUMMARY
    : (rawData ?? DUMMY_POINTS_SUMMARY);

  return (
    <main className="flex w-full shrink-0 grow flex-col gap-4 px-6 pt-5 pb-16 sm:px-8 lg:px-12 xl:px-16">
      <title>Points &amp; Rewards | Partner experience</title>

      {/* Hero Header */}
      <section className="flex flex-wrap items-center justify-between gap-4 rounded-xl border border-sky-100 bg-linear-to-r from-[#0b2340] via-[#103158] to-[#174a8b] px-5 py-4 text-white shadow-sm">
        <div className="flex min-w-0 items-center gap-3.5">
          <span className="flex size-11 shrink-0 items-center justify-center rounded-xl bg-sky-400/20 text-sky-300 ring-1 ring-sky-300/30">
            <Coins aria-hidden="true" className="size-5.5" />
          </span>
          <div className="min-w-0">
            <div className="mb-1 flex flex-wrap items-center gap-2">
              <span className="inline-flex items-center gap-1 rounded-full bg-sky-400/20 px-2.5 py-0.5 text-[11px] font-semibold text-sky-200 ring-1 ring-sky-300/30">
                PRM_Points_Data__c
              </span>
              {readyAccount?.badgeTier && (
                <span className="rounded-md bg-white/10 px-2 py-0.5 text-[11px] font-semibold text-amber-200">
                  {readyAccount.badgeTier} Tier
                </span>
              )}
            </div>
            <h1 className="text-[clamp(1.25rem,1.6vw,1.65rem)] leading-tight font-bold tracking-tight">
              Points &amp; Rewards
            </h1>
            <p className="mt-0.5 text-xs text-sky-100/85 sm:text-sm">
              Track partner rebate accruals, available point balances, redemptions, and upcoming expirations.
            </p>
          </div>
        </div>
        <Link
          to="/benefits"
          className="inline-flex items-center gap-1.5 rounded-lg bg-[#0068b5] px-3.5 py-1.5 text-xs font-semibold text-white shadow-xs transition-colors hover:bg-[#005494]"
        >
          View Points Benefits <ArrowRight aria-hidden="true" className="size-3.5" />
        </Link>
      </section>

      {loading ? (
        <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-4">
          <Skeleton className="h-24 rounded-xl" />
          <Skeleton className="h-24 rounded-xl" />
          <Skeleton className="h-24 rounded-xl" />
          <Skeleton className="h-24 rounded-xl" />
        </div>
      ) : (
        <>
          {/* 4 KPI Summary Cards */}
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-4">
            <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
              <div className="flex items-center justify-between gap-2">
                <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
                  Points Balance
                </span>
                <span className="flex size-8 items-center justify-center rounded-lg bg-sky-100 text-[#0068b5]">
                  <Coins aria-hidden="true" className="size-4" />
                </span>
              </div>
              <div>
                <p className="text-2xl font-bold tracking-tight text-[#0b2340]">
                  {fmt(summary.totalBalance)} pts
                </p>
                <p className="mt-0.5 text-xs text-slate-500">
                  Across {summary.records.length} active ledger record{summary.records.length === 1 ? '' : 's'}
                </p>
              </div>
            </Card>

            <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
              <div className="flex items-center justify-between gap-2">
                <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
                  Total Earned
                </span>
                <span className="flex size-8 items-center justify-center rounded-lg bg-emerald-100 text-emerald-700">
                  <TrendingUp aria-hidden="true" className="size-4" />
                </span>
              </div>
              <div>
                <p className="text-2xl font-bold tracking-tight text-[#0b2340]">
                  {fmt(summary.totalEarned)} pts
                </p>
                <p className="mt-0.5 text-xs text-slate-500">
                  Cumulative points accrued
                </p>
              </div>
            </Card>

            <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
              <div className="flex items-center justify-between gap-2">
                <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
                  Total Redeemed
                </span>
                <span className="flex size-8 items-center justify-center rounded-lg bg-violet-100 text-violet-700">
                  <Gift aria-hidden="true" className="size-4" />
                </span>
              </div>
              <div>
                <p className="text-2xl font-bold tracking-tight text-[#0b2340]">
                  {fmt(summary.totalRedeemed)} pts
                </p>
                <p className="mt-0.5 text-xs text-slate-500">
                  Claimed toward partner rewards
                </p>
              </div>
            </Card>

            <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
              <div className="flex items-center justify-between gap-2">
                <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
                  Due to Expire
                </span>
                <span className="flex size-8 items-center justify-center rounded-lg bg-amber-100 text-amber-600">
                  <CalendarClock aria-hidden="true" className="size-4" />
                </span>
              </div>
              <div>
                <p className="text-2xl font-bold tracking-tight text-[#0b2340]">
                  {fmt(summary.totalDueToExpire)} pts
                </p>
                <p className="mt-0.5 text-xs text-slate-500">
                  Redeem before period end date
                </p>
              </div>
            </Card>
          </div>

          {/* Points Ledger Table */}
          <Card className="gap-3 rounded-xl border border-slate-200/90 bg-white py-4 text-[#0b2340] shadow-xs">
            <div className="flex flex-wrap items-center justify-between gap-2 border-b border-slate-100 px-5 pb-3">
              <div className="flex items-center gap-2.5">
                <span className="inline-block h-4 w-1 rounded-full bg-[#0068b5]" />
                <div>
                  <h2 className="text-sm font-bold text-[#0b2340]">
                    Partner Points Ledger
                  </h2>
                  <p className="text-[11px] text-slate-500">
                    {summary.scope === 'account'
                      ? 'Points records linked directly to your partner account'
                      : summary.scope === 'org-accessible'
                        ? 'Live partner points records loaded from Salesforce (PRM_Points_Data__c)'
                        : 'Sample points ledger preview'}
                  </p>
                </div>
              </div>
              <span className="inline-flex items-center gap-1 rounded-full bg-emerald-50 px-2.5 py-0.5 text-[11px] font-semibold text-emerald-700">
                <CheckCircle2 aria-hidden="true" className="size-3" />
                {summary.records.length} Records
              </span>
            </div>

            <CardContent className="overflow-x-auto px-5 pt-1">
              <table className="w-full border-collapse text-left text-xs">
                <thead>
                  <tr className="border-b border-slate-200 text-[11px] font-semibold tracking-wider text-slate-500 uppercase">
                    <th className="py-2.5 pr-4">Record</th>
                    <th className="py-2.5 pr-4">Partner Account</th>
                    <th className="py-2.5 pr-4 text-right">Balance</th>
                    <th className="py-2.5 pr-4 text-right">Available</th>
                    <th className="py-2.5 pr-4 text-right">Due to Expire</th>
                    <th className="py-2.5 pr-4">Period</th>
                    <th className="py-2.5 text-right">Last Synced</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {summary.records.map(rec => (
                    <tr key={rec.id} className="hover:bg-sky-50/40">
                      <td className="py-2.5 pr-4 font-semibold text-[#0b2340]">
                        {rec.name}
                      </td>
                      <td className="py-2.5 pr-4 text-slate-600">
                        {rec.accountId ? (
                          <Link
                            to={`/accounts/${encodeURIComponent(rec.accountId)}`}
                            className="font-medium text-[#0068b5] hover:underline"
                          >
                            {rec.accountName ?? rec.accountId}
                          </Link>
                        ) : (
                          (rec.accountName ?? '—')
                        )}
                      </td>
                      <td className="py-2.5 pr-4 text-right font-bold text-[#0b2340]">
                        {fmt(rec.balance)} pts
                      </td>
                      <td className="py-2.5 pr-4 text-right text-slate-700">
                        {fmt(rec.available)} pts
                      </td>
                      <td className="py-2.5 pr-4 text-right">
                        {rec.dueToExpire > 0 ? (
                          <span className="inline-flex items-center gap-1 rounded-full bg-amber-50 px-2 py-0.5 font-semibold text-amber-700">
                            <AlertCircle aria-hidden="true" className="size-3" />
                            {fmt(rec.dueToExpire)} pts
                          </span>
                        ) : (
                          <span className="text-slate-400">0 pts</span>
                        )}
                      </td>
                      <td className="py-2.5 pr-4 text-slate-500">
                        {rec.startDate || rec.endDate
                          ? `${rec.startDate ?? '—'} → ${rec.endDate ?? '—'}`
                          : 'Active cycle'}
                      </td>
                      <td className="py-2.5 text-right text-slate-500">
                        {rec.lastUpdated?.slice(0, 10) ?? '—'}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </CardContent>
          </Card>
        </>
      )}
    </main>
  );
}
