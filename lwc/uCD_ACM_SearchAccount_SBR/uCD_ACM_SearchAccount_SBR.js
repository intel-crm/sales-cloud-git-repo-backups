import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import State_FIELD from '@salesforce/schema/Account.BillingStateCode';
import Country_FIELD from '@salesforce/schema/Account.BillingCountryCode';
//import Cpe_FIELD from '@salesforce/schema/Account.Core_Customer_Process_Engg__c';
//import BizOrg_FIELD from '@salesforce/schema/Account.Core_Account_Type__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import findAccounts from '@salesforce/apex/UCD_AccountConnector_SBR.findAccounts';
//import getCimResults from "@salesforce/apex/UCD_AccountConnector.getDuplicateAccountDetails";
import getAcctResults from "@salesforce/apex/UCD_GenericAcctSearch_SBR.getAcctResults";
import showFields from "@salesforce/apex/UCD_GenericAcctSearch_SBR.showFields";
import getCustomerProcesEngg from "@salesforce/apex/UCD_GenericAcctSearch_SBR.getCustomerProcesEngg";
import fetchIdentifiers from "@salesforce/apex/UCD_GenericAcctSearch_SBR.fetchIdentifiers";
import { updateRecord } from 'lightning/uiRecordApi';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import ACCOUNT_ID from '@salesforce/schema/Account.Id';     
import ISACTIVE_FIELD from '@salesforce/schema/Account.Core_Deactivated__c';    
import ISDEACTIVEREASON_FIELD from '@salesforce/schema/Account.Core_Deactivation_Reason__c';    
import RECORDTYPE_FIELD from '@salesforce/schema/Account.RecordTypeId'; 
import NEWREG_OBJECT from '@salesforce/schema/PRM_Registration_Request__c';
import {NavigationMixin} from 'lightning/navigation';
import findAccountOwners from "@salesforce/apex/UCD_AccountConnector_SBR.findAccountOwners";
//import { getRecord } from 'lightning/uiRecordApi';
import getAccountCreateReq from '@salesforce/apex/UCD_GenericAcctSearch_SBR.getAccountCreateReq';

const FIELDS = [
    'Account_Create_Request__c.Account_Name__c',
    'Account_Create_Request__c.Country__c',
    'Account_Create_Request__c.Customer_Process_Engagement__c',
];

export default class UCD_ACM_SearchAccount_SBR extends NavigationMixin(LightningElement) {
    @track _recordId;    
    @api isRecordPage;
    @track payload = {
        accountName: "",
        countryCode: "",
        country: "",
        customerProcessEng:"",
        customerProcessEngCode:"",
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
        tcity:"",
        cimId:"" ,
        Name:"",
        BillingStreet : "",
        BillingCity : "",
        BillingStateCode : "",
        BillingCountryCode : "",
        Core_CIM_ID__c: "",
        Core_Account_Legal_Name__c: "",
        tableData:"",
        stateOpt:""
    };
	@api payloadNew = {
        Name: "",
        BillingStreet : "",
        BillingCity : "",
        BillingStateCode : "",
        BillingCountryCode : "",
        Core_CIM_ID__c: "",
        Core_Account_Legal_Name__c: "",
        Mode:""
    };
    @track loaded = false;
    @track disableButton = false;
    @track error;
    @track stateOptions;
    @track countryOptions;
    @track cpeOptions;
    @track bizorgOptions;
    @track stateFieldData;
    @track showSearch = false;
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
    //@track isModalLanguageOpen = false;
    @track nospecialchar = false;
    @track openDupComp = false;
    @track nonLatinExp = /[^\u0000-\u007F ]+/;

    @track noAccessToObject = false; 

     // wire method to get if any existing account with same billing address
    @wire(findAccounts, { bStreet1: '$street1', bStreet2: '$street2'})
    accounts({data,error}){
        if(data){
            this.records = data;
            this.errors = undefined;
            this.isAddrExists = this.records.length > 0 ? true : false; }
        if(error){
            this.errors = error;
            this.records = undefined;
        }
    }
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
     AccountInfo;
    @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: State_FIELD })
    stateFieldInfo(result) {
           this.stateFieldData = result;
    }

    @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: Country_FIELD })
    countryFieldInfo({ data, error }) {
        
        if (data) {
            console.log('data.values--> ',JSON.stringify(data.values));
            this.countryOptions = data.values;
            console.log('this.countryOptions--> ',this.countryOptions);
        }
    }
   
    @wire(findAccountOwners, { cimId: '$selectedCIMID', 
                                rId: '$selectedAcctID'} 
    )
    accountsOwner({
        data,error
    }){
        if(data){
        }
        if(error){
        }
    }

    @api get recordId(){
        return this._recordId;
    }
    set recordId(value){
        this.setAttribute('recordId',value);
        this._recordId = value;
    }
    /* @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
	  accountCreateRequest; */
    connectedCallback() {
        console.log('this.recordId--> '+this._recordId);
        console.log('isRecordPage--> '+this.isRecordPage);
        //console.log('this.acctformdetails.accountName--> ',this.acctformdetails.accountName);
        if(this.acctformdetails.accountName ===undefined ||  this.acctformdetails.accountName==''){
            console.log('Inside Connected call back '+ this.acctformdetails.accountName);
        }else{  
            console.log('this.payload--> ',this.payload);
                    this.acctformdetails.postalCode=this.payload.postalCode;
                    this.acctformdetails.BillingCity=this.payload.BillingCity;   
                    this.acctformdetails.countryCode=this.payload.BillingCountryCode;
                    this.acctformdetails.customerProcessEngCode=this.payload.customerProcessEngCode; 
                    //this.acctformdetails.customerProcessEng=this.payload.customerProcessEng; 
                    this.stateOptions=this.payload.stateOpt;
                    this.acctformdetails.stateCode=this.payload.BillingStateCode;   
                    console.log('***********'+this.payload.BillingStateCode);      
                    this.showpagination = false;
                this.searchValuesList = [];
                this.openDupComp = true;
                this.loaded = true;
                this.tableData=this.payload.tableData;
           if(this.payload.tableData === undefined){
            this.tableData = [];
           }
           if (this.tableData.length>0 && this.tableData.length != undefined) {   
                this.loaded = false;
                this.disableButton = true; 
                this.showNoData = false;
                this.showpagination = true;
            } else if(this.tableData.length == 0){
                this.showNoData = true;
                this.checkBoxFieldValue = true;
                this.showpagination = false;
                this.loaded=false;
            }          
        }
         getCustomerProcesEngg()
        .then((response) =>{
            this.cpeOptions = response;
            console.log('this.cpe-->',this.cpeOptions);
        }); 
        
        if(this.isRecordPage){
            getAccountCreateReq({recId:this._recordId})
            .then((result)=>{
                if(result != undefined){
                    console.log('result--> ',JSON.stringify(result));
                    acctformdetails.customerProcessEngCode = result.Customer_Process_Engagement__c;
                    acctformdetails.accountName = result.Account_Name__c;
                    acctformdetails.countryCode = result.Customer_Process_Engagement__c;
                }
                
            });
        } 

        fetchIdentifiers ()
        .then((response) => {
            this.idata = response;
            for (let i = 0; i < this.idata.length; i++) {
                this.identifiers.push({ label: this.idata[i].UI_Label__c, value: this.idata[i].UI_Label__c},)
            }
            this.identifiers.push({label: 'Contacts Associated', value: 'Contacts'});
        })
        .catch((error) => {
            console.log('&&&&&'+JSON.stringify(error));
        });
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
                //this.checkSpecialChar();
                this.showpagination = false;
                this.searchValuesList = [];
                this.fetchCIMResults();
            }
        /*if(this.nospecialchar == true){
           
        } */  
              
    }
    handleReest() {
        this.template.querySelector('form').reset();
    }
    
     //Method that check if the Field value contain any Non_Latin characters
   /* checkSpecialChar(){
       if(this.nonLatinArray.accname != '' || this.nonLatinArray.addressline1 != '' ||
           this.nonLatinArray.addressline2 != '' || this.nonLatinArray.city != ''){
               this.isModalLanguageOpen = true;
       }
       else{
           this.nospecialchar = true;  
           this.isModalLanguageOpen = false;         
       }
    } 
    // Method for Passing the transalted fvalues to backend.
    handleLanguageChange(event){
        this.payload.tname = event.detail.tname;
        this.payload.taddressline1 = event.detail.taddressline1;
        this.payload.taddressline2 = event.detail.taddressline2;
        this.payload.tcity = event.detail.tcity;
        //this.Navigatetodupscreen();
        this.openDupComp = true;
    }
    //Method for Closing the Non-Latin modal
    handleCloseModal(event){
        this.isModalOpen = false;
        this.isModalLanguageOpen = false;
    }*/


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
        //this.openDupComp = false;
    this.disableButton=false;
        if (event.target.name == 'country') {
            
            this.payload.country = this.countryOptions.find(opt => opt.value === event.detail.value).label;
            this.payload.countryCode = event.target.value;
            let key = this.stateFieldData.data.controllerValues[event.target.value];
            this.stateOptions = this.stateFieldData.data.values.filter(opt => opt.validFor.includes(key));
            const startSelect = this.template.querySelector('.start-select');
            if (startSelect) {
                startSelect.value = '';
            }  
            this.payload.stateCode = '';
            this.payload.state = '';
        }
        if (event.target.name == 'state') {          
            this.payload.stateCode = event.target.value;
            this.payload.state = this.stateOptions.find(opt => opt.value === event.detail.value).label;
        }

        if(event.target.name =='cpe'){
            console.log('event.target.value--> '+event.target.value);
            this.payload.customerProcessEng = this.cpeOptions.find(opt => opt.value === event.detail.value).label;
            this.payload.customerProcessEngCode = event.target.value;

        }
        console.log('this.payload.customerProcessEng--> '+this.payload.customerProcessEng);
    }
    nameChangeHandler(event) {
       // this.openDupComp = false;
        this.disableButton = false;  
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
        //this.openDupComp = false;
    this.disableButton=false;
                this.payload.city = event.target.value;
                this.nonLatinArray.city ='';
                if(this.payload.city.match(this.nonLatinExp)){
                    //this.iscityspecial = true; 
                    this.nonLatinArray.city = this.payload.city;     
                }
            }	
    postalChangeHandler(event) {	
       // this.openDupComp = false;
    this.disableButton=false; 
                this.payload.postalCode = event.target.value;              
            }
    addr1ChangeHandler(event) {	
       // this.openDupComp = false;
            this.disableButton=false; 
                        this.payload.addressline1 = event.target.value;
                this.street1 = event.target.value;
                if(this.payload.accountName === undefined || this.payload.accountName === ''){
                    event.target.value = '';
                    this.showToastMessage(this.validatorMessage,this.warningVariant,this.dismissableMode);
                }
                else{
                    this.isAddrName = event.target.value.toLowerCase().includes(this.payload.accountName.toLowerCase()) ? true : false;
                }
                
                this.fullStreet = this.payload.addressline1 +" " +this.payload.addressline2;
                this.nonLatinArray.addressline1 ='';
                if(this.payload.addressline1.match(this.nonLatinExp)){
                    //this.isadd1special = true;  
                    this.nonLatinArray.addressline1 = this.payload.addressline1;     
                }
            }      
    addr2ChangeHandler(event) {	
       // this.openDupComp = false;
    this.disableButton=false; 
                this.payload.addressline2 = event.target.value;
                this.street2 = event.target.value;
                this.fullStreet =  this.payload.addressline1 +" " +this.payload.addressline2;
                if(this.payload.accountName === undefined || this.payload.accountName === ''){
                    event.target.value = '';
                    this.showToastMessage(this.validatorMessage,this.warningVariant,this.dismissableMode);
                }
                else{
                    this.isAddrName2 = event.target.value.toLowerCase().includes(this.payload.accountName.toLowerCase()) ? true : false;
                }
                //this.isAddrName2 = event.target.value.toLowerCase().includes(this.payload.accountName.toLowerCase()) ? true : false;
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
            this.addressline1=this.payload.addressline1;
            this.addressline2=this.payload.addressline2;            
        }
    }

/*************************************************************************************/


    @track recordsToDisplay = []; //Records to be displayed on the page
    @track showpagination = false;
    @track showNoData = false; 
    @track checkBoxFieldValue;
    @track disabledCondition = true;
    @track primaryAddress;  
    @track accrecId;    

    // Variables for fetching selected row data from table  
    @track seletedRowData;  
    @track selectedValue; 
    @track selectedAcctID;
    @track selectedCIMID;

    //variables to change owner
    @track isSFCIM = false;
    @track cimIdA = '';
    @track recIdA = '';
    @track isValidUser = false;
    @track isModalOpen = false;
    @track currUser = '';

    //variables to show account details in modal    
    @track ShowModal = false;   
    @api recId; 
    @api recName;

    //variables for fetching rectordtype from   
    @track recordTypeName ; 
    @track checkRecType = false;
    @track accountdeactivereason ='';
    @track inActiveRecordtypeId;
    @track accountactive = false;

    //Variable to capture list of searchvalues to be send to CIM
    @track searchValuesList= [];

    //Method to get the record type for New Registration custom object
@wire(getObjectInfo, { objectApiName: NEWREG_OBJECT })
accObjectInfo2({data, error}) {
    if(data) {
        const rtInfos2 = data.recordTypeInfos;
        let rtValues2 = Object.values(rtInfos2);
        for(let i = 0; i < rtValues2.length; i++) {
            if(rtValues2[i].name == 'Account Create Request') {
                this.selectedValue = rtValues2[i].recordTypeId;
            }       
        }
    }
    else if(error) {
        window.console.log('Error ===> '+JSON.stringify(error));
    }
}
// Method to get the Record type id for scenario where deactivated accounts record type will be changed 
@wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT }) 
accObjectInfo({data, error}) {  
    if(data) {  
        const rtInfos = data.recordTypeInfos;   
        let rtValues = Object.values(rtInfos);   

        for(let i = 0; i < rtValues.length; i++) {  
            if(rtValues[i].name === 'Intel Account') {
                this.checkRecType = false;  
                this.recordTypeName = rtValues[i].recordTypeId; 
            }   
            else if(rtValues[i].name === 'Inactive Account'){   
                this.inActiveRecordtypeId= rtValues[i].recordTypeId;
            }   
        }   
    }   
    else if(error) {  
        this.noAccessToObject = true;  
        window.console.log('Error ===> '+JSON.stringify(error)); 
        console.log('Account object')   
    }   
}


    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
    }

    
    
    handleSearchChange(event) {
        console.log('SEARCHRESULT'+event.detail);
        if(event.detail != 'NoRecords'){
        this.showpagination = false;
        //this.loaded = true;   
        this.tableData = event.detail;    
         this.template.querySelector('c-ucd-pagination').setRecordsToDisplayTest(event.detail,event.detail.length);
         this.showpagination = true;
         // this.loaded = false;
         //setRecordsToDisplayTest(this.recordsToDisplay.length);
        }
        else if(event.detail == 'NoRecords'){
          this.showpagination = false;         
          this.fetchCIMResults();
         // this.handleFilterClick();
        }
      }
      // Wrapper to send data to CIM
    addSearchValues (fieldAPINameP,fieldLabelP,fieldValueP){
        let searchValues = {
            fieldAPIName : fieldAPINameP,
            fieldLabel : fieldLabelP,
            fieldValue : fieldValueP
        };
        this.searchValuesList.push(searchValues);
    }
    //Method to send data to CIM
    fetchCIMResults(){
        this.openDupComp = true;
        this.loaded = true;
        this.searchValuesList = [];
        if(this.acctformdetails){
            this.addSearchValues('Name','Name',this.acctformdetails.accountName);
            this.addSearchValues('BillingStreet','BillingStreet',);
            this.addSearchValues('BillingCity','BillingCity',);
            this.addSearchValues('BillingCountry','BillingCountry',this.acctformdetails.country);
            this.addSearchValues('BillingState','BillingState',this.acctformdetails.state);
            this.addSearchValues('BillingPostalCode','BillingPostalCode',);
            //this.addSearchValues('Core_Account_Type__c','Biz Org Type','');
            //this.addSearchValues('Core_Account_Tier__c','Account Tier','');
            //this.addSearchValues('Industry','Industry','');
            //this.addSearchValues('Core_Intel_Partner_Alliance_PartnerGroup__c','IPA Account','');
            //this.addSearchValues('core_deactivated__c','Deactivated','');
            this.addSearchValues('Core_IPA_Partner_Role__c','Partner Role','');
            this.addSearchValues('RecordTypeId ','RecordtypeId','');
            this.addSearchValues('OwnerId','Owner','');
            this.addSearchValues('Core_CIM_ID__c','CIM ID','');

            for (let i = 0; i < this.idata.length; i++) {
               this.addSearchValues( this.idata[i].API_Name__c,this.idata[i].UI_Label__c,'');
            }
           /* this.addSearchValues('Core_IPS_Active__c','IPS Active','');
            this.addSearchValues('Core_Account_BU_Focus__c','Account BU Focus','');
            this.addSearchValues('core_b2b_entitlement__c','B2B Entitlement','');*/
        }
        console.log('addSearchValues--> ',this.addSearchValues);
        console.log('this.searchValuesList--> '+this.searchValuesList);
        if(this.searchValuesList){
            getAcctResults({
                fDetails: this.searchValuesList
            })
            .then((response) => {
                this.data = response;
                console.log('YYYYYYYYYYY'+JSON.stringify(this.data));
               // this.tableData = response;
                if (this.data.length>0) {   
                    this.tableData = response;              
                    this.loaded = false;
                    this.disableButton = true; 
                    this.showNoData = false;
                    this.showpagination = true;
                    this.showSearch = true;  
                    this.identifiersHeaders=[]; 
                    this.cGvalue=[];  
                    this.showContacts= false;          
                } else {
                    this.showNoData = true;
                    this.checkBoxFieldValue = true;
                    this.showpagination = false;
                    this.loaded=false;
                    this.showSearch = false;
                }
            })
            .catch((error) => {
               // this.showToastMessage(error.body.message,'error','dismissable');
                if ( error.body.message == 'Invalid conversion from runtime type Boolean to String'){
                    this.showToastMessage('Kindly check the ischeckbox attribute in custom setting for Checkbox fields',this.errorVariant,'sticky');
                }
                else if (error.body.message == 'Invalid conversion from runtime type String to Boolean'){
                    this.showToastMessage('Kindly uncheck the ischeckbox attribute in custom setting for Non-Checkbox fields',this.errorVariant,'sticky');
                }
                else {
                    this.showToastMessage(error.body.message,this.errorVariant,'sticky');
                }
               
                console.log('&&&&&'+JSON.stringify(error));
            });

           
        }

    }

    /*fetchCIMResults(){
        this.openDupComp = true;
        this.loaded = true;
        var setparams = {};
        this.primaryAddress = (this.acctformdetails.addressline1 != '' ? this.acctformdetails.addressline1 + ', ' : '') + (this.acctformdetails.addressline2 != undefined ? this.acctformdetails.addressline2 + ' , ' : '') + (this.acctformdetails.country != '' ? this.acctformdetails.country + ' , ' : '') +
            (this.acctformdetails.state != undefined ? this.acctformdetails.state + ' , ' : '') + (this.acctformdetails.city != '' ? this.acctformdetails.city + ' , ' : '') + (this.acctformdetails.postalCode != '' ? this.acctformdetails.postalCode + ' ' : '');
        setparams.accName = this.acctformdetails.accountName;
        setparams.accAddr = this.acctformdetails.addressline1;
        setparams.accCity = this.acctformdetails.city;
        setparams.accCountry = this.acctformdetails.country;
        setparams.accStateProvince = this.acctformdetails.state;
        //await getCimResults({
        getCimResults({
            accountDetails: setparams
        })
            .then((response) => {
                this.data = response;
                this.tableData = response;
                console.log('&&&&&'+JSON.stringify(this.tableData));
                if (this.data.length>0) {                 
                    this.loaded = false;
                    this.disableButton = true; 
                    this.showNoData = false;
                    this.showpagination = true;
                } else {
                    this.showNoData = true;
                    this.checkBoxFieldValue = true;
                    this.showpagination = false;
                }
                //this.showpagination = true;
            })
            .catch((error) => {
                this.showToastMessage(JSON.stringify(error),'error','dismissable');
                
            });
        //this.setPages(this.data);
    }*/

    // Method called on selecting a account record from table
    checkBoxSelectionHandler(event) {
        this.currUser = event.target.placeholder;
        this.isValidUser = this.currUser != 'Uncovered Account' && this.currUser != undefined && event.target.checked ? true : false; 
        if (!event.target.checked) {
            this.disabledCondition = true;
            this.selectedCIMID = '';
            this.selectedAcctID = '';
        }
        else if (event.target.checked) {
            this.disabledCondition = false;
            let selectedRows = this.template.querySelectorAll('lightning-input');
            for (let i = 0; i < selectedRows.length; i++) {
                if (selectedRows[i].checked && selectedRows[i].type === 'checkbox' && (selectedRows[i].value != event.target.value || selectedRows[i].name != event.target.name)) {             
                    selectedRows[i].checked = false;
                }                             
            }
            this.selectedAcctID =  event.target.name;
            this.selectedCIMID= event.target.value;     
        }  
    }


    //Below method is for the checkbox below the table for creating the new registration request record
    handleCheckBoxChange(event){
        this.checkBoxFieldValue = event.target.checked;       
        if (event.target.checked) {
            this.isValidUser = false;
            this.disabledCondition = false;
            this.template.querySelectorAll('[data-element="subscribe-checkbox"]')
            .forEach(element => { element.checked = false; element.disabled = true;});
            this.selectedCIMID = '';
            this.selectedAcctID = '';
        }
        else if (!event.target.checked) {
            this.disabledCondition = true;
            this.template.querySelectorAll('[data-element="subscribe-checkbox"]')
            .forEach(element => { element.disabled = false;});
        }
    }

     // Method called on click of salesforce ID on table to display the account details
    handleRowAction(event){
        this.recId = event.target.title;
        this.recName = event.target.label;
        this.ShowModal = true;  
    }
    openModal() {
        this.isModalOpen = true;
    } 
    //Method to Account details close Modal
    closeModal() {
        this.ShowModal = false;
        this.isModalOpen = false;
        //this.isModalLanguageOpen = false;
    }

    // Method called on click of Next button
    onNextClickHandler(event) {
        let i;
        if(this.selectedCIMID != undefined && this.tableData != undefined){
            this.seletedRowData = this.tableData.find(opt => opt.cimID === this.selectedCIMID);   
        }
        if(this.selectedAcctID != undefined && this.tableData != undefined){
            this.seletedRowData = this.tableData.find(opt => opt.accId === this.selectedAcctID); 
        }
        if(this.seletedRowData != undefined && !this.checkBoxFieldValue){          
            if (this.seletedRowData.sourceSystemCIM == false) {
               this.accrecId = this.seletedRowData.accId;
               this.loaded = true;
               this.isSFCIM = true;              
               /*if( this.seletedRowData.RecordTypeId === this.inActiveRecordtypeId){
                   this.activateSalesCloudAccount();                
               }*/
               this.navigateToViewAccountPage();
              
            } else {
               this.createAccountBasedOnCIMData();           
            }
        }
        if(this.checkBoxFieldValue){
            //this.createAccount();
            this.createAccountBasedOnUserData();   
        }  
    }
    

    //Method to activate the sales cloud account    
    /*activateSalesCloudAccount(){        
        const fields = {};
                   fields[ACCOUNT_ID.fieldApiName] = this.seletedRowData.accId;
                   fields[RECORDTYPE_FIELD.fieldApiName] = this.recordTypeName;
                   fields[ISACTIVE_FIELD.fieldApiName] = this.accountactive;    
                   fields[ISDEACTIVEREASON_FIELD.fieldApiName] = this.accountdeactivereason;
                   const recordInput = { fields };
                    updateRecord(recordInput)   
                    .then(() => {   
                        //this.showSuccessToast('Account has been activated');  
                        this.navigateToViewAccountPage();           
                    })  
                    .catch((error) => { 
                        //this.showErrorToast(error);       
                    }); 
    }*/

    //Below method is used to show the Account create pop up by pre-populating the user entered values
    /*createAccount(){
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "PRM_Registration_Request__c",
                actionName: "new"
            },
            state: {
                nooverride: "1",
                recordTypeId: this.selectedValue,
                defaultFieldValues:encodeDefaultFieldValues({
                    PRM_Account_Name__c:this.acctformdetails.accountName,
                    Name:this.acctformdetails.accountName,
                    PRM_Address_Line_1__c : this.acctformdetails.addressline1,
                    PRM_Address_Line_2__c: this.acctformdetails.addressline2,
                    PRM_Phy_Address_Line_1__c : this.acctformdetails.addressline1,
                    PRM_Phy_Address_Line_2__c: this.acctformdetails.addressline2,
                    PRM_City__c : this.acctformdetails.city,
                    PRM_Phy_City__c : this.acctformdetails.city,
                    PRM_Phy_State_Province__c : this.acctformdetails.state,
                    PRM_State_Province__c : this.acctformdetails.state,
                    //PRM_Country__c : this.acctformdetails.countryCode,
                    //PRM_Phy_Country__c : this.acctformdetails.countryCode,
                    PRM_Zip_Postal_Code__c : this.acctformdetails.postalCode,
                    //OwnerId: this.acctformdetails.ownerId,
                    PRM_First_Name__c : this.acctformdetails.tname,  
                    PRM_Last_Name__c : this.acctformdetails.taddressline1,   
                    //Core_Alt_Address_2__c : this.acctformdetails.taddressline2,   
                    //Core_Alt_Language_City__c : this.acctformdetails.tcity
                    PRM_First_Name__c: 'Test FirstName',
                    PRM_Last_Name__c: 'LastName',
                    PRM_Email_ID__c: 'test@test.com'
                })
            }
        });
    }*/

    //Below method is used to show the Account create pop up by pre-populating the values of CIM Data from Table
    createAccountBasedOnCIMData(){
        console.log('In createAccountBasedOnCIMData');
        console.log('Selected Row data is'+ JSON.stringify(this.seletedRowData));
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Account",
                actionName: "new",
            },
            state: {
                nooverride: "1",
                defaultFieldValues:encodeDefaultFieldValues({
                    Name:this.seletedRowData.accName,
                    BillingStreet : this.seletedRowData.address,
                    BillingCity : this.seletedRowData.City,
                    BillingStateCode : this.seletedRowData.StateCode,
                    BillingCountryCode : this.seletedRowData.CountryCode,
                    BillingPostalCode  : this.seletedRowData.postalCode,
                    Core_CIM_ID__c: this.seletedRowData.cimID,
                    Core_Account_Legal_Name__c: this.seletedRowData.accName,
                    RecordTypeId: '0122i000000D9IoAAK',
                })
            }
        });
    }

    //Method added as per user story US791779 allowing user to create Account and not New Registration request
    createAccountBasedOnUserData(){
        console.log('acctform details are '+JSON.stringify(this.acctformdetails));
        this.payload.Name= this.acctformdetails.accountName;
        if(this.acctformdetails.addressline1!=undefined){this.payload.BillingStreet=this.acctformdetails.addressline1}
        if(this.acctformdetails.addressline2!=undefined){this.payload.BillingStreet=this.payload.BillingStreet+' '+this.acctformdetails.addressline1}
        this.payload.BillingCity =  this.acctformdetails.city;
        this.payload.BillingStateCode = this.acctformdetails.stateCode;
        this.payload.BillingCountryCode = this.acctformdetails.countryCode;
        this.payload.customerProcessEngCode=this.acctformdetails.customerProcessEngCode;
        this.payload.customerProcessEng=this.acctformdetails.customerProcessEng;
        this.payload.postalCode=this.acctformdetails.postalCode;
        this.payload.tableData=this.tableData;
        this.payload.stateOpt=this.stateOptions;
        console.log('table data is '+JSON.stringify(this.tableData));
        this.navigateToCreateAcctscreen();
    }

    // Method to navigate to the respective account view page
    navigateToViewAccountPage(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
              recordId: this.accrecId,
              objectApiName: 'Account',
              actionName: 'view',
              //recordTypeId:'0122i000000D9IoAAK'
            },
            state: { 
                defaultFieldValues:encodeDefaultFieldValues({
                    recordTypeId: '0122i000000D9IoAAK'
                }),
            }
          });
    }
	
	 //Method to navigate to the duplicateinfo screen 
     navigateToCreateAcctscreen(){
        const acctSearchNextClick = new CustomEvent("acctsearchnextclick", { detail: this.payload });
        this.dispatchEvent(acctSearchNextClick);
}

@track expanded = false;
@track dropclass = "checkboxes";
@track cGvalue = [''];
/*@track showIPA = false;
@track showIPS = false;
@track showB2B = false;
@track showABM = false;*/
@track showContacts = false;
@track idata;
@track identifiers =[];
@track identifiersHeaders = [];
showCheckboxes(){
    console.log('showCheckboxes--> ');
    var dropdown= this.template.querySelector("checkboxes");
    console.log('dropdown--> ',dropdown);
    if (!this.expanded) {
        this.dropclass = "showdropbox";
        this.expanded = true;
    } else {
        this.dropclass = "checkboxes";
        this.expanded = false;
    }
    console.log('this.dropclass--> ',this.dropclass);
}

get options() {
     return this.identifiers;  
    /*[
        { label: 'IPA', value: 'IPA' },
        { label: 'IPS', value: 'IPS' },
        { label: 'BU Focus', value: 'ABM' },
        { label: 'B2B', value: 'B2B' },
        { label: 'Contacts Associated', value: 'Contacts' },        
    ];*/
}



cGroupChange(e){
    console.log('EEEEEEEEEEE '+JSON.stringify(e.detail));
    this.cGvalue = e.detail.value;
   /* if(e.detail.value.includes("IPA"))
        this.showIPA = true;
    else
        this.showIPA = false;
    if(e.detail.value.includes("IPS"))
        this.showIPS = true;
    else
        this.showIPS = false;
    if(e.detail.value.includes('B2B'))
        this.showB2B = true;
    else
        this.showB2B = false;
    if(e.detail.value.includes('BU Focus'))
        this.showABM = true;
    else
        this.showABM = false;*/
    if(e.detail.value.includes('Contacts'))
        this.showContacts = true;
    else
        this.showContacts = false; 
}

showColumnButton(){
    this.loaded = true;
    this.showpagination = false;
    this.showSearch = false;
    this.dropclass = 'checkboxes';
    this.expanded = false;
 
    if(this.searchValuesList && this.cGvalue){
        showFields({
            accDetails: this.tableData,
            colList:this.cGvalue
        })
        .then((response) => {
            console.log('IIIIIIIIIIIIIIIIII'+JSON.stringify(response));
                this.tableData = response;              
                this.loaded = false;
                this.showpagination = true;
                this.showSearch = true;
                for(let k=0;k< this.tableData.length;k++){
                    this.identifiersHeaders=[];
                    for(let j=0;j<this.tableData[k].addColList.length;j++){
                        if(this.tableData[k].addColList[j].showColumn == true){
                            this.identifiersHeaders.push(this.tableData[k].addColList[j].UILabel); 
                        }                                                 
                    }
                }
                console.log('()()(())'+JSON.stringify(this.tableData));
          
        })
        .catch((error) => {
            //this.showToastMessage(JSON.stringify(error),'error','dismissable');
            console.log('&&&&&'+JSON.stringify(error));
        });
    }

}

cancelColumnButton(){
    this.dropclass = 'checkboxes';
    this.expanded = false;
}

get selectedcGValues() {
    return this.cGvalue.join(',');
}

}