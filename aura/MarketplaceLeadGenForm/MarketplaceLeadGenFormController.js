({
    
    doInit : function(component, event, helper) {
        
        component.set('v.closeModalCallback', $A.getCallback(function() {
            
            component.set('v.localUserDetails', component.get('v.userDetails'));
            component.set('v.agreeCheckboxError', false);
            component.set('v.phoneValidationError', false);
            component.set('v.emailValidationError', false);
            component.set('v.states', []);
            component.set("v.isStateDisabled", false);
            component.set("v.isStateRequired", true);            
            component.set('v.isOpen', false);
            
            //Contact Partner analytics code starts
            var analyticsData = component.find("analyticsData");
            var source = '';
            var str = '';
            if(component.get('v.formType') == 'contact'){
                source = 'ask-a-question';
                str = 'modal_contact-partner:'+ source +'|' + component.get('v.partnerRecId');
            }else if(component.get('v.formType') == 'quote'){
                source = 'request-a-quote';
                str = 'modal_contact-partner:'+ source +'|' + component.get('v.partnerRecId') + '|' + component.get('v.productRecId');
            }
            
            
            analyticsData.formAnalyticsData('click',str,'cancel');
            //Contact Partner analytics code ends
            
        }));
        
    },
    handleCloseModal: function(component, event, helper) {
        component.set('v.localUserDetails', component.get('v.userDetails'));
        component.set('v.agreeCheckboxError', false);
        component.set('v.phoneValidationError', false);
        component.set('v.emailValidationError', false);
        component.set('v.states', []);
        component.set("v.isStateDisabled", false);
        component.set("v.isStateRequired", true);  
        component.set('v.isOpen', false);
        
    },
    handlePageEvent: function(component, event, helper) {
        console.log('type',event.getParam('type'));
     if (event.getParam('type') == 'openLeadGenModal') {
      var payload = event.getParam('payload');
         console.log('payload:::', payload);
      // If component is not yet present, add it here
     /* if (!component.find('leadGenerationForm')) {
        $A.createComponent("c:MarketplaceLeadGenForm", {
          'aura:id': 'leadGenerationForm',
        },
        function(newComponent, status, errorMessage) {
          if (status === "SUCCESS") {
            var container = component.get("v.main");
            container.push(newComponent);
            component.set("v.main", container);
            // retrigger event
            var appEvent = $A.get("e.c:MarketplacePageEvent");
            appEvent.setParams({
              type: "openLeadGenModal",
              payload: payload
            });
            appEvent.fire();
          } else if (status === "INCOMPLETE") {
            console.error("No response from server or client is offline.");
          } else if (status === "ERROR") {
            console.error("Error: " + errorMessage);
          }
        });
      }*/ // Commented due to an error

            console.log('handlePageEvent invoked from leag gen form!!!',payload.languageMessage);
            console.log('handlePageEvent invoked from leag gen form!!!',payload.formType);
            component.set('v.languageLabel', payload.languageMessage);                        
            component.set('v.formType', payload.formType || 'contact');
            console.log('AutoPartnerId :' , payload.partnerData.autoPartnerId);
            
            if(payload.partnerData.autoPartnerId){
                component.set('v.partnerId', payload.partnerData.autoPartnerId);
            }
            if(payload.partnerData.id){
                component.set('v.partnerRecId', payload.partnerData.id);
            }
            
            if(payload.partnerData.oid){
                component.set('v.productId', payload.partnerData.oid);
            }
            // IPA2.0 + US TWC4497-1631 
            // if(payload.partnerData.offRecId){
            //     component.set('v.productRecId', payload.partnerData.offRecId);
            // }
            // if (payload.partnerData.title) {
                
            //     component.set('v.offeringName', payload.partnerData.title);
            // } else {
            //     component.set('v.offeringName', '');
            // }
            if(payload.partnerData.name){
                component.set('v.partnerName', payload.partnerData.name);
            }
            
            if(payload.userAuthentication){
                
                helper.getUserDetails(component,helper);
                console.log('SUCCESS User Auth');
                
            }else{

                component.set('v.localUserDetails', {});
                component.set('v.isOpen', true);
                helper.getPartnerProfession(component,helper);
                helper.getCountryStateOptions(component, helper);
                console.log('GUEST');
            }
            
        }       	
    },
    handleFormOpen : function(component, event, helper) {
        console.log('inside handleFormOpen');
        var action = component.get("c.fetchUser");
        console.log('calling function');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               	
                console.log('entering to success loop for fetchuser'); 
                
                component.set("v.userDetails",response.getReturnValue());
                
                component.set("v.localUserDetails", component.get('v.userDetails'));
				          
                //component.set('v.isOpen', true);
                helper.getPartnerProfession(component,helper);
                helper.getCountryStateOptions(component, helper);
                console.log(response.getReturnValue());
                
                if (component.get('v.formType') == 'contact') {
                    component.set('v.modalHeading', $A.get("$Label.c.PMP_LeadGen_AskAQuestion"));
                } else if (component.get('v.formType') == 'quote') {
                    component.set('v.modalHeading', $A.get("$Label.c.PMP_LeadGen_RequestAQuote"));
                }
                //start of logic
                
                //end of logic
                var localUserDetails = component.get('v.localUserDetails');
                console.log('localUserDetails',component.get('v.localUserDetails'));
                var hasSegment = false;
                if(localUserDetails != null && localUserDetails.partnerProgramSegment){
                    hasSegment = true;
                }
                var userDetailCheck = false;
                if(hasSegment){
                    userDetailCheck = localUserDetails && Object.keys(localUserDetails).length > 0 ;
                }
                else{
                    userDetailCheck = localUserDetails && Object.keys(localUserDetails).length > 1;  
                }
                
                if (localUserDetails && Object.keys(localUserDetails).length > 0){//userDetails.preferredContact value is set in handleRadioChange function,hence the userDetail length is always to be 1
                    console.log('inside if'+Object.keys(localUserDetails).length);
                    component.set('v.readOnly', true);
                    console.log(component.get('v.readOnly'));
                    
                } else {
                    
                    component.set('v.readOnly', false);
                    component.set('v.localUserDetails', {});
                    console.log('inside else',JSON.parse(JSON.stringify(localUserDetails)));
                }
                component.set('v.formCompleted', false);
            }
        });
        $A.enqueueAction(action);          
    },
    handleFormSubmitClick: function(component, event, helper) {
        
        var isValidDate = true;
        var isValidDateFormat = true;
        if(component.find("deliveryDate") != "undefined" || component.find("deliveryDate") != '' ){
            // console.log('key = '+event.getParams().keyCode); 

            var today = new Date();        
            var dd = today.getDate();
            var mm = today.getMonth() + 1; //January is 0!
            var yyyy = today.getFullYear();
            // if date is less then 10, then append 0 before date   
            if(dd < 10){
                dd = '0' + dd;
            } 
            // if month is less then 10, then append 0 before date    
            if(mm < 10){
                mm = '0' + mm;
            }
            var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
            console.log(component.get("v.localUserDetails.deliveryDate"));
            if( component.get("v.localUserDetails.deliveryDate") == null || (component.get("v.localUserDetails.deliveryDate") != '' && component.get("v.localUserDetails.deliveryDate") < todayFormattedDate)){         
                isValidDate = false;
            }else{
                isValidDate = true;
            }
            
             /*var dobcmp = component.find("deliveryDate"),
    		 isValidDate = dobcmp.get("v.validity");*/
        }

        var isValidEmail = true; 
        var emailField = component.find("leadEmail");
        var emailFieldValue = emailField.get("v.value");
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
        
        if(!$A.util.isEmpty(emailFieldValue)){   
            if(emailFieldValue.match(regExpEmailformat)){
                isValidEmail = true;
            }else{
                isValidEmail = false;
            }
        }else{
            component.set("v.emailEmptyValidationError" , true);
                isValidEmail = false;
        }
        //Phone validation before submit, for PROD defect
        var  isValidPhone = true; 
        var phoneField = component.find("leadPhone");
        var phoneFieldValue = phoneField.get("v.value");
        var regExpPhoneformat = /^[0-9 ()+-]+$/;  
        
        if(!$A.util.isEmpty(phoneFieldValue)){   
            if(phoneFieldValue.match(regExpPhoneformat)){
                isValidPhone = true;
            }else{
                isValidPhone = false;
            }
        }
        //Phone validation before submit, for PROD defect

        var isValid = helper.isFormValid(component, helper);

        if(isValidEmail && isValidDate && isValid && isValidPhone) { // added isValidPhone for PROD defect
            
            helper.formSubmit(component, helper);
            //Adding heading when form is submitted
            component.set('v.modalHeading', $A.get("$Label.c.PMP_Inquiry_Progress"));
            component.set('v.formCompleted', true);                                                 
        }
        
        //Contact Partner analytics code starts
        var analyticsData = component.find("analyticsData");
            var source = '';
        	var str = '';
            if(component.get('v.formType') == 'contact'){
                
                str = str = 'modal_contact-partner:ask-a-question|' + component.get('v.partnerRecId');
            }else if(component.get('v.formType') == 'quote'){
                
                str = str = 'modal_contact-partner:request-a-quote|' + component.get('v.partnerRecId') + '|' + component.get('v.productRecId');
            } 
            analyticsData.formAnalyticsData('click',str,'submit');
         //Contact Partner analytics code ends
        
    },
    handleFormSubmit: function(component, event, helper) 
    {
        
        event.preventDefault();
        return false;
    },
    handleCheckboxChange: function(component, event, helper) 
    {
        if (event.currentTarget.checked && component.get('v.agreeCheckboxError')) {
            // remove error message if there is one
            component.set('v.agreeCheckboxError', false);
        }
    },
    
    emailUpdate : function(component, event, helper)
    {
        var isValidEmail = true; 
        var emailField = component.find("leadEmail");
        var emailFieldValue = emailField.get("v.value");
        // Store Regular Expression That 99.99% Works. [ http://emailregex.com/] 
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
        if(!$A.util.isEmpty(emailFieldValue)){   
            if(emailFieldValue.match(regExpEmailformat)){
                component.set("v.emailEmptyValidationError" , false); 
                component.set("v.emailValidationError" , false);
                isValidEmail = true;
            }else{
                
                component.set("v.emailEmptyValidationError" , false);
                component.set("v.emailValidationError" , true);

                //  $A.util.addClass(emailField, 'slds-has-error');
                //  emailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);
                isValidEmail = false;
            }
        }
        else{ //Added to fix double errors
              component.set("v.emailValidationError" , false); 
              component.set("v.emailEmptyValidationError" , true);
              isValidEmail = false;
        }
        component.find('leadEmail').showHelpMessageIfInvalid(); //Added to fix DE80595
    },
    dateUpdate : function(component, event, helper){
        // debugger;
        // valid = isComponentValid && isCustomMessageNotBlank()
        if (event.keyCode == 65) {
            alert('key pressed');
        }
        // alert('key pressed');
        var isValidDate = true;
        var isValidDateFormat = true;
        var dateField = component.find("deliveryDate");
        dateField.setCustomValidity('') ;
        var dateFieldValue = dateField.get("v.value");
        console.log(dateFieldValue); 
        console.log('dateFieldValue',dateFieldValue);
        // console.log('value'+component.get("v.localUserDetails.deliveryDate")); 
        console.log('component ',component.find("deliveryDate"))  
        
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        // var sel = window.getSelection().toString();
        // console.log('seletion'+sel);
        
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        var regExpDateformat =   /^\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])$/;
        
        if(component.get("v.localUserDetails.deliveryDate") != '' && component.get("v.localUserDetails.deliveryDate") < todayFormattedDate){         
            component.set("v.dateValidationError" , true);
            isValidDate = false;
        }else{
            component.set("v.dateValidationError" , false);
            isValidDate = true;
        }       
        
        /* if(dateFieldValue == null || dateFieldValue == ''){
            dateField.setCustomValidity('Your entry does not match the allowed format MMM dd, yyyy.');
            return false;
         }
          else {
             dateField.setCustomValidity('');
              return true;
           }
             dateField.reportValidity('');*/
        
    },
    /*  keyPress: function(component, event, helper){
         if (event.keyCode == 65) {
			alert('key pressed');
		}
    }*/
    
    onCountryChange : function(component, event, helper){
        console.log(event.getSource().get("v.value"));
        var ListOfDependentFields = [];
        var countryValueKey = event.getSource().get("v.value");
        component.set('v.localUserDetails.country', countryValueKey);
        var dependantFieldMap = component.get("v.dependantFieldMap");
        console.log('Dependent Map ',dependantFieldMap);
        var defaultvalue = $A.get("$Label.c.PMP_LeadGen_ChooseOne");
        if (countryValueKey != defaultvalue){
            
            for (var i = 0; i < dependantFieldMap.length; i++) {
                if(dependantFieldMap[i].label == countryValueKey){
                    ListOfDependentFields = dependantFieldMap[i].children;
                }
            }
            
            console.log('ListOfDependent Fields : ', ListOfDependentFields); 
            if(ListOfDependentFields.length > 0){
                component.set("v.isStateDisabled", false);
                component.set("v.isStateRequired", true);
                helper.fetchStateValues(component, ListOfDependentFields);
            }else{
                component.set("v.toggleStateError", false);
                component.set("v.toggleStateError", true);
                component.set("v.states", []);
                component.set("v.isStateDisabled", true);
                component.set("v.isStateRequired", false);
            }
            
        }
        
    } ,
    
    onStateChange : function(component, event, helper){
        var stateValueKey = event.getSource().get("v.value");
        component.set('v.localUserDetails.state', stateValueKey);
    },
    
    firstNameValidity: function(component, event, helper) {        
        helper.isNameValid(component, 'fname');
    },
    
    lastNameValidity: function(component, event, helper) {
        helper.isNameValid(component, 'lname');
    },
    leadnotceValidity: function(component, event, helper) {
        helper.isLeadnotesValid(component, 'leadnotce');
    },
    leaddescValidity: function(component, event, helper) {
        helper.isLeadnotesValid(component, 'leadgendesc');
    },
    companyValidity:function(component, event, helper) {
        helper.isNameValid(component, 'cmpnyName');
    },
    Phonevalidity:function(component, event, helper) {//Added to fix DE80595
        component.find('leadPhone').showHelpMessageIfInvalid();       
    },
})