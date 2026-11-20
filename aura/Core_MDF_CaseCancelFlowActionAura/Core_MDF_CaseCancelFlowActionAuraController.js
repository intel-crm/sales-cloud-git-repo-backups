({
    doInit : function(component, event, helper) {
        helper.checkAccessAndStartFlow(component);
    },

    handleStatusChange : function(component, event, helper) {
        const status = event.getParam('status');
        const applicationErrorMessage = $A.get('$Label.c.Core_MDF_ApplicationErrorMessage');

        if (status === 'ERROR') {
            $A.get('e.force:showToast').setParams({
                title: 'Error',
                message: applicationErrorMessage,
                type: 'error'
            }).fire();

            $A.get('e.force:closeQuickAction').fire();
            $A.get('e.force:refreshView').fire();
            return;
        }

        if (status !== 'FINISHED' && status !== 'FINISHED_SCREEN') {
            return;
        }

        const outputVariables = event.getParam('outputVariables') || [];
        const showErrorToast = outputVariables.some(function(outputVariable) {
            return outputVariable.name === 'showErrorToast' && outputVariable.value;
        });
        const showSuccessToast = outputVariables.some(function(outputVariable) {
            return outputVariable.name === 'showSuccessToast' && outputVariable.value;
        });

        if (showErrorToast) {
            $A.get('e.force:showToast').setParams({
                title: 'Error',
                message: applicationErrorMessage,
                type: 'error'
            }).fire();
        }

        if (showSuccessToast && !showErrorToast) {
            $A.get('e.force:showToast').setParams({
                title: 'Success',
                message: 'Case cancelled and claim released successfully.',
                type: 'success'
            }).fire();
        }

        $A.get('e.force:closeQuickAction').fire();
        $A.get('e.force:refreshView').fire();
    }
})