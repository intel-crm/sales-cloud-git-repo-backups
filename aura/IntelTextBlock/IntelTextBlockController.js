({
	doInit : function(component, event, helper) {
     
       
             component.set('v.displaySection', helper.getDisplaySection(component)); 
        
      
        
     
       

          
    
                 
       },
    handleMoreClick : function(component, event, helper) {
        component.set("v.showMore", !component.get("v.showMore"));
        component.set('v.displaySection', helper.getDisplaySection(component));
        event.preventDefault();
	}
})