import { Outlet, Link, NavLink, useLocation, matchPath } from "react-router";
import { BriefcaseBusiness, Gift, House } from "lucide-react";
import { getAllRoutes } from "./router-utils";
import { useEffect, useId, useRef, useState } from "react";
import { AuthMenu } from "./features/authentication/menu/AuthMenu";
import { Button } from "./components/ui/button";
import CustomerWebClientChat from "./components/CustomerWebClientChat";
import IghfHeader from "./components/IghfHeader";
import IghfFooter from "./components/IghfFooter";
import { GlobalSearchBox } from "./features/search";

export default function AppLayout() {
	const [isOpen, setIsOpen] = useState(false);
	const location = useLocation();
	const navId = useId();
	const outletWrapperRef = useRef<HTMLDivElement>(null);
	const previousPathname = useRef<string | null>(null);
	const menuButtonRef = useRef<HTMLButtonElement>(null);

	useEffect(() => {
		if (matchPath("/search", location.pathname)) document.title = "Search Results | MyApp";
		if (previousPathname.current !== null && previousPathname.current !== location.pathname) {
			const wrapper = outletWrapperRef.current;
			const target = wrapper?.querySelector<HTMLElement>("h1");
			if (target) {
				if (!target.hasAttribute("tabindex")) target.setAttribute("tabindex", "-1");
				target.focus();
			}
		}
		previousPathname.current = location.pathname;
	}, [location.pathname]);

	const isActive = (path: string) => location.pathname === path;

	const toggleMenu = () => setIsOpen(!isOpen);

	const navigationRoutes: { path: string; label: string }[] = getAllRoutes()
		.filter(
			(route) =>
				route.handle?.showInNavigation === true &&
				route.fullPath !== undefined &&
				route.handle?.label !== undefined,
		)
		.map(
			(route) =>
				({
					path: route.fullPath,
					label: route.handle?.label,
				}) as { path: string; label: string },
		);

	return (
		<>
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
			<IghfHeader />
			<nav aria-label="Primary" className="border-b border-white/10 bg-[#0b2340] text-white">
				<div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
					<div className="grid min-h-16 grid-cols-[minmax(0,1fr)_auto] items-center gap-x-4 gap-y-3 py-3 md:grid-cols-[auto_minmax(0,1fr)_auto]">
						<Link
							to="/"
							aria-label="Intel Partner Experience home"
							className="flex min-w-0 items-center gap-3 rounded-sm focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-white sm:gap-5"
						>
							<img
								src="https://www.intel.com/content/dam/logos/intel-header-logo.svg"
								alt="Intel"
								width={72}
								height={28}
								className="h-7 w-[72px] shrink-0 brightness-0 invert"
							/>
							<span className="text-sm font-semibold sm:text-base">Partner Experience</span>
						</Link>
						<GlobalSearchBox
							placeholder="Search accounts, contacts, opportunities..."
							hideSubmitButton
							minLengthHint="Enter at least {min} characters, then press Enter to search."
							className="col-span-2 row-start-2 min-w-0 w-full text-slate-900 md:col-span-1 md:col-start-2 md:row-start-1 md:max-w-xl [&_input]:bg-white [&_input]:text-slate-900 [&_input]:placeholder:text-slate-500"
						/>
						<div className="col-start-2 row-start-1 flex items-center gap-2 md:col-start-3">
							<AuthMenu />
							<Button
								ref={menuButtonRef}
								variant="ghost"
								size="icon"
								onClick={toggleMenu}
								aria-label="Toggle menu"
								aria-expanded={isOpen}
								aria-controls={navId}
							>
								<div
									aria-hidden="true"
									className="w-6 h-6 flex flex-col justify-center space-y-1.5"
								>
									<span
										className={`block h-0.5 w-6 bg-current transition-all ${
											isOpen ? "rotate-45 translate-y-2" : ""
										}`}
									/>
									<span
										className={`block h-0.5 w-6 bg-current transition-all ${isOpen ? "opacity-0" : ""}`}
									/>
									<span
										className={`block h-0.5 w-6 bg-current transition-all ${
											isOpen ? "-rotate-45 -translate-y-2" : ""
										}`}
									/>
								</div>
							</Button>
						</div>
					</div>
					<div id={navId} className="pb-4" hidden={!isOpen}>
						{isOpen && (
							<div className="flex flex-col space-y-1">
								{navigationRoutes.map((item) => (
									<Button
										key={item.path}
										variant={isActive(item.path) ? "secondary" : "ghost"}
										asChild
										className="justify-start"
									>
										<Link
											to={item.path}
											onClick={() => {
												setIsOpen(false);
												if (isActive(item.path)) menuButtonRef.current?.focus();
											}}
										>
											{item.label}
										</Link>
									</Button>
								))}
							</div>
						)}
					</div>
				</div>
			</nav>
			<div className="flex min-h-[calc(100dvh-4rem)] flex-col md:flex-row">
				<aside className="shrink-0 bg-[#0b2340] p-3 text-white md:w-56">
					<nav aria-label="Sidebar">
						<NavLink
							to="/"
							end
							className={({ isActive }) =>
								`flex items-center gap-3 rounded-md px-4 py-3 text-sm font-medium transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white ${
									isActive ? "bg-[#174a8b] text-white" : "text-slate-200 hover:bg-white/10"
								}`
							}
						>
							<House aria-hidden="true" className="h-5 w-5 shrink-0" />
							Home
						</NavLink>
						<NavLink
							to="/points-rewards"
							className={({ isActive }) =>
								`flex items-center gap-3 rounded-md px-4 py-3 text-sm font-medium transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white ${
									isActive ? "bg-[#174a8b] text-white" : "text-slate-200 hover:bg-white/10"
								}`
							}
						>
							<Gift aria-hidden="true" className="h-5 w-5 shrink-0" />
							Points &amp; Rewards
						</NavLink>
						<NavLink
							to="/opportunities"
							className={({ isActive }) =>
								`flex items-center gap-3 rounded-md px-4 py-3 text-sm font-medium transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white ${
									isActive ? "bg-[#174a8b] text-white" : "text-slate-200 hover:bg-white/10"
								}`
							}
						>
							<BriefcaseBusiness aria-hidden="true" className="h-5 w-5 shrink-0" />
							Opportunities
						</NavLink>
					</nav>
				</aside>
				<div id="main-content" ref={outletWrapperRef} className="min-w-0 flex-1">
					<Outlet />
				</div>
			</div>
			<IghfFooter />
			<CustomerWebClientChat
				orgId="<ORG_ID_15_OR_18_CHAR_00D...>"
				deploymentName="<EMBEDDED_SERVICE_DEPLOYMENT_NAME>"
				siteURL="<SITE_URL>"
				scrt2URL="<SCRT2_URL>"
			/>
		</>
	);
}
