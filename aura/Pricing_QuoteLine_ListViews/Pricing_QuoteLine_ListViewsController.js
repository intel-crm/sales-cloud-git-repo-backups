({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.listValues");
        action.setParams({
            "objectInfo" : component.get("v.objectInfo")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var listViewResult = response.getReturnValue();
                if(listViewResult.length > 0){
                    
                    component.set("v.listViewResult",listViewResult);
                    
                    component.set("v.currentListViewName", listViewResult[0].developerName);
                    
                    component.set("v.showListView", true);     
                }            
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
                else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    onPicklistChange: function(component, event, helper) {
        
        component.set("v.showListView", false); 
        
        var lstViewName = event.getSource().get("v.value"); 
        
        component.set("v.currentListViewName", lstViewName);
    
        component.set("v.showListView", true); 
    },
})