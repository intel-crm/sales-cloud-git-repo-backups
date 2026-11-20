// /* eslint-disable camelcase */

// import PMP_BoardQualityMetricPIMId from '@salesforce/label/c.PMP_BoardQualityMetricPIMId';
// import PMP_IPQualityMetricPIMId from '@salesforce/label/c.PMP_IPQualityMetricPIMId';
// import PMP_Yes from '@salesforce/label/c.PMP_Yes';

// /** extracts intel tech data (code copied from MarketplaceProductDetailHelper in LWC upgrade)
//  * includes: AVAILABILITY & PRICING, REGIONS
//  *
//  * PUBLICIS SAPIENT NOTES:
//  * This code is for a specific type of category to get the category Tech Spec.
//  *
//  * @param {object} specs product specifications
//  *
//  * @returns {object} formatted data
//  */
// export default function extractQualityMetrics(specs) {
//   const qualityMetrics = [];

//   specs.forEach((spec) => {
//     const isQualityMetric = [
//       PMP_BoardQualityMetricPIMId,
//       PMP_IPQualityMetricPIMId,
//     ].includes(spec.masterCategory);

//     if (isQualityMetric) {
//       const qualityMetric = [];
//       spec.valueList.forEach((item) => {
//         const [item1, item2] = item.split(':');
//         if (item2 && item2.includes(PMP_Yes)) {
//           qualityMetric.unshift({
//             key: item1,
//             value: item2,
//             isYes: true,
//           });
//         } else if (item2 === undefined) {
//           qualityMetric.unshift({
//             key: item1,
//             value: PMP_Yes,
//             isYes: true,
//           });
//         } else {
//           qualityMetric.unshift({
//             key: item1,
//             value: item2,
//             isYes: false,
//           });
//         }
//       });

//       if (qualityMetric.length) {
//         qualityMetrics.unshift({
//           masterCategory: spec.masterCategory.split('|')[0],
//           keyList: qualityMetric,
//         });
//       }
//     }
//   });

//   return qualityMetrics;
// }

export default class qualityMetrics extends LightningElement{}