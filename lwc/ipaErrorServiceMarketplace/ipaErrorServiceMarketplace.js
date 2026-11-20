/** @module ipaErrorServiceMarketplace */

/**
 * Converts an error object to a plain object. This is done since error objects
 * get serialized into an empty object.
 *
 * @param {object} error  The error object to be converted.
 * @returns {object} The plain object with the same properties as the error object.
 * @public
 */
const convertError = function convertError(error) {
  const newError = {};
  Object.getOwnPropertyNames(error).forEach((key) => {
    newError[key] = error[key];
  });
  return newError;
};



/**
 * Returns the message associated with a given error.
 *
 * @param {object} passedErrors The error that was trapped.
 * @returns {string} The error message.
 * @public
 */
function getErrorMessage(passedErrors) {
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
 * Writes error info to the console. Also, if the type is not 'console', it post the error
 * info to the window. This will be caught by the IntelCoreCommunity component, which will
 * publish it to the coreIntcErrorMessages channel.
 *
 * @param {object} error The error that was trapped.
 * @param {string} location Location where the error was caught.
 * @param {string} [type] The type of error that was trapped.
 * @public
 */
function handleError(error, location, type) {
  writeToConsole(error, location);

  // Display errors that are not only for the console
  if (type !== 'console') {
    let port = '';
    if (window.location.port) {
      port = `:${window.location.port}`;
    }
    const fullLocation = `${window.location.protocol}//${window.location.hostname}${port}`;
    window.postMessage({ type: 'intel.coreError', error: convertError(error), coreType: '' }, fullLocation); // NOSONAR
  }
}



/**
 * Writes error info to the console. Also, if the type is not 'console', it creates the error
 * data object and publishes it to the coreIntcErrorMessages channel.
 *
 * @param {object} error The error that was trapped.
 * @param {string} location Location where the error was caught.
 * @public
 */
function writeToConsole(error, location) {
  // Deal with Salesforce proxy objects
  let parsedError = JSON.parse(JSON.stringify(error));
  if (Object.keys(parsedError).length === 0) {
    parsedError = convertError(error);
  }
  // By default, writing all errors to the console
  console.error(`Error in ${location}, Message = ${getErrorMessage(error)}, Error = `, parsedError);
}

export {
  convertError, getErrorMessage, handleError, writeToConsole,
};