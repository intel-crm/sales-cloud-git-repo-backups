({
    //method called on page load
    doInit : function(component, event, helper) {
    	helper.checkFailedClaimBatchRecords(component, event, helper);
    },
    //method called to close quick action when user clicks on No
    closeModel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    //method called to update claim batch record status to submitted
    updateClaimBatchRecStatus : function(component, event, helper) {
        helper.updateClaimBatchRecStatus(component, event, helper);
    },
})