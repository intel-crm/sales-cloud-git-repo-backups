/**
 * Copyright (c) 2026, Salesforce, Inc.
 * All rights reserved.
 * For full license text, see the LICENSE.txt file
 */

import { useEffect, useRef, useState, type FormEvent, type ReactNode } from "react";
import { ExternalLink, Maximize2, Minimize2, Minus, Send } from "lucide-react";
import type { CustomerWebClientChatProps, WindowWithCwcProperties } from "../types/chat";

interface ChatTurn {
	id: string;
	query: string;
	timestampLabel: string;
	response: ReactNode;
}

function ChatExternalLink({
	href,
	children,
	italic = false,
}: {
	href: string;
	children: ReactNode;
	italic?: boolean;
}) {
	return (
		<a
			href={href}
			target="_blank"
			rel="noreferrer"
			className={`inline-flex items-center gap-0.5 font-bold text-[#0047ab] underline hover:text-[#002d6b] ${
				italic ? "italic" : ""
			}`}
		>
			<span>{children}</span>
			<ExternalLink
				aria-hidden="true"
				className="ml-0.5 inline size-3 shrink-0 text-slate-600"
			/>
		</a>
	);
}

const LINKS = {
	ipa: "https://www.intel.com/content/www/us/en/partner-alliance/overview.html",
	university: "https://partneruniversity.intel.com/",
	showcase: "https://www.intel.com/content/www/us/en/partner-alliance/partner-showcase/overview.html",
	marketingStudio: "https://marketingstudio.intel.com/",
	awr: "https://www.intel.com/content/www/us/en/support/articles/000005854/services.html",
	aboutMembership: "https://www.intel.com/content/www/us/en/partner-alliance/membership.html",
	customerSupport: "https://www.intel.com/content/www/us/en/support/contact-us.html",
	benefitsArticle:
		"https://www.intel.com/content/www/us/en/support/articles/000055213/programs/intel-partner-alliance.html",
};

const QUICK_TOPICS: {
	label: string;
	isCustom?: boolean;
	response: ReactNode;
}[] = [
	{
		label:
			"View company dashboard. Show me all of the company users with their active certifications.",
		isCustom: true,
		response: (
			<div className="space-y-2.5 text-[12.5px] leading-relaxed text-[#333333]">
				<h3 className="font-bold text-[#262626]">
					Company Dashboard &amp; Active User Certifications
				</h3>
				<p>
					Intel&reg; Partner Alliance membership provides unique
					business-building opportunities through several benefits:
				</p>
				<p className="font-bold text-[#262626]">Benefits of membership</p>
				<div className="space-y-1">
					<p>
						<strong className="font-bold text-[#262626]">
							Training and competencies
						</strong>{" "}
						&ndash; Admission to{" "}
						<ChatExternalLink href={LINKS.university}>
							Intel&reg; Partner University
						</ChatExternalLink>{" "}
						offers specialized training on advanced technologies, competency
						programs, and rewards for learning.
					</p>
					<p>
						<strong className="font-bold text-[#262626]">
							Marketing resources
						</strong>{" "}
						&ndash; Access to{" "}
						<ChatExternalLink href={LINKS.showcase}>
							Intel&reg; Partner Showcase
						</ChatExternalLink>{" "}
						and{" "}
						<ChatExternalLink href={LINKS.marketingStudio}>
							Partner Marketing Studio
						</ChatExternalLink>{" "}
						helps create more demand for your products and services.
					</p>
					<p>
						<strong className="font-bold text-[#262626]">
							Valuable rewards
						</strong>{" "}
						&ndash; Earn points for qualifying activities, advance your
						membership status, and gain access to additional resources to
						grow your business.
					</p>
					<p>
						<strong className="font-bold text-[#262626]">
							Expedited support
						</strong>{" "}
						&ndash; Quickly connect with live Intel support and account
						personnel whenever you need assistance.
					</p>
				</div>
				<p>
					To view your company users, active certifications, and complete
					list of Benefits and Requirements,{" "}
					<strong className="font-bold">visit</strong>{" "}
					<ChatExternalLink href={LINKS.aboutMembership}>
						About Membership
					</ChatExternalLink>
					.
				</p>
				<div>
					<p>Source:</p>
					<ul className="mt-1 list-disc pl-5">
						<li>
							<ChatExternalLink href={LINKS.benefitsArticle}>
								What Are the Benefits of Joining the Intel&reg; Partner
								Alliance Program?
							</ChatExternalLink>
						</li>
					</ul>
				</div>
			</div>
		),
	},
	{
		label: "View Opportunity Dashboard",
		response: (
			<div className="space-y-2.5 text-[12.5px] leading-relaxed text-[#333333]">
				<h3 className="font-bold text-[#262626]">
					Opportunity Pipeline Dashboard Summary
				</h3>
				<p>
					Your current partner opportunity pipeline includes{" "}
					<strong className="font-bold text-[#262626]">
						5 active opportunities
					</strong>{" "}
					across <strong className="font-bold text-[#262626]">3 stages</strong>{" "}
					with a total valued pipeline of{" "}
					<strong className="font-bold text-[#0068b5]">$150.00</strong>:
				</p>
				<ul className="list-disc space-y-1 pl-5">
					<li>
						<strong className="font-bold text-[#262626]">Define (1):</strong>{" "}
						Test Opportunity &mdash; $150.00 (testIntel Account)
					</li>
					<li>
						<strong className="font-bold text-[#262626]">Design (2):</strong>{" "}
						Sales-PRM-External-Distributor (EAH Child)
					</li>
					<li>
						<strong className="font-bold text-[#262626]">Qualify (2):</strong>{" "}
						TestOpp1 &amp; op1 (Demo Intel account 1 &amp; 2)
					</li>
				</ul>
				<p>
					Navigate to the{" "}
					<strong className="font-bold text-[#262626]">Opportunities</strong>{" "}
					tab in the left navigation to filter deals by stage or partner
					account.
				</p>
			</div>
		),
	},
	{
		label: "Take Me to the Latest Training",
		response: (
			<div className="space-y-2.5 text-[12.5px] leading-relaxed text-[#333333]">
				<h3 className="font-bold text-[#262626]">
					Finding Trainings in Intel&reg; Partner University
				</h3>
				<p>
					To locate training resources within the Intel&reg; Partner
					Alliance program, follow these steps:
				</p>
				<div className="space-y-1">
					<p>
						<strong className="font-bold text-[#262626]">Log in</strong>{" "}
						to the{" "}
						<ChatExternalLink href={LINKS.ipa}>
							Intel&reg; Partner Alliance
						</ChatExternalLink>{" "}
						site.
					</p>
					<p>
						<strong className="font-bold text-[#262626]">Click</strong>{" "}
						<ChatExternalLink href={LINKS.university} italic>
							Partner University
						</ChatExternalLink>
						.
					</p>
				</div>
				<div className="space-y-1.5">
					<p>
						Within Partner University, you can search for courses in any of
						the following categories.{" "}
						<strong className="font-bold text-[#262626]">Click</strong> any
						option to view available courses:
					</p>
					<p>
						<em className="italic">Competencies</em> &ndash; Enroll in a
						series of courses on a specific product or solution and earn a
						badge of completion that can be shared online.
					</p>
					<p>
						<em className="italic">Recommendations &amp; Pathways</em>{" "}
						&ndash; A collection of courses selected based on your role and
						preferences.
					</p>
					<p>
						<em className="italic">Partner University Catalog</em> &ndash;
						View the complete catalog of courses offered.
					</p>
				</div>
				<p>
					If you need further assistance,{" "}
					<strong className="font-bold text-[#262626]">contact</strong>{" "}
					<ChatExternalLink href={LINKS.customerSupport}>
						Intel Customer Support
					</ChatExternalLink>
					.
				</p>
			</div>
		),
	},
	{
		label: "Show me the top 10 resource documents",
		response: (
			<div className="space-y-2.5 text-[12.5px] leading-relaxed text-[#333333]">
				<h3 className="font-bold text-[#262626]">
					Intel&reg; Partner Alliance Technical Enablement Resources and
					Information
				</h3>
				<p>
					Intel&reg; Partner Alliance membership provides access to several
					technical enablement resources and business-building tools:
				</p>
				<div className="space-y-1">
					<p>
						<strong className="font-bold text-[#262626]">
							Training and competencies
						</strong>{" "}
						&ndash; Admission to{" "}
						<ChatExternalLink href={LINKS.university}>
							Intel&reg; Partner University
						</ChatExternalLink>{" "}
						offers specialized training on advanced technologies, competency
						programs, and rewards for learning.
					</p>
					<p>
						<strong className="font-bold text-[#262626]">
							Marketing resources
						</strong>{" "}
						&ndash; Access the{" "}
						<ChatExternalLink href={LINKS.showcase}>
							Intel&reg; Partner Showcase
						</ChatExternalLink>{" "}
						and{" "}
						<ChatExternalLink href={LINKS.marketingStudio}>
							Partner Marketing Studio
						</ChatExternalLink>{" "}
						to create demand for your products and services.
					</p>
					<p>
						<strong className="font-bold text-[#262626]">
							Valuable rewards
						</strong>{" "}
						&ndash; Earn points for qualifying activities, advance your
						membership status, and gain access to additional resources to
						grow your business.
					</p>
					<p>
						<strong className="font-bold text-[#262626]">
							Expedited support
						</strong>{" "}
						&ndash; Quickly connect with live Intel support and account
						personnel for assistance.
					</p>
					<p>
						Membership benefits vary depending on your Partner Role and
						Membership Tier. To view the complete list of benefits and
						requirements,{" "}
						<strong className="font-bold text-[#262626]">visit</strong>{" "}
						<ChatExternalLink href={LINKS.aboutMembership}>
							About Membership
						</ChatExternalLink>
						. For further clarification,{" "}
						<strong className="font-bold text-[#262626]">contact</strong>{" "}
						<ChatExternalLink href={LINKS.customerSupport}>
							Intel Customer Support
						</ChatExternalLink>
						.
					</p>
				</div>
				<div>
					<p>Source:</p>
					<ul className="mt-1 list-disc pl-5">
						<li>
							<ChatExternalLink href={LINKS.benefitsArticle}>
								What Are the Benefits of Joining the Intel&reg; Partner
								Alliance Program?
							</ChatExternalLink>
						</li>
					</ul>
				</div>
			</div>
		),
	},
	{
		label: "Create a Deal Registration",
		response: (
			<div className="space-y-2.5 text-[12.5px] leading-relaxed text-[#333333]">
				<h3 className="font-bold text-[#262626]">
					Create a New Deal Registration
				</h3>
				<p>
					Deal Registration helps protect your sales opportunities and
					unlocks additional partner pricing and support benefits.
				</p>
				<div className="space-y-1">
					<p>
						<strong className="font-bold text-[#262626]">Step 1:</strong>{" "}
						Sign in to the{" "}
						<ChatExternalLink href={LINKS.ipa}>
							Intel&reg; Partner Alliance
						</ChatExternalLink>{" "}
						portal and open your{" "}
						<strong className="font-bold text-[#262626]">
							Opportunities
						</strong>{" "}
						pipeline.
					</p>
					<p>
						<strong className="font-bold text-[#262626]">Step 2:</strong>{" "}
						Provide the end-customer account details, estimated deal value,
						target close date, and qualifying Intel&reg; products.
					</p>
					<p>
						<strong className="font-bold text-[#262626]">Step 3:</strong>{" "}
						Submit for review by your Intel Partner Account Manager.
					</p>
				</div>
				<p>
					For further assistance with deal eligibility,{" "}
					<strong className="font-bold text-[#262626]">contact</strong>{" "}
					<ChatExternalLink href={LINKS.customerSupport}>
						Intel Customer Support
					</ChatExternalLink>
					.
				</p>
			</div>
		),
	},
	{
		label: "Take me to my tier dashboard",
		response: (
			<div className="space-y-2.5 text-[12.5px] leading-relaxed text-[#333333]">
				<h3 className="font-bold text-[#262626]">
					Intel&reg; Partner Alliance Benefits &amp; Tier Overview
				</h3>
				<p>
					Intel&reg; Partner Alliance membership provides unique
					business-building opportunities through training, marketing,
					rewards, and support.
				</p>
				<div>
					<p className="font-bold text-[#262626]">
						Training and competencies
					</p>
					<p className="mt-1">
						Admission to Intel&reg; Partner University offers specialized
						training on advanced technologies, competency programs, and
						rewards for learning.
					</p>
					<p className="mt-1 font-bold text-[#262626]">
						Marketing resources
					</p>
					<p className="mt-1">
						Access to the{" "}
						<ChatExternalLink href={LINKS.showcase}>
							Intel&reg; Partner Showcase
						</ChatExternalLink>{" "}
						and{" "}
						<ChatExternalLink href={LINKS.marketingStudio}>
							Partner Marketing Studio
						</ChatExternalLink>{" "}
						helps create demand for your products and services.
					</p>
					<p className="mt-1 font-bold text-[#262626]">Valuable rewards</p>
					<p className="mt-1">
						Earn points for qualifying activities, advance your membership
						status, and gain access to additional resources to build your
						business.
					</p>
				</div>
				<div className="space-y-0.5">
					<p className="pt-0.5">
						Membership benefits vary based on Partner Role, Membership
						Tier, and other factors. To view the complete list of Benefits
						and Requirements,{" "}
						<strong className="font-bold">visit</strong>{" "}
						<ChatExternalLink href={LINKS.aboutMembership}>
							About Membership
						</ChatExternalLink>
						.
					</p>
				</div>
			</div>
		),
	},
	{
		label: "Create an MDF request",
		response: (
			<div className="space-y-2.5 text-[12.5px] leading-relaxed text-[#333333]">
				<h3 className="font-bold text-[#262626]">
					Market Development Funds (MDF) Request Guide
				</h3>
				<p>
					Eligible Intel&reg; Partner Alliance partners can request Market
					Development Funds (MDF) to co-fund demand generation, events, and
					digital campaigns.
				</p>
				<div className="space-y-1">
					<p>
						<strong className="font-bold text-[#262626]">
							Marketing resources
						</strong>{" "}
						&ndash; Access the{" "}
						<ChatExternalLink href={LINKS.showcase}>
							Intel&reg; Partner Showcase
						</ChatExternalLink>{" "}
						and{" "}
						<ChatExternalLink href={LINKS.marketingStudio}>
							Partner Marketing Studio
						</ChatExternalLink>{" "}
						for pre-approved campaign templates and co-branded assets.
					</p>
					<p>
						<strong className="font-bold text-[#262626]">
							Claim submission
						</strong>{" "}
						&ndash; Upload proof of performance (POP) after activity
						completion to receive reimbursement.
					</p>
				</div>
				<p>
					To check your MDF eligibility and requirements,{" "}
					<strong className="font-bold text-[#262626]">visit</strong>{" "}
					<ChatExternalLink href={LINKS.aboutMembership}>
						About Membership
					</ChatExternalLink>
					.
				</p>
			</div>
		),
	},
	{
		label: "Create a new Campaign",
		response: (
			<div className="space-y-2.5 text-[12.5px] leading-relaxed text-[#333333]">
				<h3 className="font-bold text-[#262626]">
					Intel&reg; Partner Marketing Studio &amp; Campaigns
				</h3>
				<p>
					Launch co-branded marketing campaigns using customizable assets in
					the{" "}
					<ChatExternalLink href={LINKS.marketingStudio}>
						Partner Marketing Studio
					</ChatExternalLink>
					:
				</p>
				<div className="space-y-1">
					<p>
						<strong className="font-bold text-[#262626]">
							Campaign-in-a-Box
						</strong>{" "}
						&ndash; Ready-to-use email templates, social media kits, and
						landing pages for Intel&reg; Core&trade; Ultra, Intel vPro&reg;,
						and Intel&reg; Xeon&reg; 6 solutions.
					</p>
					<p>
						<strong className="font-bold text-[#262626]">
							Intel&reg; Partner Showcase
						</strong>{" "}
						&ndash; Publish your solutions on the{" "}
						<ChatExternalLink href={LINKS.showcase}>
							Intel&reg; Partner Showcase
						</ChatExternalLink>{" "}
						to connect with enterprise buyers.
					</p>
				</div>
			</div>
		),
	},
	{
		label: "Submit a Support Case",
		response: (
			<div className="space-y-2.5 text-[12.5px] leading-relaxed text-[#333333]">
				<h3 className="font-bold text-[#262626]">
					Expedited Partner Support &amp; Warranty Services
				</h3>
				<p>
					Quickly connect with live Intel support and account personnel
					whenever you need assistance with partner benefits, points, or
					technical inquiries:
				</p>
				<div className="space-y-1">
					<div>
						<ChatExternalLink href={LINKS.customerSupport}>
							Intel Customer Support
						</ChatExternalLink>
					</div>
					<div>
						<ChatExternalLink href={LINKS.awr}>
							Advanced Warranty Replacement (AWR)
						</ChatExternalLink>
					</div>
					<div>
						<ChatExternalLink href={LINKS.aboutMembership}>
							About Membership
						</ChatExternalLink>
					</div>
				</div>
				<p>
					Include your Partner Account ID and case details when submitting a
					request for fastest routing.
				</p>
			</div>
		),
	},
];

function getTimeBasedGreeting(date = new Date()): string {
	const hour = date.getHours();
	if (hour >= 5 && hour < 12) return "Good Morning";
	if (hour >= 12 && hour < 17) return "Good Afternoon";
	if (hour >= 17 && hour < 21) return "Good Evening";
	return "Good Night";
}

/**
 * AskIntelBadgeIcon renders the circular "ASK INTEL" + speech-bubble bot icon
 * modeled after the AskHR badge design.
 */
export function AskIntelBadgeIcon({ className = "size-15" }: { className?: string }) {
	return (
		<svg
			viewBox="0 0 100 100"
			aria-hidden="true"
			className={className}
		>
			{/* White circular background with thick Intel Blue border ring */}
			<circle
				cx="50"
				cy="50"
				r="46"
				fill="#FFFFFF"
				stroke="#0068B5"
				strokeWidth="5.5"
			/>

			{/* Top "ASK" text */}
			<text
				x="50"
				y="44"
				textAnchor="middle"
				fontFamily="'Intel Clear', Arial, Helvetica, sans-serif"
				fontSize="24"
				fontWeight="300"
				letterSpacing="1.5"
				fill="#111827"
			>
				ASK
			</text>

			{/* Bottom-left "INTEL" bold text */}
			<text
				x="14"
				y="67"
				textAnchor="start"
				fontFamily="'Intel Clear', Arial, Helvetica, sans-serif"
				fontSize="16.5"
				fontWeight="900"
				letterSpacing="-0.4"
				fill="#0b2340"
			>
				INTEL
			</text>

			{/* Speech-bubble bot icon on bottom-right (cyan corner dot + dark navy bubble + 2 cyan square eyes) */}
			{/* Cyan dot at top-left of bubble */}
			<rect x="63.5" y="50" width="3.5" height="3.5" rx="0.6" fill="#00C7FD" />

			{/* Dark-navy speech bubble path with bottom-left tail */}
			<path
				d="M 69 51.5 H 85.5 V 67.5 H 71.5 L 65.5 72.5 V 56"
				fill="none"
				stroke="#0b2b5c"
				strokeWidth="2.8"
				strokeLinecap="square"
				strokeLinejoin="miter"
			/>

			{/* Two cyan square bot eyes inside bubble */}
			<rect
				x="69.5"
				y="56.5"
				width="5"
				height="5.5"
				rx="0.8"
				fill="none"
				stroke="#00C7FD"
				strokeWidth="1.7"
			/>
			<rect
				x="76.8"
				y="56.5"
				width="5"
				height="5.5"
				rx="0.8"
				fill="none"
				stroke="#00C7FD"
				strokeWidth="1.7"
			/>
		</svg>
	);
}

/**
 * React wrapper that embeds the Customer Web Client (Embedded Messaging) chat
 * widget and provides the floating "ASK INTEL" chatbot launcher.
 */
export function CustomerWebClientChat({
	orgId,
	deploymentName,
	siteURL,
	scrt2URL,
	language = "en",
	devMode = false,
}: CustomerWebClientChatProps) {
	const [isOpen, setIsOpen] = useState(false);
	const [isExpanded, setIsExpanded] = useState(false);
	const [draft, setDraft] = useState("");
	const [turns, setTurns] = useState<ChatTurn[]>([]);
	const messagesEndRef = useRef<HTMLDivElement>(null);
	const greeting = getTimeBasedGreeting();

	useEffect(() => {
		if (turns.length > 0) {
			messagesEndRef.current?.scrollIntoView?.({ behavior: "smooth", block: "end" });
		}
	}, [turns.length]);

	useEffect(() => {
		if (typeof window === "undefined") return;
		if (
			!orgId ||
			!deploymentName ||
			!siteURL ||
			!scrt2URL ||
			!(orgId.length === 15 || orgId.length === 18)
		) {
			return;
		}

		const win = window as WindowWithCwcProperties;
		const bootstrapSrc = `${siteURL}/assets/js/bootstrap.js`;
		const existing = document.querySelector<HTMLScriptElement>(`script[src="${bootstrapSrc}"]`);
		const script: HTMLScriptElement = existing ?? document.createElement("script");

		const init = () => {
			try {
				if (!win.embeddedservice_bootstrap) return;
				win.embeddedservice_bootstrap.settings.language = language;
				if (devMode) win.embeddedservice_bootstrap.settings.devMode = true;
				win.embeddedservice_bootstrap.init(orgId, deploymentName, siteURL, {
					scrt2URL,
				});
			} catch (err) {
				console.error("Error loading Embedded Messaging: ", err);
			}
		};

		if (existing) {
			if (win.embeddedservice_bootstrap) init();
			else existing.addEventListener("load", init, { once: true });
		} else {
			script.type = "text/javascript";
			script.src = bootstrapSrc;
			script.addEventListener("load", init, { once: true });
			document.body.appendChild(script);
		}

		return () => {
			script.removeEventListener("load", init);
		};
	}, [orgId, deploymentName, siteURL, scrt2URL, language, devMode]);

	const handleSelectTopic = (label: string, response: ReactNode) => {
		setTurns((prev) => [
			...prev,
			{
				id: `turn-${Date.now()}-${prev.length}`,
				query: label,
				timestampLabel: "Just now",
				response,
			},
		]);
	};

	const resolveResponseForQuery = (query: string): ReactNode => {
		const q = query.toLowerCase();
		if (q.includes("opportunity") || q.includes("pipeline")) {
			return QUICK_TOPICS[1].response;
		}
		if (q.includes("training") || q.includes("university") || q.includes("course")) {
			return QUICK_TOPICS[2].response;
		}
		if (q.includes("resource") || q.includes("document") || q.includes("top 10")) {
			return QUICK_TOPICS[3].response;
		}
		if (q.includes("deal") || q.includes("registration")) {
			return QUICK_TOPICS[4].response;
		}
		if (q.includes("tier") || q.includes("membership")) {
			return QUICK_TOPICS[5].response;
		}
		if (q.includes("mdf") || q.includes("fund")) {
			return QUICK_TOPICS[6].response;
		}
		if (q.includes("campaign") || q.includes("marketing")) {
			return QUICK_TOPICS[7].response;
		}
		if (q.includes("support") || q.includes("case") || q.includes("ticket")) {
			return QUICK_TOPICS[8].response;
		}
		return QUICK_TOPICS[0].response;
	};

	const handleSend = (e: FormEvent<HTMLFormElement>) => {
		e.preventDefault();
		const trimmed = draft.trim();
		if (!trimmed) return;
		handleSelectTopic(trimmed, resolveResponseForQuery(trimmed));
		setDraft("");
	};

	return (
		<div className="fixed right-4 bottom-4 z-50 flex flex-col items-end gap-3 sm:right-6 sm:bottom-5">
			{isOpen && (
				<section
					aria-label="Ask Intel - βeta"
					className={`flex max-w-[calc(100vw-2rem)] flex-col overflow-hidden rounded-xl border border-slate-200 bg-white text-[#0b2340] shadow-2xl transition-all ${
						isExpanded
							? "h-[38rem] w-[28rem] sm:w-[32rem]"
							: "h-[33rem] w-[23.5rem] sm:w-[26rem]"
					}`}
				>
					{/* Header: Ask Intel - βeta + resize & minimize controls */}
					<header className="flex items-center justify-between gap-2 border-b border-slate-100 bg-white px-5 py-3.5">
						<h2 className="text-[15px] font-bold tracking-tight text-[#111827]">
							Ask Intel - &beta;eta
						</h2>
						<div className="flex items-center gap-1.5 text-slate-700">
							<button
								type="button"
								onClick={() => setIsExpanded((prev) => !prev)}
								aria-label={isExpanded ? "Restore chat size" : "Expand chat size"}
								title={isExpanded ? "Restore size" : "Expand"}
								className="inline-flex size-7 items-center justify-center rounded-md text-slate-600 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-[#0068b5]"
							>
								{isExpanded ? (
									<Minimize2 aria-hidden="true" className="size-4" />
								) : (
									<Maximize2 aria-hidden="true" className="size-4" />
								)}
							</button>
							<button
								type="button"
								onClick={() => setIsOpen(false)}
								aria-label="Close Ask Intel chat"
								title="Minimize"
								className="inline-flex size-7 items-center justify-center rounded-md text-slate-600 transition-colors hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-[#0068b5]"
							>
								<Minus aria-hidden="true" className="size-4" />
							</button>
						</div>
					</header>

					{/* Scrollable Body */}
					<div className="flex flex-1 flex-col gap-4 overflow-y-auto px-5 py-4">
						{/* Dynamic Time-Based Greeting */}
						<div className="pt-1">
							<p className="text-[22px] leading-snug font-normal text-[#0b2340]">
								{greeting}
							</p>
							<p className="text-[22px] leading-snug font-normal text-[#0b2340]">
								How may I assist you?
							</p>
						</div>

						{/* Quick Prompts Section */}
						<div className="flex flex-col gap-2">
							<div className="flex items-center justify-between gap-2">
								<span className="text-[11px] font-bold tracking-wider text-slate-500 uppercase">
									Quick Prompts
								</span>
								<span className="inline-flex items-center gap-1 rounded-full bg-[#e8f1fb] px-2.5 py-0.5 text-[10.5px] font-semibold text-[#0054ae]">
									Create a Custom Prompt +
								</span>
							</div>
							<div className="grid grid-cols-2 gap-2">
								{QUICK_TOPICS.map((topic) => (
									<button
										key={topic.label}
										type="button"
										onClick={() => handleSelectTopic(topic.label, topic.response)}
										className={`flex items-center justify-between gap-2 rounded-md border border-[#dde7f5] bg-[#f3f6fb] px-3 py-2.5 text-left text-[12px] leading-snug font-bold text-[#0054ae] transition-colors hover:border-[#b9d2f0] hover:bg-[#e5eef9] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#0068b5] ${
											topic.isCustom ? "col-span-2" : "min-h-[3.25rem]"
										}`}
									>
										<span>{topic.label}</span>
										{topic.isCustom && (
											<span
												title="Custom Prompt"
												className="inline-flex size-5 shrink-0 items-center justify-center rounded-full bg-[#0054ae]/15 text-[10px] font-bold text-[#0054ae]"
											>
												C
											</span>
										)}
									</button>
								))}
							</div>
						</div>

						{/* Legal / Privacy Notice */}
						<p className="text-[11.5px] leading-relaxed text-[#4b5563]">
							This Virtual Assistant uses generative AI and answers may be
							inaccurate. By using this feature, you agree that Intel and its
							third-party service provider may record, use, and store the
							contents of this dialog in accordance with{" "}
							<a
								href="https://www.intel.com/content/www/us/en/privacy/intel-privacy-notice.html"
								target="_blank"
								rel="noreferrer"
								className="inline-flex items-center gap-0.5 font-bold text-[#0054ae] underline hover:text-[#003d80]"
							>
								Intel&rsquo;s Privacy Notice
								<ExternalLink
									aria-hidden="true"
									className="ml-0.5 inline size-3 text-slate-600"
								/>
							</a>
							. If you do not consent to these terms, please do not use this
							feature.
						</p>

						{/* Conversation Turns */}
						{turns.length > 0 && (
							<div className="flex flex-col gap-3.5 pt-2">
								{turns.map((turn) => (
									<div key={turn.id} className="flex flex-col gap-2.5">
										{/* User Query Pill + "Just now" timestamp */}
										<div className="flex flex-col items-end">
											<div className="max-w-[85%] rounded-lg bg-[#00162b] px-4 py-2.5 text-[12.5px] font-medium text-white shadow-2xs">
												{turn.query}
											</div>
											<span className="mt-1 text-[11px] text-slate-500">
												{turn.timestampLabel}
											</span>
										</div>

										{/* Assistant Status Message */}
										<div className="rounded-lg bg-[#eef4fb] px-4 py-3 text-[12.5px] leading-relaxed text-[#333333]">
											One moment please &mdash; I&rsquo;m checking for
											information related to your query.
										</div>

										{/* Assistant Rich Response Card */}
										<div className="rounded-lg bg-[#eef4fb] p-4">
											{turn.response}
										</div>
									</div>
								))}
								<div ref={messagesEndRef} />
							</div>
						)}
					</div>

					{/* Input Bar ("Type here") */}
					<form
						onSubmit={handleSend}
						className="border-t border-slate-200 bg-white px-4 py-3"
					>
						<div className="flex items-center rounded-sm border border-slate-400 bg-white px-3 py-1.5 focus-within:border-[#0068b5] focus-within:ring-1 focus-within:ring-[#0068b5]">
							<input
								type="text"
								value={draft}
								onChange={(e) => setDraft(e.target.value)}
								placeholder="Type here"
								aria-label="Type here"
								className="h-7 min-w-0 flex-1 bg-transparent text-xs text-[#0b2340] placeholder:text-slate-500 focus:outline-none"
							/>
							<button
								type="submit"
								aria-label="Send message"
								className="inline-flex size-7 shrink-0 items-center justify-center rounded-sm text-slate-600 transition-colors hover:text-[#0068b5] focus-visible:outline-2 focus-visible:outline-[#0068b5]"
							>
								<Send aria-hidden="true" className="size-4" />
							</button>
						</div>
					</form>
				</section>
			)}

			<button
				type="button"
				onClick={() => setIsOpen((prev) => !prev)}
				aria-label="Ask Intel chat assistant"
				aria-expanded={isOpen}
				title="Ask Intel"
				className="group relative inline-flex items-center justify-center rounded-full bg-white p-0.5 shadow-lg ring-2 ring-white transition-transform hover:scale-105 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#0068b5]"
			>
				<AskIntelBadgeIcon className="size-15 sm:size-16" />
			</button>
		</div>
	);
}

export default CustomerWebClientChat;
