({

  doInit : function(component, event, helper) {

    if (!component.get('v.recordId')) {
      throw('Something is wrong this page. No record ID found.');
    } else {
      component.find("progress").set('v.onchange', $A.getCallback(function(step) {
        helper.handleProgressBarChange(component, helper, step);
      }));
      helper.refresh(component, helper);
    }
      console.log('in form init'+component.get('v.currentStepValid'));
      component.set('v.category','System');
  },

  handleCategoryChange : function(component, event, helper) {
    // if category is selected from Modal (and does not exist on the record from the server)
    if (component.get('v.category') && !component.get('v._category')) {
      helper.save(component, helper);
      // refresh messages
      /*component.find('messaging').forEach(function(messaging) {
        messaging.show();
      });*/
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
    var warningHeading = $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Heading");
        if (component.get('v.currentStep') > 0) {
          if (component.get('v.currentStepTouched')) {
            helper.showModal(component, warningHeading,
              $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Unsaved_Changes"), true)
              .then($A.getCallback(function(val) {
                if (component.isValid() && val) {
                  component.set('v.record', component.get('v._record'));
                  component.set('v.currentStep', component.get('v.currentStep') - 1);
                }
              }));

          } else {
            if (component.get('v.currentStep') == component.get('v.wizardSteps').length - 1) { // Preview
              component.set('v.activeStep', component.get('v.currentStep') - 1);
              component.set('v.currentStep', component.get('v.currentStep') - 1);
            } else {
              helper.showModal(component, warningHeading,
                $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Dependencies"), true)
                .then($A.getCallback(function(val) {
                    if (component.isValid() && val) {
                        component.set('v.currentStep', component.get('v.currentStep') - 1);
                        //Prakash-6/26 component.set('v.currentStepValid', true);
                    }
                }));
            }
          }
        }

  },

  handleNextStep : function(component, event, helper) {
    var warningHeading = $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Heading");
    //Prakash 6/26 var formData = component.get("v.formData");
    //Prakash 6/26 component.set("v.clickNext",true);
    if (component.get('v.currentStep') == component.get('v.wizardSteps').length - 1) {
      helper.goToSubmit(component, helper); return;
    }
    if (component.get('v.currentStepValid')) {
      helper.save(component, helper, 1);
    } else {
      helper.showModal(component, warningHeading,
        $A.get("PMP_Create_Offering_Form_Warning_Current_Step_Incomplete"), true);
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
        // gets preview data for the Object Detail preview component
        helper.loadPreviewData(component).then($A.getCallback(function() {
            component.set('v.currentStepValid', true);
            component.set('v.showSpinner', false);
	    helper.scrollTop(component);
        }));
    } else if (prevStep && (wasOnPreviewStep || ((currentStep < activeStep) && (currentStep < prevStep)))) {
      component.set('v.currentWizardStep', component.get('v.wizardSteps')[component.get('v.currentStep')]);
      component.set('v.showSpinner', true);
      helper.initializeForm(component, helper).then($A.getCallback(function() {
        component.set('v.showSpinner', false);
	helper.scrollTop(component);
      }));
    }else {
      helper.scrollTop(component);
    }
  },

  handleSaveAsDraft : function(component, event, helper) {
    if (!component.get('v.currentStepTouched')) return;
    component.set('v.showSpinner', true);
    helper.saveAndRefreshData(component, helper).then($A.getCallback(function() {
      component.set('v.showSpinner', false);
      component.set('v.showSavedMessage', true);
      component.set('v.currentStepTouched', false);
       /*Prakash 6/26 if(component.get('v.currentStep') < 4){
    		var detailCmp=component.find('details');
            detailCmp.reInit();}*/
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


})