class PssQuestionOptionMappingModal extends LightningElement{}
// import { LightningElement, api, track } from 'lwc';
// import saveProposalMapping from '@salesforce/apex/PSS_SolutionMappingController.saveProposalMapping';
// import { handleError } from 'c/ipaErrorServiceMarketplace';
// // Import custom labels
// import offeringOptionsMapHeader from '@salesforce/label/c.PSS_OfferingOptionsMap_Header';
// import questionOption from '@salesforce/label/c.PSS_Question_Option';
// import offeringQuestion from '@salesforce/label/c.PSS_Offering_Question';
// import selectedOptionsLabel from '@salesforce/label/c.PSS_Selected_Options';
// import mapOfferingField from '@salesforce/label/c.PSS_Map_Offering_Field';
// import cancel from '@salesforce/label/c.PMP_Cancel';
// import saveAndCloseLabel from '@salesforce/label/c.PSS_SaveAndClose_Label';

// /**
//  *A component to display the mapping Modal for each Question
//  *
//  * This component is a child component of <c-pss-question-mapping>
//  *
//  * @example
//  * <!-- HTML component -->
//  * <c-pss-question-option-mapping-modal
//  *     top-taxonomy = {topTaxonomy}
//  *     proposal-options = {options}
//  *     has-options = {hasOptions}
//  *     offering-fields = {offeringFields}
//  *     onsave = {handleSaveMapping}
//  *     onclosemodal = {handlecloseModal}
//  *     question = {question}>
//  * </c-pss-question-option-mapping-modal>
//  *
//  * @augments LightningElement
//  * @property {object} offeringFields offering Fields that can be mapped for a Question
//  * @property {object} proposalOptions choices of the question for which mapping will be done
//  * @property {object} topTaxonomy Top Taxonomies that can be chosen while mapping
//  * @property {boolean} [hasOptions=false] Determines whether the Question contains Choices for mapping (or) not
//  * @property {object} question current Question details which is in Iteration
//  *
//  */
// class PssQuestionOptionMappingModal extends LightningElement {
//   /** This variable is used to store the Selected Field for Mapping against a Question
//    *
//    * @type {string}
//    * @private
//    */
//   selectedField;

//   /** This variable is used to store the labels which replaces the Static Text in Markup
//    *
//    * @type {object}
//    * @private
//    */
//   @track label = {
//     offeringOptionsMapHeader,
//     questionOption,
//     offeringQuestion,
//     selectedOptionsLabel,
//     mapOfferingField,
//     cancel,
//     saveAndCloseLabel,
//   };

//   /** This variable is used to store the offering Fields that can be mapped for a Question.
//    *  Passed as an input from parent component pssQuestionMapping
//    *
//    * @type {object[]}
//    * @public
//    */
//   @api offeringFields = [];

//   /** This variable is used to store the choices of the question for which mapping will be done
//    *
//    * @type {object}
//    * @public
//    */
//   @api proposalOptions;

//   /** This variable is used to store the top taxonomy value that can be chosen while mapping the choices
//    *
//    * @type {object}
//    * @public
//    */
//   @api topTaxonomy;

//   /** This variable is used as Boolean indicator which indicates whether the Question has Choices (or) not
//    * Passed from the parent component pssQuestionMapping
//    *
//    * @type {boolean}
//    * @public
//    */
//   @api hasOptions;

//   /** This variable holds the current Question details which is in Iteration of the Grand parent Component
//    * named pssConversionMapping. It is passed to this component via parent component pssQuestionMapping
//    *
//    * @type {object}
//    * @public
//    */
//   @api question;

//   /**
//    *Function called whenever the Popup has been completely rendered.
//    *This method is modifying the slds modal CSS Property to overflow the Picklist options outside Modal window
//    *
//    * @private
//    */
//   renderedCallback() {
//     if (!this.hasOptions) {
//       this.template.querySelector('.slds-modal__content').style.overflow = 'visible';
//     }
//   }

//   /**
//    * This Method will fire the CustomEvent 'closemodal'
//    * closemodal event handled in parent component pssQuestionMapping to close the slds modal
//    *
//    * @private
//    */
//   handleClose() {
//     this.dispatchEvent(new CustomEvent('closemodal'));
//   }

//   /**
//    * This method will be called when SaveAndClose button has been clicked in the Modal
//    * It will save the Question Mapping and Options Mapping details by calling the saveMapping method in this JS
//    *
//    * @private
//    */
//   saveAndClose() {
//     let options = {};
//     options = (typeof this.proposalOptions === 'undefined') ? [] : [...this.proposalOptions];

//     const propOptions = this.template.querySelectorAll('.optionsMap');
//     const { selectedField } = this;

//     // either question/options can be mapped
//     // when user is mapping question
//     if (selectedField && !(this.hasOptions)) {
//       const question = { Id: this.question.id, PMP_Offering_Field_Nm__c: selectedField };
//       const param = { mappedQuestion: question };

//       this.saveMapping(param, null);
//     } else if (options) { // when user is mapping options
//       const mappedOptionsForTable = [];
//       const saveMappingData = [];
//       let isMapped;

//       // Updating options variable based on mapped options in child component which inturn updates proposalOptions
//       for (let j = 0; j < options.length; j += 1) {
//         for (let i = 0; i < propOptions.length; i += 1) {
//           if (options[j].id === propOptions[i].option.id) {
//             const optionsObj = { ...options[j] };
//             optionsObj.offeringOptions = propOptions[i].uoptions;
//             optionsObj.selectedTopTaxonomy = propOptions[i].selectedTopTaxonomy;
//             options[j] = { ...optionsObj };
//             break;
//           }
//         }
//       }

//       for (let i = 0; i < propOptions.length; i += 1) {
//         for (let j = 0; j < options.length; j += 1) {
//           if (options[j].id === propOptions[i].option.id) {
//             const offOptions = propOptions[i].uoptions;
//             const selectedOptions = [];
//             const selectedOptionIds = [];
//             let surveyChoice = {};
//             propOptions[i].isMapped = false;

//             if (offOptions) {
//               // eslint-disable-next-line no-loop-func
//               offOptions.forEach((optn) => {
//                 if (optn.selected) {
//                   selectedOptions.push(optn.Name);
//                   selectedOptionIds.push(optn.Id);
//                   propOptions[i].isMapped = true;
//                   isMapped = true;
//                 }
//               });
//             }

//             if (propOptions[i].isMapped) {
//               surveyChoice = {};
//               surveyChoice.Id = options[j].id;
//               surveyChoice.PMP_Related_Parent_Taxonomy__c = options[j].selectedTopTaxonomy;
//               surveyChoice.PMP_Related_Offering_Options__c = selectedOptionIds.join();
//               saveMappingData.push(surveyChoice);
//             }

//             // building the mapped options table for the main screen (mappedOptionsForTable)
//             if (selectedOptions) {
//               mappedOptionsForTable.push({
//                 Label: options[j].label,
//                 SelectedTaxonomy: selectedOptions.join(),
//               });
//             }
//           }
//         }
//       }

//       if (isMapped) {
//         // eslint-disable-next-line @lwc/lwc/no-api-reassignments
//         this.proposalOptions = options;

//         const param = { mappedChoices: saveMappingData };
//         this.saveMapping(param, mappedOptionsForTable);
//       }
//     }
//   }

//   /**
//    * Function get called whenever Field has been selected in Popup while mapping Question to Partner Offering Field
//    * It will store the selectedField variable with the selected Field value
//    *
//    * @private
//    *
//    * @param {object} event - Holds the selected field value
//    */
//   handleFieldSelection(event) {
//     this.selectedField = event.detail.value;
//   }


//   /**
//    * Helper function to save the mapping details to the SObject by calling Apex Controller method
//    * This will be called from the method saveAndClose for saving Mapped details
//    * It will also fire the 'save' CustomEvent to handle in parent component pssQuestionMapping
//    *
//    * @private
//    *
//    * @param {object} param - Holds the data that needs to be saved to SObject
//    * @param {object[]} mappedOptionsForTable - Holds the mapped options table for the main screen
//    */
//   saveMapping(param, mappedOptionsForTable) {
//     saveProposalMapping({ data: param })
//       .then(() => {
//         const saveEvent = new CustomEvent('save', {
//           composed: true,
//           bubbles: true,
//           cancelable: true,
//           detail: {
//             mappedOptionsForTable,
//             selectedField: this.selectedField,
//             proposalOptions: this.proposalOptions,
//           },
//         });

//         // save Event handled in parent component pssQuestionMapping
//         this.dispatchEvent(saveEvent);
//       })
//       .catch((error) => {
//         handleError(error, 'pssQuestionOptionMappingModal - saveProposalMapping');
//       });
//   }


//   /**
//    * Getter function which translates the Name and apiName into label and value for displaying Combobox options
//    *
//    * @private
//    *
//    * @returns {object[]} Holds the Combobox options that needs to be displayed in popup
//    */
//   get options() {
//     const offeringFieldsClone = [...this.offeringFields];
//     const optionArr = [];
//     for (let i = 0; i < offeringFieldsClone.length; i += 1) {
//       const optionArrObj = {};
//       optionArrObj.label = offeringFieldsClone[i].Name;
//       optionArrObj.value = offeringFieldsClone[i].apiName;
//       optionArr.push(optionArrObj);
//     }

//     return optionArr;
//   }
// }
// export default PssQuestionOptionMappingModal;