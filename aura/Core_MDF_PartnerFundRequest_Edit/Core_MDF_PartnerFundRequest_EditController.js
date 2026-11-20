({
	checkObjectPermission : function(component, event, helper) {
        var recordTypeDevName = component.get("c.getActivityRecordTypeDevname");
        recordTypeDevName.setParams({
            "recordId" : component.get("v.recordId")
        });
        recordTypeDevName.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
            var result = response.getReturnValue();            
            	component.set("v.recordtypeDeveloperName", result); 
            helper.fetchRecordInfo(component, event);
            }else{
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                helper.displaySuccessErrorMsg(errorMessage, "Error", "error");
            }
        });
        $A.enqueueAction(recordTypeDevName);
    },
   
})