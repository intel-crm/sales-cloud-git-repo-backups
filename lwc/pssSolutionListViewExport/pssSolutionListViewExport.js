class PssSolutionExportListView extends LightningElement{}
// import { LightningElement, wire } from 'lwc';
// import fetchRecords from '@salesforce/apex/PMP_ExportListView.fetchRecords';
// import getListView from '@salesforce/apex/PMP_ExportListView.listValues';
// import getFetchKeys from '@salesforce/apex/PMP_ExportListView.fetchKeys';
// import getexportButtonVisibility from '@salesforce/apex/PSS_PartnersOnSolution.getexportButtonVisibility';
// import { handleError } from 'c/ipaErrorServiceMarketplace';
// import exportListView from '@salesforce/label/c.PSS_Export_List_View';
// import exportDropDownHeading from '@salesforce/label/c.PSS_ExportDropDownHeading';
// import exportExcelButton from '@salesforce/label/c.PSS_ExportExcelButton';
// import exportCSVButton from '@salesforce/label/c.PSS_ExportCSVButton';
// import exportCloseButton from '@salesforce/label/c.PSS_ExportCloseButton';
// import exportHeader from '@salesforce/label/c.PSS_EXPORT';

// /** A component used to export records from a selected list view and download the exported records in csv or xls format.
//  *
//  * This component is exposed in Solution List View Page.
//  * coreIntcModal and coreIntcSelect are used as child components in this component.
//  *
//  * @example
//  * <!-- HTML component -->
//  * <c-pss-solution-list-view-export onclosemodal={handleHideModal}></c-pss-solution-list-view-export>
//  *
//  * @augments LightningElement
//  */
// class PssSolutionExportListView extends LightningElement {
//   // *********** Variables ******************* //
//     /** variable to store the value to open the modalbox when we click on the export list view button.
//      *
//      * @type {boolean}
//      * @private
//      */
//     openPopup = false;

//     /** variable to store the selected list view option.
//      *
//      * @type {string}
//      * @private
//      */
//     selectedValue;

//     /** variable to store the list view names in modal box drop down.
//      *
//      * @type {string}
//      * @private
//      */
//     lstViewName;

//     /** variable to store the downloadable button type csv/xls.
//      *
//      * @type {string}
//      * @private
//      */
//     exportBtnType;

//     /** variable to validate the downloadable file type csv/xls.
//      *
//      * @type {string}
//      * @private
//      */
//     exportType;

//     /** variable to store the selected list view records count.
//      *
//      * @type {number}
//      * @private
//      */
//     resultCount;

//     /** variable to store sObject details fetched from backend
//      *
//      * @type {object[]}
//      * @private
//      */
//     fetchedsObjectList;

//     /** variable to fetch the column names
//      *
//      * @type {object.<string, string>}
//      * @private
//      */
//     colKeys;

//     /** variable to store the picklist value if true
//      *
//      * @type {object[]}
//      * @private
//      */
//     listOptions = [];

//     /** variable to store the retrieved data and convert to csv/xls.
//      *
//      * @type {string}
//      * @private
//      */
//     csvFile = '';

//     /**
//      * variable to store the result from apex controller
//      *
//      * @type {boolean}
//      * @private
//      */
//     showExportButton;

//     /** all custom labels used in the component were stored in the labels.
//      *
//      * @type {object}
//      * @private
//      */

//     showsearchbutton = false;
//     labels = {
//       exportListView,
//       exportDropDownHeading,
//       exportExcelButton,
//       exportCSVButton,
//       exportCloseButton,
//       exportHeader,
//     };

//     /**
//      *Wire method to get the list view values for a specified Solution Object.
//      *
//      * @param {object} getListView Wiring service to fetch data.
//      * @param {string} getListView.data The data fetched from the wired service.
//      * @param {string} getListView.error The error object returned from the wire service.
//      */
//     @wire(getListView, { sObjectName: 'ArdiraSurvey__Survey_Result__c' })
//     listViewResult({ error, data }) {
//       if (data) {
//         for (let i = 0; i < data.length; i += 1) {
//           this.listOptions.push({
//             label: data[i].label,
//             value: data[i].listViewId,
//           });
//         }
//       } else if (error) {
//         handleError(error, 'pssSolutionListViewExport - getListView');
//       }
//     }

//     /**
//      *Sets the openPopup value to true if clicked on the 'Export List View' button.
//      *
//      * @private
//      */
//     handleShowModal() {
//       this.openPopup = true;
//     }

//     /**
//      * Method to close the modal when Cancel button is clicked
//      * It calls the close method of coteIntcModal's close method.
//      *
//      * @private
//      */
//     handleHideModal() {
//       this.openPopup = false;
//       this.selectedValue = this.listOptions[0].value; // added by krishna ch on close button click.
//     }

//     /**
//      * Calls the init method that will load all the list view records on the load of the component
//      *
//      * @private
//      */
//     connectedCallback() {
//       let pageUrl = window.location.href;
//         if(pageUrl.includes('partner-solution-list')){
//             console.log('@@==>'+pageUrl.includes('partner-solution-list'));
//             this.showsearchbutton = true;
//         }
//       getexportButtonVisibility()
//         .then((result) => {
//           this.showExportButton = result;
//           // eslint-disable-next-line no-console
//           console.log(`result data :${JSON.stringify(result)}`);
//           if (this.showExportButton) {
//             this.loadRecords();
//           }
//         })
//         .catch((error) => {
//           handleError(error, 'pssSolutionListViewExport - buttonVisibility');
//         });
//     }


//     /**
//      * Handle to change the picklist values when changed from UI
//      *
//      * @param {event} event The event fired when the selected picklist value is changed
//      * @private
//      */
//     onPicklistChange(event) {
//       this.selectedValue = event.target.value;
//     }

//     /**
//      * Handle to load the records on the button click
//      *
//      * @param {event} event The event fired when button is clicked from UI
//      * @private
//      */
//     exportRecords(event) {
//       this.exportBtnType = event.target.dataset.name;
//       for (let i = 0; i < this.listOptions.length; i += 1) {
//         if (this.listOptions[i].value === this.selectedValue) {
//           this.lstViewName = this.listOptions[i].label;
//           break;
//         }
//       }
//       if (this.exportBtnType === exportCSVButton) {
//         this.exportType = 'csv';
//       } else {
//         this.exportType = 'excel';
//       }
//       this.csvFile = '';
//       this.loadColKeys();
//     }

//     /**
//      * Method to call Apex method imperatively to fetch list view records from salesforce
//      *
//      *
//      * @private
//      */
//     loadRecords() {
//       fetchRecords({
//         filterId: this.selectedValue,
//         sObjectName: 'ArdiraSurvey__Survey_Result__c',
//       })
//         .then((result) => {
//           this.resultCount = result.length;
//           this.fetchedsObjectList = result;
//           if (this.colKeys != null) {
//             this.convertArrayOfObjectsToCSV();
//           }
//         })
//         .catch((error) => {
//           handleError(error, 'pssSolutionListViewExport - loadRecords');
//         });
//     }

//     /**
//      * Method to call Apex method imperatively to fetch list view column label from salesforce
//      *
//      *
//      * @private
//      */
//     loadColKeys() {
//       getFetchKeys({
//         filterId: this.selectedValue,
//         sObjectName: 'ArdiraSurvey__Survey_Result__c',
//       })
//         .then((result) => {
//           this.colKeys = result;
//           this.loadRecords();
//         })
//         .catch((error) => {
//           handleError(error, 'pssSolutionListViewExport - loadColKeys');
//         });
//     }

//     /**
//      * Method to convert obtained list view records to csv or xls format
//      *
//      *
//      * @private
//      */
//     convertArrayOfObjectsToCSV() {
//       const colkeys = [];
//       const keys = Object.keys(this.colKeys);
//       const values = Object.values(this.colKeys);
//       const listLength = this.fetchedsObjectList.length;
//       const keysLength = keys.length;
//       for (let i = 0; i < keysLength; i += 1) {
//         if (keys[i] != null) {
//           colkeys.push(keys[i]);
//           this.csvFile += `${values[i]},`;
//         }
//       }
//       this.csvFile += '\n';
//       const colkeysLength = colkeys.length;
//       for (let j = 0; j < listLength; j += 1) {
//         const map = this.fetchedsObjectList[j];
//         for (let i = 0; i < colkeysLength; i += 1) {
//           let solutionApplicable = '';
//           if ((colkeys[i] === 'toLabel(PSS_Partner_Solution_Lifecycle_Status_Nm__c)'
//                         && map.PSS_Partner_Solution_Lifecycle_Status_Nm__c !== undefined)
//                     || (colkeys[i] === 'LastModifiedBy.Name' && map.LastModifiedBy !== undefined)
//                     || (colkeys[i] === 'CreatedBy.Name' && map.CreatedBy !== undefined)
//                     || (colkeys[i] === 'PSS_Solution_Name_Id_Txt__c' && map.PSS_Solution_Name_Id_Txt__c !== undefined)
//                     || map[colkeys[i]] !== undefined) {
//             switch (colkeys[i]) {
//               case 'LastModifiedBy.Name':
//                 this.csvFile += `"${map.LastModifiedBy.Name}",`;
//                 break;
//               case 'CreatedBy.Name':
//                 this.csvFile += `"${map.CreatedBy.Name}",`;
//                 break;
//               case 'toLabel(PSS_Partner_Solution_Lifecycle_Status_Nm__c)':
//                 this.csvFile += `"${map.PSS_Partner_Solution_Lifecycle_Status_Nm__c}",`;
//                 break;
//               case 'PSS_View_Program_Applicable_Txt__c':
//                 solutionApplicable = this.stripHtmlTags(map[colkeys[i]]);
//                 if (solutionApplicable !== '') this.csvFile += `"${this.stripHtmlTags(map[colkeys[i]])}",`;
//                 else this.csvFile += '-,';
//                 break;
//               case 'PSS_Solution_Name_Id_Txt__c':
//                 this.csvFile += `"${this.stripHtmlTags(map.PSS_Solution_Name_Id_Txt__c)}",`;
//                 break;
//               default:
//                 this.csvFile += `"${map[colkeys[i]]}",`;
//                 break;
//             }
//           } else {
//             this.csvFile += '-,';
//           }
//         }
//         this.csvFile += '\n';
//       }
//       this.csvFile += '\n';
//       this.download();
//     }

//     /**
//      * Method to extract field value from text wrapped within html anchor tag
//      *
//      * @param {string} str The string received containing HTML tag
//      *
//      * @returns {string} returning the text after removing the heprlink.
//      * @private
//      */
//     stripHtmlTags(str) {
//       if ((str === null) || (str === '')) {
//         return '';
//       }
//       const data = str.toString();
//       return data.replace(/<[^>]*>/g, '');
//     }

//     /**
//      * Method to download the obtained list view records in csv or xls format
//      *
//      *
//      * @private
//      */
//     download() {
//       if (this.exportBtnType !== undefined && this.selectedValue !== undefined) {
//         const blob = new Blob(['\ufeff', this.csvFile]);
//         const downloadElement = document.createElement('a');
//         downloadElement.href = window.URL.createObjectURL(blob, {
//           type: `text/csv;charset=utf-8,%EF%BB%BF${encodeURIComponent(this.csvFile)}`,
//         });
//         downloadElement.target = '_self';
//         if (this.exportType === 'csv') {
//           downloadElement.download = `${this.lstViewName}.csv`;
//         } else {
//           downloadElement.download = `${this.lstViewName}.xls`;
//         }
//         document.body.appendChild(downloadElement);
//         downloadElement.click();
//       }
//     }
// }
// export default PssSolutionExportListView;