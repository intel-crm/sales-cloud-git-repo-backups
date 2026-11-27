import { useEffect } from "react";

export default function IghfFooter() {
	useEffect(() => {
		const navigation = (window.INTELNAV ??= {});
		navigation.renderSettingsFooter = {
			version: "2.0 - 03/12/2017 08:00:00",
			OutputId: "gf_default",
		};
	}, []);

	return <div id="recode50footer" className="no-animate" />;
}
