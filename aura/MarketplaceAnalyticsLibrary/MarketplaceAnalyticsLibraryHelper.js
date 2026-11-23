({
    /**
   	* Adds a value to an object if the value is not already defined.
   	* @param {any} dataProperyValue  The value to add to the parent object.
  	* @param {string} parentPropertName  The property on the parent object whose value we are setting.
  	* @param {Object} parentObject  The parent object whose property we will add.
    */
    addAnalyticsProperty: function(dataPropertyValue, parentPropertName, parentObject) {
        // Make sure the value to add is defined and the property does not already have a value
        if (dataPropertyValue !== null && dataPropertyValue !== undefined && parentObject[parentPropertName] === undefined) {
            parentObject[parentPropertName] = dataPropertyValue;
        }
    },
    
    
    /**
   	* Adds a canonical link to the page for SEO.
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
  	*/
      addCanonicalLink : function(component, event, helper) {
        var fullUrl = 'https://' + window.location.host + window.location.pathname + '?language=' + $A.get("$Locale.langLocale"); 
        var linknode = !!document.querySelector("link[rel='canonical']") ? document.querySelector("link[rel='canonical']") : document.createElement('link');
        linknode.href = fullUrl;
        linknode.rel = 'canonical';
        document.head.appendChild(linknode);
    },
    

    /**
   	* Returns the analytics data object to post to the window message
    * listener in the HEAD script.
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
  	* @return {Object} The data object to post to the window message listener.
  	*/
    getAnalyticsData : function(component, event, helper) {
        var params = event.getParam("arguments");
		var urlStr = window.location.href;
        var urlStrWithoutQueryParams = window.location.href;
        var queryStringParamter = '';
            
        // Get the URL fields
        var splittedURL = urlStr.split("?");
        if(splittedURL != null && splittedURL.length !== undefined && splittedURL.length > 1) {
        	queryStringParamter = '?' + splittedURL[1];
        }
        urlStrWithoutQueryParams = splittedURL[0];                
        
        // Get the Offering and Partner IDs
        var offeringId = this.getOfferingId(component, event, helper);
        var partnerId = this.getPartnerId(component, event, helper);
        
        // Define pageType and title
        var pageType = params.analyticsPageType || '';
        var title = '';
        
		// Get the object representing the meta tags. The window.focus method is overwritten in the
        // HEAD script to return an object with meta tag values. This is done since the Locker service
        // stops this component from accessing the meta tags. If window.focus is called without the "true"
        // parameter, the standard window.focus method is called.
        var metaData = window.focus(true);
        if (metaData) {
            // Update pageType and title based on meta tags
            if (!pageType) {
                pageType = metaData.pageType || '';
            }
            title = metaData.title || '';
        }
       
        var messageData = {
            analyticsType: 'pageview',
            offeringId : offeringId,
            pageType: pageType, 
            partnerMDAId : partnerId,
            queryStringParamter : queryStringParamter,
            pageTitle: title,
            type: 'intel.salesForceHit',
            urlStr : urlStrWithoutQueryParams
        };
        
        return messageData;
	},
    
    
	/**
   	* Returns a domain for posting to the window message listener in the HEAD script.
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
    * @return {string} The domain to use when making making window.post calls.
  	*/
    getMessageDomain: function () {
    	return window.location.protocol + '//' + window.location.hostname + (window.location.port ? ':' + window.location.port : '');
	},
    
    
    
    /**
   	* Parses the URL to determine if it contains an Offering ID.
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
  	* @return {string} The Offering ID if it is available, otherwise
    * an empty string.
  	*/
    getOfferingId : function(component, event, helper) {
        var params = event.getParam("arguments");
        var offeringId = '';
        
        // Attempt to get the Offering ID from the component itself
        if (params.sourceComponent) {
            offeringId = params.sourceComponent.get("v.offeringId") || '';
        }
        
        // Only parse the URL if the offeringId attribute is empty
        if (!offeringId) {
            // Get the Offering ID from the URL
            var location = window.location.href;                
            var isOfferingPage = location.match(/\/offering\/[a-zA-Z0-9]{18}/);
            if(isOfferingPage != null){
                isOfferingPage += ''; 
                offeringId = isOfferingPage.slice(10);
            }
        }
        
        return offeringId;
	},
    
    
    
    /**
   	* Parses the URL to determine if it contains an Partner MDA ID.
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
  	* @return {string} The Partner MDA ID if it is available, otherwise
    * an empty string.
  	*/
    getPartnerId : function(component, event, helper) {
        var params = event.getParam("arguments");
        var partnerId = '';
        
        // Attempt to get the Partner ID from the component itself
        if (params.sourceComponent) {
            partnerId = params.sourceComponent.get("v.partnerMDAId") || '';
        }
        
        // Only parse the URL if the partnerId attribute is empty
        if (!partnerId) {
            // Get the Partner ID from the URL
            var location = window.location.href;                
        	var isPartnerPage = location.match(/\/partner\/[a-zA-Z0-9]{18}/);
            if(isPartnerPage != null){
                isPartnerPage += ''; 
                partnerId = isPartnerPage.slice(9);
            }
        }
        
        return partnerId;
    },


    /**
    * Makes a window.postMessage call with the analytics data that will be caught by code in the community 
    * HEAD element and logged in Adobe Analytics. 
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
  	*/
    makeAnalyticsCall: function (component, event, helper) {
        var params = event.getParam("arguments");
        if (params.messageData) {
            var messageDomain = this.getMessageDomain();
            var messageData = params.messageData;

            // Get the URL properties if they are not set or are blank
            if (!messageData.queryStringParamter || !messageData.urlStrWithoutQueryParams) {
                var urlStr = window.location.href;
                var urlStrWithoutQueryParams = window.location.href;
                var queryStringParamter = '';
                
                if(urlStr !== null || urlStr !== undefined){
                    var splittedURL = urlStr.split("?");
                    if(splittedURL != null && splittedURL.length !== undefined && splittedURL.length > 1) {
                        queryStringParamter = '?' + splittedURL[1];
                    }
                    urlStrWithoutQueryParams = splittedURL[0];
                }
            
                this.addAnalyticsProperty(queryStringParamter, 'queryStringParamter', messageData);
                this.addAnalyticsProperty(urlStrWithoutQueryParams, 'urlStr', messageData);
            }

            // Get the pageType if it is not set or is blank
            if (!messageData.pageType) {
                // Get the object representing the meta tags. The window.focus method is overwritten in the
                // HEAD script to return an object with meta tag values. This is done since the Locker service
                // stops this component from accessing the meta tags. If window.focus is called without the "true"
                // parameter, the standard window.focus method is called.
                var metaData = window.focus(true);
                if (metaData) {            
                    // Update pageType based on meta tags
                    this.addAnalyticsProperty(metaData.pageType || '', 'pageType', messageData);
                    this.addAnalyticsProperty(metaData.title || '', 'pageTitle', messageData);
                }
            }

            this.addAnalyticsProperty('intel.salesForceHit', 'type', messageData);
            this.addAnalyticsProperty(messageData.labelHeader, 'element', messageData);
            
            
            // This will be picked up by the listener in the HEAD script
            window.postMessage(messageData, messageDomain);
        }
	}
})