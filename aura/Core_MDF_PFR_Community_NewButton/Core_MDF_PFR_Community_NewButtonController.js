({
    //Function called on click of handle check
    handleClick : function (cmp, event, helper) {
        console.log("alert");
        cmp.set("v.CheckNew",true);
    },
    
    // Function Called on the load of the component
    checkObjectPermission: function(component, event, helper) {
      var action = component.get("c.checkSObjectCreatePermission");
        //pass the object name here for which you want
        //to fetch check the permission
        action.setParams({
            "objectName" : "PartnerFundRequest"
        });
        action.setCallback(this, function(response) {
            var permission = response.getReturnValue();
            component.set("v.objectCreatePermission", permission);
        });
        $A.enqueueAction(action);
    }
})