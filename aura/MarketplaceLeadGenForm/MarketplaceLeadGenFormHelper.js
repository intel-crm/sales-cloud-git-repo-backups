({
	generateFormData : function(component, helper) {
		return {
			logo: component.get('v.logo'), // prob not needed
			additionalLogos: component.get('v.additionalLogos'), // prob not needed
			descriptionData: component.get('v.descriptionData'),
			regionsSelected: component.get('v.regionOptions').reduce(function(arr, opt) {
				if (opt.checked) arr.push(opt.value);
				arr.concat(opt.selections);
				return arr;
			}, []),
			resources: component.get('v.resources')
		};
	},

    isFormValid : function(component, helper) {
        
        let isFNameValid = helper.isNameValid(component, 'fname');
        let isLNameValid = helper.isNameValid(component, 'lname');
        let iscompanyValid = helper.isNameValid(component, 'cmpnyName');
        let formType = component.get('v.formType');
        let isNoteorDesc = helper.isLeadnotesValid(component, (formType == 'contact' ? 'leadnotce' : 'leadgendesc'));
        let cusValid = isFNameValid && isLNameValid && iscompanyValid && isNoteorDesc;
        
        var allValid = component.find('inputField').reduce(function (validSoFar, inputCmp) {
            if (inputCmp.reportValidity) {
                inputCmp.reportValidity();
            } else if(inputCmp.showHelpMessageIfInvalid) {
                inputCmp.showHelpMessageIfInvalid();
            } else {
                console.log('It doesnt exist for both reportValidity');
            }
            return validSoFar && !inputCmp.get('v.validity').valueMissing && cusValid;
        }, true);
        
        component.find('leadPhone').showHelpMessageIfInvalid();
        component.find('leadEmail').showHelpMessageIfInvalid();
        
        // Checkbox manual validity check
        var termsChecked = component.find('inputTermsAndCondition').getElement().checked;
        component.set('v.agreeCheckboxError', !termsChecked);
        
        
        return allValid && termsChecked;
    },
    
    isNameValid: function(component, auraId) {
        
        if(auraId) {
            var com = component.find(auraId);
            var val = com.get('v.value');
            var reghtmlformat = /<.*?>/;  
            com.setCustomValidity("");
            
            if(val) {
                
                
                
                if(val.match(reghtmlformat)) {
                    com.setCustomValidity($A.get("$Label.c.PMP_Invalid_Notes_URL"));
                    com.reportValidity();
                    return false;
                }
                else if(val.includes(".") || val.includes("/")) {
                    com.setCustomValidity($A.get("$Label.c.PMP_Invalid_Notes_URL"));
                    com.reportValidity();
                    return false;
                } else {
                    com.reportValidity();
                    return true;
                }
            } else {
                com.setCustomValidity($A.get("$Label.c.PMP_LeadGen_CompleteThisField"));                
                com.reportValidity();
                return false;
            }
        }
    },
    isLeadnotesValid: function(component, auraId) {
        console.log(':::isLeadnotesValid fn called:::', auraId);
        if(auraId) {
            var com = component.find(auraId);
            var val = com.get('v.value');
            var reghtmlformat = /<.*?>/; 
            com.setCustomValidity("");
            
            if(val) {
                if(val.match(reghtmlformat)) {
                    com.setCustomValidity($A.get("$Label.c.PMP_Invalid_Notes"));
                    com.reportValidity();
                    return false;
                } else {
                    com.reportValidity();
                    return true;
                }
            } else {
                com.setCustomValidity($A.get("$Label.c.PMP_LeadGen_CompleteThisField"));
                com.reportValidity();
                return false;
            }
        }
    },
   
	formSubmit: function(component, helper) {
		// get form data here
		var data = {};
		component.find('inputField').forEach(function (inputCmp) {
			data[inputCmp.get('v.name')] = inputCmp.get('v.value');
		});
		// radio button retrieval
	/*	var preferredContact = component.find('preferredContact');
		if (preferredContact){
			preferredContact.forEach(function(elem){
				if (elem.get('v.value')){
					data.preferredContact = elem.get('v.text');
				}
			})
		}	*/ // Commented since not in MVP
        
		data['termsAndConditions'] = component.find('inputTermsAndCondition').getElement().checked;
		console.log('FormSubmit', data);
        if(component.find('inputTermsAndCondition').getElement().checked){
            component.set("v.agreeCheckboxError", false);
            
            
            var action = component.get("c.submit");
            var partnerId = '';
            var partnerName = '';
            // IPA2.0 + US TWC4497-1631 
            // var offeringId = '';
            // var offeringName = '';
            // var offeringLink = '';
            if(component.get("v.partnerId") != ""){
                partnerId = component.get("v.partnerId");
                partnerName = component.get("v.partnerName");
            }
            // if(component.get("v.productId") != ""){
            //     offeringId = component.get("v.productId");
            //     offeringName = component.get("v.offeringName");
            // }
            // var offeringRecId = ''; 
            // if(component.get("v.productRecId") != ""){
            //     offeringRecId = component.get("v.productRecId");
            // }
          
           // String url = $A.get("$Label.c.Offering_Link_URL") + offeringRecId;
           
            /*component.set('v.offeringLink','https://nppdevpmp-intelcloudcrm.cs67.force.com/imp/s/offering/' + offeringRecId);
            if(component.get("v.offeringLink") != ""){
                offeringLink = component.get("v.offeringLink");
              
            }*/
            //Getting session Id from the utag
            var utag = window.focus('utag');
            var marketingCloudId = '';
            if (utag && utag.data) {
                marketingCloudId = utag.data.wa_amc_id;
            }
            console.log('Session Id : '+marketingCloudId);
            component.set('v.localUserDetails.sessionId', marketingCloudId);
            action.setParams({
                user : component.get("v.localUserDetails"),
                formType : component.get("v.formType"),
                partnerId : partnerId,
                partnerName : partnerName
                // IPA2.0 + US TWC4497-1631 
                // offeringId : offeringId,
                // offeringName : offeringName,
                // offeringRecId : offeringRecId
            });
            console.log('User : ', component.get("v.localUserDetails"));
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var result = response.getReturnValue();
                    console.log('result '+result);
                }else{
                    console.log("Error on submitting lead "+response.getError());
                }
            });
            $A.enqueueAction(action);
        }else{
            component.set("v.agreeCheckboxError", true);
        }
	},
    
    getUserDetails : function(component, helper){
      console.log('enter intogetuserdetails');
      var action = component.get("c.fetchUser");
        console.log('calling function');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               	
                console.log('entering to success loop for fetchuser'); 
                
                component.set("v.userDetails",response.getReturnValue());
                
                component.set("v.localUserDetails", component.get('v.userDetails'));
               
				          
                component.set('v.isOpen', true);
                helper.getPartnerProfession(component,helper);
                helper.getCountryStateOptions(component, helper);
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);  
    },
    
    getPartnerProfession : function(component, helper){
        var action = component.get("c.getPartnerProfession");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var response = response.getReturnValue();
               component.set('v.partnerProfession', response); 
            }
        });
        $A.enqueueAction(action);  
    },
    
    getCountryStateOptions : function(component, helper){
        var action = component.get("c.getDependentMap");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                component.set('v.dependantFieldMap', response);
                
               
                // set the ControllerField variable values to country(Country picklist field)
                component.set("v.countries", response);
                if(component.get("v.countries")){
                    component.set("v.showSpinner",false);
                }
                console.log('state : ' , component.get("v.localUserDetails.state"));
                var ListOfDependentFields = [];
                if(component.get("v.localUserDetails.state")){
                    for (var i = 0; i < response.length; i++) {
                        if(response[i].value == component.get("v.localUserDetails.country")){
                             component.set("v.localUserDetails.country", response[i].label);
                             ListOfDependentFields = response[i].children; 	
                            for(var j =0; j < response[i].children.length; j++){
                                if(response[i].children[j].value == component.get("v.localUserDetails.state")){
                                    component.set("v.localUserDetails.state", response[i].children[j].label);
                                }
                            }
                             
                        }
                        
            		}
                }
                if(ListOfDependentFields.length > 0){
                    helper.fetchStateValues(component, ListOfDependentFields);
                }
                
                
            }
        });
        $A.enqueueAction(action);  
    },
    
    fetchStateValues : function(component, ListOfDependentFields){
        
        // create a empty array var to store state picklist values for country field  
        var dependentFields = [];
        
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        
        // set the dependentFields variable values to store(State picklist field) on lightning:select
        component.set("v.states", dependentFields);
        
    },
   
})