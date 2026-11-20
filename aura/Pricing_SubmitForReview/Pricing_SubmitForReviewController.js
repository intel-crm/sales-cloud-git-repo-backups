({
    doInit: function (component, event, helper) {
        component.find('mySpinner').set('v.class', 'slds-show');
        helper.doReview(component);
    },
    goBackLink: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
        $A.get('e.force:closeQuickAction').fire();
    },
});