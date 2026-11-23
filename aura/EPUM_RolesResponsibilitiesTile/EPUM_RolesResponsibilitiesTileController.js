({
    doInit : function(component, event, helper) {
        var spinner = component.find("mySpinner");
           $A.util.removeClass(spinner, "slds-hide");
           component.set('v.columns', [
                {label: 'Name', fieldName: 'name', type: 'text',wrapText: true},
               {label: 'Phone Number',fieldName:'phoneNumber',type: 'phone', wrapText : true},
                {label: 'Responsibility', fieldName: 'responsibility', type: 'text',  wrapText: true}
            ]);
        var childCmp = component.find("child");
        childCmp.callAuraMethodController(component,"c.getLoggedInUserRole",{typeOfAction:'getUserInfo'},helper.successCallbackUserInfo);
        childCmp.callAuraMethodController(component,"c.getContactsWithRole",{typeOfAction:'getContactRoleInfo'},helper.successCallBackContacRoleInfo);
    },
    goToURL:function(component,event,helper){
        var childCmp = component.find("child");
        childCmp.gotoEPUMRnRPage();
    }
})