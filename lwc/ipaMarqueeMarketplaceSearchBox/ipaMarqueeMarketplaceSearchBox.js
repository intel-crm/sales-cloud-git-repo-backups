// import {
//   LightningElement, api, wire, track,
// } from 'lwc';

// import searchMarketplace from '@salesforce/label/c.PMP_Search_Marketplace';
// import marketplaceOffering from '@salesforce/label/c.PMP_Search_Offerings_Placeholder';
// import marketplacePartner from '@salesforce/label/c.PMP_Search_Partners_Placeholder';

// import getBaseUrlForLaunguageCode from '@salesforce/apex/IPA_MarqueeMarketplaceController.getBaseUrlForLaunguageCode';
// import getCallOutDetails from '@salesforce/apex/IPA_MarqueeMarketplaceController.getCallOutDetails';
// import USERLANG from '@salesforce/i18n/lang';

// import { handleError } from 'c/ipaErrorServiceMarketplace';

// /** A component for a search input which uses another component coreTntcSearch as a child component.
//  *
//  * This component is embedded in the Marquee of the community builder on 3 pages:
//  * Home Page, Offerings By Category, Partner By Directory.
//  *
//  * @example
//  * <!-- HTML component -->
//  * <c-ipa-marquee-marketplace-search-box page-type={pageType}></c-ipa-marquee-marketplace-search-box>
//  *
//  * @augments LightningElement
//  * @property {string} pageType to set if the Page is either Home/Offering/Partner which is received from ipaMarqueeMarketplace component.
//  */
// class IpaMarqueeMarketplaceSearchBox extends LightningElement {
//   /* below specified are Not in Use Variables */
//   @api showSearch;

//   @api alignment;

//   @api isHomePage;

//   @api isOfferingPage;

//   @api isPartnerPage;

//   @api typeaheadNoResults;
//   /** above specified are Not in Use Variables */

//   // ******* API variables - defined in class properties *******
//   @api pageType;

//   // ******* Track variables ********

//   /** This variable is used to set the result value of Search from Coveo based on pageType
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track typeaheadOptions = [];

//   /** array to save postCallout data from wired method.
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track itemsPostCallOut = [];

//   /** This variable is used to set the placeholder value of Searchbox besd on pageType
//    *
//    * @type {string}
//    * @private
//    */
//   placeholderValue;

//   /** This variable is used to set true if keyword is being searched else false.
//    * This is to set the spinner from Child component coreIntcSearch
//    *
//    * @type {boolean}
//    * @private
//    */
//   currentlySearching = false;

//   /** This variable is used to set the results to zero if the search result is not found.
//    *
//    * @type {string}
//    * @private
//    */
//   noResultsFound;

//   /** This variable is used to set true or false. It will be set to true once the wire data is loaded else it is set to false.
//    * Search Component is only available when enableSeach is true.
//    *
//    * @type {boolean}
//    * @private
//    */
//   enableSearch;

//   /** This variable is to save ObjectType based on the pageType.
//    *
//    * @type {string}
//    * @private
//    */
//   objectType;

//   /** homePage to save type of the page, this will be true if the searchbox is on homePage.
//    *
//    * @type {boolean}
//    * @private
//    */
//   homePage;

//   /** variable to save type of the page, this will be true if the searchbox is on Offering By Category Page.
//    *
//    * @type {boolean}
//    * @private
//    */
//   offeringPage;

//   /** variable to save type of the page, this will be true if the searchbox is on Partner Directory Page.
//    *
//    * @type {boolean}
//    * @private
//    */
//   partnerPage;

//   /** variable to save keyword given in the searchbox.
//    *
//    * @type {string}
//    * @private
//    */
//   searchQuery = '';

//   /** variable to handle url while redirection.
//    *
//    * @type {string}
//    * @private
//    */
//   inputUrl = '';

//   /** variable to save language code of the browser.
//    *
//    * @type {string}
//    * @private
//    */
//   languageCode;

//   /** Labels to handle all custom labels in the component if any.
//    *
//    * @type {object}
//    * @private
//    */
//   label={
//     searchMarketplace,
//     marketplaceOffering,
//     marketplacePartner,
//   };

//   /** END OF PROPERTY DECLARATIONS */

//   // ******* Functions ********
//   /**
//    * sets the pageType of the community when pagetype was not passed into the component. Need to do this
//    * because the setter functions will fire before connectedCallback.
//    *
//    * @private
//    */
//   connectedCallback() {
//     const langValue = USERLANG.substr(0, 2);
//     if (this.pageType === 'Home') {
//       this.homePage = true;
//       this.placeholderValue = searchMarketplace;
//       this.languageCode = langValue;
//       this.objectType = '@objecttype==PMP_Company__c OR @objecttype==PMP_Partner_Offering__c';
//     } else if (this.pageType === 'Offering') {
//       this.placeholderValue = marketplaceOffering;
//       this.offeringPage = true;
//       this.objectType = '@objecttype==PMP_Partner_Offering__c';
//       if (langValue === 'ja') {
//         this.languageCode = 'ja';
//       } else if (langValue === 'zh') {
//         this.languageCode = 'zh';
//       } else {
//         this.languageCode = 'en';
//       }
//     } else if (this.pageType === 'Partner') {
//       this.placeholderValue = marketplacePartner;
//       this.partnerPage = true;
//       this.objectType = '@objecttype==PMP_Company__c';
//         if (langValue === 'ja') {
//         this.languageCode = 'ja';
//       } else if (langValue === 'zh') {
//         this.languageCode = 'zh';
//       } else {
//         this.languageCode = 'en';
//       }
//     }
//     this.noResultsFound = '';
//   }

//   /**
//    * Wire method to call apex method.
//    * It returns the callout details of the search from the metadata.
//    *
//    * @param {object} result  The result from the wire service.
//    * @param {object} result.data The data object returned from the wire service.
//    * @param {object} result.error The error object returned from the wire service.
//    * @private
//    */
//   @wire(getCallOutDetails)wiredCallOutRecords(result) {
//     let callOutData = [];
//     if (result.data) {
//       callOutData = result.data;
//       for (let i = 0; i < callOutData.length; i += 1) {
//         if (callOutData[i].DeveloperName === 'Coveo_Search_Post_CallOut') {
//           this.itemsPostCallOut = callOutData[i];
//         }
//       }
//     } else if (result.error) {
//       handleError(result.error, 'ipaMarqueeMarketplaceSearchBox - wiredCallOutRecords');
//       callOutData = undefined;
//     }
//     if (callOutData.length !== 0) {
//       this.enableSearch = true;
//     } else {
//       this.enableSearch = false;
//     }
//   }

//   /**
//    * Method to clear search string from SearchBox
//    *
//    * @param {event} event The event fired when clear button is clicked in searchbox.
//    * @private
//    */
//   handleClearKeyword(event) {
//     event.stopPropagation();
//     this.currentlySearching = false;
//     this.typeaheadOptions = [];
//     this.noResultsFound = '';
//   }

//   /**
//    * searches the input given in the search field
//    *
//    * @param {string} keyword The keyword is an input used from the input of the searchbox.
//    * @private
//    */
//   doSearch(keyword) {
//     this.searchQuery = keyword.trim();
//     this.currentlySearching = this.searchQuery !== '';
//     this.typeaheadOptions = [];
//     if (this.searchQuery && this.enableSearch === true) {
//       this.getsearchURL(keyword);
//     }
//   }

//   /**
//    * handles search input - finished typing
//    *
//    * @param {event} event finished typing event from Searchbox
//    * @private
//    */
//   handleFinishedTyping(event) {
//     const keyWordVal = event.detail.keywordValue.trim();
//     event.stopPropagation();
//     if (keyWordVal.length > 0) {
//       this.doSearch(keyWordVal);
//     } else {
//       this.typeaheadOptions = '';
//     }
//   }

//   /**
//    * handles typeahead option selected.
//    *
//    * @param {event} event selected option event from Searchbox.
//    * @private
//    */
//   handleSelectedOption(event) {
//     event.stopPropagation();
//     const { value } = event.detail;
//     this.searchQuery = value.trim();
//     if (this.searchQuery.length !== 0) {
//       if (this.homePage === true) {
//         this.doMarketPlaceRedirection();
//       } else {
//         this.doOfferingsOrPartnerRedirection();
//       }
//     }
//   }

//   /**
//    * Method to call redirection method from home page.
//    *
//    * @private
//    */
//   doMarketPlaceRedirection() {
//     this.performRedirection(this.itemsPostCallOut.PMP_CallOut_MarketPlace_TailURL_Txt__c);
//   }

//   /**
//    * Method to call the redirection methods based on page type.
//    * tailURL changes based on the page type.
//    *
//    * @private
//    */
//   doOfferingsOrPartnerRedirection() {
//     if (this.offeringPage === true) {
//       this.performRedirection(this.itemsPostCallOut.PMP_CallOut_Offerings_TailURL_Txt__c);
//     } else if (this.partnerPage === true) {
//       this.performRedirection(this.itemsPostCallOut.PMP_CallOut_Partner_TailURL_Txt__c);
//     }
//   }

//   /**
//    * performs redirection to either Partner/Offerings/both
//    *
//    * @param {string} tailURL The parameter which is passed to perform redirection based on pagetype.
//    * @private
//    */
//   performRedirection(tailURL) {
//     const intelLocale = this.getLanguageCode('PrefLangIETF');
//     const searchStrings = window.location.search.substr(1);
//     const result = {};
//     searchStrings.split('&').forEach((searchString) => {
//       const item = searchString.split('=');
//       result[item[0]] = decodeURIComponent(item[1]);
//     });
//     getBaseUrlForLaunguageCode({
//       cookieLangCode: intelLocale,
//       urlLangCode: result.language,
//     })
//       .then((recordResult) => {
//         this.baseUrlRecord = JSON.parse(recordResult);
//         this.inputUrl = this.baseUrlRecord[0].BaseURL__c + this.searchQuery + tailURL;
//         window.location.href = this.inputUrl;
//       })
//       .catch((error) => {
//         handleError(error, 'ipaMarqueeMarketplaceSearchBox - performRedirection');
//       });
//   }

//   /**
//    * returns the language code
//    *
//    * @param {cookieName} cookieName The parameter of language which is taken from the page url.
//    * @returns {string} languagecode The languagecode is returned.
//    * @private
//    */
//   getLanguageCode(cookieName) {
//     const Intelcookie = `${cookieName}=`;
//     const decodedCookies = decodeURIComponent(window.focus('cookie'));
//     const cookies = decodedCookies.split(';');
//     for (let i = 0; i < cookies.length; i += 1) {
//       let c = cookies[i];
//       while (c.charAt(0) === ' ') {
//         c = c.substring(1);
//       }
//       if (c.indexOf(Intelcookie) === 0) {
//         return c.substring(Intelcookie.length, c.length);
//       }
//     }
//     return '';
//   }

//   /**
//    * Performs Query Search to retrieve data from Coveo - HomePage
//    *
//    *
//    * @param {string} searchURL The url used for redirection.
//    * @param {number} count no of records fetched from the coveo search
//    * @param {string} q keyword used in search
//    * @param {string} bearerKey authorization key used for sending API request.
//    * @private
//    */
//   doHomePageSearch(searchURL, countval, queryWord, bearerKey) {
//     fetch(searchURL, {
//       method: this.itemsPostCallOut.PMP_CallOut_Method_Txt__c,
//       body: JSON.stringify({
//         q: queryWord,
//         count: countval,
//         locale:this.languageCode,
//       }),
//       headers: {
//         Accept: 'application/json',
//         'Content-Type': 'application/json',
//         Authorization: bearerKey,
//       },
//     })
//       .then((response) => response.json())
//       .then((data) => {
//         this.currentlySearching = false;
//         if (data.completions.length === 0) {
//           this.noResultsFound = 0;
//         } else {
//           this.noResultsFound = '';
//           const itemQueryValues = [];
//           for (let i = 0; i < data.completions.length; i += 1) {
//             const obj = data.completions[i];
//             itemQueryValues.push(obj.expression);
//           }
//           this.typeaheadOptions = itemQueryValues;
//         }
//       })
//       .catch((error) => {
//         handleError(error, 'ipaMarqueeMarketplaceSearchBox - doHomePageSearch');
//       });
//   }

//   /**
//    * Performs search to retrieve data from Coveo - Partners and Offerings page
//    *
//    * @param {string} searchURL The url used for redirection.
//    * @param {number} count no of records fetched from the coveo search
//    * @param {string} q keyword used in search
//    * @param {string} bearerKey authorization key used for sending API request.
//    * @private
//    */
//   doPartnerOfferingsPageSearch(searchURL, countval, queryWord, bearerKey) {
//     fetch(searchURL, {
//       method: this.itemsPostCallOut.PMP_CallOut_Method_Txt__c,
//       body: JSON.stringify({
//         q: queryWord,
//         count: countval,
//         locale:this.languageCode,
//       }),
//       headers: {
//         Accept: 'application/json',
//         'Content-Type': 'application/json',
//         Authorization: bearerKey,
//       },
//     })
//       .then((response) => response.json())
//       .then((data) => {
//         this.currentlySearching = false;
//         if (data.completions.length === 0) {
//           this.noResultsFound = 0;
//         } else {
//           this.noResultsFound = '';
//           const itemQueryValues = [];
//           for (let i = 0; i < data.completions.length; i += 1) {
//             const objpartoff = data.completions[i];
//             itemQueryValues.push(objpartoff.expression);
//           }
//           this.typeaheadOptions = itemQueryValues;
//         }
//       })
//       .catch((error) => {
//         handleError(error, 'ipaMarqueeMarketplaceSearchBox - doPartnerOfferingsPageSearch');
//       });
//   }

//   /**
//    * Method used to get the seachurl based on the page where the searchbox is used.
//    *
//    * @param {string} keyword value used get data from metadata to redirect.
//    *
//    * @private
//    */
//   getsearchURL(keyword) {
//     const URL = this.itemsPostCallOut.PMP_CallOut_URL_Txt__c;
//     const countval = this.itemsPostCallOut.PMP_CallOut_Result_Count_Txt__c;
//     const bearerKey = this.itemsPostCallOut.PMP_CallOut_BearerKey_Txt__c;
//     const organizationIdValue = this.itemsPostCallOut.PMP_CallOut_Organization_Id_Value_Txt__c;
//     const queryWord = keyword;
//     const searchURL = `${URL + organizationIdValue}&queryWord=${queryWord}&countval=${countval}`;
//     if (this.pageType === 'Home') {
//       this.doHomePageSearch(searchURL, countval, queryWord, bearerKey);
//     } else {
//       this.doPartnerOfferingsPageSearch(searchURL, countval, queryWord, bearerKey);
//     }
//   }
// }
// export default IpaMarqueeMarketplaceSearchBox;