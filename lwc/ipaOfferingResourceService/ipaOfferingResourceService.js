// /**
//  * service component for ipaOfferingResourceManager to get/create/delete/update
//  * the offering resources.
//  * @module ipaOfferingResourceService
//  * @example
//  * import {getResourceManagerOptions} from 'c/ipaOfferingResourceService';
//  */

// /**
//  * 
//  * @typedef OfferingResource
//  * @property {string} id resource id (if no id exists it is a NEW resource)
//  * @property {string} title resource title
//  * @property {string} description resource description
//  * @property {string} url resource url
//  * @property {string} resourceType resource type
//  * @property {string} uploadId uploaded resource id
//  * @property {string} uploadName uploaded resource name
//  * @property {string} fileType uploaded resource file type
//  * @property {string} fileSize uploaded resource file size
//  * 
//  */

// //Importing Apex Back end Methods
// import getOfferingResource from '@salesforce/apex/PMP_OfferingResourceHelper.getResources';
// import saveOfferingResource from '@salesforce/apex/PMP_OfferingResourceHelper.saveResources';
// import deleteOfferingResource from '@salesforce/apex/PMP_OfferingResourceHelper.deleteResources';
// import deleteResourceFiles from '@salesforce/apex/PMP_OfferingResourceHelper.deleteResourcesFiles';
// import getResourceTypes from '@salesforce/apex/PMP_OfferingResourceHelper.getAdditionalResourceTypes';
// import { handleError } from 'c/ipaErrorServiceMarketplace';


// /** get associated Offering Resources 
//  * 
//  * @param {string} offeringId offering Id
//  * @returns {OfferingResource[]} offering resources
//  * @public
//  */
//  export async function getResources(offeringId) {
//   let response;
//   try {
//     response = await getOfferingResource({ offeringId: offeringId });
//   } catch (error) {
//     handleError(error, 'ipaOfferingResourceService - getOfferingResource');
//   }
//   return response;

// }

// /** save data includes new and modified resources
//  * 
//  * @param {string} offeringId offering Id
//  * @param {OfferingResource[]} data to be created/updated (upsert)
//  * @public
//  */
// export async function saveResourceData(offeringId, data) {
//   try {
//     await saveOfferingResource({ offeringId: offeringId, resourceData: data });
//   } catch (error) {
//     handleError(error, 'ipaOfferingResourceService - saveOfferingResource');
//   }
// }

// /** deletes Offering Resources by id
//  * NOTE: this function does not DELETE associated uploaded files
//  * 
//  * @param {string[]} resourceIds ids of resources to delete
//  * @public
//  */
// export async function deleteResources(resourceIds) {
//   try {
//     await deleteOfferingResource({ deleteResourceIds: resourceIds });
//   } catch (error) {
//     handleError(error, 'ipaOfferingResourceService - deleteOfferingResource');
//   }
// }

// /** deleted/overwritten uploads need to be removed
//  * 
//  * @param {string[]} uploadIds ids of uploads to delete
//  * @public
//  */
// export async function deleteUploads(uploadIds, idToUploadIdMap) {
//   try {
//     console.log('uploadIds::: ', uploadIds);
//     await deleteResourceFiles({ deleteFileIds: uploadIds , idToUploadsId: idToUploadIdMap });
//   } catch (error) {
//     handleError(error, 'ipaOfferingResourceService - deleteResourceFiles');
//   }
// }

// /** get options for modal dropdown
//  * @returns {object[]} offering additional resource types
//  * @public
//  */
// export async function getResourceManagerOptions() {
//   let response;
//   try {
//     response = await getResourceTypes();
//   } catch (error) {
//     handleError(error, 'ipaOfferingResourceService - getResourceTypes');
//   }
//   return response;
// }