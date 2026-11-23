({
    cloneDpa: function (component, event, helper) {
        let cloneAction = component.get("c.doClone");
		//let quoteType = component.get("v.quotetype");
        cloneAction.setParams(
            {
                sObjectId: component.get("v.recordId"),
                action: "",
				//quoteTypeTochange : quoteType
            }
        );
        cloneAction.setCallback(this, function (response) {
            let state = response.getState();
            let returnValue = response.getReturnValue();
            var dynamicTitle = "Clone "+returnValue.IsDPAALN;
            console.log('inside clone action '+state);
            console.log('inside clone action1 '+JSON.stringify(returnValue));
            if (component.isValid()) {
                if (state === "SUCCESS") {
                    component.set("v.messageNotification", returnValue.messageResult);
                    component.set("v.isSuccess", returnValue.isSuccess);
                    component.set("v.newRecordId", returnValue.dpaId);
                    component.set("v.failedItems", returnValue.failedItems);
                    component.set("v.isDPALineCloneSuccess", returnValue.isDPALineCloneSuccess);
                    component.set("v.IsDPAALN", returnValue.IsDPAALN);
                    component.set("v.title",dynamicTitle);
                    component.find("mySpinner").set("v.class", "slds-hide");
                    if (returnValue.isDPALineCloneSuccess) {
                        component.set("v.spacingClass", "with-spacing");
                    } else {
                        component.set("v.spacingClass", "no-spacing");
                    }
                     if(returnValue.isSuccess){
                    	this.navigateToRecord(component, event, helper);
                	}

                }
            }
        });

        $A.enqueueAction(cloneAction);
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