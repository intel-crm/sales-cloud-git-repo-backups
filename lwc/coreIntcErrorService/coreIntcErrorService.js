import { api, LightningElement, wire } from 'lwc';

import { publish, MessageContext } from 'lightning/messageService';
import coreIntcErrorMessages from '@salesforce/messageChannel/coreIntcErrorMessages__c';

/**
 * This service is used to manage errors thrown in the coreIntc components. It exposes multiple methods, the primary
 * method being publishCoreError which publishes an error to the coreIntcErrorMessages channel. This component should
 * only be used by coreIntc components.
 *
 * This component needs to be a standard Lightning Element since the messageContext is only set after the component is
 * added to the DOM.
 *
 * @example
 * // Get the error service to publish the error to the message channel
 * const errorComponent = this.template.querySelector('c-core-intc-error-service');
 * if (errorComponent) {
 *   errorComponent.publishCoreError(myErrorObject);
 * }
 *
 * @example
 * <!-- HTML component examples -->
 * <c-core-intc-error-service></c-core-intc-error-service>
 *
 *
 * @augments LightningElement
 * @property {Function} [convertError]  Method used to convert an error object to a plain object and returns the.
 * plain object. This is done since error objects get serialized into an empty object.
 * @property {Function} [getErrorMessage]  Returns the message associated with a given error.
 * @property {Function} [publishCoreError]  Creates the error data object and publishes it to the coreIntcErrorMessages channel.
 * @private
 */
class CoreIntcErrorService extends LightningElement {
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
   * @private
   */
  @api
  convertError(error) {
    const newError = {};
    Object.getOwnPropertyNames(error).forEach((key) => {
      newError[key] = error[key];
    });
    return newError;
  }



  /**
   * Returns the message associated with a given error.
   *
   * @param {object} passedErrors The error that was trapped.
   * @returns {string} The error message.
   * @private
   */
  @api
  getErrorMessage(passedErrors) {
    let errors = passedErrors;
    if (!Array.isArray(errors)) {
      errors = [errors];
    }

    return errors
      // Remove null/undefined items
      .filter((error) => !!error)
      // Extract an error message
      .map((error) => {
        // UI API read errors
        if (Array.isArray(error.body)) {
          return error.body.map((e) => e.message);
        }
        // UI API DML, Apex and network errors
        if (error.body && typeof error.body.message === 'string') {
          return error.body.message;
        }
        // JS errors
        if (typeof error.message === 'string') {
          return error.message;
        }
        // Unknown error shape so try HTTP status text
        return error.statusText;
      })
      // Remove empty strings
      .filter((message) => !!message)
      // Flatten
      .join(', ');
  }



  /**
   * Creates the error data object and publishes it to the coreIntcErrorMessages channel.
   *
   * @param {object} error The error that was trapped.
   * @private
   */
  @api
  publishCoreError(error) {
    const errorData = {
      error: this.convertError(error),
      type: 'core',
    };

    // Publish to the error message channel which will be picked up by the coreIntcErrorHandler
    publish(this.messageContext, coreIntcErrorMessages, errorData);
  }
}
export default CoreIntcErrorService;