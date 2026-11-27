import { BarChart3, Coins, GraduationCap, Settings } from 'lucide-react';
import { OpportunityStageChart } from '../components/OpportunityStageChart';
import { useAuth } from '../features/authentication/context/AuthContext';

export default function HomePage() {
  const { user, isAuthenticated, loading, error } = useAuth();
  const name =
    !loading && !error && isAuthenticated ? user?.name.trim() : undefined;
  const highlights = [
    { icon: Settings, label: 'Manage benefits' },
    { icon: Coins, label: 'Track points' },
    { icon: GraduationCap, label: 'Grow with training' },
    { icon: BarChart3, label: 'Explore opportunities' },
  ];

  return (
    <main className="max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <title>Home | MyApp</title>
      <section
        aria-labelledby="home-welcome-title"
        className="mb-6 flex min-w-0 flex-col gap-6 rounded-lg border border-sky-100 bg-linear-to-r from-sky-100 via-sky-50 to-blue-100 p-5 text-[#0b2340] sm:p-6 xl:flex-row xl:items-center xl:justify-between"
      >
        <div className="min-w-0 flex-1">
          <h1
            id="home-welcome-title"
            className="break-words text-2xl font-bold sm:text-3xl"
            aria-live="polite"
          >
            {name ? `Welcome back, ${name}!` : 'Welcome to Partner Experience!'}
          </h1>
          <p className="mt-2 text-sm sm:text-base">
            Your partner journey, all in one place.
          </p>
          {loading && (
            <p role="status" className="mt-2 text-sm">
              Loading your profile...
            </p>
          )}
          {error && (
            <p role="alert" className="mt-2 text-sm text-red-800">
              {error}. Your personalized greeting is unavailable.
            </p>
          )}
          <ul
            aria-label="Partner benefits"
            className="mt-5 grid grid-cols-2 gap-4 sm:grid-cols-4"
          >
            {highlights.map(({ icon: Icon, label }) => (
              <li
                key={label}
                className="flex min-w-0 items-center gap-2 text-xs font-medium"
              >
                <span className="flex size-9 shrink-0 items-center justify-center rounded-full bg-sky-200/60 text-sky-700">
                  <Icon aria-hidden="true" className="size-5" />
                </span>
                {label}
              </li>
            ))}
          </ul>
        </div>
        <p className="shrink-0 border-t border-sky-200 pt-4 text-lg font-semibold xl:max-w-44 xl:border-t-0 xl:border-l xl:pl-6 xl:pt-0">
          Stronger Partners.
          <br />
          Brighter Possibilities.
        </p>
      </section>
      <OpportunityStageChart showPartnerCards />
    </main>
  );
}
