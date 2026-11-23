import { LightningElement, api } from 'lwc';

// import altTextPlaceholder from '@salesforce/label/c.PMP_Edit_Storefront_Alt_Text_Placeholder';
// import resourceTypeLabel from '@salesforce/label/c.PMP_Resource_Type';
// import fileLabel from '@salesforce/label/c.PMP_File';
// import downloadLabel from '@salesforce/label/c.PMP_Download';
// import videoLabel from '@salesforce/label/c.PMP_Video';
// import publishLabel from '@salesforce/label/c.PMP_PublishLabel';
// import descriptionLabel from '@salesforce/label/c.PMP_Description';
// import altTextLabel from '@salesforce/label/c.PMP_Alt_Text';
// import resourceLabel from '@salesforce/label/c.PMP_Resources';

// import openModalMessage from '@salesforce/label/c.PMP_Resource_Open_Modal_Message';
// import placeholderImageMessage from '@salesforce/label/c.PMP_Resource_Display_Placeholder_Image_Message';
// import videoModal from '@salesforce/label/c.PMP_Video_Modal';
// import placeholderModal from '@salesforce/label/c.PMP_Placeholder_Modal';

// import ipaVideo from '@salesforce/resourceUrl/IPA_Video';
// /**
//  * Display component for Offering Resources
//  *
//  * @augments Lightning Element
//  * @property {string} title resource title
//  * @property {string} [description] resource description
//  * @property {string} resourceType resource type
//  * @property {string} url resource url
//  * @property {string} [fileType] resource file type
//  * @property {string} [fileSize] resource file size
//  * @property {string} [downloadUrl] resource download url
//  * @property {boolean} [preview] used to make links 'preview' mode
//  * @property {object} [videoType]  resource of type video - video information
//  * @property {string} publishDate publish date of resource
//  * @property {boolean} [editorOption] if resource view is in SF editor
//  * @property {string} [altText] video alt text
//  * @property {string} [videoPlaceholderImage=unavailable_thumbnail_246x138.png] videoPlaceholderImage-not initialized
//  */
class IpaOfferingResource extends LightningElement {}
//   /**
//    * custom labels used in template
//    *
//    * @type {object}
//    * @private
//    */
//   labels = {
//     altTextPlaceholderText: altTextPlaceholder,
//     resourceType: resourceTypeLabel,
//     file: fileLabel,
//     download: downloadLabel,
//     video: videoLabel,
//     publish: publishLabel,
//     description: descriptionLabel,
//     altText: altTextLabel,
//     openModal: openModalMessage,
//     placeholderImage: placeholderImageMessage,
//     placeholder_modal: placeholderModal,
//     video_modal: videoModal,
//     resources: resourceLabel,
//     pageType: 'OfferingDetailPage'
//   };

//   @api title;

//   @api description;

//   @api fileType;

//   @api fileSize;

//   @api resourceType;

//   @api url;

//   @api downloadUrl;

//   @api videoType;

//   @api publishDate;

//   @api preview;

//   @api editorOption;

//   @api altText;

//   @api videoPlaceholderImage = `${ipaVideo}/unavailable_thumbnail_246x138.png`;



//   /**
//    * Returns icon info
//    *
//    * @returns {object} icon info
//    */
//   get icon() {
//     if (this.resourceType === 'Video') {
//       return { classes: 'fa-icons_functional_video-56 slds-m-right_small', alt: `${this.labels.video}: ${this.title}` };
//     }
//     return {};
//   }

//   /**
//    * determines if the video resource type has an image or thumbnailUrl and url
//    *
//    * @private
//    * @returns {boolean} video thumbnail
//    */
//   get videoTypeInfo() {
//     if (this.resourceType === 'Video') {
//       return (this.videoType?.thumbnailUrl || this.videoPlaceholderImage) && !this.url;
//     }
//     return false;
//   }

//   /**
//    * Opens the modal and plays the video that is within the modal automatically
//    *
//    * @private
//    */
//   handleOpenModal() {
//     this.template.querySelector('c-core-intc-modal').openModal();
//     this.playAllVideo('.resource-modal-video');
//   }

//   /**
//    * Opens the placeholder image within the modal
//    *
//    * @private
//    */
//   handleOpenImageModal() {
//     this.template.querySelector('.image-modal').openModal();
//   }

//   /**
//    * Closes the modal and stops playing the video that is within the modal
//    *
//    * @private
//    */
//   handleCloseModal() {
//     this.template.querySelector('c-core-intc-modal').closeModal();
//     // eslint-disable-next-line @lwc/lwc/no-async-operation
//     setTimeout(() => {
//       this.pauseAllVideo('.resource-modal-video');
//     }, 5);
//   }

//   /**
//    * Pause all videos selected by videoSelector
//    *
//    * @param {string} videoSelector css Selector
//    * @private
//    */
//   pauseAllVideo(videoSelector) {
//     const videos = this.template.querySelectorAll(`c-core-intc-video${videoSelector}`);
//     videos.forEach((video) => {
//       video.pauseVideo();
//     });
//   }

//   /**
//    * Play all videos selected by videoSelector
//    *
//    * @param {string} videoSelector css Selector
//    * @private
//    */
//   playAllVideo(videoSelector) {
//     const videos = this.template.querySelectorAll(`c-core-intc-video${videoSelector}`);
//     videos.forEach((video) => {
//       video.playVideo();
//     });
//   }

//   /**
//    * Determines the keyword entered is Enter or not
//    *
//    * @private
//    * @param {event} evt
//    * Accessibility keydown event handlers:
//    * Enter Key - opens video in the modal
//    */
//   handleKey(evt) {
//     if (evt.key === 'Enter') {
//       this.handleOpenModal();
//     }
//   }

//   /**
//    * Determines the keyword entered is Enter or not
//    *
//    * @private
//    * @param {event} evt
//    * Accessibility keydown event handlers:
//    * Enter Key - opens image in the modal
//    */
//   handleImageKey(evt) {
//     if (evt.key === 'Enter') {
//       this.handleOpenImageModal();
//     }
//   }

//   /**
//    * Accessibility keydown event handlers:
//    * Escape Key - closes modal
//    * Enter Key - closes modal (if on close icon)
//    *
//    * @private
//    * @param {event} evt
//    * event is passed to determine to open or close modal
//    */
//   handleCloseKey(evt) {
//     if (evt.key === 'Enter' && evt.target.dataset.keydownAction === 'close') {
//       this.handleCloseModal();
//     }
//     if (evt.key === 'Escape' && !this.hideClose) {
//       this.handleCloseModal();
//     }
//   }
// }
// export default IpaOfferingResource;