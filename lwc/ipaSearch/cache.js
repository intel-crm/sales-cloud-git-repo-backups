// import { handleError } from 'c/ipaErrorServiceMarketplace';

// /**
//  * Session Storage Key for saving searches
//  *
//  * @type {string}
//  * @private
//  */
// const SESSION_STORAGE_KEY = 'ipaSearch-history';

// /**
//  * Gets saved (cached) search for category if exists
//  *
//  * @param {string} categoryId category id for lookup
//  * @returns {object} returns search params (if they are stored)
//  */
// export function getSearchHistory(categoryId) {
//   let storedSearches = {};
//   try {
//     const storedSearchesJSON = sessionStorage.getItem(SESSION_STORAGE_KEY);
//     storedSearches = storedSearchesJSON ? JSON.parse(storedSearchesJSON) : storedSearches;
//   } catch (err) {
//     handleError('Search Cache could not use session storage. It might be disabled.', 'ipaSearch', 'console');
//   }
//   return storedSearches[categoryId] || {};
// }

// /**
//  * Saves (caches) search params for CATEGORY in session storage
//  * - keeps track of unlimited categories, unless data is too large
//  * - it will always keep track of at least one category
//  *
//  * @param {object} searchParams search params for saving
//  */
// export function setSearchHistory(searchParams) {
//   let storedSearches = { _history: [] };
//   try {
//     const storedSearchesJSON = sessionStorage.getItem(SESSION_STORAGE_KEY);
//     storedSearches = storedSearchesJSON ? JSON.parse(storedSearchesJSON) : storedSearches;
//   } catch (err) {
//     handleError('Search Cache could not use session storage. It might be disabled.', 'ipaSearch', 'console');
//   }
//   const { category } = searchParams;
//   storedSearches[category] = { ...searchParams };
//   if (storedSearches._history.indexOf(category) > -1) {
//     storedSearches._history.splice(storedSearches._history.indexOf(category), 1);
//   }
//   storedSearches._history.unshift(category);

//   // removes oldest data if it is starting to get too long
//   const MAX_STORAGE_LENGTH = 50000;

//   let updatedJSON = JSON.stringify(storedSearches);
//   while (updatedJSON.length > MAX_STORAGE_LENGTH && storedSearches._history.length > 1) {
//     const removeOldestCategory = storedSearches._history.pop();
//     delete storedSearches[removeOldestCategory];
//     updatedJSON = JSON.stringify(storedSearches);
//   }

//   try {
//     sessionStorage.setItem(SESSION_STORAGE_KEY, updatedJSON);
//   } catch (err) {
//     handleError('Search Cache could not use session storage. It might be disabled.', 'ipaSearch', 'console');
//   }
// }