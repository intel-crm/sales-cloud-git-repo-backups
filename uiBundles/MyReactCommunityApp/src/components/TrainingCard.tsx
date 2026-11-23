import { ArrowRight, BarChart2, Clock } from 'lucide-react';
import { Link } from 'react-router';

export interface TrainingItem {
  id: string;
  title: string;
  description: string;
  durationMinutes: number;
  level: string;
  imageUrl: string;
  route: string;
}

interface TrainingCardProps {
  training: TrainingItem;
}

export function TrainingCard({ training }: TrainingCardProps) {
  return (
    <li className="grid grid-cols-[clamp(4rem,5vw,5.25rem)_1fr_auto] items-center gap-2.5">
      <img
        src={training.imageUrl}
        alt=""
        loading="lazy"
        className="aspect-[3/2] w-full rounded-md bg-sky-50 object-cover"
      />
      <div className="flex min-w-0 flex-col">
        <span className="text-xs leading-tight font-semibold text-[#0b2340]">
          {training.title}
        </span>
        <span className="text-[11px] leading-tight text-slate-500">
          {training.description}
        </span>
        <span className="mt-0.5 flex items-center gap-1.5 text-[10.5px] text-slate-500">
          <span className="inline-flex items-center gap-1">
            <Clock aria-hidden="true" className="size-3" />
            {training.durationMinutes} min
          </span>
          <span aria-hidden="true" className="opacity-50">
            |
          </span>
          <span className="inline-flex items-center gap-1">
            <BarChart2 aria-hidden="true" className="size-3" />
            {training.level}
          </span>
        </span>
      </div>
      <Link
        to={training.route}
        aria-label={`Start ${training.title}`}
        className="inline-flex shrink-0 items-center gap-1 rounded-md bg-sky-50 px-2 py-1 text-xs font-semibold text-sky-700 transition-colors hover:bg-sky-100 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-sky-700"
      >
        Start <ArrowRight aria-hidden="true" className="size-3" />
      </Link>
    </li>
  );
}

