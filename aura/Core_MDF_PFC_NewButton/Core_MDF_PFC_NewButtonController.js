({
    //Function called on click of handle check
    handleClick : function (component, event, helper) {    
         debugger;
        component.set("v.CheckNew",true);
        var toggleButton = component.find("newButton");
        $A.util.toggleClass(toggleButton, "toggle");
    },
    
    // Function Called on the load of the component
    checkObjectPermission: function(component, event, helper) {       
        console.log('inside chk permission');
      var action = component.get("c.checkSObjectCreatePermission");
        //pass the object name here for which you want
        //to fetch check the permission
        action.setParams({
            "objectName" : "PartnerFundClaim"
        });
        action.setCallback(this, function(response) {
            var permission = response.getReturnValue();
            component.set("v.objectCreatePermission", permission);
        });
        $A.enqueueAction(action);
    }
})