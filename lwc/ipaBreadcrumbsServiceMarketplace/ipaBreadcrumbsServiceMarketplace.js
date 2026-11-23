/**
  * Returns a mock version of Marketplace's BreadcrumbNavigation object.
  * @returns {BreadcrumbNavigation} A mock version of Marketplace's BreadcrumbNavigation object.
  * @private
  */

import getBreadcrumbs from '@salesforce/apex/PMP_BreadcrumbController.getBreadcrumb';
import userLang from '@salesforce/i18n/lang';
 
 /**
   * Returns Marketplace's BreadcrumbNavigation object within a promise.
   * @returns {Promise} A promise that will resolve with Marketplace's BreadcrumbNavigation object.
   * @private
   */ 

export const getMarketplaceBreadcrumbs = async() => {
  
  let response = {};
  let url = window.location.href;
  console.log('::url1-->' + url);
  url = (url.indexOf("?") !== -1) ? url.split("?")[0] : url;
  console.log('::url::' + url);

  return await getBreadcrumbs({langCode: userLang, url: url}).then((result) => {
    response.breadcrumb = result;
    console.log(':::response:::', response);
    return Promise.resolve(response);
    //return null;
  })
}