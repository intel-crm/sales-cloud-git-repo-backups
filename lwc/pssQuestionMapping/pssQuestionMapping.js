class PssQuestionMapping extends LightningElement{}
// import { LightningElement, api, track } from 'lwc';
// // Import custom labels
// import questionLabel from '@salesforce/label/c.PSS_Question_Label';
// import questionType from '@salesforce/label/c.PSS_Question_Type';
// import optionsMapping from '@salesforce/label/c.PSS_Options_Mapping';
// import mappedToLabel from '@salesforce/label/c.PSS_Mapped_To_Label';
// import mapLabel from '@salesforce/label/c.PSS_Map_Label';

// /**
//  * A component to display the each Question in Active Survey and providing the ability to admin for mapping
//  *
//  * This component is a child component of <c-pss-conversion-mapping>
//  *
//  * @example
//  * <!-- HTML component -->
//  * <c-pss-question-mapping
//  *  question={question}
//  *  offering-fields={offeringFields}
//  *  top-taxonomy={topTaxonomy}>
//  * </c-pss-question-mapping>
//  *
//  * @augments LightningElement
//  * @property {object} question current Question details which is in Iteration of the parent Component
//  * @property {object} offeringFields Partner Offering Object fields to Map the Question to Offering Field
//  * @property {object} topTaxonomy top taxonomy values to choose while doing Mapping for each Question
//  */
// class PssQuestionMapping extends LightningElement {
//   /** This variable holds the current Question details which is in Iteration of the parent Component
//    * named pssConversionMapping
//    *
//    * @type {object}
//    * @public
//    */
//   @api question;

//   /** This variable is used to store Partner Offering Object fields to Map the Question to Offering Field
//    * This Variable is passed as Input from Parent Component pssConversionMapping
//    *
//    * @type {object}
//    * @public
//    */
//   @api offeringFields;

//   /** This variable is used to store all top taxonomy values to choose while doing Mapping for each Question
//    * It is passed as an Input from parent Component pssConversionMapping
//    *
//    * @type {object}
//    * @public
//    */
//   @api topTaxonomy;

//   /** This variable is used as an Boolean indicator to mark that the Options are Mapped inside Mapping Modal
//    *
//    * @type {boolean}
//    * @private
//    */
//   optionsMapped;

//   /** This variable is used as an Boolean indicator to mark that the Question got Mapped inside Mapping Modal
//    *
//    * @type {boolean}
//    * @private
//    */
//   questionMapped;

//   /** This variable is used to display the Field which has been mapped against the Question
//    *
//    * @type {string}
//    * @private
//    */
//   questionMappedTo;

//   /** This variable is used as an Boolean indicator to open/close the Modal
//    *
//    * @type {boolean}
//    * @private
//    */
//   modalOpen = false;


//   /** This variable contains the list of Choices Mapped against which options in Mapping Modal
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track mappedOptions = [];


//   /** This variable contains the list of Solution Options
//    *
//    * @type {object}
//    * @private
//    */
//   @track options;

//   /** This variable is boolean indicator to indicate whether Question has Choices (or) not
//    *
//    * @type {boolean}
//    * @private
//    */
//   hasOptions = false;

//   /** This variable contains the Labels for the Static Text which needs to be displayed in Markup
//    *
//    * @type {object}
//    * @private
//    */
//   @track label = {
//     questionLabel,
//     questionType,
//     optionsMapping,
//     mappedToLabel,
//     mapLabel,
//   };


//   /**
//    * Called when the when each Question is displayed at Admin Mapping Page
//    * It will create the table that contains Options Mapped, if question/options already mapped.
//    *
//    * @private
//    */
//   connectedCallback() {
//     const optionMapping = this.question.mappedChoicesByName;
//     if (optionMapping) {
//       this.mappedOptions = optionMapping;
//       this.optionsMapped = true;
//     }
//     const options = this.question.choices;

//     if (options) {
//       this.options = [...options];
//       this.hasOptions = true;
//     }
//   }


//   /**
//    * Function is executed when close and cancel button present on the popup is clicked
//    *
//    * @private
//    *
//    * @param {object} event - Fired on click of close and cancel button present on the popup
//    */
//   handlecloseModal(event) {
//     event.stopPropagation();
//     this.modalOpen = false;
//   }

//   /**
//    * Function is executed when Save button is clicked in the Popup
//    * This Function also set the variables whether Questions Mapped and Options Mapped and also the already Mapped Options
//    *
//    * @private
//    * @param {object} event - Fired on click of Save button click in Popup
//    */
//   handleSaveMapping(event) {
//     event.stopPropagation();
//     if (event.detail.mappedOptionsForTable) {
//       this.mappedOptions = event.detail.mappedOptionsForTable;
//       this.optionsMapped = true;
//       this.options = event.detail.proposalOptions;
//     } else {
//       this.questionMapped = true;

//       let name = '';

//       this.offeringFields.forEach((field) => {
//         if (field.apiName === event.detail.selectedField) {
//           name = field.Name;
//         }
//       });

//       this.questionMappedTo = `"${name}"`;
//     }

//     // closing the modal after saving
//     this.modalOpen = false;
//   }


//   /**
//    * This method will be called on click of Map Button for each Question.It will open the Mapping Modal
//    *
//    * @private
//    */
//   openMappingModal() {
//     this.modalOpen = true;
//   }

//   /**
//    *Getter Function which evaluates when the Markup is loaded.
//    *
//    * @private
//    * @returns {boolean} An indicator which indicated whether Options are mapped (or) Questions are mapped
//    */
//   get displayIconCondition() {
//     return !!((this.optionsMapped || this.questionMapped));
//   }

//   /**
//    * Getter function for computing expressions in HTML Markup
//    *
//    * @private
//    *
//    * @returns {object[]} Returns the mapped Options after marking Options which doesn't have mapping as 'Not Mapped'
//    *
//    */
//   get processedmappedOptions() {
//     const mappedOptionsClone = [...this.mappedOptions];

//     return mappedOptionsClone.map((mappedOption) => {
//       const mappedOptionClone = { ...mappedOption };

//       if (mappedOptionClone.SelectedTaxonomy === '' || mappedOptionClone.SelectedTaxonomy == null) {
//         mappedOptionClone.SelectedTaxonomy = 'Not Mapped';
//       }

//       // Generates a random number between 1 and 100 and assign it as Id
//       mappedOptionClone.Id = Math.floor((Math.random() * 100) + 1);

//       return mappedOptionClone;
//     });
//   }
// }
// export default PssQuestionMapping;