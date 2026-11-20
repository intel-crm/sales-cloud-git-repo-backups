({
    doInit: function (component, event, helper) {
        const action = component.get("c.getPicklistValues");
        component.set("v.LexSpinner", true);
        action.setParams({
            "designRegisId": component.get("v.recordId"),
            "objectType": "Core_Design_Registration__c",
            "fieldName": "Core_Rejection_Reason_Nm__c"
        });
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const message = response.getReturnValue().message;
                component.set("v.designRegisObject", response.getReturnValue().designRegisObj);
                if (message === "success") {
                    component.set("v.alertMessage", "success");
                    const allValues = response.getReturnValue().pickListValueList;
                    const opts = [];
                    if (allValues !== undefined && allValues.length > 0) {
                        for (let i = 0; i < allValues.length; i++) {
                            if (i === 0) {
                                opts.push({
                                    class: "optionClass",
                                    label: allValues[i],
                                    value: allValues[i],
                                    selected: true
                                });
                            } else {
                                opts.push({
                                    class: "optionClass",
                                    label: allValues[i],
                                    value: allValues[i]
                                });
                            }
                        }
                    }
                    component.find("pickList").set("v.options", opts);
                } else {
                    component.set("v.alertMessage", "error");
                    component.set("v.message", message);
                }
            } else {
                console.log("Error on fetching picklist values " + response.getError());
            }
            component.set("v.LexSpinner", false);
        });
        $A.enqueueAction(action);
    },

    saveDesignRegistration: function (component, event, helper) {
        component.set("v.disableSaveBtn", true);
        component.set("v.LexSpinner", true);
        const designObj = component.get("v.designRegisObject");
        if (
            typeof component.get("v.designRegisObject.Core_Rejection_Comment_Txt__c") == "undefined" ||
            component.get("v.designRegisObject.Core_Rejection_Comment_Txt__c") === ''
        ) {
            let msg = 'Please enter some valid input. \n';
            msg += 'Input is not optional. \n';
            msg += 'You must enter a value.';
            const inputCmp = component.find("commentText");
            inputCmp.set("v.errors", [{ message: msg }]);
        } else {
            component.set("v.commentError", "");
            const action = component.get("c.updateDesignRegistration");
            action.setParams({
                designRegis: designObj
            });
            action.setCallback(this, function (response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    console.log("execute " + JSON.stringify(response.getReturnValue()));
                    component.set("v.alertMessage", '');
                    component.set("v.alertMsg", response.getReturnValue());
                } else {
                    console.error('Error on updating Design ' + response.getError());
                    const errMsg = LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c;
                    component.set("v.alertMsg", errMsg);
                    component.set("v.disableSaveBtn", true);
                }
                component.set("v.LexSpinner", false);

                $A.get("e.force:refreshView").fire();
            });

            $A.enqueueAction(action);
        }
    },

    cancelPopup: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    },
})