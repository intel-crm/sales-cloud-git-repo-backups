// IPA2.0 + US TWC4497-1631
// import { LightningElement, track, wire } from 'lwc';
// import getOferings from '@salesforce/apex/PMP_OfferingListController.offeringOnSearch';
// const DELAY = 300;

// export default class OfferingSearchBox extends LightningElement {

//     @track search = '';
//     @track error;
//     @track selectedOffering;
//     @track showOfferingListFlag = false;
//     @wire(getOferings, { searchKey: '$search' })
//     offerings;
//     handleKeyUp(event) {
//         if (!this.showOfferingListFlag) {    
//             this.showOfferingListFlag = true;
//             this.template
//                 .querySelector('.offerings_list')
//                 .classList.remove('slds-hide');
//         }
//         window.clearTimeout(this.delayTimeout);
//         const searchKey = event.target.value;
//         // eslint-disable-next-line @lwc/lwc/no-async-operation
//         this.delayTimeout = setTimeout(() => {
//             this.search = searchKey;
//         }, DELAY);
//     }
//     handleOptionSelect(event) {
//         this.selectedOffering = event.currentTarget.dataset.name;
//         this.template
//             .querySelector('.selectedOption')
//             .classList.remove('slds-hide');
//         this.template
//             .querySelector('.offerings_list')
//             .classList.add('slds-hide');
//         this.template
//             .querySelector('.slds-combobox__form-element')
//             .classList.add('slds-input-has-border_padding');
//     }
//     handleRemoveSelectedOption() {
//         this.template
//             .querySelector('.selectedOption')
//             .classList.add('slds-hide');
//         this.template
//             .querySelector('.slds-combobox__form-element')
//             .classList.remove('slds-input-has-border_padding');

//         this.showOfferingListFlag = false;
//     }
// }