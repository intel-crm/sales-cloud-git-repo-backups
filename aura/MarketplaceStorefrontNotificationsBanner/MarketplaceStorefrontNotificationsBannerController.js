({
    // doInit: function(cmp, event, helper) {
    //     var navService = cmp.find("navService");
    //     // Sets the route to /lightning/o/Account/home
    //     var pageReference = {
    //         type: "standard__namedPage",
    //         attributes: {
    //             "pageName": "offering-preview"
    //         },
    //         state: {
    //             "recordId": "ABC123"
    //         }
    //     };
    //     console.log('pageReference', pageReference);
    //     cmp.set("v.pageReference", pageReference);
    //
    //     // Set the URL on the link or use the default if there's an error
    //     var defaultUrl = "#";
    //     navService.generateUrl(pageReference)
    //         .then(
    //             $A.getCallback(function(url) {
    //                 cmp.set("v.url", url ? url : defaultUrl);
    //             }),
    //             $A.getCallback(function(error) {
    //                 console.log('Error',error);
    //                 cmp.set("v.url", defaultUrl);
    //             })
    //         );
    // },
    // handleLink: function(cmp, event, helper) {
    //
    //     var navService = cmp.find("navService");
    //     // Uses the pageReference definition in the init handler
    //     var pageReference = cmp.get("v.pageReference");
    //     sessionStorage.setItem('offeringState', JSON.stringify(pageReference.state));
    //     console.log(JSON.stringify(pageReference));
    //     event.preventDefault();
    //     navService.navigate(pageReference);
    // },
    
    handleClick: function(component, event, helper) {
        console.log('7 notification');
        
        if (!component.get('v.openEditStorefront')) return;
        var appEvent = $A.get("e.c:MarketplacePageEvent");
        let type = component.get('v.textLinkLabel') == $A.get("$Label.c.PMP_Edit_Storefront_your_more_submission") ? 'openEditStoreFrontFromLink' : 'openEditStoreFront';
        appEvent.setParams({
            type: type,
            payload: {
                currentStep: component.get('v.editStorefrontStep')
            }
        });
        appEvent.fire();
        //alert(currentStep);
       // console.log('edit',component.get('v.editStorefrontStep'));
        event.preventDefault();
        event.stopPropagation();
    }
    
    
})