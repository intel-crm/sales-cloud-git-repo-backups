import { useEffect, useRef, useState } from "react";
import { Link, useParams, useNavigate } from "react-router";
import { createDataSDK } from "@salesforce/platform-sdk";
import {
	AlertCircle,
	ArrowLeft,
	ArrowRight,
	Award,
	BriefcaseBusiness,
	Building2,
	ChevronDown,
	ChevronRight,
	Clock,
	FileQuestion,
	FileText,
	Globe,
	Layers,
	MapPin,
	Phone as PhoneIcon,
	Printer,
	ShieldCheck,
	UserCheck,
	Users,
	type LucideIcon,
} from "lucide-react";
import GET_ACCOUNT_DETAIL from "../api/account/query/getAccountDetail.graphql?raw";
import { Alert, AlertTitle, AlertDescription } from "../components/ui/alert";
import { Button } from "../components/ui/button";
import { Card, CardContent } from "../components/ui/card";
import { fieldValue, getAddressFieldLines } from "../utils/accountFields";
import {
	Collapsible,
	CollapsibleTrigger,
	CollapsibleContent,
} from "../components/ui/collapsible";
import { Skeleton } from "../components/ui/skeleton";
import { useAsyncData } from "../hooks/useAsyncData";
import { useOptionalPartnerAccount } from "../features/partner/context/PartnerAccountContext";
import {
	DUMMY_BENEFITS_SUMMARY,
	DUMMY_CONTACTS,
	DUMMY_POINTS_SUMMARY,
	fetchPartnerBenefitsData,
	fetchPartnerContacts,
	fetchPartnerPointsData,
} from "../api/partnerPortalData";

/** A uiapi scalar field as returned with `@optional { value displayValue }`. Typed locally to avoid a generated-types dependency. */
type FieldValue = { value?: unknown; displayValue?: string | null } | null;
type NameHolder = { Name?: FieldValue } | null;

interface AccountNode {
	Id?: string;
	Name?: FieldValue;
	Owner?: NameHolder;
	Phone?: FieldValue;
	Fax?: FieldValue;
	Parent?: NameHolder;
	Website?: FieldValue;
	Type?: FieldValue;
	NumberOfEmployees?: FieldValue;
	Industry?: FieldValue;
	AnnualRevenue?: FieldValue;
	Description?: FieldValue;
	BillingStreet?: FieldValue;
	BillingCity?: FieldValue;
	BillingState?: FieldValue;
	BillingPostalCode?: FieldValue;
	BillingCountry?: FieldValue;
	ShippingStreet?: FieldValue;
	ShippingCity?: FieldValue;
	ShippingState?: FieldValue;
	ShippingPostalCode?: FieldValue;
	ShippingCountry?: FieldValue;
	CreatedBy?: NameHolder;
	CreatedDate?: FieldValue;
	LastModifiedBy?: NameHolder;
	LastModifiedDate?: FieldValue;
	Core_IPA_Badge_Tier__c?: FieldValue;
	Core_IPA_Partner_Role__c?: FieldValue;
}

interface GetAccountDetailResponse {
	uiapi?: {
		query?: {
			Account?: {
				edges?: Array<{ node?: AccountNode } | null> | null;
			} | null;
		} | null;
	} | null;
}

const DUMMY_ACCOUNT_NAMES: Record<string, string> = {
	"0018A00000UdIm5QAF": "Test_DISTI_Account",
	"0018A00000testIntel": "testIntel Account",
	"0018A00000eahChild": "EAH Child",
	"0018A00000demoIntel2": "Demo Intel account 2",
	"0018A00000demoIntel1": "Demo Intel account 1",
};

function buildDummyAccountNode(recordId: string): AccountNode {
	const resolvedName = DUMMY_ACCOUNT_NAMES[recordId] ?? "Test_DISTI_Account";
	return {
		Id: recordId,
		Name: { value: resolvedName, displayValue: resolvedName },
		Owner: {
			Name: {
				value: "User15912703361908692766",
				displayValue: "User15912703361908692766",
			},
		},
		Phone: null,
		Fax: null,
		Parent: null,
		Website: null,
		Type: { value: "Distributor", displayValue: "Distributor" },
		NumberOfEmployees: null,
		Industry: { value: "Technology", displayValue: "Technology" },
		AnnualRevenue: null,
		Description: null,
		BillingStreet: null,
		BillingCity: null,
		BillingState: null,
		BillingPostalCode: null,
		BillingCountry: null,
		ShippingStreet: null,
		ShippingCity: null,
		ShippingState: null,
		ShippingPostalCode: null,
		ShippingCountry: null,
		CreatedBy: {
			Name: {
				value: "User15912703361908692766",
				displayValue: "User15912703361908692766",
			},
		},
		CreatedDate: {
			value: "2020-07-14T21:25:00.000Z",
			displayValue: "7/14/2020, 9:25 PM",
		},
		LastModifiedBy: {
			Name: {
				value: "User16373214730677759040",
				displayValue: "User16373214730677759040",
			},
		},
		LastModifiedDate: {
			value: "2022-11-30T23:39:00.000Z",
			displayValue: "11/30/2022, 11:39 PM",
		},
		Core_IPA_Badge_Tier__c: {
			value: "Titanium",
			displayValue: "Titanium",
		},
		Core_IPA_Partner_Role__c: {
			value: "Distributor",
			displayValue: "Distributor",
		},
	};
}

async function fetchAccountDetail(recordId: string): Promise<AccountNode | null | undefined> {
	const data = await createDataSDK();
	const result = await data.graphql!.query<GetAccountDetailResponse, { id: string }>({
		query: GET_ACCOUNT_DETAIL,
		variables: { id: recordId },
	});

	if (result.errors?.length) {
		throw new Error(result.errors.map((e) => e.message).join("; "));
	}

	return result.data?.uiapi?.query?.Account?.edges?.[0]?.node;
}

export default function AccountObjectDetail() {
	const { recordId } = useParams();
	const navigate = useNavigate();
	const mainRef = useRef<HTMLElement>(null);
	const [completionAnnouncement, setCompletionAnnouncement] = useState("");
	const partner = useOptionalPartnerAccount();
	const isAuthFailed = Boolean(
		partner?.isAuthFallback || partner?.error?.includes("Authentication failed"),
	);

	const {
		data: rawAccount,
		loading,
		error: rawError,
	} = useAsyncData(
		async () =>
			isAuthFailed
				? buildDummyAccountNode(recordId ?? "0018A00000UdIm5QAF")
				: fetchAccountDetail(recordId!),
		[recordId, isAuthFailed],
	);

	const useFallback = Boolean(
		isAuthFailed || rawError?.includes("Authentication failed"),
	);
	const account = useFallback
		? buildDummyAccountNode(recordId ?? "0018A00000UdIm5QAF")
		: rawAccount;
	const error = useFallback ? null : rawError;

	const pageTitle = loading
		? "Loading Account | MyApp"
		: error
			? "Error | MyApp"
			: account
				? `${fieldValue(account.Name) ?? "Account"} | MyApp`
				: "Account Not Found | MyApp";

	useEffect(() => {
		if (loading) {
			setCompletionAnnouncement("");
			return;
		}
		const main = mainRef.current;
		const heading = main?.querySelector<HTMLElement>("h1");
		if (heading) {
			const active = document.activeElement;
			if (active && active !== document.body && !main?.contains(active)) {
				setCompletionAnnouncement(heading.textContent ?? "");
				return;
			}
			setCompletionAnnouncement("");
			if (!heading.hasAttribute("tabindex")) heading.setAttribute("tabindex", "-1");
			heading.focus();
		}
	}, [loading, error, account, recordId]);

	return (
		<main
			ref={mainRef}
			className="flex w-full shrink-0 grow flex-col gap-4 px-6 pt-5 pb-16 sm:px-8 lg:px-12 xl:px-16"
		>
			<title>{pageTitle}</title>
			<div role="status" aria-live="polite" className="sr-only">
				{loading ? "Loading account" : completionAnnouncement}
			</div>
			{loading && <AccountDetailSkeleton />}
			{error && <AccountDetailError onBack={() => navigate(-1)} />}
			{!loading && !error && !account && <AccountDetailNotFound onBack={() => navigate(-1)} />}
			{!loading && !error && account && (
				<AccountDetailContent
					account={account}
					recordId={recordId}
					onBack={() => navigate(-1)}
				/>
			)}
		</main>
	);
}

function AccountDetailContent({
	account,
	recordId,
	onBack,
}: {
	account: AccountNode;
	recordId?: string;
	onBack: () => void;
}) {
	const partner = useOptionalPartnerAccount();
	const partnerAccount =
		partner?.account?.kind === "ready" ? partner.account : null;

	const billingAddress = getAddressFieldLines({
		street: fieldValue(account.BillingStreet),
		city: fieldValue(account.BillingCity),
		state: fieldValue(account.BillingState),
		postalCode: fieldValue(account.BillingPostalCode),
		country: fieldValue(account.BillingCountry),
	});

	const shippingAddress = getAddressFieldLines({
		street: fieldValue(account.ShippingStreet),
		city: fieldValue(account.ShippingCity),
		state: fieldValue(account.ShippingState),
		postalCode: fieldValue(account.ShippingPostalCode),
		country: fieldValue(account.ShippingCountry),
	});

	const accountName = fieldValue(account.Name) ?? "Unnamed Account";
	const ownerName = fieldValue(account.Owner?.Name);
	const recordPartnerRoles = fieldValue(account.Core_IPA_Partner_Role__c);
	const accountType =
		fieldValue(account.Type) ??
		recordPartnerRoles?.split(";")[0]?.trim() ??
		partnerAccount?.roles?.[0] ??
		"Partner Account";
	const badgeTier =
		fieldValue(account.Core_IPA_Badge_Tier__c) ??
		partnerAccount?.badgeTier ??
		"Verified";
	const isAuthFailed = Boolean(
		partner?.isAuthFallback || partner?.error?.includes("Authentication failed"),
	);
	const targetAccountId = account.Id ?? recordId ?? "0018A00000UdIm5QAF";
	const { data: relatedData } = useAsyncData(
		async () => {
			if (isAuthFailed) {
				return {
					points: DUMMY_POINTS_SUMMARY,
					benefits: DUMMY_BENEFITS_SUMMARY,
					contacts: DUMMY_CONTACTS,
				};
			}
			const [pts, ben, cnt] = await Promise.allSettled([
				fetchPartnerPointsData(targetAccountId),
				fetchPartnerBenefitsData(targetAccountId),
				fetchPartnerContacts(targetAccountId),
			]);
			return {
				points: pts.status === "fulfilled" ? pts.value : DUMMY_POINTS_SUMMARY,
				benefits:
					ben.status === "fulfilled" ? ben.value : DUMMY_BENEFITS_SUMMARY,
				contacts:
					cnt.status === "fulfilled" ? cnt.value.contacts : DUMMY_CONTACTS,
			};
		},
		[targetAccountId, isAuthFailed],
	);
	const industry = fieldValue(account.Industry);
	const employees = fieldValue(account.NumberOfEmployees);
	const annualRevenue = fieldValue(account.AnnualRevenue);
	const createdDate = fieldValue(account.CreatedDate);
	const lastModifiedDate = fieldValue(account.LastModifiedDate);
	const createdBySummary =
		[fieldValue(account.CreatedBy?.Name), createdDate]
			.filter(Boolean)
			.join(" ") || null;
	const lastModifiedBySummary =
		[fieldValue(account.LastModifiedBy?.Name), lastModifiedDate]
			.filter(Boolean)
			.join(" ") || null;

	return (
		<div className="flex flex-col gap-4">
			{/* Hero Header Banner */}
			<div className="flex flex-wrap items-center justify-between gap-4 rounded-xl border border-sky-100 bg-linear-to-r from-[#0b2340] via-[#103158] to-[#174a8b] px-5 py-4 text-white shadow-sm">
				<div className="flex min-w-0 items-center gap-3.5">
					<span className="flex size-11 shrink-0 items-center justify-center rounded-xl bg-sky-400/20 text-sky-300 ring-1 ring-sky-300/30">
						<Building2 aria-hidden="true" className="size-5.5" />
					</span>
					<div className="min-w-0">
						<div className="mb-1 flex flex-wrap items-center gap-2">
							<span className="inline-flex items-center gap-1 rounded-full bg-sky-400/20 px-2.5 py-0.5 text-[11px] font-semibold text-sky-200 ring-1 ring-sky-300/30">
								<ShieldCheck aria-hidden="true" className="size-3" />
								Partner Account Profile
							</span>
							{(account.Id || recordId) && (
								<span className="rounded-md bg-white/10 px-2 py-0.5 font-mono text-[11px] text-sky-100/90">
									ID: {account.Id ?? recordId}
								</span>
							)}
						</div>
						<h1 className="truncate text-[clamp(1.25rem,1.6vw,1.65rem)] leading-tight font-bold tracking-tight">
							Account: {accountName}
						</h1>
						<p className="mt-0.5 text-xs text-sky-100/85 sm:text-sm">
							View organization ownership, partner classification, registered
							addresses, and system audit details.
						</p>
					</div>
				</div>

				<div className="flex flex-wrap items-center gap-2">
					<button
						type="button"
						onClick={onBack}
						className="inline-flex items-center gap-1.5 rounded-lg border border-white/25 bg-white/10 px-3 py-1.5 text-xs font-semibold text-white transition-colors hover:bg-white/20 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white"
					>
						<ArrowLeft aria-hidden="true" className="size-3.5" />
						Back
					</button>
					<Link
						to="/opportunities"
						className="inline-flex items-center gap-1.5 rounded-lg bg-[#0068b5] px-3.5 py-1.5 text-xs font-semibold text-white shadow-xs transition-colors hover:bg-[#005494] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white"
					>
						View Opportunities
						<ArrowRight aria-hidden="true" className="size-3.5" />
					</Link>
				</div>
			</div>

			{/* 4 Executive Summary KPI Cards */}
			<div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-4">
				<Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
					<div className="flex items-center justify-between gap-2">
						<span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
							Account Owner
						</span>
						<span className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-sky-100 text-[#0068b5]">
							<UserCheck aria-hidden="true" className="size-4" />
						</span>
					</div>
					<div className="min-w-0">
						<p
							className="truncate text-base font-bold tracking-tight text-[#0b2340]"
							title={ownerName ?? undefined}
						>
							{ownerName ?? "Unassigned"}
						</p>
						<p className="mt-1 text-xs text-slate-500">
							Assigned partner account representative
						</p>
					</div>
				</Card>

				<Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
					<div className="flex items-center justify-between gap-2">
						<span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
							Partner Standing
						</span>
						<span className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-amber-100 text-amber-600">
							<Award aria-hidden="true" className="size-4" />
						</span>
					</div>
					<div>
						<p className="text-base font-bold tracking-tight text-[#0b2340]">
							{badgeTier} &middot;{" "}
							<span className="font-semibold text-[#0068b5]">
								{accountType}
							</span>
						</p>
						<p className="mt-1 text-xs text-slate-500">
							Intel&reg; Partner Alliance tier &amp; role
						</p>
					</div>
				</Card>

				<Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
					<div className="flex items-center justify-between gap-2">
						<span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
							Industry &amp; Scale
						</span>
						<span className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-violet-100 text-violet-700">
							<Layers aria-hidden="true" className="size-4" />
						</span>
					</div>
					<div>
						<p className="truncate text-base font-bold tracking-tight text-[#0b2340]">
							{industry ?? "Partner Ecosystem"}
						</p>
						<p className="mt-1 text-xs text-slate-500">
							{employees
								? `${employees} employees`
								: annualRevenue
									? `Revenue: ${annualRevenue}`
									: "Enterprise partner account"}
						</p>
					</div>
				</Card>

				<Card className="justify-between gap-2 rounded-xl border border-slate-200/80 bg-white px-4 py-3.5 text-[#0b2340] shadow-xs">
					<div className="flex items-center justify-between gap-2">
						<span className="text-xs font-semibold tracking-wider text-slate-500 uppercase">
							Last Updated
						</span>
						<span className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-emerald-100 text-emerald-700">
							<Clock aria-hidden="true" className="size-4" />
						</span>
					</div>
					<div>
						<p className="truncate text-base font-bold tracking-tight text-[#0b2340]">
							{lastModifiedDate ?? createdDate ?? "Active"}
						</p>
						<p className="mt-1 truncate text-xs text-slate-500">
							{createdDate ? `Created ${createdDate}` : "Synchronized with CRM"}
						</p>
					</div>
				</Card>
			</div>

			{/* Primary Account Overview Card */}
			<Card className="gap-3 rounded-xl border border-slate-200/90 bg-white py-4 text-[#0b2340] shadow-xs">
				<div className="flex items-center justify-between gap-2 border-b border-slate-100 px-5 pb-3">
					<div className="flex items-center gap-2.5">
						<span
							aria-hidden="true"
							className="inline-block h-4 w-1 rounded-full bg-[#0068b5]"
						/>
						<div>
							<h2 className="text-sm font-bold text-[#0b2340]">
								Core Account Details
							</h2>
							<p className="text-[11px] text-slate-500">
								Primary account identity, ownership, hierarchy, and contact
								channels
							</p>
						</div>
					</div>
				</div>
				<CardContent className="space-y-3 px-5 pt-1">
					<FieldRow>
						<FieldItem label="Account Owner" icon={UserCheck}>
							{ownerName}
						</FieldItem>
						<FieldItem label="Phone" icon={PhoneIcon}>
							<TelephoneField value={fieldValue(account.Phone)} />
						</FieldItem>
					</FieldRow>
					<FieldRow>
						<FieldItem label="Account Name" icon={Building2}>
							{fieldValue(account.Name)}
						</FieldItem>
						<FieldItem label="Fax" icon={Printer}>
							<TelephoneField value={fieldValue(account.Fax)} />
						</FieldItem>
					</FieldRow>
					<FieldRow>
						<FieldItem label="Parent Account" icon={Layers}>
							{fieldValue(account.Parent?.Name)}
						</FieldItem>
						<FieldItem label="Website" icon={Globe}>
							{fieldValue(account.Website)}
						</FieldItem>
					</FieldRow>
				</CardContent>
			</Card>

			{/* Two-Column Grid for Additional Information & Address/System Information */}
			<div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
				<Section
					title="Additional Information"
					subtitle="Classification, headcount, industry vertical, and description"
					icon={BriefcaseBusiness}
				>
					<FieldRow>
						<FieldItem label="Type" icon={BriefcaseBusiness}>
							{fieldValue(account.Type)}
						</FieldItem>
						<FieldItem label="Employees" icon={Users}>
							{fieldValue(account.NumberOfEmployees)}
						</FieldItem>
					</FieldRow>
					<FieldRow>
						<FieldItem label="Industry" icon={Layers}>
							{fieldValue(account.Industry)}
						</FieldItem>
						<FieldItem label="Annual Revenue" icon={Award}>
							{fieldValue(account.AnnualRevenue)}
						</FieldItem>
					</FieldRow>
					<dl>
						<FieldItem label="Description" icon={FileText}>
							{fieldValue(account.Description)}
						</FieldItem>
					</dl>
				</Section>

				<div className="flex flex-col gap-4">
					<Section
						title="Address Information"
						subtitle="Registered billing and shipping locations"
						icon={MapPin}
					>
						<FieldRow>
							<FieldItem label="Billing Address" icon={MapPin}>
								{billingAddress
									? billingAddress.map((line, i) => <div key={i}>{line}</div>)
									: null}
							</FieldItem>
							<FieldItem label="Shipping Address" icon={MapPin}>
								{shippingAddress
									? shippingAddress.map((line, i) => <div key={i}>{line}</div>)
									: null}
							</FieldItem>
						</FieldRow>
					</Section>

					<Section
						title="System Information"
						subtitle="Record creation and last modification audit trail"
						icon={ShieldCheck}
					>
						<FieldRow>
							<FieldItem label="Created By" icon={Clock}>
								{createdBySummary}
							</FieldItem>
							<FieldItem label="Last Modified By" icon={Clock}>
								{lastModifiedBySummary}
							</FieldItem>
						</FieldRow>
					</Section>
				</div>
			</div>

			{/* Live Partner Program Benefits, Points & Contacts Section */}
			{relatedData && (
				<Section
					title="Partner Program Benefits, Points & Contacts"
					subtitle="Connected records from PRM_AccountBenefitAssociation__c, PRM_Points_Data__c, and Contact"
					icon={Award}
				>
					<FieldRow>
						<FieldItem label="IPA Badge Tier" icon={Award}>
							{badgeTier}
						</FieldItem>
						<FieldItem label="IPA Partner Roles" icon={ShieldCheck}>
							{recordPartnerRoles ??
								partnerAccount?.roles?.join("; ") ??
								accountType}
						</FieldItem>
					</FieldRow>
					<FieldRow>
						<FieldItem label="Points Balance" icon={Award}>
							<span className="flex items-center justify-between gap-2">
								<span>
									{relatedData.points.totalBalance.toLocaleString("en-US")} pts
									({relatedData.points.records.length} ledger records)
								</span>
								<Link
									to="/points-rewards"
									className="text-xs font-semibold text-[#0068b5] hover:underline"
								>
									View points &rarr;
								</Link>
							</span>
						</FieldItem>
						<FieldItem label="Active Benefits" icon={Layers}>
							<span className="flex items-center justify-between gap-2">
								<span>
									{relatedData.benefits.activeCount} active of{" "}
									{relatedData.benefits.totalCount} benefit associations
								</span>
								<Link
									to="/benefits"
									className="text-xs font-semibold text-[#0068b5] hover:underline"
								>
									Manage benefits &rarr;
								</Link>
							</span>
						</FieldItem>
					</FieldRow>
					{relatedData.contacts.length > 0 && (
						<div className="pt-1">
							<p className="mb-2 text-[11px] font-semibold tracking-wider text-slate-500 uppercase">
								Linked Contacts ({relatedData.contacts.slice(0, 4).length})
							</p>
							<div className="grid grid-cols-1 gap-2.5 sm:grid-cols-2 xl:grid-cols-4">
								{relatedData.contacts.slice(0, 4).map((c) => (
									<div
										key={c.id}
										className="rounded-lg border border-slate-200/80 bg-slate-50/70 px-3 py-2 text-xs"
									>
										<p className="truncate font-bold text-[#0b2340]">
											{c.name}
										</p>
										<p className="truncate text-[11px] text-[#0068b5]">
											{c.title ?? "Partner Contact"}
										</p>
										{c.email && (
											<p className="mt-0.5 truncate text-[11px] text-slate-500">
												{c.email}
											</p>
										)}
									</div>
								))}
							</div>
						</div>
					)}
				</Section>
			)}
		</div>
	);
}

function TelephoneField({ value }: { value?: string | null }) {
	if (!value) return null;
	return (
		<a
			href={`tel:${value}`}
			className="font-semibold text-[#0068b5] underline hover:text-[#004c87]"
		>
			{value}
		</a>
	);
}

function FieldItem({
	label,
	icon: Icon,
	children,
}: {
	label: string;
	icon?: LucideIcon;
	children: React.ReactNode;
}) {
	return (
		<div className="rounded-lg border border-slate-200/80 bg-slate-50/60 px-3.5 py-2.5 transition-colors hover:border-sky-200/80 hover:bg-sky-50/30">
			<dt className="flex items-center gap-1.5 text-[11px] font-semibold tracking-wider text-slate-500 uppercase">
				{Icon && (
					<Icon aria-hidden="true" className="size-3.5 shrink-0 text-[#0068b5]" />
				)}
				{label}
			</dt>
			<dd className="mt-1 break-words text-xs font-semibold text-[#0b2340] sm:text-[13px]">
				{children ?? "—"}
			</dd>
		</div>
	);
}

function FieldRow({ children }: { children: React.ReactNode }) {
	return (
		<dl className="grid grid-cols-1 gap-3 sm:grid-cols-2">{children}</dl>
	);
}

function Section({
	title,
	subtitle,
	icon: Icon,
	children,
}: {
	title: string;
	subtitle?: string;
	icon?: LucideIcon;
	children: React.ReactNode;
}) {
	const [open, setOpen] = useState(true);
	return (
		<Card className="gap-0 rounded-xl border border-slate-200/90 bg-white py-3.5 text-[#0b2340] shadow-xs">
			<Collapsible open={open} onOpenChange={setOpen}>
				<h2 className="px-5">
					<CollapsibleTrigger className="flex w-full cursor-pointer items-center justify-between gap-3 rounded-md py-1 text-left focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#0068b5]">
						<span className="flex items-center gap-2.5">
							{Icon && (
								<span className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-sky-100 text-[#0068b5]">
									<Icon aria-hidden="true" className="size-4" />
								</span>
							)}
							<span>
								<span className="block text-sm font-bold text-[#0b2340]">
									{title}
								</span>
								{subtitle && (
									<span className="block text-[11px] font-normal text-slate-500">
										{subtitle}
									</span>
								)}
							</span>
						</span>
						<span className="inline-flex size-7 shrink-0 items-center justify-center rounded-md bg-slate-100 text-slate-600 transition-colors hover:bg-slate-200/70">
							{open ? (
								<ChevronDown aria-hidden="true" className="size-4" />
							) : (
								<ChevronRight aria-hidden="true" className="size-4" />
							)}
						</span>
					</CollapsibleTrigger>
				</h2>
				<CollapsibleContent>
					<div className="mt-3 space-y-3 border-t border-slate-100 px-5 pt-3.5">
						{children}
					</div>
				</CollapsibleContent>
			</Collapsible>
		</Card>
	);
}

function AccountDetailError({ onBack }: { onBack: () => void }) {
	return (
		<>
			{/* Completion is announced by heading focus or the persistent status. */}
			<Alert variant="destructive" role={undefined}>
				<AlertCircle aria-hidden="true" />
				<AlertTitle>
					<h1>Failed to load account</h1>
				</AlertTitle>
				<AlertDescription>
					Something went wrong while loading this account. Please try again later.
				</AlertDescription>
			</Alert>
			<div className="mt-4 flex gap-3">
				<Button variant="outline" onClick={onBack}>
					<span aria-hidden="true">←</span> Back
				</Button>
				<Button variant="outline" onClick={() => window.location.reload()}>
					Retry
				</Button>
			</div>
		</>
	);
}

function AccountDetailNotFound({ onBack }: { onBack: () => void }) {
	return (
		<Card className="rounded-xl border border-slate-200/90 bg-white text-[#0b2340] shadow-xs">
			<CardContent className="flex flex-col items-center justify-center py-16 text-center">
				<FileQuestion aria-hidden="true" className="size-12 text-muted-foreground mb-4" />
				<h1 className="text-lg font-semibold mb-1">Account not found</h1>
				<p className="text-sm text-muted-foreground mb-6">
					The account you're looking for doesn't exist or may have been deleted.
				</p>
				<Button variant="outline" onClick={onBack}>
					<span aria-hidden="true">←</span> Go back
				</Button>
			</CardContent>
		</Card>
	);
}

function AccountDetailSkeleton() {
	return (
		<div className="space-y-4">
			<Skeleton className="h-24 w-full rounded-xl" />
			<div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-4">
				<Skeleton className="h-24 rounded-xl" />
				<Skeleton className="h-24 rounded-xl" />
				<Skeleton className="h-24 rounded-xl" />
				<Skeleton className="h-24 rounded-xl" />
			</div>

			<Card className="rounded-xl border border-slate-200/90 bg-white">
				<CardContent className="space-y-6 pt-6">
					<div className="space-y-4">
						<SkeletonFieldRow />
						<SkeletonFieldRow />
						<SkeletonFieldRow />
					</div>
					<SkeletonSection />
					<SkeletonSection />
				</CardContent>
			</Card>
		</div>
	);
}

function SkeletonField() {
	return (
		<div>
			<Skeleton className="h-4 w-24 mb-1.5" />
			<Skeleton className="h-5 w-40" />
		</div>
	);
}

function SkeletonFieldRow() {
	return (
		<div className="grid grid-cols-2 gap-x-8 gap-y-4">
			<SkeletonField />
			<SkeletonField />
		</div>
	);
}

function SkeletonSection() {
	return (
		<div className="space-y-4">
			<Skeleton className="h-7 w-48 py-2" />
			<SkeletonFieldRow />
			<SkeletonFieldRow />
		</div>
	);
}
