({
    
  getPartnerDetails : function(component, partnerId,helper) {
      
      var act = component.get("c.checkValidPartner");
      act.setParams({ "partnerId": partnerId });
      act.setCallback(this, function(response) {
          
          if(response.getState() === "SUCCESS") {
              if(response.getReturnValue() === true) {  
                  
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
                          console.log('returnValue: ',returnValue);
                          component.set('v.leadSettings', returnValue.leadSettings);
                          
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
                        //   IPA2.0 + US TWC4497-1631
                        //   component.set('v.isOfferingEditor', returnValue.isOfferingEditor);                
                        //   component.set('v.isEnhancedUser', (returnValue.isPartnerAdmin || returnValue.isMarkettingSpecialist || returnValue.isOfferingEditor));
                        component.set('v.isEnhancedUser', (returnValue.isPartnerAdmin || returnValue.isMarkettingSpecialist));

                          component.set('v.isLdrOeEmployee',returnValue.isLdrOeEmployee);
                          //Description Inconsistent Issue - Added as part of US954461 
                          helper.truncate(component,helper,returnValue.partnerShortDescription); 
                          component.set('v.moreSection', returnValue.partnerDescription);
                          component.set('v.showMoreSection',returnValue.showMoreSection);
                          component.set('v.partnerType',returnValue.partnerType);
                          
                          component.set('v.showContactPartner', returnValue.isContactPartnerVisible);
                          component.set('v.mobileListing', returnValue.mobileList);                
                          component.set('v.hasAccess', returnValue.hasAccess);                
                          component.set('v.isGuest', returnValue.isGuest);
                          component.set('v.isIntelAdmin', returnValue.isIntelAdmin);
                          component.set('v.tagline', returnValue.tagline);                
                          component.set('v.showEditPencil',component.get('v.hasAccess') && !component.get('v.isGuest') );
                          component.set('v.currentStatus',returnValue.currentStatus);
                          component.set('v.publishedStatus',returnValue.publishedStatus);
                          
                          component.set('v.statusUpdateDate',returnValue.statusUpdateDate);
                          component.set('v.initialUpdateDate',returnValue.initialUpdateDate);
                          component.set('v.publishedDate',returnValue.publishedDate);
                          
                          component.set('v.isUpdateRequired',returnValue.isUpdateRequired);
                        //   IPA2.0 + US TWC4497-1631
                        //   component.set('v.showManageOffering', returnValue.manageOfferingAccess);  
                          
                          setTimeout($A.getCallback(function() {
                              component.set('v.loading', false);
                          }), 2000);
                          //For Event Banner
                          component.set('v.showEventBanner', returnValue.isEventRelated); 
                          
                          //For Benefit
                          component.set("v.showCompanyResourceAndArticle",returnValue.showCompanyResourceAndArticle);
                          component.set("v.showCompanyResourceAndArticleforEnhanced",returnValue.showCompanyResourceAndArticleforEnhanced); 
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
                          this.reject('Unknown error.');
                      }
                  });
                  $A.enqueueAction(action);
                  
              } else {
                  window.location.href = $A.get("$Label.c.PMP_Error_Page_URL");
              }
          }
      });
      $A.enqueueAction(act);
  } ,
  
  getPartnerArticles : function(component, partnerId){
      
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
          var str = '';
          var fullDesc = desc.replace(/<[^>]+>/g, '');
          
          if(fullDesc.length > parseInt($A.get("$Label.c.PMP_Dsc_Char_Limit"))){
              var length = fullDesc.substr(0,parseInt($A.get("$Label.c.PMP_Dsc_Char_Limit"))).lastIndexOf(" ");
              str = fullDesc.substr(0,length)+ '...';
              intro = str.replace(/<[^>]+>/g, '');
              component.set('v.introSection', intro);
         }
         else{
             component.set('v.introSection', fullDesc);
         }
      }
  },
  
  updatePartnerDetails : function(component, partnerId) {
      
      var act = component.get("c.updatePartnerInfo");
      var params = { partnerId: partnerId };
      act.setParams(params);
      
      var actPromises = this.executeAction(component, act);
      
      actPromises.then(
          
          $A.getCallback(function(result){
              //do something
      }),
          $A.getCallback(function(error){
              //do something
         })
      );
  },
  
  executeAction: function(cmp, action, callback) {
      return new Promise(function(resolve, reject) {
          action.setCallback(this, function(response) {
              var state = response.getState();
              if (state === "SUCCESS") {
                // IPA2.0 + US TWC4497-1631
                //   let navLink = cmp.find("navLink");
                //   let pageRef = { 
                //       type: 'standard__objectPage', 
                //       attributes: {
                //           objectApiName: 'PMP_Partner_Offering__c',
                //           actionName: 'home'
                //       },
                //       state: { filterName: 'Default' }
                //   }
                //   navLink.navigate(pageRef, true);
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