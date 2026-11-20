({

  handleClick: function(component, event, helper) {
    
    var href = component.get('v.href');
     
    var openInNewTab = component.get('v.openInNewTab');
    var communityLink = component.get('v.communityLink');
     
    var previewMode = component.get('v.appState.Settings.previewMode');
	
    var onclick = component.get('v.onclick');
      
      
    if (previewMode) {
        
      	event.preventDefault();
	} else if (typeof onclick === 'function') {
			onclick(component, event, helper);
	} else {
    	if (openInNewTab && href) {
        	window.open(href);
      	} else if (href) {
        	window.location.href = href;
      	} else if (communityLink) {
        	var urlEvent = $A.get("e.force:navigateToURL");
        		urlEvent.setParams({
          		"url": communityLink
        	});
        	urlEvent.fire();
      	}
    }
  },

})