({
    closeModal: function(component) {
        var parentComponent = component.get("v.parentComponent");
        if (parentComponent) {
            var overlay = parentComponent.get("v.modalOverlay");
            if (overlay) {
                overlay.close();
                // Clear overlay reference after closing
                parentComponent.set("v.modalOverlay", null);
            }
        }
    },

    openIPAForm: function(component, parentComponent) {

        var recordTypeId            = parentComponent.get("v.selrecordtype");
        var recordTypeName          = parentComponent.get("v.selrecordtypeName");
        var recordTypeDeveloperName = parentComponent.get("v.selrecordtypeDeveloperName");

        if (!recordTypeId || !recordTypeName || !recordTypeDeveloperName) {
            var toastEvent = $A.get("e.force:showToast");
            if (toastEvent) {
                toastEvent.setParams({
                    title   : "Error",
                    message : "Invalid record type data. Please refresh the page.",
                    type    : "error",
                    duration: 5000
                });
                toastEvent.fire();
            }
            return;
        }

        // Close type selector modal first
        this.closeModal(component);

        // Open IPA form modal
        $A.createComponent(
            "c:Core_MDF_CreateEditOutcomeBasedActivity",
            {
                recordId               : parentComponent.get("v.recordId"),
                recordtype             : recordTypeId,
                recordtypeName         : recordTypeName,
                recordtypeDeveloperName: recordTypeDeveloperName
            },
            function(content, status) {
                if (status === "SUCCESS") {
                    var headerLabel = $A.get("$Label.c.Core_MDF_NewOutcomeBasedCampaign");
                    parentComponent.find("overlayLib").showCustomModal({
                        header          : headerLabel,
                        body            : content,
                        showCloseButton : true,
                        cssClass        : "slds-modal_large",
                        // Refresh the tab whenever this modal closes, whether via X, Cancel, or Save
                        closeCallback   : function() {
                            $A.get("e.force:refreshView").fire();
                        }
                    });
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    if (toastEvent) {
                        toastEvent.setParams({
                            title   : "Error",
                            message : "Failed to create IPA form. Please try again.",
                            type    : "error",
                            duration: 5000
                        });
                        toastEvent.fire();
                    }
                }
            }
        );
    },

    openClientForm: function(component, parentComponent) {
        this.fetchRecordTypeAndOpenForm(component, parentComponent, "c.getClientRecordType", "Client/Datacenter");
    },

    openDatacenterForm: function(component, parentComponent) {
        this.fetchRecordTypeAndOpenForm(component, parentComponent, "c.getDatacenterRecordType", "Datacenter");
    },

    fetchRecordTypeAndOpenForm: function(component, parentComponent, actionName, formLabel) {
        var self = this;
        var action = parentComponent.get(actionName);

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = response.getReturnValue();

                if (result && result.recordTypeId && result.recordTypeName && result.recordTypeDeveloperName) {
                    // Close type selector modal first
                    self.closeModal(component);

                    // Open CCF/DCF form modal with the correct record type for the selected program
                    $A.createComponent(
                        "c:Core_MDF_CreateEditCCFDCFOutcomeBasedActivity",
                        {
                            recordId               : parentComponent.get("v.recordId"),
                            recordtype             : result.recordTypeId,
                            recordtypeName          : result.recordTypeName,
                            recordtypeDeveloperName: result.recordTypeDeveloperName,
                            parentComponent         : parentComponent
                        },
                        function(content, status) {
                            if (status === "SUCCESS") {
                                var headerLabel = $A.get("$Label.c.Core_MDF_NewOutcomeBasedCampaign");
                                parentComponent.find("overlayLib").showCustomModal({
                                    header          : headerLabel,
                                    body            : content,
                                    showCloseButton : true,
                                    cssClass        : "slds-modal_large",
                                    // Refresh the tab whenever this modal closes, whether via X, Cancel, or Save
                                    closeCallback   : function() {
                                        $A.get("e.force:refreshView").fire();
                                    }
                                }).then(function(modalOverlay) {
                                    parentComponent.set("v.modalOverlay", modalOverlay);
                                });
                            } else {
                                self.showError("Failed to create " + formLabel + " form. Please try again.");
                            }
                        }
                    );
                } else {
                    self.showError("Invalid " + formLabel + " record type data. Please refresh the page.");
                }
            } else {
                self.showError("Unable to fetch " + formLabel + " record type. Please try again.");
            }
        });

        $A.enqueueAction(action);
    },

    showError: function(message) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title   : "Error",
                message : message,
                type    : "error",
                duration: 5000
            });
            toastEvent.fire();
        }
    }
})