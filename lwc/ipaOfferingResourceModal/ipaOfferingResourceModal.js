import { LightningElement, api, track } from 'lwc';

// import addLabel from '@salesforce/label/c.PMP_Edit_Storefront_Resources_Add_Btn';
// import cancelLabel from '@salesforce/label/c.Core_PMP_Cancel';
// import deleteLabel from '@salesforce/label/c.Core_PMP_Delete';
// import descriptionLabel from '@salesforce/label/c.PMP_Edit_Storefront_Description_Des_Label';
// import nameRegexLabel from '@salesforce/label/c.PMP_RegexOfferingNamePattern';
// import headingLabel from '@salesforce/label/c.PMP_New_Resources';
// import loadingLabel from '@salesforce/label/c.PMP_Loading';
// import noticeDefaultLabel from '@salesforce/label/c.PMP_Additional_Resources_Top';
// import resourceLabel from '@salesforce/label/c.PMP_Edit_Storefront_Resources_Res';
// import resourceTypeLabel from '@salesforce/label/c.PMP_Edit_Storefront_Resources_Type_Label';
// import resourceTypePlaceholderLabel from '@salesforce/label/c.PMP_Edit_Storefront_Resources_Type_Placeholder';
// import resourceUploadLabel from '@salesforce/label/c.PMP_Offering_Resource_Upload_Help_Text';
// import requiredDropdownLabel from '@salesforce/label/c.PMP_RequiredDropdownField';
// import requiredNoticeLabel from '@salesforce/label/c.PMP_Indicates_Required_Field';
// import saveLabel from '@salesforce/label/c.Core_PMP_Save';
// import titleLabel from '@salesforce/label/c.PMP_Edit_Storefront_Resources_Name_Label';
// import urlInvalidLabel from '@salesforce/label/c.PMP_Invalid_Url_Error';
// import urlRegexLabel from '@salesforce/label/c.PMP_RegexURLPattern';

// import altTextLabel from '@salesforce/label/c.PMP_Edit_Storefront_Alt_Text_Label';
// import altTextHelper from '@salesforce/label/c.PMP_Edit_Storefront_Alt_Text_Helper';
// import altTextPlaceholder from '@salesforce/label/c.PMP_Edit_Storefront_Alt_Text_Placeholder';
// import assetUrlOrUploadHelper from '@salesforce/label/c.PMP_Edit_Storefront_Asset_URL_Or_Upload_Helper';
// import assetDividerText from '@salesforce/label/c.PMP_Edit_Storefront_Asset_Divider';
// import uploadLabel from '@salesforce/label/c.PMP_Edit_Storefront_Upload_Label';
// import videoHelperSize from '@salesforce/label/c.PMP_Edit_Storefront_Upload_Video_Helper_Size';
// import videoHelperFormat from '@salesforce/label/c.PMP_Edit_Storefront_Upload_Video_Helper_Format';
// import videoHelperFile from '@salesforce/label/c.PMP_Edit_Storefront_Upload_Video_Helper_File';
// import urlLabel from '@salesforce/label/c.PMP_Edit_Storefront_Url_Label';
// import deleteFileAlt from '@salesforce/label/c.PMP_Edit_Storefront_Delete_File_Alt';
// import urlOrUploadError from '@salesforce/label/c.PMP_Edit_Storefront_Asset_URL_Or_Upload_Error';
// import urlOrUploadErrorBlank from '@salesforce/label/c.PMP_Edit_Storefront_Asset_URL_Or_Upload_Error_Blank';
// import uploadFileError from '@salesforce/label/c.PMP_Edit_Storefront_Upload_File_Error';

// import errorFileNameSpecialChars from '@salesforce/label/c.PMP_Edit_Storefront_Resources_Error_File_Name_Special_Chars';
// import errorFileSize from '@salesforce/label/c.PMP_Edit_Storefront_Resources_Error_File_Size';
// import errorFileNameLength from '@salesforce/label/c.PMP_Edit_Storefront_Resources_Error_File_Name_Length';

// import okText from '@salesforce/label/c.PMP_Okay';
// import confirmDeleteEntryTitle from '@salesforce/label/c.PMP_Video_Confirm_Delete_Title';
// import confirmDeleteEntryText from '@salesforce/label/c.PMP_Video_Confirm_Delete_Entity';

// import noHTMLLabel from '@salesforce/label/c.PMP_Invalid_Notes';
// import noURLLabel from '@salesforce/label/c.PMP_Invalid_Notes_URL';
// import charsRemainingDescriptionLabelDynamic from '@salesforce/label/c.PMP_Description_Characters_Remaining';
// import maxCharLimitLabel from '@salesforce/label/c.PMP_Maximum_Character_Limit_Msg';

// import ipaVideo from '@salesforce/resourceUrl/IPA_Video';
// import getContentDocSize from '@salesforce/apex/PMP_OfferingResourceHelper.getContentDocSize';

// import { handleError } from 'c/ipaErrorServiceMarketplace';

// import {
//   getResources,
//   saveResourceData,
//   deleteResources,
//   deleteUploads,
// } from 'c/ipaOfferingResourceService';

// /**
//  * @typedef OfferingResource
//  * @property {string} id resource id
//  * @property {string} title resource title
//  * @property {string} [description] resource description
//  * @property {string} url resource url
//  * @property {string} resourceType resource type
//  * @property {string} altText video alt text
//  * @property {string} [uploadId] uploaded resource id
//  * @property {string} [uploadName] uploaded resource name
//  */

// /**
//  * @typedef SelectOption
//  * @property {string} label option label
//  * @property {string} value option value
//  */

// /**
//  * The create/update modal for Offering Resources
//  * Used in the wrapper component ipaOfferingResourceManager
//  * in the create offering wizard
//  *
//  * @augments LightningElement
//  * @property {string} [heading=New Resource] heading override
//  * @property {string} label label at top of modal
//  * @property {number} [maxResourceLimit=20] maximum number of resources (default is 15)
//  * @property {string} recordId id for uploaded resources - required
//  * @property {OfferingResource[]} [resources] initial list of existing resources
//  * @property {SelectOption[]} resourceTypeOptions the available list of resource types (required)
//  * @property {string} [validUploadTypes] valid upload types (comma separated list of extensions)
//  * @property {string} [validUploadVideoTypes] valid upload types (comma separated list of extensions)
//  * @fires save when the resources list is saved
//  */
class IpaOfferingResourceModal extends LightningElement {}
//   static delegatesFocus = true;

//   /**
//    * Max Length of Title input value
//    *
//    * @type {number}
//    * @private
//    */
//   maxTitleLength = 80;

//   /**
//    * Max Length of URL input value
//    *
//    * @type {number}
//    * @private
//    */
//   maxUrlLength = 255;

//   /**
//    * Max length of Description textarea value
//    *
//    * @type {number}
//    * @private
//    */
//   maxDescriptionLength = 255;

//   /**
//    * Max length of Alt Text input value
//    *
//    * @type {number}
//    * @private
//    */
//    maxAltTextLength = 100;

//    /**
//     * Target that opened modal
//     *
//     * @type {object}
//     * @private
//     */
//    modalInitiator;

//   /**
//    * custom labels used in template
//    *
//    * @type {object}
//    * @private
//    */
//   labels = {
//     add: addLabel,
//     altText: altTextLabel,
//     altTextHelp: altTextHelper,
//     altTextPlaceholderText: altTextPlaceholder,
//     assetNotice: assetUrlOrUploadHelper,
//     assetDivider: assetDividerText,
//     cancel: cancelLabel,
//     confirmDelete: confirmDeleteEntryText,
//     confirmDeleteTitle: confirmDeleteEntryTitle,
//     delete: deleteLabel,
//     deleteUploadFileAlt: deleteFileAlt,
//     description: descriptionLabel,
//     heading: headingLabel,
//     loading: loadingLabel,
//     nameRegex: nameRegexLabel,
//     ok: okText,
//     resource: resourceLabel,
//     resourceType: resourceTypeLabel,
//     resourceTypePlaceholder: resourceTypePlaceholderLabel,
//     requiredDropdown: requiredDropdownLabel,
//     requiredNotice: requiredNoticeLabel,
//     save: saveLabel,
//     title: titleLabel,
//     upload: uploadLabel,
//     uploadHelpText: resourceUploadLabel,
//     uploadVideoHelpTextSize: videoHelperSize,
//     uploadVideoHelpText: videoHelperFormat,
//     uploadVideoHelpTextFileName: videoHelperFile,
//     url: urlLabel,
//     urlRegex: urlRegexLabel,
//     urlInvalid: urlInvalidLabel,
//     errors: {
//       noHTML: noHTMLLabel,
//       noURL: noURLLabel,
//       urlOrUpload: urlOrUploadError,
//       urlOrUploadBlank: urlOrUploadErrorBlank,
//       uploadFile: uploadFileError,
//       uploadFileSpecialChars: errorFileNameSpecialChars,
//       uploadFileSize: errorFileSize,
//       uploadFileNameLength: errorFileNameLength,
//     },
//     charLimits: {
//       name: maxCharLimitLabel.replace('{0}', this.maxTitleLength),
//       url: maxCharLimitLabel.replace('{0}', this.maxUrlLength),
//       description: charsRemainingDescriptionLabelDynamic,
//       altText: maxCharLimitLabel.replace('{0}', this.maxAltTextLength),
//     },
//   };

//   @api heading = this.labels.heading;

//   @api label = noticeDefaultLabel;

//   @api maxResourceLimit = 20;

//   @api recordId = '';

//   @api resourceTypeOptions = [];

//   @api validUploadTypes = ['.pdf'].join(', ');

//   @api validUploadVideoTypes = ['.mp4', '.mov', '.avi'].join(',');

//   @api idToUploadIdMap = [];

//   /** opens modal
//    *
//    * @param {event} evt modal initiator
//    * @public
//    */
//   @api open(evt) {
//     this.modalInitiator = evt.currentTarget;
//     this.isOpen = true;
//     this.template.querySelector('c-core-intc-modal').openModal();
//     this.fetchResources();
//   }

//   /**
//    * keeps track of loading state
//    *
//    * @type {boolean}
//    * @private
//    */
//   loading = false;

//   /** keeps track of current form state of resources (DRAFT STATE)
//    *
//    * @type {OfferingResource[]}
//    * @private
//    */
//   @track resources = [];

//   /**
//    * keeps track of initial resources from server (SERVER STATE)
//    * mainly for save disabled button state
//    *
//    * @type {object[]}
//    * @private
//    */
//   _resources = [];
//    /**
//    * keeps copy of initial resources 
//    *
//    * @type {object[]}
//    * @private
//    */
//     copyResources = [];

//   /**
//    * keeps track of Deleted Resources
//    * IF user "Saves" these resources will be deleted via ipaOfferingResourceService
//    * IF user "Cancels" they will not be deleted
//    *
//    * @type {string[]}
//    * @private
//    */
//   deletedResourceIds = [];

//   /**
//    * keeps track of upload IDs to delete
//    * if user "Saves" these Documents will be deleted via ipaOFferingResourceService
//    * if user "Cancels" they will not be deleted
//    *
//    * @type {string[]}
//    * @private
//    */
//   deletedUploadIds = [];

//   /**
//    * keeps track of new Upload IDs
//    * If user "Saves" nothing happens
//    * If user "Cancels" these Documents will be deleted via ipaOfferingResourceService
//    *
//    * @type {string[]}
//    * @private
//    */
//   newUploadIds = [];

//   /**
//    * Video placeholder image
//    *
//    * @type {string}
//    * @private
//    */
//   videoPlaceholderImage;

//   /**
//    * connected callback sets accepted file types text
//    */
//   connectedCallback() {
//     const validTypes = this.validUploadTypes.replace('.', '').toUpperCase();
//     const validVideoTypes = this.validUploadVideoTypes.replace('.', '').toUpperCase();
//     this.videoPlaceholderImage = `${ipaVideo}/unavailable_thumbnail_246x138.png`;
//     this.uploadHelpText = this.labels.uploadHelpText.replace('{0}', validTypes);
//     this.uploadVideoHelpText = this.labels.uploadVideoHelpText.replace('{0}', validVideoTypes);
//   }

//   /**
//    * rendered callback - focus on last resource input
//    */
//   renderedCallback() {
//     if (this.focusRNum) {
//       // race condition lwc bug... focus happens before keydown event finishes
//       // eslint-disable-next-line @lwc/lwc/no-async-operation
//       setTimeout(() => {
//         this.template.querySelector(`[data-focus="${this.focusRNum}"]`).focus();
//         this.focusRNum = null;
//       });
//     }

//     if (this.isOpen) { // upload modal messes this up
//       document.body.style.overflow = 'hidden';
//     }
//   }

//   /**
//    * limits maximum of resources to limit
//    *
//    * @returns {boolean} displays "Add Resource" button
//    */
//   get displayAddButton() {
//     return this.resources.length < this.maxResourceLimit;
//   }

//   /** disable save button if no resources exist yet (or changes have been made)
//    *
//    * @returns {boolean} if save button is disabled
//    */
//   get saveDisabled() {
//     return (this._resources.length === 0 && this.resources.length === 0) || !this.touched;
//   }

//   /** adds key for iteration and number for actions
//    *
//    * @returns {object[]} formatted resources with properties for template
//    * this includes accessibility values, key values/rnum for action items, and other text
//    */
//   get formattedResources() {
//     return this.resources.map((resource, idx) => ({
//       ...resource,
//       key: resource.key || `resource-${resource.id}-${idx}`,
//       resourceNumber: idx + 1,
//       sectionAria: `${this.labels.resource} ${idx + 1}`,
//       deleteAria: `${this.labels.delete} ${this.labels.resource} ${idx + 1}`,
//       descriptionCharsRemaining: this.dynamicDescriptionLimit(resource.description),
//       descriptionRequired: !!resource.uploadId,
//       resourceTypeUpload: resource.resourceType,
//       requiresAltText: resource.resourceType?.toLowerCase() === 'video',
//       uploadLabelID: `upload-label-${idx}`,
//       urlInputID: `url-input-${idx}`,
//       confirmDeleteText: this.labels.confirmDelete.replace('{0}', resource.resourceType?.toLowerCase()),
//     }));
//   }

//   /** dynamic description limit
//    *
//    * @param {string} desc current description
//    * @returns {string} label with dynamic # chars remaining
//    */
//   dynamicDescriptionLimit(desc = '') {
//     const value = this.maxDescriptionLength - desc.length;
//     return this.labels.charLimits.description.replace('{0}', value);
//   }

//   /**
//    * fetch resources, stores original list for touched/disabled
//    */
//   async fetchResources() {
//     this.loading = true;
//     this.touched = false;
//     try {
//       this.resources = await getResources(this.recordId) || [];
//       this._resources = [...this.resources];
//       // eslint-disable-next-line no-undef
//       this.resources.forEach((input) => {
//         const res={'id': input.id, 'resourceType': input.resourceType};
//         this.copyResources.push(res);
//       });
//     } catch (e) {
//       // errors handled in ipaOfferingResourceService
//     }
//     this.loading = false;
//   }

//   /** handles changes and stores info on the resources object
//    *
//    * @param {event} evt change event
//    */
//   handleChange(evt) {
//     this.touched = true;
//     const idx = parseInt(evt.currentTarget.dataset.rnum, 10) - 1;
//     const { name } = evt.currentTarget;
//     const value = (typeof evt.detail === 'string' ? evt.detail : evt.detail.value) || '';
//     this.resources[idx][name] = value;
//     let customValidity = '';

//     const tagMatcher = /<("[^"]*"|'[^']*'|[^'">])*>/;
//     if (['title', 'description'].includes(name) && value.match(tagMatcher)) {
//       customValidity = this.labels.errors.noHTML;
//     }
//     const easyUrlMatcher = /(http:\/|ftp:\/|https:\/|\w+\.\w+\.\w+)+/;
//     if (['title', 'description'].includes(name) && value.match(easyUrlMatcher)) {
//       customValidity = this.labels.errors.noURL;
//     }
//     if (evt.target.setCustomValidity) {
//       evt.target.setCustomValidity(customValidity);
//       this.checkAssetValidation();
//     }
//     // if resource type changed, remove uploaded file
//     if (name === 'resourceType') {
//       this.resources[idx].altText = '';
//       if(this.resources[idx].id!=''){
//       this.deleteAsset(idx);
//     }
//     }
//     this.handleVideoResource(idx);
//   }

//   /** handles adding alt text and video upload formats when resource type is video
//    *
//    * @param {number} idx resource index
//    */
//   handleVideoResource(idx) {
//     if (this.resources[idx].resourceType?.toLowerCase() === 'video') {
//       this.resources[idx].requiresAltText = true;
//     } else {
//       this.resources[idx].requiresAltText = false;
//     }
//   }

//   /** handles deleting asset for resource
//    *
//    * @param {event} evt change event
//    */
//   handleDeleteAsset(evt) {
//     this.touched = true;
//     const idx = parseInt(evt.currentTarget.dataset.rnum, 10) - 1;
//     this.touched = true;
//     this.deleteAsset(idx);
//   }

//   /**
//    * handle Enter -> send focus to first input
//    *
//    * @param {event} evt keydown event
//    */
//   handleAddResourceAccessibility(evt) {
//     if (evt.code !== 'Tab') {
//       evt.preventDefault();
//     }
//     if (evt.code !== 'Enter') {
//       return;
//     }
//     this.touched = true;
//     this.resources = this.resources.concat({
//       key: Date.now(),
//       url: 'https://',
//     });
//     this.focusRNum = String(this.resources.length);
//   }

//   /**
//    * adds a new resource to the list w/ default values
//    */
//   handleAddResource() {
//     this.touched = true;
//     this.resources = this.resources.concat({
//       key: Date.now(),
//       id:''
//     });
//   }

//   /** trash can icon click removes resource from list
//    * if an upload exists this must be deleted as cleanup
//    *
//    * @param {event} evt click event
//    */
//   handleDeleteResource(evt) {
//     this.touched = true;
//     const idxToRemove = parseInt(evt.currentTarget.dataset.rnum, 10) - 1;
//     if (this.resources[idxToRemove].id) {
//       this.deletedResourceIds.push(this.resources[idxToRemove].id);
//     }
//     if (this.resources[idxToRemove].uploadId) {
//       this.idToUploadIdMap.push({value:this.resources[idxToRemove].uploadId, key:this.resources[idxToRemove].id}); 
//       this.deletedUploadIds.push(this.resources[idxToRemove].uploadId);
//     }
//     const resources = [...this.resources];
//     resources.splice(idxToRemove, 1);
//     this.resources = resources;
//     this.focusRNum = String(Math.min(resources.length, idxToRemove + 1));
//   }

//   /** delete Accessibility (Enter)
//    *
//    * @param {event} evt keydown event
//    */
//   handleDeleteResourceAccessibility(evt) {
//     if (evt.code === 'Enter') {
//       this.handleDeleteResource(evt);
//     }
//   }

//   /** handle upload click to store rnum value
//    *
//    * @param {event} evt click event
//    */
//   handleUploadClick(evt) {
//     this.uploadIdx = parseInt(evt.currentTarget.dataset.rnum, 10) - 1;
//   }

//   /** handles a completed file upload
//    *
//    * @param {event} evt upload event
//    */
//   handleUpload(evt) {
//     this.touched = true;
//     const { files } = evt.detail;

//     if (this.resources[this.uploadIdx].uploadId) {
//       this.deletedUploadIds.push(this.resources[this.uploadIdx].uploadId);
//     }

//     this.newUploadIds.push(files[0].documentId);
//     this.resources[this.uploadIdx].uploadId = files[0].documentId;
//     this.resources[this.uploadIdx].uploadName = files[0].name;
//     const uploadName = files[0].name;
//     this.resources[this.uploadIdx].fileExt = uploadName.substring(uploadName.lastIndexOf('.'));
//     this.resources = [...this.resources];

//     this.focusRNum = '0';

//     this.checkAssetValidation();
//   }

//   /** handles a completed video file upload
//    *
//    * @param {event} evt upload event
//    */
//   handleUploadVideo(evt) {
//     getContentDocSize({ contentDocId: evt.detail.files[0].documentId })
//       .then((result) => {
//         this.touched = true;
//         const { files } = evt.detail;
//         const fileSize = result;
//         const maxFileSize = 100000; // setting maxFileSize to 100MB
//         const maxCharFileName = 80;
//         const fileValidation = /[!@#$%^&*()?,{}[\]\s]/;
//         const currentResource = this.resources[this.uploadIdx];
//         currentResource.assetHasErrors = false;

//         if (currentResource.uploadId) {
//           this.deletedUploadIds.push(currentResource.uploadId);
//           if(this.copyResources[this.uploadIdx].resourceType == 'Video' && this.resources[this.uploadIdx].id != '' && this.resources[this.uploadIdx].uploadId != '' ) {
//             this.idToUploadIdMap.push({value:this.resources[this.uploadIdx].uploadId, key:this.resources[this.uploadIdx].id}); 
//             currentResource.id = '';
//             currentResource.videoThumbnail = '';
//           }
//         }

//         this.newUploadIds.push(files[0].documentId);
//         currentResource.uploadId = files[0].documentId;
//         currentResource.uploadName = files[0].name;

//         if (fileSize > maxFileSize) {
//           // file size error
//           currentResource.errorFileSize = true;
//           currentResource.assetHasErrors = true;
//         } else {
//           currentResource.errorFileSize = false;
//         }

//         if (fileValidation.test(currentResource.uploadName)) {
//           // special chars/spaces error
//           currentResource.errorFileNameSpecialChars = true;
//           currentResource.assetHasErrors = true;
//         } else {
//           currentResource.errorFileNameSpecialChars = false;
//         }

//         if (currentResource.uploadName.length > maxCharFileName) {
//           // file name too long error
//           currentResource.errorFileNameLength = true;
//           currentResource.assetHasErrors = true;
//         } else {
//           currentResource.errorFileNameLength = false;
//         }

//         if (currentResource.assetHasErrors) {
//             this.deleteAsset(this.uploadIdx);
//         } else {
//           currentResource.assetHasErrors = false;
//         }
//         const uploadName = files[0].name;
    
//         this.resources[this.uploadIdx].fileExt = uploadName.substring(uploadName.lastIndexOf('.'));
        
//         this.resources = [...this.resources];

//         this.focusRNum = '0';

//         this.checkAssetValidation();
//       })
//       .catch((error) => {
//         // eslint-disable-next-line no-console, prefer-template
//         handleError(error, 'handleUploadVideo - getContentDocSize');
//       });
//   }

//   /**
//    * handles the modal close
//    */
//   handleClose() {
//     this.isOpen = false;
//     this.reset();

//     this.modalInitiator.focus();
//   }

//   /**
//    * handles the cancel button
//    */
//   handleCancel() {
//     this.template.querySelector('c-core-intc-modal').closeModal();

//     this.modalInitiator.focus();
//   }

//   /**
//    * save button
//    */
//   handleSave() {
//     if (this.validateForm() && this.checkAssetValidation()) {
//       this.save();

//       this.modalInitiator.focus();
//     }
//   }

//   /**
//    * pre delete button
//    *
//    * @param {event} evt handle pre delete
//    */
//   handleShowDeleteModal(evt) {
//     const idx = parseInt(evt.currentTarget.dataset.rnum, 10) - 1;
//     const currentModal = this.template.querySelector(`c-core-intc-modal[data-rnum='${idx + 1}']`);
//     currentModal.openModal();
//   }

//   /**
//    * cancel delete button
//    *
//    * @param {event} evt handle pre delete
//    */
//   handleCancelDeleteAsset(evt) {
//     const idx = parseInt(evt.currentTarget.dataset.rnum, 10) - 1;
//     const currentModal = this.template.querySelector(`c-core-intc-modal[data-rnum='${idx + 1}']`);
//     currentModal.closeModal();
//   }

//   /**
//    *
//    * deletes asset for specified resource
//    *
//    * @private
//    * @param {number} idx
//    * returns the id of the asset to delete
//    */
//   deleteAsset(idx) {
//     this.deletedUploadIds.push(this.resources[idx].uploadId);
//     if (this.copyResources[idx].resourceType == 'Video' && this.resources[idx].resourceType != 'Video'){
//       this.idToUploadIdMap.push({value:this.resources[idx].uploadId, key:this.resources[idx].id}); 
//       this.resources[idx].id = '';
//       this.resources[idx].videoThumbnail = '';
//     }
//     else if (this.copyResources[idx].resourceType != 'Video' && this.resources[idx].resourceType == 'Video') {
//       this.deletedResourceIds.push(this.resources[idx].id);
//       this.resources[idx].id = '';
//       this.resources[idx].videoThumbnail = '';
//     }
//     else if (this.copyResources[idx].resourceType == 'Video' && this.resources[idx].resourceType == 'Video') {
//       this.idToUploadIdMap.push({value:this.resources[idx].uploadId, key:this.resources[idx].id});
//       this.resources[idx].id = '';
//       this.resources[idx].videoThumbnail = '';
//     }
//     this.resources[idx].uploadId = '';
//     this.resources[idx].uploadName = '';
//     this.checkAssetValidation();
//   }

//   /**
//    * check asset validation for URL and Upload
//    *
//    * @returns {boolean} form validity
//    */
//   checkAssetValidation() {
//     let hasNoAssetErrors;
//     if (this.resources.length > 0) {
//       this.resources.forEach((resource, idx) => {
//         if (resource.uploadId && resource.url) {
//           this.resources[idx].doubleAssetError = true;
//           this.resources[idx].errorContainerClass = 'custom-error-container';
//           hasNoAssetErrors = false;
//         } else if (!resource.uploadId && !resource.url) {
//           this.resources[idx].noAssetError = true;
//           this.resources[idx].errorContainerClass = 'custom-error-container';
//           hasNoAssetErrors = false;
//         } else if (resource.uploadId || resource.url) {
//           this.resources[idx].doubleAssetError = false;
//           this.resources[idx].noAssetError = false;
//           this.resources[idx].errorContainerClass = '';
//           hasNoAssetErrors = true;
//         } else {
//           hasNoAssetErrors = true;
//         }
//       });
//     } else {
//       hasNoAssetErrors = true;
//     }

//     this.resources = [...this.resources];

//     return hasNoAssetErrors;
//   }

//   /**
//    * validates form
//    *
//    * @returns {boolean} form validity
//    */
//   validateForm() {
//     const inputs = this.template.querySelectorAll(
//       'lightning-input, lightning-textarea, c-core-intc-select',
//     );
//     const customErrors = this.template.querySelectorAll('.slds-has-error');
//     this.checkAssetValidation();
//     let stillValid = true;
//     inputs.forEach((input) => {
//       if (!input.reportValidity()) {
//         if (stillValid) {
//           input.scrollIntoView({ behavior: 'smooth' });
//           input.focus();
//         }
//         stillValid = false;
//       }
//     });
//     customErrors.forEach((error) => {
//       error.scrollIntoView({ behavior: 'smooth' });
//       error.focus();

//       stillValid = false;
//     });

//     return stillValid;
//   }

//   /**
//    * cancel helper - calls ipaOfferingResourceService
//    */
//   async reset() {
//     try {
//       if (this.newUploadIds.length) {
//         await deleteUploads(this.newUploadIds);
//         this.newUploadIds = [];
//       }
//     } catch (e) {
//       // errors handled in ipaOfferingResourceService
//     }
//     // Resets form data
//     // slightly better UI w/ 500ms delay
//     // eslint-disable-next-line @lwc/lwc/no-async-operation
//     setTimeout(() => {
//       this.resources = [];
//       this.deletedResourceIds = [];
//       this.deletedUploadIds = [];
//     }, 500);
//   }

//   /**
//    * save helper - calls ipaOfferingResourceService
//    * - 1. SAVES NEW DATA
//    * - 2. REMOVES any DELETED RESOURCES
//    * - 3. REMOVES any OVERWRITTEN UPLOADS
//    */
//   async save() {
//     this.loading = true;
//     const saveData = this.resources.map((res) => {
//       // filter out unnecessary data here
//       // eslint-disable-next-line no-unused-vars
//       const { key, ...toSave } = res;
//       return toSave;
//     });
//     try {
//       if (saveData.length) {
//         await saveResourceData(this.recordId, saveData);
//       }
//       if (this.deletedResourceIds.length) {
//         await deleteResources(this.deletedResourceIds);
//         this.deletedResourceIds = [];
//       }
//       if (this.deletedUploadIds.length) {
//         await deleteUploads(this.deletedUploadIds, this.idToUploadIdMap);
//         this.deletedUploadIds = [];
//       }
//       this.dispatchEvent(new CustomEvent('save', { detail: saveData }));
//       this.newUploadIds = []; // resets new uploads list
//       this.isOpen = false;
//       this.template.querySelector('c-core-intc-modal').closeModal();
//     } catch (e) {
//       // errors handled in ipaOfferingResourceService
//     }
//     // better ui with slight delay
//     // eslint-disable-next-line @lwc/lwc/no-async-operation
//     setTimeout(() => {
//       this.loading = false;
//     }, 500);
//   }
// }

// export default IpaOfferingResourceModal;