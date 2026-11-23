({

    init: function (component, event, helper) {
        //Server call to retrieve the state and country picklist values :
        let action = component.get("c.getPicklistValues");
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                let data = response.getReturnValue();
                console.log("DATA" + JSON.stringify(data));

                let prefLanguage = data.prefLanguageMap;
                let partRoleTypeMap = data.roleTypeMapping;
                let orgType = data.bizOrgTypeMap;

                let optionLang1 = [];
                let optionLang2 = [];
                let finalLanguageList = [];
                let optionRole = [];
                let optionOrgType = [];
                for (let i in prefLanguage) {
                    let languages = {
                        label: prefLanguage[i],
                        value: i
                    }
                    if (prefLanguage[i] == "English") {
                        optionLang1.push(languages);
                    }
                    else {
                        optionLang2.push(languages);
                    }
                }

                console.log('optionLang1' + JSON.stringify(optionLang1));
                console.log('optionLang2' + JSON.stringify(optionLang2));
                finalLanguageList = optionLang1.concat(optionLang2);
                console.log('finalLanguageList' + JSON.stringify(finalLanguageList));


                for (let i in orgType) {
                    let bizOrgType = {
                        label: orgType[i],
                        value: i
                    }
                    optionOrgType.push(bizOrgType);
                }

                component.set("v.optionsLanguage", finalLanguageList);
                component.set("v.partnerRoleTypeMap", partRoleTypeMap);
                console.log('partRoleTypeMap' + JSON.stringify(component.get("v.partnerRoleTypeMap")));
                
                component.set("v.optionsType", optionOrgType);
                
                component.set("v.stateCountryInfo", data.stateCountryInfoList);
                let stateCountryList = data.stateCountryInfoList;
                let keys = [];
                for (let i = 0; i < stateCountryList.length; i++) {
                    let country = stateCountryList[i].country;
                    let c = {
                        "label": country.substr(0, country.indexOf(';')),
                        "value": country.substr(country.indexOf(';') + 1, country.length)
                    };
                    keys.push(c);
                }
                
                component.set('v.optionsCountry', keys);
                component.set("v.formSpinner", false);
                component.set("v.loadPage", true);
                component.find("accountName").set("v.disabled", true);
                component.find("addrLine1").set("v.disabled", true);
                component.find("addrLine2").set("v.disabled", true);
                component.find("countryList").set("v.disabled", true);
                component.find("stateList").set("v.disabled", true);
                component.find("cityAdd").set("v.disabled", true);
                component.find("zipCode").set("v.disabled", true);
                component.find("web").set("v.disabled", true);
            } else {
                console.error("Error calling action: " + response.getState());
            }

        });
        $A.enqueueAction(action);

        component.set("v.formSpinner", true);
        if (component.get("v.loadPage") == true) {
            component.set("v.formSpinner", false);

        }
        component.set("v.showUI", true);
        component.set("v.showProgressBar", true);
        component.set("v.btn", false);
        component.set("v.currentStep", 'step1');
        component.set("v.buttonSection", true);
        let prev = component.find("prevButn");
        $A.util.addClass(prev, "slds-hide");
        console.log('yes');
        
    },

    populateStateValues: function (component, event, helper) {

        const countries = component.get("v.optionsCountry");
        var selectedCountry = component.get("v.countrySelected");

        for (let i in countries) {
         
            console.log('countries[i] Label' + JSON.stringify(countries[i].label));
            console.log('countries[i] Value' + JSON.stringify(countries[i].value));
            if (countries[i].value == selectedCountry) {
                console.log('ITS A MATCH' + countries[i].label);
                component.set("v.countryLabel", countries[i].label);
               
                break;
            }
        }
        component.set("v.stateSelected", "");
        var selectedCountry = event.getParam("value");
        component.set("v.countrySelected", selectedCountry);
        
        let stateCountryInfo = component.get("v.stateCountryInfo");
        let values = [];
        for (let i = 0; i < stateCountryInfo.length; i++) {
            if (stateCountryInfo[i].country.substr(stateCountryInfo[i].country.indexOf(';') + 1, stateCountryInfo[i].country.length) == selectedCountry) {
                for (let j = 0; j < stateCountryInfo[i].stateList.length; j++) {
                    let state = stateCountryInfo[i].stateList[j];
                    const s = {
                        "label": state.substr(0, state.indexOf(';')),
                        "value": state.substr(state.indexOf(';') + 1, state.length)
                    };
                    values.push(s);
                }
            }
        }
        
        component.set("v.optionsState", values);
        var stateList = component.find("stateList");
        if (values == null || values.length == 0) {
            stateList.set('v.disabled', true);
            component.set("v.stateLabel", "");
        }
        else {
            stateList.set('v.disabled', false);
        }

    },

    getStateValues: function (component, event, helper) {
        var state = component.get("v.optionsState");
        var selectedState = component.get("v.stateSelected");

        for (let i in state) {
           
            console.log('state[i] Label' + JSON.stringify(state[i].label));
            console.log('state[i] Value' + JSON.stringify(state[i].value));
            if (state[i].value == selectedState) {
                console.log('ITS A MATCH' + state[i].label);
                component.set("v.stateLabel", state[i].label);
              
                break;
            }
        }

    },

    registerForm: function (component, event, helper) {
        component.set("v.formSpinner", true);
        if (component.get("v.loadPage") == true) {
            component.set("v.formSpinner", false);
        }
        component.set("v.showUI", true);
        component.set("v.showProgressBar", true);
        component.set("v.btn", false);
        component.set("v.currentStep", 'step1');
        component.set("v.buttonSection", true);
        var prev = component.find("prevButn");
        $A.util.addClass(prev, "slds-hide");
       

    },

    cancelEvent: function (component, event, helper) {
        let url = window.location.href;
        url = url.replace(url.substring(url.indexOf('lightning/') + 10), 'page/home');
        window.location.href = url;
        component.set("v.showUI", false);
        component.set("v.showProgressBar", false);
        component.set("v.btn", true);
        component.set("v.buttonSection", false);
        component.set("v.accId", "");
        component.set("v.accName", "");
        component.set("v.roleSelected", "");
        component.set("v.orgTypeSelected", "");
        component.set("v.addressOne", "");
        component.set("v.addressTwo", "");
        component.set("v.countrySelected", "");
        component.set("v.addressCity", "");
        component.set("v.stateSelected", "");
        component.set("v.addressZip", "");
        component.set("v.conFirstName", "");
        component.set("v.conEmail", "");
        component.set("v.conLastName", "");
        component.set("v.languageSelected", "");
        component.set("v.contactCountrySelected", "");
        component.set("v.userWebsite", "");

        var buttonClicked = event.getSource().getLocalId();
        console.log('buttonClicked' + buttonClicked);
        if (buttonClicked == "closeBtn") {
            component.set("v.showFinalPage", false);
        }
    },

    nextEvent: function (component, event, helper) {
        console.log('duplicate Method 3');
//blocked account:
if(component.get("v.accId")!=null && component.get("v.accId")!=undefined){
           
    let action4 = component.get("c.getBlockedAccountContact");
    action4.setParams({
        emailId: component.get("v.conEmail"), accId:component.get("v.accId")

    });

    ///blocked cont:
action4.setCallback(this, function (data) {
var state = data.getState();
if (component.isValid() && state === "SUCCESS") {
let result = data.getReturnValue();
console.log('result' + JSON.stringify(result));

if (result != null) {
   
   if(result==true){
    component.set("v.showUI", true);
    component.set("v.showTables", false);
        var stepNumber = component.get("v.currentStep");
        console.log('stepNumber' + stepNumber);
        if (stepNumber == "step2") {
            component.set("v.currentStep", 'step1');
        }
   component.set("v.blockedContact",result);
   // component.set("v.showUI", true);
    component.set("v.showBlockedContact", true);
    component.set("v.associatedAccountIsIPA",false);
    let toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "type": "error",
        "mode": "sticky",
        "message": $A.get("$Label.c.PRM_BlockedAccountError")
    });
    toastEvent.fire();
    component.find("nextBtn").set("v.disabled", true);
   }
}

}
});
    $A.enqueueAction(action4);
}
if(component.get("v.showBlockedContact")==false){
    console.log('showBlockedContact' + component.get("v.showBlockedContact"));
        component.set("v.showUI", false);
        component.set("v.showProgressBar", false);
        component.set("v.showTables", true);
        console.log('Table' + component.get("v.showTables"));
        let stepNumber = component.get("v.currentStep");
        console.log('stepNumber' + stepNumber);
        if (stepNumber == "step1") {
            component.set("v.currentStep", 'step2');
        }
        $A.util.addClass(component.find("cancelBtn"), "slds-hide");
        $A.util.addClass(component.find("nextBtn"), "slds-hide");
        console.log('accid for blocked'+component.get("v.accId"));
}  
        
    },

    duplicateInfoPage: function (component, event, helper) {
        component.set("v.showConfirmationPage", false);
        $A.util.addClass(component.find("nextBtn"), "slds-hide");
        $A.util.addClass(component.find("prevButn"), "slds-hide");
        $A.util.addClass(component.find("closeBtn"), "slds-hide");
        component.set("v.showTables", true);


        component.set("v.showProgressBar", false);
        let stepNumber = component.get("v.currentStep");
        console.log('stepNumber' + stepNumber);
        if (stepNumber == "step3") {
            component.set("v.currentStep", 'step2');
        }

        let submit = component.find("submit");
        $A.util.addClass(submit, "slds-hide");
    },

    prevEvent: function (component, event, helper) {
        component.set("v.showUI", true);
       

        console.log('disable it' + component.get("v.disableAccountInputs"));
        //keep account inputs disable if an existing contact got found
        if (component.get("v.disableAccountInputs")) {
            console.log('component.find("accountName").get("v.disabled")' + component.find("accountName").get("v.disabled"));
            console.log('component.find("addrLine1").get("v.disabled")' + component.find("addrLine1").get("v.disabled"));
            console.log('component.find("addrLine2").get("v.disabled")' + component.find("addrLine2").get("v.disabled"));

            
            if (component.get("v.accountNameVisible")) {
                component.find("accountName").set("v.disabled", true);
            }
            if (component.get("v.addrLine1Visible")) {
                component.find("addrLine1").set("v.disabled", true);
            }
            if (component.get("v.addrLine2Visible")) {
                component.find("addrLine2").set("v.disabled", true);
            }
            if (component.get("v.countryListVisible")) {
                component.find("countryList").set("v.disabled", true);
            }
            if (component.get("v.stateListVisible")) {
                component.find("stateList").set("v.disabled", true);
            }
            if (component.get("v.cityAddVisible")) {
                component.find("cityAdd").set("v.disabled", true);
            }
            if (component.get("v.zipCodeVisible")) {
                component.find("zipCode").set("v.disabled", true);
            }
            if (component.get("v.webVisible")) {
                component.find("web").set("v.disabled", true);
            }
            //added as part of INC10931061 by Yogesh
            if (component.get("v.optionsType")){
                  component.find("bizOrgType").set("v.disabled", true);
              }
            

        }
        component.set("v.showTables", false);
        var stepNumber = component.get("v.currentStep");
        console.log('stepNumber' + stepNumber);
        if (stepNumber == "step2") {
            component.set("v.currentStep", 'step1');
        }
        $A.util.removeClass(component.find("cancelBtn"), "slds-hide");
        $A.util.removeClass(component.find("nextBtn"), "slds-hide");
        component.find("nextBtn").set('v.disabled', false);
        var prev = component.find("prevButn");
        $A.util.addClass(prev, "slds-hide");
       

        let value = component.find("childComp").getCimAccounts();
        console.log('value' + JSON.stringify(value));
        component.set("v.finalMapFromCIM", value);
        if (value != null) {
            component.set("v.accountAssociatedToExistingContact", null);
            if (value.accountAssociatedToExistingContact != null) {
                component.set("v.accountAssociatedToExistingContact", value.accountAssociatedToExistingContact);
            }

            if (value.associatedAccountIsIPA != null) {
                component.set("v.associatedAccountIsIPA", value.associatedAccountIsIPA);
            }

            component.set("v.duplicateContactRecord", null);
            if (value.duplicateContactRecord != null) {
                component.set("v.duplicateContactRecord", value.duplicateContactRecord);
            }

            if (value.DuplicateRecords != null) {
                let v = value.DuplicateRecords;
                component.set("v.prevCimVal", JSON.stringify(v));
            }
            if (value.SelectedRow != null) {
                let selectedCimValue = value.SelectedRow;
                component.set("v.prevSelectedCimVal", selectedCimValue);
            }
            if (value.AccountDuplicateStatus != null) {   
                let dupStatus = value.AccountDuplicateStatus;
                component.set("v.accountDuplicateStatus", dupStatus);
            }
            if (value.ContactDuplicateStatus != null) {   
                const contDupStatus = value.ContactDuplicateStatus;
                component.set("v.contactDuplicateStatus", contDupStatus);
            }
            if (value.accountDupStatusMap != null && value.accountDupStatusMap != undefined ) {   
                let accountDupStatusMapObj = value.accountDupStatusMap;
                component.set("v.accountDupStatusMapOnUI", accountDupStatusMapObj);
                console.log('Setting accountDupStatusMapOnUI in Admin helper'+JSON.stringify(accountDupStatusMapObj));
            }
            
        }
        else if (value == null || value == '' || value.DuplicateRecords == null || value.DuplicateRecords == '') {
           
            let v = "No Duplicate Values Found";
            component.set("v.prevCimVal", v);
            
        }

    },

    buttonEvent: function (component, event, helper) {
        let value = event.getParam("Button");
        let button = component.find('nextBtn');
        if (value == "show") {
            button.set('v.disabled', false);
            
        }
        else {
            button.set('v.disabled', true);
          
        }
    },

    validateInputs: function (component, event, helper) {
        console.log('duplicate Method');

        let emailId = component.find("emailId");
        let regExpEmailformat = $A.get("$Label.c.PRM_ContactEmail_Regex");
    //    //blockedContact
    //    // let blockedContact=component.get("c.getBlockedContact")
    //    let action = component.get("c.getBlockedContact");

            
    //    action.setParams({
    //        emailId: component.get("v.emailId")
    //    });

       
       
    //    action.setCallback(this, function (data) {
    //        var state = data.getState();
    //        if (component.isValid() && state === "SUCCESS") {
    //            let result = data.getReturnValue();
    //            console.log('result' + JSON.stringify(result));

    //            if (result != null) {
    //               component.set("v.blockedContact",result);
    //               if(component.get("v.blockedContact") != true){
                    
    //                component.set("v.showBlockedContact", true);
    //                let toastEvent = $A.get("e.force:showToast");
    //                toastEvent.setParams({
    //                    "type": "warning",
    //                    "message": "Above contact is blocked"
    //                });
    //                toastEvent.fire();
    //                component.find("nextBtn").set("v.disabled", true);
    //               }
    //            }
    //        }
    //    });
    //    $A.enqueueAction(action);

        
        if ((component.get("v.accName") != null && component.get("v.accName") != '') &&
            (component.get("v.orgTypeSelected") != null && component.get("v.orgTypeSelected") != '') &&
            (component.get("v.addressOne") != null && component.get("v.addressOne") != '') &&
            (component.get("v.countrySelected") != null && component.get("v.countrySelected") != '') &&
            (component.get("v.addressCity") != null && component.get("v.addressCity") != '') &&
            ((component.get("v.stateSelected") != null && component.get("v.stateSelected") != '') || (component.get("v.optionsState") != null && component.get("v.optionsState").length == 0)) &&
            (component.get("v.addressZip") != null && component.get("v.addressZip") != '') &&
            (component.get("v.userWebsite") != null && component.get("v.userWebsite") != '') &&
            (component.get("v.conFirstName") != null && component.get("v.conFirstName") != '') &&
            (component.get("v.conEmail") != undefined && component.get("v.conEmail") != "" && emailId.get('v.value').match(regExpEmailformat)) &&
            (component.get("v.conLastName") != null && component.get("v.conLastName") != '') &&
            (component.get("v.contactCountrySelected") != null && component.get("v.contactCountrySelected") != '') &&
            (component.get("v.languageSelected") != null && component.get("v.languageSelected") != '')) {

            component.set("v.showErrorMsg", false);

        }

        else {
            component.set("v.showErrorMsg", true);
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "warning",
                "message": "Please fill in the required fields"
            });
            toastEvent.fire();

        }
    },
    partnerRoleChange: function (component, event, helper) {
        

    },

    orgTypeChange: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        component.set("v.orgTypeSelected", selectedOptionValue);

        var roleType = component.get("v.partnerRoleTypeMap");
        var orgType = component.get("v.orgTypeSelected");
        if (roleType[orgType]) {
            console.log('roleType' + roleType[orgType]);
            component.set("v.optionsRole", roleType[orgType]);
        }
        else {
            component.set("v.optionsRole", "");
        }

    },

    prefLanguageChange: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        component.set("v.languageSelected", selectedOptionValue);
    },

    // To show soft warning message for Emborgoed Countries 
 countryChangeMessage : function(component, event, helper){
        let embarHelpLink = $A.get("$Label.c.PRM_Embargoed_Help_Link").toString();
        let embarErroMsg = $A.get("$Label.c.PRM_Embargoed_Alert_MSG").toString();
            component.set("v.showErrorMsg", true);
            let emborMsglink = embarHelpLink;
            let emborMsg = embarErroMsg;
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                type: "warning",
                message: emborMsg,
                messageTemplate: '{0} please visit {1}',
                messageTemplateData: [
                    emborMsg,
                    {
                        url: emborMsglink, 
                        label: emborMsglink,
                    }
                ]
            });
            toastEvent.fire();
},

     // Restrict embargoed countries - US860528 / US860527
      prefhandleCountry: function (component, event, helper) {
        let selectedaccItem = component.find("countryList").get("v.value");
        let selectedconItem = component.find("contCntry").get("v.value");
        let embarCountryString = $A.get("$Label.c.PRM_Embargoed_country").toString();
        let embarCountryList = embarCountryString.split(",");
        let nonembarCountryString = $A.get("$Label.c.PRM_NonEmbargoed_Country").toString();
        let nonembarCountryList = nonembarCountryString.split(",");
        console.log('embarCountryList>' + embarCountryList);
        if ((embarCountryList.includes(selectedaccItem) && nonembarCountryList.includes(selectedconItem)) || (embarCountryList.includes(selectedaccItem))  || (embarCountryList.includes(selectedconItem))) {
            component.find("nextBtn").set("v.disabled", true);
            helper.countryChangeMessage(component, event, helper);
            component.set("v.restrictEmbargoedCountry", true);
    
        } else {
            component.find("nextBtn").set("v.disabled", false);
            component.set("v.restrictEmbargoedCountry", false);
        }
        if(component.get("v.showBlockedContact")==true){
            component.find("nextBtn").set("v.disabled", true);
        }
    },

    confirmationPage: function (component, event, helper) {
        component.set("v.showUI", false);
        component.set("v.showTables", false);
        component.set("v.showConfirmationPage", true);

        

        let nextButton = component.find("nextBtn");
        $A.util.addClass(nextButton, "slds-hide");
        
        let submit = component.find("submit");
        $A.util.removeClass(submit, "slds-hide");

        let stepNumber = component.get("v.currentStep");
        console.log('stepNumber-Confirmation' + stepNumber);
        if (stepNumber == "step2") {
            component.set("v.currentStep", 'step3');
        }

    },

    goToSBRMsgPage: function (component, event, helper){
        // show toast msg when admin tries to create new account 
        var toastEvent = $A.get("e.force:showToast");

        toastEvent.setParams({
            "type": "error",
            "mode": "sticky",
            "message": "Required message",
            "messageTemplate":"New account creation is restricted through {0} registration. You can either reuse an account from the same page or initiate creating a new account using the SBR process. To Create New Account {1}",
            "messageTemplateData":["Admin",{
                url: "/lightning/n/New_Account_SBR",
                label:"click here"
            }]
        });
        toastEvent.fire();
    },

    submit: function (component, event, helper) {
        component.set("v.showConfirmationPage", false);
        component.set("v.showProgressBar", false);
        var prevButton = component.find("prevButn");
        $A.util.addClass(prevButton, "slds-hide");
        var submit = component.find("submit");
        $A.util.addClass(submit, "slds-hide");

        component.set("v.submissionSpinner", true);
        var action = component.get("c.submitAdminRequestForm");
        console.log('InputMap before submission-->   ' + JSON.stringify(component.get("v.InputMap")));
        console.log('Account Id before submission-->   ' + JSON.stringify(component.get('v.accId')));
        var paramMapForApex = component.get("v.InputMap");
        
        if (component.get('v.accId') != null && component.get('v.accId') != '' && component.get('v.accId') != undefined) {
            paramMapForApex.AccountID = component.get('v.accId');
            console.log('paramMapForApex.accId:' + paramMapForApex.AccountID);
        }
        if (paramMapForApex.SelectedRow != null) {
            if (paramMapForApex.SelectedRow.length == 0) {
                paramMapForApex.SelectedRow = '';
            } else {
                paramMapForApex.SelectedRow = JSON.stringify(paramMapForApex.SelectedRow);
            }
        }

        if (paramMapForApex.accountAssociatedToExistingContact != null) {
            if (paramMapForApex.accountAssociatedToExistingContact.length == 0) {
                paramMapForApex.accountAssociatedToExistingContact = '';
            } else {
                paramMapForApex.accountAssociatedToExistingContact = JSON.stringify(paramMapForApex.accountAssociatedToExistingContact);
            }
        }

        if (paramMapForApex.duplicateContactRecord != null) {
            if (paramMapForApex.duplicateContactRecord.length == 0) {
                paramMapForApex.duplicateContactRecord = '';
            } else {
                paramMapForApex.duplicateContactRecord = JSON.stringify(paramMapForApex.duplicateContactRecord);
            }
        }

        if (paramMapForApex.associatedAccountIsIPA != null) {
            paramMapForApex.associatedAccountIsIPA = JSON.stringify(paramMapForApex.associatedAccountIsIPA);
        }
        
        console.log('Map before passing in submit method apex' + JSON.stringify(paramMapForApex));
        action.setParams({
            registrationDetailsMap: paramMapForApex
        });

        action.setCallback(this, function (data) {
            let state = data.getState();
            if (component.isValid() && state === "SUCCESS") {

                let result = data.getReturnValue();
                console.log('result' + JSON.stringify(result));
                let Id = result.AccountId;
                console.log('Id' + Id);
                if (Id != null && Id != '') {
                    
                    component.set("v.submissionSpinner", false);
                    component.set("v.showProgressBar", true);

                   

                    component.set("v.showFinalPage", true);
                    component.set("v.accountId", Id);
                    let close = component.find("closeBtn");
                    $A.util.removeClass(close, "slds-hide");

                    let stepNumber = component.get("v.currentStep");
                    console.log('stepNumber' + stepNumber);
                    if (stepNumber == "step3") {
                        component.set("v.currentStep", 'step4');
                    }
                }
            }

        });
        $A.enqueueAction(action);
    },
    navigationToAccountPage: function (component, event, helper) {
        console.log('Account ID ' + component.get("v.accountId"));
        var accId = component.get("v.accountId");
        if (accId != null && accId != '') {
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
            let defaultUrl = "#";
            navService.generateUrl(pageReference)
                .then($A.getCallback(function (url) {
                    component.set("v.url", url ? encodeURI(url) : defaultUrl);
                }), $A.getCallback(function (error) {
                    component.set("v.url", defaultUrl);
                }));
        }
    },

    //hide next button when we are modifying contact email Id
    updateEmailInput: function (component, event, helper) {
        let emailId = component.find("emailId");
        let regExpEmailformat = $A.get("$Label.c.PRM_ContactEmail_Regex");
               if (component.get("v.conEmail") != undefined && component.get("v.conEmail") != "" && emailId.get('v.value').match(regExpEmailformat)) {
            component.find("nextBtn").set("v.disabled", true);
        }
        else {
           
            if (component.get("v.restrictEmbargoedCountry") == true) {
                component.find("nextBtn").set("v.disabled", true);
            } else {
                component.find("nextBtn").set("v.disabled", false);
            }
        }

        

    },

    //gets invoked when email is invalid or if it a new contact email
    disableAccountInfo: function (component, event, helper) {
        console.log('empty values');
        let validity = component.find("accountName").get("v.disabled");
        console.log('validity' + validity);
        if (validity == true) {
            //component.find("accountID").set("v.disabled", false);
            component.find("accountName").set("v.disabled", false);
            component.find("addrLine1").set("v.disabled", false);
            component.find("addrLine2").set("v.disabled", false);
            component.find("countryList").set("v.disabled", false);
            component.find("stateList").set("v.disabled", false);
            component.find("cityAdd").set("v.disabled", false);
            component.find("zipCode").set("v.disabled", false);
            component.find("web").set("v.disabled", false);
            component.set("v.optionsState", "");
            component.set("v.accId", "");
            component.set("v.accName", "");
            component.set("v.addressOne", "");
            component.set("v.addressTwo", "");
            component.set("v.countrySelected", "");
            component.set("v.addressCity", "");
            component.set("v.addressZip", "");
            component.set("v.stateSelected", "");
            component.set("v.orgTypeCheck", "");
            component.set("v.userWebsite", "");
            component.set("v.disableAccountInputs", false);
            component.find("bizOrgType").set("v.disabled", false);
            component.find("contCntry").set("v.disabled", false);
        }
      
        $A.util.removeClass(component.find("nextBtn"), "slds-hide");
    },

    //gets invoked when tab moves away from contact email id
    getAccountDetails: function (component, event, helper) {
        let emailId = component.find("emailId");
        let regExpEmailformat = $A.get("$Label.c.PRM_ContactEmail_Regex");

        console.log('Email Value ' + component.get("v.conEmail"));
        let btnValidity = component.find("nextBtn").get("v.disabled");
        if (btnValidity) {
            console.log('btnValidity' + btnValidity);
            //Check added for restricting next button visibility for  embargoed countries -Restrict embargoed countries - US860528 / US860527
            if (component.get("v.restrictEmbargoedCountry") == false) {
                component.find("nextBtn").set("v.disabled", false);
            }
        }
        let action1 = component.get("c.fetchPendingSelfRegRequests");
        action1.setParams({
            emailId: component.get("v.conEmail")
        });
        
        let action2 = component.get("c.systemAccountDetails");
        action2.setParams({
            emailId: component.get("v.conEmail")
        });
        let action3 = component.get("c.fetchPendingACM");  
        action3.setParams({
            emailId: component.get("v.conEmail")
        });
        //blockedContact
        let action4 = component.get("c.getBlockedAccountContact");
        action4.setParams({
            emailId: component.get("v.conEmail"), accId:component.get("v.accId")

        });
        
      
        if (component.get("v.conEmail") != undefined && component.get("v.conEmail") != "" && emailId.get('v.value').match(regExpEmailformat)) {
            // to compare existing email with email changing in onchangeEvent
            component.set("v.conEmailCompare", component.get("v.conEmail"));
            component.set("v.validEmail", true);


            let action = component.get("c.fetchAccountDetails");

            
            action.setParams({
                emailId: component.get("v.conEmail")
            });

            
            
            action.setCallback(this, function (data) {
                var state = data.getState();
                if (component.isValid() && state === "SUCCESS") {
                    let result = data.getReturnValue();
                    console.log('result' + JSON.stringify(result));

                    if (result == null) {
                        helper.disableAccountInfo(component, event, helper);
                    }
                    else {
                        for (let p in result) {
                            console.log('in');
                            let accResult = result[p];
                            console.log('p' + JSON.stringify(p));
                            console.log('result[p]' + JSON.stringify(result[p]));
                            component.find("accountName").set("v.disabled", true);
                            console.log('1' + JSON.stringify(p));
                            component.find("addrLine1").set("v.disabled", true);
                            console.log('2' + JSON.stringify(p));
                            component.find("addrLine2").set("v.disabled", true);
                            console.log('3' + JSON.stringify(p));
                            component.find("countryList").set("v.disabled", true);
                            component.find("stateList").set("v.disabled", true);
                            component.find("cityAdd").set("v.disabled", true);
                            component.find("zipCode").set("v.disabled", true);
                            component.find("web").set("v.disabled", true);
                            component.find("bizOrgType").set("v.disabled", true);
                            
                            

                            console.log('p1' + JSON.stringify(p));

                            if (accResult.Account.Name == undefined || accResult.Account.Name == '') {
                                accResult.Account.Name = '';
                                component.find("accountName").set("v.disabled", false);
                            }
                            if (accResult.Account.BillingCountryCode == undefined || accResult.Account.BillingCountryCode == '') {
                                accResult.Account.BillingCountryCode = '';
                                component.find("countryList").set("v.disabled", false);
                            }
                            if (accResult.Account.BillingStateCode == undefined || accResult.Account.BillingStateCode == '') {
                                accResult.Account.BillingStateCode = '';
                                component.find("stateList").set("v.disabled", false);
                            }
                            if (accResult.Account.BillingStreet == undefined || accResult.Account.BillingStreet == '') {
                                accResult.Account.BillingStreet = '';
                                component.find("addrLine1").set("v.disabled", false);
                            }
                            if (accResult.Account.BillingCity == undefined || accResult.Account.BillingCity == '') {
                                accResult.Account.BillingCity = '';
                                component.find("cityAdd").set("v.disabled", false);
                            }
                            if (accResult.Account.BillingPostalCode == undefined || accResult.Account.BillingPostalCode == '') {
                                accResult.Account.BillingPostalCode = '';
                                component.find("zipCode").set("v.disabled", false);
                            }
                           
                           
                            if (accResult.Account.Core_User_Defined_Website__c == undefined || accResult.Account.Core_User_Defined_Website__c == '') {
                                accResult.Account.Core_User_Defined_Website__c = '';
                                component.find("web").set("v.disabled", false);
                            }

                            console.log('p2' + JSON.stringify(p));

               
                            
                            if(accResult.Account.Core_Account_Type__c!='' && accResult.Account.Core_Account_Type__c!=undefined && accResult.Account.Core_Account_Type__c!=null){
                            component.set("v.orgTypeCheck", accResult.Account.Core_Account_Type__c);
                            }

                            console.log('p3' + JSON.stringify(p));

                            console.log('Country--->'+accResult.Account.BillingCountryCode);
                            

                            component.set("v.accId", accResult.AccountId);
                            component.set("v.accName", accResult.Account.Name);
                            component.set("v.addressOne", accResult.Account.BillingStreet);
                            component.set("v.addressTwo", "");
                            component.set("v.countrySelected", accResult.Account.BillingCountryCode);
                           let roleType = component.get("v.partnerRoleTypeMap");                           
                            
                           let optionsRole = '';
                             if(accResult.Account.Core_Account_Type__c!='' && accResult.Account.Core_Account_Type__c!=undefined && accResult.Account.Core_Account_Type__c!=null){
                            if(accResult.Account.Core_Account_Type__c.toString().includes(';')){
                                
                                let strAry = accResult.Account.Core_Account_Type__c.split(";");                                 
                                
                                strAry.forEach(orgType => {
                                    if(optionsRole == ''){
                                        optionsRole =   roleType[orgType];  
                                    }else{
                                        optionsRole = optionsRole + ';' + roleType[orgType];
                                    }    
                                });
                            }else{
                                optionsRole = roleType[accResult.Account.Core_Account_Type__c];    
                            }                            
                            component.set("v.optionsRole", optionsRole);
                             }
                            var stateCountryInfo = component.get("v.stateCountryInfo");
                            let values = [];
                            for (let i = 0; i < stateCountryInfo.length; i++) {
                                if (stateCountryInfo[i].country.substr(stateCountryInfo[i].country.indexOf(';') + 1, stateCountryInfo[i].country.length) == accResult.Account.BillingCountryCode) {
                                    for (let j = 0; j < stateCountryInfo[i].stateList.length; j++) {
                                        var state = stateCountryInfo[i].stateList[j];
                                        let s = {
                                            "label": state.substr(0, state.indexOf(';')),
                                            "value": state.substr(state.indexOf(';') + 1, state.length)
                                        };
                                        values.push(s);
                                    }
                                }
                            }
                            component.set("v.optionsState", values);
                            component.set("v.addressCity", accResult.Account.BillingCity);
                            component.set("v.addressZip", accResult.Account.BillingPostalCode);
                            component.set("v.stateSelected", accResult.Account.BillingStateCode);
                            component.set("v.userWebsite", accResult.Account.Core_User_Defined_Website__c);
                            component.set("v.disableAccountInputs", true);
                           
                            if (component.find("accountName").get("v.disabled")) {
                                component.set("v.accountNameVisible", true);
                            }
                            if (component.find("addrLine1").get("v.disabled")) {
                                component.set("v.addrLine1Visible", true);
                            }
                            if (component.find("addrLine2").get("v.disabled")) {
                                component.set("v.addrLine2Visible", true);
                            }
                            if (component.find("countryList").get("v.disabled")) {
                                component.set("v.countryListVisible", true);
                            }
                            if (component.find("stateList").get("v.disabled")) {
                                component.set("v.stateListVisible", true);
                            }
                            if (component.find("cityAdd").get("v.disabled")) {
                                component.set("v.cityAddVisible", true);
                            }
                            if (component.find("zipCode").get("v.disabled")) {
                                component.set("v.zipCodeVisible", true);
                            }
                            if (component.find("web").get("v.disabled")) {
                                component.set("v.webVisible", true);
                            }

                            
                            $A.util.removeClass(component.find("nextBtn"), "slds-hide");

                            if (accResult.Account.Name != undefined && accResult.Account.Name != '' &&
                                accResult.Core_IPA_PartnerRole__c != undefined && accResult.Core_IPA_PartnerRole__c != '') {
                                alert('This contact is already part of the IPA Account - ' + accResult.Account.Name + ' for the ' + accResult.Core_IPA_PartnerRole__c + ' Role');
                                component.find("nextBtn").set("v.disabled", true);
                            }
                            else {
                                component.find("nextBtn").set("v.disabled", false);
                            }

                        }
                    }
                }
            });
            $A.enqueueAction(action);
            
            action1.setCallback(this, function (data) {
                let state = data.getState();
                if (state === "SUCCESS") {
                    let reReqresult = data.getReturnValue();
                    console.log('reReqresult' + JSON.stringify(reReqresult));
                    
                    if (reReqresult == null) {
                        //helper.disableAccountInfo(component, event, helper);
                    }else{
                        
                      
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "mode": "sticky",
                            "message": "There is a pending Registration Request for this contact"
                        });
                        toastEvent.fire();
                        component.find("nextBtn").set("v.disabled", true);
                        component.find("contCntry").set("v.disabled", true);
                        component.find("accountName").set("v.disabled", true);
                        component.find("addrLine1").set("v.disabled", true);
                        component.find("addrLine2").set("v.disabled", true);
                        component.find("countryList").set("v.disabled", true);
                        component.find("stateList").set("v.disabled", true);
                        component.find("cityAdd").set("v.disabled", true);
                        component.find("zipCode").set("v.disabled", true);
                        component.find("web").set("v.disabled", true);
                        component.find("bizOrgType").set("v.disabled", true);
                        
                    }
                    
                }
                
                
            });
            $A.enqueueAction(action1); 
            
            
            action2.setCallback(this, function (data) {
                let state = data.getState();
                if (state === "SUCCESS") {
                    const returnvale = data.getReturnValue();
                    console.log('returnvale-->' +JSON.stringify(returnvale));
                    
                    if (returnvale == true) {
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "mode": "sticky",
                            "message": $A.get("$Label.c.PRM_ACR_SystemAccError")
                            
                        });
                        toastEvent.fire();
                        
                        component.find("nextBtn").set("v.disabled", true);
                        component.find("contCntry").set("v.disabled", true);
                        component.find("accountName").set("v.disabled", true);
                        component.find("addrLine1").set("v.disabled", true);
                        component.find("addrLine2").set("v.disabled", true);
                        component.find("countryList").set("v.disabled", true);
                        component.find("stateList").set("v.disabled", true);
                        component.find("cityAdd").set("v.disabled", true);
                        component.find("zipCode").set("v.disabled", true);
                        component.find("web").set("v.disabled", true);
                        component.find("bizOrgType").set("v.disabled", true);
                    }else{
                        //helper.disableAccountInfo(component, event, helper);
                    }
                }
                
            });
            $A.enqueueAction(action2);
            //Added as a part of INC10931061 Biz Org Type issue
            action3.setCallback(this, function (data) {
                let state = data.getState();
                if (state === "SUCCESS") {
                    const returnvale = data.getReturnValue();
                    console.log('returnvale-->' +JSON.stringify(returnvale));
                    if (returnvale != 'inactive') {
                        console.log('inside returnvale');
                        component.set("v.orgTypeSelected", returnvale);
                        var roleType = component.get("v.partnerRoleTypeMap");                           
                        var optionsRole = '';
                        if(returnvale!='' && returnvale!=undefined && returnvale!=null){
                            if(returnvale.toString().includes(';')){
                                
                                let strAry = returnvale.split(";");                                 
                                strAry.forEach(orgType => {
                                    if(optionsRole == ''){
                                        optionsRole =   roleType[orgType];  
                                    }else{
                                        optionsRole = optionsRole + ';' + roleType[orgType];
                                    }    
                                });
                            }else{
                                optionsRole = roleType[returnvale];    
                            }                            
                            component.set("v.optionsRole", optionsRole);
                        }
                        component.find("bizOrgType").set("v.disabled", true);
                    }else{
                        component.find("bizOrgType").set("v.disabled", false);
                    }
                }                
                });
            $A.enqueueAction(action3);

///blocked cont:
action4.setCallback(this, function (data) {
    var state = data.getState();
    if (component.isValid() && state === "SUCCESS") {
        let result = data.getReturnValue();
        console.log('result' + JSON.stringify(result));

        if (result != null) {
           component.set("v.blockedContact",result);
           if(result==true){
             
            component.set("v.showBlockedContact", true);
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "mode": "sticky",
                "message": $A.get("$Label.c.PRM_BlockedContError_IPA").toString()
            });
            toastEvent.fire();
            component.find("nextBtn").set("v.disabled", true);
           }
        }
    }
});
$A.enqueueAction(action4);
}
        

       
        else {
            component.find("nextBtn").set("v.disabled", true);
            helper.disableAccountInfo(component, event, helper);
        }
        
    },

   
    prefhandleSuppressEmail: function (component, event, helper) {        
        let suppressEmailValue = component.find('checkbox1').get('v.checked');        
        if(suppressEmailValue){
            component.set("v.suppressEmail", true);
        }else{
            component.set("v.suppressEmail", false);
        }     
        console.log('Value -->'+suppressEmailValue);
    },
    
    
    
})