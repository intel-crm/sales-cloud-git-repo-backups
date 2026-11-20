import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import newWindowMessage from '@salesforce/label/c.Core_Intc_New_Window';


/**
 * A reusable component for displaying an anchor link. It contains various settings to control the display and
 * behavior of the link. It also provides settings to automatically generate Salesforce links using the
 * [NavigationMixin](https://developer.salesforce.com/docs/component-library/bundle/lightning-navigation/documentation).
 *
 * ### Link Content
 * There are two methods for setting the content within a link:
 * * Set the <code>label</code> property</li>
 * * Place the content between the c-core-intc-link tags (referred to as the "slot")
 * If you use a slot, you should still specify a <code>label</code>, <code>title</code>, or <code>aria-label</code> value to
 * provide extra information for users with screen readers.
 *
 * ### Setting the HREF
 * There are two ways to set the link's href property:
 * * Set the <code>externalUrl</code> property. The href will be set directly to this value.
 * * Set either the <code>communityPage</code>, <code>objectPage</code>, or <code>pageReference</code> property. If you set the
 *  <code>communityPage</code> or <code>objectPage</code> properties, the coreIntcLink will create a Salesforce
 *  [PageReference](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type)
 *  based on it. If you set the <code>pageReference</code> property, it will use it as your Salesforce PageReference.
 *  It will then use the Salesforce
 *  [NavigationMixin](https://developer.salesforce.com/docs/component-library/bundle/lightning-navigation/documentation)
 *  to genreate an href based on this Salesforce PageReference.
 *
 * ### Events
 * A "corelinkclick" event is generated when the user clicks on the link. This event is bubbled to all ancestor elements.
 * The following object is passed as part of the event:
 * <pre><code>detail: {
 *  communityPage: [the communityPage property],
 *  externalUrl: [the externalUrl property],
 *  href: [the href as computed by coreIntcLink based on your property settings],
 *  label: [the label property if it was set, or the textContent of the first node in the slot],
 *  objectPage: [the objectPage property],
 *  pageRef: [the Salesforce PageReference as computed by coreIntcLink],
 *  recordId: [the recordId property]
 * }
 * </code></pre>
 * This event can be caught by adding an "oncorelinkclick" handler to the coreIntcLink component.<br>
 * <code>&lt;c-core-intc-link external-url="https://circuit.intel.com" label="Circuit" oncorelinkclick={handleClick}&gt;&lt;/c-core-intc-link&gt;</code>
 *
 * ### Notes:
 * * Links with an <code>externalUrl</code> (except links that start with "#") will by default open in a new window. Links with a <code>communityPage</code>,
 *   <code>objectPage</code>, or <code>pageReference</code> will open in the current window by default. These defaults can be
 *   overridden using the <code>target</code> property.
 * * Links that open in a new window will display a new window icon by default. This can be disabled
 *    by setting the <code>hideIcon</code> property to true.
 * * Links that open in a new window will have the text "(Opens in a new window)" automatically added to their aria-label value.
 * * Links that open in the current window do not display an icon by default. An icon can be enabled by setting <code>hideIcon</code>
 *    to false.
 * * Links that send an email will display a mail icon by default. This can be disabled by setting the <code>hideIcon</code> property to true.
 * * The default icons are [Font Awesome](https://fontawesome.com/) icons loaded by the
 *    [IGHF](https://drc.intel.com/web/ighf-overview/). For links that open in a new window, the "fa-link-ext" icon is used.
 *    For links that open in the current window, the "fa-arrow-right" icon is used. For email links, the "fa-mail-1" icon is used.
 * * If your site does not use the IGHF, or does not have Font Awesome icons avaiable, you can use the
 *    [Salesforce icons](https://www.lightningdesignsystem.com/icons/) instead by setting <code>salesforceIcon</code> to true. For links that
 *    open in a new window, the "utility:new_window" icon is used. For links that open in the current window, the
 *    "utility:forward" icon is used. For email links, the "utility:email" icon is used.
 * * If the <code>title</code> property is not set, the <code>label</code> property will be used as the link's title.
 * * If the <code>ariaLabel</code> property is not set, the <code>title</code> property will be used as the link's aria-label. If the
 *    <code>title</code> property is not set, the <code>label</code>property will be used instead.
 * * To truncate the link text, (or add any additional styling with classes) use the <code>className</code>
 *    attribute with global classes. For truncation, use "truncate-1" for 1 line, "truncate-3" for 3 lines, etc.
 * * To set boolean properties to true, you just need to add the property. To set them to false, you must set it equal to "false".
 *
 * <div id="core-examples" sf-attr="c-coreintclink_coreintclink">
 *  <demo-core-intc-link show1="true"></demo-core-intc-link>
 *  <demo-core-intc-link show2="true"></demo-core-intc-link>
 *  <demo-core-intc-link show3="true"></demo-core-intc-link>
 *  <demo-core-intc-link show4="true"></demo-core-intc-link>
 *  <demo-core-intc-link show5="true"></demo-core-intc-link>
 *  <demo-core-intc-link show6="true"></demo-core-intc-link>
 *  <demo-core-intc-link show7="true"></demo-core-intc-link>
 *  <demo-core-intc-link show8="true"></demo-core-intc-link>
 *  <demo-core-intc-link show9="true"></demo-core-intc-link>
 *  <demo-core-intc-link show10="true"></demo-core-intc-link>
 *  <demo-core-intc-link show11="true"></demo-core-intc-link>
 *  <demo-core-intc-link show12="true"></demo-core-intc-link>
 * </div>
 *
 * @example
 * <!-- HTML component example 1 -->
 * <!-- External URL with content set using label -->
 * <c-core-intc-link external-url="https://circuit.intel.com" label="Circuit"></c-core-intc-link>
 *
 * @example
 * <!-- HTML component example 2 -->
 * <!-- External URL with content set using slot -->
 * <c-core-intc-link external-url="https://circuit.intel.com" label="Click to visit Circuit">Circuit</c-core-intc-link>
 *
 * @example
 * <!-- HTML component example 3 -->
 * <!-- Hiding the icon -->
 * <c-core-intc-link external-url="https://circuit.intel.com" label="Circuit" hide-icon></c-core-intc-link>
 *
 * @example
 * <!-- HTML component example 4 -->
 * <!-- Catching the corelinkclick event -->
 * <c-core-intc-link external-url="https://circuit.intel.com" label="Circuit" oncorelinkclick={handleClick}></c-core-intc-link>
 *
 * @example
 * <!-- HTML component example 5 -->
 * <!-- Community Page -->
 * <c-core-intc-link community-page="Home" label="Home"></c-core-intc-link>
 *
 * @example
 * <!-- HTML component example 6 -->
 * <!-- Object Page -->
 * <c-core-intc-link object-page="Account" label="Accounts"></c-core-intc-link>
 *
 * @example
 * <!-- HTML component example 7 -->
 * <!-- Record Page -->
 * <c-core-intc-link object-page="Account" record-id="0018A00000TSoDAQA1" label="Account Record"></c-core-intc-link>
 *
 * @example
 * <!-- HTML component example 8 -->
 * <!-- Showing the icon -->
 * <c-core-intc-link community-page="Home" label="Home" hide-icon="false"></c-core-intc-link>
 *
 * @example
 * <!-- HTML component example 9 -->
 * <!-- External URL with Salesforce icon -->
 * <c-core-intc-link external-url="https://circuit.intel.com" label="Circuit" salesforce-icon></c-core-intc-link>
 *
 * @example
 * <!-- HTML component example 10 -->
 * <!-- External URL with CSS Class Name -->
 * <c-core-intc-link external-url="https://circuit.intel.com" label="Circuit" class-name="slds-m-left_medium"></c-core-intc-link>
 *
 * @example
 * <!-- HTML component example 11 -->
 * <!-- Send an email -->
 * <c-core-intc-link external-url="mailto:test@intel.com" label="Email Test"></c-core-intc-link>
 *
 * @example
 * <!-- HTML component example 12 -->
 * <!-- ariaLabel value -->
 * <c-core-intc-link external-url="https://circuit.intel.com" label="Circuit" aria-label="Home page for Intel employees"></c-core-intc-link>
 *
 * @augments LightningElement
 * @augments NavigationMixin
 * @property {string} [ariaLabel]  A string to use as the
 *  [aria-label](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/ARIA_Techniques/Using_the_aria-label_attribute). Defaults to
 *  the <code>title</property> if ariaLabel is not set. If <code>title</code> is not set, then the <code>label</code> is used.
 * @property {boolean} [ariaSkip=false]  Indicates if the link should be hidden from screen readers by setting
 *  [aria-hidden](https://developer.mozilla.org/en-US/docs/Web/API/Element/ariaHidden) to true and the tabindex to -1.
 * @property {string} [className]  A string of CSS classes to add to the anchor element. These classes must be global CSS classes (such
 *  as Salesforce slds classes) in order to be applied to the link. If a class name of "button" or "link-no-style" is passed, the
 *  standard link styling will not be applied.
 * @property {string} [communityPage]  The name when using a Named Page Type (Experience Builder Sites) Salesforce
 *  [PageReference](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type).
 * @property {string} [externalUrl]  The URL to use for the link. If this is not set, then the <code>communityPage</code>, <code>objectPage</code>,
 *  or <code>pageReference</code> must be set.
 * @property {boolean} [hideIcon=false]  Indicates if the icon should be hidden, regardless of the type of link and target.
 * @property {string} [iconClass]  A string of CSS classes to add to the icon container element. These classes must be global CSS classes (such
 *  as Salesforce slds classes) in order for them to be applied to the icon container.
 * @property {string} [iconName]  The name of a [Font Awesome](https://fontawesome.com/) icon to use for the icon, or if <code>salesforceIcon</code>
 *  is set to true, then the name of the [Salesforce icon](https://www.lightningdesignsystem.com/icons/) to use. Setting an iconName will cause the icon
 *  to always be displayed.
 * @property {boolean} [inverse=false]  Indicates if inverse styling should be applied to the link. This includes setting the color to white and
 *  adding a dashed underline. Used this when rendering the link on a dark colored background.
 * @property {string} [label]  The text for the link.
 * @property {boolean} [noSeoConvert=false]  Indicates if an href should not be generated when using the <code>communityPage</code>,
 *  <code>objectPage</code>, or <code>pageReference</code> properties. Instead of generating and updating the href, the generated Salesforce
 *  [PageReference](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type)
 *  will be passed directly to the Salesforce
 *  [NavigationMixin](https://developer.salesforce.com/docs/component-library/bundle/lightning-navigation/documentation) when the user
 *  clicks on the link. This means the href for the link will be the same as the current URL, and so does not actually reflect where the
 *  link will go. This should not be set to true when SEO (Search Engine Optimization) is a consideration. However, if SEO
 *  is not a concern, there are performance benefits to not generating the href.
 * @property {string} [objectPage]  The objectApiName when using an Object Type Salesforce
 *  [PageReference](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type).
 * @property {object} [pageReference]  A Salesforce
 *  [PageReference](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type) to use to generate
 *  the link's href.
 * @property {object} [params]  An object containing name:value pairs to be added as querystring parameters when using a Salesforce
 *  [PageReference](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type) to navigate.
 * @property {boolean} [prevent=false]  Indicates if the anchor click event should be have preventDefault and stopPropagation called.
 * @property {boolean} [preview=false]  Indicates if the link should not be clickable (although clicking on it will generate a corelinkclick event).
 * @property {string} [recordId]  The recordId when using an Record Page Type Salesforce
 *  [PageReference](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type). If recordId is set,
 *  the <code>objectPage</code> must also be set.
 * @property {boolean} [salesforceIcon=false]  Indicates if [Salesforce icons](https://www.lightningdesignsystem.com/icons/) should be used instead
 * of [Font Awesome](https://fontawesome.com/) icons.
 * @property {boolean} [throwError=false]  Indicates if validation errors should be thrown. If they are not thrown, they will be written to the console.
 *  See [this](https://developer.salesforce.com/blogs/2020/08/error-handling-best-practices-for-lightning-web-components.html) for information
 *  on error handling.
 * @property {string} [target]  The [target](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a) value for the link.
 * @property {string} [title]  The [title](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/title) value for the link. This will default
 *  to the <code>label</code> value if title is not set.
 */
class CoreIntcLink extends NavigationMixin(LightningElement) {
  // Need to delegate the focus behavior to inside the template content
  static delegatesFocus = true;

  // ******* API variables - defined in class properties *******
  @api ariaLabel;

  @api className = '';

  @api hideIcon;

  @api iconClass;

  @api iconName;

  @api inverse = false;

  @api label = '';

  @api noSeoConvert = false;

  @api prevent = false;

  @api preview = false;

  @api salesforceIcon;

  @api throwError = false;

  @api target = '';

  @api title = '';


  // ******* API getters and setters - defined in class properties *******
  /**
   * Returns the internal version of the ariaSkip api property. See definition in class properties.
   *
   * @returns {boolean} The internal ariaSkip property.
   * @private
   */
  @api get ariaSkip() {
    return this._ariaSkip;
  }

  /**
   * Sets the internal ariaSkip property after converting it to a boolean. Also
   * calls the updateAria method in order to modify the link'a DOM properties.
   *
   * @param {boolean} value  The value for ariaSkip.
   * @private
   */
  set ariaSkip(value) {
    if (value === 'false') {
      this._ariaSkip = false;
    } else {
      this._ariaSkip = !!value;
    }
    this.updateAria();
  }


  /**
   * Returns the internal version of the communityPage property. See definition in class properties.
   *
   * @returns {string} The internal communityPage api property.
   * @private
   */
  @api get communityPage() {
    return this._communityPage;
  }


  /**
   * Sets the internal communityPage property and then calls the function to update the formattedPageReference
   * and href.
   *
   * @param {string} value  The value for communityPage.
   * @private
   */
  set communityPage(value) {
    this._communityPage = value;
    this.updateNavigationReference();
  }


  /**
   * Returns the internal version of the externalUrl api property. See definition in class properties.
   *
   * @returns {string} The internal externalUrl property.
   * @private
   */
  @api get externalUrl() {
    return this._externalUrl;
  }


  /**
   * Sets the internal externalUrl property and then calls the function to update the formattedPageReference
   * and href.
   *
   * @param {string} value  The value for externalUrl.
   * @private
   */
  set externalUrl(value) {
    if (value && !value.startsWith('#') && !/^(https?:\/\/|mailto:)/i.test(value)) {
      this._externalUrl = `https://${value}`;
    } else {
      this._externalUrl = value;
    }
    this.updateNavigationReference();
  }


  /**
   * Returns the internal version of the objectPage api property. See definition in class properties.
   *
   * @returns {string} The internal objectPage property.
   * @private
   */
  @api get objectPage() {
    return this._objectPage;
  }


  /**
   * Sets the internal objectPage property and then calls the function to update the formattedPageReference
   * and href.
   *
   * @param {string} value  The value for objectPage.
   * @private
   */
  set objectPage(value) {
    this._objectPage = value;
    this.updateNavigationReference();
  }


  /**
   * Returns the internal version of the pageReference api property. See definition in class properties.
   *
   * @returns {string} The internal pageReference property.
   * @private
   */
  @api get pageReference() {
    return this._pageReference;
  }


  /**
   * Sets the internal pageReference property and then calls the function to update the formattedPageReference
   * and href.
   *
   * @param {string} value  The value for pageReference.
   * @private
   */
  set pageReference(value) {
    this._pageReference = value;
    this.updateNavigationReference();
  }


  /**
   * Returns the internal version of the params api property. See definition in class properties.
   *
   * @returns {object} The internal params property.
   * @private
   */
  @api get params() {
    return this._params;
  }


  /**
   * Sets the internal params property and then calls the function to update the formattedPageReference
   * and href.
   *
   * @param {object} value  The value for params.
   * @private
   */
  set params(value) {
    this._params = value;
    this.updateNavigationReference();
  }


  /**
   * Returns the internal version of the recordId api property. See definition in class properties.
   *
   * @returns {string} The internal recordId property.
   * @private
   */
  @api get recordId() {
    return this._recordId;
  }


  /**
   * Sets the internal recordId property and then calls the function to update the formattedPageReference
   * and href.
   *
   * @param {string} value  The value for recordId.
   * @private
   */
  set recordId(value) {
    this._recordId = value;
    this.updateNavigationReference();
  }



  // ******* Class variables ********
  /**
   * Indicates if the ariaSkip value has been set. Used to determine if the DOM needs to be updated.
   *
   * @type {boolean}
   * @private
   */
  ariaSkipSet = false;


  /**
   * Internal version of the ariaSkip api property. See definition in class properties.
   *
   * @type {boolean}
   * @private
   */
  _ariaSkip;


  /**
   * Internal version of the communityPage api property. See definition in class properties.
   *
   * @type {string}
   * @private
   */
  _communityPage;


  /**
   * Indicates if the connectCallback method has been run. This is needed since the NavigationMixin
   * will not work properly until connectedCallback has run.
   *
   * @type {boolean}
   * @private
   */
  connectedCallbackDone = false;


  /**
   * Internal version of the externalUrl api property. See definition in class properties.
   *
   * @type {string}
   * @private
   */
  _externalUrl;


  /**
   * The full pageReference object created by the createPageReference method. This is the object
   * passed to the NavigationMixin.
   *
   * @type {object}
   * @private
   */
  formattedPageReference;


  /**
   * Indicates if the link has slot content.
   *
   * @type {boolean}
   * @private
   */
  hasSlotContent = false;


  /**
   * The HREF for the actual anchor element.
   *
   * @type {string}
   * @private
   */
  href = '';


  /**
   * Internal version of the objectPage api property. See definition in class properties.
   *
   * @type {string}
   * @private
   */
  _objectPage;


  /**
   * Indicates if an error has been encountered. If so, the link is not displayed.
   *
   * @type {boolean}
   * @private
   */
  noError = true;


  /**
   * Internal version of the pageReference api property. See definition in class properties.
   *
   * @type {object}
   * @private
   */
  _pageReference;


  /**
   * Internal version of the params api property. See definition in class properties.
   *
   * @type {object}
   * @private
   */
  _params;


  /**
   * Internal version of the recordId api property. See definition in class properties.
   *
   * @type {string}
   * @private
   */
  _recordId;




  // ******* Class getters ********
  /**
   * Determines the CSS classes to apply to the anchor element.
   *
   * @returns {string} The CSS classes to apply to the anchor.
   * @private
   */
  get anchorClasses() {
    const classes = this.className.split(' ');
    return [
      'core-link',
      (classes.includes('button') || classes.includes('link-no-style')) ? '' : 'link-text',
      this.className,
      (this.preview && this.preview !== 'false') ? 'core-link-preview' : '',
      (this.inverse && this.inverse !== 'false') ? 'color-white inverse' : '',
    ].join(' ');
  }



  /**
   * Determines if the icon should be hidden.
   *
   * @returns {boolean} Indicates if the icon should be hidden.
   * @private
   */
  get anchorHideIcon() {
    // Match the string value
    if (this.hideIcon === 'false' || this.iconName) {
      return false;
    }

    // Only display an icon if there is link content
    if (!this.label && !this.hasSlotContent) {
      return true;
    }

    // These are the default conditions for showing the icon
    if (this.hideIcon || ((this.anchorTarget === '_self' || this.anchorTarget === '') && !(this.externalUrl && this.externalUrl.startsWith('mailto')))) {
      return true;
    }

    // If it got past the default conditions, then the icon should not be displayed
    return false;
  }



  /**
   * Determines the target window for the anchor element.
   *
   * @returns {string} The target window for the anchor element.
   * @private
   */
  get anchorTarget() {
    // Check if a target was set via the api
    if (this.target) {
      return this.target;
    }

    // Default all external urls except mailto open in a new window
    if (this.externalUrl && !this.externalUrl.startsWith('mailto') && !this.externalUrl.startsWith('#')) {
      return '_blank';
    }

    // If it got this far, open it in the current window
    return '';
  }



  /**
   * Determines the title attribute for the anchor element.
   *
   * @returns {string} The title attribute for the anchor element.
   * @private
   */
  get anchorTitle() {
    return this.title || this.label;
  }



  /**
   * Determines the aria-label attribute for the anchor element.
   *
   * @returns {string} The aria-label attribute for the anchor element.
   * @private
   */
  get ariaLabelValue() {
    let labelValue = this.ariaLabel || this.title || this.label;
    const target = this.anchorTarget;
    if (target !== '' && target !== '_self') {
      labelValue += ` ${newWindowMessage}`;
    }

    return labelValue;
  }



  /**
   * Determines the CSS classes to apply to the icon container. If a Font Awesome icon is
   * being used, it will be returned with the classes.
   *
   * @returns {string} The CSS classes to apply to the icon container.
   * @private
   */
  get iconClasses() {
    let fullIconClasses = [];

    // Add any classes passed in via the api
    if (this.iconClass) {
      fullIconClasses = [this.iconClass];
    }

    // Only Font Awesome icons are defined as CSS classes
    if (!this.salesforceIcon) {
      let defaultIconClass = '';

      // Determine the appropriate Font Awesome class
      if (this.iconName) {
        defaultIconClass = this.iconName;
      } else if (this.externalUrl && this.externalUrl.startsWith('mailto')) {
        defaultIconClass = 'fa-mail-1';
      } else if (this.anchorTarget === '_self' || this.anchorTarget === '') {
        defaultIconClass = 'fa-arrow-right';
      } else {
        defaultIconClass = 'fa-link-ext';
      }
      fullIconClasses.push(defaultIconClass);
    }

    // Return classes along with defaults
    return `core-link-icon ${fullIconClasses.join(' ')}`;
  }



  /**
   * Determines the name of the Salesforce icon to use.
   *
   * @returns {string} The name of the Salesforce icon.
   * @private
   */
  get salesforceIconName() {
    let name = '';
    if (this.salesforceIcon) {
      // Determine the appropriate Salesforce icon
      if (this.iconName) {
        name = this.iconName;
      } else if (this.externalUrl && this.externalUrl.startsWith('mailto')) {
        name = 'utility:email';
      } else if (this.anchorTarget === '_self' || this.anchorTarget === '') {
        name = 'utility:forward';
      } else {
        name = 'utility:new_window';
      }
    }
    return name;
  }



  /**
   * Determines if the slot needs to be hidden and if so, returns the SLDS class to hide it.
   *
   * @returns {string} The CSS class to hide the slot content.
   * @private
   */
  get slotClass() {
    return !this.hasSlotContent && this.label ? 'slds-hide' : '';
  }



  // ******* Standard Methods ********
  /**
   * Sets a flag to indicate connectedCallback has run, since the NavigationMixin will not work
   * properly until connectedCallback has run. Also, calls the method to generate the HREF for the
   * link.
   *
   * @private
   */
  connectedCallback() {
    this.connectedCallbackDone = true;
    this.updateNavigationReference();
  }



  /**
   * Creates a Salesforce PageReference object based on the parameters passed in via the api.
   *
   * @returns {object} The Salesforce PageReference object to be used by the NavigationMixin.
   * @private
   */
  createPageReference() {
    if (this.pageReference) {
      return this.pageReference;
    }

    let newPageReference;

    // Page Reference -- Community Page
    if (this.communityPage) {
      newPageReference = {
        type: 'comm__namedPage',
        attributes: {
          name: this.communityPage,
        },
      };
    }

    // Page Reference -- Object Page
    if (this.objectPage && !this.recordId) {
      newPageReference = {
        type: 'standard__objectPage',
        attributes: {
          actionName: 'list',
          objectApiName: this.objectPage,
        },
      };
    }

    // Page Reference -- Record Page
    if (this.recordId) {
      newPageReference = {
        type: 'standard__recordPage',
        attributes: {
          actionName: 'view',
          objectApiName: this.objectPage,
          recordId: this.recordId,
        },
      };
    }

    // Check if parameters were passed
    if (newPageReference && this.params) {
      newPageReference.state = this.params;
    }

    return newPageReference;
  }



  /**
   * Called when the user clicks on the link. Determines if the event needs to be cancelled, as well as invokes the NavigationMixin if
   * the HREF was not updated for no SEO conversion. Finally, it throws the corelinkclick event.
   *
   * @param {object} evt  The standard DOM click event.
   * @private
   */
  handleClick(evt) {
    if ((this.prevent && this.prevent !== 'false') || (this.preview && this.preview !== 'false')
      || (!this.externalUrl && this.noSeoConvert && this.noSeoConvert !== 'false')) {
      evt.preventDefault();
      evt.stopPropagation();

      // Check if the HREF was not updaated
      if (!(this.prevent && this.prevent !== 'false') && !(this.preview && this.preview !== 'false')
        && !this.externalUrl && this.noSeoConvert && this.noSeoConvert !== 'false') {
        // It was not so use the NavigationMixin to do the navigation
        this[NavigationMixin.Navigate](this.formattedPageReference);
      }
    }

    // Default to label, and get text if it is not set
    let anchorText = this.label;
    if (!anchorText) {
      const slotContent = this.template.querySelector('slot').assignedNodes();
      if (slotContent.length) {
        anchorText = slotContent[0].textContent;
      }
    }

    // Throw the event
    this.dispatchEvent(
      new CustomEvent('corelinkclick', {
        bubbles: true,
        cancelable: true,
        composed: true,
        detail: {
          communityPage: this.communityPage,
          externalUrl: this.externalUrl,
          href: this.href,
          label: anchorText,
          objectPage: this.objectPage,
          pageRef: this.formattedPageReference,
          recordId: this.recordId,
        },
      }),
    );
  }



  /**
   * Updates the variable that tracks whether there is slot content.
   *
   * @param {object} evt  The standard DOM slotChange event.
   * @private
   */
  handleSlotChange(evt) {
    let hasContent = false;
    const slotNodes = evt.target.assignedNodes({ flatten: true });
    const slotNodesLength = slotNodes.length;

    // Check for anything other than an empty slot
    for (let count = 0; count < slotNodesLength; count += 1) {
      if (slotNodes[count].tagName !== 'SLOT') {
        hasContent = true;
        break;
      }
    }

    this.hasSlotContent = hasContent;
  }



  /**
   * The ARIA attributes are dynamically set in the DOM, so can't set them until the anchor
   * element is added to the DOM.
   *
   * @private
   */
  renderedCallback() {
    this.updateAria();
  }



  /**
   * Sets the HREF attribute for the anchor element.
   *
   * @private
   */
  async setHref() {
    if (this.externalUrl) {
      this.href = this.externalUrl;
    } else if (!this.noSeoConvert || this.noSeoConvert === 'false') {
      // Only update the HREF if not doing SEO conversion
      const url = await this[NavigationMixin.GenerateUrl](this.formattedPageReference);
      this.href = url || '';
    }
  }



  /**
   * Updaates the ARIA attributes in the DOM based on the ariaSkip value. This will make the
   * anchor element visible/invisible to screen readers.
   *
   * @private
   */
  updateAria() {
    // Update the DOM if the anchor should be skipped by screen readers, or if it has been skipped
    // in the past and now should not be skipped.
    if (this.ariaSkipSet || this.ariaSkip) {
      const anchorElement = this.template.querySelector('a');
      if (anchorElement) {
        anchorElement.setAttribute('aria-hidden', String(this.ariaSkip));
        anchorElement.setAttribute('tabindex', this.ariaSkip ? '-1' : '0');
        this.ariaSkipSet = true;
      }
    }
  }



  /**
   * Called whenever one of the HREF related api properties are changed. Sets the
   * Salesforce PageReference and updates the HREF.
   *
   * @private
   */
  updateNavigationReference() {
    this.formattedPageReference = this.createPageReference();
    if (this.connectedCallbackDone && this.validateLink() && (this.externalUrl || (!this.noSeoConvert || this.noSeoConvert === 'false'))) {
      this.setHref();
    }
  }



  /**
   * Determines if a link includes the needed api values.
   *
   * @returns {boolean} Indicates if the link is valid.
   * @private
   */
  validateLink() {
    let message = '';

    if (!message && this.recordId && !this.objectPage) {
      message = 'a record-id is given but an object-page is not included.';
    }
    if (!message && !this.externalUrl && !this.communityPage && !this.objectPage && !this.pageReference) {
      message = 'an external-url, community-page, object-page, or page-reference must be included';
    }

    if (message) {
      this.noError = false;
      if (this.throwError && this.throwError !== 'false') {
        throw new TypeError(message);
      } else {
        console.error(`Error in coreIntcLink: ${message}`);
      }
      return false;
    }

    this.noError = true;
    return true;
  }
}
export default CoreIntcLink;