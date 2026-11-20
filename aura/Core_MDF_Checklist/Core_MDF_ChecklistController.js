({
    //On init
    doInit: function(component, event, helper) {
        helper.onInit(component,event,helper);
    },
    //When the checklist is updated
    updateRecords : function(component, event, helper) {
        helper.updateChecklistRecords(component,event,helper);   
    },
    
    //Checklist Enhancements v1 - Checklist Enhancements v1 - US458776: [Case: Edit] Automatic Status for Checklist Results
    closeModel: function(component, event, helper) {
        component.set("v.isOpen", false);
     },
    updateCase: function(component, event, helper) {
        component.set("v.isOpen", false);
        component.set("v.performUpdate", true);
        helper.updateCaseStatus(component,event,helper);
     }
})