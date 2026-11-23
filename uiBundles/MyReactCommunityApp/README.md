# React External App

A React template for customer-facing apps on the Salesforce platform. Includes authentication, global search, and an Experience Cloud site container. Built with React, Vite, TypeScript, and Tailwind/shadcn.

For project-level details (metadata, deploy), see the [project README](../../../../../../README.md).

## Prerequisites

```bash
npm install
```

## Run (development)

```bash
npm run dev
```

Starts the Vite dev server (default: http://localhost:5173).

## Build

```bash
npm run build
```

Writes the production bundle to `dist/` inside the UI Bundle folder.

## Test

```bash
npm test
```

Runs the unit test suite (Vitest).

## Left navigation

The dark-blue top bar links Home through the Intel logo and Partner Experience
label. The logo is referenced from Intel's public site and displayed in white;
the host must permit `https://www.intel.com` images through its CSP.

Global search sits immediately after the Partner Experience branding in the
header on every page, replacing the Home-only search. On screens narrower
than 768 CSS pixels it moves to a full-width second row. Search still requires
at least three characters and opens the existing search results route in the
main body area, retaining the Salesforce deployment base path. The header has
only the search input, with no Search button: press Enter (or the mobile
keyboard's Search action) to submit. Typing alone does not start a search.
The reusable `GlobalSearchBox` retains its button by default; the header uses
`hideSubmitButton` to omit it.
Submitting another term from Search Results refreshes the existing page without
a reload. Fresh header submissions reset the prior scope, filters, sorting,
and pagination; browser Back/Forward restores the URL's query and source
settings. The header reflects the submitted URL query without searching as
you type. Pending URL updates from the previous search are cancelled.
The search results route sets `showSearchBar={false}` to avoid a second query
input in the body. Source scope selection, results, filters, sorting, and
pagination remain in the body.

The page and browser title are **Search Results**. Account, Contact, and
Opportunity matches are grouped into separate object tables with gray column
headers. Columns follow each source's configured `displayFields`, including
relationship subfields, and prefer Salesforce display values. Missing values
show a dash; configured record links remain on the first column. Only fields
listed in `sortBy` have sortable headers; these use the existing server-side
sort and pagination, not a local-only reorder. Tables scroll horizontally on
narrow screens. CMS content keeps its existing renderer. Other consumers of
`Search` retain the list layout unless they opt into `resultLayout="table"`.

The app layout includes a dark-blue left navigation panel with a Home icon and
link. Home is highlighted only on the Home route. On narrow screens the panel
stacks above the page content. The existing header menu and IGHF are unchanged.

Points & Rewards links to `/points-rewards` from the sidebar and header menu.
The page displays "Coming soon...Page under Construction" and highlights its
sidebar item while active. Links retain the Salesforce deployment base path.

## Home welcome and opportunity count

Home starts with a light-blue welcome banner, partner-benefit icons, and the
message "Your partner journey, all in one place." Signed-in users see
"Welcome back, {name}!" using the same display name and shared authentication
context as the persona menu, without another user request. Guests and users
whose name is unavailable see "Welcome to Partner Experience!" instead.
Authentication loading and failure states are shown explicitly; the dashboard
remains available below the banner. The greeting uses the full supplied display
name rather than guessing a first name. The banner uses CSS styling and icons,
not an external stock photo.

The Home page shows an Opportunity Pipeline card using the exact same
Salesforce-formatted total pipeline value as the chart summary below it. Both
share one aggregate request/state, not a record count or a first-page sum.
Partner users see visible records belonging to their resolved Account;
non-partners see all opportunities they can access. The Opportunities page still
displays its Total Opportunities count and up to 10 records; this limit does not
cap its count or the pipeline value. Loading and query errors are shown instead
of a misleading zero. A valid empty pipeline shows a zero value.

The Home overview uses a responsive grid of five cards styled with colored
icons: Total Rebates (Points), Partner Tier, Training Credits, Warranty, and
Opportunity Pipeline. Rebates, training, and warranty display explicitly labeled
sample data, with their actions disabled until those features are connected. Total
Pipeline shares the chart's live aggregate query and links to the Opportunities page.
The compact grid shows all five cards in one row at desktop widths (1024 CSS
pixels and above), two columns on tablets, and one column on mobile. Icons
stack above the text on narrower desktop windows to keep the cards readable.
Home does not display the Opportunity Pipeline list below the cards; use
View opportunities or the sidebar to open the Opportunities page.
Sample cards remain visible if the pipeline query is loading or fails.

### Opportunity stage chart

A compact Opportunity Pipeline card appears below the five Home cards and above
the Opportunities list. Blue gradient bars show stages, with Closed Won in green.
Amounts appear above the bars and record counts below each stage. The right-hand
summary shows the total pipeline value and total opportunities across all stages
(not an open-only count). View all and View opportunities open the Opportunities
page. No quarterly percentage is displayed.
The X-axis shows stages and the Y-axis shows the sum of Amount for each stage.
GraphQL `uiapi.aggregate.Opportunity` groups by `StageName`, sums `Amount`, and
counts `Id` per stage. An ungrouped aggregate supplies the formatted pipeline sum
server-side with the same partner/non-partner scope as the live count/list, independently of
the list's first ten records. Aggregate pages are followed until complete.
Salesforce supplies exact formatted stage and summary amounts; currency symbols
and conversions are not hardcoded. Null sums display as zero. Negative amounts
extend below zero and use red bars.
The chart scrolls horizontally on narrow screens and includes hover/focus
amount labels plus an expandable table of exact totals. Loading, no records,
and query/access errors have explicit states independent of the list and cards.

### Partner Tier

Partner Tier uses GraphQL to read `IsPartner` and `AccountId` for the signed-in
user. A shared account provider resolves this once for the card, opportunity
count/list, and chart on both pages. Users with `IsPartner=true` use their linked
Account; signed-in non-partners use Account `0018A00000UdIm5QAF` for tier details
only, without restricting their accessible opportunities. The selected Account is queried for
`Core_IPA_Badge_Tier__c` and `Core_IPA_Partner_Role__c`. The badge replaces the
sample tier. The first nonempty semicolon-separated role appears on the card;
hover over it to see the full role list, also exposed to screen readers.
View account details opens the selected Account. If the partner User/Account
lookup fails, the linked Account ID is missing, or either the badge tier or roles
is blank, resolution falls back to `0018A00000UdIm5QAF`. The failure is logged and
a visible default-account notice is displayed. The default lookup is attempted
once; if it fails, errors stay visible and no opportunity requests are issued.
Blank default-account fields retain Not provided / No partner roles states.
For partner users (including fallback), the list, live count, stage sums/counts,
and overall pipeline sum use `where: { AccountId: { eq: accountId } }` for the
resolved Account. For verified non-partners, all four use `where: null` to retain
all records accessible to them. An unreadable partner status uses the scoped
default-Account fallback, not an unrestricted opportunity query.
No opportunity requests run until resolution completes. User/account changes
clear the displayed data while loading and discard late responses.
Guests see Not applicable, are prompted to sign in for opportunities, and do
not trigger Account or opportunity queries. Global search is unchanged.
Queries use the current user's Salesforce permissions; this does not change
profiles, sharing, or field-level access.

## Intel global header and footer (IGHF)

`IghfHeader` and `IghfFooter` are mounted in `AppLayout`: `IghfHeader` sits above
the existing app navigation, and `IghfFooter` sits at the bottom of the DOM
after `<Outlet />`. They use the Partnercenter Unified Community configuration
read from the `crmdevipa` sandbox: the `recode50header` and `recode50footer`
mount points, `no-animate` class, `https://www.intel.com/ighf/50recode.2/js/headerchooser.js`
loader, and `INTELNAV.renderSettings` with version `2.0 - 03/12/2017 08:00:00`,
`textDirection: "ltr"` and `OutputId: "default"`.

The culture comes from `SFDC_ENV.language`, then the document language, with
the original IntelHeader language mappings. Authenticated users get the
source component's empty `INTELNAV.dashboard` setting. Existing application
navigation, authentication, and route handling are unchanged. The hosted Intel
code is referenced, not copied into the bundle.

The hosting site's CSP must permit the Intel loader and its downstream
scripts, styles, images, fonts, and connections. Configure these through the
normal Salesforce Trusted URLs/CSP process after inspecting the actual
blocked origins; this change does not relax CSP or change any org settings.
Loader errors and a 20-second render timeout display an alert without
blocking app navigation. Verify the live header with the intended site
origin and representative guest/authenticated users before deployment.
Local tests use simulated vendor rendering and do not establish that the
hosted header works under a particular Salesforce site's CSP.
The production bundle was also previewed locally with the real Intel loader:
the header rendered and stayed mounted with a single loader after navigating
from Home to Search. Salesforce-authenticated behavior still requires site
validation; a localhost preview has no Salesforce session.
