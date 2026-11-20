import locale from '@salesforce/i18n/locale';
import { addAnalyticsProperty, makeAnalyticsCall } from 'c/coreIntcAnalytics';

/**
 * Adds a canonical link to the page for SEO.
 */
function addCanonicalLink() {
  // eslint-disable-next-line @lwc/lwc/no-document-query
  let canonicalLink = document.querySelector('link[rel=\'canonical\']');
  if (!canonicalLink) {
    canonicalLink = document.createElement('link');
    canonicalLink.rel = 'canonical';
  }
  canonicalLink.href = `https://${window.location.host}${window.location.pathname}?language=${locale}`;
  document.head.appendChild(canonicalLink);
}

/**
 * Calls the analytics service to log the page view. Also creates a canonical link if specified.
 *
 * @param {string} pageData  The JSON data needed for analytics (page title and page type).
 * @param {string} communityName  The name of the community ('Marketplace', 'IPA').
 * @param {boolean} includeCanonical  Indicates if a canonical link should be created for the page.
 * @private
 */
function callAnalytics(pageData, communityName, includeCanonical) {
  // Get additional analytics data
  const analyticsData = getAnalyticsData(pageData, communityName);

  // Use the library component to send the analytics data. There is a
  // window message listener in the HEAD script that will call the salesforceHit method.
  makeIpaAnalyticsCall(analyticsData);

  if (includeCanonical) {
    // Add a canonical link
    addCanonicalLink();
  }
}

/**
 * Creates an object with properties that will be sent to the analytics logging service.
 *
 * @param {string} pageData  The JSON data needed for analytics (page title and page type).
 * @param {string} communityName  The name of the community ('Marketplace', 'IPA', 'Leads').
 * @returns {object} An object containing properties that will be sent to the analytics
 *
 * logging service.
 * @public
 */
function getAnalyticsData(pageData, communityName) {
  // Get data from component parameter
  let analyticsData = {};
  if (pageData) {
    try {
      analyticsData = JSON.parse(pageData);
    } catch (err) {
      console.error(
        'An error occurred attempting to parse the analytics pageData in ipaAnalyticsService. The error was: ',
        err,
      );
    }
  }

  if (communityName === 'Marketplace') {
    analyticsData.offeringId = getOfferingId();
    analyticsData.mdaId = getPartnerId();
  }
  return analyticsData;
}

/**
 * Parses the URL to determine if it contains an Offering ID.
 *
 * @param {object} sourceComponent  The optional aura component.
 * @returns {string} The Offering ID if it is available, otherwise
 * an empty string.
 */
function getOfferingId(sourceComponent) {
  let offeringId = '';

  // Attempt to get the Offering ID from the component itself
  if (sourceComponent) {
    offeringId = sourceComponent.get('v.offeringId') || '';
  }

  // Only parse the URL if the offeringId attribute is empty
  if (!offeringId) {
    // Get the Offering ID from the URL
    const location = window.location.href;
    let isOfferingPage = location.match(/\/offering\/[a-zA-Z0-9]{18}/);
    if (isOfferingPage != null) {
      isOfferingPage += '';
      offeringId = isOfferingPage.slice(10);
    }
  }

  return offeringId;
}

/**
 * Parses the URL to determine if it contains an Partner MDA ID.
 *
 * @param {object} sourceComponent  The optional aura component.
 * @returns {string} The Partner MDA ID if it is available, otherwise
 * an empty string.
 */
function getPartnerId(sourceComponent) {
  let partnerId = '';

  // Attempt to get the Partner ID from the component itself
  if (sourceComponent) {
    partnerId = sourceComponent.get('v.partnerMDAId') || '';
  }

  // Only parse the URL if the partnerId attribute is empty
  if (!partnerId) {
    // Get the Partner ID from the URL
    const location = window.location.href;
    let isPartnerPage = location.match(/\/partner\/[a-zA-Z0-9]{18}/);
    if (isPartnerPage != null) {
      isPartnerPage += '';
      partnerId = isPartnerPage.slice(9);
    }
  }

  return partnerId;
}

/**
 * Makes a window.postMessage call with the analytics data that will be caught by code in the community
 * HEAD element and logged in Adobe Analytics.
 *
 * @param {object} analyticsData analytics data
 * @param {object} sourceComponent source component
 */
function makeIpaAnalyticsCall(analyticsData = {}, sourceComponent) {
  // Get the Offering and Partner IDs
  const offeringId = getOfferingId(sourceComponent);
  const partnerId = getPartnerId(sourceComponent);

  addAnalyticsProperty('pageview', 'analyticsType', analyticsData);
  addAnalyticsProperty(offeringId, 'offeringId', analyticsData);
  addAnalyticsProperty(partnerId, 'partnerMDAId', analyticsData);

  makeAnalyticsCall(analyticsData);
}

export {
  addCanonicalLink,
  callAnalytics,
  getAnalyticsData,
  getOfferingId,
  getPartnerId,
  makeIpaAnalyticsCall,
};