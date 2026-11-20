import { LightningElement, api, wire } from 'lwc';
import { makeIpaAnalyticsCall } from 'c/ipaAnalyticsService';
import contactPartner from '@salesforce/label/c.PMP_Contact_Partner';
import askAQuestion from '@salesforce/label/c.PMP_LeadGen_AskAQuestion';
import requestAQuote from '@salesforce/label/c.PMP_Request_A_Quote';
import { publish, MessageContext } from 'lightning/messageService';
import ipaMarketplaceChannel from '@salesforce/messageChannel/ipaMarketplace__c';

/** Modal Data
 * Both Product/Partner Data
 *
 * @typedef ModalData
 * @property {string} name name
 * @property {string} id id
 * @property {string} autoPartnerId partner id
 * @property {string} leadLangPreference language
 * @property {string} isLoggedIn is user logged in?
 * Just Product Data
 * @property {string} title product title
 * @property {string} oid product oID
 * @property {string} offRecId record id
 *
 */

/** Contact Partner button
 * can be a single button or a button menu dropdown
 * action opens the Contact Partner form
 *
 * @augments LightningElement
 * @property {boolean} autoScroll scrolls elements into view on open/close
 * @property {boolean} isMenu determines if a single button or "button menu" is shown
 * @property {ModalData} modalData data for the Contact Partner Form
 * @property {string[]} analyticsDetails details for the analytics call
 * @property {boolean} [previewMode] preview mode (disable button action)
 * @fires action when an menu item is activated
 */
class IpaContactPartnerButton extends LightningElement {
  @api autoScroll;

  @api isMenu

  @api modalData = {};

  @api analyticsDetails = [];

  @api previewMode;

  // To pass scope, you must get a message context.
  @wire(MessageContext)
  messageContext;

  /** label for button "Contact Partner"
   *
   * @type {string} label
   * @private
   */
  contactPartnerLabel = contactPartner;

  /** formats link objects for template
   *
   * @returns {object[]} contact partner menu items
   * @private
   */
  get contactLinks() {
    return [
      { label: askAQuestion, action: 'askQuestion' },
      { label: requestAQuote, action: 'requestQuote' },
    ];
  }

  /** formats data for template
   * includes refresh key or UI refresh
   *
   * @returns {object} data with refresh key
   * @private
   */
  get data() {
    return {
      ...this.modalData,
      refreshKey: Math.random(),
    };
  }

  /**
   * event handler for contact partner button (not menu)
   *
   * @private
   */
  handleContactPartnerButton() {
    this.handleContactAction({ detail: 'askQuestion' });
  }

  /** handle action item
   * - publishes message to open form
   * - dispatches custom event
   * - makes analytics call
   *
   * @param {event} evt menu button action
   * @private
   */
  handleContactAction(evt) {
    if (this.previewMode) {
      return;
    }

    // publish message on channel to open Contact Form
    const modalType = evt.detail;
    const payload = { modalType, modalData: this.modalData };
    publish(this.messageContext, ipaMarketplaceChannel, { type: 'contactPartnerModal', payload });

    // dispatch custom event
    this.dispatchEvent(new CustomEvent('action'));

    // makes analytics call
    const analyticsObj = {
      analyticsType: 'click',
      element: modalType === 'askQuestion' ? 'ask-a-question' : 'request-a-quote',
      details: this.analyticsDetails.join('|'),
    };
    makeIpaAnalyticsCall(analyticsObj);
  }

  /**
   * handle menu toggle (for analytics)
   */
  handleContactToggle() {
    const details = ['expand:'].concat(this.analyticsDetails);
    const analyticsObj = {
      analyticsType: 'click',
      element: 'contact-partner',
      details: details.join('|'),
    };
    makeIpaAnalyticsCall(analyticsObj);
  }
}
export default IpaContactPartnerButton;