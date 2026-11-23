import { CircleHelp } from 'lucide-react';
import { Link } from 'react-router';

interface HelpButtonProps {
  to?: string;
}

export function HelpButton({ to = '/help' }: HelpButtonProps) {
  return (
    <Link
      to={to}
      aria-label="Help"
      className="inline-flex size-9 shrink-0 items-center justify-center rounded-md text-[#262626] transition-colors hover:bg-black/5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#0068b5]"
    >
      <CircleHelp aria-hidden="true" className="size-5" />
    </Link>
  );
}
