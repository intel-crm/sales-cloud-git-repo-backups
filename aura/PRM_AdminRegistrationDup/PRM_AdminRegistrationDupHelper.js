({
    
    init : function(component,event,helper){
        //Server call to retrieve the state and country picklist values :
        var action = component.get("c.getPicklistValues");
        action.setCallback( this, function( response ) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                var data = response.getReturnValue();
                console.log("DATA"+JSON.stringify(data));
                
                var prefLanguage = data.prefLanguageMap;
                var partRoleTypeMap = data.roleTypeMapping;
                var orgType = data.bizOrgTypeMap;
                
                var optionLang1 = [];
                var optionLang2 = [];
                var finalLanguageList = [];
                var optionRole = [];
                var optionOrgType = [];
                for(var i in prefLanguage){
                    var languages = {
                        label: prefLanguage[i],
                        value : i
                    }
                    if(prefLanguage[i] == "English"){
                        optionLang1.push(languages);
                    }
                    else {
                        optionLang2.push(languages);
                    }
                }
                
                console.log('optionLang1'+JSON.stringify(optionLang1));
                console.log('optionLang2'+JSON.stringify(optionLang2));
                finalLanguageList = optionLang1.concat(optionLang2);
                console.log('finalLanguageList'+JSON.stringify(finalLanguageList));
                
                /* for(var i in partRole){
                    var roles = {
                        label: partRole[i],
                        value : i
                    }
                    optionRole.push(roles);
                }*/
                
                for(var i in orgType){
                    var bizOrgType = {
                        label: orgType[i],
                        value : i
                    }
                    optionOrgType.push(bizOrgType);
                }
                
                component.set("v.optionsLanguage",finalLanguageList);
                component.set("v.partnerRoleTypeMap",partRoleTypeMap);
                console.log('partRoleTypeMap'+JSON.stringify(component.get("v.partnerRoleTypeMap")));
                //console.log("partRoleTypeMap"+JSON.stringify(partRoleTypeMap));
                //component.set("v.optionsRole",optionRole);
                component.set("v.optionsType",optionOrgType);
                //console.log('options '+JSON.stringify(option));
                //alert(JSON.stringify(data.bizOrgTypeMap));
                component.set("v.stateCountryInfo",data.stateCountryInfoList);
                //alert('data'+JSON.stringify(data));
                var stateCountryList = data.stateCountryInfoList ;
                let keys = [];
                for (var i=0; i<stateCountryList.length; i++){
                    var country = stateCountryList[i].country;
                    var c ={
                        "label": country.substr(0, country.indexOf(';')),
                        "value": country.substr(country.indexOf(';')+1,country.length) 
                    };            
                    keys.push(c);    
                }
                //alert(JSON.stringify(keys));
                component.set('v.optionsCountry',keys);
                component.set("v.formSpinner",false);
                component.set("v.loadPage",true);
                component.find("accountName").set("v.disabled",true);
                component.find("addrLine1").set("v.disabled",true);
                component.find("addrLine2").set("v.disabled",true);
                component.find("countryList").set("v.disabled",true);
                component.find("stateList").set("v.disabled",true);
                component.find("cityAdd").set("v.disabled",true);
                component.find("zipCode").set("v.disabled",true);
                component.find("web").set("v.disabled",true);
            }else{
                console.error("Error calling action: "+ response.getState());
            }
            
            
        }); 
        $A.enqueueAction(action);
        
        component.set("v.formSpinner",true);
        if(component.get("v.loadPage") == true){
            component.set("v.formSpinner",false);
            
        }
        component.set("v.showUI",true);
        component.set("v.showProgressBar",true);
        component.set("v.btn",false);
        component.set("v.currentStep",'step1');
        component.set("v.buttonSection",true);    
        var prev = component.find("prevButn");
        $A.util.addClass(prev, "slds-hide");
        console.log('yes');
        //acc.set("v.disabled",true);
    },
    
    populateStateValues : function(component,event,helper){
        
        var countries= component.get("v.optionsCountry");
        var selectedCountry = component.get("v.countrySelected");
        
        for(var i in countries){
            // console.log('i'+i);
            console.log('countries[i] Label'+JSON.stringify(countries[i].label));
            console.log('countries[i] Value'+JSON.stringify(countries[i].value));
            if(countries[i].value == selectedCountry){
                console.log('ITS A MATCH'+countries[i].label);
                component.set("v.countryLabel",countries[i].label);
                //component.set("")
                break;
            }
        }
        component.set("v.stateSelected","");
        var selectedCountry = event.getParam("value");
        component.set("v.countrySelected",selectedCountry);
        //alert(selectedCountry);
        var stateCountryInfo = component.get("v.stateCountryInfo");
        let values = [];
        for (var i=0; i<stateCountryInfo.length; i++){
            if(stateCountryInfo[i].country.substr(stateCountryInfo[i].country.indexOf(';')+1,stateCountryInfo[i].country.length) == selectedCountry){
                for(var j=0; j<stateCountryInfo[i].stateList.length; j++)
                {
                    var state= stateCountryInfo[i].stateList[j];
                    var s ={
                        "label": state.substr(0, state.indexOf(';')) ,
                        "value": state.substr(state.indexOf(';')+1,state.length)
                    };            
                    values.push(s);            
                }
            }
        }
        //alert(JSON.stringify(values));
        component.set("v.optionsState",values);
        var stateList = component.find("stateList");
        if(values== null || values.length == 0)
        {   
            stateList.set('v.disabled',true);
            component.set("v.stateLabel","");
        }
        else{
            stateList.set('v.disabled',false);
        }
        
    },
    
    getStateValues : function(component,event,helper){
        var state= component.get("v.optionsState");
        var selectedState = component.get("v.stateSelected");
        
        for(var i in state){
            // console.log('i'+i);
            console.log('state[i] Label'+JSON.stringify(state[i].label));
            console.log('state[i] Value'+JSON.stringify(state[i].value));
            if(state[i].value == selectedState){
                console.log('ITS A MATCH'+state[i].label);
                component.set("v.stateLabel",state[i].label);
                //component.set("")
                break;
            }
        }
        
    },
    
    registerForm : function(component,event,helper) {
        component.set("v.formSpinner",true);
        if(component.get("v.loadPage") == true){
            component.set("v.formSpinner",false);
        }
        component.set("v.showUI",true);
        component.set("v.showProgressBar",true);
        component.set("v.btn",false);
        component.set("v.currentStep",'step1');
        component.set("v.buttonSection",true);    
        var prev = component.find("prevButn");
        $A.util.addClass(prev, "slds-hide");
        //var nextDuplicateInfoButton = component.find("nextDuplicateInfoBtn");
        //$A.util.addClass(nextDuplicateInfoButton, "slds-hide");
        
    },
    
    cancelEvent : function(component,event,helper){
        var url = window.location.href;
        url = url.replace(url.substring(url.indexOf('lightning/') + 10), 'page/home');
        window.location.href = url;
        component.set("v.showUI",false);
        component.set("v.showProgressBar",false);
        component.set("v.btn",true);
        component.set("v.buttonSection",false);
        component.set("v.accName","");
        component.set("v.roleSelected","");
        component.set("v.orgTypeSelected","");
        component.set("v.addressOne","");
        component.set("v.addressTwo","");
        component.set("v.countrySelected","");
        component.set("v.addressCity","");
        component.set("v.stateSelected","");
        component.set("v.addressZip","");
        component.set("v.conFirstName","");
        component.set("v.conEmail","");
        component.set("v.conLastName","");
        component.set("v.languageSelected","");
        component.set("v.contactCountrySelected","");
        component.set("v.userWebsite","");
        
        var buttonClicked = event.getSource().getLocalId();
        console.log('buttonClicked' + buttonClicked);
        if(buttonClicked == "closeBtn"){
            component.set("v.showFinalPage",false);
        }
    },
    
    nextEvent : function(component,event,helper){
        console.log('duplicate Method 3');
        
        component.set("v.showUI",false);
        component.set("v.showProgressBar",false);
        component.set("v.showTables",true);
        console.log('Table'+component.get("v.showTables"));
        var stepNumber = component.get("v.currentStep");
        console.log('stepNumber'+stepNumber);
        if(stepNumber == "step1"){
            component.set("v.currentStep",'step2');
        }
        $A.util.addClass(component.find("cancelBtn"), "slds-hide");
        $A.util.addClass(component.find("nextBtn"), "slds-hide");
        
    },
    
    duplicateInfoPage : function(component,event,helper){
        component.set("v.showConfirmationPage",false);
        $A.util.addClass(component.find("nextBtn"), "slds-hide");
        $A.util.addClass(component.find("prevButn"), "slds-hide");
        component.set("v.showTables",true);
        
        /*var secondLi = component.find("secondLI");
        console.log('secondLi'+secondLi);
        $A.util.removeClass(secondLi,'slds-path__item slds-is-won');
        $A.util.addClass(secondLi,'slds-path__item slds-is-current slds-is-active');
        
        //var duplicateTitle = component.find("duplicateTitle");
        //console.log('duplicateTitle'+duplicateTitle);
        //$A.util.addClass(duplicateTitle,'addColor');
        
        var thirdLi = component.find("thirdLI");
        console.log('thirdLi'+thirdLi);
        $A.util.removeClass(thirdLi,'slds-path__item slds-is-current slds-is-active');
        $A.util.addClass(thirdLi,'slds-path__item slds-is-incomplete');
        */
        
        component.set("v.showProgressBar",false);
        var stepNumber = component.get("v.currentStep");
        console.log('stepNumber'+stepNumber);
        if(stepNumber == "step3"){
            component.set("v.currentStep",'step2');
        }
        
        //var prevConfirmationButton = component.find("prevConfirmationBtn");
        //$A.util.addClass(prevConfirmationButton, "slds-hide");
        var submit = component.find("submit");
        $A.util.addClass(submit, "slds-hide");
    },
    
    
    prevEvent : function(component,event,helper){
        component.set("v.showUI",true);
        /*var li = component.find("firstLI");
        console.log('LI'+li);
        $A.util.removeClass(li,'slds-path__item slds-is-won');
        $A.util.addClass(li,'slds-path__item slds-is-current slds-is-active');
        
        var secondLi = component.find("secondLI");
        console.log('secondLi'+secondLi);
        $A.util.removeClass(secondLi,'slds-path__item slds-is-current slds-is-active');
        $A.util.addClass(secondLi,'slds-path__item slds-is-incomplete');
        
        var duplicateTitle = component.find("duplicateTitle");
        $A.util.removeClass(duplicateTitle,"addColor");*/
        
        console.log('disable it'+component.get("v.disableAccountInputs"));
        //keep account inputs disable if an existing contact got found
        if(component.get("v.disableAccountInputs")){
            console.log('component.find("accountName").get("v.disabled")'+component.find("accountName").get("v.disabled"));
            console.log('component.find("addrLine1").get("v.disabled")'+component.find("addrLine1").get("v.disabled"));
            console.log('component.find("addrLine2").get("v.disabled")'+component.find("addrLine2").get("v.disabled"));
            if(component.get("v.accountNameVisible")){
                component.find("accountName").set("v.disabled",true);
            }
            if(component.get("v.addrLine1Visible")){
                component.find("addrLine1").set("v.disabled",true);
            }
            if(component.get("v.addrLine2Visible")){
                component.find("addrLine2").set("v.disabled",true);
            }
            if(component.get("v.countryListVisible")){
                component.find("countryList").set("v.disabled",true);
            }
            if(component.get("v.stateListVisible")){
                component.find("stateList").set("v.disabled",true);
            }
            if(component.get("v.cityAddVisible")){
                component.find("cityAdd").set("v.disabled",true);
            }
            if(component.get("v.zipCodeVisible")){
                component.find("zipCode").set("v.disabled",true);
            }
            if(component.get("v.webVisible")){
                component.find("web").set("v.disabled",true);
            }
			
        }
        component.set("v.showTables",false);
        var stepNumber = component.get("v.currentStep");
        console.log('stepNumber'+stepNumber);
        if(stepNumber == "step2"){
            component.set("v.currentStep",'step1');
        }
        $A.util.removeClass(component.find("cancelBtn"), "slds-hide");
        $A.util.removeClass(component.find("nextBtn"), "slds-hide");
        component.find("nextBtn").set('v.disabled',false);
        var prev = component.find("prevButn");
        $A.util.addClass(prev, "slds-hide");
        //var nextDuplicateInfoButton = component.find("nextDuplicateInfoBtn");
        //$A.util.addClass(nextDuplicateInfoButton, "slds-hide");
        
        var value  = component.find("childComp").getCimAccounts();
        console.log('value'+JSON.stringify(value));
        component.set("v.finalMapFromCIM",value);
        if(value != null){
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
            
            if(value.DuplicateRecords != null)
            {
                var v = value.DuplicateRecords;
                component.set("v.prevCimVal",JSON.stringify(v));
            }
            if(value.SelectedRow != null)
            {
                var selectedCimValue = value.SelectedRow ;
                component.set("v.prevSelectedCimVal",selectedCimValue);  
            }
            //alert('inside if to set value of dup status'+value.AccountDuplicateStatus);  
            if(value.AccountDuplicateStatus != null)
            {   //alert('inside if to set value of Account dup status');
                var dupStatus = value.AccountDuplicateStatus ;
                component.set("v.accountDuplicateStatus",dupStatus);
            }
            if(value.ContactDuplicateStatus != null)
            {   //alert('inside if to set value of Contact dup status');
                var contDupStatus = value.ContactDuplicateStatus ;
                component.set("v.contactDuplicateStatus",contDupStatus);
            }  
            
        }
        else if(value == null || value =='' || value.DuplicateRecords == null || value.DuplicateRecords == ''){
            //alert("else - no value found");
            var v = "No Duplicate Values Found";
            component.set("v.prevCimVal",v);
            //alert('VALUES2-->'+JSON.stringify(v));
        }        
        
    },
    
    buttonEvent : function(component,event,helper){
        var value = event.getParam("Button");
        var button = component.find('nextBtn');
        if(value == "show"){
            button.set('v.disabled',false);
            //$A.util.removeClass(component.find("nextBtn"), "slds-hide");
        }
        else{
            button.set('v.disabled',true);
            //$A.util.addClass(component.find("nextBtn"), "slds-hide");
        }
    },
    
    validateInputs : function(component,event,helper){
        console.log('duplicate Method');
        
        var emailId = component.find("emailId");
        //var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        var regExpEmailformat =$A.get("$Label.c.PRM_ContactEmail_Regex");
        ///^(([a-zA-Z0-9.\-_\\]{2,64})@([a-zA-Z0-9.\-_\\]{2,64}))$/;
        if((component.get("v.accName") != null && component.get("v.accName") != '') &&
           (component.get("v.orgTypeSelected") != null && component.get("v.orgTypeSelected") != '') &&
           (component.get("v.addressOne") != null && component.get("v.addressOne") != '') &&
           (component.get("v.countrySelected") != null && component.get("v.countrySelected") != '') &&
           (component.get("v.addressCity") != null && component.get("v.addressCity") != '') &&
           ((component.get("v.stateSelected") != null && component.get("v.stateSelected") != '') || (component.get("v.optionsState") != null && component.get("v.optionsState").length == 0)) &&
           (component.get("v.addressZip") != null && component.get("v.addressZip") != '') && (component.get("v.userWebsite")!= null && 
           component.get("v.userWebsite")!= '') && (component.get("v.conFirstName") != null && component.get("v.conFirstName") != '') &&
           (component.get("v.conEmail") != undefined && component.get("v.conEmail") != "" && emailId.get('v.value').match(regExpEmailformat)) &&
           (component.get("v.conLastName") != null && component.get("v.conLastName") != '' ) &&
           (component.get("v.contactCountrySelected") != null && component.get("v.contactCountrySelected") != '' ) &&
           (component.get("v.languageSelected") != null && component.get("v.languageSelected") != '')){
            
            component.set("v.showErrorMsg",false);
            
            // DE85395
            /*if(component.get("v.orgTypeCheck") != ''){
                var strAry = component.get("v.orgTypeCheck").split(";");
                console.log('VALUE OF STRING ARRAY : '+strAry);
                if(strAry.includes(component.get("v.orgTypeSelected")))
                {
                    component.set("v.showErrorMsg",true);
                    alert('This is an existing Partner Role');
                }
                
            }*/
        }
        
        else {
            //component.find("nextBtn").set("v.disabled",true);         
            component.set("v.showErrorMsg",true);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : "warning",
                "message": "Please fill in the required fields"
            });
            toastEvent.fire();
            
            
        }
    },
    partnerRoleChange : function(component,event,helper){
        //var selectedOptionValue = event.getParam("value");
        //component.set("v.roleSelected",selectedOptionValue);
        //console.log('')
        
    },
    
    orgTypeChange : function(component,event,helper){
        var selectedOptionValue = event.getParam("value");
        component.set("v.orgTypeSelected",selectedOptionValue);
        
        var roleType = component.get("v.partnerRoleTypeMap");
        var orgType = component.get("v.orgTypeSelected");
        if(roleType[orgType]){
            console.log('roleType'+roleType[orgType]);
            component.set("v.optionsRole",roleType[orgType]);
        }
        else{
            component.set("v.optionsRole","");
        }
        
    },
    
    prefLanguageChange : function(component,event,helper){
        var selectedOptionValue = event.getParam("value");
        component.set("v.languageSelected",selectedOptionValue);
    },
    
    confirmationPage: function(component,event,helper){
        component.set("v.showUI",false);
        component.set("v.showTables",false);
        component.set("v.showConfirmationPage",true);
        
        /*var secondLi = component.find("secondLI");
        console.log('secondLi'+secondLi);
        $A.util.removeClass(secondLi,'slds-path__item slds-is-current slds-is-active');
        $A.util.addClass(secondLi,'slds-path__item slds-is-won');
        
        var duplicateTitle = component.find("duplicateTitle");
        console.log('duplicateTitle'+duplicateTitle);
        $A.util.addClass(duplicateTitle,'addColor');
        
        var thirdLi = component.find("thirdLI");
        console.log('thirdLi'+thirdLi);
        $A.util.removeClass(thirdLi,'slds-path__item slds-is-incomplete');
        $A.util.addClass(thirdLi,'slds-path__item slds-is-current slds-is-active');*/
        
        
        var nextButton = component.find("nextBtn");
        $A.util.addClass(nextButton, "slds-hide");
        //var nextDuplicateInfoButton = component.find("nextDuplicateInfoBtn");
        //$A.util.addClass(nextDuplicateInfoButton, "slds-hide");
        //var prevConfirmationButton = component.find("prevConfirmationBtn");
        //$A.util.removeClass(prevConfirmationButton, "slds-hide");
        var submit = component.find("submit");
        $A.util.removeClass(submit, "slds-hide");
        
        var stepNumber = component.get("v.currentStep");
        console.log('stepNumber'+stepNumber);
        if(stepNumber == "step2"){
            component.set("v.currentStep",'step3');
        }
        
    },
    
    submit : function(component,event,helper){
        component.set("v.showConfirmationPage",false);
        component.set("v.showProgressBar",false);
        var prevButton = component.find("prevButn");
        $A.util.addClass(prevButton, "slds-hide");
        var submit = component.find("submit");
        $A.util.addClass(submit, "slds-hide");
        
        component.set("v.submissionSpinner",true);
        var action = component.get("c.submitAdminRequestForm");
        console.log('InputMap before submission-->   '+JSON.stringify(component.get("v.InputMap")));
        var paramMapForApex = component.get("v.InputMap") ;
        if(paramMapForApex.SelectedRow != null)
        {
            if(paramMapForApex.SelectedRow.length == 0)
            {
                paramMapForApex.SelectedRow = '';
            }else{
                paramMapForApex.SelectedRow = JSON.stringify(paramMapForApex.SelectedRow);    
            }  
        }
        
        if(paramMapForApex.accountAssociatedToExistingContact != null)
        {
            if(paramMapForApex.accountAssociatedToExistingContact.length == 0)
            {
                paramMapForApex.accountAssociatedToExistingContact = '';
            }else{
                paramMapForApex.accountAssociatedToExistingContact = JSON.stringify(paramMapForApex.accountAssociatedToExistingContact);    
            }  
        }
        
        if(paramMapForApex.duplicateContactRecord != null)
        {
            if(paramMapForApex.duplicateContactRecord.length == 0)
            {
                paramMapForApex.duplicateContactRecord = '';
            }else{
                paramMapForApex.duplicateContactRecord = JSON.stringify(paramMapForApex.duplicateContactRecord);    
            }  
        }
        
        if(paramMapForApex.associatedAccountIsIPA != null){
            paramMapForApex.associatedAccountIsIPA = JSON.stringify(paramMapForApex.associatedAccountIsIPA);
        }
        
        console.log('Map before passing in submit method apex'+JSON.stringify(paramMapForApex));
        action.setParams({
            registrationDetailsMap: paramMapForApex
        });
        
        action.setCallback(this, function(data) {
            var state= data.getState();
            if(component.isValid() && state === "SUCCESS") {
                
                var result = data.getReturnValue();
                console.log('result'+JSON.stringify(result));
                var Id = result.AccountId;
                console.log('Id'+Id);
                if(Id !=null && Id != ''){
                    //var spinner = component.find("submitSpinner");
                    //$A.util.addClass(spinner, "slds-hide");
                    component.set("v.submissionSpinner",false);
                    component.set("v.showProgressBar",true);
                    
                    /* var li = component.find("firstLI");
                    console.log('LI'+li);
                    $A.util.removeClass(li,'slds-path__item slds-is-current slds-is-active');
                    $A.util.addClass(li,'slds-path__item slds-is-won');
                    
                    var secondLi = component.find("secondLI");
                    console.log('secondLi'+secondLi);
                    $A.util.removeClass(secondLi,'slds-path__item slds-is-incomplete');
                    $A.util.addClass(secondLi,'slds-path__item slds-is-won');
                    
                    var duplicateTitle = component.find("duplicateTitle");
                    console.log('duplicateTitle'+duplicateTitle);
                    $A.util.addClass(duplicateTitle,'addColor');
                    
                    var thirdLi = component.find("thirdLI");
                    console.log('thirdLi'+thirdLi);
                    $A.util.removeClass(thirdLi,'slds-path__item slds-is-current slds-is-active');
                    $A.util.addClass(thirdLi,'slds-path__item slds-is-won');
                    
                    var confirmationTitle = component.find("confirmationTitle");
                    console.log('confirmationTitle'+confirmationTitle);
                    $A.util.addClass(confirmationTitle,'addColorToConfirmation');
                    
                    var fourthLi = component.find("fourthLI");
                    console.log('fourthLi'+fourthLi);
                    $A.util.removeClass(fourthLi,'slds-path__item slds-is-incomplete');
                    $A.util.addClass(fourthLi,'slds-path__item slds-is-won');
                    
                    var submissionTitle = component.find("submissionTitle");
                    $A.util.addClass(submissionTitle,'addColorToSubmission');*/
                    
                    component.set("v.showFinalPage",true);
                    component.set("v.accountId",Id);
                    var close = component.find("closeBtn");
                    $A.util.removeClass(close,"slds-hide");
                    
                    var stepNumber = component.get("v.currentStep");
                    console.log('stepNumber'+stepNumber);
                    if(stepNumber == "step3"){
                        component.set("v.currentStep",'step4');
                    }
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    navigationToAccountPage : function(component,event,helper){
        console.log('Account ID '+component.get("v.accountId"));
        var accId = component.get("v.accountId");
        if(accId != null && accId != ''){
            var navService = component.find("navigationService");
            var pageReference = {
                type: "standard__recordPage", 
                attributes: { 
                    "recordId": accId,
                    "objectApiName": "Account",
                    "actionName": "view",
                }
            }; 
            component.set("v.pageReference", pageReference); 
            var defaultUrl = "#";
            navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                component.set("v.url", url ? encodeURI(url) : defaultUrl);
            }), $A.getCallback(function(error) {
                component.set("v.url", defaultUrl);
            })); 
        }
    },
    
    //hide next button when we are modifying contact email Id
    updateEmailInput : function(component,event,helper){
        var emailId = component.find("emailId");
        var regExpEmailformat = $A.get("$Label.c.PRM_ContactEmail_Regex");
        ///^(([a-zA-Z0-9.\-_\\]{2,64})@([a-zA-Z0-9.\-_\\]{2,64}))$/;
        
        
        if(component.get("v.conEmail") != undefined && component.get("v.conEmail") != "" && emailId.get('v.value').match(regExpEmailformat)){
            component.find("nextBtn").set("v.disabled",true);
        }
        else{
            component.find("nextBtn").set("v.disabled",false);
        }
        
        
        
        /*var btnValidity = component.find("nextBtn").get("v.disabled");
			if(btnValidity == true){
			console.log('btnValidity'+btnValidity);
			component.find("nextBtn").set("v.disabled",false);
			}*/
        /*
        console.log('on change email');
        $A.util.addClass(component.find("nextBtn"), "slds-hide");
        console.log('on changed email'+event.getParam("value"));
        console.log('earlier email'+component.get("v.conEmailCompare"));
        if(event.getParam("value") == component.get("v.conEmailCompare")){
            
            $A.util.removeClass(component.find("nextBtn"), "slds-hide");   
        }*/
        
        
    },
    
    //gets invoked when email is invalid or if it a new contact email
    disableAccountInfo : function(component,event,helper){
        console.log('empty values');
        var validity = component.find("accountName").get("v.disabled");
        console.log('validity'+validity);
        if(validity == true){
            component.find("accountName").set("v.disabled",false);
            component.find("addrLine1").set("v.disabled",false);
            component.find("addrLine2").set("v.disabled",false);
            component.find("countryList").set("v.disabled",false);
            component.find("stateList").set("v.disabled",false);
            component.find("cityAdd").set("v.disabled",false);
            component.find("zipCode").set("v.disabled",false);
            component.find("web").set("v.disabled",false);
            component.set("v.optionsState","");
            component.set("v.accName","");
            component.set("v.addressOne","");
            component.set("v.addressTwo","");
            component.set("v.countrySelected","");
            component.set("v.addressCity","");
            component.set("v.addressZip","");
            component.set("v.stateSelected","");
            component.set("v.orgTypeCheck","");
            component.set("v.userWebsite","");
            component.set("v.disableAccountInputs",false);
        }
        /*var btnValidity = component.find("nextBtn").get("v.disabled");
		if(btnValidity == true){
			console.log('btnValidity'+btnValidity);
			component.find("nextBtn").set("v.disabled",false);
		}*/
        $A.util.removeClass(component.find("nextBtn"), "slds-hide");        
    },
    
    //gets invoked when tab moves away from contact email id
    getAccountDetails : function(component,event,helper){
        var emailId = component.find("emailId");
        //var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        var regExpEmailformat = $A.get("$Label.c.PRM_ContactEmail_Regex");
        ///^(([a-zA-Z0-9.\-_\\]{2,64})@([a-zA-Z0-9.\-_\\]{2,64}))$/;
        
        
        console.log('Email Value '+component.get("v.conEmail"));
        var btnValidity = component.find("nextBtn").get("v.disabled");
        if(btnValidity){
            console.log('btnValidity'+btnValidity);
            component.find("nextBtn").set("v.disabled",false);
        }
        
        if(component.get("v.conEmail") != undefined && component.get("v.conEmail") != "" && emailId.get('v.value').match(regExpEmailformat)){
            // to compare existing email with email changing in onchangeEvent
            component.set("v.conEmailCompare",component.get("v.conEmail"));
            component.set("v.validEmail",true);
            var action = component.get("c.fetchAccountDetails");
            
            action.setParams({
                emailId: component.get("v.conEmail")
            });
            
            action.setCallback(this, function(data) {
                var state= data.getState();
                if(component.isValid() && state === "SUCCESS") {
                    var result = data.getReturnValue();
                    console.log('result'+JSON.stringify(result));
                    
                    if(result == null){
                        helper.disableAccountInfo(component,event,helper);
                    }
                    else{
                        for(var p in result){
                            console.log('in');
                            var accResult = result[p];
                            console.log('p'+JSON.stringify(p));
                            console.log('result[p]'+JSON.stringify(result[p]));
                            component.find("accountName").set("v.disabled",true);
                            component.find("addrLine1").set("v.disabled",true);
                            component.find("addrLine2").set("v.disabled",true);
                            component.find("countryList").set("v.disabled",true);
                            component.find("stateList").set("v.disabled",true);
                            component.find("cityAdd").set("v.disabled",true);
                            component.find("zipCode").set("v.disabled",true);
                            component.find("web").set("v.disabled",true);
                            
                            if(accResult.Account.Name == undefined || accResult.Account.Name == ''){
                                accResult.Account.Name = '';
                                component.find("accountName").set("v.disabled",false);
                            }
                            if(accResult.Account.BillingCountryCode == undefined || accResult.Account.BillingCountryCode == ''){
                                accResult.Account.BillingCountryCode = '';
                                component.find("countryList").set("v.disabled",false);
                            }
                            if(accResult.Account.BillingStateCode == undefined || accResult.Account.BillingStateCode == ''){
                                accResult.Account.BillingStateCode = '';
                                component.find("stateList").set("v.disabled",false);
                            }
                            if(accResult.Account.BillingStreet == undefined || accResult.Account.BillingStreet == ''){
                                accResult.Account.BillingStreet = '';
                                component.find("addrLine1").set("v.disabled",false);
                            }
                            if(accResult.Account.BillingCity == undefined || accResult.Account.BillingCity == ''){
                                accResult.Account.BillingCity = '';
                                component.find("cityAdd").set("v.disabled",false);
                            }
                            if(accResult.Account.BillingPostalCode == undefined || accResult.Account.BillingPostalCode == ''){
                                accResult.Account.BillingPostalCode = '';
                                component.find("zipCode").set("v.disabled",false);
                            }
                            if(accResult.Account.Core_Account_Type__c == undefined || accResult.Account.Core_Account_Type__c == ''){
                                accResult.Account.Core_Account_Type__c = '';
                            }
                            if(accResult.Account.Core_User_Defined_Website__c == undefined || accResult.Account.Core_User_Defined_Website__c == ''){
                                accResult.Account.Core_User_Defined_Website__c = '';
                                component.find("web").set("v.disabled",false);
                            }
                            
                            
                            component.set("v.orgTypeCheck",accResult.Account.Core_Account_Type__c);
                            component.set("v.accName",accResult.Account.Name);
                            component.set("v.addressOne",accResult.Account.BillingStreet);
                            component.set("v.addressTwo","");
                            component.set("v.countrySelected",accResult.Account.BillingCountryCode);
                            var stateCountryInfo = component.get("v.stateCountryInfo");
                            let values = [];
                            for (var i=0; i<stateCountryInfo.length; i++){
                                if(stateCountryInfo[i].country.substr(stateCountryInfo[i].country.indexOf(';')+1,stateCountryInfo[i].country.length) == accResult.Account.BillingCountryCode){
                                    for(var j=0; j<stateCountryInfo[i].stateList.length; j++)
                                    {
                                        var state= stateCountryInfo[i].stateList[j];
                                        var s ={
                                            "label": state.substr(0, state.indexOf(';')) ,
                                            "value": state.substr(state.indexOf(';')+1,state.length)
                                        };            
                                        values.push(s);            
                                    }
                                }
                            }
                            component.set("v.optionsState",values);
                            component.set("v.addressCity",accResult.Account.BillingCity);
                            component.set("v.addressZip",accResult.Account.BillingPostalCode);
                            component.set("v.stateSelected",accResult.Account.BillingStateCode);
                            component.set("v.userWebsite",accResult.Account.Core_User_Defined_Website__c);
                            component.set("v.disableAccountInputs",true);
                            if(component.find("accountName").get("v.disabled")){
                                component.set("v.accountNameVisible",true);
                            }
                            if(component.find("addrLine1").get("v.disabled")){
                                component.set("v.addrLine1Visible",true);
                            }
                            if(component.find("addrLine2").get("v.disabled")){
                                component.set("v.addrLine2Visible",true);
                            }
                            if(component.find("countryList").get("v.disabled")){
                                component.set("v.countryListVisible",true);
                            }
                            if(component.find("stateList").get("v.disabled")){
                                component.set("v.stateListVisible",true);
                            }
                            if(component.find("cityAdd").get("v.disabled")){
                                component.set("v.cityAddVisible",true);
                            }
                            if(component.find("zipCode").get("v.disabled")){
                                component.set("v.zipCodeVisible",true);
                            }
                            if(component.find("web").get("v.disabled")){
                                component.set("v.webVisible",true);
                            }
                            
                            
                            $A.util.removeClass(component.find("nextBtn"), "slds-hide");
                            
                            
                            if(accResult.Account.Name != undefined && accResult.Account.Name != '' && 
                               accResult.Core_IPA_PartnerRole__c != undefined && accResult.Core_IPA_PartnerRole__c != ''){
                                alert('This contact is already part of the IPA Account - '+accResult.Account.Name+' for the '+accResult.Core_IPA_PartnerRole__c+' Role');
                                component.find("nextBtn").set("v.disabled",true);
                            }
                            else{
                                component.find("nextBtn").set("v.disabled",false);
                            }
                            
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
        else{
            component.find("nextBtn").set("v.disabled",true);
            helper.disableAccountInfo(component,event,helper);
        }
    }
    
})