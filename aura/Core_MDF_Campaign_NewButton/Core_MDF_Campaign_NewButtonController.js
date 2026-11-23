({
	handleClick : function(component, event, helper) {
		component.set("v.CheckNew",true);
	},
    
   // Function Called on the load of the component 
    checkObjectPermission: function(component, event, helper) {
      var action = component.get("c.checkSObjectCreatePermission");
        action.setParams({
            "objectName" : "Campaign"
        });
        action.setCallback(this, function(response) {
            var permission = response.getReturnValue();
            console.log('permission'+permission);
            console.log('permission'+$A.get("$SObjectType.CurrentUser.Id"));
            component.set("v.objectCreatePermission", permission);
        });
        $A.enqueueAction(action);
    } 
})