import { useState } from 'react';
import { Link } from 'react-router';
import {
  ArrowRight,
  Award,
  CheckCircle2,
  Clock,
  Layers,
  Settings,
  XCircle,
} from 'lucide-react';
import { Card, CardContent } from '../components/ui/card';
import { Skeleton } from '../components/ui/skeleton';
import { useAsyncData } from '../hooks/useAsyncData';
import { useOptionalPartnerAccount } from '../features/partner/context/PartnerAccountContext';
import {
  DUMMY_BENEFITS_SUMMARY,
  fetchPartnerBenefitsData,
  isAuthFailureMessage,
} from '../api/partnerPortalData';

type BenefitFilter = 'all' | 'active' | 'inactive' | 'catalog';

export default function ManageBenefitsPage() {
  const [filter, setFilter] = useState<BenefitFilter>('all');
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
        ? DUMMY_BENEFITS_SUMMARY
        : fetchPartnerBenefitsData(accountId),
    [accountId, isAuthFailed]
  );

  const useFallback = Boolean(isAuthFailed || isAuthFailureMessage(rawError));
  const summary = useFallback
    ? DUMMY_BENEFITS_SUMMARY
    : (rawData ?? DUMMY_BENEFITS_SUMMARY);

  const displayedItems =
    filter === 'catalog'
      ? summary.catalogBenefits
      : summary.enrolledBenefits.filter(item => {
          if (filter === 'active') return item.status.toLowerCase() === 'active';
          if (filter === 'inactive')
            return item.status.toLowerCase() !== 'active';
          return true;
        });

  return (
    <main className="flex w-full shrink-0 grow flex-col gap-4 px-6 pt-5 pb-16 sm:px-8 lg:px-12 xl:px-16">
      <title>Manage Benefits | Partner experience</title>

      {/* Hero Header */}
      <section className="flex flex-wrap items-center justify-between gap-4 rounded-xl border border-sky-100 bg-linear-to-r from-[#0b2340] via-[#103158] to-[#174a8b] px-5 py-4 text-white shadow-sm">
        <div className="flex min-w-0 items-center gap-3.5">
          <span className="flex size-11 shrink-0 items-center justify-center rounded-xl bg-sky-400/20 text-sky-300 ring-1 ring-sky-300/30">
            <Settings aria-hidden="true" className="size-5.5" />
          </span>
          <div className="min-w-0">
            <div className="mb-1 flex flex-wrap items-center gap-2">
              <span className="inline-flex items-center gap-1 rounded-full bg-sky-400/20 px-2.5 py-0.5 text-[11px] font-semibold text-sky-200 ring-1 ring-sky-300/30">
                PRM_AccountBenefitAssociation__c
              </span>
              {readyAccount?.badgeTier && (
                <span className="rounded-md bg-white/10 px-2 py-0.5 text-[11px] font-semibold text-amber-200">
                  {readyAccount.badgeTier} Tier
                </span>
              )}
            </div>
            <h1 className="text-[clamp(1.25rem,1.6vw,1.65rem)] leading-tight font-bold tracking-tight">
              Manage Partner Benefits
            </h1>
            <p className="mt-0.5 text-xs text-sky-100/85 sm:text-sm">
              Review active Intel&reg; Partner Alliance entitlements, benefit associations, and program catalog offerings.
            </p>
          </div>
        </div>
        <Link
          to="/points-rewards"
          className="inline-flex items-center gap-1.5 rounded-lg bg-[#0068b5] px-3.5 py-1.5 text-xs font-semibold text-white shadow-xs transition-colors hover:bg-[#005494]"
        >
          View Points Balance <ArrowRight aria-hidden="true" className="size-3.5" />
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
          {/* 4 Summary Cards */}
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-4">
            <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
              <div className="flex items-center justify-between gap-2">
                <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
                  Total Associations
                </span>
                <span className="flex size-8 items-center justify-center rounded-lg bg-sky-100 text-[#0068b5]">
                  <Layers aria-hidden="true" className="size-4" />
                </span>
              </div>
              <div>
                <p className="text-2xl font-bold tracking-tight text-[#0b2340]">
                  {summary.totalCount}
                </p>
                <p className="mt-0.5 text-xs text-slate-500">
                  Enrolled partner benefit records
                </p>
              </div>
            </Card>

            <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
              <div className="flex items-center justify-between gap-2">
                <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
                  Active Benefits
                </span>
                <span className="flex size-8 items-center justify-center rounded-lg bg-emerald-100 text-emerald-700">
                  <CheckCircle2 aria-hidden="true" className="size-4" />
                </span>
              </div>
              <div>
                <p className="text-2xl font-bold tracking-tight text-emerald-700">
                  {summary.activeCount}
                </p>
                <p className="mt-0.5 text-xs text-slate-500">
                  Currently enabled for your organization
                </p>
              </div>
            </Card>

            <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
              <div className="flex items-center justify-between gap-2">
                <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
                  Inactive / Pending
                </span>
                <span className="flex size-8 items-center justify-center rounded-lg bg-amber-100 text-amber-600">
                  <Clock aria-hidden="true" className="size-4" />
                </span>
              </div>
              <div>
                <p className="text-2xl font-bold tracking-tight text-[#0b2340]">
                  {summary.inactiveCount}
                </p>
                <p className="mt-0.5 text-xs text-slate-500">
                  Eligible upon tier or specialty qualification
                </p>
              </div>
            </Card>

            <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
              <div className="flex items-center justify-between gap-2">
                <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
                  Program Catalog
                </span>
                <span className="flex size-8 items-center justify-center rounded-lg bg-violet-100 text-violet-700">
                  <Award aria-hidden="true" className="size-4" />
                </span>
              </div>
              <div>
                <p className="text-2xl font-bold tracking-tight text-[#0b2340]">
                  {summary.catalogBenefits.length || summary.totalCount}
                </p>
                <p className="mt-0.5 text-xs text-slate-500">
                  Master benefits in PRM_PartnerBenefit__c
                </p>
              </div>
            </Card>
          </div>

          {/* Filter Tabs + Benefit Cards Grid */}
          <Card className="gap-3 rounded-xl border border-slate-200/90 bg-white py-4 text-[#0b2340] shadow-xs">
            <div className="flex flex-wrap items-center justify-between gap-3 border-b border-slate-100 px-5 pb-3">
              <div className="flex items-center gap-2.5">
                <span className="inline-block h-4 w-1 rounded-full bg-[#0068b5]" />
                <div>
                  <h2 className="text-sm font-bold text-[#0b2340]">
                    Partner Benefit Entitlements
                  </h2>
                  <p className="text-[11px] text-slate-500">
                    {summary.scope === 'account'
                      ? 'Benefits linked directly to your partner account'
                      : summary.scope === 'org-accessible'
                        ? 'Live benefit records loaded from Salesforce'
                        : 'Sample partner benefit entitlements'}
                  </p>
                </div>
              </div>

              <div className="flex flex-wrap items-center gap-1.5">
                {(
                  [
                    ['all', `All (${summary.totalCount})`],
                    ['active', `Active (${summary.activeCount})`],
                    ['inactive', `Inactive (${summary.inactiveCount})`],
                    ...(summary.catalogBenefits.length > 0
                      ? [
                          [
                            'catalog',
                            `Program Catalog (${summary.catalogBenefits.length})`,
                          ] as const,
                        ]
                      : []),
                  ] as const
                ).map(([key, label]) => (
                  <button
                    key={key}
                    type="button"
                    onClick={() => setFilter(key)}
                    className={`rounded-full px-3 py-1 text-xs font-semibold transition-colors ${
                      filter === key
                        ? 'bg-[#0068b5] text-white'
                        : 'bg-slate-100 text-slate-600 hover:bg-slate-200/70'
                    }`}
                  >
                    {label}
                  </button>
                ))}
              </div>
            </div>

            <CardContent className="px-5 pt-1">
              {displayedItems.length === 0 ? (
                <p className="py-8 text-center text-xs text-slate-500">
                  No benefit records match the selected filter.
                </p>
              ) : (
                <div className="grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-3">
                  {displayedItems.map(item => {
                    const isActive =
                      item.status.toLowerCase() === 'active' ||
                      item.status === 'Catalog';
                    return (
                      <div
                        key={item.id}
                        className="flex flex-col justify-between gap-2.5 rounded-lg border border-slate-200/90 bg-slate-50/50 p-3.5 transition-colors hover:border-sky-200 hover:bg-sky-50/30"
                      >
                        <div>
                          <div className="flex items-start justify-between gap-2">
                            <h3 className="text-xs leading-snug font-bold text-[#0b2340] sm:text-[13px]">
                              {item.name}
                            </h3>
                            <span
                              className={`inline-flex shrink-0 items-center gap-1 rounded-full px-2 py-0.5 text-[10.5px] font-semibold ${
                                isActive
                                  ? 'bg-emerald-100 text-emerald-800'
                                  : 'bg-slate-200 text-slate-700'
                              }`}
                            >
                              {isActive ? (
                                <CheckCircle2
                                  aria-hidden="true"
                                  className="size-3"
                                />
                              ) : (
                                <XCircle
                                  aria-hidden="true"
                                  className="size-3"
                                />
                              )}
                              {item.status}
                            </span>
                          </div>

                          <div className="mt-1.5 flex flex-wrap items-center gap-1.5">
                            {item.code && (
                              <span className="rounded-sm bg-sky-100/80 px-1.5 py-0.5 font-mono text-[10px] font-semibold text-[#0054ae]">
                                {item.code}
                              </span>
                            )}
                            {item.type && (
                              <span className="rounded-sm bg-slate-200/70 px-1.5 py-0.5 text-[10px] font-medium text-slate-700">
                                {item.type}
                              </span>
                            )}
                          </div>

                          {item.description && (
                            <p className="mt-2 text-xs leading-relaxed text-slate-600">
                              {item.description}
                            </p>
                          )}
                        </div>

                        <div className="flex items-center justify-between border-t border-slate-200/70 pt-2 text-[11px] text-slate-500">
                          <span className="truncate">
                            {item.accountName ?? item.source ?? 'Intel® Partner Alliance'}
                          </span>
                          {item.statusChangedDate && (
                            <span className="shrink-0">
                              {item.statusChangedDate.slice(0, 10)}
                            </span>
                          )}
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </CardContent>
          </Card>
        </>
      )}
    </main>
  );
}
