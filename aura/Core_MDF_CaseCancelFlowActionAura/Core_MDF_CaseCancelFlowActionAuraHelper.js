({
    FLOW_NAME : 'Core_MDF_Cancel_Case_Flow',
    ACCESS_DENIED_MESSAGE : 'Only Claim Case Reviewer Managers can cancel a case.',

    checkAccessAndStartFlow: function(component) {
        const applicationErrorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
        const action = component.get('c.getCancelCaseAccess');
        action.setCallback(this, function(response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                if (response.getReturnValue() === true) {
                    this.startFlow(component);
                } else if (response.getReturnValue() === false) {
                    this.handleServerExceptions(component, this.ACCESS_DENIED_MESSAGE);
                } else {
                    this.handleServerExceptions(component, applicationErrorMessage);
                }
                return;
            }

            this.handleServerExceptions(component, applicationErrorMessage);
        });
        $A.enqueueAction(action);
    },

    startFlow: function(component) {
        const flow = component.find('cancelCaseFlow');
        flow.startFlow(this.FLOW_NAME, [
            {
                name: 'recordId',
                type: 'String',
                value: component.get('v.recordId')
            }
        ]);
    },

    handleServerExceptions: function(component, message) {
        $A.get('e.force:showToast').setParams({
            title: 'Error',
            message: message,
            type: 'error'
        }).fire();

        $A.get('e.force:closeQuickAction').fire();
        $A.get('e.force:refreshView').fire();
    }
})