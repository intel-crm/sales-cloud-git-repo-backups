import { LightningElement, api } from 'lwc';
// import updateOfferingDates from '@salesforce/apex/PMP_OfferingDetailsController.updateOfferingDates';
// import endDateError from '@salesforce/label/c.PMP_End_Date_Less_Than_Start_Date_Error';
// import validFrom from '@salesforce/label/c.PMP_Offering_Valid_From';
// import validTo from '@salesforce/label/c.PMP_Offering_Valid_To';
// import submit from '@salesforce/label/c.PMP_LeadGen_Submit';
// import cancel from '@salesforce/label/c.Core_PMP_Cancel';
// import endDateEqualToStartDate from '@salesforce/label/c.PMP_End_Date_Equals_Start_Date_Error';
// import offeringValidityPeriod from '@salesforce/label/c.PMP_Offering_Validity_Period';
// import success from '@salesforce/label/c.PMP_Success';
// import successMessage from '@salesforce/label/c.PMP_offering_Updated_successfully';
// import error from '@salesforce/label/c.PMP_Error';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { handleError } from 'c/ipaErrorServiceMarketplace';
// import { loadScript } from 'lightning/platformResourceLoader';
// import CoreResource from '@salesforce/resourceUrl/Core_INTC';

// // This component uses momentJS from the Core_INTC Static Resource
// /* global moment */

// /**
//  * Date Update Modal on Offering Detail page
//  *
//  * @property {string} offeringId offering id
//  * @fires close when modal is closed
//  */
class IpaOfferingDateUpdate extends LightningElement {}
//   @api offeringId;

//   /** min start date
//    * today in 'YYYY-MM-DD' format
//    *
//    * @type {string}
//    * @private
//    */
//    minStartDate = '';

//   /** shows spinner
//    *
//    * @type {boolean}
//    * @private
//    */
//   showSpinner = false;

//   /** start date value
//    *
//    * @type {string}
//    * @private
//    */
//   startDate;

//   /** end date value
//    *
//    * @type {string}
//    * @private
//    */
//   endDate;

//   /** end date input disabled
//    *
//    * @type {boolean}
//    * @private
//    */
//   endDateDisabled = true;

//   /** save button disabled
//    *
//    * @type {boolean}
//    * @private
//    */
//   saveDisabled = true;

//   /** end date minimum value
//    *
//    * @type {string}
//    * @private
//    */
//   minEndDate = '';

//   /** custom labels
//    *
//    * @type {object}
//    * @private
//    */
//   label = {
//     endDateError,
//     validFrom,
//     validTo,
//     submit,
//     cancel,
//     endDateEqualToStartDate,
//     offeringValidityPeriod,
//     success,
//     successMessage,
//     error,
//   };

//   /**
//    * connected callback
//    */
//   connectedCallback() {
//     this.showSpinner = true;
//     loadScript(this, `${CoreResource}/general/moment.min.js`).then(() => {
//       this.minStartDate = moment().format('YYYY-MM-DD');
//       this.minEndDate = this.minStartDate;
//       this.showSpinner = false;
//     });
//   }

//   /**
//    * handle save
//    *
//    * @private
//    */
//   handleSave() {
//     // checking the form validity before save
//     const validityCheck = this.checkValidity();

//     if (validityCheck) {
//       this.showSpinner = true;
//       const strtDt = moment(this.startDate).toDate();
//       const endDt = moment(this.endDate).toDate();
//       updateOfferingDates({
//         offering: {
//           Id: this.offeringId,
//           PMP_Partner_Offering_Start_Dt__c: strtDt,
//           PMP_Partner_Offering_End_Dt__c: endDt,
//         },
//       })
//         .then(() => {
//           this.showToast(
//             this.label.success,
//             this.label.successMessage,
//             'success',
//           );
//           this.showSpinner = false;
//           this.dispatchEvent(
//             new CustomEvent('close', {
//               detail: {
//                 showButton: false,
//               },
//             }),
//           );
//         })
//         .catch((err) => {
//           handleError(err, 'ipaOfferingDateUpdate - @updateOfferingDates');
//         });
//     }
//   }

//   /**
//    * on change of fields values
//    *
//    * @param {event} event change event
//    * @private
//    */
//   handleChange(event) {
//     const { name, value } = event.target;
//     // setting the value entered to the corresponding attribute
//     this[event.target.name] = event.target.value;
//     // setting the save button to disabled, if any field value is blank
//     if (!value) {
//       this.saveDisabled = true;
//     // to set the end date to 2 year from start date
//     } else if (name === 'startDate') {
//       // adding 2 year to the date and setting end date.
//       this.endDate = moment(value).add(2, 'year').format('YYYY-MM-DD');
//       this.minEndDate = moment(value).format('YYYY-MM-DD');
//       this.saveDisabled = false;
//       this.endDateDisabled = false;
//     }
//     this.checkValidity();
//   }

//   /**
//    * Close modal when cancel is clicked
//    *
//    * @private
//    */
//   handleCancel() {
//     this.template.querySelector('c-core-intc-modal').closeModal();
//   }

//   /**
//    * handle modal close, bubble event for offering detail
//    *
//    * @private
//    */
//   handleClose() {
//     this.dispatchEvent(
//       new CustomEvent('close', {
//         detail: {
//           showButton: true,
//         },
//       }),
//     );
//   }

//   /**
//    * method to check the form validity
//    *
//    * @returns {boolean} validity
//    * @private
//    */
//   checkValidity() {
//     let valid = true;

//     const endDateInput = this.template.querySelector(
//       'lightning-input[data-id=\'endDate\']',
//     );

//     // if start date is after end date
//     if (this.startDate && this.endDate && moment(this.startDate).isAfter(this.endDate)) {
//       endDateInput.setCustomValidity(this.label.endDateError);
//       endDateInput.reportValidity();
//       valid = false;
//     // if end date equal to start date
//     } else if (this.startDate && this.endDate && moment(this.startDate).isSame(this.endDate)) {
//       endDateInput.setCustomValidity(this.label.endDateEqualToStartDate);
//       endDateInput.reportValidity();
//       valid = false;
//     } else {
//       // resetting any previous errors on the fields to blank
//       const allInputs = [...this.template.querySelectorAll('lightning-input')];
//       allInputs.forEach((inp) => {
//         inp.setCustomValidity('');
//         if (!inp.reportValidity()) {
//           valid = false;
//           inp.focus();
//         }
//       });
//     }
//     this.saveDisabled = !valid;
//     return valid;
//   }

//   /**
//    * show toast
//    *
//    * @param {string} title toast title
//    * @param {string} message toast message
//    * @param {string} variant toast variant
//    * @private
//    */
//   showToast(title, message, variant) {
//     const event = new ShowToastEvent({
//       title,
//       message,
//       variant,
//     });
//     this.dispatchEvent(event);
//   }
// }
// export default IpaOfferingDateUpdate;