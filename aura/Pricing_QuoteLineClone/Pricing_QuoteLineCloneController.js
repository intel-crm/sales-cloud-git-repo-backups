({
    doInit: function(component, event, helper) {
        component.find("mySpinner").set("v.class", "slds-show");
        helper.cloneQuoteLine(component);        
    },
    goBackLink : function(component, event, helper) {
        component.find("overlayLib1").notifyClose();
    }
})