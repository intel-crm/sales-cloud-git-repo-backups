({
    doInit : function(component,event,helper){
        helper.init(component,event,helper);
    },
    

    handleClick : function(component, event, helper) {
        helper.registerForm(component,event,helper);
    },
    cancelbtn : function(component,event,helper){
        helper.cancelEvent(component,event,helper);
    },
    next : function(component,event,helper){
        
        console.log("step Number"+component.get("v.currentStep"));
        // open confirmation Page       
        if(component.get("v.currentStep") === 'step2'){
            
            console.log("confirmation method");
            console.log('Confirmation Step'+component.get("v.currentStep"));
            let value  = component.find("childComp").getCimAccounts();
            console.log('value'+JSON.stringify(value));
            component.set("v.finalMapFromCIM",value);
            
            if(value != null)
            {
                component.set("v.accountAssociatedToExistingContact",null);
                if(value.accountAssociatedToExistingContact!= null)
                {
                    component.set("v.accountAssociatedToExistingContact",value.accountAssociatedToExistingContact);
                }
                
                if(value.associatedAccountIsIPA != null){
                    component.set("v.associatedAccountIsIPA",value.associatedAccountIsIPA);
                }
                
                component.set("v.duplicateContactRecord",null);
                if(value.duplicateContactRecord != null){
                    component.set("v.duplicateContactRecord",value.duplicateContactRecord);
                }
                //can add inactive scenario
                if(value.DuplicateRecords != null){
                    let v = value.DuplicateRecords;
                    console.log('inside DuplicateRecords'+v);
                    component.set("v.prevCimVal",JSON.stringify(v));
                }
                if(value.SelectedRow != null)
                {
                    let selectedAccount = value.SelectedRow;
                    component.set("v.prevSelectedCimVal",selectedAccount);   
                }
                if(value.DuplicateRecords == null || value.DuplicateRecords =='')
                {
                    let v = "No Duplicate Values Found";
                    component.set("v.prevCimVal",v);    
                }
                if(value.AccountDuplicateStatus != null)
                {   
                    let dupStatus = value.AccountDuplicateStatus ;
                    
                    component.set("v.accountDuplicateStatus",dupStatus);
                }
                if(value.ContactDuplicateStatus != null)
                {   
                    let contDupStatus = value.ContactDuplicateStatus ;
                    component.set("v.contactDuplicateStatus",contDupStatus);
                }
                
                console.log('Previous selected CIm account-->',component.get("v.prevSelectedCimVal"));  
                //var comparsionSelectedAccount = JSON.parse(component.get("v.prevSelectedCimVal"));
                //map containing values from UI
                let mapOfInputs = {AccountID: component.get("v.accId"),AccountName: component.get("v.accName"),
                                   BizOrgType: component.get("v.orgTypeSelected"),PartnerRole : component.get("v.optionsRole"),
                                   AddressLine1 : component.get("v.addressOne"), AddressLine2 : component.get("v.addressTwo"),
                                   Country : component.get("v.countrySelected"),CountryLabel : component.get("v.countryLabel"),
                                   State : component.get("v.stateSelected"),StateLabel : component.get("v.stateLabel"),
                                   City : component.get("v.addressCity"),PostalCode : component.get("v.addressZip"),Website : component.get("v.userWebsite"),
                                   ContactFirstName: component.get("v.conFirstName"),ContactLastName : component.get("v.conLastName"),
                                   ContactEmail: component.get("v.conEmail"),PreferredLanguage : component.get("v.languageSelected"),ContactCountry : component.get("v.contactCountrySelected"),
                                   DuplicateInfo : component.get("v.prevCimVal"), SelectedRow : component.get("v.prevSelectedCimVal"), AccountDuplicateStatus : component.get("v.accountDuplicateStatus"),
                                   ContactDuplicateStatus : component.get("v.contactDuplicateStatus"),accountAssociatedToExistingContact: component.get("v.accountAssociatedToExistingContact"),
                                   duplicateContactRecord : component.get("v.duplicateContactRecord"),associatedAccountIsIPA : component.get("v.associatedAccountIsIPA"),                                   
                                   SuppressEmail : component.get("v.suppressEmail") };


                //SBR's Changes ***********************************************
                var mapOfUCDInput = {AccountName: component.get("v.accName"),
                                   Country : component.get("v.countrySelected"),
                                   State : component.get("v.stateSelected"),
                                   City : component.get("v.addressCity"),
                                   Website : component.get("v.userWebsite"),
                                   };

                component.set("v.UCDMap",mapOfUCDInput);                  
                console.log('mapOfUCDInput--->'+JSON.stringify(mapOfUCDInput));                           
                //**********************************************************************
                
                component.set("v.InputMap",mapOfInputs);

                if (mapOfInputs.SelectedRow !== null && (JSON.stringify(mapOfInputs.SelectedRow).length > 2 || mapOfInputs.duplicateContactRecord != null)) {
                    helper.confirmationPage(component, event, helper);
                } else {
                    helper.goToSBRMsgPage(component, event, helper);
                }

                   
            }
            
        } 
        
        //open duplicate result table
        if(component.get("v.currentStep") == 'step1'){
            
            helper.validateInputs(component,event,helper);
            if(component.get("v.showErrorMsg") == false){
                console.log('duplicate Method 2');
                var prevInputValues;
                let newValues;
                let selectedCimRow =  component.get("v.prevSelectedCimVal") ;
                let mapOfInputs = {AccountID: component.get("v.accId"),AccountName: component.get("v.accName"),
                                   BizOrgType: component.get("v.orgTypeSelected"),PartnerRole : component.get("v.optionsRole"),
                                   AddressLine1 : component.get("v.addressOne"),AddressLine2 : component.get("v.addressTwo"),
                                   Country : component.get("v.countrySelected"),State : component.get("v.stateSelected"),
                                   City : component.get("v.addressCity"),PostalCode : component.get("v.addressZip"),Website : component.get("v.userWebsite"),
                                   ContactFirstName: component.get("v.conFirstName"),ContactLastName : component.get("v.conLastName"),
                                   ContactEmail: component.get("v.conEmail"),PreferredLanguage : component.get("v.languageSelected"),ContactCountry : component.get("v.contactCountrySelected"),
                                   DuplicateInfo : component.get("v.prevCimVal"),SelectedRow : selectedCimRow, AccountDuplicateStatus : component.get("v.accountDuplicateStatus"),
                                   ContactDuplicateStatus : component.get("v.contactDuplicateStatus"),accountAssociatedToExistingContact: component.get("v.accountAssociatedToExistingContact"),
                                   duplicateContactRecord : component.get("v.duplicateContactRecord"),associatedAccountIsIPA : component.get("v.associatedAccountIsIPA"),
                                   
                                   SuppressEmail : component.get("v.suppressEmail")};

                if(component.get("v.addressTwo") != undefined && component.get("v.addressTwo") != ""){
                    newValues = component.get("v.accName").trim()+component.get("v.addressOne").trim()+component.get("v.addressTwo").trim()+component.get("v.countrySelected")+component.get("v.stateSelected")+component.get("v.addressCity").trim()+component.get("v.addressZip").trim();
                }
                else {
                    newValues = component.get("v.accName").trim()+component.get("v.addressOne").trim()+component.get("v.countrySelected")+component.get("v.stateSelected")+component.get("v.addressCity").trim()+component.get("v.addressZip").trim();
                }
                console.log("newValues"+JSON.stringify(newValues));
                console.log("prevInputValues"+JSON.stringify(component.get("v.prevInputValues")));
                if(newValues != null && newValues != component.get("v.prevInputValues") && component.get("v.prevInputValues") != null && component.get("v.prevInputValues") != 'undefined'){
                    mapOfInputs.DuplicateInfo = "";
                    console.log("====CIM Callout required===");
                }

                console.log('Input Map'+JSON.stringify(mapOfInputs));
                component.set("v.InputMap",mapOfInputs);
                if(component.get("v.addressTwo") != undefined && component.get("v.addressTwo") != ""){
                    prevInputValues = component.get("v.accName").trim()+component.get("v.addressOne").trim()+component.get("v.addressTwo").trim()+component.get("v.countrySelected")+component.get("v.stateSelected")+component.get("v.addressCity").trim()+component.get("v.addressZip").trim();
                }
                else {
                    prevInputValues = component.get("v.accName").trim()+component.get("v.addressOne").trim()+component.get("v.countrySelected")+component.get("v.stateSelected")+component.get("v.addressCity").trim()+component.get("v.addressZip").trim();
                }
                component.set("v.prevInputValues",prevInputValues);
				 helper.nextEvent(component,event,helper); 
            }
        }
        
    },


    handleStateChange : function(component,event,helper){
        helper.getStateValues(component,event,helper);
    },
    handleMyComponentEvent : function(component,event,helper){
        let value = event.getParam("Loading");
        let valuesMap = event.getParam("FinalMap");
        let disbleValue=event.getParam("DisableNext");
        console.log('EVENT'+value);
        if(value){
            console.log('EVENT2'+value);
            component.set("v.showProgressBar",true);
            console.log("valuesMap--> "+JSON.stringify(valuesMap));
            console.log("valuesMap Account DUP STatus-->"+valuesMap.AccountDuplicateStatus);
            console.log("valuesMap Contact Dup Status-->"+valuesMap.ContactDuplicateStatus);
            console.log('@@ valuesMap.accountExactMatch-->'+valuesMap.accountExactMatch);
            
            
            let prev = component.find("prevButn");
            $A.util.removeClass(prev, "slds-hide");


            

            if(valuesMap != null && valuesMap != undefined){
                $A.util.removeClass(component.find("nextBtn"), "slds-hide");
            }
            if(disbleValue != null && disbleValue != undefined){
                component.find("nextBtn").set("v.disabled", true);
            }
        }
    },
    
    handleButtonEvent : function(component,event,helper){
        helper.buttonEvent(component,event,helper);
    },
    
    previous : function(component,event,helper){
        console.log('step Number'+component.get("v.currentStep"));
        
        if(component.get("v.currentStep") == "step2"){
            console.log('First Previous');
            helper.prevEvent(component,event,helper);
        }
        
        if(component.get("v.currentStep") == "step3"){
            console.log('Second Previous');
            helper.duplicateInfoPage(component,event,helper);
        }
        
    },
    handleRoleChange : function(component,event,helper){
        helper.partnerRoleChange(component,event,helper);
    },
    handleOrgTypeChange : function(component,event,helper){
        helper.orgTypeChange(component,event,helper);
    },
    handleLanguageChange : function(component,event,helper){
        helper.prefLanguageChange(component,event,helper);
    },

   
     //Restrict embargoed countries - US860528 / US860527
     handleCountry : function(component,event,helper){
        helper.prefhandleCountry(component,event,helper);
    },

    handleCountryChange : function(component,event,helper){
       helper.populateStateValues(component,event,helper);
        helper.prefhandleCountry(component,event,helper);
    },

    finalSubmission : function(component,event,helper){
        helper.submit(component,event,helper);
    },
    
    navigateToAccount : function(component,event,helper){
        helper.navigationToAccountPage(component,event,helper);
    },
    
    updateEmail : function(component,event,helper){
        helper.updateEmailInput(component,event,helper);
    },
    
    getAccount : function(component,event,helper){
        helper.getAccountDetails(component,event,helper);
       
    },
    
    
    handleSuppressEmail :function(component,event,helper){
        helper.prefhandleSuppressEmail(component,event,helper);
    },

    openModal: function(component, event, helper) {
        component.set("v.showModal", true);
    },
    
    closeModal: function(component, event, helper) {
        component.set("v.showModal", false);
    }
  
})