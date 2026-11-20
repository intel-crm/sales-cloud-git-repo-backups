({
	doInit : function(component, event, helper) {
        helper.onInit(component, event);
    },
    
    handleMouseEnter : function(component, event, helper) {
        helper.displayTooltip(component, event); 
    },
    
    handleMouseLeave : function(component, event, helper) {
        helper.hideTooltip(component, event);
    }
    
})