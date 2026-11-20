import { LightningElement, api, track } from 'lwc';
import CoreINTC from '@salesforce/resourceUrl/Core_INTC';


/**
 * A reusable component for displaying contacts. The component has different displays that can be set
 * via the version property.
 *
 * ### Key differences between versions are:
 * * Version 1 allows for a single link to be displayed, whereas version 2 allows for multiple links to be displayed.
 * * Version 1 displays a large image for each contact, whereas version 2 displays a much smaller icon.
 * * Version 1 displays 3 contacts in a row, whereas version 2 displays four.
 *
 * ### Notes:
 * * The CoreIntcContacts component expects an array of [Contacts]{@link Contact} to be passed to it.
 *   See {@link Contact} for a list of properties relevant to each version.
 * * In resolutions below 768 pixels, the component displays each contact on its own line.
 * * It is up to the developer to add the appropriate amount of padding in their component containing CoreIntcContacts.
 *
 * <div id="core-examples" sf-attr="c-coreintccontacts_coreintccontacts">
 *  <demo-core-intc-contacts show1="true"></demo-core-intc-contacts>
 *  <demo-core-intc-contacts show2="true"></demo-core-intc-contacts>
 * </div>
 *
 * @example
 * // JavaScript component example 1
 * // This is example code for defining the contacts parameter in your JavaScript file. Note that you may need to track
 * // your contacts variable depending on how you are setting it.
 *
 * // contacts in version 1 format
 * contacts1 = [
 *   {
 *     copy: 'Contact us anytime, we will respond within 1 business day.',
 *     imgUrl: '/imp/resource/1575453332000/PMP_Contact_us_RequestSupport',
 *     label: 'Request Support',
 *     linkUrl: 'https://www.intel.com',
 *     linkCopy: 'Submit Request',
 *   },
 *   {
 *     copy: 'Chat is available during normal business hours.',
 *     imgUrl: 'chat',
 *     label: 'Chat',
 *     linkUrl: 'https://www.intel.com',
 *     linkCopy: 'Chat Now',
 *     linkTarget: '_self',
 *   },
 *   {
 *     copy: 'Call us during normal business hours.',
 *     label: 'Phone',
 *     linkUrl: 'https://www.intel.com',
 *     linkCopy: 'View Phone Directory',
 *   },
 * ];
 *
 * // Set for version 1
 * config1 = {
 *   version: '1',
 * };
 *
 * @example
 * <!-- HTML component example 1 -->
 * <!-- Explicitly set version 1 display -->
 * <c-core-intc-contacts contacts={contacts1} config={config1}></c-core-intc-contacts>
 *
 * @example
 * // JavaScript component example 1
 * // This is example code for defining the contacts parameter in your JavaScript file. Note that you may need to track
 * // your contacts variable depending on how you are setting it.
 *
 * // Contacts in version 2 format
 * contacts2 = [
 *   {
 *     icon: 'help',
 *     label: 'Find Answers',
 *     links: [
 *       {
 *         url: 'https://www.intel.com',
 *         copy: 'Tiers, roles, and responsibilities',
 *       },
 *       {
 *         url: 'https://www.intel.com',
 *         copy: 'Specialities',
 *       },
 *     ],
 *   },
 *   {
 *     copy: 'You can submit a support request anytime.',
 *     icon: 'email',
 *     label: 'Request Support',
 *     links: [
 *       {
 *         url: 'https://www.intel.com',
 *         copy: 'Submit Request',
 *       },
 *     ],
 *   },
 *   {
 *     copy: 'Available Monday to Friday, 8:30 am to 4:30 pm PST.',
 *     icon: 'comments',
 *     label: 'Online Chat',
 *     links: [
 *       {
 *         url: 'https://www.intel.com',
 *         copy: 'Chat now',
 *         target: '_self',
 *       },
 *     ],
 *   },
 *   {
 *     copy: 'Phone from Monday to Friday, 8:30 am to 4:30 pm PST.',
 *     icon: 'call',
 *     label: 'Call Us',
 *     links: [
 *       {
 *         url: 'https://www.intel.com',
 *         copy: 'View phone directory',
 *       },
 *     ],
 *   },
 * ];
 *
 * // Set for version 2
 * config2 = {
 *   version: '2',
 * };
 *
 * @example
 * <!-- HTML component example 2 -->
 * <!-- Explicitly set version 2 display -->
 * <c-core-intc-contacts contacts={contacts2} config={config2}></c-core-intc-contacts>
 *
 * @augments LightningElement
 * @property {Contact[]} contacts  An array of {@link Contact}s to display. These contacts will
 * be used as the basis for the internal Contacts objects used for display.
 * @property {ContactConfig} [config]  Configuration settings for controlling the display of the
 * component. See {@link ContactConfig} for details.
 */
class CoreIntcContacts extends LightningElement {
  // ******* API variables - defined in class properties *******
  /**
   * Returns the internal version of the Contacts array. Key and link related properties
   * will be set automatically if they are not already set.
   *
   * @returns {Contact[]} The internal array of Contacts in the version format expected by
   * the component.
   * @private
   */
  @api
  get contacts() {
    return this._contacts;
  }

  /**
   * Stores the Contacts array passed by the user and then checks if the version is
   * already defined. If yes, then it sets the internal version of the Contacts array.
   * If no, the internal version of Contacts will be set in the version setter or in the
   * connectedCallback.
   *
   * @param {Contact[]} baseContacts  The Contacts passed as a parameter to the component.
   * @private
   */
  set contacts(baseContacts) {
    try {
      this.passedContacts = baseContacts;
      if (this.configSet) {
        this._contacts = this.getComponentContacts(this.passedContacts, this._config.version);
      }
    } catch (error) {
      this.handleError(error);
    }
  }



  /**
   * Returns the internal configuration object.
   *
   * @returns {string} The version of the component to display.
   * @private
   */
  @api
  get config() {
    return this._config;
  }

  /**
   * Sets the config and then checks if the contacts have already been
   * defined. If yes, then it sets the internal version of the Contacts array.
   * If no, the internal version of Contacts will be set in the contacts setter or in the
   * connectedCallback.
   *
   * @param {string} baseConfig  The version of the component to display.
   * @private
   */
  set config(baseConfig) {
    try {
      Object.assign(this._config, baseConfig);
      this.setComponentConfig(this._config);

      if (this.passedContacts) {
        this._contacts = this.getComponentContacts(this.passedContacts, this._config.version);
      }
    } catch (error) {
      this.handleError(error);
    }
  }




  // ******* Track variables ********
  /**
   * This is the internal config object used to drive the display of the component.
   *
   * @type {ContactConfig}
   * @private
   */
  @track
  _config = {
    displayNonSelfLinkIcon: true,
    displaySelfLinkIcon: false,
    mobilePadding: true,
    nonSelfLinkIcon: 'forward',
    nonSelfLinkIconType: 'utility',
    selfLinkIcon: 'forward',
    selfLinkIconType: 'utility',
    version: '1',
  };


  /**
   * This is the internal array of Contacts with all the properties the component expects.
   * It is generated through the [getComponentContacts]{@link CoreIntcContacts#getComponentContacts}
   * method.
   *
   * @type {Contact[]}
   * @private
   */
  @track
  _contacts;


  /**
   * Object used to track what version should be displayed.
   *
   * @type {object}
   * @private
   */
  @track
  display = {
    version1: false,
    version2: false,
  };



  // ******* Global variables ********
  /**
   * Indicates if the component has been rendered. Used in error handling since errors cannot be published
   * until after rendering.
   *
   * @type {boolean}
   * @private
   */
  componentRendered = false;

  /**
   * Indicates if the internal version of the config object has been set.
   *
   * @type {boolean}
   * @private
   */
   configSet = false;

  /**
   * Indicates if the internal version of the contacts array has already been set.
   *
   * @type {boolean}
   * @private
   */
  contactsSet = false;

  /**
   * The array of contacts that was passed to the component.
   *
   * @type {Contact[]}
   * @private
   */
  passedContacts;

  /**
   * CSS class names for the container container element.
   *
   * @type {string}
   * @private
   */
  rowCss = 'slds-grid slds-grid_align-spread slds-wrap contact-row-container';

  /**
   * An array of errors that were thrown. This is only populated with errors that are thrown
   * before rendering.
   *
   * @type {object[]}
   * @private
   */
  unhandledErrors = [];




  // ******* Functions ********
  /**
   * Used to set the contacts objects when the version was not passed into the component. Need to do this
   * because the setter functions will fire before connectedCallback, but they will never set the
   * contacts because the version was not set. The version is defaulted to '1' for backwards
   * compatibility support.
   *
   * @private
   */
  connectedCallback() {
    try {
      if (!this.configSet) {
        this.setComponentConfig(this._config);
      }

      if (!this.contactsSet && this.passedContacts) {
        this._contacts = this.getComponentContacts(this.passedContacts, this._config.version);
      }
    } catch (error) {
      this.handleError(error);
    }
  }



  /**
   * Determines the method to call to get the correct Contacts data object version and then
   * calls it.
   *
   * @param {Contact[]} baseContacts  The Contacts passed as a parameter to the component.
   * @param {string} baseVersion  The version of the Contacts object that should be returned.
   * @returns {Contact[]} An array of Contacts with all the properties expected by the component
   * for the specified version.
   * @private
   */
  getComponentContacts(baseContacts, baseVersion) {
    let newContacts = [];

    if (baseVersion === '1') {
      newContacts = this.getComponentContactsV1(baseContacts);
    } else if (baseVersion === '2') {
      newContacts = this.getComponentContactsV2(baseContacts);
    }

    this.contactsSet = true;
    return newContacts;
  }



  /**
   * Returns the internal array of Contacts objects in version 1 format. It adds key and linkTarget
   * values to the contacts if they are not already set.
   *
   * @param {Contact[]} baseContacts  The Contacts passed as a parameter to the component.
   * @returns {Contact[]} An array of Contacts in version 1 format with all the properties
   * expected by the component.
   * @private
   */
  getComponentContactsV1(baseContacts) {
    // Loop through each Contact in the parameter array to check for a key and linkTarget.
    return baseContacts.map((contact, index) => {
      // Use the existing linkTarget and if it doesn't exist, set it to open in a new tab
      const linkTarget = contact.linkTarget || '_blank';

      // Get the key value to use
      const keyValue = this.getKeyValue(contact, 'contact', index);

      // Check if a default image is being used
      let { imgUrl } = contact;
      if (imgUrl === 'request' || imgUrl === 'phone' || imgUrl === 'chat') {
        // Yes so update the url
        imgUrl = `${CoreINTC}/intcContacts/images/${imgUrl}.png`;
      }

      // Need to recreate the object in version 1 format
      return {
        copy: contact.copy,
        imgUrl,
        key: keyValue,
        label: contact.label,
        linkUrl: contact.linkUrl,
        linkCopy: contact.linkCopy,
        linkTarget,
      };
    });
  }



  /**
   * Returns the internal array of Contacts objects in version 2 format. It adds key and linkTarget
   * values to the contacts if they are not already set.
   *
   * @param {Contact[]} baseContacts  The Contacts passed as a parameter to the component.
   * @returns {Contact[]} An array of Contacts in version 2 format with all the properties
   * expected by the component.
   * @private
   */
  getComponentContactsV2(baseContacts) {
    // Loop through each Contact in the parameter array
    return baseContacts.map((contact, index) => {
      // Get the key value to use
      const keyValue = this.getKeyValue(contact, 'contact', index);

      // Set defaults
      const iconType = contact.iconType || 'utility';
      let icon = `${iconType}:${contact.icon}`;
      let iconIsLightning = true;

      // Custom type means we will not use the Salesforce lightning-icon
      if (iconType === 'custom') {
        iconIsLightning = false;
        // Add padding CSS class
        icon = `slds-m-right_x-small ${contact.icon}`;
      }

      // Get the current links array
      let { links } = contact;

      // Check if links were included
      if (contact.links && contact.links.length) {
        // Yes so get the formatted link objects
        links = this.getLinks(contact, index);
      }

      // Need to recreate the object in version 2 format
      return {
        copy: contact.copy,
        icon,
        iconIsLightning,
        key: keyValue,
        label: contact.label,
        links,
      };
    });
  }



  /**
   * Creates an array of new ContactLink objects with additional properties expected by the component.
   * Only used in the version 2 display.
   *
   * @param {Contact} contact  The Contact containing the links used to build the new array.
   * @param {number} index  The index of the Contact in the contacts array.
   * @returns {ContactLink[]} An array of ContactLinks with all the properties expected by the component.
   * @private
   */
  getLinks(contact, index) {
    // Return the new array by looping through each link
    return contact.links.map((link, linkIndex) => {
      // Get the key value to use
      const linkKeyValue = this.getKeyValue(link, `link_${index}`, linkIndex);

      // Set defaults
      const linkTarget = link.target || '_blank';
      let linkTargetIcon = '';
      let targetIconIsLightning = true;

      // Check if the link is opening in the current tab
      if (linkTarget === '' || linkTarget === '_self') {
        // Yes so check if a target icon should be displayed
        if (this._config.displaySelfLinkIcon) {
          // Yes so set it and determine if a lightning icon is being used
          linkTargetIcon = `${this._config.selfLinkIconType}:${this._config.selfLinkIcon}`;
          if (this._config.selfLinkIconType === 'custom') {
            linkTargetIcon = this._config.selfLinkIcon;
            targetIconIsLightning = false;
          }
        }
      } else if (this._config.displayNonSelfLinkIcon) {
        // Not opening in the current tab and should be displayed
        // Set the target icon and determine if a lightning icon is being used
        linkTargetIcon = `${this._config.nonSelfLinkIconType}:${this._config.nonSelfLinkIcon}`;
        if (this._config.nonSelfLinkIconType === 'custom') {
          linkTargetIcon = this._config.nonSelfLinkIcon;
          targetIconIsLightning = false;
        }
      }

      // Return an expected link object
      return {
        copy: link.copy,
        key: linkKeyValue,
        target: linkTarget,
        targetIcon: linkTargetIcon,
        targetIconIsLightning,
        url: link.url,
      };
    });
  }


  /**
   * Checks if an object has a key property. If it does, then it returns its value,
   * otherwise it returns a key value based on the prefix and index.
   *
   * @param {object} dataObject  The object to check for a key property.
   * @param {string} prefix  The prefix used to generate a key value.
   * @param {number} index  The index used to generate a key value.
   * @returns {string} A string to use for a key value.
   * @private
   */
  getKeyValue(dataObject, prefix, index) {
    // Default a key value
    let keyValue = `${prefix}_${index}`;

    // Check if the data object already has a key
    if (dataObject.key !== undefined && dataObject.key !== null) {
      // Yes so use it instead
      keyValue = dataObject.key;
    }
    return keyValue;
  }



  /**
   * Handles errors thrown while processing.
   *
   * @param {object} error  The error that was thrown.
   * @private
   */
  handleError(error) {
    // Can't publish until after rendering
    if (!this.componentRendered) {
      this.unhandledErrors.push(error);
    } else {
      // Get the error service to publish the error to the message channel
      const errorComponent = this.template.querySelector('c-core-intc-error-service');
      if (errorComponent) {
        errorComponent.publishCoreError(error);
      }
    }
  }



  /**
   * This is needed since the @wire message context used to publish to the message channel is only available
   * after the component has been attached to the DOM.
   *
   * @private
   */
  renderedCallback() {
    this.componentRendered = true;

    // Check for any errors thrown before DOM attachment
    if (this.unhandledErrors.length) {
      // Yes so handle them
      this.unhandledErrors.forEach((error) => {
        this.handleError(error);
      });
      this.unhandledErrors.length = 0;
    }
  }



  /**
   * Sets properties driven by the config object.
   *
   * @param {ContactConfig} config  The config object used to drive the display of the component.
   * @private
   */
  setComponentConfig(config) {
    if (config.version === '1') {
      this.display.version1 = true;
      this.display.version2 = false;
    } else if (config.version === '2') {
      this.display.version1 = false;
      this.display.version2 = true;
    }

    if (config.mobilePadding) {
      this.rowCss += ' contact-row-container-mobile';
    }

    this.configSet = true;
  }
}
export default CoreIntcContacts;



// ********* Type Definitions ************
/**
 * Represents a contact used by the {@link CoreIntcContacts} component. The {@link CoreIntcContacts} component supports
 * different display versions, so not all of the properties listed are applicable to every version.
 * Each property will specifiy at the start of its descroption which versions use it.
 *
 * @typedef Contact
 * @property {string} [copy]  [All versions] The description of the contact (accepts HTML).
 * @property {string} [icon]  [Version 2] The name of the icon to display. This can be one of the icons from the
 * [Lightning Design System](https://www.lightningdesignsystem.com/icons/), or a custom CSS icon class. If you use a
 * custom CSS icon class, make sure to set the iconType property to "custom".
 * @property {string} [iconType=utility]  [Version 2] The type of the icon displayed. The iconType can either be
 * one of the Lightning Design System [Icon Types](https://www.lightningdesignsystem.com/icons/), or "custom". If it is
 * "custom", the icon property will be set as a CSS class on a SPAN element.
 * @property {string} [imgUrl]  [Version 1] The URL of the image to display for the contact. Set this equal to "phone",
 * "chat", or "request" to use the default images.
 * @property {string} [key]  [All versions] The unique identifier for this contact. It will be generated if not included.
 * @property {string} [label]  [All versions] The header for the contact (accepts HTML). [All versions]
 * @property {string} [linkCopy]  [Version 1] The text to display as the link.
 * @property {ContactLink[]} [links]  [Version 2] An array of {@link ContactLink}s to be displayed.
 * @property {string} [linkTarget=_blank]  [Version 1] The anchor target attribute for the link. See
 * [target](https://www.w3schools.com/tags/att_a_target.asp) for possible values.
 * @property {string} [linkUrl]  [Version 1] The URL where the link points.
 */


/**
 * Represents the configuration settings for the {@link CoreIntcContacts} component. Some configuration settings
 * are only used when the version is set to "2".  Each property will specifiy at the start of its descroption
 * which versions use it.
 *
 * @typedef ContactConfig
 * @property {boolean} [displayNonSelfLinkIcon=true]  [Version 2] Indicates if an icon should be displayed to the right of
 * links that are targetted to open in a different tab.
 * @property {boolean} [displaySelfLinkIcon=false]  [Version 2] Indicates if an icon should be displayed to the right of
 * links that are targetted to open in the current tab.
 * @property {boolean} [mobilePadding=true]  [All versions] Indicates if 1rem of padding should be added to the left
 * and right sides of the component when the resolution is below 768 pixels.
 * @property {string} [nonSelfLinkIcon=forward]  [Version 2] The name of the icon to display beside links targetted to
 * open in a different tab. Only applicable when displayNonSelfLinkIcon is set to true.
 * @property {string} [nonSelfLinkIconType=utility]  [Version 2] The type of the target icon displayed. This can either be
 * one of the Lightning Design System [Icon Types](https://www.lightningdesignsystem.com/icons/), or "custom". If it is
 * "custom", the nonSelfLinkIcon property will be set as a CSS class on a SPAN element. Only applicable when displayNonSelfLinkIcon
 * is set to true.
 * @property {string} [selfLinkIcon=forward]  [Version 2] The name of the icon to display beside links targetted to
 * open in the current tab. Only applicable when displaySelfLinkIcon is set to true.
 * @property {string} [selfLinkIconType=utility]  [Version 2] The type of the target icon displayed. This can either be
 * one of the Lightning Design System [Icon Types](https://www.lightningdesignsystem.com/icons/), or "custom". If it is
 * "custom", the selfLinkIcon property will be set as a CSS class on a SPAN element. Only applicable when displaySelfLinkIcon
 * is set to true.
 * @property {string} [version='1']  [All versions] The version of the component to display. Each version
 * is displayed differently, and expects a few different properties in the {@link Contact}s objects.
 */


/**
 * Represents a link in a {@link Contact}'s links array. Used in the {@link CoreIntcContacts} component
 * when the version is set to "2".
 *
 * @typedef ContactLink
 * @property {string} copy  The text to display as the link.
 * @property {string} [key]  The unique identifier for this link. It will be generated if not included.
 * @property {string} url  The URL where the link points.
 * @property {string} [target=_blank]  The anchor target attribute for the link. See
 * [target](https://www.w3schools.com/tags/att_a_target.asp) for possible values.
 */