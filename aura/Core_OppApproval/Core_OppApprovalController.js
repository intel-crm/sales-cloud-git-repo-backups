({
	handleClick : function(component, event, helper) {
        var action = component.get("c.checklistForApproval");
        action.setParams({
            "oppId" : component.get("v.recordId"),
            "comments" : component.get("v.comments")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.msg",result);
                               
            }else{
                component.set("v.msg","Something went wrong, please try again!");
            }
        });
        $A.enqueueAction(action);
	}
	
})