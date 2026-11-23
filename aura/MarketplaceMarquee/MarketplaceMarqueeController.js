({
	doInit : function(component, event, helper) {
		var breadcrumbData = [
			{ label: 'Marketplace Home', url: '/home' }
		];
		if (component.get('v.type') === 'myoffering') {
			breadcrumbData = [
			 { label: 'Marketplace Home', url: '/home' }
			 ,{ label: 'All Marketplace', url: '#' }
			 ,{ label: 'Partner Directory', url: '#' }
			 ,{ label: 'Store Front', url: '#' }

		 ];
	  } else if (component.get('v.type') === 'editlead') {
			breadcrumbData = [
			 { label: 'Edit Lead', url: '/home' }
		 ];
		}

		component.set('v.breadcrumbData', breadcrumbData);
	}
})