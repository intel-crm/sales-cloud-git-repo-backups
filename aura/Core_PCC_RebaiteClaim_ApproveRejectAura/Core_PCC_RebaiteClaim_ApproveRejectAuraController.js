({
    init: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },

    closeModal: function(component, event, helper) {
        component.set("v.isModalOpen", false);
        $A.get("e.force:closeQuickAction").fire();
    },

    save: function(component, event, helper) {
        // Add any additional save logic here if needed
        component.set("v.isModalOpen", false);
        $A.get("e.force:closeQuickAction").fire();
    }
})