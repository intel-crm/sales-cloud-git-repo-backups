import { LightningElement, track,wire } from "lwc";
import getDeactivateAccts from "@salesforce/apex/UCD_AccountDeactivation.GetDeactivateAccts";
import deactivateSelectedAccts from "@salesforce/apex/UCD_AccountDeactivation.DeactivateSelectedAccts";
import deactivateSingleAcct from "@salesforce/apex/UCD_AccountDeactivation.DeactivateSingleAcct";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class UcdAcctDeactivation extends LightningElement {
//@wire(getDeactivateAccts) accounts;
@track error;
@track accList;
@track loaded = false;
@track deactivateRec;
@track selectedAccts = [];
@track checked = false;
@track ShowModal = false;
@track multiAccts = false;
@track recId;
@track recName;
@track index = 0;
@track sfdcBaseURL;
@track showpagination = false;
@track showSearch = false;

startDate = this.defaultstartDate();
endDate = this.defaultendDate();

@track recordsToDisplay = []; //Records to be displayed on the page
@track rowNumberOffset; //Row number
@track disableFilter = false;

@track noAccessToObject = false; //For displaying card for not having data
//Capture the event fired from the paginator component
handlePaginatorChange(event) {
  this.recordsToDisplay = event.detail;
  this.showpagination = true; 
  this.loaded = false;
}
handleSearchChange(event) {
  if(event.detail != 'NoRecords'){
  this.showpagination = false;
  this.loaded = true;   
  this.accList = event.detail;    
  console.log('FIRST'+event.detail.length);   
  this.template.querySelector('c-ucd-pagination').setRecordsToDisplayTest(event.detail,event.detail.length);
}
  else if(event.detail == 'NoRecords'){
    this.showpagination = false;
    this.handleFilterClick();
  }
}
connectedCallback() {
  this.loadAccounts();
}

//Method for Loading the Records available for deactivation fron apex
loadAccounts() {
  this.recordsToDisplay = [];
  
  getDeactivateAccts({ startDate: this.startDate, endDate: this.endDate })
    .then((result) => {
      console.log('startDate'+JSON.stringify(result));
      if (result!= null && result.length) {
        this.accList = result;
        this.showpagination = true;
        this.showSearch = true;
      } 
      else{
        this.showpagination = false;
        this.showSearch = false;
      }
      if(result === null){          
          this.noAccessToObject = true;         
      }
      this.loaded = false;
    })
    .catch((error) => {
      this.error = error;
      console.log('errror'+JSON.stringify(error));
      if(error.body.message == "Too many query rows: 50001"){
        this.showsuccessToast("Data is Too Large to Display, Kindly reduce the Time frame.","Warning");
        this.loaded = false;
      }
      else{
        this.showsuccessToast(error.body.message,"Error");
        this.loaded = false;
      }
    });
}

//Method for deactivating Single Record
deactiveSingleRec(event) {
  this.loaded = true;
  this.deactivateRec = event.target.title;
  const indexPos = event.currentTarget.name;
  let remList = [];
  remList = this.accList;
    deactivateSingleAcct({
    AcctId: event.target.title
  })
  
    .then((result) => {   
        if(result === 'yes'){
          remList.splice(indexPos,1);
          this.recordsToDisplay = remList;
      this.showsuccessToast("Account has been deactivated","Success");
      this.showpagination = false;
      this.handleFilterClick();
        }
        if(result === 'No'){
        this.showsuccessToast("Account has not been deactivated due to insufficient permissions","Warning");
        }
        this.loaded = false;
    })
    .catch((error) => {
      console.log(error);
});
}

//Method handles selection of all checkbox
selectAllCheckbox(event) {
  let selectedRows = this.template.querySelectorAll("lightning-input");
  for (let i = 0; i < selectedRows.length; i++) {
    if (selectedRows[i].type === "checkbox") {
      selectedRows[i].checked = event.target.checked;
    }
  }
}

//Method for deactivating multiple records
deactivateHandler() {
  this.loaded = true;
  this.selectedAccts = [];
  let selectedRows = this.template.querySelectorAll("lightning-input");
  let remList = [];
  remList = this.accList;
  // based on selected row getting values of the contact
  for (let i = 0; i < selectedRows.length; i++) {     
    if (selectedRows[i].checked && selectedRows[i].type === "checkbox") {
      this.multiAccts =  selectedRows[i].checked && selectedRows[i].type === "checkbox" ? true: false;
      this.selectedAccts.push({
        Name: selectedRows[i].value,
        Id: selectedRows[i].dataset.id
      });
      remList.splice(selectedRows[i].title, 1);
      selectedRows[i].checked = false;
    }
  }
    deactivateSelectedAccts({
    Accts: this.selectedAccts
  })
    .then((response) => {
      if(this.multiAccts == true && response === 'yes'){
        this.recordsToDisplay = remList;
      this.showsuccessToast("Account has been deactivated","Success");
      this.showpagination = false;
        this.handleFilterClick();
      }
      else if (this.multiAccts == false){
        this.showsuccessToast("Select atleast One Account to Deactivate","Warning");
        }
      else if(response === 'No'){
this.showsuccessToast("Account has not been deactivated due to insufficient permissions","Warning");
      }
      this.loaded = false;
    })
    .catch((error) => {
      console.log(error);
      console.log('J132 ',error)
    });
}

//Method to display popup on scren with account details
showRecordDetail(event) {
  this.recId = event.target.label;
  this.recName = event.target.Name;
  this.ShowModal = true;
}

//Method to navigate to selected Account record
navigateToDetail(event) {
  this.recId = event.target.value;
  this.sfdcBaseURL = window.location.origin;
  let acctUrl = this.sfdcBaseURL + "/" + this.recId;
  window.open(acctUrl);
}

//Method to Account details close Modal
closeModal() {
  this.ShowModal = false;
}

//Toast Message Method
showsuccessToast(message, variant) {
const evt = new ShowToastEvent({
    title: variant,
    message: message,
    variant: variant,
    mode: "dismissable"
  });
  this.dispatchEvent(evt);
}

get startDate() {
  return this.startDate;
}

get endDate() {
  return this.endDate;
}

get maxDate() {
return this.defaultendDate();
}

defaultstartDate(){
  var date1 = new Date(); // Now 
  date1.setDate(date1.getDate() - 365); // Set now + 30 days as the new date      
  let day1 = date1.getDate();
  if(day1 < 10){
    day1 = "0" + day1;
  }
  let month1 = date1.getMonth()+1;
  if(month1 < 10){
    month1 = "0" + month1;
  }
    let defaultDate = `${date1.getFullYear()}-${month1}-${day1}`;
  console.log('DDDDDDDDDDD'+defaultDate);
  return defaultDate;
}

defaultendDate(){
  var date2 = new Date(); // Now 
  date2.setDate(date2.getDate() - 30); // Set now + 30 days as the new date    
  let day2 = date2.getDate();
  if(day2 < 10){
    day2 = "0" + day2;
  }
  let month2 = date2.getMonth()+1;
  if(month2 < 10){
    month2 = "0" + month2;
  }
  let defaultDate1 = `${date2.getFullYear()}-${month2}-${day2}`;
  console.log('EEEEEEEEEEE'+defaultDate1);
  return defaultDate1;
}

//Method to filter data by start and end dates
  handleFilterClick() {
  let endDate = this.template.querySelector("[data-id='enddate']");
  console.log('endDate'+JSON.stringify(endDate));
  this.loaded = true;
  this.showpagination = false;
  this.showSearch = false;
  this.startDate = this.template.querySelector("[data-id='startdate']").value;
  console.log('startDate'+JSON.stringify(this.startDate));
  this.endDate = endDate.value;
  this.loadAccounts();
}

handleEndDateChange(event) {
  let endDate = this.template.querySelector("[data-id='enddate']");
  if (endDate.validity.valid) {
    this.disableFilter = false;
  } else {
    this.disableFilter = true;
  }
} 
}