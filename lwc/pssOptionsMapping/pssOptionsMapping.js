class PssOptionsMapping extends LightningElement{}
// /* eslint-disable @lwc/lwc/no-api-reassignments */
// import { LightningElement, api, track } from 'lwc';
// import getChildTaxonomies from '@salesforce/apex/PSS_SolutionMappingController.getChildTaxonomies';
// import { handleError } from 'c/ipaErrorServiceMarketplace';
// // Import custom labels
// import topTaxonomyLabel from '@salesforce/label/c.PSS_TopTaxonomy_Label';
// import relevantOptions from '@salesforce/label/c.PSS_Relevant_Options';

// /**
//  *
//  * A component to display the top taxonomy and child Taxonomy details for Mapping
//  *
//  * This component is a child component of <c-pss-question-option-mapping-modal>
//  *
//  * @example
//  * <!-- HTML component -->
//  * <c-pss-options-mapping
//  *    option = {option}
//  *    uoptions = {option.offeringOptions}
//  *    top-taxonomy = {topTaxonomy}
//  *    selected-top-taxonomy = {option.selectedTopTaxonomy}
//  *    selected-child-taxonomy= {option.selectedChildTaxonomy}>
//  *  </c-pss-options-mapping>
//  *
//  * @augments LightningElement
//  * @property {string} selectedTopTaxonomy Passed from parent Component to Display already selected top Taxonomy value
//  * @property {string} selectedChildTaxonomy Passed from parent Component to Display already selected Child Taxonomy value
//  * @property {string} topTaxonomy Display top taxonomies that can be selected while Mapping
//  * @property {object} uoptions display child taxonomies that are selected while Mapping
//  * @property {object} option current Option in Iteration for Mapping
//  *
//  */
// class PssOptionsMapping extends LightningElement {
//   /** This variable is used as an Boolean indicator to mark whether the Select Relevant Options Dropdown has been clicked (or) not
//    *
//    * @type {boolean}
//    * @private
//    */
//   multipleDropdownOpen;

//   /** This variable is used as an Boolean indicator to mark whether the options box has been touched (or) not
//    *
//    * @type {boolean}
//    * @private
//    */
//   touched;

//   /** This variable is used as an Boolean indicator to mark whether the error message has to be shown (or) not
//    *
//    * @type {boolean}
//    * @private
//    */
//   forceShowError;

//   /** This variable is used to show placeholder message in Select Relevant options input
//    *
//    * @type {string}
//    * @private
//    */
//   placeholder;

//   /** This variable is used as id value for input text in Popup
//    *
//    * @type {string}
//    * @private
//    */
//   optionName;

//   /** This variable is used to display the Error Message in Markup
//    *
//    * @type {string}
//    * @private
//    */
//   errorMessage;

//   /** This variable is used to store selected Pill values
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track multiValues = [];

//   /** This variable is used to store selected Relevant Options
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track options = [];

//   /** This variable is used to store concatenated Relevant Options with delimiter ';'
//    *
//    * @type {string}
//    * @private
//    */
//   value;

//   /** This variable is used as Boolean indicator to decide whether values are joined (or) not
//    *
//    * @type {boolean}
//    * @private
//    */
//   isPicklist;

//   /** This variable is used to store labels for displaying static text in Markup
//    *
//    * @type {object}
//    * @private
//    */
//   @track label = {
//     topTaxonomyLabel,
//     relevantOptions,

//   };

//   /** This variable is used to display already selected Top Taxonomy during Mapping
//    *
//    * @type {string}
//    * @public
//    */
//   @api selectedTopTaxonomy = '';

//   /** This variable is used to display already selected Child Taxonomy during Mapping
//    *
//    * @type {string}
//    * @public
//    */
//   @api selectedChildTaxonomy = '';

//   /** This variable is used to display top taxonomies that can be selected while Mapping
//    *
//    * @type {object[]}
//    * @public
//    */
//   @api topTaxonomy = [];

//   /** This variable is used to display child taxonomies that are selected while Mapping
//    *
//    * @type {object}
//    * @public
//    */
//   @api uoptions;

//   /** This variable contains the current Option in Iteration for Mapping
//    * It is iterated and passed as an Input from parent component pssQuestionOptionMappingModal
//    *
//    * @type {object}
//    * @public
//    */
//   @api option;

//   /**
//    * Function called when the Component has been initialized
//    * It will loop the Child taxonomies and marks the selected attibute as true for already selected Child Taxonomy
//    *
//    * @private
//    */
//   connectedCallback() {
//     const taxonomyOptions = (typeof this.uoptions === 'undefined') ? [] : [...this.uoptions];
//     const selectedTaxonomy = (typeof this.selectedChildTaxonomy === 'undefined') ? '' : this.selectedChildTaxonomy;

//     this.uoptions = (typeof this.uoptions === 'undefined') ? [] : this.uoptions;

//     if (taxonomyOptions && selectedTaxonomy) {
//       taxonomyOptions.forEach((opt, index, arr) => {
//         const optClone = { ...opt };

//         if (selectedTaxonomy.includes(optClone.Id)) {
//           optClone.selected = true;
//         }

//         // eslint-disable-next-line no-param-reassign
//         arr[index] = optClone;
//       });

//       this.uoptions = taxonomyOptions;
//     }
//   }

//   /**
//    * Getter function for computing expressions for HTML Markup
//    * It computes the slds classes that needs to be shown for input element in Markup
//    *
//    * @private
//    *
//    * @returns {string} Computed Div class used for HTML Markup
//    */
//   get ComputedDivClass() {
//     const strSeparator = ' ';
//     const str2 = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
//     let str3 = '';
//     let str4 = '';
//     if (this.multipleDropdownOpen) {
//       str3 = 'slds-is-open';
//     }

//     if (this.touched && (this.multiValues.length === 0)) {
//       str4 = 'slds-has-error';
//     }

//     const finalStr = str2.concat(strSeparator, str3, strSeparator, str4);

//     return finalStr;
//   }

//   /**
//    * Getter function for computing expressions to add slds classes for HTML Markup
//    *
//    * @private
//    *
//    * @returns {string} Computed Class for HTML Markup
//    */
//   get ComputedInputClass() {
//     const string1 = 'slds-input slds-combobox__input';
//     let string2 = '';
//     if (this.multipleDropdownOpen) {
//       string2 = ' slds-has-focus';
//     }

//     const sConcatStr = string1.concat(string2);

//     return sConcatStr;
//   }

//   /**
//    *Getter function for computing expressions and display Error Message DIV in HTML Markup
//    *
//    * @private
//    *
//    * @returns {boolean} Returns Boolean indicator which is used in HTML Markup
//    */
//   get Expr1() {
//     if ((this.touched && this.multiValues.length === 0) || this.forceShowError) {
//       return true;
//     }

//     return false;
//   }

//   /**
//    * Getter function for computing expressions for HTML Markup
//    *
//    * @private
//    *
//    * @returns {object} Object which holds the Computed Id and Classes
//    */
//   get ComputedOptions() {
//     const _optionsClone = [...this.uoptions];
//     let indexVar = 0;

//     return _optionsClone.map((optionClone) => {
//       let optionHighlight = '';
//       const optionClonebkp = { ...optionClone };
//       if (optionClonebkp.highlight) {
//         optionHighlight = 'highlight';
//       }
//       optionClonebkp.ComputedId = `option${indexVar}`;
//       indexVar += 1;
//       optionClonebkp.ComputedClass = `${'slds-media slds-listbox__option slds-listbox__option_plain slds-media_small '}${optionHighlight}`;

//       return optionClonebkp;
//     });
//   }

//   /**
//    * Getter function for computing expressions for HTML Markup
//    *
//    * @private
//    *
//    * @returns {object[]} Array of Top Taxonomy Combobox options
//    */
//   get comboboxoptions() {
//     const topTaxonomyClone = [...this.topTaxonomy];
//     const optionArr = [];
//     for (let i = 0; i < topTaxonomyClone.length; i += 1) {
//       const optionArrObj = {};
//       optionArrObj.label = topTaxonomyClone[i].Name;
//       optionArrObj.value = topTaxonomyClone[i].pimId;
//       optionArrObj.selected = (topTaxonomyClone[i].pimId === this.selectedTopTaxonomy);
//       optionArr.push(optionArrObj);
//     }

//     return optionArr;
//   }


//   /**
//    * This Method will fire whenever the Select Relevant option Combobox is clicked and sets the variables to true
//    *
//    * @private
//    */
//   handleToggleMultipleDropdown() {
//     this.multipleDropdownOpen = !(this.multipleDropdownOpen);
//     if (!(this.multipleDropdownOpen)) {
//       this.touched = true;
//     }
//   }

//   /**
//    * Method called onBlur event of the Select Relevant Option Input in Markup
//    * It will set the reactive private variables appropriately
//    *
//    * @private
//    */
//   handleCloseMultipleDropdown() {
//     this.touched = true;
//     this.multipleDropdownOpen = false;
//   }

//   /**
//    * Function to handle MouseDown event in HTML Markup
//    *
//    * @private
//    *
//    * @param {object} event - Fired when the Mousedown event occured in HTML markup of popup
//    */
//   preventBlur(event) {
//     event.preventDefault();
//   }

//   /**
//    * Function called when Select Relevant Options combobox has been clicked
//    * This method will handle the selection of Listed Items in Select Relevant Option combobox
//    *
//    * @private
//    *
//    * @param {object} event - Fired when Select Relevant Options combobox has been selected
//    */
//   handleSelectMultipleOption(event) {
//     const data = event.currentTarget.dataset;
//     const options = [...this.uoptions];
//     const optionsObjClone = { ...options[data.idx] };
//     optionsObjClone.selected = (typeof optionsObjClone.selected === 'undefined') ? true : !(optionsObjClone.selected);
//     options[data.idx] = optionsObjClone;

//     this.uoptions = options;
//     this.setValueForMultiple();
//   }

//   /**
//    * Function called when the Selected Pill options has been removed
//    * It removes the pill that has been displayed for previous selections in Select Relevant Options
//    * It also updates the Placeholder value displayed
//    *
//    * @private
//    *
//    * @param {object} event - Event Fired when the Selected Relevant Options Pill has been removed
//    */
//   handleRemovePill(event) {
//     const pill = event.currentTarget.dataset.val;
//     const options = [...this.uoptions];
//     options.forEach((opt, index, arr) => {
//       const optClone = { ...opt };
//       if (optClone.Id === pill) {
//         optClone.selected = false;
//       }

//       // eslint-disable-next-line no-param-reassign
//       arr[index] = optClone;
//     });
//     this.uoptions = options;

//     this.resetMultiplePlaceholder();

//     const values = this.multiValues;
//     values.splice(values.indexOf(pill), 1);
//     this.multiValues = values;
//     this.value = this.isPicklist ? values.join(';') : values;
//   }

//   /**
//    * Function called when the Combobox option for 'Select the Specification/Category' has been changed
//    * This method will set the variable selectedTopTaxonomy and calls the method fetchChildTaxonomy based on selectedTopTaxonomy
//    *
//    * @private
//    *
//    * @param {object} event - Event fired when the Top Taxonomy Combobox value changes
//    */
//   handleTaxonomySelection(event) {
//     this.selectedTopTaxonomy = event.detail.value;
//     this.fetchChildTaxonomy();
//   }

//   /**
//    * Function called from another function handleSelectMultipleOption when Select Relevant Option picklist has been selected
//    * This will store the selected values in value variable and also calls resetMultiplePlaceholder method to set Placeholder value for input in Markup
//    *
//    * @private
//    */
//   setValueForMultiple() {
//     const options = this.uoptions;
//     const values = options.filter((opt) => opt.selected)
//       .map((opt) => opt.id);

//     this.multiValues = values;

//     if (values.length || this.value !== undefined) {
//       this.value = values.join(';');
//     }

//     this.multipleDropdownOpen = false;
//     this.resetMultiplePlaceholder();
//   }

//   /**
//    * Function called from another function setValueForMultiple
//    * It will be used to set the placeholder value for input text in Markup
//    *
//    * @private
//    */
//   resetMultiplePlaceholder() {
//     const selected = this.uoptions.filter((opt) => opt.selected);

//     if (selected.length > 0) {
//       this.placeholder = `${selected.length} option${selected.length === 1 ? '' : 's'} selected`;
//     } else {
//       this.placeholder = 'No options selected';
//     }
//   }

//   /**
//    * Function called when the Top Taxonomy option has been changed inorder to fetch ChildTaxonomy options
//    * This method will call the Apex Controller method getChildTaxonomies to fetch the child taxonomy values based on
//    * the top taxonomy that has been selected
//    *
//    * @private
//    */
//   fetchChildTaxonomy() {
//     const selectedFieldName = this.selectedTopTaxonomy;

//     getChildTaxonomies({ parentId: selectedFieldName })
//       .then((result) => {
//         this.selectedField = selectedFieldName;
//         this.uoptions = result;
//       })
//       .catch((error) => {
//         handleError(error, 'pssOptionsMapping - getChildTaxonomies');
//       });
//   }
// }
// export default PssOptionsMapping;