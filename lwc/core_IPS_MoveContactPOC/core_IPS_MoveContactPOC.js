import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import userId from '@salesforce/user/Id';

import getCore_IPS_MoveContact_AnkitTest_LWCPOC from '@salesforce/apex/Core_IPS_MoveContact_AnkitTest.getCore_IPS_MoveContact_AnkitTest_LWCPOC';
//import updateContactOnSave from '@salesforce/apex/Core_IPS_MoveContact_AnkitTest.updateContactOnSave';
import getCurrentContact from '@salesforce/apex/Core_IPS_MoveContactPOC.getCurrentContact';
import getTargetAccountObj from '@salesforce/apex/Core_IPS_MoveContactPOC.getTargetAccountObj';
import getTargetContactObj from '@salesforce/apex/Core_IPS_MoveContactPOC.getTargetContactObj';
import getContactEntitlement from '@salesforce/apex/Core_IPS_MoveContactPOC.getContactEntitlement';
import fetchDefaultRecord from '@salesforce/apex/Core_IPS_MoveContactPOC.fetchDefaultRecord';
import getCases from '@salesforce/apex/Core_IPS_MoveContactPOC.getCases';
import updateContactOnSave from '@salesforce/apex/Core_IPS_MoveContactPOC.updateContactOnSave';

import hasValidInputs from '@salesforce/apex/Core_IPS_MoveContactPOC.hasValidInputs';
const DELAY = 300;
const submitAfterDELAY = 10000;
const columns = [
    { label: 'Account Name', fieldName: 'AccountName', type: 'url',
    typeAttributes: { label: { fieldName: 'Name' }, target: '_blank'} },
    { label: 'Sales Group', fieldName: 'Core_Sales_Groups__c'},
    { label: 'Account Owner', fieldName: 'OwnerName', type: 'url',
    typeAttributes: { label: { fieldName: 'Owner' }, target: '_blank'} },
    { label: 'Prime Account Name', fieldName: 'Core_Prime_Account_Name__c'},
    { label: 'Prime Country/Region', fieldName: 'Core_Account_Country__c'},
	{ label: 'Covered Account', fieldName: 'Core_Covered_Account__c', type:"boolean"},
    { label: 'CIM ID', fieldName: 'Core_CIM_ID__c'},
	{ label: 'Partner Program', fieldName: 'Core_Partner_Alliance_Program__c'},
    { label: 'Biz Org Type', fieldName: 'Core_Account_Type__c' },
    { label: 'Account ID', fieldName: 'Id'}
];

export default class Core_IPS_MoveContactPOC extends NavigationMixin(LightningElement) {
accdata = [];
columns = columns;
@track loggedInUserId= userId ;
@track currentName;
@track searchName;
@track savedContact;
@track results;
@track records;
@track gecFound = false;


@api displayTable;

@track CurrentAccountName;
@track CurrentContactName;
@track targetAccount;
@track message;
@track isRequired = true;
@track thrownError = false;
@track gecFoundAcc = false;
@track isCheckedKeepEntitlement = false;
@track isContactEntitlement = true;
//@track gecFoundCon = false;

//@track accOwner = false;


selectedAccount;
currentAccountName
currentAccountId;
@api recordId;
@api Account;
@api Contact;
@track currentPageReference = null;
@track Reason = null;
@track isCheckedWithAccowner = false;
urlStateParameters = null;
@api label = 'Identify the Account to move the selected Contact to:';
@api placeholder = 'search...';
@api iconName = 'standard:account';
@api sObjectApiName = 'Account';
@api defaultRecordId = '';
@api conLookup;
@api isLoaded = false;
// private properties
lstResult = []; // to store list of returned records
hasRecords = true;
searchKey=''; // to store input field value
isSearchLoading = false; // to control loading spinner
delayTimeout;
@track error;

selectedRecord = {};

//c/contact
@api conlabel = 'Identify the Contact to transfer the Cases to:';
//@api conplaceholder = 'search...';
@api coniconName = 'standard:contact';
@api consObjectApiName = 'Contact';
//@api defaultRecordId = '';
// private properties
conlstResult = []; // to store list of returned records
conhasRecords = true;
consearchKey=''; // to store input field value
conisSearchLoading = false; // to control loading spinner
/*delayTimeout;*/

conselectedRecord = {};



@wire(CurrentPageReference)
getStateParameters(currentPageReference) {
if (currentPageReference) {
    this.urlStateParameters = currentPageReference.state;
    this.setParametersBasedOnUrl();
}
}

setParametersBasedOnUrl() {
this.recordId = this.urlStateParameters.c__recordId || null;

}
@wire(getCurrentContact, {recordId: '$recordId'}) 
wireRecord({data,error}){
if(data){
var accName;  
this.results = data;
//alert("datas"+JSON.stringify(this.results.Account.Name));
console.log('yes'+this.results);
accName = this.results.Account.Name;
this.currentAccountId=this.results.Account.Id;

this.CurrentAccountName = accName;
this.CurrentContactName = this.results.Name;
this.Contact = data;
this.error = undefined;
this.dataNotFound = '';
this.gecFoundAcc = this.results.Account.Core_Export_Compliance_Block__c;
if(this.loggedInUserId === this.results.Account.OwnerId){
this.isRequired = false;
}
getCases({ currentCon: this.Contact})
.then((result) => {
if(result != null){
    
this.gecFound = result;
//alert('No'+this.gecFound);
//this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
}
})
.catch((error) => {
this.error = error;
this.selectedRecord = {};
});
/*if(this.results == ''){
this.dataNotFound = 'There is no Account found related to Account name';
}*/
}else{
//alert('errors'+error);
this.error = error;
this.data=undefined;
}
}

connectedCallback(){
  
/*if(this.defaultRecordId != ''){
    fetchDefaultRecord({ recordId: this.defaultRecordId})
    .then((result) => {
        if(result != null){
            this.selectedRecord = result;
           // alert(this.selectedRecord)
            this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
        }
    })
    .catch((error) => {
        this.error = error;
        this.selectedRecord = {};
    });
}*/

getContactEntitlement({recordId: this.recordId})
.then((result) => {
    if(result.length > 0){
        this.isContactEntitlement = false;
    }
});

//this.handleRowSelection(event);
}

// @wire(getContactEntitlement,{recordId: '$recordId'})
// EntitlementRec(value){
//     alert("entitlement " + JSON.stringify(value));
//     if(value.length > 0){
//         this.isContactEntitlement = false;
//     }
// };
// to store selected lookup record in object formate 
// initial function to populate default selected lookup record if defaultRecordId provided  

// wire function property to fetch search record based on user input

@wire(getTargetAccountObj, { targetAccountName: '$searchKey'})
searchResult(value) {
const { data, error } = value; // destructure the provisioned value
this.isSearchLoading = false;
if (data) {
        this.hasRecords = data.length == 0 ? false : true; 
        this.lstResult = JSON.parse(JSON.stringify(data)); 
        //this.accdata = JSON.parse(JSON.stringify(data));
        let tempRecs = [];
        data.forEach( ( record ) => {
            let tempRec = Object.assign( {}, record );  
            tempRec.AccountName = '/' + tempRec.Id;
            tempRec.Owner = tempRec.Owner.Name;
            tempRec.OwnerName = '/' + tempRec.OwnerId;
            tempRecs.push( tempRec );
            
        });
        this.accdata = tempRecs;
        this.error = undefined;
        //alert(this.accdata.length);
if(this.accdata.length<=0){
    this.Account ='';
}

        //console.log('(error1---> ' + JSON.stringify(this.data));
        //console.log('(error2---> ' + this.data);
        if(this.selectedRecord.length>0){
            this.displayTable = false;
            this.selectedRecord ={};
        }else{
            this.displayTable = true;
        }
        
    }
else if (error) {
    this.displayTable = false;
    console.log('(error---> ' + JSON.stringify(error));
    }
};
@wire(getTargetContactObj, { consearchKey: '$consearchKey', currentAccountId: '$currentAccountId', currentConId: '$recordId'})
searchResultCon(value) {
const { data, error } = value; // destructure the provisioned value
this.conisSearchLoading = false;
if (data) {
        this.conhasRecords = data.length == 0 ? false : true;
        console.log(JSON.parse(JSON.stringify(data)));
        this.conlstResult = JSON.parse(JSON.stringify(data));
        console.log(this.conlstResult);
        //this.displayTable = true;
    }
else if (error) {
    //this.displayTable = false;
    console.log('(error---> ' + JSON.stringify(error));
    }
};

// update searchKey property on input field change  
handleKeyChange(event) {
// Debouncing this method: Do not update the reactive property as long as this function is
// being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
this.isSearchLoading = true;
window.clearTimeout(this.delayTimeout);
const searchKey = event.target.value;
//alert(searchKey);
if(searchKey != '' && searchKey != null){
this.delayTimeout = setTimeout(() => {
this.searchKey = searchKey;
}, DELAY);
//alert(this.searchKey);
}else{
    this.handleRemove();
}
}

handleKeyChangeContact(event) {
    // Debouncing this method: Do not update the reactive property as long as this function is
    // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
    this.conisSearchLoading = true;
    window.clearTimeout(this.delayTimeout);
    const consearchKey = event.target.value;
    console.log(consearchKey);
    this.delayTimeout = setTimeout(() => {
    this.consearchKey = consearchKey;
    }, DELAY);
    }
    
// method to toggle lookup result section on UI 
toggleResult(event){
const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
const clsList = lookupInputContainer.classList;
const whichEvent = event.target.getAttribute('data-source');
switch(whichEvent) {
    case 'searchInputField':
        clsList.add('slds-is-open');
        break;
    case 'lookupContainer':
        clsList.remove('slds-is-open');    
    break;                    
    }
    
}

contoggleResult(event){
    const conlookupInputContainer = this.template.querySelector('.conlookupInputContainer');
    const clsList = conlookupInputContainer.classList;
    const whichEvent = event.target.getAttribute('data-source');
    switch(whichEvent) {
        case 'consearchInputField':
            clsList.add('slds-is-open');
            break;
        case 'conlookupContainer':
            clsList.remove('slds-is-open');    
        break;                    
        }
        //this.consearchKey = null;
    }

// method to clear selected lookup record  
handleRemove(){
this.searchKey = '';    
this.selectedRecord = {};
this.conselectedRecord = {};
this.Account=undefined;
//alert('AccRemoved'+this.Account);
this.lookupUpdatehandler(undefined); // update value on parent component as well from helper function 

// remove selected pill and display input field again 
/*const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
searchBoxWrapper.classList.remove('slds-hide');
searchBoxWrapper.classList.add('slds-show');
const pillDiv = this.template.querySelector('.pillDiv');
pillDiv.classList.remove('slds-show');
pillDiv.classList.add('slds-hide');*/
}

handleRemoveCon(){
    this.consearchKey = '';
    this.conselectedRecord = {};
   // this.Account=undefined;
    this.conlookupUpdatehandler(undefined); // update value on parent component as well from helper function 
    
    // remove selected pill and display input field again 
    const consearchBoxWrapper = this.template.querySelector('.consearchBoxWrapper');
    consearchBoxWrapper.classList.remove('slds-hide');
    consearchBoxWrapper.classList.add('slds-show');
    const conpillDiv = this.template.querySelector('.conpillDiv');
    conpillDiv.classList.remove('slds-show');
    conpillDiv.classList.add('slds-hide');
    }

// method to update selected record from search result 
handelSelectedRecord(event){
var objId = event.target.getAttribute('data-recid'); // get selected record Id 
this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list 
//alert(this.selectedRecord);
this.Account=this.selectedRecord;
//alert(this.Account);

this.lookupUpdatehandler(this.selectedRecord);
console.log('(error---> 12' + JSON.stringify(this.Account)); // update value on parent component as well from helper function 
this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
}
handelSelectedConRecord(event){
    var objId = event.target.getAttribute('data-recid'); // get selected record Id 
    this.conselectedRecord = this.conlstResult.find(data => data.Id === objId); // find selected record from list 
    //alert(this.selectedRecord);
    this.conLookup=this.conselectedRecord;
    //alert(this.conLookup);

    this.conlookupUpdatehandler(this.conselectedRecord);
    console.log('(error---> 12' + JSON.stringify(this.conLookup)); // update value on parent component as well from helper function 
    this.handelconSelectRecordHelper(); // helper function to show/hide lookup result container on UI
    }

/*COMMON HELPER METHOD STARTED*/
handelSelectRecordHelper(){
this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
searchBoxWrapper.classList.remove('slds-show');
searchBoxWrapper.classList.add('slds-hide');
const pillDiv = this.template.querySelector('.pillDiv');
pillDiv.classList.remove('slds-hide');
pillDiv.classList.add('slds-show');     
}

handelconSelectRecordHelper(){
    this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
    const consearchBoxWrapper = this.template.querySelector('.consearchBoxWrapper');
    consearchBoxWrapper.classList.remove('slds-show');
    consearchBoxWrapper.classList.add('slds-hide');
    const conpillDiv = this.template.querySelector('.conpillDiv');
    conpillDiv.classList.remove('slds-hide');
    conpillDiv.classList.add('slds-show');
    }

// send selected lookup record to parent component using custom event
lookupUpdatehandler(value){    
const oEvent = new CustomEvent('lookupupdate',
{
'detail': {selectedRecord: value}
}
);
this.dispatchEvent(oEvent);
}

conlookupUpdatehandler(value){    
    const oEvent = new CustomEvent('lookupupdate',
    {
    'detail': {conselectedRecord: value}
    }
    );
    this.dispatchEvent(oEvent);
    }

handleSave(){

//targetaccountid,ccontact obj
if(this.Account !== null && this.Account !== '' && this.Account !== undefined){
    console.log('am here1');
//alert(JSON.stringify(this.Account));
if(this.isRequired === true){
    console.log('am here2');
//alert(this.isRequired);
//alert(this.Reason +this.isCheckedWithAccowner);
    if(this.Reason === '' || this.Reason === null){
        this.thrownError = true;
        this.toastMessage('Error',' Please enter a Reason for moving the contact to another Account ','error');
    }else if(!this.isCheckedWithAccowner){
        this.thrownError = true;
        this.toastMessage('Error',' Please check with current Account owner before transfering the contact to Another account ','error');
        
    }
    
    }
    if( this.thrownError){
        
    }else{
hasValidInputs({ con: this.Contact, tarAcc: this.Account, gecCase:this.gecFound,keepEntitlements:this.isCheckedKeepEntitlement})
.then((result) => {
    console.log('am here2'+result);
    //alert('1111'+JSON.stringify(this.Account));
    if(result === 'true'){
       // alert('yes am1 ');    
updateContactOnSave({ CurrContact: this.Contact, tarAccount: this.Account, Reason:this.Reason, isCheckedWithAccowner:this.isCheckedWithAccowner, isCheckedKeepEntitlement:this.isCheckedKeepEntitlement})
.then((result) => {
    console.log('am here3'+result);
   // alert('1111'+result);
if(result === 'Approval request has been sent successfully'){
    this.toastMessage('Success','Approval request has been sent successfully','success');

    }else if(result === 'Account change for this contact already in Progress. Please try later.'){
        this.toastMessage('Info','Account change for this contact already in Progress. Please try later.','info');
        
    }else if(result === 'A request to move the contact is already in progress!'){
        this.toastMessage('Info','A request to move the contact is already in progress!','info');
        
    }else{
        this.toastMessage('Error',result,'error');
    }
    window.clearTimeout(this.delayTimeout);
    this.delayTimeout = setTimeout(() => {
        window.history.back();
        return false;
        }, submitAfterDELAY);
})
.catch((error) => {
this.error = error;
//alert(error+JSON.stringify(this.error));
//this.selectedRecord = {};
console.log(`this error is comming ${error}`);
this.toastMessage('Error',error.body.message,'error');
});
        }else if(result === ' Current account and Requested account is same.'){
            this.toastMessage('Info',' Current account and Requested account is same.','info');
            
        }else if(result === ' GEC Cases Found, moving contact and Entitlements is not allowed.'){
            this.toastMessage('Error',' GEC Cases Found, moving contact and Entitlements is not allowed.','error');	
        
        }else if(result ===' Account : INVALID ACCOUNT '){
            this.toastMessage('Info',' Account : INVALID ACCOUNT ','info');	
        }else if(result === 'You are moving the contact from a PSG account to a non-PSG account.<br/>  Are you sure you want to proceed?'){
            this.toastMessage('Warning',' You are moving the contact from a PSG account to a non-PSG account. Are you sure you want to proceed?','warning');	
        
        }else if(result ==='Keep Entitlements is not allowed when moving contact from a standard account to an ODM account or from an ODM account to standard account'){
            this.toastMessage('Error','Keep Entitlements is not allowed when moving contact from a standard account to an ODM account or from an ODM account to standard account','error');	
        
        }else if(result ==='CNDA must be filled manually by the user on the Account record : '+this.Account.Name){
            this.toastMessage('Error','CNDA must be filled manually by the user on the Account record : '+this.Account.Name,'error');	
        
        }else if(result ==='CIM ID must be filled manually by the user on the Account record : '+this.Account.Name){
            this.toastMessage('Error','CIM ID must be filled manually by the user on the Account record : '+this.Account.Name,'error');	
        
        }else if(result ==='English Only Name must be filled manually by the user on the Account record : '+this.Account.Name){
            this.toastMessage('Error','English Only Name must be filled manually by the user on the Account record : '+this.Account.Name,'error');	
        
        }else if(result ===' Account :'+this.Contact.Account.Name+' is on  GEC Hold '){
            this.toastMessage('Error',' Account :'+this.Contact.Account.Name+' is on  GEC Hold ','error');	
        }else if(result ===' Account :'+this.Account.Name+' is on  GEC Hold '){
            this.toastMessage('Error',' Account :'+this.Account.Name+' is on  GEC Hold ','error');	
        }else if(result ==='Please contact IT Support to have them manually set the UserRole to Account :'+this.Account.Name+'\'s Owner :'){
            this.toastMessage('Error','Please contact IT Support to have them manually set the UserRole to Account :'+this.Account.Name+'\'s Owner :','error');	
        }
})
.catch((error) => {
    this.error = error;
    console.log('am here4'+error);
    //alert(error+JSON.stringify(this.error));
    this.selectedRecord = {};
    this.toastMessage('Error',error.body.message,'error');
});


}
}else{
this.toastMessage('Error','Please choose a Account','error');
}
}
handleCancel(event){
/* var url = window.location.href;
var value = url.substr(0,url.lastIndexOf('/') + 1);*/
window.history.back();
return false;
}
handleInputReason(event){
this.Reason = event.target.value;
if(this.Reason){
    this.thrownError = false;
    }
}
handleCheckAccOwner(event){
this.isCheckedWithAccowner = event.target.checked;
if(this.isCheckedWithAccowner){
this.thrownError = false;
}
}
toastMessage(value1, value2, value3){
const evt = new ShowToastEvent({
title: value1,
message: value2,
variant: value3,
mode: 'dismissable'
});
this.dispatchEvent(evt);
}
handleKeepEntitlement(event){
this.isCheckedKeepEntitlement = event.target.checked;
    }
handleRowSelection(event){
    var selectedRows=event.detail.selectedRows;
    //alert('rows'+selectedRows.length);
    if(selectedRows.length>0){
    //let rowId = event.detail.row.Id;
    //alert(rowId);
    //this.selectedRecord = selectedRows;
   // alert(this.selectedRecord);
   // alert(JSON.stringify(this.selectedRecord));
    if(selectedRows.length>1)
    {
        var el = this.template.querySelector('lightning-datatable');
        selectedRows=el.selectedRows=el.selectedRows.slice(1);
        event.preventDefault();
        
        return;
    }
//alert('selectedRows'+selectedRows);

    this.selectedRecord = selectedRows;
    this.Account= this.selectedRecord[0];
    this.searchKey = this.selectedRecord[0].Name; 
    //alert(this.searchKey);
    this.isLoaded = true;
    //alert(this.isLoaded);
    this.displayTable = false;
}  
this.displayTable = false;

}
}