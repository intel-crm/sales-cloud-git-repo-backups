/*Developer By: Shiva [Weezer] [Core_MDF]
  Description: Utility Js for common funtionality.
*/
export class utilityModule {

  /*Developer By: Shiva [Weezer] [Core_MDF]
   Description: This method is used to sanitize the inputparam to fix checkmark issue (Client Potential XSS)
   Date: 12th March 2024
   Input Param: Any string that needs to be sanitized.
   */
  sanitize(inputValue) {

    let output = '';
    if (inputValue != null && inputValue != undefined) {
      //script element
      const scriptTagPattern = /<script\b[^>]*>(.*?)<\/script>/gi;

      //Check inputValue contains script elements if yes, returns true
      const scriptTags = inputValue.match(scriptTagPattern);

      if (scriptTags) {
        //replace script element with blank
        output = inputValue.replace(scriptTagPattern, '');
      } else {
        //remove html elements e.g. <p>, <strong>, <div>.. 
        const doc = new DOMParser().parseFromString(inputValue, 'text/html');
        output = doc.body.textContent || '';
      }
    }

    return output;

  }
}

//constants to be re-used in any of the JS files

//KPI Metrics constants
export const OLD_KPI_FIELDS_PB = ['Core_MDF_Lead_Quantity_nbr__c', 'Core_MDF_Deployment_Quantity_nbr__c', 'Core_MDF_Other_Quantity_nbr__c'];
export const OLD_KPI_FIELDS_AB = ['Core_MDF_Metrics_txt__c'];
export const OLD_KPI_FIELDS_ALL = ['Core_MDF_Lead_Quantity_nbr__c', 'Core_MDF_Deployment_Quantity_nbr__c', 'Core_MDF_Other_Quantity_nbr__c', 'Core_MDF_Metrics_txt__c'];


//TWC3117-10490 - [CCF/DCF/IPA] - Reimbursement Rate Values
// This method is used to check the existing RR% on a campaign budget and add it if its not present in the current values
export function addExistingReimbursementRate(existingCampRRVal, rrOptions) {
  let finalRROptions = [];
  if(rrOptions !== undefined && rrOptions !== null && rrOptions !== "" && rrOptions.length > 0) {
    finalRROptions = JSON.parse(JSON.stringify(rrOptions));
 
    if (existingCampRRVal) {
      if (!finalRROptions.some(option => option.value === existingCampRRVal)) {
        const numericValue = parseFloat(existingCampRRVal);
   
        let index = finalRROptions.findIndex(option => parseFloat(option.value) > numericValue);
        if (index === -1) {
          finalRROptions.push({ label: existingCampRRVal, value: existingCampRRVal });
        } else {
          finalRROptions.splice(index, 0, { label: existingCampRRVal, value: existingCampRRVal });
        }
      }
    }
  }
  return finalRROptions;
}