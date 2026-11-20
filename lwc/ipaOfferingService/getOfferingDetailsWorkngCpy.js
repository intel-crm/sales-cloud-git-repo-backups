// /* Core Resource for default Product Gallery Image */
// import CoreResource from '@salesforce/resourceUrl/Core_INTC';

// /* Internal Imports */
// import getOfferingDetailsBackendWrkngCpy from './getOfferingDetailsBackendWrkngCpy';
// import { LightningElement } from 'lwc';

// /* 4x3 default placeholder for missing Gallery Image */
// const placeholder4x3 = `${CoreResource}/images/standard-placeholder-4x3.png`;

// /**
//  * @typedef {object} OfferingRequestParams
//  * @property {string} offeringId offering ID
//  * @property {string} langCode language code
//  * @property {string} language language
//  */

// /** getOfferingDetails (for Offering Detail L3 page - ipaOfferingDetail)
//  *
//  * This function calls another function which calls the APEX on the backend
//  * This function then calls presenters, extracting the data needed for:
//  *  - Marquee
//  *  - Compare Offering (in Marquee checkbox)
//  *  - Offering Detail component
//  *
//  * @param {OfferingRequestParams} params request params for offering details
//  * @returns {Promise} promise with all the data for the offering detail page
//  */
// export default async function getOfferingDetails({ offeringId }) {
//   // Splits Offering into Use Cases
//   const offering = await getOfferingDetailsBackendWrkngCpy({ offeringId });

//   return {
//     marqueeData: marqueeDataPresenter(offering),
//     offeringDetailData: offeringDetailDataPresenter(offering),
//     compareProductData: compareProductDataPresenter(offering),
//   };
// }

// /** extracts offering data for marquee
//  *
//  * @param {*} offering offering object
//  * @returns {*} marquee data
//  */
// function marqueeDataPresenter(offering = {}) {
//   return {
//     title: offering.title || 'error: missing data',
//     partnerName: offering.partnerName || 'error: missing data',
//     partnerId: offering.partnerId || 'error: missing data',
//     publishedDate: offering.publishedDate || 'error: missing data',
//     tagline: offering.tagline || '', // not required, no default
//   };
// }

// /** extracts offering data for offering detail component
//  *
//  * @param {*} offering offering object
//  * @returns {*} offering detail data
//  */
// function offeringDetailDataPresenter(offering = {}) {
//   return {
//     notificationBanners: offering.notificationBanners || [],
//     showDisclaimer: !!offering.showDisclaimer,
//     showEventBanner: !!offering.showEventBanner,
//     showCloneButton: !!offering.showCloneButton,
//     showContactPartner: !!offering.showContactPartner,
//     showEditButton: !!offering.showEditButton,
//     editButtonDisabled: offering.editButtonDisabled,
//     showDateChangeButton: !!offering.showDateChangeButton,
//     showAllCompanyOfferingsLink: !!offering.showAllCompanyOfferingsLink,
//     contactPartnerModalData: offering.contactPartnerModalData,
//     images: offering.images.length ? offering.images : [placeholder4x3], // use default placeholder if no images exist
//     descriptionShort: offering.descriptionShort || '', // if no description exists, this section will be hidden
//     descriptionLong: offering.descriptionLong || '',
//     techSpecs: offering.techSpecs || [],
//     qualityMetrics: offering.qualityMetrics || [],
//     intelTechnology: offering.intelTechnology || [],
//     marketingInfo: offering.marketingInfo || [],
//     resources: offering.resources || [],
//     partnerLogo: offering.partnerLogo || placeholder4x3, // ..remove eventually, no default needed - data must include logo
//     partnerId: offering.partnerId || 'error: missing data',
//     partnerName: offering.partnerName || 'error: missing data',
//     partnerAttributes: offering.partnerAttributes || [],
//     companyResources: offering.companyResources || [],
//     articles: offering.articles || [],
//   };
// }

// /** extracts offering data for compare product
//  *
//  * @param {*} offering offering object
//  * @returns {*} compare product data
//  */
// function compareProductDataPresenter(offering = {}) {
//   return {
//     id: offering.id || 'error: missing data',
//     title: offering.title || 'error: missing data',
//     imageUrl: offering.imageUrl || 'error: missing data',
//     compareCategoryId: offering.compareCategoryId || 'error: missing data',
//   };
// }
export default class getOfferingDetailsWorkngcpy extends LightningElement{}