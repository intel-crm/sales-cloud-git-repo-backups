({
	doInit: function(component, event, helper) {
        //var compEvent = component.getEvent("closeActionModalEvent");
		//compEvent.fire();
		//var appEvent = $A.get("e.c:appEvent");
        //appEvent.fire();
        var pageref = component.get("v.pageReference");
        if(pageref !== undefined && pageref !== null) {
        	component.set("v.recordId", pageref.state.c__recordId);    
        }
	},
    handleClose: function(component, event, helper) {
        //const closeQA = new CustomEvent('close');
            // Dispatches the event.
        //this.dispatchEvent(closeQA);
    }
})