({
    handleCancel: function (component, event, helper) {
        component.set("v.confirmationValue", "Cancel");
        component.find("overlayLib").notifyClose();
    },
    handleOK: function (component, event, helper) {
        component.set("v.confirmationValue", "OK");
        
        component.find("overlayLib").notifyClose();
    }
})