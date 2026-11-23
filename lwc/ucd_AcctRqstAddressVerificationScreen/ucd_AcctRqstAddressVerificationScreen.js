import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addressVerification from "@salesforce/apex/UCD_ACM_AddressVerificationOnReqstQueue.addressVerification";
const FIELDS=[
    'Account_Create_Request__c.Address__Street__s',
    'Account_Create_Request__c.Address__City__s',
    'Account_Create_Request__c.Address__StateCode__s',
    'Account_Create_Request__c.Address__CountryCode__s',
    'Account_Create_Request__c.Address__PostalCode__s'
];
export default class Ucd_AcctRqstAddressVerificationScreen extends LightningElement {
    @api recordId;
    accountRequest;
    //@track error;
    @track showModal=false;
    @track cleansedAddress;
    @track showAddress=false;

    @wire(getRecord,{recordId: '$recordId',fields: FIELDS})
    wiredAccountRequest({error,data}){
        if(data){
            console.log('Data Enter');
            this.accountRequest=data.fields;
            this.cleanseAddress();
        }
        else if(error){
            this.showToast('Error', 'Error Loading data','error');
        }
    }
    cleanseAddress(){
        console.log('@@Street '+this.accountRequest.Address__Street__s.value);
        const address={
            streetName : this.accountRequest.Address__Street__s.value,
            cityName : this.accountRequest.Address__City__s.value,
            stateName : this.accountRequest.Address__StateCode__s.value,
            countryName : this.accountRequest.Address__CountryCode__s.value,
            postalCode : this.accountRequest.Address__PostalCode__s.value
        };
        addressVerification({address})
        .then(result=>{
            this.cleansedAddress=result;
            this.showModal=true;
            console.log('CleansedAddress@67 '+JSON.stringify(this.cleansedAddress));
            if(this.cleansedAddress.verificationStatus==='Reverted' || this.cleansedAddress.verificationStatus==='Unverified'){
                this.showAddress=false;
            }
            else{
                this.showAddress=true;
            }
            this.showToast('Success','Address cleansed','success');
        })
        .catch(error=>{
            this.showToast('Error','Error while clensing','error');
        });
    }
    showToast(title,message,variant){
        const event=new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }
    closedModal(){
        this.showModal=false;
    }
}