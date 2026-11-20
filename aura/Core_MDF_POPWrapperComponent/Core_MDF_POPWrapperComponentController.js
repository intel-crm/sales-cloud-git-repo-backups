({
    doInit: function (component, event, helper) {
        let claimId = component.get("v.recordId")
        helper.checkUserAccessAndFetchAuditDocDetails(component, claimId);
    },
    openManageAuditDocumentSection: function (component, event, helper) {
        component.set("v.openManageAuditDocumentWrapperComp", true);
        component.set("v.openManageAuditDocPopup", true);
    }
})