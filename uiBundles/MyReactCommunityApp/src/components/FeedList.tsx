import {
  BriefcaseBusiness,
  Coins,
  FileText,
  Gift,
  GraduationCap,
  Megaphone,
  ShieldCheck,
  User,
  type LucideIcon,
} from 'lucide-react';

export type FeedTone = 'blue' | 'green' | 'amber' | 'purple';

export type FeedIconName =
  | 'campaign'
  | 'gift'
  | 'document'
  | 'school'
  | 'coin'
  | 'briefcase'
  | 'shieldCheck'
  | 'person';

export interface FeedItem {
  id: string;
  title: string;
  description?: string;
  detail?: string;
  date: string;
  icon: FeedIconName;
  tone: FeedTone;
}

const ICON_MAP: Record<FeedIconName, LucideIcon> = {
  campaign: Megaphone,
  gift: Gift,
  document: FileText,
  school: GraduationCap,
  coin: Coins,
  briefcase: BriefcaseBusiness,
  shieldCheck: ShieldCheck,
  person: User,
};

const TONE_CLASSES: Record<FeedTone, string> = {
  blue: 'bg-sky-100 text-sky-600',
  green: 'bg-emerald-100 text-emerald-600',
  amber: 'bg-amber-100 text-amber-600',
  purple: 'bg-violet-100 text-violet-600',
};

const dateFmt = new Intl.DateTimeFormat('en-US', {
  month: 'short',
  day: 'numeric',
  year: 'numeric',
  timeZone: 'UTC',
});

export function formatFeedDate(iso: string): string {
  if (!iso) return '';
  const parsed = new Date(iso);
  return Number.isNaN(parsed.getTime()) ? iso : dateFmt.format(parsed);
}

interface FeedListProps {
  items: FeedItem[];
  variant?: 'updates' | 'activity';
}

export function FeedList({ items, variant = 'updates' }: FeedListProps) {
  const isActivity = variant === 'activity';

  return (
    <ul className="m-0 grid flex-1 list-none divide-y divide-slate-100 p-0">
      {items.map(item => {
        const Icon = ICON_MAP[item.icon] ?? FileText;
        const toneClass = TONE_CLASSES[item.tone] ?? TONE_CLASSES.blue;
        return (
          <li
            key={item.id}
            className="grid grid-cols-[auto_1fr_auto] items-center gap-3 py-2 first:pt-1 last:pb-1"
          >
            <span
              className={`inline-flex size-8 shrink-0 items-center justify-center rounded-full ${toneClass}`}
            >
              <Icon aria-hidden="true" className="size-4" />
            </span>
            <div className="flex min-w-0 flex-col">
              <span
                className={`text-[#0b2340] leading-snug ${
                  isActivity
                    ? 'text-xs font-semibold'
                    : 'text-xs font-bold'
                }`}
              >
                {item.title}
              </span>
              <span className="mt-0.5 line-clamp-2 text-[11px] leading-snug text-slate-500">
                {item.description ?? item.detail}
              </span>
            </div>
            <time
              dateTime={item.date}
              className="whitespace-nowrap rounded-full bg-slate-50 px-2 py-0.5 text-[11px] font-medium text-slate-500"
            >
              {formatFeedDate(item.date)}
            </time>
          </li>
        );
      })}
    </ul>
  );
}

