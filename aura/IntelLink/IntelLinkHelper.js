({
    
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.reference_page_reference_type
    getPageReference : function(component) {
        
        if (component.get('v.pageReference')){
            console.log('if pageRefernce');
            return component.get('v.pageReference');
            
        } else if (component.get('v.page')) {
            console.log('if page');
            return {
                type: 'comm__namedPage',
                attributes: {
                    pageName: component.get('v.page')
                }
            };
        } else if (component.get('v.recordId')) {
            console.log('if recordID');
            return {
                type: "standard__recordPage",
                attributes: {
                    recordId: component.get('v.recordId'),
                    objectApiName: component.get('v.objectApiName'),
                    actionName: "view"
                }
            };
        } else if (component.get('v.objectApiName')) {
            console.log('if objectApName');
            return {
                type: "standard__objectPage",
                attributes: {
                    objectApiName: component.get('v.objectApiName'),
                    actionName: "list"
                },
                state: {
                    filterName: "Recent"
                }
            }
        }
        
   
        
    },
    // Note we truncate only the labels and not body types
    truncate: function(component, helper) {
        var truncate = component.get('v.truncate'),
            resetTruncated = component.get('v.truncatedString'),
            label = component.get('v.label');
        
        if (truncate > 3 && label && label.length > truncate-3) {
            component.set('v.truncatedString', label.substring(0,truncate-3).trim());
            resetTruncated = false;
        }
        
        if (resetTruncated) {
            component.set('v.truncatedString', '');
        }
    },
    resetUrl : function(component, helper) {
        var defaultUrl = component.get('v.url') || "#",
            params = '',
            pageReference = helper.getPageReference(component);
        
        if (pageReference) {
            if (component.get('v.params')) {
                params = '?';
                Object.keys(component.get('v.params')).forEach(function(key, idx) {
                    params = params + (idx == 0 ? '' : '&') + key + '=' + component.get('v.params')[key];
                });
                
            } else if (component.get('v.searchParams')) {
                params = '?search=' +
                    encodeURIComponent(JSON.stringify(component.get('v.searchParams')));
                
            }
            
            // ADDING TIMEOUT RESOLVES SALESFORCE BUG w/ NAVIGATION URL
            // Bug: When navigating back sometimes urlResponse will return
            // javascript:void(0) with same exact pageReference.
            // - fix added 6/7/2019
            window.setTimeout($A.getCallback(function() {
                if (component.isValid()) {
                    component.find("navService").generateUrl(pageReference)
                    .then($A.getCallback(function(urlResponse) {
                        component.set("v._href", urlResponse ? urlResponse + params : defaultUrl);
                    })).catch($A.getCallback(function(error) {
                        component.set("v._href", defaultUrl);
                    }));
                }
            }), 100);
            
            
        } else {
            // if (defaultUrl !== "#" && !defaultUrl.match(/^[a-zA-Z]+:\/\//)) {
            //   defaultUrl = 'http://' + defaultUrl;
            // }
            component.set('v._href', defaultUrl);
            console.log(defaultUrl);
        }
    },
    
    /**
   	* Posts a message to the window message listener in the HEAD script. This will
    * cause the listener to call the salesforceHit method for logging the data to
    * the analytics engine.
   	* @param {Object} component  The Lightning web component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
  	*/
    makeAnalyticsCall: function (component){
        var analyticsLibrary = component.find("analyticsLibrary");
        
        // Default pageType and title
        var pageType = component.get("v.pageType") || '';
        var title = component.get("v.title") || '';       
        
        // Get the Offering and Partner IDs
        var offeringId = analyticsLibrary.getOfferingId(component);
        var partnerId = analyticsLibrary.getPartnerId(component) || component.get("v.partnerMDAId"); //Added the 'Or' condition so that PartnerMDA Id is fetched up from OfferingDetailPage.
        
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
            //Not required , since the title is passed from respectvie component
            //title = metaData.title || '';
        }         
        // Create the parameters for the analytics post
        var messageData = {
            analyticsType: 'click',
            element : component.get("v.LabelHeader") || '',
            offeringId : offeringId,
            pageTitle : title,
            pageType: pageType, 
            partnerMDAId : partnerId,
            targetURL : component.get('v.url') || component.get('v._href') || ''
        };
        
        // Call the helper library to log the analytics data
        analyticsLibrary.makeAnalyticsCall(messageData);
    },
   
    
})