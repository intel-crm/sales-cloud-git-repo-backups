({
    //This function is used to check the current user session type and redirects to provided url
    getCurrentSessionType: function(component, event, helper)  {
        //url - provided in community
        var extUrl = component.get("v.url");
        if(!$A.util.isUndefinedOrNull(extUrl) && extUrl !=""){
            //Live Preview session type available from community builder
            var livePreviewSessionType = $A.get("$Label.c.Core_LivePreview");
            var action = component.get("c.getCurrentSession");
            action.setCallback(this, function(response) {
                //session type
                var sessionType = response.getReturnValue();
                if(sessionType != livePreviewSessionType){
                    // opening url in a new tab for community user
                    window.open(''+extUrl+'');
                    //redirects to previous page
                    window.history.back();
                }
            });
            $A.enqueueAction(action);
        }
    }
})