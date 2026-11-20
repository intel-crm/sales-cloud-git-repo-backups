class PssConversionMapping extends LightningElement{}
// import { LightningElement, track } from 'lwc';
// import getQuestions from '@salesforce/apex/PSS_SolutionMappingController.getQuestions';
// import { handleError } from 'c/ipaErrorServiceMarketplace';
// import adminMappingPageHeader from '@salesforce/label/c.PSS_AdminMappingPage_Header';

// /** A component to display the set of Questions from Active Survey and make it available for Mapping. This Mapping will be used for Solution to
//  *  Offering Conversion
//  *
//  * This component is exposed in the Admin Mapping Page for Conversion Mapping
//  *
//  * @example
//  * <!-- HTML component -->
//  * <c-pss-conversion-mapping></c-pss-conversion-mapping>
//  *
//  * @augments LightningElement
//  */
// class PssConversionMapping extends LightningElement {
//   /** This variable is used to store all questions available for Mapping
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track questions = [];

//   /** This variable is used to store all top taxonomy value to choose while doing Mapping
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track topTaxonomy = [];

//   /** This variable is used to store Partner Offering Object fields to Map the Question to Offering Field
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track offeringFields = [];

//   /** This variable contains the Labels for the Static Text which needs to be displayed in Markup
//    *
//    * @type {object}
//    * @private
//    */
//   @track label = {
//     adminMappingPageHeader,
//   };

//   /**
//    * Function called when the Component has been initialized.This Method will call the Apex Controller method 'getQuestions' and
//    * then it will set the Private variables in this component for further processing
//    *
//    * @private
//    *
//    */
//   connectedCallback() {
//     getQuestions()
//       .then((result) => {
//         this.questions = result.questions;
//         this.offeringFields = result.offeringFields;
//         this.topTaxonomy = result.topTaxonomy;
//       })
//       .catch((error) => {
//         handleError(error, 'pssConversionMapping - getQuestions');
//       });
//   }
// }
// export default PssConversionMapping;