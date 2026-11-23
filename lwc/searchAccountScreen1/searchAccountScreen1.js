import { LightningElement,api,wire,track } from 'lwc';
import {NavigationMixin,CurrentPageReference} from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from "lightning/uiRecordApi"; 

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import State_FIELD from '@salesforce/schema/Account.BillingStateCode';
import Country_FIELD from '@salesforce/schema/Account.BillingCountryCode';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAcctResults from "@salesforce/apex/UCD_GenericAcctSearch_SBR.getAcctResults";
import Req_Acc_Name from '@salesforce/schema/Account_Create_Request__c.Account_Name__c';
import Alt_Language_Name from '@salesforce/schema/Account_Create_Request__c.Core_Alternate_Language_Name__c';
import Website from '@salesforce/schema/Account_Create_Request__c.Website__c';
import proType from '@salesforce/schema/Account_Create_Request__c.Process_Type__c';
import callSubmitFlow from "@salesforce/apex/UCD_GenericAcctSearch_SBR.callSubmitFlow";

const fields = [Req_Acc_Name,Alt_Language_Name,Website,proType];

const columns = [
     { 
        label: 'Account Name', 
        fieldName: 'recordUrl', 
        type :'url',
        typeAttributes: {label: {fieldName: 'accName'},
        target: '_blank'},
        initialWidth: 170,
    },
    { label: 'Unified Hierarchy', fieldName: 'unifiedHierarchy',initialWidth: 150,},
    { label: 'Unified Id', fieldName: 'bpId',initialWidth: 150,},
    { label: 'Unified Customer Type', fieldName: 'customerAggregationCode',initialWidth: 170,},
    { label: 'Address', fieldName: 'address',initialWidth: 170,},
    { label: 'Unified Customer URL', fieldName: 'Website',initialWidth: 160,},
    { label: 'Associated Unified Global', fieldName: 'unifiedGlobalCustomer',initialWidth: 150,},
    { label: 'Sales group', fieldName:'salesGroupCode',initialWidth: 150,},
    { label: 'Account Owner', fieldName: 'accOwner',initialWidth: 150,},
];

export default class SearchAccountScreen1 extends NavigationMixin(LightningElement) {
    // All Variables
    @track data=[];
    tableData=[];
    @track treeItems = [];
    columns = columns;
    @track _recordId; 
    @track checkBoxFieldValue = false;
    @track setSelectedRows = [];
    @track showpagination = false;
    @track error = false;
    @track isValidUser = true;
    @track isOpportunity = false;
    @track isOther = false;
    @track noAccessToObject = false;
    @track stateFieldData;
    @track countryOptions;
    @track stateOptions;
    @track searchAccountData = {
        customerName : '',
        customerWebsite:'',
        nonLatin:'',
        addLine1:'',
        addLine2:'',
        city:'',
        countryCode:'',
        stateCode:'',
        zipCode:'',
        cpe:'',
        country:'',
        state:'',
        street:''
    }
    @track searchValuesList= [];
    @track loaded = false;
    @track showModalLoading = false;
    @track openDupComp = false;
    @track disableNext = true;
    @track disableReUse = true;
    @track recordsCount = 0;
    @track selectedRecords = []; 
    @track selectedRecordsData 
    @track isShowModal = false;
    @track value;
    
    @track cpeOptions = [];
    lstCPESelected = [];
    processType;

    @track customerName;
    @track customerWebsite;
    @track countryCode;
    @track stateCode;
    @track country;
    @track state;
    @track preSelectedRows = [];
    @track street;
    @track isRequired=true;
    @track isNotRequired = false;
    @api acctreasontrail;
    @api isRecordPage;
    @api intelRecordTypeId;
    showBIReport = false;
    @api pageReference;

    // Wire Methods
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
     AccountInfo;
     @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: Country_FIELD })
     countryFieldInfo({ data, error }) {
         
         if (data) {
             this.countryOptions = JSON.parse(JSON.stringify(data.values));
             let noneCountry = {"attributes":null,"label":"--None--","validFor":[],"value":"None"};
             this.countryOptions.unshift(noneCountry);
             console.log('countryOptions',JSON.stringify(data.values));
             console.log('countrytry',this.countryOptions);
 
         }
     }
 
    @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: State_FIELD })
    stateFieldInfo(result) {
           // this.stateFieldData = JSON.stringify(result.values);
           this.stateFieldData = result;
           console.log('stateFieldData',this.stateFieldData.values);

    }


    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    accountReq({error,data}){
        if(data != undefined){
            this.customerName = data.fields.Account_Name__c.value;
            this.processType = data.fields.Process_Type__c.value;
            console.log('processType'+this.processType);
        }
        
    }

    @wire(CurrentPageReference) 
    pageReference;

    connectedCallback(){
        if (this.pageReference) {
            if (this.pageReference.type === 'standard__recordPage') {
                this.showBIReport = true;
            }
        }
        console.log('this.acctreasontrail'+this.acctreasontrail);
    }
        
    @wire(getObjectInfo, { objectApiName: 'Account_Create_Request__c' })
        objectInfo({error,data}){
            if(data){
                
                //
            }
        }

    @api get recordId(){
        return this._recordId;
    }
    set recordId(value){
        this.setAttribute('recordId',value);
        
        this._recordId = value;
    }

    // 
    textInputChangeHandler(event){
        if(!this.isRecordPage){
            if(event.target.name == 'name'){
                this.searchAccountData.customerName = event.target.value;
            }
            if(event.target.name == 'website'){
                this.searchAccountData.customerWebsite = event.target.value;
            }
            if(event.target.name == 'nonLatin'){
                this.searchAccountData.nonLatin = event.target.value;
            }
            if(event.target.name == 'addLine1'){
                this.searchAccountData.addLine1 = event.target.value;
            }
            if(event.target.name == 'addLine2'){
                this.searchAccountData.addLine2 = event.target.value;
            }
            if(event.target.name == 'country'){
                this.countryCode = event.target.value;
            }
            if(event.target.name == 'state'){
                this.stateCode = event.target.value;
            }
            if(event.target.name == 'city'){
                this.searchAccountData.city = event.target.value;
            }
            if(event.target.name == 'zipCode'){
                this.searchAccountData.zipCode = event.target.value;
            }
            if(event.target.name == 'street'){
                this.searchAccountData.street = event.target.value;
                this.isRequired = !this.searchAccountData.street;
                this.isNotRequired = !this.isRequired;
            }
        }else{
            if(event.target.name == 'name'){
                this.customerName = event.target.value;
            }
            if(event.target.name == 'website'){
                this.customerWebsite = event.target.value;
            }
            if(event.target.name == 'country'){
                this.countryCode = event.target.value;
            }
            if(event.target.name == 'state'){
                this.stateCode = event.target.value;
            }
            if(event.target.name == 'street'){
                this.street = event.target.value;
                this.isRequired = !this.street;
                this.isNotRequired = !this.isRequired;
            }
        }
        
    }

    isRowSelected(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            this.recordsCount = event.detail.selectedRows.length;
            if (this.recordsCount > 0) {
                if (this.recordsCount > 1) {
                    let selectedKey;
                    let accId = this.selectedRecords[0].accId;

                    selectedRows.forEach(function(element) {
                        if(accId !== element.accId) {
                            selectedKey = element;
                        }
                    });

                    let selectedCheckbox = [];
                    selectedCheckbox.push(selectedKey.accId);
                    this.preSelectedRows = selectedCheckbox;
                    this.selectedRecords = [];
                    this.selectedRecords.push(selectedKey);
                    event.preventDefault();
                    return;
                } else if (this.recordsCount == 1) {
                    this.selectedRecords = selectedRows;
                    this.disableReUse = false;
                }
            } else {
                this.disableReUse = true;
            }
        } else {
            this.disableReUse = true;
        }
    }

    reuseClickHandler(event){
        this.isShowModal = true;
        this.lstCPESelected =[];
        this.cpeOptions = [];
        this.selectedRecordsData = this.selectedRecords[0];
    }
    handleCPEChange(event){
        this.lstCPESelected = event.detail.value;
    }
    
    handleBackButtonClick(event){
        this.isShowModal = false;
        this.lstCPESelected = [];
        this.cpeOptions = [];
    }
    handleSubmit(event){
        this.showModalLoading = true;
        callSubmitFlow({
            recordId:this._recordId,
            accId:this.selectedRecordsData.accId,
            accName:this.selectedRecordsData.accName,
            accBpId:this.selectedRecordsData.bpId,
          // accCustomerType:this.selectedRecordsData.customerAggregationCode,
          // accCPE:this.selectedRecordsData.cpe,
          // selectedCPE:JSON.stringify(this.lstCPESelected)
        })
        .then((response) => {
            if(response){
                this.showModalLoading = false;
                this.isShowModal = false;
                this.showSuccessToast('Success','Submit Record Successfully!')
                window.location.reload();
            }
        })
        .catch((error) => {
            //console.log(error);
        });
    }

    pickListChangeHandler(event){
        if(!this.isRecordPage){
            if(event.target.name == 'country'){
                this.searchAccountData.country = this.countryOptions.find(opt => opt.value === event.detail.value).label;
                this.searchAccountData.countryCode = event.target.value;
                this.searchAccountData.stateCode = '';
                this.searchAccountData.state = '';
                let key = this.stateFieldData.data.controllerValues[event.target.value];
                this.stateOptions = this.stateFieldData.data.values.filter(opt => opt.validFor.includes(key));
                let noneState = {"attributes":null,"label":"--None--","validFor":[222],"value":"None"};
                this.stateOptions.unshift(noneState);
     
                console.log('this.stateOptions',this.stateOptions);
            }
            if (event.target.name == 'state') {          
                this.searchAccountData.stateCode = event.target.value;
                this.searchAccountData.state = this.stateOptions.find(opt => opt.value === event.detail.value).label;
            }
        }else{
            if(event.target.name == 'country'){
                this.country = this.countryOptions.find(opt => opt.value === event.detail.value).label;
                this.countryCode = event.target.value;
                this.stateCode = '';
                this.state = '';
                let key = this.stateFieldData.data.controllerValues[event.target.value];
                this.stateOptions = this.stateFieldData.data.values.filter(opt => opt.validFor.includes(key));
                let noneState = {"attributes":null,"label":"--None--","validFor":[222],"value":"None"};
                this.stateOptions.unshift(noneState);

                console.log('country'+this.countryCode);
            }
            if (event.target.name == 'state') {          
                this.stateCode = event.target.value;
                this.state = this.stateOptions.find(opt => opt.value === event.detail.value).label;
            }
        }
        
    }

    // Seach Button
     searchClickHandler(event){
        this.disableNext = true; 
        this.searchValuesList = [];
        this.error = false;
        this.loaded = true;
        this.openDupComp = false;
        console.log('country value'+this.searchAccountData.country);
        if(!this.isRecordPage){
            if(this.searchAccountData.customerName == '' || this.searchAccountData.customerName == undefined || this.searchAccountData.customerName == null || !this.searchAccountData.customerName.trim()){
                this.error = true;
                this.loaded = false;
                this.showToastMessage("Customer Name is mandatory", "error", "dismissable");
    
            }else if ((this.searchAccountData.customerName != '' || this.searchAccountData.customerName != undefined) &&
                     ((this.searchAccountData.customerWebsite == '' || this.searchAccountData.customerWebsite == undefined ||
                     this.searchAccountData.customerWebsite == null || !this.searchAccountData.customerWebsite.trim()) &&
                      (this.searchAccountData.countryCode == '' || this.searchAccountData.countryCode == undefined || this.searchAccountData.countryCode == 'None') &&
                      (this.searchAccountData.stateCode == '' ||  this.searchAccountData.stateCode == undefined || this.searchAccountData.stateCode == 'None'))){
                     
                this.error = true;
                this.loaded = false;
                this.showToastMessage("In addition to the required field(s), you need to provide the value for at least one extra field.", "error", "dismissable");
    
            }else{
                if(this.searchAccountData.countryCode == 'None'){
                    this.searchAccountData.country = '';
                }
                if(this.searchAccountData.stateCode == 'None'){
                    this.searchAccountData.state = '';
                }
                
                if(this.searchAccountData){
                    this.addSearchValues('Name','Name',this.searchAccountData.customerName);
                    this.addSearchValues('Website','Website',this.searchAccountData.customerWebsite);
                    this.addSearchValues('Core_MDM_Website__c','Core_MDM_Website__c',this.searchAccountData.customerWebsite);
                    this.addSearchValues('BillingStreet','BillingStreet',);
                    this.addSearchValues('BillingCity','BillingCity',);
                    this.addSearchValues('BillingAddress','BillingAddress',);
                    this.addSearchValues('Core_Alternate_Language_Name__c','Alternate Language Name',this.searchAccountData.nonLatin);
                    this.addSearchValues('BillingCountry','BillingCountry',this.searchAccountData.country);
                    //this.addSearchValues('BillingCountry','BillingCountry',this.countryCode1);
                    this.addSearchValues('BillingState','BillingState',this.searchAccountData.state);
                    this.addSearchValues('BillingPostalCode','BillingPostalCode',);
                    this.addSearchValues('RecordType.Name','Account Record Type',);
                    this.addSearchValues('Owner.Name','Account Owner',);
                    this.addSearchValues('Core_Customer_Aggregation_Type__c','Customer Aggregation Type',);
                    this.addSearchValues('Core_Unified_Global_Customer__c','Global Customer',);
                    this.addSearchValues('Core_CIM_ID__c','CIM ID',);
                    this.addSearchValues('Core_Sales_Groups__c','Sales Group',);

                }
            }
        }else{
            console.log('country value'+this.countryCode);
            if(this.customerName == '' || this.customerName == undefined || this.customerName == null || !this.customerName.trim()){
                this.error = true;
                this.loaded = false;
                this.showToastMessage("Customer Name is mandatory", "error", "dismissable");
            } else if ((this.customerName != '' || this.customerName != undefined) &&
                     ((this.customerWebsite == '' || this.customerWebsite == undefined ||
                     this.customerWebsite == null || !this.customerWebsite.trim()) &&
                      (this.countryCode == '' || this.countryCode == undefined || this.countryCode == 'None') &&
                      (this.stateCode == '' ||  this.stateCode == undefined || this.stateCode == 'None'))){
                     
                this.error = true;
                this.loaded = false;
                this.showToastMessage("In addition to the required field(s), you need to provide the value for at least one extra field.", "error", "dismissable");
    
            } else{

                if(this.countryCode == 'None'){
                    this.country = '';
                }
                if(this.stateCode == 'None'){
                    this.state = '';
                }
                

                this.disableReUse = true;
                this.acctreasontrail = this.processType;
                console.log('processType'+this.processType);
                
                this.addSearchValues('Name','Name',this.customerName);
                this.addSearchValues('Website','Website',this.customerWebsite);
                this.addSearchValues('Core_MDM_Website__c','Core_MDM_Website__c',this.customerWebsite);
                this.addSearchValues('BillingStreet','BillingStreet',);
                this.addSearchValues('BillingCity','BillingCity',);
                this.addSearchValues('BillingAddress','BillingAddress',);
                this.addSearchValues('BillingCountry','BillingCountry',this.country);
                this.addSearchValues('BillingState','BillingState',this.state);
                this.addSearchValues('BillingPostalCode','BillingPostalCode',);
                this.addSearchValues('RecordType.Name','Account Record Type',);
                this.addSearchValues('Owner.Name','Account Owner',);
                this.addSearchValues('Core_Customer_Aggregation_Type__c','Customer Aggregation Type',);
                this.addSearchValues('Core_Unified_Global_Customer__c','Global Customer',);
                this.addSearchValues('Core_CIM_ID__c','CIM ID',);
                this.addSearchValues('Core_Sales_Groups__c','Sales Group',);
            }
            
        }
        if(!this.error){
            if(this.searchValuesList){
                console.log('acctreasontrailsearch',+this.acctreasontrail);
                getAcctResults({
                    fDetails: this.searchValuesList,
                    requestReason: this.acctreasontrail
                })
                .then((response) => {
                    this.data = response;
                     if (this.data.length>0) {
                        var tempjson = JSON.parse(JSON.stringify(this.data).split('childAccounts').join('_children'))
                        this.treeItems = tempjson;             
                        this.loaded = false;
                        this.showpagination = true;
                    } else {
                        this.showpagination = false;
                        this.loaded=false;
                    }
                    this.openDupComp = true;
                })
                .catch((error) => {
                    this.showpagination = false;
                    this.loaded=false;
                    this.openDupComp = true;
                });
            }
        }
        
    
    }

    clearClickHandler(event){
        this.searchAccountData.customerName = '';
        this.searchAccountData.customerWebsite = '';
        this.searchAccountData.countryCode = '';
        this.searchAccountData.stateCode = '';
        this.searchAccountData.country = '';
        this.searchAccountData.state = '';
        this.customerName = '';
        this.customerWebsite = '';
        this.countryCode='';
        this.stateCode='';
        this.stateOptions = [];
    }

    addSearchValues (fieldAPINameP,fieldLabelP,fieldValueP){
        let searchValues = {
            fieldAPIName : fieldAPINameP,
            fieldLabel : fieldLabelP,
            fieldValue : fieldValueP
        };
        this.searchValuesList.push(searchValues);
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
    onNextClickHandler(event){
        if(this.checkBoxFieldValue){
            const acctSearchNextClick = new CustomEvent("acctsearchnextclick", { detail: this.searchAccountData });
            this.dispatchEvent(acctSearchNextClick);
        }else{
            alert('Work in progress');
        }
    }
    handleCheckBoxChange(event){
        this.checkBoxFieldValue = event.target.checked; 
        if(this.checkBoxFieldValue){
            this.disableNext = false;
            
            if(this.tableData.length > 0){
                const row = this.template.querySelector("lightning-datatable").getSelectedRows();
                this.setSelectedRows = [];
            }
        }else{
            this.disableNext = true;
        }
    }

    showSuccessToast(title,message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    onNewAccountClick(event) {
            const config = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            },
            state: {
                count: '1',
                nooverride: '1',
                useRecordTypeCheck: '1',
                recordTypeId: this.intelRecordTypeId,
            }
        }
        this[NavigationMixin.Navigate](config);
    }
}