({
 init: function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var rId = myPageRef.state.c__recId;
        component.set("v.recId", rId);
    },
    
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})