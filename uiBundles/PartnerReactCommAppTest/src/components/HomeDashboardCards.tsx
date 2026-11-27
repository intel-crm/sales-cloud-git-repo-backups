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

interface HomeDashboardCardsProps {
  pipelineValue: string | null;
  loading: boolean;
  error: string | null;
}

export function HomeDashboardCards({
  pipelineValue,
  loading,
  error,
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
      value: '35 Points',
      description: 'vs. last quarter',
      trend: '12%',
      icon: Coins,
      color: 'bg-sky-100 text-sky-600',
      action: 'View points',
    },
    {
      title: 'Partner Tier',
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
      value: '2 Credits',
      description: 'Available training credits',
      icon: GraduationCap,
      color: 'bg-violet-100 text-violet-600',
      action: 'View training',
    },
    {
      title: 'Warranty',
      value: 'Active',
      description: 'Benefit status',
      icon: ShieldCheck,
      color: 'bg-emerald-100 text-emerald-600',
      action: 'View warranty',
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
    <section aria-label="Partner overview" className="mb-8">
      <p className="mb-3 text-xs text-slate-500">
        Rebates, training and warranty show sample data.
      </p>
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
              className="min-w-0 gap-3 rounded-md bg-white p-3 text-[#0b2340] shadow-sm"
            >
              <div className="flex flex-1 flex-col items-start gap-2 xl:flex-row">
                <div
                  className={`flex size-8 shrink-0 items-center justify-center rounded-full ${color}`}
                >
                  <Icon aria-hidden="true" className="size-5" />
                </div>
                <div className="min-w-0 max-w-full">
                  <h2 className="text-[11px] font-semibold uppercase leading-4">
                    {title}
                  </h2>
                  <div className="mt-2 flex flex-wrap items-baseline gap-1">
                    <p
                      className="min-w-0 break-words text-xl font-bold tracking-tight"
                      aria-live={
                        href || title === 'Partner Tier' ? 'polite' : undefined
                      }
                    >
                      {value}
                    </p>
                    {trend && (
                      <span className="text-[11px] font-semibold text-emerald-700">
                        <span aria-hidden="true">&uarr; </span>
                        <span className="sr-only">Up </span>
                        {trend}
                      </span>
                    )}
                  </div>
                  <p
                    className="mt-1 break-words text-[11px] text-slate-500"
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
                  {title === 'Partner Tier' && account?.fallbackReason && (
                    <p
                      role="status"
                      className="mt-1 break-words text-[11px] text-amber-800"
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
                  className="mt-1 flex items-center justify-end gap-1 rounded-sm text-[11px] font-semibold text-sky-700 hover:underline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-sky-700"
                >
                  {action}
                  <ArrowRight aria-hidden="true" className="size-3 shrink-0" />
                </Link>
              ) : (
                <button
                  type="button"
                  disabled
                  title={disabledReason ?? 'Not available yet - sample data'}
                  className="mt-1 flex items-center justify-end gap-1 text-[11px] font-semibold text-sky-700 disabled:cursor-not-allowed disabled:opacity-60"
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
