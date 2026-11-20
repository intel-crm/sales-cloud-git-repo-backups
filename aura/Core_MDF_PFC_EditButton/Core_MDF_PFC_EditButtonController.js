({
    //Function called on click of handle check
    handleClick : function (component, event, helper) {
        component.set("v.CheckEdit",true);
        var toggleButton = component.find("editButton");
        $A.util.toggleClass(toggleButton, "toggle");
    },
    
    // Function Called on the load of the component
    checkObjectPermission: function (component, event, helper) {
        console.log('rec id in Edit--' + component.get("v.recordId"));
        var action = component.get("c.hasAccessToEditClaim");
        //pass the object name here for which you want
        //to fetch check the permission
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var permission = response.getReturnValue();
            component.set("v.objectEditPermission", permission);
        });
        $A.enqueueAction(action);
    }
})