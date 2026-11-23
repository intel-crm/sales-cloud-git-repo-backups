// import lang from '@salesforce/i18n/lang';
// import locale from '@salesforce/i18n/locale';
// import { addAnalyticsProperty, makeAnalyticsCall } from 'c/coreIntcAnalytics';

// /**
// * Adds a canonical link to the page for SEO.
// */
// function addCanonicalLink() {
//   var linknode = !!document.querySelector("link[rel='canonical']") ? document.querySelector("link[rel='canonical']") : document.createElement('link');
//   linknode.href = `https://${window.location.host}${window.location.pathname}?language=${locale}`;
//   linknode.rel = 'canonical';
//   document.head.appendChild(linknode);
// }



// /**
// * Parses the URL to determine if it contains an Offering ID.
// * @param {Object} sourceComponent  The optional aura component.
// * @return {string} The Offering ID if it is available, otherwise
// * an empty string.
// */
// function getOfferingId(sourceComponent) {
//   let offeringId = '';
  
//   // Attempt to get the Offering ID from the component itself
//   if (sourceComponent) {
//       offeringId = sourceComponent.get("v.offeringId") || '';
//   }
  
//   // Only parse the URL if the offeringId attribute is empty
//   if (!offeringId) {
//       // Get the Offering ID from the URL
//       const location = window.location.href;                
//       let isOfferingPage = location.match(/\/offering\/[a-zA-Z0-9]{18}/);
//       if (isOfferingPage != null) {
//           isOfferingPage += ''; 
//           offeringId = isOfferingPage.slice(10);
//       }
//   }
  
//   return offeringId;
// }



// /**
// * Parses the URL to determine if it contains an Partner MDA ID.
// * @param {Object} sourceComponent  The optional aura component.
// * @return {string} The Partner MDA ID if it is available, otherwise
// * an empty string.
// */
// function getPartnerId(sourceComponent) {
//   let partnerId = '';
  
//   // Attempt to get the Partner ID from the component itself
//   if (sourceComponent) {
//       partnerId = sourceComponent.get("v.partnerMDAId") || '';
//   }
  
//   // Only parse the URL if the partnerId attribute is empty
//   if (!partnerId) {
//     // Get the Partner ID from the URL
//     const location = window.location.href;                
//     let isPartnerPage = location.match(/\/partner\/[a-zA-Z0-9]{18}/);
//     if (isPartnerPage != null) {
//         isPartnerPage += ''; 
//         partnerId = isPartnerPage.slice(9);
//     }
//   }
  
//   return partnerId;
// }



// /**
// * Makes a window.postMessage call with the analytics data that will be caught by code in the community 
// * HEAD element and logged in Adobe Analytics.
// * @param {Object} event  The event associated with the call.
// */
// function makeMarketplaceAnalyticsCall(analyticsData, sourceComponent) {
//   if (!analyticsData) {
//     analyticsData = {};
//   }

//   // Get the Offering and Partner IDs
//   const offeringId = getOfferingId(sourceComponent);
//   const partnerId = getPartnerId(sourceComponent);

//   addAnalyticsProperty('pageview', 'analyticsType', analyticsData);
//   addAnalyticsProperty(offeringId, 'offeringId', analyticsData);
//   addAnalyticsProperty(partnerId, 'partnerMDAId', analyticsData);

//   makeAnalyticsCall(analyticsData);
// }


// export { addCanonicalLink, makeMarketplaceAnalyticsCall }
export { }