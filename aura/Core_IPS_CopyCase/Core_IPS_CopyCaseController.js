({
	doInit: function(component, event, helper) {
        var pageref = component.get("v.pageReference");
        if(pageref !== undefined && pageref !== null) {
        	component.set("v.recordId", pageref.state.c__recordId);    
        }
	}
})