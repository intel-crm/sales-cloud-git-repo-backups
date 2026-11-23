({
	doInit : function(component, event, helper) {
        helper.fetchClaimRecord(component);
	},
    closeModal: function(component, event, helper) {
        $A.get("e.force:refreshView").fire();
        component.set("v.showErrorModalOnEditClaim", false);
    }
})