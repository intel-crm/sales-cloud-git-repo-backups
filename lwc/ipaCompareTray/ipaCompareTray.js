import { LightningElement } from 'lwc';

import ipaCompareTrayService from 'c/ipaCompareTrayService';

import ariaStatus from '@salesforce/label/c.PMP_CompareTray_Status';
import categoryMismatch from '@salesforce/label/c.PMP_CompareTray_CategoryMismatch';
import compareTrayFull from '@salesforce/label/c.PMP_CompareTray_Full_Warning';
import removeItemLabel from '@salesforce/label/c.PMP_CompareTray_RemoveItem';
import clearAllLabel from '@salesforce/label/c.PMP_CompareTray_Clear_All';
import compareLabel from '@salesforce/label/c.PMP_Compare';
import toggleLabel from '@salesforce/label/c.PMP_CompareTray_Toggle';

/**
 * Product Compare Tray
 * - This component is fixed at the bottom of the page and allows the user to compare products of the same 2nd level category
 * - It is associated with ipaCompareCheckbox (the "Add to Compare" checkbox component)
 *
 * @augments LightningElement
 */
class IpaCompareTray extends LightningElement {
    /**
     * Custom labels
     *
     * @type {object}
     * @private
     */
    labels = {
      clearAllLabel,
      compareLabel,
      toggleTrayAccessibility: toggleLabel,
    };

    /**
     * Returns label string for compare tray
     *
     * @returns {string} compare label
     * @private
     */
    get compareLabel() {
      return `${this.labels.compareLabel} ${this.count}/${this.capacity}`;
    }

    /**
     * tracks notification message
     *
     * @type {string}
     * @private
     */
    notificationMessage = '';

    /**
     * State of compare tray
     *
     * @type {boolean}
     * @private
     */
    isOpen;

    /**
     * tracks compare tray items
     *
     * @type {object[]}
     * @private
     */
    items = [];

    /**
     * Returns classes for HTML markup
     *
     * @returns {string} classes
     * @private
     */
    get classes() {
      let status = '';

      if (this.hasItems) {
        if (this.isOpen) {
          status = 'open';
        } else {
          status = 'closed';
        }
      } else {
        status = 'slds-hide';
      }

      return `compare-tray ${status}`;
    }

    /**
     * Returns classes for HTML button markup
     *
     * @returns {string} button classes
     * @private
     */
    get compareButtonClasses() {
      return [
        'button button-primary button-full-width',
        this.isCompareDisabled ? 'button-disabled' : ''].join(' ');
    }

    /**
     * Returns utility icon name
     *
     * @returns {string} icon name
     * @private
     */
    get iconName() {
      return this.isOpen && this.hasItems ? 'utility:chevrondown' : 'utility:chevronup';
    }

    /**
     * Returns number of items in compare tray
     *
     * @returns {number} items
     * @private
     */
    get count() {
      return this.items.length;
    }

    /**
     * Checks if compare tray has items
     *
     * @returns {boolean} boolean value
     * @private
     */
    get hasItems() {
      return this.count > 0;
    }

    /**
     * Compare tray is disabled for less than 2 items
     *
     * @returns {boolean} boolean value
     * @private
     */
    get isCompareDisabled() {
      return this.count < 2;
    }

    /**
     * Returns the capacity of the compare tray
     *
     * @returns {number} capacity of compare tray
     * @private
     */
    get capacity() {
      return ipaCompareTrayService.capacity;
    }

    /**
     * Returns array of objects representing placeholder items for HTML markup
     *
     * @returns {object[]} array of placeholder item objects
     * @private
     */
    get placeholders() {
      const p = [];
      while (p.length < (this.capacity - this.count)) {
        p.push({ key: `tray-item-placeholder-${p.length}` });
      }
      return p;
    }

    /**
     * Returns label for compare tray aria status
     *
     * @returns {string} status label
     * @private
     */
    get statusLabel() {
      return ariaStatus.replace('{0}', this.count).replace('{1}', this.capacity);
    }

    /**
     * Connected callback - subscribes to redux compareTray data
     *
     * @private
     */
    connectedCallback() {
      this.serviceSub = ipaCompareTrayService.subscribe(({ items, notification }) => {
        // add aria labels to X remove checkboxes
        this.items = Object.values(items).map((item) => ({
          ...item,
          removeAriaLabel: removeItemLabel.replace('{0}', item.title),
        }));
        // display status as notification message
        this.notificationMessage = {
          FULL: compareTrayFull,
          CATEGORY_MISMATCH: categoryMismatch,
        }[notification] || '';

        const wasOpen = this.isOpen;
        // close tray if no items
        if (this.items.length === 0) {
          this.isOpen = false;
        }

        // open tray if notification msg
        if (this.notificationMessage) {
          this.isOpen = true;
        }
        if (!wasOpen && this.isOpen) {
          // eslint-disable-next-line @lwc/lwc/no-async-operation
          setTimeout(() => {
            this.template.querySelector('.toggle-tray').focus();
          }, 100);
        }
      });
    }

    /**
     * Unsubscribes to ipaCompareTrayService
     *
     * @private
     */
    disconnectedCallback() {
      if (this.serviceSub) {
        this.serviceSub();
      }
    }

    /**
     * Handles toggling compare tray using keys
     *
     * @param {event} evt onkeydown event
     * @private
     */
    handleToggleOpenAccessibility(evt) {
      if (evt.code === 'Enter') {
        this.handleToggleOpen();
      }
    }

    /**
     * Handles toggling compare tray
     *
     * @private
     */
    handleToggleOpen() {
      this.isOpen = !this.isOpen;
      if (!this.isOpen) {
        ipaCompareTrayService.clearStatus();
      }
    }

    /**
     * Handles removing an item from compare tray using keys
     *
     * @param {event} evt onkeydown event
     * @private
     */
    handleRemoveItemAccessibility(evt) {
      if (evt.code === 'Enter') {
        this.handleRemoveItem(evt);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
          this.template.querySelector('.toggle-tray').focus();
        }, 100);
      }
    }

    /**
     * Handles removing an item from compare tray
     *
     * @param {event} evt onclick event
     * @private
     */
    handleRemoveItem(evt) {
      const { id } = evt.currentTarget.dataset;
      ipaCompareTrayService.toggleItem({ id });
    }

    /**
     * Handles clearing compare tray
     *
     * @private
     */
    handleClearTray() {
      ipaCompareTrayService.clearTray();
    }
}
export default IpaCompareTray;