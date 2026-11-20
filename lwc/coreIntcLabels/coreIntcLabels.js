/** @module coreIntcLabels */
import UserLocale from '@salesforce/i18n/locale';

/**
 * Separator (between the locale and label value) used when putting a label into sessionStorage.
 *
 * @type {string}
 * @private
 */
const LabelSeparator = ':-:';


/**
 * Message text indicating a label was not found.
 *
 * @type {string}
 * @private
 */
const CoreLabelNotFound = 'CoreIntcLabel Value Not Found';



/**
 * Adds label values to sessionStorage.
 *
 * @param {object[]} labels  An array of label objects with property name:value pairs.
 * @param {string} validationFunction  A function to execute to determine if the label has a valid value.
 * @private
 */
function addLabelsToStorage(labels, validationFunction) {
  const allLabels = Object.keys(labels);
  let labelName;

  // Add each label to sessionStorage
  for (let count = 0; count < allLabels.length; count += 1) {
    labelName = allLabels[count];
    // Make sure value is valid before adding it
    if (validationFunction(labels[labelName])) {
      sessionStorage.setItem(`${UserLocale}${LabelSeparator}${labelName}`, labels[labelName]);
    }
  }
}



/**
 * Returns label values from either Salesforce, sessionStorage, or a backend data service. This function is needed due
 * to an intermittent bug in Salesforce where it does not always generate a label value.
 *
 * This function looks for label values in the following order:
 * 1. Value returned from Salesforce.
 * 2. Value in sessionStorage.
 * 3. Value from a supplied backend data service (which are added to sessionStorage after they are retrieved).
 *
 * These values are by default considered valid when they are not null, not undefined, and not an empty string ('').
 * Looking for values in this order means that the backend data service will only be called if the Salesforce bug
 * is encountered. The vast majority of the time, the backend data service will not be called.
 *
 * @example
 * import { LightningElement } from 'lwc';
 * // Import the label method
 * import { getAllLabels } from 'c/coreIntcLabels';
 *
 * // Import labels from Salesforce
 * import pssAsessmentCompleted from '@salesforce/label/c.PSS_Assessment_Completed';
 * import pssSolutionSubmission from '@salesforce/label/c.PSS_SolutionSubmission';
 * import pssIntelReviewSubmit from '@salesforce/label/c.PSS_IntelReviewSubmit';
 *
 * // Import the backend data service that will be called if the Salesforce label values are invalid
 * import getDemoLabels from '@salesforce/apex/PSS_LabelDemoController.getDemoLabels';
 *
 * export default class PssLabelDemo extends LightningElement {
 *   // Create a label object with name:value pairs
 *   labels = {
 *     pssAsessmentCompleted,
 *     pssSolutionSubmission,
 *     pssIntelReviewSubmit,
 *   };
 *
 *   connectedCallback() {
 *     // Async function that will handle getting the labels and calling functions dependant on their value.
 *     this.init();
 *     // Call functions that are not dependant on label values
 *     this.notDependantOnLabels();
 *   }
 *
 *   async init() {
 *     try {
 *       // This call uses the default validation logic
 *       this.labels = await getAllLabels(this.labels, getDemoLabels);
 *     } catch (error) {
 *       // Put your error handling code here
 *     }
 *     this.dependantOnLabels();
 *   }
 *
 *   dependantOnLabels() {
 *     // Code dependant on label values
 *   }
 *
 *   notDependantOnLabels() {
 *     // Code not dependant on label values
 *   }
 * }
 *
 * @param {object[]} labels  An array of label objects with property name:value pairs.
 * @param {Function} dataService  A function to execute that calls a backend data service. The data
 *  service must return label values in a name:value pair map object whose property names match the
 *  names used in the labels object.
 * @param {Function} [validationFunction=validateLabelValue]  An optional validation function to
 *  use when determining if a label value is valid. If this is not included, the default validation
 *  function will be used which considers any value that is null, undefined, or an empty string ('') invalid.
 * @returns {object[]} An object matching the name:value pairs of the <code>labels</code> object but with updated values.
 * @async
 * @public
 */
async function getAllLabels(labels, dataService, validationFunction = validateLabelValue) {
  let labelName;
  let newLabels = {};
  let newLabelValue;

  const allLabels = Object.keys(labels);

  // Go through each label in the labels object
  for (let count = 0; count < allLabels.length; count += 1) {
    labelName = allLabels[count];

    // Attempt to get the label's value from Salesforce or sessionStorage
    newLabelValue = getLabelValue(labelName, labels[labelName], validationFunction);
    // Check if a valid value was not found
    if (newLabelValue === CoreLabelNotFound) {
      // No valid value found, so blank the return object and exit loop
      newLabels = {};
      break;
    } else {
      newLabels[labelName] = newLabelValue;
    }
  }

  // Check if the loop was exited due to a label that did not have a valid value
  if (newLabelValue === CoreLabelNotFound) {
    // Yes so need to call the backend dataservice to get the label values
    return dataService()
      .then((result) => {
        // Update sessionStorage with the returned label values
        addLabelsToStorage(result, validationFunction);

        // Loop through all the labels again
        for (let count = 0; count < allLabels.length; count += 1) {
          labelName = allLabels[count];
          newLabelValue = getLabelValue(labelName, labels[labelName], validationFunction);
          // This time if a value was not found then just blank it
          if (newLabelValue === CoreLabelNotFound) {
            newLabelValue = '';
          }
          // Add the value to the object
          newLabels[labelName] = newLabelValue;
        }
        return newLabels;
      });
  }
  return newLabels;
}



/**
 * Retrieves a label value from sessionStorage.
 *
 * @param {string} labelName  The name of the label to retrieve.
 * @returns {string} The label's value from sessionStorage.
 * @private
 */
function getLabelFromStorage(labelName) {
  const sessionLabelName = `${UserLocale}${LabelSeparator}${labelName}`;
  return sessionStorage.getItem(sessionLabelName);
}



/**
 * Attempts to get a label's value. It will check if Salesforce returned a valid value, and if so, return
 * it. If Salesforce did not return a valid value, it will attempt to get the value from sessionStorage.
 * If the value in sessionStorage is not valid, then a not found message is returned.
 *
 * @param {string} labelName  The name of the label.
 * @param {string} labelValue  The value of the label given by Salesforce.
 * @param {string} validationFunction  A function to execute to determine if the label has a valid value.
 * @returns {string} The label's value or a message indicating a valid value was not found.
 * @private
 */
function getLabelValue(labelName, labelValue, validationFunction) {
  // Check if the Salesforce value is valid
  if (validateLabelValue(labelValue)) {
    // Yes so return it
    return labelValue;
  }

  // Salesforce value is not valid, so check sessionStorage
  const sessionLabelValue = getLabelFromStorage(labelName);
  if (validationFunction(sessionLabelValue)) {
    // sessionStorage value is valid so return it
    return sessionLabelValue;
  }

  // If the code has gotten this far, then a valid value was not found.
  return CoreLabelNotFound;
}



/**
 * Replaces all instances of the suplied replacement strings with their equivalent replacement value. All
 * replacement strings should start with '<%%' and end with '%%>'. <br>Parses any instances of JSON
 * strings in the label as well. JSON strings should start with '<%j%' and end with '%j%>'.
 *
 * @example
 * // This example only uses a replacement string
 * // Need to import the replaceLabels method
 * import { replaceLabels } from 'c/coreIntcLabels';
 *
 * // In this example, searchMarketplace is "This is a <%%PMP_Replace%%> value."
 * import searchMarketplace from '@salesforce/label/c.PMP_Search_Marketplace';
 * // replaceValue's text is "replaced"
 * import replaceValue from '@salesforce/label/c.PMP_Replace';
 *
 * // Call the method to replace the label. Note that another label (PMP_Replace) is being used as
 * // the replaceValue, but neither the replace string nor the replace value need to be labels.
 * const updatedLabelValue = replaceLabels(searchMarketplace, { PMP_Replace: replaceValue });
 * // updatedLabelValue will be ["This is a replaced value."]
 *
 * @example
 * // This example uses a replacement string and a JSON string
 * // Need to import the replaceLabels method
 * import { replaceLabels } from 'c/coreIntcLabels';
 *
 * // In this example, searchMarketplace is "This is a link to the <%j%{"href":"<%%PMP_Replace%%>", "target":"_blank", "text":"Intel"}%j%> website."
 * // Keep in mind the properties inside the JSON string are up to you, they are simply returned by this method.
 * import searchMarketplace from '@salesforce/label/c.PMP_Search_Marketplace';
 * // replaceValue's text is "https://www.intel.com"
 * import replaceValue from '@salesforce/label/c.PMP_Replace';
 *
 * // Call the method to replace the label. Note that another label (PMP_Replace) is being used as
 * // the replaceValue, but neither the replace string nor the replace value need to be labels.
 * const updatedLabelValue = replaceLabels(searchMarketplace, { PMP_Replace: replaceValue });
 * // updatedLabelValue will be ["This is a link to the ", { href:"https://www.intel.com", target:"_blank", text:"Intel"}, " website."]
 *
 * @param {string} label  The label to have all its replacement strings replaced and its JSON strings parsed.
 * The replacement strings should start with '<%%' and end with '%%>'. The JSON strings should start with
 * '<%j%' and end with '%j%>'.
 * @param {object} replacements  An object with key:value pairs for string replacement. The key is the replacement string
 * and the value is the text to replace it with. The '<%%' and '%%>' delimiters do not need to be included in the key names.
 * @returns {string[] | object[]} An array of either strings and/or JSON objects representing the fully replaced text of the label.
 * @public
 */
function replaceLabels(label, replacements) {
  // Ran into a weird parsing error with CodeScan if this is only defined as a function. Needed to define it as a
  // constant or CodeScan would throw a parsing error.
  // Element tag constants
  const elementTag = '%j%';
  const startTag = `<${elementTag}{`;
  const endTag = `}${elementTag}>`;
  const tagLength = startTag.length;

  // This is what will be returned
  let results = [];

  // Replace any labels
  let replacedValue = label;
  if (replacements) {
    replacedValue = replaceLabelText(label, replacements);
  }

  // Check for element tags
  let startIndex = replacedValue.indexOf(startTag);
  let endIndex = replacedValue.indexOf(endTag);
  let tagValue;

  // Loop through the label while there is still an element tag inside it
  while (startIndex >= 0 && endIndex >= (startIndex + tagLength + 5)) {
    // Add any text before the element tag
    if (startIndex > 0) {
      results.push(replacedValue.substring(0, startIndex));
    }

    // Get the content inside the element tags
    tagValue = replacedValue.substring(startIndex + tagLength - 1, endIndex + 1);

    // Parse the content inside the element tags
    try {
      results.push(JSON.parse(tagValue));
    } catch (ex) {
      console.error('Error parsing JSON string.', ex);
    }

    // Remove the text through the end of the element tag since it has already be pushed into the array
    replacedValue = replacedValue.slice(endIndex + tagLength);

    // Check for more element tags inside the label - finding any will continue the loop
    startIndex = replacedValue.indexOf(startTag);
    endIndex = replacedValue.indexOf(endTag);
  }

  // Add any remaining text to the results
  if (Array.isArray(replacedValue)) {
    results = results.concat(replacedValue);
  } else if (replacedValue.length > 0) {
    results.push(replacedValue);
  }

  return results;
}



/**
 * Repalces all instances of suplied replacement strings with their equivalent replacement value. All
 * replacement strings should start with '<%%' and end with '%%>'.
 *
 *
 * @param {string} label  The label that will have all its replacement strings replaced. The replacement strings
 * should start with '<%%' and end with '%%>'.
 * @param {object} replacements  An object with key:value pairs to replace. The key is the replacement string
 * and the value is the text to replace it with. The '<%%' and '%%>' delimiters do not need to be included in key names.
 * @returns {string} The label with all replacement strings replaced.
 * @private
 */
function replaceLabelText(label, replacements) {
  let replacedValue = label;
  let regTest;

  // Get all values to replace
  const properties = Object.keys(replacements);

  // Loop through each property and replace it in the label
  properties.forEach((property) => {
    regTest = `<%%${property}%%>`;
    replacedValue = replacedValue.replaceAll(regTest, replacements[property]);
  });

  // Check if a replacement references another replacement
  if (replacedValue.search(/<%%.*%%>/g) > -1 && replacedValue !== label) {
    // Yes so recursively call this function
    replacedValue = replaceLabels(replacedValue, replacements);
  }

  return replacedValue;
}



/**
 * Tests if a label's value is valid. Assumes an empty string is not valid.
 *
 * @param {string} labelValue  The value of the label to test.
 * @returns {boolean} Indicates if the value is valid.
 * @private
 */
function validateLabelValue(labelValue) {
  if (labelValue === null || labelValue === undefined || labelValue === '') {
    return false;
  }
  return true;
}

export { getAllLabels, replaceLabels };