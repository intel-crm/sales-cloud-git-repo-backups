({
    
    doInit:function(component,event,helper)
    {
       
        var newbutton = component.find('newmilestonebutton');
		$A.util.removeClass(newbutton, 'cMarketplaceThemeLayout');

        helper.getOfferingDetails(component,helper);
        var partnerName=component.get("v.partnerName");
        console.log("Name initial");
        console.log(component.get("v.partnerName"));
        
   		
        /*var action = component.get("c.fetchUser");
		action.setCallback(this, function(response) {
		var state = response.getState();
		if (state === "SUCCESS") {
        component.set("v.userDetails",response.getReturnValue());
            console.log("odd:",response.getReturnValue());
            
		} 
        
        //Calling wap_tms test function
        try {
            //code before the pause
            setTimeout(function(){
                console.log('MarketplaceProductDetailController.js : before calling = ');
                /*if (typeof loadAnalyticsScript !== 'undefined') {
                    loadAnalyticsScript('us-en');
                }*/
               /* console.log('MarketplaceProductDetailController.js > utag_data = '+ utag_data);
            }, 1000);
        	//wap_tms.custom.salesForceTest(obj);
        } catch (e) {
        	console.log(e);
        };

            
	});
      
    $A.enqueueAction(action);*/
        
    	try {
            var obj = {
              'integer': 12345,
              'string': 'string',
              'boolean': true
            };
            
            /*
            MP_WAP_OBJ.offerringId = '111111111111111111111111';
            console.log('MarketplaceProductDetailController > MP_WAP_OBJ.offerringId = '+  MP_WAP_OBJ.offerringId);
            console.log('MarketplaceProductDetailController > wap_tms = '+ wap_tms);
            */
            //console.log('MarketplaceProductDetailController > wap_tms.custom.salesForceHit = '+ wap_tms.custom.salesForceHit);
            //console.log('MarketplaceProductDetailController.js > wap_tms.custom = '+ JSON.stringify(wap_tms.custom));
            //wap_tms.custom.salesForceTest(obj);
        	/*setTimeout(function(){
            }, 1000);*/
        } catch(e) {
        	console.log(e);
        };
   	
    //mock server call,added on 06/27 
       /* var notificationData = [
            {
                type: 'redo',
                openInBlank: 'false',
                message: 'Your offering requires an update for approval.',
                textLinkLabel: 'Edit This Offering',
                pageReference: {
                    type: "standard__recordPage",
                    attributes: {
                        "objectApiName": "PMP_Partner_Offering__c",
                        "recordId": component.get('v.editRecordId'),
                        actionName: 'view'
                    }
                }
            },
            {
                type: 'lock',
                openInBlank: 'true',
                message: 'Your offering requires an update for approval.',
                textLinkLabel: 'View This Offering',
                pageReference: {
                    type: "standard__namedPage",
                    attributes: {
                        "pageName": "offering-preview"
                    },
                    state: {
                        "recordId": "a3s0n0000002BnzAAE"
                    }
                }
            }
            
        ];
        setTimeout($A.getCallback(function() {
			if (!component.get('v.previewMode')) {
				component.set('v.notificationData', notificationData);
				//component.set('v.loading', false);
			}
		}), 2000);
	/*----------------End------------------------------------------*/        
    },

	handleEditOffering : function(component, event, helper) {

	},

	handleViewOffering : function(component, event, helper) {

	},
    
    /********* Commented by Hemanta. This code has moved.  **********************
     * **************************************************************************/
	openRequestaQuote: function(component, event, helper) {
        console.log('an user');
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
         console.log('logged in user');
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
		console.log('hidebutton-->' +showButton);
        component.set("v.showDateChangeSection",false);
        component.set("v.showDateChangeButton",showButton);
    },
    openDateChange : function(component, event, helper){
        component.set("v.showDateChangeSection",true);
    }
        
     
})