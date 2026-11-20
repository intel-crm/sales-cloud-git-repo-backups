// // NOTE PREVIEW MODE - show no banners implement?
// import DraftEditBannerMessage from '@salesforce/label/c.PMP_DraftEditBannerMessage';
// import RejectedEditBannerMessage from '@salesforce/label/c.PMP_RejectedEditBannerMessage';
// import RedoBannerMessageBannerMessage from '@salesforce/label/c.PMP_PublishedEditBannerMessage';
// import ApprovedFutureDateBannerMessage from '@salesforce/label/c.PMP_ApprovedFutureDateEditBannerMessage';
// import ScheduledToBePublishedBannerMessage from '@salesforce/label/c.PMP_ScheduledToBePublishedEditBannerMessage';
// import AdminReviewEditBannerMessage from '@salesforce/label/c.PMP_AdminReviewEditBannerMessage';
// import UpdateRequiredEditBannerMessage from '@salesforce/label/c.PMP_UpdateRequiredEditBannerMessage';
// import RetiredOfferingBannerNotification from '@salesforce/label/c.PMP_RetiredOfferingBannerNotification';

// /** extracts notification banner (code copied from MarketplaceProductDetailHelper in LWC upgrade)
//  *
//  * @param {object} offeringDetails offering details
//  * @param {string} startDate start date
//  * 
//  *
//  * @returns {object} notification banner
//  */
// export default function extractNotificationBanner(offeringDetails = {}, startDate) {
//   let today = new Date(); // Declaring todays date to check future date scenario
//   today = today.toISOString().slice(0, 10); // changing the date to required format

//   let details = {
//     type: '',
//     message: '',
//   };

//   let isPublished;
//   if (offeringDetails.PMP_Is_Not_Available_On_MP_Ind__c === false){
//     if (offeringDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Draft') {
//       details = {
//         type: 'redo',
//         message: DraftEditBannerMessage,
//       };
//     }else if (offeringDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Rejected') {
//       details = {
//         type: 'lock',
//         message: RejectedEditBannerMessage,
//       };
//     }else if (offeringDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Published') {
//       isPublished = true; // For Clone button visiblity
//       details = {
//         type: 'redo',
//         message: RedoBannerMessageBannerMessage,
//       };
//     }else if (offeringDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Approved') {
//       if (((startDate <= today) && offeringDetails.PMP_Pre_Release_Item_Count_Num__c === 0
//       && offeringDetails.PMP_Pre_Release_Check_Nm__c == null) || (offeringDetails.PMP_Pre_Release_Item_Count_Num__c === 0
//       && offeringDetails.PMP_Pre_Release_Check_Nm__c === 'Yes' && (startDate <= today)) || (offeringDetails.PMP_Pre_Release_Item_Count_Num__c === 0
//             && offeringDetails.PMP_Pre_Release_Check_Nm__c === 'No' && !offeringDetails.PMP_Is_Notified_Ind__c && (startDate <= today))) {
//         isPublished = true; // For Clone button visiblity
//         details = {
//           type: 'redo',
//           message: RedoBannerMessageBannerMessage,
//         };
//       }else if (offeringDetails.PMP_Pre_Release_Item_Count_Num__c === 0 && startDate > today && (offeringDetails.PMP_Pre_Release_Check_Nm__c !== 'No'
//       || (offeringDetails.PMP_Pre_Release_Check_Nm__c === 'No' && !offeringDetails.PMP_Is_Notified_Ind__c))) {
//         isPublished = true; // For Clone button visiblity
//         const futureDateLabel = ApprovedFutureDateBannerMessage.replace('{0}', startDate);
//         details = {
//           type: 'lock',
//           message: futureDateLabel,
//         };
//       }else { // Scheduled to be published banner message when offering is approved but not published
//         isPublished = true;
//         details = {
//           type: 'redo',
//           message: ScheduledToBePublishedBannerMessage,
//         };
//      }
//     } else if (offeringDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Admin Review') {
//       details = {
//         type: 'lock',
//         message: AdminReviewEditBannerMessage,
//       };
//     }else if (offeringDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Update Required') {
//       details = {
//         type: 'redo',
//         message: UpdateRequiredEditBannerMessage,
//       };
//     } else if(offeringDetails.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Retired') {
//       details = {
//         type: 'lock',
//         message: RetiredOfferingBannerNotification,
//       }
//     }
//   } else{
//     if (offeringDetails.PMP_Working_Copy_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Draft') {
//       details = {
//         type: 'redo',
//         message: DraftEditBannerMessage,
//       };
//     }else if (offeringDetails.PMP_Working_Copy_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Rejected') {
//       details = {
//         type: 'lock',
//         message: RejectedEditBannerMessage,
//       };
//     }else if (offeringDetails.PMP_Working_Copy_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Approved') {
//       if (((startDate <= today) && offeringDetails.PMP_Pre_Release_Item_Count_Num__c === 0
//       && offeringDetails.PMP_Pre_Release_Check_Nm__c == null) || (offeringDetails.PMP_Pre_Release_Item_Count_Num__c === 0
//       && offeringDetails.PMP_Pre_Release_Check_Nm__c === 'Yes' && (startDate <= today)) || (offeringDetails.PMP_Pre_Release_Item_Count_Num__c === 0
//             && offeringDetails.PMP_Pre_Release_Check_Nm__c === 'No' && !offeringDetails.PMP_Is_Notified_Ind__c && (startDate <= today))) {
//         isPublished = true; // For Clone button visiblity
//         details = {
//           type: 'redo',
//           message: RedoBannerMessageBannerMessage,
//         };
//       }else if (offeringDetails.PMP_Pre_Release_Item_Count_Num__c === 0 && startDate > today && (offeringDetails.PMP_Pre_Release_Check_Nm__c !== 'No'
//       || (offeringDetails.PMP_Pre_Release_Check_Nm__c === 'No' && !offeringDetails.PMP_Is_Notified_Ind__c))) {
//         isPublished = true; // For Clone button visiblity
//         const futureDateLabel = ApprovedFutureDateBannerMessage.replace('{0}', startDate);
//         details = {
//           type: 'lock',
//           message: futureDateLabel,
//         };
//       }else { // Scheduled to be published banner message when offering is approved but not published
//         isPublished = true;
//         details = {
//           type: 'redo',
//           message: ScheduledToBePublishedBannerMessage,
//         };
//      }
//     } else if (offeringDetails.PMP_Working_Copy_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Admin Review') {
//       details = {
//         type: 'lock',
//         message: AdminReviewEditBannerMessage,
//       };
//     }else if (offeringDetails.PMP_Working_Copy_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Update Required') {
//       details = {
//         type: 'redo',
//         message: UpdateRequiredEditBannerMessage,
//       };
//     } else if(offeringDetails.PMP_Working_Copy_Id__r. PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Retired') {
//       details = {
//         type: 'lock',
//         message: RetiredOfferingBannerNotification,
//       }
//     }
//   }  
  

//   return {
//     notificationBanner: notificationBannerMessages(details.type, details.message),
//     isPublished,
//   };
// }

// /** extracts notification banner (code copied from MarketplaceProductDetailHelper in LWC upgrade)
//  *
//  * @param {object} type banner type gives symbol on left hand side of banner message
//  * @param {object} message message on the banner
//  *
//  * @returns {object} notification banner
//  */
// function notificationBannerMessages(type, message) {
//   return {
//     type, // This will give the symbol on the left hand side of the banner message
//     openInBlank: false, // To open in a new window
//     message, // Message on the banner
//   };
// }
export default class notificationBanner extends LightningElement{}