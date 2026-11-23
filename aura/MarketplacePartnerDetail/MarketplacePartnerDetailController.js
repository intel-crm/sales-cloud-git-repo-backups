({
    openContactForm: function(component, event, helper) {
        // Set logged user details to null
        console.log('openContactForm');
        component.find("contactForm").set("v.userDetails", {});
        
        var appEvent = $A.get("e.c:MarketplacePageEvent");
        
        appEvent.setParams({
            type: "openLeadGenModal",
            payload: {
                formType: "contact",
                prefLanguage: component.get("v.leadSettings").languagePreference  
            }
        });
        appEvent.fire();
    },

    
    doInit : function(component, event, helper) {
        
        
        
         /* var benefitAction=component.get('c.isBasicProfileBenefit');
        benefitAction.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                
                var returnValue = response.getReturnValue();
                if(returnValue == true){
                    alert('returnValue'+returnValue);
                     component.set("v.showCompanyResourceAndArticle",true);
                }else{
                     alert('returnValue'+returnValue);
                    
                   component.set("v.showCompanyResourceAndArticle",false);
                }
                
                //component.set("v.showTabs", true);
                
                
            }
        });
        $A.enqueueAction(benefitAction);*/
        
        
        
        component.set('v.loading', true);
        console.log('URL: '+window.location.href);
        helper.getPartnerDetails(component, component.get('v.recordId'), helper);             
        helper.getPartnerArticles(component, component.get('v.recordId'));
      setTimeout($A.getCallback(function() {
                        
            var isgTabs = component.find('isgtabs');
            
            if (isgTabs && isgTabs.isValid && isgTabs.isValid() && isgTabs.reset) {
                window.setTimeout($A.getCallback(function() {
                    isgTabs.reset();
                },500));
            }
            
        }), 2000);
     
    },
     handleOpenStorefrontForm: function(component, event, helper) {
                                var partnerType = component.get('v.partnerType');
        console.log('---partnerType--->'+partnerType);
                                if (partnerType == 'BFTMKTPLBC'||partnerType == 'BFTMKTPLED') {
                                                //var isAdmin = true;
            var isProfileAdmin = true;
                                } else {
                                                //var isAdmin = false;
                                                var isProfileAdmin = false;
                                }
                                var appEvent = $A.get("e.c:MarketplacePageEvent");
                                appEvent.setParams({
                                                                type: 'openEditStoreFront',
                                                                payload: { 
                                                                                currentStep: event.getParam('params'),
                                                                                isAdminUser: isProfileAdmin
                                                                }
                                                });
                  console.log('payload',event.getParam('params'));

                                appEvent.fire();
                },
    //Added by Megha as part of US619896
     handleOpenStorefrontForm1: function(component, event, helper) {
       
                                var appEvent = $A.get("e.c:MarketplacePageEvent");
                                appEvent.setParams({
                                                                type: 'openEditStoreFrontFromDraft',
                                                                payload: { 
                                                                                currentStep: event.getParam('params'),
                                                                                //isAdminUser: isProfileAdmin
                                                                }
                                                });
         console.log('payload',event.getParam('params'));
                                appEvent.fire();
     },
    
    //Added by Subash for US661733
    gotoOfferingList: function(component, event, helper) {
        console.log(':::gotoOfferingList fn called:::', component.get('v.recordId'));
        helper.updatePartnerDetails(component, component.get('v.recordId'));
    }
})