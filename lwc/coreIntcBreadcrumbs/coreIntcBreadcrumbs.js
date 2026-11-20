import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


/**
 * A reusable component for interacting with the IGHF second
 * level of navigation (breadcrumbs).
 *
 * The CoreIntcBreadcrumbs component exposes a renderBreadcrumbs method that expects a
 * [BreadcrumbNavigation]{@link BreadcrumbNavigation} object with child [Breadcrumbs]{@link Breadcrumb}. This object will
 * be passed to the IGHF to render the second level navigation/breadcrumbs.
 *
 * [Breadcrumbs]{@link Breadcrumb} are defined by either specifying a url property or a data property. If a url is specified, the
 * breadcrumb will be rendered as a standard HTML link. If a data property is specified, its sfData property is
 * passed to the [NavigationMixin.Navigate](https://developer.salesforce.com/docs/component-library/bundle/lightning-navigation/documentation)
 * method as the pageReference parameter. If no url or data property is specified, the breadcrumb will be rendered as standard text.
 *
 * @example
 * // This is example code for defining the BreadcrumbNavigation object in your LWC and
 * // then calling the renderBreadcrumbs method. It includes examples of standard links and
 * // pageReference objects.
 *
 * import { LightningElement } from 'lwc';
 *
 * class myComponent extends LightningElement {
 *   // Indicates if the navigation breadcrumbs have already been rendered.
 *   breadcrumbsRendered = false;
 *
 *   // Example navigation object
 *   navigation = {
 *     breadcrumb: {
 *       id: 1,
 *       selected: true,
 *       text: 'Intel Partner Alliance',
 *       children: [
 *         {
 *           id: 16,
 *           text: 'FIND PARTNERS',
 *         },
 *         {
 *           id: 2,
 *           text: 'Partner Home',
 *           url: 'https://partnerhome.intel.com',
 *         },
 *         {
 *           data: {
 *             sfData: {
 *               type: 'comm__namedPage',
 *               attributes: {
 *                 pageName: 'home',
 *               },
 *             },
 *           },
 *           id: 3,
 *           text: 'Partner Benefits',
 *         },
 *         {
 *           id: 5,
 *           text: 'Sales Enablement Resources',
 *           url: 'https://salesresources.intel.com',
 *           target: '_blank',
 *         },
 *         {
 *           id: 6,
 *           selected: true,
 *           text: 'About Membership',
 *           url: 'https://aboutmembership.intel.com',
 *           children: [
 *             {
 *               id: 8,
 *               text: 'Sales Enablement Resources',
 *               url: 'https://salesresources.intel.com',
 *             },
 *           ],
 *         },
 *         {
 *           id: 9,
 *           text: 'Get Help',
 *           url: 'https://gethelp.intel.com',
 *         },
 *       ],
 *     },
 *   };
 *
 *
 *   // Use the renderedCalledback lifecycle hook since the coreIntcBreadcrumbs
 *   // component will not be available until DOM attachment.
 *   renderedCallback() {
 *     // Only invoke the breadcrumb logic the first time the component is rendered
 *     if (!this.breadcrumbsRendered) {
 *       this.breadcrumbsRendered = true;
 *       // Call the method to actually render the breadcrumbs. There are additional optional parameters that
 *       // are documented in the method description below.
 *       this.template.querySelector('c-core-intc-breadcrumbs').renderBreadcrumbs(this.navigation);
 *     }
 *   }
 * }
 *
 * @example
 * <!-- HTML component example - include coreIntcBreadcrumbs in your component-->
 * <c-core-intc-breadcrumbs></c-core-intc-breadcrumbs>
 *
 * @augments NavigationMixin
 * @augments LightningElement
 */
class CoreIntcBreadcrumbs extends NavigationMixin(LightningElement) {
  // NOTE > This component was not implemented as a service component due to issues with getting the
  // NavigationMixin to work without using the LightningElement. Hopefully, Salesforce releases a
  // navigation API that does not have this constraint and this component can be converted to a service
  // component.
  //
  // ******* Track variables ********
  /**
   * Full URL for this domain. Used for window messaging.
   *
   * @type {string}
   * @private
   */
  fullLocation = `${window.location.protocol}//${window.location.hostname}${window.location.port ? `:${window.location.port}` : ''}`;



  // ******* API functions - defined in class properties *******
  /**
   * A method to call to render the second level navigation/breadcrumbs.
   *
   * @param {BreadcrumbNavigation} breadcrumbNavigation  An array of child navigation links for a breadcrumb.
   * @param {boolean} [noPopupHeaders=false] Indicates if selected links should not be copied into their popup menu as the first item.
   * @param {boolean} [noSeoConvert=false] Indicates if the data object used by the NavigationMixin should not be converted to a URL.
   * @param {boolean} [noAnalytics=false] Indicates if analytics should not be tracked when breadcrumbs are clicked.
   * @public
   */
  @api
  renderBreadcrumbs(breadcrumbNavigation, noPopupHeaders, noSeoConvert, noAnalytics) {
    this.validateBreadcrumb(breadcrumbNavigation.breadcrumb);

    // Check if need to add a copy of the selected breadcrumb to its popup menu
    let breadcrumbs = breadcrumbNavigation;
    let copyBreadcrumbs = true;
    if (!noPopupHeaders) {
      breadcrumbs = this.addPopupHeaders(breadcrumbNavigation);
      copyBreadcrumbs = false;
    }

    this.convertForSeo(noSeoConvert, breadcrumbs, copyBreadcrumbs, noAnalytics).then((seoBreadcrumbs) => {
      // Set up the listener that will be called from the community HEAD.
      window.addEventListener('message', this.doNavigate, false);

      // Send the breadcrumbs to the listener in the community HEAD that will call the IGHF code
      window.postMessage({ type: 'intel.renderBreadcrumbs', data: seoBreadcrumbs }, this.fullLocation); // NOSONAR
    });
  }



  // ******* Functions ********
  /**
   * Inserts a new child link for all selected breadcrumbs. This new child link is a copy of itself, so
   * that it is displayed as the first menu option in the popup.
   *
   * @param {BreadcrumbNavigation} breadcrumbNavigation  An array of child navigation links for a breadcrumb.
   * @returns {BreadcrumbNavigation} A new BreadcrumbNavigation object that has the selected items as their
   * own first child.
   * @private
   */
  addPopupHeaders(breadcrumbNavigation) {
    // Create a new copy of the object so the original version is not modified.
    // Using JSON methods since none of the properties in this data should run into
    // the limitations inherent in this approach for deep copying.
    const newBreadcrumbNavigation = JSON.parse(JSON.stringify(breadcrumbNavigation));

    // Loop variables
    let selectedItem = newBreadcrumbNavigation.breadcrumb;
    let newSelectedItem;
    let count = 0;
    let length = 0;

    // Continue looping while there is a selected breadcrumb
    while (selectedItem) {
      // Check if the selected link has children
      if (selectedItem.children && selectedItem.children.length) {
        // Yes, so this means a popup will be created and we need to
        // insert a copy of itself
        const selectedCopy = {
          id: `${selectedItem.id}-header`,
          text: selectedItem.text,
          url: selectedItem.url,
          useCallback: selectedItem.useCallback || false,
        };
        if (selectedItem.data) {
          selectedCopy.data = selectedItem.data;
        }
        selectedItem.children.splice(0, 0, selectedCopy);

        // Loop through the selected item to see if it has a selected child
        newSelectedItem = null;
        length = selectedItem.children.length;
        for (count = 0; count < length; count += 1) {
          // Check if selected
          if (selectedItem.children[count].selected) {
            // Yes so break the loop
            newSelectedItem = selectedItem.children[count];
            break;
          }
        }

        // A new selected link was found so need to go recursively go through its children
        if (newSelectedItem !== selectedItem) {
          selectedItem = newSelectedItem;
        } else {
          // A new selected link wasn't found so exit the loop
          break;
        }
      } else {
        // No children so there can be no popup
        break;
      }
    }

    return newBreadcrumbNavigation;
  }



  /**
   * Returns a [BreadcrumbNavigation]{@link BreadcrumbNavigation} object with all data objects converted to
   * URLs (based on parameters).
   *
   * @param {boolean} noSeoConvert  Indicates if data objects should not be converted to URLs.
   * @param {BreadcrumbNavigation} breadcrumbNavigation  The breadcrumbs to potentially convert from a data objects to URLs.
   * @param {boolean} copyBreadcrumbs  Indicates if the breadcrumbNavigation object should be copied.
   * @param {boolean} noAnalytics  Indicates if analytics are not being tracked.
   * @returns {BreadcrumbNavigation} The BreadcrumbNavigation after all breadcrumbs have been converted.
   * @private
   */
  convertForSeo(noSeoConvert, breadcrumbNavigation, copyBreadcrumbs, noAnalytics) {
    let newBreadcrumbNavigation = breadcrumbNavigation;
    if (copyBreadcrumbs) {
      // Create a new copy of the object so the original version is not modified.
      // Using JSON methods since none of the properties in this data should run into
      // the limitations inherent in this approach for deep copying.
      newBreadcrumbNavigation = JSON.parse(JSON.stringify(breadcrumbNavigation));
    }

    // Create an array to hold all the promises returned by the NavigationMixin
    const updatedBreadcrumbs = [];

    // Call the method to convert breadcrumbs
    this.getSeoLinks(updatedBreadcrumbs, newBreadcrumbNavigation.breadcrumb, noSeoConvert, noAnalytics);

    // Check if there were any breadcrumbs to convert
    if (updatedBreadcrumbs.length) {
      // Yes so return the update breadcrumbs after all the conversions resolve
      return Promise.all(updatedBreadcrumbs).then(() => newBreadcrumbNavigation);
    }

    // No breadcrumbs to convert so just return what was passed in
    return Promise.resolve(newBreadcrumbNavigation);
  }



  /**
   * Called when the element is removed from the DOM. Used to remove the window message listener.
   *
   * @private
   */
  disconnectedCallback() {
    window.removeEventListener('message', this.doNavigate);
  }



  /**
   * Called when a window message is received. Used to invoke Salesforce navigation for
   * [Breadcrumbs]{@link Breadcrumb} that have useCallback set to true. Messaging is used to communicate with
   * scripts in the community's HEAD element.
   *
   * @param {object} evt  The Javascript message event object.
   * @private
   */
  doNavigate = (evt) => {
    if (evt.origin === this.fullLocation && evt.data && evt.data.type === 'intel.doNavigate') {
      // The standard message data object will contain the data parameter to be used by
      // the Salesforce navigation api.
      this[NavigationMixin.Navigate](evt.data.data);
    }
  };



  /**
   * Determines if a breadcrumb is for a Salesforce link and then converts it from
   * a data object to a url.
   *
   * @param {object[]} updatedBreadcrumbs  The array of promises created by the NavigationMixin.
   * @param {Breadcrumb} breadcrumb  The breadcrumb to potentially convert from a data object to a URL.
   * @param {boolean} noSeoConvert  Indicates if data objects should not be converted to URLs.
   * @param {boolean} noAnalytics  Indicates if analytics are not being tracked.
   * @private
   */
  getSeoLink(updatedBreadcrumbs, breadcrumb, noSeoConvert, noAnalytics) { // NOSONAR
    /* eslint-disable no-param-reassign */
    if (this.isSalesforceLink(breadcrumb)) {
      if (!noSeoConvert || !noAnalytics) {
        let navigationData = breadcrumb.data;
        if (breadcrumb.data.sfData) {
          navigationData = breadcrumb.data.sfData;
        }
        // Call the NavigationMixin to get the URL for a data object
        updatedBreadcrumbs.push(this[NavigationMixin.GenerateUrl](navigationData).then((url) => {
          if (noSeoConvert) {
            breadcrumb.useCallback = true;
            breadcrumb.data = breadcrumb.data || {};
            breadcrumb.data.cancelEvent = true;
            if (!noAnalytics) {
              breadcrumb.data.analyticsUrl = `${this.fullLocation}${url}`;
              breadcrumb.data.analyticsText = breadcrumb.text;
            }
          } else {
            if (breadcrumb.data.sfData) {
              delete breadcrumb.data.sfData;
              if (Object.keys(breadcrumb.data).length === 0) {
                delete breadcrumb.data;
              }
            } else {
              delete breadcrumb.data;
            }
            breadcrumb.url = url;
            if (!noAnalytics) {
              breadcrumb.useCallback = true;
            }
          }
        }));
      } else {
        breadcrumb.data = breadcrumb.data || {};
        breadcrumb.data.cancelEvent = true;
      }
    } else if (!noAnalytics && breadcrumb.url) {
      breadcrumb.useCallback = true;
    }
    /* eslint-enable no-param-reassign */
  }



  /**
   * Calls the method to convert a Salesforce breadcrumb from a data object to a url. Also does this
   * recursively for the breadcrumb's children.
   *
   * @param {object[]} updatedBreadcrumbs  The array of promises created by the NavigationMixin.
   * @param {Breadcrumb} breadcrumb  The breadcrumb to potentially convert from a data object to a URL.
   * @param {boolean} noSeoConvert  Indicates if data objects should not be converted to URLs.
   * @param {boolean} noAnalytics  Indicates if analytics are not being tracked.
   * @private
   */
  getSeoLinks(updatedBreadcrumbs, breadcrumb, noSeoConvert, noAnalytics) {
    this.getSeoLink(updatedBreadcrumbs, breadcrumb, noSeoConvert, noAnalytics);
    if (breadcrumb.children) {
      breadcrumb.children.forEach((child) => {
        this.getSeoLinks(updatedBreadcrumbs, child, noSeoConvert, noAnalytics);
      });
    }
  }



  /**
   * Determines if a breadcrumb uses the data object to link to a Salesforce page.
   *
   * @param {Breadcrumb} breadcrumb  The breadcrumb to test if it is a Salesforce link.
   * @returns {boolean} Indicates if the link is for a Salesforce page.
   * @private
   */
  isSalesforceLink(breadcrumb) {
    const pageTypes = [
      'standard__app',
      'standard__component',
      'standard__knowledgeArticlePage',
      'comm__loginPage',
      'comm__namedPage',
      'standard__namedPage',
      'standard__navItemPage',
      'standard__objectPage',
      'standard__recordPage',
      'standard__recordRelationshipPage',
      'standard__webPage',
    ];

    if (breadcrumb.data && (breadcrumb.data.sfData || pageTypes.includes(breadcrumb.data.type))) {
      return true;
    }
    return false;
  }



  /**
   * Validates that a breadcrumb has an ID and does not have multiple selected children.
   * This method recursively calls itself to validate all child breadcrumbs.
   *
   * @param {Breadcrumb} breadcrumb  The breadcrumb to be validated.
   * @private
   */
  validateBreadcrumb(breadcrumb) {
    if (breadcrumb.id === undefined || breadcrumb.id === null) {
      throw new Error(`Error in Breadcrumbs - "${breadcrumb.text}" does not have an ID`);
    }
    if (breadcrumb.children && breadcrumb.children.length) {
      let selected = false;
      breadcrumb.children.forEach((child) => {
        if (child.selected) {
          if (selected) {
            throw new Error(`Error in Breadcrumbs - "${breadcrumb.text}" has multiple selected children`);
          } else {
            selected = true;
          }
        }
        this.validateBreadcrumb(child);
      });
    }
  }
}
export default CoreIntcBreadcrumbs;



// ********* Type Definitions ************
/**
 * Represents the first breadcrumb to be rendered by the IGHF as part of the second
 * level navigation. This object is passed directly to the IGHF method.
 *
 * @typedef BreadcrumbNavigation
 * @property {Breadcrumb} breadcrumb  The first breadcrumb to be rendered by the IGHF. Additional
 * breadcrumbs need to be represented as children of this breadcrumb.
 */

/**
 * Represents a breadcrumb/link to be displayed in the second level navigation of the IGHF.
 *
 * @typedef Breadcrumb
 * @property {Function} [callback] A function to be called when the user clicks on a link. The callback property
 * can only be set for the first (top level) breadcrumb, it cannot be set for children. Children can set the "useCallback"
 * property to indicate if the top level callback function should be called when the user clicks on that child. The callback
 * function will be added by default if it is not specified. The default callback function will invoke the
 * [NavigationMixin.Navigate](https://developer.salesforce.com/docs/component-library/bundle/lightning-navigation/documentation)
 * method and pass the "data" object to it as the pageReference parameter.
 * @property {Breadcrumb[]} [children] An array of breadcrumbs/links that are the children of this link.
 * @property {object} [data] An object to be passed to the “callback” function when "useCallback" is set to true. This object
 * should have a property called "sfData" if it is to use the Salesforce NavigationMixin for navigation.
 * @property {string | number} id An ID unique across all breadcrumbs/links.
 * @property {boolean} [selected=false] Indicates if this breadcrumb/link is in the current page’s navigation hierarchy.
 * @property {string} [target] The [target](https://www.w3schools.com/tags/att_a_target.asp) attribute for an HTML link.
 * @property {string} text The text to display for the breadcrumb/link.
 * @property {string} [url] The url of the link.
 * */