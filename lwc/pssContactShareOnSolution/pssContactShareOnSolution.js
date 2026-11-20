class PssContactShareOnSolution extends NavigationMixin(LightningElement){}
// import {
//   LightningElement, wire, track, api,
// } from 'lwc';
// import { getRecord } from 'lightning/uiRecordApi';
// import STATUS from '@salesforce/schema/ArdiraSurvey__Survey_Result__c.PSS_Partner_Solution_Lifecycle_Status_Nm__c';
// import SUBMITTER from '@salesforce/schema/ArdiraSurvey__Survey_Result__c.ArdiraSurvey__Assigned_To_Contact__r.Name';
// import searchContactList from '@salesforce/apex/PSS_ContactsShare.searchContact';
// import getContactList from '@salesforce/apex/PSS_ContactsShare.retrieveContact';
// import shareSolution from '@salesforce/apex/PSS_ContactsShare.sharingSolutionRecords';
// import retrieveSharedList from '@salesforce/apex/PSS_ContactsShare.retrieveShareRecords';
// import retrieveSharedContactsForEmail from '@salesforce/apex/PSS_ContactsShare.fetchSharedContactsForSolution';
// import { NavigationMixin } from 'lightning/navigation';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { handleError } from 'c/ipaErrorServiceMarketplace';

// import header from '@salesforce/label/c.PSS_AddContactsModal_Header';
// import placeholder from '@salesforce/label/c.Core_MDF_LWC_SearchUser_Label';
// import saveButtonLabel from '@salesforce/label/c.PSS_SaveContacts_Button';
// import manageText from '@salesforce/label/c.PSS_ManageContactText_AddContact';
// import manageTextContd from '@salesforce/label/c.PSS_ManageContactTextcont_AddContact';
// import noResultsFoundSharedContacts from '@salesforce/label/c.PSS_NoResultsFoundFor_ViewSharedContacts_Link';
// import noResultsFound from '@salesforce/label/c.PSS_NoContactsFoundMsg_AddContact';
// import noResultsFoundContd from '@salesforce/label/c.PSS_NoContactsFoundMsgContd_AddContact';
// import manageIPALink from '@salesforce/label/c.PSS_ManageContactLink_AddContact';
// import manageIPALinkURL from '@salesforce/label/c.PSS_AddContactIPAURL';
// import success from '@salesforce/label/c.PMP_Success';
// import toastMessageOnSuccess from '@salesforce/label/c.PSS_AddContacts_ToastMessage';
// import solutionContacts from '@salesforce/label/c.PSS_Solution_Contacts';
// import submitterLabel from '@salesforce/label/c.PSS_Solution_Submitter';

// /** A component to add contacts to the Solutions.
//  * This component is exposed in the Solution Detail Page and create edit solution page
//  * component will be visible only when the solution is in draft or update required status
//  * Used coreIntcModal as child component.
//  *
//  * @example
//  * <!-- HTML component -->
//  * <c-pss-contact-share-on-solution solution-id={solutionId} onclosemodal={handleClose} is-button="true" is-v-f-page=false></c-pss-contact-share-on-solution>
//  *
//  * @augments NavigationMixin
//  * @augments LightningElement
//  * @property {string} solutionId variable to store recordId of Solution if the Add contacts button is in created Edit solution page.
//  * @property {boolean} [isVFPage=false] variable to identify whether the LWC Component has been invoked from VF Page (or) not.
//  * @property {boolean} isButton variable to store boolean value to identify from where the component is being called
//  * @property {boolean} isOpenPopup variable to identify the model popup to open in create-Edit Page and Solution Detail Page.
//  */
// class PssContactShareOnSolution extends NavigationMixin(LightningElement) {
//   /** API Variables */

//   @api solutionId;

//   @api isVFPage = false;

//   @api isOpenPopup;

//   @api isButton;

//   /** ***** Track Variables  */

//   /**
//    * variable to store the pilldata
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track pillData = [];

//   /**
//    * variable to store the IPA contacts.
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track contactsRecord = [];

//   /**
//    * variable to store the shared contact list
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track sharedRecordList = [];

//   /**
//    * variable to store the contact list when using searchbox
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track contactSearchData = [];

//   /**
//    * variable to store the preselected data of initial datatable
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track initialSelected = [];

//   /**
//    * variable to store the preselected data of datatable in search load
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track searchPreSelected = [];

//   /**
//    * variable to store the selected rows when search is used.
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track searchGetRows = [];

//   /**
//    * variable to store the selected data of initial datatable
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track selectedData = [];

//   /**
//    * variable to store the column data of datatable
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track columns = [
//     {
//       label: 'Email', fieldName: 'Email', type: 'Email', hideDefaultActions: true,
//     },
//   ];

//   /**
//    * variable to store submitter name of Solution.
//    *
//    * @type {string}
//    * @private
//    */
//   submitterName = null;

//   /**
//    * variable to store recordId of Solution.
//    *
//    * @type {string}
//    * @private
//    */
//   recordId;

//   /**
//    * variable to store the boolean variable true if search string is there else false
//    *
//    * @type {boolean}
//    * @private
//    */
//   isContactSearch;

//   /**
//    * variable to store the boolean variable true if contacts available else false
//    *
//    * @type {boolean}
//    * @private
//    */
//   isContactsAvailable;

//   /**
//    * variable to store the boolean variable true if contacts are loading
//    *
//    * @type {boolean}
//    * @private
//    */
//   isLoading;

//   /**
//    * variable to store boolean value true if pilldata exists.
//    *
//    * @type {boolean}
//    * @private
//    */
//   isPillData;

//   /**
//    * variable to store boolean value to open a modal based on conditions.
//    *
//    * @type {boolean}
//    * @private
//    */
//   openModal;

//   /**
//    * variable to enable/disable the save button after rowselection
//    *
//    * @type {boolean}
//    * @private
//    */
//   isSaveDisabled = true;

//   /**
//    * variable to show the spinner if data is loading.
//    *
//    * @type {boolean}
//    * @private
//    */
//   showSpinner = true;


//   /** all custom labels used in the component were stored in the labels.
//    *
//    * @type {object}
//    * @private
//    */
//   labels = {
//     header,
//     placeholder,
//     saveButtonLabel,
//     manageText,
//     manageTextContd,
//     noResultsFoundContd,
//     manageIPALink,
//     manageIPALinkURL,
//     noResultsFound,
//     success,
//     toastMessageOnSuccess,
//     solutionContacts,
//     submitterLabel,
//     noResultsFoundSharedContacts,
//   };

//   /**
//    * Wire method to get the status of the current record from Solution Object.
//    *
//    * @param {object} result  The result from the wire service.
//    * @param {object} result.error  The error object returned from the wire service.
//    * @param {object} result.data  The data object returned from the wire service.
//    *
//    * @private
//    */
//   @wire(getRecord, { recordId: '$recordId', fields: [STATUS, SUBMITTER] })
//   surveyStatus({ data, error }) {
//     if (data) {
//       this.submitterName = data.fields.ArdiraSurvey__Assigned_To_Contact__r.displayValue;
//     } else if (error) {
//       handleError(error, 'PssContactShareOnSolution - surveyStatus');
//     }
//   }

//   /**
//    * retrieves the recordId retrieved from the current page
//    * calls the imperative method to get all the IPA contacts for this solution record.
//    * OR to get all the shared contacts for emails.
//    *
//    * @private
//    */
//   connectedCallback() {
//     if (this.isOpenPopup) {
//       this.openModal = true;
//     } else {
//       this.openModal = false;
//     }
//     if (this.solutionId === '') {
//       this.recordId = ((new URL(window.location.href))).searchParams.get('recordId');
//     } else {
//       this.recordId = this.solutionId;
//     }
//     // calling methods from button or link on solution detail page
//     if (this.isButton) {
//       this.getAllContacts();
//     } else {
//       this.getSharedContactsForEmail();
//     }
//   }

//   /**
//    * Method handled to get all IPA contacts and calls method to retrieve the shared list of the solution.
//    *
//    * @private
//    */
//   getAllContacts() {
//     this.isLoading = true;
//     getContactList({ recordId: this.recordId })
//       .then((result) => {
//         this.contactsRecord = result;
//         if (this.contactsRecord && this.contactsRecord.length > 0) {
//           this.getSharedList();
//           this.isContactsAvailable = true;
//         } else {
//           this.isContactsAvailable = false;
//         }
//         this.isLoading = false;
//       })
//       .catch((error) => {
//         handleError(error, 'pssContactShareOnSolution - getContactList');
//       });
//   }

//   /**
//    * Method handled all IPA contacts and calls calls method to retrieve the shared list.
//    *
//    * @private
//    */
//   getSharedList() {
//     retrieveSharedList({
//       conList: this.contactsRecord,
//       recordId: this.recordId,
//     })
//       .then((data) => {
//         for (let i = 0; i < data.length; i += 1) {
//           this.sharedRecordList.push(data[i]);
//         }
//         this.initialSelected = this.sharedRecordList.map((record) => record.Id);
//         this.pillData = [...this.sharedRecordList];
//         this.isPillContainer();
//       })
//       .catch((error) => {
//         handleError(error, 'pssContactShareOnSolution - retrieveSharedList');
//       });
//   }

//   /** handles search clear from search component
//    *
//    * @param {event} event The event fired when clear button is clicked in searchbox.
//    * @private
//    */
//   handleClearKeyword(event) {
//     event.stopPropagation();
//     this.currentlySearching = false;
//     this.isContactSearch = false;

//     this.contactSearchData.forEach((e) => this.initialSelected.forEach((e2) => {
//       if (e.Id === e2) {
//         const index = this.initialSelected.indexOf(e2);
//         this.initialSelected.splice(index, 1);
//       }
//     }));
//     this.initialSelected = this.initialSelected.concat(this.searchPreSelected);
//     this.initialSelected = [...new Set(this.initialSelected)];
//     this.isPillContainer();
//   }

//   /** handles search input - finished typing
//    *
//    * @param {event} event finished typing event from Searchbox
//    * @private
//    */
//   handleFinishedTyping(event) {
//     this.searchString = event.detail.keywordValue.trim();
//     event.stopPropagation();
//     this.isContactSearch = true;
//     this.handleKeyUp();
//   }

//   /** handle remove removes the item of pill
//    *
//    * @param {event} event fires when item of pill data is removed.
//    * @private
//    */
//   handleRemove(event) {
//     // retrieves the ID of event clicked attribute.
//     const removeItems = event.currentTarget.getAttribute('data-id1');
//     if (removeItems) {
//       this.isSaveDisabled = false;
//     }
//     // retrieves the index of the element
//     if (!this.isContactSearch) {
//       for (let i = 0; i < this.initialSelected.length; i += 1) {
//         if (this.initialSelected[i] === removeItems && this.pillData[i].Id === removeItems) {
//           this.initialSelected.splice(i, 1);
//           this.pillData.splice(i, 1);
//           break;
//         }
//       }
//       this.template.querySelector('[data-id3="datarow"]').selectedRows = this.initialSelected;
//     } else if (this.isContactSearch) {
//       for (let k = 0; k < this.pillData.length; k += 1) {
//         if (this.pillData[k].Id === removeItems) {
//           this.pillData.splice(k, 1);
//           break;
//         }
//       }

//       for (let m = 0; m < this.initialSelected.length; m += 1) {
//         if (this.initialSelected[m] === removeItems) {
//           this.initialSelected.splice(m, 1);
//           break;
//         }
//       }

//       for (let i = 0; i < this.searchPreSelected.length; i += 1) {
//         if (this.searchPreSelected[i] === removeItems) {
//           this.searchPreSelected.splice(i, 1);
//           break;
//         }
//       }
//       this.template.querySelector('[data-id4="datarow"]').selectedRows = this.searchPreSelected;
//     }
//   }

//   /**
//    * Method handled when the input in search component is typed.
//    * this method calls search contacts method to call the search from the Contacts list.
//    *
//    * @private
//    */
//   handleKeyUp() {
//     if (this.searchString && this.searchString.length > 0) {
//       this.isContactSearch = true;
//       searchContactList({
//         contactList: this.contactsRecord,
//         searchKey: this.searchString,
//       })
//         .then((result) => {
//           this.contactSearchData = result;

//           if (this.contactSearchData && this.contactSearchData.length > 0) {
//             this.searchPreSelected = [...this.initialSelected];
//             this.pillData = [...this.pillData];
//             this.isPillContainer();
//           }
//         })
//         .catch((error) => {
//           handleError(error, 'pssContactShareOnSolution - searchContactList');
//         });
//     } else {
//       this.isContactSearch = false;

//       this.contactSearchData.forEach((element1) => this.initialSelected.forEach((element2) => {
//         if (element1.Id === element2) {
//           const index = this.initialSelected.indexOf(element2);
//           this.initialSelected.splice(index, 1);
//         }
//       }));
//       this.initialSelected = this.initialSelected.concat(this.searchPreSelected);
//       this.initialSelected = [...new Set(this.initialSelected)];
//       this.isPillContainer();
//     }
//   }

//   /**
//    * Method to send all selected/deselected data so that the solution can be shared to the sent list.
//    * selected option event from Searchbox
//    *
//    * @private
//    */
//   shareContact() {
//     this.selectedData = this.pillData;
//     this.openModal = false;
//     let toShareData = [];
//     if (this.selectedData && this.selectedData.length > 0) {
//       toShareData = this.selectedData;
//     } else {
//       toShareData = null;
//     }
//     shareSolution({
//       contacts: toShareData,
//       asrId: this.recordId,
//     }).then((result) => {
//       this.sharedResult = result;
//       if (this.isVFPage) {
//         // Fire CustomEvent when the LWC Component is invoked inside VF Page
//         this.dispatchEvent(new CustomEvent('toasteventAddCont', {
//           composed: true,
//           bubbles: true,
//           cancelable: true,
//           detail: {
//             title: this.labels.success,
//             mode: 'pester',
//             message: this.labels.toastMessageOnSuccess,
//             variant: 'success',
//           },
//         }));
//       } else {
//         // Fire Standard ToastEvent when the LWC Component is invoked outside VF Page
//         this.dispatchEvent(new ShowToastEvent({
//           title: this.labels.success,
//           mode: 'pester',
//           message: this.labels.toastMessageOnSuccess,
//           variant: 'success',
//         }));
//       }
//       this.dispatchEvent(new CustomEvent('closemodal'));
//     })
//       .catch((error) => {
//         handleError(error, 'pssContactShareOnSolution - shareContact');
//         this.dispatchEvent(new CustomEvent('closemodal'));
//       });
//     this.isSaveDisabled = true;
//   }

//   /**
//    * Method to handle all selected rows from the datatable.
//    *
//    * @param {event} event event fired when row is selected/deselected
//    * @private
//    */
//   rowSelection(event) {
//     const rowRecord = event.detail.selectedRows;
//     if (rowRecord) {
//       this.isSaveDisabled = false;
//     }
//     this.selectedData = this.template.querySelector('[data-id3="datarow"]').getSelectedRows();
//     const allSelectedRows = this.initialSelected;

//     allSelectedRows.splice(0, allSelectedRows.length);

//     for (let k = 0; k < rowRecord.length; k += 1) {
//       allSelectedRows.push(rowRecord[k].Id);
//     }

//     this.initialSelected.push(...allSelectedRows);
//     this.initialSelected = [...new Set(this.initialSelected)];
//     this.pillData = [...this.selectedData];

//     this.isPillContainer();
//   }

//   /**
//    * Method to handle all selected rows from the datatable when the contact search is enabled.
//    *
//    * @param {event} event event fired when row is selected/deselected
//    * @private
//    */
//   searchRowSelection(event) {
//     const searchRowSelected = event.detail.selectedRows;
//     if (searchRowSelected) {
//       this.isSaveDisabled = false;
//     }
//     this.searchGetRows = this.template.querySelector('[data-id4="datarow"]').getSelectedRows();

//     const searchAllSelected = this.searchPreSelected;

//     searchAllSelected.splice(0, searchAllSelected.length);

//     for (let k = 0; k < searchRowSelected.length; k += 1) {
//       searchAllSelected.push(searchRowSelected[k].Id);
//     }

//     this.searchPreSelected.push(...searchAllSelected);
//     this.searchPreSelected = [...new Set(this.searchPreSelected)];

//     this.pillData = [...this.pillData, ...searchRowSelected];

//     // delete duplicates in pill data
//     this.pillData = this.pillData.reduce((unique, item) => {
//       if (!unique.some((obj) => obj.Id === item.Id)) {
//         unique.push(item);
//       }
//       return unique;
//     }, []);

//     // to get the common records between selected data of initial datatable and the contacts when search enabled.
//     const commonData = this.pillData.filter((item1) => this.contactSearchData.some((item2) => item1.Id === item2.Id));

//     // To get the difference data between commondata and searchGetRows
//     const difference = commonData.filter((ele1) => !searchRowSelected.some((ele2) => ele1.Id === ele2.Id));

//     for (let i = 0; i < this.pillData.length; i += 1) {
//       for (let m = 0; m < difference.length; m += 1) {
//         if (this.pillData[i] === difference[m]) {
//           this.pillData.splice(i, 1);
//           break;
//         }
//       }
//     }
//     this.isPillContainer();
//   }

//   /**
//    * Method to return true if there exists pilldata else false.
//    *
//    * @private
//    */
//   isPillContainer() {
//     if (this.pillData && this.pillData.length > 0) {
//       this.isPillData = true;
//     } else {
//       this.isPillData = false;
//     }
//   }

//   /**
//    * Method to close the modal.
//    *
//    * @private
//    */
//   handleClose() {
//     this.openModal = false;
//     this.dispatchEvent(new CustomEvent('closemodal'));
//     this.showSpinner = false;
//   }

//   /**
//    * Method to retrieve the shared contacts for email sends
//    *
//    * @private
//    */
//   getSharedContactsForEmail() {
//     this.isContactsAvailable = false;
//     retrieveSharedContactsForEmail({ solutionId: this.recordId })
//       .then((data) => {
//         for (let i = 0; i < data.length; i += 1) {
//           this.contactsRecord.push(data[i]);
//         }
//         if (this.contactsRecord.length > 0) {
//           this.isContactsAvailable = true;
//         }
//         this.showSpinner = false;
//       })
//       .catch((error) => {
//         handleError(error, 'pssContactShareOnSolution - getSharedContactsForEmail');
//       });
//   }
// }

// export default PssContactShareOnSolution;