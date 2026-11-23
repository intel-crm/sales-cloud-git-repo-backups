({
    // method called on component initialization
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
    },
    // method called on click of cancel claim button
    cancelClaim : function(component, event, helper) {
        var reason = component.get("v.cancellationReason") || "";
        var reasonRequired = component.get("v.reasonRequired");
        var reasonInput = component.find("reasonInput");
        
        if (reasonRequired && !reason.trim()) {
            if (reasonInput) {
                reasonInput.reportValidity();
            }
            return;
        }
        component.set("v.Spinner",true);
        helper.cancelClaim(component, event, helper, reason.trim());        
    },
    CloseToast: function(component, event, helper) {
        var cmpTarget = component.find('toast');
        $A.util.addClass(cmpTarget, 'slds-hide');  
    },
    CloseErrorToast: function(component, event, helper) {
        var cmpTarget = component.find('errorToast');
        $A.util.addClass(cmpTarget, 'slds-hide');  
    },
    // method called to refersh the page
    isRefreshed : function(component, event, helper) {
        helper.isRefreshed(component, event, helper);
    },

    closeModel : function(component, event, helper) {
        if(component.get("v.isCustomComp")){
            let closeModalEvent = component.getEvent("closeModalEvent");
            closeModalEvent.fire();
        }
        else{
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    
})