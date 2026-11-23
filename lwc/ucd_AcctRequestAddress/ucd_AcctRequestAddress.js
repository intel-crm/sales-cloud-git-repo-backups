import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import {NavigationMixin} from 'lightning/navigation';
import addressVerification from "@salesforce/apex/UCD_ACM_AddressVerificationOnReqstQueue.addressVerification";
const FIELDS=[
    'Account_Create_Request__c.Address__Street__s',
    'Account_Create_Request__c.Address__City__s',
    'Account_Create_Request__c.Address__StateCode__s',
    'Account_Create_Request__c.Address__CountryCode__s',
    'Account_Create_Request__c.Address__PostalCode__s'
];
export default class Ucd_AcctRequestAddress extends NavigationMixin(LightningElement) {
    @api recordId;
    @track error;
    @track cleansedAddress;
    @track showModal=false;
    @track showAddress=false;
    
    connectedCallBack(){
        console.log('Connected Callback');
        /*this.cleansedAddress=null;
        this.error=null;
        if(this.accountRequest && this.accountRequest.data){
            console.log('#accountRequest '+this.accountRequest);
            this.cleanseAddress();
        }*/
    }
    /*cleanseAddress(){
        if(this.accountRequest.data){
            const{Address__Street__s,Address__City__s,Address__StateCode__s,Address__CountryCode__s,Address__PostalCode__s}=this.Account_Create_Request__c.data.fields;
            addressVerification({
                streetName : Address__Street__s.value,
                cityName : Address__City__s.value,
                stateName : Address__StateCode__s.value,
                countryName : Address__CountryCode__s.value,
                postalCode : Address__PostalCode__s.value
            })
            .then(result =>{
                this.cleansedAddress=result;
                this.showModal=true;
                console.log('CleansedAddress@67 '+JSON.stringify(this.cleansedAddress));
                if(this.cleansedAddress.verificationStatus==='Reverted' || this.cleansedAddress.verificationStatus==='Unverified'){
                    this.showAddress=false;
                }
                else{
                    this.showAddress=true;
                }
            })
            .catch(error=>{
                this.error=error.body.message;
            })
        }
        else if(this.accountRequest.error){
            this.error=this.accountRequest.error.body.message;
        }
    }*/
}