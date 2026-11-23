({
    
    getPartnerDetails : function(component, partnerId,helper) {
        console.log('inside helper'+partnerId);
        var userLangCode = $A.get("$Locale.langLocale");
        var action = component.get("c.getPartnerDetails");
        action.setParams({
            'partnerId':partnerId,
            langCode: userLangCode
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                var returnValue = response.getReturnValue();
              
                component.set('v.leadSettings', returnValue.leadSettings);
                console.log(returnValue);
                component.set('v.mdaId', returnValue.mdaId);
                setTimeout($A.getCallback(function(){
                    component.set('v.partner', returnValue);
                }),2000);
                component.set('v.dataObj', returnValue.partnerDetails);                
                component.set('v.languageLabel', returnValue.leadLangPreference);              
                component.set('v.hasLeadGenAccess', returnValue.hasLeadGenAccess);                
                component.set('v.isSamePartnerUser', returnValue.isSamePartnerUser);
                
                //Added by Subash for guided setup and a welcome note US620593
                component.set('v.isMarkettingSpecialist', returnValue.isMarkettingSpecialist);
                component.set('v.isPartnerAdmin', returnValue.isPartnerAdmin);
                component.set('v.showEnhancedPopup', returnValue.showEnhancedPopup);
                component.set('v.isOfferingEditor', returnValue.isOfferingEditor);                
                component.set('v.isEnhancedUser', (returnValue.isPartnerAdmin || returnValue.isMarkettingSpecialist || returnValue.isOfferingEditor));
                console.log('isMarkettingSpecialist:::', returnValue.isMarkettingSpecialist, 
                            ':::isPartnerAdmin:::', returnValue.isPartnerAdmin, 
                            ':::showEnhancedPopup::::', returnValue.showEnhancedPopup,
                            ':::isOfferingEditor::::', returnValue.isOfferingEditor,
                            ':::isEnhancedUser::::', component.get('v.isEnhancedUser')
                           );
                //End
                
                component.set('v.isLdrOeEmployee',returnValue.isLdrOeEmployee);

                console.log('isLdrOeEmployee'+returnValue.isLdrOeEmployee);
                
                helper.truncate(component,helper,returnValue.partnerDescription);               
                //component.set('v.introSection', returnValue.introSection);
               //component.set('v.moreSection', returnValue.moreSection);
               component.set('v.showMoreSection',returnValue.showMoreSection);
              component.set('v.partnerType',returnValue.partnerType);
                //alert('partnerType'+returnValue.partnerType);
                
                component.set('v.showContactPartner', returnValue.isContactPartnerVisible);
                component.set('v.mobileListing', returnValue.mobileList);                
                component.set('v.hasAccess', returnValue.hasAccess);                
                component.set('v.isGuest', returnValue.isGuest);
                component.set('v.isIntelAdmin', returnValue.isIntelAdmin);
                component.set('v.tagline', returnValue.tagline);                
                component.set('v.showEditPencil',component.get('v.hasAccess') && !component.get('v.isGuest') );
               component.set('v.currentStatus',returnValue.currentStatus);
               //alert('CurrentStatus'+returnValue.currentStatus);
              component.set('v.publishedStatus',returnValue.publishedStatus);
               //alert('publishedStatus'+returnValue.publishedStatus);
                
                component.set('v.statusUpdateDate',returnValue.statusUpdateDate);
                component.set('v.initialUpdateDate',returnValue.initialUpdateDate);
                console.log('initialUpdateDate',component.get('v.initialUpdateDate'));
                console.log('statusUpdateDate',component.get('v.statusUpdateDate'));
                component.set('v.isUpdateRequired',returnValue.isUpdateRequired);                
                component.set('v.showManageOffering', returnValue.manageOfferingAccess);  
                //alert('returnValue.manageOfferingAccess'+returnValue.manageOfferingAccess);
                  
                component.set('v.loading', false);
                //For Benefit
                component.set("v.showCompanyResourceAndArticle",returnValue.showCompanyResourceAndArticle);
                component.set("v.showCompanyResourceAndArticleforEnhanced",returnValue.showCompanyResourceAndArticleforEnhanced); 
            } else if (status === "INCOMPLETE") {
                // do something?
            } else if (status === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(':::error:::', errors)
                        console.error(errors[0].message);
                    };
                }
            } else {
                reject('Unknown error.');
            }
        });
        $A.enqueueAction(action);
    } ,
    
    getPartnerArticles : function(component, partnerId){
        console.log('partnerId',partnerId);
        var userLangCode = $A.get("$Locale.langLocale");
        var action = component.get("c.getPartnerArticles");
        action.setParams({
            'partnerId' : partnerId,
            langCode: userLangCode
        });
        action.setCallback(this, function(response){
            var status = response.getState();
            if (status === "SUCCESS") {
                var returnValue = response.getReturnValue();
                
                setTimeout($A.getCallback(function(){
                    component.set('v.companyArticles', returnValue.articleList);
                    component.set('v.viewalllabel',returnValue.viewAllLabel);
                }),2000);
            } else if (status === "INCOMPLETE") {
                // do something?
            } else if (status === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                    };
                }
            } else {
                reject('Unknown error.');
            }
        });
        $A.enqueueAction(action);
        
    },
    
    truncate : function(component, helper, desc){
        
        if(desc != null){
            var intro = '';
            var more = '';
            var fullDesc = desc;
            
            var str = '';
            var scrubbedDesc = fullDesc.replace(/<[^>]*>?/gm, '');
            if(scrubbedDesc.length > parseInt($A.get("$Label.c.PMP_Dsc_Char_Limit"))){
                str = scrubbedDesc.substr(0,parseInt($A.get("$Label.c.PMP_Dsc_Char_Limit")));
                intro = str;
                more = fullDesc;
                component.set('v.introSection', intro);
                component.set('v.moreSection', fullDesc);
            }else{
                component.set('v.introSection', fullDesc);
            }
        }
    },
    
    updatePartnerDetails : function(component, partnerId) {
        
        var act = component.get("c.updatePartnerInfo");
        //var params = { partnerId: 'a3z0n0000006FWS' };
        var params = { partnerId: partnerId };
        act.setParams(params);
        
        var actPromises = this.executeAction(component, act);
        console.log(':::actPromises:::', actPromises);
        actPromises.then(
            
            $A.getCallback(function(result){
                console.log(':::result:::', result);
            }),
            $A.getCallback(function(error){
                console.log(':::error:::', error.message);
            })
        );
        
        console.log(':::updatePartnerDetails inside:::', partnerId);
    },
    
    executeAction: function(cmp, action, callback) {
        console.log(':::executeAction fn called:::');
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state:::', state);
                if (state === "SUCCESS") {
                    let navLink = cmp.find("navLink");
                    let pageRef = { 
                        type: 'standard__objectPage', 
                        attributes: {
                            objectApiName: 'PMP_Partner_Offering__c',
                            actionName: 'home'
                        },
                        state: { filterName: 'Default' }
                    }
                    navLink.navigate(pageRef, true);
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            reject(Error("Error message: " + errors[0].message));
                        }
                    }
                    else {
                        reject(Error("Unknown error"));
                    }
                }
            });
            $A.enqueueAction(action);
        });
    }
})