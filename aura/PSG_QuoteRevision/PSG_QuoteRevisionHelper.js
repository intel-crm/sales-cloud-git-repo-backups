({
    quoteTypeCheck: function(component, event, helper){
        
    },
    
    
    reviseQuote: function (component, event, helper) {
        let reviseAction = component.get("c.doClone");
        let quoteType = component.get("v.quotetype");
        console.log("quotetypeUnderreviseQuote",quoteType);
        reviseAction.setParams(
            {
                sObjectId: component.get("v.recordId"),
                action: "revision",
                quoteTypeTochange : quoteType
            }
        );
        reviseAction.setCallback(this, function (response) {
            let state = response.getState();
            let returnValue = response.getReturnValue();
            console.log('inside revise action '+state);
            console.log('inside revise action1 '+returnValue);
            if (component.isValid()) {
                if (state === "SUCCESS") {
                    component.set("v.messageNotification", returnValue.messageResult);
                    component.set("v.isSuccess", returnValue.isSuccess);
                    component.set("v.newRecordId", returnValue.quoteId);
                    component.find("mySpinner").set("v.class", "slds-hide");
                    if(returnValue.isSuccess){
                    	this.navigateToRecord(component, event, helper);
                	}
                }else if(state == "ERROR"){
                        var errors = response.getError();                       
                                          console.log('inside revise action 2 '+errors[0].message);

                           
                }              
     
            }
        });

        $A.enqueueAction(reviseAction);
    },
        navigateToRecord: function (component, event, helper) {
        let navService = component.find("navService");
        let pageReference = {
            "type": "standard__recordPage",
            "attributes": {
                "recordId": component.get("v.newRecordId"),
                "actionName": "view"
            }
        }

        navService.generateUrl(pageReference)
            .then($A.getCallback(function (url) {
                console.log('success: ' + url);
                window.open(url, '_blank');
            }),
                $A.getCallback(function (error) {
                    console.log('error: ' + error);
                }));
    }
})