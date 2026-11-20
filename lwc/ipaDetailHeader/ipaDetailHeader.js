import { LightningElement, api } from 'lwc';
// custom labels
import goldPartner from '@salesforce/label/c.PMP_GoldPartner';
import titaniumPartner from '@salesforce/label/c.PMP_TitaniumPartner';
import memberPartner from '@salesforce/label/c.PMP_MemberPartner';
import byLabel from '@salesforce/label/c.PMP_By';
import lastUpdatedLabel from '@salesforce/label/c.PMP_L3_Marquee_Last_Updated';
import cacheCaptureTimeLabel from '@salesforce/label/c.PMP_L3_Marquee_Cache_Capture_Time';
import noCachedDatalabel from '@salesforce/label/c.PMP_L3_Marquee_No_Cached_Data';

import mobileStorefront from './mobileStorefrontHeader.html';
import defaultStorefront from './ipaStorefrontDetailHeader.html';
import mobileOffering from './mobileOfferingHeader.html';
import defaultOffering from './ipaOfferingDetailHeader.html';

/**
 * @typedef Badge
 * @property {string} name Name of the badge
 * @property {string} icon Name of the icon class, only one of icon/image must be defined.
 * @property {string} image Name of the image, only one of icon/image must be defined.
 */
/**
 * Header component used for offering detail and storefront detail pages.
 *
 * @property {string} logoUrl URL of the logo
 * @property {string} logoAlt alt text for the logo
 * @property {string} [headline=Headline] headLine text
 * @property {string} [tagline=Tagline] tagLine text
 * @property {boolean} isMobile Indicates whether component is mobile
 * @property {string} [headerType=offering] Determines whether storefront or offering header should be used
 * @property {object} contactPartnerAnalyticsDetails Object containing analytic data for contact partner
 * @property {object} contactPartnerModalData Object containing contact partner modal data
 * @property {boolean} contactPartnerVisible Determines whether contact should be visible or not
 * @property {boolean} previewMode preview mode
 * -- Properties used by Offering --
 * @property {string} lastModified Last modified date of the offering
 * @property {string} cacheTime Cache capture time of the offering
 * @property {string} internalAdmin check isAdmin of the offering
 * @property {string} offeringOwner Name of the offering owner
 * @property {string} offeringOwnerId Id of the Offering owner
 * -- Properties used by Storefront
 * @property {Badge[]} badges List of badges (used by Storefront)
 * @property {string} partnerStatus status level (ie. 'gold' / 'titanium')
 * @property {string} partnerRole role for Partner (ie. "Partner Role")
 * @augments LightningElement
 */
class IpaDetailHeader extends LightningElement {
  @api
  logoUrl;

  @api
  logoAlt;

  @api
  tagline = 'Tagline';

  @api
  headline = 'Headline';

  @api
  badges;

  @api
  headerType = 'offering';

  @api
  isMobile;

  @api
  lastModified;

  @api
  cacheTime;

  @api
  internalAdmin;

  @api
  offeringOwner;

  @api
  offeringOwnerId;

  @api
  contactPartnerAnalyticsDetails;

  @api
  contactPartnerModalData;

  @api
  contactPartnerVisible;

  @api
  previewMode;

  @api
  partnerStatus;

  @api
  partnerRole;

  /**
   * Icon class of partner status
   *
   * @returns {string} Name of the Icon class
   * @private
   */
  get partnerStatusIconClass() {
    const styleClasses = ['fa-bookmark'];
    if (this.partnerStatus === 'gold') {
      styleClasses.push('partner-status-gold');
    } else if (this.partnerStatus === 'titanium') {
      styleClasses.push('partner-status-titanium');
    }
    return styleClasses.join(' ');
  }

  /**
   * Return badges with iconClass. Partner status and partner role is added if present
   *
   * @private
   * @returns {Badge[]} badges with iconClass attribute
   */
  get formattedBadges() {
    const fBadges = this.badges.map((badge) => {
      if (badge.icon) {
        return { ...badge, iconClass: `slds-m-right_x-small intel-icon ${badge.icon}` };
      }
      return badge;
    });
    if (this.partnerStatusLabel) {
      const partnerBadge = { name: this.partnerStatusLabel, iconClass: `slds-m-right_x-small intel-icon ${this.partnerStatusIconClass}` };
      fBadges.unshift(partnerBadge);
    }
    if (this.partnerRole) {
      const roleBadge = { name: this.partnerRole };
      fBadges.push(roleBadge);
    }
    return fBadges;
  }

  /**
   * Custom labels
   *
   * @type {object}
   * @private
   */
  labels = {
    by: byLabel, lastUpdated: lastUpdatedLabel, cacheTimelabel: cacheCaptureTimeLabel, noCachedDatalabel,
  };

  /**
   * Returns template based on device
   *
   * @returns {object} Layout used for rendering
   */
  render() {
    if (this.headerType === 'storefront') {
      return this.isMobile ? mobileStorefront : defaultStorefront;
    }
    if (this.headerType === 'offering') {
      return this.isMobile ? mobileOffering : defaultOffering;
    }
    return this.isMobile ? mobileStorefront : defaultStorefront;
  }

  /**
   * Returns partner status label
   *
   * @returns {string} partner status label
   * @private
   */
  get partnerStatusLabel() {
    switch (this.partnerStatus) {
      case 'gold':
        return goldPartner;
      case 'titanium':
        return titaniumPartner;
      case 'member':
        return memberPartner;
      default:
        return '';
    }
  }
}
export default IpaDetailHeader;