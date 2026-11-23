import { StrictMode } from "react";
import { act, cleanup, fireEvent, render, screen, within } from "@testing-library/react";
import { MemoryRouter } from "react-router";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import IghfHeader from "./IghfHeader";

const auth = vi.hoisted(() => ({ loading: false, isAuthenticated: false }));
vi.mock("../features/authentication/context/AuthContext", () => ({
	useAuth: () => auth,
}));

const LOADER_URL = "https://www.intel.com/ighf/50recode.2/js/headerchooser.js";
const scripts = () => document.querySelectorAll<HTMLScriptElement>(`script[src="${LOADER_URL}"]`);

beforeEach(() => {
	auth.loading = false;
	auth.isAuthenticated = false;
	document.documentElement.lang = "en";
	vi.stubGlobal("SFDC_ENV", { language: "en-US" });
	vi.useFakeTimers();
});

afterEach(() => {
	cleanup();
	scripts().forEach((script) => script.remove());
	delete window.INTELNAV;
	document.documentElement.lang = "";
	vi.unstubAllGlobals();
	vi.restoreAllMocks();
	vi.useRealTimers();
});

describe("IghfHeader", () => {
	it("loads headerchooser.js once in StrictMode and configures INTELNAV.renderSettings", () => {
		auth.isAuthenticated = true;
		render(
			<StrictMode>
				<MemoryRouter>
					<IghfHeader />
				</MemoryRouter>
			</StrictMode>,
		);

		expect(document.querySelector("#recode50header")).toHaveClass("no-animate");
		expect(scripts()).toHaveLength(1);
		expect(scripts()[0].async).toBe(true);
		expect(window.INTELNAV?.renderSettings).toEqual({
			version: "2.0 - 03/12/2017 08:00:00",
			textDirection: "ltr",
			culture: "en_US",
			OutputId: "default",
		});
		expect(window.INTELNAV?.dashboard).toBe("");
	});

	it("keeps the built-in IGHF header fallback without showing an error alert if the external loader fails", () => {
		const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});
		render(
			<MemoryRouter>
				<IghfHeader />
			</MemoryRouter>,
		);

		fireEvent.error(scripts()[0]);
		act(() => {
			vi.advanceTimersByTime(20000);
		});

		const nav = screen.getByRole("navigation", { name: "Primary" });
		const brand = within(nav).getByRole("link", { name: "Intel Partner Experience home" });
		expect(brand).toHaveAttribute("href", "/");
		expect(within(brand).getByRole("img", { name: "Intel" })).toHaveAttribute(
			"src",
			"https://www.intel.com/content/dam/logos/intel-header-logo.svg",
		);
		expect(within(brand).getByText("Partner Experience")).toBeInTheDocument();
		expect(within(nav).getByRole("search")).toBeInTheDocument();
		expect(within(nav).getByRole("link", { name: "My Intel Account" })).toHaveAttribute("href", "/profile");
		expect(within(nav).getByLabelText("Language: English")).toHaveTextContent("ENGLISH");
		expect(screen.queryByRole("alert")).toBeNull();
		expect(warnSpy).toHaveBeenCalled();
	});

	it("switches to embedded Partner Experience bar when live vendor header renders into #recode50header", async () => {
		vi.useRealTimers();
		render(
			<MemoryRouter>
				<IghfHeader />
			</MemoryRouter>,
		);

		const container = document.querySelector("#recode50header")!;
		expect(container).toHaveClass("recode50");
		await act(async () => {
			const vendorNav = document.createElement("div");
			vendorNav.className = "global-nav-redesign";
			container.appendChild(vendorNav);
		});

		expect(container).toHaveClass("recode50");
		const nav = screen.getByRole("navigation", { name: "Primary" });
		expect(within(nav).getByText("Partner Experience")).toBeInTheDocument();
		expect(within(nav).getByRole("search")).toBeInTheDocument();
		expect(within(nav).queryByRole("link", { name: "My Intel Account" })).toBeNull();
	});
});
