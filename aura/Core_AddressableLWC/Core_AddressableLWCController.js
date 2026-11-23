({
    init : function(component, event, helper) {
		let pageRef = component.get("v.pageReference");
        console.log('##rec'+component.get("v.recordId"));

		let encodedCompDef = btoa(
			JSON.stringify({
				componentDef: pageRef.state.c__lwc,
                //Core_GenerateAIPoweredAccountSummaryComp,
				recordId: pageRef.state.recordId,
				attributes: pageRef.state.recordId
			})
		);

		component.find("navService").navigate(
			{
				type: "standard__webPage",
				attributes: {
					url: "/one/one.app#" + encodedCompDef
				}
			},
			true
		);
    }
})