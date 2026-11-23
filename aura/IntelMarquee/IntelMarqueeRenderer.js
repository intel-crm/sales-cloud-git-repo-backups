({
	/**
   	* Executes after the content has been rendered. By this point, the meta tags should be 
    * inserted into the DOM.
   	* @param {Object} component  The Lightning component object.
  	* @param {Object} helper  The Helper associated with this object.
    * Modification log : Added conditions to restrict pageView hit for search and quick search cases
  	*/
    afterRender: function (component, helper) {
        // Standard after render called
        this.superAfterRender();
        var windowUrl = window.location.href;
        var currentState = component.get('v.state');        
        var analyticsLibrary = component.find("analyticsLibrary");
        if(windowUrl.includes("search")){
            if(currentState.searchBoxPageName!='home' && !currentState.isQsearch){
                // Use the library component to generate the data and domain for the analytics message.
                // There is a window message listener in the HEAD script that will call the salesforceHit method.            
                var messageDomain = analyticsLibrary.getMessageDomain();
                var messageData = analyticsLibrary.getAnalyticsData(component.get("v.analyticsPageType"));
                window.postMessage(messageData, messageDomain);
            }
        }else{
            
            // Use the library component to generate the data and domain for the analytics message.
            // There is a window message listener in the HEAD script that will call the salesforceHit method.            
            var messageDomain = analyticsLibrary.getMessageDomain();
            var messageData = analyticsLibrary.getAnalyticsData(component.get("v.analyticsPageType"));
            window.postMessage(messageData, messageDomain);
                
        }

        // Add a canonical link
        analyticsLibrary.addCanonicalLink();
	},
})