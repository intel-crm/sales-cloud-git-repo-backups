({
	checkObjectPermission : function(component, event, helper) {
        var action = component.get("c.checkSObjectCreatePermission");
        //pass the object name here for which you want
        //to fetch check the permission
        action.setParams({
            "objectName" : "PartnerFundRequest"
        });
        action.setCallback(this, function(response) {
            var permission = response.getReturnValue();
            if(permission == true){
            	component.set("v.objectCreatePermission", permission);
            }else{
                component.set("v.showErrorCondition", true);
            }
        });
        $A.enqueueAction(action);
    },
    
    // Function Called on Cancel or "X"
    closeModal: function(component, event, helper) {
        var fundRequestRecId = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": fundRequestRecId,
            "slideDevName": "detail"
        });
        navEvt.fire();
   	},
    
})