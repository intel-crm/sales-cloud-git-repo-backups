import { api, LightningElement } from 'lwc';
import { makeIpaAnalyticsCall } from 'c/ipaAnalyticsService';
import websiteLabel from '@salesforce/label/c.PMP_Website';

/**
 * A reusable component for Marketplace/IPA links. This component is built on top of the coreIntcLink component.
 * It includes additional functionality for making analytics calls, as well as search related settings.
 *
 * <h2>Label / Slotted Content</h2><br>
 * If no slotted content is passed the link will display the 'label' value as the link text.<br>
 * If using slotted content a 'label' attribute should still be passed in to set the <code>aria-label</code> value.</i>
 *
 * <br><h2>Truncation and Global Classes</h2><br>
 * To truncate the link label, (or add any additional styling with classes) use the <code>className</code>
 * attribute with global classes.<br>For truncation use "truncate-1" for 1 line, "truncate-3" for 3 lines, etc.
 *
 * @example
 * <!-- HTML component example -->
 * <!-- Basic Link with Label -->
 * <c-ipa-link label="Home Page" community-page="home"></c-ipa-link>
 *
 * @example
 * <!-- HTML component example -->
 * <!-- Link with Slotted Content -->
 * <c-ipa-link label="Home Page" community-page="home">
 *      <img src="home.png">
 * </c-ipa-link>
 *
 * @example
 * <!-- HTML component example -->
 * <!-- External Url without popout Icon -->
 * <c-ipa-link label="Intel.com" external-url="https://www.intel.com" hide-icon></c-ipa-link>
 *
 * @example
 * <!-- HTML component example -->
 * <!-- Record Page Link with a caret on a dark theme -->
 * <c-ipa-link inverse caret label="Home Page" object-page="Account" record-id="XX23e23"></c-ipa-link>
 *
 * @property {string} [analyticsElement=""] Name to use for the element property of the analytics call. Defaults to an empty string.
 * @property {string} [ariaLabel] A string to use as the
 *  [aria-label](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/ARIA_Techniques/Using_the_aria-label_attribute). Defaults to
 *  the <code>label</property> if ariaLabel is not set.
 * @property {boolean} [ariaSkip=false] Indicates if the link should be hidden from screen readers by setting
 *  [aria-hidden](https://developer.mozilla.org/en-US/docs/Web/API/Element/ariaHidden) to true and the tabindex to -1.
 * @property {boolean} [caret=false] Indicates if the caret icon (font awesome "fa-arrow-right") should be displayed after the link.
 * @property {string} [className] A string of CSS classes to add to the anchor element. These classes must be global CSS classes (such
 *  as Salesforce slds classes) in order to be applied to the link. If a class name of "button" or "link-no-style" is passed, the
 *  standard link styling will not be applied.
 * @property {string} [communityPage] The name when using a Named Page Type (Experience Builder Sites) Salesforce
 *  [PageReference](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type).
 * @property {string} [doAnalytics="true"] Indicates if an analytics call should be made when the user clicks on the link.
 * @property {string} [externalUrl] The URL to use for the link. If this is not set, then the <code>communityPage</code>, <code>objectPage</code>,
 *  or <code>pageReference</code> must be set.
 * @property {boolean} [hideIcon=false] Indicates if the icon should be hidden, regardless of the type of link and target.
 * @property {boolean} [inverse=false] Indicates if inverse styling should be applied to the link. This includes setting the color to white and
 *  adding a dashed underline. Used this when rendering the link on a dark colored background.
 * @property {string} [label] The text for the link.
 * @property {boolean} [newWindow=false] Indicates if the link should be opened in new window <i>(NOTE: external urls open in new window by default)</i>.
 * @property {string} [objectPage] The objectApiName when using an Object Type Salesforce
 *  [PageReference](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type).
 * @property {object} [pageReference] A Salesforce
 *  [PageReference](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type) to use to generate
 *  the link's href.
 * @property {object} [params] An object containing name:value pairs to be added as querystring parameters when using a Salesforce
 *  [PageReference](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type) to navigate.
 * @property {boolean} [prevent=false] Indicates if the anchor click event should be have preventDefault and stopPropagation called. Setting this to true
 *  will cause the ipaLink to throw a custom link event.
 * @property {boolean} [preview=false] Indicates if the link should not be clickable (although clicking on it will generate a corelinkclick event).
 * @property {string} [recordId] The recordId when using an Record Page Type Salesforce
 *  [PageReference](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type). If recordId is set,
 *  the <code>objectPage</code> must also be set. If the <code>communityPage</code> or <code>externalUrl</code> are set in addition to the recordId,
 *  the recordId is set to blank since it will not be used by an externalUrl or community page.
 * @property {object} [searchParams] Search parameters to pass in the querystring ("search=""). Including this will generate a page reference to the
 *  PMP_Offering_Category__c page.
 */
class IpaLink extends LightningElement {
  // ******* API variables - defined in class properties *******
  @api analyticsElement = '';

  @api analyticsPage = '';

  @api ariaLabel;

  @api ariaSkip;

  @api caret;

  @api className = '';

  @api communityPage;

  @api doAnalytics = 'true';

  @api externalUrl;

  @api hideIcon;

  @api inverse;

  @api label = '';

  @api newWindow;

  @api objectPage;

  @api pageReference;

  @api params;

  @api prevent;

  @api preview;

  @api recordId;

  @api searchParams;

  labels={
    website: websiteLabel
  };


  // ******* Class getters ********
  /**
   * Converts the caret property into the coreIntcLink iconName property.
   *
   * @returns {string} The value for the coreIntcLink iconName property.
   * @private
   */
  get anchorIconName() {
    if (this.caret) {
      return 'fa-arrow-right';
    }
    return '';
  }



  /**
   * Returns the pageReference if it was set, or creates a pageReference when searchParams are included.
   *
   * @returns {object} The pageReference to pass to coreIntcLink.
   * @private
   */
  get anchorPageReference() {
    // Pass the pageReference if it was set
    if (this.pageReference) {
      return this.pageReference;
    }

    // searchParams included so create a pageReference and pass it
    //IPA2.0:US-4497-1631_OfferingEOL
    // if (!this.objectPage && this.searchParams && this.searchParams.cat) {
    //   return {
    //     type: 'standard__recordPage',
    //     attributes: {
    //       recordId: this.searchParams.cat,
    //       objectApiName: 'PMP_Offering_Category__c',
    //       actionName: 'view',
    //     },
    //   };
    // }

    return null;
  }



  /**
   * Adds searchParams to the passed in params, or if no params were passed,
   * creates a params object and adds searchParams to it.
   *
   * @returns {object} The pageReference to pass to coreIntcLink.
   * @private
   */
  get anchorParams() {
    let newParams = this.params;

    // Add searchParams
    if (this.searchParams && Object.keys(this.searchParams).length > 0) {
      newParams = newParams || {};
      newParams.search = encodeURIComponent(JSON.stringify(this.searchParams));
    }

    return newParams;
  }



  /**
   * The original ipaLink defaulted to a externalUrl/communityPage if it was set, even if a
   * recordId was passed, whereas coreIntcLink is the opposite. This getter is used to mimic
   * the original ipaLink functionality.
   *
   * @returns {string} The recordId to pass to coreIntcLink.
   * @private
   */
  get anchorRecordId() {
    if (this.externalUrl || this.communityPage) {
      // Blank the recordId since it is not used with an external url or community page
      return '';
    }
    return this.recordId;
  }



  /**
   * Determines the target window for the anchor element.
   *
   * @returns {string} The target window for the anchor element.
   * @private
   */
  get anchorTarget() {
    // Default all external urls except mailto open in a new window
    if (this.newWindow || (this.externalUrl && !this.externalUrl.startsWith('mailto'))) {
      return '_blank';
    }

    // If it got this far, open it in the current window
    return '';
  }




  // ******* Standard Methods ********
  /**
   * Calls analytics when the link is clicked and dispatches a click event when prevent is true.
   *
   * @param {object} linkClickEvent  The corelinkclick event thrown by the coreIntcLink.
   * @private
   */
  handleLinkClick(linkClickEvent) {
    if (this.doAnalytics === 'true') {
      this.makeAnalyticsCall(linkClickEvent);
    }

    // Stop the corelinkclick event from propagating since we will throw the ipaLink click event
    linkClickEvent.stopPropagation();

    // Only throw the click event when prevent is true
    if (this.prevent) {
      this.dispatchEvent(
        new CustomEvent('click', {
          detail: {
            externalUrl: linkClickEvent.detail.externalUrl,
            communityPage: linkClickEvent.detail.communityPage,
            objectPage: linkClickEvent.detail.objectPage,
            recordId: linkClickEvent.detail.recordId,
            pageRef: linkClickEvent.detail.pageRef,
          },
        }),
      );
    }
  }



  /**
   * Creates a data object based on the link's properties and sends that
   * to the analytics library to be logged.
   *
   * @param {object} linkClickEvent  The corelinkclick event thrown by the coreIntcLink.
   * @private
   */
  makeAnalyticsCall(linkClickEvent) {
    // Create the parameters for the analytics post
    
    if(linkClickEvent.detail.label != '' && linkClickEvent.detail.label.includes(this.labels.website)){
      this.analyticsElement = this.labels.website;
      //messageData.pageType = 'PartnerDetailPage';
    }

    const messageData = {
      analyticsType: 'click',
      element: this.analyticsElement || '',
      pageTitle: linkClickEvent.detail.label || '',
      targetURL: linkClickEvent.detail.href || '',
    };

    

    if(this.analyticsPage){
      messageData.pageType = this.analyticsPage;
    }
    // Call the helper library to log the analytics data
    makeIpaAnalyticsCall(messageData);
  }
}
export default IpaLink;