/** @module coreIntcSso */

import sitesLabel from '@salesforce/label/c.Core_Intc_SSO_Site_Identifier';
import ipaSettings from '@salesforce/label/c.PMP_SSO_IPA';
import leadsSettings from '@salesforce/label/c.PMP_SSO_Leads';
import marketplaceSettings from '@salesforce/label/c.PMP_SSO_Marketplace';
import cookieeSettings from '@salesforce/label/c.PMP_SSO_Cookies';


/* eslint-disable default-case */
/* eslint-disable no-param-reassign */


/**
 * Checks if SSO was attempted by looking up the cookie set by setSSOAttemptCookie().
 * Returns true or false based on existance of the cookie.
 *
 * @param {string} siteName  The name of the site (Marketplace, IPA, Leads).
 * @returns {boolean} Indicates if SSO has been attempted.
 */
function checkSSOAttempt(siteName) {
  let wasAttempted = false;

  const realSiteName = getSiteName(siteName);
  const cookieName = getCookieInfo('SSOAttemptedCookie', realSiteName);
  const attemptedCookie = getCookieValue(cookieName, true);

  if (attemptedCookie !== '' && attemptedCookie !== 'false') {
    wasAttempted = true;
  }

  return wasAttempted;
}



/**
 * Get attributes used for cookie processing which are stored in PMP_SSO_Cookies
 * Returns the attribute value based on the site name.
 *
 * @param {string} propertyName Name of the property.
 * @param {string} siteName The name of the site (Marketplace, IPA, Leads).
 * @returns {string} The attribute value as a string.
 */
function getCookieInfo(propertyName, siteName) {
  let jsonValue = '';
  const sites = parseJson(cookieeSettings);
  const realSiteName = getSiteName(siteName);

  if (sites && realSiteName) {
    const jsonSite = sites[realSiteName];
    if (jsonSite) {
      jsonValue = jsonSite[propertyName];
      if (jsonValue !== undefined) {
        return jsonValue;
      }
    }
  }

  return jsonValue;
}



/**
 * Returns the value for a given cookie.
 *
 * @param {string} cookieName  The name of the cookie.
 * @param {boolean} useComponent  Indicates if the component's document.cookie (cookies only
 * available to this component) should be used.
 * @returns {string} The value of the cookie, or '' if the cookie is not found.
 * @private
 */
function getCookieValue(cookieName, useComponent) {
  const name = `${cookieName}=`;
  // Call the window.focus method to get all cookies
  let allCookies = window.focus('cookie');
  // Check if should only use the cookies available to this component
  if (useComponent) {
    allCookies = document.cookie;
  }
  const decodedCookie = decodeURIComponent(allCookies);
  const cookies = decodedCookie.split(';');

  // Loop through all the cookies
  for (let i = 0; i < cookies.length; i += 1) {
    let cookie = cookies[i];
    // Remove any opening spaces
    while (cookie.charAt(0) === ' ') {
      cookie = cookie.substring(1);
    }

    // Check if the cookie matches the name
    if (cookie.indexOf(name) === 0) {
      // Yes so return its value
      return cookie.substring(name.length, cookie.length);
    }
  }
  return '';
}



/**
 * Returns the siteName is a value was passed in, otherwise it determines the siteName
 * and returns it.
 *
 * @param {string} siteName  The name of the site (Marketplace, IPA, Leads).
 * @returns {string} The name of the site (Marketplace, IPA, Leads).
 * @private
 */
function getSiteName(siteName) {
  if (siteName) {
    return siteName;
  }
  return whichSite();
}



/**
 * Gets a site's SSO settings label and then returns it as parsed JSON.
 * This is needed since later versions of Aura components won't allow
 * dynamic label names.
 *
 * @param {string} siteName  The name of the site whose SSO settings are to be retrieved.
 * @returns {object} The site's SSO label settings.
 */
function getSSOSettings(siteName) {
  let ssoSettings;
  const realSiteName = getSiteName(siteName);

  // Determine the appropriate label. From an LWC standpoint, this can be done
  // dynamically, but will do it explicitly incase there are some Aura oddities
  // when including since Aura can't do dynamic labels.
  switch (realSiteName) {
    case 'IPA':
      ssoSettings = ipaSettings;
      break;
    case 'Leads':
      ssoSettings = leadsSettings;
      break;
    case 'Marketplace':
      ssoSettings = marketplaceSettings;
      break;
    default:
      ssoSettings = '';
  }

  return parseJson(ssoSettings);
}



/**
 * Attempts to parse a string of JSON and return the resulting object.
 *
 * @param {string} jsonValue  The string of JSON to attempt to parse.
 * @returns {object} The parsed JSON object.
 */
function parseJson(jsonValue) {
  let json;
  if (jsonValue) {
    try {
      json = JSON.parse(jsonValue);
    } catch (ex) {
      console.error('Parse Error in coreIntcSso parseJson: ', ex);
    }
  }

  return json;
}



/**
 * Set a cookie to indicate SSO was already attempted and failed.
 * This is implied when a user has visited the Accees Denied page.
 *
 * @param {string} siteName  The name of the site whose cookie is to be set.
 */
function setSSOAttemptCookie(siteName) {
  const realSiteName = getSiteName(siteName);
  const cookieName = getCookieInfo('SSOAttemptedCookie', realSiteName);
  document.cookie = `${cookieName}=true;path=/`;
}



/**
 * Returns the site name based on the URL stored in Core_Intc_SSO_Site_Identifier.
 *
 * @returns {string} The site name as a string.
 */
function whichSite() {
  const { href } = window.location;
  // Get the available sites
  const sites = JSON.parse(sitesLabel);

  let site = '';
  let i = 0;

  // Loop through the sites for a match
  for (i; i < sites.length; i += 1) {
    if (href.indexOf(sites[i].URL) >= 0) {
      site = sites[i].Site;
      break;
    }
  }

  return site;
}


export {
  checkSSOAttempt, getCookieInfo, getCookieValue, getSSOSettings, setSSOAttemptCookie, whichSite,
};