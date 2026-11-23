({
    //method called on page load
    doInit : function(component, event, helper) {
    	helper.fetchUserAndClaimDetails(component, event, helper);
    },
    
    //method called to close quick action when user clicks on No
    closeModel: function(component, event, helper) {
    	$A.get("e.force:closeQuickAction").fire();
    },
    
    //method called when Release Criteria Hold or Release Intel/Member Manual Hold checkbox is checked
    toggleReleaseSubmissionButton: function (component, event){
        if(component.get("v.isCriteriaChecked") || component.get("v.isIntManualChecked") || component.get("v.isMemManualChecked")) {
             component.find('proceed').set("v.disabled",false);
        }
        else{
             component.find('proceed').set("v.disabled",true);
        }
    },
    
    //method called when Release Hold/Yes button is clicked by External/Internal User after checking Release Criteria or Manual Hold checkbox
     releaseHold : function(component, event, helper) {
    	helper.releaseHold(component, event, helper);
    },
})