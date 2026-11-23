({
    callAddMethod : function(component, event, helper) {
        var addAccCmp=component.find('Core_IPS_addAccountsLexId');
        addAccCmp.handleAdd('Add');
    },
    callAddDoneMethod : function(component, event, helper) {
        var addAccCmp=component.find('Core_IPS_addAccountsLexId');
        addAccCmp.handleAdd('AddDone');
    },
    callCancelMethod : function(component, event, helper) {
        var addAccCmp=component.find('Core_IPS_addAccountsLexId');
        addAccCmp.handleCancel();
    }
})