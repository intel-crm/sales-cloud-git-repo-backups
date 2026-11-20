// import { LightningElement, api, track } from 'lwc';

// import disclaimer1Label from '@salesforce/label/c.PMP_Video_Uploader_Disclaimer1';
// import uploadLabel from '@salesforce/label/c.PMP_Upload_Video';
// import addVideoLabel from '@salesforce/label/c.PMP_Add_Video_Btn_Label';
// import videoLabel from '@salesforce/label/c.PMP_Video_Label';
// import videoTitleLabel from '@salesforce/label/c.PMP_Video_Title';
// import videoDescriptionLabel from '@salesforce/label/c.PMP_Video_Description';
// import altTextLabel from '@salesforce/label/c.PMP_Alt_Text_Label';
// import altTextHelper from '@salesforce/label/c.PMP_Edit_Storefront_Alt_Text_Helper';
// import videoHelperSize from '@salesforce/label/c.PMP_Edit_Storefront_Upload_Video_Helper_Size';
// import videoHelperFormat from '@salesforce/label/c.PMP_Edit_Storefront_Upload_Video_Helper_Format';
// import videoHelperFile from '@salesforce/label/c.PMP_Edit_Storefront_Upload_Video_Helper_File';

// import cancelLabel from '@salesforce/label/c.Core_PMP_Cancel';
// import deleteLabel from '@salesforce/label/c.Core_PMP_Delete';
// import okText from '@salesforce/label/c.PMP_Okay';
// import confirmDeleteEntryTitle from '@salesforce/label/c.PMP_Video_Confirm_Delete_Title';
// import confirmDeleteEntryText from '@salesforce/label/c.PMP_Video_Confirm_Delete_Entity';
// import charsRemainingDescriptionLabelDynamic from '@salesforce/label/c.PMP_Description_Characters_Remaining';
// import PMP_Empty_Title from '@salesforce/label/c.PMP_Empty_Title';
// import PMP_Empty_Description from '@salesforce/label/c.PMP_Empty_Description';
// import PMP_Empty_Alt_Text from '@salesforce/label/c.PMP_Empty_Alt_Text';

// import errorFileNameSpecialChars from '@salesforce/label/c.PMP_Edit_Storefront_Resources_Error_File_Name_Special_Chars';
// import errorFileSize from '@salesforce/label/c.PMP_Edit_Storefront_Resources_Error_File_Size';
// import errorFileNameLength from '@salesforce/label/c.PMP_Edit_Storefront_Resources_Error_File_Name_Length';
// import errorFileNameAndVideoTitle from '@salesforce/label/c.PMP_Error_Video_File_Name_And_Title';
// import No_Of_File_Error from '@salesforce/label/c.PMP_No_Of_File_Error';
// import Prev_Details from '@salesforce/label/c.PMP_Prev_Details';

// import ipaVideo from '@salesforce/resourceUrl/IPA_Video';
// import validateVideo from '@salesforce/apex/PMP_OfferingResourceHelper.validateVideo';
// import saveGalleryVideo from '@salesforce/apex/PMP_OfferingResourceHelper.saveGalleryVideo';
// import getGalleryVideos from '@salesforce/apex/PMP_OfferingResourceHelper.getGalleryVideos';
// import updateGalleryVideo from '@salesforce/apex/PMP_OfferingResourceHelper.updateGalleryVideo';
// import getGalleryImagesCount from '@salesforce/apex/PMP_OfferingResourceHelper.getGalleryImagesCount';


// import { handleError } from 'c/ipaErrorServiceMarketplace';

// /**
//  *
//  * This component is to manage the video uploads on Offering Admin
//  *
//  * @property {string} recordId id for uploaded videos - required
//  * @property {string} [offeringId={!recordId}] this is the Offering Id
//  * @property {Array} videosList an array of videos to for an Offering Id
//  * @augments LightningElement
//  */
export default class IpaOfferingUploadVideo extends LightningElement {}

//   /**
//    * to copy videos
//    * @type {Object}
//    * @public
//    */
//   @api videosList=[];
 

//    /**
//    * store Record Id
//    * @type {String}
//    * @public
//    */
//   @api offeringId = '';

//     /**
//    *variable for holding the placeholder image for video
//    *
//    * @private
//    * @type {string}
//    */
//   videoPlaceholderImage = `${ipaVideo}/unavailable_thumbnail_246x138.png`;

//   /**
//    * Max Length of Title input value
//    *
//    * @type {number}
//    * @private
//    */
//   maxTitleLength = 50;

//   /**
//    * Max length of Description textarea value
//    *
//    * @type {number}
//    * @private
//    */
//   maxDescriptionLength = 255;

//    /**
//    * Max Length of URL input value
//    *
//    * @type {number}
//    * @private
//    */
//     maxTextLength = 100;

//   /**
//    * custom labels used in template
//    *
//    * @type {object}
//    * @private
//    */
//   labels = {
//     addVideo: addVideoLabel,
//     altText: altTextLabel,
//     altTextHelp: altTextHelper,
//     cancel: cancelLabel,
//     confirmDelete: confirmDeleteEntryText,
//     confirmDeleteTitle: confirmDeleteEntryTitle,
//     delete: deleteLabel,
//     disclaimer1: disclaimer1Label,
//     ok: okText,
//     upload: uploadLabel,
//     uploadVideoHelpText: videoHelperFormat,
//     uploadVideoHelpTextFileName: videoHelperFile,
//     uploadVideoHelpTextSize: videoHelperSize,
//     video: videoLabel,
//     videoTitle: videoTitleLabel,
//     videoDescription: videoDescriptionLabel,
//     charLimits: {
//       description: charsRemainingDescriptionLabelDynamic,
//     },
//     errors: {
//       uploadFileNameLength: errorFileNameLength,
//       uploadFileSize: errorFileSize,
//       uploadFileSpecialChars: errorFileNameSpecialChars,
//       videoFileExists: errorFileNameAndVideoTitle,
//       empty_Title: PMP_Empty_Title,
//       empty_Description: PMP_Empty_Description,
//       empty_Alt_Text: PMP_Empty_Alt_Text,
//       noOfFileError:No_Of_File_Error,
//       fillPrevOne:Prev_Details
//     },
//   };
  
//     /**
//    * varibale for holding max number of videos to display
//    *
//    * @private
//    * @type {number}
//    */
//   maxVideoLimit = 4;

//   /**
//    * keeps track of video titleExists
//    * @type {boolean}
//    * @private
//    */
//   titleExists = false;

//   /**
//    * keeps track of display Input fields
//    * @type {boolean}
//    * @private
//    */
//   displayInputFields = false;

//   /**
//    * keeps track of current form state of videos
//    *
//    * @type {string[]}
//    * @private
//    */
//   @track videos = []; 

//   /**
//    * varibale for holding number of images
//    *
//    * @private
//    * @type {number}
//    */
//   galleryImagesCount=0;

//   /**
//    * keeps track of Files exceeding 5
//    * @type {boolean}
//    * @private
//    */
//   noofFileMore=false;

//    /**
//    * keeps track of Previous Video details filled or not
//    * @type {boolean}
//    * @private
//    */
//   addWrapper=false;

//    /**
//    * keeps track of Errors on Add Video
//    * @type {boolean}
//    * @private
//    */
//   addVideoError=false;

//    /**
//    *
//    * Runs when the component is loaded
//    *
//    */
//   connectedCallback(){
//     this.fetchGalleryResources();
//   }

//   /**
//    * fetch resources
//    * 
//    * @private
//    */
//       fetchGalleryResources() {
//         console.log(this.videos);
//         getGalleryVideos({ offeringId: this.offeringId })
//         .then((result) => {
//           console.log(result);
//           this.videos = result;
//           // eslint-disable-next-line @lwc/lwc/no-api-reassignments
//           this.videosList = this.videos;
//           this.displayInputFields = true;
//       }).catch ((error) => {
//         console.log(e);
//         handleError(error, 'getGalleryVideos');
//       });
//     }
  
//   /**
//    * displays or hides "Add Video" button
//    *
//    * @returns {boolean} display "Add Video" Button
//    */
//   get displayAddButton() {
//     return true;
//   }

//   /**
//    * helper function that sends focus to the first input field
//    *
//    * @param {boolean} display takes a boolean
//    */
//   displayInputField(display) {
//     this.displayInputFields = display;
//     if (display) {
//       // eslint-disable-next-line @lwc/lwc/no-async-operation
//       setTimeout(() => {
//         this.template.querySelector('lightning-input').focus();
//       });
//     }
//   }

//   /**
//    * handle Enter -> send focus to first input field
//    *
//    * @param {event} evt keydown event
//    */
//   handleAddVideoAccessibility(evt) {
//     this.displayInputField(true);
//     if (evt.code !== 'Tab') {
//       evt.preventDefault();
//     }
//     if (evt.code !== 'Enter') {
//       return;
//     }
//     this.touched = true;
//     this.videos = this.videos.concat({
//       key: Date.now(),
//       url: 'https://',
//     });
//     this.focusRNum = String(this.videos.length);
//   }

//   /**
//    * Handle "Add Video" Button
//    *
//    */
//   handleAddVideo() { 
//   getGalleryImagesCount({ offeringId: this.offeringId })
//   .then((result) => {
//     this.galleryImagesCount = result;
//     var videoCount = this.videos.length;
//     var maxlimit;
//     if (this.galleryImagesCount == 0) {
//       maxlimit = 4
//     } else {
//       maxlimit = 5;
//     }
//     if (videoCount == 0) {
//       if((this.galleryImagesCount+videoCount) >= maxlimit) {
//         this.addVideoError = true;
//            this.noofFileMore = true;
//       }
//       else {
//         this.displayInputFields = true;
//             this.videos = this.videos.concat({
//          key: Date.now(),
//          id: '',
//          altText: '',
//          description: '',
//          title: ''
//        });
//          this.videosList = [...this.videos];
//          this.noofFileMore = false;
//          this.addVideoError = false;
//       }
//    }
//    else {
//      const currVid = this.videos[this.videos.length-1];
//      var vidId = currVid.Id?currVid.Id:currVid.id;
//        if (currVid.altText == '' || currVid.description == '' ||currVid.title == ''||vidId == ''){
//          this.addVideoError = true;
//          this.addWrapper = true;
//        }
//      else {	
//        if ((this.galleryImagesCount+videoCount) >= maxlimit) {
//          this.addVideoError = true;
//          this.noofFileMore = true;
//         }
//         else {
//           this.displayInputFields = true;
//           this.videos = this.videos.concat({
//            key: Date.now(),
//            id: '',
//            altText: '',
//            description: '',
//            title: ''
//          });
//          // eslint-disable-next-line @lwc/lwc/no-api-reassignments
//          this.videosList = [...this.videos];
//          this.noofFileMore = false;
//          this.addVideoError = false;
//        }
//      }
//   }
// }).catch ((error) => {
//   console.log(e);
//   handleError(error, 'getGalleryImagesCount');
// });
    
//   }


//   /**  dynamic description limit
//    *
//    *  @param {string} [desc=''] - current description
//    * @returns {string} label with dynamic # chars remaining
//    */
//   dynamicDescriptionLimit(desc = '') {
//     const value = this.maxDescriptionLength - desc.length;
//     return this.labels.charLimits.description.replace('{0}', value);
//   }

//   /** adds key for iteration and number for actions
//    *
//    * @returns {object[]} formatted videos with properties for template
//    * this includes accessibility values, key values/rnum for action items, and other text
//    */
//   get formattedVideos() {
//     return this.videos.map((video, idx) => ({
//       ...video,
//       key: video.key ||  `video-${video.id}-${idx}`,
//       videoNumber: idx + 1,
//       sectionAria: `${this.labels.video} ${idx + 1}`,
//       deleteAria: `${this.labels.delete} ${this.labels.video} ${idx + 1}`,
//       descriptionCharsRemaining: this.dynamicDescriptionLimit(video.description),
//       confirmDeleteText: this.labels.confirmDelete.replace('{0}', 'video'),
//       uploadLabelID: `upload-label-${idx}`,
//       title: video.title,
//       disabled: (video.disabled||video.id)==''?false:true
//     }));
//   }

//   /** deletes video asset for specified video
//    *
//    * @param {number} idx upload event
//    */
//   deleteAsset(idx) {
//     var vidId = this.videos[idx].Id?this.videos[idx].Id:this.videos[idx].id;
//       updateGalleryVideo({ offeringResId: vidId,uploadId: this.videos[idx].uploadId})
//           .then((result) => {
//             if(result) {
//               let video = {};
//               video.title = this.videos[idx].title
//               video.description = this.videos[idx].description
//               video.altText = this.videos[idx].altText
//               video.assetHasErrors = this.videos[idx].assetHasErrors
//               video.errorFileNo = this.videos[idx].errorFileNo
//               video.errorFileSize = this.videos[idx].errorFileSize
//               video.errorFileNameSpecialChars = this.videos[idx].errorFileNameSpecialChars
//               video.errorFileNameLength = this.videos[idx].errorFileNameLength
//               video.errorFileExists = this.videos[idx].errorFileExists      
//               video.id = '';   
//               this.videos[idx] = video;
//               // eslint-disable-next-line @lwc/lwc/no-api-reassignments
//               this.videosList = [...this.videos];
//               this.addVideoError = false;
//               this.noofFileMore = false;
//             }
//           }).catch((error) => {
//             handleError(error, 'handleUploadVideo - saveGalleryVideo');
//           });
//   }
//   /** handles deleting asset for video
//    *
//    * @param {event} evt change event
//    */
//   handleDeleteAsset(evt) {
//     const idx = parseInt(evt.currentTarget.dataset.rnum, 10) - 1;
//     this.touched = true;
//     this.deleteAsset(idx);
//   }

//   /** delete Accessibility (Enter)
//    *
//    * @param {event} evt keydown event
//    */
//   handleDeletevideoAccessibility(evt) {
//     if (evt.code === 'Enter') {
//       this.handleVideoResource(evt);
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
//    * handler that closes the pop up modal with Tab and Event event key
//    *
//    * @param {event} evt tab or enter on icon button
//    */
//   handleDeleteAssetIconAccessibility(evt) {
//     if (evt.key === 'Tab') {
//       // eslint-disable-next-line @lwc/lwc/no-async-operation
//       setTimeout(() => {
//         this.template.querySelector('.addButton-container').focus();
//       });
//     }
//     if (evt.key === 'Enter') {
//       this.handleShowDeleteModal();
//     }
//   }

//   /**
//    * handler to delete a video
//    *
//    * @param {event} evt click on delete icon
//    */
//   handleDeleteVideo(evt) {
//     const idxtoRemove = parseInt(evt.currentTarget.dataset.rnum, 10) - 1;
//     var vidId = this.videos[idxtoRemove].Id?this.videos[idxtoRemove].Id:this.videos[idxtoRemove].id
//     if (vidId) {
//       updateGalleryVideo({ offeringResId: vidId,uploadId: this.videos[idxtoRemove].uploadId})
//         // eslint-disable-next-line no-unused-vars    
//         .then((result) => {
//             var videos = [...this.videos];
//             videos.splice(idxtoRemove, 1);
    
//             this.videos = videos;
//             this.addVideoError = false;
//             // eslint-disable-next-line @lwc/lwc/no-api-reassignments
//             this.videosList = [...this.videos];
//           }).catch((error) => {
//             handleError(error, 'handleDeleteVideo - updateGalleryVideo');
//           });
//       } else {
//         var videos = [...this.videos];
//             videos.splice(idxtoRemove, 1);
//             this.addVideoError = false;
//             this.videos = videos;
//             // eslint-disable-next-line @lwc/lwc/no-api-reassignments
//             this.videosList = [...this.videos];
//             this.addWrapper = false;
//       }
    
    
//   }

//   /** handle upload click to store rnum value
//   * 
//   * @param {event} evt click event
//   */
//    handleUploadClick(evt) {
//     this.uploadIdx = parseInt(evt.currentTarget.dataset.rnum, 10) - 1;
//     const currVid = this.videos[this.uploadIdx];
//     currVid.assetHasErrors = true;
//     if (currVid.title == null || currVid.title == '') {
//       currVid.titleEmpty = true;
//     }
//     if (currVid.description == null || currVid.description == '') {
//       currVid.desEmpty = true;
//     }
//     if (currVid.altText == null || currVid.altText == '') {
//       currVid.textEmpty = true;
//     }
//     if (currVid.altText && currVid.description && currVid.title) {
//       currVid.assetHasErrors = false;
//     }
//     if (currVid.altText == '' || currVid.description == '' ||currVid.title == '') {
//       currVid.disabled = true;
//     }
//     this.videos[this.uploadIdx] = {...this.videos[this.uploadIdx], ...currVid};
//     // eslint-disable-next-line @lwc/lwc/no-api-reassignments
//     this.videosList = this.videos;
//   }

//   /** handles changes to any of the input fields
//    *
//    * @param {event} evt change to inputs fields
//    */
//   handleValue(evt) {
//     const idx = parseInt(evt.currentTarget.dataset.rnum, 10) - 1;
//     const { name } = evt.currentTarget;
//     const value = (typeof evt.detail === 'string' ? evt.detail : evt.detail.value) || '';
//     this.videos[idx][name] = value;
//     this.videos[idx].titleEmpty = false;
//     this.videos[idx].desEmpty = false;
//     this.videos[idx].textEmpty = false;
//     this.videos[idx].disabled = false;


//     // clear custom errors
//     this.videos[idx].errors = null;
//     this.addVideoError = false;
//     this.noOfFiles = false;
//     this.addWrapper = false;
//     // check duplicates for title field
//     if (name === 'title') {
//       const titleExist = this.videos.some((video, index) => {
//         if (idx === index) return false;
//         return (video.title === value);
//       });
//       this.titleExists = titleExist;
//     }
//     // eslint-disable-next-line @lwc/lwc/no-api-reassignments
//     this.videosList = this.videos;
//   }

//   /**
//    * list of accepted formats that can be uploaded
//    *
//    * @returns {string} valid input types
//    */
//   get acceptedFormats() {
//     return ['.mp4', '.mov', '.avi'];
//   }

//   /**
//    * handles a completed video file upload
//    *
//    * @param {event} evt upload event
//    */
//   handleUploadVideo(evt) {
//     validateVideo({ offeringId: this.offeringId,contentDocId: evt.detail.files[0].documentId })
//     .then((result) => {
//       this.touched = true;
//       const { files } = evt.detail;
//       const fileSize = result.contentDocSize;
//       const noOfImages = parseInt(result.imageCount);
//         const maxFileSize = 100000; // setting maxFileSize to 100MB
//         const maxCharFileName = 80;
//         const fileValidation = /[!@#$%^&*()?,{}[\]\s]/;

//         const currentVideo = {
//           ...this.videos[this.uploadIdx],
//           assetHasErrors: false,
//         index: 'video-upload-' + this.uploadIdx,
//           uploadName: files[0].name,
//           uploadId: files[0].documentId,
//       };
//       if ((noOfImages+this.videos.length-1) < 5) {
//       // clear errors from previous upload
//         currentVideo.assetHasErrors = false;
//         // file name and video title duplicate check
//         if (this.videos.length > 1 && files.length) {
//           const matchingFiles = this.videos.filter((video, index) => {
//             if (index === this.uploadIdx) return false;
//             return (video.uploadName === files[0].name);
//           });

//           if (matchingFiles.length > 0 && this.titleExists) {
//             currentVideo.assetHasErrors = true;
//             currentVideo.errorFileExists = true;
//           } else {
//             currentVideo.errorFileExists = false;
//           }
//         }

//         // file size check
//         if (fileSize > maxFileSize) {
//           currentVideo.assetHasErrors = true;
//           currentVideo.errorFileSize = true;
//         } else {
//           currentVideo.errorFileSize = false;
//         }

//         // special chars and space check
//         if (fileValidation.test(currentVideo.uploadName)) {
//           currentVideo.assetHasErrors = true;
//           currentVideo.errorFileNameSpecialChars = true;
//         } else {
//           currentVideo.errorFileNameSpecialChars = false;
//         }

//         // file name length check
//         if (currentVideo.uploadName.length > maxCharFileName) {
//           currentVideo.assetHasErrors = true;
//           currentVideo.errorFileNameLength = true;
//         } else {
//           currentVideo.errorFileNameLength = false;
//         }
//         this.videos[this.uploadIdx] = { ...this.videos[this.uploadIdx], ...currentVideo};
//         // check if the current video asset has errors and if so delete the asset
//         if (currentVideo.assetHasErrors) {
//             this.deleteAsset(this.uploadIdx);
//             currentVideo.uploadName = '';
//             currentVideo.uploadId = '';
//         } else {
//           currentVideo.assetHasErrors = false;
//         }
//       if(!currentVideo.assetHasErrors){
//       // eslint-disable-next-line @lwc/lwc/no-async-operation
//       const uploadName = currentVideo.uploadName
//       const fileExt = uploadName.substring(uploadName.lastIndexOf('.'));
//       this.videos[this.uploadIdx] = { ...this.videos[this.uploadIdx], ...currentVideo};
//       var videobackend =
//         {
//           title: this.videos[this.uploadIdx].title ,
//           uploadName: files[0].name,
//           uploadId: files[0].documentId,
//           altText: this.videos[this.uploadIdx].altText,
//           description: this.videos[this.uploadIdx].description,
//           fileExt: fileExt
//         };
//         saveGalleryVideo({ offeringId: this.offeringId,galleryVideo: videobackend })
//         .then((result) => {
//           // eslint-disable-next-line no-shadow
//           this.videos[this.uploadIdx].id = result;
//           // eslint-disable-next-line @lwc/lwc/no-api-reassignments
//           this.videos[this.uploadIdx].assetHasErrors = false;
//           this.videos[this.uploadIdx].errorFileNo = '';
//           this.videos[this.uploadIdx].errorFileSize = '';
//           this.videos[this.uploadIdx].errorFileNameSpecialChars = '';
//           this.videos[this.uploadIdx].errorFileNameLength = '';
//           this.videos[this.uploadIdx].errorFileExists  = '';
//           this.addWrapper = true;
//           this.videosList = [...this.videos];
//         }).catch((error) => {
//           handleError(error, 'handleUploadVideo - saveGalleryVideo');
//         });
//       }
//       // eslint-disable-next-line @lwc/lwc/no-async-operation
//       setTimeout(() => {
//         this.template.querySelector('.remove-video-asset').focus();
//       });
//     }else{
//         this.videos[this.uploadIdx].assetHasErrors = true;
//         this.videos[this.uploadIdx].errorFileNo = true;
//     }
//     })
//     .catch((error) => {
//       handleError(error, 'handleUploadVideo - getContentDocSize');
//     });
//   }
// }