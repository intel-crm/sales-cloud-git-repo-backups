({
	doInit : function(component, event, helper) {
		var action =component.get("c.sendRequestToSAP");
        action.setParams({
            dpaId : component.get("v.recordId"),
            action:"submit"
        });
        action.setCallback(this,(response)=>{
            if(response.getState()==='SUCCESS'){
                if(response.getReturnValue().isSuccess){
                    helper.showToast('Success!',response.getReturnValue().message,'success');
                    $A.get("e.force:closeQuickAction").fire();
                    helper.refreshView();
                }else{
                    helper.showToast('Failed',response.getReturnValue().message,'error');
                    $A.get("e.force:closeQuickAction").fire();
                    helper.refreshView();
                }
            }else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        helper.showToast('Failed',errors[0].message,'error');
                        $A.get("e.force:closeQuickAction").fire();
                        helper.refreshView();
                    }
                } else {
                    console.log("Unknown error");
                    helper.showToast('Failed',"Unknown error",'error');
                    $A.get("e.force:closeQuickAction").fire();
                    helper.refreshView();
                }
            }
        });
        $A.enqueueAction(action);
	}
})