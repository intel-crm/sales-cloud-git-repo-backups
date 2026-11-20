({
    
    doInit : function(component, event, helper) {
        

        //let partnerId = component.get('v.recordId'); 
        //component.set('v.modalHeading', $A.get("$Label.c.PMP_Edit_Storefront_Heading"));
        // Summarizes all data in the last tab of the form
        component.set("v.summaryData", { 
            logo: {},
            description: {},
            regions: {},
            resources: {},
            isUpdated: false // keeps track of the modified state of the entire form
        });
        component.set("v.descriptionData",{
            description: '',
            tagline: '',
            language: ''
        });
                
        component.set('v.partner', {});
        component.set('v.showText', false);
        component.set("v.partnerNames", []);
        component.set('v.isAdmin', true);
        component.set('v.isProfileAdmin',true);
        component.set('v.isOpenCheckbox', true);
        helper.resetHeading(component, helper);
        
        
        if (!component.get('v.isLocked') || component.get('v.isFromLink')) {
            
            // TODO Check if the currentStep IS VALID otherwise revert to the step that needs filling up
            helper.handleFormOpen(component, helper);
            
            // Tab Change callback (Edit state)
            component.set("v.onTabChange", $A.getCallback(function(step) {
                
                component.set("v.currentStep", parseInt(step));
                if(step == 0) {
                   component.find("switch").set("v.checked", component.get("v.showText"));
                    /*
                    setTimeout($A.getCallback(function(){
                        helper.highlightInvalidFields(component, helper);
                    }),1000)
                    */
                }
            }));
            
            // Progress Bar callback (Create state)
            component.set('v.onstepchange', $A.getCallback(function(step) {
                
                helper.handleProgressBarChange(component, helper, step);
            }));
            
            // Form inputs callback
            component.set('v.updateFormCallback', $A.getCallback(function(cmp) {
                const currentStep = component.get('v.currentStep');
                if (cmp.get("v.touched")) {
                    component.set("v.formTouched", true);
                    
                    if (currentStep == 0) {
                        
                        component.set("v.summaryData.logo.isUpdated", true);
                        component.set("v.summaryData.isUpdated", true);
                        document.querySelector(".nextButton button").focus(); // INTEL-288 bug
                    }
                    if (currentStep == 1) {
                        
                        component.set("v.summaryData.description.isUpdated", true);
                        component.set("v.summaryData.isUpdated", true);
                    }
                    if (currentStep == 2) {
                        component.set("v.summaryData.companyDetail.isUpdated", true);
                        component.set("v.summaryData.isUpdated", true);
                    }
                  //  component.set("v.formValid", helper.isFormValid(component, helper));
                    // Input Change:
                    window.setTimeout($A.getCallback(function() {
                        // If errors are showing, see if we can remove them
                        if (component.get("v.showErrors")) {
                            
                            helper.resetErrorsForCurrentStep(component, helper, component.get('v.currentStep'));
                        }
                        // Check if entire form is valid (for next/submit buttons)
                       component.set("v.formValid", helper.isFormValid(component, helper));
                    }),5000);
                    
                }
                
                // if  callback, check logo status
                /*if (cmp && cmp.getLocalId() == 'uploader1') {
                    
                    component.set('v.hasLogo', cmp.get('v.images').length > 0);
                    
                    if (component.get("v.hasLogo")) {
                        component.set("v.logourl", cmp.get("v.images")[0].url);
                    } else {
                        component.set("v.logourl", null);
                    }
                    
                }*/
                if (cmp && cmp.getLocalId() == 'uploader1')
                {
                    component.set('v.hasLogo', cmp.get('v.images').length > 0);
                    component.set('v.LogoCheck',  cmp.get('v.images').length > 0);
                    
                }
                
                const url = component.get('c.getlogoUrl');
                const workingCopyId = component.get('v.workingCopyId');
                
                url.setParams({
                    partnerId: workingCopyId
                    
                });
                if(workingCopyId) {
                    url.setCallback(this, function(response) {
                        const status = response.getState();
                        
                        if (status === "SUCCESS") {
                            const returnvalue = response.getReturnValue();
                            component.set('v.logourl', returnvalue);
                        }
                        
                    });
                    $A.enqueueAction(url); 
                }
                // if region callback, Reset Region Values
                if (cmp /*&& cmp.getLocalId() == 'regionDropdown'*/) {
                    helper.resetRegionValues(component, helper);
                }
                component.set('v.nextButtonDisabled', !helper.isCurrentStepValid(component, helper));
                
            }));
            
            // close modal handler
            component.set('v.closeModalCallback', $A.getCallback(function() {
                const confirmLabel = $A.get("$Label.c.PMP_Edit_Storefront_Cancel_Alert_Msg");
                if (component.get('v.formTouched') && component.get('v.currentStep') != 5) {
                    if (window.confirm(confirmLabel)){ component.set('v.isOpen', false);}
                } else {
                    component.set('v.isOpen', false);
                }
            }));
            
            // set initial current step default
            component.set('v.currentStep', component.get('v.currentStep') || 0);
            
            
            
            const tempSum ={ 
                logo: {},
                description: {},
                companyDetail: {},
                resources: {},
                isUpdated: false // keeps track of the modified state of the entire form
            };
            const summary = Object.assign({}, tempSum);
            component.set('v.summaryData', summary);
            
            
        } 
        
        
        /* window.setTimeout(function() {
        let leadSettings = {
          administrator: {
            name: 'Jane Johanssen',
            email: 'jjohanssen@pyramidtech.com',
            job: 'Information Management Professional',
            phone: '11 546 43223 23432 x456'
          },
          enableLeadGeneration: true,
          limitToPartners: false,
          languagePreference: [
            {label:'English', value:'eng', selected:true},
            {label:'Francais', value:'fr', selected:true},
            {label:'Spanish', value:'o3', selected: false},
            {label:'Deutsch', value:'o4', selected: false},
            {label:'Italiano', value:'o5', selected: false}
          ]
        }
        
        component.set('v.leadSettings', leadSettings);
    
        // Update leadsettings data
        component.set('v.onLeadGenDataUpdate', $A.getCallback(function(data){
          component.set('v.leadSettings', data);
        }));
        
        
      }, 3000); */

    },

    handlePageEvent: function(component, event, helper) {
        // alert('inside handlepageevent');
        
        component.set('v.partner', {});
        component.set('v.showText', false);
        component.set("v.partnerNames", []);
        const paramType = event.getParam('type');
        
        if (paramType == 'openEditStoreFront' || paramType == 'openEditStoreFrontFromDraft' || paramType == 'openEditStoreFrontFromLink') {
            component.set('v.showModal', false);	
            component.set('v.isFromLink', false);
            //Added by Megha as part of US619896
            if(paramType == 'openEditStoreFrontFromDraft') {
                component.set('v.showModal',true);
            } else if(paramType == 'openEditStoreFrontFromLink') {
                component.set('v.isFromLink', true);
            }
            
            if(!component.get('v.isFromLink')) { 
                if(component.get('v.steps').length == 0 || component.get("v.isIntelAdmin")) { //Defect Fix DE76742
                    
                    const action = component.get("c.getSteps");
                    
                    action.setCallback(this, function(response) {
                        const status = response.getState();
                        
                        if (status === "SUCCESS") {
                            
                            component.set('v.steps',response.getReturnValue());
                            
                        } else if (status === "INCOMPLETE") {
                          
                        } else if (status === "ERROR") {
                            const errors = response.getError();
                            
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
                }
            } else {     	
                component.set('v.showSpinner', true); 	
                component.set('v.steps', ['']);   	
                helper.fetchData(component, helper); 	
            }
            const payload = event.getParam('payload');
            
            component.set('v.currentStep', parseInt(payload.currentStep) || 0);
            
            //component.set('v.activeStep', 2);
            //component.set('v.isAdmin', payload.isAdminUser);
            component.set('v.isProfileAdmin', payload.isAdminUser);
            if (payload.firstSubmission != undefined) {
                component.set("v.firstSubmission", payload.firstSubmission);
            }
            helper.resetHeading(component, helper);
            component.set('v.isOpen', true); //This step calls the handleformopen 
                        
        }     
    },
    
    handleFormOpen : function(component, event, helper) {
        
        helper.handleFormOpen(component, helper);
    },
    
    handleFormSubmit : function(component, event, helper) {
        event.preventDefault();
        return false;
    },
    
    handlePrevStep : function(component, event, helper) {
        component.set('v.currentStep', component.get('v.currentStep') - 1);
        const tabset = component.find("tabset");
        if (tabset){ tabset.changeTab(component.get("v.currentStep"));}
        component.set("v.showErrors", false);
    },
    
    handleNextStep : function(component, event, helper) {
        
        const steps = component.get("v.steps"); 
        let currentStep = component.get("v.currentStep");
        
        //component.set('v.leadSettings',true);
        if (!helper.isStepValid(component, helper)) {
            helper.highlightInvalidFields(component, helper);
            helper.resetErrorsForCurrentStep(component, helper, currentStep);
            return;
        }
        
         currentStep = component.get("v.currentStep");
        if (component.get('v.currentStep') == steps.length-1) {
            component.set('v.showSpinner', true);
            
            helper.handleReSubmit(component, helper).then($A.getCallback(function() {
                component.set('v.currentStep', steps.length);
                component.set('v.showSpinner', false);
                
                if(component.get('v.currentStep') == steps.length && component.get('v.isIntelAdmin')){ //Removed status condition
                    
                    component.set('v.showSpinner', true);
                    setTimeout($A.getCallback(function(){
                        helper.handleUpdateStatusAdmin(component, helper).then($A.getCallback(function() {
                            component.set('v.showSpinner', false);
                            
                        }));
                        
                    }),5000);
                    
                }	
                
            }));
        }else if(component.get('v.currentStep') == 5 && !component.get('v.isIntelAdmin')){
            component.set('v.leadSettings',true);
            component.set('v.currentStep', currentStep+1);
        } else {
            component.set("v.currentStep", currentStep + 1);
            const tabset = component.find("tabset");
            if (tabset) {tabset.changeTab(currentStep + 1);}
        }
        
        /* if (currentStep == 5) {
            
            component.set("v.showSpinner", true);
            // setTimeout($A.getCallback(function(){
            component.set("v.currentStep", 6);//Lead Gen
            component.set('v.leadSettings',true);
            
            helper.handleReSubmit(component, helper).then($A.getCallback(function() {
                
                component.set("v.showSpinner", false);
            }));
            // }),50);
        } else {
            
            component.set("v.currentStep", currentStep + 1);
            let tabset = component.find("tabset");
            if (tabset) tabset.changeTab(currentStep + 1);
        }*/
    },
    
    handleStepChange : function(component, event, helper) {

        component.set("v.showErrors", false);
        helper.resetSubHeading(component, helper);
        helper.resetHeading(component, helper);
        
        //component.set('v.activeStep', component.get('v.currentStep'));
        component.set('v.activeStep', 6);
        if (event.getParam("oldValue") < event.getParam("value")) {
            window.setTimeout($A.getCallback(function() {
                if (component.find("modal")) {component.find("modal").scrollTo();}
            }));
        }
        
        if (component.get('v.currentStep') == 3) {
            if (component.get('v.resources').length == 0) {
                // add resource w/ default values if none exists
            //    component.set('v.resources', [{ title: '', url: 'https://', type: '' }]); //commented and replaced with below line as part of US848310
                component.set('v.resources', [{ title: '', url: '', type: '' }]);
            }            
        }
        if(component.get('v.currentStep') == 4){
            const regionOptions1 = component.get('v.regionOptions');
             helper.formatSummaryData(component, helper)
             
             const regionsToDisplay = regionOptions1;
             
             const regionsMap = new Map();
             
            
            for(let i=0;i<regionsToDisplay.length;i++){
                if(regionsToDisplay[i].children){
                    for(let j=0;j<regionsToDisplay[i].children.length;j++){
                        for(let k=0;k<regionsToDisplay[i].children[j].children.length;k++){
                            if(regionsToDisplay[i].children[j].children[k].checked==true){
                                regionsMap.set(regionsToDisplay[i].children[j].label,regionsToDisplay[i].children[j].children[k].label);
                            }
                        }
                    }
                }
            }
            
            const regionsToDisplayFinal=[];
            
            for(let i=0;i<regionsToDisplay.length;i++){
                if(regionsToDisplay[i].checked && regionsToDisplay[i].children){
                    for(let j=0;j<regionsToDisplay[i].children.length;j++){
                        for(let k=0;k<regionsToDisplay[i].children[j].children.length;k++){
                            regionsToDisplay[i].children[j].children[k].last = false;
                            if(regionsToDisplay[i].children[j].children[k].checked==true && regionsMap.get(regionsToDisplay[i].children[j].label)==regionsToDisplay[i].children[j].children[k].label){
                               regionsToDisplay[i].children[j].children[k].last = true; 
                            }
                        }
                    }
                    regionsToDisplayFinal.push(regionsToDisplay[i]);
                }
            }
            
            component.set('v.regionsToDisplay',regionsToDisplayFinal); 
            
            if (component.get("v.currentStep") < 4) {
                component.set("v.stepLoading", true);
                window.setTimeout($A.getCallback(function() {
                    component.set('v.stepLoading', false);
                }), 350);
            }
        }
    },
    
    handleGoToSummary: function(component, event, helper) {
        if(component.get("v.isPublishedCopyDraft") || component.get("v.isIntelAdmin")) {
            component.set("v.currentStep", 4); /*Added by Manjula as part of DE77034*/
        } else {
            component.find("tabset").changeTab(4);
        }
    },
    
    handleAddResource : function(component, event, helper) {
        const resources = component.get('v.resources');
   //   resources.push({ title: '', url: 'https://', type: '' });  //commented and replaced with below line as part of US848310
   	    resources.push({ title: '', url: '', type: '' });
        component.set('v.resources', resources.slice());
        window.setTimeout($A.getCallback(function() {
            component.set('v.formValid', helper.isFormValid(component, helper));
        }));
        component.set("v.resourcesError", false);
        component.set("v.showErrors", false);
    },
    
    handleDeleteResource : function(component, event, helper) {
        const idx = event.target.dataset.idx;
        const resources = component.get('v.resources');
        resources.splice(idx, 1);
        component.set('v.resources', resources);
        window.setTimeout($A.getCallback(function() {
            component.set('v.formValid', helper.isFormValid(component, helper));
            if (component.get('v.showErrors') || !resources.length) {
                helper.resetErrorsForCurrentStep(component, helper,component.get('v.currentStep'));
            }
        }));
    },
    
    /* handleResourceChange : function(component, event, helper) {
        event.getSource().reportValidity();
        component.set("v.formTouched", true);
        component.set("v.formValid", helper.isFormValid(component, helper));
        if (component.get('v.showErrors')) helper.resetErrorsForCurrentStep(component, helper,component.get('v.currentStep'));
        component.set("v.summaryData.resources.isUpdated", true);
        component.set("v.summaryData.isUpdated", true);
    },
    
    handleResourceDropdownChange : function(component, event, helper) {
        component.set("v.formTouched", true);
        component.set("v.formValid", helper.isFormValid(component, helper));
        if (component.get('v.showErrors')) helper.resetErrorsForCurrentStep(component, helper,component.get('v.currentStep'));
        component.set("v.summaryData.resources.isUpdated", true);
        component.set("v.summaryData.isUpdated", true);
    },*/
    
    handleChange : function(component, event, helper) {
        event.getSource().reportValidity();
        component.set("v.formTouched", true);
        component.set("v.formValid", helper.isFormValid(component, helper));
        if (component.get('v.showErrors')) {helper.resetErrorsForCurrentStep(component, helper);}
        component.set("v.summaryData.resources.isUpdated", true);
        component.set("v.summaryData.isUpdated", true);
    },
    
    handleDropdownChange : function(component, event, helper) {
        component.set("v.formTouched", true);
        component.set("v.formValid", helper.isFormValid(component, helper));
        if (component.get('v.showErrors')) {helper.resetErrorsForCurrentStep(component, helper);}
        component.set("v.summaryData.resources.isUpdated", true);
        component.set("v.summaryData.isUpdated", true);
    },
    
    handleClose : function(component, event, helper) {
        
        component.set('v.leadSettings', false);
        if(component.get('v.currentStep') == 6 && !component.get('v.isIntelAdmin')){
            const appEvent = $A.get("e.c:MarketplacePageEvent");
            appEvent.setParams({
                type: 'saveLeadSettings'
            });
             appEvent.fire();
            
        }
        
        const confirmLabel = $A.get("$Label.c.PMP_Edit_Storefront_Cancel_Alert_Msg");
        if (component.get("v.formTouched") && component.get("v.currentStep") < 5) {
            if(window.confirm(confirmLabel)) { 
                component.set("v.isOpen", false);
            }
        } else {
            component.set('v.isOpen', false);
        }
    },    
    handleUploadAdditional : function(component, event, helper) {
        component.set('v.showAdditionalUploader', true);
    },
        
    /* region */
    handleRegionChangeAll: function (component, event, helper) {
        
        const selected = component.find('selectAllRegionCheckbox').get('v.checked');
        const options = component.get('v.regionOptions')
        const anyChecked=false;
        //added for select All functionality.
        if(selected){
            options.forEach(function (opt) {
               opt.checked = false; 
                opt.children.forEach(function (child) {
                    child.checked = false; 
                    child.children.forEach(function (subchild) {
                        subchild.checked = false; 
                    });
                });
                
            });
            
            
        component.set('v.regionOptions', options);
            
        options.forEach(function (opt) {
            opt.checked = true; // top level region || triggers handleRegionChange
            opt.children.forEach(function (child) {
                child.checked = true; // sub-region
            
            child.children.forEach(function (subchild) {
                subchild.checked = true; // countries.
            });
            });    
            
        });
        }else{
            options.forEach(function (opt) {
            opt.checked = false; // top level region || triggers handleRegionChange
            opt.children.forEach(function (child) {
                child.checked = false; // sub-region
            
            child.children.forEach(function (subchild) {
                subchild.checked = false; // countries.
            });
            });    
            
        });
            component.set('v.regionOptions', options);
        }    
        component.set('v.regionOptions', options);
        component.set('v.regionError', !selected);
        if(component.get('v.errorInputs').length > 0){
            component.set("v.showErrors", !anyChecked);
        }
        
        component.set("v.summaryData.companyDetail.isUpdated", true);
        component.set("v.summaryData.isUpdated", true);
        component.set("v.formValid", helper.isFormValid(component, helper));
        component.set('v.nextButtonDisabled', !helper.isCurrentStepValid(component, helper));
    },
    handleRegionChange : function(component, event, helper) {
        let allSelected = true;
        const options = component.get('v.regionOptions');
        let anyChecked = false;
        //Logic updated by Nikhil
        options.forEach(function(opt) {
            if(opt.checked){
                anyChecked = true

            }else{
                opt.children.forEach(function(child) { 
                    child.checked = false; 
                    child.children.forEach(function(subchild){
                       subchild.checked = false;
                    });    
                }); 
                opt.selections = [];
                allSelected = false;
                
            }
            let anyChild = false;
            opt.children.forEach(function(child){
                if(child.checked){
                     //added by krishna ch
                    anyChild = true;
                  child.children.forEach(function(subchild){  //added by krishna ch
                    if(subchild.checked){
                       subchild.checked = child.checked;
                     
                    }
                      else{
                          subchild.checked = false;
                           allSelected = false;
                      }
                                           
                  });
                    
                }
                else{
                    child.checked = false;
                     allSelected = false;
                }
            });
            if(!anyChild){
                opt.children = opt.children.map(function (child) {
                    return child;
                });	
            }

        });
        component.set('v.regionOptions', options);
        component.set('v.regionsSelectedAll', allSelected);
        component.set("v.regionError", !anyChecked);
        if(component.get('v.errorInputs').length > 0){
            component.set("v.showErrors", !anyChecked);
        }
        component.set("v.summaryData.companyDetail.isUpdated", true);
        component.set("v.summaryData.isUpdated", true);
        component.set("v.formValid", helper.isFormValid(component, helper));
        component.set('v.nextButtonDisabled', !helper.isCurrentStepValid(component, helper));
        component.set('v.isOpenCheckbox', false);//added by krishna ch
    },
    /* Industry */
    handleIndustryChange : function(component, event, helper) {
        
        
        
        const options = component.get('v.industryOptions');let anyChecked = false;
        
        options.forEach(function(opt) {
            if (opt.checked) {
                anyChecked = true;
                //opt.selections = [opt.children[0].value];    //Commented by Nikhil Not needed
            } else {
                opt.children.forEach(function(child) { child.selected = false; });
                opt.selections = [];
            }
        });
        
        component.set('v.industryOptions', options);
        component.set('v.industryError', !anyChecked);
        if(component.get('v.errorInputs').length > 0){
            component.set("v.showErrors", !anyChecked);
        }
        component.set("v.summaryData.companyDetail.isUpdated", true);
        component.set("v.summaryData.isUpdated", true);
        component.set("v.formValid", helper.isFormValid(component, helper));
        component.set('v.nextButtonDisabled', !helper.isCurrentStepValid(component, helper));
    },
    /* Application */
    handleApplicationChange : function(component, event, helper) {
        let anyChecked = component.get('v.applicationOptions').find(function(opt) {
            return opt.checked;
        });
        component.set('v.applicationError', !anyChecked);
        
        
        const options = component.get('v.applicationOptions');
        anyChecked = false;
        
        options.forEach(function(opt) {
            if (opt.checked) {
                anyChecked = true;
                //opt.selections = [opt.children[0].value];    //Commented by Nikhil Not needed
            } else {
                opt.children.forEach(function(child) { child.selected = false; });
                opt.selections = [];
            }
        });
        
        component.set('v.applicationOptions', options);
        component.set('v.applicationError', !anyChecked);
        if(component.get('v.errorInputs').length > 0){
            component.set("v.showErrors", !anyChecked);
        }
        component.set("v.summaryData.companyDetail.isUpdated", true);
        component.set("v.summaryData.isUpdated", true);
        component.set("v.formValid", helper.isFormValid(component, helper));
        component.set('v.nextButtonDisabled', !helper.isCurrentStepValid(component, helper));
    },
    
    handleToggleShowMoreMsg : function(component, event, helper) {
        component.set('v.showMoreMsg', !component.get('v.showMoreMsg'));
    },
    
    handleSubmitEdits: function(component, event, helper) {
        const steps = component.get("v.steps");
        component.set("v.showSpinner", true);
        component.set("v.currentStep", 0);
        if (component.find("modal")) {component.find("modal").scrollTo();}
        helper.handleReSubmit(component, helper).then($A.getCallback(function() {
            component.set('v.currentStep', steps.length);
            component.set('v.showSpinner', false);
            
            if(component.get('v.currentStep') == 6){ //Removed status condition
                
                component.set('v.showSpinner', true);
                setTimeout($A.getCallback(function(){
                    helper.handleUpdateStatusAdmin(component, helper).then($A.getCallback(function() {
                        component.set('v.showSpinner', false);                               
                    }));
                    
                }),5000);
                
            }	
            
        }));
        helper.resetHeading(component, helper);
    },
    
    handleGoBack: function(component, event, helper) {
        const incompleteTab = event.target.dataset.tab;
        
        // Tabset used on edit your storefront
        const tabset = component.find("tabset");
        
        //If Edit your Storefront
        if (tabset) {
            if (incompleteTab === "logo") {tabset.changeTab("0");}
            if (incompleteTab === "description") {tabset.changeTab("1");}
            if (incompleteTab === "regions") {tabset.changeTab("2");}
            if (incompleteTab === "resources") {tabset.changeTab("3");}
            //Else Add/Create your storefront
        } else {
            if (incompleteTab === "logo") {component.set("v.currentStep", 0);}
            if (incompleteTab === "description") {component.set("v.currentStep", 1);}
            if (incompleteTab === "regions") {component.set("v.currentStep", 2);}
            if (incompleteTab === "resources") {component.set("v.currentStep", 3);}
        }
    },
    
    handleErrorClick: function(component, event, helper) {
        const id = event.currentTarget.id;
        
        const element = document.getElementById(id);
        element.scrollIntoView(true);
    },
    
    //
    handleLogoCheck : function(component, event, helper){
        
        const childObj = component.find('uploader1');
        component.set('v.logoCheck', childObj.get('v.logoCheck'));
        console.log('check data method call');
    },
    
    switchToText: function(component, event, helper) {
        const swtch = component.find("switch");
        const flag = swtch.get("v.checked");
        component.set("v.showText", flag);
    },
  onSuppressEmailCheck: function(component, event, helper) {
        const flag = component.find("suppressEmail").get("v.checked");
        component.set("v.suppressEmail", flag);
    },
    //Added by Subash for US682883 & US685085
    companyInformationValidation: function(component, event, helper) {
       component.set("v.websiteReturnValue",true);
       helper.companyInformationValidation(component, event, helper);
    }, 
    
    partnerNameDropDownChange: function(component, event, helper) {
        const part = component.get("v.partwrapMap")
        const partner = part[component.get("v.pnameDropdown")];
        
        component.set("v.partner", partner);
        component.set("v.pnameFreeText", partner.name); //on chance of picklist the free text wil populate the same
        helper.fetchCountryAndState(component);
        helper.companyInformationValidation(component, event, helper);
    },
    
    //Added by Subash for US686667
    onCountryChange : function(component, event, helper) {
        let partner = component.get('v.partner');
        partner = partner ? partner : {};
        partner.country = event.getSource().get("v.value");
        partner.state = "";
        component.set('v.partner', partner);
        helper.fetchCountryAndState(component);
        helper.companyInformationValidation(component, event, helper);
    },
    
    onStateChange : function(component, event, helper){
        let partner = component.get('v.partner');
        partner = partner ? partner : {};
        partner.state = event.getSource().get("v.value");
        component.set('v.partner', partner);
        helper.companyInformationValidation(component, event, helper);
    },
    //End of US686667

    //Added by Ajay for form validation and tab content visibility logic
    handleCurrentStepValueChange : function(component, event, helper){
        helper.handleTabContentVisibility(component, helper, event.getParam('value'));
        console.log('check update : '+event.getParam('value'));
    },
})