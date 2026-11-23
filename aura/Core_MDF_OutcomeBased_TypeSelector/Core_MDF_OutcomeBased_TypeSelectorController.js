({
    handleTypeChange: function(component, event, helper) {
        var selectedValue = event.target.value;
        component.set("v.selectedType", selectedValue);
    },

    doInit: function(component, event, helper) {
        // Read parent permissions and hide/show options accordingly
        // Prefer permissions passed directly; fall back to parent's attribute if not provided
        var perms = component.get('v.userCreationPermissions') || (component.get('v.parentComponent') && component.get('v.parentComponent').get('v.userCreationPermissions')) || {};
        component.set('v.showIPAOption', !!perms.hasIPA);
        component.set('v.showClientOption', !!perms.hasCCF);
        component.set('v.showDatacenterOption', !!perms.hasDCF);

        // If only one option available, auto-open it
        var available = [];
        if (component.get('v.showClientOption')) available.push('Client');
        if (component.get('v.showDatacenterOption')) available.push('Datacenter');
        if (component.get('v.showIPAOption')) available.push('IntelPartnerAlliance');

        if (available.length === 1) {
            var parent = component.get('v.parentComponent');
            var only = available[0];
            if (only === 'IntelPartnerAlliance') helper.openIPAForm(component, parent);
            else if (only === 'Client') helper.openClientForm(component, parent);
            else if (only === 'Datacenter') helper.openDatacenterForm(component, parent);
        }
    },

    handleCancel: function(component, event, helper) {
        helper.closeModal(component);
    },

    handleNext: function(component, event, helper) {
        var selectedType = component.find("campaignTypePickList").get("v.value");

        if (!selectedType) {
            var toastEvent = $A.get("e.force:showToast");
            if (toastEvent) {
                toastEvent.setParams({
                    title   : "Warning",
                    message : "Please select a Campaign Type before proceeding.",
                    type    : "warning",
                    duration: 4000
                });
                toastEvent.fire();
            }
            return;
        }

        var parentComponent = component.get("v.parentComponent");

        if (selectedType === "IntelPartnerAlliance") {
            helper.openIPAForm(component, parentComponent);

        } else if (selectedType === "Client") {
            helper.openClientForm(component, parentComponent);

        } else if (selectedType === "Datacenter") {
            helper.openDatacenterForm(component, parentComponent);
        }
    }
})