import { LightningElement, api } from 'lwc';
// import {
//   getResources,
//   getResourceManagerOptions,
// } from 'c/ipaOfferingResourceService';

// import headingLabel from '@salesforce/label/c.PMP_Manage_Resources_Heading';
// import loadingLabel from '@salesforce/label/c.PMP_Loading';
// import manageResourcesLabel from '@salesforce/label/c.PMP_Manage_Resources';
// import noResourcesLabel from '@salesforce/label/c.PMP_Manage_Resources_None';

// import downloadLabel from '@salesforce/label/c.PMP_Download';
// import fileLabel from '@salesforce/label/c.PMP_File';
// import resourceTypeLabel from '@salesforce/label/c.PMP_Resource_Type';

// /**
//  * This component is to manage Offering Resources and is used
//  * in the Offering Creation wizard
//  *
//  * It is a wrapper for the display component (ipaOfferingResource)
//  * and the create/update modal (ipaOfferingResourceModal)
//  *
//  * @augments LightningElement
//  * @property {string} recordId id for offering
//  */
class IpaOfferingResourceManager extends LightningElement {}
//   /**
//    * custom labels used in template
//    *
//    * @type {object}
//    * @private
//    */
//   labels = {
//     download: downloadLabel,
//     file: fileLabel,
//     heading: headingLabel,
//     loading: loadingLabel,
//     manageResources: manageResourcesLabel,
//     noResources: noResourcesLabel,
//     resourceType: resourceTypeLabel,
//   };

//   @api recordId;

//   /**
//    * keeps track of a loading state
//    *
//    * @type {boolean}
//    * @private
//    */
//   loading = false;

//   /**
//    * keeps track of resource objects
//    * these are fetched via the ipaOfferingResourceService
//    *
//    * @type {object[]}
//    * @private
//    */
//   resources = [];

//   /**
//    * resource type options
//    * used in modal for dropdown, and in label for list
//    *
//    * @type {object[]}
//    * @private
//    */
//   resourceTypeOptions = [];

//   /** shows if resources have loaded and list is empty
//    *
//    * @returns {boolean} show "You have no resources"
//    */
//   get showNoResourcesText() {
//     return !this.loading && !this.resources.length;
//   }

//   /**
//    * determines if the video resource type has an image or thumbnailUrl and url
//    *
//    * @returns {string} image path
//    */
//   get videoTypeInfo() {
//     return (this.videoType?.image || this.videoType?.thumbnailUrl) && !this.url;
//   }

//   /**
//    * checks resourceType value for video
//    *
//    * @returns {boolean} is or is not video resource type
//    */
//   get isVideo() {
//     return this.resourceType === 'video';
//   }

//   /**
//    * connected callback
//    */
//   connectedCallback() {
//     getResourceManagerOptions().then((options) => {
//       this.resourceTypeOptions = [...options];
//       this.setResourceValues();
//     });
//     this.resetData();
//   }

//   /**
//    * load data
//    */
//   resetData() {
//     this.loading = true;
//     this.fetchData().then(() => {
//       this.loading = false;
//     });
//   }

//   /**
//    * fetch resources
//    *
//    * @returns {Promise} promise
//    */
//   async fetchData() {
//     this.resources = await getResources(this.recordId) || [];
//     this.setResourceValues();
//   }

//   /**
//    * sets label values for resource type based on options
//    */
//   setResourceValues() {
//     if (this.resourceTypeOptions.length && this.resources.length) {
//       this.readyResources = this.resources.map((resource) => {
//         // to get label, first look for a match in the resource options
//         // otherwise just use the resource type
//         const matchingOption = this.resourceTypeOptions.find((opt) => opt.value === resource.resourceType);
//         const label = matchingOption ? matchingOption.label : resource.resourceType;
//         return {
//           ...resource,
//           resourceTypeLabel: label,
//         };
//       });
//     }
//   }

//   /**
//    * handle button click
//    *
//    * @param {event} evt initiate modal open
//    */
//   handleButtonClick(evt) {
//     this.template.querySelector('c-ipa-offering-resource-modal').open(evt);
//   }

//   /**
//    * handle save event
//    *
//    */
//   handleSave() {
//     this.resetData();
//   }
// }

// export default IpaOfferingResourceManager;