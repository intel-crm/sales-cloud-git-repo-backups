import {
  ArrowRight,
  BarChart3,
  Coins,
  GraduationCap,
  ShieldCheck,
  Star,
} from 'lucide-react';
import { Link } from 'react-router';
import { Card } from './ui/card';
import { usePartnerAccount } from '../features/partner/context/PartnerAccountContext';
import type { LiveHomeCardsData } from '../hooks/usePartnerPortalOverview';

interface HomeDashboardCardsProps {
  pipelineValue: string | null;
  loading: boolean;
  error: string | null;
  liveCards?: LiveHomeCardsData | null;
}

export function HomeDashboardCards({
  pipelineValue,
  loading,
  error,
  liveCards,
}: HomeDashboardCardsProps) {
  const partner = usePartnerAccount();
  const partnerLoading = partner.loading;
  const account = partner.account?.kind === 'ready' ? partner.account : null;
  const partnerValue = partnerLoading
    ? 'Loading...'
    : partner.error
      ? 'Unavailable'
      : account
        ? account.badgeTier || 'Not provided'
        : partner.account?.kind === 'not-applicable'
          ? 'Not applicable'
          : 'Unavailable';
  const partnerDescription = partnerLoading
    ? 'Loading partner account...'
    : partner.error
      ? partner.error
      : account
        ? (account.roles[0] ?? 'No partner roles')
        : 'Sign in to view partner details';
  const fullRoles =
    !partnerLoading && !partner.error && account?.roles.length
      ? account.roles.join('; ')
      : undefined;
  const cards = [
    {
      title: 'Total Rebates (Points)',
      value: liveCards ? liveCards.pointsValue : '35 Points',
      description: liveCards ? liveCards.pointsDescription : 'vs. last quarter',
      trend: liveCards ? liveCards.pointsTrend : '12%',
      icon: Coins,
      color: 'bg-sky-100 text-sky-600',
      action: 'View points',
      href: liveCards?.pointsHref,
    },
    {
      title: 'Partner-Tier',
      value: partnerValue,
      description: partnerDescription,
      descriptionTitle: fullRoles,
      isError: !partnerLoading && !!partner.error,
      icon: Star,
      color: 'bg-amber-100 text-amber-500',
      action: 'View account details',
      href:
        !partnerLoading && !partner.error && account
          ? `/accounts/${encodeURIComponent(account.accountId)}`
          : undefined,
      disabledReason: 'Partner account details are not available.',
    },
    {
      title: 'Training Credits',
      value: liveCards ? liveCards.trainingValue : '2 Credits',
      description: liveCards
        ? liveCards.trainingDescription
        : 'Available training credits',
      icon: GraduationCap,
      color: 'bg-violet-100 text-violet-600',
      action: 'View training',
      href: liveCards?.trainingHref,
    },
    {
      title: 'Warranty',
      value: liveCards ? liveCards.warrantyValue : 'Active',
      description: liveCards
        ? liveCards.warrantyDescription
        : 'Benefit status',
      icon: ShieldCheck,
      color: 'bg-emerald-100 text-emerald-600',
      action: 'View warranty',
      href: liveCards?.warrantyHref,
    },
    {
      title: 'Opportunity Pipeline',
      value: loading ? 'Loading...' : error ? 'Unavailable' : pipelineValue,
      description: error
        ? 'Pipeline value could not be loaded'
        : account?.opportunityScope === 'all-accessible'
          ? 'Across all stages, visible to you'
          : 'For the selected account, across all stages',
      icon: BarChart3,
      color: 'bg-sky-100 text-sky-600',
      action: 'View opportunities',
      href: '/opportunities',
    },
  ];

  return (
    <section aria-label="Partner overview" className="w-full">
      {!liveCards?.isLiveData && (
        <p className="mb-1.5 text-xs text-slate-500">
          Rebates, training and warranty show sample data.
        </p>
      )}
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-5">
        {cards.map(
          ({
            title,
            value,
            description,
            descriptionTitle,
            isError,
            trend,
            icon: Icon,
            color,
            action,
            href,
            disabledReason,
          }) => (
            <Card
              key={title}
              role="region"
              aria-label={title}
              className="min-w-0 justify-between gap-2 rounded-md bg-white px-3.5 py-2.5 text-[#0b2340] shadow-sm"
            >
              <div className="flex flex-1 flex-col items-start gap-2 xl:flex-row">
                <div
                  className={`flex size-8 shrink-0 items-center justify-center rounded-full ${color}`}
                >
                  <Icon aria-hidden="true" className="size-4" />
                </div>
                <div className="min-w-0 flex-1">
                  <h2 className="text-[clamp(0.675rem,0.72vw,0.75rem)] font-semibold uppercase leading-4">
                    {title}
                  </h2>
                  <div className="mt-1 flex flex-wrap items-baseline gap-1">
                    <p
                      className="min-w-0 break-words text-[clamp(1.125rem,1.35vw,1.375rem)] leading-tight font-bold tracking-tight"
                      aria-live={
                        href || title === 'Partner-Tier' || title === 'Prestige'
                          ? 'polite'
                          : undefined
                      }
                    >
                      {value}
                    </p>
                    {trend && (
                      <span className="text-xs font-semibold text-emerald-700">
                        <span aria-hidden="true">&uarr; </span>
                        <span className="sr-only">Up </span>
                        {trend}
                      </span>
                    )}
                  </div>
                  <p
                    className="mt-0.5 break-words text-xs leading-tight text-slate-500"
                    title={descriptionTitle}
                    aria-label={
                      descriptionTitle
                        ? `Partner roles: ${descriptionTitle}`
                        : undefined
                    }
                    tabIndex={descriptionTitle ? 0 : undefined}
                    role={isError ? 'alert' : undefined}
                  >
                    {description}
                  </p>
                  {(title === 'Partner-Tier' || title === 'Prestige') &&
                    account?.fallbackReason && (
                      <p
                        role="status"
                        className="mt-0.5 break-words text-xs leading-tight text-amber-800"
                        title={account.fallbackReason}
                      >
                        Using default account
                      </p>
                    )}
                </div>
              </div>
              {href ? (
                <Link
                  to={href}
                  className="mt-1 flex items-center justify-end gap-1 rounded-sm text-xs font-semibold text-sky-700 hover:underline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-sky-700"
                >
                  {action}
                  <ArrowRight aria-hidden="true" className="size-3 shrink-0" />
                </Link>
              ) : (
                <button
                  type="button"
                  disabled
                  title={disabledReason ?? 'Not available yet - sample data'}
                  className="mt-1 flex items-center justify-end gap-1 text-xs font-semibold text-sky-700 disabled:cursor-not-allowed disabled:opacity-60"
                >
                  {action}
                  <ArrowRight aria-hidden="true" className="size-3 shrink-0" />
                </button>
              )}
            </Card>
          )
        )}
      </div>
    </section>
  );
}
