({
	doInit : function(component, event, helper) {
		var myPageRef = component.get("v.pageReference");
        var id = myPageRef.id;
        component.set('v.id', id);
	}
})