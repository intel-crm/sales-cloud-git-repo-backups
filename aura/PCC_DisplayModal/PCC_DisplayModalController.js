({
	closeModel : function(component, event, helper) {
        //$A.get("e.force:closeQuickAction").fire();
        //$A.get('e.force:refreshView').fire();
        window.open(component.get("v.listViewUrl"),"_self");
	}
})