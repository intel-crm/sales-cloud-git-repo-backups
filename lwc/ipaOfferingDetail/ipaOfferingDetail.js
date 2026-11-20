/* eslint-disable max-len */
import { LightningElement, api } from 'lwc';
// import { checkValidOffering, getOfferingDetails } from 'c/ipaOfferingService';
// import cloneOfferingDetail from '@salesforce/apex/PMP_OfferingDetailsController.cloneOfferingDetail';
// import { NavigationMixin } from 'lightning/navigation';
// import { handleError } from 'c/ipaErrorServiceMarketplace';
// import { loadStyle } from 'lightning/platformResourceLoader';
// import IpaResources from '@salesforce/resourceUrl/IpaResources';

// import removeRecordCache from '@salesforce/apex/PMP_OfferingDetailsController.removeRecordCache';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* Custom Labels */
// import errorPageUrl from '@salesforce/label/c.PMP_Error_Page_URL';

// import yesLabel from '@salesforce/label/c.PMP_Yes';
// import aboutLabel from '@salesforce/label/c.PMP_About_Company';
// import messagingLabel from '@salesforce/label/c.PMP_Messaging_MessagesAboutOffering';
// import disclaimer from '@salesforce/label/c.PMP_OfferingDetailDisclaimer1';
// import disclaimer2 from '@salesforce/label/c.PMP_OfferingDetailDisclaimer2';
// import disclaimerUrl from '@salesforce/label/c.PMP_DisclaimerURL';

// import overviewLabel from '@salesforce/label/c.PMP_L3_Partner_Detail_Overview';
// import techSpecLabel from '@salesforce/label/c.Core_Technical_Specification';
// import qualityMetricsTableHeaderLabel from '@salesforce/label/c.PMP_Quality_Metrics_Table';
// import intelTechLabel from '@salesforce/label/c.Core_Included_Intel_Technology';
// import descriptionLabel from '@salesforce/label/c.PMP_Description';
// import offeringDetailsLabel from '@salesforce/label/c.PMP_Offering_Details';
// import resourcesLabel from '@salesforce/label/c.PMP_Resources';
// import allCompanyOfferingsLabel from '@salesforce/label/c.PMP_All_Company_Offerings';
// import companyResourcesLabel from '@salesforce/label/c.PMP_Company_Resources';
// import articlesAndNewspapersLabel from '@salesforce/label/c.PMP_Company_Articles';
// import articlesViewAllLabel from '@salesforce/label/c.PMP_ViewAll';
// import marketingInfoLabel from '@salesforce/label/c.PMP_Marketing_Info';

// import updateDateButtonLabel from '@salesforce/label/c.PMP_Edit_Publish_date';
// import cloneButtonLabel from '@salesforce/label/c.PMP_CloneOffering';
// import editButtonLabel from '@salesforce/label/c.PMP_EditOffering';
// import tableOfContentsLabel from '@salesforce/label/c.PMP_Table_Of_Contents';
// import loadingLabel from '@salesforce/label/c.PMP_Loading';
// import clearCacheButtonLabel from '@salesforce/label/c.PMP_ClearCache';

/* Internal Imports */
//import { formatOfferingDetailData, defaultData } from './data';

/* Loading Screen */
//import loadingTemplate from './loading.html';

/* Offering Template */
//import mainTemplate from './ipaOfferingDetail.html';

/**
 * Simple UI Component for the Offering Detail
 * Contains custom labels, data loader, UI templates
 * Contains minimal business logic
 *
 * @augments LightningElement
 * @property {string} recordId offering id
 * @property {boolean} previewMode preview mode
 */
class IpaOfferingDetail extends NavigationMixin(LightningElement) {
    /**
   * Status of the preview mode
   *
   * @type {string}
   * @public
   */
  @api previewMode;
  /**

  /**
   * Id of the current record
   *
   * @type {string}
   * @public
   */
  @api recordId;

//   /**
//    * Status of the preview mode
//    *
//    * @type {string}
//    * @public
//    */
//   @api previewMode;
//   /**
//    * Flag of active section to avoid multiple calls on the scroll
//    *
//    * @type {string}
//    * @private
//    */
//   isAdded;

//   /**
//    * Current active section which will be used to check in the scroll method
//    *
//    * @type {string}
//    * @private
//    */
//   currentSection;

//   /**
//    * Custom Labels
//    *
//    * @type {object}
//    * @private
//    */
//   labels = {
//     yes: yesLabel,
//     about: aboutLabel,
//     overviewHeadline: overviewLabel,
//     techSpecsHeadline: techSpecLabel,
//     qualityMetricsTableHeader: qualityMetricsTableHeaderLabel,
//     includedIntelTechHeadline: intelTechLabel,
//     tabDescription: descriptionLabel,
//     tabDetails: offeringDetailsLabel,
//     tabResources: resourcesLabel,
//     messaging: messagingLabel,
//     allCompanyOfferings: allCompanyOfferingsLabel,
//     companyResources: companyResourcesLabel,
//     articlesAndNewspapers: articlesAndNewspapersLabel,
//     articlesViewAll: articlesViewAllLabel,
//     marketingInfo: marketingInfoLabel,
//     disclaimer,
//     disclaimer2,
//     disclaimerUrl,
//     cloneOfferingButton: cloneButtonLabel,
//     editOfferingButton: editButtonLabel,
//     updateDateButton: updateDateButtonLabel,
//     tableOfContents: tableOfContentsLabel,
//     loading: loadingLabel,
//     clearCacheButton: clearCacheButtonLabel,
//   };

//   /** The main data object for all of the offering detail data
//    * - defaults are found in 'data.js'
//    * - real data loaded through ipaOfferingService
//    *
//    * @type {defaultData.OfferingDetailData}
//    * @private
//    */
//   data = {};

//   /** tracks if offering data is loaded to show loading template
//    *
//    * @type {boolean}
//    * @private
//    */
//   dataLoaded;

//   /** tracks if date update modal is open
//    *
//    * @type {boolean}
//    * @private
//    */
//   showDateUpdateModal;

//   /**
//    * List of jump link labels for c-ipa-jump-link component
//    *
//    * @returns {string[]} list of jump links
//    * @private
//    */
//   get jumplinks() {
//     return [
//       this.labels.overviewHeadline,
//       this.labels.techSpecsHeadline,
//       this.data.qualityMetrics.length ? this.data.qualityMetricsLabel : '',
//       this.data.intelTechnology.length ? this.labels.includedIntelTechHeadline : '',
//       this.data.resources.length ? this.labels.tabResources : '',
//       this.currentScreen.isTablet ? this.labels.marketingInfo : '',
//     ].filter((link) => link);
//   }

//   /** only shows "Messaging" chat component if url param exists
//    *
//    * @returns {boolean} if data exists
//    * @private
//    */
//   get showMessagingComponent() {
//     return !!this.getJsonFromUrl().viewChat;
//   }

//   /** working record id
//    *
//    * @returns {string} offering id
//    * @private
//    */
//   get workingId() {
//     return this.data.workingCopyId || this.recordId;
//   }

//   /**
//    * Indicates if contact partner button should be displayed
//    *
//    * @returns {boolean} contact partner visible
//    * @private
//    */
//   get showContactPartnerButton() {
//     return this.data.showContactPartner;
//   }

//   /**
//    * connected callback
//    * - loads data
//    * - adds scroll handler
//    *
//    * @private
//    */
//   connectedCallback() {
//     if (this.previewMode) {
//       loadStyle(this, `${IpaResources}/overrides/ipaOfferingDetailPreview.css`);
//     }
//     this.isLoading = true;
//     this.loadData();
//     window.addEventListener('scroll', this.handleScroll.bind(this));
//   }

//   /**
//    * disconnected callback
//    * - removes scroll handler
//    *
//    * @private
//    */
//   disconnectedCallback() {
//     window.removeEventListener('scroll', this.handleScroll.bind(this));
//   }


//   /**
//    * Allow user to scroll through the page if modal was opened in preview mode
//    *
//    * @private
//    */
//   handleModalOpen() {
//     if (this.previewMode) {
//       // eslint-disable-next-line @lwc/lwc/no-async-operation
//       window.setTimeout(() => {
//         document.body.style.overflow = 'auto';
//       }, 20);
//     }
//   }

//   /**
//    * Allow user to scroll through the page if modal was opened in preview mode
//    *
//    * @private
//    */
//   handleModalOpen() {
//     if (this.previewMode) {
//       // eslint-disable-next-line @lwc/lwc/no-async-operation
//       window.setTimeout(() => {
//         document.body.style.overflow = 'auto';
//       }, 20);
//     }
//   }

//   /**
//    * handle scroll
//    *
//    * @private
//    */
//   handleScroll() {
//     if (!this.previewMode && !this.currentScreen.isMobile) {
//       this.handleScrollForJumpLinks();
//     }
//   }

//   /** render loading template or main detail template
//    *
//    * @returns {any} template
//    * @private
//    */
//   render() {
//     return this.dataLoaded ? mainTemplate : loadingTemplate;
//   }

//   /**
//    * loads data using ipaOfferingService
//    * - formats data (and adds defaults)
//    * - current error handling in Service (stays on loading screen)
//    *
//    * @async
//    * @private
//    */
//   async loadData() {
//     try {
//       const isValidOffering = await checkValidOffering({ offeringId: this.recordId, isPreview: this.previewMode });
//       if (!isValidOffering) {
//         window.location.href = errorPageUrl;
//         return;
//       }

//       // Marquee data could be refactored out into one obj (w/ ipaOfferingService refactor)
//       const {
//         offeringDetailData,
//         marqueeData,
//       } = await getOfferingDetails({ offeringId: this.recordId, Preview: this.previewMode });
//       this.data = {
//         ...formatOfferingDetailData(offeringDetailData, {
//           isPreviewMode: this.previewMode,
//         }),
//         ...marqueeData,
//       };
//       console.log('check this.data --> ',this.data);

//       this.dataLoaded = true;
//     } catch (e) {
//       handleError(e, 'ipaOfferingDetail - loadData');
//     }
//   }

//   /**
   
//    * Clear cache Offering
//    *
//    * @async
//    * @private
//    */
//   async handleClearCacheOffering() {
//     try {
//       const response = await removeRecordCache({
//         recordId: this.recordId,
//         objectName: 'OfferingDetail',
//       });
//       const newresponse = JSON.parse(response);
//       if (newresponse === true) {
//         const evt = new ShowToastEvent({
//           title: 'Success!',
//           message: 'Cleared Cache',
//           variant: 'success',
//           mode: 'dismissable',
//           duration: '5000',
//           key: 'info_alt',
//         });
//     this.dispatchEvent(evt);
//     window.location.reload();
//     }
//     } catch (e) {
//       handleError(e, 'ipaOfferingDetail - clearCache');
//     }
//   }

//   /**
//    * Clone Offering, then navigate to cloned record
//    *
//    * @async
//    * @private
//    */
//   async handleCloneOffering() {
//     this.dataLoaded = false;
//     try {
//       const response = await cloneOfferingDetail({
//         offeringId: this.workingId,
//         language: this.data.displayLanguage,
//       });
//       const newresponse = JSON.parse(response);
//       if (newresponse.isSuccessful && newresponse.objectData.clonedRecId) {
//         this[NavigationMixin.Navigate]({
//           type: 'standard__namedPage',
//           attributes: {
//             pageName: 'offering-edit',
//           },
//           state: {
//             recordId: newresponse.objectData.clonedRecId,
//           },
//         });
//       } else {
//         handleError(new Error(`No Record Id Returned - ${response}`), 'ipaOfferingDetail - @PMP_OfferingDetailsController.cloneOfferingDetail');
//       }
//     } catch (e) {
//       handleError(e, 'ipaOfferingDetail - @PMP_OfferingDetailsController.cloneOfferingDetail');
//     }
//   }

//   /**
//    * handle Change Date button click
//    *
//    * @private
//    */
//   handleDateUpdate() {
//     this.showDateUpdateModal = true;
//   }

//   /**
//    * handleClose change date modal
//    *
//    * @private
//    */
//   handleCloseDateUpdateModal() {
//     this.showDateUpdateModal = false;
//   }

//   /** Edit Page link Page Reference
//    *
//    * @returns {object} page reference
//    * @private
//    */
//   get editOfferingPageReference() {
//     return {
//       type: 'standard__namedPage',
//       attributes: {
//         pageName: 'offering-edit',
//       },
//       state: {
//         recordId: this.workingId,
//         lang: this.data.displayLanguage,
//       },
//     };
//   }

//   /** gets query params from url
//    *
//    * @returns {object} url params
//    * @private
//    */
//   getJsonFromUrl() {
//     const query = window.location.search.substr(1);
//     const result = {};
//     query.split('&').forEach((part) => {
//       const item = part.split('=');
//       result[item[0]] = decodeURIComponent(item[1]);
//     });
//     return result;
//   }

//   /** current screen information
//    *
//    * @returns {object} current screen
//    * @private
//    */
//   currentScreen = { isMobile: false };

//   /**
//    * screen change (using coreIntcUtilities)
//    *
//    * @param {event} evt screen change event
//    * @private
//    */
//   handleScreenChange(evt) {
//     this.currentScreen = evt.detail.screen;
//     // if going from tablet -> desktop reduces jump links...
//     this.currentSection = Math.min((this.currentSection || 0), this.jumplinks.length - 1);
//     if (!this.currentScreen.isMobile) {
//       const links = this.template.querySelector('c-ipa-jump-links');
//       if (links) {
//         links.handleScroll(this.currentSection);
//       }
//     }
//   }

//   /**
//    * method to scroll to the particular section based on the clcik on the jump link section
//    * evt.detail will hold the data-id from the jump link corresponding section in detail page
//    *
//    * @param {event} evt clickevent
//    * @private
//    */
//   handleSelectedSection(evt) {
//     if (!this.previewMode) {
//       const newSection = evt.detail;
//       this.skipHighlightJumpLinks = true;
//       const allSections = this.template.querySelectorAll('.offering-detail-section');
//       let selectedSection = allSections[newSection];
//       const header = this.template.querySelector('.header-container');
//       selectedSection = newSection === '0' ? header : selectedSection;
//       if (selectedSection) {
//         selectedSection.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' });
//       }
//       this.currentSection = newSection;
//     }
//   }

//   /**
//    * method which will be called on the scroll and check the offsetTop against window's pageYOffset
//    * call the jump link's method by passing the current section's data-id
//    *
//    * @private
//    */
//   handleScrollForJumpLinks() {
//     this._scrolling = true;
//     clearTimeout(this._scrollTimer);
//     // eslint-disable-next-line @lwc/lwc/no-async-operation
//     this._scrollTimer = setTimeout(() => {
//       this._scrolling = false;
//       this.skipHighlightJumpLinks = false;
//     }, 300);

//     if (!this.skipHighlightJumpLinks) {
//       const oldSection = this.currentSection;
//       const sections = this.template.querySelectorAll('.offering-detail-section');
//       sections.forEach((section, idx) => {
//         const sectionTop = section.offsetTop - (window.innerHeight / 3);
//         if (window.pageYOffset >= sectionTop) {
//           this.currentSection = idx;
//         }
//       });
//       if ((window.innerHeight + window.pageYOffset) >= (document.body.offsetHeight - 5)) {
//         this.currentSection = sections.length - 1; // for really tall viewports
//       }
//       if (oldSection !== this.currentSection) {
//         const links = this.template.querySelector('c-ipa-jump-links');
//         if (links) {
//           links.handleScroll(this.currentSection);
//         }
//       }
//     }
//   }

//   /**
//    * getter for details classes to adjust based on the current screen properies.
//    *
//    * @returns {string} css classes
//    * @private
//    */
//   get detailsContainerClass() {
//     return [
//       'slds-col slds-size_12-of-12 slds-medium-size_8-of-12 slds-large-size_6-of-12',
//       'offering-details slds-p-left_medium slds-p-right_medium',
//       this.currentScreen.isMobile ? 'slds-p-top_x-small' : 'slds-p-top_small',
//     ].join(' ');
//   }
// }
}export default IpaOfferingDetail;