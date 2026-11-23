import { ArrowRight } from 'lucide-react';
import { Link } from 'react-router';
import sidebarMountainsImg from '../assets/images/sidebar-mountains.jpg';

interface SideNavPromoProps {
  titleLines?: string[];
  subtitle?: string;
  ctaLabel?: string;
  ctaRoute?: string;
  imageUrl?: string;
}

export function SideNavPromo({
  titleLines = ['Together', 'we go further'],
  subtitle = 'Innovate. Collaborate. Grow with Intel.',
  ctaLabel = 'Explore resources',
  ctaRoute = '/resources',
  imageUrl = sidebarMountainsImg,
}: SideNavPromoProps) {
  return (
    <aside
      aria-label="Partner resources promotion"
      style={{
        backgroundImage: `linear-gradient(180deg, rgba(11, 33, 76, 0.15) 0%, rgba(11, 33, 76, 0.8) 45%, #071936 72%), url("${imageUrl}")`,
      }}
      className="mt-auto min-h-0 shrink rounded-lg bg-[#071936] bg-size-[100%_auto] bg-top bg-no-repeat px-3.5 pt-10 pb-3 text-white xl:pt-14"
    >
      <h2 className="mb-1 flex flex-col text-[clamp(0.925rem,1vw,1.15rem)] leading-tight font-semibold">
        {titleLines.map(line => (
          <span key={line}>{line}</span>
        ))}
      </h2>
      <p className="mb-2.5 text-[11px] leading-snug text-slate-200">
        {subtitle}
      </p>
      <Link
        to={ctaRoute}
        className="inline-flex w-full items-center justify-center gap-1.5 rounded-md border border-sky-300/70 bg-transparent px-2.5 py-1.5 text-xs font-medium text-sky-100 transition-colors hover:bg-white/10 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white"
      >
        {ctaLabel} <ArrowRight aria-hidden="true" className="size-3.5" />
      </Link>
    </aside>
  );
}

