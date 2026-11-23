/** Documentation for Quick Search Component
 *
 * @namespace ipaKeywordandFilterSearch
 * @property {boolean} separatorAbove adds separator above
 * @property {boolean} separatorBelow adds separator below
 *
 * @author Sai, Last Modified: April 2022
 */

 import heading from '@salesforce/label/c.PMP_Quick_Search_Heading';
 import searchLoading from '@salesforce/label/c.PMP_Quick_Search_Loading';
 import searchButton from '@salesforce/label/c.PMP_Quick_Search_Button_Offerings';

 import { LightningElement, api, track } from 'lwc';
 import { NavigationMixin } from 'lightning/navigation';
 // import { SearchHelper } from 'c/ipaSearchService';
 import { subscribeToTaxonomyData } from 'c/ipaTaxonomyService';
 //import { makeIpaAnalyticsCall } from 'c/ipaAnalyticsService';

 /**
  * @augments LightningElement
  * @property {string} taxonomy1 first dropdown
  * @property {string} taxonomy2 second dropdown
  * @property {string} taxonomy3 third dropdown
  * @property {boolean} separatorAbove show separator above component
  * @property {boolean} separatorBelow show separator below component
  * @property {boolean} paddingAbove add padding above component
  * @property {boolean} paddingBelow add padding below component
  */
 class IpaKeywordAndFilterSearch extends NavigationMixin(LightningElement) {
   @api taxonomy1;

   @api taxonomy2;

   @api taxonomy3;

   @api taxonomy4;

   @api taxonomy5;

   @api taxonomy6;

   @api separatorAbove;

   @api separatorBelow;

   @api paddingAbove;

   @api paddingBelow;

   @track options = [];

   @track dropdownList = 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta';

   @track selectedValue = 'Select a Value';

   @track selectedListOfValues='';

   //@track filter = [];

   /**
    * custom labels
    *
    * @type {object}
    * @private
    */
   labels = {
     heading, searchLoading, searchButton,
   };

   /**
    * Filter structure for dropdowns
    *
    * @type {object[]}
    * @private
    */
   filterStructure = [];

   /**
    * keeps track of loading data
    *
    * @type {boolean}
    * @private
    */
   loading;

   /**
    * keeps track of dropdown values for search
    *
    * @type {object}
    * @private
    */
   searchValues = {};

   /**
    * Returns Formatted Filters for Template
    * - if loading return placeholder dropdown structure
    *
    * @returns {object[]} formatted filters for template
    * @private
    */
   get filters() {
     this.filterStructure = [
       this.taxonomy1 || '(missing design attribute for: Primary)',
       this.taxonomy2 || '(missing design attribute for: Secondary)',
       this.taxonomy3 || '(missing design attribute for: Tertiary)',
       this.taxonomy4 || '(missing design attribute for: Quaternary)',
       this.taxonomy5 || '(missing design attribute for: Quinary)',
       this.taxonomy6 || '(missing design attribute for: Senary)',
     ];

     return this.filterStructure.map((filter, idx) => {
       // loading structure
       if (this.loading) {
         return {
           key: `loading-filter-${idx}`,
           name: `loading-filter-${idx}`,
           label: '',
           disabled: false,
           options: [],
         };
       }

       const taxonomy = this.taxonomyData[filter];
       if (!taxonomy) {
         throw new Error(`Missing Taxonomy Data for: ${filter}`);
       }

       //const selectedPrimary = this.searchValues[this.filterStructure[0]];
       const disabled = false;
       /*let opts = [];
       opts = taxonomy.topLevelIds.map((id) => taxonomy.records[id]);
       for(let i=0;i<opts.length;i++) {
         opts[i] = [{ label:opts[i], isChecked:false, class:this.dropdownList}];
       }*/

       return {
         name: filter,
         key: filter,
         label: taxonomy.label,
         disabled,
         options: taxonomy.topLevelIds.map((id) => taxonomy.records[id]),
       };
     });
   }

   /** api name
    *
    * @returns {string} api name
    * @private
    */
   get apiName() {
     return this.taxonomyData[this.filterStructure[0]].apiName;
   }

   openDropdown(event){
    const targetId = event.currentTarget.name;
    this.template.querySelector('[data-id="' +targetId+ '"]').className = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';
   }

   closeDropDown(event){
    const targetIdclose = event.currentTarget.title;
    this.template.querySelector('[data-id="' +targetIdclose+ '"]').className = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
   }

   selectOption(event){
    const isCheck = event.currentTarget.dataset.id;
    const label = event.currentTarget.dataset.name;
    var selectedOption='';
    var allOptions = [];
    //let innerOptions = [];
    allOptions = this.taxonomyData[event.currentTarget.title].topLevelIds.map((id) => this.taxonomyData[event.currentTarget.title].records[id]);
    /*for(let i=0;i<allOptions.length;i++) {
      allOptions[i] = [{ label:allOptions[i], isChecked:false, class:this.dropdownList}];
    }*/
    let count=0;

    for(let i=0;i<allOptions.length;i++) {
        if(allOptions[i].label===label) {
            if(isCheck==='true') {
                allOptions[i].isChecked = false;
                allOptions[i].class = this.dropdownList;
             } else {
                allOptions[i].isChecked = true; 
                //allOptions[i][j].class = 'slds-media slds-listbox__option slds-listbox__option_plain slds-media_small slds-media_center slds-is-selected';
              }
        } if(allOptions[i].isChecked) { 
           count++;
        }
    //innerOptions.push(allOptions[i]);
  }

   /*var obj = [];
   for(let m=0;m<this.filter.length;m++) {
     if(this.filter[m]!=null) {
      obj = JSON.parse(JSON.stringify(this.filter[m]));
        if(obj.key === event.currentTarget.title) {
          obj.options = innerOptions; 
          this.filter[m].options = obj.options;
          console.log(this.filter[m]);
        }
      }
    }*/
    
    if(count === 1) {
            selectedOption = count+' Value Selected';
        } else if(count>1) {
            selectedOption = count+' Values Selected';
        }
        this.options = allOptions;
        this.selectedValue=selectedOption;
    }

   /**
    * Connected Callback
    * - subscribing to redux taxonomy data
    *
    * @private
    */
   connectedCallback() {
      this.loading = true;
      this.taxonomyData = {};
      this.sub = subscribeToTaxonomyData((taxonomyData) => {
        if (taxonomyData.includesBaseList) {
          this.taxonomyData = taxonomyData.data;
          this.loading = false;
        }
      });
   }

   /**
    * Disconnected Callback
    * - unsubscribing to redux
    *
    * @private
    */
   disconnectedCallback() {
     if (this.sub) {
         this.sub();
     }
   }
 }
 export default IpaKeywordAndFilterSearch;