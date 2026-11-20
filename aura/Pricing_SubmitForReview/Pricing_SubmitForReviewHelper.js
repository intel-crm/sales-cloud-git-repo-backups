({
    doReview: function (component, event, helper) {
        component.set('v.messageNotification', '');
        let cloneAction = component.get('c.submitForReview');    // NOSONAR
        cloneAction.setParams(
            {
                sObjectId: component.get('v.recordId'),
            }
        );
        cloneAction.setCallback(this, function (response) {
            let state = response.getState();    // NOSONAR
            let returnValue = response.getReturnValue();    // NOSONAR
            console.log("response-->" + response.getReturnValue());
            if (component.isValid() && state === 'SUCCESS') {
                component.set('v.messageNotification', returnValue.messageNotification);
                component.set('v.isSuccess', returnValue.isSuccess);
                component.find('mySpinner').set('v.class', 'slds-hide');
            }
        });
        $A.enqueueAction(cloneAction);
    },
});