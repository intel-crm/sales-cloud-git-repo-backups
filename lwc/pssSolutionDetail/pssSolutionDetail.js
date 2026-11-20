class PssSolutionDetails extends NavigationMixin(LightningElement){}
// import { LightningElement, track, wire } from 'lwc';
// import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { getAllLabels } from 'c/coreIntcLabels';

// // apex class
// import resultRecord from '@salesforce/apex/PSS_PartnerResponsePageCtrl.getPartnerResponses';
// import solutionToOffering from '@salesforce/apex/PSS_SolutionToOfferingRetrigger.convertSolutionToOffering';
// import accessToSolution from '@salesforce/apex/PSS_PartnerResponsePageCtrl.accessSolutionRecord';
// import getCustomLabels from '@salesforce/apex/PSS_CustomLabelsForLWC.customLabelsForSolDetailPage';


// // custom labels
// import messageHelpText from '@salesforce/label/c.PSS_MessageText';
// import messageHeading from '@salesforce/label/c.PSS_MessageBox_Heading';
// import draftStatusLabel from '@salesforce/label/c.PSS_Draft_SolutionDetail_BannerMessage';
// import updateLabel from '@salesforce/label/c.PSS_UpdateRequired_SolutionDetail_BannerMessage';
// import rejectedLabel from '@salesforce/label/c.PSS_Rejected_SolutionDetail_BannerMessage';
// import approvedLabel from '@salesforce/label/c.PSS_Approved_SolutionDetail_BannerMessage';
// import adminLabel from '@salesforce/label/c.PSS_AdminReview_SolutionDetail_BannerMessage';
// import cancelLabel from '@salesforce/label/c.PSS_Cancel_SolutionDetail_BannerMessage';
// import onholdLabel from '@salesforce/label/c.PSS_OnHold_SolutionDetail_BannerMessage';
// import reviewLabel from '@salesforce/label/c.PSS_ReviewScheduled_SolutionDetail_BannerMessage';
// import submitterDetailsLabel from '@salesforce/label/c.PSS_Submitter_Details';
// import solutionDetailsLabel from '@salesforce/label/c.PSS_Solution_Details';
// import solutionUrlLabel from '@salesforce/label/c.PSS_Solution_URL';
// import messageLabel from '@salesforce/label/c.PSS_Message_About_Your_Solution';
// import editSolutionLabel from '@salesforce/label/c.PSS_Edit_Solution';
// import addContactsLabel from '@salesforce/label/c.PSS_Add_Contacts';
// import draftOffering from '@salesforce/label/c.PSS_Create_Draft_Offering';
// import recreateButtonLabel from '@salesforce/label/c.PSS_ReCreate_Offering_Button';
// import warningLabel from '@salesforce/label/c.PMP_Create_Offering_Form_Warning_Heading';
// import partnerValidationLabel from '@salesforce/label/c.PSS_Conversion_MPI_Record_Validation_Error';
// import successLabel from '@salesforce/label/c.PMP_Success';
// import offeringCreationSuccessLabel from '@salesforce/label/c.PSS_Offering_Creation_Success';
// import benefitValidationTitleLabel from '@salesforce/label/c.PSS_Select_Benefit_Validation_Toast_Title';
// import benefitValidationMessageLabel from '@salesforce/label/c.PSS_Select_Benefit_Validation_Toast_Message';
// import { handleError } from 'c/ipaErrorServiceMarketplace';
// import helpText from '@salesforce/label/c.PSS_AddContacts_HelpText';
// import retiredSolutionLabel from '@salesforce/label/c.PSS_Retired_SolutionDetail_BannerMessage';
// import aiipSolutionWarningLabel from '@salesforce/label/c.PSS_AIIP_Solution_Conversion_Warning';
// import aiipSolutionConversionErrorLabel from '@salesforce/label/c.PSS_AIIP_Solution_Conversion_Error_Message';
// import errorLabel from '@salesforce/label/c.PMP_Error';
// import aiipLabel from '@salesforce/label/c.PSS_AIIP_Value';

// /** The Solution Detail component is used in solution detail page.
//  * The component consists of button,fields which is to be displayed in the solution detail page.
//  *
//  *  @example
//  * <!-- HTML component -->
//  * <c-pss-solution-details></c-pss-solution-details>
//  *
//  * @augments NavigationMixin
//  * @augments LightningElement
//  *
//  *
//  */
// class PssSolutionDetails extends NavigationMixin(LightningElement) {
//   /** Custom Labels:
//    * "draftStatusLabel"-PSS_Draft_SolutionDetail_BannerMessage
//    * "updateLabel"-PSS_UpdateRequired_SolutionDetail_BannerMessage
//    * "rejectedLabel"-PSS_Rejected_SolutionDetail_BannerMessage
//    * "approvedLabel"-PSS_Approved_SolutionDetail_BannerMessage
//    * "adminLabel"-PSS_AdminReview_SolutionDetail_BannerMessage
//    * "cancelLabel"-PSS_Cancel_SolutionDetail_BannerMessage
//    * "onholdLabel"-PSS_OnHold_SolutionDetail_BannerMessage
//    * "reviewLabel"-PSS_ReviewScheduled_SolutionDetail_BannerMessage
//    * "submitterDetailsLabel"-PSS_Submitter_Details
//    * "solutionDetailsLabel"-PSS_Solution_Details
//    * "solutionUrlLabel"-PSS_Solution_URL
//    * "messageLabel"-PSS_Message_About_Your_Solution
//    * "editSolutionLabel"-PSS_Edit_Solution
//    * "addContactsLabel"-PSS_Add_Contacts
//    * "draftOffering"-PSS_Create_Draft_Offering
//    * "recreateButtonLabel"-PSS_ReCreate_Offering_Button
//    * "warningLabel"-PMP_Create_Offering_Form_Warning_Heading
//    * "partnerValidationLabel"-PSS_Conversion_MPI_Record_Validation_Error
//    * "successLabel"-PMP_Success
//    * "offeringCreationSuccessLabel"-PSS_Offering_Creation_Success
//    * "benefitValidationTitleLabel"-PSS_Select_Benefit_Validation_Toast_Title
//    * "benefitValidationMessageLabel"-PSS_Select_Benefit_Validation_Toast_Message
//    *
//    * @type {object}
//    * @private
//    */
//   labels = {
//     messageHeading,
//     messageHelpText,
//     draftStatusLabel,
//     updateLabel,
//     rejectedLabel,
//     approvedLabel,
//     adminLabel,
//     cancelLabel,
//     onholdLabel,
//     reviewLabel,
//     submitterDetailsLabel,
//     solutionDetailsLabel,
//     solutionUrlLabel,
//     messageLabel,
//     editSolutionLabel,
//     addContactsLabel,
//     draftOffering,
//     recreateButtonLabel,
//     warningLabel,
//     partnerValidationLabel,
//     successLabel,
//     offeringCreationSuccessLabel,
//     benefitValidationTitleLabel,
//     benefitValidationMessageLabel,
//     helpText,
//     retiredSolutionLabel,
//     aiipSolutionWarningLabel,
//     aiipSolutionConversionErrorLabel,
//     errorLabel,
//     aiipLabel,
//   };

//   /** to pass the response to child component
//    *
//    * @type {object}
//    * @private
//    */
//   @track resultRecordDetails;

//   /** to pass the response to child component the question and answer.
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track questionAnsList;

//   /** to pass the response to child component the intelproducts.
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track intelProductList;

//   /**
//    * Constant Variables used in the component
//    *
//    * @type {object}
//    * @private
//    */
//   CONSTANT = {
//     REJECTED_STATUS: 'Rejected',
//     UPDATE_STATUS: 'Update Required',
//     PROGRESS_STATUS: 'Draft',
//     APPROVED_STATUS: 'Approved',
//     ADMIN_STATUS: 'Admin Review',
//     HOLD_STATUS: 'On Hold',
//     CANCEL_STATUS: 'Cancelled',
//     SCHEDULED_STATUS: 'Review Scheduled',
//     LOCK_ICON: 'lock',
//     REVIEW_ICON: 'review',
//     PUBLISHED_ICON: 'published',
//     UPDATE_ICON: 'update',
//     DRAFT_OFFERING: 'Converted To MP Offerings',
//     RETIRED_STATUS: 'Retired',
//   };

//   /** internal boolean variable to set to shows up add contact screen
//    *
//    * @type {boolean}
//    * @private
//    *
//    */
//   addContact;

//   /** internal variable to get the current page reference
//    *
//    * @type {object}
//    * @private
//    */
//   currentPageReference = null;

//   /** variable that is used to get the URL parameters.
//    *
//    * @type {object}
//    * @private
//    */
//   urlStateParameters = null;

//   /** internal variable to show the edit button on solution detail page.
//    *
//    *
//    * @type {boolean}
//    * @private
//    */
//   showEditable;

//   /** internal variable to show the re-create offering button on solution detail page.
//    *
//    *
//    * @type {boolean}
//    * @private
//    */
//   showRecreate;

//   /** variable that is used to set the id and send that to apex class.
//    *
//    *
//    * @type {string}
//    * @private
//    */
//   recordId;

//   /** internal variable that is used to check whether the solution detail page is navigated from the
//    * messaging component.
//    *
//    * @type {boolean}
//    * @private
//    */
//   viewchat = false;

//   /** internal variable that holds solution to offering method return data.
//    *
//    * @type {object}
//    * @private
//    */
//   resultWrapper;

//   /** internal variable to control the spinner visibility.
//    *
//    * @type {boolean}
//    * @private
//    */
//   isLoading = false;

//   /** variable to show the Add Contact button.
//    * button is visible when the variable is true else button is invisible.
//    *
//    * @type {boolean}
//    * @private
//    */
//   showAddContact;

//   /** variable to show the solution record when the access is present
//    *
//    * @type {boolean}
//    * @private
//    */
//   accessSolution;

//   //Added as part of TWC729-5748 - Ardira Package Update Issue Fix
//   /** variable to store the solution logicalId
//    *
//    * @type {string}
//    * @private
//    */
//   logicalId;

//   /** variable to show the default tab
//    *
//    * @type {number}
//    * @private
//    */
//   initialActiveTab = 0;

//   /**
//    *Checks whether the logged user as access to the record
//    * by Passing the recordId and on load of the component
//    * gets the response for the component based on solution id
//    * This response includes intelproducts,solution questions which is been answered
//    *
//    * @private
//    *
//    */
//   connectedCallback() {
//     this.init();
//     this.initialActiveTab = 0;
//     if (window.location.href.match('#tab-1')) {
//       this.initialActiveTab = 1;
//     }
//   }

//   /**
//    * Async function that handles getting the labels and calling functions that are dependant on label values.
//    *
//    * @private
//    */
//   async init() {
//     await this.updateLabels();
//     accessToSolution({ recordId: this.recordId })
//       .then((result) => {
//         this.accessSolution = result;
//         if (this.accessSolution === true) {
//           resultRecord({ recordId: this.recordId })
//             .then((solutionResult) => {
//               this.resultRecordDetails = solutionResult;
//               document.title = solutionResult.resultRecordName;
//               this.questionAnsList = this.resultRecordDetails.questionAnsList;
//               this.intelProductList = this.resultRecordDetails.intelProductQuesAndAnsList;
//               this.showEditable = this.resultRecordDetails.showEditable;
//               this.bannerDetails(this.resultRecordDetails.resultRecord.PSS_Partner_Solution_Lifecycle_Status_Nm__c);
//               this.showRecreate = (this.resultRecordDetails.isAdmin
//                 && this.resultRecordDetails.resultRecord.PSS_Partner_Solution_Lifecycle_Status_Nm__c === this.CONSTANT.APPROVED_STATUS);
//               this.showAddContact = this.resultRecordDetails.showAddContact;
//               //Added as part of TWC729-5748 - Ardira Package Update Issue Fix
//               this.logicalId = this.resultRecordDetails.logicalId;
//             })
//             .catch((error) => {
//               handleError(error, 'pssSolutionDetail - resultRecord');
//             });
//         } else if (this.accessSolution === false) {
//           this[NavigationMixin.Navigate]({
//             type: 'comm__namedPage',
//             attributes: { pageName: 'error' },
//           });
//         }
//       });
//   }

//   /**
//    * Calls the imported method to update the label values.
//    *
//    * @private
//    */
//   async updateLabels() {
//     try {
//       // This call uses the default validation logic
//       this.labels = await getAllLabels(this.labels, getCustomLabels);
//     } catch (error) {
//       handleError(error, 'pssSolutionDetail - updateLabels');
//     }
//   }


//   /** handles the banner details based on the solution status
//    * helps to configure the banner icon based on solution status
//    *
//    * @param {string} status status of the solution record
//    * @private
//    */
//   bannerDetails(status) {
//     switch (status) {
//       case this.CONSTANT.CANCEL_STATUS:
//         this.message = this.labels.cancelLabel;
//         this.iconType = this.CONSTANT.LOCK_ICON;
//         break;
//       case this.CONSTANT.REJECTED_STATUS:
//         this.message = this.labels.rejectedLabel;
//         this.iconType = this.CONSTANT.LOCK_ICON;
//         break;
//       case this.CONSTANT.UPDATE_STATUS:
//         this.message = this.labels.updateLabel;
//         this.iconType = this.CONSTANT.UPDATE_ICON;
//         break;
//       case this.CONSTANT.PROGRESS_STATUS:
//         this.message = this.labels.draftStatusLabel;
//         this.iconType = '';
//         break;
//       case this.CONSTANT.APPROVED_STATUS:
//         this.message = this.labels.approvedLabel;
//         this.iconType = this.CONSTANT.PUBLISHED_ICON;
//         break;
//       case this.CONSTANT.ADMIN_STATUS:
//         this.message = this.labels.adminLabel;
//         this.iconType = this.CONSTANT.LOCK_ICON;
//         break;
//       case this.CONSTANT.HOLD_STATUS:
//         this.message = this.labels.onholdLabel;
//         this.iconType = this.CONSTANT.LOCK_ICON;
//         break;
//       case this.CONSTANT.SCHEDULED_STATUS:
//         this.message = this.labels.reviewLabel;
//         this.iconType = this.CONSTANT.LOCK_ICON;
//         break;
//       case this.CONSTANT.DRAFT_OFFERING:
//         this.message = this.labels.draftOffering;
//         this.iconType = this.CONSTANT.PUBLISHED_ICON;
//         break;
//       case this.CONSTANT.RETIRED_STATUS:
//         this.message = this.labels.retiredSolutionLabel;
//         this.iconType = this.CONSTANT.LOCK_ICON;
//         break;
//       default:
//         break;
//     }
//   }


//   /**
//    * to get the current page parameter from the URL
//    *
//    * @param {object} currentPageReference current reference of the page
//    * @private
//    */
//   @wire(CurrentPageReference)
//   getStateParameters(currentPageReference) {
//     if (currentPageReference) {
//       this.urlStateParameters = currentPageReference.state;
//       this.recordId = this.urlStateParameters.recordId;
//       this.viewchat = this.urlStateParameters.viewchat;
//       if (this.viewchat === true) {
//         this.viewchat = true;
//       }
//     }
//   }

//   /**
//    * Navigate to edit mode to the corresponding record page
//    *
//    * @private
//    */
//   navigateToEditMode() {
//     const baseUrl = `${window.location.origin}${solutionUrlLabel}create-edit-solution?`;
//     //Added as part of TWC729-5748 - Ardira Package Update Issue Fix
//     if(this.logicalId != null){
//       window.open(`${baseUrl}recordId=${this.recordId}&logicalId=${this.logicalId}`, '_self');
//     }else{
//       window.open(`${baseUrl}recordId=${this.recordId}`, '_self');
//     }
//   }

//   /**
//    *Shows up the add Contact screen when add contact button is clicked.
//    *
//    * @private
//    */
//   navigateToAddContact() {
//     this.addContact = true;
//   }

//   /**
//    *To convert solution to offering by clicking recreate offering button.
//    *
//    * @private
//    */
//   createOfferingFromSolution() {
//     let conversionFlag = true;
//     let aiipWarning = false;
//     /* Handling AIIP Conversion */
//     const arr = this.resultRecordDetails.resultRecord.PSS_Programs_Applicable_Nm__c.split(';');
//     /* To show warning during conversion */
//     if (this.resultRecordDetails.resultRecord.PSS_Programs_Applicable_Nm__c.includes(this.labels.aiipLabel)) {
//       aiipWarning = true;
//     }
//     if (arr.length === 1 && arr[0] === this.labels.aiipLabel) {
//       conversionFlag = false;
//     }
//     if (!conversionFlag) {
//       this.toastValidationMessage(this.labels.errorLabel, this.labels.aiipSolutionConversionErrorLabel, 'error', 'dismissible');
//     }
//     if (conversionFlag) {
//       this.isLoading = true;
//       solutionToOffering({ solutionId: this.recordId })
//         .then((result) => {
//           this.resultWrapper = result;
//           if (this.resultWrapper.partnerValidation) {
//             this.toastValidationMessage(this.labels.warningLabel, this.labels.partnerValidationLabel, 'warning', 'dismissible');
//           }
//           if (this.resultWrapper.selectBenefit) {
//             this.toastValidationMessage(this.labels.benefitValidationTitleLabel, this.labels.benefitValidationMessageLabel, 'warning', 'dismissible');
//           }
//           if (this.resultWrapper.offeringCreated) {
//             this.toastValidationMessage(this.labels.successLabel, this.labels.offeringCreationSuccessLabel, 'success');
//             this.showRecreate = false;
//             if (aiipWarning) {
//               this.toastValidationMessage(this.labels.warningLabel, this.labels.aiipSolutionWarningLabel, 'warning', 'dismissible');
//             }
//           }
//           this.resultRecordDetails = this.resultWrapper.resultDetails ? this.resultWrapper.resultDetails : this.resultRecordDetails;
//           if (this.resultRecordDetails.resultRecord.PSS_Partner_Solution_Lifecycle_Status_Nm__c === this.CONSTANT.DRAFT_OFFERING) {
//             this.bannerDetails(this.resultRecordDetails.resultRecord.PSS_Partner_Solution_Lifecycle_Status_Nm__c);
//           }
//         })
//         .catch((error) => {
//           handleError(error, 'pssSolutionDetail - solutionToOffering');
//         })
//         .finally(() => {
//           this.isLoading = false;
//         });
//     }
//   }

//   /**
//    *Shows up the toast message when the validation is failed.
//    *
//    * @param {string}  toastTitle toast event title.
//    * @param {string}  toastMessage toast event message.
//    * @param {string}  toastVariant toast event variant.
//    * @param {string}  toastMode toast event mode.
//    * @private
//    */
//   toastValidationMessage(toastTitle, toastMessage, toastVariant, toastMode) {
//     const evt = new ShowToastEvent({
//       title: toastTitle,
//       message: toastMessage,
//       variant: toastVariant,
//       mode: toastMode || '',
//     });
//     this.dispatchEvent(evt);
//   }

//   /**
//    * Closes the modal popup of addcontacts
//    *
//    * @private
//    */
//   closeModal() {
//     this.addContact = false;
//   }
// }
// export default PssSolutionDetails;