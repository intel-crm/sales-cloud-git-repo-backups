// /* eslint-disable */
// import PMP_Category from '@salesforce/label/c.PMP_Category';
// import PMP_Processors from '@salesforce/label/c.PMP_Processors';
// import PMP_chipsets from '@salesforce/label/c.PMP_chipsets';
// import PMP_FPGA from '@salesforce/label/c.PMP_FPGA';
// import PMP_Intel_Technologies from '@salesforce/label/c.PMP_Intel_Technologies';
// import PMP_Industry from '@salesforce/label/c.PMP_Industry';
// import PMP_application from '@salesforce/label/c.PMP_application';
// import PMP_Availability_and_Pricing from '@salesforce/label/c.PMP_Availability_and_Pricing';
// import PMP_Geo_Coverage from '@salesforce/label/c.PMP_Geo_Coverage';
// import PMP_End_Customer_Type from '@salesforce/label/c.PMP_End_Customer_Type';
// import PMP_Operating_Systems from '@salesforce/label/c.PMP_Operating_Systems';
// import PMP_Devices_and_Interfaces from '@salesforce/label/c.PMP_Devices_and_Interfaces';
// import PMP_Displays from '@salesforce/label/c.PMP_Displays';
// import PMP_Environment from '@salesforce/label/c.PMP_Environment';
// import PMP_Battery from '@salesforce/label/c.PMP_Battery';
// import PMP_Dimensions from '@salesforce/label/c.PMP_Dimensions';
// import PMP_Memory from '@salesforce/label/c.PMP_Memory';
// import PMP_Storage from '@salesforce/label/c.PMP_Storage';
// import PMP_Wireless from '@salesforce/label/c.PMP_Wireless';
// import PMP_Cloud_Services from '@salesforce/label/c.PMP_Cloud_Services';
// import PMP_NUC from '@salesforce/label/c.PMP_NUC';
// import PMP_Expertise from '@salesforce/label/c.PMP_Expertise';
// import PMP_Industry_Standards from '@salesforce/label/c.PMP_Industry_Standards';
// import PMP_IP_Certification from '@salesforce/label/c.PMP_IP_Certification';
// import PMP_IP_License from '@salesforce/label/c.PMP_IP_License';

// /** Industry and Application exclude list */
// import PMP_NPP_01_Industry from '@salesforce/label/c.PMP_NPP_01_Industry';
// import PMP_NPP_01_APP from '@salesforce/label/c.PMP_NPP_01_APP';
// import PMP_NPP_01_TYPE from '@salesforce/label/c.PMP_NPP_01_TYPE';

// import PMP_DevicesandInterfacesLevel1 from '@salesforce/label/c.PMP_DevicesandInterfacesLevel1';
// import PMP_NPP_Processors from '@salesforce/label/c.PMP_NPP_Processors';
// import PMP_NPP_Wireless from '@salesforce/label/c.PMP_NPP_Wireless';

// import PMP_NPP_OperationSystems from '@salesforce/label/c.PMP_NPP_OperationSystems';
// import PMP_NPP_IntelTechnologies from '@salesforce/label/c.PMP_NPP_IntelTechnologies';


// // Availability and Pricing
// import PMP_AvailabilityandPricing from '@salesforce/label/c.PMP_AvailabilityandPricing';
// import PMP_NPP_EndCustomerType from '@salesforce/label/c.PMP_NPP_EndCustomerType';

// import PMP_DisplaysLevel1 from '@salesforce/label/c.PMP_DisplaysLevel1';

// // Operation Systems

// // EnvironmentLevel
// import PMP_EnvironmentLevel1 from '@salesforce/label/c.PMP_EnvironmentLevel1';

// import PMP_BatteryLevel1 from '@salesforce/label/c.PMP_BatteryLevel1';
// import PMP_DimensionsLevel1 from '@salesforce/label/c.PMP_DimensionsLevel1';
// import PMP_StorageLevel1 from '@salesforce/label/c.PMP_StorageLevel1';

// // cloud
// import PMP_NPP_Cloud_Services from '@salesforce/label/c.PMP_NPP_Cloud_Services';
// // chipset
// import PMP_NPP_Chipsets from '@salesforce/label/c.PMP_NPP_Chipsets';
// import PMP_NPP_FPGA from '@salesforce/label/c.PMP_NPP_FPGA';
// import PMP_NPP_NUC from '@salesforce/label/c.PMP_NPP_NUC';

// // sections
// import PMP_Create_Offering_Form_STEP2 from '@salesforce/label/c.PMP_Create_Offering_Form_STEP2';
// import PMP_Market_Info from '@salesforce/label/c.PMP_Market_Info';
// import PMP_Technical_Specs from '@salesforce/label/c.PMP_Technical_Specs';


// import fetchOfferingDetails from '@salesforce/apex/PMP_OfferingDetailsController.fetchOfferingDetails';

// import lang from '@salesforce/i18n/lang'; 
// import { handleError } from 'c/ipaErrorServiceMarketplace';


// // https://salesforce.stackexchange.com/questions/311440/lwc-locale-does-not-match-apex-version
// const langCode = lang.replaceAll('-', '_');

// /**
//  * Fetch Data
//  *
//  * @param {object[]} compareTrayItems compare tray items
//  * @returns {Promise} formatted compare data
//  */
// export default async function getdata(compareTrayItems) {
//   const offeringIds = compareTrayItems.map((item) => item.id);
//   const params = {
//     offeringIds,
//     bEditOffering: false,
//     bViewOffering: true,
//     bCompareOffering: true,
//     langCode,
//   };

//   try {
//     const response = await Promise.all([
//       fetchOfferingDetails({ ...params, isPartnerDetails: true }),
//       fetchOfferingDetails({ ...params, isPartnerDetails: false }),
//     ]);
//     const tableData = handleMultipleOfferingDetailChange(
//       compareTrayItems, response[0], response[1],
//     );
//     return tableData;
//   } catch (err) {
//     handleError(err, 'ipaCompareProducts - fetchData', 'console');
//   }
//   return [];
// }

// /**
//  * Logic copied from MarketplaceCompareProducts controller 'handlemultipleOfferingDetailsChange'
//  *
//  * @param {object[]} compareTrayItems compare tray items
//  * @param {object} multipleOfferingDetails offering detail object
//  * @param {object} multiplePartnerDetails partner detail object
//  * @returns {object} formatted compare data
//  */
// function handleMultipleOfferingDetailChange(
//   compareTrayItems, multiplePartnerDetails, multipleOfferingDetails,
// ) {
//   let userLocale = langCode;
//   let offeringIds = [];
//   let productsToCompare = [];

//   const labels = [PMP_Category, PMP_Processors, PMP_chipsets, PMP_FPGA, PMP_Intel_Technologies, PMP_Industry,
//     PMP_application, PMP_Availability_and_Pricing,
//     PMP_Geo_Coverage, PMP_End_Customer_Type, PMP_Operating_Systems,
//     PMP_Devices_and_Interfaces,
//     PMP_Displays, PMP_Environment, PMP_Battery,
//     PMP_Dimensions, PMP_Memory, PMP_Storage,
//     PMP_Wireless, PMP_Cloud_Services, PMP_NUC,
//     PMP_Expertise, PMP_Industry_Standards, PMP_IP_Certification, PMP_IP_License,
//   ];

//   let sections = [];
//   const industryColumField = new Set();
//   const applicationColumField = new Set();
//   const availPriceColumField = new Set();
//   const geoDetailsColumField = new Set();
//   const essentialColumField = new Set();
//   const processorColumField = new Set();
//   const processorSocketedColumnField = new Set();
//   const chipsetColumField = new Set();
//   const fpgaColumField = new Set();
//   const techColumField = new Set();
//   const EndCustomerColumField = new Set();
//   const displayColumField = new Set();
//   const deviceColumField = new Set();
//   const environmentColumField = new Set();
//   const osColumField = new Set();
//   const batteryColumnField = new Set();
//   const dimensionColumnField = new Set();
//   const memoryColumnField = new Set();
//   const storageColumnField = new Set();
//   const wirelessColumnField = new Set();
//   const cloudColumnField = new Set();
//   const nucColumField = new Set(); // Added by Abhishek for Nuc US
//   const expertiseColumnField = new Set();// Added for Expertise[PSG]
//   const industryStandColumnField = new Set();// Added for Industry Standard Certificate
//   const ipCertificateColumnField = new Set();// Added for IP Certificate
//   const ipLicenseColumnField = new Set();// Added for IP License Delivery

//   const industryProductsToCompare = [];
//   const applicationProductsToCompare = [];
//   const availPriceProductsToCompare = [];
//   const geoDetailProductsToCompare = [];
//   const EndProductsToCompare = [];
//   const essentialProductsToCompare = [];
//   const processorProductsToCompare = [];
//   const processorSocketedProductsToCompare = [];
//   const chipsetProductsToCompare = [];
//   const fpgaProductsToCompare = [];
//   const techProductsToCompare = [];
//   const customerProductsToCompare = [];
//   const displayProductsToCompare = [];
//   const deviceProductsToCompare = [];
//   const osProductsToCompare = [];
//   const batteryProductsToCompare = [];
//   const dimensionProductsToCompare = [];
//   const memoryProductsToCompare = [];
//   const storageProductsToCompare = [];
//   const wirelessProductsToCompare = [];
//   const cloudProductsToCompare = [];
//   const nucProductsToCompare = []; // Added by Abhishek for Nuc US.
//   const expertiseProductsToCompare = [];// Added for Expertise[PSG]
//   const industryStandsToCompare = [];// Added for Industry Standards
//   const ipCertificateToCompare = [];// Added for IP Certification
//   const ipLicenseToCompare = [];// Added for IP License Delivery
//   /* Added by raj as part of defect fix(DE98862) */
//   const categoryById = new Map();
//   const categoryChildById = new Map();

//   // logged-In or Guest users language code (if changed via language selector) - Gireesh(US664733)

//   if (userLocale != null || userLocale !== undefined) {
//     userLocale = userLocale.toLowerCase();
//   }




//   // If multipleOfferingDetails has elements then perform the below operations
//   if (Object.keys(multipleOfferingDetails) && Object.keys(multipleOfferingDetails).length > 0) {
//     /* for (var prodIndex = 0; prodIndex < compareTrayItems.length; prodIndex++) {
//         var productsToCompareObj = new Object();
//         productsToCompareObj.Id = compareTrayItems[prodIndex].id;
//         productsToCompareObj.Name = compareTrayItems[prodIndex].title;
//         productsToCompareObj.logo = compareTrayItems[prodIndex].imageUrl;

//         //adding all Ids to the list
//         offeringIds.push(compareTrayItems[prodIndex].id);
//         productsToCompare.push(productsToCompareObj);

//     }  */
//     offeringIds = compareTrayItems.map((obj) => obj.id);
//     productsToCompare = compareTrayItems.map((obj) => ({
//       Id: obj.id,
//       Name: obj.title,
//       logo: obj.imageUrl,
//     }));


//     // COMPARE DATA


//     /* End */
//     // Accordion
//     //

//     // creating accordions with empty categories(Header)
//     sections = labels.map((currentItem) => ({
//       label: currentItem,
//       open: false,
//       categories: [],
//     }));

//     let productInfo = [];
//     // Iterate for each Offering Ids
//     for (let prodIndex = 0; prodIndex < compareTrayItems.length; prodIndex++) {
//       // Get the Offering Details
//       let offeringDetails = [];

//       if (multipleOfferingDetails.offerings[compareTrayItems[prodIndex].id] !== undefined && JSON.parse(multipleOfferingDetails.offerings[compareTrayItems[prodIndex].id]).objectData !== undefined) offeringDetails = JSON.parse(multipleOfferingDetails.offerings[compareTrayItems[prodIndex].id]).objectData;

//       // Gireesh:US664733
//       if (userLocale == null || userLocale === undefined && offeringDetails.userLocale != null && offeringDetails.userLocale !== undefined) {
//         userLocale = (offeringDetails.userLocale).toLowerCase();
//       }
//       const industryProducts = {};
//       const applicationProducts = {};
//       const typeProducts = {};
//       const availPriceProducts = {};
//       const geoDetailProducts = {};
//       const EndProducts = {};
//       const essentialProducts = {};
//       const processorProducts = {};
//       const processorSocketedProducts = {};
//       const chipsetProducts = {};
//       const fpgaProducts = {};
//       const techProducts = {};
//       const environmentProducts = {};
//       const displayProducts = {};
//       const deviceProducts = {};
//       const osProducts = {};
//       const batteryProducts = {};
//       const dimensionProducts = {};
//       const memoryProducts = {};
//       const storageProducts = {};
//       const wirelessProducts = {};
//       const cloudProducts = {};
//       const nucProducts = {}; // Added By Abhishek for NUC
//       const expertiseProducts = {};// Added for Expertise[PSG]
//       const insdustryStandProd = {};// Added for Industry Standard Certificate
//       const ipCertificateProd = {};// Added for IP Certificate
//       const ipLicenseProd = {};// Added for IP License Deliver

//       const excludeList = [];
//       const excludeHeaderList = [];
//       const includeHeaderList = new Set();
//       const processorHasChildList = new Set();
//       const tempExcludeList = [];
//       const processorExcludeList = [];
//       const processorExcludeTempList = [];
//       const osstring = '';
//       const osProdSpec = '';
//       const osValues = [];
//       let enValues = [];
//       const wirelessstring = '';
//       const wirelesprodspec = '';
//       let displaystring = '';
//       let displayprodspec = '';
//       let memorystring = '';
//       let memoryprodspec = '';
//       const devicestring = '';
//       const deviceprodspec = '';
//       let enString = '';
//       let envProdSpec = '';
//       let storageString = '';
//       let storageprodspec = '';
//       const repeat = '';
//       let expertiseSpec = '';// Added for Expertise[PSG]
//       let expertiseValues = [];// Added for Expertise[PSG]
//       let expertise = '';// Added for Expertise[PSG]
//       const catMap = new Map();
//       const catChildListMap = new Map();
//       const catChildList = [];
//       const systemHeaders = [];
//       const nodesVisited = [];
//       const regionById = new Map();
//       const regionChildById = new Map();
//       const countries = []; // added by raj to display countries with region, as part of spike story

//       const showContactPartner = !!offeringDetails.showContactPartner;

//       // Iterate Categories
//       if (offeringDetails.selectedCategories && offeringDetails.selectedCategories.length > 0) {
//         for (let catIndex = 0; catIndex < offeringDetails.selectedCategories.length; catIndex++) {
//           // For System, get only top nodes under system
//           if (offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r !== undefined
//                    && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c !== undefined
//                    && (offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c === 'IPA_TYPE_Sys')) {
//             systemHeaders.push(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c);
//           }


//           // Industry and Application exclude list
//           if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c !== undefined
//                     && ((offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).includes(PMP_NPP_01_Industry)
//                      || (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).includes(PMP_NPP_01_APP)
//                      || (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).includes(PMP_NPP_01_TYPE)
//                     )
//           ) {
//             for (let inrIndex = 0; inrIndex < offeringDetails.selectedCategories.length; inrIndex++) {
//               if (offeringDetails.selectedCategories[inrIndex].PMP_Ancestor_Category_Cd__c !== undefined) {
//                 // Exclude header nodes if child exist
//                 if (offeringDetails.selectedCategories[inrIndex].PMP_Ancestor_Category_Cd__c.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c)) {
//                   excludeHeaderList.push(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c);
//                 }
//                 // Exclude intermediate nodes but with ancestor length greater than 2
//                 const innerAncestorKeys = (offeringDetails.selectedCategories[inrIndex].PMP_Ancestor_Category_Cd__c).split('|');
//                 // add intermediate nodes into exclude list
//                 if (innerAncestorKeys.length > 2) {
//                   for (let kLen = 2; kLen < innerAncestorKeys.length; kLen++) {
//                     if (!excludeList.includes(innerAncestorKeys[kLen])) excludeList.push(innerAncestorKeys[kLen]);
//                   }
//                 }
//               }
//             }
//           }

//           // Industry
//           // Filter all industry data excluding labels
//           if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c !== undefined && (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).includes(PMP_NPP_01_Industry)) {
//             const ancestorKeys = (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).split('|');
//             let directParent = '';
//             // Get the direct of the current Category whose ancestor category length greater than 2
//             if (ancestorKeys.length > 2 && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r !== undefined
//                        && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r !== undefined) {
//               directParent = offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.Name;
//               if (userLocale === 'zh_cn' && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Chinese_Nm__c !== undefined) directParent = offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Chinese_Nm__c;
//               else if (userLocale === 'ja' && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Japanese_Nm__c !== undefined) directParent = offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Japanese_Nm__c;
//             }
//             // For all the child nodes of HEADER, concatenate with direct parent
//             if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c !== PMP_NPP_01_Industry) {
//               // Header PIM category is created as key, so 2nd element is picked from the ancestor PIM cartegory  (PMP_Ancestor_Category_Cd__c)
//               // If the Key already exist append the value, otherwise add the key and value
//               if (industryProducts[ancestorKeys[1]] && !excludeList.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c)) {
//                 let prevString = industryProducts[ancestorKeys[1]];
//                 if (directParent.length > 0) prevString = `${prevString + ((prevString.length > 0) ? '<br/>' : '') + directParent} : ${offeringDetails.selectedCategories[catIndex].Name}`;
//                 else prevString = prevString + ((prevString.length > 0) ? '<br/>' : '') + offeringDetails.selectedCategories[catIndex].Name;
//                 industryProducts[ancestorKeys[1]] = prevString;
//               } else if (!excludeList.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c)) {
//                 if (directParent.length > 0) industryProducts[ancestorKeys[1]] = `${directParent} : ${offeringDetails.selectedCategories[catIndex].Name}`;
//                 else industryProducts[ancestorKeys[1]] = offeringDetails.selectedCategories[catIndex].Name;
//               }
//             }

//             // Header PIM category is created as key(PMP_Offering_Category_External_Key__c)
//             else if (!excludeHeaderList.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c)) {
//               if (industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c]) {
//                 let prevString = industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c];
//                 prevString = `${prevString}<br/>${offeringDetails.selectedCategories[catIndex].Name}`;
//                 industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c] = prevString;
//               } else {
//                 industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c] = offeringDetails.selectedCategories[catIndex].Name;
//               }
//             }

//             // Creating the Header nodes, Categories which are direct decendants of NPP_01_Industry will become the Header node
//             if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c !== undefined && (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c === PMP_NPP_01_Industry)) {
//               const industryNameValue = new Object();
//               industryNameValue[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c] = offeringDetails.selectedCategories[catIndex].Name;
//               Object.assign(industryColumField, industryNameValue);
//             }
//           }
//           // application
//           // Filter all Application data excluding labels
//           else if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c !== undefined && (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).includes(PMP_NPP_01_APP)) {
//             const ancestorKeys = (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).split('|');
//             let directParent = '';
//             // Get the direct of the current Category whose ancestor category length greater than 2
//             if (ancestorKeys.length > 2 && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r !== undefined
//                        && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r !== undefined) {
//               directParent = offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.Name;
//               if (userLocale === 'zh_cn' && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Chinese_Nm__c !== undefined) directParent = offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Chinese_Nm__c;
//               else if (userLocale === 'ja' && offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Japanese_Nm__c !== undefined) directParent = offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Category_Japanese_Nm__c;
//             }
//             // For all the child nodes of HEADER, concatenate with direct parent
//             if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c !== PMP_NPP_01_APP) {
//               // Header PIM category is created as key, so 2nd element is picked from the ancestor PIM cartegory  (PMP_Ancestor_Category_Cd__c)
//               // If the Key already exist append the value, otherwise add the key and value
//               if (applicationProducts[ancestorKeys[1]] && !excludeList.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c)) {
//                 let prevString = applicationProducts[ancestorKeys[1]];
//                 if (directParent.length > 0) prevString = `${prevString}<br/>${directParent} : ${offeringDetails.selectedCategories[catIndex].Name}`;
//                 else prevString = `${prevString}<br/>${offeringDetails.selectedCategories[catIndex].Name}`;
//                 applicationProducts[ancestorKeys[1]] = prevString;
//               } else if (!excludeList.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c)) {
//                 if (directParent.length > 0) applicationProducts[ancestorKeys[1]] = `${directParent} : ${offeringDetails.selectedCategories[catIndex].Name}`;
//                 else applicationProducts[ancestorKeys[1]] = offeringDetails.selectedCategories[catIndex].Name;
//               }
//             }
//             // Header PIM category is created as key(PMP_Offering_Category_External_Key__c)
//             else if (!excludeHeaderList.includes(offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c)) {
//               if (industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c]) {
//                 let prevString = industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c];
//                 prevString = prevString + ((prevString.length > 0) ? '<br/>' : '') + offeringDetails.selectedCategories[catIndex].Name;
//                 industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c] = prevString;
//               } else {
//                 industryProducts[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c] = offeringDetails.selectedCategories[catIndex].Name;
//               }
//             }
//             // Creating the Header nodes, Categories which are direct decendants of NPP_01_Industry will become the Header node
//             if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c !== undefined && (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c === PMP_NPP_01_APP)) {
//               const applicationNameValue = new Object();
//               applicationNameValue[offeringDetails.selectedCategories[catIndex].PMP_Offering_Category_External_Key__c] = offeringDetails.selectedCategories[catIndex].Name;
//               Object.assign(applicationColumField, applicationNameValue);
//             }
//           }
//           // new Type
//           else if (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c !== undefined && (offeringDetails.selectedCategories[catIndex].PMP_Ancestor_Category_Cd__c).includes(PMP_NPP_01_TYPE)) {
//             /* Added as part of defect fix (DE98862) */
//             const catList = [];// to store category's child
//             // map<categoryId,categoryObject>,contains categoryId and it's object record
//             categoryById.set(offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c, offeringDetails.selectedCategories[catIndex]);
//             // map<categoryId,List<categoryObject>>,contains categoryId and list of child related to it(Default 0)
//             categoryChildById.set(offeringDetails.selectedCategories[catIndex].PMP_Category_Id__r.PMP_Partner_Product_Category_Cd__c, catList);
//             /* End */
//           }
//           // newType end
//         }
//       }
//       /* Added as part of defect fix (DE98862) */
//       for (const cat of offeringDetails.selectedCategories) {
//         if (cat.PMP_Ancestor_Category_Cd__c) {
//           if (cat.PMP_Ancestor_Category_Cd__c.includes(PMP_NPP_01_TYPE) && categoryChildById.has(cat.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c)) {
//             categoryChildById.get(cat.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c).push(cat);
//           }
//         }
//       }
//       if (categoryChildById) {
//         for (const itr of categoryChildById.keys()) {
//           let productCategories = '';
//           if (categoryChildById.get(itr).length === 0) {
//             // getting only the child nodes which were selected
//             const cat = categoryById.get(itr);
//             const ancesCat = cat.PMP_Ancestor_Category_Cd__c.split('|');
//             const typeNameValue = new Object();
//             const gParent = categoryById.get(ancesCat[1]);
//             typeNameValue[gParent.PMP_Offering_Category_External_Key__c] = gParent.Name;
//             Object.assign(essentialColumField, typeNameValue);
//             if (ancesCat.length > 2) {
//               // appending all parent except for the ultimate parent
//               for (let ancesIdx = 2; ancesIdx < ancesCat.length; ancesIdx++) {
//                 const parent = categoryById.get(ancesCat[ancesIdx]);
//                 if (parent) {
//                   productCategories += `${parent.Name} : `;
//                 }
//               }
//             }
//             productCategories += cat.Name;
//             typeProducts[gParent.PMP_Offering_Category_External_Key__c] = productCategories;
//           }
//         }
//       }
//       /* End */
//       // Specifications
//       if (offeringDetails.selectedSpecifications && offeringDetails.selectedSpecifications.length > 0) {
//         for (let specIndex = 0; specIndex < offeringDetails.selectedSpecifications.length; specIndex++) {
//           // Include List Start
//           {
//             // Include  SpecId List for PMP_DevicesandInterfacesLevel1 Specification
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined
//                         && (
//                           (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes(PMP_DevicesandInterfacesLevel1)
//                          || (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes(PMP_NPP_Processors)
//                          || (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes(PMP_NPP_Wireless)
//                             || (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes(PMP_NPP_OperationSystems)
//                             || (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes(PMP_NPP_IntelTechnologies)
//                         )
//             ) {
//               for (let inrIndex = 0; inrIndex < offeringDetails.selectedSpecifications.length; inrIndex++) {
//                 if (offeringDetails.selectedSpecifications[inrIndex].PMP_Ancestor_Specification_Cd__c !== undefined
//                                 && offeringDetails.selectedSpecifications[inrIndex].PMP_Specification_Value_Cd__c !== undefined
//                                 && (offeringDetails.selectedSpecifications[inrIndex].PMP_Ancestor_Specification_Cd__c).includes(offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c)

//                 ) {
//                   // Include nodes if child exist
//                   includeHeaderList.add(offeringDetails.selectedSpecifications[inrIndex].PMP_Product_Specification_Cd__c);
                  
//                   let keys = [];
//                   if (offeringDetails.selectedSpecifications[inrIndex].PMP_Ancestor_Specification_Cd__c !== undefined) keys = offeringDetails.selectedSpecifications[inrIndex].PMP_Ancestor_Specification_Cd__c.split('|');

//                   if (keys.length > 1) {
//                     includeHeaderList.add(keys[keys.length - 1]);
//                     processorHasChildList.add(keys[keys.length - 1]);
//                   }
//                 }
//               }
//             }
//           }
//           // Include List End

//           // Availability and Pricing PMP_AvailabilityandPricing PMP_AvailabilityandPricing
//           if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined && offeringDetails.selectedSpecifications && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes(PMP_AvailabilityandPricing)) {
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c === PMP_AvailabilityandPricing) {
//               availPriceProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//             }

//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c === 'NPP_AvailabilityAndPricing_CPP') {
//               availPriceProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = 'Y';
//             }

//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined && offeringDetails.selectedSpecifications && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c === PMP_AvailabilityandPricing)) {
//               const availPriceNameValue = new Object();
//               availPriceNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//               Object.assign(availPriceColumField, availPriceNameValue);
//             }
//           }
//           // Geo Details New
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined
//                         && offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c.includes('NPP_GeographicCoverage')
//           ) {
//             const subRegions = [];// to store sub regions
//             // storing the region records by product specification Id
//             regionById.set(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c, offeringDetails.selectedSpecifications[specIndex]);
//             // setting child list of the region to empty(default 0)
//             regionChildById.set(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c, subRegions);
//             // Added by raj as part of spike story
//             /* if(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined){//storing all the selected countries in a list
//                       countries.push(offeringDetails.selectedSpecifications[specIndex]);
//                     } */
//           }


//           // End Customer Type
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined && offeringDetails.selectedSpecifications && (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c) === PMP_NPP_EndCustomerType) {
//             EndProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = 'Y';
//             const endCustomerNameValue = new Object();
//             endCustomerNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//             Object.assign(EndCustomerColumField, endCustomerNameValue);
//           }


//           // Devices & Interfaces start-Gireesh

//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined
//            && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes(PMP_DevicesandInterfacesLevel1)) {
//             const keys = offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c.split('|');
//             // one which includes children
//             if (includeHeaderList.has(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)) {
//               // for ones having ancestor length ==1
//               if (keys.length === 1 && offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                 let prevStr = deviceProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
//                 if (prevStr === undefined) prevStr = '';
//                 deviceProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = prevStr + ((prevStr.length > 0) ? '<br/>' : '')
//               + offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//               }
//               // for ones having ancestor length>1
//               else if (keys.length > 1 && offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                 let prevString = '';
//                 if (keys[keys.length - 1]) {
//                   prevString = deviceProducts[keys[keys.length - 1]];
//                   if (prevString === undefined) prevString = '';
//                   deviceProducts[keys[keys.length - 1]] = `${prevString + ((prevString.length > 0) ? '<br/>' : '') + offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c}:${
//                     offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//                 } else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined
//                 && offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c !== undefined) {
//                   deviceProducts[keys[keys.length - 1]] = `${offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c}:${
//                     offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//                 }
//               }
//             }
//             // one which has no child
//             else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c !== undefined) { deviceProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c; }
//             // Only Header Nodes
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined && offeringDetails.selectedSpecifications && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c === PMP_DevicesandInterfacesLevel1)) {
//               const deviceNameValue = new Object();
//               deviceNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//               Object.assign(deviceColumField, deviceNameValue);
//             }
//           }

//           // Devices & Interfaces  End



//           // Displays
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes(PMP_DisplaysLevel1)) {
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined && displayprodspec.includes(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)) {
//               displaystring = `${displaystring}<br/>${offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//             } else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//               displayprodspec = offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c;
//               displaystring = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//             }
//             displayProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = displaystring;
//             const displayNameValue = new Object();
//             displayNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//             Object.assign(displayColumField, displayNameValue);
//           }
//           // Operation Systems

//           // OS
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes(PMP_NPP_OperationSystems)) {
//             let bCheckParentValue = false;
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== PMP_NPP_OperationSystems) {
//               const keys = (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).split('|');
//               let directParent = '';
//               // if the ancestor length is greater than 2, then find the 'Name' of the direct parent
//               for (let index = 0; index < offeringDetails.selectedSpecifications.length; index++) {
//                 if (keys.length > 2) {
//                   if (offeringDetails.selectedSpecifications[index].PMP_Product_Specification_Cd__c === keys[keys.length - 1]) {
//                     directParent = offeringDetails.selectedSpecifications[index].Name;
//                     break;
//                   }
//                 }
//                 if (offeringDetails.selectedSpecifications[index].PMP_Specification_Value_Cd__c !== undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes(PMP_NPP_OperationSystems)) {
//                   tempExcludeList.push(offeringDetails.selectedSpecifications[index].Name);
//                 }
//               }

//               if (osProducts[keys[1]]) {
//                 let prevString = osProducts[keys[1]];
//                 if (directParent.length > 0) {
//                   if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c === undefined && !tempExcludeList.includes(offeringDetails.selectedSpecifications[specIndex].Name)) {
//                     prevString = `${prevString}<br/>${directParent} : ${offeringDetails.selectedSpecifications[specIndex].Name}`;
//                     bCheckParentValue = true;
//                   } else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                     prevString = `${prevString}<br/> <b>${offeringDetails.selectedSpecifications[specIndex].Name}</b> : ${offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//                     bCheckParentValue = true;
//                   }
//                 } else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c === undefined && !tempExcludeList.includes(offeringDetails.selectedSpecifications[specIndex].Name)) {
//                   prevString = `${prevString}<br/>${offeringDetails.selectedSpecifications[specIndex].Name}`;
//                   bCheckParentValue = true;
//                 } else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                   prevString = `${prevString}<br/> <b>${offeringDetails.selectedSpecifications[specIndex].Name}</b> : ${offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//                   bCheckParentValue = true;
//                 }
//                 osProducts[keys[1]] = prevString;
//               } else if (directParent.length > 0) {
//                 osProducts[keys[1]] = `${directParent} : ${offeringDetails.selectedSpecifications[specIndex].Name}`;
//                 bCheckParentValue = true;
//               } else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c === undefined && !tempExcludeList.includes(offeringDetails.selectedSpecifications[specIndex].Name)) {
//                 osProducts[keys[1]] = offeringDetails.selectedSpecifications[specIndex].Name;
//                 bCheckParentValue = true;
//               } else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                 osProducts[keys[1]] = `<b>${offeringDetails.selectedSpecifications[specIndex].Name}</b> : ${offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//                 bCheckParentValue = true;
//               }
//             } else if (osProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]) {
//               let prevString = osProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
//               prevString = `${prevString}<br/>${offeringDetails.selectedSpecifications[specIndex].Name}`;
//               osProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = prevString;
//               bCheckParentValue = true;
//             } else {
            
//               if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                 osProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//               } else if (!processorHasChildList.has(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)) osProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//             }

//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c === PMP_NPP_OperationSystems)) {
//               const osNameValue = new Object();
//               if (osNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] !== undefined) {
//                 osNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//               } else {
//                 osNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//               }

//               Object.assign(osColumField, osNameValue);
//             }
//           }
//           // Environment
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined && offeringDetails.selectedSpecifications && offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c === PMP_EnvironmentLevel1) {
//             if (envProdSpec.includes(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)) {
//               if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c) {
//                 enValues.push(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c);
//               } else {
//                 enValues.push(offeringDetails.selectedSpecifications[specIndex].Name);
//               }
//             } else {
//               envProdSpec = offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c;
//               enValues = [];
//               if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c) {
//                 enValues.push(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c);
//               } else {
//                 enValues.push(offeringDetails.selectedSpecifications[specIndex].Name);
//               }
//             }
//             if (enValues.length > 1 && enValues.includes(offeringDetails.selectedSpecifications[specIndex].Name)) {
//               let index = -1;
//               index = enValues.indexOf(offeringDetails.selectedSpecifications[specIndex].Name);
//               if (index > -1) {
//                 enValues.splice(index, 1);
//               }
//             }
//             enString = enValues.join('<br/> ');
//             environmentProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = enString;
//             const enNameValue = new Object();
//             enNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//             Object.assign(environmentColumField, enNameValue);
//           }
//           // Battery
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined && offeringDetails.selectedSpecifications && offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c === PMP_BatteryLevel1) // PMP_BatteryLevel1 PMP_DimensionsLevel1 PMP_Memory
//           {
//             batteryProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//             const batteryNameValue = new Object();
//             batteryNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//             Object.assign(batteryColumnField, batteryNameValue);
//           }
//           // Dimensions
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined && offeringDetails.selectedSpecifications && offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c === PMP_DimensionsLevel1) {
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) dimensionProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//             const dimesionNameValue = new Object();
//             dimesionNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//             Object.assign(dimensionColumnField, dimesionNameValue);
//           }
//           // Memory
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined && offeringDetails.selectedSpecifications && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c.includes(PMP_Memory)) {
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined && memoryprodspec.includes(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)) {
//               memorystring = `${memorystring}<br/>${offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//             } else {
//               memoryprodspec = offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c;
//               if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c) {
//                 memorystring = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//               } else {
//                 memorystring = offeringDetails.selectedSpecifications[specIndex].Name;
//               }
//             }

//             memoryProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = memorystring;
//             const memoryNameValue = new Object();
//             memoryNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//             Object.assign(memoryColumnField, memoryNameValue);
//           }
//           // Storage
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined && offeringDetails.selectedSpecifications && offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c === PMP_StorageLevel1) {
//             if (storageprodspec.includes(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)) storageString = `${storageString}<br/>${offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//             else {
//               storageprodspec = offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c;
//               if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c) {
//                 storageString = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//               } else {
//                 storageString = offeringDetails.selectedSpecifications[specIndex].Name;
//               }
//             }
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c) {
//               storageProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//             } else {
//               storageProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//             }
//             const storageNameValue = new Object();
//             storageNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//             Object.assign(storageColumnField, storageNameValue);
//           }


//           // Wireless start-Gireesh
//           else if ((offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined
//                   && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c === PMP_NPP_Wireless))
//                  || offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c === PMP_NPP_Wireless
//           ) {
//             // Selectables directly under Wireless

//             {
//               if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined
//                    && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined
//                    && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c === PMP_NPP_Wireless) {
//                 wirelessProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//               }
//             }

//             let keys = [];
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined) keys = offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c.split('|');
//             // one which includes children
//             if (includeHeaderList.has(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)) {
//               // for ones having ancestor length ==1
//               if (keys.length === 1 && offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                 let prevStr = wirelessProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
//                 if (prevStr === undefined)	prevStr = '';
//                 wirelessProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = prevStr + ((prevStr.length > 0) ? '<br/>' : '')
//                     + offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//               }
//               // for ones having ancestor length>1
//               else if (keys.length > 1 && offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                 let prevString = '';
//                 if (keys[keys.length - 1]) {
//                   prevString = wirelessProducts[keys[keys.length - 1]];
//                   if (prevString === undefined) prevString = '';
//                   if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c !== undefined) {
//                     wirelessProducts[keys[keys.length - 1]] = `${prevString + ((prevString.length > 0) ? '<br/>' : '') + offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c}:${
//                       offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//                   }
//                 } else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c !== undefined) {
//                   wirelessProducts[keys[keys.length - 1]] = `${offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c}:${
//                     offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//                 }
//               }
//             }
//             // one which has no child
//             else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c !== undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined) {
//               wirelessProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c;
//             }
//             // Only Header Nodes
//             const wirelessNameValue = new Object();
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined
//                 && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined
//                 && offeringDetails.selectedSpecifications[specIndex].Name !== undefined
//                 && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c === PMP_NPP_Wireless)
//             ) {
//               wirelessNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//               Object.assign(wirelessColumnField, wirelessNameValue);
//             }
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined
//                  && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined
//                  && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c === PMP_NPP_Wireless
//             ) {
//               wirelessNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//               Object.assign(wirelessColumnField, wirelessNameValue);
//             }
//           }
//           // Wireless end


//           // Cloud
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined && offeringDetails.selectedSpecifications && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c === PMP_NPP_Cloud_Services) {
//             cloudProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = 'Y';
//             const cloudNameValue = new Object();
//             cloudNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//             Object.assign(cloudColumnField, cloudNameValue);
//           }

//           // processors
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined
//                   && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes(PMP_NPP_Processors)
//                  && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== 'NPP_Processors_ProcessorSocketed'
//           ) {
//             let bCheckParentValue = false;
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== PMP_NPP_Processors) {
//               const keys = (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).split('|');
              
//               let directParent = '';
//               // duplicateSpecCheck = duplicateSpecCheck + offeringDetails.selectedSpecifications[k].Name;
//               // if the ancestor length is greater than 2, then find the 'Name' of the direct parent
//               for (let index = 0; index < offeringDetails.selectedSpecifications.length; index++) {
//                 if (keys.length > 2) {
//                   if (offeringDetails.selectedSpecifications[index].PMP_Product_Specification_Cd__c === keys[keys.length - 1]) {
//                     directParent = offeringDetails.selectedSpecifications[index].Name;
//                     break;
//                   }
//                 }
//                 if (offeringDetails.selectedSpecifications[index].PMP_Specification_Value_Cd__c !== undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes(PMP_NPP_Processors)) {
//                   tempExcludeList.push(offeringDetails.selectedSpecifications[index].Name);
//                 }
//               }

//               if (processorProducts[keys[1]]) {
//                 let prevString = processorProducts[keys[1]];
//                 if (directParent.length > 0) {
//                   if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c === undefined && !tempExcludeList.includes(offeringDetails.selectedSpecifications[specIndex].Name)) {
//                     prevString = `${prevString}<br/>${directParent} : ${offeringDetails.selectedSpecifications[specIndex].Name}`;
//                     bCheckParentValue = true;
//                   } else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                     prevString = `${prevString}<br/> <b>${offeringDetails.selectedSpecifications[specIndex].Name}</b> : ${offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//                     bCheckParentValue = true;
//                   }
//                 } else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c === undefined && !tempExcludeList.includes(offeringDetails.selectedSpecifications[specIndex].Name)) {
//                   prevString = `${prevString}<br/>${offeringDetails.selectedSpecifications[specIndex].Name}`;
//                   bCheckParentValue = true;
//                 } else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                   prevString = `${prevString}<br/> <b>${offeringDetails.selectedSpecifications[specIndex].Name}</b> : ${offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//                   bCheckParentValue = true;
//                 }
//                 processorProducts[keys[1]] = prevString;
//               } else if (directParent.length > 0) {
//                 processorProducts[keys[1]] = `${directParent} : ${offeringDetails.selectedSpecifications[specIndex].Name}`;
//                 bCheckParentValue = true;
//               } else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c === undefined && !tempExcludeList.includes(offeringDetails.selectedSpecifications[specIndex].Name)) {
//                 processorProducts[keys[1]] = offeringDetails.selectedSpecifications[specIndex].Name;
//                 bCheckParentValue = true;
//               } else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                 processorProducts[keys[1]] = `<b>${offeringDetails.selectedSpecifications[specIndex].Name}</b> : ${offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//                 bCheckParentValue = true;
//               }
//             } else if (processorProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]) {
//               let prevString = processorProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
//               prevString = `${prevString}<br/>${offeringDetails.selectedSpecifications[specIndex].Name}`;
//               processorProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = prevString;
//               bCheckParentValue = true;
//             } else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//               processorProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//             } else if (!processorHasChildList.has(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)) processorProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;

//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c === PMP_NPP_Processors)) {
//               const processorNameValue = new Object();
//               if (processorNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] !== undefined) {
//                 processorNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//               } else {
//                 processorNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//               }

//               Object.assign(processorColumField, processorNameValue);
//             }
//           }
//           // Processor Socketed
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined
//                     && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c === 'NPP_Processors_ProcessorSocketed'
//           ) {
//             processorSocketedProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = 'Y';
//             const processorSocketedNameValue = new Object();
//             processorSocketedNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//             Object.assign(processorSocketedColumnField, processorSocketedNameValue);
//           }
//           // Chipset
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes(PMP_NPP_Chipsets)) {
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== PMP_NPP_Chipsets) {
//               if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                 if (chipsetProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]) {
//                   if (chipsetProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] === offeringDetails.selectedSpecifications[specIndex].Name) {
//                     chipsetProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                   } else {
//                     const prevString = chipsetProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
//                     chipsetProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = `${prevString}<br/>${offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//                   }
//                 } else {
//                   chipsetProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                 }
//               } else {
//                 chipsetProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//               }
//             }
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== PMP_NPP_Chipsets)) {
//               const chipsetNameValue = new Object();

//               if (chipsetNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] !== undefined) {
//                 chipsetNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//               } else {
//                 chipsetNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//               }
//               Object.assign(chipsetColumField, chipsetNameValue);
//             }
//           }
//           // FPGA
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes(PMP_NPP_FPGA)) {
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== PMP_NPP_FPGA) {
//               if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                 if (fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]) {
//                   if (fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] === offeringDetails.selectedSpecifications[specIndex].Name) {
//                     fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                   } else {
//                     const prevString = fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
//                     fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = `${prevString}, <br/>${offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//                   }
//                 } else {
//                   fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                 }
//               } else {
//                 fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Partner_Product_Specification_Id__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//               }
//             } else {
//               fpgaProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//             }
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c === PMP_NPP_FPGA)) {
//               const fpgaNameValue = new Object();
//               if (fpgaNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] !== undefined) {
//                 fpgaNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//               } else {
//                 fpgaNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//               }
//               Object.assign(fpgaColumField, fpgaNameValue);
//             }
//           }
//           // Nuc
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined
//                                          && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes(PMP_NPP_NUC)) {
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c != PMP_NPP_NUC) {
//               if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                 if (nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]) {
//                   if (nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] == offeringDetails.selectedSpecifications[specIndex].Name) {
//                     nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                   } else {
//                     const prevString = nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
//                     nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = `${prevString}<br/>${offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//                   }
//                 } else {
//                   nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//                 }
//               } else if (!nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c]) {
//                 nucProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//               }
//             }

//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined
//                                           && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== PMP_NPP_NUC)) {
//               const nucNameValue = new Object();
//               if (nucNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] !== undefined) {
//                 nucNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//               } else {
//                 nucNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//               }

//               Object.assign(nucColumField, nucNameValue);
//             }
//           }
//           // Intel Tech

//           else if ((offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined
//                && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c === PMP_NPP_IntelTechnologies))
//               || offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c === PMP_NPP_IntelTechnologies) {
//             // Selectables directly under Wireless
            

//             {
//               if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined
//               && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined
//               && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c === PMP_NPP_IntelTechnologies) {
//                 techProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
                
//               }
//             }

//             let keys = [];
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined) keys = offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c.split('|');
//             // one which includes children
//             if (includeHeaderList.has(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)) {
//               // for ones having ancestor length ==1
//               if (keys.length === 1 && offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                 let prevStr = techProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c];
//                 if (prevStr === undefined)	prevStr = '';
//                 techProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = prevStr + ((prevStr.length > 0) ? '<br/>' : '')
//                  + offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
                
//               }
//               // for ones having ancestor length>1
//               else if (keys.length > 1 && offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined) {
//                 let prevString = '';
//                 if (keys[keys.length - 1]) {
//                   prevString = techProducts[keys[keys.length - 1]];
//                   if (prevString === undefined) prevString = '';
//                   if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c !== undefined) {
//                     techProducts[keys[keys.length - 1]] = `${prevString + ((prevString.length > 0) ? '<br/>' : '') + offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c}:${
//                       offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//                   }
                  
//                 } else {
//                   if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c !== undefined) {
//                     techProducts[keys[keys.length - 1]] = `${offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c}:${
//                       offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c}`;
//                   }
//                 }
//               }
//             }
//             // one which has no child
//             else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c !== undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined) {
//               techProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Nm__c;
              
//             }
//             // Only Header Nodes

//             const techsNameValue = new Object();
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined
//              && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined
//              && offeringDetails.selectedSpecifications[specIndex].Name !== undefined
//              && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c === PMP_NPP_IntelTechnologies)
//             ) {
//               techsNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//               Object.assign(techColumField, techsNameValue);
//             }
//             if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined
//             && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined
//             && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c === PMP_NPP_IntelTechnologies) {
//               techsNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//               Object.assign(techColumField, techsNameValue);
//             }
//           }
//           // Expertise[PSG]
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c !== undefined && (offeringDetails.selectedSpecifications[specIndex].PMP_Ancestor_Specification_Cd__c).includes('ExpertiseLevel1')) {
//             if (expertiseSpec.includes(offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c)) {
//               if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c) {
//                 expertiseValues.push(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c);
//               } else {
//                 expertiseValues.push(offeringDetails.selectedSpecifications[specIndex].Name);
//               }
//             } else {
//               expertiseSpec = offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c;
//               expertiseValues = [];
//               if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c) {
//                 expertiseValues.push(offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c);
//               } else {
//                 expertiseValues.push(offeringDetails.selectedSpecifications[specIndex].Name);
//               }
//             }
//             if (expertiseValues.length > 1 && expertiseValues.includes(offeringDetails.selectedSpecifications[specIndex].Name)) {
//               let index = -1;
//               index = expertiseValues.indexOf(offeringDetails.selectedSpecifications[specIndex].Name);
//               if (index > -1) {
//                 expertiseValues.splice(index, 1);
//               }
//             }
//             expertise = expertiseValues.join('<br/> ');
//             expertiseProducts[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = expertise;
//             const expertiseNameValue = new Object();
//             expertiseNameValue[offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c] = offeringDetails.selectedSpecifications[specIndex].Name;
//             Object.assign(expertiseColumnField, expertiseNameValue);
//           }
//           // Industry Standards/Certifications
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined && offeringDetails.selectedSpecifications && (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c) === 'NPP_Industry_Standards_Certifications') {
//             insdustryStandProd[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = 'Y';
//             const industryStandName = new Object();
//             industryStandName[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//             Object.assign(industryStandColumnField, industryStandName);
//           }
//           // IP License Delivery
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined && offeringDetails.selectedSpecifications && (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c) === 'NPP_IP_License_Delivery_Method') {
//             ipLicenseProd[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = 'Y';
//             const ipLicenseName = new Object();
//             ipLicenseName[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//             Object.assign(ipLicenseColumnField, ipLicenseName);
//           }
//           // IP Certification
//           else if (offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c !== undefined && offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c !== undefined && offeringDetails.selectedSpecifications && (offeringDetails.selectedSpecifications[specIndex].PMP_Product_Specification_Cd__c) === 'NPP_IP_Certification') {
//             ipCertificateProd[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = 'Y';
//             const ipCertificateName = new Object();
//             ipCertificateName[offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c] = offeringDetails.selectedSpecifications[specIndex].PMP_Specification_Value_Cd__c;
//             Object.assign(ipCertificateColumnField, ipCertificateName);
//           }
//         }
//       }

//       // Geographic Coverage-Gireesh
//       for (const region of regionById.values()) {
//         /* if parent of current region is present in the map,push it to the child list */
//         if (regionChildById.has(region.PMP_Product_Specification_Cd__c)) {
//           regionChildById.get(region.PMP_Product_Specification_Cd__c).push(region);
//         }
//       }
//       if (regionChildById) { // if region child map is not empty or null
//         for (const regionId of regionChildById.keys()) { // iterating over region child map
//           let regionValues = '';
//           let parent = '';
//           if (regionChildById.get(regionId).length === 1) { // fetch only those regions which are at leaf node(based on selection)
//             const region = regionById.get(regionId);// fetch the region record from regionById map
//             const ancesCat = region.PMP_Ancestor_Specification_Cd__c.split('|');
//             if (ancesCat.length > 1) { // if the region have parent then append parent with ':'
//               for (let ancesIdx = 1; ancesIdx < ancesCat.length; ancesIdx++) { // iterate over all it's parent and append them
//                 parent = regionById.get(ancesCat[ancesIdx]);// fetch the parent record from the regionById map
//                 if (parent) { // if the parent record is there append the name
//                   const geoDetailsNameValue = new Object();
//                   geoDetailsNameValue[parent.PMP_Product_Specification_Cd__c] = parent.Name;
//                   Object.assign(geoDetailsColumField, geoDetailsNameValue);
//                 }
//               }
//             }
//             regionValues += region.Name;// append the region's name
//             if (regionValues !== undefined && parent && parent.PMP_Product_Specification_Cd__c !== undefined && geoDetailProducts[parent.PMP_Product_Specification_Cd__c] !== undefined) geoDetailProducts[parent.PMP_Product_Specification_Cd__c] = `${geoDetailProducts[parent.PMP_Product_Specification_Cd__c]}<br/>${regionValues}`;
//             else if (regionValues && parent && parent.PMP_Product_Specification_Cd__c) geoDetailProducts[parent.PMP_Product_Specification_Cd__c] = regionValues;
//           }
//         }
//       }

//       industryProductsToCompare.push(industryProducts);
//       applicationProductsToCompare.push(applicationProducts);
//       availPriceProductsToCompare.push(availPriceProducts);
//       geoDetailProductsToCompare.push(geoDetailProducts);
//       essentialProductsToCompare.push(typeProducts);
//       processorProductsToCompare.push(processorProducts);
//       processorSocketedProductsToCompare.push(processorSocketedProducts);
//       chipsetProductsToCompare.push(chipsetProducts);
//       fpgaProductsToCompare.push(fpgaProducts);
//       techProductsToCompare.push(techProducts);
//       EndProductsToCompare.push(EndProducts);
//       customerProductsToCompare.push(environmentProducts);
//       displayProductsToCompare.push(displayProducts);
//       deviceProductsToCompare.push(deviceProducts);
//       osProductsToCompare.push(osProducts);
//       batteryProductsToCompare.push(batteryProducts);
//       dimensionProductsToCompare.push(dimensionProducts);
//       memoryProductsToCompare.push(memoryProducts);
//       storageProductsToCompare.push(storageProducts);
//       wirelessProductsToCompare.push(wirelessProducts);
//       cloudProductsToCompare.push(cloudProducts);
//       nucProductsToCompare.push(nucProducts); // Added by Abhishek Nuc
//       expertiseProductsToCompare.push(expertiseProducts);// Added for Expertise[PSG]
//       industryStandsToCompare.push(insdustryStandProd);// Added for industry products
//       ipLicenseToCompare.push(ipLicenseProd);// Added for ip License
//       ipCertificateToCompare.push(ipCertificateProd);// Added for ip Certificate
//     }

//     // looping sections to add to columns
//     for (let secIndex = 0; secIndex < sections.length; secIndex++) {
//       if (sections[secIndex].label === PMP_Industry) {
//         for (const key in industryColumField) {
//           if ({}.hasOwnProperty.call(industryColumField, key)) {
//             const category = new Object();
//             category.label = industryColumField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_application) {
//         for (const key in applicationColumField) {
//           if ({}.hasOwnProperty.call(applicationColumField, key)) {
//             const category = new Object();
//             category.label = applicationColumField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_Availability_and_Pricing) {
//         for (const key in availPriceColumField) {
//           if ({}.hasOwnProperty.call(availPriceColumField, key)) {
//             const category = new Object();
//             category.label = availPriceColumField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_Geo_Coverage) {
//         for (const key in geoDetailsColumField) {
//           if ({}.hasOwnProperty.call(geoDetailsColumField, key)) {
//             const category = new Object();
//             category.label = geoDetailsColumField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_End_Customer_Type) {
//         for (const key in EndCustomerColumField) {
//           if ({}.hasOwnProperty.call(EndCustomerColumField, key)) {
//             const category = new Object();
//             category.label = EndCustomerColumField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_Category) {
//         for (const key in essentialColumField) {
//           if ({}.hasOwnProperty.call(essentialColumField, key)) {
//             const category = new Object();
//             category.label = essentialColumField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_Processors) {
//         // Other processors
//         for (const key in processorColumField) {
//           if ({}.hasOwnProperty.call(processorColumField, key)) {
//             const category = new Object();
//             category.label = processorColumField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//         // Processor socketed
//         for (const key in processorSocketedColumnField) {
//           if ({}.hasOwnProperty.call(processorSocketedColumnField, key)) {
//             const category = new Object();
//             category.label = processorSocketedColumnField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_chipsets) {
//         for (const key in chipsetColumField) {
//           if ({}.hasOwnProperty.call(chipsetColumField, key)) {
//             const category = new Object();
//             category.label = chipsetColumField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_FPGA) {
//         for (const key in fpgaColumField) {
//           if ({}.hasOwnProperty.call(fpgaColumField, key)) {
//             const category = new Object();
//             category.label = fpgaColumField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label == PMP_Intel_Technologies) {
//         for (const key in techColumField) {
//           if ({}.hasOwnProperty.call(techColumField, key)) {
//             const category = new Object();
//             category.label = techColumField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_Intel_Technologies) {
//         for (const key in osColumField) {
//           if ({}.hasOwnProperty.call(osColumField, key)) {
//             const category = new Object();
//             category.label = osColumField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_Devices_and_Interfaces) {
//         for (const key in deviceColumField) {
//           if ({}.hasOwnProperty.call(deviceColumField, key)) {
//             const category = new Object();
//             category.label = deviceColumField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_Displays) {
//         for (const key in displayColumField) {
//           if ({}.hasOwnProperty.call(displayColumField, key)) {
//             const category = new Object();
//             category.label = displayColumField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_Environment) {
//         for (const key in environmentColumField) {
//           if ({}.hasOwnProperty.call(environmentColumField, key)) {
//             const category = new Object();
//             category.label = environmentColumField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_Battery) {
//         for (const key in batteryColumnField) {
//           if ({}.hasOwnProperty.call(batteryColumnField, key)) {
//             const category = new Object();
//             category.label = batteryColumnField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_Dimensions) {
//         for (const key in dimensionColumnField) {
//           if ({}.hasOwnProperty.call(dimensionColumnField, key)) {
//             const category = new Object();
//             category.label = dimensionColumnField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_Memory) {
//         for (const key in memoryColumnField) {
//           if ({}.hasOwnProperty.call(memoryColumnField, key)) {
//             const category = new Object();
//             category.label = memoryColumnField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_Storage) {
//         for (const key in storageColumnField) {
//           if ({}.hasOwnProperty.call(storageColumnField, key)) {
//             const category = new Object();
//             category.label = storageColumnField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_Wireless) {
//         for (const key in wirelessColumnField) {
//           if ({}.hasOwnProperty.call(wirelessColumnField, key)) {
//             const category = new Object();
//             category.label = wirelessColumnField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_Cloud_Services) {
//         for (const key in cloudColumnField) {
//           if ({}.hasOwnProperty.call(cloudColumnField, key)) {
//             const category = new Object();
//             category.label = cloudColumnField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === PMP_NUC) { // Added by Abhishek for Nuc
//         for (const key in nucColumField) {
//           if ({}.hasOwnProperty.call(nucColumField, key)) {
//             const category = new Object();
//             category.label = nucColumField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === 'Expertise') { // Added for Expertise[PSG]
//         for (const key in expertiseColumnField) {
//           if ({}.hasOwnProperty.call(expertiseColumnField, key)) {
//             const category = new Object();
//             category.label = expertiseColumnField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === 'Industry Standards/Certifications') { // added for industry standards
//         for (const key in industryStandColumnField) {
//           if ({}.hasOwnProperty.call(industryStandColumnField, key)) {
//             const category = new Object();
//             category.label = industryStandColumnField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === 'IP License Delivery Method') { // added for IP License
//         for (const key in ipLicenseColumnField) {
//           if ({}.hasOwnProperty.call(ipLicenseColumnField, key)) {
//             const category = new Object();
//             category.label = ipLicenseColumnField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       } else if (sections[secIndex].label === 'IP Certification') { // added for IP Certificates
//         for (const key in ipCertificateColumnField) {
//           if ({}.hasOwnProperty.call(ipCertificateColumnField, key)) {
//             const category = new Object();
//             category.label = ipCertificateColumnField[key];
//             category.fieldName = key;
//             sections[secIndex].categories.push(category);
//           }
//         }
//       }
//     }
//     // copy data to productsToCompare so that all values will be displayed
//     for (let itmIndex = 0; itmIndex < compareTrayItems.length; itmIndex++) {
//       Object.assign(productsToCompare[itmIndex], industryProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], applicationProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], availPriceProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], geoDetailProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], EndProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], essentialProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], processorProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], processorSocketedProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], chipsetProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], fpgaProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], techProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], customerProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], displayProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], deviceProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], osProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], batteryProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], dimensionProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], memoryProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], storageProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], wirelessProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], cloudProductsToCompare[itmIndex]);
//       Object.assign(productsToCompare[itmIndex], nucProductsToCompare[itmIndex]); // Added by Abhishek for Nuc US.
//       Object.assign(productsToCompare[itmIndex], expertiseProductsToCompare[itmIndex]);// Added for Expertise[PSG]
//       Object.assign(productsToCompare[itmIndex], industryStandsToCompare[itmIndex]);// Added for indsutry standards
//       Object.assign(productsToCompare[itmIndex], ipLicenseToCompare[itmIndex]);// Added for IP License delivery
//       Object.assign(productsToCompare[itmIndex], ipCertificateToCompare[itmIndex]);// Added for IP Certification
//       // Assign partner information

//       if (multiplePartnerDetails && multiplePartnerDetails.productInfo && multiplePartnerDetails.productInfo[compareTrayItems[itmIndex].id] !== undefined) {
//         productInfo = multiplePartnerDetails.productInfo[compareTrayItems[itmIndex].id][0];
        


//         const partner = new Object();
//         partner.partner = productInfo.partner;
//         Object.assign(productsToCompare[itmIndex], partner);
//         const contactPartnerData = new Object();
//         contactPartnerData.Data = {
//           autoPartnerId: productInfo.partner.autoPartnerId,
//           contactByEmail: false,
//           contactByForm: true,
//           requestAQuote: true,
//           offRecId: productInfo.id,
//           name: productInfo.partner.name,
//           oid: productInfo.autoOffId,
//           title: productInfo.title,
//           id: productInfo.partner.id,
//           description: null,
//           attributes: null,
//           isGuest: productInfo.isGuest,
//           leadLangPreference: productInfo.leadLangPreference,
//           contactPartnerVisible: productInfo.contactPartnerVisible,

//         };
//         Object.assign(productsToCompare[itmIndex], contactPartnerData);
//       }
//     }
//     return compareGroupingSections(sections, productsToCompare);
//   }
// }

// /**
//  * Returns an array of numbers representing the amount of 'add cards' to be displayed
//  *
//  * @param {object[]} productsToCompare products to compare
//  * @param {number} [maxProducts=4] max products
//  * @returns {number[]} filler array 
//  */
// function addBlankSections(productsToCompare, maxProducts = 4) {
//   const maxProductsCount = maxProducts;

//   const productsToAdd = maxProductsCount - productsToCompare.length;
//   const fillerArray = [];
//   for (let i = 0; i < productsToAdd; i++) {
//     fillerArray.push(i);
//   }

//   return fillerArray;
//   // Add Blank Sections to fill up < 4 gap
// }


// /**
//  * Returns compare table data with appropriate sections added as
//  * well as contact partner data
//  *
//  * @param {object[]} sections sections
//  * @param {object[]} productsToCompare products to compare
//  * @returns {object} compare products data
//  */
// function compareGroupingSections(sections, productsToCompare) {
//   const groups = [];
//   const labels = [
//     PMP_Category,
//     PMP_Create_Offering_Form_STEP2,
//     PMP_Market_Info,
//     PMP_Technical_Specs
//   ];

//   const groupingSections = [];

//   // new group section
//   for (var grpSectionsIndex = 0; grpSectionsIndex < labels.length; grpSectionsIndex++) {
//     const groupingSection = new Object();
//     const sectionsFinal = [];

//     if (labels[grpSectionsIndex] == PMP_Category) {
//       groupingSection.groupNames = [PMP_Category];
//       groupingSection.groupLabel = '';
//     } else if (labels[grpSectionsIndex] == PMP_Create_Offering_Form_STEP2) {
//       groupingSection.groupNames = [PMP_Processors, PMP_chipsets, PMP_FPGA,
//         PMP_Intel_Technologies, PMP_NUC];
//       groupingSection.groupLabel = PMP_Create_Offering_Form_STEP2;
//     } else if (labels[grpSectionsIndex] == PMP_Market_Info) {
//       groupingSection.groupNames = [PMP_Industry, PMP_application, PMP_Availability_and_Pricing, PMP_Geo_Coverage];
//       groupingSection.groupLabel = PMP_Market_Info;
//     } else if (labels[grpSectionsIndex] == PMP_Technical_Specs) {
//       groupingSection.groupNames = [PMP_End_Customer_Type, PMP_Operating_Systems, PMP_Displays, PMP_Battery,
//         PMP_Dimensions, PMP_Memory, PMP_Storage,
//         PMP_Wireless, PMP_Devices_and_Interfaces, PMP_Environment,
//         PMP_Cloud_Services,
//         PMP_Expertise, PMP_Industry_Standards,
//         PMP_IP_Certification, PMP_IP_License];
//       groupingSection.groupLabel = PMP_Technical_Specs;
//     }

//     groupingSection.sections = sectionsFinal;
//     groupingSections.push(groupingSection);
//   }


//   // new group section
//   for (let index = 0; index < sections.length; index++) {
//     for (var grpSectionsIndex = 0; grpSectionsIndex < groupingSections.length; grpSectionsIndex++) {
//       if (groupingSections[grpSectionsIndex].groupNames.length > 0 && groupingSections[grpSectionsIndex].groupNames.includes(sections[index].label)) {
//         groupingSections[grpSectionsIndex].sections.push(sections[index]);
//       }
//     }
//   }
//   // new group section end

//   // UI DATA new group section
//   const outputGroupingSections = groupingSections.map((group) => ({
//     sectionLabel: group.groupLabel,
//     children: group.sections.map((section) => Object.assign(section, {
//       data: section.categories.map((cat) => {
//         const values = productsToCompare.map((product) => product[cat.fieldName]);
//         let areDifferent = false;

//         values.reduce((value1, value2) => {
//           if ((value1 || value2) && value1 !== value2) areDifferent = true;
//           return value2;
//         });
//         return {
//           highlight: areDifferent,
//           label: cat.label,
//           info: cat.infoTooltip,
//           data: values,
//         };
//       }),
//     })),
//   }));

//   return {
//     contactPartnerData: productsToCompare.map((product) => product.Data),
//     sections: outputGroupingSections,
//   };
// }