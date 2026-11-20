({
	checkObjectPermission : function(component, event, helper) {
       helper.doInit(component, event, helper);
    },

    closeQuickAction : function(component, event, helper) {
        if(component.get("v.isCustomComp")){
            let closeModalEvent = component.getEvent("closeModalEvent");
            closeModalEvent.fire();
        }
        else{
            $A.get("e.force:closeQuickAction").fire();
        }
    }
})