({
    doInit: function(component, event, helper) {
        
    },

    openEditStoreModal : function(component, event, helper) {
        
        var appEvent = $A.get("e.c:MarketplacePageEvent");
        appEvent.setParams({
                type: 'openEditStoreFrontFromDraft',
                payload: { 
                    currentStep: component.get('v.currentStep')
                    //firstSubmission: !component.get('v.visible') Not needed 
                }
            });
        appEvent.fire();
    }
})