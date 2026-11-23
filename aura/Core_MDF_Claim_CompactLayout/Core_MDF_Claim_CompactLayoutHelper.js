({
	call : function(action, params) {
        return new Promise($A.getCallback(function(resolve, reject) {
            if(params){
                action.setParams(params);
            }
            action.setCallback(this, function(a){
                if(a.getState() == "SUCCESS"){
                    resolve(a.getReturnValue());
                } else {
                    reject(a.getError());
                }
           });
           $A.enqueueAction(action);
        }));
    },

    quickActionFunction : function(component, quickAction, type, dependentCmpNameOrFieldValue) {
        if (type != 'Update') {
            if (quickAction == 'Clone') {
                component.set("v.openCmp", 'Clone');
            }
            else if (quickAction == 'Create Activity') {
                component.set("v.openCmp", 'Create Activity');
            }
            else if (quickAction == 'Edit') {
                console.log('Checking-- 30');
                component.set("v.openCmp", 'Edit');
            }
            component.set("v.openModalForLtCmp", true);
        } else if (type == 'Update') {
            component.set("v.openCmp", 'Update');
            component.set("v.openModalForUpdateButton", true);
            component.set("v.modalHeader", quickAction);
            var modalBodyDetail = quickAction == 'Cancel Campaign' ? 'Campaign' : 'Proposal';
            component.set("v.modalBody", modalBodyDetail);
            component.set("v.fieldValue", dependentCmpNameOrFieldValue);
        }
    }
})