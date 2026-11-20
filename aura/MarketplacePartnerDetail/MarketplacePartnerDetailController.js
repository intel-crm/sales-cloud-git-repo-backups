/**
 * @description       : 
 * @author            : Balaji M
 * @group             : 
 * @last modified on  : 08-14-2020
 * @last modified by  : Balaji M
 * Modifications Log 
 * Ver   Date         Author     Modification
 * 1.0   07-28-2020   Balaji M   Initial Version
**/
({
    openContactForm: function(component, event, helper) {
        // Set logged user details to null

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

        var strDynSave =component.get('v.dynSave');
        var strDynUpdate =component.get('v.dynUpdate');
        var strDynRejected =component.get('v.dynRejected');

        strDynSave = strDynSave.replace(/{.*}/,'' );
        strDynSave = strDynSave.replace('{}','' );
        component.set('v.dynSave', strDynSave);

        strDynUpdate = strDynUpdate.replace(/{.*}/,'' );
        strDynUpdate = strDynUpdate.replace('{}','' );
        component.set('v.dynUpdate', strDynUpdate);

        strDynRejected = strDynRejected.replace(/{.*}/,'' );
        strDynRejected = strDynRejected.replace('{}','' );
        component.set('v.dynRejected', strDynRejected);


        component.set('v.loading', true);

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


        appEvent.fire();
    },
    //Added by Megha as part of US619896
    handleOpenStorefrontForm1: function(component, event, helper) {

        var appEvent = $A.get("e.c:MarketplacePageEvent");
        appEvent.setParams({
            type: 'openEditStoreFrontFromDraft',
            payload: { 
                currentStep: event.getParam('params')
            }
        });

        appEvent.fire();
    },

    //Added by Subash for US661733
    gotoOfferingList: function(component, event, helper) {
        helper.updatePartnerDetails(component, component.get('v.recordId'));
    }
})