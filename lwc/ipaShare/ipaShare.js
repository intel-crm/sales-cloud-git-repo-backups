import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { handleError } from 'c/ipaErrorServiceMarketplace';

// Custom Labels
import copy from '@salesforce/label/c.PMP_CopyUrl';
import copied from '@salesforce/label/c.PMP_Copied';
import share from '@salesforce/label/c.PMP_Share';
import close from '@salesforce/label/c.PMP_Close';
import email from '@salesforce/label/c.PMP_Email';
import sharePage from '@salesforce/label/c.PMP_Share_Page';
import emailSubject from '@salesforce/label/c.PMP_Share_Email_Subject';

/**
 * Documentation for the IpaShare component
 * A button with an expandable dropdown containing various social share capabilities
 *
 * @property {boolean} [showLabel=false] indicates if 'Share Page' label should be displayed
 * @property {string} [emailBody] the topic of the email being sent, otherwise blank
 * @property {string} [emailLink] url that email subject should link to, otherwise will link to current page
 * @property {boolean} [previewMode] preview mode (disable functionality)
 * @property {string} [buttonClasses=''] Additional CSS classes to add to the button.
 * @augments LightningElement
 */
class IpaShare extends LightningElement {
    @api showLabel = false;

    @api emailBody;

    @api emailLink;

    @api previewMode;

    @api buttonClasses = '';

    /**
     * Custom labels
     *
     * @type {object}
     * @private
     */
    labels = {
      copy,
      copied,
      share,
      close,
      email,
      sharePage,
      emailSubject,
    }

    /**
     * Indicates if share menu is expanded
     *
     * @type {boolean}
     * @private
     */
    expanded = false;

    /**
     * Returns href for email anchor element
     *
     * @returns {string} email href
     * @private
     */
    get email() {
      let link = this.emailLink ? this.emailLink : window.location.href;
      // Can't use uriEncode as it double encodes search filter link parameters and breaks link
      link = link.replace('&', '%26');
      const body = this.emailBody ? `${this.emailBody}%0A` : '';
      return `mailto:?subject=${this.labels.emailSubject}&body=${body}${link}`;
    }

    /**
     * Returns the CSS classes to use for the button.
     *
     * @returns {string} CSS classes for the button.
     * @private
     */
    get fullButtonClasses() {
      return `link-text link-no-underline ${this.buttonClasses}`;
    }

    /**
     * Handles opening share link
     *
     * @private
     */
    handleToggleShare() {
      if (!this.previewMode) {
        this.expanded = !this.expanded;
      }
    }

    /**
     * Handles closing share menu using escape
     *
     * @param {event} e onkeyup event
     * @private
     */
    handleCloseShare(e) {
      if (this.expanded && e.code === 'Escape') {
        this.expanded = false;
      }
    }

    /**
     * Handles copying share link, then displays a toast message and closes share overlay
     *
     * @private
     */
    handleCopy() {
      const inputEle = document.createElement('input');
      const urlValueToCopy = this.emailLink || window.location.href;
      inputEle.setAttribute('value', urlValueToCopy);
      document.body.appendChild(inputEle);
      inputEle.select();
      inputEle.setSelectionRange(0, 9999999);

      try {
        // navigator.clipboard.writeText not supported by lightning locker
        document.execCommand('copy');
        this.template.querySelector('button[data-id="shareButton"]').focus();
        this.dispatchEvent(new ShowToastEvent({
          title: copied,
          variant: 'info',
        }));
      } catch (err) {
        handleError('Error Unable to Copy To Clipboard', 'ipaSearchHeader', 'console');
      }
      inputEle.parentNode.removeChild(inputEle);
    }
}
export default IpaShare;