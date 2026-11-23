import { Outlet, NavLink, useLocation, matchPath } from "react-router";
import {
	BarChart3,
	BriefcaseBusiness,
	Folder,
	Gift,
	House,
	PanelLeftClose,
	PanelLeftOpen,
	Settings,
	Shield,
	Store,
	User,
} from "lucide-react";
import { useEffect, useRef, useState } from "react";
import CustomerWebClientChat from "./components/CustomerWebClientChat";
import IghfHeader from "./components/IghfHeader";
import IghfFooter from "./components/IghfFooter";
import { SideNavPromo } from "./components/SideNavPromo";

const INTEL_FAVICON_DATA_URI =
	"data:image/svg+xml," +
	encodeURIComponent(
		`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><rect width="64" height="64" rx="12" fill="#0068B5"/><text x="6" y="42" font-family="'Intel Clear',Arial,sans-serif" font-size="23" font-weight="800" fill="#FFFFFF" letter-spacing="-0.5">intel</text><rect x="53" y="37" width="5" height="5" fill="#00C7FD"/></svg>`,
	);

const SIDEBAR_ITEMS = [
	{ to: "/", label: "Home", icon: House, end: true },
	{ to: "/benefits", label: "Manage Benefits", icon: Settings },
	{ to: "/points-rewards", label: "Points & Rewards", icon: Gift },
	{ to: "/warranty", label: "Warranty", icon: Shield },
	{ to: "/training", label: "Sales & Training", icon: Store },
	{ to: "/opportunities", label: "Opportunities", icon: BriefcaseBusiness },
	{ to: "/resources", label: "Resources & Tools", icon: Folder },
	{ to: "/account", label: "Account Management", icon: User },
	{ to: "/reports", label: "Reports & Analytics", icon: BarChart3 },
];

const SIDEBAR_COLLAPSED_STORAGE_KEY = "ipa.sidebarCollapsed";

export default function AppLayout() {
	const location = useLocation();
	const outletWrapperRef = useRef<HTMLDivElement>(null);
	const previousPathname = useRef<string | null>(null);
	const [mobileNavOpen, setMobileNavOpen] = useState(false);
	const [sidebarCollapsed, setSidebarCollapsed] = useState<boolean>(() => {
		try {
			return window.localStorage.getItem(SIDEBAR_COLLAPSED_STORAGE_KEY) === "true";
		} catch {
			return false;
		}
	});

	const toggleSidebarCollapsed = () => {
		setSidebarCollapsed((prev) => {
			const next = !prev;
			try {
				window.localStorage.setItem(SIDEBAR_COLLAPSED_STORAGE_KEY, String(next));
			} catch {
				// Ignore storage errors in restricted environments
			}
			return next;
		});
	};

	const isDesktopCollapsed = sidebarCollapsed && !mobileNavOpen;

	useEffect(() => {
		let iconLink = document.head.querySelector<HTMLLinkElement>("link[rel='icon']");
		if (!iconLink) {
			iconLink = document.createElement("link");
			iconLink.rel = "icon";
			document.head.appendChild(iconLink);
		}
		iconLink.type = "image/svg+xml";
		iconLink.href = INTEL_FAVICON_DATA_URI;
	}, []);

	useEffect(() => {
		setMobileNavOpen(false);
		if (matchPath("/search", location.pathname)) document.title = "Search Results | MyApp";
		if (previousPathname.current !== null && previousPathname.current !== location.pathname) {
			const wrapper = outletWrapperRef.current;
			wrapper?.scrollTo?.({ top: 0 });
			const target = wrapper?.querySelector<HTMLElement>("h1");
			if (target) {
				if (!target.hasAttribute("tabindex")) target.setAttribute("tabindex", "-1");
				target.focus({ preventScroll: true });
			}
		}
		previousPathname.current = location.pathname;
	}, [location.pathname]);

	return (
		<div className="flex h-dvh flex-col overflow-hidden bg-[#f4f6f9]">
			<a
				href="#main-content"
				onClick={(e) => {
					e.preventDefault();
					const content = outletWrapperRef.current;
					if (content) {
						if (!content.hasAttribute("tabindex")) content.setAttribute("tabindex", "-1");
						content.focus();
					}
				}}
				className="sr-only focus:not-sr-only focus:absolute focus:z-50 focus:top-2 focus:left-2 focus:rounded-md focus:bg-white focus:px-4 focus:py-2 focus:text-gray-900 focus:shadow focus:ring-2 focus:ring-gray-900"
			>
				Skip to main content
			</a>
			<IghfHeader
				mobileNavOpen={mobileNavOpen}
				onToggleMobileNav={() => setMobileNavOpen((prev) => !prev)}
			/>
			<div className="relative flex min-h-0 flex-1 overflow-hidden">
				{mobileNavOpen && (
					<div
						aria-hidden="true"
						onClick={() => setMobileNavOpen(false)}
						className="fixed inset-0 top-[3.75rem] z-40 bg-black/40 md:hidden"
					/>
				)}
				<aside
					id="app-sidebar"
					className={`${
						mobileNavOpen
							? "fixed inset-y-0 top-[3.75rem] left-0 z-50 flex w-64 max-w-[80vw]"
							: "hidden md:flex"
					} ${
						isDesktopCollapsed ? "md:w-16 md:px-2" : "md:w-[clamp(13rem,14vw,16.5rem)]"
					} h-full shrink-0 flex-col justify-between gap-2 overflow-hidden bg-[#0b2340] p-2.5 text-white transition-[width] duration-200 ease-in-out md:static md:z-auto`}
				>
					<div className="flex min-h-0 flex-col gap-1">
						<div
							className={`hidden md:flex ${
								isDesktopCollapsed ? "justify-center" : "justify-end"
							}`}
						>
							<button
								type="button"
								onClick={toggleSidebarCollapsed}
								aria-label={sidebarCollapsed ? "Expand sidebar" : "Collapse sidebar"}
								aria-expanded={!sidebarCollapsed}
								aria-controls="app-sidebar"
								title={sidebarCollapsed ? "Expand sidebar" : "Collapse sidebar"}
								className="inline-flex items-center justify-center rounded-md p-1.5 text-slate-300 transition-colors hover:bg-white/10 hover:text-white focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white"
							>
								{sidebarCollapsed ? (
									<PanelLeftOpen aria-hidden="true" className="h-4 w-4" />
								) : (
									<PanelLeftClose aria-hidden="true" className="h-4 w-4" />
								)}
							</button>
						</div>
						<nav aria-label="Sidebar" className="flex flex-col gap-0.5">
							{SIDEBAR_ITEMS.map(({ to, label, icon: Icon, end }) => (
								<NavLink
									key={to}
									to={to}
									end={end}
									title={isDesktopCollapsed ? label : undefined}
									onClick={() => setMobileNavOpen(false)}
									className={({ isActive }) =>
										`flex items-center rounded-md text-[clamp(0.775rem,0.85vw,0.875rem)] font-normal transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white ${
											isDesktopCollapsed
												? "justify-center px-2 py-2"
												: "gap-2.5 px-3 py-1.5"
										} ${
											isActive ? "bg-[#174a8b] font-medium text-white" : "text-slate-200 hover:bg-white/10"
										}`
									}
								>
									<Icon aria-hidden="true" className="h-4 w-4 shrink-0" />
									<span className={isDesktopCollapsed ? "sr-only" : "truncate"}>{label}</span>
								</NavLink>
							))}
						</nav>
					</div>
					{!isDesktopCollapsed && <SideNavPromo />}
				</aside>
				<div
					id="main-content"
					ref={outletWrapperRef}
					className="flex min-h-0 min-w-0 flex-1 flex-col overflow-y-auto bg-[#f4f6f9]"
				>
					<div className="flex w-full shrink-0 grow flex-col">
						<Outlet />
					</div>
					<div className="shrink-0">
						<IghfFooter />
					</div>
				</div>
			</div>
			<CustomerWebClientChat
				orgId="<ORG_ID_15_OR_18_CHAR_00D...>"
				deploymentName="<EMBEDDED_SERVICE_DEPLOYMENT_NAME>"
				siteURL="<SITE_URL>"
				scrt2URL="<SCRT2_URL>"
			/>
		</div>
	);
}
