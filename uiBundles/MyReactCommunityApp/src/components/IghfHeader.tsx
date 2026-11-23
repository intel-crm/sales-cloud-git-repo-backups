import { useEffect, useRef, useState } from "react";
import { Globe, Menu, User, X } from "lucide-react";
import { Link, useInRouterContext } from "react-router";
import { useAuth } from "../features/authentication/context/AuthContext";
import { GlobalSearchBox } from "../features/search";

const LOADER_URL = "https://www.intel.com/ighf/50recode.2/js/headerchooser.js";
const LANGUAGE_CULTURES: Record<string, string> = {
	en: "en_US",
	"en-GB": "en_UK",
	en_GB: "en_UK",
	ja: "ja_JP",
	fr: "fr_FR",
	de: "de_DE",
	ko: "ko_KR",
	es: "es_ES",
	it: "it_IT",
	ru: "ru_RU",
};

interface IghfHeaderProps {
	mobileNavOpen?: boolean;
	onToggleMobileNav?: () => void;
}

interface VendorHeaderOffsets {
	leftOffsetPx: number;
	rightOffsetPx: number;
}

function measureVendorHeaderOffsets(container: HTMLElement): VendorHeaderOffsets {
	container.classList.add("recode50");
	document.documentElement.classList.add("rwd", "headerfooter-menu3");

	let leftOffsetPx = 96;
	let rightOffsetPx = 180;
	const containerRect = container.getBoundingClientRect();
	if (containerRect.width <= 0) {
		return { leftOffsetPx, rightOffsetPx };
	}

	const logoEl = container.querySelector<HTMLElement>(
		".navbar-logo, .navbar-header, a.intel-logo-rebrand",
	);
	if (logoEl) {
		const logoRect = logoEl.getBoundingClientRect();
		if (logoRect.width > 0 && logoRect.width < 200 && logoRect.right > containerRect.left) {
			leftOffsetPx = Math.min(
				150,
				Math.max(84, Math.round(logoRect.right - containerRect.left + 8)),
			);
		}
	}

	const rightUtilityCluster = container.querySelector<HTMLElement>(
		".navbar-right, .nav-right, .utility-nav, ul.navbar-right",
	);
	if (rightUtilityCluster) {
		const rightRect = rightUtilityCluster.getBoundingClientRect();
		if (rightRect.width > 0 && rightRect.width < 360 && containerRect.right > rightRect.left) {
			rightOffsetPx = Math.min(
				320,
				Math.max(140, Math.round(containerRect.right - rightRect.left + 16)),
			);
		}
	}

	return { leftOffsetPx, rightOffsetPx };
}

function PartnerHeaderBar({
	mobileNavOpen = false,
	onToggleMobileNav,
	hasVendorHeader,
	offsets,
}: IghfHeaderProps & {
	hasVendorHeader: boolean;
	offsets: VendorHeaderOffsets;
}) {
	return (
		<nav
			aria-label="Primary"
			style={
				hasVendorHeader
					? {
							zIndex: 20,
							left: `${offsets.leftOffsetPx}px`,
							right: `${offsets.rightOffsetPx}px`,
						}
					: undefined
			}
			className={
				hasVendorHeader
					? "pointer-events-none relative flex min-h-[3.75rem] w-full items-center justify-between gap-2 px-3 py-2 md:absolute md:inset-y-0 md:w-auto md:px-0"
					: "flex min-h-[3.75rem] w-full items-center justify-between gap-2 px-3 py-2 sm:gap-4 sm:px-6"
			}
		>
			<div className="flex min-w-0 flex-1 items-center gap-2.5 sm:gap-5">
				{onToggleMobileNav && (
					<button
						type="button"
						onClick={onToggleMobileNav}
						aria-label={mobileNavOpen ? "Close navigation menu" : "Open navigation menu"}
						aria-expanded={mobileNavOpen}
						aria-controls="app-sidebar"
						className="pointer-events-auto inline-flex shrink-0 items-center justify-center rounded-md p-1.5 text-[#0068b5] transition-colors hover:bg-slate-100 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#0068b5] md:hidden"
					>
						{mobileNavOpen ? (
							<X aria-hidden="true" className="size-5" />
						) : (
							<Menu aria-hidden="true" className="size-5" />
						)}
					</button>
				)}
				<Link
					to="/"
					aria-label="Intel Partner Experience home"
					className="pointer-events-auto flex shrink-0 items-center gap-2 rounded-sm text-[#262626] focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-[#0068b5] sm:gap-4"
				>
					<img
						src="https://www.intel.com/content/dam/logos/intel-header-logo.svg"
						alt="Intel"
						className={hasVendorHeader ? "sr-only" : "h-5 w-auto shrink-0 sm:h-6"}
					/>
					<span aria-hidden="true" className="h-5 w-px bg-slate-300" />
					<span className="whitespace-nowrap text-sm font-normal tracking-tight text-[#262626] sm:text-[clamp(0.95rem,1vw,1.1rem)]">
						Partner Experience
					</span>
				</Link>
				<GlobalSearchBox
					placeholder="Search accounts, contacts, opportunities..."
					hideSubmitButton
					minLengthHint="Enter at least {min} characters, then press Enter to search."
					className="pointer-events-auto min-w-0 flex-1 md:max-w-[50%] text-[#262626] [&_input]:h-9 [&_input]:w-full [&_input]:rounded-md [&_input]:border-slate-300 [&_input]:bg-white [&_input]:text-[#262626] [&_input]:placeholder:text-slate-500"
				/>
			</div>
			{!hasVendorHeader && (
				<div className="ml-auto flex shrink-0 items-center gap-3 text-[#0068b5] sm:gap-5">
					<Link
						to="/profile"
						aria-label="My Intel Account"
						className="inline-flex items-center justify-center rounded-sm p-1 text-[#0068b5] transition-colors hover:text-[#004a86] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#0068b5]"
					>
						<User aria-hidden="true" className="size-5 stroke-[1.75]" />
					</Link>
					<div
						aria-label="Language: English"
						className="inline-flex items-center gap-1.5 text-xs font-normal tracking-wide text-[#0068b5] uppercase select-none"
					>
						<Globe aria-hidden="true" className="size-5 stroke-[1.75]" />
						<span className="hidden sm:inline">ENGLISH</span>
					</div>
				</div>
			)}
		</nav>
	);
}

export default function IghfHeader({ mobileNavOpen, onToggleMobileNav }: IghfHeaderProps = {}) {
	const { loading, isAuthenticated } = useAuth();
	const inRouter = useInRouterContext();
	const containerRef = useRef<HTMLDivElement>(null);
	const [hasVendorHeader, setHasVendorHeader] = useState(false);
	const [offsets, setOffsets] = useState<VendorHeaderOffsets>({
		leftOffsetPx: 96,
		rightOffsetPx: 200,
	});

	useEffect(() => {
		if (loading || !containerRef.current) return;

		const container = containerRef.current;
		container.classList.add("recode50");

		const environment = (globalThis as { SFDC_ENV?: { language?: string } }).SFDC_ENV;
		const language = environment?.language || document.documentElement.lang || "en";
		const culture = LANGUAGE_CULTURES[language] || language.replace(/-/g, "_");
		const navigation = (window.INTELNAV ??= {});
		navigation.renderSettings = {
			version: "2.0 - 03/12/2017 08:00:00",
			textDirection: "ltr",
			culture,
			OutputId: "default",
		};
		if (isAuthenticated) navigation.dashboard = "";

		const cachedHeaderHtml = (
			window as Window & {
				GAAT40?: { HTMLContentHeader?: { content?: string } };
			}
		).GAAT40?.HTMLContentHeader?.content;
		if (container.childElementCount === 0 && cachedHeaderHtml) {
			container.innerHTML = cachedHeaderHtml;
		}

		const isVendorReady = () =>
			container.childElementCount > 0 && !container.querySelector("#tmpHDBlueBar");

		const syncVendorHeader = () => {
			container.classList.add("recode50");
			if (isVendorReady()) {
				setHasVendorHeader(true);
				setOffsets(measureVendorHeaderOffsets(container));
			}
		};

		const reportFallback = () => {
			console.warn(
				"[IghfHeader] External Intel IGHF loader could not complete. Using built-in IGHF header fallback.",
			);
		};

		let script = document.querySelector<HTMLScriptElement>(`script[src="${LOADER_URL}"]`);
		const isNewScript = !script;
		if (!script) {
			script = document.createElement("script");
			script.src = LOADER_URL;
			script.async = true;
		}
		script.addEventListener("error", reportFallback);

		const syncTimers: number[] = [];
		const scheduleSync = () => {
			syncVendorHeader();
			syncTimers.push(window.setTimeout(syncVendorHeader, 150));
			syncTimers.push(window.setTimeout(syncVendorHeader, 500));
			syncTimers.push(window.setTimeout(syncVendorHeader, 1500));
		};

		scheduleSync();

		const timeout = window.setTimeout(() => {
			if (!isVendorReady()) reportFallback();
		}, 20000);

		const observer = new MutationObserver(() => {
			if (isVendorReady()) {
				window.clearTimeout(timeout);
				scheduleSync();
			}
		});
		observer.observe(container, { childList: true, subtree: true });

		const trackedLinks = new Set<HTMLLinkElement>();
		const attachStylesheetListeners = () => {
			document.head.querySelectorAll<HTMLLinkElement>('link[rel="stylesheet"]').forEach((link) => {
				if (!trackedLinks.has(link)) {
					trackedLinks.add(link);
					link.addEventListener("load", syncVendorHeader);
				}
			});
		};
		attachStylesheetListeners();
		const headObserver = new MutationObserver(() => {
			attachStylesheetListeners();
		});
		headObserver.observe(document.head, { childList: true });

		const resizeObserver =
			typeof ResizeObserver !== "undefined" ? new ResizeObserver(syncVendorHeader) : null;
		resizeObserver?.observe(container);
		window.addEventListener("resize", syncVendorHeader);

		if (isNewScript) document.head.appendChild(script);

		return () => {
			observer.disconnect();
			headObserver.disconnect();
			trackedLinks.forEach((link) => link.removeEventListener("load", syncVendorHeader));
			resizeObserver?.disconnect();
			window.removeEventListener("resize", syncVendorHeader);
			window.clearTimeout(timeout);
			syncTimers.forEach((id) => window.clearTimeout(id));
			script.removeEventListener("error", reportFallback);
		};
	}, [loading, isAuthenticated]);

	return (
		<header
			className={`relative z-30 min-h-[3.75rem] w-full shrink-0 bg-white ${
				hasVendorHeader ? "" : "border-b border-slate-200"
			}`}
		>
			<div className={hasVendorHeader ? "w-full" : "h-0 overflow-hidden"}>
				<div id="recode50header" className="recode50 no-animate" ref={containerRef} />
			</div>
			{inRouter && (
				<PartnerHeaderBar
					mobileNavOpen={mobileNavOpen}
					onToggleMobileNav={onToggleMobileNav}
					hasVendorHeader={hasVendorHeader}
					offsets={offsets}
				/>
			)}
		</header>
	);
}
