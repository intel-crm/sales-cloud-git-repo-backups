//import { LightningElement,track } from 'lwc';
import { LightningElement, track, api ,wire } from 'lwc';
/*import checkIPSUser from '@salesforce/apex/Sales_NonIPSCaseCreation.checkIPSUser';
import checkExternal from '@salesforce/apex/Sales_NonIPSCaseCreation.checkExternal';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
//import IS_IPS from "@salesforce/schema/User.Contact.Core_IPS_Active__c";
//import USER_ID from "@salesforce/user/Id";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import URL_IPS from '@salesforce/label/c.Sales_URL_IPS_User';
import IPS_Error_Msg from '@salesforce/label/c.Sales_Ips_Error_Message';
import How_to from '@salesforce/label/c.Sales_IPS_How_to_Link';
import Frequently_asked_questions from '@salesforce/label/c.Sales_Frequently_asked_questions';
import contact_your_distributor from '@salesforce/label/c.Sales_contact_your_distributor';
import day_trial_license from '@salesforce/label/c.Sales_30_day_trial_license';
import quartus_Web_edition from '@salesforce/label/c.Sales_Quartus_II_Web_edition';
import Maxplus_II_license from '@salesforce/label/c.Sales_Maxplus_II_license';
import Rnewal_Add_Seat_License_Link from '@salesforce/label/c.Salese_Rnewal_Add_Seat_License_Link';
import Sales_Case_Question from '@salesforce/label/c.Sales_Case_Question';
import Sales_Feature_Message from '@salesforce/label/c.Sales_Feature_Message';
import Sales_Case_Guidance from '@salesforce/label/c.Sales_Case_Guidance';
import Sales_Case_On_License from '@salesforce/label/c.Sales_Case_On_License';
import Sales_Case_Navigation from '@salesforce/label/c.Sales_Case_Navigation';
import Sales_Case_Any_Question from '@salesforce/label/c.Sales_Case_Any_Question';
import Sales_Case_New_Subcription from '@salesforce/label/c.Sales_Case_New_Subcription';
import Sales_Case_You_Can_Also from '@salesforce/label/c.Sales_Case_You_Can_Also';
import Sale_Case_Get from '@salesforce/label/c.Sale_Case_Get';
import Sales_Case_Free from '@salesforce/label/c.Sales_Case_Free';
import Sales_Case_looking_Something from '@salesforce/label/c.Sales_Case_looking_Something';
import Sales_internal from '@salesforce/label/c.Salese_Rnewal_Add_Seat_License_Link_Internal';
import Sales_Technical_Issue from '@salesforce/label/c.Sales_Technical_Issue';
import Sales_yes from '@salesforce/label/c.Sales_yes';
import Sales_no from '@salesforce/label/c.Sales_no';
import Sales_Contact_Customer_Title from '@salesforce/label/c.Sales_Contact_Customer_Title';
import Sales_Contact_Customer_Title_New from '@salesforce/label/c.Sales_Contact_Customer_Title_New';
import Sales_How_to_label from '@salesforce/label/c.Sales_How_to_label';
import Sales_Freq_Question from '@salesforce/label/c.Sales_Freq_Question';
import Sales_Renewal_License_Label from '@salesforce/label/c.Sales_Renewal_License_Label';
import Sales_Add_seat_license from '@salesforce/label/c.Sales_Add_seat_license';
import Sales_myIntel from '@salesforce/label/c.Sales_myIntel';
//import Sales_Technical_Issue from '@salesforce/label/c.Sales_Technical_Issue';
import Sales_Case_Maxplus from '@salesforce/label/c.Sales_Case_Maxplus';
import Sales_Case_Quartus from '@salesforce/label/c.Sales_Case_Quartus';
import Sales_Case_30days from '@salesforce/label/c.Sales_Case_30days';
import Sales_distributor from '@salesforce/label/c.Sales_distributor';
import Sales_Getafree from '@salesforce/label/c.Sales_Getafree';
import Sales_stepbystepGuidance from '@salesforce/label/c.Sales_stepbystepGuidance';
import Sales_Frequentlyaskedquestions from '@salesforce/label/c.Sales_Frequentlyaskedquestions';
import Sales_contactCustomerSupport from '@salesforce/label/c.Sales_contactCustomerSupport';

import Sales_Help_Eval_Free_Emp from '@salesforce/label/c.Sales_Help_Eval_Free_Emp';
import Sales_FGPA_Installation from '@salesforce/label/c.Sales_FGPA_Installation';
*/
export default class Sales_ContactCustomerService_HomePage extends NavigationMixin(LightningElement) {

        /*@track optionSelected;
        @api NonIpsCaseCreation=false;

    getSelection(event) {
        this.optionSelected = event.detail.value;
    }
    label = {
        URL_IPS,IPS_Error_Msg,How_to ,Frequently_asked_questions,contact_your_distributor,
        day_trial_license,quartus_Web_edition,Maxplus_II_license,Rnewal_Add_Seat_License_Link,
        Sales_Case_Question,Sales_Feature_Message,Sales_Case_Guidance,Sales_Case_On_License,Sales_Case_Navigation,
        Sales_Case_Any_Question,Sales_Case_New_Subcription,Sales_Case_You_Can_Also,Sale_Case_Get,Sales_Case_Free,
        Sales_Case_looking_Something,Sales_internal,Sales_Technical_Issue,Sales_yes,Sales_no,Sales_Contact_Customer_Title,
        Sales_How_to_label,Sales_Freq_Question,Sales_Renewal_License_Label,Sales_Add_seat_license,Sales_myIntel,Sales_Case_Maxplus,Sales_Case_Quartus,Sales_Case_30days,Sales_Contact_Customer_Title,Sales_distributor,Sales_Contact_Customer_Title_New,
        Sales_FGPA_Installation,Sales_Help_Eval_Free_Emp,Sales_Getafree,Sales_contactCustomerSupport,Sales_Frequentlyaskedquestions,Sales_stepbystepGuidance
    }; 

    get isOption1(){return this.optionSelected == 'Opt1'}
    get isOption2(){return this.optionSelected == 'Opt2'}

    get myoptions() {
        return [
            { label: this.label.Sales_yes, value: 'Opt1' },
            { label: this.label.Sales_no, value: 'Opt2' },
        ];
    }
    viewRecord(){
        checkIPSUser()
        .then((result) => {
            console.log('result '+ result);
            if(result == true){
                console.log('result '+ result);
                this[NavigationMixin.Navigate]({
                    "type": "standard__webPage",
                    "attributes": {
                        "url": this.label.URL_IPS
                    }
                });
            }else{
               this.showToast('Error',this.label.IPS_Error_Msg+' {1}.','error');
               console.log(this.label.IPS_Error_Msg);
             //  this.showToast('Error','You need to have access to Intel Premier Support (IPS) in order to submit technical issues/queries. You can enroll for IPS access via {1}.','error');
            }
        })
        .catch((error) => {
            this.error = error;
            this.contacts = undefined;
        });
       
    }
    showToast(msgTitle,msg,type){
        console.log('In Toast');
        this.dispatchEvent(
            new ShowToastEvent({
                title: msgTitle,
                message: msg,
                variant: type,
                mode: 'Sticky',
                "messageData": [
                    'myIntel',
                    {
                        url: 'https://intel.com',
                        label: this.label.Sales_myIntel
                    }
                ]
            }),
        );
    }
    viewRecord1(){
        
        //this.NonIpsCaseCreation=true;
        checkIPSUser()
        .then((result) => {
            console.log('result '+ result);
            if(result == true){
                console.log('result '+ result);
                this[NavigationMixin.Navigate]({
                    "type": "standard__webPage",
                    "attributes": {
                        "url": this.label.URL_IPS
                    }
                });
            }else{
                this.NonIpsCaseCreation=true;
            }

        })
        .catch((error) => {
            this.error = error;
            this.contacts = undefined;
        });
    }
    viewHowto(){
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.label.How_to
            }
        });
    }
    viewFrequentlyQue(){
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.label.Frequently_asked_questions
            }
        });
    }
    viewcontactdistributor(){
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.label.contact_your_distributor
            }
        });
    }
    viewdaytriallicense(){
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.label.day_trial_license
            }
        });
    }
    viewquartusWebeditionx(){
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.label.quartus_Web_edition
            }
        });
    }
    viewMaxplusIIlicense(){
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.label.Maxplus_II_license
            }
        });
    }
    viewURL(){
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.label.Sales_FGPA_Installation
            }
        });
    }
    viewRnewalAddSeatLicenseLink(){
        checkExternal()
        .then((result) => {
            console.log('result external'+ result);
            if(result == true){
                console.log('result '+ result);
                this[NavigationMixin.Navigate]({
                    "type": "standard__webPage",
                    "attributes": {
                        "url": this.label.Rnewal_Add_Seat_License_Link
                    }
                });
            }else{
                this[NavigationMixin.Navigate]({
                    "type": "standard__webPage",
                    "attributes": {
                        "url": this.label.Sales_internal
                    }
                });
            }

        })
    }*/
}