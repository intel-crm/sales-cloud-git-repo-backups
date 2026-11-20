class pssActivationCallOnApproval extends LightningElement{}
// import {
//   LightningElement, wire, api,
// } from 'lwc';
// import SOLUTION_OBJECT from '@salesforce/schema/ArdiraSurvey__Survey_Result__c';
// import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
// import STATUS from '@salesforce/schema/ArdiraSurvey__Survey_Result__c.PSS_Solution_Status_Nm__c';
// import getSurveyResult from '@salesforce/apex/PSS_ActivationCallOnSolution.getSurveyResult';
// import updateResultRecord from '@salesforce/apex/PSS_ActivationCallOnSolution.updateResultRecord';
// import { handleError } from 'c/ipaErrorServiceMarketplace';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// import chooseOneLabel from '@salesforce/label/c.PMP_LeadGen_ChooseOne';
// import submitLabel from '@salesforce/label/c.PMP_LeadGen_Submit';
// import cancelLabel from '@salesforce/label/c.PMP_Cancel';
// import activationCallStatusLabel from '@salesforce/label/c.PSS_Activation_Status';
// import activationCallDateLabel from '@salesforce/label/c.PSS_Activation_Call_Date';
// import activationCallDetails from '@salesforce/label/c.PSS_Activation_Call_Details';
// import activationCallComments from '@salesforce/label/c.PSS_Activation_Call_Comments';
// import ActivationToastTitle from '@salesforce/label/c.PSS_ActivationToastTitle';
// import ActivationToastMessage from '@salesforce/label/c.PSS_ActivationToastMessage';


// /** A component to set the Activation call fields to the Solution Object.
//  *
//  * This component is exposed in the Admin Review Page when the status is approved and submit the solution.
//  * Used coreIntcModal, coreIntcSelect components as child components
//  *
//  * @example
//  * <!-- HTML component -->
//  * <c-pss-activation-call-on-approval onactivation={showModal} oncancel-activation={closeModal}></c-pss-activation-call-on-approval>
//  *
//  * @augments LightningElement
//  * @property {string} solutionId variable to store recordId of Solution.
//  * @property {boolean} isLink variable to identify where we are calling the activation details component.
//  */
// class pssActivationCallOnApproval extends LightningElement {
//   // *********** Variables ******************* //

//   @api solutionId;

//   @api isLink;

//   /**  variable to set the date to current day's date
//    *
//    * @type {Date}
//    * @private
//    */
//   today = new Date();

//   /** variable to set the default date in the date component.
//    *
//    * @type {Date}
//    * @private
//    */
//   defaultDate;

//   /** variable to set the selectDate
//    *
//    * @type {string}
//    * @private
//    */
//   selectedDate;

//   /** variable to set the activationComments of the text area component
//    *
//    * @type {string}
//    * @private
//    */
//   activationComments;

//   /** variable to set the selected options of the pick list values
//    *
//    * @type {object}
//    * @private
//    */
//   statusOptions;

//   /** variable to set the the styles of textarea component. It will be true when the component is rendered.
//    *
//    * @type {boolean}
//    * @private
//    */
//   isRendered = false;

//   /** variable to store the result after saving data in Solution Object
//    *
//    * @type {object[]}
//    * @private
//    */
//   updatedResult = [];

//   /** variable to store the activationCallResult data from UI
//    *
//    * @type {object[]}
//    * @private
//    */
//   activationCallResult = [];

//   /** variable to store the recordId from current page url
//    *
//    * @type {string}
//    * @private
//    */
//   recordId;

//   /** all custom labels used in the component were stored in the labels.
//    *
//    * @type {object}
//    */
//   labels = {
//     chooseOneLabel,
//     cancelLabel,
//     submitLabel,
//     activationCallStatusLabel,
//     activationCallDateLabel,
//     activationCallDetails,
//     activationCallComments,
//     ActivationToastTitle,
//     ActivationToastMessage,
//   };

//   /** variable to open the modal based on conditions
//    *
//    * @type {boolean}
//    * @private
//    */
//   openModal = true;

//   /** variable to get the selected option from the picklist component
//    *
//    * @type {string}
//    * @private
//    */
//   selectedOption;

//   /** variable to store the status of the solution
//    *
//    * @type {string}
//    * @private
//    */
//   solutionStatus;

//   /** variable to store the activation date which is retrieved from the backend
//    *
//    * @type {Date}
//    * @private
//    */
//   storedActivationDate;

//   /** variable to store the activation status which is retrieved from the backend
//    *
//    * @type {string}
//    * @private
//    */
//   storedActivationStatus;

//   /** variable to store the activation comments which is retrieved from the backend
//    *
//    * @type {string}
//    * @private
//    */
//   storedActivationComments;

//   /** variable to enable the edit the activation call details
//    *
//    * @type {boolean}
//    * @private
//    */
//   isActivationEditable = false;

//   /**
//    * variable to store the default option selected in picklist
//    *
//    * @type {string}
//    * @private
//    */
//   defalutOptionSelected;

//   /**
//    * variable to store the default text selected in text area
//    *
//    * @type {string}
//    * @private
//    */
//   defalutTextSelected;

//   /**
//    * variable to show the spinner when data is loading
//    *
//    * @type {boolean}
//    * @private
//    */
//   isLoading;
//   // ******* Functions ********

//   /**
//    * Onload function to get the recordId from the current pageURL when the component is loaded and to set
//    * the date value to default current day's date
//    *
//    * @private
//    */
//   connectedCallback() {
//     this.recordId = ((new URL(window.location.href))).searchParams.get('recordId');
//     this.defaultDate = this.today.toISOString().slice(0, 10);
//     this.selectedDate = this.defaultDate;
//     if (this.isLink) {
//       this.isLoading = true;
//       this.getSolutionData();
//     }
//   }

//   /**
//    * Method to get all the details of activation call and status from the backend
//    *
//    * @private
//    */
//   getSolutionData() {
//     getSurveyResult({ recordId: this.recordId })
//       .then((result) => {
//         for (let i = 0; i < result.length; i += 1) {
//           this.solutionStatus = result[i].solutionStatus;
//           if (typeof result[i].solutionActivationDate !== 'undefined') {
//             this.storedActivationDate = result[i].solutionActivationDate;
//           } else {
//             this.storedActivationDate = '';
//           }
//           if (typeof result[i].solutionActivationStatus !== 'undefined') {
//             this.storedActivationStatus = result[i].solutionActivationStatus;
//           } else {
//             this.storedActivationStatus = '';
//           }
//           if (typeof result[i].solutionActivationComments !== 'undefined') {
//             this.storedActivationComments = result[i].solutionActivationComments;
//           } else {
//             this.storedActivationComments = '';
//           }
//         }
//         if (this.solutionStatus === 'Approved' || this.solutionStatus === 'Converted To MP Offerings') {
//           this.isActivationEditable = true;
//           this.activationDetails();
//         } else {
//           this.isActivationEditable = false;
//           this.isLoading = false;
//         }
//       })
//       .catch((error) => {
//         handleError(error, 'pssActivationCallOnApproval - getSolutionData');
//       });
//   }

//   /**
//    * Method to get all the details of Activation from
//    * backend and store them in the component variables.
//    *
//    * @private
//    */
//   activationDetails() {
//     this.selectedDate = this.storedActivationDate ? this.storedActivationDate : this.defaultDate;
//     this.defalutOptionSelected = this.storedActivationStatus ? this.storedActivationStatus : this.labels.chooseOneLabel;
//     this.defalutTextSelected = this.storedActivationComments ? this.storedActivationComments : '';
//     this.isLoading = false;
//   }

//   /**
//    * method to set the styletag of textarea when the modal is loaded.
//    *
//    *@private
//    */
//   renderedCallback() {
//     if (!this.isRendered) {
//       this.isRendered = true;
//       const styleTag = document.createElement('style');
//       styleTag.innerText = 'textarea { height: 50px; min-width : 870px }';
//       this.template.querySelector('lightning-textarea').appendChild(styleTag);
//     }
//   }

//   /**
//    * Wire method to get Object Schema,
//    * retrieved for getting the recordtype value of solution object.
//    *
//    * @param {object} result  The result from the wire service.
//    * @param {object} result.data The data object returned from the wire service.
//    * @param {object} result.error The error object returned from the wire service.
//    * @private
//    */
//   @wire(getObjectInfo, { objectApiName: SOLUTION_OBJECT })
//   objectInfo;

//   /**
//    * Wire method to get the picklist values for a specified field Status from Solution Object.
//    *
//    * @param {object} result  The result from the wire service.
//    * @param {object} result.error  The error object returned from the wire service.
//    * @param {object} result.data  The data object returned from the wire service.
//    *
//    * @private
//    */
//   @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: STATUS })
//   statusValues({ data, error }) {
//     if (data) {
//       const item = [];
//       item.push({ label: this.labels.chooseOneLabel, value: '', Selected: this.labels.chooseOneLabel });
//       for (let i = 0; i < data.values.length; i += 1) {
//         item.push({ label: data.values[i].value, value: data.values[i].value });
//       }
//       this.statusOptions = item;
//     } else if (error) {
//       handleError(error, 'pssActivationCallOnApproval - getPcicklistValues');
//     }
//   }

//   /**
//    * Method to return the values of picklist retrieved from wire method to display them in the UI
//    *
//    * @returns {object} statusOptions
//    * @private
//    */
//   get statusOptions() {
//     return this.statusOptions;
//   }

//   /**
//    * Handle Date change method passes in event parameter.
//    * sets the selectedDate to the target value
//    *
//    * @param {event} event The event fired when changes the date in the date field.
//    * @private
//    */
//   handleDateChange(event) {
//     this.selectedDate = event.target.value;
//   }

//   /**
//    * Handle Text change method passes in event parameter.
//    * sets the activationComments to the target value
//    *
//    * @param {event} event The event fired when the value in the teaxt area component is updated.
//    * @private
//    */
//   handletextChange(event) {
//     this.activationComments = event.target.value;
//   }

//   /**
//    * Handle change method passes in event parameter.
//    * sets the selectedOption to the target value
//    *
//    * @param {event} event The event fired the option of the picklist value is changed.
//    * @private
//    */
//   handleChange(event) {
//     this.selectedOption = event.target.value;
//   }

//   /**
//    * On click of Submit button, calls the update method from apex class,
//    * to update the input values in the solution object.
//    *
//    * @private
//    */
//   onSubmit() {
//     this.validateSurveyResult();
//   }

//   /**
//    * On click of Cancel button, closes the modal in UI.
//    *
//    * @private
//    */
//   closeModalOnCancel() {
//     this.openModal = false;
//     this.dispatchEvent(new CustomEvent('activation'));
//     this.template.querySelector('c-core-intc-modal').closeModal();
//   }

//   /** Method to close the modal when inverse button of modal is clicked
//    *
//    * @private
//    */
//   closeActivationModal() {
//     this.openModal = false;
//     this.dispatchEvent(new CustomEvent('activation'));
//   }

//   /**
//    * Method to validate the input values in the form.
//    *
//    * @private
//    */
//   validateSurveyResult() {
//     if (this.isLink) {
//       const dateCheck = this.template.querySelector('lightning-input').reportValidity();
//       const commentCheck = this.template.querySelector('lightning-textarea').reportValidity();
//       if (dateCheck && commentCheck) {
//         this.updatedActivationCallDetails();
//       }
//     } else { // if (this.selectedDate && (this.selectedOption || this.activationComments)) {
//       this.updatedActivationCallDetails();
//     }
//   }

//   /** method to update activation call input values.
//    *
//    *
//    * @private
//    */
//   updatedActivationCallDetails() {
//     this.activationCallResult.push(this.selectedDate);
//     this.selectedOption = this.selectedOption ? this.selectedOption : this.storedActivationStatus;
//     this.activationCallResult.push(this.selectedOption);
//     this.activationComments = this.activationComments ? this.activationComments : this.storedActivationComments;
//     this.activationCallResult.push(this.activationComments);
//     updateResultRecord({ surveyResult: this.activationCallResult, recordId: this.recordId })
//       .then((result) => {
//         this.updatedResult = result;
//         this.dispatchEvent(new CustomEvent('activation'));
//         this.template.querySelector('c-core-intc-modal').closeModal();
//         this.openModal = false;
//         if (this.isLink) {
//           this.fireSuccessToast();
//         }
//       })
//       .catch((error) => {
//         handleError(error, 'pssActivationCallOnApproval - updateResultRecord');
//       });
//   }

//   /**
//    * Method to show the success toast message when click on submit button.
//    *
//    * @private
//    */
//   fireSuccessToast() {
//     const evt = new ShowToastEvent({
//       title: this.labels.ActivationToastTitle,
//       message: this.labels.ActivationToastMessage,
//       variant: 'success',
//       mode: 'dismissable',
//     });
//     this.dispatchEvent(evt);
//   }
// }
// export default pssActivationCallOnApproval;