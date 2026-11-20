import { LightningElement, api } from 'lwc';

// Custom Labels
import ariaHideContent from '@salesforce/label/c.Core_Intc_Side_Content_Hide';
import ariaShowContent from '@salesforce/label/c.Core_Intc_Side_Content_Show';


/**
 * A component for displaying default content along with additional hidden content. A hub & spoke model is used for
 * mobile resolutions, and an accordion model is used for desktop resolutions. Slots are used to define the default
 * content and the additional hidden content.
 *
 * ### Available Slots
 * * <code>link</code>: An optional slot that is displayed by default. If it is not set, the <code>headline</code> property
 *    is used as the link.
 * * <code>content</code>: The hidden content to be displayed when the user clicks on the <code>link</code> slot.
 *
 * ### Mobile Hub & Spoke Display
 * * For mobile displays (screen resolutions less than 1024px), the hub is the <code>link</code> slot and the spoke is
 * <code>content</code> slot.
 * * When the user clicks on the hub link, the spoke content flys out from the left.
 * * When the spoke is displayed, all other content including the hub is hidden.
 *
 * ### Desktop Accordion Display
 * * For desktop displays (screen resolutions greater than or equal to 1024px), the <code>link</code> slot is the
 *  accordion header and the <code>content</code> slot is the accordion content.
 * * The header and the content can both be displayed at the same time.
 *
 * <div id="core-examples" sf-attr="c-coreintchubspoke_coreintchubspoke">
 *  <demo-core-intc-hub-spoke show1="true"></demo-core-intc-hub-spoke>
 *  <demo-core-intc-hub-spoke show2="true"></demo-core-intc-hub-spoke>
 *  <demo-core-intc-hub-spoke show3="true"></demo-core-intc-hub-spoke>
 * </div>
 *
 * @example
 * <!-- HTML component example 1 -->
 * <!-- Basic example -->
 * <c-core-intc-hub-spoke headline="Click to view content">
 *  <div slot="content">Example One Content</div>
 * </c-core-intc-hub-spoke>
 *
 * @example
 * <!-- HTML component example 2 -->
 * <!-- Example with a custom link that is a button -->
 * <c-core-intc-hub-spoke headline="Click to view content">
 *  <div slot="link">
 *    <lightning-button variant="brand" label="View Content" title="View Hub-Spoke content"></lightning-button>
 *  </div>
 *  <div slot="content">Example Two Content</div>
 * </c-core-intc-hub-spoke>
 *
 * @example
 * <!-- HTML component example 3 -->
 * <!-- Example with the blue colorScheme, noBorderTop, and a small desktopHeadingSize -->
 * <c-core-intc-hub-spoke headline="Click to view content" color-scheme="blue" no-border-top="true" desktop-heading-size="small">
 *  <div slot="content">Example Three Content</div>
 * </c-core-intc-hub-spoke>
 *
 * @augments LightningElement
 * @property {string} headline Text to use as the header of the content.
 * @property {string} [className] CSS class names to apply to the link container.
 * @property {string} [colorScheme=default] Sets the colorscheme of the "spoke" content in the mobile display.
 *  It can either be the default white background for the header and content area, or "blue" which produces a
 *  blue header background with a light gray content area.
 * @property {string} [noBorderTop=false] Removes the border-top on the desktop display accordion panel.
 * @property {boolean} [expanded=false] Sets whether the content is initially expanded or hidden in the desktop display.
 * @property {string} [desktopHeadingSize=regular] Sets the heading style (small/regular) in the desktop display.
 * @property {string} [variant] If variant='inverse', inverse styling will be applied to spoke headers.
 * @property {boolean} [noAccordion=false] Removes accordion functionality in desktop display
 * @fires open hub and spoke opens
 * @fires close hub and spoke closes
 */
class CoreIntcHubSpoke extends LightningElement {
  @api headline = '';

  @api className = '';

  @api colorScheme = 'default';

  @api noBorderTop = false;

  @api expanded = false;

  @api desktopHeadingSize = 'regular';

  @api variant = '';

  @api noAccordion = false;

  /**
   * tracks if modal is open
   *
   * @type {boolean}
   * @private
   */
  modalOpen = false;

  /**
   * overlay class
   *
   * @type {string}
   * @private
   */
  overlayClass = 'slds-hide';

  /**
   * Breakpoint
   *
   * @type {object}
   * @private
   */
  currentScreenSize = {}

  /**
   * custom labels
   *
   * @type {object}
   * @private
   */
  labels = {
    showContent: ariaShowContent,
    hideContent: ariaHideContent,
  }

  /**
   * handles screen changes
   * - if screen changes to mobile from desktop, close all hub-spoke
   * - if screen changes to desktop from mobile, reset accordions (open if initially expanded)
   *
   * @param {event} evt screen change event
   */
  handleScreenChange(evt) {
    this.currentScreenSize = evt.detail.screen;
    const { isMobile } = this.currentScreenSize;
    if (!this.previousScreenSize) {
      if (!isMobile && this.expanded) {
        this.open();
      }
    } else if (isMobile) {
      this.close();
    } else if (this.previousScreenSize.isMobile && !isMobile && this.expanded) {
      this.open();
    }
    this.previousScreenSize = this.currentScreenSize;
  }

  /**
   * Indicates if spoke overlay should be a button
   *
   * @returns {boolean} is button
   * @private
   */
  get isButton() {
    return this.currentScreenSize.isMobile || !this.noAccordion;
  }


  /**
   * Gets style classes when it is a headline view or overlay view
   *
   * @private
   * @returns {object} headline css classes and overlay css class
   */
  get classes() {
    return {
      headline: ['spoke-headline', 'slds-text-align_center', this.className].join(' '),
      overlay: ['spoke-overlay', this.overlayClass].join(' '),
    };
  }

  /**
   * Updates color scheme based style
   *
   * @private
   * @returns {object} is it default returns default, is it blue the returns blue
   */
  get ifs() {
    return {
      isDefault: this.colorScheme === 'default',
      isBlue: this.colorScheme === 'blue',
    };
  }



  /**
   * Handles toggle of modal open and closing
   *
   * @param {object} evt  Passes in event prevent default
   * @returns {boolean} If modal is open, close or open.
   * @private
   */
  handleToggle(evt) {
    evt.preventDefault();
    return this.modalOpen ? this.close() : this.open();
  }



  /**
   * Open sets overlay class to empty '', sets dataset isModalOpen to true, dispatches event 'open'
   *
   * @private
   */
  open() {
    this.overlayClass = '';
    if (this.currentScreenSize.isMobile) {
      document.body.dataset.isModalOpen = true;
    }
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    window.setTimeout(() => {
      this.modalOpen = true;
      if (this.currentScreenSize.isMobile) this.template.querySelector('.spoke-close').focus();
    });
    this.dispatchEvent(new CustomEvent('open'));
  }

  /**
   * Returns the role for the spoke-overlay container
   *
   * @returns {string} role
   * @private
   */
  get overlayRole() {
    if (this.modalOpen && this.currentScreenSize.isMobile) {
      return 'dialog';
    }
    return '';
  }

  /**
   * Returns the aria-labelledby for the spoke-overlay container
   *
   * @returns {string} aria-labelledby
   * @private
   */
  get overlayAriaLabelledby() {
    if (this.modalOpen && this.currentScreenSize.isMobile) {
      return 'core-intc-hs-modal-title';
    }
    return 'core-intc-hs-none';
  }



  /**
   * Closes hub and spoke programmatically.
   *
   * @public
   */
  @api close() {
    this.modalOpen = false;
    document.body.dataset.isModalOpen = false;
    if (this.currentScreenSize.isMobile) {
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      window.setTimeout(() => {
        this.overlayClass = 'slds-hide';
        this.template.querySelector('.spoke-open').focus();
      }, 700);
    } else {
      this.overlayClass = 'slds-hide';
    }
    this.dispatchEvent(new CustomEvent('close'));
  }
}
export default CoreIntcHubSpoke;

/**
 * Dispatches event when Hub and Spoke is opened
 *
 * @event CoreIntcHubSpoke#open
 * @type {object}
 *
 */

/**
 * Dispatches event when Hub and Spoke is closed
 *
 * @event CoreIntcHubSpoke#close
 * @type {object}
 *
 */