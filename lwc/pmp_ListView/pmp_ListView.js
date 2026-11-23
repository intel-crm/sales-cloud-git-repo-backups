// IPA2.0 + US TWC4497-1631
// import { LightningElement, wire, track, api } from 'lwc';
// import getOfferingList from '@salesforce/apex/PMP_ListOfferingViewController.getOfferingList';
// import getNext from '@salesforce/apex/PMP_ListOfferingViewController.getNext';
// import getPrevious from '@salesforce/apex/PMP_ListOfferingViewController.getPrevious';
// import TotalRecords from '@salesforce/apex/PMP_ListOfferingViewController.TotalRecords';

// /* eslint-disable no-console */
//  /* eslint-disable no-alert */

//  const COLS = [
//     { label: 'Partner Offering Lifecycle Status', fieldName: 'lifecycle_status', type: 'text',
//     sortable: "true" },
//     { label: 'Offering Name', fieldName: 'offering_name', type: 'text',
//     sortable: "true"  },
//     { label: 'View Offerings', fieldName: 'view_offering', type: 'text',
//     sortable: "true" },
//     { label: 'Edit Offering', fieldName: 'EditRecord', type: 'url',
//     typeAttributes: { label: {fieldName: 'Edit'}, target: '_blank'},sortable: "true"},

//     { label: 'Clone Offering', fieldName: 'CloneRecord', type: 'url',
//     typeAttributes: { label: {fieldName: 'Clone'}, target: '_blank'},sortable: "true"},

//     { label: 'Company Information', fieldName: 'Company' ,type: 'url', 
//     typeAttributes: { label: {fieldName: 'CompanyName'}, target: '_blank'}},

//     { label: 'Intel Marketplace Admin', fieldName: 'admin', type: 'url',
//     typeAttributes: { label: {fieldName: 'adminName'}, target: '_blank'},sortable: "true" },

//     { label: 'Category', fieldName: 'category', type: 'text',
//     sortable: "true"  },
//     { label: 'Sub Category', fieldName: 'subcategory', type: 'text',
//     sortable: "true"  },
//     { label: 'Is Published', fieldName: 'ispublished', type: 'boolean',
//     sortable: "true"  },
//     { label: 'Last Modified Date', fieldName: 'lastodifieddate', type: 'date',
//     sortable: "true"  },
//     { label: 'Last Modified By', fieldName: 'lastmodifiedurl', type: 'url',
//     typeAttributes: { label: {fieldName: 'userName'}, target: '_blank'},sortable: "true"  },
//     { label: 'Partner Program Segment', fieldName: 'partner_programsegment', type: 'text',
//     sortable: "true"  },
//     { label: 'Translation Status', fieldName: 'translation_status', type: 'customLink',
//     sortable: "true"  },
//     { label: 'Created Date', fieldName: 'createddate', type: 'date',
//     sortable: "true"  },
//     { label: 'Partner Offering Visibility Name', fieldName: 'offeringvisibility', type: 'customLink',
//     sortable: "true"  }

//  ];

// const Retired_Offerings = 'Retired Offerings';
// const Admin_Review_Queue = 'Admin Review Queue';
// const ALL_Offerings = 'All Offerings';
 
// const filterOptions = [
//     { value: Retired_Offerings, label: Retired_Offerings },
//     { value: Admin_Review_Queue, label: Admin_Review_Queue },
//     { value: ALL_Offerings, label: ALL_Offerings },
// ];
 
// export default class Pmp_ListView extends LightningElement {
// @track columns = COLS;
// @track v_Offset=0;
// @track v_TotalRecords;
// @track page_size = 50;
// @track offeringName = "";
// @track records = [];
// @track isFilterOn = false;
// @track error;
// @track searchString;
// @track initialRecords;
// @track data;
// @track filter = ALL_Offerings;
// @track isExpanded = false;
// @track currentFilter = ALL_Offerings;
// @track isExpanded = false;
// @track itemsForCurrentView = this.data;
// filterOptions = filterOptions;
// @track searchKey = '';

// //Fetching records from apex class
// async getofferingData(){
//     console.log('call method-->');
//     console.log('searchkey--->'+this.searchKey);
//     await getOfferingList({
//         filter: this.filter,
//         searchkey: this.searchKey
//     })
//     .then((result) => {
//         let tempRecs = [];
//                     result.forEach( ( record ) => {
//                         let tempRec = Object.assign( {}, record );  
//                         tempRec.Company = 'https://intel--crmdevint3.sandbox.my.site.com/imp/s/partner-edit/' + tempRec.companyId + '/' + tempRec.comapnyInfo;
//                         tempRec.CompanyName = tempRec.comapnyInfo;
//                         if(tempRec.admin != null){
//                             tempRec.admin = 'https://intel--crmdevint3.sandbox.my.site.com/imp/s/profile/'+tempRec.admin;
//                             tempRec.adminName = tempRec.adminName;
//                         }
//                         if(tempRec.lastmodifiedId != null){
//                             tempRec.lastmodifiedurl = 'https://intel--crmdevint3.sandbox.my.site.com/imp/s/profile/'+tempRec.lastmodifiedId;
//                             tempRec.userName = tempRec.usersName;
//                         }
//                         if(tempRec.offeringId != null){
//                             tempRec.EditRecord = 'https://intel--crmdevint3.sandbox.my.site.com/imp/s/offering-edit?recordId=' + tempRec.offeringId + '&language=en_US&action=edit';
//                             tempRec.Edit = 'Edit';

//                             tempRec.CloneRecord = 'https://intel--crmdevint3.sandbox.my.site.com/imp/s/offering-edit?recordId=' + tempRec.offeringId + '&lang=NAS&action=clone';
//                             tempRec.Clone = 'Clone';
//                         }
//                         tempRecs.push( tempRec );
                        
//                     });
//         this.data = tempRecs;
//         this.initialRecords = tempRecs;
//         //console.log('Records-->'+this.records);
//         this.error = undefined;
//     })
//     .catch((error) => {
//         this.error = error;
//         this.data = [];
//         console.log('Error :' + JSON.stringify(error));
//     });
// }

// //Executes on the page load
// connectedCallback() {
//     this.getofferingData();
//     //this.loadData();
// }




// get dropdownTriggerClass() {
//     if (this.isExpanded) {
//         return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view slds-is-open'
//     } else {
//         return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view'
//     }
// }

// handleSearch(event) {
//     this.searchKey = event.target.value.toLowerCase();
    
//     this.getofferingData();
//     // if (searchKey) {
//     //     this.data = this.initialRecords;

//     //     if (this.data) {
//     //         let searchRecords = [];

//     //         for (let record of this.data) {
//     //             let valuesArray = Object.values(record);

//     //             for (let val of valuesArray) {
//     //                 let strVal = String(val);

//     //                 if (strVal) {

//     //                     if (strVal.toLowerCase().includes(searchKey)) {
//     //                         searchRecords.push(record);
//     //                         break;
//     //                     }
//     //                 }
//     //             }
//     //         }

//     //         console.log('Matched Offerings are ' + JSON.stringify(searchRecords));
//     //         this.data = searchRecords;
//     //     }
//     // } else {
//     //     this.data = this.initialRecords;
//     // }
// }

// handleclick(){
//     console.log('searchkey--->'+this.searchKey);
//     console.log('filter-->'+this.filter);
//     this.getofferingData();
// }

// handleClickExtend() {
//     this.isExpanded = !this.isExpanded;
// }

// handleFilterChangeButton(event) {
//     console.log('currenttarhet:::'+event.target.dataset.filter);
//     this.filter = event.target.dataset.filter;
//     this.isExpanded = !this.isExpanded;
//     this.getofferingData();
//     // if (filter !== this.currentFilter) {
//     //     this.currentFilter = event.target.dataset.filter;
//     //     setTimeout(() => {
//     //         this.handleFilterData(this.currentFilter), 0
//     //     });
//     // } else {
//     //     this.isLoaded = true;
//     // }
// }

// handleFilterData(filter) {
//     if (filter === ALL_Offerings) {
//         this.itemsForCurrentView = this.data;
//     } else {
//         this.itemsForCurrentView = this.data.filter(item => {
//             //return item.Priority === filter;
//         })
//     }
//     this.isLoaded = true;
// }

// previousHandler2(){
//     getPrevious({v_Offset: this.v_Offset, v_pagesize: this.page_size}).then(result=>{
//         this.v_Offset = result;
//         if(this.v_Offset === 0){
//             this.template.querySelector('c-paginator').changeView('trueprevious');
//         }else{
//             this.template.querySelector('c-paginator').changeView('falsenext');
//         }
//     });
// }
// nextHandler2(){
//     getNext({v_Offset: this.v_Offset, v_pagesize: this.page_size}).then(result=>{
//         this.v_Offset = result;
//        if(this.v_Offset + 50 > this.v_TotalRecords){
//             this.template.querySelector('c-paginator').changeView('truenext');
//         }else{
//             this.template.querySelector('c-paginator').changeView('falseprevious');
//         }
//     });
// }

// changeHandler2(event){
//     const det = event.detail;
//     this.page_size = det;
// }
// firstpagehandler(){
//     this.v_Offset = 0;
//     this.template.querySelector('c-paginator').changeView('trueprevious');
//     this.template.querySelector('c-paginator').changeView('falsenext');
// }
// lastpagehandler(){
//     this.v_Offset = this.v_TotalRecords - (this.v_TotalRecords)%(this.page_size);
//     this.template.querySelector('c-paginator').changeView('falseprevious');
//     this.template.querySelector('c-paginator').changeView('truenext');
// }

// }