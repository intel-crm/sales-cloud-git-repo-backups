import { act, cleanup, render, screen } from "@testing-library/react";
import { afterEach, describe, expect, it } from "vitest";
import IghfFooter from "./IghfFooter";

afterEach(() => {
	cleanup();
	delete window.INTELNAV;
});

describe("IghfFooter", () => {
	it("renders #recode50footer, sets footer settings, and displays fallback Intel footer until vendor footer loads", async () => {
		render(<IghfFooter />);
		const footerMount = document.querySelector("#recode50footer")!;
		expect(footerMount).not.toBeNull();
		expect(footerMount).toHaveClass("recode50");
		expect(footerMount).toHaveClass("no-animate");
		expect(window.INTELNAV?.renderSettingsFooter).toEqual({
			version: "2.0 - 03/12/2017 08:00:00",
			OutputId: "gf_default",
		});

		expect(screen.getByRole("contentinfo", { name: "Intel global footer" })).toBeInTheDocument();
		expect(screen.getByRole("link", { name: "Company Overview" })).toBeInTheDocument();

		await act(async () => {
			const vendorFooter = document.createElement("div");
			vendorFooter.textContent = "Live Intel Global Footer";
			footerMount.appendChild(vendorFooter);
		});

		expect(footerMount).toHaveClass("recode50");
		expect(screen.queryByRole("contentinfo", { name: "Intel global footer" })).toBeNull();
		expect(screen.getByText("Live Intel Global Footer")).toBeInTheDocument();
	});
});
