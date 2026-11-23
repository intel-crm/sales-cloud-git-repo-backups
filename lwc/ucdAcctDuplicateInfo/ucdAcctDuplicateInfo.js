import {
  LightningElement,
  api,
  track,
  wire
} from "lwc";
import getCimResults from "@salesforce/apex/UCD_AccountConnector.getDuplicateAccountDetails";
import createAcctInSlcld from "@salesforce/apex/UCD_AccountConnector.createNewSlsCldAccount";
import createNewRegAccount from "@salesforce/apex/UCD_AccountConnector.createNewRegAccount";
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_ID from '@salesforce/schema/Account.Id'; 
import ISACTIVE_FIELD from '@salesforce/schema/Account.Core_Deactivated__c';
import ISDEACTIVEREASON_FIELD from '@salesforce/schema/Account.Core_Deactivation_Reason__c';
import RECORDTYPE_FIELD from '@salesforce/schema/Account.RecordTypeId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import {
  NavigationMixin
} from 'lightning/navigation';

const fields = [ACCOUNT_ID, ISACTIVE_FIELD, ISDEACTIVEREASON_FIELD,RECORDTYPE_FIELD];
const tColumns = [
  {
    label: "Name",
    fieldName: "AcctName",
    type: "text",
    wrapText: true 
  },
  {
    label: "CIM ID",
    fieldName: "CimID",
    type: "text"
  },
  {
    label: "Account Id",
    fieldName: "RecordID",
    type: "button",
    typeAttributes: { 
      label: { fieldName: "RecordID" },
      name: { fieldName: "RecordID" },
      variant: 'base' 
      } 
  },
  {
    label: "Primary Address",
    fieldName: "Address",
    type: "text",
    wrapText: true
  },
  {
    label: "IPA Account",
    fieldName: "IsIPA",
    type: "boolean",
    cellAttributes:{
      "class": "slds-m-left_xx-large slds-p-left_xx-large"
    }
  },
  {
    label: "Owner ID",
    fieldName: "OwnerID"
  },
  {
    label: "Duplicate Account Status",
    fieldName: "DupStatus"
  }
];
export default class UcdAcctDuplicateInfo extends NavigationMixin(LightningElement) {
  @api acctformdetails;
 // @api accttransdetails;
  @api stepNum = "step-2";
  displayResults = false;
  acctDuplicateInfoStep = true;
  srcSystm = "cim";
  @track gridconfig = {};
  @track srcSys;
  @track primaryAddress;
  @track retVal = {
    accId: "",
    accName: ""
  };
  recrdID;
  @api objectApiName;
  @track rtValue; 
  @track Spinner = false;
  @track rsp;
  @track systemUnavailable = false;
  @track noCimRecords = false;
  @track accountsFound = true;
  @track accountactive = false;
  @track accountdeactivereason = '';
  @track acctfrmdetlstest;
  @track selectedValue;
  @track recordTypeName ;
  @track checkRecType = false;
  columns = [{
    label: "Account Name",
    fieldName: "accountName",
    type: "text",
    sortable: false,
  },
  {
    label: "Business Organization Value",
    fieldName: "bizOrgTypeCode",
    type: "text",
    sortable: false,
  },
  {
    label: "Primary Address",
    fieldName: "primaryAddress",
    type: "",
    sortable: false,
  }
  ];

  @track acctDetailInDupTble = {
    accName: "",
    physicalCountry: "",
    physicalState: "",
    physicalStreetAddr: "",
    physicalCity: "",
    physicalPostalCode: "",
    bizOrgVal: "",
    cimID: "",
    IsIPA: ""
  };

  constructor() {
    super();
  }

  renderedCallback() {
  }
  // Method to get the Record type id for scenario where deactivated accounts record type will be changed
  @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accObjectInfo({data, error}) {
        if(data) {
            let optionsValues = [];
            const rtInfos = data.recordTypeInfos;
            let rtValues = Object.values(rtInfos);
           
            for(let i = 0; i < rtValues.length; i++) {
                if(rtValues[i].name === 'Intel Account') {
                    this.recordTypeName = rtValues[i].recordTypeId;
                }
                else if(rtValues[i].name === 'Inactive Account'){
                    this.checkRecType = true;
                }
            }
        }
        else if(error) {
            window.console.log('Error ===> '+JSON.stringify(error));
        }
    }
  //below connected call back method is used to get User inputs and show it on screen 2 in a table where address is concatenated
  connectedCallback() {
    this.acctfrmdetlstest = [{
      ...this.acctformdetails
    }];
    if(this.acctfrmdetlstest.length>0){
      this.acctfrmdetlstest[0].primaryAddress = this.acctfrmdetlstest[0].addressline1 + ',';
      if (this.acctfrmdetlstest[0].addressline2 != '' && this.acctfrmdetlstest[0].addressline2 != undefined ) {
              this.acctfrmdetlstest[0].primaryAddress = this.acctfrmdetlstest[0].primaryAddress + this.acctfrmdetlstest[0].addressline2 + ', ';
          }
          if (this.acctfrmdetlstest[0].country != '' && this.acctfrmdetlstest[0].country != undefined) {
            this.acctfrmdetlstest[0].primaryAddress = this.acctfrmdetlstest[0].primaryAddress + this.acctfrmdetlstest[0].country + ', ';
        }
        if (this.acctfrmdetlstest[0].state != '' && this.acctfrmdetlstest[0].state != undefined) {
            this.acctfrmdetlstest[0].primaryAddress = this.acctfrmdetlstest[0].primaryAddress + this.acctfrmdetlstest[0].state + ', ';
        }
        if (this.acctfrmdetlstest[0].city != '' && this.acctfrmdetlstest[0].city != undefined) {
            this.acctfrmdetlstest[0].primaryAddress = this.acctfrmdetlstest[0].primaryAddress + this.acctfrmdetlstest[0].city + ', ';
        }
        if (this.acctfrmdetlstest[0].postalCode != '' && this.acctfrmdetlstest[0].postalCode != undefined ) {
            this.acctfrmdetlstest[0].primaryAddress = this.acctfrmdetlstest[0].primaryAddress + this.acctfrmdetlstest[0].postalCode;
        }
    }
    
    var setparams = {};
    setparams.accName = this.acctfrmdetlstest[0].accountName;
    setparams.accAddr = this.acctfrmdetlstest[0].primaryAddress;
    setparams.accCity = this.acctfrmdetlstest[0].city;
    setparams.accCountry = this.acctfrmdetlstest[0].country;
    getCimResults({
      accountDetails: setparams
    })
      .then((response) => {
        let tableData = this.selectDuplicateAccounts(response);
        this.setConfig(tableData);
        if(tableData.length >0){
        this.accountsFound = true;
        this.Spinner = false;
        }
        else{
          this.accountsFound = false;
        }
        //this.error = undefined;
      })
      .catch((error) => {
        this.systemUnavailable = true;
        debugger;
        console.log(error);
        console.log("#### NOT HERE" + JSON.parse(JSON.stringify(error)));
        //this.error = error;
      });
  }
//When Previous button is clicked custom event is dispatched and sent to master layout to handle it
  onPrevClickHandler() {
    const acctDupInfoPrevClick = new CustomEvent("acctdupinfoprevclick");
    this.dispatchEvent(acctDupInfoPrevClick);
  }

//When Next button is clicked if the Account exists in Salesforce user is redirected to the page
//else New Account is created in Salesforce with reference to CIM Data
  onNextClickHandler(event) {  
    this.Spinner = false; 
    if (this.srcSys == false) {
      this.navigateToViewAccountPage();
    } else if (this.srcSys == true) {    
      this.createCIMAccountInSalescloud(); 
    }
    else {
      this.createNewAccountInSalescloud();
     // const acctDupInfoNextClick = new CustomEvent("acctdupinfonextclick");
     // this.dispatchEvent(acctDupInfoNextClick);
    }
  }
//Below method is used to get the values when Apex class is called and the values are mapped to the custom attributes created in a wrapper class
  selectDuplicateAccounts(response) {
    let selectedData = [];
    Object.entries(response).forEach((val) => {
      let values = val[1];
      selectedData.push({
        AcctName: values.accName,
        Address: values.fullAddress,
        BizOrgType: values.bizOrgType,
        IsIPA: values.IPAFlag,
        DupStatus: values.searchScore,
        SourceSystem: values.sourceSystemCIM,
        CimID: values.cimID,
        RecordID: values.accId,
        Country:values.Country,
        State:values.State,
        City:values.City,
        PostalCode:values.postalCode,
        OwnerID: values.accOwner
      });
    });
    return selectedData;
  }
//Using the below method we are configuring the data table of LWC component GridWithPagination
  setConfig(tData) {
    this.Spinner = true;
    this.gridconfig = {
      columns: tColumns,
      data: tData,
      pagesize: 10
    };
  }
//Using the below method we are handling which row is selected
  handleRowSelection(event) {
    console.log('event' + event);
    //const selectedRows = event.detail.selectedRows;
    console.log('event' + event.detail);
    const selectedRows = event.detail;
    for (let i = 0; i < selectedRows.length; i++) {
      this.srcSys = selectedRows[i].SourceSystem;
      this.acctDetailInDupTble.accName = selectedRows[i].AcctName;
      this.acctDetailInDupTble.cimID = selectedRows[i].CimID;
      this.acctDetailInDupTble.physicalCountry = selectedRows[i].Country;
      this.acctDetailInDupTble.physicalState = selectedRows[i].State;
      this.acctDetailInDupTble.physicalStreetAddr = selectedRows[i].Address;
      this.acctDetailInDupTble.physicalCity = selectedRows[i].City;
      this.acctDetailInDupTble.physicalPostalCode = selectedRows[i].PostalCode;
      this.acctDetailInDupTble.bizOrgVal = selectedRows[i].BizOrgType;
      this.acctDetailInDupTble.IsIPA = selectedRows[i].IsIPA;
      this.recrdID = selectedRows[i].RecordID;
    }
  }

  // Navigate to View Account Page
  navigateToViewAccountPage() {
     /* if (this.retVal.accId != null && this.retVal.accId != "") {
        this.recordId = this.retVal.accId;
        this.recrdID = this.retVal.accId;
      }*/
      
      
    this.recordId = this.recrdID;
    if(this.checkRecType == true){
    const fields = {};
    fields[RECORDTYPE_FIELD.fieldApiName] = this.recordTypeName;
    fields[ISACTIVE_FIELD.fieldApiName] = this.accountactive;
    fields[ACCOUNT_ID.fieldApiName] = this.recordId;
    fields[ISDEACTIVEREASON_FIELD.fieldApiName] = this.accountdeactivereason;
    
    
    const recordInput = { fields };
            updateRecord(recordInput)
             .then(() => {
                    this.navigatingtoRecordView();                   
                    }) 
    }
    else{
        this.navigatingtoRecordView();
    }
  }
//Common Navigation method to view Account record view details 
  navigatingtoRecordView(){
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: this.recordId,
        objectApiName: 'Account',
        actionName: 'view'
      },
    });
  }
//New Account record creation Toast message display
  recordCreationtoastdisplay(){
    const evt = new ShowToastEvent({
      message: 'New Account Record has been created',
      variant: 'success',
      mode: 'dismissable'
    });
     this.dispatchEvent(evt);
  }

  //If the account does not exist in Salesforce and user select a grid, based on the value available in CIM the record will be created in Salesforce
  createCIMAccountInSalescloud() {
    console.log('res 2cim');  
    this.Spinner = false;
    var setparams = {};
    setparams.accName = this.acctDetailInDupTble.accName;
    setparams.physicalCountry = this.acctDetailInDupTble.physicalCountry;
    setparams.physicalStreetAddr = this.acctDetailInDupTble.physicalStreetAddr;
    setparams.physicalState = this.acctDetailInDupTble.physicalState;
    setparams.physicalCity = this.acctDetailInDupTble.physicalCity;
    setparams.physicalPostalCode = this.acctDetailInDupTble.physicalPostalCode;
    setparams.bizOrgVal = this.acctDetailInDupTble.bizOrgVal;
    setparams.cimID = this.acctDetailInDupTble.cimID;
    setparams.ownerID = '0052D00000123vEQAQ';

    createAcctInSlcld({
      cimRecord: setparams
    })
      .then((response) => {  
        this.Spinner = true;     
         //console.log('in create account method  ' + response.accId);
         let respse = this.selectRspDta(response);  
         this.recordId = this.retVal.accId;   
         //this.navigateToViewAccountPage();  
         this.navigatingtoRecordView();  
         this.recordCreationtoastdisplay();
         console.log('res 3cim');
         console.log('KK ',JSON.stringify(response))
      }       
        )
      .catch((error) => {
        debugger;
        console.log(error);
        console.log("#### NOT HERE" +JSON.stringify(error));
        //this.error = error;
      });
    this.rtValue = this.retVal.accId;
  }
//set the record id from the response after new record creation
  selectRspDta(response) {
    this.retVal.accId = response.accId;
    this.retVal.accName = response.accName;
  }
//Below method is used to create a new Account in Salesforce if user DOES NOT Select a Row from the Grid
  createNewAccountInSalescloud() {
    console.log('res 3');
    this.Spinner = true; 
    var setparams = {};
    setparams.accName = this.acctformdetails.accountName;
    setparams.accCountry = this.acctformdetails.countryCode;
    setparams.accStateProvince = this.acctformdetails.stateCode;
    setparams.addressLine1 = this.acctformdetails.addressline1;
    setparams.addressLine2 = this.acctformdetails.addressline2;
    setparams.accCity = this.acctformdetails.city;
    setparams.accPostalCode = this.acctformdetails.postalCode;	
	  setparams.bizOrg = this.acctformdetails.bizOrgType;
    setparams.ownerId = this.acctformdetails.ownerId;
    //setparams.ownerId = '0052D00000123vEQAQ';
    /*alert(this.acctformdetails.tname+''+
    this.acctformdetails.taddressline1+''+
    this.acctformdetails.taddressline2+''+
    this.acctformdetails.tcity);*/
    
      setparams.tname = this.acctformdetails.tname;
      setparams.taddressline1 = this.acctformdetails.taddressline1;
      setparams.taddressline2 = this.acctformdetails.taddressline2;
      setparams.tcity = this.acctformdetails.tcity;

    

    createNewRegAccount({
      accountDetails: setparams
    })
      .then((response) => {       
         this.Spinner = true;
         console.log('in create account method  ' + this.Spinner);
         let respse = this.selectRspDta(response);  
         this.recordId = this.retVal.accId;  
         console.log('in create account method  ' + this.recordId);
         this.navigatingtoRecordView();
         this.recordCreationtoastdisplay();
         console.log('res 3');
      }       
        )
      .catch((error) => {
        debugger;
        console.log(error);
        console.log("#### NOT HERE" + JSON.parse(JSON.stringify(error)));
        //this.error = error;
      });
  }

  userConfirmChkHandler(event){
    console.log(event.target.value);
  }

}