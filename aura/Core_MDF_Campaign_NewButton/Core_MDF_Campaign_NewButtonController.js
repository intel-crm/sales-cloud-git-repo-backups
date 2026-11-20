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
            component.set("v.objectCreatePermission", permission);
        });
        $A.enqueueAction(action);
    } 
})