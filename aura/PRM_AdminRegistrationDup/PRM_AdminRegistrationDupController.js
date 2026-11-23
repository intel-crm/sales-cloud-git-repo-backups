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
        if(component.get("v.currentStep") == 'step2'){
            
            console.log("confirmation method");
            console.log('Confirmation Step'+component.get("v.currentStep"));
            var value  = component.find("childComp").getCimAccounts();
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
                
                if(value.DuplicateRecords != null){
                    var v = value.DuplicateRecords;
                    component.set("v.prevCimVal",JSON.stringify(v));
                }
                if(value.SelectedRow != null)
                {
                    var selectedAccount = value.SelectedRow;
                    component.set("v.prevSelectedCimVal",selectedAccount);   
                }
                if(value.DuplicateRecords == null || value.DuplicateRecords =='')
                {
                    var v = "No Duplicate Values Found";
                    component.set("v.prevCimVal",v);    
                }
                if(value.AccountDuplicateStatus != null)
                {   //alert('inside if to set value of dup status on next of second screen');
                    var dupStatus = value.AccountDuplicateStatus ;
                    component.set("v.accountDuplicateStatus",dupStatus);
                }
                if(value.ContactDuplicateStatus != null)
                {   //alert('inside if to set value of dup status on next of second screen');
                    var contDupStatus = value.ContactDuplicateStatus ;
                    component.set("v.contactDuplicateStatus",contDupStatus);
                }
                
                console.log('Previous selected CIm account-->',component.get("v.prevSelectedCimVal"));  
                //var comparsionSelectedAccount = JSON.parse(component.get("v.prevSelectedCimVal"));
                //map containing values from UI
                var mapOfInputs = {AccountName: component.get("v.accName"),
                                   BizOrgType: component.get("v.orgTypeSelected"),PartnerRole : component.get("v.optionsRole"),
                                   AddressLine1 : component.get("v.addressOne"), AddressLine2 : component.get("v.addressTwo"),
                                   Country : component.get("v.countrySelected"),CountryLabel : component.get("v.countryLabel"),
                                   State : component.get("v.stateSelected"),StateLabel : component.get("v.stateLabel"),
                                   City : component.get("v.addressCity"),PostalCode : component.get("v.addressZip"),Website : component.get("v.userWebsite"),
                                   ContactFirstName: component.get("v.conFirstName"),ContactLastName : component.get("v.conLastName"),
                                   ContactEmail: component.get("v.conEmail"),PreferredLanguage : component.get("v.languageSelected"),ContactCountry : component.get("v.contactCountrySelected"),
                                   DuplicateInfo : component.get("v.prevCimVal"), SelectedRow : component.get("v.prevSelectedCimVal"), AccountDuplicateStatus : component.get("v.accountDuplicateStatus"),
                                   ContactDuplicateStatus : component.get("v.contactDuplicateStatus"),accountAssociatedToExistingContact: component.get("v.accountAssociatedToExistingContact"),
                                   duplicateContactRecord : component.get("v.duplicateContactRecord"),associatedAccountIsIPA : component.get("v.associatedAccountIsIPA")};
                
                component.set("v.InputMap",mapOfInputs);
                console.log('mapOfInputs 3 '+JSON.stringify(mapOfInputs));
                
                helper.confirmationPage(component,event,helper);
                
            }
        } 
        //open duplicate result table
        if(component.get("v.currentStep") == 'step1'){
            
            helper.validateInputs(component,event,helper);
            if(component.get("v.showErrorMsg") == false){
                console.log('duplicate Method 2');
                var prevInputValues;
                var newValues;
                var selectedCimRow =  component.get("v.prevSelectedCimVal") ;
                //alert('Dup status set in parent comp'+component.get("v.accountDuplicateStatus"));
                var mapOfInputs = {AccountName: component.get("v.accName"),
                                   BizOrgType: component.get("v.orgTypeSelected"),PartnerRole : component.get("v.optionsRole"),
                                   AddressLine1 : component.get("v.addressOne"),AddressLine2 : component.get("v.addressTwo"),
                                   Country : component.get("v.countrySelected"),State : component.get("v.stateSelected"),
                                   City : component.get("v.addressCity"),PostalCode : component.get("v.addressZip"),Website : component.get("v.userWebsite"),
                                   ContactFirstName: component.get("v.conFirstName"),ContactLastName : component.get("v.conLastName"),
                                   ContactEmail: component.get("v.conEmail"),PreferredLanguage : component.get("v.languageSelected"),ContactCountry : component.get("v.contactCountrySelected"),
                                   DuplicateInfo : component.get("v.prevCimVal"),SelectedRow : selectedCimRow, AccountDuplicateStatus : component.get("v.accountDuplicateStatus"),
                                   ContactDuplicateStatus : component.get("v.contactDuplicateStatus"),accountAssociatedToExistingContact: component.get("v.accountAssociatedToExistingContact"),
                                   duplicateContactRecord : component.get("v.duplicateContactRecord"),associatedAccountIsIPA : component.get("v.associatedAccountIsIPA")};
                
                if(component.get("v.addressTwo") != undefined && component.get("v.addressTwo") != ""){
                    newValues = component.get("v.accName").trim()+component.get("v.addressOne").trim()+component.get("v.addressTwo").trim()+component.get("v.countrySelected")+component.get("v.stateSelected")+component.get("v.addressCity").trim()+component.get("v.addressZip").trim();
                }
                else {
                    newValues = component.get("v.accName").trim()+component.get("v.addressOne").trim()+component.get("v.countrySelected")+component.get("v.stateSelected")+component.get("v.addressCity").trim()+component.get("v.addressZip").trim();
                }
                console.log("newValues"+JSON.stringify(newValues));
                console.log("prevInputValues"+JSON.stringify(component.get("v.prevInputValues")));
                //alert('PrevInputValues'+JSON.stringify(component.get("v.prevInputValues")));
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
    handleCountryChange : function(component,event,helper){
        helper.populateStateValues(component,event,helper);
    },
    handleStateChange : function(component,event,helper){
        helper.getStateValues(component,event,helper);
    },
    handleMyComponentEvent : function(component,event,helper){
        var value = event.getParam("Loading");
        var valuesMap = event.getParam("FinalMap");
        console.log('EVENT'+value);
        if(value){
            console.log('EVENT2'+value);
            component.set("v.showProgressBar",true);
            console.log("valuesMap--> "+JSON.stringify(valuesMap));
            console.log("valuesMap Account DUP STatus-->"+valuesMap.AccountDuplicateStatus);
            console.log("valuesMap Contact Dup Status-->"+valuesMap.ContactDuplicateStatus);
            /*var li = component.find("firstLI");
            console.log('LI'+li);
            $A.util.removeClass(li,'slds-path__item slds-is-current slds-is-active');
            $A.util.addClass(li,'slds-path__item slds-is-won');
            
            var secondLi = component.find("secondLI");
            console.log('secondLi'+secondLi);
            $A.util.removeClass(secondLi,'slds-path__item slds-is-incomplete');
            $A.util.addClass(secondLi,'slds-path__item slds-is-current slds-is-active');*/
            
            var prev = component.find("prevButn");
            $A.util.removeClass(prev, "slds-hide");
            
            //Scenarios where we need next button on duplicate screen without selecting row
            if(valuesMap != null && valuesMap != undefined &&
               (valuesMap.AccountDuplicateStatus == "NoDup" && valuesMap.ContactDuplicateStatus == "NoDuplicate") ||
               (valuesMap.AccountDuplicateStatus == "PartDup" && valuesMap.ContactDuplicateStatus == "NoDuplicate") ||
               (valuesMap.AccountDuplicateStatus == "NoDup" && valuesMap.ContactDuplicateStatus == "Duplicate") ||
               (valuesMap.AccountDuplicateStatus == "PartDup" && valuesMap.ContactDuplicateStatus == "Duplicate") ||
               (valuesMap.AccountDuplicateStatus == "FullDup" && valuesMap.ContactDuplicateStatus == "Duplicate")){
                $A.util.removeClass(component.find("nextBtn"), "slds-hide");
            }
            else {
                //alert('Disable It');
                var button = component.find('nextBtn');
                button.set('v.disabled',true);
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
    }
    
})