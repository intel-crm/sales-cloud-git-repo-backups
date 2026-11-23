import { Bell } from 'lucide-react';
import { Link } from 'react-router';

interface NotificationBellProps {
  unreadCount?: number;
  to?: string;
}

export function NotificationBell({
  unreadCount = 3,
  to = '/notifications',
}: NotificationBellProps) {
  const count = Math.max(0, unreadCount);
  const label = `Notifications${count > 0 ? `, ${count} unread` : ''}`;

  return (
    <Link
      to={to}
      aria-label={label}
      className="relative inline-flex size-9 shrink-0 items-center justify-center rounded-md text-[#262626] transition-colors hover:bg-black/5 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#0068b5]"
    >
      <Bell aria-hidden="true" className="size-5" />
      {count > 0 && (
        <span
          aria-hidden="true"
          className="absolute top-1 right-1 inline-flex min-w-4 items-center justify-center rounded-full bg-red-600 px-1 text-[10px] leading-4 font-bold text-white"
        >
          {count > 99 ? '99+' : count}
        </span>
      )}
    </Link>
  );
}
