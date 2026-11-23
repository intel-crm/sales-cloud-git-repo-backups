({
    doInit: function (component, event, helper) {
        helper.fetchRecordTypes(component);
    },

    handleNext: function (component, event, helper) {
        helper.renderSelectedRecordType(component);
    },

    handleRecordTypeChange: function (component, event, helper) {
        helper.prepareSelectedRecordType(component);
    },

    closeModal: function (component, event, helper) {
        helper.closeModal(component);
    }
})