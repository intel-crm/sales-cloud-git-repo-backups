import { BarChart3, Coins, GraduationCap, Settings } from 'lucide-react';
import { Link } from 'react-router';
import { OpportunityStageChart } from '../components/OpportunityStageChart';
import { ImportantUpdates } from '../components/ImportantUpdates';
import { RecentActivity } from '../components/RecentActivity';
import { RecommendedTrainings } from '../components/RecommendedTrainings';
import { RecommendedIntelContent } from '../components/RecommendedIntelContent';
import { InviteColleague } from '../components/InviteColleague';
import { QuickLinks } from '../components/QuickLinks';
import { useAuth } from '../features/authentication/context/AuthContext';
import { usePartnerPortalOverview } from '../hooks/usePartnerPortalOverview';
import heroPartnersImg from '../assets/images/hero-partners.jpg';

export default function HomePage() {
  const { user, isAuthenticated, loading, error } = useAuth();
  const { liveCards, liveUpdates, liveActivity } = usePartnerPortalOverview();
  const name =
    !loading && !error && isAuthenticated ? user?.name.trim() : undefined;
  const highlights = [
    { icon: Settings, label: 'Manage benefits', to: '/benefits' },
    { icon: Coins, label: 'Track points', to: '/points-rewards' },
    { icon: GraduationCap, label: 'Grow with training', to: '/training' },
    { icon: BarChart3, label: 'Explore opportunities', to: '/opportunities' },
  ];

  return (
    <main className="flex w-full shrink-0 grow flex-col justify-between gap-3.5 px-6 pt-5 pb-16 sm:px-8 lg:px-12 xl:px-16">
      <title>Dashboard | Partner experience</title>
      <section
        aria-labelledby="home-welcome-title"
        className="flex min-w-0 flex-col gap-4 rounded-lg border border-sky-100 bg-linear-to-r from-sky-100 via-sky-50 to-blue-100 px-5 py-3.5 text-[#0b2340] xl:flex-row xl:items-center xl:justify-between"
      >
        <div className="min-w-0 flex-1">
          <h1
            id="home-welcome-title"
            className="break-words text-[clamp(1.25rem,1.6vw,1.875rem)] font-bold leading-tight"
            aria-live="polite"
          >
            {name ? `Welcome back, ${name}!` : 'Welcome to Partner Experience!'}
          </h1>
          <p className="mt-1 text-[clamp(0.75rem,0.9vw,0.95rem)]">
            Your partner journey, all in one place.
          </p>
          {loading && (
            <p role="status" className="mt-1 text-xs">
              Loading your profile...
            </p>
          )}
          {error && (
            <p role="alert" className="mt-1 text-xs text-red-800">
              {error}. Your personalized greeting is unavailable.
            </p>
          )}
          <ul
            aria-label="Partner benefits"
            className="mt-3 grid grid-cols-2 gap-3 sm:grid-cols-4"
          >
            {highlights.map(({ icon: Icon, label, to }) => (
              <li key={label} className="min-w-0">
                <Link
                  to={to}
                  className="flex min-w-0 items-center gap-2 rounded-md text-[clamp(0.75rem,0.82vw,0.875rem)] font-medium transition-opacity hover:opacity-80 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-sky-700"
                >
                  <span className="flex size-8 shrink-0 items-center justify-center rounded-full bg-sky-200/60 text-sky-700">
                    <Icon aria-hidden="true" className="size-4" />
                  </span>
                  {label}
                </Link>
              </li>
            ))}
          </ul>
        </div>
        <div
          style={{ backgroundImage: `url("${heroPartnersImg}")` }}
          aria-hidden="true"
          className="hidden aspect-[2/1] w-[clamp(11rem,15vw,18rem)] shrink-0 rounded-lg bg-cover bg-center shadow-sm lg:block"
        />
        <p className="shrink-0 border-t border-sky-200 pt-2 text-[clamp(0.875rem,1.05vw,1.15rem)] leading-snug font-semibold xl:border-t-0 xl:border-l xl:pl-5 xl:pt-0">
          Stronger Partners.
          <br />
          Brighter Possibilities.
        </p>
      </section>
      <OpportunityStageChart
        showPartnerCards
        liveCards={liveCards}
        betweenCardsAndChart={
          <>
            <div className="grid shrink-0 grow grid-cols-1 items-stretch gap-3 lg:grid-cols-[1fr_0.95fr_1.05fr]">
              <ImportantUpdates items={liveUpdates} />
              <RecentActivity items={liveActivity} />
              <RecommendedTrainings />
            </div>
            <RecommendedIntelContent userName={name} />
          </>
        }
        besideChart={
          <>
            <InviteColleague />
            <QuickLinks />
          </>
        }
      />
    </main>
  );
}
