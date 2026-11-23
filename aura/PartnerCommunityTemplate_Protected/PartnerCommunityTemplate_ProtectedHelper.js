({
	redirectUserToTnCPage : function(component) {
         
      var action = component.get("c.redirect");
        action.setParams({
                "siteUrl" : window.location.href
            });
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS") {
                
                if(response.getReturnValue()=='true'){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                "url": "/customerdisclaimer"
                });
                urlEvent.fire();
                window.location.reload(true);
                }
                else if(response.getReturnValue()==''){
                    var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/errorpage"
                            });
                             urlEvent.fire();
                    window.location.reload(true);
                }
             }             
            else {
                var errors = response.getError();
                if (errors) {
                     if (errors[0] && errors[0].message) {
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/errorpage"
                            });
                             urlEvent.fire();
                         window.location.reload(true);
                       }
                } 
                
            }
        });
         $A.enqueueAction(action);
	}
})