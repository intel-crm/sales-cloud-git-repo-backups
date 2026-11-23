import { Link } from 'react-router';
import {
  ArrowRight,
  Award,
  Building2,
  Mail,
  Phone,
  ShieldCheck,
  Users,
} from 'lucide-react';
import { Card, CardContent } from '../components/ui/card';
import { Skeleton } from '../components/ui/skeleton';
import { useAsyncData } from '../hooks/useAsyncData';
import { useOptionalPartnerAccount } from '../features/partner/context/PartnerAccountContext';
import {
  DUMMY_CONTACTS,
  fetchPartnerContacts,
  isAuthFailureMessage,
} from '../api/partnerPortalData';

export default function AccountManagementPage() {
  const partner = useOptionalPartnerAccount();
  const isAuthFailed = Boolean(
    partner?.isAuthFallback || isAuthFailureMessage(partner?.error)
  );
  const readyAccount =
    partner?.account?.kind === 'ready' ? partner.account : null;
  const accountId =
    readyAccount?.accountId ?? '0018A00000UdIm5QAF';
  const queryAccountId =
    readyAccount?.opportunityScope === 'all-accessible'
      ? null
      : readyAccount?.accountId ?? null;

  const { data: rawData, loading, error: rawError } = useAsyncData(
    async () =>
      isAuthFailed
        ? { contacts: DUMMY_CONTACTS, scope: 'sample' as const }
        : fetchPartnerContacts(queryAccountId),
    [queryAccountId, isAuthFailed]
  );

  const useFallback = Boolean(isAuthFailed || isAuthFailureMessage(rawError));
  const result = useFallback
    ? { contacts: DUMMY_CONTACTS, scope: 'sample' as const }
    : (rawData ?? { contacts: DUMMY_CONTACTS, scope: 'sample' as const });

  return (
    <main className="flex w-full shrink-0 grow flex-col gap-4 px-6 pt-5 pb-16 sm:px-8 lg:px-12 xl:px-16">
      <title>Account Management | Partner experience</title>

      {/* Hero Header */}
      <section className="flex flex-wrap items-center justify-between gap-4 rounded-xl border border-sky-100 bg-linear-to-r from-[#0b2340] via-[#103158] to-[#174a8b] px-5 py-4 text-white shadow-sm">
        <div className="flex min-w-0 items-center gap-3.5">
          <span className="flex size-11 shrink-0 items-center justify-center rounded-xl bg-sky-400/20 text-sky-300 ring-1 ring-sky-300/30">
            <Users aria-hidden="true" className="size-5.5" />
          </span>
          <div className="min-w-0">
            <div className="mb-1 flex flex-wrap items-center gap-2">
              <span className="inline-flex items-center gap-1 rounded-full bg-sky-400/20 px-2.5 py-0.5 text-[11px] font-semibold text-sky-200 ring-1 ring-sky-300/30">
                Account &amp; Contact Directory
              </span>
              {readyAccount?.badgeTier && (
                <span className="rounded-md bg-white/10 px-2 py-0.5 text-[11px] font-semibold text-amber-200">
                  {readyAccount.badgeTier}
                </span>
              )}
            </div>
            <h1 className="text-[clamp(1.25rem,1.6vw,1.65rem)] leading-tight font-bold tracking-tight">
              Account Management
            </h1>
            <p className="mt-0.5 text-xs text-sky-100/85 sm:text-sm">
              Manage your Intel&reg; Partner Alliance organization profile, tier roles, and authorized partner contacts.
            </p>
          </div>
        </div>
        <Link
          to={`/accounts/${encodeURIComponent(accountId)}`}
          className="inline-flex items-center gap-1.5 rounded-lg bg-[#0068b5] px-3.5 py-1.5 text-xs font-semibold text-white shadow-xs transition-colors hover:bg-[#005494]"
        >
          Open Full Account Profile <ArrowRight aria-hidden="true" className="size-3.5" />
        </Link>
      </section>

      {/* Summary Strip */}
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
        <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
          <div className="flex items-center justify-between gap-2">
            <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
              Partner Tier
            </span>
            <span className="flex size-8 items-center justify-center rounded-lg bg-amber-100 text-amber-600">
              <Award aria-hidden="true" className="size-4" />
            </span>
          </div>
          <div>
            <p className="text-xl font-bold text-[#0b2340]">
              {readyAccount?.badgeTier ?? 'Titanium'}
            </p>
            <p className="mt-0.5 text-xs text-slate-500">
              Active Intel&reg; Partner Alliance tier
            </p>
          </div>
        </Card>

        <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
          <div className="flex items-center justify-between gap-2">
            <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
              Partner Roles
            </span>
            <span className="flex size-8 items-center justify-center rounded-lg bg-sky-100 text-[#0068b5]">
              <ShieldCheck aria-hidden="true" className="size-4" />
            </span>
          </div>
          <div>
            <p className="truncate text-xl font-bold text-[#0b2340]">
              {readyAccount?.roles?.join(', ') || 'Distributor'}
            </p>
            <p className="mt-0.5 text-xs text-slate-500">
              Core_IPA_Partner_Role__c
            </p>
          </div>
        </Card>

        <Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
          <div className="flex items-center justify-between gap-2">
            <span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
              Registered Contacts
            </span>
            <span className="flex size-8 items-center justify-center rounded-lg bg-violet-100 text-violet-700">
              <Building2 aria-hidden="true" className="size-4" />
            </span>
          </div>
          <div>
            <p className="text-xl font-bold text-[#0b2340]">
              {loading ? '...' : result.contacts.length}
            </p>
            <p className="mt-0.5 text-xs text-slate-500">
              Directory contacts loaded from Salesforce Contact
            </p>
          </div>
        </Card>
      </div>

      {/* Contacts Grid */}
      {loading ? (
        <Skeleton className="h-64 w-full rounded-xl" />
      ) : (
        <Card className="gap-3 rounded-xl border border-slate-200/90 bg-white py-4 text-[#0b2340] shadow-xs">
          <div className="flex items-center justify-between gap-2 border-b border-slate-100 px-5 pb-3">
            <div className="flex items-center gap-2.5">
              <span className="inline-block h-4 w-1 rounded-full bg-[#0068b5]" />
              <div>
                <h2 className="text-sm font-bold text-[#0b2340]">
                  Authorized Partner Contacts
                </h2>
                <p className="text-[11px] text-slate-500">
                  {result.scope === 'account'
                    ? 'Contacts linked directly to your partner account'
                    : result.scope === 'org-accessible'
                      ? 'Live partner contacts loaded from Salesforce (Contact)'
                      : 'Sample partner contacts'}
                </p>
              </div>
            </div>
          </div>

          <CardContent className="grid grid-cols-1 gap-3 px-5 pt-1 md:grid-cols-2 xl:grid-cols-3">
            {result.contacts.map(c => (
              <div
                key={c.id}
                className="flex flex-col justify-between gap-2 rounded-lg border border-slate-200/90 bg-slate-50/50 p-3.5 transition-colors hover:border-sky-200 hover:bg-sky-50/30"
              >
                <div>
                  <p className="text-sm font-bold text-[#0b2340]">{c.name}</p>
                  <p className="text-xs font-medium text-[#0068b5]">
                    {c.title ?? 'Partner Team Member'}
                  </p>
                  {c.accountName && (
                    <p className="mt-0.5 text-[11px] text-slate-500">
                      {c.accountName}
                    </p>
                  )}
                </div>

                <div className="mt-1 space-y-1 border-t border-slate-200/70 pt-2 text-xs text-slate-600">
                  {c.email && (
                    <div className="flex items-center gap-1.5 truncate">
                      <Mail aria-hidden="true" className="size-3.5 shrink-0 text-slate-400" />
                      <a
                        href={`mailto:${c.email}`}
                        className="truncate text-[#0068b5] hover:underline"
                      >
                        {c.email}
                      </a>
                    </div>
                  )}
                  {c.phone && (
                    <div className="flex items-center gap-1.5">
                      <Phone aria-hidden="true" className="size-3.5 shrink-0 text-slate-400" />
                      <span>{c.phone}</span>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </CardContent>
        </Card>
      )}
    </main>
  );
}
