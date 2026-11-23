import { cleanup, fireEvent, render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter, Route, Routes, useLocation } from "react-router";
import { afterEach, describe, expect, it, vi } from "vitest";
import AppLayout from "./appLayout";
import OpportunitiesPage from "./pages/Opportunities";
import PointsRewardsPage from "./pages/PointsRewards";
import HomePage from "./pages/Home";
import { GlobalSearchBox } from "./features/search/components/GlobalSearchBox";

vi.mock("./router-utils", () => ({ getAllRoutes: () => [] }));
vi.mock("./features/authentication/menu/AuthMenu", () => ({ AuthMenu: () => null }));
vi.mock("./features/authentication/context/AuthContext", () => ({
  useAuth: () => ({ user: null, isAuthenticated: false, loading: false, error: null }),
}));
vi.mock("./features/partner/context/PartnerAccountContext", () => {
  const mockPartner = {
    account: { kind: "ready", accountId: "account-1", badgeTier: "Gold", roles: ["Distributor"] },
    loading: false,
    error: null,
  };
  return {
    usePartnerAccount: () => mockPartner,
    useOptionalPartnerAccount: () => mockPartner,
  };
});
vi.mock("./components/IghfFooter", () => ({ default: () => null }));
vi.mock("./components/CustomerWebClientChat", () => ({ default: () => null }));
vi.mock("./features/search", () => import("./features/search/components/GlobalSearchBox"));
vi.mock("./api/graphqlClient", () => ({
  executeGraphQL: vi.fn(async () => ({
    uiapi: {
      aggregate: {
        Opportunity: { edges: [], pageInfo: { hasNextPage: false, endCursor: null } },
        pipelineTotal: { edges: [] },
      },
      query: { Opportunity: {
      totalCount: 42,
      edges: [{
        node: {
          Id: "opp-1",
          Name: { value: "Example opportunity" },
          StageName: { value: "Qualification" },
          Amount: { value: 100 },
          CloseDate: { value: "2026-12-01" },
          Account: null,
        },
      }],
    } } },
  })),
}));

afterEach(() => {
  cleanup();
  window.localStorage.removeItem("ipa.sidebarCollapsed");
});

function SearchDestination() {
  const location = useLocation();
  return <main><h1>Search page</h1><p>{location.pathname}{location.search}</p></main>;
}

function renderLayout(path: string, basename = "/") {
  return render(
    <MemoryRouter basename={basename} initialEntries={[path]}>
      <Routes>
        <Route element={<AppLayout />}>
          <Route index element={<h1>Home page</h1>} />
          <Route path="search" element={<SearchDestination />} />
          <Route path="opportunities" element={<OpportunitiesPage />} />
          <Route path="points-rewards" element={<PointsRewardsPage />} />
        </Route>
      </Routes>
    </MemoryRouter>,
  );
}

describe("left navigation", () => {
  it("shows the new menu items directly below Home", () => {
    renderLayout("/");
    const sidebar = screen.getByRole("navigation", { name: "Sidebar" });
    expect(Array.from(sidebar.children).map((item) => item.textContent)).toEqual([
      "Home",
      "Manage Benefits",
      "Points & Rewards",
      "Warranty",
      "Sales & Training",
      "Opportunities",
      "Resources & Tools",
      "Account Management",
      "Reports & Analytics",
    ]);
    expect(within(sidebar).getByRole("link", { name: "Points & Rewards" }))
      .toHaveAttribute("href", "/points-rewards");
    expect(within(sidebar).getByRole("link", { name: "Opportunities" }))
      .toHaveAttribute("href", "/opportunities");
    expect(screen.getByRole("complementary", { name: "Partner resources promotion" })).toBeInTheDocument();
  });

  it("opens Points & Rewards with the points ledger and active navigation", async () => {
    const user = userEvent.setup();
    renderLayout("/");
    const sidebar = within(screen.getByRole("navigation", { name: "Sidebar" }));
    const points = sidebar.getByRole("link", { name: "Points & Rewards" });
    await user.click(points);
    expect(screen.getByRole("heading", { name: "Points & Rewards", level: 1 })).toHaveFocus();
    expect(await screen.findByText("Partner Points Ledger")).toBeInTheDocument();
    expect(points).toHaveAttribute("aria-current", "page");
    expect(points).toHaveClass("bg-[#174a8b]");
    expect(sidebar.getByRole("link", { name: "Home" })).not.toHaveAttribute("aria-current");
    expect(document.title).toBe("Points & Rewards | Partner experience");
  });

  it("opens Points & Rewards directly under the Salesforce deployment base path", async () => {
    renderLayout("/MyReactCommunityApp/points-rewards", "/MyReactCommunityApp");
    const points = within(screen.getByRole("navigation", { name: "Sidebar" }))
      .getByRole("link", { name: "Points & Rewards" });
    expect(points).toHaveAttribute("href", "/MyReactCommunityApp/points-rewards");
    expect(points).toHaveAttribute("aria-current", "page");
    expect(await screen.findByText("Partner Points Ledger")).toBeInTheDocument();
  });

  describe("header search", () => {
    it("places the only Home search after the branding in the primary navigation", async () => {
      render(
        <MemoryRouter>
          <Routes>
            <Route element={<AppLayout />}>
              <Route index element={<HomePage />} />
            </Route>
          </Routes>
        </MemoryRouter>,
      );
      const header = screen.getByRole("navigation", { name: "Primary" });
      const brand = within(header).getByRole("link", { name: "Intel Partner Experience home" });
      const search = within(header).getByRole("search");
      expect(within(search).queryByRole("button")).not.toBeInTheDocument();
      expect(within(search).getByRole("textbox", { name: "Search" })).toHaveAttribute("enterkeyhint", "search");
      expect(brand.compareDocumentPosition(search) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
      expect(screen.getAllByRole("search")).toHaveLength(1);
      expect(within(screen.getByRole("main")).queryByRole("search")).not.toBeInTheDocument();
      const overview = screen.getByRole("region", { name: "Partner overview" });
      const pipeline = within(overview).getByRole("region", { name: "Opportunity Pipeline" });
      expect(await within(pipeline).findByText("0")).toBeInTheDocument();
      expect(screen.queryByText("Example opportunity")).not.toBeInTheDocument();
      expect(screen.getAllByRole("region", { name: "Opportunity Pipeline" })).toHaveLength(2);
      expect(screen.getAllByRole("heading", { name: "Opportunity Pipeline" })).toHaveLength(2);
    });

    it.each(["form submission", "enter"])("submits header search with %s and preserves the Salesforce base path", async (method) => {
      const user = userEvent.setup();
      renderLayout("/MyReactCommunityApp/opportunities", "/MyReactCommunityApp");
      const header = within(screen.getByRole("navigation", { name: "Primary" }));
      const input = header.getByRole("textbox", { name: "Search" });
      await user.type(input, "  Acme & Co  ");
      expect(screen.getByRole("heading", { name: "Opportunities", level: 1 })).toBeInTheDocument();
      if (method === "form submission") {
        fireEvent.submit(header.getByRole("search"));
      } else {
        await user.keyboard("{Enter}");
      }
      expect(within(screen.getByRole("main")).getByText("/search?q=Acme%20%26%20Co")).toBeInTheDocument();
      expect(header.queryByText("/search?q=Acme%20%26%20Co")).not.toBeInTheDocument();
      expect(screen.getByRole("heading", { name: "Search page" })).toHaveFocus();
      expect(document.title).toBe("Search Results | MyApp");
      expect(header.getByRole("textbox", { name: "Search" })).toBeInTheDocument();
    });

    it.each(["", "  ", "ab", " ab "])("does not submit a short or blank query: %j", async (text) => {
      const user = userEvent.setup();
      renderLayout("/");
      const header = within(screen.getByRole("navigation", { name: "Primary" }));
      const input = header.getByRole("textbox", { name: "Search" });
      if (text) await user.type(input, text);
      await user.click(input);
      await user.keyboard("{Enter}");
      fireEvent.submit(header.getByRole("search"));
      expect(screen.getByRole("heading", { name: "Home page" })).toBeInTheDocument();
    });

    it("preserves the reusable search button by default", async () => {
      const user = userEvent.setup();
      render(
        <MemoryRouter>
          <Routes>
            <Route index element={<GlobalSearchBox />} />
            <Route path="search" element={<SearchDestination />} />
          </Routes>
        </MemoryRouter>,
      );
      const button = screen.getByRole("button", { name: "Search" });
      expect(button).toBeDisabled();
      await user.type(screen.getByRole("textbox", { name: "Search" }), "Acme");
      await user.click(button);
      expect(screen.getByText("/search?q=Acme")).toBeInTheDocument();
    });
  });

  it("opens Opportunities from the sidebar and displays the opportunity list results", async () => {
    const user = userEvent.setup();
    renderLayout("/");
    const sidebar = within(screen.getByRole("navigation", { name: "Sidebar" }));
    const opportunities = sidebar.getByRole("link", { name: "Opportunities" });
    expect(opportunities).not.toHaveAttribute("aria-current");
    await user.click(opportunities);
    expect(screen.getByRole("heading", { name: "Opportunities", level: 1 })).toHaveFocus();
    expect(opportunities).toHaveAttribute("aria-current", "page");
    expect(opportunities).toHaveClass("bg-[#174a8b]");
    expect(sidebar.getByRole("link", { name: "Home" })).not.toHaveAttribute("aria-current");
    const count = await screen.findByRole("region", { name: "Total Opportunities" });
    expect(within(count).getByText("42")).toBeInTheDocument();
    expect(screen.getByText("Example opportunity")).toBeInTheDocument();
    expect(document.title).toBe("Opportunities | MyApp");
  });

  it("opens Opportunities directly under the Salesforce deployment base path", async () => {
    renderLayout("/MyReactCommunityApp/opportunities", "/MyReactCommunityApp");
    const opportunities = within(screen.getByRole("navigation", { name: "Sidebar" }))
      .getByRole("link", { name: "Opportunities" });
    expect(opportunities).toHaveAttribute("href", "/MyReactCommunityApp/opportunities");
    expect(opportunities).toHaveAttribute("aria-current", "page");
    expect(await screen.findByText("Example opportunity")).toBeInTheDocument();
  });

  it("shows the Intel logo and Partner Experience branding linked to Home", () => {
    renderLayout("/");
    const brand = screen.getByRole("link", { name: "Intel Partner Experience home" });
    expect(brand).toHaveAttribute("href", "/");
    expect(within(brand).getByRole("img", { name: "Intel" })).toHaveAttribute(
      "src", "https://www.intel.com/content/dam/logos/intel-header-logo.svg",
    );
    expect(within(brand).getByText("Partner Experience")).toBeInTheDocument();
    expect(screen.queryByText("React App")).not.toBeInTheDocument();
  });

  it("shows an active Home link and the page content", () => {
    renderLayout("/");
    const home = within(screen.getByRole("navigation", { name: "Sidebar" }))
      .getByRole("link", { name: "Home" });
    expect(home).toHaveAttribute("aria-current", "page");
    expect(home).toHaveClass("bg-[#174a8b]");
    expect(screen.getByRole("heading", { name: "Home page" })).toBeInTheDocument();
  });

  it("navigates home from another page and updates active state", async () => {
    const user = userEvent.setup();
    renderLayout("/search");
    const home = within(screen.getByRole("navigation", { name: "Sidebar" }))
      .getByRole("link", { name: "Home" });
    expect(home).not.toHaveAttribute("aria-current");
    await user.click(home);
    expect(screen.getByRole("heading", { name: "Home page" })).toBeInTheDocument();
    expect(home).toHaveAttribute("aria-current", "page");
  });

  it("preserves the Salesforce deployment base path", () => {
    renderLayout("/MyReactCommunityApp/search", "/MyReactCommunityApp");
    const home = within(screen.getByRole("navigation", { name: "Sidebar" }))
      .getByRole("link", { name: "Home" });
    expect(home).toHaveAttribute("href", "/MyReactCommunityApp");
  });

  it("hides LNAV on mobile by default, expands it on click, and keeps LNAV non-scrolling while main content scrolls independently", async () => {
    const user = userEvent.setup();
    renderLayout("/");
    const sidebarContainer = document.getElementById("app-sidebar");
    const mainContent = document.getElementById("main-content");
    expect(sidebarContainer).toHaveClass("hidden", "md:flex", "overflow-hidden");
    expect(mainContent).toHaveClass("overflow-y-auto");

    const openBtn = screen.getByRole("button", { name: "Open navigation menu" });
    expect(openBtn).toHaveAttribute("aria-expanded", "false");
    await user.click(openBtn);

    const closeBtn = screen.getByRole("button", { name: "Close navigation menu" });
    expect(closeBtn).toHaveAttribute("aria-expanded", "true");
    expect(sidebarContainer).toHaveClass("fixed", "flex");

    await user.click(within(screen.getByRole("navigation", { name: "Sidebar" })).getByRole("link", { name: "Points & Rewards" }));
    expect(screen.getByRole("button", { name: "Open navigation menu" })).toHaveAttribute("aria-expanded", "false");
    expect(sidebarContainer).toHaveClass("hidden", "md:flex");
  });

  it("collapses and expands the desktop LNAV into an icon rail and persists state", async () => {
    const user = userEvent.setup();
    renderLayout("/");
    const sidebarContainer = document.getElementById("app-sidebar");
    expect(sidebarContainer).toHaveClass("md:w-[clamp(13rem,14vw,16.5rem)]");
    expect(screen.getByRole("complementary", { name: "Partner resources promotion" })).toBeInTheDocument();

    const collapseBtn = screen.getByRole("button", { name: "Collapse sidebar" });
    expect(collapseBtn).toHaveAttribute("aria-expanded", "true");
    await user.click(collapseBtn);

    expect(sidebarContainer).toHaveClass("md:w-16");
    expect(window.localStorage.getItem("ipa.sidebarCollapsed")).toBe("true");
    expect(screen.queryByRole("complementary", { name: "Partner resources promotion" })).not.toBeInTheDocument();
    expect(within(screen.getByRole("navigation", { name: "Sidebar" })).getByRole("link", { name: "Home" })).toHaveAttribute("title", "Home");

    const expandBtn = screen.getByRole("button", { name: "Expand sidebar" });
    expect(expandBtn).toHaveAttribute("aria-expanded", "false");
    await user.click(expandBtn);

    expect(sidebarContainer).toHaveClass("md:w-[clamp(13rem,14vw,16.5rem)]");
    expect(window.localStorage.getItem("ipa.sidebarCollapsed")).toBe("false");
    expect(screen.getByRole("complementary", { name: "Partner resources promotion" })).toBeInTheDocument();
  });
});
