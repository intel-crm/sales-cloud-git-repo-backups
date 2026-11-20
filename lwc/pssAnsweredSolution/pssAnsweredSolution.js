class PssAnsweredSolution extends LightningElement{}
// import { LightningElement, api, track } from 'lwc';

// // custom label
// import intelProductsLabel from '@salesforce/label/c.PSS_Intel_Products';
// import questionLabel from '@salesforce/label/c.PSS_Question';
// import answerLabel from '@salesforce/label/c.PSS_Answer';
// import projectedQuantityLabel from '@salesforce/label/c.PSS_Projected_Quantity';
// import commentsLabel from '@salesforce/label/c.PSS_Comments';
// import urlRegularExpression from '@salesforce/label/c.PSS_URL_Regular_Expression';


// /** This component is to display the question and answer for the Solution Details
//  * and for intel products.
//  *
//  * @example
//  * <!-- HTML component -->
//  * <c-pss-answered-solution question-ans-list={questionAnsList} intel-product-list={intelProductList}></c-pss-answered-solution>
//  *
//  * @augments LightningElement
//  * @property {object[]} questionAnsList list for the question and answer of solution
//  * @property {object[]} intelProductList list for the intel products
//  *
//  */
// class PssAnsweredSolution extends LightningElement {
//   /** custom labels:
//    *
//    * intelProductsLabel - PSS_Intel_Products
//    * questionLabel - PSS_Question
//    * answerLabel - PSS_Answer
//    *
//    * @type {object}
//    * @private
//    */
//   labels = {
//     intelProductsLabel,
//     questionLabel,
//     answerLabel,
//     projectedQuantityLabel,
//     commentsLabel,
//   };

//   /**
//    * Columns to display in the datatable
//    * fieldName will be retrieved from the apex class
//    *
//    * @type {object}
//    * @private
//    */
//   columns = [
//     { label: intelProductsLabel, fieldName: 'ques', wrapText: true },
//     { label: projectedQuantityLabel, fieldName: 'ans', wrapText: true },
//     { label: commentsLabel, fieldName: 'comm', wrapText: false },
//   ];

//   /** Constant variable used in the components
//    *
//    * @type {object}
//    * @private
//    */
//   CONSTANT = {
//     INTEL_PRODUCT: 'IOTG_IntelProduct',
//     PROJECTED_QUANTITY: 'IOTG_ProjectedQuantity',
//     COMMENTS: 'IOTG_Comments',
//   }

//   /** Boolean to display the intel product on UI
//    *
//    * @type {boolean}
//    *
//    * @private
//    */
//   intelProduct = false;

//   /** To Display the question and answer of the solution record.
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track answerobj = [];

//   /** To display the intel products added for the solution.
//    *
//    * @type {object[]}
//    *
//    * @private
//    */
//   @track intelProductValue = [];

//   /** To display the projected quantity for the intel products in the solution.
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track projectedQuantity = [];

//   /** To display the comments for the intel products in the solution.
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track comments = [];

//   /** Boolean to display the question and answer on the solution detail page
//    *
//    * @type {boolean}
//    * @private
//    */
//   ansFlag = false;

//   /**
//    *internal array to get the question and answer from the parent record.
//    *
//    * @returns {object[]}  The internal array of solution in the version format expected by the component.
//    * @private
//    */
//   @api
//   get questionAnsList() {
//     return this._questionAnsList;
//   }


//   /** To set the value for the question and answer in the solution result table.
//    * calls the private method and passes the parameter as solution record.
//    *
//    *  @param {object[]} value The solution result record passed as parameter.
//    *  @private
//    */
//   set questionAnsList(value) {
//     this.setAttribute('questionAnsList', value);
//     this._questionAnsList = value;
//     this.questionAns(this.questionAnsList);
//   }

//   /**
//    * internal array of the intel products for the solution record.
//    *
//    * @returns {object[]}  The internal array of solution in the version format expected by the component.
//    * @private
//    */
//   @api
//   get intelProductList() {
//     return this._intelProductList;
//   }

//   /** To set the value for the intel products in the solution result table.
//    * calls the private method.
//    *
//    *  @param {object[]} value The intel products from the solution record passed as parameter.
//    *  @private
//    *
//    */
//   set intelProductList(value) {
//     this.setAttribute('intelProductList', value);
//     this._intelProductList = value;
//     if (JSON.stringify(this.intelProductList) !== undefined) {
//       this.intelProducts(this.intelProductList);
//     }
//   }

//   /** Sets the value for Question and answer for the each field which is to be displayed to admin/partner.
//    *
//    * @param {object[]} questionAnsList array that holds the question and answer of the solution record.
//    * @private
//    */
//   questionAns(questionAnsList) {
//     if (questionAnsList != null) {
//       for (let i = 0; i < questionAnsList.length; i += 1) {
//         if (questionAnsList[i].ques !== undefined && questionAnsList[i].ques != null) {
//           if (questionAnsList[i].ans.match(urlRegularExpression)) {
//             this.answerobj.push({ value: questionAnsList[i].ans, key: questionAnsList[i].ques, isLink: true });
//           } else {
//             this.answerobj.push({ value: questionAnsList[i].ans, key: questionAnsList[i].ques, isLink: false });
//           }
//         }
//       }
//     }
//     this.ansFlag = true;
//   }

//   /** Sets the array for the intelProduct which is to be displayed as the screen.
//    *
//    * @param {object[]} intelProductList array that holds the intel products for the corresponding solution.
//    * @private
//    */
//   intelProducts(intelProductList) {
//     if (intelProductList.length > 0) {
//       this.intelProduct = true;
//     }
//   }
// }
// export default PssAnsweredSolution;