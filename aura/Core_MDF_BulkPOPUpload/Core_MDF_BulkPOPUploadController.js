({
    //Initializing the components by setting attributes 
    doInit: function (component, event, helper) {
        helper.initiateComponent(component, event, helper); 
    },
    
    uploadAction: function (component, event, helper){        
        helper.uploadAction(component, event, helper); 
    },
    
    //This function is used to close error toast message
    closeErrorToast: function(component, event, helper) {
        var cmpTarget = component.find('errorToast');
        $A.util.addClass(cmpTarget, 'slds-hide');  
    }, 

    handleMouseHover: function(component, event, helper) {
        var my = event.srcElement.id;
        component.set("v.reId",my);
        helper.getMiniLayout(component, event, helper)
    },
    handleMouseOut: function(component, event, helper) {
        component.set("v.hoverRow",-1);
        component.set("v.togglehover",false);
    },
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire()
        $A.get('e.force:refreshView').fire();
    },

    //This method is executed when bulk pop upload event is triggered from manage audit wrapper component
    prepareDocListAndClaimData: function(component, event, helper) {
        let auditDocumentList = event.getParam("auditDocumentList");
        let thirdPartyWrapper = event.getParam("thirdPartyWrapper");
        component.set("v.auditDocument", auditDocumentList);
        helper.update3rdPartyDetails(component, thirdPartyWrapper);
        helper.saveClaimResult(component, event, helper);
    }
})