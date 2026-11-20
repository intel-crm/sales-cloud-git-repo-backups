// /* eslint-disable no-restricted-syntax */
// /* eslint-disable spaced-comment */
// /* eslint-disable camelcase */
// import PMP_NPP_GeographicCoverage from '@salesforce/label/c.PMP_NPP_GeographicCoverage';
// import PMP_AvailabilityandPricingLevel1 from '@salesforce/label/c.PMP_AvailabilityandPricingLevel1';
// import PMP_NPP_AvailabilityAndPricing_CPP from '@salesforce/label/c.PMP_NPP_AvailabilityAndPricing_CPP';
// import PMP_Yes from '@salesforce/label/c.PMP_Yes';
// import PMP_NPP_Processors from '@salesforce/label/c.PMP_NPP_Processors';
// import PMP_NPP_Graphics from '@salesforce/label/c.PMP_NPP_Graphics';
// import PMP_NPP_Chipsets from '@salesforce/label/c.PMP_NPP_Chipsets';
// import PMP_NPP_FPGA from '@salesforce/label/c.PMP_NPP_FPGA';
// import PMP_NPP_NUC from '@salesforce/label/c.PMP_NPP_NUC';
// import PMP_NPP_IntelTechnologies from '@salesforce/label/c.PMP_NPP_IntelTechnologies';
// import PMP_IntelTechImageURL from '@salesforce/label/c.PMP_IntelTechImageURL';
// import PMP_NPP_Intel_FPGA_Platforms from '@salesforce/label/c.PMP_NPP_Intel_FPGA_Platforms';

// /** extracts intel tech data (code copied from MarketplaceProductDetailHelper in LWC upgrade)
//  * includes: AVAILABILITY & PRICING, REGIONS
//  *
//  * @param {object} specs product specifications
//  *
//  * @returns {object} formatted data
//  */
// export default function extractIntelTech(specs = []) {
//   const specifications = specs;
//   const product = {
//     specification: [],
//     specifications: {
//       data: [],
//     },
//     includedIntelTechnologies: [],
//     regions: [],
//     industriesApplications: {
//       availability_pricing: [],
//     },
//   };

//   let productCategories = '';
//   product.SpecName = [];

//   let processorDescription = '';
//   let graphicsDescription = '';
//   let chipsetDescription = '';
//   let PimageURLNew = '';
//   let GimageURLNew = '';
//   let CimageURLNew = '';
//   let FimageURLNew = '';
//   let IimageURLNew = '';

//   let PspecPIMId = '';
//   let GspecPIMId = '';
//   let CspecPIMId = '';
//   let FspecPIMId = '';
//   let IspecPIMId = '';
//   let NspecPIMId = '';
//   let pacSpecPIMId = '';

//   let PisSpecValueRecord = false;
//   let GisSpecValueRecord = false;
//   let CisSpecValueRecord = false;
//   let FisSpecValueRecord = false;
//   let IisSpecValueRecord = false;
//   let NisSpecValueRecord = false;
//   let pacIsSpecValueRecord = false;

//   const processorParentProductURLMapByName = new Map();
//   const graphicsParentProductURLMapByName = new Map();
//   const chipsetParentProductURLMapByName = new Map();
//   const fpgaParentProductURLMapByName = new Map();
//   const intelTechParentProductURLMapByName = new Map();
//   const nucParentProductURLMapByName = new Map();
//   const pacParentProductURLMapByName = new Map();

//   const regionById = new Map();
//   const regionChildById = new Map();
//   const countriesBySubRegionId = new Map();
//   const countries = [];

//   let nucDescription = '';
//   const nucObjectMapByName = new Map();
//   const nucDescMap = new Map();
//   let NimageURLNew = '';

//   let pacDescription = '';
//   const pacObjectMapByName = new Map();
//   const pacDescMap = new Map();
//   let pacImageURLNew = '';

//   const chipsetObjectMapByName = new Map();
//   const chipsetDescMap = new Map();

//   let fpgaDescription = '';
//   const fpgaObjectMapByName = new Map();
//   const fpgaDescMap = new Map();

//   const processorObjectMapByName = new Map();
//   const processorDescMap = new Map();

//   const graphicsObjectMapByName = new Map();
//   const graphicsDescMap = new Map();

//   let intelTechDescription = '';
//   const intelTechObjectMapByName = new Map();
//   const intelTechDescMap = new Map();

//   specifications.forEach((spec) => {
//     /* Added By Raj for displaying region and subregion on details page US439862 */
// 		console.log('Boolean',spec.PMP_Boolean_Ind__c);
//     if (spec.PMP_Ancestor_Specification_Cd__c !== undefined
//       && spec.PMP_Ancestor_Specification_Cd__c.includes(PMP_NPP_GeographicCoverage)) {
//       const subRegions = [];// to store sub regions
//       // storing the region records by product specification Id
//       regionById.set(spec.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c, spec);
//       // setting child list of the region to empty(default 0)
//       // commented as no longer required
//       regionChildById.set(spec.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c, subRegions);
//       // storing the selected countries in seperate map(added by raj as part of spike)
//       if(spec.PMP_Specification_Value_Cd__c !== undefined){
//           countries.push(spec);
//           countriesBySubRegionId.set(spec.PMP_Product_Specification_Cd__c, spec);
//       }
//     }
//     /*--------------------------------End-------------------------------------*/
//     // Availability and Pricing from selected specification,added by raj for US298826
//     if (spec.PMP_Ancestor_Specification_Cd__c === PMP_AvailabilityandPricingLevel1) {
//       if (spec.PMP_Product_Specification_Cd__c === PMP_NPP_AvailabilityAndPricing_CPP) {
//         productCategories = `${spec.PMP_Specification_Nm__c} : ${PMP_Yes}`;
//       } else {
//         productCategories = `${spec.PMP_Specification_Nm__c} : ${spec.PMP_Specification_Value_Cd__c}`;
//       }
//       product.industriesApplications.availability_pricing.push({
//         label: productCategories,
//         link: '#',
//       });
//     }
//     /* User Story: US611446
//      * Added by:    Deepanshu - ONYX
//      * Description: The purpose for this code is to display Processors as a part of Included Intel Technologies through new optimized code.
//      */
//     // Checking the parent by using a method to fetch the custom labels
//     if (spec.PMP_Ancestor_Specification_Cd__c !== undefined
//       && spec.PMP_Ancestor_Specification_Cd__c.includes(PMP_NPP_Processors)
//       && spec.PMP_Specification_Id__r.PMP_Specification_Type_Nm__c === 'Processor') {
//       // Variables for internal use
//       let isSpecNotPresent = false;
//       let isSpecPresent = false;
//       let isOnlySpec = false;
//       const specsList = [];
//       // Enter only if specification value is selected
//       if (spec.PMP_Specification_Value_Cd__c !== undefined) {
//         // If the Spec Tech Map doesn't have specification Name - from hereon referred to as "isSpecNotPresent"
//         if (!processorObjectMapByName.has(spec.Name)) {
//           // Setting isSpecNotPresent boolean as true for further processing in method
//           isSpecNotPresent = true;
//           // Calling Generic method and getting all details
//           const recData = createSpecInstance(spec, processorDescription, PimageURLNew, PspecPIMId, PisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//           if (recData.specDescObject !== undefined) {
//             processorObjectMapByName.set(spec.Name, recData.specTechObject);
//             specsList.push(recData.specDescObject);
//             processorDescMap.set(spec.Name, specsList);
//           }
//           processorDescription = recData.specDescription;
//           PimageURLNew = recData.specImageUrlNew;
//           PspecPIMId = recData.specCurrentPIMId;
//           PisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         // If Spec Tech map has specification name
//         } else {
//           // Setting Condition2 boolean as true for further processing in method
//           isSpecPresent = true;
//           // Calling Generic method and getting all details
//           const recData = createSpecInstance(spec, processorDescription, PimageURLNew, PspecPIMId, PisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//           if (recData.specDescObject !== undefined) {
//             processorObjectMapByName.set(recData.specTechName, recData.specTechObject);
//             let temp = [];
//             if ((processorDescMap.get(spec.Name) !== undefined)) {
//               temp = processorDescMap.get(spec.Name);
//             }
//             temp.push(recData.specDescObject);
//             processorDescMap.set(spec.Name, temp);
//           }
//           processorDescription = recData.specDescription;
//           PimageURLNew = recData.specImageUrlNew;
//           PspecPIMId = recData.specCurrentPIMId;
//           PisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         }

//       // If Spec values are not present - Create only Spec Object and populate with spec data
//       } else {
//         // Setting isOnlySpec boolean as true for further processing in method
//         isOnlySpec = true;
//         // Calling Generic method and getting all details
//         const recData = createSpecInstance(spec, processorDescription, PimageURLNew, PspecPIMId, PisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//         processorObjectMapByName.set(spec.Name, recData.specTechObject);
//         processorParentProductURLMapByName.set(spec.Name, recData.specParentProductUrl);
//         processorDescription = recData.specDescription;
//         PimageURLNew = recData.specImageUrlNew;
//         PspecPIMId = recData.specCurrentPIMId;
//         PisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         if (spec.PMP_Specification_Id__r) {
//           processorObjectMapByName.delete(spec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name);
//         }
//       }

//     /* User Story: TWC1824-5522
//      * Added by:    Ajay - ONYX
//      * Description: The purpose for this code is to display Graphics as a part of Included Intel Technologies through new optimized code.
//      */
//     // Checking the parent by using a method to fetch the custom labels
//     } else if (spec.PMP_Ancestor_Specification_Cd__c !== undefined
//       && spec.PMP_Ancestor_Specification_Cd__c.includes(PMP_NPP_Graphics)
//       && spec.PMP_Specification_Id__r.PMP_Specification_Type_Nm__c === 'Graphics') {
//       // Variables for internal use
//       let isSpecNotPresent = false;
//       let isSpecPresent = false;
//       let isOnlySpec = false;
//       const specsList = [];
//       // Enter only if specification value is selected
//       if (spec.PMP_Specification_Value_Cd__c !== undefined) {
//         // If the Spec Tech Map doesn't have specification Name - from hereon referred to as "isSpecNotPresent"
//         if (!graphicsObjectMapByName.has(spec.Name)) {
//           // Setting isSpecNotPresent boolean as true for further processing in method
//           isSpecNotPresent = true;
//           // Calling Generic method and getting all details
//           const recData = createSpecInstance(spec, graphicsDescription, GimageURLNew, GspecPIMId, GisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//           if (recData.specDescObject !== undefined) {
//             graphicsObjectMapByName.set(spec.Name, recData.specTechObject);
//             specsList.push(recData.specDescObject);
//             graphicsDescMap.set(spec.Name, specsList);
//           }
//           graphicsDescription = recData.specDescription;
//           GimageURLNew = recData.specImageUrlNew;
//           GspecPIMId = recData.specCurrentPIMId;
//           GisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         // If Spec Tech map has specification name
//         } else {
//           // Setting Condition2 boolean as true for further processing in method
//           isSpecPresent = true;
//           // Calling Generic method and getting all details
//           const recData = createSpecInstance(spec, graphicsDescription, GimageURLNew, GspecPIMId, GisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//           if (recData.specDescObject !== undefined) {
//             graphicsObjectMapByName.set(recData.specTechName, recData.specTechObject);
//             let temp = [];
//             if ((graphicsDescMap.get(spec.Name) !== undefined)) {
//               temp = graphicsDescMap.get(spec.Name);
//             }
//             temp.push(recData.specDescObject);
//             graphicsDescMap.set(spec.Name, temp);
//           }
//           graphicsDescription = recData.specDescription;
//           GimageURLNew = recData.specImageUrlNew;
//           GspecPIMId = recData.specCurrentPIMId;
//           GisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         }

//       // If Spec values are not present - Create only Spec Object and populate with spec data
//       } else {
//         // Setting isOnlySpec boolean as true for further processing in method
//         isOnlySpec = true;
//         // Calling Generic method and getting all details
//         const recData = createSpecInstance(spec, graphicsDescription, GimageURLNew, GspecPIMId, GisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//         graphicsObjectMapByName.set(spec.Name, recData.specTechObject);
//         graphicsParentProductURLMapByName.set(spec.Name, recData.specParentProductUrl);
//         graphicsDescription = recData.specDescription;
//         GimageURLNew = recData.specImageUrlNew;
//         GspecPIMId = recData.specCurrentPIMId;
//         GisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         if (spec.PMP_Specification_Id__r) {
//           graphicsObjectMapByName.delete(spec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name);
//         }
//     }

//     /* User Story: US600114
//      * Added by:    Deepanshu - ONYX
//      * Description: The purpose for this code is to display Chipset as a part of Included Intel Technologies through new optimized code.
//      */
//     // Checking the parent by using a method to fetch the custom labels
//     } else if (spec.PMP_Ancestor_Specification_Cd__c !== undefined
//       && spec.PMP_Ancestor_Specification_Cd__c.includes(PMP_NPP_Chipsets)) {
//       // Variables for internal use
//       let isSpecNotPresent = false;
//       let isSpecPresent = false;
//       let isOnlySpec = false;
//       const specsList = [];

//       // Enter only if specification value is selected
//       if (spec.PMP_Specification_Value_Cd__c !== undefined) {
//         // If the Spec Tech Map doesn't have specification Name - from hereon referred to as "isSpecNotPresent"
//         if (!chipsetObjectMapByName.has(spec.Name)) {
//           // Setting isSpecNotPresent boolean as true for further processing in method
//           isSpecNotPresent = true;
//           // Calling Generic method and getting all details
//           const recData = createSpecInstance(spec, chipsetDescription, CimageURLNew, CspecPIMId, CisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//           if (recData.specDescObject !== undefined) {
//             chipsetObjectMapByName.set(spec.Name, recData.specTechObject);
//             specsList.push(recData.specDescObject);
//             chipsetDescMap.set(spec.Name, specsList);
//           }
//           chipsetDescription = recData.specDescription;
//           CimageURLNew = recData.specImageUrlNew;
//           CspecPIMId = recData.specCurrentPIMId;
//           CisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         // If Spec Tech map has specification name
//         } else {
//           // Setting Condition2 boolean as true for further processing in method
//           isSpecPresent = true;
//           // Calling Generic method and getting all details
//           const recData = createSpecInstance(spec, chipsetDescription, CimageURLNew, CspecPIMId, CisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//           if (recData.specDescObject !== undefined) {
//             chipsetObjectMapByName.set(recData.specTechName, recData.specTechObject);
//             let temp = [];
//             if ((chipsetDescMap.get(spec.Name) !== undefined)) {
//               temp = chipsetDescMap.get(spec.Name);
//             }
//             temp.push(recData.specDescObject);
//             chipsetDescMap.set(spec.Name, temp);
//           }
//           chipsetDescription = recData.specDescription;
//           CimageURLNew = recData.specImageUrlNew;
//           CspecPIMId = recData.specCurrentPIMId;
//           CisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         }

//       // If Spec values are not present - Create only Spec Object and populate with spec data
//       } else {
//         // Setting isOnlySpec boolean as true for further processing in method
//         isOnlySpec = true;
//         // Calling Generic method and getting all details
//         const recData = createSpecInstance(spec, chipsetDescription, CimageURLNew, CspecPIMId, CisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//         chipsetObjectMapByName.set(spec.Name, recData.specTechObject);
//         chipsetParentProductURLMapByName.set(spec.Name, recData.specParentProductUrl);
//         chipsetDescription = recData.specDescription;
//         CimageURLNew = recData.specImageUrlNew;
//         CspecPIMId = recData.specCurrentPIMId;
//         CisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         if (spec.PMP_Specification_Id__r) {
//           chipsetObjectMapByName.delete(spec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name);
//         }
//       }

//     /* User Story: US600114
//     * Added by:    Deepanshu - ONYX
//     * Description: The purpose for this code is to display FPGA as a part of Included Intel Technologies through new optimized code.
//     */
//     // Checking the parent by using a method to fetch the custom labels
//     } else if (spec.PMP_Ancestor_Specification_Cd__c !== undefined
//       && spec.PMP_Ancestor_Specification_Cd__c.includes(PMP_NPP_FPGA)) {
//       // Variables for internal use
//       let isSpecNotPresent = false;
//       let isSpecPresent = false;
//       let isOnlySpec = false;
//       const specsList = [];

//       // Enter only if specification value is selected
//       if (spec.PMP_Specification_Value_Cd__c !== undefined) {
//         // If the Spec Tech Map doesn't have specification Name - from hereon referred to as "isSpecNotPresent"
//         if (!fpgaObjectMapByName.has(spec.Name)) {
//           // Setting isSpecNotPresent boolean as true for further processing in method
//           isSpecNotPresent = true;
//           // Calling Generic method and getting all details
//           const recData = createSpecInstance(spec, fpgaDescription, FimageURLNew, FspecPIMId, FisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//           if (recData.specDescObject !== undefined) {
//             fpgaObjectMapByName.set(spec.Name, recData.specTechObject);
//             specsList.push(recData.specDescObject);
//             fpgaDescMap.set(spec.Name, specsList);
//           }
//           fpgaDescription = recData.specDescription;
//           FimageURLNew = recData.specImageUrlNew;
//           FspecPIMId = recData.specCurrentPIMId;
//           FisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         // If Spec Tech map has specification name
//         } else {
//           // Setting Condition2 boolean as true for further processing in method
//           isSpecPresent = true;
//           // Calling Generic method and getting all details
//           const recData = createSpecInstance(spec, fpgaDescription, FimageURLNew, FspecPIMId, FisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//           if (recData.specDescObject !== undefined) {
//             fpgaObjectMapByName.set(recData.specTechName, recData.specTechObject);
//             let temp = [];
//             if ((fpgaDescMap.get(spec.Name) !== undefined)) {
//               temp = fpgaDescMap.get(spec.Name);
//             }
//             temp.push(recData.specDescObject);
//             fpgaDescMap.set(spec.Name, temp);
//           }
//           fpgaDescription = recData.specDescription;
//           FimageURLNew = recData.specImageUrlNew;
//           FspecPIMId = recData.specCurrentPIMId;
//           FisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         }

//       // If Spec values are not present - Create only Spec Object and populate with spec data
//       } else {
//         // Setting isOnlySpec boolean as true for further processing in method
//         isOnlySpec = true;
//         // Calling Generic method and getting all details
//         const recData = createSpecInstance(spec, fpgaDescription, FimageURLNew, FspecPIMId, FisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//         fpgaObjectMapByName.set(spec.Name, recData.specTechObject);
//         fpgaParentProductURLMapByName.set(spec.Name, recData.specParentProductUrl);
//         fpgaDescription = recData.specDescription;
//         FimageURLNew = recData.specImageUrlNew;
//         FspecPIMId = recData.specCurrentPIMId;
//         FisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         if (spec.PMP_Specification_Id__r) {
//           fpgaObjectMapByName.delete(spec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name);
//         }
//       }

//     /* User Story:
//     * Added by:    Deepanshu - ONYX
//     * Description: The purpose for this code is to display NUC as a part of Included Intel Technologies through new optimized code.
//     */
//     // Checking the parent by using a method to fetch the custom labels
//     } else if (spec.PMP_Ancestor_Specification_Cd__c !== undefined
//       && spec.PMP_Ancestor_Specification_Cd__c.includes(PMP_NPP_NUC)) {
//       // Variables for internal use
//       let isSpecNotPresent = false;
//       let isSpecPresent = false;
//       let isOnlySpec = false;
//       const specsList = [];

//       // Enter only if specification value is selected
//       if (spec.PMP_Specification_Value_Cd__c !== undefined) {
//         // If the Spec Tech Map doesn't have specification Name - from hereon referred to as "Condition 1"
//         if (!nucObjectMapByName.has(spec.Name)) {
//           // Setting Condition2 boolean as true for further processing in method
//           isSpecNotPresent = true;
//           // Calling Generic method and getting all details
//           const recData = createSpecInstance(spec, nucDescription, NimageURLNew, NspecPIMId, NisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//           if (recData.specDescObject !== undefined) {
//             nucObjectMapByName.set(spec.Name, recData.specTechObject);
//             specsList.push(recData.specDescObject);
//             nucDescMap.set(spec.Name, specsList);
//           }
//           nucDescription = recData.specDescription;
//           NimageURLNew = recData.specImageUrlNew;
//           NspecPIMId = recData.specCurrentPIMId;
//           NisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         // If Spec Tech map has specification name
//         } else {
//           // Setting Condition2 boolean as true for further processing in method
//           isSpecPresent = true;
//           // Calling Generic method and getting all details
//           const recData = createSpecInstance(spec, nucDescription, NimageURLNew, NspecPIMId, NisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//           if (recData.specDescObject !== undefined) {
//             nucObjectMapByName.set(recData.specTechName, recData.specTechObject);
//             let temp = [];
//             if ((nucDescMap.get(spec.Name) !== undefined)) {
//               temp = nucDescMap.get(spec.Name);
//             }
//             temp.push(recData.specDescObject);
//             nucDescMap.set(spec.Name, temp);
//           }
//           nucDescription = recData.specDescription;
//           NimageURLNew = recData.specImageUrlNew;
//           NspecPIMId = recData.specCurrentPIMId;
//           NisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         }

//       // If Spec values are not present - Create only Spec Object and populate with spec data
//       } else {
//         // Setting isOnlySpec boolean as true for further processing in method
//         isOnlySpec = true;
//         // Calling Generic method and getting all details
//         const recData = createSpecInstance(spec, nucDescription, NimageURLNew, NspecPIMId, NisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//         nucObjectMapByName.set(spec.Name, recData.specTechObject);
//         nucParentProductURLMapByName.set(spec.Name, recData.specParentProductUrl);
//         nucDescription = recData.specDescription;
//         NimageURLNew = recData.specImageUrlNew;
//         NspecPIMId = recData.specCurrentPIMId;
//         NisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         if (spec.PMP_Specification_Id__r) {
//           nucObjectMapByName.delete(spec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name);
//         }
//       }

//     /* User Story:    US849478
//     * Added by:    Deepanshu - ONYX
//     * Description: The purpose for this code is to display PAC FPGA as a part of Included Intel Technologies.
//     */
//     //Checking the parent by using a method to fetch the custom labels
//     } else if (spec.PMP_Ancestor_Specification_Cd__c !== undefined
//       && spec.PMP_Ancestor_Specification_Cd__c.includes(PMP_NPP_Intel_FPGA_Platforms)) {
//       // Variables for internal use
//       let isSpecNotPresent = false;
//       let isSpecPresent = false;
//       let isOnlySpec = false;
//       const specsList = [];

//       // Enter only if specification value is selected
//       if (spec.PMP_Specification_Value_Cd__c !== undefined) {
//         // If the Spec Tech Map doesn't have specification Name - from hereon referred to as "isSpecNotPresent"
//         if (!pacObjectMapByName.has(spec.Name)) {
//           // Setting isSpecNotPresent boolean as true for further processing in method
//           isSpecNotPresent = true;
//           // Calling Generic method and getting all details
//           const recData = createSpecInstance(spec, pacDescription, pacImageURLNew, pacSpecPIMId, pacIsSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//           if (recData.specDescObject !== undefined) {
//             pacObjectMapByName.set(spec.Name, recData.specTechObject);
//             specsList.push(recData.specDescObject);
//             pacDescMap.set(spec.Name, specsList);
//           }
//           pacDescription = recData.specDescription;
//           pacImageURLNew = recData.specImageUrlNew;
//           pacSpecPIMId = recData.specCurrentPIMId;
//           pacIsSpecValueRecord=recData.isCurrentSpecValueRecord;

//         // If Spec Tech map has specification name
//         } else {
//           // Setting Condition2 boolean as true for further processing in method
//           isSpecPresent = true;
//           // Calling Generic method and getting all details
//           const recData = createSpecInstance(spec, pacDescription, pacImageURLNew, pacSpecPIMId, pacIsSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//           if (recData.specDescObject !== undefined) {
//             pacObjectMapByName.set(recData.specTechName, recData.specTechObject);
//             let temp = [];
//             if ((pacDescMap.get(spec.Name) !== undefined)) {
//               temp = pacDescMap.get(spec.Name);
//             }
//             temp.push(recData.specDescObject);
//             pacDescMap.set(spec.Name, temp);
//           }
//           pacDescription = recData.specDescription;
//           pacImageURLNew = recData.specImageUrlNew;
//           pacSpecPIMId = recData.specCurrentPIMId;
//           pacIsSpecValueRecord=recData.isCurrentSpecValueRecord;
//         }

//       // If Spec values are not present - Create only Spec Object and populate with spec data
//       } else {
//         // Setting isOnlySpec boolean as true for further processing in method
//         isOnlySpec = true;
//         // Calling Generic method and getting all details
//         const recData = createSpecInstance(spec, pacDescription, pacImageURLNew, pacSpecPIMId, pacIsSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//         pacObjectMapByName.set(spec.Name, recData.specTechObject);
//         pacParentProductURLMapByName.set(spec.Name, recData.specParentProductUrl);
//         pacDescription = recData.specDescription;
//         pacImageURLNew = recData.specImageUrlNew;
//         pacSpecPIMId = recData.specCurrentPIMId;
//         pacIsSpecValueRecord=recData.isCurrentSpecValueRecord;
//         if (spec.PMP_Specification_Id__r) {
//           pacObjectMapByName.delete(spec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name);
//         }
//       }

//     /* User Story:  US611446
//     * Added by:    Deepanshu - ONYX
//     * Description: The purpose for this code is to display Intel Technologies as a part of Included Intel Technologies through new optimized code.
//     */
//     // Checking the parent by using a method to fetch the custom labels
//     } else if (spec.PMP_Ancestor_Specification_Cd__c !== undefined
//       && spec.PMP_Ancestor_Specification_Cd__c.includes(PMP_NPP_IntelTechnologies)) {
//       // Variables for internal use
//       let isSpecNotPresent = false;
//       let isSpecPresent = false;
//       let isOnlySpec = false;
//       const specsList = [];

//       // Enter only if specification value is selected
//       if (spec.PMP_Specification_Value_Cd__c !== undefined) {
//         // If the Spec Tech Map doesn't have specification Name - from hereon referred to as "isSpecNotPresent"
//         if (!intelTechObjectMapByName.has(spec.Name)) {
//           // Setting isSpecNotPresent boolean as true for further processing in method
//           isSpecNotPresent = true;
//           // Calling Generic method and getting all details
//           const recData = createSpecInstance(spec, intelTechDescription, IimageURLNew, IspecPIMId, IisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//           if (recData.specDescObject !== undefined) {
//             intelTechObjectMapByName.set(spec.Name, recData.specTechObject);
//             specsList.push(recData.specDescObject);
//             intelTechDescMap.set(spec.Name, specsList);
//           }
//           intelTechDescription = recData.specDescription;
//           IimageURLNew = recData.specImageUrlNew;
//           IspecPIMId = recData.specCurrentPIMId;
//           IisSpecValueRecord=recData.isCurrentSpecValueRecord;

//         // If Spec Tech map has specification name
//         } else {
//           // Setting Condition2 boolean as true for further processing in method
//           isSpecPresent = true;
//           // Calling Generic method and getting all details
//           const recData = createSpecInstance(spec, intelTechDescription, IimageURLNew, IspecPIMId, IisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//           if (recData.specDescObject !== undefined) {
//             intelTechObjectMapByName.set(recData.specTechName, recData.specTechObject);
//             let temp = [];
//             if ((intelTechDescMap.get(spec.Name) !== undefined)) {
//               temp = intelTechDescMap.get(spec.Name);
//             }
//             temp.push(recData.specDescObject);
//             intelTechDescMap.set(spec.Name, temp);
//           }
//           intelTechDescription = recData.specDescription;
//           IimageURLNew = recData.specImageUrlNew;
//           IspecPIMId = recData.specCurrentPIMId;
//           IisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         }

//       // If Spec values are not present - Create only Spec Object and populate with spec data
//       } else {
//         // Setting isOnlySpec boolean as true for further processing in method
//         isOnlySpec = true;
//         // Calling Generic method and getting all details
//         const recData = createSpecInstance(spec, intelTechDescription, IimageURLNew, IspecPIMId, IisSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec);
//         intelTechObjectMapByName.set(spec.Name, recData.specTechObject);
//         intelTechParentProductURLMapByName.set(spec.Name, recData.specParentProductUrl);
//         intelTechDescription = recData.specDescription;
//         IimageURLNew = recData.specImageUrlNew;
//         IspecPIMId = recData.specCurrentPIMId;
//         IisSpecValueRecord=recData.isCurrentSpecValueRecord;
//         if (spec.PMP_Specification_Id__r) {
//           intelTechObjectMapByName.delete(spec.PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.Name);
//         }
//       }
//     }
//   });

//   for (const specTitle of processorObjectMapByName.keys()) {
//     product.includedIntelTechnologies.push({
//       specTitle,
//       specTitleUrl: processorParentProductURLMapByName.get(specTitle),
//       specValues: processorDescMap.get(specTitle),
//       specImageUrl: processorObjectMapByName.get(specTitle).imageUrl,
//     });
//   }

//   for (const specTitle of graphicsObjectMapByName.keys()) {
//     product.includedIntelTechnologies.push({
//       specTitle,
//       specTitleUrl: graphicsParentProductURLMapByName.get(specTitle),
//       specValues: graphicsDescMap.get(specTitle),
//       specImageUrl: graphicsObjectMapByName.get(specTitle).imageUrl,
//     });
//   }

//   for (const specTitle of chipsetObjectMapByName.keys()) {
//     product.includedIntelTechnologies.push({
//       specTitle,
//       specTitleUrl: chipsetParentProductURLMapByName.get(specTitle),
//       specValues: chipsetDescMap.get(specTitle),
//       specImageUrl: chipsetObjectMapByName.get(specTitle).imageUrl,
//     });
//   }

//   for (const specTitle of fpgaObjectMapByName.keys()) {
//     product.includedIntelTechnologies.push({
//       specTitle,
//       specTitleUrl: fpgaParentProductURLMapByName.get(specTitle),
//       specValues: fpgaDescMap.get(specTitle),
//       specImageUrl: fpgaObjectMapByName.get(specTitle).imageUrl,
//     });
//   }

//   for (const specTitle of nucObjectMapByName.keys()) {
//     product.includedIntelTechnologies.push({
//       specTitle,
//       specTitleUrl: nucParentProductURLMapByName.get(specTitle),
//       specValues: nucDescMap.get(specTitle),
//       specImageUrl: nucObjectMapByName.get(specTitle).imageUrl,
//     });
//   }

//   for (const specTitle of pacObjectMapByName.keys()) {
//     product.includedIntelTechnologies.push({
//       specTitle,
//       specTitleUrl: pacParentProductURLMapByName.get(specTitle),
//       specValues: pacDescMap.get(specTitle),
//       specImageUrl: pacObjectMapByName.get(specTitle).imageUrl,
//     });
//   }

//   for (const specTitle of intelTechObjectMapByName.keys()) {
//     product.includedIntelTechnologies.push({
//       specTitle,
//       specTitleUrl: intelTechParentProductURLMapByName.get(specTitle),
//       specValues: intelTechDescMap.get(specTitle),
//       specImageUrl: intelTechObjectMapByName.get(specTitle).imageUrl,
//     });
//   }

//   for (const reg of regionById.values()) {
//     /*if parent of current region is present in the map,push it to the child list*/
//     if (regionChildById.has(reg.PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c)) {
//       regionChildById.get(reg.PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c).push(reg);
//     }
//   }

//   for (const regionId of regionChildById.keys()) { // iterating over region child map
//     let regionValues = '';
//     if (regionChildById.get(regionId).length === 0) { //fetch only those regions which are at leaf node(based on selection)
//       const region = regionById.get(regionId); // fetch the region record from regionById map
//       const ancesCat = region.PMP_Ancestor_Specification_Cd__c.split('|');
//       if (ancesCat.length > 1) { // if the region have parent then append parent with ':'
//         for (let ancesIdx = 1; ancesIdx < ancesCat.length; ancesIdx += 1) { // iterate over all it's parent and append them
//           const parent = regionById.get(ancesCat[ancesIdx]); // fetch the parent record from the regionById map
//           if (parent) { // if the parent record is there append the name
//             regionValues += `${parent.Name} : `;
//           }
//         }
//       }
//       regionValues += region.Name; // append the region's name
//     }
//     if (regionValues) { // if region values are present,push them to the regions list
//       product.regions.push({ value: regionValues });
//     }
//   }
//   if(countries){//if countries are selected,iterate over all the countries and append region and sub-region with it
//     for(const country of countries){//iterating over all the selected countries
//         let regionValues = '';
//         let ancesCat = country.PMP_Ancestor_Specification_Cd__c.split('|');//splitting the ancestor to get all the parents
//         if(ancesCat.length > 1){
//             for(const ances of ancesCat){
//                 let parent=regionById.get(ances);//fetch the parent record from the regionById map
//                 if(parent){//if the parent record is there append the name
//                     regionValues +=parent.Name+' : ';
//                 }
//             }
//         }
//         //appending region + sub-region + country
//         regionValues = regionValues + country.PMP_Specification_Nm__c + ' : ' + country.PMP_Specification_Value_Cd__c;
//         if(regionValues){//if region value is not empty, push it to the product regions list
//             product.regions.push({value: regionValues});
//         }
//     }
//   }

//   return product;
// }

// /** needs doc
//  *
//  * @param {*} specification need
//  * @param {*} recDescription need
//  * @param {*} recImageUrlNew need
//  * @param {*} recPreviousPIMId need
//  * @param {*} recIsPreviousSpecValueRecord need
//  * @param {*} isSpecNotPresent need
//  * @param {*} isSpecPresent need
//  * @param {*} isOnlySpec need (appears unused)
//  * @returns {*} not sure
//  */

// function createSpecInstance(specification, recDescription, recImageUrlNew, recPreviousPIMId, recIsPreviousSpecValueRecord, isSpecNotPresent, isSpecPresent, isOnlySpec) {
//   // Intermediate Variables for processing

//   /* eslint-disable no-unused-vars */
//   const isOnly = isOnlySpec; // appears to be unused

//   let specDescription = '';
//   let specImageUrlNew = '';
//   let specCurrentPIMId = '';
//   let specParentProductUrl = '';
//   let isCurrentSpecValueRecord = false;

//   specCurrentPIMId=specification.PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c;
//   // creating object variable for recieved spec
//   const spec = {};

//   // Creating Spec description object for storing Product URLs
//   //  if (isSpecNotPresent === true || isSpecPresent === true) {
//   const specDescriptionObj = {};
//   //  }

//   if (isSpecPresent === true) {
//     // Assigning specification value in string - spec description
//     specDescription = `${recDescription}<br/>${specification.PMP_Specification_Value_Cd__c}`;
//     // Assigning the same string to- spec description object
//     specDescriptionObj.description = specification.PMP_Specification_Value_Cd__c;
//   } else if (isSpecNotPresent === true) {
//     // Assign Spec description specification value to string
//     specDescription = specification.PMP_Specification_Value_Cd__c;
//     // Assigning the same Spec description to Spec description object & spec object
//     specDescriptionObj.description = specDescription;
//   } else {
//     specDescription = specification.Name;
//   }
//   spec.description = specDescription;

//   if (specification.PMP_Specification_Value_Id__r) {

//     isCurrentSpecValueRecord=true;

//     // Populating Image URL in Spec Object
//     if (specification.PMP_Specification_Value_Id__r.PMP_Image_URL__c) {
//       spec.imageUrl = specification.PMP_Specification_Value_Id__r.PMP_Image_URL__c;
//       specImageUrlNew = specification.PMP_Specification_Value_Id__r.PMP_Image_URL__c;
//     }

//     // Populating Product URL  in Spec Object
//     if (specification.PMP_Specification_Value_Id__r.PMP_Product_URL__c) {
//       spec.productUrl = specification.PMP_Specification_Value_Id__r.PMP_Product_URL__c;
//       specDescriptionObj.productURL = specification.PMP_Specification_Value_Id__r.PMP_Product_URL__c;
//     }

//   // This condition is executed when no spec value is selected
//   } else {
//     // Image URL
//     if (specification.PMP_Specification_Id__r.PMP_Image_url__c) {
//       spec.imageUrl = specification.PMP_Specification_Id__r.PMP_Image_url__c;
//       specImageUrlNew = specification.PMP_Specification_Id__r.PMP_Image_url__c;
//     }
//     // Product URL
//     if (specification.PMP_Specification_Id__r.PMP_Product_url__c) {
//       specParentProductUrl = specification.PMP_Specification_Id__r.PMP_Product_url__c;
//     }
//   }
//   // if previous image URL is having value and current spec is parent, then assign the previous image URL to the Spec
//   if(recImageUrlNew!==undefined && recImageUrlNew!=='' && specCurrentPIMId===recPreviousPIMId && isCurrentSpecValueRecord!==recIsPreviousSpecValueRecord && isCurrentSpecValueRecord===false)
//   {
//     if (specification.PMP_Ancestor_Specification_Cd__c.includes(PMP_NPP_IntelTechnologies)) {
//       spec.imageUrl = PMP_IntelTechImageURL;
//     }
//     else{
//       spec.imageUrl = recImageUrlNew;
//       specImageUrlNew = spec.imageUrl;
//     }
//   }
//   // if image URL is undefined and belongs to same Intel Product then assign the previous image URL to the Spec
//   if (spec.imageUrl === undefined && specCurrentPIMId===recPreviousPIMId ) {
//       spec.imageUrl = recImageUrlNew;
//       specImageUrlNew = spec.imageUrl;
//   }
//  // if image URL is undefined and belongs to Intel Technologies Product then assign the default image URL to the Spec
//   if(spec.imageUrl === undefined && specification.PMP_Ancestor_Specification_Cd__c.includes(PMP_NPP_IntelTechnologies)) {
//       spec.imageUrl = PMP_IntelTechImageURL;
//       specImageUrlNew = spec.imageUrl;
//   }

//   return {
//     isOnly,
//     specTechName: specification.Name,
//     specTechObject: spec,
//     specDescName: specification.Name,
//     specDescObject: specDescriptionObj,
//     specDescription,
//     specImageUrlNew,
//     specCurrentPIMId,
//     isCurrentSpecValueRecord,
//     specParentProductUrl,
//   };
// }

 export default class specifications extends LightningElement{}