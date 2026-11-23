({
	/**
   	* Adds the company breadcrumb (if the user is associated with a company). MGDANIES
   	* @param {Object} component  The Lightning web component.
  	*/
    addCompanyBreadcrumb : function(component) {
        // Get the company from the backend controller
		var actionFetchCompany = component.get("c.getCompany");        						
        actionFetchCompany.setCallback(this, function(response) {
            var state = response.getState();
            // Check if the call worked
            if (state === "SUCCESS") {
                // Yes so get the company returned
                var response = response.getReturnValue();
                var breadcrumbData = component.get("v.breadcrumbData");
                
                // Check if the user is associated with a company
                if(response != null){
                    // Yes so add the company breadcrumb
                    var companyBreadcrumb = {
                        label: response.Name
                    };
                    
                    // Check if the breadcrumb is in the Partner Admin portal
                    if (breadcrumbData[0].url) {
                        // Yes so need to use the URL to Marketplace
                        var marketplaceUrl = $A.get("$Label.c.PMP_Marketplace_Community_URL");
                       companyBreadcrumb.url = marketplaceUrl + '/partner/' + response.Id;
                    } else {
                        // No so will use the navService
                        companyBreadcrumb.type = 'standard__recordPage';
                        companyBreadcrumb.attributes = {
                            recordId: response.Id,
                            objectApiName: 'PMP_Company__c',
                            actionName: "view"
                        };
                        // This won't actually be used, but is needed to get through the IF
                        // check in the Breadcrumbs so that the navService is used.
                        companyBreadcrumb.page = 'home';
                    }
                    // Insert the company breadcrumb and update the component
                    breadcrumbData.splice(2, 0, companyBreadcrumb);
                    component.set("v.breadcrumbData", breadcrumbData);
                }
            } else if (status === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error(errors[0].message); reject(errors[0].message);
                } else { reject('Unknown error.'); }
            } 
        });
        $A.enqueueAction(actionFetchCompany);
	},
   
})