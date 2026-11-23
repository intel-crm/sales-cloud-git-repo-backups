import { useEffect, useState } from 'react';
import { useOptionalPartnerAccount } from '../features/partner/context/PartnerAccountContext';
import type { FeedItem } from '../components/FeedList';
import {
  DUMMY_BENEFITS_SUMMARY,
  DUMMY_POINTS_SUMMARY,
  DUMMY_TRAINING_SUMMARY,
  DUMMY_WARRANTY_SUMMARY,
  fetchPartnerBenefitsData,
  fetchPartnerContacts,
  fetchPartnerMessages,
  fetchPartnerPointsData,
  fetchPartnerTrainingSummary,
  fetchPartnerWarrantyData,
  type PartnerBenefitsSummary,
  type PartnerPointsSummary,
  type PartnerTrainingSummary,
  type PartnerWarrantySummary,
} from '../api/partnerPortalData';

export interface LiveHomeCardsData {
  pointsValue: string;
  pointsDescription: string;
  pointsTrend?: string;
  pointsHref: string;
  trainingValue: string;
  trainingDescription: string;
  trainingHref: string;
  warrantyValue: string;
  warrantyDescription: string;
  warrantyHref: string;
  isLiveData: boolean;
}

export interface PartnerPortalOverviewState {
  liveCards: LiveHomeCardsData | null;
  liveUpdates: FeedItem[] | undefined;
  liveActivity: FeedItem[] | undefined;
  points: PartnerPointsSummary | null;
  benefits: PartnerBenefitsSummary | null;
  warranty: PartnerWarrantySummary | null;
  training: PartnerTrainingSummary | null;
  loading: boolean;
}

function formatNumber(n: number): string {
  return new Intl.NumberFormat('en-US').format(Math.round(n));
}

function buildRecentActivityItems(
  points: PartnerPointsSummary,
  benefits: PartnerBenefitsSummary,
  warranty: PartnerWarrantySummary,
  training: PartnerTrainingSummary,
  contactNames: Array<{ name: string; title: string | null; createdDate: string | null }>
): FeedItem[] {
  const items: FeedItem[] = [];

  if (training.completedCourses.length > 0) {
    const firstCourse = training.completedCourses[0];
    items.push({
      id: `act-trn-${firstCourse.id}`,
      title: 'Completed training',
      detail: `${firstCourse.title} — +${firstCourse.credits} credit${firstCourse.credits === 1 ? '' : 's'}`,
      date: firstCourse.completedDate ?? '2026-10-12',
      icon: 'school',
      tone: 'blue',
    });
  }

  if (points.records.length > 0) {
    const topPts = points.records[0];
    items.push({
      id: `act-pts-${topPts.id}`,
      title: 'Points balance synced',
      detail: `${formatNumber(points.totalBalance)} pts available across ${points.records.length} ledger record${points.records.length === 1 ? '' : 's'}`,
      date: topPts.lastUpdated?.slice(0, 10) ?? '2026-10-10',
      icon: 'coin',
      tone: 'amber',
    });
  }

  if (benefits.enrolledBenefits.length > 0) {
    const topBen =
      benefits.enrolledBenefits.find(
        b => b.status.toLowerCase() === 'active'
      ) ?? benefits.enrolledBenefits[0];
    items.push({
      id: `act-ben-${topBen.id}`,
      title: `Benefit ${topBen.status.toLowerCase()}: ${topBen.name}`,
      detail: `${benefits.activeCount} of ${benefits.totalCount} partner program benefits active`,
      date: topBen.statusChangedDate?.slice(0, 10) ?? '2026-10-08',
      icon: 'briefcase',
      tone: 'blue',
    });
  }

  if (warranty.records.length > 0) {
    const topWrt = warranty.records[0];
    items.push({
      id: `act-wrt-${topWrt.id}`,
      title: 'Warranty entitlement verified',
      detail: `AWR remaining: ${formatNumber(warranty.awrRemaining)} · SWR remaining: ${formatNumber(warranty.swrRemaining)}`,
      date: topWrt.asOfDate?.slice(0, 10) ?? '2026-10-06',
      icon: 'shieldCheck',
      tone: 'green',
    });
  }

  if (contactNames.length > 0) {
    const topContact = contactNames[0];
    items.push({
      id: `act-cnt-${topContact.name}`,
      title: 'Partner contact verified',
      detail: `${topContact.name}${topContact.title ? ` (${topContact.title})` : ''} — ${contactNames.length} directory contact${contactNames.length === 1 ? '' : 's'}`,
      date: topContact.createdDate ?? '2026-10-04',
      icon: 'person',
      tone: 'purple',
    });
  }

  return items.slice(0, 5);
}

export function usePartnerPortalOverview(): PartnerPortalOverviewState {
  const partner = useOptionalPartnerAccount();
  const [state, setState] = useState<PartnerPortalOverviewState>({
    liveCards: null,
    liveUpdates: undefined,
    liveActivity: undefined,
    points: null,
    benefits: null,
    warranty: null,
    training: null,
    loading: false,
  });

  const isAuthFallback = Boolean(
    partner?.isAuthFallback ||
      partner?.error?.includes('Authentication failed')
  );
  const readyAccount =
    partner?.account?.kind === 'ready' ? partner.account : null;
  const accountId =
    readyAccount?.opportunityScope === 'all-accessible'
      ? null
      : readyAccount?.accountId ?? null;
  const hasProvider = partner !== null;
  const partnerLoading = Boolean(partner?.loading);

  useEffect(() => {
    // When rendered in isolated unit tests without PartnerAccountProvider, keep static defaults
    if (!hasProvider || partnerLoading) {
      return;
    }

    if (isAuthFallback) {
      setState({
        liveCards: {
          pointsValue: `${formatNumber(DUMMY_POINTS_SUMMARY.totalBalance)} Points`,
          pointsDescription: `${formatNumber(DUMMY_POINTS_SUMMARY.totalDueToExpire)} pts due to expire`,
          pointsTrend: '12%',
          pointsHref: '/points-rewards',
          trainingValue: `${DUMMY_TRAINING_SUMMARY.totalCredits} Credits`,
          trainingDescription: `${DUMMY_TRAINING_SUMMARY.completedCourses.length} completed courses`,
          trainingHref: '/training',
          warrantyValue: DUMMY_WARRANTY_SUMMARY.statusLabel,
          warrantyDescription: `${DUMMY_WARRANTY_SUMMARY.awrRemaining} AWR · ${DUMMY_WARRANTY_SUMMARY.swrRemaining} SWR remaining`,
          warrantyHref: '/warranty',
          isLiveData: false,
        },
        liveUpdates: undefined,
        liveActivity: undefined,
        points: DUMMY_POINTS_SUMMARY,
        benefits: DUMMY_BENEFITS_SUMMARY,
        warranty: DUMMY_WARRANTY_SUMMARY,
        training: DUMMY_TRAINING_SUMMARY,
        loading: false,
      });
      return;
    }

    if (!readyAccount) {
      return;
    }

    let cancelled = false;
    setState(prev => ({ ...prev, loading: true }));

    void Promise.allSettled([
      fetchPartnerPointsData(accountId),
      fetchPartnerBenefitsData(accountId),
      fetchPartnerWarrantyData(accountId),
      fetchPartnerMessages(6),
      fetchPartnerTrainingSummary(),
      fetchPartnerContacts(accountId),
    ]).then(([ptsRes, benRes, wrtRes, msgRes, trnRes, cntRes]) => {
      if (cancelled) return;

      const points =
        ptsRes.status === 'fulfilled' ? ptsRes.value : DUMMY_POINTS_SUMMARY;
      const benefits =
        benRes.status === 'fulfilled' ? benRes.value : DUMMY_BENEFITS_SUMMARY;
      const warranty =
        wrtRes.status === 'fulfilled' ? wrtRes.value : DUMMY_WARRANTY_SUMMARY;
      const messages =
        msgRes.status === 'fulfilled' && msgRes.value.length > 0
          ? msgRes.value
          : undefined;
      const training =
        trnRes.status === 'fulfilled' ? trnRes.value : DUMMY_TRAINING_SUMMARY;
      const contacts =
        cntRes.status === 'fulfilled' ? cntRes.value.contacts : [];

      const anyLive =
        points.scope !== 'sample' ||
        benefits.scope !== 'sample' ||
        warranty.scope !== 'sample' ||
        Boolean(messages);

      const activity = buildRecentActivityItems(
        points,
        benefits,
        warranty,
        training,
        contacts
      );

      setState({
        liveCards: {
          pointsValue: `${formatNumber(points.totalBalance)} Points`,
          pointsDescription:
            points.totalDueToExpire > 0
              ? `${formatNumber(points.totalDueToExpire)} pts due to expire`
              : `${points.records.length} active points ledger records`,
          pointsHref: '/points-rewards',
          trainingValue: `${formatNumber(training.totalCredits)} Credits`,
          trainingDescription: `${benefits.activeCount} active program benefits`,
          trainingHref: '/training',
          warrantyValue: warranty.statusLabel,
          warrantyDescription: `${formatNumber(warranty.awrRemaining)} AWR · ${formatNumber(warranty.swrRemaining)} SWR remaining`,
          warrantyHref: '/warranty',
          isLiveData: anyLive,
        },
        liveUpdates: messages,
        liveActivity: activity.length > 0 ? activity : undefined,
        points,
        benefits,
        warranty,
        training,
        loading: false,
      });
    });

    return () => {
      cancelled = true;
    };
  }, [hasProvider, partnerLoading, isAuthFallback, readyAccount, accountId]);

  return state;
}
