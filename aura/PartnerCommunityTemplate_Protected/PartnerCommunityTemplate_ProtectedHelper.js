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
                this.pageReload('/customerdisclaimer');
                }
                else if(response.getReturnValue()==''){
                    var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/errorpage"
                            });
                             urlEvent.fire();
                    this.pageReload('/errorpage');
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
                         this.pageReload('/errorpage');
                       }
                } 
                
            }
        });
        $A.enqueueAction(action);
    },

    pageReload: function (url) {
        setTimeout(() => {
            console.log('window.location.href', window.location.href);
            if(window.location.href.includes(url)) {
                window.location.reload(true);
            }
        }, $A.get("$Label.c.Core_MDF_CommunityPageReload_Timer"))
    }
})