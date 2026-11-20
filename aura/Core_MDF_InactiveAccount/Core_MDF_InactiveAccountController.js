({
    // method called on click of inactivate account button
    doInit : function(component, event, helper) {
    	helper.checkUserPermission(component, event, helper);
    },
    //method called to check whether account is eligible for inactivation
    checkAccountEligibiltyForInactivation : function(component, event, helper) {
    	helper.checkAccountEligibiltyForInactivation(component, event, helper);
    },
    //method called to close quick action when user clicks on No
    closeModel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})