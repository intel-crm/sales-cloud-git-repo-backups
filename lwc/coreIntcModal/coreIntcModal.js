import { LightningElement, api } from 'lwc';

// Custom Labels
import closeModal from '@salesforce/label/c.Core_Intc_CloseModal';
import completeModal from '@salesforce/label/c.Core_Intc_CompleteModal';
import returnStartModal from '@salesforce/label/c.Core_Intc_ReturnStartModal';

/**
 * Displays a modal component that renders content behind it unclickable. Slots are used to pass content to the modal.
 * The modal can be displayed either in a Basic View or a Quick View.
 *
 * ### Slots
 * * header: The header for the modal. Rendered with a blue background.
 * * body: The main content of the modal.
 * * footer: Content to display at the bottom of the modal.
 *
 * ### Basic View
 * * This is the default view.
 * * The header and footer are always visible.
 * * The modal's body will scroll if needed.
 *
 * ### Quick View
 * * Enabled by setting the <code>isQuickview</code> property to true.
 * * The header and footer can be scrolled out of view.
 * * The entire page will scroll if needed.
 * * Animation is included to expand the modal.
 * * The width of the modal can be reduced using the <code>slim</code> property.
 *
 * #### Gallery View
 * * Used by coreIntcGallery component
 * * Enabled by setting the <code>isGalleryOverlay</code> property to true.
 * * Modal will have transparent background and will have specified width.
 * * See galleryOverlay.css for detailed styling changes.
 *
 * ### Notes:
 * * All slots are optional.
 * * If the header slot is included, a close button is automatically added to its top right corner.
 *    Padding is automatically added so that header text will not overwrite the close button.
 * * If the header slot is not included, then the close button is automatically added to the top right corner of the body.
 *    Padding is not automatically added, which means body content can overwrite the close button. You must add padding or
 *    margin to your body content to prevent this.
 * * The close icon is always white, unless <code>isQuickview</code> is set to true, in which case it defaults to
 *  dark gray. Set <code>closeIconInverse</code> to true to make the close icon white while in the quick view.
 * * By default, clicking outside the modal will close it. Set the <code>noCloseOnClick</code> property to true if you want
 *  it to stay open.
 * * The modal utilizes the 'slds-modal' and 'slds-modal__container' classes from the Salesforce
 *  <a href="https://www.lightningdesignsystem.com/" target="_blank" rel="noopener noreferrer">Lightning Design System</a>.
 * * When closing the modal, focus will automatically be returned to the element that had focus previously as long as the
 *  modal and the previous element are within the same
 *  <a href="https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.create_dom" target="_blank"
 *  rel="noopener noreferrer">Shadow DOM</a>. If they are not, focus can be programatically returned to
 *  the previous element by adding an "onclose" handler to the core-intc-modal. This event will be thrown when the modal is
 *  closed, and then you can programmatically set focus to the previous element.
 *
 * <div id="core-examples" sf-attr="c-coreintcmodal_coreintcmodal">
 *  <demo-core-intc-modal show1="true"></demo-core-intc-modal>
 *  <demo-core-intc-modal show2="true"></demo-core-intc-modal>
 *  <demo-core-intc-modal show3="true"></demo-core-intc-modal>
 * </div>
 *
 * @example
 * <!-- HTML component example 1 -->
 * <!-- Basic -->
 * <c-core-intc-modal>
 *  <div slot="header"><h4>Example 1 Modal - Basic View</h4></div>
 *  <div slot="body"><p>Example 1 Modal Content</p></div>
 *  <div slot="footer"><p>Example 1 Footer</p></div>
 * </c-core-intc-modal>
 *
 * @example
 * <!-- HTML component example 2 -->
 * <!-- Quick View with closeIconInverse -->
 * <c-core-intc-modal is-quickview="true" close-icon-inverse="true">
 *  <div slot="header"><h4>Example 2 Modal - Quick View</h4></div>
 *  <div slot="body"><p>Example 2 Modal Content</p></div>
 *  <div slot="footer"><p>Example 2 Footer</p></div>
 * </c-core-intc-modal>
 *
 * @example
 * <!-- HTML component example 3 -->
 * <!-- Quick View with slim, noCloseOnClick, and no header or footer -->
 * <c-core-intc-modal is-quickview="true" slim="true" no-close-on-click="true">
 *  <div slot="body"><p class="modal-example-content">Example 3 Modal Content</p></div>
 * </c-core-intc-modal>
 *
 * @augments LightningElement
 * @property {boolean} [closeIconInverse=false] Indicates if the close icon should be white. Only applies to the
 * Quick View display. The Basic View always has a white close icon.
 * @property {boolean} [hideClose=false] Indicates if the close button should not be displayed.
 * @property {boolean} [isOpen=false] Indicates if the modal should be opened on load.
 * @property {boolean} [isQuickview=false] Use the Quick View display described above.
 * @property {boolean} [noCloseOnClick=false] Indicates if clicking outside the modal should not close it.
 * @property {boolean} [slim=false] Reduces the width of the modal if using the Quick View.
 * @property {string} [modalTitle='Modal'] Announces the title of the modal to screen readers ('modal' by default).
 * @property {boolean} [isGalleryOverlay=false] Use the Gallery overlay display described above.
 */
class CoreIntcModal extends LightningElement {
  // ******* API variables - defined in class properties *******
  @api closeIconInverse = false;

  @api hideClose = false;

  @api isOpen;

  @api isQuickview = false;

  @api noCloseOnClick = false;

  @api slim = false;

  @api modalTitle = 'Modal';

  @api isGalleryOverlay = false;

  // ******* API variables - deprecated *******
  // These parameters are no longer used but are kept around so that older instances of core-intc-modal that still reference
  // them don't throw an error.
  @api hasHeader;

  @api hasBody;

  @api hasFooter;


  // ******* Class properties *******
  /**
   * The CSS class to use for the body container.
   *
   * @type {string}
   * @private
   */
  bodyClass = 'slds-hide';

  /**
   * The CSS class to use for the close anchor in the body slot.
   *
   * @type {string}
   * @private
   */
  closeBodyClass = '';

  /**
   * The CSS class to use for the close anchor in the header slot.
   *
   * @type {string}
   * @private
   */
  closeHeaderClass = 'modal-close';

  /**
   * The CSS class to use for the footer.
   *
   * @type {string}
   * @private
   */
  footerClass = 'slds-hide';

  /**
   * The CSS class to use for the header.
   *
   * @type {string}
   * @private
   */
  headerClass = 'slds-hide';

  /**
   * Indicates if the modal is currently open.
   *
   * @type {boolean}
   * @private
   */
  isModalOpen;

  /**
   * Contains labels used in the UI.
   *
   * @type {object}
   * @private
   */
  labels = {
    closeModal,
    completeModal,
    returnStartModal,
  };

  /**
   * The element that had focus when the modal was opened.
   *
   * @type {HTMLElement}
   * @private
   */
   previouslyActiveElement;

  /**
   * Tracking variable for the show animation.
   *
   * @type {boolean}
   * @private
   */
  showModal;

  /**
   * Stores the direction the tab key focus is moving (forward or back).
   *
   * @type {string}
   * @private
   */
  tabDirection = '';




  // ******* Class Methods *******
  /**
   * Connected Callback - opens modal if initially set to open
   *
   * @private
   */
  connectedCallback() {
    this.wasModalClosed = true;
    if (this.isOpen && this.isOpen !== 'false') {
      this.openModal();
    }
  }




  /**
   * Resets the body style and data attribute to indicate the modal is closed.
   *
   * @private
   */
  disconnectedCallback() {
    this.updateBodyStyle('auto', false);
  }




  /**
   * Rendered Callback
   * Accessibility - Focuses modal on first focusable element on open
   *
   * @private
   */
  renderedCallback() {
    if (this.wasModalClosed && this.isModalOpen) {
      // Get the element that is currently focused
      if (!this.previouslyActiveElement && this.template.host && this.template.host.getRootNode()) {
        const previousFocus = this.template.host.getRootNode().activeElement;
        if (previousFocus) {
          this.previouslyActiveElement = previousFocus;
        }
      }

      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        this.focusFirstElement();
      }, 1);
      this.wasModalClosed = false;
    }
  }



  /**
   * Closes modal programmatically.
   *
   * @public
   */
  @api closeModal() {
    this.showModal = false;
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      this.isModalOpen = false;
      this.wasModalClosed = true;
    }, 280); // match w/ animation time in animations.css
    this.updateBodyStyle('auto', false);
    this.dispatchEvent(new CustomEvent('close'));

    // Return focus to the element that had it when the modal was opened
    if (this.previouslyActiveElement) {
      this.previouslyActiveElement.focus();
    }
  }



  /**
   * Returns the first element that can receive focus.
   *
   * @returns {HTMLElement} The first element that can receive focus.
   * @private
   */
  findFirstFocusableElement() {
    let firstElement;
    if (this.hideClose) {
      // Not displaying the close button so use the start button
      firstElement = this.template.querySelector('.core-focus-start');
    } else {
      // Close button displayed so it is always the first element
      firstElement = this.template.querySelector('.modal-close');
    }
    return firstElement;
  }



  /**
   * Focuses on first focusable element. Used when navigating via the tab key.
   *
   * @public
   */
  @api
  focusFirstElement() {
    const firstElement = this.findFirstFocusableElement();
    if (firstElement) {
      firstElement.focus();
    }
  }



  /**
   * Focuses on last focusable element. Used when navigating via the tab key.
   *
   * @private
   */
  focusLastElement() {
    const lastElement = this.template.querySelector('.core-focus-end');
    if (lastElement) {
      lastElement.focus();
    } else {
      // No last element found so default to focusing on the first
      this.focusFirstElement();
    }
  }



  /**
   * Accessibility keydown event handlers:
   * Escape Key - closes modal
   * Enter Key - closes modal (if on close icon)
   * Tab - sets the direction the tab key focus is moving
   *
   * @param {object} evt key down event
   * @private
   */
  handleAllKeyDown(evt) {
    if (evt.key === 'Escape' && !this.hideClose) {
      this.closeModal();
    } else if ((evt.key === 'Enter' || evt.key === ' ' || evt.key === 'Spacebar') && evt.target.dataset.keydownAction === 'close') {
      this.closeModal();
      evt.preventDefault();
    } else if (evt.key === 'Tab') {
      if (evt.shiftKey) {
        this.tabDirection = 'back';
      } else {
        this.tabDirection = 'forward';
      }
    }
  }


  /**
   * Determines if the user's focus has moved outside the modal when clicking the shift-tab key on
   * the close modal link. If so, it moves focus to the return to start button (the last element in modal).
   *
   * @private
   */
  handleBlurFirst() {
    if (!this.template.querySelector('.modal-main-container:focus-within') && this.tabDirection === 'back') {
      this.focusLastElement();
      this.tabDirection = '';
    }
  }



  /**
   * Determines if the user's focus has moved outside the modal when clicking the tab key on
   * the return to start button. If so, it moves focus to the close modal link (the first element in modal).
   *
   * @private
   */
  handleBlurLast() {
    if (!this.template.querySelector('.modal-main-container:focus-within') && this.tabDirection === 'forward') {
      this.focusFirstElement();
      this.tabDirection = '';
    }
  }



  /**
   * Close modal on click backdrop
   *
   * @param {object} evt click event
   * @private
   */
  handleClickBackdrop(evt) {
    if (evt.target) {
      if ((evt.target === evt.currentTarget || evt.target.className === 'slds-modal__container') && (!this.noCloseOnClick || this.noCloseOnClick === 'false')) {
        this.closeModal();
      }
    }
  }



  /**
   * Close modal event handler
   *
   * @private
   */
  handleCloseModal() {
    this.closeModal();
  }



  /**
   * Determines the appropriate CSS class for a slot's container element based
   * on whether the slot has content.
   *
   * @param {object} evt The slotChange event.
   * @private
   */
  handleSlotChange(evt) {
    const hasContent = this.testForSlotContent(evt.target);

    // Default to hiding the slot's container
    let newClass = 'slds-hide';

    // Remove the hide class if the slot has content
    if (hasContent) {
      switch (evt.target.name) {
        case 'body':
          newClass = 'modal-content';
          break;
        case 'header':
          newClass = 'modal-header';
          break;
        default:
          newClass = '';
      }
    }

    // Update the class property
    this[`${evt.target.name}Class`] = newClass;

    // Update the close anchor
    this.setCloseClasses();
  }



  /**
   * Check if modal has been opened before
   *
   * @returns {boolean} returns boolean
   * @private
   */
  get hasModalOpenedBefore() {
    this._hasModalOpenedBefore = this._hasModalOpenedBefore || this.isModalOpen;
    return this._hasModalOpenedBefore;
  }



  /**
   * Opens modal programmatically.
   *
   * @public
   */
  @api openModal() {
    this.isModalOpen = true;
    this.showModal = true;
    this.updateBodyStyle('hidden', true);
    this.dispatchEvent(new CustomEvent('open'));
  }



  /**
   * Sets the CSS classes used for displaying the close anchor in the header and the body.
   *
   * @private
   */
  setCloseClasses() {
    if (this.hideClose) {
      this.closeBodyClass = '';
      this.closeHeaderClass = '';
      return;
    }

    let newCloseClass = 'modal-close';
    // Determine if quick view
    if (this.isQuickview && this.isQuickview !== 'false') {
      // Quick view defaults to grey icon so check if need inverse
      if (this.closeIconInverse && this.closeIconInverse !== 'false') {
        newCloseClass = `${newCloseClass} color-white`;
      }
    } else if (!this.closeIconInverse || this.closeIconInverse === 'false') {
      // Non-quick view so it defaults to white as long as not inverse
      newCloseClass = `${newCloseClass} color-white`;
    }

    if (this.headerClass === 'modal-header') {
      this.closeHeaderClass = newCloseClass;
      this.closeBodyClass = '';
    } else if (this.isQuickview) {
      this.closeHeaderClass = '';
      this.closeBodyClass = newCloseClass;
    } else {
      this.closeHeaderClass = '';
      // Add additional padding if in quick view and no header
      this.closeBodyClass = `${newCloseClass} modal-close-body`;
    }
  }



  /**
   * Determines if a slot has content.
   *
   * @param {object} slot The slot to test for content.
   * @returns {boolean} Indicates if the slot has content.
   * @private
   */
  testForSlotContent(slot) {
    let hasContent = false;

    // Get the slot's content along with descendant slots
    const slotNodes = slot.assignedNodes({ flatten: true });
    const slotNodesLength = slotNodes.length;

    // Check for anything other than an empty slot
    for (let count = 0; count < slotNodesLength; count += 1) {
      if (slotNodes[count].tagName !== 'SLOT') {
        hasContent = true;
        break;
      }
    }

    return hasContent;
  }



  /**
   * Updates the document.body overflow and custom data attribute indicating the modal open status.
   *
   * @param {string} overflow The CSS value for overflow.
   * @param {boolean} isModalOpen Indicates if the modal is open or closed.
   * @private
   */
  updateBodyStyle(overflow, isModalOpen) {
    document.body.style.overflow = overflow;
    document.body.dataset.isModalOpen = isModalOpen;
  }
}
export default CoreIntcModal;