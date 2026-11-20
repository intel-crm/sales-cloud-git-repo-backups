/**
 * Search Helper
 *
 * Shared Singleton to share data across pages (spa) / components
 * (Needed for components that interact with search from other pages (ie. ipaQuickSearch))
 */
class SearchHelper {
  /**
   * Analytics Values
   *
   * These are set before a new search and cleared after search completes
   *
   * @type {object}
   */
  analytics = {}

  /**
   * Initial Search Values
   *
   * These can be set to provide initial search params once navigation to L2 Search Page occurs
   * (example: done in ipaQuickSearch)
   *
   * @type {object}
   */
  initialParams = {}

  /**
   * This is a map of URL params => Search params
   *
   * @type {object[]}
   */
  urlSearchParamMap = [
    ['q', 'keyword'],
    ['p', 'page'],
    ['s', 'sortType'],
    ['f', 'filters'],
  ]

  /**
   * Converts URL query string params (from window location) to search params format
   *
   * @returns {object} search params
   */
  getSearchParamsFromUrl() {
    const searchParams = {};
    const url = new URL(window.location);
    let urlSearchParams = url.searchParams.get('search');
    if (urlSearchParams) {
      urlSearchParams = JSON.parse(decodeURIComponent(urlSearchParams));
      this.urlSearchParamMap.forEach(([urlParam, searchParam]) => {
        if (urlSearchParams[urlParam]) {
          searchParams[searchParam] = urlSearchParams[urlParam];
        }
      });
    }
    return searchParams;
  }

  /**
   * Converts search params into shorter query string params for URL
   * - used to Copy / Share a search page
   *
   * @param {object} searchParams search params to convert
   * @returns {object} url params
   */
  getUrlFromSearchParams(searchParams) {
    const urlParams = {};
    const url = new URL(window.location);
    this.urlSearchParamMap.forEach(([urlParam, searchParam]) => {
      if (searchParams[searchParam]) {
        urlParams[urlParam] = searchParams[searchParam];
      }
    });
    url.searchParams.set('search', encodeURIComponent(JSON.stringify(urlParams)));
    return url.toString();
  }
}
export default new SearchHelper();