// /** Documentation for Quick Search Component
//  *
//  * @namespace ipaQuickSearch
//  * @property {boolean} separatorAbove adds separator above
//  * @property {boolean} separatorBelow adds separator below
//  *
//  * @author Nick Demarest, Last Modified: May 29 2020
//  */

// import heading from '@salesforce/label/c.PMP_Quick_Search_Heading';
// import searchLoading from '@salesforce/label/c.PMP_Quick_Search_Loading';
// import searchButton from '@salesforce/label/c.PMP_Quick_Search_Button_Offerings';

import { LightningElement, api } from 'lwc';
// import { NavigationMixin } from 'lightning/navigation';
// import { SearchHelper } from 'c/ipaSearchService';
// import { subscribeToTaxonomyData } from 'c/ipaTaxonomyService';
// import { makeIpaAnalyticsCall } from 'c/ipaAnalyticsService';

/**
 * @augments LightningElement
 * @property {string} taxonomy1 first dropdown
 * @property {string} taxonomy2 second dropdown
 * @property {string} taxonomy3 third dropdown
 * @property {string} taxonomy4 fourth dropdown
 * @property {boolean} separatorBelow show separator below component
 * @property {boolean} paddingAbove add padding above component
 * @property {boolean} paddingBelow add padding below component
*/
class IpaQuickSearch extends NavigationMixin(LightningElement) { 
    @api taxonomy1;

  @api taxonomy2;

  @api taxonomy3;

  @api taxonomy4;
   @api separatorAbove;

  @api separatorBelow;

  @api paddingAbove;

  @api paddingBelow;




}
 

 
//   /**
//    * custom labels
//    *
//    * @type {object}
//    * @private
//    */
//   labels = {
//     heading, searchLoading, searchButton,
//   }

//   /**
//    * Filter structure for dropdowns
//    *
//    * @type {object[]}
//    * @private
//    */
//   filterStructure = [];

//   /**
//    * keeps track of loading data
//    *
//    * @type {boolean}
//    * @private
//    */
//   loading;

//   /**
//    * keeps track of dropdown values for search
//    *
//    * @type {object}
//    * @private
//    */
//   searchValues = {};

//   /**
//    * Returns Formatted Filters for Template
//    * - if loading return placeholder dropdown structure
//    * - includes disabled logic (all dropdowns are dependent first being selected)
//    *
//    * @returns {object[]} formatted filters for template
//    * @private
//    */
//   get filters() {
//     this.filterStructure = [
//       this.taxonomy1 || '(missing design attribute for: Primary)',
//       this.taxonomy2 || '(missing design attribute for: Secondary)',
//       this.taxonomy3 || '(missing design attribute for: Tertiary)',
//       this.taxonomy4 || '(missing design attribute for: Quaternary)',
//     ];

//     return this.filterStructure.map((filter, idx) => {
//       // loading structure
//       if (this.loading) {
//         return {
//           key: `loading-filter-${idx}`,
//           name: `loading-filter-${idx}`,
//           label: '',
//           disabled: true,
//           options: [],
//         };
//       }

//       const taxonomy = this.taxonomyData[filter];
//       if (!taxonomy) throw new Error(`Missing Taxonomy Data for: ${filter}`);

//       // Dependency on Categories
//       const selectedPrimary = this.searchValues[this.filterStructure[0]];
//       const disabled = idx > 0 && !selectedPrimary;

//       return {
//         name: filter,
//         key: filter,
//         label: taxonomy.label,
//         disabled,
//         options: taxonomy.topLevelIds.map((id) => taxonomy.records[id]),
//       };
//     });
//   }

//   /** api name
//    *
//    * @returns {string} api name
//    * @private
//    */
//   get apiName() {
//     return this.taxonomyData[this.filterStructure[0]].apiName;
//   }

//   /**
//    * button is disabled until first dropdown is selected
//    *
//    * @returns {boolean} boolean value
//    * @private
//    */
//   get isButtonDisabled() {
//     return !this.searchValues[this.filterStructure[0]];
//   }

//   /**
//    * Connected Callback
//    * - subscribing to redux taxonomy data
//    *
//    * @private
//    */
//   connectedCallback() {
//     this.loading = true;
//     this.taxonomyData = {};
//     this.sub = subscribeToTaxonomyData((taxonomyData) => {
//       if (taxonomyData.includesBaseList) {
//         this.taxonomyData = taxonomyData.data;
//         this.loading = false;
//       }
//     });
//   }

//   /**
//    * Disconnected Callback
//    * - unsubscribing to redux
//    *
//    * @private
//    */
//   disconnectedCallback() {
//     if (this.sub) this.sub();
//   }

//   /**
//    * changes search values with new selection
//    *
//    * @param {event} evt onchange select event
//    * @private
//    */
//   handleSelectFilter(evt) {
//     this.searchValues = {
//       ...this.searchValues,
//       [evt.currentTarget.getAttribute('name')]: evt.currentTarget.value,
//     };
//   }

//   /**
//    * Handles Search - navigates to record page with selected values
//    *
//    * @private
//    */
//   handleSearch() {
//     const searchParams = { filters: {} };

//     this.filterStructure.slice(1).forEach((value) => {
//       if (this.searchValues[value]) {
//         searchParams.filters[value] = [this.searchValues[value]];
//       }
//     });

//     this.callSearchSubmitAnalytics();

//     SearchHelper.initialParams = { ...searchParams };
//     this[NavigationMixin.Navigate]({
//       type: 'standard__recordPage',
//       attributes: {
//         recordId: this.searchValues[this.filterStructure[0]],
//         objectApiName: this.apiName,
//         actionName: 'view',
//       },
//     });
//   }

//   /**
//    * call analytics
//    *
//    * @private
//    */
//   callSearchSubmitAnalytics() {
//     const details = this.filterStructure.map((value) => this.searchValues[value] || 'NA');

//     const analyticsClick = {
//       analyticsType: 'click',
//       element: 'quick-search-filter',
//       details: details.join('|'),
//     };

//     // Quick search submit click call
//     makeIpaAnalyticsCall(analyticsClick);

//     // Setting data for quick search response analytics call. Done in search searchAction
//     SearchHelper.analytics = {
//       analyticsType: 'filter',
//       element: 'quick-search-filter',
//       details: details.join(','),
//     };

//     // sample:
//     // 'details': 'a5N3b000000L7RrEAK|a5N3b000000L7SiEAK|NA|a5g3b000000PMQjAAO',
//     // 'a5N3b000000L7RrEAK' is 'software' id Category.
//     // 'a5N3b000000L7SiEAK' is 'industry' id Category.
//     // 'NA' means the user didn't select any value on that dropdown Category.
//     // 'a5g3b000000PMQjAAO' is 'americas' id Category. } });
//   }
// }
 export default IpaQuickSearch;