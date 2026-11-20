import { LightningElement, api, track } from 'lwc';

import quickViewLabel from '@salesforce/label/c.PMP_Quick_View';
import ariaQuickViewLabel from '@salesforce/label/c.PMP_aria_open_quickview';

/**
 * This is the "Quick View" component of a product/partner card
 * - It opens a modal on desktop, and is hub/spoke on mobile by default
 *
 * @augments LightningElement
 * @property {boolean} hasEyebrow card in quick view has eyebrow (i.e. header)
 * @property {boolean} isQuickView display in quick view mode
 * @property {boolean} isSlim modal display is slim
 * @property {string} modalButtonLabel label for modal open button (displayed if not in quick view mode)
 * @property {string} modalTitle Announces the title of the modal to screen readers (modal by default).
 * @property {boolean} displayMobileModal toggle for displaying modal in mobile view (default is hub/spoke on mobile)
 */
export default class IpaQuickView extends LightningElement {
    @api hasEyebrow;

    @api isQuickView;

    @api isSlim;

    @api modalButtonLabel = '';

    @api modalTitle = 'Modal';

    @api displayMobileModal;

    /**
     * custom labels
     *
     * @type {object}
     * @private
     */
    label = {
      quickView: quickViewLabel,
      ariaQuickView: ariaQuickViewLabel,
    };

    /**
     * State of modal
     *
     * @type {boolean}
     * @private
     */
    isModalOpen;

    /**
     * Current breakpoint
     *
     * @type {object}
     * @private
     */
   @track breakpoint = {};

   /**
    * Checks value of breakpoint
    *
    * @returns {boolean} boolean value
    * @private
    */
   get isHubSpoke() {
     return this.breakpoint.isMobile && !this.displayMobileModal;
   }

   /**
    * Indicates if modal close icon should have inverse display
    *
    * @returns {boolean} close icon inverse
    * @private
    */
    get displayIconInverse() {
      return this.isQuickView && this.hasEyebrow;
    }

   /**
    * Handles opening quick view modal
    *
    * @private
    */
   handleOpenQuickView() {
     this.template.querySelector('c-core-intc-modal').openModal();
   }

   /**
    * Handles opening quick view modal using keys
    *
    * @param {event} event onkeypress event
    * @private
    */
   handleBtnKeyDown(event) {
     if (event.key === 'Enter' || event.key === 'Spacebar') { // "Spacebar" for IE11 support
       this.template.querySelector('c-core-intc-modal').openModal();
       this.dispatchEvent(new CustomEvent('open'));
     }
   }

   /**
    * Handles open event for hub-spoke
    *
    * @private
    */
   handleOpenEvent() {
     this.dispatchEvent(new CustomEvent('open'));
   }

   /**
    * Handles close event for hub-spoke
    *
    * @private
    */
   handleCloseEvent() {
     this.dispatchEvent(new CustomEvent('close'));
   }

   /**
    * handle screen change through breakpoints
    *
    * @param {event} evt screen change event
    */
   handleScreenChange(evt) {
     this.breakpoint = evt.detail.screen;
   }

    /**
     * Closes quick view (both modal and hub-spoke)
     *
     * @public
     */
    @api close() {
     if (this.isHubSpoke) {
       this.template.querySelector('c-core-intc-hub-spoke').close();
     } else {
       this.template.querySelector('c-core-intc-modal').closeModal();
     }
   }
}