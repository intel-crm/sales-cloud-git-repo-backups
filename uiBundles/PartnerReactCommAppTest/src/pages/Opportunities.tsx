import { NativeOpportunityList } from '../components/OpportunityList';
import { OpportunityStageChart } from '../components/OpportunityStageChart';

export default function OpportunitiesPage() {
  return (
    <main className="max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <title>Opportunities | MyApp</title>
      <h1 className="text-2xl font-bold mb-6">Opportunities</h1>
      <OpportunityStageChart />
      <NativeOpportunityList />
    </main>
  );
}
