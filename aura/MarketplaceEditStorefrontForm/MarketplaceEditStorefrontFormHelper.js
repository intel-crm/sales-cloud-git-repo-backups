({
    
    handleFormOpen : function(component, helper) {
        console.log('handleFormOpen',!component.get('v.isOpen'));
        if (!component.get('v.isOpen')) return;
        // reset form
		component.set('v.formTouched', false);
        component.set('v.industryError', false);
        component.set('v.applicationError', false);
        component.set('v.regionError', false);
		component.set('v.resourcesError', false);
  		            
             
        component.set('v.showSpinner', true);
        
        helper.fetchData(component, helper).then($A.getCallback(function() {
            
            component.set('v.showSpinner', false);
            helper.resetHeading(component, helper);
            helper.resetSubHeading(component, helper);
        }));
    },

    fetchData : function(component, helper) {
        console.log('fetchData');
        var userLangCode = $A.get("$Locale.langLocale");
        return new Promise($A.getCallback(function(resolve, reject) {
            //check Locked status
            var action = component.get("c.isLocked");
            action.setParams({
                partnerId: component.get('v.partnerId')
                
            });
            
            action.setCallback(this, function(response) {
                var status = response.getState();
                if (status === "SUCCESS") {
                    var isLocked = component.get('v.isFromLink') ? false : response.getReturnValue();
                    component.set('v.isLocked',isLocked);
                    console.log('Locked = ',isLocked);
                    if(isLocked){
                        resolve();
                    }
                    if(!isLocked){
                        console.log('fetching Data')
                        var fetchData = component.get("c.getPartnerExistingData");
                        
                        fetchData.setParams({
                            'partnerId':component.get('v.partnerId'),
                            'langCode': userLangCode
                        });
                        fetchData.setCallback(this, function(response) {
                            var status = response.getState();
                            
                            if (status === "SUCCESS") {
                                var returnValue = response.getReturnValue();
                                console.log('ReturnValue :', returnValue);
                                component.set('v.currentStatus',returnValue.currentStatus);
                                if(returnValue.currentStatus == 'Draft' || returnValue.currentStatus == null)
                                	component.set('v.isFirstDraft', true);
                                //Step-1 LOGO
                                component.set('v.workingCopyId', returnValue.workingCopyId);
                                component.set('v.logoCheck', returnValue.logoCheck);
                                
                                if(component.get('v.isFromLink')) {       	
                                    helper.getLogoURL(component, helper);       	
                                }
                                
                                //STEP-2 DESCRIPTION
                                component.set('v.descriptionData', returnValue.descriptionData);
                                console.log('Desc in fetchData : ', component.get('v.descriptionData').description.length);
                                //STEP-3 COMPANY DETAILS
                                //INDUSTRY
                                var indOptions = returnValue.industryOptions;
                                var indsSelected = returnValue.industriesSelected;
                                indOptions.forEach(function(opt) {
                                    
                                    opt.checked = indsSelected.includes(opt.value);
                                    
                                    opt.children.forEach(function(child){
                                        child.selected = indsSelected.includes(child.value);
                                    });
                                    
                                });
                                component.set('v.industryOptions',indOptions);
                                
                                //APPLICATION 
                                var appOptions = returnValue.applicationOptions;
                                var appsSelected = returnValue.applicationsSelected;
                                appOptions.forEach(function(opt) {
                                    
                                    opt.checked = appsSelected.includes(opt.value);
                                    
                                    opt.children.forEach(function(child){
                                        child.selected = appsSelected.includes(child.value);
                                    });
                                    
                                });
                                component.set('v.applicationOptions',appOptions);
                                
                                //GEOGRAPHIC COVERAGE
                                var regionOptions = returnValue.regionOptions;
                                var regionsSelected = returnValue.regionsSelected;
                                console.log('regionsSelected',regionsSelected);
                                regionOptions.forEach(function(opt) {
                                    opt.checked = regionsSelected.includes(opt.value);
                                    
                                    opt.children.forEach(function(child){
                                        child.selected = regionsSelected.includes(child.value);
                                    });
                                });
                                component.set('v.regionOptions', regionOptions);
                                console.log('regions',regionOptions)
                                //component.set('v.regionsSelected', regionsSelected);
                                
                                //STEP-4 RESOURCES
                                component.set('v.resources', returnValue.resourceData.resources);
                                component.set('v.resourceTypeOptions', returnValue.resourceData.resourceTypes);
                                
                                //STEP-5 ADMIN REVIEW
                                component.set('v.loggedInAdmin',returnValue.admin);
                                component.set('v.admins',returnValue.adminList);
                                component.set('v.statusList',returnValue.statusList);
                                component.set('v.submittedOn',returnValue.submittedOn);
                                component.set('v.submittedBy',returnValue.submittedBy);
                                component.set('v.isPublishedCopyDraft', returnValue.isPublishedCopyDraft);
                                
                                if(component.get('v.isFromLink')) {       	
                                    helper.formatSummaryData(component, helper);     	
                                    component.set('v.showSpinner', false);         	
                                }           	
                                console.log(':::end formatSummaryData:::', component.get('v.summaryData'));
                                console.log(returnValue.isPublishedCopyDraft+ ' isPublishedCopyDraft');
                                
                                component.set('v.showSpinner', false);
                                //
                                resolve();
                                
                            } else if (status === "INCOMPLETE") {
                                console.log('callback Incomplete');
                                reject();
                            } else if (status === "ERROR") {
                                var errors = response.getError();
                                if (errors) {
                                    if (errors[0] && errors[0].message) {
                                        console.error(errors[0].message);
                                        
                                    };
                                }
                                reject(errors);
                            } else {
                                reject('Unknown error.');
                            }
                        });
                        
                        $A.enqueueAction(fetchData);
                    }
                    
                } else if (status === "INCOMPLETE") {
                    console.log('callback Incomplete');
                    reject();
                } else if (status === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error(errors[0].message);
                            
                        };
                    }
                    reject(errors);
                } else {
                    reject('Unknown error.');
                }
            });
            $A.enqueueAction(action);
            
     
        })); 
        
    },
    
    getLogoURL : function(component, helper) {   	
        	
        var url = component.get('c.getlogoUrl');       	
        	
        url.setParams({        	
            partnerId: component.get('v.workingCopyId')       	
            	
        });  	
        console.log(':::getLogoURL workingCopyId:::', component.get('v.workingCopyId'));   	
        url.setCallback(this, function(response) {      	
            var status = response.getState(); 	
            console.log(':::getLogoURL:::', status);       	
            if (status === "SUCCESS") {              	
                var returnvalue = response.getReturnValue();   	
                console.log(':::logoURL:::', returnvalue);              	
                component.set('v.hasLogo', true);          	
                component.set('v.logourl', returnvalue);             	
            } 	
            	
        });  	
        $A.enqueueAction(url);        	
    },
    
    handleProgressBarChange : function(component, helper, step) {
        
        if (helper.isCurrentStepValid(component, helper)) {
            if(step == 4 && !component.get('v.isIntelAdmin')){
                component.set('v.formValid', true);
            }
            component.set('v.currentStep', step);
        } else {
           helper.highlightInvalidFields(component, helper);
           helper.resetErrorsForCurrentStep(component, helper, component.get('v.currentStep')); 
        }
    },
    
    handleReSubmit : function(component, helper) {
        
        return new Promise($A.getCallback(function(resolve, reject) {
            var data = helper.generateFormData(component, helper);
            console.log('DATA', JSON.parse(JSON.stringify(data)));
            
            var action = component.get("c.saveEditFormData");
            action.setParams({
                'partnerId':component.get('v.partnerId'),
                'requestJSON': JSON.stringify(data)
            });
            action.setCallback(this, function(response) {
                var steps = component.get('v.steps');
                var status = response.getState();
                console.log('Status',status);
                if (status === "SUCCESS") {
                    
                    var returnValue = response.getReturnValue();
                    console.log('Success' + returnValue);
                    
                    resolve();
                } else if (status === "INCOMPLETE") {
                    // do something?
                    reject();
                } else if (status === "ERROR") {
                    var errors = response.getError();
                    console.log('Errors' , errors[0].message);
                    console.error(errors[0]);
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error(errors[0].message);
                        };
                    }
                    reject(errors);
                } else {
                    reject('Unknown error.');
                }
            });
            
            $A.enqueueAction(action);
        }));
        
        
        
        
        /*  return new Promise(function(resolve, reject) {
		var data = helper.generateFormData(component, helper);
		console.log('DATA', JSON.parse(JSON.stringify(data)));
		
		// SAVE DATA TO SERVER HERE
		
          
		//Save action Ends

		window.setTimeout(resolve, 1000); // mock a 1s server call
	  }); */
    },
    
    handleUpdateStatusAdmin	: function(component, helper){
        
        return new Promise($A.getCallback(function(resolve, reject) {
            var data = helper.generateFormData(component, helper);
            console.log('step 5');
            console.log('Admin data : ' , data);            
            var action = component.get("c.updateStatusAdmin");
            action.setParams({
                'partnerId':component.get('v.partnerId'),
                'requestJSON': JSON.stringify(data)
            });
            action.setCallback(this, function(response) {
                
                var status = response.getState();
                console.log('Status',status);
                if (status === "SUCCESS") {
                    
                    var returnValue = response.getReturnValue();
                    
                    resolve();
                } else if (status === "INCOMPLETE") {
                    // do something?
                    reject();
                } else if (status === "ERROR") {
                    var errors = response.getError();
                    console.log('Errors' , errors[0].message);
                    console.error(errors[0]);
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error(errors[0].message);
                        };
                    }
                    reject(errors);
                } else {
                    reject('Unknown error.');
                }
            });
            
            $A.enqueueAction(action);
        }));
    }, 
    
    generateFormData : function(component, helper) {
        console.log('generateFormData');
        console.log('Desc : ', component.get('v.descriptionData'));
        return {
            descriptionData: component.get('v.descriptionData'),
            
            regionsSelected: component.get('v.regionOptions').reduce(function(arr, opt) {
                /*if (opt.checked){                    
                    arr.push(opt.value);
                    arr = arr.concat(opt.selections);    
                }*/
                if (opt.checked) arr.push(opt.value);
                
                opt.children.forEach(function(child) {
                    if (child.selected) arr.push(child.value);
                })
                return arr;
            }, []),
            
            //Added by Nikhil
            applicationsSelected: component.get('v.applicationOptions').reduce(function(arr, opt) {
                /* if (opt.checked){
                    arr.push(opt.value);
                    arr = arr.concat(opt.selections);     
                } */
                if (opt.checked) arr.push(opt.value);
                
                opt.children.forEach(function(child) {
                    if (child.selected) arr.push(child.value);
                })
                return arr;
            }, []),
            //Added by Nikhil
            industriesSelected: component.get('v.industryOptions').reduce(function(arr, opt) {
                /*if (opt.checked){
                    arr.push(opt.value);
                    arr = arr.concat(opt.selections);   
                } */
                if (opt.checked) arr.push(opt.value);
                
                opt.children.forEach(function(child) {
                    if (child.selected) arr.push(child.value);
                })                
                return arr;
            }, []),
            
            resources: component.get('v.resources'),
            
            //STEP-5 ADMIN REVIEW 
            status:component.get('v.currentStatus'),
            admin:component.get('v.loggedInAdmin')
        };
    },
    
    isFormValid : function(component, helper) {
         var data = helper.generateFormData(component, helper), msgs = [];
        console.log('isFormValid_data:', data);
        var currentStep = component.get('v.currentStep');
        
        // step 1
        
        if (currentStep == 0) {
            var logo = component.find("uploader1").get('v.images').length > 0;
            component.set('v.logoCheck',logo);
        }
        var logoCheck = component.get('v.logoCheck');
        if (!logoCheck) msgs.push($A.get("$Label.c.PMP_Edit_Storefront_Logo_Error"));
        
        // step 2 
        console.log('data.descriptionData :', data.descriptionData);
        if (data.descriptionData && !data.descriptionData.tagline) msgs.push($A.get("$Label.c.PMP_Edit_Storefront_Tagline_Error"));
        //if (!data.descriptionData.tagline) msgs.push($A.get("$Label.c.PMP_Edit_Storefront_Tagline_Error"));
        if (data.descriptionData && !data.descriptionData.language) msgs.push($A.get("$Label.c.PMP_Edit_Storefront_Language_Error"));
        if (data.descriptionData && !data.descriptionData.description) msgs.push($A.get("$Label.c.PMP_Edit_Storefront_Description_Error"));
        
        // step 3
        
        
        if (!data.industriesSelected.length) msgs.push('You need to select at least one industry.');
        if (!data.applicationsSelected.length) msgs.push('You need to select at least one application.');
        if (!data.regionsSelected.length) msgs.push('You need to select at least one region.');
        // step 4
        if (!data.resources.length) msgs.push('You need at least one resource.');
        
        component.set('v.formErrorMsgs', msgs);
        
        var resources = component.find("resource") ? [].concat(component.find("resource")) : [];
        var resourcesValid = true;
        resources.forEach(function(input) {
            if(!input.checkValidity()) resourcesValid = false;
        });
        
        
        
        console.log('isFormValid END');        
        return (resourcesValid && msgs.length == 0); 
        return [0,1,2,3].find(function(step) {
            return !helper.isStepValid(component, helper, step);
        }) ? false : true;  
    },
    
    isCurrentStepValid : function(component, helper, step) {
        
        var currentStep = component.get('v.currentStep');
        var data = helper.generateFormData(component, helper);
        
        console.log('isCurrentStepValid', data);
        
        /*   if (step == 0) {
            console.log('inside isCurrentStepValid-------'+component.get('v.logoCheck'));
            if (!component.get('v.logoCheck')) {
                return component.find("formInput").reportValidity();
            }
        }*/
        
        if (currentStep == 0){
            var hasLogo = component.find("uploader1").get('v.images').length > 0;
            component.set('v.logoCheck',hasLogo);
            if (!hasLogo) {
                return false;
            } else {
                return true;
            }
        }
        
        if (currentStep == 1) {
            if (data.descriptionData && data.descriptionData.tagline &&
                                           data.descriptionData.language &&
                                           data.descriptionData.description) {
                return true;
            } else {
                return false;
            }
        }
        
        if (currentStep == 2) {
            if (!data.industriesSelected.length || !data.applicationsSelected.length || !data.regionsSelected.length) {
                return false;
            } else {
                return true;
            }
        }
        
        //Added by Nikhil
        if (currentStep == 3) {
            var resValid = true;
            data.resources.forEach(function(res, i){
                    if (!res.title || !res.type || !res.url || !res.url.match(component.get('v.urlMatchingPattern'))) {
                        console.log('Inside res');
                        resValid = false;
                    }
                });
            return resValid;
        }
        
        if(currentStep == 5 && component.get('v.isIntelAdmin')){
           
            return true;
        }
        
        return true;
    },
    
    isStepValid : function(component, helper, checkStep) {
        var step = typeof checkStep !== "undefined" ? checkStep : component.get('v.currentStep');
        var data = helper.generateFormData(component, helper);
        console.log('isStepValid : ', JSON.stringify(data));
        
        switch (step) {
                // logo
            case 0:
                return !component.get('v.hasLogo') ? false : true;
                // description fields
            case 1:
                return (!data.descriptionData.tagline || !data.descriptionData.language || 
                        !data.descriptionData.description ) ? false : true;
                // regions
            case 2:
                return (!data.industriesSelected.length || !data.applicationsSelected.length || !data.regionsSelected.length) ? false : true;
                // resources
            case 3:
                return !data.resources.length || data.resources.find(function(res) {
                    return (!res.title || !res.type || !res.url || !res.url.match(component.get('v.urlMatchingPattern')));
                }) ? false : true;
            default:
                return true; // maybe on summary step
        }
    },
    
    resetRegionValues : function(component, helper) {
        console.log('resetRegionValues')
        var allSelected = true, anyRegions = false;
        var options = component.get('v.regionOptions');
        options.forEach(function(opt) {
            var checkOption = false;
            opt.children.forEach(function(child) {
                if (child.selected) {
                    anyRegions = true;
                    checkOption = true; //added by nikhil to check if any sub region is selected
                }else{
                    allSelected = false;
                }
            });
            opt.checked = checkOption;
            if (!opt.checked) allSelected = false;
        });
        console.log('reseted regions',options)
        component.set('v.regionOptions', options);
        component.set('v.regionsSelectedAll', allSelected);
        component.set('v.regionError', !anyRegions);
        component.set('v.nextButtonDisabled', !helper.isCurrentStepValid(component, helper));
    },
    
    formatSummaryData: function(component, helper) {
        
        var data = helper.generateFormData(component, helper),
            summaryData = component.get('v.summaryData');
        console.log('Summary structure : ', summaryData);
        
        summaryData.logo.isValid = helper.isStepValid(component, helper, 0);
        
        // Description
        let currentLangOption = component.get('v.descriptionData.languageOptions').find(function(opt) {
            return opt.value == component.get('v.descriptionData.language');
        });
        let languageDisplay = currentLangOption ? currentLangOption.label : '';
        
        summaryData.description.language = languageDisplay;
        summaryData.description.tagline = data.descriptionData.tagline;
        summaryData.description.description = data.descriptionData.description;
        summaryData.description.isValid = helper.isStepValid(component, helper, 1);
        
        //Company detail
        //
        
        var industryOptions = component.get('v.industryOptions');       
        var selectedIndustries = [];
        industryOptions.forEach(function(ind){        
            if(data.industriesSelected.includes(ind.value))
            { 	var selectedChildren = [];
             ind.children.forEach(function(child){
                 if(child.selected == true){                    
                     selectedChildren.push(child);
                 }                
             });             
             ind.children = selectedChildren; 
             selectedIndustries.push(ind);                
            }            
        });
        summaryData.companyDetail.industries = selectedIndustries;
        
        var applicationOptions = component.get('v.applicationOptions');
        
        var selectedApplications = [];
        applicationOptions.forEach(function(app){        
            if(data.applicationsSelected.includes(app.value))
            {	var selectedChildren = [];
             app.children.forEach(function(child){
                 if(child.selected == true){                    
                     selectedChildren.push(child);
                 }                
             });             
             app.children = selectedChildren;
             selectedApplications.push(app);                
            }            
        });
        summaryData.companyDetail.applications = selectedApplications;
        
        var regionOptions = component.get('v.regionOptions');
        
        var selectedRegions = [];
        regionOptions.forEach(function(reg){        
            if(data.regionsSelected.includes(reg.value))
            {	var arr = [];
             reg.children.forEach(function(child){
                 if(child.selected == true){                    
                     arr.push(child);
                 }                
             });             
             reg.children = arr;     
             selectedRegions.push(reg);
            }           
        });
        summaryData.companyDetail.regions = selectedRegions;
        
        summaryData.companyDetail.isValid = helper.isStepValid(component, helper, 2);
        
        // Resources
        summaryData.resources.all = component.get('v.resources').map(function(resource) {
            let resourcetype = component.get('v.resourceTypeOptions').find(function(opt) {
                return opt.value == resource.type;
            });
            resourcetype = resourcetype ? resourcetype.label : 'Unknown Type';
            return { title: resource.title, type: resourcetype, url: resource.url };
        });
        summaryData.resources.isValid = helper.isStepValid(component, helper, 3);
        component.set('v.summaryData', summaryData);
        //console.log('Summary : ' , summaryData);
        console.log('Summary', JSON.parse(JSON.stringify(summaryData)));
        /*Added for logo issue*/
       
    },
    
    resetHeading: function (component, helper) {
        
                                
        var firstSubmission = component.get('v.isFirstDraft');
        
        var isWorkingDraft = (component.get('v.currentStatus') == 'Draft' || component.get('v.currentStatus') == null) ? true : false ;
        
        console.log('firstSubmission',firstSubmission);
        var isLocked =  component.get('v.isLocked');
        console.log('isLocked',isLocked);
        var isAdmin = component.get('v.isAdmin');
        var currentHeading = '';
        var labels = {
            add: $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Add"),
            edit: $A.get("$Label.c.PMP_Edit_Storefront_Heading"),
            locked: $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Locked"),
            review: $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Review"),
            status: $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Status"),
            submitted: $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Submitted"),
            isAdminStep1: $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Step1Profile"),
            isAdminStep2: $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Step2Profile")
        }
        console.log('Step in switch  ', component.get('v.currentStep'));
          /*var fetchData = component.get("c.getPartnerExistingData");
                          var userLangCode = $A.get("$Locale.langLocale");
                        fetchData.setParams({
                            'partnerId':component.get('v.partnerId'),
                            'langCode': userLangCode
                        });
                        fetchData.setCallback(this, function(response) {
                            var status = response.getState();
                            
       
                        if (status === "SUCCESS") {
                                var returnValue = response.getReturnValue();
                                console.log('ReturnValue :', returnValue);
                                component.set('v.currentStatus',returnValue.currentStatus);
                           if(returnValue.currentStatus=='Draft')
                           {
                           
                                currentHeading = labels.add;
                           }
                            }
                        });
          $A.enqueueAction(fetchData);*/
        
        if(component.get('v.currentStep') == 4){
            currentHeading = labels.review;
        }
        
        else{
            if(firstSubmission){
                currentHeading = labels.add;
               
            }else{
                currentHeading = labels.edit;
                
            }
        }
        
        if (isLocked) currentHeading = labels.locked;
        console.log('firstSubmission:::', firstSubmission, ':::', component.get('v.showModal')); 
        if(isWorkingDraft && !component.get('v.showModal')){
            //component.set('v.currentStep',0)
            //component.set('v.activeStep', 0);
            //component.set("v.currentStep", currentStep + 1);
            // component.set("v.formTouched", true);
               currentHeading = labels.isAdminStep1;
            
           // currentHeading = labels.add;
                component.set('v.isProfileAdmin', true);
                console.log('Heading inside if : ', currentHeading)
                
            
        } 
        if(component.get('v.currentStep') == 6 && !component.get('v.isIntelAdmin')){
            currentHeading = labels.isAdminStep2;
        }
        
        if(component.get('v.isFromLink')) {	
            currentHeading = $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Review");	
        }
        component.set('v.modalHeading', currentHeading);
        console.log('Heading::: ', currentHeading)
    },
    
    resetSubHeading : function(component, helper) {
        var currentHeading = component.get("v.steps")[component.get("v.currentStep")] || {};
        //component.set("v.currentStepHeading", currentHeading.label || 'Missing Label');
        component.set("v.currentStepHeading", (currentHeading.label ? currentHeading.label : currentHeading) || 'Missing Label');
    },
    
    highlightInvalidFields : function(component, helper) {
        var data = helper.generateFormData(component, helper);
        var currentStep = component.get('v.currentStep');
        if (currentStep == 0) { 
            component.find("uploader1").reportValidity();
        }
        if (currentStep == 1) {
            component.find("dropdown").find("dropdown").showHelpMessageIfInvalid();
            component.find("textInput").find("input").reportValidity();
            component.find("rtInput").reportValidity();
            //component.find("industryDropdown").set('v.touched', true);
        }
        if (currentStep == 2) {
            //component.find("industryDropdown").set('v.touched', true);
            //component.find("applicationDropdown").set('v.touched', true);  
             if (!data.industriesSelected.length) {
               component.set('v.industryError', true);
            }
            if (!data.applicationsSelected.length) {
               component.set('v.applicationError', true);
            }
            if (!data.regionsSelected.length) {
                component.set('v.regionError', true);
            }        
            
            
            
        }
        if (currentStep == 3) {
            var resInputs = [].concat(component.find("resource") || []);
            resInputs.map(function(inp) {
                if (inp.reportValidity) inp.reportValidity();
                if (inp.showHelpMessageIfInvalid) inp.showHelpMessageIfInvalid();
            });
            if (!resInputs.length) {
                component.set('v.resourcesError', true);
            }
        }
    },
    
    resetErrorsForCurrentStep: function(component, helper, step) {
        var currentStep = step;
        var errorInputs = [], data = helper.generateFormData(component, helper);
        console.log('data in errors : ', data);
        if (currentStep == 0) {
            if (!component.get('v.hasLogo')) {
                errorInputs.push({
                    name: 'logoScollId',//component.find('uploader1').get('v.name'),
                    label: $A.get("$Label.c.PMP_Edit_Offering_Form_Storefront_Logo")
                });
            }
        }
        
        if (currentStep == 1) {
            if (!data.descriptionData.language) {
                errorInputs.push({
                    name: 'langScrollId',//component.find('dropdown').get('v.name'),
                    label: $A.get("$Label.c.PMP_Edit_Storefront_Description_Lang_Label")
                });
            }
            if (!data.descriptionData.tagline) {
                errorInputs.push({
                    name: 'tagScrollId',//component.find('textInput').get('v.name'),
                    label: $A.get("$Label.c.PMP_Edit_Storefront_Description_Tagline_Label")
                });
            }
            if (!data.descriptionData.description) {
                errorInputs.push({
                    name: 'descScrollId',//component.find('rtInput').get('v.name'),
                    label: $A.get("$Label.c.PMP_Edit_Storefront_Description_Des_Label")
                });
            } 			
        }
        
        if (currentStep == 2) {
            if (!data.industriesSelected.length) {
                errorInputs.push({
                    name: 'indScrollId',//component.find('industryDropdown').get('v.name'),
                    label: $A.get("$Label.c.PMP_Industry")
                });
            }
            if (!data.applicationsSelected.length) {
                errorInputs.push({
                    name: 'appScrollId',//component.find('applicationDropdown').get('v.name'),
                    label: $A.get("$Label.c.PMP_application")
                });
            }
            if (!data.regionsSelected.length) {
                errorInputs.push({
                    name: 'regScrollId',//component.find('selectAllRegionCheckbox').get('v.name'),
                    label: $A.get("$Label.c.PMP_Edit_Storefront_Geo_Top")
                });
            }
        }
        
        if (currentStep == 3) {
            if (!data.resources.length) {
                errorInputs.push({
                    name: 'resScrollId',
                    label: $A.get("$Label.c.PMP_Company_Resources")
                });
            } else {
                data.resources.forEach(function(res, i){
                    if (!res.title || !res.type || !res.url || !res.url.match(component.get('v.urlMatchingPattern'))) {
                        errorInputs.push({
                            name: 'resource' + i,
                            label: 'Resource ' + (i + 1)
                        });
                    }
                });
            }
        }
        
        component.set('v.errorInputs', errorInputs);
        component.set('v.showErrors', errorInputs.length > 0);
        console.log('Errors : ', errorInputs);
    },
    
})