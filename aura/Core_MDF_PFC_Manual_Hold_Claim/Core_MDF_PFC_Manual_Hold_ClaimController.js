({
	// method called on component initialization
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
    },
    
    // method called to update updateHoldYes
    updateClaimHoldDeatils : function(component, event, helper) {  
        component.set("v.Spinner",true);
        helper.updateClaimHoldDeatils(component);
    },
    
    // method called to refersh the page
    isRefreshed : function(component, event, helper) {
        helper.isRefreshed(component, event, helper);
    },
    
    closeModel: function(component, event, helper) {
        if(component.get("v.isCustomComp")){
            let closeModalEvent = component.getEvent("closeModalEvent");
            closeModalEvent.fire();
        }
        else{
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    
    closeErrorToast:function(component, event, helper) {
        var cmpTarget = component.find('errorToast');
        $A.util.addClass(cmpTarget, 'slds-hide');  
    },
    
    CloseToast: function(component, event, helper) {
        var cmpTarget = component.find('toast');
        $A.util.addClass(cmpTarget, 'slds-hide');  
    },
   
    toggleYesButton: function (component, event){
        var holdComments = component.get("v.holdComments");
        if( holdComments != null && holdComments.trim()){        
             component.find('yesButton').set("v.disabled",false); // Enable yes Button
        }
        else{
             component.find('yesButton').set("v.disabled",true); // Disable Yes Button
        }
    },
})