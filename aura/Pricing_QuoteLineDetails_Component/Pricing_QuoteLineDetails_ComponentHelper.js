({
    editRecord: function (component, event, helper, quoteLineId) {
        console.log('quoteLineId::'+quoteLineId);
       
        const editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            navigationLocation: "RELATED_LIST_ROW",
            recordId: quoteLineId
        });
        console.log('editRecordEvent.fire():'+editRecordEvent);
        editRecordEvent.fire();
    },
    deleteRecord: function (component, event, helper, quoteLineId) {
        component.set("v.quoteLineToBeDeleted", quoteLineId);
        $A.createComponent("c:Pricing_Modal_Confirmation", {
            quoteLineToBeDeleted: component.getReference("v.quoteLineToBeDeleted"),
            confirmationValue: component.getReference("v.confirmationValue")
        }, function (
            content,
            status
        ) {
            if (status === "SUCCESS") {
                let modalFooter = content;   // NOSONAR
                component
                    .find("overlayLib")
                    .showCustomModal({
                        header: "Confirmation",
                        body: "Are you sure you want to delete this quote line?",
                        footer: modalFooter,
                        showCloseButton: false,
                        cssClass: "slds-text-align_center",
                        closeCallback: function (ovl) {
                            const confirmationValue = component.get("v.confirmationValue");
                            const quoteLineTobeDeleted = component.get("v.quoteLineToBeDeleted");
                            if (confirmationValue == "OK") {
                                const action = component.get("c.deleteRecord");
                                action.setParams({
                                    quoteLineId: quoteLineTobeDeleted
                                });
                                action.setCallback(this, function (response) {
                                    const state = response.getState();
                                    if (state === "SUCCESS") {
                                        const toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            title: "Success",
                                            message: $A.get(
                                                "$Label.c.Pricing_Tender_Delete_Quote_Line_Message"
                                            ),
                                            duration: " 3000",
                                            key: "info_alt",
                                            type: "success",
                                            mode: "dismissible"
                                        });
                                        toastEvent.fire();
                                        $A.get("e.force:refreshView").fire();
                                    } else {
                                        console.error(
                                            $A.get("$Label.c.Pricing_Tenders_QuoteLine_DeleteErrorMessage")
                                        );
                                    }
                                });
                                $A.enqueueAction(action);
                            } else if (confirmationValue == "Cancel") {
                                //closes the modal or popover from the component
                                component.find("overlayLib").notifyClose();
                            }
                        }
                    })
                    .then(function (overlay) {
                        console.log("Overlay is made");
                    });
            }
        });
    },
    handleSubmitForApproval: function (component, event, helper) {
        component.set("v.showApprovalErrorScreen", true);
    },
    sendRequest: function (component, event, helper, quoteLineId, integrationAction) {
        const action = component.get("c.insertOutbound");
        action.setParams({
            parentId: quoteLineId,
            action: integrationAction
        });
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const currentValue = "" + response.getReturnValue();
                if (currentValue == "Success") {
                    helper.showToastMessage(component, event, helper, "success", "Quote Line information has been sent to My Deals to " + integrationAction + " the deal.", "Success", "dismissible");
                }
                else if (currentValue.includes($A.get("$Label.c.Pricing_OverlapDeal_Error_Message"))) {
                    helper.showToastMessage(component, event, helper, "error", currentValue, "Error", "sticky");
                }
                else {
                    helper.showToastMessage(component, event, helper, "error", ("" + currentValue), "Error", "sticky");
                }

                // Close the spinner and enable button
                if (component.find("mySpinner") != undefined) {
                    component.find("mySpinner").set("v.class", "slds-hide");
                    component.set("v.isSpinner", false);
                    component.set("v.isDisabled", false);
                }
                $A.get("e.force:refreshView").fire();
            } else {
                helper.showToastMessage(component, event, helper, "error", "Error in sending request submission", "Error", "sticky");
                // Close the spinner and enable button
                if (component.find("mySpinner") != undefined) {
                    component.find("mySpinner").set("v.class", "slds-hide");
                    component.set("v.isSpinner", false);
                    component.set("v.isDisabled", false);
                }
                $A.get("e.force:refreshView").fire();
            }

        });
        // Show spinner and enable buttons
        if (component.find("mySpinner") != undefined) {
            component.find("mySpinner").set("v.class", "slds-show");
            component.set("v.isSpinner", true);
            component.set("v.isDisabled", true);
        }
        $A.enqueueAction(action);
    },
    showToastMessage: function (component, event, helper, type, message, title, modeStr) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: "3000",
            key: "info_alt",
            type: type,
            mode: modeStr
        });
        toastEvent.fire();
    },
    callRecordApproval: function (component, event, helper, showToast) {
        const action = component.get("c.recordApproval");
        action.setParams({
            quoteLineId: component.get("v.quoteLineId"),
            comments: component.get("v.comments"),
            status: component.get("v.approvalAction"),
            lineItem: component.get("v.quoteLine"),
            revisionComment: component.get("v.revisionComments"),
            showRevisionFields: component.get("v.showRevisionFields"),
            rejectionReason: component.get("v.selectedRejectionReasonsPickListValue"),
            lostReason: component.get("v.selectedLostReasonsPickListValue"),
        });
        action.setCallback(this, function (response) {
            const state = response.getState();
            const customExMessage = response.getReturnValue();
            if (state === "SUCCESS") {
                if (customExMessage !== null) {
                    let toastEvent = $A.get("e.force:showToast");   // NOSONAR
                    toastEvent.setParams({
                        title: "Error",
                        message: customExMessage,
                        type: "Error",
                        mode: "dismissible"
                    });
                    toastEvent.fire();
                } else {
                    /* modified for US1089347: Enhancement on Post to Chatter when using Revision options */
                    const comments = component.get("v.revisionComments");
                    if (((showToast == "show_revision_by_oem" || showToast == "show_revision_by_field") && comments == '') || showToast == "show_rollback_msg") {
                        const successMessage =
                            showToast == "show_revision_by_oem"
                                ? $A.get("$Label.c.Pricing_Tender_Revision_By_OEM_Message") : showToast == "show_rollback_msg"
                                    ? $A.get("$Label.c.Pricing_Tender_Rollbacl_By_OEM_Message")
                                    : $A.get("$Label.c.Pricing_Tender_Revision_By_Field_Message");

                        let toastEvent = $A.get("e.force:showToast");  // NOSONAR
                        toastEvent.setParams({
                            title: "Success",
                            message: successMessage,
                            type: showToast == "show_rollback_msg" ? "Success" : "Info",
                            mode: "dismissible"
                        });
                        toastEvent.fire();
                    }
                }
                // Close the spinner and enable button
                if (component.find("mySpinner") != undefined) {
                    component.find("mySpinner").set("v.class", "slds-hide");
                    component.set("v.isSpinner", false);
                    component.set("v.isDisabled", false);
                }

                component.set("v.isModalOpen", false);
                $A.get("e.force:refreshView").fire();
            }
        });
        // Show spinner and enable buttons
        if (component.find("mySpinner") != undefined) {
            component.find("mySpinner").set("v.class", "slds-show");
            component.set("v.isSpinner", true);
            component.set("v.isDisabled", true);
        }
        $A.enqueueAction(action);
    },

    clone: function (component, event, helper, quoteLineId) {
        let modalBody;
        $A.createComponent(
            "c:Pricing_QuoteLineClone",
            { recordId: quoteLineId },
            function (content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    component.find("overlayLib").showCustomModal({
                        body: modalBody,
                        showCloseButton: true,
                        closeCallback: function () {
                            $A.get("e.force:refreshView").fire();
                        }
                    });
                }
                component.set("v.menuItemDisable", false);
            }
        );
    },
    handleRevisionByOEM: function (component, event, helper) {
        helper.callRecordApproval(component, event, helper, "show_revision_by_oem");
    },
    handleRevisionByFIELD: function (component, event, helper) {
        helper.callRecordApproval(
            component,
            event,
            helper,
            "show_revision_by_field"
        );
    },
    requestChange: function (component, event, helper, quoteLineId) {
        const menuValue = component.get("v.actionStr");
        let message = "";

        if (menuValue == $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_Request_Change")) {
            message = $A.get("$Label.c.Pricing_Tender_CR_Existing_Request_Error");
        } else if (menuValue == $A.get("$Label.c.Pricing_Tender_Cancel_Action") || menuValue == $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_Won") || menuValue == $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_Lost")) {
            message = $A.get("$Label.c.Pricing_Tender_CR_Reference_Status_Change_Message");
        }

        const unifiedAction = component.get("c.isNotUnifiedQuoteLine");
        unifiedAction.setParams({
            quoteLineId: component.get("v.quoteLineId"),
            qliApprovedEndDate: component.get("v.qliIdToApprovedEndDateMap")[component.get("v.quoteLineId")],
            action: component.get("v.actionStr")
        });
        unifiedAction.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.wonMsg", response.getReturnValue());
                let result = component.get("v.wonMsg").split(";"); //index[0] = PendingCRExist OR customerBlocked, index[1] = Header, index[2] = unified msg OR QL number
                if (result !== undefined && result !== null) {
                    if (result[0] === 'PendingCRExist') {
                        message = message.replace('${quoteLineNumber}', result[2]);
                        component.find("notifLib").showNotice({
                            variant: "warning",
                            title: "",
                            header: result[1],
                            message: message
                        });
                    } else if (result[0] === 'customerBlocked' && menuValue == $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_Won") && result[2] !== 'Success') {
                        component.find("notifLib").showNotice({
                            variant: "warning",
                            title: "",
                            header: result[1],
                            message: result[2]
                        });
                    } else if (result[0] === 'expiredCR' && menuValue == $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_Request_Change")) {
                        component.find("notifLib").showNotice({
                            variant: "warning",
                            title: "",
                            header: result[1],
                            message: result[2]
                        });
                    }
                    else {
                        if (menuValue == $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_Request_Change")) {
                            this.openChangeRequest(component, event, helper, quoteLineId);
                        } else if (menuValue == $A.get("$Label.c.Pricing_Tender_Cancel_Action")) {
                            //this.cancelQuoteLine(component, event, helper, quoteLineId);
                            component.set("v.isModalOpen", true);
                        } else if (menuValue == $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_Won") || menuValue == $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_Lost")) {
                            component.set("v.isModalOpen", true);
                        }
                    }
                }

            } else {
                console.error('Error @ isNotUnifiedQuoteLine -->'+response);
            }
        });
        $A.enqueueAction(unifiedAction);

    },
    cancelQuoteLine: function (component, event, helper, quoteLineId) {
        const action = component.get("c.cancelRecord");
        action.setParams({
            quoteLineId: component.get("v.quoteLineId"),
            comments: component.get("v.comments")
        });
        action.setCallback(this, function (response) {
            const state = response.getState();
            const customExMessage = response.getReturnValue();
            if (state === "SUCCESS") {
                if (customExMessage !== null) {
                    const toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error",
                        message: customExMessage,
                        type: "Error",
                        mode: "dismissible"
                    });
                    toastEvent.fire();
                    if (component.find("mySpinner") != undefined) {
                        component.find("mySpinner").set("v.class", "slds-hide");
                        component.set("v.isSpinner", false);
                        component.set("v.isDisabled", false);
                    }
                    $A.get("e.force:refreshView").fire();
                } else {
                    const toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Success",
                        message: $A.get(
                            "$Label.c.Pricing_Tender_Cancel_Quote_Line_Message"
                        ),
                        duration: " 3000",
                        key: "info_alt",
                        type: "success",
                        mode: "dismissible"
                    });
                    toastEvent.fire();
                    // show spinner
                    if (component.find("mySpinner") != undefined) {
                        component.find("mySpinner").set("v.class", "slds-show");
                        component.set("v.isSpinner", false);
                        component.set("v.isDisabled", false);
                    }
                    component.set("v.isModalOpen", false);
                    $A.get("e.force:refreshView").fire();
                }
            } else {
                console.error(
                    $A.get("$Label.c.Pricing_Tender_QuoteLine_CancelErrorMessage")
                );
            }
        });
        // show spinner
        if (component.find("mySpinner") != undefined) {
            component.find("mySpinner").set("v.class", "slds-show");
            component.set("v.isSpinner", true);
            component.set("v.isDisabled", true);
        }
        $A.enqueueAction(action);
    },
    openChangeRequest: function (component, event, helper, quoteLineId) {
        let modalBody;
        const requestChange = $A.get(
            "$Label.c.Pricing_Tender_QuoteLine_Action_Request_Change"
        );
        $A.createComponent(
            "c:Pricing_QuoteLineRequestChange",
            {
                recordId: quoteLineId,
                action: requestChange,
                refreshParentComponent: component.getReference(
                    "v.refreshParentComponent"
                )
            },
            function (content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    component.find("overlayLib").showCustomModal({
                        body: modalBody,
                        header: requestChange,
                        showCloseButton: true,
                        closeCallback: function () {
                            const refreshParent = component.get("v.refreshParentComponent")
                            if (refreshParent) {
                                $A.get("e.force:refreshView").fire();
                            }
                        }
                    });
                }
            }
        );
    },
    handleRollback: function (component, event, helper) {  //method to call recordApproval for OEM Recall
        helper.callRecordApproval(component, event, helper, "show_rollback_msg");
    },
    getRejectionReasonsValue: function (component, event) {
        const rid = component.get("v.recordId");
        var action = component.get("c.getRejectionReasonsValue");
        action.setParams({
            recId: rid
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for (var key in result) {
                    fieldMap.push({ key: key, value: result[key] });
                }
                component.set("v.RejectionReasonsMap", fieldMap);
            } else {
                helper.showToastMessage(component, event, helper, "error", ("" + state), "Error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    getLostReasonValue: function (component, event) {
        var action = component.get("c.getLostReasonValue");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for (var key in result) {
                    fieldMap.push({ key: key, value: result[key] });
                }
                component.set("v.LostReasonMap", fieldMap);
            } else {
                helper.showToastMessage(component, event, helper, "error", ("" + state), "Error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },
    getRecommendedPrice: function (component, event, helper, quoteLineId) {//check on future methods
        let quotelinedata = component.get("v.quoteLines");
        let quoteLinNbr = quotelinedata.filter(element => element.Id == quoteLineId)[0].Pricing_Quote_Line_Number__c;
        var action = component.get("c.getRecommendedPrice");
        action.setParams({
            quoteLineId : quoteLineId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                const isError = response.getReturnValue();
                if(isError) {
                    helper.showToastMessage(component, event, helper, "error", "Error Occured", "Error", "sticky");
                } else {
                    helper.showToastMessage(component, event, helper, "success", "Agentic Callout is initiated to get the Price. Please Refresh after some time",quoteLinNbr,"dismissable");
                }
            } else {
                helper.showToastMessage(component, event, helper, "error", ("" + state), "Error", "sticky");
            }
        });
        $A.enqueueAction(action);
    }
});