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
import checkForDuplicates from "@salesforce/apex/UCD_GenericAcctSearch_SBR.checkForDuplicates";
import userFields from "@salesforce/apex/UCD_GenericAcctSearch_SBR.userFields";
import WarningLabel from "@salesforce/label/c.UCD_UserSearchError";
import UCD_ACM_Intel_Covered_Undefined_SalesGroup from '@salesforce/label/c.UCD_ACM_Intel_Covered_Undefined_SalesGroup';
import UCD_ACM_Intel_Covered_NotPartnerLed_SalesGroup from '@salesforce/label/c.UCD_ACM_Intel_Covered_NotPartnerLed_SalesGroup';
import UCD_ACM_Intel_Covered_PartnerLed_SalesGroup from '@salesforce/label/c.UCD_ACM_Intel_Covered_PartnerLed_SalesGroup';

const accRequestColumns=[
    {label : 'ARQ ID', fieldName: 'recordUrl',type:'url',typeAttributes:{label:{fieldName:'acctRequestId'}, target:'_blank'}},
    {label : 'Requested Name',fieldName: 'customername',},
    {label : 'Requested Address', fieldName: 'acctRequestCountry'},
    {label : 'Requested Date', fieldName: 'createdDate'},
    {label : 'Requested by User Name', fieldName: 'requestorName'},
    {label : 'Requested Reason Type', fieldName: 'processType'}
];

const acctColumns=[
    {label : 'Account ID', fieldName: 'recordacctId',type:'url',typeAttributes:{label:{fieldName:'acctId'}, target:'_blank'}},
    {label : 'Account Name',fieldName: 'accountName',},
    {label : 'Account Address', fieldName: 'accountCountry'},
    {label : 'Account Owner', fieldName: 'acctOwner'},
    {label : 'Unified Global Customer Name', fieldName: 'unifiedGlobalCustomerName'}
];

export default class ucd_ACM_Create_Account_SBR extends NavigationMixin(LightningElement) {

    @track loaded=false;
    @track errorMsg;
    @track permissionErrorCode=0;
    @track submitError;
    @track errorList;
    @track UserName;
    @track UserEmail;
    @track UserWWID;
    @track OwnerId;
    @track RequestorUser;
    @track disabledDigital = true;
    @track disabledLocalLang = true;
    @track spinLoad=false;
    @track stateFieldData;
    @track accountLevel = '';
    @track accountcategory = '';
    accountName='';
    alternateLanName='';
    @track accountNameLocalLan='';
    digitalIdentifier='';
    digitalIdentifierVal='';
    industry='';
    subIndustry='';
    salesGrp='';
    taxId='';
    @track accountcoverage='Not Covered';
    @track option1;
    @track option2;
    @track option3;
    @track option4 = false;
    label = {
        Intel_Led_Label, 
        Partner_Led_Label, 
        Other_Led_Label,
        Not_Covered_Label,
        UCD_ACM_Intel_Covered_Undefined_SalesGroup,
        UCD_ACM_Intel_Covered_NotPartnerLed_SalesGroup,
        UCD_ACM_Intel_Covered_PartnerLed_SalesGroup};
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
    @track showDuplicates=false;
    @track accountDuplicate=false;
    @track accountRequestDuplicate=false;
    @track duplicates=[];
    accRequestColumns=accRequestColumns;
    acctColumns=acctColumns;
    @api acctformdetails; 
    @api acctreasontrail;
    @api objectApiName="Account";
    @track fields;
    get options() {
        return [
            { label: 'Submit Request for Self', value: false},
            { label: 'Submit Request for Others', value: true },
        ];
    }
    @track selected = false;
    @track selected1 = false;
    userselection;
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
        // New requirement: For all request types other than Opportunity Management, 
        // lock account primary coverage as "Not Covered" and account level as "No Level"
        if (this.acctreasontrail !== 'Opportunity Management') {
            this.accountcoverage = 'Not Covered';
            this.accountLevel = 'NoLevel';
        }
   }
   
   pickListChangeHandler(event){
    this.showDuplicates = false;
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
        console.log('@OnChangecall');
        this.showDuplicates = false;
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
                this.salesGrp = event.target.value;
        }
        if(event.target.fieldName == 'Tax_Id__c'){
            console.log('event.target.value--> '+event.target.value);
            this.taxId = event.target.value;
        }
        if(event.target.fieldName == 'Core_Account_Primary_Coverage__c'){
                this.accountcoverage = event.target.value;
                if (this.isOpportunityManagement) {
                            if(this.accountcoverage === 'Indirect Covered') {
                            this.accountLevel = 'Level3';
                            const levelField = this.template.querySelector('.AccountLevel');
                            if(levelField) {
                                levelField.value = 'Level3';
                                levelField.disabled = true;
                            }
                            this.showToastSuccessMessage('Info', 'Account Level set to Level 3 for Indirect Covered', 'info', 3000);
                        }
                    
                    // Auto-set and lock Account Level for Not Covered
                    else if(this.accountcoverage === 'Not Covered') {
                        this.accountLevel = 'NoLevel';
                        const levelField = this.template.querySelector('.AccountLevel');
                        if(levelField) {
                            levelField.value = 'NoLevel';
                            levelField.disabled = true;
                        }
                        this.showToastSuccessMessage('Info', 'Account Level set to No Level for Not Covered', 'info', 3000);
                    }
                    // Enable Account Level for other coverages
                    else {
                        const levelField = this.template.querySelector('.AccountLevel');
                        if(levelField) {
                            levelField.disabled = false;
                        }
                    }
                }else {
                    // For non-Opportunity Management requests, reset to Not Covered if changed
                    this.accountcoverage = 'Not Covered';
                    const coverageField = this.template.querySelector('.AccountCoverage');
                    if (coverageField) {
                        coverageField.value = 'Not Covered';
                    }
                    event.preventDefault();
                }
    }
        if(event.target.fieldName == 'Global_Account__c'){
            this.globalAccount = event.target.value;
        } 
        if(event.target.fieldName == 'Core_Account_Category__c'){
            this.accountcategory = event.target.value;
        }
        if(event.target.fieldName == 'Core_Account_Level__c'){
            this.accountLevel = event.target.value;
        }
    }

    handleSelfSelectionchange(event){
        if(event.target.name == 'self'){
            this.template.querySelector('.others').checked = false;
            this.selected = false;
            this.selectedRecord(event);
        }
         if(event.target.name == 'others'){
            this.selected = true;
            this.template.querySelector('.self').checked = false;
        }
        console.log('Event ',event.target.value,' selected', this.selected, ' name' , event.target.value);
        let hide = "visibility\: hidden\;margin-top\: -5%\;";
        let show = "visibility\: visible\;";
        this.userselection = true;
    }
    handleSuccess(event) {
        this.loaded=false;
        this.spinLoad=false;
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
        this.spinLoad=false;
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
        // For non-Opportunity Management requests, ensure these values are set
        if (!this.isOpportunityManagement) {
            this.accountcoverage = 'Not Covered';
            this.accountLevel = 'NoLevel';
        }
        if (this.isOpportunityManagement) {
                
                if (!this.validateAccountLevelRules()) {
                return; // Stop submission if validation fails
            }
        }
        if(!this.validateUserSelection()){
            return;
        }
            
            // Set the account level and category for Opportunity Management
        
            this.spinLoad=true;
            const nameFieldValue=this.template.querySelector(".Name").value;
            const alternateLangNameFieldValue=this.accountNameLocalLan;
            const countryFieldValue=this.addressAddress.Country;
            const streetFieldValue=this.addressAddress.Street;
            const cityFieldValue=this.addressAddress.City;
            const stateFieldValue=this.addressAddress.province;
            //const postalCodeValue=this.addressAddress.postalCode;
            console.log('#@$stateFieldValue35 '+stateFieldValue);
            checkForDuplicates({
                customername : nameFieldValue,
                alternateLangName : alternateLangNameFieldValue,
                primaryCountry : countryFieldValue,
                primaryStreet : streetFieldValue,
                primaryCity : cityFieldValue,
                primaryState : stateFieldValue
            })
            .then(result =>{
                if(result && result.length >0){
                    this.spinLoad=false;
                this.showToastDuplicateErrorMessage('error','Error!','Error! An account matching the customer name & address you entered has been found. You can’t submit this new request as it is a duplicate.');
                    this.showDuplicates=true;
                    this.duplicates=result;
                    console.log('DuplicateRecordS1 '+JSON.stringify(this.duplicates));
                    this.formatRecordsForDisplay();
                }else{
                    this.duplicates = [];
                if(!this.isError){
                    const fields = event.detail.fields;
                    console.log('fields 2--> '+JSON.stringify(fields));
                    fields.Address__CountryCode__s = this.addressAddress.Country;
                    fields.Address__StateCode__s = this.addressAddress.province;
                    fields.Address__Street__s = this.addressAddress.Street;
                    fields.Address__City__s = this.addressAddress.City;
                    fields.Address__PostalCode__s = this.addressAddress.postalCode;
                    fields.Core_Sales_Groups__c = this.salesGrp;
                    if (!fields.Core_Account_Level__c || fields.Core_Account_Level__c === '') {
                        fields.Core_Account_Level__c = this.accountLevel || 'NoLevel';
                    }
                    fields.Core_Account_Category__c = this.accountcategory;
                    fields['OwnerId'] = this.OwnerId;
                    //this.validateFields(event,fields);
                    this.template.querySelector('lightning-record-edit-form').submit(fields);
                        }
                }
            })
            .catch(error =>{
                this.spinLoad=false;
            console.error('Error Duplicate Check', error);
        });
        
    }

    formatRecordsForDisplay(){
        let formattedRecordsAccount=[];
        let formattedRecordsAccountRequest=[];
        this.duplicates.forEach(record =>{
            const formattedAccountRecord={
                recordacctId:'/' + record.acctId,
                acctId:record.acctId,
                accountName:record.accountName,
                accountCountry:record.accountCountry,
                acctOwner:record.acctOwner,
                unifiedGlobalCustomerName:record.unifiedGlobalCustomerName
            };
            const formattedRecordRequest={
                recordUrl:'/'+record.acctRequestId,
                acctRequestId:record.acctRequestId,
                customername:record.customername,
                acctRequestCountry:record.acctRequestCountry,
                createdDate:record.createdDate,
                requestorName:record.requestorName,
                processType:record.processType
            };
            if(record.objectName==='Account'){
                this.accountDuplicate=true;
                formattedRecordsAccount.push(formattedAccountRecord);
                console.log('@#AccountRecordcheck7 '+this.accountDuplicate);
            }
            if(record.objectName==='Account_Create_Request__c'){
                this.accountRequestDuplicate=true;
                formattedRecordsAccountRequest.push(formattedRecordRequest);
                console.log('@#AccountRequestrecordcheck6 '+this.accountRequestDuplicate);
            }
        });

        this.formattedRecordsAccount=formattedRecordsAccount;
        this.formattedRecordsAccountRequest=formattedRecordsAccountRequest;
        if(formattedRecordsAccount.length===0){
            this.accountDuplicate=false;
            console.log('@#AccountRecordcheckfalsec '+this.accountDuplicate);
        }
        if(formattedRecordsAccountRequest.length===0){
            this.accountRequestDuplicate=false;
            console.log('@#AccountRequsetcheckfalse '+this.accountRequestDuplicate);
        }
        console.log('#formattedRecordsAccount7 '+JSON.stringify(this.formattedRecordsAccount));
        console.log('#formattedRecordsAccountRequest7 '+JSON.stringify(this.formattedRecordsAccountRequest));
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
        console.log('USER_ID' + USER_ID + 'OwnerId ' + this.OwnerId)
        //Add account level validation if this is an Opportunity Management request
        if(this.selected == true && (this.OwnerId == null || USER_ID == this.OwnerId)){
            this.showToastErrorMessage('error', 'Validation Error', WarningLabel);
            this.loaded=false;
            this.isError = true;
            this.spinLoad = false;
            return;
        }
        if (this.isOpportunityManagement) {
            // Check account level rules
            const accountLevelValid = this.validateAccountLevelRules();
            if (!accountLevelValid) {
                this.isError = true;
                return; // Exit validation early since we've already shown the error toast
            }
        }

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
        console.log('DupCheck ');
    }

    get isOpportunityManagement() {
    return this.acctreasontrail === 'Opportunity Management';
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

    showToastDuplicateErrorMessage(variant,title,message){
        const eve = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message,
            mode :'sticky'
        });
        this.dispatchEvent(eve); 
    }
    // Function called on user record selection from lookup.This is the selected user record
  selectedRecord(event) {
    //this.spinner = !this.spinner;
    if (event.detail.recordId != null || USER_ID != null) {
      //Selected user record Id
      this.OwnerId = event.detail.recordId ? event.detail.recordId : USER_ID;
      //To populate account list on user select from lookup search
      console.log('OwnerId ', this.OwnerId);
      userFields({
        recordID: this.OwnerId
    }).then(result =>{
           if (result) {
            console.log('result', result);
            this.UserName = result.name;
            this.UserEmail = result.email;
            this.UserWWID = result.wwid;
            this.OwnerId = result.id;
        }
    }).catch(error=>{
        console.log(error);
        
    });
  }}

    validateAccountLevelRules() {
        let isValid = true;
        let errorMessage = '';
        //setting default values if null or empty
        if(this.accountcoverage == null || this.accountcoverage == '' ){
            this.accountcoverage = 'Not Covered';
        }
        // if(this.accountLevel == null || this.accountLevel == ''||this.accountLevel.toLowerCase() === 'undefined'){
        //     console.log('entering undefined check ,value:'+this.accountLevel);
        //      this.accountLevel = 'NoLevel';
        // }
        
        const coverage = (this.accountcoverage || '').trim();
        const salesGroup = (this.salesGrp || '').trim();
        const level = (this.accountLevel || '').trim();
        const isLevel12 = lvl => ['Level1', 'Level 1', 'Level2', 'Level 2'].includes(lvl);
        const isLevel2 = lvl => [ 'Level2', 'Level 2'].includes(lvl);
        const isLevel123 = lvl => ['Level1', 'Level 1', 'Level2', 'Level 2', 'Level3', 'Level 3'].includes(lvl);
        const isNoLevel = lvl =>  ['No Level', 'NoLevel'].includes(lvl);

        
        // Rule 1 & 2: If Account Primary Coverage is Intel Covered (and not Partner Led), Account level must be Level1/2
        if (coverage === 'Intel Covered') {
            if (salesGroup.toLowerCase() === 'undefined' || !salesGroup) {
                if (!isNoLevel(level)) {
                    isValid = false;
                    errorMessage = this.label.UCD_ACM_Intel_Covered_Undefined_SalesGroup;
                }
            } else {
                const isPartnerLed = salesGroup.toLowerCase().includes('partner led');
                if (!isPartnerLed) {
                    if (!isLevel12(level)) {
                        isValid = false;
                        errorMessage = this.label.UCD_ACM_Intel_Covered_NotPartnerLed_SalesGroup;
                    }
                } else if(isPartnerLed) {
                    if (!isLevel2(level)) {
                        isValid = false;
                        errorMessage = this.label.UCD_ACM_Intel_Covered_PartnerLed_SalesGroup;
                    }
                }
            }
        }
        // If validation fails, show error message
        if (!isValid) {
            this.showToastErrorMessage('error', 'Validation Error', errorMessage);
            console.log('Account level validation failed:', errorMessage);
        }

        
        return isValid;
    }

    validateUserSelection(){
        var isValid = true;
        var errorMessage;
        if(this.selected == true && (this.OwnerId == null || USER_ID == this.OwnerId)){
            isValid = false;
            errorMessage = WarningLabel;        
        }
        // If validation fails, show error message
        if (!isValid) {
            this.showToastErrorMessage('error', 'Validation Error', errorMessage);
        }

        
        return isValid;
    }

    renderedCallback() {
        setTimeout(() => {
            const levelField = this.template.querySelector('.AccountLevel');
            const coverageField = this.template.querySelector('.AccountCoverage');
            if (levelField) {
                if (this.acctreasontrail !== 'Opportunity Management') {
                    // For non-Opportunity Management requests, lock both fields
                    levelField.value = 'NoLevel';
                    levelField.disabled = true;
                    
                    if (coverageField) {
                        coverageField.value = 'Not Covered';
                        coverageField.disabled = true;
                    }
                } else {
                    // For Opportunity Management, apply the existing logic
                    if (this.accountcoverage === 'Not Covered') {
                        levelField.value = 'NoLevel';
                        levelField.disabled = true;
                    } else if (this.accountcoverage === 'Indirect Covered') {
                        levelField.value = 'Level3';
                        levelField.disabled = true;
                    } else {
                        levelField.disabled = false;
                    }
                }
            }
        }, 0);
    }
    
}