// import checkValidOffering from '@salesforce/apex/PMP_OfferingDetailsController.checkValidOffering';

// /**
//  * check if offering is valid ?
//  *
//  * @param {object} params params object
//  * @param {string} params.offeringId offering record id
//  * @param {boolean} params.isPreview if in preview mode
//  * @returns {boolean} validity
//  */
// export default async function isValidOffering({ offeringId, isPreview }) {
//   return checkValidOffering({ offeringId, isPreview: !!isPreview });
// }

export default class checkValidOffering extends LightningElement{}