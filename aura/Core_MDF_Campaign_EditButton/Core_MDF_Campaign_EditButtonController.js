({
    doInit : function(component, event, helper) {
		helper.checkObjectPermission(component, event);
        helper.fetchRecordInfo(component, event); 
	},
    
    fetchFieldSetInfo : function(component, event, helper) {
        if(component.get("v.recordInfoLoaded")) {
        	helper.fetchFieldSetInfo(component, event);
        }
	},
    
    handleClick : function(component, event, helper) {
		component.set("v.CheckEdit",true);
	},
    
    // Function Called on Cancel or "X"
    closeModal: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId") ,
            "slideDevName": "detail"
        });
        navEvt.fire();
   	}
})