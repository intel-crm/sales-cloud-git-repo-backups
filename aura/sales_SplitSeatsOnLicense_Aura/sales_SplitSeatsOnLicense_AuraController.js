({
    closeQuickAction : function(component, event, helper) {
        console.log('Inside aura');
      
        $A.get("e.force:closeQuickAction").fire();
        
    },
    
})