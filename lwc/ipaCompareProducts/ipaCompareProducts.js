import { LightningElement } from 'lwc';
class IpaCompareProducts extends LightningElement {}
// import ipaCompareTrayService from 'c/ipaCompareTrayService';
// import { handleError } from 'c/ipaErrorServiceMarketplace';
// import labels from './labels';
// import getdata from './formatData';

// /**
//  * UI Component for Compare Products page
//  *
//  * @augments {LightningElement}
//  */
// class IpaCompareProducts extends LightningElement {
//     /**
//      * Data object for compare table
//      *
//      * @type {object[]}
//      * @private
//      */
//     data = [];

//     /**
//      * Array of offering cards to be compared (max 4).
//      * If less than 4 cards being compared, will contain one
//      * placeholder card.
//      *
//      * @type {object[]}
//      * @private
//      */
//     cards = [];

//     /**
//      * Array of partner contact data for product cards.
//      *
//      * @type {object[]}
//      * @private
//      */
//     contactPartnerData = [];

//     /**
//      * Custom labels
//      *
//      * @type {object}
//      * @private
//      */
//     labels = labels;

//     /**
//      * Indicates if page is loading
//      *
//      * @type {boolean}
//      * @private
//      */
//     loading;

//     /**
//      * Indicates if compare warning should be displayed
//      *
//      * @type {boolean}
//      * @private
//      */
//     showWarning = false;

//     /**
//      * Indicates if detailed product card view is being displayed
//      *
//      * @type {boolean}
//      * @private
//      */
//     showMoreCards = false;

//     /**
//      * Add utility icon name for cards
//      *
//      * @type {string}
//      * @private
//      */
//     addIconName = 'utility:add';

//     /**
//      * Close utility icon name for cards
//      *
//      * @type {string}
//      * @private
//      */
//     closeIconName = 'utility:close';

//     /**
//      * Highlight utility icon
//      *
//      * @type {string}
//      * @private
//      */
//     highlightIconName = 'utility:macros';

//     /**
//      * Indicates whether highlight checkbox is checked
//      *
//      * @type {boolean}
//      * @private
//      */
//     checked = true;

//     /**
//      * Handles toggling highlight differences
//      *
//      * @private
//      */
//     handleHighlight() {
//       this.checked = !this.checked;
//     }

//     /**
//      * Handles toggling highlight differences using keys
//      *
//      * @param {event} evt onkeydown event
//      * @private
//      */
//     handleHighlightAccessibility(evt) {
//       if (evt.code === 'Enter') this.handleHighlight();
//     }

//     /**
//      * Handles toggling detailed card mobile view
//      *
//      * @private
//      */
//     handleShowMoreCards() {
//       this.showMoreCards = !this.showMoreCards;
//     }

//     /**
//      * Handles removing a card from the compare table and compare tray
//      *
//      * @param {event} evt click event
//      * @private
//      */
//     handleRemoveCard(evt) {
//       if (this.cards.length > 1) {
//         const { id } = evt.currentTarget.dataset;
//         ipaCompareTrayService.toggleItem({ id });
//         this.retrieveTableData(this.cards);
//       }

//       this.showWarning = this.cards.length < 2;
//     }

//     /**
//      * Handles removing a card from the compare table and compare tray using keys
//      *
//      * @param {event} evt onkeydown event
//      * @private
//      */
//     handleRemoveCardAccessibility(evt) {
//       if (evt.code === 'Enter') this.handleRemoveCard(evt);
//     }

//     /**
//      * Handles clicking the back button.
//      *
//      * @private
//      */
//     handleBackButton() {
//       window.history.back();
//     }

//     /**
//      * Connected callback - retrieves compare table data
//      *
//      * @private
//      */
//     connectedCallback() {
//       this.loading = true;
//       this.subscription = ipaCompareTrayService.subscribe(({ items }) => {
//         this.cards = Object.values(items).map((item) => ({
//           ...item,
//           removeAriaLabel: labels.PMP_CompareTable_RemoveItem.replace('{0}', item.title),
//         }));
//         this.showWarning = this.cards.length < 2;
//       });
//       this.retrieveTableData(this.cards);
//     }

//     /**
//      * Disconnected callback
//      * removes subscription
//      *
//      * @private
//      */
//     disconnectedCallback() {
//       if (this.subscription) {
//         this.subscription();
//       }
//     }

//     /**
//      * Retrieves product data for populating compare table
//      *
//      * @param {string[]} productIds array of compare product ids
//      * @private
//      */
//     retrieveTableData(productIds) {
//       this.loading = true;
//       getdata(productIds).then(
//         (response) => {
//           this.contactPartnerData = response.contactPartnerData;
//           this.data = response.tableData;
//           this.loading = false;
//         },
//       ).catch(
//         (error) => { handleError(error, 'ipaCompareProducts - retrieveTableData', 'console'); },
//       );
//     }

//     /**
//      * Returns formatted array of product cards (with placeholder card)
//      *
//      * @returns {object[]} formatted cards
//      * @private
//      */
//     get formatCards() {
//       const categoryId = this.cards.length ? this.cards[0].compareCategoryId : '';
//       const formattedCards = this.cards.map((card, idx) => ({
//         ...card,
//         contactPartnerData: this.contactPartnerData[idx] || {},
//       }));
//       while (formattedCards.length < 4) {
//         formattedCards.push({
//           compareCategoryId: categoryId,
//           id: '',
//           imageUrl: '',
//           removeAriaLabel: labels.PMP_CompareTable_AddItem,
//           title: '',
//         });
//       }
//       return formattedCards;
//     }
// }
// export default IpaCompareProducts;