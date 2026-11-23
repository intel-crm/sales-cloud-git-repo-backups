import { BriefcaseBusiness } from 'lucide-react';
import { NativeOpportunityList } from '../components/OpportunityList';
import { OpportunityStageChart } from '../components/OpportunityStageChart';

export default function OpportunitiesPage() {
  return (
    <main className="flex w-full shrink-0 grow flex-col gap-4 px-6 pt-5 pb-16 sm:px-8 lg:px-12 xl:px-16">
      <title>Opportunities | MyApp</title>
      <div className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-sky-100 bg-linear-to-r from-[#0b2340] via-[#103158] to-[#174a8b] px-5 py-4 text-white shadow-sm">
        <div className="flex items-center gap-3.5">
          <span className="flex size-10 shrink-0 items-center justify-center rounded-lg bg-sky-400/20 text-sky-300 ring-1 ring-sky-300/30">
            <BriefcaseBusiness aria-hidden="true" className="size-5" />
          </span>
          <div>
            <h1 className="text-[clamp(1.25rem,1.6vw,1.65rem)] leading-tight font-bold tracking-tight">
              Opportunities
            </h1>
            <p className="mt-0.5 text-xs text-sky-100/85 sm:text-sm">
              Track deal progression, stage velocity, and partner account
              pipeline across all stages.
            </p>
          </div>
        </div>
      </div>
      <OpportunityStageChart />
      <NativeOpportunityList />
    </main>
  );
}
