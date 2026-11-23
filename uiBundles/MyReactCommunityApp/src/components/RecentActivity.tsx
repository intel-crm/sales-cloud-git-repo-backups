import { useId } from 'react';
import { ArrowRight } from 'lucide-react';
import { Link } from 'react-router';
import { Card, CardContent, CardHeader } from './ui/card';
import { FeedList, type FeedItem } from './FeedList';

const DEFAULT_ACTIVITY: FeedItem[] = [
  {
    id: 'a1',
    title: 'Completed training',
    detail: 'Intel® Core™ Platform Overview — +1 training credit earned',
    date: '2024-10-12',
    icon: 'school',
    tone: 'blue',
  },
  {
    id: 'a2',
    title: 'Points updated',
    detail: '+10 points accrued from Q3 partner rebate claim',
    date: '2024-10-10',
    icon: 'coin',
    tone: 'amber',
  },
  {
    id: 'a3',
    title: 'Opportunity created',
    detail: 'Enterprise Workstation Deal registered in pipeline',
    date: '2024-10-08',
    icon: 'briefcase',
    tone: 'blue',
  },
  {
    id: 'a4',
    title: 'Warranty benefit verified',
    detail: 'Advanced Warranty Replacement active for your account',
    date: '2024-10-06',
    icon: 'shieldCheck',
    tone: 'green',
  },
  {
    id: 'a5',
    title: 'Contact updated',
    detail: 'Primary partner administrator contact details verified',
    date: '2024-10-04',
    icon: 'person',
    tone: 'purple',
  },
];

interface RecentActivityProps {
  items?: FeedItem[];
  limit?: number;
  viewAllRoute?: string;
}

export function RecentActivity({
  items = DEFAULT_ACTIVITY,
  limit = 5,
  viewAllRoute = '/activity',
}: RecentActivityProps) {
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
          Recent Activity
        </h2>
        <Link to={viewAllRoute} className={linkClass}>
          View all <ArrowRight aria-hidden="true" className="size-3" />
        </Link>
      </CardHeader>
      <CardContent className="flex min-w-0 flex-1 flex-col px-3.5">
        <FeedList items={visibleItems} variant="activity" />
      </CardContent>
    </Card>
  );
}

