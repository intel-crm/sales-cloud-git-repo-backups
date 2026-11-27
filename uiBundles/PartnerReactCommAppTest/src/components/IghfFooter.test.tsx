import { render } from "@testing-library/react";
import { afterEach, describe, expect, it } from "vitest";
import IghfFooter from "./IghfFooter";

afterEach(() => {
	delete window.INTELNAV;
});

describe("IghfFooter", () => {
	it("renders the expected recode50footer element with no-animate class and sets footer settings", () => {
		render(<IghfFooter />);
		const footer = document.querySelector("#recode50footer");
		expect(footer).not.toBeNull();
		expect(footer).toHaveClass("no-animate");
		expect(window.INTELNAV?.renderSettingsFooter).toEqual({
			version: "2.0 - 03/12/2017 08:00:00",
			OutputId: "gf_default",
		});
	});
});
