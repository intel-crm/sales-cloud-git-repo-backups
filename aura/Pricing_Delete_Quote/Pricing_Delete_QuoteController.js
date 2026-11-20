({
    doInit: function (component, event, helper) {
        component.set("v.isSuccess", true);
    },
    deleteQuote: function (component, event, helper) {
        let recordId = component.get("v.recordId");  // NOSONAR
        component.find("mySpinner").set("v.class", "slds-show");
        helper.deleteQuoteRecord(component, event, helper, recordId);
    },
    handleExit: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire()
    },
    goBackLink: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
    },
})