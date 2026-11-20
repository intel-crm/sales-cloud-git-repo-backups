({
    doInit: function (component, event, helper) {
        // Show spinner during processing
        component.find("mySpinner").set("v.class", "slds-show");
        component.set("v.errorMsg", $A.get("$Label.c.Pricing_Tender_API_Quote_SVD_Submit_Error_Msg"));
        const action = component.get("c.getQuoteDetails");
        let idToBePass = '';
        if (component.get("v.sObjectName") == 'SBQQ__Quote__c') {
            idToBePass = component.get("v.recordId");
        } else if (component.get("v.sObjectName") == 'SBQQ__QuoteLine__c') {
            idToBePass = component.get("v.quoteId");
        }
        action.setParams({ recordId: idToBePass });
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                let quote = response.getReturnValue();
                // Check if Quote is of type "Small Volume"
                if (quote.Pricing_Program_Type_Nm__c === $A.get("$Label.c.Pricing_Tender_Small_Volume_Quote")) {
                    // Fetch SVD Active Status
                    const svdAction = component.get("c.getSVDQuoteActiveStatus");
                    svdAction.setCallback(this, function (svdResponse) {
                        let svdState = svdResponse.getState();
                        if (svdState === "SUCCESS") {
                            component.set("v.isSVDActive", !svdResponse.getReturnValue());
                            // Call helper method if applicable
                            if (!component.get("v.isSVDActive")) {
                                helper.processTenderQuote(component);
                            }
                        } else if (svdState === "ERROR") {
                            let errors = response.getError();
                            component.set("v.messageNotification", errors[0].message);
                            console.error("Error fetching SVD Active Status: ", errors[0].message);
                        }
                    });
                    $A.enqueueAction(svdAction);
                } else {
                    helper.processTenderQuote(component);
                }
            } else if (state === "ERROR") {
                let errors = response.getError();
                component.set("v.messageNotification", errors[0].message);
                console.error("Error fetching Quote Details: ", errors[0].message);
            }
        });
        $A.enqueueAction(action);
        component.set("v.isLoad", true);
        //component.find("mySpinner").set("v.class", "slds-hide");
    },

    goBackLink: function (component, event, helper) {
        // Close the Quick Action
        $A.get("e.force:closeQuickAction").fire();
        let isQuoteLineApproval = component.get("v.isQuoteLineApproval");
        component.set("v.isModelOpen", false);
        if (isQuoteLineApproval) {
            let method = component.get("v.method");
            $A.enqueueAction(method);
        } else {
            // Refresh the view
            $A.get("e.force:refreshView").fire();
        }
    }
});