({

  goToSubmit : function(component, helper) {
    /*Added by raj for US341586 to handle status change on submit*/
    var action = component.get("c.submitOffering");
    action.setParams({ submitRequest: JSON.stringify(component.get("v.formData")) });
    $A.enqueueAction(action);
    /*---------------End-US341586--------------------------------*/
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({ "url": "/create-offering-submit" });
    urlEvent.fire();
  },

  returnToList : function(component, helper) {
	/* US340229 to handle cancel scenario across all tabs*/
	/* var action = component.get("c.cancelOffering");
	   action.setParams({ offeringId: component.get('v.recordId') });
           $A.enqueueAction(action); */
    /*---------------End-US340229--------------------------------*/
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({ "url": "/pmp-partner-offering/PMP_Partner_Offering__c/" + component.get('v.recordListViewId') });
    urlEvent.fire();
  },

  refresh : function(component, helper) {
    component.set('v.showSpinner', true);
    helper.loadData(component, helper).then($A.getCallback(function() {
      component.set('v.showSpinner', false);
    }));
  },

  save : function(component, helper, delta, refreshOnly) {
    component.set('v.showSpinner', true);
    helper.saveAndRefreshData(component, helper, delta, refreshOnly).then($A.getCallback(function() {
      component.set('v.showSpinner', false);
      if(component.get('v.currentStep') < 4){
      	  var detailCmp=component.find('details');
          detailCmp.reInit();}
    }));
  },

  handleProgressBarChange : function(component, helper, selectedStep) {
    var activeStep          = component.get('v.activeStep'),
        currentStep         = component.get('v.currentStep'),
        currentStepValid    = component.get('v.currentStepValid'),
        currentStepTouched  = component.get('v.currentStepTouched'),
        warningHeading      = $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Heading"),
        data = component.get('v.responseData');

    // does nothing if user selects the current step
    if (selectedStep == currentStep) {
      return;

      // user selects a step too far down the path
    } else if (selectedStep > activeStep + 1) {
        //Admin Logic added by Shahrukh, Condition to check will be changed after security implementation : US341597
      if(data.steps.length!=6){
      	helper.showModal(component, warningHeading, $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Steps_In_Order"), false);
      }else{
        helper.adminReviewProgressBarChange(component,helper,selectedStep); // Hiding modals for admin
      }


      // user selects the next step, but the current step isn't completed
    } else if (selectedStep == activeStep + 1 && currentStep == activeStep && !currentStepValid) {
      //Admin Logic added by Shahrukh, Condition to check will be changed after security implementation : US341597
      if(data.steps.length!=6){
      	helper.showModal(component, warningHeading, $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Current_Step_Incomplete"), false);
      }else{
        helper.adminReviewProgressBarChange(component,helper,selectedStep); // Hiding modals for admin
      }
      // user selects the next step (after the active step), but is currently on a previous step
    } else if (selectedStep == activeStep + 1 && currentStep < activeStep) {
      //Admin Logic added by Shahrukh, Condition to check will be changed after security implementation : US341597
      if(data.steps.length!=6){
      	helper.showModal(component, warningHeading, $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Steps_In_Order"), false);
      }else{
        helper.adminReviewProgressBarChange(component,helper,selectedStep);  // Hiding modals for admin
      }


      // user selects a previous step than currently on
    } else if (selectedStep < currentStep) {

     	if(data.steps.length!=6){
          if (currentStepTouched) {
            helper.showModal(component, warningHeading, $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Unsaved_Changes"), true)
              .then($A.getCallback(function(val) {
                if (component.isValid() && val) {
                  component.set('v.formData', component.get('v._formData'));
                  component.set('v.currentStep', component.get('v.currentStep') - 1);
                }
              }));
          } else {
            if (selectedStep == component.get('v.wizardSteps').length - 2) {
              component.set('v.currentStep', selectedStep);
            } else if (selectedStep != component.get('v.wizardSteps').length - 1) {
              helper.showModal(component, warningHeading, $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Dependencies"), true)
                .then($A.getCallback(function(val) {
                  if (component.isValid() && val) component.set('v.currentStep', selectedStep);
                }));
            }
      	}
        }else{
            helper.adminReviewProgressBarChange(component,helper,selectedStep); // Hiding modals for admin on click of previous tab added by Shahrukh : US341597
        }
      // user selects a next step and the current step is valid
    } else {
      helper.save(component, helper, (selectedStep - currentStep));
    }
  },

  initializeForm : function(component, helper) {
    component.set('v.formSections', []);
    var promises = component.get('v.currentWizardStep.sections').map(function(section) {
      return new Promise(function(resolve, reject) {
          $A.createComponent("c:MarketplaceCreateProductFormSection", {
          "aura:id" : "section",
          "headline" : section.headline,
          "isAccordion" : section.isAccordion,
          "isAccordionOnlyShowCurrent" : section.isAccordionOnlyShowCurrent,
          "subsections" : section.subsections,
          "formData" : component.getReference('v.formData'),
          "currentStepTouched" : component.getReference('v.currentStepTouched'),
          "updateFormCallback" : $A.getCallback(function(refreshOption) {
              console.log("refreshOption",refreshOption);
            if (component.isValid()) {
                // checkform needs timeout to ensure components are rendered
              window.setTimeout($A.getCallback(function() {
                 helper.checkForm(component, helper);
              }));
              //Prakash 6/26 helper.checkForm(component, helper);
              if (refreshOption == 'SAVE') { helper.save(component, helper); }
              if (refreshOption == 'REFRESHONLY') { helper.save(component, helper, 0, true); }
                if(refreshOption=='deleteOffSpec'){
                    console.log('inside test-->');
                    component.set('v.deleteOffSpec', true);
                }  //added by abhishek edit POC
                /*Gireesh:US378991: edit offering visibility */
                if(refreshOption=='public'){
                    component.set('v.visibilityChanged',true);
                }
                if(refreshOption=='nonPublic'){
                    component.set('v.visibilityChanged',false);
                }
                console.log("@refreshOption",refreshOption);
                /*end Gireesh*/

            }
          })
        }, function(newComponent, status, errorMessage) {
          if (status === "SUCCESS") {
            resolve(newComponent);
          } else if (status === "INCOMPLETE") {
            reject("No response from server or client is offline.");
          } else if (status === "ERROR") {
            reject("Error: " + errorMessage);
          }
        });
      });
    });

    return Promise.all(promises).then(function(sections) {
      component.set('v.formSections', sections);
        console.log("sec:")
        console.log(sections)
      var subsections = sections.reduce(function(arr, section) {
        return arr.concat(section.find("subsection") ? [].concat(section.find("subsection")) : []);
      }, []);
      var allInputsBuilt = subsections.map(function(sub) { return sub.get('v.inputsBuiltPromise'); });
      // once all of the inputs (from all of the subsections) resolve their promises, then check the form
      return Promise.all(allInputsBuilt);
    });
  },

	checkForm : function(component, helper) {
    // gathers the state of the form based on current values of the inputs
    var formValid = false, formTouched = false, allInputs = [];
    helper.getAllSubsections(component, helper).forEach(function(subsection) {
      allInputs = allInputs.concat(subsection.find("formInput") ? [].concat(subsection.find("formInput")) : []);
    });

    var expectedInputs = component.get('v.currentWizardStep')
      .sections.reduce(function(count, section) {
        return count + section.subsections.reduce(function(c, sub) {
          return c + sub.inputs.length;
        }, 0);
      }, 0);
    // Form is INVALID until all inputs both exist and are valid
    console.log('==>>> debugging NEXT button validity', allInputs.length, expectedInputs, allInputs.map(function(i) { return i.get('v.value'); }));

   if (allInputs.length == expectedInputs) {
      formValid = true;
      allInputs.forEach(function(input) {
        if (!input.get('v.valid')) formValid = false;
        if (input.get('v.touched')) formTouched = true;
      });
      component.set('v.showSpinner', false);
    }
   console.log('formvalid-->' +formValid);


    if(window.localStorage.getItem('hideSave')=='true' || window.localStorage.getItem('hideSaveDesc')=='true')
      formTouched = false;

    component.set('v.currentStepValid', formValid);
    component.set('v.currentStepTouched', formTouched);

    if (formTouched) { component.set('v.showSavedMessage', false); }
        /*Gireesh:US378991:
        If Visibility of the Offering changed from Partner/Intel to Public
        */
        if(component.get("v.visibilityChanged")){
            helper.handleVisibilityChange(component, helper);

        }
	},

  getAllSubsections : function(component, helper) {
    var sections = component.find("section") ? [].concat(component.find("section")) : [];
    return sections.reduce(function(arr, section) {
      return arr.concat(section.find("subsection") ? [].concat(section.find("subsection")) : []);
    }, []);
  },

  setWizardData : function(component, helper, data) {
    return new Promise(function(resolve, reject) {
        console.log("steps count");
      console.log(data.steps.length);
        if (data.steps.length != 6 && data.steps.length != 5)
            reject('There must be exactly 5 steps available to the wizard.');
        if (data.steps.length == 6)
            component.set('v.hideButtons',true);
      component.set('v._category', data.category);
      component.set('v.category', data.category);
      component.set('v.formData', data.formData);
      component.set('v.formData', Object.assign({}, data.formData));
      component.set('v.wizardSteps', data.steps);

        //Added by Shahrukh US341597 : To Default last step for Admin
       /* if((data.formData.offering.PMP_Current_User_Profile_Nm__c=='1629028@intel.com.crm.nppdevpmp' || data.formData.offering.PMP_Current_User_Profile_Nm__c=='11849006@intel.com') && data.currentStep==0
           || data.formData.offering.PMP_Current_User_Profile_Nm__c=='11871086@intel.com.nppdevpmp'
           ||data.formData.offering.PMP_Current_User_Profile_Nm__c=='11875036@intel.com'){*/
        if(data.steps.length == 6){
        	component.set('v.activeStep', 5);
            component.set('v.currentStep', 5);
            component.set('v.currentWizardStep', data.steps[5]);
        }else{
          component.set('v.activeStep', data.activeStep);
          component.set('v.currentStep', data.currentStep);
          component.set('v.currentWizardStep', data.steps[data.currentStep]);
        }
      component.find('progress').set('v.pathLabels', data.steps.map(function(step) {
        console.log(step.name);
        return step.name;
      }));
      window.setTimeout($A.getCallback(function() {
  			helper.initializeForm(component, helper).then(resolve).catch(reject);
  		}));
    });
  },

  showModal : function(component, header, message, showCancelButton) {
    return new Promise(function(resolve, reject) {
      component.set('v.modalInfo', {
        header: 'Warning', message: message, showCancelButton: showCancelButton
      });

      component.set('v.showModal', true);
      component.set('v.modalCallback', $A.getCallback(function(val) { // returns true on success
        resolve(val);
        component.set('v.showModal', false);
        component.set('v.modalInfo', undefined);
        component.set('v.modalCallback', undefined);

        /*var data = component.get("v.responseData");
        component.set('v.currentStep', 0);
        component.set('v.currentWizardStep', data.steps[0]);
      	component.set('v.showSpinner', true);
        component.set('v.activeStep',0);
        helper.initializeForm(component,helper).then($A.getCallback(function() {
        	component.set('v.showSpinner', false);
      	}));	*/

      }));
    });
	},


  // ++++---- SERVER CALLS ----++++

  loadData : function(component, helper) {
    return new Promise(function(resolve, reject) {
      var action = component.get("c.getWizardData");
      console.log(component.get('v.recordId'));
      action.setParams({ offeringId: component.get('v.recordId') });
      action.setCallback(this, function(response) {
        var status = response.getState();
          if (status === "SUCCESS") {
              var response = JSON.parse(response.getReturnValue());
              if (component.get('v.debugMode')) {
                  console.log('SERVER RESPONSE getWizardData: ', response);
              }
          component.set('v.responseData',response);
          helper.setWizardData(component, helper, response).then(resolve).catch(function(e) {
            if (component.get('v.debugMode')) {
              console.error('Form Error: Something is wrong with the wizard data. ' + e, e);
            }
            reject(e);
          });
        } else if (status === "ERROR") {
          var errors = response.getError();
          if (errors && errors[0] && errors[0].message) {
            console.error(errors[0].message); reject(errors[0].message);
          } else { reject('Unknown error.'); }
        } else {
          console.error('Unknown error.'); reject('Unknown error.');
        }
      });
      $A.enqueueAction(action);
    });
  },

    saveIfNoDuplicateError : function(component,helper,params,refreshOnly,resolve){
        //console.log("saveIfNoDuplicateError");
        console.log(JSON.stringify(params.formData));
      var action = refreshOnly ? component.get("c.refreshData") : component.get("c.saveOffering");
      if (component.get('v.debugMode')) {
        console.log('SERVER REQUEST saveOffering', JSON.parse(JSON.stringify(params)));
      }
      action.setParams({ saveRequest: JSON.stringify(params) });
      action.setCallback(this, function(response) {
        var status = response.getState();
        if (status === "SUCCESS") {
          var response = JSON.parse(response.getReturnValue());
          if (component.get('v.debugMode')) {
            console.log('saveAndRefreshData response: ', response);
          }
          component.set('v.deleteOffSpec',false);
          component.set('v.responseData',response);
          helper.setWizardData(component, helper, response).then(resolve).catch(function(e) {
            if (component.get('v.debugMode')) {
              console.error('Form Error: Something is wrong with the data setup. ' + e, e);
            }
            reject(e);
          });
        } else if (status === "ERROR") {
          var errors = response.getError();
          if (errors && errors[0] && errors[0].message) {
            console.error('Error saving form: ' + errors[0].message); reject(errors[0].message);
          } else { reject('Unknown error.'); }
        } else {
          console.error('Unknown error.'); reject('Unknown error.');
        }
      });
      $A.enqueueAction(action);
    },

  saveAndRefreshData : function(component, helper, stepDelta, refreshOnly) {
      console.log("category--");
      console.log(component.get("v.category"));

      console.log("formData--");
      console.log(component.get("v.formData"));

    if (refreshOnly) console.warn('Refresh only?');
    refreshOnly = false;
    return new Promise(function(resolve, reject) {
      var stepChange = stepDelta || 0;
        //Duplicate Name check
        /**US-340188: Duplicate Name check - START* Manasa*/

        var callSave = false; // call save method variable : default, false
        var activeStep = component.get('v.activeStep'), currentStep = component.get('v.currentStep');

        //Gireesh:US356106: get selected categories
        /*var categories=[]
        if(currentStep+stepChange===1){
           categories=component.get('v.formData');
            categories.selectedCategories=JSON.stringify(helper.getSelectedAttributes(helper));
           // component.set('v.formData',categories);
        }*/

        var deleteOffSpec = component.get('v.deleteOffSpec');
        console.log('deleteOffSpec-->' +deleteOffSpec);
        var params = {
        activeStep: activeStep == currentStep && stepChange == 1 ? activeStep + 1 : activeStep,
        currentStep: currentStep + stepChange,
            stepChange : stepChange,
            deleteOffSpec:deleteOffSpec,
        category: component.get('v.category'),
            formData: component.get('v.formData') || {}, //Prakash 6/26
        };

        //APPLICABLE ONLY FOR STEP 0 - OFFERING DETAILS TAB
        if(activeStep === 0){

            var duplicateAction = component.get("c.isDuplicateOfferingServerCall");
            if(params.formData.offering.Id !=null && params.formData.offering.Name !=null
               && params.formData.offering.PMP_Company_Id__c !=null){
            	component.set('v.firstTimePageLoad',false);
                duplicateAction.setParams({strOfferingName : params.formData.offering.Name,
                                           offeringId : params.formData.offering.Id,
                                           companyId : params.formData.offering.PMP_Company_Id__c});
                duplicateAction.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('state--->',response.getState());
                    if(state === "SUCCESS"){
                    var response = JSON.parse(response.getReturnValue());

                        if(response === -1){
                                 console.log('Im here in the response -1 log');
                                  var toastEvent = $A.get("e.force:showToast");
                                  if(toastEvent){
                                      toastEvent.setParams({
                                          mode: 'dismissible',
                                          title:"Error!",
                                          message:$A.get("$Label.c.PMP_DupicateOfferingError")
                                      });
                                      toastEvent.fire();
                                  }
                                  // Dont call Save method here
                                  /*****************START*********************/
                                  callSave = false;
                                  component.set('v.firstTimePageLoad',false);
                                  component.set('v.showSpinner', false);
                                  /*****************END***********************/
                              }
                       /*else if(response === 0){

                                  helper.showModal(component, "Warning","There is another offering with the same name with other Partner. Do you want to continue ?", true)
                                  .then($A.getCallback(function(val) {

                                    if (val) {
                                    	component.set('v.showSpinner', false);
                                    	console.log('inside modal for warning');
                                    	console.log('val--------------->',val);
                                    	component.set('v.showModal', true);
                                        component.set('v.modalInfo', true);
                                        component.set('v.modalCallback', true);
                                    	// Call Save method here
                                        console.log('Im here in the response 0 log');

     										callSave = true;
                                          component.set('v.firstTimePageLoad',true);
                                          helper.saveIfNoDuplicateError(component,helper,params,refreshOnly,resolve);


                                    }
                                    else{
                                        callSave = false;
                                        component.set('v.firstTimePageLoad',false);
                                        component.set('v.showSpinner', false);
                                    }
                                  }));
                              }*/
                       else if(response === 0){
                           var retVal = confirm("There is another offering with the same name with other Partner. Do you want to continue ?");
                           if( retVal == true ){
                               // Call Save method here
                               console.log('Im here in the response 0 log');

									callSave = true;
                                 component.set('v.firstTimePageLoad',true);
                                 helper.saveIfNoDuplicateError(component,helper,params,refreshOnly,resolve);

                           }
                           else{
                               callSave = false;
                               component.set('v.firstTimePageLoad',false);
                               component.set('v.showSpinner', false);
                           }
                       }
                           else if(response === 1){
                               // Call Save method here
                               console.log('Im here in the response 1 log');
                               /********************START*******************/
      							//helper.updateForm(component);
                               callSave = true;
                                    component.set('v.firstTimePageLoad',true);
                               helper.saveIfNoDuplicateError(component,helper,params,refreshOnly,resolve);
                               /************END*****************************/
                           }
                    }
                    else if (state === "ERROR"){
                      var errors = response.getError();
                         if (errors) {
                           if (errors[0] && errors[0].message) {
                               console.log("Error message:: " +
                                                errors[0].message);
                    }
                } else{
                    console.log("Unknown error");
                }
            }
                });
                $A.enqueueAction(duplicateAction);
            }
        }
        //APPLICABLE FOR STEP OTHER THAN 0
        else if(activeStep !=0){
            console.log('inside activeStep != 0');
            callSave = true;
        }
        //offering details page loaded for the fist time
     if(component.get("v.firstTimePageLoad")){
         console.log('****offering details page loaded for the fist time*****');
        callSave = true;
        component.set('v.firstTimePageLoad',false);
     }
        console.log('callSave', callSave);
        console.log('firstTimePageLoad',component.get("v.firstTimePageLoad"));
        //CALL SAVE METHOD ONLY IF VAR callSave IS TRUE
        if(callSave){
           helper.saveIfNoDuplicateError(component,helper,params,refreshOnly,resolve);
        }
              /**US-340188: Duplicate Name check - END*Manasa*/
    });
  },


  loadPreviewData: function(component) {
    return new Promise(function(resolve, reject) {
      var action = component.get("c.getPreviewData");
      action.setParams({ offeringId: component.get('v.recordId') });
      action.setCallback(this, function(response) {
        var status = response.getState();
        if (status === "SUCCESS") {
          var response = JSON.parse(response.getReturnValue());
            console.log("preview response ");
            console.log(response);
          if (component.get('v.debugMode')) {
            console.log('getPreviewData response: ', response);
          }
         component.find('offeringPreview').set('v.data', response);
          component.find('offeringPreview').set('v.breadcrumbData', [
            { label: $A.get("$Label.c.PMP_Breadcrumbs_Marketplace_Home"), page: 'l0-marketplace' },
            { label: $A.get("$Label.c.PMP_Breadcrumbs_All_Marketplace"), page: 'l2' },
            { label: $A.get("$Label.c.PMP_Breadcrumbs_All_Products"), page: 'l2', searchParams: { type: 'product' } }
          ]);
          resolve();
        } else if (status === "ERROR") {
          var errors = response.getError();
          if (errors && errors[0] && errors[0].message) {
            console.error('Error saving form: ' + errors[0].message); reject(errors[0].message);
          } else { reject('Unknown error.'); }
        } else {
          console.error('Unknown error.'); reject('Unknown error.');
        }
      });
      $A.enqueueAction(action);
    });
  },

    /*Gireesh:US356106: create category data*/
    /*returnCategoryData:function(helper, arr){
        var  selectedOffering= new Object();
        selectedOffering.PIMCategoryId=arr[1];
        selectedOffering.PIMParentCategoryId=arr[1];
        selectedOffering.ancestorCategoryId=arr[2];
        selectedOffering.ancestorCategoryName=arr[3];
        selectedOffering.businessSegments=arr[4];
        selectedOffering.categoryName=arr[5];
        selectedOffering.childOfferingCategory=arr[6];
        selectedOffering.displayType=arr[7];
        selectedOffering.localizedNames=arr[8];
        selectedOffering.nodeExpanded=arr[9];
        selectedOffering.nodeSelected=arr[10];
        selectedOffering.recordId=arr[11];
        return selectedOffering;
        */
        /*selectedOffering.PMP_Ancestor_Category_Cd__c=arr[0];
        selectedOffering.PMP_Category_Id__c=arr[1];
        selectedOffering.Name=arr[2];
        selectedOffering.PMP_Localized_Category_Nm__c=arr[3];
        selectedOffering.PMP_Offering_Category_External_Key__c=arr[4];
        return selectedOffering;*/
    /*},*/

    /*Gireesh:US356106 :get all the selected nodes from the category object*/
    /*getSelectedAttributes:function(helper){

        var arr=['NPP_02_TYPE_Comp','NPP_01_TYPE','NPP_01_TYPE','Categories','IoT;Server;Personal Computers','Component',[],'Radiobutton','Component|组件|コンポーネント',false,true,'a3p0n000000GtFzAAK'];
        var arr2=['NPP_03_TYPE_Comp_Board','NPP_02_TYPE_Comp','NPP_02_TYPE_Comp','Categories|Component','IoT;Server;Personal Computers','Board',[],'Radiobutton','Board|主板|ボード',true,true,'a3p0n000000GtG0AAK'];
        var arr3=['NPP_02_APP_DigSecSurv','NPP_01_APP','NPP_01_APP','Application','IoT','Digital Security Surveillance',[],'Checkbox','Digital Security Surveillance|数字安全监督|デジタル・セキュリティー・サーベイランス',false,true,'a3p0n000000GtIkAAK'];

        /*var arr=['NPP_01_TYPE', 'a3p0n000000GtFzAAK','Component', 'Component|组件|コンポーネント','NPP_02_TYPE_Comp'];
        var arr2=['NPP_02_TYPE_Comp','a3p0n000000GtG0AAK','Board','Board|主板|ボード','NPP_03_TYPE_Comp_Board'];
        var arr3=['NPP_01_APP','a3p0n000000GtIkAAK','Digital Security Surveillance','Digital Security Surveillance|数字安全监督|デジタル・セキュリティー・サーベイランス','NPP_02_APP_DigSecSurv'];
        */
        /*var categories=[]
        categories.push(helper.returnCategoryData(helper,arr));

        categories.push(helper.returnCategoryData(helper,arr2));

       categories.push(helper.returnCategoryData(helper,arr3));

        console.log('getSelectedAttributes');
        console.log(categories);
        return categories;

    },*/
    //Added by Shahrukh US341597 : To set selected step after hiding warning modals
    adminReviewProgressBarChange:function(component,helper,selectedStep){
		//component.set('v.currentStepValid', true);
        component.set('v.currentStep', selectedStep);
        component.set('v.currentWizardStep', component.get('v.wizardSteps')[selectedStep]);
      	component.set('v.showSpinner', true);
        component.set('v.activeStep',selectedStep);
      	helper.initializeForm(component, helper).then($A.getCallback(function() {
        	component.set('v.showSpinner', false);
      	}));
    },

    /*Gireesh:US378991:
     * get Categories of the Offering in order to extract pre-release items based on the categories been selected
     * */
    handleVisibilityChange:function(component, helper) {
        var categories=[];
        return new Promise(function(resolve, reject) {
            var action = component.get("c.fetchOfferingDetail");
            action.setParams({ offeringId: component.get('v.recordId'),
                              bEditOffering: false,
                              bViewOffering: true,
                              bCompareOffering: true,
                             });
            action.setCallback(this, function(response) {
                var status = response.getState();
                if (status === "SUCCESS") {
                    var response = JSON.parse(response.getReturnValue());
                    if (component.get('v.debugMode')) {
                        //console.log('SERVER RESPONSE handleVisibilityChange: ', response);
                    }
                    var selectedSpecifications=response.objectData.selectedSpecifications;
                    var selectedCategories=response.objectData.selectedCategories;
                    for(var index=0;index<selectedCategories.length;index++){
                        if(selectedCategories[index].PMP_Category_Id__r!=undefined){
                            categories.push(selectedCategories[index].PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c);
                        }

                    }
                    console.log("@categories",categories);
                    //Get pre-release items based on the selected category
                    helper.getOffsetValues(component, helper, categories,response.objectData.selectedSpecifications);

                } else if (status === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.error(errors[0].message); reject(errors[0].message);
                    } else { reject('Unknown error.'); }
                } else {
                    console.error('Unknown error.'); reject('Unknown error.');
                }
            });
            $A.enqueueAction(action);
        });

    },

    /*Gireesh:US378991:
     * Get all the pre-release items and check if the curernt offering is holding any pre-release items
     * Throw error if selected and disable save and next buttons
     */
    getOffsetValues:function(component, helper, selectedCategories, selectedSpecifications) {
        var offSetValueIds=[];
        var selectedSpecificationIds=[]
        return new Promise(function(resolve, reject) {
            var action = component.get("c.getOffSetValues");
            action.setParams({ selectedCategoryIds: selectedCategories
                             });
            action.setCallback(this, function(response) {
                var status = response.getState();
                if (status === "SUCCESS") {
                    var response = JSON.parse(response.getReturnValue());
                    if (component.get('v.debugMode')) {
                        //console.log('SERVER RESPONSE getOffsetValues:', response);
                    }
                    //Extact all pre-prelease PIM Specification Value Ids
                    for(var index=0;index<response.length;index++){
                         if(response[index].PMP_Specification_Value_Id__r!=undefined &&
                            response[index].PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Cd__c!=undefined){
                             offSetValueIds.push(response[index].PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Cd__c);
                         }
                    }
                    //Extract any pre-prelease  PIM Specification Value Ids if selected for the current offering
                    for(var index=0;index<selectedSpecifications.length;index++){
                          if(selectedSpecifications[index].PMP_Specification_Value_Id__r!=undefined &&
                            selectedSpecifications[index].PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Cd__c!=undefined){
                              selectedSpecificationIds.push(selectedSpecifications[index].PMP_Specification_Value_Id__r.PMP_Product_Specification_Value_Cd__c);
                          }
                    }

                    //If atleast one pre-release item is selected, throw an error and disable save and next buttons
                    for(var index=0;index<selectedSpecificationIds.length;index++){
                        if(offSetValueIds.includes(selectedSpecificationIds[index])){
                            var toastEvent = $A.get("e.force:showToast");
                            if(toastEvent){
                                toastEvent.setParams({
                                    mode: 'dismissible',
                                    title:"Error!",
                                    message:$A.get("$Label.c.PMP_pre_release_selected")
                                });
                                toastEvent.fire();
                            }
                            component.set('v.currentStepValid', false);
                            component.set('v.currentStepTouched', false);
                            break;
                        }
                   }


                } else if (status === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.error(errors[0].message); reject(errors[0].message);
                    } else { reject('Unknown error.'); }
                } else {
                    console.error('Unknown error.'); reject('Unknown error.');
                }
            });
            $A.enqueueAction(action);
        });
    },

    scrollTop: function(component){
    var isSmoothScrollSupported = 'scrollBehavior' in document.documentElement.style;
    if (isSmoothScrollSupported){
      window.scrollTo({
        top: 0,
        behavior: 'smooth',
      });
    } else {
      // usually IE only
      window.scrollTo(0, 0);
    }
  }
})