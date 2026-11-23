({
    doInit: function (component, event, helper) {
        const action = component.get("c.getQuoteDetails");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.quote", response.getReturnValue());
                const quoteDetail = component.get("v.quote");
                const isSVDActive = component.get("c.getSVDQuoteActiveStatus");
                isSVDActive.setCallback(this, function (response) {
                    const state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.isSVDActive", response.getReturnValue());
                    }
                });
                $A.enqueueAction(isSVDActive);

                if (quoteDetail.Pricing_Program_Type_Nm__c == $A.get("$Label.c.Pricing_Tender_Small_Volume_Quote")) {
                    component.set("v.isSVD", true);
                    component.set("v.isSuccess", true);
                    let options = [];
                    options.push({ value: $A.get("$Label.c.Pricing_Tender_Standard_Quote"), label: $A.get("$Label.c.Pricing_Tender_Standard_Quote") });

                    component.set("v.value", $A.get("$Label.c.Pricing_Tender_Small_Volume_Quote"))
                    const isSVDAllowed = component.get("c.isSVDCloneAllowed");
                    if (quoteDetail.Pricing_Program_Type_Nm__c != $A.get("$Label.c.Pricing_Tender_Standard_Quote")) { //Add SVD only if SSD,PMem or Nic quotes
                        isSVDAllowed.setParams({ accId: quoteDetail.SBQQ__Account__c });
                        isSVDAllowed.setCallback(this, function (response) {
                            const state = response.getState();
                            if (state === "SUCCESS") {
                                if (response.getReturnValue() && component.get("v.isSVDActive")) {
                                    options.splice(1, 0, { value: $A.get("$Label.c.Pricing_Tender_Small_Volume_Quote"), label: $A.get("$Label.c.Pricing_Tender_Small_Volume_Quote") });
                                    component.set("v.options", options);
                                } else {
                                    component.set("v.options", options);
                                }
                            } else {
                                component.set("v.options", options);
                            }
                        });
                        $A.enqueueAction(isSVDAllowed);
                    } else {
                        component.set("v.options", options);
                    }
                } else {
                    component.find("mySpinner").set("v.class", "slds-show");
                    component.set("v.showMessageScreen", true);
                    helper.cloneQuote(component);
                }
            } else {
                console.error("Not able to get Quote data");
            }
        });
        $A.enqueueAction(action);
    },
    goBackLink: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    navigateToRecord: function (component, event, helper) {
        let navService = component.find("navService");  // NOSONAR
        let pageReference = {                         // NOSONAR
            "type": "standard__recordPage",
            "attributes": {
                "recordId": component.get("v.newRecordId"),
                "actionName": "view"
            }
        }

        navService.generateUrl(pageReference)
            .then($A.getCallback(function (url) {
                window.open(url, '_blank');
            }),
                $A.getCallback(function (error) {
                    console.error('error @ generateUrl: ' + error);
                }));
    },
    closeModel: function (component, event, helper) {
        component.set("v.isSVD", false);
        let dismissActionPanel = $A.get("e.force:closeQuickAction");  // NOSONAR
        dismissActionPanel.fire();
    },
    handleChange: function (component, event, helper) {
        let changeValue = event.getParam("value");  // NOSONAR
        component.set("v.quoteType", changeValue);
        if (changeValue == $A.get("$Label.c.Pricing_Tender_Standard_Quote")) {
            component.set("v.showAddText", true);
        }
        else {
            component.set("v.showAddText", false);
        }
    },
    quoteClone: function (component, event, helper) {
        component.find("mySpinner").set("v.class", "slds-show");
        component.set("v.showMessageScreen", true);
        component.set("v.isSVD", false);
        helper.cloneQuote(component);
    }
})