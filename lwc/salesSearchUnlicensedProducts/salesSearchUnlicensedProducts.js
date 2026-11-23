import { LightningElement, track, api, wire } from 'lwc';
import retriveLicensedDetails from '@salesforce/apex/Sales_LicenseGenerationUtlity_Chatbot.retriveLicensedDetails';
import retriveLicenseDetailsOnSearch from '@salesforce/apex/Sales_LicenseGenerationUtlity_Chatbot.retriveLicenseDetailsOnSearch';
import PAGE_SIZE from '@salesforce/label/c.sales_chatbot_page_size';
// Column for Datatable
const columns = [
{ label: 'Serial #', fieldName: 'salesLicenseActivationCode', type: 'text', finalwidth: 600 },
{ label: 'Product Name', fieldName: 'productName', type: 'text' },
{ label: '# of seats', fieldName: 'salesQuantity', type: 'Number', initialwidth: '20%' },
{ label: 'Maintenance expiration', fieldName: 'salesLicenseMaintenanceExpDt', type: 'date', initialwidth: '20%' }
];

export default class Sales_GetComputerDetails_Bot extends LightningElement {
@track previousIds = [];
@track Liclist;
@track ids = [];
@track action;
@track temp = [];
//  @api successmsgforunlicensed;
@api validSerialNo;
//  @api item;
@api successResponsefromUnlicensed;
@api searchedProductName;
@api isDataFoundonSeach;
@api isDefaultDataFound;
@api selectedSerialNo;
// hostNameInput;
@track columns = columns;
// totalPage = 0;
currentPage = 1;
//  nextPage = 0;
firstpage = true;
// get data from apex Class
getData() {
retriveLicensedDetails({ ids: JSON.stringify(this.temp), action: this.action }).then(result => {
    if (result !== null && result !== undefined) {
        this.Liclist = result;
        for (let index = 0; index < this.Liclist.length; index++) {
            if (!this.ids.includes(this.Liclist[index].id)) {
                this.ids.push(this.Liclist[index].id);
            }
        }
    }
}).catch(error => {
})
}

connectedCallback() {
if(this.licListonSearch==undefined){
    this.isDefaultDataFound = true; 
this.getData();
}else{
this.isDataFoundonSeach = true;
}
}

handleRowSelection(event) {
var selectedRows = event.detail.selectedRows;
console.log("You selected: " + selectedRows[0].salesLicenseActivationCode);
this.selectedSerialNo = selectedRows[0].salesLicenseActivationCode;
this.selectedSerialNoForUnlicensed = selectedRows[0].salesLicenseActivationCode;;
console.log('this.selectedSerialNo in row selection'+this.selectedSerialNo);
}

callComputerNameComp(event){
console.log('SEELCT serial#=>'+this.selectedSerialNo);
if(this.selectedSerialNo!=undefined){
    this.validSerialNo = true;
    this.successResponsefromUnlicensed = 'You have successfully selected a License!';
}else{
    this.validSerialNo = false;
}
}

inputChange(event) {
this.searchedProductName = event.target.value;
console.log('this.searchedProductName==>'+this.searchedProductName)
}

// Previous(Inside If) and Next Button(Inside else) Logic 
hostReassignment(event) {
let name = event.target.name;
this.temp = [];
this.previousIds = [];
if (name == 'Previous') {
    this.currentPage--;
    this.firstpage = this.currentPage == 1 ? true : false;
    this.action = name;
    let i = 0;
    //               1                                      3-2 =1
    for (let index = 0; index < PAGE_SIZE; index++) {
        this.ids.pop();
    }

    let start = this.currentPage == 1 ? 0 : parseInt(PAGE_SIZE) * (this.currentPage - 1);
    let finish = start + parseInt(PAGE_SIZE);
    console.log('start -->' + start + 'FInish -->' + finish);
    this.previousIds = this.ids.slice(start, finish);
    console.log('Prev Ids -->' + this.previousIds);
    this.temp = this.previousIds;
    console.log(this.temp.length);
} else {
    this.currentPage++;
    this.firstpage = this.currentPage > 1 ? false : true;
    this.action = name;
    this.temp = this.ids;

}
this.getData();
}

// User gives input as a Product Name and from here we can search that specific Product
validateLicenseName(event) {
console.log('Name==>'+this.searchedProductName);
if(this.searchedProductName==undefined || this.searchedProductName==null || this.searchedProductName==''){
    console.log('Inside if==>'+this.searchedProductName);
    this.isDataFoundonSeach = false;
    this.isDefaultDataFound = true;
}else{
    console.log('Inside else==>'+this.searchedProductName);
    retriveLicenseDetailsOnSearch({productName : this.searchedProductName})
    .then(result => {
        console.log('result-->'+result);
        this.licListonSearch = result;
        if(this.licListonSearch[0] != undefined){
            this.isDataFoundonSeach = true;
            this.isDefaultDataFound = false;
            console.log('On Search-->'+this.licListonSearch);
        }else{
            this.isDefaultDataFound = true;
        }
    })
}
}

tableOuterDivScrolled(event) {
this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
if (this._tableViewInnerDiv) {
    if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
        this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
    }
    this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) + "px;" + this.tableBodyStyle;
}
this.tableScrolled(event);
}

tableScrolled(event) {
if (this.enableInfiniteScrolling) {
    if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
        this.dispatchEvent(new CustomEvent('showmorerecords', {
            bubbles: true
        }));
    }
}
if (this.enableBatchLoading) {
    if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
        this.dispatchEvent(new CustomEvent('shownextbatch', {
            bubbles: true
        }));
    }
    }
}
}