({
    doInit: function(component, event, helper) {
        // Fetch user creation permissions first. Only fetch IPA record type when user has IPA permission.
        var permAction = component.get("c.getUserCreationPermissions");
        permAction.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var perms = response.getReturnValue() || {};
                // showNewButton if user has any creation permission
                component.set("v.showNewButton", !!(perms.hasIPA || perms.hasCCF || perms.hasDCF));
                // store permissions on component for helper use
                component.set("v.userCreationPermissions", perms);
                component.set("v.permsFetched", true);

                // only fetch IPA record type when user has IPA permission; avoid blocking CCF/DCF-only users
                if (perms.hasIPA) {
                    helper.fetchIPARecordType(component);
                } else {
                    // ensure recordTypesFetched is false so UI doesn't require IPA fetch
                    component.set("v.recordTypesFetched", false);
                }
            } else {
                console.error('Error fetching creation permissions:', response.getError());
            }
        });
        $A.enqueueAction(permAction);
    
    },
    
    openModal: function(component, event, helper) {
        // Decide whether to open type selector or open a specific form directly
        helper.handleOpenModalFlow(component);
    }
})