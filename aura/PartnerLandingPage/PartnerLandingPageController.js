({
	doInit : function(component, event, helper) {
        
 /*var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": 'https://www.google.com/maps/place/'
    });
    urlEvent.fire();*/
        //  window.location = "/s/DisclaimerPage";
       
           
		},
    navigate:function(component, event, helper) {
        
          var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__DisclaimerPage',
            }
        };
        console.log('pageReference');
        console.log(pageReference);
		 var navService = component.find("navService");
              //  event.preventDefault();
                //navigate function navigates to page reference
                console.log(navService);
        //event.preventDefault();
                navService.navigate(pageReference);
    
    }
})