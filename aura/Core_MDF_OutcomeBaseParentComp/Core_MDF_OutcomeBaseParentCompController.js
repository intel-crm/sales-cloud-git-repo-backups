({
    doInit: function(component, event, helper) {
        helper.fetchIPARecordType(component);

        let action = component.get("c.hasNewCampaignAccess");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.showNewButton", response.getReturnValue());
            } else {
                console.error(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    // 🔹 SINGLE source of truth for opening modal
    openModal: function(component) {

        var recordTypeId = component.get("v.selrecordtype");
        var recordTypeName = component.get("v.selrecordtypeName");
        var recordTypeDeveloperName = component.get("v.selrecordtypeDeveloperName");

        if (!recordTypeId || !recordTypeName || !recordTypeDeveloperName) {
            helper.showToast(
                "Error",
                "Invalid record type data. Please refresh the page.",
                "error"
            );
            return;
        }

        $A.createComponent(
            "c:Core_MDF_CreateEditOutcomeBasedActivity",
            {
                recordId: component.get("v.recordId"),
                recordtype: recordTypeId,
                recordtypeName: recordTypeName,
                recordtypeDeveloperName: recordTypeDeveloperName
            },
            function(content, status) {
                if (status === "SUCCESS") {
                    component.find("overlayLib").showCustomModal({
                        header: $A.get("$Label.c.Core_MDF_NewOutcomeBasedCampaign"),
                        body: content,
                        showCloseButton: true,
                        cssClass: "slds-modal_large"
                    });
                } else {
                    helper.showToast("Error", "Failed to open modal", "error");
                }
            }
        );
    },

    // 🔁 Called from Save & New event
    handleReopenOverlay : function(component) {
        Console.log('its parent');
        // close existing modal
        component.find("overlayLib").notifyClose();

        // reopen fresh modal
        setTimeout(() => {
            this.openModal(component);
        }, 0);
    }
});