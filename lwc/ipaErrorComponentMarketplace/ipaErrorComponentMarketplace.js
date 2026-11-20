import { api, LightningElement, wire } from 'lwc';

import { publish, MessageContext } from 'lightning/messageService';
import coreIntcErrorMessages from '@salesforce/messageChannel/coreIntcErrorMessages__c';
import { convertError as convertErrorService, getErrorMessage as getErrorMessageService, writeToConsole } from 'c/ipaErrorServiceMarketplace';


/**
 * This component is used to manage errors thrown in Marketplace components. It exposes multiple methods, the primary
 * method being handleError which publishes an error to the coreIntcErrorMessages channel.
 *
 * This component needs to be a standard Lightning Element since the messageContext is only set after the component is
 * added to the DOM.
 *
 * @example
 * // Get the error component to publish the error to the message channel
 * const errorComponent = this.template.querySelector('c-ipa-error-component-marketplace');
 * if (errorComponent) {
 *   errorComponent.handleError(myErrorObject, 'my location');
 * }
 *
 * @example
 * <!-- HTML component examples -->
 * <c-ipa-error-component-marketplace></c-ipa-error-component-marketplace>
 *
 *
 * @augments LightningElement
 * @property {Function} [convertError]  Method used to convert an error object to a plain object and returns the.
 * plain object. This is done since error objects get serialized into an empty object.
 * @property {Function} [getErrorMessage]  Returns the message associated with a given error.
 * @property {Function} [handleError]  Writes the error to the console, then creates the error data
 * object and publishes it to the coreIntcErrorMessages channel.
 */
class IpaErrorComponentMarketplace extends LightningElement {
  /**
   * The message context object needed for passing scope to the publish method.
   *
   * @type {object}
   * @private
   */
  @wire(MessageContext)
  messageContext;



  /**
   * Converts an error object to a plain object. This is done since error objects
   * get serialized into an empty object.
   *
   * @param {object} error  The error object to be converted.
   * @returns {object} The plain object with the same properties as the error object.
   * @public
   */
  @api
  convertError(error) {
    return convertErrorService(error);
  }



  /**
   * Returns the message associated with a given error.
   *
   * @param {object} passedErrors The error that was trapped.
   * @returns {string} The error message.
   * @public
   */
  @api
  getErrorMessage(passedErrors) {
    return getErrorMessageService(passedErrors);
  }



  /**
   * Writes error info to the console. Also, if the type is not 'console', it creates the error
   * data object and publishes it to the coreIntcErrorMessages channel.
   *
   * @param {object} error The error that was trapped.
   * @param {string} location Location where the error was caught.
   * @param {string} [type] The type of error that was trapped.
   * @public
   */
  @api
  handleError(error, location, type) {
    writeToConsole(error, location);

    // Display errors that are not only for the console
    if (type !== 'console' && !window.focus('errorGet')) {
      const errorData = {
        error: this.convertError(error),
        type,
      };

      // Publish to the error message channel which will be picked up by the coreIntcErrorHandler
      publish(this.messageContext, coreIntcErrorMessages, errorData);

      // Update the error state
      window.focus('errorSet');
    }
  }
}
export default IpaErrorComponentMarketplace;