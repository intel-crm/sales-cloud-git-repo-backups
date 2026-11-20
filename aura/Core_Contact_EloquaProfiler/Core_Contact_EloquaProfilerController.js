({
  
    doInit : function (component, event, helper) {
		helper.getUserDetails(component, event, helper);
    },
    openLink : function (component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
      	urlEvent.setParams({
      		"url": component.get("v.urlParams")
    	});
    	urlEvent.fire();
	},
    /*showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
   },
    
 	// this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },*/
})