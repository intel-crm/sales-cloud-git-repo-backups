import { useId } from 'react';
import {
  BarChart3,
  Coins,
  FileText,
  GraduationCap,
  Settings,
  Shield,
  type LucideIcon,
} from 'lucide-react';
import { Link } from 'react-router';
import { Card, CardContent, CardHeader } from './ui/card';

export interface QuickLinkItem {
  id: string;
  label: string;
  route: string;
  icon: LucideIcon;
}

const DEFAULT_QUICK_LINKS: QuickLinkItem[] = [
  {
    id: 'ql-benefits',
    label: 'Manage Benefits',
    icon: Settings,
    route: '/benefits',
  },
  {
    id: 'ql-points',
    label: 'Points',
    icon: Coins,
    route: '/points-rewards',
  },
  {
    id: 'ql-warranty',
    label: 'Warranty',
    icon: Shield,
    route: '/warranty',
  },
  {
    id: 'ql-training',
    label: 'Training',
    icon: GraduationCap,
    route: '/training',
  },
  {
    id: 'ql-opps',
    label: 'Opportunities',
    icon: BarChart3,
    route: '/opportunities',
  },
  {
    id: 'ql-resources',
    label: 'Resources',
    icon: FileText,
    route: '/resources',
  },
];

interface QuickLinksProps {
  items?: QuickLinkItem[];
}

export function QuickLinks({ items = DEFAULT_QUICK_LINKS }: QuickLinksProps) {
  const id = useId();

  return (
    <Card
      role="region"
      aria-labelledby={`${id}-heading`}
      className="flex min-w-0 flex-1 flex-col gap-2 rounded-xl border border-slate-200/90 bg-white py-3 text-[#0b2340] shadow-xs"
    >
      <CardHeader className="flex items-center justify-between gap-2 px-4">
        <h2 id={`${id}-heading`} className="text-sm font-bold">
          Quick Links
        </h2>
      </CardHeader>
      <CardContent className="flex min-w-0 flex-1 flex-col justify-center px-4">
        <ul className="m-0 grid list-none grid-cols-3 gap-2 p-0">
          {items.map(({ id: itemId, label, route, icon: Icon }) => (
            <li key={itemId} className="flex">
              <Link
                to={route}
                className="flex w-full flex-col items-center justify-center gap-1 rounded-lg border border-slate-100 bg-slate-50/50 px-2 py-2 text-center text-[11px] font-medium leading-tight text-[#0b2340] transition-colors hover:border-sky-200 hover:bg-sky-50/70 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-sky-700"
              >
                <span className="inline-flex h-7 w-8 shrink-0 items-center justify-center rounded-lg bg-sky-100 text-sky-600">
                  <Icon aria-hidden="true" className="size-3.5" />
                </span>
                <span>{label}</span>
              </Link>
            </li>
          ))}
        </ul>
      </CardContent>
    </Card>
  );
}

