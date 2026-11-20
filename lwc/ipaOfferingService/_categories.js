// /* eslint-disable camelcase */
// import PMP_NPP_01_Industry from '@salesforce/label/c.PMP_NPP_01_Industry';
// import PMP_NPP_01_APP from '@salesforce/label/c.PMP_NPP_01_APP';
// import PMP_NPP_01_TYPE from '@salesforce/label/c.PMP_NPP_01_TYPE';

// /** extracts marketing info (code copied from MarketplaceProductDetailHelper in LWC upgrade)
//  *
//  * @param {*} categories not sure
//  *
//  * @returns {object[]} categories and marketing info
//  */
// export default function extractCategories(categories) {
//   const categoryById = {};
//   const categoryChildById = {};
//   const IndustryById = {};
//   const IndustryChildById = {};
//   const applicationById = {};
//   const applicationChildById = {};

//   categories.forEach((category) => {
//     if (category.PMP_Ancestor_Category_Cd__c) {
//       // Industries from selected categories,added by raj for US298826
//       if (category.PMP_Ancestor_Category_Cd__c.includes(PMP_NPP_01_Industry)) {
//         IndustryById[category.PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c] = category;
//         IndustryChildById[category.PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c] = [];

//       // Applications from selected categories,added by raj for US298826
//       } else if (category.PMP_Ancestor_Category_Cd__c.includes(PMP_NPP_01_APP)) {
//         applicationById[category.PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c] = category;
//         applicationChildById[category.PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c] = [];

//         // Category from selected categories - ON TECHINICAL SPECIFICATIONS SECTION
//       } else if (category.PMP_Ancestor_Category_Cd__c.includes(PMP_NPP_01_TYPE)) {
//         categoryById[category.PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c] = category;
//         categoryChildById[category.PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c] = [];
//       }
//     }

//     if (category.PMP_Ancestor_Category_Cd__c) {
//       if (category.PMP_Ancestor_Category_Cd__c.includes(PMP_NPP_01_Industry)
//         && IndustryChildById[category.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c]) {
//         IndustryChildById[category.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c].push(category);
//       } else if (category.PMP_Ancestor_Category_Cd__c.includes(PMP_NPP_01_APP)
//         && applicationChildById[category.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c]) {
//         applicationChildById[category.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c].push(category);
//       } else if (category.PMP_Ancestor_Category_Cd__c.includes(PMP_NPP_01_TYPE)
//         && categoryChildById[category.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c]) {
//         categoryChildById[category.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c].push(category);
//       }
//     }
//   });

//   const applications = buildLabels(applicationChildById, applicationById);
//   const industries = buildLabels(IndustryChildById, IndustryById);
//   const productCategories = Object.values(categoryById);

//   return {
//     applications, industries, productCategories,
//   };
// }

// /**
//  * helper function to build labels
//  *
//  * @param {*} group group
//  * @param {*} groupParent group parent
//  * @returns {*} labels
//  */
// function buildLabels(group, groupParent) {
//   const result = [];
//   Object.keys(group).forEach((key) => {
//     let label = '';
//     if (group[key].length === 0) {
//       // getting only the nodes which doesn't have any child
//       const cat = groupParent[key];
//       const ancesCat = cat.PMP_Ancestor_Category_Cd__c.split('|');
//       // appending all parent except for the ultimate parent
//       ancesCat.slice(1).forEach((ancestor) => {
//         const parent = groupParent[ancestor];
//         label += `${parent.Name} : `;
//       });
//       label += cat.Name;
//     }
//     if (label) {
//       result.push({
//         label,
//         link: '#',
//       });
//     }
//   });
//   let otherValueIndex;	
//   let otherValue;	
//   result.forEach((record) =>{	
//     let indexFirst = result.indexOf(record)+1;	
//     if(result[indexFirst-1].label == 'Others' && (indexFirst != result.length)){	
//       otherValueIndex = indexFirst-1;	
//       otherValue = result[indexFirst-1].label;	
//     }	
//     if(record.label.includes(':') && (result[indexFirst] && !(result[indexFirst].label.includes(':')))){  	
//         result.splice(indexFirst,1);     	
//       }	
//     });	
   	
//   if(otherValueIndex != undefined && otherValue != undefined){	
//     result[otherValueIndex].label = result[result.length-1].label;	
//     result[result.length-1].label = otherValue;	
//   }
//   return result;
// }
export default class categories extends LightningElement{}