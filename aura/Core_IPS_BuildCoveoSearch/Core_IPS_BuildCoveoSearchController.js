({
    doInit : function(component, event, helper) {
        
        const getUserRole = function() {
            var action = component.get("c.getUserRole");
            action.setcallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var role = response.getReturnValue();
                }  
            });
            return role;
        }
      // $A.enqueueAction(action);
        
       /*
        var role;
        var action = component.get("c.getUserRole");
            action.setcallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    role = response.getReturnValue();
                }  
            });
         $A.enqueueAction(action);
        
        
        var getUserRole = function(){
            return role;
        }
        */
        
        // Get the Coveo SearchUI Component.
        var coveoSearchUI = component.find('CoveoAgentPanel');
        // Register this to be executed before the search-ui initialization.
        coveoSearchUI.registerBeforeInit(function (cmp, rootInterface, Coveo) {
            // Register an handler on the "buildingQuery" event.
            coveoSearchUI.proxyAddEventListener('buildingQuery', function (e, args) {
                // Add your context dictionary
                args.queryBuilder.addContext({
                    "userRole": getUserRole()
                });
            });
        });
    }
})