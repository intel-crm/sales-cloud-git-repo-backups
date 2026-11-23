import { useId } from 'react';
import { ArrowRight } from 'lucide-react';
import { Link } from 'react-router';
import { Card, CardContent, CardHeader } from './ui/card';
import { FeedList, type FeedItem } from './FeedList';

const DEFAULT_UPDATES: FeedItem[] = [
  {
    id: 'u1',
    title: 'New Training Courses Available',
    date: '2024-10-10',
    icon: 'campaign',
    tone: 'purple',
    description:
      'Explore the latest Intel product and solution training to grow your expertise.',
  },
  {
    id: 'u2',
    title: 'Points Accrual Benefit Active',
    date: '2024-10-08',
    icon: 'gift',
    tone: 'blue',
    description:
      'Your Points Accrual benefit is active. You can now view your points balance.',
  },
  {
    id: 'u3',
    title: 'Manage Benefits Enhancements',
    date: '2024-10-05',
    icon: 'document',
    tone: 'blue',
    description: 'New features are now available on the Manage Benefits page.',
  },
  {
    id: 'u4',
    title: 'Q4 Partner Rebate Program Open',
    date: '2024-10-02',
    icon: 'coin',
    tone: 'amber',
    description:
      'Submit qualifying server and client system sales to maximize quarterly rebates.',
  },
  {
    id: 'u5',
    title: 'Intel® Xeon® 6 Partner Sales Kit Released',
    date: '2024-09-28',
    icon: 'briefcase',
    tone: 'green',
    description:
      'Download updated battlecards, solution briefs, and customer pitch decks.',
  },
];

interface ImportantUpdatesProps {
  items?: FeedItem[];
  limit?: number;
  viewAllRoute?: string;
}

export function ImportantUpdates({
  items = DEFAULT_UPDATES,
  limit = 5,
  viewAllRoute = '/updates',
}: ImportantUpdatesProps) {
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
          Important Updates
        </h2>
        <Link to={viewAllRoute} className={linkClass}>
          View all <ArrowRight aria-hidden="true" className="size-3" />
        </Link>
      </CardHeader>
      <CardContent className="flex min-w-0 flex-1 flex-col px-3.5">
        <FeedList items={visibleItems} variant="updates" />
      </CardContent>
    </Card>
  );
}

