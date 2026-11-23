({
    doInit: function (component, event, helper) {
        helper.syncOptions(component);
    },

    handleOptionsChange: function (component, event, helper) {
        helper.syncOptions(component);
    },

    handleSelectedOptionsChange: function (component, event, helper) {
        helper.syncOptions(component);
    },

    handleSearch: function (component, event, helper) {
        helper.applyFilter(component);
    },

    handleOptionToggle: function (component, event, helper) {
        helper.toggleSelection(component, event.getSource().get("v.name"), event.getSource().get("v.checked"));
    },

    validateErrors: function (component, event, helper) {
        helper.validate(component);
    }
})