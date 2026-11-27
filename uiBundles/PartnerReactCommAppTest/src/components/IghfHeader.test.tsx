import { StrictMode } from "react";
import { act, cleanup, render, screen } from "@testing-library/react";
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
	it("uses the source site's loader, mount point and settings, only once in StrictMode", () => {
		render(<StrictMode><IghfHeader /></StrictMode>);
		expect(document.querySelector("#recode50header")).toHaveClass("no-animate");
		expect(scripts()).toHaveLength(1);
		expect(scripts()[0].async).toBe(true);
		expect(window.INTELNAV?.renderSettings).toEqual({
			version: "2.0 - 03/12/2017 08:00:00",
			textDirection: "ltr",
			culture: "en_US",
			OutputId: "default",
		});
	});

	it.each([
		["ja", "ja_JP"], ["fr", "fr_FR"], ["de", "de_DE"], ["ko", "ko_KR"],
		["es", "es_ES"], ["it", "it_IT"], ["ru", "ru_RU"], ["zh-CN", "zh_CN"],
	])("maps %s to the configured IGHF culture %s", (language, culture) => {
		vi.stubGlobal("SFDC_ENV", { language });
		render(<IghfHeader />);
		expect(window.INTELNAV?.renderSettings?.culture).toBe(culture);
	});

	it("falls back to the document language when the platform language is absent", () => {
		vi.stubGlobal("SFDC_ENV", undefined);
		document.documentElement.lang = "de";
		render(<IghfHeader />);
		expect(window.INTELNAV?.renderSettings?.culture).toBe("de_DE");
	});

	it("waits for authentication and disables the dashboard for signed-in users", () => {
		auth.loading = true;
		const { rerender } = render(<IghfHeader />);
		expect(scripts()).toHaveLength(0);
		auth.loading = false;
		auth.isAuthenticated = true;
		rerender(<IghfHeader />);
		expect(window.INTELNAV?.dashboard).toBe("");
		expect(scripts()).toHaveLength(1);
	});

	it("reuses a host page's existing loader", () => {
		const script = document.createElement("script");
		script.src = LOADER_URL;
		document.head.appendChild(script);
		render(<IghfHeader />);
		expect(scripts()).toHaveLength(1);
		expect(scripts()[0]).toBe(script);
	});

	it("reports loader errors visibly", () => {
		vi.spyOn(console, "error").mockImplementation(() => {});
		render(<IghfHeader />);
		act(() => scripts()[0].dispatchEvent(new Event("error")));
		expect(screen.getByRole("alert")).toHaveTextContent("could not load");
		expect(console.error).toHaveBeenCalled();
	});

	it("reports a loader that never renders the header", () => {
		vi.spyOn(console, "error").mockImplementation(() => {});
		render(<IghfHeader />);
		act(() => vi.advanceTimersByTime(20000));
		expect(screen.getByRole("alert")).toHaveTextContent("could not load");
	});

	it("does not report failure once the vendor renders into the container", async () => {
		render(<IghfHeader />);
		await act(async () => {
			document.querySelector("#recode50header")!.appendChild(document.createElement("nav"));
		});
		act(() => vi.advanceTimersByTime(20000));
		expect(screen.queryByRole("alert")).toBeNull();
	});

	it("cleans up pending timeouts on unmount without removing the shared loader", () => {
		const { unmount } = render(<IghfHeader />);
		unmount();
		expect(vi.getTimerCount()).toBe(0);
		expect(scripts()).toHaveLength(1);
	});
});
