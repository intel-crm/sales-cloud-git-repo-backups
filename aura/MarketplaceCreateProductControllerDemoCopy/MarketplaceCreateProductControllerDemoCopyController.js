({
  
    doInit : function(component, event, helper) {
        component.set('v.surveyurl', 'https://kprabuddh-developer-edition.ap17.force.com/ArdiraSurvey/SurveyResponse.app?recordId=a0H2x000001ST6E&logicalId=3813458e-b756-c821-534f-74f57dd3dbec');    
       // component.set('v.surveyurl', 'https://kprabuddh-dev-ed.my.salesforce.com/ArdiraSurvey/SurveyResponse.app?recordId=a0H2x000001ST6J&logicalId=8b54e613-4345-fd07-908b-7a3a8fe16985');
/*var match = window.location.href.match(/.*recordId\=(.*)/), id;
        component.set('v.surveyurl', 'https://kprabuddh-dev-ed.my.salesforce.com/ArdiraSurvey/SurveyResponse.app?recordId=a0H2x000001ST6J&logicalId=8b54e613-4345-fd07-908b-7a3a8fe16985');
        //component.set('v.recordId','a5b8A000000DAVL');
        // set record ID
        if (match) { 
            
            if(match[1].includes("&")){
                id=match[1].split("&")[0];
                var languageAttr = match[1].split("&")[1];
                var language = languageAttr.split("=")[1];
                
                component.set('v.userSelectedLanguage',language); 
            }
            else{
                id = match[1];
            }
          
            component.set('v.recordId', id);
        }
        
        if (!component.get('v.recordId')) {
            throw($A.get("$Label.c.PMP_NoRecordIDFoundError"));
        } else {
            
            component.find("progress").set('v.onchange', $A.getCallback(function(step) {
                helper.handleProgressBarChange(component, helper, step);
            }));
            helper.refresh(component, helper);
        } */
        
    },
    survey:function(component,event,helper){
         //window.open("https://kprabuddh-developer-edition.ap17.force.com/ArdiraSurvey/SurveyResponse.app?recordId=a0H2x000001ST6E&logicalId=3813458e-b756-c821-534f-74f57dd3dbec");
    },
    handleCategoryChange : function(component, event, helper) {
        // if category is selected from Modal (and does not exist on the record from the server)
        if (component.get('v.category') && !component.get('v._category')) {
            helper.save(component, helper);
        }
    },
    
    handleCancel : function(component, event, helper) {
        var warningHeading = $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Heading");
        if (component.get('v.currentStepTouched')) {
            helper.showModal(component, warningHeading,
                             $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Unsaved_Changes"), true)
            .then($A.getCallback(function(val) {
                if (component.isValid() && val) helper.returnToList(component, helper);
            }));
        } else { helper.returnToList(component, helper); }
    },
    
    handlePrevStep : function(component, event, helper) {
        
        component.set('v.showErrors', false);
        var warningHeading = $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Heading");
        if (component.get('v.currentStep') > 0) {
            if (component.get('v.currentStepTouched')) {
                helper.showModal(component, warningHeading,
                                 $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Unsaved_Changes"), true)
                .then($A.getCallback(function(val) {
                    if (component.get('v.currentStep') == 1) {
                        //helper.showModal(component, warningHeading,
                        //  $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Dependencies"), true)
                        //  ($A.getCallback(function(val) {
                        if (component.isValid() && val) component.set('v.currentStep', component.get('v.currentStep') - 1);
                        //  }));
                    } else {
                        if (component.isValid() && val) component.set('v.currentStep', component.get('v.currentStep') - 1);
                    }
                }));
                
            } else {
                
                
                if (component.get('v.currentStep') == component.get('v.wizardSteps').length - 1) { // Preview
                    component.set('v.activeStep', component.get('v.currentStep') - 1);
                    component.set('v.currentStep', component.get('v.currentStep') - 1);
                } else if (component.get('v.currentStep') == 1) {
                    //helper.showModal(component, warningHeading,
                    //  $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Dependencies"), true)
                    // ($A.getCallback(function(val) {
                    if (component.isValid() ) {
                        component.set('v.currentStep', component.get('v.currentStep') - 1);
                        //Prakash-6/26 component.set('v.currentStepValid', true);
                    }
                    //   }));
                } else {
                    component.set('v.currentStep', component.get('v.currentStep') - 1);
                }
            }
        }
        
        
    },
    
    
    handleNextStep : function(component, event, helper) {
        // NOTE: IE 11 ignores disabled buttons and still makes it clickable
        var warningHeading = $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Heading");
        //Prakash 6/26 var formData = component.get("v.formData");
        component.set("v.clickNext",true);
        if (component.get('v.currentStep') == component.get('v.wizardSteps').length - 1 || (component.get('v.wizardSteps').length==6 && component.get('v.currentStep') == component.get('v.wizardSteps').length - 2)){
            helper.goToSubmit(component, helper); return;
        }
        
        helper.checkForm(component, helper, true);
        
        if (component.get('v.currentStepValid')) {
            //US527092:Gireesh
            //Save if form is touched else just render the current step on click of next button
            //if(component.get('v.currentStepTouched')){
                helper.save(component, helper, 1);
            /*}else{ //commneted by Abhishek
                component.set('v.showSpinner', true);
                component.set('v.currentStep', component.get("v.currentStep")+1);
                var repsData = component.get('v.responseData');
                component.set('v.currentWizardStep',repsData.steps[component.get("v.currentStep")]);
                helper.initializeForm(component, helper).then($A.getCallback(function() {
                    component.set('v.showSpinner', false);
                }));  
            } */
            component.set('v.showErrors', false);
        } else {
            component.set('v.showErrors', true);
      		helper.handleShowToast(component);
      		helper.checkForm(component, helper, true);
            var warningMessage = $A.get("PMP_Create_Offering_Form_Warning_Current_Step_Incomplete");
            // if warning message exists show it
            if (warningMessage) {
                helper.showModal(component, warningHeading, warningMessage, true);
            }
            
        }
    },
    
    
    handleStepChange : function(component, event, helper) {
        
        var currentStep = component.get('v.currentStep'),
            activeStep = component.get('v.activeStep'),
            prevStep = event.getParam('oldValue'),
            previewStep = component.get('v.wizardSteps').length - 1;
        var wasOnPreviewStep = prevStep == previewStep;
        component.set('v.showSavedMessage', false);
        component.set('v.currentStepTouched', false);
        
        
        if (currentStep > 0 && currentStep == previewStep) {
            
            component.set('v.showSpinner', true);
            // sets strength & ways to improve
            component.set('v.offeringStrength', 1);
            component.set('v.waysToImprove', [
                { label: 'Include some specifications', formDataApiName: 'Specifications' },
                { label: 'include a datasheet', formDataApiName: 'Datasheet' },
                { label: 'select a specific Intel® Processor', formDataApiName: 'Processor_Field__c' }
            ]);
            
            /*Commented by Gireesh-MarketplaceCreateProductPreview.cmp will fetch PreviewData based on recordId, 
         * no need to externally fetchData 
         */
            // gets preview data for the Object Detail preview component
            /*helper.loadPreviewData(component).then($A.getCallback(function() {
            
            component.set('v.showSpinner', false);
	    helper.scrollTop(component);
        }));*/
        } else if (prevStep && (wasOnPreviewStep || ((currentStep < activeStep) && (currentStep < prevStep)))) {
            
            
            component.set('v.currentWizardStep', component.get('v.wizardSteps')[component.get('v.currentStep')]);
            component.set('v.showSpinner', true);
            //component.set('v.formSections', []);
            window.setTimeout($A.getCallback(function() {  
                helper.initializeForm(component, helper).then($A.getCallback(function() {
                    component.set('v.showSpinner', false);
                    if (component.get('v.currentStepValid')) {
                    helper.scrollTop(component);
                    }    
                }));
            }));   
            
        }else {
            if (component.get('v.currentStepValid')) {
            helper.scrollTop(component);
        }
        }
    },
    
    handleSaveAsDraft : function(component, event, helper) {
        if (!component.get('v.currentStepTouched')) return;
        component.set('v.showSpinner', true);
        
        helper.saveAndRefreshData(component, helper).then($A.getCallback(function() {
            component.set('v.showSpinner', false);
            component.set('v.showSavedMessage', true);
            component.set('v.currentStepTouched', false);
            /*Added by raj for offering tracker*/ 
            if(component.get('v.currentStep') < 4){
                var detailCmp=component.find('details');
                detailCmp.reInit();
            }
            /*Added by raj for offering tracker*/
        }));
    },
    
    handleFormSubmit : function(component, event, helper) {
        event.preventDefault();
    },
    
    handlePageSearch : function(component, event, helper) {
        var searchTerm = component.get('v.pageSearchTerm');
        helper.getAllSubsections(component, helper).forEach(function(subsection) {
            var allInputs = subsection.find("formInput") ? [].concat(subsection.find("formInput")) : [];
            allInputs.forEach(function(input) {
                input.set('v.searchTerm', searchTerm);
            });
        });
    },
    //US523547 - End Customer type should not be mandatory for embedded IoT.
    handleEndCustomerTypeMandatory : function(component,event,helper){
        //get parameter from the event.
        var isMandatory = event.getParam("isMandatory");
        var allInputs = [];
        //get all subsections and iterate over their inputs.
        helper.getAllSubsections(component, helper).forEach(function(subsection) {
            
            
            allInputs = allInputs.concat(subsection.find("formInput") ? [].concat(subsection.find("formInput")) : []);
            
        });
        
        allInputs.forEach(function(input) {
            //fetch specId of the field from custom label.
            var endCustomertype = $A.get("$Label.c.PMP_NPP_EndCustomerType");
            
            // set the End Customer Type field to mandatory/non mandatory based on the event parameter received.
            if (input.get('v.fieldName') == endCustomertype){                
                input.set('v.required', isMandatory);                
                input.set('v.valid',!isMandatory ? true : false );
                
                
            }
        }); 
    },
    //Psg POC Abhishek
    handleAvailablityMandatory : function(component,event,helper){
        var isMandatory = event.getParam("isMandatory");
        var fieldName = event.getParam("fieldName");
        console.log('eventField name' ,fieldName);
        helper.toggleFieldMandatory(component,helper,fieldName,isMandatory);
    }
    //Poc End
    
    
})