({
    doInit : function(component, event, helper) {
        helper.checkUserPermission(component, event, helper);
    },
    checkExceptionEligibilityCriteria : function(component, event, helper) {
        helper.checkExceptionEligibilityForCancellation(component, event, helper);
    },
    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})