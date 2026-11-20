// import { search, searchResultCounts, SearchHelper } from 'c/ipaSearchService';
// import { makeIpaAnalyticsCall } from 'c/ipaAnalyticsService';

// // labels
// import relevance from '@salesforce/label/c.PMP_SortByRelevance';
// import featured from '@salesforce/label/c.PMP_SortByFeatured';
// import partnerTier from '@salesforce/label/c.PMP_SortByPartnerTier';
// import newlyAdded from '@salesforce/label/c.PMP_SortByNew';
// import alpha from '@salesforce/label/c.PMP_SortByAlpha';

// /**
//  * Default Sort Options
//  *
//  * @type {object[]}
//  */
// const defaultSortByOptions = [
//   { label: alpha, value: 'alphabetical' },
//   { label: relevance, value: 'relevance' },
//   { label: featured, value: 'featured' },
//   { label: partnerTier, value: 'partner' },
//   { label: newlyAdded, value: 'new' },
// ];

// /**
//  * search results - REQUEST #1
//  *
//  * @param {object} searchParams search params
//  * @returns {object} search response
//  */
// export async function search1(searchParams) {
//   let searchResponse = {
//     sortByOptions: [],
//     results: [],
//     resultsPerPage: 0,
//     totalResults: 0,
//     totalPages: 0,
//   };

//   try {
//     searchResponse = await search(searchParams);
//   } catch (err) {
//     return {};
//   }

//   // sets "Sort By" options for dropdown based on 1. default list, 2. override from search
//   if (!searchResponse.sortByOptions) {
//     searchResponse.sortByOptions = defaultSortByOptions;
//   }

//   if (!searchResponse.sortByOptions.find((opt) => opt.selected)) {
//     // if there is no selected option returned, try to use the searchParams value
//     const paramSortValue = searchParams.sortType;
//     searchResponse.sortByOptions = searchResponse.sortByOptions.map((opt) => ({
//       ...opt,
//       selected: paramSortValue === opt.value,
//     }));

//     // if there is still no selected option, select the first option
//     if (!searchResponse.sortByOptions.find((opt) => opt.selected)) {
//       searchResponse.sortByOptions[0].selected = true;
//     }
//   }

//   // Search Analytics
//   const searchAnalytics = { ...SearchHelper.analytics };
//   if (Object.values(searchAnalytics).length) {
//     makeIpaAnalyticsCall({
//       ...searchAnalytics,
//       details: `${searchResponse.totalResults}|${searchAnalytics.details}`,
//     });
//     SearchHelper.analytics = {}; // resets analytics object
//   }

//   return searchResponse;
// }


// /**
//  * Search Counts for Filter (REQUEST #2)
//  *
//  * @param {object} searchParams searchParams
//  * @returns {object} search result counts response
//  */
// export async function search2(searchParams) {
//   return searchResultCounts(searchParams);
// }