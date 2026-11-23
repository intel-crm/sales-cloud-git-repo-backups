import { useEffect, useRef, useState } from "react";

const PRIMARY_LINKS = [
	{ label: "Company Overview", href: "https://www.intel.com/content/www/us/en/company-overview/company-overview.html" },
	{ label: "Contact Intel", href: "https://www.intel.com/content/www/us/en/support/contact-us.html" },
	{ label: "News", href: "https://newsroom.intel.com/" },
	{ label: "Investors", href: "https://www.intc.com/" },
	{ label: "Careers", href: "https://www.intel.com/content/www/us/en/jobs/jobs-at-intel.html" },
	{ label: "Corporate Responsibility", href: "https://www.intel.com/content/www/us/en/corporate-responsibility/corporate-responsibility.html" },
	{ label: "Inclusion", href: "https://www.intel.com/content/www/us/en/diversity/diversity-at-intel.html" },
	{ label: "Public Policy", href: "https://www.intel.com/content/www/us/en/policy/policy-overview.html" },
] as const;

const LEGAL_LINKS = [
	{ label: "Terms of Use", href: "https://www.intel.com/content/www/us/en/legal/terms-of-use.html" },
	{ label: "*Trademarks", href: "https://www.intel.com/content/www/us/en/legal/trademarks.html" },
	{ label: "Cookies", href: "https://www.intel.com/content/www/us/en/privacy/intel-cookie-notice.html" },
	{ label: "Privacy", href: "https://www.intel.com/content/www/us/en/privacy/intel-privacy-notice.html" },
	{ label: "Supply Chain Transparency", href: "https://www.intel.com/content/www/us/en/corporate-responsibility/statement-combating-modern-slavery.html" },
	{ label: "Site Map", href: "https://www.intel.com/content/www/us/en/siteindex.html" },
	{ label: "Recycling", href: "https://www.intel.com/content/www/us/en/support/articles/000098122/services.html" },
] as const;

function removeFooterTopMargin(container: HTMLElement) {
	container.style.setProperty("margin-top", "0", "important");
	container.style.setProperty("padding-top", "0", "important");
	const elements = container.querySelectorAll<HTMLElement>("footer, div, section");
	elements.forEach((el) => {
		const computed = window.getComputedStyle(el);
		if (parseFloat(computed.marginTop) > 0) {
			el.style.setProperty("margin-top", "0", "important");
		}
	});
}

function FallbackIghfFooter() {
	return (
		<footer
			aria-label="Intel global footer"
			className="w-full border-t border-slate-200 bg-[#e9eaec] px-5 py-8 text-[#262626] sm:px-8 lg:px-12"
		>
			<div className="mx-auto flex max-w-6xl flex-col gap-6 md:flex-row md:items-center md:gap-10">
				<div className="hidden shrink-0 md:block">
					<a
						href="https://www.intel.com/content/www/us/en/homepage.html"
						target="_blank"
						rel="noreferrer"
						aria-label="Intel Corporation home"
						className="inline-block focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-[#0068b5]"
					>
						<img
							src="https://www.intel.com/content/dam/logos/intel-header-logo.svg"
							alt="Intel"
							className="h-8 w-auto"
						/>
					</a>
				</div>

				<div className="flex min-w-0 flex-1 flex-col gap-5">
					<nav aria-label="Footer navigation">
						<ul className="flex flex-wrap gap-x-6 gap-y-2 text-[0.925rem] font-normal text-[#262626]">
							{PRIMARY_LINKS.map((item) => (
								<li key={item.label}>
									<a
										href={item.href}
										target="_blank"
										rel="noreferrer"
										className="hover:text-[#0068b5] hover:underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#0068b5]"
									>
										{item.label}
									</a>
								</li>
							))}
						</ul>
					</nav>

					<div className="flex items-center gap-5 text-[#262626]">
						<a
							href="https://www.facebook.com/Intel"
							target="_blank"
							rel="noreferrer"
							aria-label="Intel on Facebook"
							className="transition-colors hover:text-[#0068b5]"
						>
							<svg aria-hidden="true" viewBox="0 0 24 24" className="size-5 fill-current">
								<path d="M13.5 21v-7.5h2.5l.4-3h-2.9V8.6c0-.9.3-1.5 1.6-1.5H16.5V4.4c-.3 0-1.2-.1-2.2-.1-2.2 0-3.8 1.3-3.8 3.8v2.4H8v3h2.5V21h3Z" />
							</svg>
						</a>
						<a
							href="https://x.com/intel"
							target="_blank"
							rel="noreferrer"
							aria-label="Intel on X"
							className="transition-colors hover:text-[#0068b5]"
						>
							<svg aria-hidden="true" viewBox="0 0 24 24" className="size-5 fill-current">
								<path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
							</svg>
						</a>
						<a
							href="https://www.linkedin.com/company/intel-corporation"
							target="_blank"
							rel="noreferrer"
							aria-label="Intel on LinkedIn"
							className="transition-colors hover:text-[#0068b5]"
						>
							<svg aria-hidden="true" viewBox="0 0 24 24" className="size-5 fill-current">
								<path d="M6.94 8.5H3.56V20h3.38V8.5ZM5.25 3A2.02 2.02 0 0 0 3.2 5.03c0 1.11.9 2.02 2.02 2.02h.03c1.14 0 2.04-.91 2.04-2.02C7.27 3.9 6.39 3 5.25 3ZM20.8 13.4c0-3.47-1.85-5.08-4.32-5.08-1.99 0-2.88 1.1-3.38 1.87V8.5H9.72c.04.95 0 11.5 0 11.5h3.38v-6.42c0-.34.03-.68.13-.93.27-.68.89-1.39 1.93-1.39 1.36 0 1.9 1.04 1.9 2.56V20h3.38v-6.6h.36Z" />
							</svg>
						</a>
						<a
							href="https://www.youtube.com/user/channelintel"
							target="_blank"
							rel="noreferrer"
							aria-label="Intel on YouTube"
							className="transition-colors hover:text-[#0068b5]"
						>
							<svg aria-hidden="true" viewBox="0 0 24 24" className="size-5 fill-current">
								<path d="M21.58 7.19a2.75 2.75 0 0 0-1.94-1.95C17.93 4.78 12 4.78 12 4.78s-5.93 0-7.64.46A2.75 2.75 0 0 0 2.42 7.2C1.96 8.9 1.96 12 1.96 12s0 3.1.46 4.81a2.75 2.75 0 0 0 1.94 1.95c1.71.46 7.64.46 7.64.46s5.93 0 7.64-.46a2.75 2.75 0 0 0 1.94-1.95c.46-1.71.46-4.81.46-4.81s0-3.1-.46-4.81ZM10 15.15V8.85L15.45 12 10 15.15Z" />
							</svg>
						</a>
						<a
							href="https://www.instagram.com/intel/"
							target="_blank"
							rel="noreferrer"
							aria-label="Intel on Instagram"
							className="transition-colors hover:text-[#0068b5]"
						>
							<svg aria-hidden="true" viewBox="0 0 24 24" className="size-5 fill-current">
								<path d="M12 2.2c3.2 0 3.58.01 4.85.07 1.17.05 1.8.25 2.22.41.56.22.96.48 1.38.9.42.42.68.82.9 1.38.16.42.36 1.05.41 2.22.06 1.27.07 1.65.07 4.85s-.01 3.58-.07 4.85c-.05 1.17-.25 1.8-.41 2.22a3.72 3.72 0 0 1-.9 1.38c-.42.42-.82.68-1.38.9-.42.16-1.05.36-2.22.41-1.27.06-1.65.07-4.85.07s-3.58-.01-4.85-.07c-1.17-.05-1.8-.25-2.22-.41a3.72 3.72 0 0 1-1.38-.9 3.72 3.72 0 0 1-.9-1.38c-.16-.42-.36-1.05-.41-2.22C2.21 15.58 2.2 15.2 2.2 12s.01-3.58.07-4.85c.05-1.17.25-1.8.41-2.22.22-.56.48-.96.9-1.38.42-.42.82-.68 1.38-.9.42-.16 1.05-.36 2.22-.41C8.42 2.21 8.8 2.2 12 2.2Zm0 1.8c-3.15 0-3.52.01-4.76.07-.98.04-1.51.21-1.86.35-.47.18-.8.4-1.15.75-.35.35-.57.68-.75 1.15-.14.35-.31.88-.35 1.86-.06 1.24-.07 1.61-.07 4.76s.01 3.52.07 4.76c.04.98.21 1.51.35 1.86.18.47.4.8.75 1.15.35.35.68.57 1.15.75.35.14.88.31 1.86.35 1.24.06 1.61.07 4.76.07s3.52-.01 4.76-.07c.98-.04 1.51-.21 1.86-.35.47-.18.8-.4 1.15-.75.35-.35.57-.68.75-1.15.14-.35.31-.88.35-1.86.06-1.24.07-1.61.07-4.76s-.01-3.52-.07-4.76c-.04-.98-.21-1.51-.35-1.86a3.1 3.1 0 0 0-.75-1.15 3.1 3.1 0 0 0-1.15-.75c-.35-.14-.88-.31-1.86-.35-1.24-.06-1.61-.07-4.76-.07Zm0 3.08a4.92 4.92 0 1 1 0 9.84 4.92 4.92 0 0 1 0-9.84Zm0 1.8a3.12 3.12 0 1 0 0 6.24 3.12 3.12 0 0 0 0-6.24Zm5.12-3.15a1.15 1.15 0 1 1 0 2.3 1.15 1.15 0 0 1 0-2.3Z" />
							</svg>
						</a>
					</div>

					<div className="flex flex-wrap items-center gap-x-3 gap-y-1.5 text-xs text-[#262626]">
						<span>&copy; Intel Corporation</span>
						{LEGAL_LINKS.map((item) => (
							<span key={item.label} className="inline-flex items-center gap-3">
								<span aria-hidden="true" className="text-slate-400">
									|
								</span>
								<a
									href={item.href}
									target="_blank"
									rel="noreferrer"
									className="hover:text-[#0068b5] hover:underline"
								>
									{item.label}
								</a>
							</span>
						))}
					</div>

					<p className="max-w-4xl text-xs leading-relaxed text-[#3c3c3c]">
						Intel technologies may require enabled hardware, software or service activation. // No
						product or component can be absolutely secure. // Your costs and results may vary. //
						Performance varies by use, configuration, and other factors. Learn more at{" "}
						<a
							href="https://www.intel.com/performanceindex"
							target="_blank"
							rel="noreferrer"
							className="underline hover:text-[#0068b5]"
						>
							intel.com/performanceindex
						</a>
						. // See our complete legal{" "}
						<a
							href="https://www.intel.com/content/www/us/en/products/docs/processors/core/core-i7-ee-general-notices.html"
							target="_blank"
							rel="noreferrer"
							className="underline hover:text-[#0068b5]"
						>
							Notices and Disclaimers
						</a>
						. // Intel is committed to respecting human rights and avoiding causing or contributing to
						adverse impacts on human rights. See Intel&apos;s{" "}
						<a
							href="https://www.intel.com/content/www/us/en/policy/policy-human-rights.html"
							target="_blank"
							rel="noreferrer"
							className="underline hover:text-[#0068b5]"
						>
							Global Human Rights Principles
						</a>
						. Intel&apos;s products and software are intended only to be used in applications that do
						not cause or contribute to adverse impacts on human rights.
					</p>

					<div className="pt-1 md:hidden">
						<img
							src="https://www.intel.com/content/dam/logos/intel-header-logo.svg"
							alt="Intel"
							className="h-6 w-auto"
						/>
					</div>
				</div>
			</div>
		</footer>
	);
}

export default function IghfFooter() {
	const footerRef = useRef<HTMLDivElement>(null);
	const [hasVendorFooter, setHasVendorFooter] = useState(false);

	useEffect(() => {
		const navigation = (window.INTELNAV ??= {});
		navigation.renderSettingsFooter = {
			version: "2.0 - 03/12/2017 08:00:00",
			OutputId: "gf_default",
		};

		const container = footerRef.current;
		if (!container) return;
		container.classList.add("recode50");

		const cachedFooterHtml = (
			window as Window & {
				GAAT40?: { HTMLContentFooter?: { content?: string } };
			}
		).GAAT40?.HTMLContentFooter?.content;
		if (container.childElementCount === 0 && cachedFooterHtml) {
			container.innerHTML = cachedFooterHtml;
		}

		const syncTimers: number[] = [];
		const scheduleFooterSync = () => {
			container.classList.add("recode50");
			if (container.childElementCount > 0) {
				document.documentElement.classList.add("rwd", "headerfooter-menu3");
				setHasVendorFooter(true);
			}
			removeFooterTopMargin(container);
			syncTimers.push(window.setTimeout(() => removeFooterTopMargin(container), 150));
			syncTimers.push(window.setTimeout(() => removeFooterTopMargin(container), 500));
		};
		scheduleFooterSync();

		const observer = new MutationObserver(() => {
			scheduleFooterSync();
		});
		observer.observe(container, { childList: true, subtree: true });

		return () => {
			observer.disconnect();
			syncTimers.forEach((id) => window.clearTimeout(id));
		};
	}, []);

	return (
		<>
			<div className={hasVendorFooter ? "w-full" : "h-0 overflow-hidden"}>
				<div id="recode50footer" className="recode50 no-animate" ref={footerRef} />
			</div>
			{!hasVendorFooter && <FallbackIghfFooter />}
		</>
	);
}
