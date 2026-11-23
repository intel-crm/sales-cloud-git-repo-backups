({
    fetchRecordTypes: function (component) {
        component.set("v.isRecordTypeLoading", true);
        component.set("v.errorMessage", "");

        var action = component.get("c.getCCFDCFOutcomeRecordTypes");
        if (action.setStorable) {
            action.setStorable();
        }
        action.setCallback(this, function (response) {
            component.set("v.isRecordTypeLoading", false);

            if (response.getState() !== "SUCCESS") {
                component.set("v.errorMessage", "Unable to load record types. Please try again.");
                return;
            }

            var result = response.getReturnValue() || {};
            var options = result.recordTypeOptions || [];
            component.set("v.recordTypeOptions", options);
            component.set("v.recordTypeIdByDeveloperName", result.recordTypeDevNameAndId || {});
            component.set("v.recordTypeLabelByDeveloperName", result.recordTypeDevNameAndLabelName || {});

            if (options.length === 0) {
                component.set("v.errorMessage", $A.get("$Label.c.Core_MDF_NoRecordTypeAccess"));
                return;
            }

            if (options.length === 1) {
                component.set("v.selectedRecordTypeDeveloperName", options[0].value);
                this.prepareSelectedRecordType(component);
            }
        });

        $A.enqueueAction(action);
    },

    clearPreparedForm: function (component) {
        component.set("v.selectedRecordTypeId", "");
        component.set("v.selectedRecordTypeName", "");
        component.set("v.preparedRecordTypeDeveloperName", "");
        component.set("v.preparedFormBody", null);
        component.set("v.isFormReady", false);
        component.set("v.isFormLoading", false);
    },

    prepareSelectedRecordType: function (component) {
        if (component.get("v.isRecordTypeLoading")) {
            return;
        }

        var selectedDeveloperName = component.get("v.selectedRecordTypeDeveloperName");
        if (!selectedDeveloperName) {
            this.clearPreparedForm(component);
            component.set("v.errorMessage", "");
            return;
        }

        var idByDeveloperName = component.get("v.recordTypeIdByDeveloperName") || {};
        var labelByDeveloperName = component.get("v.recordTypeLabelByDeveloperName") || {};
        if (!idByDeveloperName[selectedDeveloperName] || !labelByDeveloperName[selectedDeveloperName]) {
            this.clearPreparedForm(component);
            component.set("v.errorMessage", "Selected record type is not ready. Please try again.");
            return;
        }

        component.set("v.selectedRecordTypeId", idByDeveloperName[selectedDeveloperName]);
        component.set("v.selectedRecordTypeName", labelByDeveloperName[selectedDeveloperName]);
        component.set("v.preparedRecordTypeDeveloperName", selectedDeveloperName);
        component.set("v.preparedFormBody", null);
        component.set("v.isFormReady", false);
        component.set("v.isFormLoading", true);
        component.set("v.errorMessage", "");

        $A.createComponent(
            "c:Core_MDF_CreateEditCCFDCFOutcomeBasedActivity",
            {
                recordId: component.get("v.recordId"),
                recordtype: idByDeveloperName[selectedDeveloperName],
                recordtypeName: labelByDeveloperName[selectedDeveloperName],
                recordtypeDeveloperName: selectedDeveloperName,
                parentComponent: component
            },
            function (createdComponent, status, errorMessage) {
                if (component.get("v.selectedRecordTypeDeveloperName") !== selectedDeveloperName) {
                    if (createdComponent && createdComponent.destroy) {
                        createdComponent.destroy();
                    }
                    return;
                }

                component.set("v.isFormLoading", false);
                if (status === "SUCCESS") {
                    component.set("v.preparedFormBody", createdComponent);
                    component.set("v.isFormReady", true);
                    return;
                }

                component.set("v.isFormReady", false);
                component.set("v.preparedFormBody", null);
                component.set("v.errorMessage", errorMessage || "Unable to initialize Client/Datacenter form. Please try again.");
            }
        );
    },

    renderSelectedRecordType: function (component) {
        if (component.get("v.isRecordTypeLoading") || component.get("v.isFormLoading")) {
            return;
        }

        var selectedDeveloperName = component.get("v.selectedRecordTypeDeveloperName");
        var labelByDeveloperName = component.get("v.recordTypeLabelByDeveloperName") || {};
        var preparedFormBody = component.get("v.preparedFormBody");

        if (!selectedDeveloperName) {
            component.set("v.errorMessage", "Please select a record type.");
            return;
        }

        if (!component.get("v.isFormReady") || !preparedFormBody || component.get("v.preparedRecordTypeDeveloperName") !== selectedDeveloperName) {
            component.set("v.errorMessage", "Please wait until the selected record type form is initialized.");
            return;
        }

        var overlayLib = component.find("overlayLib");
        if (!overlayLib) {
            component.set("v.errorMessage", "Unable to open Client/Datacenter form. Please try again.");
            return;
        }

        component.set("v.errorMessage", "");
        component.set("v.showSpinner", true);

        overlayLib.showCustomModal({
            header: labelByDeveloperName[selectedDeveloperName],
            body: preparedFormBody,
            showCloseButton: true,
            cssClass: "slds-modal_large"
        }).then(function (overlay) {
            component.set("v.modalOverlay", overlay);
            component.set("v.renderForm", true);
            component.set("v.showSpinner", false);
        });
    },

    closeModal: function (component) {
        var closeQuickAction = $A.get("e.force:closeQuickAction");
        if (closeQuickAction) {
            closeQuickAction.fire();
            return;
        }

        var recordId = component.get("v.recordId");
        var navigateToRecord = $A.get("e.force:navigateToSObject");
        if (recordId && navigateToRecord) {
            navigateToRecord.setParams({
                recordId: recordId,
                slideDevName: "detail"
            });
            navigateToRecord.fire();
            return;
        }

        var navigateHome = $A.get("e.force:navigateToObjectHome");
        if (navigateHome) {
            navigateHome.setParams({
                scope: "PartnerFundRequest"
            });
            navigateHome.fire();
        }
    }
})