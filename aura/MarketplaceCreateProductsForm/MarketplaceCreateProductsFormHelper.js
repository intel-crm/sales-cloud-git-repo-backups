({
    // IPA2.0 + US TWC4497-1631
//     goToSubmit: function (component, helper) {
//         /*Added by raj for US341586 to handle status change on submit*/

//         var action = component.get("c.submitOffering");
//         action.setParams({
//             submitRequest: JSON.stringify(component.get("v.formData")),
//             "userSelectedLanguage": component.get('v.userSelectedLanguage')
//         });
//         $A.enqueueAction(action);

//         /*---------------End-US341586--------------------------------*/
//         if(component.get('v.wizardSteps') && component.get('v.wizardSteps').length === 5){
//             window.localStorage.setItem('hideSave', false);
//         	window.localStorage.setItem('hideSaveDesc', false);
//         	window.localStorage.setItem('hideSaveCompany', false);
//             var urlEvent = $A.get("e.force:navigateToURL");
//             urlEvent.setParams({ "url": "/offering-submit" });
//             urlEvent.fire();
//         }else{
//             var data = JSON.parse(JSON.stringify(component.get('v.responseData')));
            
//             component.set('v.activeStep', component.get('v.currentStep') + 1);
//             component.set('v.showSpinner', true);
//             window.setTimeout($A.getCallback(function() {
//                 component.set('v.currentStep', component.get('v.currentStep') + 1);
//                 component.set('v.currentWizardStep', data.steps[5]);
//                 component.set('v.anyStepTouched', false);
//                 component.set('v.showSpinner', false);
//             }), 5000);
            
            
//         }
         
//     },
    
//     returnToList : function(component, helper) {
//         /* US340229 to handle cancel scenario across all tabs*/
//         //Commenting server side logic as per the show stopper defect.
//         /*var action = component.get("c.cancelOffering");
// 	action.setParams({ offeringId: component.get('v.recordId') });
//     $A.enqueueAction(action); */
//         /*---------------End-US340229--------------------------------*/
//         var urlEvent = $A.get("e.force:navigateToURL");
//         urlEvent.setParams({ "url": "/pmp-partner-offering/PMP_Partner_Offering__c/" + component.get('v.recordListViewId') });
//         urlEvent.fire();
//     },
    
//     refresh : function(component, helper) {
//         component.set('v.showSpinner', true);
//         helper.loadData(component, helper).then($A.getCallback(function() {
//             component.set('v.showSpinner', false);
//         }));
//     },
    
//     save : function(component, helper, delta, refreshOnly) {
//         component.set('v.showSpinner', true);
//         helper.saveAndRefreshData(component, helper, delta, refreshOnly).then($A.getCallback(function() {
//             component.set('v.showSpinner', false);
            
//             if(component.get('v.currentStep') < 4){
//                 window.setTimeout($A.getCallback(function() {
                    
//                     var detailCmp=component.find('details');
                    
//                     detailCmp.reInit();
//                 }));
//             }
            
            
            
            
//         }));
//     },
    
//     handleProgressBarChange : function(component, helper, selectedStep) {
//         helper.checkForm(component,helper,true);
//         var activeStep          = component.get('v.activeStep'),
//             currentStep         = component.get('v.currentStep'),
//             // previewStep         = component.get('v.wizardSteps').length - 1,
//            // previewStep = 4, //Modified by Abhishek, as there is an additional step for admin review and the preview was
//             //not working as expected.
//             currentStepValid    = component.get('v.currentStepValid'),
//             currentStepTouched  = component.get('v.currentStepTouched'),
//             warningHeading      = $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Heading");
//         var    data = component.get('v.responseData');
        
//         if(JSON.parse(JSON.stringify(data))){
//             var status = JSON.parse(JSON.stringify(data)).formData.offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c;  
//         }  
//         // does nothing if user selects the current step
//         if (selectedStep == currentStep) {
//             return;
            
//             // user selects a step too far down the path
//              //if steps are not active, even admin cannot skip tabs -- to maintain consistency
//         } else if (selectedStep > activeStep + 1) {            
//                 helper.showModal(component, warningHeading, $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Steps_In_Order"), false);  
                
            
//         } 
//             // user selects the next step, but the current step isn't completed
//             else if (selectedStep == activeStep + 1 && currentStep == activeStep && !currentStepValid) {
            
            
//                 helper.showModal(component, warningHeading, $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Current_Step_Incomplete"), false); // Hiding modals for admin
            
//             // user selects the next step (after the active step), but is currently on a previous step
//         } else if (selectedStep == activeStep + 1 && currentStep < activeStep && ((activeStep < (previewStep - 1)) || (activeStep===3 && previewStep===4))) {            
           
//                 helper.showModal(component, warningHeading, $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Steps_In_Order"), false);
            
//             // user selects a previous step than currently on
//         } else if (selectedStep < currentStep) {
//             component.set('v.showErrors', false);
//                 if (currentStepTouched) {
//                     helper.showModal(component, warningHeading, $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Unsaved_Changes"), true)
//                     .then($A.getCallback(function(val) {
//                         if (selectedStep == 0) {
//                             // helper.showModal(component, warningHeading, $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Dependencies"), true)
//                             // .then($A.getCallback(function(val) {
//                             if (component.isValid() && val) component.set('v.currentStep', selectedStep);
//                             // }));
//                         } else {
//                             if (component.isValid() && val) component.set('v.currentStep', selectedStep);
//                         }
//                     }));
//                 } else {
//                     if (selectedStep == 0) {
//                         // helper.showModal(component, warningHeading, $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Dependencies"), true)
//                         // .then($A.getCallback(function(val) {
//                         if(component.isValid())
//                             component.set('v.currentStep', selectedStep); 
//                         /*   if (component.isValid()) {//Abhishek added here
//                             //US527092:Gireesh
//                             // render the current step 0 on change of progress bar
//                             component.set('v.showSpinner', true);
                           
//                             var repsData = component.get('v.responseData');
//                             component.set('v.currentWizardStep',repsData.steps[selectedStep]);                            
//                             helper.initializeForm(component, helper).then($A.getCallback(function() {
//                                 component.set('v.showSpinner', false);
//                             }));
//                         } */
//                         //  }));
//                     } else {
//                         component.set('v.currentStep', selectedStep);
//                     }
//                 }
//             // user selects a next step and the current step is valid
//         } else {
//             //Production issue fix
//             if(!component.get('v.currentStepValid') && currentStep != previewStep){
//                 helper.showModal(component, warningHeading, $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Current_Step_Incomplete"), false);
//             }
//             //US598314 if admin navigates from Preview to admin review tab without clicking submit button   
//             else if(currentStep == previewStep && status =='Draft' && data.steps.length==6 && activeStep ==previewStep ){
//                 //helper.showModal(component, warningHeading, 'Please submit the offering to proceed further', false);
//                 helper.goToSubmit(component, helper); return;
//             }
//             //US598314 after admin review tab is activated(by clicking submit button),
//             // not required to call save if admin is naviagting back and forth from preview to admin review tab
//             else if(currentStep == previewStep && data.steps.length==6 && activeStep > previewStep ){
//                 component.set('v.showSpinner', true);
//                 component.set('v.currentStep', selectedStep);
//                 var repsData = component.get('v.responseData');                                              
//                 component.set('v.currentWizardStep',repsData.steps[selectedStep]);
//                 helper.initializeForm(component, helper).then($A.getCallback(function() {
//                 	component.set('v.showSpinner', false);
//                 }));
//             }
//             else if(data.steps.length==6 && activeStep == previewStep+1 && selectedStep == 5 ){
//                 //If form is touched, call save first and then submit as a callback.
// 					if(component.get('v.anyStepTouched')){
//                         component.set('v.showSpinner', true);
//                         component.set('v.formSections', []);
//                        helper.saveAndRefreshData(component, helper, (4 - currentStep),true).then($A.getCallback(function() {
//                            window.setTimeout($A.getCallback(function() {
//                                helper.goToSubmit(component, helper);
                           		
//                            }))
//                            component.set('v.showSpinner', false);
			                           
//                        }));
//                     }
//                 //If form remains untouched, do not save or submit
//                     else{
//                         component.set('v.showSpinner', true);
//                         component.set('v.currentStep', selectedStep);
//                         var repsData = component.get('v.responseData');                                              
//                         component.set('v.currentWizardStep',repsData.steps[selectedStep]);
//                         helper.initializeForm(component, helper).then($A.getCallback(function() {
//                             component.set('v.showSpinner', false);
//                         }));
//                     }
//                 }
            
                
//             else{
//                 helper.save(component, helper, (selectedStep - currentStep));
                
//                 //US527092:Gireesh
//                 //Save if form is touched else just render the current step on change of progress bar
//                 /*if(component.get('v.currentStepTouched')){
//                     helper.save(component, helper, (selectedStep - currentStep));    
//                 } 
//                 else{ //commneted by Abhishek 
//                     component.set('v.showSpinner', true);
//                     component.set('v.currentStep', selectedStep);
//                     var repsData = component.get('v.responseData');                                              
//                     component.set('v.currentWizardStep',repsData.steps[selectedStep]);
//                     helper.initializeForm(component, helper).then($A.getCallback(function() {
//                         component.set('v.showSpinner', false);
//                     }));                       
//                 } */  
//                 if(currentStep != previewStep && selectedStep == previewStep && component.get('v.currentStepValid')){
//                     component.set('v.formSections', []);
//                 }
//                 //Production issue fix
//                 else if(currentStep != previewStep +1 && selectedStep == previewStep +1 && component.get('v.currentStepValid')){
//                     component.set('v.formSections', []);
//                 } 
//             }
            
            
//         }
//     },
    
//     initializeForm : function(component, helper) {
//         [].concat(component.find('section')).forEach(function(s) {
//             if (s) s.destroy();
//         });
//         component.set('v.formSections', []);
        
//         var userSelectedLanguage = component.get('v.userSelectedLanguage');
        
//         var promises = component.get('v.currentWizardStep.sections').map(function(section) {
//             return new Promise(function(resolve, reject) {
//                 $A.createComponent("c:MarketplaceCreateProductFormSection", {
//                     "aura:id" : "section",
//                     "headline" : section.headline,
//                     "isAccordion" : section.isAccordion,
//                     "isAccordionOnlyShowCurrent" : section.isAccordionOnlyShowCurrent,
//                     "subsections" : section.subsections,
//                     "formData" : component.getReference('v.formData'),
//                     "currentStepTouched" : component.getReference('v.currentStepTouched'),
//                     "userSelectedLanguage" : userSelectedLanguage,
//                     "activeStep" : component.getReference('v.activeStep'),
//                     "updateFormCallback" : $A.getCallback(function(cmp,refreshOption) {
                        
                       
                        
                       
//                         // checkform needs timeout to ensure components are rendered
//                         window.setTimeout($A.getCallback(function() {
//                             if(component.isValid() ){
//                                 helper.checkForm(component, helper);
//                                 if (refreshOption == 'SAVE') { helper.save(component, helper); }
//                                 if (refreshOption == 'REFRESHONLY') { helper.save(component, helper, 0, true); }
//                                 if(refreshOption=='deleteOfferingSpecifications'){
//                                     component.set('v.activeStep',0);
//                                     component.set('v.deleteOfferingSpecifications', true);
                                   
//                                 }  //added by abhishek edit POC
//                                 /*Gireesh:US378991: edit offering visibility */
//                                 if(refreshOption=='public'){
//                                     component.set('v.activeStep',0);
//                                     component.set('v.visibilityChanged',true);
//                                 }
//                                 if(refreshOption=='nonPublic' && component.get('v.visibilityChanged') ){
//                                     component.set('v.visibilityChanged',false);
//                                 }
//                                 if(refreshOption=='both' || refreshOption=='translation_table' ){
//                                     component.set('v.translationSaveType',refreshOption );
                                    
//                                 }
//                             }
                            
                            
                            
//                         }));
                        
                        
                        
//                     })
//                 }, function(newComponent, status, errorMessage) {
//                     if (status === "SUCCESS") {
                         
                        
//                         resolve(newComponent);
//                     } else if (status === "INCOMPLETE") {
//                         reject("No response from server or client is offline.");
//                     } else if (status === "ERROR") {
//                         reject("Error: " + errorMessage);
//                     }
//                 });
//             });
//         });
    
        
//         return Promise.all(promises).then(function(sections) {
//             component.set('v.formSections', sections);
            
//             var subsections = sections.reduce(function(arr, section) {
//                 return arr.concat(section.find("subsection") ? [].concat(section.find("subsection")) : []);
//             }, []);
//             var allInputsBuilt = subsections.map(function(sub) { return sub.get('v.inputsBuiltPromise'); });
//             // once all of the inputs (from all of the subsections) resolve their promises, then check the form
//             return Promise.all(allInputsBuilt);
//         });
           
//     },
    
//     checkForm : function(component, helper, showErrors) {
//         // gathers the state of the form based on current values of the inputs
//         var formValid = false, formTouched = false, allInputs = [];
//         var showPreRelease = false;
	    
//         helper.getAllSubsections(component, helper).forEach(function(subsection) {
//             allInputs = allInputs.concat(subsection.find("formInput") ? [].concat(subsection.find("formInput")) : []);
//         });

//         var expectedInputs = component.get('v.currentWizardStep')
//         .sections.reduce(function(count, section) {
//             return count + section.subsections.reduce(function(c, sub) {
//                 return c + sub.inputs.length;
//             }, 0);
//         }, 0);
//         // Form is INVALID until all inputs both exist and are valid
        
        
//         if (allInputs.length == expectedInputs) {
//             formValid = true;
//             allInputs.forEach(function(input) {
//                 if (!input.get('v.valid')) formValid = false;
//                 if (input.get('v.touched')) formTouched = true;
		    
//                 if(input.get('v.preReleaseCount')>0){
//                    showPreRelease=true;
//                 }	
                
//                 if(input.get('v.fieldName') == 'PMP_Pre_Release_Check_Nm__c' && component.get('v.currentStep')===1 && showPreRelease && input.get('v.value')==null){
//                     formValid = false;
//                 }
                
//             });
//             component.set('v.showSpinner', false);
//         }
	    
	    
// 	//if preRelease item is checked below code will handle activation of a new sub section, 
//         //this logic will be executed only on tab2
//         if(showPreRelease && component.get('v.currentStep')===1){
//              helper.handlePreRelease(component,event,helper,false);
//         }else if(!showPreRelease && component.get('v.currentStep')===1){
//               helper.handlePreRelease(component,event,helper,true); 
//         }    
        
        
//         if(window.localStorage.getItem('hideSave')=='true' || window.localStorage.getItem('hideSaveDesc')=='true' || window.localStorage.getItem('hideSaveCompany')=='true')
//             formTouched = false;
        
        
//         component.set('v.currentStepValid', formValid);
//         component.set('v.currentStepTouched', formTouched);
        
//         if(!component.get('v.anyStepTouched')){
            
//             component.set('v.anyStepTouched', formTouched);
//         }
       
//         if (formTouched || showErrors){
//             helper.getErrorInputs(component, helper);
//         } 
        
       
        
//         if (formTouched) { component.set('v.showSavedMessage', false); }
        
        
        
//         /*Gireesh:US378991:
//         If Visibility of the Offering changed from Partner/Intel to Public
//         --commented by Abhishek -- */
//        /* if(component.get("v.visibilityChanged") ){
//             helper.handleVisibilityChange(component, helper);
//             component.set('v.visibilityChanged', false);
            
//         } */
//     },
    
//     getErrorInputs : function(component, helper) {
//     // gathers the state of the form based on current values of the inputs
//     var allInputs = [];
//     helper.getAllSubsections(component, helper).forEach(function(subsection) {
//       allInputs = allInputs.concat(subsection.find("formInput") ? [].concat(subsection.find("formInput")) : []);
//     });
    
//     //Filter to find invalid inputs
//     var errorInputs = allInputs.filter(function(input) {
//       return input.get('v.valid') == false;
//     }).map(function(input) {
//       input.showErrorMessage();
//       return {
//         name: input.get('v.name'), 
//         label: input.get('v.errorAnchorLabel') || input.get('v.label'),//Added by raj as part of merge "input.get('v.errorAnchorLabel') || [03/26]"
//         value: input.get('v.value')
//       };
//     });
    
//     var customValidationFieldNames = $A.get("$Label.c.PMP_CustomValidation_FieldNames");
//     var fieldNameArray = customValidationFieldNames.split(";");    
        
// 	var finalErrorInputs = [];    
//     errorInputs.forEach(function(input) {
//         if (input.value === "" || input.value === undefined || input.value === null){
//             finalErrorInputs.push(input);
//         }else if(input.value.length===undefined || input.value.length===0 || (input.value.length>=1 && JSON.stringify(input.value)=='[]') || (input.name=='offering__PMP_Partner_Offering_Dsc__c' && input.value.length>131072)){ //As Part of US954587 :added input.value.length>131072
//             finalErrorInputs.push(input);
//         }else if(fieldNameArray.includes(input.name)){
//             finalErrorInputs.push(input);
//         }
        
//     }); 
//     //Added By Pranjal : TWC4497-41 start
//     var currentStep = component.get('v.currentStep');
//     if(currentStep==3){
//      var vidWrapper =  allInputs[1].find('ipaOffering').get('v.videosList');
      
//         var itr = 1;
//         var allVidErrorInputList = []; 
//          vidWrapper.forEach(function(video) {
//            var vidErrorInputList = []; 
//            if(video.title==""){
//             vidErrorInputList.push({
//                 name: 'title'+itr, 
//                 label: $A.get("$Label.c.PMP_Video")+itr+" "+ $A.get("$Label.c.PMP_Title"),
//                 value: video.title
//               });
//               component.set('v.currentStepValid', false);
//         }
           
//            if(video.description==""){
//                vidErrorInputList.push({
//                    name: 'description'+itr, 
//                    label: $A.get("$Label.c.PMP_Video")+itr+" "+ $A.get("$Label.c.PMP_Description"),
//                    value: video.description
//                  });
//                  component.set('v.currentStepValid', false);
//            }
//            if(video.altText==""){
//             vidErrorInputList.push({
//                 name: 'alttext'+itr, 
//                 label: $A.get("$Label.c.PMP_Video")+itr+" "+$A.get("$Label.c.PMP_Alt_Text"),
//                 value: video.altText
//               });
//               component.set('v.currentStepValid', false);
//         }
//            if(video.id==''){   
//             vidErrorInputList.push({
//                 name: 'No Video'+itr, 
//                 label: $A.get("$Label.c.PMP_Video")+ itr +" "+$A.get("$Label.c.PMP_not_Uploaded")
//               });
//               component.set('v.currentStepValid', false);
//            }
//            allVidErrorInputList.push(...vidErrorInputList);
//            itr=itr+1;
//          });
//            component.set("v.formData.galleryWrapperList",vidWrapper);
//          finalErrorInputs.push(...allVidErrorInputList);
//       var imgWrapper = allInputs[2].get('v.images');
//          itr=0;
//       var altErrorInput={};
//       imgWrapper.forEach(function(input) {
//         var pattern=$A.get("$Label.c.PMP_RegexOfferingNamePattern");
//         var url=RegExp(pattern,"g");
//         var valid=url.test(input.altText);
//         if(!valid || input.altText==""||input.altText== undefined || input.altText === null){
//             altErrorInput = {
//                 name: 'alttext'+itr, 
//                 label: $A.get("$Label.c.PMP_Alt_Text"),
//                 value: input.altText
//               };
//               component.set('v.currentStepValid', false);
//           finalErrorInputs.push(altErrorInput);
//           }
//           itr=itr+1;
//       });
//       component.set("v.formData.imgWrapper",imgWrapper);
//     }
//     //Added By Pranjal : TWC4497-41  Ends
//     component.set('v.errorInputs', finalErrorInputs);
//         if(finalErrorInputs.length===0 || finalErrorInputs===undefined){
//            component.set('v.currentStepValid', true); 
//         }    
        
//   },
    
//     getAllSubsections : function(component, helper) {
//         var sections = component.get('v.formSections');
        
//         return sections.reduce(function(arr, section) {
//             return arr.concat(section.find("subsection") ? [].concat(section.find("subsection")) : []);
//         }, []);
//     },
    
//     setWizardData : function(component, helper, data) {
//         return new Promise(function(resolve, reject) {
           
//             if (data.steps.length != 6 && data.steps.length != 5)
//                 reject('There must be exactly 5 steps available to the wizard.');
//             if (data.steps.length == 6)
//                 component.set('v.hideButtons',true);
//             component.set('v._category', data.category);
//             component.set('v.category', data.category);
//             component.set('v.formData', data.formData);
//             component.set('v.formData', Object.assign({}, data.formData));
//             component.set('v.wizardSteps', data.steps);
            
           
//             if(data.steps.length == 6 && !component.get("v.clickNext") && data.activeStep==4 && 
//                data.currentStep==4 && data.formData.offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c != 'Draft'){
//                 component.set('v.activeStep', 5);
//                 component.set('v.currentStep', 5);
//                 component.set('v.currentWizardStep', data.steps[5]);
//             }else if(data.steps.length == 5 && data.formData.offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Update Required'){
//                 component.set('v.activeStep', data.activeStep);
//                 component.set('v.currentStep', 0);
//                 component.set('v.currentWizardStep', data.steps[0]); 
//             }
//             else{
//                 component.set('v.activeStep', data.activeStep);
//                 component.set('v.currentStep', data.currentStep);
//                 component.set('v.currentWizardStep', data.steps[data.currentStep]);   
//             }
            
//             component.find('progress').set('v.pathLabels', data.steps.map(function(step) {
//                 return step.name;
//             }));
//             window.setTimeout($A.getCallback(function() {
//                 helper.initializeForm(component, helper).then(resolve).catch(reject);
//             }));
//         });
//     },
    
//     showModal : function(component, header, message, showCancelButton) {
//         return new Promise(function(resolve, reject) {
//             component.set('v.modalInfo', {
//                 header: $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Heading"), message: message, showCancelButton: showCancelButton
//             });
            
//             component.set('v.showModal', true);
//             component.set('v.modalCallback', $A.getCallback(function(val) { // returns true on success
//                 resolve(val);
//                 component.set('v.showModal', false);
//                 component.set('v.modalInfo', undefined);
//                 component.set('v.modalCallback', undefined);
                
//                 /*var data = component.get("v.responseData");
//         component.set('v.currentStep', 0);
//         component.set('v.currentWizardStep', data.steps[0]);
//       	component.set('v.showSpinner', true);
//         component.set('v.activeStep',0);
//         helper.initializeForm(component,helper).then($A.getCallback(function() {
//         	component.set('v.showSpinner', false);
//       	}));	*/
                
//             }));
//         });
//     },
    
    
//     // ++++---- SERVER CALLS ----++++
//     // 
    
//     createNewOffering : function(component, helper){
        
//         var action = component.get("c.createRecord");
//         alert('createnewoffering');
//         action.setCallback(this, 
//                            function(response) {
//                                var state = response.getState();
//                                if (state === "SUCCESS") {
//                                    var NewRecordId=response.getReturnValue();
//                                    alert(NewRecordId);
//                                    component.set('v.recordId', NewRecordId);
//                                    component.set('v.recordListViewId', NewRecordId); 
//                                } 
//                            }); 
//         $A.enqueueAction(action);
        
//     },
    
//     loadData : function(component, helper) {
        
//         return new Promise(function(resolve, reject) {
//             var action = component.get("c.getWizardData");
            
//             action.setParams({ offeringId: component.get('v.recordId'),
//                               selectedLanguage:component.get('v.userSelectedLanguage')});
//             action.setCallback(this, function(response) {
//                 var status = response.getState();
//                 if (status === "SUCCESS") {
                    
//                     var response = JSON.parse(response.getReturnValue());
//                     component.set('v.responseData',response);

//                     helper.setWizardData(component, helper, response).then(resolve).catch(function(e) {
//                         if (component.get('v.debugMode')) {
//                             console.error('Form Error: Something is wrong with the wizard data. ' + e, e);
//                         }
//                         reject(e);
//                     });
//                 } else if (status === "ERROR") {
//                     var errors = response.getError();
//                     if (errors && errors[0] && errors[0].message) {
//                         console.error(errors[0].message); reject(errors[0].message);
//                     } else { reject('Unknown error.'); }
//                 } else {
//                     console.error('Unknown error.'); reject('Unknown error.');
//                 }
//             });
//             var requestInitiatedTime=new Date().getTime();
//             $A.enqueueAction(action);
//         });
//     },
    
//     saveIfNoDuplicateError : function(component,helper,params,refreshOnly,resolve){
//        console.log('JSON.stringify(params) :::' + JSON.stringify(params));
//         var action = refreshOnly ? component.get("c.refreshData") : component.get("c.saveOffering");
       
//         action.setParams({ saveRequest: JSON.stringify(params) });
//         action.setCallback(this, function(response) {
//             var status = response.getState();
//             if (status === "SUCCESS") {
//                 var response = JSON.parse(response.getReturnValue());
                
//                 component.set('v.deleteOfferingSpecifications',false);
//                 component.set('v.translationSaveType', null);  
//                 component.set('v.responseData',response);
                
                
//                 helper.setWizardData(component, helper, response).then(resolve).catch(function(e) {
//                     if (component.get('v.debugMode')) {
//                         console.error('Form Error: Something is wrong with the data setup. ' + e, e);
//                     }
//                     reject(e);
//                 });
                
                
//             } else if (status === "ERROR") {
//                 var errors = response.getError();
//                 if (errors && errors[0] && errors[0].message) {
//                     console.error('Error saving form: ' + errors[0].message); reject(errors[0].message);
//                 } else { reject('Unknown error.'); }
//             } else {
//                 console.error('Unknown error.'); reject('Unknown error.');
//             }
//         });
//         $A.enqueueAction(action);
//     },
    
//     saveAndRefreshData : function(component, helper, stepDelta, refreshOnly) {
        
        
//         if(component.get("v.wizardSteps").length === 6 && component.get("v.currentStepTouched") && (component.get("v.formData").offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Approved')){
//             //var formData = JSON.parse(JSON.stringify(component.get("v.formData")));
//             var formData = component.get("v.formData");
//             formData.offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Draft'; 
//             component.set("v.formData",formData); 
//         }
        
        
//         if (refreshOnly) console.warn('Refresh only?');
//         refreshOnly = false;
//         return new Promise(function(resolve, reject) {
//             var stepChange = stepDelta || 0;
//             //Duplicate Name check
//             /**US-340188: Duplicate Name check - START* Manasa*/
            
//             var callSave = false; // call save method variable : default, false
//             var activeStep = component.get('v.activeStep'), currentStep = component.get('v.currentStep');
            
//             //Gireesh:US356106: get selected categories
//             /*var categories=[]
//         if(currentStep+stepChange===1){
//            categories=component.get('v.formData');
//             categories.selectedCategories=JSON.stringify(helper.getSelectedAttributes(helper));
//            // component.set('v.formData',categories);
//         }*/
            
//             var deleteOffSpec = component.get('v.deleteOfferingSpecifications');
//             //deleteOffSpec = true;
//             var params = {
//                 activeStep: activeStep == currentStep && stepChange == 1 ? activeStep + 1 : activeStep,
//                 currentStep: currentStep + stepChange,
//                 stepChange : stepChange,
//                 deleteOfferingSpecifications:deleteOffSpec,
//                 category: component.get('v.category'),
//                 formData: component.get('v.formData') || {}, //Prakash 6/26
// 		selectedLanguage: component.get('v.userSelectedLanguage'),
//                 translationSaveType : component.get('v.translationSaveType ')
//             };
            
//             //APPLICABLE ONLY FOR STEP 0 - OFFERING DETAILS TAB
//             if(currentStep === 0){
//                 var validateOfferingDataAction = component.get("c.validateOfferingDataServerCall");
//                 if(params.formData.offering.Id !=null && params.formData.offering.PMP_Partner_Offering_Nm__c !=null
//                    && params.formData.offering.PMP_Company_Id__c !=null){
//                     component.set('v.firstTimePageLoad',false);
//                     validateOfferingDataAction.setParams({checkRequestData : JSON.stringify(params.formData)});
//                     validateOfferingDataAction.setCallback(this, function(response) {
//                         var state = response.getState();
                        
//                         if(state === "SUCCESS"){
//                             var response = JSON.parse(response.getReturnValue());
                            
//                             if(response === -1){
                                
//                                 var toastEvent = $A.get("e.force:showToast");
//                                 if(toastEvent){
//                                     toastEvent.setParams({
//                                         mode: 'dismissible',
//                                         title:$A.get("$Label.c.PMP_Error")+'!',
//                                         message:$A.get("$Label.c.PMP_DupicateOfferingError")
//                                     });
//                                     toastEvent.fire();
//                                 }
//                                 // Dont call Save method here
//                                 /*****************START*********************/
//                                 callSave = false;
//                                 component.set('v.firstTimePageLoad',false);
//                                 component.set('v.showSpinner', false);
//                                 /*****************END***********************/
//                             }
//                             /*else if(response === 0){
//                                   helper.showModal(component, "Warning","There is another offering with the same name with other Partner. Do you want to continue ?", true)
//                                   .then($A.getCallback(function(val) {
//                                     if (val) {
//                                     	component.set('v.showSpinner', false);
                                    	
//                                     	component.set('v.showModal', true);
//                                         component.set('v.modalInfo', true);
//                                         component.set('v.modalCallback', true);
//                                     	// Call Save method here
                                       
//      										callSave = true;
//                                           component.set('v.firstTimePageLoad',true);
//                                           helper.saveIfNoDuplicateError(component,helper,params,refreshOnly,resolve);
//                                     }
//                                     else{
//                                         callSave = false;
//                                         component.set('v.firstTimePageLoad',false);
//                                         component.set('v.showSpinner', false);
//                                     }
//                                   }));
//                               }*/
//                         else if(response === 0){
//                             var retVal = confirm($A.get("$Label.c.PMP_DuplicatePartnerExist"));
//                             if( retVal == true ){
//                                 // Call Save method here
                               
                                
//                                 callSave = true;
//                                 component.set('v.firstTimePageLoad',true);
//                                 helper.saveIfNoDuplicateError(component,helper,params,refreshOnly,resolve);
                                
//                             }
//                             else{
//                                 callSave = false;
//                                 component.set('v.firstTimePageLoad',false);
//                                 component.set('v.showSpinner', false);
//                             }
//                         }
//                             else if(response === 1){
//                                 // Call Save method here
                                
//                                 /********************START*******************/
//                                 //helper.updateForm(component);
//                                 callSave = true;
//                                 component.set('v.firstTimePageLoad',true);
//                                 helper.saveIfNoDuplicateError(component,helper,params,refreshOnly,resolve);
//                                 /************END*****************************/
//                             }
//                                 else if(response === -2){
//                                     var toastEvent = $A.get("e.force:showToast");
//                                     if(toastEvent){
//                                         toastEvent.setParams({
//                                             mode: 'dismissible',
//                                             title:$A.get("$Label.c.PMP_Error")+'!',
//                                             message:$A.get("$Label.c.PMP_NonISAOffering_ErrorMsg")
//                                         });
//                                         toastEvent.fire();
//                                         callSave = false;
//                                         component.set('v.firstTimePageLoad',false);
//                                         component.set('v.showSpinner', false);
//                                     }
//                                 }
//                     }
//                     else if (state === "ERROR"){
//                         var errors = response.getError();
//                         if (errors) {
//                             if (errors[0] && errors[0].message) {
//                                 console.log("Error message:: " +
//                                             errors[0].message);
//                             }
//                         } else{
//                             console.log("Unknown error");
//                         }
//                     }
//                 });
//                 $A.enqueueAction(validateOfferingDataAction);
//             }
//         }
//             //Applicable for step 3
//             else if(currentStep ===3){
//                 callSave = true;
//                 component.set('v.firstTimePageLoad',true);
//                 /* DEFECT FIX : DE51223 - START :Sandhya */
//                 var isTitleOnlyWithSpaceVal = false;
//                 if(params.formData.productWebPageData.Name){
//                     var titleVal= params.formData.productWebPageData.Name;
//                     var titleValAfterTrim = titleVal.trim();
//                     if(titleValAfterTrim.length === 0){
//                         isTitleOnlyWithSpaceVal = true;
                        
//                     }
//                 }
//                 /* DEFECT FIX : DE51223 - END : Sandhya */
//                 if(((!params.formData.productWebPageData.Url && params.formData.productWebPageData.Name ) ||
//                     (params.formData.productWebPageData.Url && !params.formData.productWebPageData.Name)) || isTitleOnlyWithSpaceVal){
//                     var toastEvent = $A.get("e.force:showToast");
//                     if(toastEvent){
//                         toastEvent.setParams({
//                             mode: 'dismissible',
//                             title:$A.get("$Label.c.PMP_Error")+'!',
//                             message:$A.get("$Label.c.PMP_ProductWebUrl_ErrorMsg")
//                         });
//                         toastEvent.fire();
//                     }
//                     callSave = false;
//                     component.set('v.showSpinner', false);
//                     component.set('v.firstTimePageLoad',false);
//                     component.set('v.currentStepValid',false);
//                 }
//                 else{
//                     component.set('v.formSections', []);
//                 }
//             }
//             //APPLICABLE FOR STEP OTHER THAN 0
//                 else if(currentStep !=0){
                    
//                     callSave = true;
//                 }
//             //offering details page loaded for the fist time
//             if(component.get("v.firstTimePageLoad")){
                
//                 callSave = true;
//                 component.set('v.firstTimePageLoad',false);
//             }
            
//             //CALL SAVE METHOD ONLY IF VAR callSave IS TRUE
//             if(callSave){
//                 helper.saveIfNoDuplicateError(component,helper,params,refreshOnly,resolve);
//             }
//             /**US-340188: Duplicate Name check - END*Manasa*/
//         });
//     },
    
    
//    /* loadPreviewData: function(component) {
//         return new Promise(function(resolve, reject) {
//             var action = component.get("c.getPreviewData");
//             action.setParams({ offeringId: component.get('v.recordId') });
//             action.setCallback(this, function(response) {
//                 var status = response.getState();
//                 if (status === "SUCCESS") {
//                     var response = JSON.parse(response.getReturnValue());
                   
                    
//                     component.find('offeringPreview').set('v.data', response);
//                     component.find('offeringPreview').set('v.breadcrumbData', [
//                         { label: $A.get("$Label.c.PMP_Breadcrumbs_Marketplace_Home"), page: 'l0-marketplace' },
//                         { label: $A.get("$Label.c.PMP_Breadcrumbs_All_Marketplace"), page: 'l2' },
//                         { label: $A.get("$Label.c.PMP_Breadcrumbs_All_Products"), page: 'l2', searchParams: { type: 'product' } }
//                     ]);
//                     resolve();
//                 } else if (status === "ERROR") {
//                     var errors = response.getError();
//                     if (errors && errors[0] && errors[0].message) {
//                         console.error('Error saving form: ' + errors[0].message); reject(errors[0].message);
//                     } else { reject('Unknown error.'); }
//                 } else {
//                     console.error('Unknown error.'); reject('Unknown error.');
//                 }
//             });
//             $A.enqueueAction(action);
//         });
//     },
//     */
    
//     //Added by Shahrukh US341597 : To set selected step after hiding warning modals
//    /* adminReviewProgressBarChange:function(component,helper,selectedStep){
//         //component.set('v.currentStepValid', true);
//         component.set('v.currentStep', selectedStep);
//         component.set('v.currentWizardStep', component.get('v.wizardSteps')[selectedStep]);
//         component.set('v.showSpinner', true);
//         // component.set('v.activeStep',selectedStep);
//         helper.initializeForm(component, helper).then($A.getCallback(function() {
//             component.set('v.showSpinner', false);
//         }));
//     },
//     */
    
    
    
//     /*Gireesh:US378991:
//      * check if any pre-release items are selected
//      * --commented by Abhishek-- */
//    /* handleVisibilityChange:function(component, helper) {
//         return new Promise(function(resolve, reject) {
//             var action = component.get("c.getOffSetValues");
//             action.setParams({ offeringId:component.get("v.recordId")
//                              });
//             action.setCallback(this, function(response) {
//                 var status = response.getState();
//                 if (status === "SUCCESS") {
//                     var response = JSON.parse(response.getReturnValue());
                    
//                     if(response){
//                         var toastEvent = $A.get("e.force:showToast");
//                         if(toastEvent){
//                             toastEvent.setParams({
//                                 mode: 'dismissible',
//                                 title:$A.get("$Label.c.PMP_Error")+'!',
//                                 message:$A.get("$Label.c.PMP_pre_release_selected")
//                             });
//                            // toastEvent.fire();
//                         }
//                         component.set('v.currentStepValid', false);
//                         component.set('v.currentStepTouched', false);  
//                     }
                    
                    
//                 } else if (status === "ERROR") {
//                     var errors = response.getError();
//                     if (errors && errors[0] && errors[0].message) {
//                         console.error(errors[0].message); reject(errors[0].message);
//                     } else { reject('Unknown error.'); }
//                 } else {
//                     console.error('Unknown error.'); reject('Unknown error.');
//                 }
//             });
//             $A.enqueueAction(action);
//         });
        
//     }, */
    
    
    
//     scrollTop: function(component){
//         var isSmoothScrollSupported = 'scrollBehavior' in document.documentElement.style;
//         if (isSmoothScrollSupported){
//             window.scrollTo({
//                 top: 0,
//                 behavior: 'smooth',
//             });
//         } else {
//             // usually IE only
//             window.scrollTo(0, 0);
//         }
//     },
    
//     handleShowToast : function(component, event, helper) {
//     var toastEvent = $A.get("e.force:showToast");
//     toastEvent.setParams({
//         mode: 'pester',
//         key: 'error',
//         type: 'error',
//         message: $A.get("$Label.c.PMP_Toast_RequiredFieldsErrorMessage")
//     });
//     toastEvent.fire();
//   },
//   //Below code handles show and hide of pre release section  
//   handlePreRelease : function(component, event, helper, sectionActive) {
//      var allInputs = []; 
//      helper.getAllSubsections(component, helper).forEach(function(subsection) {
//                 if(subsection.get('v.headline') == $A.get( "$Label.c.PMP_PreRelease_SubSection_Name" )){
//                    subsection.set('v.notActive',sectionActive);
//                    allInputs = allInputs.concat(subsection.find("formInput") ? [].concat(subsection.find("formInput")) : []);
                    
//                   allInputs.forEach(function(input) {
                        
                        
//                         if (input.get('v.fieldName') == 'PMP_Pre_Release_Check_Nm__c'){
//                             if(!sectionActive){
//                                 input.set('v.required',!sectionActive);
//                                 if(input.get('v.value')==null){
// 				   input.set('v.valid',false);
//                                 }
//                             }else{
//                                 input.set('v.required',false);
//                             	input.set('v.valid',true);
//                                 var options = input.get('v.options');
                                
//                                 var finaloptions = [];
//                                 options.forEach(function(option,idx){
//                                 	option.isSelected = null;
//                                 	finaloptions.push(option);
//                                 });
//                             	input.set('v.options',finaloptions);
//                             	input.set('v.value',null);
                                
//                             }    
                            
//                         }    
//         			});   
//                 }
//             });
//   },
    
//     toggleFieldMandatory : function(component,helper,fieldName,isMandatory){        
        
//         var allInputs = [];
//         //get all subsections and iterate over their inputs.
//         helper.getAllSubsections(component, helper).forEach(function(subsection) {           
//             allInputs = allInputs.concat(subsection.find("formInput") ? [].concat(subsection.find("formInput")) : []);
            
//         });        
//             allInputs.forEach(function(input) {
                           
//                 // set the field as mandatory/non mandatory based on the parameter received.
//                 // if current field name matches the filed name to be toggled
//                 if (input.get('v.inputSpecId') == fieldName){                    
                   
//                     //if mandatory.
//                     //TODO: add one more parameter to the event called disable field 
//                     // so that the event handling becomes more generic.
//                     if(isMandatory){                        
//                         //if field was intially required, only then make it mandatory else not mandatory
//                         input.set('v.required', input.get('v.originallyRequired')); 
//                         input.set('v.disabled',false); //todo: Need to add isDisabled as a parameter to event.
//                         //if field was intially required, only then it is invalid else valid
//                         input.set('v.valid',!input.get('v.originallyRequired')); 
//                         $A.util.removeClass(input.find('input'), "hide-error-message"); // show error message 
                       
//                     }
                    
//                     //if field is not mandatory
//                     else{
//                         input.set('v.valid', true);
//                         input.set('v.hasError', false);
//                         console.log('insideElse' , input.get('v.hasError'));
//                         /* Below lines of code to remove error and hide error messsage is required, as 
//                          * Lighnting input is not automatically updating the CSS when the component is set
//                          * as isValid = true.
//                         */
//                         $A.util.removeClass(input.find('input'),'slds-has-error'); // remove red border
//     					$A.util.addClass(input.find('input'), "hide-error-message"); // custom css class to hide error message 
                        
//                         //input.set('v.touched', true);
//                         input.set('v.required', false); 
//                         input.set('v.disabled',true);
//                         input.set('v.value', ''); //clear the user entered value                        
                        
//                     }
                    
//                 }
//             }); 
//     	},
//       //Poc End
//       /* ---------------------------
//      @ Part of Livelier #214:To Show Error Page
//      @ Added by Pranjal
//      @ Created on 14-Feb-2021
//      @ Description: to Show Error Page if URL  
//      ---------------------------*/
//       navigateToErrorPage : function(component,helper){
//         var marketplaceUrl = $A.get('$Label.c.PMP_Marketplace_Community_URL');
//         window.location.href = marketplaceUrl + '/error';
//     },
    
})