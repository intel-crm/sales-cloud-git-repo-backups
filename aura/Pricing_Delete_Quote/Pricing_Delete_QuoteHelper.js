({
    deleteQuoteRecord: function (component, event, helper, recordId) {
        let action = component.get("c.deleteIQRQuote");   // NOSONAR
        action.setParams({
            quoteId: recordId
        });
        action.setCallback(this, function (response) {
            let state = response.getState();   // NOSONAR
            let returnValue = response.getReturnValue();    // NOSONAR
            console.log(returnValue);
            if (state === "SUCCESS") {
                if (returnValue == true) {
                    $A.get("e.force:closeQuickAction").fire();
                    component.find("mySpinner").set("v.class", "slds-hide");
                    //"$Label.c.Pricing_Tender_Delete_Quote_Message"
                    let toastEvent = $A.get("e.force:showToast");    // NOSONAR
                    toastEvent.setParams({
                        title: "Success",
                        message: $A.get(
                            "$Label.c.Pricing_Tender_Delete_Quote_Message"
                        ),
                        duration: " 3000",
                        key: "info_alt",
                        type: "success",
                        mode: "dismissible"
                    });
                    toastEvent.fire();
                    helper.navigate(component, event, helper);
                } else {
                    //"$Label.c.Pricing_Tender_Delete_Quote_Message"
                    component.set("v.messageNotification", $A.get("$Label.c.Pricing_QuoteDelete_No_Access_Error_Message"));
                    component.set("v.isSuccess", returnValue);
                    component.find("mySpinner").set("v.class", "slds-hide");
                }
            }

        });
        $A.enqueueAction(action);
    },

    navigate: function (component, event, helper) {
        var navService = component.find("navService");  // NOSONAR
        var pageReference = {                       // NOSONAR
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'SBQQ__Quote__c',
                actionName: 'list'
            },
            state: {
                filterName: "Recent"
            }
        };
        navService.navigate(pageReference);
    }
})