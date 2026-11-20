({

	doInit : function(component, event, helper) {

		// helper.getOfferingDetails(component, component.get('v.recordId'))...
		var footerLinks = {};
		footerLinks['keymetrics'] = [
			{
				title: 'Manage Storefront',
				data: [
					{ label: 'Manage storefront', link: '#' },
					{ label: 'Manage Contacts', link: '#' }
					// IPA2.0 + US TWC4497-1631 
					// { label: 'Manage Offerings', link: '#' }
				]
			},
			{
				title: 'Improve Storefront Stats',
				data: [
					{ label: 'Learn about specialties', link: '#' },
					{ label: 'JapanEarn more competencies', link: '#' }
				]
			}
		];
		footerLinks['leads'] = [
			{
				title: '',
				data: [
					{ label: '$A.get("$Label.c.PMP_View_All_Leads")', link: '#' },
					{ label: '$A.get("$Label.c.PMP_Edit_Contact_Methods")', link: '#' },
				]
			}
		];
		// IPA2.0 + US TWC4497-1631 
		// footerLinks['offerings'] = [
		// 	{
		// 		title: '',
		// 		data: [
		// 			{ label: '$A.get("$Label.c.PMP_Manage_Offerings")', link: '#' },
		// 			{ label: '$A.get("$Label.c.PMP_Add_a_new_offering")', link: '#' },
		// 			{ label: '$A.get("$Label.c.PMP_View_Your_offerings")', link: '#' },
		// 		]
		// 	}
		// ];
		if (footerLinks[component.get('v.type')]) {
			console.log('footerLinks',  footerLinks[component.get('v.type')]);
			component.set('v.linkList', footerLinks[component.get('v.type')]);
		}

		
	},


})