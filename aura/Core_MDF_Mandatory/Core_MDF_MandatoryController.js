({  
    Save: function(component, event, helper) {
        
        if(component.get("v.isCCF")){
            var action = component.get("c.saveRegionWiseData");        
            
            action.setParams({
                "rWList": component.get("v.regionWiseRecords")
            });       
        }
        
        else if(component.get("v.isDCF")){
            var action = component.get("c.saveCategoryWiseData");
            action.setParams({
                "cWList": component.get("v.categoryWiseRecords")
            });
            
        }        
        
        // set callback 
        action.setCallback(this, function(response) {
            var state = response.getState();
            var errors = response.getError();
            if (state === "SUCCESS") {              
                var closeModalEvent = component.getEvent("closeModalEvent");
                closeModalEvent.fire();
            }                
            
            if (state === "ERROR") {                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:$A.get("$Label.c.Core_MDF_CCF_DCF_ERROR"),
                    duration:'5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        
        // enqueue the server side action  
        $A.enqueueAction(action);
        
        
    }
})