({
	getProgramInfo : function (component, selectedValues, selectedDate) {
          var action = component.get("c.saveInactiveProgramData");
        action.setParams({ 
            'bankId'			: component.get("v.recordId"),
            'InactiveProgram' 	: selectedValues,
            'InactiveDate' 		: selectedDate
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: $A.get("$Label.c.Core_MDF_SuccessToastTitle"),
                    type: 'success',
                    message: 'Bank Inactivated Successfully'
                });
                toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();    
        }
        }),
            $A.enqueueAction(action);
	}
})