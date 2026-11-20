({
    
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.reference_page_reference_type
    getPageReference : function(component) {
        
        if (component.get('v.pageReference')){
            return component.get('v.pageReference');
            
        } else if (component.get('v.page')) {
            
            return {
                type: 'comm__namedPage',
                attributes: {
                    pageName: component.get('v.page')
                }
            };
        } else if (component.get('v.recordId')) {
            
            //Event Page Behavioural Analytics[US749107]            
            
            var evt=component.get('v.eventPage');
            let nav = {
                type: "standard__recordPage",
                attributes: {
                    recordId: component.get('v.recordId'),
                    objectApiName: component.get('v.objectApiName'),
                    actionName: "view"
                }
            }
            if(evt==true){
                nav.state = { icid:component.get('v.eventName') };
            } 
            return nav;    
            
        } else if (component.get('v.objectApiName')) {
             
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
            
        }
    },
    

    /**
   	* Calls the analytics library with link data. This will cause the listener
    * in the community HEAD to call the salesforceHit method for logging the data to
    * the analytics engine.
   	* @param {Object} component  The Lightning web component.
  	*/
    makeAnalyticsCall: function (component){
      var analyticsLibrary = component.find("analyticsLibrary");
      
      // Create the parameters for the analytics post
      var messageData = {
          analyticsType: 'click',
          element : component.get("v.LabelHeader") || '',
          pageTitle : component.get("v.title") || '',
          pageType: component.get("v.pageType") || '', 
          targetURL : component.get('v.url') || component.get('v._href') || ''
      };
        
      //Promotion Blade Web Analytics code Starts 
        if(component.get('v.eventPage')){
            var str = component.get('v.eventName');
      		var n = str.length;
      		var res = str.substring(16, n-1);//the slicing the eventName from "PromotionBlade:eventName"
             messageData.element ='learn-more';
          	 messageData.details = res || '';
        }
        //Promotion Blade Web Analytics code Ends 

      // Call the helper library to log the analytics data
      analyticsLibrary.makeIpaAnalyticsCall(messageData, component);
  },
   
})