import { useId } from 'react';
import { ArrowRight } from 'lucide-react';
import { Link } from 'react-router';
import { Card, CardContent, CardHeader } from './ui/card';
import { TrainingCard, type TrainingItem } from './TrainingCard';
import trainingAiImg from '../assets/images/training-ai.jpg';
import trainingVproImg from '../assets/images/training-vpro.jpg';
import trainingSalesImg from '../assets/images/training-sales.jpg';

const DEFAULT_TRAININGS: TrainingItem[] = [
  {
    id: 't1',
    title: 'Intel® AI Solutions Overview',
    description:
      "Learn about Intel's AI portfolio and partner opportunities.",
    durationMinutes: 30,
    level: 'Beginner',
    imageUrl: trainingAiImg,
    route: '/training',
  },
  {
    id: 't2',
    title: 'Intel® vPro® Platform',
    description:
      'Drive business growth with Intel vPro for modern workplaces.',
    durationMinutes: 45,
    level: 'Intermediate',
    imageUrl: trainingVproImg,
    route: '/training',
  },
  {
    id: 't3',
    title: 'Sales Enablement Fundamentals',
    description: 'Build your go-to-market skills with Intel resources.',
    durationMinutes: 25,
    level: 'Beginner',
    imageUrl: trainingSalesImg,
    route: '/training',
  },
];

interface RecommendedTrainingsProps {
  items?: TrainingItem[];
  limit?: number;
  viewAllRoute?: string;
}

export function RecommendedTrainings({
  items = DEFAULT_TRAININGS,
  limit = 3,
  viewAllRoute = '/training',
}: RecommendedTrainingsProps) {
  const id = useId();
  const visibleItems = items.slice(0, limit);
  const linkClass =
    'inline-flex shrink-0 items-center gap-1 rounded-sm text-xs font-semibold text-sky-700 hover:underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-sky-700';

  return (
    <Card
      role="region"
      aria-labelledby={`${id}-heading`}
      className="flex min-w-0 flex-col gap-1.5 rounded-lg bg-white py-2 text-[#0b2340] shadow-sm"
    >
      <CardHeader className="flex items-center justify-between gap-2 px-3.5">
        <h2 id={`${id}-heading`} className="text-sm font-bold">
          Recommended Trainings
        </h2>
        <Link to={viewAllRoute} className={linkClass}>
          View all <ArrowRight aria-hidden="true" className="size-3" />
        </Link>
      </CardHeader>
      <CardContent className="flex min-w-0 flex-1 flex-col px-3.5">
        <ul className="m-0 grid flex-1 list-none gap-1.5 p-0">
          {visibleItems.map(training => (
            <TrainingCard key={training.id} training={training} />
          ))}
        </ul>
      </CardContent>
    </Card>
  );
}

