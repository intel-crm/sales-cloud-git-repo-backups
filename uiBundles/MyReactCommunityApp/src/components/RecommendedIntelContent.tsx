import { useId, useState } from 'react';
import { ArrowRight, ChevronLeft, ChevronRight, Info } from 'lucide-react';
import { Link } from 'react-router';
import trainingAiImg from '../assets/images/training-ai.jpg';
import trainingVproImg from '../assets/images/training-vpro.jpg';
import trainingSalesImg from '../assets/images/training-sales.jpg';
import heroPartnersImg from '../assets/images/hero-partners.jpg';

export interface RecommendedIntelContentItem {
  id: string;
  badge: string;
  title: string;
  description: string;
  ctaLabel: string;
  href: string;
  visualType:
    | 'ai-pc'
    | 'campaign-assets'
    | 'financial-insights'
    | 'core-ultra'
    | 'program-guide'
    | 'webinar-ai';
}

const DEFAULT_CONTENT_ITEMS: RecommendedIntelContentItem[] = [
  {
    id: 'rec-1',
    badge: 'SOLUTION BRIEF',
    title: 'AI PCs for the Modern Workplace',
    description:
      'Position AI PCs to drive productivity and business value for your customers.',
    ctaLabel: 'Read now',
    href: '/resources',
    visualType: 'ai-pc',
  },
  {
    id: 'rec-2',
    badge: 'CAMPAIGN ASSETS',
    title: 'Co-Marketing Campaign Toolkit',
    description:
      'Ready-to-use assets to run demand generation campaigns.',
    ctaLabel: 'Explore assets',
    href: '/resources',
    visualType: 'campaign-assets',
  },
  {
    id: 'rec-3',
    badge: 'INDUSTRY INSIGHTS',
    title: 'AI in Financial Services',
    description:
      'Latest trends and use cases for AI PCs and data center solutions.',
    ctaLabel: 'View insights',
    href: '/resources',
    visualType: 'financial-insights',
  },
  {
    id: 'rec-4',
    badge: 'PRODUCT INFO',
    title: 'Intel® Core™ Ultra for Business',
    description: 'Technical resources, datasheets and sales tools.',
    ctaLabel: 'Download resources',
    href: '/resources',
    visualType: 'core-ultra',
  },
  {
    id: 'rec-5',
    badge: 'PARTNER PROGRAM',
    title: 'Partner Alliance Program Guide',
    description:
      'Benefits, requirements and how to progress to Prestige.',
    ctaLabel: 'View guide',
    href: '/benefits',
    visualType: 'program-guide',
  },
  {
    id: 'rec-6',
    badge: 'WEBINAR',
    title: 'Winning with AI: Partner Success Stories',
    description:
      'Hear from partners driving growth with Intel AI solutions.',
    ctaLabel: 'Watch now',
    href: '/training',
    visualType: 'webinar-ai',
  },
];

function CardThumbnailVisual({
  visualType,
}: {
  visualType: RecommendedIntelContentItem['visualType'];
}) {
  switch (visualType) {
    case 'ai-pc':
      return (
        <div className="relative h-full w-full overflow-hidden bg-[#00285a]">
          <img
            src={trainingVproImg}
            alt=""
            aria-hidden="true"
            className="h-full w-full object-cover object-right opacity-85 transition-transform duration-300 group-hover:scale-105"
          />
          <div className="absolute inset-0 bg-linear-to-r from-[#003c7d]/95 via-[#0054ae]/70 to-transparent" />
          <div className="absolute bottom-2 left-2.5 flex items-baseline gap-2 select-none">
            <span className="text-2xl leading-none font-extrabold tracking-tight text-sky-300/95">
              AI
            </span>
            <span className="text-[11px] font-bold tracking-tight text-white/95">
              intel.
            </span>
          </div>
        </div>
      );
    case 'campaign-assets':
      return (
        <div className="relative h-full w-full overflow-hidden bg-slate-200">
          <img
            src={heroPartnersImg}
            alt=""
            aria-hidden="true"
            className="h-full w-full object-cover object-center transition-transform duration-300 group-hover:scale-105"
          />
          <div className="absolute inset-0 bg-linear-to-t from-slate-900/35 via-transparent to-slate-900/15" />
        </div>
      );
    case 'financial-insights':
      return (
        <div className="relative h-full w-full overflow-hidden bg-linear-to-b from-[#1a3a6c] via-[#3b5988] to-[#d98a5c]">
          {/* Dusk skyline illustration matching Industry Insights card */}
          <svg
            viewBox="0 0 240 100"
            aria-hidden="true"
            className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
            preserveAspectRatio="none"
          >
            <defs>
              <linearGradient id="skyGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#0f2952" />
                <stop offset="55%" stopColor="#2c538a" />
                <stop offset="100%" stopColor="#e08b56" />
              </linearGradient>
              <linearGradient id="bldgGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#1e3c68" />
                <stop offset="100%" stopColor="#091931" />
              </linearGradient>
            </defs>
            <rect width="240" height="100" fill="url(#skyGrad)" />
            {/* Glowing digital grid lines */}
            <g stroke="#38bdf8" strokeOpacity="0.28" strokeWidth="0.7">
              <line x1="35" y1="0" x2="35" y2="100" />
              <line x1="85" y1="0" x2="85" y2="100" />
              <line x1="130" y1="0" x2="130" y2="100" />
              <line x1="185" y1="0" x2="185" y2="100" />
              <path d="M0 78 Q 60 58, 120 70 T 240 52" fill="none" stroke="#fbbf24" strokeOpacity="0.55" strokeWidth="1.2" />
            </g>
            {/* City skyscrapers */}
            <g fill="url(#bldgGrad)">
              <rect x="8" y="54" width="16" height="46" />
              <rect x="28" y="38" width="18" height="62" />
              <rect x="50" y="48" width="14" height="52" />
              <rect x="68" y="30" width="20" height="70" />
              <polygon points="102,14 112,32 112,100 92,100 92,32" />
              <rect x="116" y="42" width="18" height="58" />
              <rect x="138" y="24" width="22" height="76" />
              <rect x="164" y="36" width="17" height="64" />
              <rect x="185" y="46" width="20" height="54" />
              <rect x="209" y="34" width="22" height="66" />
            </g>
            {/* Warm city lights */}
            <g fill="#fde68a" fillOpacity="0.75">
              <rect x="72" y="36" width="3" height="2" />
              <rect x="78" y="42" width="3" height="2" />
              <rect x="98" y="38" width="4" height="2" />
              <rect x="143" y="32" width="4" height="2" />
              <rect x="150" y="40" width="4" height="2" />
              <rect x="143" y="48" width="4" height="2" />
              <rect x="214" y="42" width="4" height="2" />
            </g>
          </svg>
        </div>
      );
    case 'core-ultra':
      return (
        <div className="relative h-full w-full overflow-hidden bg-[#041633]">
          <img
            src={trainingAiImg}
            alt=""
            aria-hidden="true"
            className="h-full w-full object-cover opacity-55 transition-transform duration-300 group-hover:scale-105"
          />
          <div className="absolute inset-0 bg-linear-to-r from-[#03122b]/90 via-[#062356]/75 to-[#0054ae]/60" />
          {/* Intel Core Ultra badge graphic */}
          <div className="absolute right-2.5 bottom-1.5 flex flex-col items-start rounded-sm border border-sky-400/50 bg-linear-to-br from-[#08244f] to-[#021029] px-2.5 py-1 shadow-md select-none">
            <span className="text-[10px] leading-tight font-bold tracking-tight text-white">
              intel
            </span>
            <span className="text-[12px] leading-none font-extrabold tracking-wide text-white">
              CORE
            </span>
            <span className="mt-0.5 text-[7px] leading-none font-bold tracking-widest text-sky-300 uppercase">
              ULTRA
            </span>
          </div>
        </div>
      );
    case 'program-guide':
      return (
        <div className="relative h-full w-full overflow-hidden bg-slate-200">
          <img
            src={trainingSalesImg}
            alt=""
            aria-hidden="true"
            className="h-full w-full object-cover object-center transition-transform duration-300 group-hover:scale-105"
          />
          <div className="absolute inset-0 bg-linear-to-t from-slate-900/30 via-transparent to-slate-900/15" />
        </div>
      );
    case 'webinar-ai':
      return (
        <div className="relative h-full w-full overflow-hidden bg-[#041e42]">
          <img
            src={trainingAiImg}
            alt=""
            aria-hidden="true"
            className="h-full w-full object-cover object-center transition-transform duration-300 group-hover:scale-105"
          />
          <div className="absolute inset-0 bg-linear-to-t from-[#031530]/80 via-[#00448c]/35 to-transparent" />
          <div className="absolute inset-0 flex items-center justify-center select-none">
            <div className="rounded-sm border border-sky-300/40 bg-[#003c7d]/80 px-2.5 py-1 text-center backdrop-blur-[1px]">
              <span className="block text-[12px] leading-none font-bold tracking-tight text-white">
                intel.
              </span>
              <span className="mt-0.5 block text-[7px] font-semibold tracking-widest text-sky-200 uppercase">
                AI Solutions
              </span>
            </div>
          </div>
        </div>
      );
  }
}

interface RecommendedIntelContentProps {
  userName?: string;
  items?: RecommendedIntelContentItem[];
  viewAllRoute?: string;
}

export function RecommendedIntelContent({
  userName,
  items = DEFAULT_CONTENT_ITEMS,
  viewAllRoute = '/resources',
}: RecommendedIntelContentProps) {
  const id = useId();
  const [offset, setOffset] = useState(0);

  const visibleItems =
    offset === 0
      ? items
      : [...items.slice(offset), ...items.slice(0, offset)];

  const handlePrev = () => {
    setOffset(prev => (prev - 1 + items.length) % items.length);
  };

  const handleNext = () => {
    setOffset(prev => (prev + 1) % items.length);
  };

  return (
    <section
      role="region"
      aria-labelledby={`${id}-heading`}
      className="relative flex min-w-0 flex-col gap-3 rounded-xl border border-sky-200/90 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs sm:px-5"
    >
      {/* Header Row */}
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div className="flex items-start gap-2.5">
          {/* Blue Partner Content Badge Icon */}
          <span
            aria-hidden="true"
            className="mt-0.5 inline-flex size-6 shrink-0 items-center justify-center text-[#0068b5]"
          >
            <svg
              viewBox="0 0 24 24"
              fill="none"
              className="size-5.5"
              stroke="currentColor"
              strokeWidth="1.9"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <path d="M12 3L4.5 6.5v5.2c0 5 3.2 8.7 7.5 10.3 4.3-1.6 7.5-5.3 7.5-10.3V6.5L12 3z" />
              <path d="M9.5 13.5c0-1.4 1.1-2.5 2.5-2.5s2.5 1.1 2.5 2.5" />
              <circle cx="12" cy="8.5" r="1.25" fill="currentColor" stroke="none" />
              <circle cx="18.5" cy="5" r="2" fill="#0068b5" stroke="white" strokeWidth="1.2" />
            </svg>
          </span>
          <div>
            <div className="flex flex-wrap items-center gap-2">
              <h2
                id={`${id}-heading`}
                className="text-[15px] font-bold tracking-tight text-[#0b2340] sm:text-base"
              >
                Recommended Intel.com Partner Content
              </h2>
              <span className="inline-flex items-center rounded-full border border-slate-300 bg-slate-50 px-2 py-0.5 text-[10px] leading-none font-bold tracking-wider text-slate-600 uppercase">
                BETA
              </span>
            </div>
            <p className="mt-0.5 text-xs text-slate-500">
              Based on your profile, industry focus, recent activity and the
              latest Intel.com content
            </p>
          </div>
        </div>

        {/* Right / Center-Right: Personalized for {userName} (hidden when auth fails) + View all content */}
        <div className="flex flex-wrap items-center gap-4 sm:gap-6">
          {userName && (
            <div className="flex items-center gap-1.5 text-xs text-slate-500">
              <span>
                Personalized for{' '}
                <strong className="font-bold text-[#0068b5]">{userName}</strong>
              </span>
              <span
                title="Recommendations are tailored to your user profile and partner activity"
                className="inline-flex items-center text-slate-400"
              >
                <Info aria-hidden="true" className="size-3.5" />
              </span>
            </div>
          )}
          <Link
            to={viewAllRoute}
            className="inline-flex shrink-0 items-center gap-1 rounded-sm text-xs font-semibold text-[#0068b5] hover:underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-sky-700"
          >
            View all content <ArrowRight aria-hidden="true" className="size-3" />
          </Link>
        </div>
      </div>

      {/* Cards Row with Left / Right Carousel Controls */}
      <div className="relative flex items-center">
        <button
          type="button"
          onClick={handlePrev}
          aria-label="Previous recommended content"
          className="absolute -left-2.5 z-10 hidden size-7 items-center justify-center rounded-full border border-slate-200 bg-white text-slate-600 shadow-xs transition-colors hover:bg-slate-50 hover:text-[#0068b5] focus-visible:outline-2 focus-visible:outline-sky-700 sm:inline-flex"
        >
          <ChevronLeft aria-hidden="true" className="size-4" />
        </button>

        <ul className="m-0 grid w-full list-none grid-cols-1 gap-3 p-0 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-6">
          {visibleItems.map(item => (
            <li
              key={item.id}
              className="group flex min-w-0 flex-col overflow-hidden rounded-lg border border-slate-200/90 bg-white transition-shadow hover:shadow-md"
            >
              {/* Thumbnail Banner + Category Pill */}
              <div className="relative h-22 w-full shrink-0 overflow-hidden">
                <CardThumbnailVisual visualType={item.visualType} />
                <span className="absolute top-2 left-2 rounded-xs bg-[#004a86]/90 px-1.5 py-0.5 text-[9px] leading-tight font-bold tracking-wider text-white uppercase shadow-2xs backdrop-blur-[1px]">
                  {item.badge}
                </span>
              </div>

              {/* Card Body */}
              <div className="flex flex-1 flex-col justify-between gap-2 p-3">
                <div>
                  <h3 className="text-xs leading-snug font-bold text-[#0b2340]">
                    {item.title}
                  </h3>
                  <p className="mt-1 text-[11px] leading-relaxed text-slate-600">
                    {item.description}
                  </p>
                </div>
                <Link
                  to={item.href}
                  className="inline-flex items-center gap-1 text-[11px] font-semibold text-[#0068b5] hover:underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-sky-700"
                >
                  {item.ctaLabel}{' '}
                  <ArrowRight aria-hidden="true" className="size-3" />
                </Link>
              </div>
            </li>
          ))}
        </ul>

        <button
          type="button"
          onClick={handleNext}
          aria-label="Next recommended content"
          className="absolute -right-2.5 z-10 hidden size-7 items-center justify-center rounded-full border border-slate-200 bg-white text-slate-600 shadow-xs transition-colors hover:bg-slate-50 hover:text-[#0068b5] focus-visible:outline-2 focus-visible:outline-sky-700 sm:inline-flex"
        >
          <ChevronRight aria-hidden="true" className="size-4" />
        </button>
      </div>
    </section>
  );
}
