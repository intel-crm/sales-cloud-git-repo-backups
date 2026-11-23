({
    //Function called on click of New Button
    handleClick : function (component, event, helper) {    
        component.set("v.hasClickedNewButton",true);
    },
    
    // Function Called on the load of the component
    checkObjectPermission: function(component, event, helper) {       
      var action = component.get("c.checkSObjectCreatePermission");
        //pass the object name here for which you want
        //to fetch check the permission
        action.setParams({
            "objectName" : "Account"
        });
        action.setCallback(this, function(response) {
            var permission = response.getReturnValue();
            component.set("v.hasAccountRecordCreateAccess", permission);
        });
        $A.enqueueAction(action);
    }
})