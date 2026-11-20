/** Documentation for the Tab Component
 * <br>To be used with the {@link ipaTabset ipaTabset} component.<br>
 * Content is passed in through a <code>&lt;slot&gt;</code> tag.
 * @example
 * <c-ipa-tabset>
 *     <c-ipa-tab heading="Tab 1">Tab 1 Content</c-ipa-tab>
 *     <c-ipa-tab heading="Tab 2">Tab 2 Content</c-ipa-tab>
 * </c-ipa-tabset>
 * @namespace ipaTab
 * @property {string} link optional deeplink id for the tab
 * @property {string} heading required text for the tab label
 * @property {boolean} active public attribute to get active status of tab
 * @property {string} idValue html id value for accessibility
 * @property {string} ariaLabelledBy html aria-labelled-by attribute value for accessibility
 * @property {string} tabIndex=-1 default tabindex can be overwritten if needed <br><i>(Ideally content would be tabbable.)</i>
 * @author Nick Demarest, last modified 29 May 2020
*/

import { LightningElement, api } from 'lwc';

export default class IpaTab extends LightningElement {
    @api link;
    @api heading;
    @api active;
    @api idValue;
    @api ariaLabelledBy;
    @api tabIndex = '-1';

    get isActivated() {
        if (this.active) this.activated = true;
        return this.activated;
    }

    // set programatically b/c LWC appends random index numbers in the template otherwise
    renderedCallback() {
        this.template.querySelector('.tab-container').setAttribute('id', this.idValue);
        this.template.querySelector('.tab-container').setAttribute('aria-labelled-by', this.ariaLabelledBy);
    }
}