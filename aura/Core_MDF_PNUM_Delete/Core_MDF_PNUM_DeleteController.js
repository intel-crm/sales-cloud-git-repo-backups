({
    // method called on component initialization
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
    },
    // method called on click of Delete Account User button
    deleteAccountUser : function(component, event, helper) {
        component.set("v.Spinner",true);
        helper.deleteAccountUser(component, event, helper);
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
    
    closeModel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
})