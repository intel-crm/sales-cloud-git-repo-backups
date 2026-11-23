({
    closeQuickAction : function(component, event, helper) {
        console.log('Inside aura');
        
        $A.get("e.force:closeQuickAction").fire();
       $A.get('e.force:refreshView').fire();
	   $A.enqueueAction(action);
        
    }
    
})