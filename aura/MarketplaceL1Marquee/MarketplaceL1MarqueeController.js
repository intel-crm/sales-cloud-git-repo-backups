({
	doInit : function(component, event, helper) {
		var breadcrumbData = [
			{ label: $A.get("$Label.c.PMP_Breadcrumbs_Marketplace_Home"), page: 'l0-marketplace' }
		];
		component.set('v.breadcrumbData', breadcrumbData);

		if (component.get('v.type') == 'partner') {
			component.set('v.headingLabel', $A.get("$Label.c.PMP_L1_Partner"));
			component.set('v.textLabel', $A.get("$Label.c.PMP_L1_Partner_Subheading"));

		} 
		// IPA2.0 + US TWC4497-1631
		// else {
		// 	component.set('v.headingLabel', $A.get("$Label.c.PMP_L1_Offering"));
		// 	component.set('v.textLabel', $A.get("$Label.c.PMP_L1_Offering_Subheading"));
		// }
	}
})