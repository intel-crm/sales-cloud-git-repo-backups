({
    invoke : function(component, event, helper) {        
        return new Promise(function(resolve, reject) {
            $A.get("e.force:refreshView").fire();
            resolve();
        });
    }
})