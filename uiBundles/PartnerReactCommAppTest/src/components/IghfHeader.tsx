import { useEffect, useRef, useState } from "react";
import { useAuth } from "../features/authentication/context/AuthContext";

const LOADER_URL = "https://www.intel.com/ighf/50recode.2/js/headerchooser.js";
const LANGUAGE_CULTURES: Record<string, string> = {
	en: "en_US",
	ja: "ja_JP",
	fr: "fr_FR",
	de: "de_DE",
	ko: "ko_KR",
	es: "es_ES",
	it: "it_IT",
	ru: "ru_RU",
};

export default function IghfHeader() {
	const { loading, isAuthenticated } = useAuth();
	const containerRef = useRef<HTMLDivElement>(null);
	const [error, setError] = useState("");

	useEffect(() => {
		if (loading || !containerRef.current) return;

		const container = containerRef.current;
		const environment = (globalThis as { SFDC_ENV?: { language?: string } }).SFDC_ENV;
		const language = environment?.language || document.documentElement.lang || "en";
		const culture = LANGUAGE_CULTURES[language] || language.replace(/-/g, "_");
		const navigation = (window.INTELNAV ??= {});
		navigation.renderSettings = {
			version: "2.0 - 03/12/2017 08:00:00",
			textDirection: "ltr",
			culture,
			OutputId: "default",
		};
		if (isAuthenticated) navigation.dashboard = "";

		const reportFailure = () => {
			const message = "The Intel global header could not load. Refresh the page to try again.";
			console.error("[IghfHeader]", message);
			setError(message);
		};

		let script = document.querySelector<HTMLScriptElement>(`script[src="${LOADER_URL}"]`);
		const isNewScript = !script;
		if (!script) {
			script = document.createElement("script");
			script.src = LOADER_URL;
			script.async = true;
		}
		script.addEventListener("error", reportFailure);

		// The chooser loads further assets; its load event alone does not mean the header rendered.
		const timeout = window.setTimeout(() => {
			if (!container.childElementCount) reportFailure();
		}, 20000);
		const observer = new MutationObserver(() => {
			if (container.childElementCount) {
				window.clearTimeout(timeout);
				setError("");
			}
		});
		observer.observe(container, { childList: true });
		if (isNewScript) document.head.appendChild(script);

		return () => {
			observer.disconnect();
			window.clearTimeout(timeout);
			script.removeEventListener("error", reportFailure);
			// Keep the shared loader across StrictMode effect replay and client-side navigation.
		};
	}, [loading, isAuthenticated]);

	return (
		<>
			<div id="recode50header" className="no-animate" ref={containerRef} />
			{error && (
				<p role="alert" className="border-b border-red-200 bg-red-50 px-4 py-3 text-red-800">
					{error}
				</p>
			)}
		</>
	);
}
