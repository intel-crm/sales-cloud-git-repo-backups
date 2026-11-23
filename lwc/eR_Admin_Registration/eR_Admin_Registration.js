import { LightningElement, track } from 'lwc';
import fetchStateCountryValues from '@salesforce/apex/PRM_AdminRegistration.fetchStateCountryValues';
import fetchAccountDetails from '@salesforce/apex/PRM_AdminRegistration.fetchAccountDetails';
import getPicklistValues from '@salesforce/apex/PRM_AdminRegistration.getPicklistValues';
import systemAccountDetails from '@salesforce/apex/PRM_AdminRegistration.systemAccountDetails';

import REGISTRATION_OBJECT from '@salesforce/schema/PRM_Registration_Request__c';
import FirstName from '@salesforce/schema/PRM_Registration_Request__c.PRM_First_Name__c';
import LastName from '@salesforce/schema/PRM_Registration_Request__c.PRM_Last_Name__c';
import Email from '@salesforce/schema/PRM_Registration_Request__c.PRM_Email_ID__c';
import PreLang from '@salesforce/schema/PRM_Registration_Request__c.PRM_Preferred_Language__c';
import Country from '@salesforce/schema/PRM_Registration_Request__c.PRM_Contact_Country__c';
import SupressedEmail from '@salesforce/schema/PRM_Registration_Request__c.PRM_Suppress_Email__c';
import AccountName from '@salesforce/schema/PRM_Registration_Request__c.PRM_Account_ID__c';
import BizOrg from '@salesforce/schema/PRM_Registration_Request__c.PRM_Partner_Type__c';
import Website from '@salesforce/schema/PRM_Registration_Request__c.PRM_Account_URL__c'; 
import Address1 from '@salesforce/schema/PRM_Registration_Request__c.PRM_Address_Line_1__c';
import Address2 from '@salesforce/schema/PRM_Registration_Request__c.PRM_Address_Line_2__c';
import State from '@salesforce/schema/PRM_Registration_Request__c.PRM_State_Province__c'; 
import City from '@salesforce/schema/PRM_Registration_Request__c.PRM_City__c';
import Zip from '@salesforce/schema/PRM_Registration_Request__c.PRM_Zip_Postal_Code__c'; 


export default class ER_Admin_Registration extends LightningElement {
    @track selectedStep = 'Step1';
    @track optionsCountry;
    @track optionsLanguage;
    @track partnerRoleTypeMap;
    @track languageSelected;
    @track optionsType;
    @track optionsState;
    @track data = [];
    @track firstname = this.FirstName;
    Con = {
       // firstname : this.FirstName,
        lastname : this.LastName,
        email : this.Email,
        prelang : this.PreLang,
        country : this.Country,
        surmail : this.SupressedEmail,
        account : this.AccountName,
        bizorg : this.BizOrg,
        website : this.Website,
        add1 : this.Address1,
        add2 : this.Address2,
        state : this.State,
        city : this.City,
        zip : this.Zip

    }
connectedCallback(){
    this.fetchCountry();
}

    fetchCountry(){

        getPicklistValues().then(result=>{
            this.data = result;
            console.log('this.data country', this.data);
             
            console.log('country',this.keys);
            console.log('State',this.value);

  
            var prefLanguage = this.data.prefLanguageMap;
            var partRoleTypeMap = this.data.roleTypeMapping;
            var orgType = this.data.bizOrgTypeMap;
            
            var optionLang1 = [];
            var optionLang2 = [];
            var finalLanguageList = [];
            var optionRole = [];
            var optionOrgType = [];
            for (var i in prefLanguage) {
                var languages = {
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

            for (var i in orgType) {
                var bizOrgType = {
                    label: orgType[i],
                    value: i
                }
                optionOrgType.push(bizOrgType);
            }
            this.optionsLanguage = finalLanguageList;
            this.partnerRoleTypeMap = partRoleTypeMap;
            this.optionsType = optionOrgType;
           
            /*
            console.log('partRoleTypeMap' + JSON.stringify(component.get("v.partnerRoleTypeMap")));
            //console.log("partRoleTypeMap"+JSON.stringify(partRoleTypeMap));
            //component.set("v.optionsRole",optionRole);
            component.set("v.optionsType", optionOrgType);
            //console.log('options '+JSON.stringify(option));
            //alert(JSON.stringify(this.data.bizOrgTypeMap));
            component.set("v.stateCountryInfo", this.data.stateCountryInfoList);
            //alert('this.data'+JSON.stringify(this.data));
            */
            var stateCountryList = this.data.stateCountryInfoList;
            let keys = [];
            for (var i = 0; i < stateCountryList.length; i++) {
                var country = stateCountryList[i].country;
                var c = {
                    "label": country.substr(0, country.indexOf(';')),
                    "value": country.substr(country.indexOf(';') + 1, country.length)
                };
                keys.push(c);
            }

            this.optionsCountry = keys; 
            this.optionsState = value;

            }).catch(error =>{
                console.log('Error country',error);
            })

        }
    handleNext() {
        var getselectedStep = this.selectedStep;
        if(getselectedStep === 'Step1'){
            this.selectedStep = 'Step2';
        }
        else if(getselectedStep === 'Step2'){
            this.selectedStep = 'Step3';
        }
        else if(getselectedStep === 'Step3'){
            this.selectedStep = 'Step4';
        }
    }
 
    handlePrev() {
        var getselectedStep = this.selectedStep;
        if(getselectedStep === 'Step2'){
            this.selectedStep = 'Step1';
        }
        else if(getselectedStep === 'Step3'){
            this.selectedStep = 'Step2';
        }
        else if(getselectedStep === 'Step4'){
            this.selectedStep = 'Step3';
        }
    }
      
    handleFinish() {
        alert('Finished...');
        this.selectedStep = 'Step1';
    }
      
    selectStep1() {
        this.selectedStep = 'Step1';
    }
 
    selectStep2() {
        this.selectedStep = 'Step2';
    }
 
    selectStep3() {
        this.selectedStep = 'Step3';
    }
 
    selectStep4() {
        this.selectedStep = 'Step4';
    }
 
    get isSelectStep1() {
        return this.selectedStep === "Step1";
    }
    get isSelectStep2() {
        return this.selectedStep === "Step2";
    }
    get isSelectStep3() {
        return this.selectedStep === "Step3";
    }
    get isSelectStep4() {
        return this.selectedStep === "Step4";
    }
    

}