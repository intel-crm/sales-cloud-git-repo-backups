({
    
    doInit:function(component,event,helper)
    {
        
        var newbutton = component.find('newmilestonebutton');
		$A.util.removeClass(newbutton, 'cMarketplaceThemeLayout');
		component.set("v.product",null);
        helper.getOfferingDetails(component,helper);
        var partnerName=component.get("v.partnerName");
        
    	try {
            var obj = {
              'integer': 12345,
              'string': 'string',
              'boolean': true
            };
        } catch(e) {
        	console.log(e);
        };
	/*----------------End------------------------------------------*/        
    },

	handleEditOffering : function(component, event, helper) {

	},

	handleViewOffering : function(component, event, helper) {

	},
    
    /********* Commented by Hemanta. This code has moved.  **********************
     * **************************************************************************/
	openRequestaQuote: function(component, event, helper) {
        
		// Set logged user details to null
		component.find("contactForm").set("v.userDetails", {});
		var appEvent = $A.get("e.c:MarketplacePageEvent");
		appEvent.setParams({
		  type: "openLeadGenModal",
		  payload: {
			 formType: "quote"
		  }
		});
		appEvent.fire();
	 },
	 openRequestaQuoteLoggedIn: function(component, event, helper) {
         
		// Set logged user details
		component
		  .find("contactForm")
		  .set("v.userDetails", component.get("v.userDetails"));

		var appEvent = $A.get("e.c:MarketplacePageEvent");
		appEvent.setParams({
		  type: "openLeadGenModal",
		  payload: {
			 formType: "quote"
		  }
		});
		appEvent.fire();
	 },
    openDisclaimer : function(component,event, helper) {
       window.open($A.get("$Label.c.PMP_DisclaimerURL"), '_blank');
  	},
    handleClone : function(component,event, helper) {
       helper.getClonedOfferingDetails(component,helper);
  	},
	
    closeModal : function(component, event, helper){
        var showButton = event.getParam('showButton');
		
        component.set("v.showDateChangeSection",false);
        component.set("v.showDateChangeButton",showButton);
    },
    openDateChange : function(component, event, helper){
        component.set("v.showDateChangeSection",true);
    }
        
     
})