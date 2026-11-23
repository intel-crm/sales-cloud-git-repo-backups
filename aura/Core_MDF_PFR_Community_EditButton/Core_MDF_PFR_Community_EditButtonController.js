({
	// Function Called on Cancel or "X"
    closeModal: function(component, event, helper) {
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                "scope": "PartnerFundRequest"
            });
            homeEvent.fire();
   	},
    
    // Function called on the click of the Edit button
    handleClick : function (cmp, event, helper) {
        console.log("alert");
        cmp.set("v.CheckEdit",true);
        //.body.style.overflow = "hidden";
    },
    
    // Function Called on the load of the component
    checkObjectPermission: function(component, event, helper) { 
      var action = component.get("c.checkSObjectEditPermission");
        //pass the object name here for which you want
        //to fetch check the permission
        action.setParams({
            "objectName" : "PartnerFundRequest"
        });
        action.setCallback(this, function(response) {
            var permission = response.getReturnValue();
            component.set("v.objectEditPermission", permission);
        });
        $A.enqueueAction(action);
    }
})