import { LightningElement, api } from 'lwc';

// Disabling valid-types due to issue with default value of tabIndex
/**
 * Individual tabs contained within a {@link CoreIntcTabset} component.
 *
 * ### Notes:
 * * Tab content is passed in through a <code>&lt;slot&gt;</code> tag.
 * * The behavior of the tabs is controlled via the {@link CoreIntcTabset} settings. Tabs
 *     is just used to specify a heading and pass content via the <code>&lt;slot&gt;</code>.
 * * If more tabs are defined than can be displayed, scroll paddles are added to the left and
 *   right side of the tabs. However, the content of a tab will always expand to the full width of the content container.
 * * When mobile stacking is used, the tab heading will be rendered above its content.
 *
 * ### CSS Variables
 * * See the {@link CoreIntcTabset} for CSS variables.
 *
 * <div id="core-examples" sf-attr="c-coreintctabset_coreintctabset c-coreintctab_coreintctab">
 *   <demo-core-intc-tabset show1="true"></demo-core-intc-tabset>
 *   <demo-core-intc-tabset show2="true"></demo-core-intc-tabset>
 *   <demo-core-intc-tabset show3="true"></demo-core-intc-tabset>
 * </div>
 *
 * @example
 * <!-- HTML component example 1 -->
 * <!-- Default display -->
 * <c-core-intc-tabset name="demo1">
 *     <c-core-intc-tab heading="Tab 1">Tab 1 Content</c-core-intc-tab>
 *     <c-core-intc-tab heading="Tab 2">Tab 2 Content</c-core-intc-tab>
 * </c-core-intc-tabset>
 *
 * @example
 * <!-- HTML component example 2 -->
 * <!-- Set the selected tab and use mobile stacking -->
 * <c-core-intc-tabset name="demo2" initial-active-tab="2" stack-mobile="true">
 *     <c-core-intc-tab heading="Tab 1">Tab 1 Content</c-core-intc-tab>
 *     <c-core-intc-tab heading="Tab 2">Tab 2 Content</c-core-intc-tab>
 *     <c-core-intc-tab heading="Tab 3">Tab 3 Content</c-core-intc-tab>
 * </c-core-intc-tabset>
 *
 * @example
 * <!-- HTML component example 3 -->
 * <!-- Long tab names to demonstrate scrolling -->
 * <c-core-intc-tabset name="demo3">
 *   <c-core-intc-tab heading="Tab 1 with a longer name to demonstrate scrolling">Tab 1 Content</c-core-intc-tab>
 *   <c-core-intc-tab heading="Tab 2 with a longer name to demonstrate scrolling">Tab 2 Content</c-core-intc-tab>
 *   <c-core-intc-tab heading="Tab 3 with a longer name to demonstrate scrolling">Tab 3 Content</c-core-intc-tab>
 *   <c-core-intc-tab heading="Tab 4 with a longer name to demonstrate scrolling">Tab 4 Content</c-core-intc-tab>
 *   <c-core-intc-tab heading="Tab 5 with a longer name to demonstrate scrolling">Tab 5 Content</c-core-intc-tab>
 * </c-core-intc-tabset>
 *
 * @augments LightningElement
 * @property {string} [link] The name of a deeplink to navigate to.
 * @property {string} heading Text to use as the tab label. Also displayed as a header when the {@link CoreIntcTabset}
 * <code>stackMobile</code> is set to true.
 */
class CoreIntcTab extends LightningElement {
  // ******* API variables - these can be set by the dev so defined in class properties *******
  @api link;

  @api heading;


  // ******* API variables - these are set by the tabset so they are not in the public definition ********
  /**
   * Indicates if this is the selected tab.
   *
   * @type {boolean}
   * @private
   */
  @api active;

  /**
   * ID to assign to the tab-container element. Used for accessibility.
   *
   * @type {string}
   * @private
   */
  @api idValue;

  /**
   * The string to use as the aria-labelled-by attribute for accessibility.
   *
   * @type {string}
   * @private
   */
  @api ariaLabelledBy;

  /**
   * Indicates if tabs should be stacked and always visible on mobile.
   *
   * @type {boolean}
   * @private
   */
  @api stackMobile;

  /**
   * Currently, non-selected tabs are not tabbable.
   *
   * @type {string}
   * @private
   */
  @api tabIndex = '-1';



  // ******* Class getters ********
  /**
   * Indicates if the tab content is displayed.
   *
   * @returns {boolean} Indicator for whether the tab content is displayed.
   * @private
   */
  get isActivated() {
    if (this.active || this.stackMobile) {
      this.activated = true;
    }
    return this.activated;
  }



  // ******* Functions ********
  /**
   * Set programatically b/c LWC appends random index numbers in the template otherwise.
   *
   * @private
   */
  renderedCallback() {
    this.template.querySelector('.tab-container').setAttribute('id', this.idValue);
    this.template.querySelector('.tab-container').setAttribute('aria-labelledby', this.ariaLabelledBy);
  }
}
export default CoreIntcTab;