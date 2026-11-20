({
	doInit : function(component, event, helper) {
        
        component.set('v.showSignIn', false);
        
        if($A.get("$SObjectType.CurrentUser.Email") === undefined){
                component.set('v.showSignIn', true);  
        }

    component.set('v.mapStateToAttributes', function(state) {
        
      var searchType = state.searchType, selectedCategory = state.selectedCategoryId;
      var label = '', subheading = '', learnMoreLink = '';

			// TODO -- Replace with any changed Custom Labels and update to proper URLs
			var marketplaceHomeLabel = 'Marketplace Home'; //$A.get("$Label.c.PMP_L2_Marquee_All_Heading");
			var allMarketplaceLabel = $A.get("$Label.c.PMP_L2_Marquee_All_Heading");
			/*var breadcrumbData = [
				{ label: 'Marketplace Home', url: '/s/home' },
				{ label: 'All Marketplace', url: '/imp/s/search' }
			];*/
            var breadcrumbData = [
				{ label: $A.get("$Label.c.PMP_Breadcrumbs_Marketplace_Home"), page: 'l0-marketplace' },
				{ label: $A.get("$Label.c.PMP_Breadcrumbs_All_Marketplace"), page: 'l2' },
			];

      if (!selectedCategory) {

        if (searchType == 'all') {
          label = $A.get("$Label.c.PMP_L2_Marquee_All_Heading");
          subheading = $A.get("$Label.c.PMP_L2_Marquee_ALL_Subheading");

        } else if (searchType == 'partner') {
          label = $A.get("$Label.c.PMP_L2_Marquee_Partner_Heading");
          subheading = $A.get("$Label.c.PMP_L2_Marquee_Partner_Subheading");

        } else if (searchType == 'product') {
          label = $A.get("$Label.c.PMP_L2_Marquee_Product_Heading");
          subheading = $A.get("$Label.c.PMP_L2_Marquee_Product_Subheading");
        }

      } else {
        label = state.searchHeading;
        subheading = state.searchSubHeading;
		learnMoreLink = state.searchCtaLink;          
      }

			if (searchType == 'partner') {
				var partnerLabel = $A.get("$Label.c.PMP_L2_Marquee_Partner_Heading");
				//breadcrumbData.push({ label: partnerLabel, url: '/s/partnerDirectory' });
				breadcrumbData.push({ label: partnerLabel, page: 'l1-partners' });
				if (selectedCategory) {
					breadcrumbData.push({
            label: state.searchHeading,
            page: 'l2',
            searchParams: { type: 'partner', cat: selectedCategory }
          });
				}
			}

			if (searchType == 'product') {
				var productLabel = $A.get("$Label.c.PMP_L2_Marquee_Product_Heading");
				breadcrumbData.push({ label: productLabel, page: 'l1-offerings' });
				//breadcrumbData.push({ label: 'Product Catalog', url: '/s/productCatalog' });
				if (selectedCategory) {
					breadcrumbData.push({
            label: state.searchHeading,
            page: 'l2',
            searchParams: { type: 'product', cat: selectedCategory }
          });
				}
			}
        
       /* if (searchType == 'all') {
				var productLabel = $A.get("$Label.c.PMP_L2_Marquee_ALL_Subheading");
				//breadcrumbData.push({ label: 'Product Catalog', url: '/s/productCatalog' });
				if (selectedCategory) {
					breadcrumbData.push({
            label: component.get('v.state.searchHeading'),
            page: 'l2',
            searchParams: { type: 'all', cat: selectedCategory }
          });
				}
			}*/

      return {
				breadcrumbData: breadcrumbData,
        		headingLabel: label,
        		textLabel: subheading,
          		learnMoreLink: learnMoreLink
      };
    });
	}
})