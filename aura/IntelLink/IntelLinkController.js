({

	doInit : function(component, event, helper) {
        
    	helper.resetUrl(component, helper);
		helper.truncate(component, helper);
	},

  handleReset : function(component, event, helper) {
    helper.resetUrl(component, helper);
		helper.truncate(component, helper);
  },
  
  handleClick : function(component, event, helper) {
		helper.makeAnalyticsCall(component);
        event.preventDefault();
        event.stopPropagation();
      
        //Added as part of DE77473 for checking the http in the URL
        var url = component.get('v.url') || component.get('v._href');
        if (component.get('v.openInBlank')) {
            if (!url.indexOf("http://") == 0 && !url.indexOf("https://") == 0) {
                url = 'http://' + url;
            }
  
           window.open(url);
            console.log('URL : ', url);
            console.log('v url : ', component.get('v.url'));
        } else {
            
            // Modified to add the ability to bypass the navigateToURL function - MGDANIES 10/29
            if (component.get('v.useNavigateToURL')) {
            	var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({ url: url });
                urlEvent.fire();
            } else {
               	window.location = url;
            }
       }      	
      
  }

})