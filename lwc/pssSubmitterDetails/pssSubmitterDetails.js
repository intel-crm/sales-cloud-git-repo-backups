class PssSubmitterDetails extends NavigationMixin(LightningElement){}
// /* eslint-disable max-len */
// import { LightningElement, api, track } from 'lwc';
// import { NavigationMixin } from 'lightning/navigation';

// // custom labels
// import submittedByLabel from '@salesforce/label/c.PSS_Submitted_By';
// import submittedOnLabel from '@salesforce/label/c.PSS_Submitted_On';
// import statusLabel from '@salesforce/label/c.PSS_Status';
// import cancelLabel from '@salesforce/label/c.PSS_Cancel_Reason';
// import scoreLabel from '@salesforce/label/c.PSS_Consolidated_Score';
// import programsLabel from '@salesforce/label/c.PSS_Programs_Applicable';
// import systemBenefitLabel from '@salesforce/label/c.PSS_System_Suggested_Benefit_Level';
// import adminBenefitLabel from '@salesforce/label/c.PSS_Admin_Suggested_Benefit_Level';
// import followUpLabel from '@salesforce/label/c.PSS_Follow_Up_Date';
// import reviewLabel from '@salesforce/label/c.PSS_Review_Scheduled_Date';
// import onholdLabel from '@salesforce/label/c.PSS_On_Hold_Time';
// import updateTimeLabel from '@salesforce/label/c.PSS_Update_Required_Time';
// import daysLabel from '@salesforce/label/c.PSS_Days';
// import hoursLabel from '@salesforce/label/c.PSS_Hours';
// import minsLabel from '@salesforce/label/c.PSS_Mins';
// import viewOfferingLabel from '@salesforce/label/c.PMP_View_Offering';
// import conversionLogLabel from '@salesforce/label/c.PSS_Conversion_Admin_Log_Details';
// import solutionSharedWith from '@salesforce/label/c.PSS_Solution_Shared_With';
// import viewSharedContactsLabel from '@salesforce/label/c.PSS_View_Shared_Contacts';
// import submitterEmail from '@salesforce/label/c.PSS_Solution_SubmitterEmail';
// import partnerName from '@salesforce/label/c.PSS_Solution_PartnerName';
// import englishPartnerName from '@salesforce/label/c.PSS_Solution_EnglishPartnerName';
// import forecastRevenue from '@salesforce/label/c.PSS_Forecast_Revenue';
// import partnerRole from '@salesforce/label/c.PSS_Partner_Role';
// import accountName from '@salesforce/label/c.PSS_Account_Name';
// import country from '@salesforce/label/c.PSS_Country';
// import region from '@salesforce/label/c.PSS_Region';
// import approvedDate from '@salesforce/label/c.PSS_Approved_Date';
// import viewActivationCallDetails from '@salesforce/label/c.PSS_View_Activation_Call_Details';
// import activationDetails from '@salesforce/label/c.PSS_Solution_Activation_Call';


// /** The Submitter Detail is the component used to display the admin/partner details.
//  *
//  * @example
//  * <!-- HTML component -->
//  * <c-pss-submitter-details result-record-details={resultRecordDetails}></c-pss-submitter-details>
//  *
//  *@augments LightningElement
//  *@property {object[]} resultRecordDetails internal list to get the solution record.
//  *
//  */
// class PssSubmitterDetails extends NavigationMixin(LightningElement) {
//   /** custom labels:
//    * "submittedByLabel"-PSS_Submitted_By
//    * "submittedOnLabel"-PSS_Submitted_On
//    * "statusLabel"-PSS_Status
//    * "cancelLabel"-PSS_Cancel_Reason
//    * "scoreLabel"-PSS_Consolidated_Score
//    * "programsLabel"-PSS_Programs_Applicable
//    * "systemBenefitLabel"-PSS_System_Suggested_Benefit_Level
//    * "adminBenefitLabel"-PSS_Admin_Suggested_Benefit_Level
//    * "followUpLabel"-PSS_Follow_Up_Date
//    * "reviewLabel"-PSS_Review_Scheduled_Date
//    * "onholdLabel"-PSS_On_Hold_Time
//    * "updateTimeLabel"-PSS_Update_Required_Time
//    * "daysLabel"-PSS_Days
//    * "hoursLabel"-PSS_Hours
//    * "minsLabel"-PSS_Mins
//    * "viewOfferingLabel"-PMP_View_Offering
//    * "conversionLogLabel"-PSS_Conversion_Admin_Log_Details
//    * "viewActivationCallDetails"-PSS_View_Activation_Call_Details
//    * "activationDetails"-PSS_Solution_Activation_Call
//    *
//    * @type {object}
//    * @private
//    */
//   labels = {
//     submittedByLabel,
//     submittedOnLabel,
//     statusLabel,
//     cancelLabel,
//     scoreLabel,
//     programsLabel,
//     systemBenefitLabel,
//     adminBenefitLabel,
//     followUpLabel,
//     reviewLabel,
//     onholdLabel,
//     updateTimeLabel,
//     daysLabel,
//     hoursLabel,
//     minsLabel,
//     viewOfferingLabel,
//     conversionLogLabel,
//     solutionSharedWith,
//     viewSharedContactsLabel,
//     submitterEmail,
//     partnerName,
//     englishPartnerName,
//     forecastRevenue,
//     partnerRole,
//     accountName,
//     country,
//     region,
//     approvedDate,
//     viewActivationCallDetails,
//     activationDetails,
//   };

//   /** variable that holds key-value pair that is displayed in the UI.
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track objects = [];

//   /** variable that holds boolean value whether user clicked on View Shared Contacts link.
//    *
//    * @type {boolean}
//    * @private
//    */
//   viewSharedContacts = false;


//   /** internal variable that holds solution record details.
//    *
//    * @type {object[]}
//    * @private
//    */
//   resultRecord;

//   /** variable to store the partnerName
//    *
//    * @type {string}
//    * @private
//    */
//   partnerName;

//   /** variable to store the partnerName in English
//    *
//    * @type {string}
//    * @private
//    */
//    partnerNameEnglishOnly;

//   /** variable to store the partnerRole
//    *
//    * @type {string}
//    * @private
//    */
//   partnerRole;

//   /** variable to store the company Id
//    *
//    * @type {string}
//    * @private
//    */
//   partnerValue;

//   /** variable to store the attribute value to true if partner Name is CompanyId else false
//    *
//    * @type {boolean}
//    * @private
//    */
//   isPartnerName;

//   /** variable to store the benefit type of the company record.
//    *
//    * @type {string}
//    * @private
//    */
//   companyBenefitType;

//   /** variable to store the value if true activation call details will be url
//    *
//    * @type {boolean}
//    * @private
//    */
//   isActivationDetails = false;

//   /**
//    * internal array of the question and answer for the solution record.
//    *
//    * @returns {object[]}  The internal array of solution in the version format expected by the component.
//    * @private
//    */
//   @api
//   get resultRecordDetails() {
//     return this._resultRecordDetails;
//   }

//   /**
//    * Stores the solution record array which is passed by the user and sets the value of the
//    * array which is defined internally.
//    * calls the private method and passes the parameter as the solution record.
//    *
//    *  @param {object[]} value The solution result record passed as parameter.
//    *  @private
//    */
//   set resultRecordDetails(value) {
//     this.setAttribute('resultRecordDetails', value);
//     this._resultRecordDetails = value;
//     this.recordDetails(this.resultRecordDetails);
//   }

//   /**
//    *Sets the viewSharedContacts value to true if clicked on link.
//    *
//    * @private
//    */
//   openPopUp() {
//     this.viewSharedContacts = true;
//   }

//   /** sets the isActivationDetails value to true if click on link.
//    *
//    * @private
//    */
//   openActivationPopUp() {
//     this.isActivationDetails = true;
//   }

//   /** sets the isActivationDetails value to false if click on cancel/close button.
//    *
//    * @private
//    */
//   closeActivationPopUp() {
//     this.isActivationDetails = false;
//   }

//   /**
//    *Sets the viewSharedContacts value to true if clicked on link.
//    *
//    * @param {object} evt The solution result record passed as parameter.
//    * @private
//    */
//   handleKeyDown(evt) {
//     const enterKey = 13;
//     const spaceKey = 32;
//     if (evt.keyCode === enterKey || evt.keyCode === spaceKey) {
//       evt.preventDefault();
//       this.openPopUp();
//     }
//   }

//   /**
//    *Method to navigate to partner page when clicks on enterkey or spacekey
//    *
//    * @param {object} event The solution result record passed as parameter.
//    * @private
//    */
//   handleKeyDownOnPartner(event) {
//     const enterKey = 13;
//     const spaceKey = 32;
//     if (event.keyCode === enterKey || event.keyCode === spaceKey) {
//       event.preventDefault();
//       this.navigateToPartnerPage();
//     }
//   }

//   /**
//    *Sets the viewSharedContacts value to false if clicked on close model.
//    *
//    * @private
//    */
//   closeModal() {
//     this.viewSharedContacts = false;
//   }

//   /**
//    *Sets the variable value for each field which is to be displayed to the admin/partner.
//    *
//    * @param {object[]} resultRecordDetails array that holds the solution record.
//    * @private
//    */
//   recordDetails(resultRecordDetails) {
//     if (resultRecordDetails != null) {
//       let billingCountryCode = '';
//       let coreGeo = '';
//       this.objects = [];
//       this.resultRecord = resultRecordDetails.resultRecord;
//       this.partnerRole = resultRecordDetails.partnerRole;
//       this.partnerName = this.resultRecord.PSS_Company_Id__c;
//       this.partnerNameEnglishOnly = this.resultRecordDetails.partnerName;

//       if (!this.partnerName) {
//         this.partnerValue = this.resultRecord.PSS_Partner_Name_FR__c;
//         this.isPartnerName = false;
//       } else {
//         this.companyBenefitType = this.resultRecord.PSS_Company_Id__r.PMP_Partner_Benefit_Type__c;
//         this.partnerValue = this.resultRecord.PSS_Partner_Name_FR__c;
//         if (this.companyBenefitType === 'Solution Marketplace Basic Access') {
//           this.isPartnerName = false;
//         } else {
//           this.isPartnerName = true;
//         }
//       }

//       if (this.resultRecord.PSS_Partner_Account_Id__c !== null && this.resultRecord.PSS_Partner_Account_Id__c !== undefined) {
//         billingCountryCode = this.resultRecord.PSS_Partner_Account_Id__r.BillingCountryCode;
//         coreGeo = this.resultRecord.PSS_Partner_Account_Id__r.Core_Geo__c;
//       }

//       let totalOnHoldMinutes = this.resultRecord.PSS_Elapsed_Time_For_On_Hold_Nm__c + this.resultRecord.PSS_Total_Minutes_On_Hold__c;
//       let totalUpdateRequiredMinutes = this.resultRecord.PSS_Elapsed_Time_For_Update_Required_Nm__c + this.resultRecord.PSS_Total_Minutes_Update_Required__c;
//       if (totalOnHoldMinutes) {
//         const totalOnHoldDays = Math.floor(totalOnHoldMinutes / 1440) < 10 ? `0${Math.floor(totalOnHoldMinutes / 1440)}` : Math.floor(totalOnHoldMinutes / 1440);
//         const totalOnHoldHours = Math.floor((totalOnHoldMinutes - totalOnHoldDays * 1440) / 60) < 10 ? `0${Math.floor((totalOnHoldMinutes - totalOnHoldDays * 1440) / 60)}` : Math.floor((totalOnHoldMinutes - totalOnHoldDays * 1440) / 60);
//         totalOnHoldMinutes = Math.floor(totalOnHoldMinutes % 60) < 10 ? `0${Math.floor(totalOnHoldMinutes % 60)}` : Math.floor(totalOnHoldMinutes % 60);
//         this.holdTime = (totalOnHoldDays > 0) ? `${totalOnHoldDays} ${this.labels.daysLabel} ${totalOnHoldHours} ${this.labels.hoursLabel} ${totalOnHoldMinutes} ${this.labels.minsLabel}` : `${totalOnHoldHours} ${this.labels.hoursLabel} ${totalOnHoldMinutes} ${this.labels.minsLabel}`;
//       }
//       if (totalUpdateRequiredMinutes) {
//         const totalUpdateRequiredDays = Math.floor(totalUpdateRequiredMinutes / 1440) < 10 ? `0${Math.floor(totalUpdateRequiredMinutes / 1440)}` : Math.floor(totalUpdateRequiredMinutes / 1440);
//         const totalUpdateRequiredHours = Math.floor((totalUpdateRequiredMinutes - totalUpdateRequiredDays * 1440) / 60) < 10 ? `0${Math.floor((totalUpdateRequiredMinutes - totalUpdateRequiredDays * 1440) / 60)}` : Math.floor((totalUpdateRequiredMinutes - totalUpdateRequiredDays * 1440) / 60);
//         totalUpdateRequiredMinutes = Math.floor(totalUpdateRequiredMinutes % 60) < 10 ? `0${Math.floor(totalUpdateRequiredMinutes % 60)}` : Math.floor(totalUpdateRequiredMinutes % 60);
//         this.updateRequiredTime = (totalUpdateRequiredDays > 0) ? `${totalUpdateRequiredDays}  ${this.labels.daysLabel}  ${totalUpdateRequiredHours} ${this.labels.hoursLabel} ${totalUpdateRequiredMinutes} ${this.labels.minsLabel}` : `${totalUpdateRequiredHours} ${this.labels.hoursLabel} ${totalUpdateRequiredMinutes} ${this.labels.minsLabel}`;
//       }

//       if (resultRecordDetails.isAdmin === true) {
//         this.objects.push({ value: this.partnerValue, key: this.labels.partnerName, isPartnerExists: this.isPartnerName });
//         if (this.partnerNameEnglishOnly) {
//           this.objects.push({ value: this.partnerNameEnglishOnly, key: this.labels.englishPartnerName });
//         }
//       }

//       this.objects.push({ value: this.resultRecordDetails.submitterName, key: this.labels.submittedByLabel });

//       if (resultRecordDetails.isAdmin === true) {
//         this.objects.push({ value: this.resultRecordDetails.submitterEmail, key: this.labels.submitterEmail });
//       }
//       this.objects.push({ value: this.resultRecord.PSS_Submitted_On_Dt__c, key: this.labels.submittedOnLabel });
//       this.objects.push({ value: this.resultRecord.PSS_View_Program_Applicable_Txt__c, key: this.labels.programsLabel, isFormattedText: true });
//       this.objects.push({ value: this.resultRecord.PSS_Partner_Solution_Lifecycle_Status_Nm__c, key: this.labels.statusLabel });
//       if (this.resultRecord.PSS_Partner_Solution_Lifecycle_Status_Nm__c === 'Cancelled') {
//         this.objects.push({ value: this.resultRecord.PSS_Cancel_Reason_Txt__c, key: this.labels.cancelLabel });
//       }

//       if (resultRecordDetails.isAdmin === true) {
//         this.objects.push({ value: this.partnerRole, key: this.labels.partnerRole });
//         this.objects.push({ value: billingCountryCode, key: this.labels.country });
//         this.objects.push({ value: coreGeo, key: this.labels.region });
//       }

//       if (resultRecordDetails.isAdmin === true || resultRecordDetails.isEmployee === true) {
//         this.objects.push({ value: this.resultRecord.PSS_Impact_Path_Score__c, key: this.labels.scoreLabel });
//         const systemBenefit = (this.resultRecord.PSS_System_Suggested_Benefit_Level__r != null ? this.resultRecord.PSS_System_Suggested_Benefit_Level__r.Name : '');
//         this.objects.push({ value: systemBenefit, key: this.labels.systemBenefitLabel, isFormattedText: true });
//         const adminBenefit = (this.resultRecord.PSS_Admin_Suggested_Benefit_Level__r != null ? this.resultRecord.PSS_Admin_Suggested_Benefit_Level__r.Name : '');
//         this.objects.push({ value: adminBenefit, key: this.labels.adminBenefitLabel, isFormattedText: true });
//       }

//       if (resultRecordDetails.isAdmin === true) {
//         this.objects.push({ value: this.resultRecord.PSS_Solution_Revenue_Projection__c, key: this.labels.forecastRevenue });
//       }
//       this.objects.push({ value: this.labels.viewSharedContactsLabel, key: this.labels.solutionSharedWith, isSolutionShared: true });
//       this.objects.push({ value: this.resultRecord.PSS_View_Offering_Txt__c, key: this.labels.viewOfferingLabel, isFormattedText: true });

//       if (resultRecordDetails.isAdmin === true) {
//         this.objects.push({ value: this.resultRecord.PSS_Approval_Date_dt__c, key: this.labels.approvedDate });
//       }

//       if (resultRecordDetails.isAdmin === true || resultRecordDetails.isEmployee === true) {
//         this.objects.push({ value: this.resultRecord.PSS_Follow_up_Date_Dt__c, key: this.labels.followUpLabel });
//         this.objects.push({ value: this.resultRecord.PSS_Review_Scheduled_Date_dt__c, key: this.labels.reviewLabel });
//         this.objects.push({ value: this.holdTime, key: this.labels.onholdLabel });
//         this.objects.push({ value: this.updateRequiredTime, key: this.labels.updateTimeLabel });
//         const adminLogMessage = this.resultRecord.PSS_Conversion_Admin_Log_Details_Txt__c ? this.resultRecord.PSS_Conversion_Admin_Log_Details_Txt__c : '';
//         this.objects.push({ value: adminLogMessage, key: this.labels.conversionLogLabel, isLogDetailsText: true });
//         this.objects.push({ value: this.labels.viewActivationCallDetails, key: this.labels.activationDetails, activationCall: true });
//       }
//     }
//   }

//   /**
//    * method to navigate tp partner page when user clicks on Partner Name
//    *
//    * @private
//    */
//   navigateToPartnerPage() {
//     this[NavigationMixin.Navigate]({
//       type: 'standard__recordPage',
//       attributes: {
//         recordId: this.partnerName,
//         objectApiName: 'PMP_Company__c',
//         actionName: 'view',
//       },
//     });
//   }
// }
// export default PssSubmitterDetails;