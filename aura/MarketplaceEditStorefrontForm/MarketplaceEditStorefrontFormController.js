({
    
    doInit : function(component, event, helper) {
        var partnerId = component.get('v.recordId'); 
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
        component.set('v.isAdmin', true);
        component.set('v.isProfileAdmin',true);
        helper.resetHeading(component, helper);
        
        
        if (!component.get('v.isLocked') || component.get('v.isFromLink')) {
            
            // TODO Check if the currentStep IS VALID otherwise revert to the step that needs filling up
            helper.handleFormOpen(component, helper);
            
            // Tab Change callback (Edit state)
            component.set("v.onTabChange", $A.getCallback(function(step) {
                console.log('Tab changed : ', step);
                component.set("v.currentStep", parseInt(step));
            }));
            
            // Progress Bar callback (Create state)
            component.set('v.onstepchange', $A.getCallback(function(step) {
                
                helper.handleProgressBarChange(component, helper, step);
                console.log('Step = ', step);
            }));
            
            // Form inputs callback
            component.set('v.updateFormCallback', $A.getCallback(function(cmp) {
                var currentStep = component.get('v.currentStep');
                
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
                    
                    // Input Change:
                    window.setTimeout($A.getCallback(function() {
                        // If errors are showing, see if we can remove them
                        if (component.get("v.showErrors")) {
                            console.log('resetting errors');
                            helper.resetErrorsForCurrentStep(component, helper, component.get('v.currentStep'));
                        }
                        // Check if entire form is valid (for next/submit buttons)
                        component.set("v.formValid", helper.isFormValid(component, helper));
                    }));
                    console.log('Validity check : ', helper.isFormValid(component, helper));
                }
                
                // if  callback, check logo status
                /*if (cmp && cmp.getLocalId() == 'uploader1') {
                    console.log('img len : ', cmp.get('v.images').length);
                    
                    console.log('logourl : ', cmp.get("v.images")[0].url);
                    component.set('v.hasLogo', cmp.get('v.images').length > 0);
                    console.log('hasLogo : ', component.get("v.hasLogo"));
                    if (component.get("v.hasLogo")) {
                        console.log('logourl inside if : ', cmp.get("v.images")[0].url);
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
                var url = component.get('c.getlogoUrl');
                
                url.setParams({
                    partnerId: component.get('v.workingCopyId')
                    
                });
                url.setCallback(this, function(response) {
                    var status = response.getState();
                    
                    if (status === "SUCCESS") {
                        var returnvalue = response.getReturnValue();
                        component.set('v.logourl', returnvalue);
                    }
                    
                });
                $A.enqueueAction(url); 
                
                // if region callback, Reset Region Values
                if (cmp && cmp.getLocalId() == 'regionDropdown') {
                    helper.resetRegionValues(component, helper);
                }
                component.set('v.nextButtonDisabled', !helper.isCurrentStepValid(component, helper));
                
            }));
            
            // close modal handler
            component.set('v.closeModalCallback', $A.getCallback(function() {
                var confirmLabel = $A.get("$Label.c.PMP_Edit_Storefront_Cancel_Alert_Msg");
                if (component.get('v.formTouched') && component.get('v.currentStep') != 5) {
                    if (window.confirm(confirmLabel)) component.set('v.isOpen', false);
                } else {
                    component.set('v.isOpen', false);
                }
            }));
            
            // set initial current step default
            component.set('v.currentStep', component.get('v.currentStep') || 0);
            
            
            
            var tempSum ={ 
                logo: {},
                description: {},
                companyDetail: {},
                resources: {},
                isUpdated: false // keeps track of the modified state of the entire form
            };
            var summary = Object.assign({}, tempSum);
            component.set('v.summaryData', summary);
            
            
        } 
        
        
        /* window.setTimeout(function() {
        var leadSettings = {
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
        
        console.log('v.leadSettings', leadSettings);
      }, 3000); */
    },
    
    handlePageEvent: function(component, event, helper) {
        // alert('inside handlepageevent');
        console.log('IsIntelAdmin : ', component.get('v.isIntelAdmin'));
        console.log('status : ', component.get('v.currentStatus'));
        let paramType = event.getParam('type');
        
        if (paramType == 'openEditStoreFront' || paramType == 'openEditStoreFrontFromDraft' || paramType == 'openEditStoreFrontFromLink') {
            component.set('v.showModal', false);	
            component.set('v.isFromLink', false);
            //Added by Megha as part of US619896
            if(paramType == 'openEditStoreFrontFromDraft') {
                component.set('v.showModal',true);
            } else if(paramType == 'openEditStoreFrontFromLink') {
                component.set('v.isFromLink', true);
            }
            console.log(':::steps:::', component.get('v.steps'));
            if(!component.get('v.isFromLink')) { 
                if(component.get('v.steps').length == 0 || component.get("v.isIntelAdmin")) { //Defect Fix DE76742
                    
                    var action = component.get("c.getSteps");
                    
                    action.setCallback(this, function(response) {
                        var status = response.getState();
                        if (status === "SUCCESS") {
                            
                            component.set('v.steps',response.getReturnValue());
                            console.log('Steps : ' , response.getReturnValue());
                        } else if (status === "INCOMPLETE") {
                            console.log('callback Incomplete');
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
                }
            } else {     	
                component.set('v.showSpinner', true); 	
                component.set('v.steps', ['']);   	
                helper.fetchData(component, helper); 	
            }
            var payload = event.getParam('payload');
            console.log('payload:::',payload.currentStep);
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
        var tabset = component.find("tabset");
        if (tabset) tabset.changeTab(component.get("v.currentStep"));
        component.set("v.showErrors", false);
    },
    
    handleNextStep : function(component, event, helper) {
        console.log('step',component.get('v.currentStep'));
        var steps = component.get("v.steps"); 
        var currentStep = component.get("v.currentStep");
        var isAdmin = component.get('v.isAdmin'); 
        console.log('isAdmin',isAdmin);
        var isProfileAdmin = component.get('v.isProfileAdmin');
        console.log('isProfileAdmin',isProfileAdmin);
        //component.set('v.leadSettings',true);
        if (!helper.isStepValid(component, helper)) {
            helper.highlightInvalidFields(component, helper);
            helper.resetErrorsForCurrentStep(component, helper, currentStep);
            return;
        }
        
        var currentStep = component.get("v.currentStep");
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
                            console.log('handleUpdateStatusAdmin called');
                        }));
                        
                    }),5000);
                    
                }	
                
            }));
        }else if(component.get('v.currentStep') == 5 && !component.get('v.isIntelAdmin')){
            component.set('v.leadSettings',true);
            component.set('v.currentStep', currentStep+1);
        } else {
            component.set("v.currentStep", currentStep + 1);
            var tabset = component.find("tabset");
            if (tabset) tabset.changeTab(currentStep + 1);
        }
        
        
        /* if (currentStep == 5) {
            // console.log('proceedbutton',component.get('v.currentStep'));
            component.set("v.showSpinner", true);
            // setTimeout($A.getCallback(function(){
            component.set("v.currentStep", 6);//Lead Gen
            component.set('v.leadSettings',true);
            
            helper.handleReSubmit(component, helper).then($A.getCallback(function() {
                //  console.log('callback',component.get('v.currentStep'));
                component.set("v.showSpinner", false);
            }));
            // }),50);
        } else {
            console.log('callback else',component.get('v.currentStep')); 
            component.set("v.currentStep", currentStep + 1);
            var tabset = component.find("tabset");
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
                if (component.find("modal")) component.find("modal").scrollTo();
            }));
        }
        
        if (component.get('v.currentStep') == 3) {
            if (component.get('v.resources').length == 0) {
                // add resource w/ default values if none exists
                component.set('v.resources', [{ title: '', url: 'https://', type: '' }]);
            }            
        }
        if(component.get('v.currentStep') == 4){
            helper.formatSummaryData(component, helper)
            //console.log('logourl###',url);
            if (component.get("v.currentStep") < 4) {
                component.set("v.stepLoading", true);
                window.setTimeout($A.getCallback(function() {
                    component.set('v.stepLoading', false);
                }), 350);
            }
        }
        
    },
    
    handleGoToSummary: function(component, event, helper) {
       if(component.get('v.isIntelAdmin')){
          var steps = component.get("v.steps");
          component.set("v.currentStep", 4); 
       }else
       component.find("tabset").changeTab(4); //Added as part of DE81109
        
    },
    
    handleAddResource : function(component, event, helper) {
        var resources = component.get('v.resources');
        resources.push({ title: '', url: 'https://', type: '' });
        component.set('v.resources', resources.slice());
        window.setTimeout($A.getCallback(function() {
            component.set('v.formValid', helper.isFormValid(component, helper));
        }));
        component.set("v.resourcesError", false);
        component.set("v.showErrors", false);
    },
    
    handleDeleteResource : function(component, event, helper) {
        var idx = event.target.dataset.idx;
        var resources = component.get('v.resources');
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
        if (component.get('v.showErrors')) helper.resetErrorsForCurrentStep(component, helper);
        component.set("v.summaryData.resources.isUpdated", true);
        component.set("v.summaryData.isUpdated", true);
    },
    
    handleDropdownChange : function(component, event, helper) {
        component.set("v.formTouched", true);
        component.set("v.formValid", helper.isFormValid(component, helper));
        if (component.get('v.showErrors')) helper.resetErrorsForCurrentStep(component, helper);
        component.set("v.summaryData.resources.isUpdated", true);
        component.set("v.summaryData.isUpdated", true);
    },
    
    
    handleClose : function(component, event, helper) {
        
        component.set('v.leadSettings', false);
        if(component.get('v.currentStep') == 6 && !component.get('v.isIntelAdmin')){
            var appEvent = $A.get("e.c:MarketplacePageEvent");
            appEvent.setParams({
                type: 'saveLeadSettings'
            });
             appEvent.fire();
            
        }
        
        var confirmLabel = $A.get("$Label.c.PMP_Edit_Storefront_Cancel_Alert_Msg");
        if (
            component.get("v.formTouched") &&
            component.get("v.currentStep") != 5
        ) {
            if (window.confirm(confirmLabel)) component.set("v.isOpen", false);
        } else {
            component.set('v.isOpen', false);
        }
    },    
    
    handleUploadAdditional : function(component, event, helper) {
        component.set('v.showAdditionalUploader', true);
    },
    
    
    
    /* region */
    handleRegionChangeAll: function (component, event, helper) {
        var selected = component.find('selectAllRegionCheckbox').get('v.checked');
        var options = component.get('v.regionOptions'), anyChecked = false;
        options.forEach(function (opt) {
            opt.checked = selected;
            opt.children.forEach(function (child) {
                child.selected = selected;
            });
        });
        component.set('v.regionOptions', options);
        if(component.find('regionDropdown'))
            [].concat(component.find('regionDropdown')).forEach(function (drop) { drop.update(); });
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
        
        var allSelected = true;
        var options = component.get('v.regionOptions'), anyChecked = false;
        
        /*options.forEach(function(opt) {
			if (opt.checked) {
				anyChecked = true;
				//opt.selections = [opt.children[0].value];    //Commented by Nikhil Not needed
			} else {
				opt.children.forEach(function(child) { child.selected = false; });
				opt.selections = [];
                allSelected = false;
			}
		});*/
        //Logic updated by Nikhil
        options.forEach(function(opt) {
            if(opt.checked){
                anyChecked = true
            }else{
                opt.children.forEach(function(child) { child.selected = false; });
                opt.selections = [];
                allSelected = false;
            }
            var anyChild = false;
            opt.children.forEach(function(child){
                if(child.selected){
                    anyChild = true;
                }
            })
            if(!anyChild){
                opt.children = opt.children.map(function (child) {
                    child.selected = opt.checked;
                    return child;
                });	
            }
        });
        
        component.set('v.regionOptions', options);
        component.set('v.regionsSelectedAll', allSelected);
        if(component.find('regionDropdown'))
            [].concat(component.find('regionDropdown')).forEach(function (drop) { drop.update(); });
        component.set("v.regionError", !anyChecked);
        if(component.get('v.errorInputs').length > 0){
            component.set("v.showErrors", !anyChecked);
        }
        component.set("v.summaryData.companyDetail.isUpdated", true);
        component.set("v.summaryData.isUpdated", true);
        component.set("v.formValid", helper.isFormValid(component, helper));
        component.set('v.nextButtonDisabled', !helper.isCurrentStepValid(component, helper));
    },
    /* Industry */
    handleIndustryChange : function(component, event, helper) {
        
        console.log('handleIndustryChange');
        
        var options = component.get('v.industryOptions'), anyChecked = false;
        
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
        var anyChecked = component.get('v.applicationOptions').find(function(opt) {
            return opt.checked;
        });
        component.set('v.applicationError', !anyChecked);
        console.log('handleApplicationChange');
        
        var options = component.get('v.applicationOptions'), anyChecked = false;
        
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
        var steps = component.get("v.steps");
        component.set("v.showSpinner", true);
        component.set("v.currentStep", 5);
        if (component.find("modal")) component.find("modal").scrollTo();
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
        var incompleteTab = event.target.dataset.tab;
        
        // Tabset used on edit your storefront
        var tabset = component.find("tabset");
        
        //If Edit your Storefront
        if (tabset) {
            if (incompleteTab === "logo") tabset.changeTab("0");
            if (incompleteTab === "description") tabset.changeTab("1");
            if (incompleteTab === "regions") tabset.changeTab("2");
            if (incompleteTab === "resources") tabset.changeTab("3");
            //Else Add/Create your storefront
        } else {
            if (incompleteTab === "logo") component.set("v.currentStep", 0);
            if (incompleteTab === "description") component.set("v.currentStep", 1);
            if (incompleteTab === "regions") component.set("v.currentStep", 2);
            if (incompleteTab === "resources") component.set("v.currentStep", 3);
        }
    },
    
    handleErrorClick: function(component, event, helper) {
        var id = event.currentTarget.id;
        console.log('element id : ', id);
        var element = document.getElementById(id);
        element.scrollIntoView(true);
    },
    
    //
    handleLogoCheck : function(component, event, helper){
        
        var childObj = component.find('uploader1');
        component.set('v.logoCheck', childObj.get('v.logoCheck'));
        
    },
    
    
})