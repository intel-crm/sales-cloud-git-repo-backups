import { Link } from 'react-router';
import {
  ArrowRight,
  CheckCircle2,
  PackageCheck,
  RefreshCw,
  ShieldCheck,
} from 'lucide-react';
import { Card, CardContent } from '../components/ui/card';
import { Skeleton } from '../components/ui/skeleton';
import { useAsyncData } from '../hooks/useAsyncData';
import { useOptionalPartnerAccount } from '../features/partner/context/PartnerAccountContext';
import {
  DUMMY_WARRANTY_SUMMARY,
  fetchPartnerWarrantyData,
  isAuthFailureMessage,
} from '../api/partnerPortalData';

function fmt(n: number): string {
  return new Intl.NumberFormat('en-US').format(Math.round(n));
}

export default function WarrantyPage() {
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
        ? DUMMY_WARRANTY_SUMMARY
        : fetchPartnerWarrantyData(accountId),
    [accountId, isAuthFailed]
  );

  const useFallback = Boolean(isAuthFailed || isAuthFailureMessage(rawError));
  const summary = useFallback
    ? DUMMY_WARRANTY_SUMMARY
    : (rawData ?? DUMMY_WARRANTY_SUMMARY);

  const awrTotal = summary.awrRemaining + summary.awrUsed || 1;
  const swrTotal = summary.swrRemaining + summary.swrUsed || 1;
  const awrPct = Math.round((summary.awrRemaining / awrTotal) * 100);
  const swrPct = Math.round((summary.swrRemaining / swrTotal) * 100);

  return (
    <main className="flex w-full shrink-0 grow flex-col gap-4 px-6 pt-5 pb-16 sm:px-8 lg:px-12 xl:px-16">
      <title>Warranty | Partner experience</title>

      {/* Hero Header */}
      <section className="flex flex-wrap items-center justify-between gap-4 rounded-xl border border-sky-100 bg-linear-to-r from-[#0b2340] via-[#103158] to-[#174a8b] px-5 py-4 text-white shadow-sm">
        <div className="flex min-w-0 items-center gap-3.5">
          <span className="flex size-11 shrink-0 items-center justify-center rounded-xl bg-emerald-400/20 text-emerald-300 ring-1 ring-emerald-300/30">
            <ShieldCheck aria-hidden="true" className="size-5.5" />
          </span>
          <div className="min-w-0">
            <div className="mb-1 flex flex-wrap items-center gap-2">
              <span className="inline-flex items-center gap-1 rounded-full bg-sky-400/20 px-2.5 py-0.5 text-[11px] font-semibold text-sky-200 ring-1 ring-sky-300/30">
                PRM_Warranty_Data__c
              </span>
              <span className="rounded-md bg-emerald-400/20 px-2 py-0.5 text-[11px] font-semibold text-emerald-200">
                Status: {summary.statusLabel}
              </span>
            </div>
            <h1 className="text-[clamp(1.25rem,1.6vw,1.65rem)] leading-tight font-bold tracking-tight">
              Partner Warranty Entitlements
            </h1>
            <p className="mt-0.5 text-xs text-sky-100/85 sm:text-sm">
              Monitor Advanced Warranty Replacement (AWR) and Standard Warranty Replacement (SWR) allocations.
            </p>
          </div>
        </div>
        <Link
          to="/benefits"
          className="inline-flex items-center gap-1.5 rounded-lg bg-[#0068b5] px-3.5 py-1.5 text-xs font-semibold text-white shadow-xs transition-colors hover:bg-[#005494]"
        >
          Manage Benefits <ArrowRight aria-hidden="true" className="size-3.5" />
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
                  AWR Remaining
                </span>
                <span className="flex size-8 items-center justify-center rounded-lg bg-emerald-100 text-emerald-700">
                  <ShieldCheck aria-hidden="true" className="size-4" />
                </span>
              </div>
              <div>
                <p className="text-2xl font-bold tracking-tight text-[#0b2340]">
                  {fmt(summary.awrRemaining)}
                </p>
                <div className="mt-1.5 h-1.5 w-full overflow-hidden rounded-full bg-slate-100">
                  <div
                    className="h-full rounded-full bg-emerald-500"
                    style={{ width: `${awrPct}%` }}
                  />
                </div>
                <p className="mt-1 text-xs text-slate-500">
                  {awrPct}% of AWR pool available
                </p>
              </div>
            </Card>

            <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
              <div className="flex items-center justify-between gap-2">
                <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
                  AWR Used
                </span>
                <span className="flex size-8 items-center justify-center rounded-lg bg-sky-100 text-[#0068b5]">
                  <RefreshCw aria-hidden="true" className="size-4" />
                </span>
              </div>
              <div>
                <p className="text-2xl font-bold tracking-tight text-[#0b2340]">
                  {fmt(summary.awrUsed)}
                </p>
                <p className="mt-1 text-xs text-slate-500">
                  Advanced replacement claims fulfilled
                </p>
              </div>
            </Card>

            <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
              <div className="flex items-center justify-between gap-2">
                <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
                  SWR Remaining
                </span>
                <span className="flex size-8 items-center justify-center rounded-lg bg-violet-100 text-violet-700">
                  <PackageCheck aria-hidden="true" className="size-4" />
                </span>
              </div>
              <div>
                <p className="text-2xl font-bold tracking-tight text-[#0b2340]">
                  {fmt(summary.swrRemaining)}
                </p>
                <div className="mt-1.5 h-1.5 w-full overflow-hidden rounded-full bg-slate-100">
                  <div
                    className="h-full rounded-full bg-[#0068b5]"
                    style={{ width: `${swrPct}%` }}
                  />
                </div>
                <p className="mt-1 text-xs text-slate-500">
                  {swrPct}% of SWR pool available
                </p>
              </div>
            </Card>

            <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
              <div className="flex items-center justify-between gap-2">
                <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
                  SWR Used
                </span>
                <span className="flex size-8 items-center justify-center rounded-lg bg-amber-100 text-amber-600">
                  <CheckCircle2 aria-hidden="true" className="size-4" />
                </span>
              </div>
              <div>
                <p className="text-2xl font-bold tracking-tight text-[#0b2340]">
                  {fmt(summary.swrUsed)}
                </p>
                <p className="mt-1 text-xs text-slate-500">
                  Standard replacement claims fulfilled
                </p>
              </div>
            </Card>
          </div>

          {/* Warranty Records Table */}
          <Card className="gap-3 rounded-xl border border-slate-200/90 bg-white py-4 text-[#0b2340] shadow-xs">
            <div className="flex items-center justify-between gap-2 border-b border-slate-100 px-5 pb-3">
              <div className="flex items-center gap-2.5">
                <span className="inline-block h-4 w-1 rounded-full bg-[#0068b5]" />
                <div>
                  <h2 className="text-sm font-bold text-[#0b2340]">
                    Warranty Entitlement Allocations
                  </h2>
                  <p className="text-[11px] text-slate-500">
                    {summary.scope === 'account'
                      ? 'Warranty records linked to your partner account'
                      : summary.scope === 'org-accessible'
                        ? 'Live warranty records loaded from Salesforce (PRM_Warranty_Data__c)'
                        : 'Sample warranty allocations'}
                  </p>
                </div>
              </div>
            </div>

            <CardContent className="overflow-x-auto px-5 pt-1">
              <table className="w-full border-collapse text-left text-xs">
                <thead>
                  <tr className="border-b border-slate-200 text-[11px] font-semibold tracking-wider text-slate-500 uppercase">
                    <th className="py-2.5 pr-4">Record ID</th>
                    <th className="py-2.5 pr-4">Partner Account</th>
                    <th className="py-2.5 pr-4 text-right">AWR Remaining</th>
                    <th className="py-2.5 pr-4 text-right">AWR Used</th>
                    <th className="py-2.5 pr-4 text-right">SWR Remaining</th>
                    <th className="py-2.5 pr-4 text-right">SWR Used</th>
                    <th className="py-2.5 text-right">As of Date</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {summary.records.map(rec => (
                    <tr key={rec.id} className="hover:bg-sky-50/40">
                      <td className="py-2.5 pr-4 font-semibold text-[#0b2340]">
                        {rec.name}
                      </td>
                      <td className="py-2.5 pr-4 text-slate-600">
                        {rec.accountName ?? 'Partner Account'}
                      </td>
                      <td className="py-2.5 pr-4 text-right font-bold text-emerald-700">
                        {fmt(rec.awrRemaining)}
                      </td>
                      <td className="py-2.5 pr-4 text-right text-slate-600">
                        {fmt(rec.awrUsed)}
                      </td>
                      <td className="py-2.5 pr-4 text-right font-bold text-[#0068b5]">
                        {fmt(rec.swrRemaining)}
                      </td>
                      <td className="py-2.5 pr-4 text-right text-slate-600">
                        {fmt(rec.swrUsed)}
                      </td>
                      <td className="py-2.5 text-right text-slate-500">
                        {rec.asOfDate ?? 'Current'}
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
