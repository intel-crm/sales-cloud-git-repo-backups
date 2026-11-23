import { LightningElement, api, track, wire } from "lwc";
import getCimResults from "@salesforce/apex/UCD_AccountConnector.getDuplicateAccountDetails";
//import createAcctInSlcld from "@salesforce/apex/UCD_AccountConnector.createNewSlsCldAccount";
//import createNewRegAccount from "@salesforce/apex/UCD_AccountConnector.createNewRegAccount";
import findAccountOwners from "@salesforce/apex/UCD_AccountConnector.findAccountOwners";
import findCimResults from "@salesforce/apex/UCD_CIMConnector.getCimResults";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import {NavigationMixin} from 'lightning/navigation';
import ACCOUNT_ID from '@salesforce/schema/Account.Id';     
import ISACTIVE_FIELD from '@salesforce/schema/Account.Core_Deactivated__c';    
import ISDEACTIVEREASON_FIELD from '@salesforce/schema/Account.Core_Deactivation_Reason__c';    
import RECORDTYPE_FIELD from '@salesforce/schema/Account.RecordTypeId'; 
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import NEWREG_OBJECT from '@salesforce/schema/PRM_Registration_Request__c';

export default class UcdAcctDuplicate extends NavigationMixin(LightningElement) {
    
    @track checkBoxFieldValue;
    @track selectedValue;
    @track disabledCondition = true;

    @api acctformdetails;  
    @api payload; 
    @api stepNum = "step-2";    
    @track loaded = false;  
    @track primaryAddress;  
    @track accrecId;    
        
    // Variables for Pagination 
    @track prevButton = '<';    
    @track nextButton = '>';    
    data = [];  
    @track tableData=[];    
    @track page = 1;    
    perpage = 10;   
    @track pages = [];  
    set_size = 5;   
    @track showNoData = false;  
    @track records; 
    @track pageIndex = 1;   
    // Variables for fetching selected row data from table  
    @track seletedRowData;  
    @track seelctedAccData;
    @track selectedValue; 
    @track selectedAcctID;
    @track selectedCIMID;
    @track ownSelValue;  
        
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
    //variables to change owner
    @track isSFCIM = false;
    @track cimIdA = '';
    @track recIdA = '';
    @track isValidUser = false;
    @track isModalOpen = false;
    @track currUser = '';

    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
    @track showpagination = false;
    @track errorMessage = '';

    

    //Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
        this.loaded = true;
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
    @wire(findCimResults)
cimResults({ error, data }) {
    if (data) {
    }
    if (error) {
        this.errorMessage = error;
    }
}

//Method to get the record type for New Registration custom object

@wire(getObjectInfo, { objectApiName: NEWREG_OBJECT })
    accObjectInfo2({data, error}) {
        if(data) {
            let optionsValues = [];
            const rtInfos2 = data.recordTypeInfos;
            let rtValues2 = Object.values(rtInfos2);
            for(let i = 0; i < rtValues2.length; i++) {
                if(rtValues2[i].name == 'Account Create Request') {
                    this.selectedValue = rtValues2[i].recordTypeId;
                }
            }
            //this.options = optionsValues;
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
                    //this.checkRecType = true; 
                    this.inActiveRecordtypeId= rtValues[i].recordTypeId;
                }   
            }   
        }   
        else if(error) {    
            window.console.log('Error ===> '+JSON.stringify(error));    
        }   
    }
    async connectedCallback() {
        this.fetchCIMResults();
    }

    fetchCIMResults(){
        var setparams = {};
        console.log('Name is'+this.acctformdetails.accountName);
        console.log('state is'+this.acctformdetails.state);
        console.log('Country is'+this.acctformdetails.country);
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
                if (this.data.length>0) {
                    this.showNoData = false;
                    this.showpagination = true;
                } else {
                    this.showNoData = true;
                    this.checkBoxFieldValue = true;
                    this.showpagination = false;
                }
                //this.showpagination = true;
                this.loaded = true;
            })
            .catch((error) => {
                console.log('&&&&&'+JSON.stringify(error));
                this.showToastMessage('error',JSON.stringify(error),'error','dismissable');
                
            });
        //this.setPages(this.data);
    }

    disconnectedCallback() {
        this.acctformdetails = {};
        console.log('values are '+JSON.stringify(this.acctformdetails));
    }
    renderedCallback() {
        //this.fetchCIMResults();
        this.renderButtons();
    }
    
    renderButtons = () => {
        this.template.querySelectorAll('button').forEach((but) => {
            but.style.backgroundColor = this.page === parseInt(but.dataset.id, 10) ? 'dodgerblue' : 'white';
            but.style.color = this.page === parseInt(but.dataset.id, 10) ? 'white' : 'black';
        });
    }
    // Method called on click of Previous button
    onPrevClickHandler() {
        const acctDupInfoPrevClick = new CustomEvent("acctdupinfoprevclick", { detail: this.acctformdetails });
        this.dispatchEvent(acctDupInfoPrevClick);
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
               //this.createnewCIMaccount();
               this.createAccountBasedOnCIMData();           
            }
        }
        if(this.checkBoxFieldValue){
            this.createAccount();
        }
       /* else {
            this.createnewaccountrequest();
        }*/
            
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

    //Method to create new account with existing CIM record details
    /* Commenting this block as now standard New record creation screen is shown with values pre populated
	createnewCIMaccount(){
                    var setparams = {};
                    setparams.accName = this.seletedRowData.accName;
                    setparams.physicalCountry = this.acctformdetails.country;
                    setparams.physicalState = this.acctformdetails.state;
                    setparams.physicalStreetAddr = this.acctformdetails.addressline1 + this.acctformdetails.addressline2;
                    setparams.physicalCity = this.acctformdetails.city;
                    setparams.physicalPostalCode = this.acctformdetails.postalCode;
                    setparams.bizOrgVal = this.acctformdetails.bizOrgType;
                    setparams.cimID = this.seletedRowData.cimID;
                    createAcctInSlcld({
                        cimRecord: setparams
                    })
                        .then((response) => {
                            this.accrecId = response.accId;
                            this.loaded = true;
                            this.showToastMessage('Success','New Account created','Success','dismissable');
                            this.navigateToViewAccountPage();
                        })
                        .catch((error) => {
                            this.showToastMessage('error',this.errorMessage,'error','dismissable');
                        });                  
    }
	
	*/

    //Method to create a new account request record
	/* Commenting this block as now standard New record creation screen is shown with values pre populated
    createnewaccountrequest(){
        this.loaded = false;
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
            setparams.tname = this.acctformdetails.tname;   
            setparams.taddressline1 = this.acctformdetails.taddressline1;   
            setparams.taddressline2 = this.acctformdetails.taddressline2;   
            setparams.tcity = this.acctformdetails.tcity;

            createNewRegAccount({
                accountDetails: setparams
            })
                .then((response) => {
                    this.accrecId = response.accId;
                    this.loaded = true;
                    this.showToastMessage('Success','New Account created','Success','dismissable');       
                    this.navigateToViewAccountPage();            
                }
                )
                .catch((error) => {
                    this.loaded = true;
                    console.log(error)
                });              
    }
	*/
	
    //Below method is used to show the Account create pop up by pre-populating the user entered values
    createAccount(){
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
    }

    //Below method is used to show the Account create pop up by pre-populating the values of CIM Data from Table
    createAccountBasedOnCIMData(){
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
                    BillingStateCode : this.seletedRowData.State,
                    BillingCountryCode : this.seletedRowData.Country,
					Core_CIM_ID__c: this.seletedRowData.cimID
                })
            }
        });
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
    // Method to show toast messages
    showToastMessage(title,message,variant,mode) {
        this.loaded = true;
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
    // Method called on selecting a account record from table
    checkBoxSelectionHandler(event) {
        this.currUser = event.target.placeholder;
        this.isValidUser = this.currUser != 'Uncovered Account' && this.currUser != undefined && event.target.checked ? true : false; 
        if (!event.target.checked) {
            this.disabledCondition = true;
            this.selectedValue = '';
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
    
    // Method called on click of salesforce ID on table to display the account details
    handleRowAction(event){
        this.recId = event.target.label;
        this.recName = event.target.title;
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
    handleSuccess(event) {

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
}