({
	/**
   	* Calls the helper to add a canonical link to the page for SEO.
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
    * @return {Object} The data object to post to the window message listener.
  	*/
	  addCanonicalLink : function(component, event, helper) {
        return helper.addCanonicalLink(component, event, helper);
	},
    
    
    /**
   	* Calls the helper to get the analytics data object to post to the window message
    * listener in the HEAD script.
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
    * @return {Object} The data object to post to the window message listener.
  	*/
	  getAnalyticsData : function(component, event, helper) {
        return helper.getAnalyticsData(component, event, helper);
	},
    
    
    /**
   	* Calls the helper to get the message domain for posting to the window message
    * listener in the HEAD script.
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
    * @return {string} The domain to use when making making window.post calls.
  	*/
    getMessageDomain: function (component, event, helper) {
        return helper.getMessageDomain();
	},
    
    
    /**
   	* Calls the helper to get the Offering ID.
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
    * @return {string} The Offering ID if it is available, otherwise
    * an empty string.
  	*/
	// IPA2.0 + US TWC4497-1631
    // getOfferingId: function (component, event, helper) {
    //     return helper.getOfferingId(component, event, helper);
    // },
    
    
    /**
   	* Calls the helper to get the Partner ID.
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
    * @return {string} The Partner MDA ID if it is available, otherwise
    * an empty string.
  	*/
    getPartnerId: function (component, event, helper) {
        return helper.getPartnerId(component, event, helper);
	},
	

	/**
   	* Calls the helper to make a call to the analytics logger.
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
  	*/
	makeAnalyticsCall: function (component, event, helper) {
        return helper.makeAnalyticsCall(component, event, helper);
    }
})