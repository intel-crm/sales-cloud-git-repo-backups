// import { handleError } from 'c/ipaErrorServiceMarketplace';
// import fetchData from './fetchData';
// import labels from './labels';

// /**
//  * Format Data
//  *
//  * @param {object[]} compareTrayItems compare tray items
//  * @returns {Promise} formatted data
//  */
// export default async function formatData(compareTrayItems) {
//   try {
//     const response = await fetchData(compareTrayItems);

//     const tableData = response.sections.reduce((allSections, section) => {
//       const newSection = {
//         ...section,
//         children: section.children.filter((child) => child.data.length).map((child, idx) => ({
//           ...child,
//           expanded: idx < 3,
//           ariaLabelledBy: `${child.label}-${labels.PMP_CompareProducts_AriaLabelledBy}`,
//           ariaControls: `${child.label}-${labels.PMP_CompareProducts_AriaControls}`,
//         })),
//       };

//       if (newSection.children.length) {
//         allSections.push(newSection);
//       }

//       return allSections;
//     }, []);

//     return {
//       contactPartnerData: response.contactPartnerData,
//       tableData,
//     };
//   } catch (err) {
//     handleError(err, 'ipaCompareProducts - formatData', 'console');
//     return [];
//   }
// }