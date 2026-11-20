/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import badgeTagline from '@salesforce/label/c.PMP_Featured';
import learnMore from '@salesforce/label/c.PMP_Learn_More';
import categoryLabel from '@salesforce/label/c.PMP_Category';

/**
 * Documentation for the Storefront Offering/Article card component.
 *
 * @property {string} cardType Can be either 'article' or 'offering'
 * @property {object} card data
 * @property {string} card.title title for card
 * @property {string} card.description description for card
 * @property {boolean} card.featured indicates if card has featured badge or not
 * @property {string} [card.imageUrl] image for card
 * @property {string} [card.imageAlt] alt text for card
 * @property {string} [card.id] Salesforce Id
 * @property {string} [card.tagline] tagline
 * @property {string} [card.externalUrl] external article url
 * @property {string} [card.createdDate] article date of creation
 * @property {object[]} [card.categories] card categories
 *
 * @augments LightningElement
 * @augments NavigationMixin
 */
class IpaStorefrontDetailCard extends NavigationMixin(LightningElement) {
    // Need to delegate the focus behavior to inside the template content
    static delegatesFocus = true;

    @api cardType;

    @api card;

    /**
     * Custom labels
     *
     * @type {object}
     * @private
     */
    labels = {
      badgeTagline,
      learnMore,
      categoryLabel,
    }

    /**
     * Current breakpoint
     *
     * @type {object}
     * @private
     */
   breakpoint = {};

   /**
    * Link to card
    *
    * @type {string}
    * @private
    */
   url = '';

   /**
    * Indicates if card type is offering
    *
    * @returns {boolean} if card is offering
    * @private
    */
   get isOffering() {
     return this.cardType === 'offering';
   }

   /**
    * Indicates if card has image
    *
    * @type {boolean}
    * @private
    */
   get hasImage() {
     return !!this.card.imageUrl;
   }

   /**
    * Indicates if card has a tagline
    *
    * @type {boolean}
    * @private
    */
   get hasTagline() {
     return !!this.card.tagline;
   }

   /**
    * Returns css class for card description
    *
    * @returns {string} class
    * @private
    */
   get descriptionClass() {
     return this.breakpoint.isMobile ? 'truncate-5' : 'truncate-4';
   }

   /**
    * Returns card link for share component
    *
    * @returns {string} card link
    */
   get shareLink() {
     return this.cardType === 'article' ? this.card.externalUrl : this.url;
   }

   /**
    * Handles screen change
    *
    * @param {event} evt screen change event
    */
   handleScreenChange(evt) {
     this.breakpoint = evt.detail.screen;
   }

   /**
    * Connected callback
    */
   connectedCallback() {
     if (this.cardType === 'offering') this.formatLink();
   }

   /**
    * Formats card link for share component
    *
    * @private
    */
   async formatLink() {
     const newPageReference = {
       type: 'standard__recordPage',
       attributes: {
         actionName: 'view',
         objectApiName: 'PMP_Partner_Offering__c',
         recordId: this.card.id,
       },
     };
     const link = await this[NavigationMixin.GenerateUrl](newPageReference);
     this.url = link ? `${window.location.origin}${link}` : '';
   }
} export default IpaStorefrontDetailCard;