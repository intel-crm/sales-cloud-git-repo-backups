import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import User_Name from '@salesforce/schema/User.Name';
import User_Email from '@salesforce/schema/User.Email';
import User_WWID from '@salesforce/schema/User.Core_WWID__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import Country_FIELD from '@salesforce/schema/Account.BillingCountryCode';
import State_FIELD from '@salesforce/schema/Account.BillingStateCode';
import Intel_Led_Label from '@salesforce/label/c.UCD_Intel_Led_Label';
import Partner_Led_Label from '@salesforce/label/c.UCD_Partner_Led_Label';
import Other_Led_Label from '@salesforce/label/c.UCD_Other_Led_Label';
import Not_Covered_Label from '@salesforce/label/c.UCD_Not_Covered_Label';

export default class ucd_ACM_Create_Account_SBR extends NavigationMixin(LightningElement) {

    @track loaded=false;
    @track errorMsg;
    @track permissionErrorCode=0;
    @track submitError;
    @track errorList;
    @track UserName;
    @track UserEmail;
    @track UserWWID;
    @track disabledDigital = true;
    @track disabledLocalLang = true;
    @track stateFieldData;
    accountName='';
    alternateLanName='';
    @track accountNameLocalLan='';
    digitalIdentifier='';
    digitalIdentifierVal='';
    industry='';
    subIndustry='';
    salesGrp='';
    taxId='';
    @track accountcoverage='';
    @track option1;
    @track option2;
    @track option3;
    @track option4 = false;
    label = {
        Intel_Led_Label, 
        Partner_Led_Label, 
        Other_Led_Label,
        Not_Covered_Label};
    globalAccount='';
    @track state="";
    @track stateOpt='';
    @track province='';
    isError = false;
    
     loader(event){
    this.loaded = true;
    }

    @track countryOptions;
    @track stateOptions;
    @track addressAddress = {
        Street: '',
        City: '',
        province: '',
        postalCode: '',
        Country: '',
        stateCode:''
    }
    @api acctformdetails; 
    @api acctreasontrail;
    @api objectApiName="Account";

    @track displaySalesgroup = false;

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    AccountInfo;
   @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: State_FIELD })
    /* stateFieldInfo(result) {
            this.stateFieldData = result;
    } */
   stateFieldInfo({ data, error }) {
        if (data) {
           // this.stateOptions = data.values;
           this.stateOptions = '';
            this.stateFieldData = data;
        }
    }
    get getStateOptions() {
        return this.stateOptions;
    }

   @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: Country_FIELD })
   countryFieldInfo({ data, error }) {
       
       if (data) {
           this.countryOptions = JSON.parse(JSON.stringify(data.values));
       }
   }
   get getCountryOptions() {
    return this.countryOptions;
   }

    connectedCallback() {
        if(this.acctreasontrail === 'CoMarketing') {
            this.displaySalesgroup = false;
            this.salesGrp = 'Undefined';
        } 
        else if (this.acctreasontrail === 'Partner' || this.acctreasontrail === 'Access & Entitlement' || this.acctreasontrail === 'Other'){
            this.displaySalesgroup = true;
            this.Value = 'Undefined';
            this.salesGrp = this.Value;
        }
        else {
            this.displaySalesgroup = true;
        }
   }
   
   pickListChangeHandler(event){

   if(event.target.country != ''){           
     this.addressAddress.Country = event.target.country;
     let key = this.stateFieldData.controllerValues[event.target.country];
     this.stateOptions = this.stateFieldData.values.filter(opt => opt.validFor.includes(key));
   }
   if(event.target.country==''){
    this.addressAddress.province ='';
    this.stateOptions = '';
    this.addressAddress.stateCode='';
   }
   if(event.target.street != ''){  
   this.addressAddress.Street = event.target.street;
   }
   if(event.target.city != ''){  
   this.addressAddress.City = event.target.city;
   }
   if(event.target.province != ''){  
   this.addressAddress.province = event.target.province;
   }
   if(event.target.postalCode != ''){  
   this.addressAddress.postalCode = event.target.postalCode;
   }
   console.log('addres filed postalcode'+event.target.postalCode);

 }
   
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [User_Name,User_Email,User_WWID]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.UserName = data.fields.Name.value;
            this.UserEmail = data.fields.Email.value;
            this.UserWWID = data.fields.Core_WWID__c.value;

            
        }
    }
   
    renderedCallback() {
        this.loaded=false;
    }
    handleLoad(event){
        this.loaded=false;
    }
    
    handleFieldChange(event){
        if(event.target.fieldName == 'Account_Name__c'){
            console.log('Name--> '+event.target.value);
            this.accountName = event.target.value;
        }
        if(event.target.fieldName == 'Core_Alternate_Name_Language__c'){
            console.log('AlternateLan--> '+event.target.value);
            if(event.target.value != ''){
                this.disabledLocalLang = false;
            }else{
                this.disabledLocalLang = true;
                this.accountNameLocalLan = '';
            }
            this.alternateLanName = event.target.value;
        }
        if(event.target.fieldName == 'Core_Alternate_Language_Name__c'){
            console.log('CoreAltLan--> '+event.target.value);
            this.accountNameLocalLan = event.target.value;
        }
        if(event.target.fieldName == 'Digital_Identifier_Type__c'){
            console.log('DigitalIden--> ',event.target.value);
            if(event.target.value != ''){
                this.disabledDigital = false;

            }else{
                this.disabledDigital = true;
                this.digitalIdentifierVal = '';

            }
            console.log('event.target.value--> '+event.target.value);
            this.digitalIdentifier = event.target.value;
        }
        if(event.target.fieldName == 'Digital_Identifier_Value__c'){
            console.log('DigitalIdenVal--> '+event.target.value);
            this.digitalIdentifierVal = event.target.value;
        }
        if(event.target.fieldName == 'Industry__c'){
            console.log('Industry--> '+event.target.value);
            this.industry = event.target.value;
        }
        if(event.target.fieldName == 'Core_Sub_Industry__c'){
            console.log('SubInd--> '+event.target.value);
            this.subIndustry = event.target.value;
        }
        if(event.target.fieldName == 'Core_Sales_Groups__c'){
            console.log('salesGrp--> '+event.target.value);
            this.salesGrp = event.target.value;
        }
        if(event.target.fieldName == 'Tax_Id__c'){
            console.log('event.target.value--> '+event.target.value);
            this.taxId = event.target.value;
        }
        if(event.target.fieldName == 'Core_Account_Primary_Coverage__c'){
            this.accountcoverage = event.target.value;
            if(this.accountcoverage === 'Intel-led Account'){
                this.option1 = true;
                this.option2 = false;
                this.option3 = false;
                this.option4 = true;
            }
            else if(this.accountcoverage === 'Partner-led Account'){
                this.option2 = true;
                this.option1 = false;
                this.option3 = false;
                this.option4 = true;
            }
            else if(this.accountcoverage === 'Other-led Account'){
                this.option3 = true;
                this.option1 = false;
                this.option2 = false;
                this.option4 = true;
            }
            else if(this.accountcoverage === 'Not Covered Account'){
                this.option4 = false;
                this.option1 = false;
                this.option2 = false;
                this.option3 = false;
            }
        }
        if(event.target.fieldName == 'Global_Account__c'){
            this.globalAccount = event.target.value;
        }
    }
    handleSuccess(event) {
        this.loaded=false;
        if(!this.isError){
            this.showToastSuccessMessage('Success !','Account Request Record has been created successfully','success',1000);
            
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                  recordId: event.detail.id,
                  objectApiName: 'Account_Create_Request__c',
                  actionName: 'list'
                },
                state:{
                    filterName: 'New_Request'
                }
              });
        }
        
    }
    handleError(event) {
        console.log('Inside handle error'+JSON.stringify(event.detail));
        this.loaded=false; 
        if(JSON.stringify(event.detail.detail)==='""'){
            console.log('Inside if'+event.detail.detail);
            this.permissionErrorCode=1;
            this.errorMsg='Invalid values to create a record!';                                      
        }
        else{
            console.log('Inside else'+event.detail.detail);
            this.errorMsg=JSON.stringify(event.detail.detail);            
        }
        this.showToastErrorMessage('error','Error!',this.errorMsg);
    }
    
    handleBackButtonClick(event) {
        console.log('inside create account '+JSON.stringify(this.acctformdetails));
        const acctCreateBackClick = new CustomEvent("acctcreatebackclick", { detail: this.acctformdetails });
        this.dispatchEvent(acctCreateBackClick);       
    }

    handleSubmit1(event) {
        const fields = event.detail.fields;
        console.log('fields 1--> '+JSON.stringify(fields));
        this.validateFields(event);
        
    }
    handleSubmit(event){
        console.log('In handleSubmit'+this.addressAddress.postalCode);
        event.preventDefault();
        if(!this.isError){
            const fields = event.detail.fields;
            console.log('fields 2--> '+JSON.stringify(fields));
            fields.Address__CountryCode__s = this.addressAddress.Country;
            fields.Address__StateCode__s = this.addressAddress.province;
            fields.Address__Street__s = this.addressAddress.Street;
            fields.Address__City__s = this.addressAddress.City;
            fields.Address__PostalCode__s = this.addressAddress.postalCode;
            fields.Core_Sales_Groups__c = this.salesGrp;

            //this.validateFields(event,fields);
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
        
    }

    validateFields(event){
        this.submitError='' ;
        this.errorList='';
        
        console.log('this.template.querySelector(".Name").value--> '+this.template.querySelector(".Name").value);
        this.errorList=(((this.template.querySelector(".Name").value == '' || this.template.querySelector(".Name").value == null) || !this.template.querySelector(".Name").value.trim())?(this.submitError+',' +'Account Name'):'')+
        ((!this.template.querySelector(".Industry").value)?(this.submitError+',' +'Industry'):'')+
        ((!this.template.querySelector(".SubIndustry").value)?(this.submitError+',' +'Sub Industry'):'')+
        ((!this.template.querySelector(".globaAcct").value)?(this.submitError+',' +'Justification for Request'):'')+
        ((!this.template.querySelector(".digitalIdentifier").value)?(this.submitError+',' +'Digital Identifier '):'')+
        ((!this.template.querySelector(".digitalIdentifierVal").value)?(this.submitError+',' +'Digital Identifier Value'):'');


        if(this.displaySalesgroup)
        {
            this.errorList = this.errorList + ((!this.template.querySelector(".SalesGrp").value)?(this.submitError+',' +'Sales Group'):'');
        }

        console.log('disabled'+this.disabledDigital);
        if(!this.disabledDigital)
        {
            console.log('inside if digital');
            if(this.digitalIdentifierVal == '' && this.digitalIdentifier == 'Website/URL')
            {
                this.errorList = this.errorList + (((this.template.querySelector(".digitalIdentifierVal").value == '' || this.template.querySelector(".digitalIdentifierVal").value == null) || !this.template.querySelector(".digitalIdentifierVal").value.trim())?(' . If a customer website cannot be found, you can enter N/A'):'')
            }
             else if(this.digitalIdentifierVal == '' && this.digitalIdentifier == 'WeChat')
             {
                this.errorList = this.errorList + (((this.template.querySelector(".digitalIdentifierVal").value == '' || this.template.querySelector(".digitalIdentifierVal").value == null) || !this.template.querySelector(".digitalIdentifierVal").value.trim())?(' . If a customer website cannot be found, you can enter N/A'):'')
            }

        }
        if(!this.disabledLocalLang)
        {
        this.errorList = this.errorList + (((this.template.querySelector(".AltLangName").value == '' || this.template.querySelector(".AltLangName").value == null) || !this.template.querySelector(".AltLangName").value.trim())?(this.submitError+',' +'Customer Name - Local Language'):'')
        }
      //  (((this.template.querySelector(".digitalIdentifier").value == '' || this.template.querySelector(".digitalIdentifier").value == null) || !this.template.querySelector(".digitalIdentifier").value.trim())?(this.submitError+',' +'Digital Identifier Value'):'')+
       // (((this.template.querySelector(".AltLangName").value == '' || this.template.querySelector(".AltLangName").value == null) || !this.template.querySelector(".AltLangName").value.trim())?(this.submitError+',' +'Customer Name - Local Language'):'');
        console.log('error list'+this.errorList);
        const address = this.template.querySelector('lightning-input-address');
    //Country Field Validation
    var country = address.country;
    if (country == null || country == '') {
        address.setCustomValidityForField('Complete this field.', 'country');
    } else {
        address.setCustomValidityForField("", 'country'); //Reset previously set message
    }

     //Street Field Validation
     var street = address.street;
     console.log('Street'+street);
     if (!street) {
         address.setCustomValidityForField('Complete this field.', 'street');
     } else {
         address.setCustomValidityForField("", 'street'); //Reset previously set message
     }
     
     //city Field Validation
     var city = address.city;
     console.log('Street'+city);
     if (!city) {
         address.setCustomValidityForField('Complete this field.', 'city');
     } else {
        address.setCustomValidityForField("", 'city'); //Reset previously set message
     }

    address.reportValidity(); // Refreshes the component to show or remove error messages from UI
    const isValid = address.checkValidity(); //Check if the address is Valid and accordingly proceed.
         
       if(!isValid){
        this.errorList = this.errorList+', Complete all address fields.';
       }

        if(this.errorList.charAt(0) == ','){
            this.submitError=this.errorList.substring(1);
        }else{
            this.submitError=this.errorList;
        }
        console.log('this.submitError--> '+this.submitError);
        if(this.submitError!=''){
            this.isError = true;
            this.showToastErrorMessage('error','Error!','Review the required fields errors! '+this.submitError);
        }else{
            console.log('in else submiterror');
            this.isError = false;
        } 
    }

    showToastSuccessMessage(title,message,variant,duration) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant ,
            duration: duration
        });
        this.dispatchEvent(evt);
    }

    showToastErrorMessage(variant,title,message){
        const eve = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message,
        });
        this.dispatchEvent(eve); 
    }
    
}