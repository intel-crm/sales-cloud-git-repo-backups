/**
 * Methods related to making Adobe Analytics calls.
 *
 * @module coreIntcAnalytics
 */

/**
 * Adds a value to an object if the value is not already defined.
 *
 * @param {any} dataPropertyValue  The value to add to the parent object.
 * @param {string} parentPropertName  The property on the parent object whose value we are setting.
 * @param {object} parentObject  The parent object whose property we will add.
 * @public
 */
const addAnalyticsProperty = function addAnalyticsProperty(dataPropertyValue, parentPropertName, parentObject) {
  // Ran into a weird parsing error with CodeScan if this is only defined as a function. Needed to define it as a
  // constant or CodeScan would throw a parsing error.
  // Make sure the value to add is defined and the property does not already have a value
  if (dataPropertyValue !== null && dataPropertyValue !== undefined && parentObject[parentPropertName] === undefined) {
    /* eslint-disable no-param-reassign */
    parentObject[parentPropertName] = dataPropertyValue;
  }
};



/**
 * Returns a domain for posting to the window message listener in the HEAD script.
 *
 * @returns {string} The domain to use when making making window.post calls.
 * @public
 */
function getMessageDomain() {
  return `${window.location.protocol}//${window.location.hostname}${window.location.port ? `:${window.location.port}` : ''}`;
}



/**
 * Makes a window.postMessage call with the analytics data that will be caught by code in the community
 * HEAD element and logged in Adobe Analytics.
 *
 * @param {object} analyticsData  The data object to be passed to analytics.
 * @public
 */
function makeAnalyticsCall(analyticsData) {
  const messageDomain = getMessageDomain();

  // Get the URL properties if they are not set or are blank
  if (!analyticsData.querystring) {
    let url = window.location.href; // NOSONAR
    let querystring = '';

    // Update if it has a querystring
    if (url) {
      const splitUrl = url.split('?');
      if (splitUrl.length > 1) {
        [url] = splitUrl;
        querystring = `?${splitUrl[1]}`;
      }
    }

    addAnalyticsProperty(querystring, 'querystring', analyticsData);
    addAnalyticsProperty(url, 'url', analyticsData);
  }

  // Get the pageType if it is not set or is blank
  if (!analyticsData.pageType) {
    // Get the object representing the meta tags. The window.focus method is overwritten in the
    // HEAD script to return an object with meta tag values. This is done since the Locker service
    // stops this component from accessing the meta tags. If window.focus is called without the "true"
    // parameter, the standard window.focus method is called.
    const metaData = window.focus('meta');
    if (metaData) {
      // Update pageType based on meta tags
        addAnalyticsProperty(metaData.pageType || '', 'pageType', analyticsData);
      addAnalyticsProperty(metaData.title || '', 'title', analyticsData);
    }
  }

  addAnalyticsProperty('intel.salesForceHit', 'type', analyticsData);
  addAnalyticsProperty(analyticsData.labelHeader, 'element', analyticsData);


  // This will be picked up by the listener in the HEAD script
  window.postMessage(analyticsData, messageDomain); // NOSONAR
}


export { addAnalyticsProperty, getMessageDomain, makeAnalyticsCall };