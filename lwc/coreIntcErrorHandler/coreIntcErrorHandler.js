import { api, LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
  APPLICATION_SCOPE,
  MessageContext,
  subscribe,
  unsubscribe,
} from 'lightning/messageService';
import coreIntcErrorMessages from '@salesforce/messageChannel/coreIntcErrorMessages__c';

// Labels
import coreIntcErrorConsoleMessageLabel from '@salesforce/label/c.Core_Intc_Error_Console_Message';
import coreIntcErrorCoreMessageLabel from '@salesforce/label/c.Core_Intc_Error_Core_Message';
import coreIntcErrorMessageLabel from '@salesforce/label/c.Core_Intc_Error_Message';
import coreIntcErrorTitleLabel from '@salesforce/label/c.Core_Intc_Error_Title';


/* eslint-disable-next-line */
/* eslint-disable jsdoc/check-examples */
/**
 * A reusable component for handling errors thrown in other components. It's primary purpose is to display error messages via the
 * Lightning Platform [Show Toast](https://developer.salesforce.com/docs/component-library/bundle/lightning-platform-show-toast-event/documentation)
 * functionality.<br>
 *
 * This component subscribes to messages published to the coreIntcErrorMessages
 * [message service](https://developer.salesforce.com/docs/component-library/bundle/lightning-message-service/documentation). It expects {@link CoreError}
 * objects to be published to the channel and will process them using the settings in the config {@link CoreErrorConfig} object.<br>
 *
 * A few notes about Salesforce's
 * [Show Toast](https://developer.salesforce.com/docs/component-library/bundle/lightning-platform-show-toast-event/documentation) functionality:
 * <ul>
 *  <li>Only three toasts can be displayed at once. Additional toasts will queue to display (as long as they are not subject to the second note below).</li>
 *  <li>Multiple toasts with the same content cannot be displayed at the same time. This means if the error message and error title
 *  are the same for multiple errors, then only one will be displayed at a time. They also do not queue, which means toasts will be ignored
 *  if they are the same as a toast currently being displayed. However, once the toast is closed, the same toast can be
 *  displayed again.</li>
 * </ul>
 *
 * @example
 * // This example shows publishing a message to the coreIntcErrorMessages channel
 *
 * // Message channel imports needed
 * import { publish, MessageContext } from 'lightning/messageService';
 * import coreIntcErrorMessages from '@salesforce/messageChannel/coreIntcErrorMessages__c';
 *
 * // To pass scope, you must get a message context.
 * wire(MessageContext) // Note wire needs to be `@wire` - can't write it in JSDoc due to escaping issues
 * messageContext;
 *
 * // Converts an error object to a plain object. This is done since error objects
 * // get serialized into an empty object.
 * convertError(error) {
 *   const newError = {};
 *   Object.getOwnPropertyNames(error).forEach((key) => {
 *     newError[key] = error[key];
 *   });
 *   return newError;
 * }
 *
 * // This function calls a backend APEX class
 * myMethod() {
 *   myServiceCall()
 *     .then((result) => {
 *       console.log('the service worked');
 *     })
 *     .catch((error) => {
 *       // Publish to the message channel so that it will be handled by the coreIntcErrorHandler. The third parameter is the CoreError object.
 *       // Only the CoreError message and error properties are set in this example, but you can set whatever CoreError properties you want.
 *       // For any properties you don't set, the config object's properties will be used as defaults.
 *       publish(this.messageContext, coreIntcErrorMessages, { error: this.convertError(error), message: `This is my error message.` });
 *     });
 * }
 *
 * @augments LightningElement
 * @property {CoreErrorConfig} config  A {@link CoreErrorConfig} object that defines how errors should be handled. This is available
 * to be set as a property on the theme.
 */
class CoreIntcErrorHandler extends LightningElement {
  // ******* API variables - defined in class properties *******
  @api config;


  // ******* Class variables ********
  /**
   * The {@link CoreErrorConfig} object used to control how the coreIntcErrorHandler processes errors. This
   * object is updated with any settings defined in the config API object.
   *
   * @type {CoreErrorConfig}
   * @private
   */
  coreConfig = {
    excludeErrorTypes: [],
    message: coreIntcErrorMessageLabel,
    messageData: [],
    mode: 'sticky',
    singleDisplay: true,
    singleDisplayConsole: true,
    singleDisplayConsoleMessage: coreIntcErrorConsoleMessageLabel,
    title: coreIntcErrorTitleLabel,
    variant: 'error',
  };


  /**
   * Indicates if a toast has been displayed for a previous error.
   *
   * @type {boolean}
   * @private
   */
  errorDisplayed = false;


  /**
   * Subscription to the error message channel.
   *
   * @type {object}
   * @private
   */
  errorSubscription;



  /**
   * Provides info about the components using the message channel.
   *
   * @type {object}
   * @private
   */
  @wire(MessageContext)
  messageContext;




  // ******* Methods ********
  /**
   * Sets the configuration and subscribes to the Core Error message channel.
   *
   * @private
   */
  connectedCallback() {
    try {
      if (this.config) {
        try {
          let parsedConfig = this.config;
          if (typeof this.config === 'string') {
            parsedConfig = JSON.parse(this.config);
          }
          this.coreConfig = {...this.coreConfig, ...parsedConfig};
        } catch (parseEx) {
          console.error('Unable to parse coreIntcErrorHandler config', parseEx, this.config);
        }
      }
      this.subscribeToMessageChannel();

      const fullLocation = `${window.location.protocol}//${window.location.hostname}${window.location.port ? `:${window.location.port}` : ''}`;
      window.postMessage({ type: 'intel.coreErrorLoaded' }, fullLocation); // NOSONAR
    } catch (ex) {
      console.error(coreIntcErrorCoreMessageLabel, ex);
    }
  }



  /**
   * Unsubscribes to the Core Error message channel.
   *
   * @private
   */
  disconnectedCallback() {
    try {
      this.unsubscribeToMessageChannel();
    } catch (ex) {
      console.error(coreIntcErrorCoreMessageLabel, ex);
    }
  }



  /**
   * Determines the appropriate value for a toast configuration property.
   *
   * @param {string} propertyName The name of the toast configuration property.
   * @param {object} defaultConfig The default configuration for toasts.
   * @param {object} data The data object published to the error message channel.
   * @returns {string} The value to use for the toast configuration property.
   * @private
   */
  getToastProperty(propertyName, defaultConfig, data) {
    if (data[propertyName] !== undefined) {
      return data[propertyName];
    }
    return defaultConfig[propertyName];
  }



  /**
   * Handles error messages received from the coreIntcErrorMessages channel.
   *
   * @param {CoreError} data incoming message
   * @private
   */
  handleMessage(data) {
    try {
      // Check if this error needs to be written to the console instead of being displayed in a toast
      if ((this.errorDisplayed && this.coreConfig.singleDisplay && this.coreConfig.singleDisplayConsole && data.type !== 'toast') || data.type === 'console') {
        // Use the passed in message if a console message has not been defined
        let consoleMessage = this.getToastProperty('message', this.coreConfig, data);
        if (this.coreConfig.singleDisplayConsoleMessage && data.type !== 'console') {
          consoleMessage = this.coreConfig.singleDisplayConsoleMessage;
        }
        console.error(consoleMessage, data.error, data.location);
        return;
      }

      // Default to not handling the error
      let displayToast = false;

      // Determine if this error should be displayed
      if (data.type === undefined || data.type === 'toast' || this.coreConfig.excludeErrorTypes.length === 0) {
        displayToast = true;
      } else {
        displayToast = !this.coreConfig.excludeErrorTypes.includes(data.type);
      }

      // Check if the error should be displayed
      if (displayToast) {
        this.errorDisplayed = true;

        // Yes so set the toast properties
        const toastConfig = {
          message: this.getToastProperty('message', this.coreConfig, data),
          messageData: this.getToastProperty('messageData', this.coreConfig, data),
          mode: this.getToastProperty('mode', this.coreConfig, data),
          title: this.getToastProperty('title', this.coreConfig, data),
          variant: this.getToastProperty('variant', this.coreConfig, data),
        };

        // Display the toast
        const evt = new ShowToastEvent(toastConfig);
        this.dispatchEvent(evt);
      }
    } catch (ex) {
      console.error(coreIntcErrorCoreMessageLabel, ex);
    }
  }



  /**
   * Subscribe to the error message channel and sets the handler.
   *
   * @private
   */
  subscribeToMessageChannel() {
    if (!this.errorSubscription) {
      this.errorSubscription = subscribe(
        this.messageContext,
        coreIntcErrorMessages,
        (message) => this.handleMessage(message),
        { scope: APPLICATION_SCOPE },
      );
    }
  }



  /**
   * Unsubscribes to error message channel.
   *
   * @private
   */
  unsubscribeToMessageChannel() {
    unsubscribe(this.errorSubscription);
    this.errorSubscription = null;
  }
}
export default CoreIntcErrorHandler;



// ********* Type Definitions ************
/**
 * An object representing the error to be handled. This is what is published to the CoreIntcErrorMessages message channel and what
 * is processed by the {@link CoreIntcErrorHandler}.
 *
 * @typedef CoreError
 * @property {object} [error]  The actual error object that was thrown.
 * @property {string} [location]  The location where the error was thrown. This could be a method, a component, a service, etc. It is
 * displayed in the console.error statement for any errors handled after the first displayed error if {@link CoreErrorConfig}.singleDisplay is set to true.
 * @property {string} [message=Core_Intc_Error_Core_Message Custom Label]  The Lightning Platform
 * [Show Toast](https://developer.salesforce.com/docs/component-library/bundle/lightning-platform-show-toast-event/documentation) message.
 * @property {string | object} [messageData=[]]  The Lightning Platform
 * [Show Toast](https://developer.salesforce.com/docs/component-library/bundle/lightning-platform-show-toast-event/documentation) messageData.
 * @property {string} [mode=sticky]  The Lightning Platform
 * [Show Toast](https://developer.salesforce.com/docs/component-library/bundle/lightning-platform-show-toast-event/documentation) mode.
 * @property {string} [title=Core_Intc_Error_Core_Title Custom Label]  The Lightning Platform
 * [Show Toast](https://developer.salesforce.com/docs/component-library/bundle/lightning-platform-show-toast-event/documentation) title.
 * @property {string} [type]  The type of error thrown. There are a few predefined values: 'core' is used for errors thrown in CoreIntc components, 'console'
 * means always write the error to the console, and 'toast' means always display the error in a toast. Other values are arbitrary and
 * can be defined by you. Type is also used in conjunction with the {@link CoreErrorConfig}.excludeErrorTypes setting to ignore certain types of errors.
 * @property {string} [variant=error]  The Lightning Platform
 * [Show Toast](https://developer.salesforce.com/docs/component-library/bundle/lightning-platform-show-toast-event/documentation) variant.
 */


/**
 * Configuration settings used by the {@link CoreIntcErrorHandler} for displaying error toasts/messages.
 *
 * @typedef CoreErrorConfig
 * @property {string[]} [excludeErrorTypes=[]]  An array of {@link CoreError} types to be ignored by the {@link CoreIntcErrorHandler}.
 * Since errors thrown by the CoreIntc components are published to the CoreIntcErrorMessages channel, include 'core' in this array if you want
 * to handle these errors in your own code (even if this means just republishing the error again with your own message and type).
 * @property {string} [message=Core_Intc_Error_Core_Message Custom Label]  The Lightning Platform
 * [Show Toast](https://developer.salesforce.com/docs/component-library/bundle/lightning-platform-show-toast-event/documentation) message.
 * @property {string | object} [messageData=[]]  The Lightning Platform
 * [Show Toast](https://developer.salesforce.com/docs/component-library/bundle/lightning-platform-show-toast-event/documentation) messageData.
 * @property {string} [mode=sticky]  The Lightning Platform
 * [Show Toast](https://developer.salesforce.com/docs/component-library/bundle/lightning-platform-show-toast-event/documentation) mode.
 * @property {boolean} [singleDisplay=true]  Indicates if only the first error received by the {@link CoreIntcErrorHandler} should be displayed
 * as a toast.
 * @property {boolean} [singleDisplayConsole=true]  If singleDisplay is set to true, this indicates if subsequent errors should be written to the console.
 * @property {string} [singleDisplayConsoleMessage=Core_Intc_Error_Console_Message Custom Label]  The default console message to use
 * when singleDisplay and singleDisplayConsole are both set to true. The {@link CoreError}.error and {@link CoreError}.location are also written to the console.
 * @property {string} [title=Core_Intc_Error_Core_Title Custom Label]  The Lightning Platform
 * [Show Toast](https://developer.salesforce.com/docs/component-library/bundle/lightning-platform-show-toast-event/documentation) title.
 * @property {string} [variant=error]  The Lightning Platform
 * [Show Toast](https://developer.salesforce.com/docs/component-library/bundle/lightning-platform-show-toast-event/documentation) variant.
 */