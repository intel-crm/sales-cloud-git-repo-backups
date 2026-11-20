import { LightningElement, api } from 'lwc';

/**
 * @typedef MenuItem
 * @property {string} label item label
 * @property {string} action name for action
 * @property {string} communityPage for items that navigate to a community page
 * @property {string} externalUrl for items that navigate to an external url
 */

/** Button Menu Dropdown
 * <br>
 * <h3>Menu Items</h3>
 * Menu items can be structured to use the {@link ipaLink ipaLink} component, with <b>communityPage</b> or <b>externalUrl</b> attributes.
 * <br>
 * They can also be structured as 'action' items. In this case a custom event is fired: <b>action</b>.
 *
 * @augments LightningElement
 * @property {string} title menu title
 * @property {boolean} [autoScroll] if set to 'true' it will auto scroll after menu is opened/closed
 * @property {MenuItem[]} menuItems the menu items for the dropdown
 * @fires action when menu item is selected
 * @fires toggle when menu is opened or closed
 */
class IpaButtonMenuDropdown extends LightningElement {
  @api title = '';

  @api autoScroll;

  /**
   * menu items
   *
   * @type {MenuItem[]}
   * @public
   */
  @api set menuItems(items) {
    this._menuItems = items.map((item) => ({
      key: item.label.replace(/\s/g, '_'),
      label: item.label || 'missing label',
      action: item.action,
      isAction: !!item.action,
      communityPage: item.communityPage,
      externalUrl: item.externalUrl,
    }));
  }

  /** menu items
   *
   * @returns {MenuItem[]} menu items
   * @private
   */
  get menuItems() {
    return this._menuItems;
  }

  /**
   * tracks menu open status
   *
   * @type {boolean}
   * @private
   */
  isOpen;

  /**
   * icon name (SLDS)
   *
   * @type {string}
   * @private
   */
  get iconName() {
    return this.isOpen ? 'utility:chevronup' : 'utility:chevrondown';
  }

  /**
   * handle button
   *
   * @param {event} evt select item action, emits event
   * @private
   */
  handleSelectItem(evt) {
    const i = this.menuItems.find(
      (item) => item.key === evt.target.dataset.key,
    );
    if (i && i.action) {
      this.dispatchEvent(new CustomEvent('action', { detail: i.action }));
    }
  }

  /**
   * handle button (accessibility)
   *
   * @param {event} evt button key down
   * @private
   */
  handleBtnKeyDown(evt) {
    if (evt.key === 'Enter' || evt.key === 'Spacebar') {
      const i = this.menuItems.find(
        (item) => item.key === evt.target.dataset.key,
      );
      this.dispatchEvent(new CustomEvent('action', { detail: i.action }));
    }
  }

  /**
   * toggles open/close menu, emits toggle event
   *
   * @private
   */
  handleToggleOpen() {
    this.isOpen = !this.isOpen;
    this.dispatchEvent(new CustomEvent('toggle', { detail: this.isOpen }));
  }

  /**
   * rendered callback
   * - scrolls into view if 'autoScroll' property is set
   *
   * @private
   */
  renderedCallback() {
    const els = this.template.querySelectorAll('li');
    if (els.length && this.autoScroll) {
      els[els.length - 1].scrollIntoView();
    }
  }
}
export default IpaButtonMenuDropdown;