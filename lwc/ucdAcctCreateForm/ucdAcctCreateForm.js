import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import State_FIELD from '@salesforce/schema/Account.BillingStateCode';
import Country_FIELD from '@salesforce/schema/Account.BillingCountryCode';
import BizOrg_FIELD from '@salesforce/schema/Account.Core_Account_Type__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import findAccounts from '@salesforce/apex/UCD_AccountConnector.findAccounts';

export default class UcdAcctCreateForm extends LightningElement {

    @track payload = {
        accountName: "",
        countryCode: "",
        country: "",
        stateCode: "",
        state: "",
        bizOrgTypeCode: "",
        bizOrgType: "",
        addressline1: "",
        addressline2: "",
        postalCode: "",
        ownerId: "",
        city: "",
        tname:"",
        taddressline1:"",
        taddressline2:"",
        tcity:""       
    };
  
    @api payloadNew = {};
    @track error;
    @track stateOptions;
    @track countryOptions;
    @track bizorgOptions;
    @track stateFieldData;
    /* variables use as part of US740756 to check existing billing address */
    @api records;
    @api errors;
    @track street1='';
    @track street2 =''
    @track fullStreet = this.payload.addressline1 +" " +this.payload.addressline2;
    @track isAddrExists = false;
    @track isAddrName = false;
    @track isAddrName2 = false;
    /*end US740756 variables */


     isAddressError = false;
    /* Toast Message Varibles */
    @track validatorMessage = this.isAddressError ? 'Special characters not allowed in form fields' : 'Please fill in the required fields';
    @track warningVariant = 'warning';
    @track errorVariant = 'error';
    @track successVariant = 'success';
    @track dismissableMode = 'dismissable';
    /* End of toast message variables */
    //This is for moving modal to new component 
    @api nonLatinArray = {
        accname: '',
        addressline1: '',
        addressline2: '',
        city: '',    
    };
    @track isModalOpen = false;
    @track nospecialchar = false;
    @track nonLatinExp = /[^\u0000-\u007F ]+/;

     // wire method to get if any existing account with same billing address
    @wire(findAccounts, { bStreet1: '$street1', bStreet2: '$street2'}  
    )
    accounts({
        data,error
    }){
        if(data){
            this.records = data;
            this.errors = undefined;
            this.isAddrExists = this.records.length > 0 ? true : false; 
        }
        if(error){
            this.errors = error;
            this.records = undefined;
        }
    }
    //end of wire method
     @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
     AccountInfo;
     @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: State_FIELD })
     stateFieldInfo({ data, error }) {
        if (data) {
            this.stateFieldData = data;
            this.stateOptions = data.values;
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: Country_FIELD })
    countryFieldInfo({ data, error }) {
        if (data) this.countryOptions = data.values;
    }
    @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: BizOrg_FIELD })
    bizOrgFieldInfo({ data, error }) {
        if (data) this.bizorgOptions = data.values;
    }  
    // method called on click on Next button
    nextClickHandler(event) {       
        if (!this.validateFields()) {
            this.showToastMessage(this.validatorMessage,this.warningVariant,this.dismissableMode);
        }
        else if(this.isAddrExists == true ){
            this.showToastMessage('An organization exists for this physical address',this.warningVariant,this.dismissableMode);
        }
        else if(this.isAddrName == true || this.isAddrName2 == true){
            this.showToastMessage('Name and Address cannot have same value',this.warningVariant,this.dismissableMode);
        }
        else{              
                this.checkSpecialChar();
            }
        if(this.nospecialchar == true){
            this.Navigatetodupscreen();
        }          
    }
    //Method to navigate to the duplicateinfo screen 
    Navigatetodupscreen(){
            const acctCreateNextClick = new CustomEvent("acctcreatenextclick", { detail: this.payload });
            this.dispatchEvent(acctCreateNextClick);
    }
    
     //Method that check if the Field value contain any Non_Latin characters
     checkSpecialChar(){
        console.log('ENTERRRRRRR'+JSON.stringify(this.nonLatinArray));
       if(this.nonLatinArray.accname != '' || this.nonLatinArray.addressline1 != '' ||
           this.nonLatinArray.addressline2 != '' || this.nonLatinArray.city != ''){
               this.isModalOpen = true;
       }
       else{
           this.nospecialchar = true;  
           this.isModalOpen = false;         
       }
    } 
    // Method for Passing the transalted fvalues to backend.
    handleLanguageChange(event){
        this.payload.tname = event.detail.tname;
        this.payload.taddressline1 = event.detail.taddressline1;
        this.payload.taddressline2 = event.detail.taddressline2;
        this.payload.tcity = event.detail.tcity;
        console.log('FINALLY COMING FROM CHILD ARE' +JSON.stringify(event.detail));
        this.Navigatetodupscreen();
    }
    //Method for Closing the Non-Latin modal
    handleCloseModal(event){
        this.isModalOpen = false;
    }


    validateFields() {
        this.isAddressError = false;
        const regex = RegExp('[!@#$%^*()?":{}|<>]');
        const allValid = [...this.template.querySelectorAll('.validate')].reduce(
            (validSoFar, inputCmp) => {
                if(inputCmp.name.startsWith('addressline')){
                    if(regex.test(inputCmp.value)){
                        inputCmp.setCustomValidity("Invalid Address");
                        this.isAddressError = true;}
                    else {inputCmp.setCustomValidity("");}
                }
               else if(inputCmp.name.startsWith('Name')){
                    if(regex.test(inputCmp.value)) {
                        inputCmp.setCustomValidity("Invalid Name");
                        this.isAddressError = true; }
                    else {inputCmp.setCustomValidity("");}
                }
                else if(inputCmp.name.startsWith('city')){
                    if(regex.test(inputCmp.value)){
                        inputCmp.setCustomValidity("Invalid City");
                        this.isAddressError = true;}
                    else {inputCmp.setCustomValidity("");  }
                }
                else if(inputCmp.name.startsWith('postalCode')){
                    if(regex.test(inputCmp.value)){
                        inputCmp.setCustomValidity("Invalid zip/postal code");
                        this.isAddressError = true; }
                    else {inputCmp.setCustomValidity("");  }
                }
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        return allValid;
    }
    // Toast messages for all scenarios
    showToastMessage(message,variant,mode) {
        const evt = new ShowToastEvent({
            message: message,
            variant: variant,
            mode: mode 
        });
        this.dispatchEvent(evt);
    }
    //Method which stores the field values dynamically
    inputChangeHandler(event) {
        if (event.target.name == 'country') {
            this.payload.country = this.countryOptions.find(opt => opt.value === event.detail.value).label;
            this.payload.countryCode = event.target.value;
            this.country1 = event.target.value;
            let key = this.stateFieldData.controllerValues[event.target.value];
            this.stateOptions = this.stateFieldData.values.filter(opt => opt.validFor.includes(key));
        }
        if (event.target.name == 'state') {
            this.payload.stateCode = event.target.value;
            this.state1 = event.target.value;
            this.payload.state = this.stateOptions.find(opt => opt.value === event.detail.value).label;
            this.stateValue = event.target.value;
        }
    }
    nameChangeHandler(event) {
        this.payload.accountName = event.target.value;
        this.nonLatinArray.accname = '';
        if( this.payload.accountName.match(this.nonLatinExp)){        
            //this.isnamespecial = true; 
            this.nonLatinArray.accname = this.payload.accountName;
         }
    }
    bizorgChangeHandler(event) {		
            this.payload.bizOrgTypeCode = this.bizorgOptions.find(opt => opt.value === event.detail.value).label;
            this.payload.bizOrgType = event.target.value;
            }
    cityChangeHandler(event) {		
                this.payload.city = event.target.value;
                this.nonLatinArray.city ='';
                if(this.payload.city.match(this.nonLatinExp)){
                    //this.iscityspecial = true; 
                    this.nonLatinArray.city = this.payload.city;     
                }
            }	
    postalChangeHandler(event) {		
                this.payload.postalCode = event.target.value;              
            }
    addr1ChangeHandler(event) {		
                this.payload.addressline1 = event.target.value;
                this.street1 = event.target.value;
                this.isAddrName = event.target.value.toLowerCase().includes(this.payload.accountName.toLowerCase()) ? true : false;
                this.fullStreet = this.payload.addressline1 +" " +this.payload.addressline2;
                console.log('^^^^ADDRESS FULL IS BEFORE ^^^^^'+this.fullStreet);
                this.nonLatinArray.addressline1 ='';
                if(this.payload.addressline1.match(this.nonLatinExp)){
                    //this.isadd1special = true;  
                    this.nonLatinArray.addressline1 = this.payload.addressline1;     
                }
            }      
    addr2ChangeHandler(event) {		
                this.payload.addressline2 = event.target.value;
                this.street2 = event.target.value;
                this.fullStreet =  this.payload.addressline1 +" " +this.payload.addressline2;
                console.log('^^^^ADDRESS FULL IS ^^^^^'+this.fullStreet);
                this.isAddrName2 = event.target.value.toLowerCase().includes(this.payload.accountName.toLowerCase()) ? true : false;
                this.nonLatinArray.addressline2 ='';
                if(this.payload.addressline2 != null || this.payload.addressline2 != undefined){
                    if(this.payload.addressline2.match(this.nonLatinExp)){
                         //this.isadd2special = true; 
                         this.nonLatinArray.addressline2 = this.payload.addressline2;     
                    }
                }
            }
    @api
    get acctformdetails() {
        return this.payload;
    }
    set acctformdetails(value) {        
        if (value) {
            this.payload = JSON.parse(JSON.stringify(value));
            this.fullStreet =  this.payload.addressline1 +" " +this.payload.addressline2;
            this.street1 = this.payload.addressline1;
            this.street2 = this.payload.addressline2;
            console.log('PAYLOAD IS ****' +JSON.stringify(this.payload));
        }
    }
}