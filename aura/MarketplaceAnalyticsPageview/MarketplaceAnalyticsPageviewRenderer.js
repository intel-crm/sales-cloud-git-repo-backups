({
	/**
   	* Executes after the content has been rendered. By this point, the meta tags should be 
    * inserted into the DOM.
   	* @param {Object} component  The Lightning component object.
  	* @param {Object} helper  The Helper associated with this object.
  	*/
    afterRender: function (component, helper) {
        // Standard after render called
        this.superAfterRender();
        
        // Use the library component to generate the data and domain for the analytics message.
        // There is a window message listener in the HEAD script that will call the salesforceHit method.
        var analyticsLibrary = component.find("analyticsLibrary");
		var messageDomain = analyticsLibrary.getMessageDomain();
        var messageData = analyticsLibrary.getAnalyticsData(component.get("v.analyticsPageType"));
        window.postMessage(messageData, messageDomain);

        // Add a canonical link
        analyticsLibrary.addCanonicalLink();
	},
})