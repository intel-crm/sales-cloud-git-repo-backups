import { LightningElement, track, api ,wire } from 'lwc';
import checkIPSUser from '@salesforce/apex/Sales_NonIPSCaseCreation.checkIPSUser';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
//import IS_IPS from "@salesforce/schema/User.Contact.Core_IPS_Active__c";
//import USER_ID from "@salesforce/user/Id";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
//import URL_IPS from '@salesforce/label/c.URL_IPS_User';
import URL_IPS from '@salesforce/label/c.URL';
export default class Contactservice extends NavigationMixin(LightningElement) {
    @track optionSelected;
    /*
    @wire(getRecord, { recordId: USER_ID, fields: [IS_IPS] })
    user;
    */
    label = {
        URL_IPS}; 
    getSelection(event) {
        this.optionSelected = event.detail.value;
    }
    
    get isYES(){return this.optionSelected == 'yes'}
    get isNO(){return this.optionSelected == 'no'}
    
    value = '';
    get options() {
        return [
            { label: 'YES', value: 'yes' },
            { label: 'NO', value: 'no' },
        ];
    }
    viewRecord(){
        checkIPSUser()
        .then((result) => {
            console.log('result '+ result);
            if(result == false){
                console.log('result '+ result);
                this[NavigationMixin.Navigate]({
                    "type": "standard__webPage",
                    "attributes": {
                        "url":  this.label.URL_IPS
                    }
                });
            }else{
                this.showToast('Error','you need to have access to intel premier support(IPS) in order to submit technical issue/querires.You can Enroll for IPS access via {1}','error');
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
                mode: 'dismissable',
                "messageData": [
                    'myIntel',
                    {
                        url: 'https://intel.com',
                        label: 'myIntel'
                    }
                ]
            }),
        );
    }
}