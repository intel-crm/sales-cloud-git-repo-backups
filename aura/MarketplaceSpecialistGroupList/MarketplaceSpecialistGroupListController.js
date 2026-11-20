({
    doInit : function(component, event, helper) {
        component.set('v.loading', true);
		//component.set('v.title', 'Specialists Group');
		component.set('v.title', $A.get("$Label.c.PMP_Speiality_Group_Heading"));
        component.set('v.subtitle', $A.get("$Label.c.PMP_Speiality_Group_SubHeading"));
        helper.getSpecialistGroupList(component);
       
        /*var mockCategories = {
            title: 'Specialists Group',
            //subtitle: 'Discover and make valuable connections with Intel Partners and partner communities.',
            listing: [
                { label: 'Enthusiast Specialist', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
                { label: 'Visual Specialist', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
                { label: 'AI Specialist', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
                { label: 'Cloud Specialist', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
                { label: 'Industry Specialist', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
                { label: 'Specialist Category', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
                { label: 'AI Specialist', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
                { label: 'Cloud Specialist', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
                { label: 'Specialist Category', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
                { label: 'AI Specialist', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
                { label: 'Cloud Specialist', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'}
            ]
            //CTA: 'View All Partners',
            //CTAUrl: 'search'
        }
        
        if (pageType === 'partner') {
          mockCategories.listing = [
              { label: 'Enthusiast Specialist', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
              { label: 'Visual Specialist', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
              { label: 'AI Specialist', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
              { label: 'Cloud Specialist', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
              { label: 'Category 5', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
              { label: 'Category 6', page: 'l2', imgUrl: 'https://via.placeholder.com/50/1e2e43/FFFFFF'},
          ]
        }*/
       // var pageType = component.get('v.pageType');
		
        //component.set('v.listing', mockCategories.listing);
        
        //component.set('v.subtitle', mockCategories.subtitle);
        //component.set('v.CTA', mockCategories.CTA);
        //component.set('v.CTAUrl', mockCategories.CTAUrl);
    }
})