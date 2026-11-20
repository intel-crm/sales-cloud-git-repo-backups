// /** extracts partner attributes
//  *
//  * TODO - REFACTOR DATA STRUCTURE FROM BACKEND
//  *
//  * @param {*} partnerAttributes attributes
//  *
//  * @returns {object[]} formatted data
//  */
// export default function extractQualityMetrics(partnerAttributes = []) {
//   return partnerAttributes.map((det) => {
//     let sections = [];

//     // first look at typeGroupings property OR types directly
//     if (det && (det.typeGroupings || det.types)) {
//       sections = (det.typeGroupings || [{ types: det.types }]);
//       sections = sections.map((grp) => ({
//         label: grp.name,
//         values: grp.types.map((typ) => {
//           const value = {
//             // PER JANE'S REQUEST - REMOVING ALL PARTNER LINKS FOR  NOW
//             isLink: false, // true,
//             label: typ.name,
//           };
//           if (typ.link) {
//             value.isLink = true;
//             value.externalUrl = typ.link;
//           }
//           return value;
//         }),
//       }));
//     }

//     // then look at textBlock... (used in addresses)
//     if (det && (!det.typeGroupings && !det.types && det.textBlock)) {
//       sections = [{
//         values: det.textBlock.split('<br>').map((txt) => ({
//           isLink: false,
//           label: txt,
//         })),
//       }];
//     }

//     return {
//       title: det ? det.name : '',
//       sections,
//     };
//   });
// }

export default class partnerAttributes extends LightningElement{}