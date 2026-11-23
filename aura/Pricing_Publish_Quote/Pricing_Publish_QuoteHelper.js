({
    processTenderQuote: function (component, event, helper) {
        //component.set('v.messageNotification', '');
        let recordId = component.get('v.recordId');  // NOSONAR
        let action = component.get('c.PublishTenderQuote');  // NOSONAR
        action.setParams({
            recId: recordId,
        });
        action.setCallback(this, function (response) {
            console.log('response:'+response);   // NOSONAR
                console.log('response11');
                let state = response.getState();
                //let returnValue = response.getReturnValue();   // NOSONAR
                console.log('state:'+state);
                if (state === 'SUCCESS') {
                    let returnValue = response.getReturnValue();   // NOSONAR
                    component.set('v.messageNotification', returnValue.messageNotification);
                    component.find("mySpinner").set("v.class", "slds-hide");
                    component.set('v.isSuccess', returnValue.isSuccess);
                }else if (state === 'ERROR'){
                    let returnValue = response.getReturnValue(); 
                    console.log("Response Data:", JSON.stringify(response.getReturnValue()));
                    component.set('v.messageNotification',returnValue != null ? returnValue.messageNotification : 'Error occured while processing the request Please Contact IQR Team');
                    component.find("mySpinner").set("v.class", "slds-hide");
                }
        });
        $A.enqueueAction(action);
        // var spinner = component.find("mySpinner");
        //     $A.util.addClass(spinner, "slds-hide");
    },
    navigateToRefresh: function (component, event, helper) {
        let navEvt = $A.get('e.force:navigateToSObject');   // NOSONAR
        let rid = component.get('v.recordId');    // NOSONAR
        navEvt.setParams({
            'recordId': rid,
        });
        navEvt.fire();
    },
});