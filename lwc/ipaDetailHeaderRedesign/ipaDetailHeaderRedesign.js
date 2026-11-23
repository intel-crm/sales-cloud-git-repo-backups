// import { LightningElement, api } from 'lwc';
// // custom labels
// import companyWebsiteLabel from '@salesforce/label/c.PMP_Company_Website';
// import goldPartner from '@salesforce/label/c.PMP_GoldPartner';
// import titaniumPartner from '@salesforce/label/c.PMP_TitaniumPartner';
// import memberPartner from '@salesforce/label/c.PMP_MemberPartner';
// import byLabel from '@salesforce/label/c.PMP_By';
// import mobileStorefront from './mobileStorefrontHeader.html';
// import defaultStorefront from './ipaStorefrontDetailHeader.html';
// // import mobileOffering from './mobileOfferingHeader.html';
// // import defaultOffering from './ipaOfferingDetailHeader.html';

// /**
//  * @typedef Badge
//  * @property {string} name Name of the badge
//  * @property {string} icon Name of the icon class, only one of icon/image must be defined.
//  * @property {string} image Name of the image, only one of icon/image must be defined.
//  */
// /**
//  * Header component used for offering detail and storefront detail pages.
//  *
//  * @property {string} logoUrl URL of the logo
//  * @property {string} logoAlt alt text for the logo
//  * @property {string} [headline=Headline] headLine text
//  * @property {string} [tagline=Tagline] tagLine text
//  * @property {boolean} isMobile Indicates whether component is mobile
//  * @property {string} [headerType=offering] Determines whether storefront or offering header should be used
//  * @property {object} contactPartnerAnalyticsDetails Object containing analytic data for contact partner
//  * @property {object} contactPartnerModalData Object containing contact partner modal data
//  * @property {boolean} contactPartnerVisible Determines whether contact should be visible or not
//  * @property {boolean} previewMode preview mode
//  * @property {object[]} tabs Array of tab objects to display.
//  * -- Properties used by Offering --
//  * @property {string[]|object[]} images The images to display for the offering.
//  * @property {string} offeringOwner Name of the offering owner
//  * @property {string} offeringOwnerId Id of the Offering owner
//  * -- Properties used by Storefront
//  * @property {Badge[]} badges List of badges (used by Storefront)
//  * @property {string} companyDescriptionLabel The CompanyInformation label.
//  * @property {object} companyInfo The companyInfo object passed from the backend.
//  * @property {string} pageName The page name used in analytics.
//  * @property {string} partnerStatus status level (ie. 'gold' / 'titanium')
//  * @property {string} partnerRole role for Partner (ie. "Partner Role")
//  * @augments LightningElement
//  */
// class IpaDetailHeaderRedesign extends LightningElement {
//   @api
//   logoUrl;

//   @api
//   logoAlt;

//   @api
//   tagline = 'Tagline';

//   @api
//   headline = 'Headline';

//   @api
//   badges;

//   // @api
//   // headerType = 'offering';

//   @api
//   isMobile;

//   // @api
//   // offeringOwner;

//   // @api
//   // offeringOwnerId;

//   @api
//   contactPartnerAnalyticsDetails;

//   @api
//   contactPartnerModalData;

//   @api
//   contactPartnerVisible;

//   @api
//   previewMode;

//   @api
//   partnerStatus;

//   @api
//   partnerRole;

//   @api
//   companyDescriptionLabel;

//   @api
//   companyInfo;

//   @api
//   pageName;

//   @api
//   images;

//   @api
//   tabs;


//   /**
//    * Returns the CSS classes to use for the partner badge.
//    *
//    * @private
//    * @returns {string} CSS classes to use for the badge.
//    */
//   get badgeClass() {
//     let iconClass = '';
//     if (this.partnerStatusLabel) {
//       iconClass = `intel-icon ${this.partnerStatusIconClass}`;
//     }
//     return iconClass;
//   }

//   /**
//    * Returns company website label
//    *
//    * @returns {string} company website label
//    * @private
//    */
//   get companyWebsiteLabel() {
//     return (this.companyInfo) ? companyWebsiteLabel.replace('{0}', this.companyInfo.websiteLabel) : '';
//   }

//   /**
//    * Returns CSS classes to use for the offerings gallery container.
//    *
//    * @returns {string} CSS classes to use for the offerings gallery container.
//    * @private
//    */
//   // get offeringGalleryClass() {
//   //   let cssClasses = 'slds-col slds-size_1-of-1 slds-medium-size_5-of-12 slds-large-size_6-of-12';
//   //   if (this.images && this.images.length > 1) {
//   //     cssClasses += ' gallery-offset';
//   //   }
//   //   return cssClasses;
//   // }

//   /**
//    * Icon class of partner status
//    *
//    * @returns {string} Name of the Icon class
//    * @private
//    */
//   get partnerStatusIconClass() {
//     const styleClasses = ['fa-bookmark'];
//     if (this.partnerStatus === 'gold') {
//       styleClasses.push('partner-status-gold');
//     } else if (this.partnerStatus === 'titanium') {
//       styleClasses.push('partner-status-titanium');
//     }
//     return styleClasses.join(' ');
//   }

//   /**
//    * Custom labels
//    *
//    * @type {object}
//    * @private
//    */
//   labels = {
//     by: byLabel,
//   };

//   /**
//    * Returns template based on device
//    *
//    * @returns {object} Layout used for rendering
//    */
//   render() {
//     if (this.headerType === 'storefront') {
//       return this.isMobile ? mobileStorefront : defaultStorefront;
//     }
//     // if (this.headerType === 'offering') {
//     //   return this.isMobile ? mobileOffering : defaultOffering;
//     // }
//     return this.isMobile ? mobileStorefront : defaultStorefront;
//   }

//   /**
//    * Returns partner status label
//    *
//    * @returns {string} partner status label
//    * @private
//    */
//   get partnerStatusLabel() {
//     switch (this.partnerStatus) {
//       case 'gold':
//         return goldPartner;
//       case 'titanium':
//         return titaniumPartner;
//       case 'member':
//         return memberPartner;
//       default:
//         return '';
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
//    * Publishes an event picked up by the parent for when the user changes tabs.
//    *
//    * @param {event} evt Tab change event.
//    *
//    * @private
//    */
//   handleTabChange(evt) {
//     const selectedEvent = new CustomEvent('selected', { detail: evt.detail.label });
//     this.dispatchEvent(selectedEvent);
//   }
// }
 export default IpaDetailHeaderRedesign;