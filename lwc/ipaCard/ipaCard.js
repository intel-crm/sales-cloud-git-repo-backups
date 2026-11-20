import { LightningElement, api, track } from 'lwc';
import { getPartnerDetails } from 'c/ipaPartnerService';
import { makeIpaAnalyticsCall } from 'c/ipaAnalyticsService';

// Custom Labels
import goldPartner from '@salesforce/label/c.PMP_GoldPartner';
import titaniumPartner from '@salesforce/label/c.PMP_TitaniumPartner';
import memberPartner from '@salesforce/label/c.PMP_MemberPartner';
import byLabel from '@salesforce/label/c.PMP_By';
import viewFullOfferingDetailsLabel from '@salesforce/label/c.PMP_View_Full_Offering_Details';
import viewFullPartnerDetailsLabel from '@salesforce/label/c.PMP_View_Full_Partner_Details';
import viewWebsiteLabel from '@salesforce/label/c.PMP_View_Website';
import categoriesLabel from '@salesforce/label/c.PMP_Search_Categories_Filter';
import loadingTemplate from './loading.html';
import cardTemplate from './ipaCard.html';

/** a Partner attribute and its list of values shown on the Partner card (ie. "Application Expertise")
 *
 * @typedef Attribute
 * @property {string} title title
 * @property {string[]} values attribute values
 */

/** Partner Specialty
 *
 * @typedef Specialty
 * @property {string} title title (ie. "Enthusiast PC Specialist")
 * @property {string} [iconImgUrl] image src for an image to be used as an icon
 * @property {string} [icon] icon name for custom font icon use (ie. 'fa-cancel')
 * @property {string} [sfIcon] [Salesforce]{@link https://lightningdesignsystem.com/icons/#utility} Salesforce icon name
 */

/** Documentation for the product/partner Card Component
 * <br>
 * ⏳ Property can be lazyloaded
 *
 * @example
 * <!-- HTML component example -->
 * <c-ipa-card
 *      card={cardData}
 *      lazyload
 *      is-loading
 *      hide-image-variation></c-ipa-card>
 *
 * @property {object} card data
 * @property {string} card.cardType type of card... can be 'product', 'partner', or 'member'
 * @property {string} card.id Salesforce Id
 * @property {string} card.compareCategoryId Salesforce Id for second-tier category for ipaCompareCheckbox (product cards only)
 * @property {string} card.imageUrl image for card
 * @property {string} card.title title for card (Partner Name / Product Name)
 * @property {string} [card.description] description for card
 * @property {string} [card.distributorWebsite] distributor website
 * @property {string} [card.distributorTagline] distributor tagline
 * @property {string} [card.website] website for card
 * @property {string} [card.partnerName] name of Partner <i>(NOTE: will be same as title for partner cards)</i>
 * @property {string} [card.partnerByLine] byline for Partner (ie. "4.2k Solutions Deployed")
 * @property {string} [card.partnerRole] role for Partner (ie. "Partner Role")
 * @property {string} [card.partnerStatus] status level (ie. 'gold' / 'titanium')
 * @property {boolean} [card.contactPartnerVisible] show/hide "Contact Partner" button/dropdown
 * @property {object} [card.categoryL1] top level category
 * @property {string} [card.categoryL1.Id] salesforce Id
 * @property {string} [card.categoryL1.Name] label name
 * @property {object|object[]} [card.categoryL2] top level category (NOTE: can be list)
 * @property {string} [card.categoryL2.Id] salesforce Id
 * @property {string} [card.categoryL2.Name] label name
 * @property {object|object[]} [card.categoryL3] top level category (NOTE: can be list)
 * @property {string} [card.categoryL3.Id] salesforce Id
 * @property {string} [card.categoryL3.Name] label name
 * @property {Attribute[]} [card.partnerAttributes] ⏳ list of attribute values for partner (do not include Categories here)
 * @property {Specialty[]} [card.partnerSpecialties] ⏳ list of specialty values for partner
 * @property {boolean} [lazyload=false] lazy load partner details in Quick View
 * @property {boolean} [isLoading=false] show loading template while waiting for data
 * @property {boolean} [hideImageVariation=false] temporary flag for card variation w/o images
 * @property {boolean} [hideAddToCompare=false] removes "Add to Compare" checkbox from product cards
 * @augments LightningElement
 */
class IpaCard extends LightningElement {
  @api card = {};

  @api lazyload;

  @api isLoading = false;

  @api hideImageVariation = false;

  @api hideAddToCompare = false;

  /**
   * Custom labels
   *
   * @type {object}
   * @private
   */
  labels = {
    categories: categoriesLabel,
    by: byLabel,
    viewFullOfferingDetails: viewFullOfferingDetailsLabel,
    viewFullPartnerDetails: viewFullPartnerDetailsLabel,
    viewWebsite: viewWebsiteLabel,
  };

  /**
   * Current breakpoint
   *
   * @type {object}
   * @private
   */
  @track breakpoint = {};

  /**
   * Lazy loaded card details
   *
   * @type {object}
   * @private
   */
  @track _lazyLoaded = { _loaded: false };

  /**
   * Connected callback - validates card type
   *
   * @private
   */
  connectedCallback() {
    const validTypes = ['product', 'partner', 'member'];
    if (validTypes.indexOf(this.cardType) < 0 && !this.isLoading) {
      throw new Error(`ipaCard: ${this.cardType} is an invalid card type! Must be 'product', 'partner', or 'member'.`);
    }
  }

  /**
   * Returns card type
   *
   * @returns {string} card type
   * @private
   */
  get cardType() {
    return this.card.cardType;
  }

  /**
   * Returns object api name
   *
   * @returns {string} object api name
   * @private
   */
  get objectName() {
    return this.cardType === 'partner' ? 'PMP_Partner__c' : 'PMP_Partner_Offering__c';
  }

  /**
   * Returns card key
   *
   * @returns {number} key
   * @private
   */
  get key() {
    return this.card.id;
  }

  /**
   * Returns image url
   *
   * @returns {string} image url
   * @private
   */
  get imageUrl() {
    return this.card.imageUrl || '';
  }

  /**
   * Indicates whether card has an eyebrow
   *
   * @returns {boolean} card eyebrow
   * @private
   */
  get eyebrow() {
    return this.card.eyebrow || false;
  }

  /**
   * Returns eyebrow tagline
   *
   * @returns {string} eyebrow tagline
   * @private
   */
  get eyebrowTagline() {
    return this.card.eyebrowTagline || '&nbsp;';
  }

  /**
   * Returns card title
   *
   * @returns {string} title
   * @private
   */
  get title() {
    return this.card.title || '';
  }

  /**
   * Returns card description
   *
   * @returns {string} description
   * @private
   */
  get description() {
    return this.card.description || '';
  }

  /**
   * Returns card website
   *
   * @returns {string} website
   * @private
   */
  get website() {
    return this.card.website || '';
  }

  /**
   * Returns card website host
   *
   * @returns {string} card website host
   * @private
   */
  get websiteLabel() {
    if (this.website) {
      const url = new URL(this.website);
      return url.host;
    }
    return '';
  }

  /**
   * Returns L1 category
   *
   * @returns {object} L1 category
   * @private
   */
  get categoryL1() {
    return this.card.categoryL1 || {};
  }

  /**
   * Returns array of L2 categories
   *
   * @returns {object[]} L2 categories
   * @private
   */
  get categoryL2() {
    return [].concat(this.card.categoryL2 || []);
  }

  /**
   * Returns array of L3 categories
   *
   * @returns {object[]} L3 categories
   * @private
   */
  get categoryL3() {
    return [].concat(this.card.categoryL3 || []);
  }

  /**
   * Returns array of card categories
   *
   * @returns {object[]} card categories
   * @private
   */
  get categories() {
    return [this.categoryL1.Name]
      .concat(this.categoryL2.map((cat) => cat.Name))
      .concat(this.categoryL3.map((cat) => cat.Name))
      .filter((content) => content);
  }

  /**
   * Returns card distributor website
   *
   * @returns {string} distributor website
   * @private
   */
  get distributorWebsite() {
    return this.card.distributorWebsite || '';
  }

  /**
   * Returns card distributor website host
   *
   * @returns {string} distributor host
   * @private
   */
  get distributorWebsiteLabel() {
    if (this.distributorWebsite) {
      const url = new URL(this.distributorWebsite);
      return url.host;
    }
    return '';
  }

  /**
   * Returns card distributor tagline
   *
   * @returns {string} distributor tagline
   * @private
   */
  get distributorTagline() {
    return this.card.distributorTagline || '';
  }

  /**
   * Returns partner name
   *
   * @returns {string} partner name
   * @private
   */
  get partnerName() {
    return this.card.partnerName || '';
  }

  /**
   * Returns partner byline
   *
   * @returns {string} partner byline
   * @private
   */
  get partnerByLine() {
    return this.card.partnerByLine || '';
  }

  /**
   * Returns partner status
   *
   * @returns {string} partner status
   * @private
   */
  get partnerStatus() {
    return this.card.partnerStatus || '';
  }

  /**
   * Returns partner role
   *
   * @returns {string} partner role
   * @private
   */
  get partnerRole() {
    return this.card.partnerRole || '';
  }

  /**
   * Returns partner attributes
   * Card shows first 5 attributes with a "Show More" expander
   * "Show less" intro is first 5 attributes
   *
   * @returns {Attribute[]} partner attributes
   * @private
   */
  get partnerAttributes() {
    return (this._lazyLoaded.partnerAttributes || this.card.partnerAttributes || []).map((att) => {
      const values = att.values || [];
      return {
        ...att,
        all: values.join(', '),
        sample: values.slice(0, 5).join(', '),
      };
    });
  }

  /**
   * Returns partner specialties
   *
   * @returns {Specialty[]} partner specialties
   * @private
   */
  get partnerSpecialties() {
    return (this._lazyLoaded.partnerSpecialties || this.card.partnerSpecialties || []).map((sp) => ({
      ...sp,
      iconClass: `icon ${sp.icon}`,
    }));
  }

  /**
   * Returns partner status label
   *
   * @returns {string} partner status label
   * @private
   */
  get partnerStatusLabel() {
    switch (this.card.partnerStatus) {
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

  /**
   * Indicates whether contact partner button is visible
   *
   * @returns {boolean} if contact partner is visible
   */
  get contactPartnerVisible() {
    return this.card.contactPartnerVisible !== undefined ? this.card.contactPartnerVisible : true;
  }

  /**
   * Returns card data for ipaCompareCheckbox
   *
   * @returns {object} card comparison data
   * @private
   */
  get compareProductData() {
    return {
      id: this.card.id,
      imageUrl: this.imageUrl,
      title: this.title,
      compareCategoryId: this.card.compareCategoryId,
    };
  }

  /**
   * Returns card CSS classes for HTML Markup
   *
   * @returns {string} classes
   * @private
   */
  get cardClasses() {
    return ['card', 'bg-white', `partner-status-${this.partnerStatus}`].join(' ');
  }

  /**
   * Returns object composed of boolean helper properties
   *
   * @returns {object} helper
   * @private
   */
  get ifs() {
    return {
      isProductCard: this.cardType === 'product',
      isPartnerCard: this.cardType === 'partner',
      isMemberPartner: this.cardType === 'member',
      showLazyLoadSpinner: this.lazyload && !this._lazyLoaded._loaded,
      showWebsite: this.cardType === 'member' && this.website,
    };
  }

  /**
   * Returns window size for ipaCompareCheckbox
   *
   * @returns {string} window size
   * @private
   */
  get addToCompareSize() {
    if (this.breakpoint.isMobile) return 'default';
    return 'small';
  }

  /**
   * Returns partner analytics details for contact menu
   *
   * @returns {string[]} analytics details
   * @private
   */
  get contactPartnerAnalyticsDetails() {
    const details = ['modal_contact-partner'];
    details.push(this.categories.length ? this.categories.join('-') : 'NA');
    details.push(this.card.partnerId);

    if (this.ifs.isProductCard) details.push(this.card.id);
    return details;
  }

  /**
   * Returns contact partner data for contact menu
   *
   * @returns {object} contact partner
   * @private
   */
  get contactPartnerModalData() {
    if (this.cardType === 'partner') {
      return {
        name: this.title,
        id: this.key,
        autoPartnerId: this.card.autoPartnerId,
        leadLangPreference: this.card.leadLangPreference,
        isLoggedIn: !this.card.isGuest,
      };
    }
    // product
    return {
      name: this.card.partnerName,
      id: this.card.partnerId,
      autoPartnerId: (typeof (this.card.autoPartnerId)) != 'undefined' ? this.card.autoPartnerId : this.card.partner.autoPartnerId,
      leadLangPreference: this.card.leadLangPreference,
      title: this.title,
      oid: this.card.autoOffId,
      offRecId: this.key,
      isLoggedIn: !this.card.isGuest,
    };
  }

  /**
   * Returns template to use for rendering the card
   *
   * @returns {object} template
   * @private
   */
  render() {
    return this.isLoading ? loadingTemplate : cardTemplate;
  }

  /**
   * Handles open event for quick view modal
   *
   * @private
   */
  handleOpenQuickView() {
    this.lazyLoadPartnerData();
    this.handleQuickviewAnalyticsCall(true);
  }

  /**
   * Handles close event for Quick View modal
   *
   * @private
   */
  handleCloseQuickView() {
    this.handleQuickviewAnalyticsCall(false);
  }

  /**
   * Creates a data object based on card's properties and
   * send that to the analytics service
   *
   * @param {boolean} expand Indicates if Quick View is open/closed
   * @private
   */
  handleQuickviewAnalyticsCall(expand) {
    const action = expand ? 'expand:' : '';
    const details = []; // CategoryName|PartnerId|ProductId
    details.push(this.categories.length ? this.categories.join('-') : 'NA');

    details.push(this.card.partnerId);
    if (this.ifs.isProductCard) {
      details.push(this.card.id);
    }
    const analyticsObj = {
      analyticsType: 'click',
      element: 'quick-view',
      details: action + details.join('|'),
    };
    makeIpaAnalyticsCall(analyticsObj);
  }

  /**
   * Handles opening the Contact Partner menu and closing the Quick View modal
   *
   * @private
   */
  handleContactAction() {
    this.template.querySelector('c-ipa-quick-view').close();
  }

  /**
   * handle screen change thru breakpoints
   *
   * @param {event} evt screen change event
   */
  handleScreenChange(evt) {
    this.breakpoint = evt.detail.screen;
  }

  /**
   * Lazy loads contact partner data
   *
   * @async
   * @private
   */
  async lazyLoadPartnerData() {
    const partner = await getPartnerDetails({ id: this.card.id });
    this._lazyLoaded = {
      _loaded: true,
      partnerSpecialties: partner.specialties,
      partnerAttributes: partner.attributes,
    };
  }
}
export default IpaCard;