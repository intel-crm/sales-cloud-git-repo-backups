/* eslint-disable camelcase */
// import getOfferingDetail from '@salesforce/apex/PMP_OfferingDetailsController.getOfferingDetailProductDetails';
// import getMarqueeProductInformation from '@salesforce/apex/PMP_SearchMarqueeDetailController.getProductInformation';
// import industriesLabel from '@salesforce/label/c.Core_PMP_Industries';
// import availabilitypricingLabel from '@salesforce/label/c.PMP_Availability_and_Pricing';
// import applicationsLabel from '@salesforce/label/c.PMP_Applications';
// import regionLabel from '@salesforce/label/c.Core_Regions';

// import langLocale from '@salesforce/i18n/lang'; //en-US where $A.get("$Locale.langLocale"); returns en_US

// import CoreResource from '@salesforce/resourceUrl/Core_INTC';

// import PMP_Image from '@salesforce/label/c.PMP_Image';
// import PMP_Thumbnail_Image from '@salesforce/label/c.PMP_Thumbnail_Image';
// import PMP_Category from '@salesforce/label/c.PMP_Category';

// import notificationBannerExtractor from './_notificationBanner';
// import galleryImageExtractor from './_galleryImages';
// import categoriesExtractor from './_categories';
// import specificationsExtractor from './_specifications';
// import qualityMetricsExtractor from './_qualityMetrics';
// import partnerAttributesExtractor from './_partnerAttributes';

// // Placeholder Images
// const placeholder1x1 = `${CoreResource}/images/standard-placeholder-1x1.png`;

// /** backend data call for getOfferingDetails
//  *
//  * @param {string} offeringId id for offering
//  * @returns {Promise} promise with all the data for the offering detail page
//  */
// export default async function getOfferingDetailsBackend({ offeringId }) {
//   let langCode = langLocale;
//   if(langLocale.includes('-')){
//     langCode = langLocale.replaceAll('-','_');
//   }
//   let language = '';
//   let query = window.location.search.substr(1);
//   let item = query.split("language=");
//   language = !item ? 'NA' : item[1]; 


   
//   const responses = await Promise.all([
//     getMarqueeProductInformation({ offeringId, langCode }),
//     getOfferingDetail({
//       offeringId,
//       bEditOffering: false,
//       bViewOffering: true,
//       bCompareOffering: false,
//       language,
//       langCode,
//       isPreview: false, // isPreview
//     }),
//   ]);

//   const marqueeResponse = responses[0][0];
//   const response = JSON.parse(responses[1]).objectData;
//   const offering__c = response.OfferingDetail[0];
//   const startDate = offering__c.PMP_Partner_Offering_Start_Dt__c; // storing from date in a variable
//   const today = (new Date()).toISOString().slice(0, 10);

//   const extractedNotificationBanner = notificationBannerExtractor(offering__c, startDate);
//   const extractedGalleryImages = galleryImageExtractor(response.contentWrapper);
//   const extractedCategories = categoriesExtractor(response.selectedCategories);
//   const extractedSpecifications = specificationsExtractor(response.selectedSpecifications);
//   const extractedQualityMetrics = qualityMetricsExtractor(response.selectedSpecificationsMap);
//   const extractedPartnerAttributes = partnerAttributesExtractor(response.partnerDetail.attributes);

//   // GATHER OFFERING DATA
//   const offering = {
//     showCloneButton : false,
//     showDateChangeButton : false,
//     contactPartnerModalData : false,
//     editButtonDisabled : false,
//     showDisclaimer : false,
//     showAllCompanyOfferingsLink : false,
//     displayLanguage : '',
//     isAnonymousUser: !!response.isAnonymousUser,
//     isAdmin: !!response.isAdmin,
//     isPublished: !!extractedNotificationBanner.isPublished,
//     notificationBanners: [{
//       message: extractedNotificationBanner.notificationBanner.message,
//       iconType: extractedNotificationBanner.notificationBanner.type,
//       theme: 'background',
//     }] || [],
//     showEventBanner: response.eventPartnerOffering,
//     showEditButton: !!response.showEditButton,
//     showContactPartner: !!response.showContactPartner,
//     // Offering Info
//     id: offering__c.Id,
//     workingCopyId: response.WorkingCopyId,
//     title: offering__c.Name,
//     images: extractedGalleryImages,
//     compareCategoryId: marqueeResponse ? marqueeResponse.compareCategoryId : '',
//     publishedDate: new Date(offering__c.PMP_Offering_Status_Update_Dt__c),
//     tagline: offering__c.PMP_Partner_Offering_Tag_Line_Txt__c,
//     descriptionShort: offering__c.PMP_Partner_Offering_Dsc__c,
//     descriptionLong: offering__c.PMP_Partner_Offering_Dsc__c,
//     techSpecs: [{
//       label: PMP_Category,
//       attributesList: [{
//         separator: ':',
//         values: extractedCategories.productCategories.map((cat) => ({
//           isLink: true,
//           label: cat.Name,
//           recordId: cat.PMP_Category_Id__c,
//           objectPage: 'PMP_Category__c',
//         })),
//       }],
//     }].concat((response.selectedSpecificationsMap || []).map((s) => ({
//       label: s.masterCategory,
//       attributesList: [{
//         values: s.valueList.map((v) => ({
//           label: v,
//         })),
//       }],
//     }))),
//     qualityMetrics: (extractedQualityMetrics || []).map((m) => ({
//       label: m.masterCategory,
//       attributesList: [{
//         values: m.valueList.map((v) => ({
//           label: v,
//         })),
//       }],
//     })),
//     intelTechnology: extractedSpecifications.includedIntelTechnologies.map((t) => ({
//       image: t.specImageUrl || placeholder1x1,
//       imageLink: t.specTitleUrl,
//       values: [{
//         isLink: !!t.specTitleUrl,
//         class: 'text-bold',
//         label: t.specTitle,
//         externalUrl: t.specTitleUrl,
//       }].concat((t.specValues || []).map((v) => ({
//         isLink: !!v.productURL,
//         label: v.description,
//         externalUrl: v.productURL,
//       }))),
//     })),
//     marketingInfo: [
//       {
//         headline: industriesLabel,
//         items: extractedCategories.industries.map((i) => i.label),
//       },
//       {
//         headline: applicationsLabel,
//         items: extractedCategories.applications.map((a) => a.label),
//       },
//       {
//         headline: regionLabel,
//         items: extractedSpecifications.regions.map((r) => r.value),
//       },
//       {
//         headline: availabilitypricingLabel,
//         items: extractedSpecifications.industriesApplications.availability_pricing.map((a) => a.label),
//       },
//     ].filter((section) => section.items.length),
//     // Resources
//     resources: (response.offeringResources || [])
//       .map((r) => ({
//         title: r.title,
//         url: r.url,      
//         description: r.description,
//         fileType: r.fileType,
//         fileSize: r.fileSize,
//         resourceType: r.resourceType,
//         downloadUrl: r.downloadUrl,

//       })),
//     // Partner Info
//     partnerId: offering__c.PMP_Company_Id__r.Id || '',
//     partnerName:  offering__c.PMP_Company_Id__r.Name ||'',
//     partnerLogo: response.partnerDetail.imageUrl,
//     // Partner Attributes
//     partnerAttributes: extractedPartnerAttributes,
//     // Company Resources
//     companyResources: (response.productCompanyResource.companyResources || []).map((r) => ({
//       title: r.title,
//       url: r.linkUrl,
//       label: r.linkUrl,
//     })),
//     // Articles
//     articles: (response.articleCompanyResource.articleList || []).map((a) => ({
//       ...a,
//     })),
//   };

//   // Additional Business Logic
//   // Edit / Clone Buttons, Notification Banner, etc.
//   if ( response.showEditButton && (offering__c.PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Published' || offering__c.PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Retired' )) {
//     offering.showCloneButton = true;
//       if(offering__c.PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Retired') {
//         offering.showEditButton = false;
//       }
//   } else {
//     offering.notificationBanners = [];
//   } // User is logged in
//     // Date Change Button
//     if (offering.showEditButton && offering__c.PMP_Is_Notified_Ind__c) {
//        offering.showDateChangeButton = true;
//     }

//     // Gireesh:US762788
//     const isNotEnglish = (
//       !(offering__c.PMP_Translated_Languages__c).includes('English')
//       && (offering__c.PMP_Business_Segment_Nm__c).includes('IoT')
//     );

//     const isUnderReview = offering__c.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Admin Review';
//     const isApprovedForFuture = (
//       offering__c.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Approved'
//       && (new Date(startDate) > new Date(today))
//     );

//     if ((isNotEnglish && response.isAdmin) || (!response.isAdmin && (isUnderReview || isApprovedForFuture))) {
//       offering.editButtonDisabled = true;
//     }
  

//   // Show Disclaimer
//   if (response.isIntelEmployee && (offering__c.PMP_Partner_Offering_Visibility_Nm__c !== 'Public Content')) {
//     offering.showDisclaimer = true;
//   }

//   // Show "All Company Offerings ->" Link
//   if (response.partnerDetail.benefitType === 'Solutions Marketplace Enhanced') {
//     offering.showAllCompanyOfferingsLink = true;
//   }

//   // add contact partner modal data
//   offering.contactPartnerModalData = {};
//   if (response.showContactPartner) {
//     offering.contactPartnerModalData = {
//       name: offering.partnerName,
//       id: offering.partnerId,
//       autoPartnerId: offering.partnerAutoId,
//       leadLangPreference: offering.leadLangPreference,
//       title: offering.title,
//       oid: offering__c.PMP_Offering_Id__c, 
//       offRecId: offering__c.Id,
//       isLoggedIn: !offering.isAnonymousUser, 
//     };
//   }


//   // if langauge parameter is not present in url, we check for user locale in the apex controller and
//   // send it as a parmeter. This is done as a part of change request.
//   if (!language && response.userLocale && response.userLocale !== 'NA') {
//     language = response.userLocale;

//   // we set Language as NA on the offering name formula field so that we show base language
//   // values when user clicks on offering name from list view
//   } else if (language === 'NA') {
//     language = undefined;
//   }
//   offering.displayLanguage = language;

//   // eslint-disable-next-line no-console
//   console.log('getOfferingDetailsBackend - compiled offering data', offering);

//   return offering;
// }
export default class getOfferingDetailsBackendWrkngCpy extends LightningElement{}