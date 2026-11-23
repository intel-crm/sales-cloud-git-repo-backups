({
	doInit : function(component, event, helper) {
		var action = component.get("c.cloneAnySobjet");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                $A.get('e.force:closeQuickAction').fire();
                var fieldMap = response.getReturnValue();
                var createEvent = $A.get('e.force:createRecord');
                createEvent.setParams({
                    'entityApiName' : 'Core_Goal__c',
                    'defaultFieldValues' : fieldMap
                });
                createEvent.fire();
            }else{
                console.log("Error on fetching field values "+response.getError());
            }
        });
        $A.enqueueAction(action);
	},
    
    waiting: function(component, event, helper) {
        document.getElementById("Accspinner").style.display = "block";
    },
})