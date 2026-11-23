({
    loadModal : function(component, event, helper) {
        component.set('v.isLoadModal', true);
    },

    handleCancel: function(component, event, helper) {
        component.set('v.isLoadModal', false);
    }
})