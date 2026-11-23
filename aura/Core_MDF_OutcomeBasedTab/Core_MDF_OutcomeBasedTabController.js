({ doInit: function(component, event, helper) {
    var navService = component.find("navService"); 
    var pageReference = { 
        type: "standard__objectPage", 
        attributes: { objectApiName: "PartnerFundRequest", actionName: "list" }, 
        state: {filterName: "Recently Viewed" } }; 
        navService.navigate(pageReference, true); } })