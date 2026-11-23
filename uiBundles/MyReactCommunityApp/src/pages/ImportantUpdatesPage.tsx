import { Link } from 'react-router';
import { ArrowLeft, Bell } from 'lucide-react';
import { Card, CardContent } from '../components/ui/card';
import { Skeleton } from '../components/ui/skeleton';
import { FeedList, type FeedItem } from '../components/FeedList';
import { useAsyncData } from '../hooks/useAsyncData';
import { useOptionalPartnerAccount } from '../features/partner/context/PartnerAccountContext';
import {
  fetchPartnerMessages,
  isAuthFailureMessage,
} from '../api/partnerPortalData';

const FALLBACK_UPDATES: FeedItem[] = [
  {
    id: 'u1',
    title: 'New Training Courses Available',
    date: '2026-10-10',
    icon: 'campaign',
    tone: 'purple',
    description:
      'Explore the latest Intel product and solution training to grow your expertise.',
  },
  {
    id: 'u2',
    title: 'Points Accrual Benefit Active',
    date: '2026-10-08',
    icon: 'gift',
    tone: 'blue',
    description:
      'Your Points Accrual benefit is active. You can now view your points balance.',
  },
  {
    id: 'u3',
    title: 'Manage Benefits Enhancements',
    date: '2026-10-05',
    icon: 'document',
    tone: 'blue',
    description: 'New features are now available on the Manage Benefits page.',
  },
  {
    id: 'u4',
    title: 'Q4 Partner Rebate Program Open',
    date: '2026-10-02',
    icon: 'coin',
    tone: 'amber',
    description:
      'Submit qualifying server and client system sales to maximize quarterly rebates.',
  },
  {
    id: 'u5',
    title: 'Intel® Xeon® 6 Partner Sales Kit Released',
    date: '2026-09-28',
    icon: 'briefcase',
    tone: 'green',
    description:
      'Download updated battlecards, solution briefs, and customer pitch decks.',
  },
];

export default function ImportantUpdatesPage() {
  const partner = useOptionalPartnerAccount();
  const isAuthFailed = Boolean(
    partner?.isAuthFallback || isAuthFailureMessage(partner?.error)
  );

  const { data: rawItems, loading, error: rawError } = useAsyncData(
    async () => (isAuthFailed ? FALLBACK_UPDATES : fetchPartnerMessages(25)),
    [isAuthFailed]
  );

  const useFallback = Boolean(isAuthFailed || isAuthFailureMessage(rawError));
  const items =
    !useFallback && rawItems && rawItems.length > 0
      ? rawItems
      : FALLBACK_UPDATES;

  return (
    <main className="flex w-full shrink-0 grow flex-col gap-4 px-6 pt-5 pb-16 sm:px-8 lg:px-12 xl:px-16">
      <title>Important Updates | Partner experience</title>

      <section className="flex flex-wrap items-center justify-between gap-4 rounded-xl border border-sky-100 bg-linear-to-r from-[#0b2340] via-[#103158] to-[#174a8b] px-5 py-4 text-white shadow-sm">
        <div className="flex min-w-0 items-center gap-3.5">
          <span className="flex size-11 shrink-0 items-center justify-center rounded-xl bg-sky-400/20 text-sky-300 ring-1 ring-sky-300/30">
            <Bell aria-hidden="true" className="size-5.5" />
          </span>
          <div className="min-w-0">
            <div className="mb-1 flex flex-wrap items-center gap-2">
              <span className="inline-flex items-center gap-1 rounded-full bg-sky-400/20 px-2.5 py-0.5 text-[11px] font-semibold text-sky-200 ring-1 ring-sky-300/30">
                PRM_Message__c
              </span>
            </div>
            <h1 className="text-[clamp(1.25rem,1.6vw,1.65rem)] leading-tight font-bold tracking-tight">
              Important Updates &amp; Announcements
            </h1>
            <p className="mt-0.5 text-xs text-sky-100/85 sm:text-sm">
              Program announcements, portal enhancements, and enablement alerts from Intel&reg; Partner Alliance.
            </p>
          </div>
        </div>
        <Link
          to="/"
          className="inline-flex items-center gap-1.5 rounded-lg border border-white/25 bg-white/10 px-3 py-1.5 text-xs font-semibold text-white transition-colors hover:bg-white/20"
        >
          <ArrowLeft aria-hidden="true" className="size-3.5" />
          Back to Dashboard
        </Link>
      </section>

      {loading ? (
        <Skeleton className="h-72 w-full rounded-xl" />
      ) : (
        <Card className="gap-3 rounded-xl border border-slate-200/90 bg-white py-4 text-[#0b2340] shadow-xs">
          <CardContent className="px-5">
            <FeedList items={items} variant="updates" />
          </CardContent>
        </Card>
      )}
    </main>
  );
}
