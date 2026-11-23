({
	doInit : function(component, event, helper) {
        const quoteLineId = component.get("v.recordId");
        console.log('Record Id: '+quoteLineId);
		var navService = component.find("navService");
            var pageReference = {
                    "type": "standard__navItemPage",
                    "attributes": {
                        "apiName": $A.get("$Label.c.Pricing_PriceRecommendation_Page_Link")  
                    },    
                    "state": {
                        "c__qline":quoteLineId
                    }
            };    
            navService.navigate(pageReference);
	}
})