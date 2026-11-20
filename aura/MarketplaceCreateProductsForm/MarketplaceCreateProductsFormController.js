({
    // IPA2.0 + US TWC4497-1631
  
    // doInit: function (component, event, helper) {

    //     //Livelier #214 : start URL Navigation Check Starts : Pranjal 
    //     var actiontoperform = window.location.href.match(/.*action\=(.*)/);
    //     var urlstring = window.location.href.match(/.*language\=(.*)/);
    //     if (urlstring != null) {
    //         var temp = urlstring[1].split("&");
    //     }
    //     var langtopass = !temp ? 'NA' : temp[0];
    //     var offeringRecordId = component.get('v.recordId');
    //     if (actiontoperform != null && actiontoperform[1] == 'clone') {
    //         var actionforclone = component.get("c.cloneOfferingDetail");
    //         actionforclone.setParams({
    //             'offeringId': offeringRecordId,
    //             'language': langtopass
    //         });
    //         actionforclone.setCallback(this, function (response) {
    //             var stateforclone = response.getState();
    //             if (stateforclone === "SUCCESS") {
    //                 var newresponse = JSON.parse(response.getReturnValue());
    //                 offeringRecordId = newresponse.objectData.clonedRecId;
    //                 var actionofclone = component.get("c.isSafeURLNavigation");
    //                 actionofclone.setParams({ 'offeringId': offeringRecordId });
    //                 actionofclone.setCallback(this, function (response) {
    //                     var state = response.getState();
    //                     let offeringDataWrapper;
    //                     if (state === "SUCCESS") {
    //                         offeringDataWrapper = response.getReturnValue();
    //                         if (offeringDataWrapper != null && offeringDataWrapper != '' && offeringDataWrapper.access) {
    //                             /*if (offeringDataWrapper.validateBookmarkUrl == 'isAdminreview') {
    //                                 var marketplaceUrl = $A.get('$Label.c.PMP_Marketplace_Community_URL');
    //                                 var urlEvent = $A.get("e.force:navigateToURL");
    //                                 urlEvent.setParams({
    //                                     "url": marketplaceUrl + '/offering/' + offeringRecordId
    //                                 });
    //                                 urlEvent.fire();
    //                             } else if (offeringDataWrapper.validateBookmarkUrl == 'isRetired') {
    //                                 helper.navigateToErrorPage(component, helper);
    //                             } else {
    //                                 var match = window.location.href.match(/.*recordId\=(.*)/), id;
    //                                 //get the URL Parameters
    //                                 var searchString = window.location.search;
    //                                 var urlParams = new URLSearchParams(searchString);
    //                                 var Lang = urlParams.get('Lang');
    //                                 // set record ID
    //                                 if (match) {
    //                                     //get the recordId from url params 
    //                                     id = urlParams.get('recordId');
    //                                     //only for the 'Lang' parameter which will get appended in URL for MP Admins
    //                                     //when navigated using view offerings - translated language hyperlinks
    //                                     if (Lang && Lang !== null && Lang !== '') {
    //                                         component.set('v.userSelectedLanguage', Lang);
    //                                     }
    //                                     if (actiontoperform != null && actiontoperform[1] == 'clone') {
    //                                         component.set('v.recordId', offeringRecordId);
    //                                         var marketplaceUrl = $A.get('$Label.c.PMP_Marketplace_Community_URL');
    //                                         marketplaceUrl = marketplaceUrl + '/offering-edit?recordId=' + offeringRecordId;
    //                                         const url = new URL(marketplaceUrl);
    //                                         window.history.replaceState(null, null, url);
    //                                     } else {
    //                                         component.set('v.recordId', id);
    //                                     }
    //                                 }
    //                                 if (!component.get('v.recordId')) {
    //                                     throw ($A.get("$Label.c.PMP_NoRecordIDFoundError"));
    //                                 } else {
    //                                     component.find("progress").set('v.onchange', $A.getCallback(function (step) {
    //                                         helper.handleProgressBarChange(component, helper, step);
    //                                     }));
    //                                     helper.refresh(component, helper);
    //                                 }
    //                             }*/
    //                         }
    //                         else {
    //                             helper.navigateToErrorPage(component, helper);
    //                         }
    //                         // //Livelier #214 : ends
    //                     }
    //                 });
    //                 $A.enqueueAction(actionofclone);
    //             }
    //         });
    //         $A.enqueueAction(actionforclone);
    //     } else {
    //         var action = component.get("c.isSafeURLNavigation");
    //         action.setParams({ 'offeringId': offeringRecordId });
    //         action.setCallback(this, function (response) {
    //             var state = response.getState();
    //             let offeringDataWrapper;
    //             if (state === "SUCCESS") {
    //                 offeringDataWrapper = response.getReturnValue();
    //                 if (offeringDataWrapper != null && offeringDataWrapper != '' && offeringDataWrapper.access) {
    //                    /* if (offeringDataWrapper.validateBookmarkUrl == 'isAdminreview') {
    //                         var marketplaceUrl = $A.get('$Label.c.PMP_Marketplace_Community_URL');
    //                         var urlEvent = $A.get("e.force:navigateToURL");
    //                         urlEvent.setParams({
    //                             "url": marketplaceUrl + '/offering/' + offeringRecordId
    //                         });
    //                         urlEvent.fire();
    //                     } else if (offeringDataWrapper.validateBookmarkUrl == 'isRetired') {
    //                         helper.navigateToErrorPage(component, helper);
    //                     } else {
    //                         var match = window.location.href.match(/.*recordId\=(.*)/), id;
    //                         //get the URL Parameters
    //                         var searchString = window.location.search;
    //                         var urlParams = new URLSearchParams(searchString);
    //                         var Lang = urlParams.get('Lang');
    //                         // set record ID
    //                         if (match) {
    //                             //get the recordId from url params 
    //                             id = urlParams.get('recordId');
    //                             //only for the 'Lang' parameter which will get appended in URL for MP Admins
    //                             //when navigated using view offerings - translated language hyperlinks
    //                             if (Lang && Lang !== null && Lang !== '') {
    //                                 component.set('v.userSelectedLanguage', Lang);
    //                             }
    //                             component.set('v.recordId', id);
    //                         }
    //                         if (!component.get('v.recordId')) {
    //                             throw ($A.get("$Label.c.PMP_NoRecordIDFoundError"));
    //                         } else {
    //                             component.find("progress").set('v.onchange', $A.getCallback(function (step) {
    //                                 helper.handleProgressBarChange(component, helper, step);
    //                             }));
    //                             helper.refresh(component, helper);
    //                         }
    //                     }*/
    //                 }
    //                 else {
    //                     helper.navigateToErrorPage(component, helper);
    //                 }
    //                 // //Livelier #214 : ends
    //             }
    //         });
    //         $A.enqueueAction(action);
    //     }
    // },
    
    // handleCategoryChange : function(component, event, helper) {
        
    //     // if category is selected from Modal (and does not exist on the record from the server)
    //                 if (component.get('v.category') && !component.get('v._category')) {
    //                     helper.save(component, helper);
    //                 }
        
    // },
    
    // handleCancel : function(component, event, helper) {
    //     var warningHeading = $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Heading");
    //     if (component.get('v.currentStepTouched')) {
    //         helper.showModal(component, warningHeading,
    //                          $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Unsaved_Changes"), true)
    //         .then($A.getCallback(function(val) {
    //             if (component.isValid() && val) helper.returnToList(component, helper);
    //         }));
    //     } else { 
    //         window.localStorage.setItem('hideSave', false);
    //         window.localStorage.setItem('hideSaveDesc', false);
    //         window.localStorage.setItem('hideSaveCompany', false);
    //         helper.returnToList(component, helper); 
    //     }
    // },
    
    // handlePrevStep : function(component, event, helper) {
    //     component.set('v.showErrors', false);
    //     var warningHeading = $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Heading");
    //     if (component.get('v.currentStep') > 0) {
    //         if (component.get('v.currentStepTouched')) {
    //             helper.showModal(component, warningHeading,
    //                              $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Unsaved_Changes"), true)
    //             .then($A.getCallback(function(val) {
    //                 if (component.get('v.currentStep') == 1) {
                       
    //                     if (component.isValid() && val) component.set('v.currentStep', component.get('v.currentStep') - 1);
                        
    //                 } else {
    //                     if (component.isValid() && val) component.set('v.currentStep', component.get('v.currentStep') - 1);
                        
    //                 }
    //             }));
                
    //         } else {
                
                
    //             if (component.get('v.currentStep') == component.get('v.wizardSteps').length - 1) { // Preview
    //                 component.set('v.activeStep', component.get('v.currentStep') - 1);
    //                 component.set('v.currentStep', component.get('v.currentStep') - 1);
                    
    //             } else if (component.get('v.currentStep') == 1) {
                    
    //                 if (component.isValid() ) {
    //                     component.set('v.currentStep', component.get('v.currentStep') - 1);
                        
    //                 }
                    
    //             } else {
    //                 component.set('v.currentStep', component.get('v.currentStep') - 1);
                    
                    
                    
                    
    //             }
    //         }
    //     }
        
        
    // },
    
    
    // handleNextStep : function(component, event, helper) {
    //     // NOTE: IE 11 ignores disabled buttons and still makes it clickable
    //     var warningHeading = $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Heading");
    //     //Prakash 6/26 var formData = component.get("v.formData");
    //     component.set("v.clickNext",true);
    //     if (component.get('v.currentStep') == component.get('v.wizardSteps').length - 1 || (component.get('v.wizardSteps').length==6 && component.get('v.currentStep') == component.get('v.wizardSteps').length - 2)){
    //         helper.goToSubmit(component, helper); return;
    //     }
        
    //     helper.checkForm(component, helper, true);
        
    //     if (component.get('v.currentStepValid')) {
            
    //             helper.save(component, helper, 1);
            
    //         component.set('v.showErrors', false);
    //     } else {
    //         component.set('v.showErrors', true);
    //   		helper.handleShowToast(component);
    //   		helper.checkForm(component, helper, true);
    //         var warningMessage = $A.get("PMP_Create_Offering_Form_Warning_Current_Step_Incomplete");
    //         // if warning message exists show it
    //         if (warningMessage) {
    //             helper.showModal(component, warningHeading, warningMessage, true);
    //         }
            
    //     }
    // },
    
    
    // handleStepChange : function(component, event, helper) {
        
    //     var currentStep = component.get('v.currentStep'),
    //         activeStep = component.get('v.activeStep'),
    //         prevStep = event.getParam('oldValue'),
    //         previewStep = component.get('v.wizardSteps').length - 1;
    //     var wasOnPreviewStep = prevStep == previewStep;
    //     component.set('v.showSavedMessage', false);
    //     component.set('v.currentStepTouched', false);
    //     window.localStorage.setItem('hideSave', false);
    //     window.localStorage.setItem('hideSaveDesc', false);
    //     window.localStorage.setItem('hideSaveCompany', false);
    //     if((component.get('v.currentStep') == 1 || component.get('v.currentStep') == 2) &&  component.get('v.wizardSteps')[currentStep].sections[0].subsections.length == 0){
    //         var nextPageMessage = $A.get("$Label.c.PMP_Create_Offering_Form_Click_Next_Message").replace('{0}', component.get('v.wizardSteps')[currentStep].name);
    //         component.set('v.NextPageMessage',nextPageMessage);
    //         component.set('v.showNextPageMessage',true); 
            
    //     }else{
    //         component.set('v.showNextPageMessage',false);
    //     }
        
    //     if (currentStep > 0 && currentStep == previewStep) {
            
    //         component.set('v.showSpinner', true);
    //         // sets strength & ways to improve
    //         component.set('v.offeringStrength', 1);
    //         component.set('v.waysToImprove', [
    //             { label: 'Include some specifications', formDataApiName: 'Specifications' },
    //             { label: 'include a datasheet', formDataApiName: 'Datasheet' },
    //             { label: 'select a specific Intel® Processor', formDataApiName: 'Processor_Field__c' }
    //         ]);
            
    //         /*Commented by Gireesh-MarketplaceCreateProductPreview.cmp will fetch PreviewData based on recordId, 
    //      * no need to externally fetchData 
    //      */
    //         // gets preview data for the Object Detail preview component
    //         /*helper.loadPreviewData(component).then($A.getCallback(function() {
            
    //         component.set('v.showSpinner', false);
	//     helper.scrollTop(component);
    //     }));*/
    //     } else if (prevStep && (wasOnPreviewStep || ((currentStep < activeStep) && (currentStep < prevStep)))) {
            
            
    //         component.set('v.currentWizardStep', component.get('v.wizardSteps')[component.get('v.currentStep')]);
    //         component.set('v.showSpinner', true);
    //         //component.set('v.formSections', []);
    //         window.setTimeout($A.getCallback(function() {  
    //             helper.initializeForm(component, helper).then($A.getCallback(function() {
    //                 component.set('v.showSpinner', false);
    //                 if (component.get('v.currentStepValid')) {
    //                 helper.scrollTop(component);
    //                 }    
    //             }));
    //         }));   
            
    //     }else {
    //         if (component.get('v.currentStepValid')) {
    //         helper.scrollTop(component);
    //     }
    //     }
    // },
    
    // handleSaveAsDraft : function(component, event, helper) {
    //     if (!component.get('v.currentStepTouched')) return;
        
        
    //     helper.checkForm(component,helper,false);
    //         if(!component.get('v.currentStepValid')){
    //         	component.set('v.activeStep',component.get('v.currentStep'));
    //         }  
    //     component.set('v.showSpinner', true);
    //     helper.saveAndRefreshData(component, helper).then($A.getCallback(function() {
    //         component.set('v.showSpinner', false);
    //         component.set('v.showSavedMessage', true);
    //         component.set('v.currentStepTouched', false);
    //          helper.checkForm(component, helper, false);
    //         if(!component.get('v.currentStepValid')){
    //         	component.set('v.activeStep',component.get('v.currentStep'));

    //         }   
    //         /*Added by raj for offering tracker*/ 
    //         if(component.get('v.currentStep') < 4){
    //             var detailCmp=component.find('details');
    //             detailCmp.reInit();
    //         }
    //         /*Added by raj for offering tracker*/
    //     }));
    // },
    
    // handleFormSubmit : function(component, event, helper) {
    //     event.preventDefault();
    // },
    
    // handlePageSearch : function(component, event, helper) {
    //     var searchTerm = component.get('v.pageSearchTerm');
    //     helper.getAllSubsections(component, helper).forEach(function(subsection) {
    //         var allInputs = subsection.find("formInput") ? [].concat(subsection.find("formInput")) : [];
    //         allInputs.forEach(function(input) {
    //             input.set('v.searchTerm', searchTerm);
    //         });
    //     });
    // },
    // //US523547 - End Customer type should not be mandatory for embedded IoT.
    // handleEndCustomerTypeMandatory : function(component,event,helper){
    //     //get parameter from the event.
    //     var isMandatory = event.getParam("isMandatory");
    //     var allInputs = [];
    //     //get all subsections and iterate over their inputs.
    //     helper.getAllSubsections(component, helper).forEach(function(subsection) {
            
            
    //         allInputs = allInputs.concat(subsection.find("formInput") ? [].concat(subsection.find("formInput")) : []);
            
    //     });
        
    //     allInputs.forEach(function(input) {
    //         //fetch specId of the field from custom label.
    //         var endCustomertype = $A.get("$Label.c.PMP_NPP_EndCustomerType");
            
    //         // set the End Customer Type field to mandatory/non mandatory based on the event parameter received.
    //         if (input.get('v.fieldName') == endCustomertype){                
    //             input.set('v.required', isMandatory);                
    //             input.set('v.valid',!isMandatory ? true : false );
                
                
    //         }
    //     }); 
    // },
    // //Psg to toggle the mandatory behaviour of the price field based on Contact for price field
    // handleAvailablityMandatory : function(component,event,helper){
    //     var isMandatory = event.getParam("isMandatory");
    //     var fieldName = event.getParam("fieldName");
    //     console.log('eventField name' ,fieldName);
    //     helper.toggleFieldMandatory(component,helper,fieldName,isMandatory);
    // }
    
})