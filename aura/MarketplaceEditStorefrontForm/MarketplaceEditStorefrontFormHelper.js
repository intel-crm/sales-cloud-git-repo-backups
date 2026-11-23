/**
 * @description       : 
 * @author            : Balaji M
 * @group             : 
 * @last modified on  : 08-24-2020
 * @last modified by  : Balaji M
 * Modifications Log 
 * Ver   Date         Author     Modification
 * 1.0   08-24-2020   Balaji M   Initial Version
**/
({
    
    handleFormOpen : function(component, helper) {
        
        if (!component.get('v.isOpen')) { return
        };
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
        const userLangCode = $A.get("$Locale.langLocale");
        return new Promise($A.getCallback(function(resolve, reject) {
            //check Locked status
            const action = component.get("c.isLocked");
            action.setParams({
                partnerId: component.get('v.partnerId')
                
            });
            
            action.setCallback(this, function(response) {
                const status = response.getState();
                if (status === "SUCCESS") {
                    const isLocked = component.get('v.isFromLink') ? false : response.getReturnValue();
                    component.set('v.isLocked',isLocked);
                   
                    if(isLocked){
                        resolve();
                    }
                    if(!isLocked){
                        
                        const fetchData = component.get("c.getPartnerExistingData");
                        
                        fetchData.setParams({
                            'partnerId':component.get('v.partnerId'),
                            'langCode': userLangCode
                        });
                        fetchData.setCallback(this, function(response) {
                            const status = response.getState();
                            if (status === "SUCCESS") {
                                const returnValue = response.getReturnValue();
                                
                                component.set('v.currentStatus',returnValue.currentStatus);
                                if(returnValue.currentStatus == 'Draft' || returnValue.currentStatus == null) {
                                	component.set('v.isFirstDraft', true);
                                }
                                //Step-1 LOGO
                                component.set('v.workingCopyId', returnValue.workingCopyId);
                                console.log('check data return val: '+returnValue.logoCheck);
                                component.set('v.logoCheck', returnValue.logoCheck);
                                //Added by Subash for US682883
                                //component.set('v.partner', returnValue.partner);
                                const webaddwrap = returnValue.webaddwrap;
                                 let partner = {};
                                if(webaddwrap && Object.keys(webaddwrap).length > 0) {
                                    //Auto population of address for draft changes
                                    
                                   /* Object.keys(returnValue.webaddwrap).forEach(function(key) {
                                        partner = returnValue.webaddwrap[key];
                                    });*/
                                     
                                  let key= Object.keys(returnValue.webaddwrap)[0];
                                        partner = returnValue.webaddwrap[key];
                                }
                                if(returnValue.partner && Object.keys(webaddwrap).length > 0) {
                                	webaddwrap[returnValue.partner.name] = returnValue.partner;
                                }
                             

                                component.set('v.partwrap', webaddwrap);
                                 //if(component.get('v.isIntelAdmin')){ // for handling the partners having with and without websites 
                                let selectedpart ={};
                                if(!component.get('v.isFirstDraft')){ // for handling the partners having with and without websites                                 
                                component.set('v.partner',returnValue.partner);
                                selectedpart = returnValue.partner;
                                component.set('v.pnameFreeText', returnValue.partner.name);
                                component.set('v.pnameDropdown', returnValue.partner.name);
                                }
                                else{
                                component.set('v.partner', partner);
                                selectedpart = partner;
                                component.set('v.pnameFreeText', partner.name);
                                component.set('v.pnameDropdown', partner.name);  
                                }
                                let partnerNames = [];
                                if(returnValue.partnerNames && returnValue.partnerNames.length > 0) {
                                    partnerNames = returnValue.partnerNames;
                                } else if(returnValue.partner && returnValue.partner.name && !component.get('v.isFirstDraft')) {
                                    partnerNames = [{label: returnValue.partner.name, value: returnValue.partner.name}];
                                } 
                                if(selectedpart && selectedpart.name) {
                                    let flag = false;
                                    partnerNames.forEach(function(opt) {
                                        if(!flag && opt.value == selectedpart.name) {
                                            opt.selected = true;
                                            //partner.name = opt.value;
                                            flag = true;
                                        }
                                    });
                                    
                                    if(!flag && !component.get('v.isFirstDraft')) {
                                        partnerNames.push({label: selectedpart.name, value: selectedpart.name, selected: true});
                                    	//partner.name = returnValue.partner.name;
                                    }
                                }
                               
                                component.set('v.partnerNames', partnerNames);
                               //IPA 2.0 TWC729-7887
                             //   component.set('v.isEnhanced',returnValue.isEnhanced);                          
                                helper.getCountryStateOptions(component, helper);
                                //End for US682883
                                //start of address website changes
                                //Create an empty array to store the map keys 
                                //Store the response of apex controller (return map)     
                                //Set the store response[map] to component attribute, which name is map and type is map.   
                                component.set('v.partwrapMap', returnValue.webaddwrap);
                                if(component.get('v.isFromLink')) {       	
                                    helper.getLogoURL(component, helper);       	
                                }
                                
                                //STEP-2 DESCRIPTION
                                component.set('v.descriptionData', returnValue.descriptionData);
                                
                                //STEP-3 COMPANY DETAILS
                                //INDUSTRY
                                const indOptions = returnValue.industryOptions;
                                const indsSelected = returnValue.industriesSelected;
                                if(indOptions) {
                                    indOptions.forEach(function(opt) {
                                        opt.checked = indsSelected.includes(opt.value);
                                        
                                        opt.children.forEach(function(child){
                                            child.selected = indsSelected.includes(child.value);
                                        });
                                        
                                    });
                                    component.set('v.industryOptions',indOptions);
                                }
                                
                                //APPLICATION 
                                const appOptions = returnValue.applicationOptions;
                                const appsSelected = returnValue.applicationsSelected;
                                if(appOptions) {
                                    appOptions.forEach(function(opt) {
                                        
                                        opt.checked = appsSelected.includes(opt.value);
                                        
                                        opt.children.forEach(function(child){
                                            child.selected = appsSelected.includes(child.value);
                                        });
                                        
                                    });
                                    component.set('v.applicationOptions',appOptions);
                                }
                                component.set('v.isDistributor', returnValue.isDistributor); //Added by Subash for US697109
                                //GEOGRAPHIC COVERAGE
                                const regionOptions = returnValue.regionOptions;
                                const regionsSelected = returnValue.regionsSelected;
                                if(regionOptions) {
                                    regionOptions.forEach(function(opt) {
                                        opt.checked = regionsSelected.includes(opt.value);
                                        
                                        opt.children.forEach(function(child){
                                            child.checked = regionsSelected.includes(child.value);
                                            //Start :added by krishna ch
                                           child.children.forEach(function(subchild){
                                               subchild.checked = regionsSelected.includes(subchild.value);
                                           });//End
                                            
                                        });
                                    });
                                    component.set('v.regionOptions', regionOptions);
                                }
                                //component.set('v.regionsSelected', regionsSelected);
                                
                                //STEP-4 RESOURCES
                                if(returnValue.resourceData) {
                                    component.set('v.resources', returnValue.resourceData.resources);
                                    component.set('v.resourceTypeOptions', returnValue.resourceData.resourceTypes);
                                }
                                
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
                                
                                
                                component.set('v.showSpinner', false);
                                //
                                resolve();
                                
                            } else if (status === "INCOMPLETE") {
                                reject();
                            } else if (status === "ERROR") {
                                const errors = response.getError();
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
                    reject();
                } else if (status === "ERROR") {
                    const errors = response.getError();
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
        	
        const url = component.get('c.getlogoUrl');       	
        	
        url.setParams({        	
            partnerId: component.get('v.workingCopyId')       	
            	
        });  	
         	
        url.setCallback(this, function(response) {      	
            const status = response.getState(); 	
                   	
            if (status === "SUCCESS") {              	
                const returnvalue = response.getReturnValue();   	
                component.set('v.hasLogo', true);          	
                component.set('v.logourl', returnvalue);             	
            } 	
            	
        });  	
        $A.enqueueAction(url);        	
    },
    
    handleProgressBarChange : function(component, helper, step) {
        if(step == 0) {
            setTimeout($A.getCallback(function(){
                component.find("switch").set("v.checked", component.get("v.showText"));
            }),500);
            helper.resetErrorsForCurrentStep(component, helper, component.get('v.currentStep'))
        }
        if (helper.isCurrentStepValid(component, helper)) {
           component.set('v.currentStep', step);  
        } else {
           helper.highlightInvalidFields(component, helper);
           helper.resetErrorsForCurrentStep(component, helper, component.get('v.currentStep')); 
        }
    },
    
    handleReSubmit : function(component, helper) {
        
        return new Promise($A.getCallback(function(resolve, reject) {
            const data = helper.generateFormData(component, helper);
            
            
            const action = component.get("c.saveEditFormData");
            action.setParams({
                'partnerId':component.get('v.partnerId'),
                'requestJSON': JSON.stringify(data)
            });
            const savingInProgressStorefrontToastEvent = $A.get("e.force:showToast");
            savingInProgressStorefrontToastEvent.setParams({
                            "title":   $A.get("$Label.c.PMP_Storefront_Edit_Wait_Title"),
                            "type": "info",
                            "mode":"dismissable",
                            "message":  $A.get("$Label.c.PMP_Storefront_Edit_Save_InProgress_Message")
                        });
            savingInProgressStorefrontToastEvent.fire();
            action.setCallback(this, function(response) {
                const status = response.getState();
                if (status === "SUCCESS") {
                    //IPA 2.0 TWC729-7887
                    if (data.status==='Approved' && component.get('v.isIntelAdmin') /*&& !component.get('v.isEnhanced')*/) { 
                        const EnhancedInProgressToastEvent = $A.get("e.force:showToast");
                        EnhancedInProgressToastEvent.setParams({
                            "title":  $A.get("$Label.c.PMP_Storefront_Edit_Wait_Title"),
                            "type": "Success",
                            "mode":"Sticy",
                            "message": $A.get("$Label.c.PMP_Storefront_Edit_Enhanced_InProgress_Message")
                        });
                        EnhancedInProgressToastEvent.fire();
                        resolve();
                        //IPA 2.0 TWC729-7887
                      /*  helper.assignEnhancedBenefit(component,helper).then($A.getCallback(function(){
                            resolve();
                        }));*/
                        }else{
                            const StorefrontSaveToastEvent = $A.get("e.force:showToast");
                            StorefrontSaveToastEvent.setParams({
                                "title":   $A.get("$Label.c.PMP_Storefront_Edit_Success_Title"),
                                "type": "success",
                                "mode":"sticky",
                                "message":  $A.get("$Label.c.PMP_Storefront_Edit_Save_Success_Message")
                            });
                            StorefrontSaveToastEvent.fire();
                            resolve();
                        }
                    
                } else if (status === "INCOMPLETE") {
                    const errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                            component.set('v.showSpinner', false); 
                            const SaveStoreFrontErrorToastEvent = $A.get("e.force:showToast");
                            SaveStoreFrontErrorToastEvent.setParams({
                                "title":  $A.get("$Label.c.PMP_Storefront_Edit_Error_Title"),
                                "type": "Error",
                                "mode":"sticky",
                                "message": errors[0].message
                            });
                            SaveStoreFrontErrorToastEvent.fire();
                        }
                    }
                   
                    reject();
                } else if (status === "ERROR") {
                    const errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                            component.set('v.showSpinner', false); 
                            const SaveStoreFrontErrorToastEvent = $A.get("e.force:showToast");
                            SaveStoreFrontErrorToastEvent.setParams({
                                "title":  $A.get("$Label.c.PMP_Storefront_Edit_Error_Title"),
                                "type": "Error",
                                "mode":"sticky",
                                "message": errors[0].message
                            });
                            SaveStoreFrontErrorToastEvent.fire();
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
//IPA 2.0 TWC729-7887
  /*  assignEnhancedBenefit:function(component,helper){
    
        return new Promise($A.getCallback(function(resolve, reject) {
        const data = helper.generateFormData(component, helper);            
            const action = component.get("c.AssignEnhancedBenefitToStorefront");
            action.setParams({
                'partnerId':component.get('v.partnerId'),
                'requestJSON': JSON.stringify(data)
            });
            action.setCallback(this, function(response) {
                const status = response.getState();
                if (status === "SUCCESS") {
                    const EnhancedSuccessToastEvent = $A.get("e.force:showToast");
                    EnhancedSuccessToastEvent.setParams({
                        "title":  $A.get("$Label.c.PMP_Storefront_Edit_Success_Title"),
                        "type": "success",
                        "mode":"sticky",
                        "message":  $A.get("$Label.c.PMP_Storefront_Edit_Enhanced_Success_Message")
                    });
                    EnhancedSuccessToastEvent.fire();
                    resolve();
                } else if (status === "INCOMPLETE") {
                    const errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                            component.set('v.showSpinner', false); 
                            const EnhancedErrorToastEvent = $A.get("e.force:showToast");
                            EnhancedErrorToastEvent.setParams({
                                "title":   $A.get("$Label.c.PMP_Storefront_Edit_Enhanced_Failed_Message"),
                                "type": "Error",
                                "mode":"sticky",
                                "message": errors[0].message
                            });
                            EnhancedErrorToastEvent.fire();
                        }
                    }
                   
                   resolve();
                } else if (status === "ERROR") {
                    const errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                            component.set('v.showSpinner', false); 
                            const EnhancedErrorToastEvent = $A.get("e.force:showToast");
                            EnhancedErrorToastEvent.setParams({
                                "title":  $A.get("$Label.c.PMP_Storefront_Edit_Enhanced_Failed_Message"),
                                "type": "Error",
                                "mode":"sticky",
                                "message": errors[0].message
                            });
                            EnhancedErrorToastEvent.fire();
                        };
                    }
                    resolve();
                } else {
                    resolve();
                    reject('Unknown error.');
                }
            });

            $A.enqueueAction(action)
        }));
    },*/
    
    handleUpdateStatusAdmin	: function(component, helper){
        
        return new Promise($A.getCallback(function(resolve, reject) {
            const data = helper.generateFormData(component, helper);
                       
            const action = component.get("c.updateStatusAdmin");
            action.setParams({
                'partnerId':component.get('v.partnerId'),
                'requestJSON': JSON.stringify(data)
            });
            action.setCallback(this, function(response) {
                
                const status = response.getState();
                
                if (status === "SUCCESS") {                    
                    resolve();
                } else if (status === "INCOMPLETE") {
                   
                    reject();
                } else if (status === "ERROR") {
                    const errors = response.getError();
                    
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
        
        const partner = component.get("v.partner");
        if(partner) {
            partner.name = component.get("v.showText") ? component.get("v.pnameFreeText") : component.get("v.pnameDropdown");
        }
       
        return {
            descriptionData: component.get('v.descriptionData'),
            partner: partner,
            regionsSelected: component.get('v.regionOptions').reduce(function(arr, opt) {
                /*if (opt.checked){                    
                    arr.push(opt.value);
                    arr = arr.concat(opt.selections);    
                }*/
                if (opt.checked) 
                {
                    arr.push(opt.value);
                
                opt.children.forEach(function(child) {
                    if (child.checked){
                        arr.push(child.value);
                    
                 child.children.forEach(function(subchild) {
                    if (subchild.checked){
                        arr.push(subchild.value);
                    } 
                    });
                }
                    
                })
               }
                return arr;
            }, []),
           
            
            //Added by Nikhil
            applicationsSelected: component.get('v.applicationOptions').reduce(function(arr, opt) {
                /* if (opt.checked){
                    arr.push(opt.value);
                    arr = arr.concat(opt.selections);     
                } */
                if (opt.checked) {
                    arr.push(opt.value);
                }
                
                opt.children.forEach(function(child) {
                    if (child.selected) {
                        arr.push(child.value);
                    }
                })
                return arr;
            }, []),
            //Added by Nikhil
            industriesSelected: component.get('v.industryOptions').reduce(function(arr, opt) {
                /*if (opt.checked){
                    arr.push(opt.value);
                    arr = arr.concat(opt.selections);   
                } */
                if (opt.checked) {
                    arr.push(opt.value);
                }
                
                opt.children.forEach(function(child) {
                    if (child.selected) {
                        arr.push(child.value);
                    }
                })                
                return arr;
            }, []),
            
            resources: component.get('v.resources'),
            
            //STEP-5 ADMIN REVIEW 
            status:component.get('v.currentStatus'),
            admin:component.get('v.loggedInAdmin'),
            suppressEmail: component.get('v.suppressEmail')
        };
    },

    isFormValid : function(component, helper) {
        const data = helper.generateFormData(component, helper), msgs = [];

        const currentStep = component.get('v.currentStep');
        let logoImage;

        //Modified by Ajay for form validation and tab content logic
        //if (currentStep == 0) {
            const logoCmp = component.find("uploader1");
            
            if(logoCmp) {
                logoImage = logoCmp.get('v.images');
                const logo = logoCmp.get('v.images') && logoCmp.get('v.images').length > 0;
                console.log('check data check : '+logoCmp.get('v.images').length > 0);
                console.log('check data logo : '+logo);
                component.set('v.logoCheck',logo);
            }
        //}

        if(logoImage) {
            if (logoImage[0] != undefined) {
                component.set('v.logourl', logoImage[0].url);
            }
        } else {
            component.set('v.hasLogo',false);
        }

        const logoCheck = component.get('v.logoCheck');
        if (!logoCheck) {
            msgs.push($A.get("$Label.c.PMP_Edit_Storefront_Logo_Error"));
        }
        console.log('check data logoCheck : '+logoCheck);

        if (!data.partner || !data.partner.name) {msgs.push($A.get("$Label.c.PMP_Edit_Storefront_Partner_Name_Error")); }//Added by Subash for US682883
       // website field Changes- Starts
       

        if(!data.partner || !data.partner.website) {
            
            msgs.push($A.get("$Label.c.PMP_Invalid_Website"));
            
           
        }
        component.set('v.formErrorMsgs', msgs);
        let websiteCheck = component.get("v.websiteReturnValue");
        let websiteValid = true;
            const websites = component.find("pwebsite") ? [].concat(component.find("pwebsite")) : []; 
            websites.forEach(function(input) {
                if(!input.checkValidity()) {websiteValid = false;}
            });
            component.set('v.websiteValidation',websiteValid);
        // website field Changes- Starts
        if (!helper.addressValidation(component)) {msgs.push($A.get("$Label.c.PMP_Invalid_Address"));}
        // step 2 
        if (data.descriptionData && !data.descriptionData.tagline) {msgs.push($A.get("$Label.c.PMP_Edit_Storefront_Tagline_Error"));}
        if (data.descriptionData && !data.descriptionData.language) {msgs.push($A.get("$Label.c.PMP_Edit_Storefront_Language_Error"));}
        if ((data.descriptionData && !data.descriptionData.description) ||(data.descriptionData && data.descriptionData.description && data.descriptionData.description.length>131072)) {
            msgs.push($A.get("$Label.c.PMP_Edit_Storefront_Description_Error"));
        }  //US954587 added OR Condition
        
        // step 3      
        const isDistributor = component.get('v.isDistributor'); //Added by Subash for US697109  
        if (!data.industriesSelected.length) {msgs.push($A.get("$Label.c.PMP_Edit_Storefront_Industry_Error")); }  //'You need to select at least one industry.'
        if (!data.applicationsSelected.length) {msgs.push($A.get("$Label.c.PMP_Edit_Storefront_Application_Error")); }  //'You need to select at least one application.'
        if (!isDistributor && !data.regionsSelected.length) {msgs.push($A.get("$Label.c.PMP_Edit_Storefront_Geo_Error"));}   //'You need to select at least one region.'
        
        // step 4
        if (!data.resources.length) {msgs.push($A.get("$Label.c.PMP_Edit_Storefront_Resource_Error"));}   //'You need at least one resource.'
        
        component.set('v.formErrorMsgs', msgs);
        
        const resources = component.find("resource") ? [].concat(component.find("resource")) : [];
        let resourcesValid = true;
        resources.forEach(function(input) {
            if(!input.checkValidity()) {resourcesValid = false;}
        });
        
        
                
        return ((resourcesValid  && msgs.length == 0) && websiteValid);
       
        return [0,1,2,3].find(function(step) {
            return !helper.isStepValid(component, helper, step);
        }) ? false : true;  
    },
    
    isCurrentStepValid : function(component, helper, step) {
        
        const currentStep = component.get('v.currentStep');
        const data = helper.generateFormData(component, helper);
        
        
        
        /*   if (step == 0) {
            
            if (!component.get('v.logoCheck')) {
                return component.find("formInput").reportValidity();
            }
        }*/
        
        if (currentStep == 0){
            const hasLogo = component.find("uploader1") && component.find("uploader1").get('v.images') && component.find("uploader1").get('v.images').length > 0;
            component.set('v.logoCheck',hasLogo);
            if (!hasLogo || !data || !data.partner || !data.partner.name ||!data.partner.website|| !helper.addressValidation(component) || !component.get('v.websiteValidation')) {// added !data.partner.website as part of website field Changes
                return false;
            } else {
                return true;
            }
        }
        
        if (currentStep == 1) {
            if (data.descriptionData && data.descriptionData.tagline &&
                                           data.descriptionData.language &&
                data.descriptionData.description && data.descriptionData.description.length<=131072) { //US954587:added data.descriptionData.description.length<131073
                return true;
            } else {
                return false;
            }
        }
        
        const isDistributor = component.get('v.isDistributor'); //Added by Subash for US697109	
        if (currentStep == 2) {
            if (!data.industriesSelected.length || !data.applicationsSelected.length || (!isDistributor && !data.regionsSelected.length)) {
                return false;
            } else {
                return true;
            }
        }
        
        //Added by Nikhil
        if (currentStep == 3) {
            let resValid = true;
            data.resources.forEach(function(res, i){
                    if (!res.title || !res.type || !res.url || !res.url.match(component.get('v.urlMatchingPattern'))) {
                       
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
        const step = typeof checkStep !== "undefined" ? checkStep : component.get('v.currentStep');
        const data = helper.generateFormData(component, helper);
        const isDistributor = component.get('v.isDistributor'); //Added by Subash for US697109	
        
        
        switch (step) {
                // logo
            case 0:
                return (!data || !data.partner || !data.partner.name || !data.partner.website || !component.get('v.hasLogo') || !helper.addressValidation(component) || !component.get('v.websiteValidation') ? false : true); //added !data.partner.website as part of website filed changes
                // description fields
            case 1:
                return (!data.descriptionData.tagline || !data.descriptionData.language || 
                        !data.descriptionData.description || data.descriptionData.description.length>131072) ? false : true;   //US954587:added data.descriptionData.description.length>131072
                // regions
            case 2:
                return (!data.industriesSelected.length || !data.applicationsSelected.length || (!isDistributor && !data.regionsSelected.length)) ? false : true;
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
        
        let allSelected = true, anyRegions = false;
        const options = component.get('v.regionOptions');
        options.forEach(function(opt) {
            let checkOption = false;
            //added by krishna ch as part of TWC1824-1619 : QA: MP: during edit storefront user not able to see the selected region
            if(opt.checked){
                checkOption = true;
                anyRegions = true;
            }
            opt.children.forEach(function(child) {
                if (child.checked) {
                    anyRegions = true;
                    checkOption = true; //added by nikhil to check if any sub region is selected
                }else{
                    allSelected = false;
                    
                }
            });
            opt.checked = checkOption;
            if (!opt.checked) {allSelected = false;}
        });
        
        component.set('v.regionOptions', options);
        component.set('v.regionsSelectedAll', allSelected);
        component.set('v.regionError', !anyRegions);
        component.set('v.nextButtonDisabled', !helper.isCurrentStepValid(component, helper));
    },
    
    formatSummaryData: function(component, helper) {
        
        const data = helper.generateFormData(component, helper);
        const summaryData = component.get('v.summaryData');
       
        
        summaryData.logo.isValid = helper.isStepValid(component, helper, 0);
        //summaryData.partnerName.isValid = helper.isStepValid(component, helper, 0);
        
        // Description
        const currentLangOption = component.get('v.descriptionData.languageOptions').find(function(opt) {
            return opt.value == component.get('v.descriptionData.language');
        });
        const languageDisplay = currentLangOption ? currentLangOption.label : '';
        
        summaryData.description.language = languageDisplay;
        summaryData.description.tagline = data.descriptionData.tagline;
        summaryData.description.description = data.descriptionData.description;
        summaryData.description.isValid = helper.isStepValid(component, helper, 1);
        
        //Company detail
        //
        
        const industryOptions = component.get('v.industryOptions');       
        const selectedIndustries = [];
        industryOptions.forEach(function(ind){        
            if(data.industriesSelected.includes(ind.value))
            { 	const selectedChildren = [];
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
        
        const applicationOptions = component.get('v.applicationOptions');
        
        const selectedApplications = [];
        applicationOptions.forEach(function(app){        
            if(data.applicationsSelected.includes(app.value))
            {	const selectedChildren = [];
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
        
        const regionOptions = component.get('v.regionOptions');
        const tempRegions = regionOptions;
        const selectedRegions = [];
        regionOptions.forEach(function(reg){
            
            if(data.regionsSelected.includes(reg.value))
           {
               reg.children.forEach(function(child){
                 if(child.checked == true){                    
                     selectedRegions.push(child.value);
              child.children.forEach(function(subchild){
                  if(subchild.checked == true){                    
                     selectedRegions.push(subchild.value);
                  }
                  
              });
                 }
             }); 
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
       
        /*Added for logo issue*/
       
    },
    
    resetHeading: function (component, helper) {
        
                                
        const firstSubmission = component.get('v.isFirstDraft');
        
        const isWorkingDraft = (component.get('v.currentStatus') == 'Draft' || component.get('v.currentStatus') == null) ? true : false ;
        
        
        const isLocked =  component.get('v.isLocked');
       
        const isAdmin = component.get('v.isAdmin');
        let currentHeading = '';
        const labels = {
            add: $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Add"),
            edit: $A.get("$Label.c.PMP_Edit_Storefront_Heading"),
            locked: $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Locked"),
            review: $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Review"),
            status: $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Status"),
            submitted: $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Submitted"),
            isAdminStep1: $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Step1Profile"),
            isAdminStep2: $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Step2Profile")
        }
        
          /*let fetchData = component.get("c.getPartnerExistingData");
                          let userLangCode = $A.get("$Locale.langLocale");
                        fetchData.setParams({
                            'partnerId':component.get('v.partnerId'),
                            'langCode': userLangCode
                        });
                        fetchData.setCallback(this, function(response) {
                            let status = response.getState();
                            
       
                        if (status === "SUCCESS") {
                                let returnValue = response.getReturnValue();
                                
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
        
        if (isLocked) {currentHeading = labels.locked;}
         
        if(isWorkingDraft && !component.get('v.showModal')){
            //component.set('v.currentStep',0)
            //component.set('v.activeStep', 0);
            //component.set("v.currentStep", currentStep + 1);
            // component.set("v.formTouched", true);
               currentHeading = labels.isAdminStep1;
            
           // currentHeading = labels.add;
                component.set('v.isProfileAdmin', true);
                
                
            
        } 
        if(component.get('v.currentStep') == 6 && !component.get('v.isIntelAdmin')){
            currentHeading = labels.isAdminStep2;
        }
        
        if(component.get('v.isFromLink')) {	
            currentHeading = $A.get("$Label.c.PMP_Edit_Storefront_Modal_Heading_Review");	
        }
        component.set('v.modalHeading', currentHeading);
        
    },
    
    resetSubHeading : function(component, helper) {
        const currentHeading = component.get("v.steps")[component.get("v.currentStep")] || {};
        //component.set("v.currentStepHeading", currentHeading.label || 'Missing Label');
        component.set("v.currentStepHeading", (currentHeading.label ? currentHeading.label : currentHeading) || 'Missing Label');
    },
    
    highlightInvalidFields : function(component, helper) {
        const data = helper.generateFormData(component, helper);
        const currentStep = component.get('v.currentStep');
        if (currentStep == 0) { 
            if(component.get("v.showText")) {
                component.find("pnameTxt").reportValidity();
            } else {
                if(component.find("pname")) {
                    //component.find("pname").showHelpMessageIfInvalid();
                }
            }
            component.set("v.isInvalidAddress", !helper.addressValidation(component));
            component.find("uploader1").reportValidity();
            component.find("pwebsite").reportValidity();
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
            const resInputs = [].concat(component.find("resource") || []);
            resInputs.map(function(inp) {
                if (inp.reportValidity) {inp.reportValidity();}
                if (inp.showHelpMessageIfInvalid) {inp.showHelpMessageIfInvalid();}
                return inp;
            });
            if (!resInputs.length) {
                component.set('v.resourcesError', true);
            }
           
        }
    },
    
    resetErrorsForCurrentStep: function(component, helper, step) {
        const currentStep = step;
        const errorInputs = [], data = helper.generateFormData(component, helper);
        
        if (currentStep == 0) {
            if (!component.get('v.hasLogo')) {
                errorInputs.push({
                    name: 'logoScollId',//component.find('uploader1').get('v.name'),
                    label: $A.get("$Label.c.PMP_Edit_Offering_Form_Storefront_Logo")
                });
            }
            if (!helper.addressValidation(component)) {
                errorInputs.push({
                    name: 'addressScollId',//component.find('uploader1').get('v.name'),
                    label: $A.get("$Label.c.PMP_Address")
                });
            }
            // website field Changes- Starts
           if (!data.partner.website) {
                 errorInputs.push({
                    name: 'webScrollId',//component.find('dropdown').get('v.name'),
                    label: $A.get("$Label.c.PMP_Website")
                });
            }
            // website field Changes- Ends
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
                    label: $A.get("$Label.c.PMP_Edit_Storefront_Company_Resources")
                });
            } else {
                data.resources.forEach(function(res, i){
                    if (!res.title || !res.type || !res.url || !res.url.match(component.get('v.urlMatchingPattern'))) {
                       const resourceString = $A.get("$Label.c.PMP_Edit_Storefront_Resources_Res");
                        errorInputs.push({
                            name: 'resource' + i,
                            label: resourceString + (i + 1)
                        });
                    }
                });
            }
        }
        
        component.set('v.errorInputs', errorInputs);
        component.set('v.showErrors', errorInputs.length > 0);
        
    },
    
    //Added by Subash for US686667
    getCountryStateOptions : function(component, helper){
        const action = component.get("c.getDependentMap");
        action.setCallback(this, function(response) {
            
            if(response.getState() === "SUCCESS") {
                component.set("v.countries", response.getReturnValue());
                helper.fetchCountryAndState(component);

            }
        });
        $A.enqueueAction(action);  
    },
    
    fetchCountryAndState: function(component) {
    	
        const country = component.get("v.countries");
        const partner = component.get("v.partner");
        let states = [];
        
        if(country && country.length > 0) {
            country.forEach(function(cnt, i) {
                if(cnt.label == partner.country) {
                    if(cnt.children && cnt.children.length > 0) {
                        states = cnt.children;
                    }
                }
            });
        }
        component.set("v.isStateDisabled", states.length == 0);
        component.set("v.states", states)
    },
    
    addressValidation: function(component) {
    	
        const partner = component.get("v.partner");
        
        if(partner && partner.primaryStreet && partner.country && 
           (partner.state || component.get("v.states").length == 0) && partner.city && partner.postalCode) {
            return true;
        } else if((!partner.primaryStreet || partner.primaryStreet == '') && (!partner.country || partner.country == '') &&
                 (!partner.city || partner.city == '') && (!partner.postalCode || partner.postalCode == '')) {
            if(partner.secondaryStreet) {
                return false;
            } else {
                return true;
            }
        } else {
            return false;
        }        
    },
    
    companyInformationValidation: function(component, event, helper) {
       
        event.getSource().reportValidity();
        component.set("v.summaryData.logo.isUpdated", true);
        component.set("v.summaryData.isUpdated", true);
        component.set("v.isInvalidAddress", false);
        component.set("v.formValid", helper.isFormValid(component, helper));
        helper.highlightInvalidFields(component, helper);
    }, 
    //End of US686667

    //Added by Ajay for form validation and tab content logic
    handleTabContentVisibility : function(component, helper, currentStep){
        
        const tab0 = component.find("step-0");
        const tab1 = component.find("step-1");
        const tab2 = component.find("step-2");
        const tab3 = component.find("step-3");
        const tab4 = component.find("step-4");
        const tab5 = component.find("step-5");

        if(currentStep === 0) {

            $A.util.addClass(tab0, 'slds-show');
            $A.util.addClass(tab1, 'slds-hide');
            $A.util.addClass(tab2, 'slds-hide');
            $A.util.addClass(tab3, 'slds-hide');
            $A.util.addClass(tab4, 'slds-hide');
            $A.util.addClass(tab5, 'slds-hide');

            $A.util.removeClass(tab0, 'slds-hide');
            $A.util.removeClass(tab1, 'slds-show');
            $A.util.removeClass(tab2, 'slds-show');
            $A.util.removeClass(tab3, 'slds-show');
            $A.util.removeClass(tab4, 'slds-show');
            $A.util.removeClass(tab5, 'slds-show');
        
        } else if(currentStep === 1) {

            $A.util.addClass(tab0, 'slds-hide');
            $A.util.addClass(tab1, 'slds-show');
            $A.util.addClass(tab2, 'slds-hide');
            $A.util.addClass(tab3, 'slds-hide');
            $A.util.addClass(tab4, 'slds-hide');
            $A.util.addClass(tab5, 'slds-hide');

            $A.util.removeClass(tab0, 'slds-show');
            $A.util.removeClass(tab1, 'slds-hide');
            $A.util.removeClass(tab2, 'slds-show');
            $A.util.removeClass(tab3, 'slds-show');
            $A.util.removeClass(tab4, 'slds-show');
            $A.util.removeClass(tab5, 'slds-show');

        } else if(currentStep === 2) {

            $A.util.addClass(tab0, 'slds-hide');
            $A.util.addClass(tab1, 'slds-hide');
            $A.util.addClass(tab2, 'slds-show');
            $A.util.addClass(tab3, 'slds-hide');
            $A.util.addClass(tab4, 'slds-hide');
            $A.util.addClass(tab5, 'slds-hide');

            $A.util.removeClass(tab0, 'slds-show');
            $A.util.removeClass(tab1, 'slds-show');
            $A.util.removeClass(tab2, 'slds-hide');
            $A.util.removeClass(tab3, 'slds-show');
            $A.util.removeClass(tab4, 'slds-show');
            $A.util.removeClass(tab5, 'slds-show');
            
        } else if(currentStep === 3) {

            $A.util.addClass(tab0, 'slds-hide');
            $A.util.addClass(tab1, 'slds-hide');
            $A.util.addClass(tab2, 'slds-hide');
            $A.util.addClass(tab3, 'slds-show');
            $A.util.addClass(tab4, 'slds-hide');
            $A.util.addClass(tab5, 'slds-hide');

            $A.util.removeClass(tab0, 'slds-show');
            $A.util.removeClass(tab1, 'slds-show');
            $A.util.removeClass(tab2, 'slds-show');
            $A.util.removeClass(tab3, 'slds-hide');
            $A.util.removeClass(tab4, 'slds-show');
            $A.util.removeClass(tab5, 'slds-show');
            
        } else if(currentStep === 4) {

            $A.util.addClass(tab0, 'slds-hide');
            $A.util.addClass(tab1, 'slds-hide');
            $A.util.addClass(tab2, 'slds-hide');
            $A.util.addClass(tab3, 'slds-hide');
            $A.util.addClass(tab4, 'slds-show');
            $A.util.addClass(tab5, 'slds-hide');

            $A.util.removeClass(tab0, 'slds-show');
            $A.util.removeClass(tab1, 'slds-show');
            $A.util.removeClass(tab2, 'slds-show');
            $A.util.removeClass(tab3, 'slds-show');
            $A.util.removeClass(tab4, 'slds-hide');
            $A.util.removeClass(tab5, 'slds-show');
            
        } else if(currentStep === 5) {

            $A.util.addClass(tab0, 'slds-hide');
            $A.util.addClass(tab1, 'slds-hide');
            $A.util.addClass(tab2, 'slds-hide');
            $A.util.addClass(tab3, 'slds-hide');
            $A.util.addClass(tab4, 'slds-hide');
            $A.util.addClass(tab5, 'slds-show');

            $A.util.removeClass(tab0, 'slds-show');
            $A.util.removeClass(tab1, 'slds-show');
            $A.util.removeClass(tab2, 'slds-show');
            $A.util.removeClass(tab3, 'slds-show');
            $A.util.removeClass(tab4, 'slds-show');
            $A.util.removeClass(tab5, 'slds-hide');
            
        }

    },
})