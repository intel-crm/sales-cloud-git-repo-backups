({
    // This Method is called when the Component is Initialized
    doInit: function (component, event, helper) {
        helper.fetchRecordTypeMetaData(component, event, helper);
    },
    // This Method is called when the file is uploaded by the User
    handleUploadFinished: function (component, event, helper) {
        helper.handleUploadFinished(component, event, helper);
    },
    // This Method is called when the file is uploaded by the User
    handleClick: function (component, event, helper) {
        helper.parsefile(component, event, helper);
    },
    // This method sets the Request Id on change of Program LookUp
    updateLookUpId: function (component, event, helper) {
        component.set("v.programId", event.getParam("sObjectId"));
        component.set("v.programLabel",event.getParam("sObjectLabel"));
        var programIdComponent = component.find("programInputHelpMsg");
        $A.util.removeClass(programIdComponent, "slds-show");
        $A.util.addClass(programIdComponent, "slds-hide");
        helper.fetchBulkClaimTemplate(component, event, helper);
        var appProg = $A.get("$Label.c.Core_MDF_Prog_For_Bgt_Validation_PFR").split(';');
        if(appProg.includes(component.get("v.programLabel"))){
            component.set('v.showAppPicklistVal',true);
        } 
    },
    // This method clears the Request Id on change of Program LookUp
    clearLookUpId: function (component, event, helper) {
        component.set("v.programId", '');
        component.set("v.programLabel",'');
        var downloadTemplateLink = component.find("downloadTemplate");
        $A.util.addClass(downloadTemplateLink, "slds-hide");
        $A.util.removeClass(downloadTemplateLink, "slds-show");
    },
    getTemplate: function (component, event, helper) {
        component.find('templateURL').click();
    },
    // Upon clicking on cancel button, modal will be closed
    onCancel: function (component, event, helper) {
        component.set("v.togglePopUp", false);
    },
    getAvailableValues: function (component, event, helper) {
        helper.fetchAvailActSubTypeValues(component, event, helper);
    }    
})