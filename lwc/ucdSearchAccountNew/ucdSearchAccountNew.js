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
import { refreshApex } from '@salesforce/apex';

import findAccounts from '@salesforce/apex/UCD_AccountConnector.findAccounts';
import getCimResults from "@salesforce/apex/UCD_AccountConnector.getDuplicateAccountDetails";
import getAcctResults from "@salesforce/apex/UCD_GenericAcctSearch.getAcctResults";
import { updateRecord } from 'lightning/uiRecordApi';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import ACCOUNT_ID from '@salesforce/schema/Account.Id';     
import ISACTIVE_FIELD from '@salesforce/schema/Account.Core_Deactivated__c';    
import ISDEACTIVEREASON_FIELD from '@salesforce/schema/Account.Core_Deactivation_Reason__c';    
import RECORDTYPE_FIELD from '@salesforce/schema/Account.RecordTypeId'; 
import NEWREG_OBJECT from '@salesforce/schema/PRM_Registration_Request__c';
import {NavigationMixin} from 'lightning/navigation';

export default class UcdSearchAccountNew extends NavigationMixin(LightningElement) {

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
        tcity:"",
        cimId:"" ,
        Name:"",
        BillingStreet : "",
        BillingCity : "",
        BillingStateCode : "",
        BillingCountryCode : "",
        Core_CIM_ID__c: "",
        Core_Account_Legal_Name__c: "",
        tableData:""
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
    @track openDupComp = false;
    @track nonLatinExp = /[^\u0000-\u007F ]+/;

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
        if (data) this.countryOptions = data.values;
    }
    @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: BizOrg_FIELD })
    bizOrgFieldInfo({ data, error }) {
        if (data) this.bizorgOptions = data.values;
    } 
    //end of wire method

    async connectedCallback() {
        if(this.acctformdetails.accountName ===undefined){
            console.log('Inside Connected call back '+ this.acctformdetails.accountName);
        }
        else{
            console.log('Inside Connected call back1 '+this.acctformdetails.accountName);
            this.showpagination = false;
           this.searchValuesList = [];
           //this.fetchCIMResults();
           this.openDupComp = true;
           this.loaded = true;
           console.log('table data is'+ JSON.stringify(this.tableData));
           this.tableData=this.payload.tableData;
           if (this.tableData.length>0) {                 
            this.loaded = false;
            this.disableButton = true; 
            this.showNoData = false;
            this.showpagination = true;
        } else {
            this.showNoData = true;
            this.checkBoxFieldValue = true;
            this.showpagination = false;
            this.loaded=false;
        }
           console.log('Inside Connected call back end ');
        }
    }
    
    // method called on click on Next button
    nextClickHandler(event) {  
        console.log('^^^^NAME AFTER CHANGE IS BEFORE ^^^^^'+JSON.stringify(this.payload));
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
            this.showpagination = false;
           this.searchValuesList = [];
           this.fetchCIMResults();
        }   
              
    }
    handleReest() {
        this.template.querySelector('form').reset();
    }
    
     //Method that check if the Field value contain any Non_Latin characters
    checkSpecialChar(){
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
        //this.Navigatetodupscreen();
        this.openDupComp = true;
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
        //this.openDupComp = false;
        this.disableButton = false; 
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
            console.log('SARANYAAAAAAA'+this.payload.state);
        }
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
        this.disableButton = false;  
                this.payload.city = event.target.value;
                this.nonLatinArray.city ='';
                if(this.payload.city.match(this.nonLatinExp)){
                    //this.iscityspecial = true; 
                    this.nonLatinArray.city = this.payload.city;     
                }
            }	
    postalChangeHandler(event) {	
       // this.openDupComp = false;
        this.disableButton = false;  
                this.payload.postalCode = event.target.value;              
            }
    addr1ChangeHandler(event) {	
       // this.openDupComp = false;
                this.disableButton = false;  
                        this.payload.addressline1 = event.target.value;
                this.street1 = event.target.value;
                this.isAddrName = event.target.value.toLowerCase().includes(this.payload.accountName.toLowerCase()) ? true : false;
                this.fullStreet = this.payload.addressline1 +" " +this.payload.addressline2;
                this.nonLatinArray.addressline1 ='';
                if(this.payload.addressline1.match(this.nonLatinExp)){
                    //this.isadd1special = true;  
                    this.nonLatinArray.addressline1 = this.payload.addressline1;     
                }
            }      
    addr2ChangeHandler(event) {	
       // this.openDupComp = false;
        this.disableButton = false;  
                this.payload.addressline2 = event.target.value;
                this.street2 = event.target.value;
                this.fullStreet =  this.payload.addressline1 +" " +this.payload.addressline2;
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
            console.log('inside acctformdetails set')
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
        window.console.log('Error ===> '+JSON.stringify(error));    
    }   
}


    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
        console.log('$$$$R$' +JSON.stringify(this.recordsToDisplay));
    }

    // Wrapper to send data to CIM
    addSearchValues (fieldAPINameP,fieldLabelP,fieldValueP){
        let searchValues = {
            fieldAPIName : fieldAPINameP,
            fieldLabel : fieldLabelP,
            fieldValue : fieldValueP
        };
        this.searchValuesList.push(searchValues);
        console.log('SEARCHVALUES'+JSON.stringify(this.searchValuesList));
    }

    //Method to send data to CIM
    fetchCIMResults(){
        this.openDupComp = true;
        this.loaded = true;
        if(this.acctformdetails){
            this.addSearchValues('Name','Name',this.acctformdetails.accountName);
            this.addSearchValues('BillingStreet','BillingStreet',this.acctformdetails.addressline1);
            this.addSearchValues('BillingCity','BillingCity',this.acctformdetails.city);
            this.addSearchValues('BillingCountry','BillingCountry',this.acctformdetails.country);
            this.addSearchValues('BillingState','BillingState',this.acctformdetails.state);
            this.addSearchValues('BillingPostalCode','BillingPostalCode',this.acctformdetails.postalCode);
            this.addSearchValues('Core_Account_Type__c','Biz Org Type','');
            this.addSearchValues('Core_Account_Tier__c','Account Tier','');
            this.addSearchValues('Industry','Industry','');
            this.addSearchValues('Core_Intel_Partner_Alliance_PartnerGroup__c','IPA Account','');
            this.addSearchValues('core_deactivated__c','Deactivated','');
            this.addSearchValues('Core_IPA_Partner_Role__c','Partner Role','');
            this.addSearchValues('RecordTypeId ','RecordtypeId','');
            this.addSearchValues('OwnerId','Owner','');
            this.addSearchValues('Core_CIM_ID__c','CIM ID','');

        }

        if(this.searchValuesList){
            getAcctResults({
                fDetails: this.searchValuesList
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
                    this.loaded=false;
                }
            })
            .catch((error) => {
                //this.showToastMessage(JSON.stringify(error),'error','dismissable');
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
        console.log('#####'+JSON.stringify(event.target));
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
    }

    // Method called on click of Next button
    onNextClickHandler(event) {
        let i;
        if(this.selectedCIMID != undefined){
            this.seletedRowData = this.tableData.find(opt => opt.cimID === this.selectedCIMID);     
        }
        if(this.selectedAcctID != undefined && this.selectedCIMID != undefined){
            this.seletedRowData = this.tableData.find(opt => opt.accId === this.selectedAcctID);     
        }
        if(this.seletedRowData){          
            if (this.seletedRowData.sourceSystemCIM == false) {
               this.accrecId = this.seletedRowData.accId;
               this.loaded = true;
               this.isSFCIM = true;              
               if( this.seletedRowData.RecordTypeId === this.inActiveRecordtypeId){
                   this.activateSalesCloudAccount();                
               }
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
    activateSalesCloudAccount(){        
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
    }

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
        console.log('Selected Row data is'+ JSON.stringify(this.seletedRowData));
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Account",
                actionName: "new"
            },
            state: {
                nooverride: "1",
                defaultFieldValues:encodeDefaultFieldValues({
                    Name:this.seletedRowData.accName,
                    BillingStreet : this.seletedRowData.address,
                    BillingCity : this.seletedRowData.City,
                    BillingStateCode : this.seletedRowData.stateCode,
                    BillingCountryCode : this.seletedRowData.CountryCode,
                    Core_CIM_ID__c: this.seletedRowData.cimID,
                    Core_Account_Legal_Name__c: this.seletedRowData.accName
                })
            }
        });
                    // this.payload.Name= this.seletedRowData.accName;  
                    // this.payload.BillingStreet = this.seletedRowData.address;
                    // this.payload.BillingCity = this.seletedRowData.City;
                    // this.payload.BillingStateCode = this.seletedRowData.stateCode;
                    // this.payload.BillingCountryCode = this.acctformdetails.countryCode;
                    // console.log('payload country code is'+ JSON.stringify(this.seletedRowData));
                    // this.payload.Core_CIM_ID__c= this.seletedRowData.cimID;
                    // this.payload.Core_Account_Legal_Name__c= this.seletedRowData.accName;
                    // this.navigateToCreateAcctscreen();
    }

    //Method added as per user story US791779 allowing user to create Account and not New Registration request
    createAccountBasedOnUserData(){
        // this.payloadNew.Name= this.acctformdetails.accountName;  
        // this.payloadNew.BillingStreet = this.acctformdetails.addressline1 +'' +this.acctformdetails.addressline2;
        // this.payloadNew.BillingCity =  this.acctformdetails.city;
        // this.payloadNew.BillingStateCode = this.acctformdetails.stateCode;
        // this.payloadNew.BillingCountryCode = this.acctformdetails.countryCode;
        //this.payloadNew.Mode= "new";
        this.payload.Name= this.acctformdetails.accountName;
        this.payload.BillingStreet = this.acctformdetails.addressline1==undefined?'':this.acctformdetails.addressline1 +'' +this.acctformdetails.addressline2==undefined?'':this.acctformdetails.addressline2;
        this.payload.BillingCity =  this.acctformdetails.city;
        this.payload.BillingStateCode = this.acctformdetails.stateCode;
        this.payload.BillingCountryCode = this.acctformdetails.countryCode;
        this.payload.tableData=this.tableData;
        console.log('Before Navigate');
        this.navigateToCreateAcctscreen();
    }

    // Method to navigate to the respective account view page
    navigateToViewAccountPage(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
              recordId: this.accrecId,
              objectApiName: 'Account',
              actionName: 'view'
            },
          });
    }
	
	 //Method to navigate to the duplicateinfo screen 
     navigateToCreateAcctscreen(){
        const acctSearchNextClick = new CustomEvent("acctsearchnextclick", { detail: this.payload });
        this.dispatchEvent(acctSearchNextClick);
}

}