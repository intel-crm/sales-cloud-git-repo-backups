({
	doInit : function(component, event, helper) {
		var breadcrumbData = [
			{ label: 'Marketplace Home', url: '/home' }
		];
		component.set('v.breadcrumbData', breadcrumbData);
	}
})