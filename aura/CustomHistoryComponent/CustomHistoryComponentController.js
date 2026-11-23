({
    
    doInit : function(component, event, helper) {
        
         var action = component.get("c.loadData");
        action.setParams({ 
            recordId : component.get("v.recordId"),
            objectInfo : component.get("v.objectName"),
            internalUserName : 'Test',
            profiles : 'NA',
            permsets : 'NA',
            customperms : 'NA',
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 component.set("v.historyData",response.getReturnValue());

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);  
          $A.get('e.force:refreshView').fire();
        
        /*var action = component.get("c.getHistoryHeader");
        action.setParams({ 
            objectInfo : component.get("v.objectName")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 alert("From server: " + response.getReturnValue());
                component.set("v.historyHeaderData",response.getReturnValue());
                //this.loadData(component, event);

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
        
        */
        
     
    },
    
 
    
    handleHistoryDataChange: function(component, event) {
        console.log('event handled');
        
       // 
       component.set("v.objectName",event.getParam('value'));
       component.set("v.flag",event.getParam('flag'));
        if(component.get("v.flag")){
            location.reload();
            component.set("v.flag",false);
        }
       /*   console.log(component.get("v.objectName"));
        console.log(component.get("v.recordId"));
         
        var action = component.get("c.loadData");
        action.setParams({ 
            recordId : component.get("v.recordId"),
            objectInfo : component.get("v.objectName"),
            internalUserName : 'Test',
            profiles : 'NA',
            permsets : 'NA',
            customperms : 'NA',
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                alert("From server: " + response.getReturnValue());

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
         $A.get('e.force:refreshView').fire();*/
    },
  
  /*  handleRefresh : function(component, event) {

        var action = component.get("c.loadData");
        action.setParams({ 
            recordId : component.get("v.recordId"),
            objectInfo : component.get("v.objectName"),
            internalUserName : 'Test',
            profiles : 'NA',
            permsets : 'NA',
            customperms : 'NA',
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                alert("From server: " + response.getReturnValue());
component.set("v.historyData",response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
    },*/
    
    
});