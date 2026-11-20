class PssCreateProposalButton extends LightningElement{}
// import { LightningElement, wire } from 'lwc';

// import submitButtonLabel from '@salesforce/label/c.PSS_Submit_Solution';
// import { handleError } from 'c/ipaErrorServiceMarketplace';
// import { getAllLabels } from 'c/coreIntcLabels';

// import { CurrentPageReference } from 'lightning/navigation';

// // apex class
// import getSoulutionButtonVisibility from '@salesforce/apex/PSS_PartnersOnSolution.getSoulutionButtonVisibility';
// import getCustomLabels from '@salesforce/apex/PSS_CustomLabelsForLWC.customLabelsForSolListViewPage';


// /** The component is used to show the submit a solution button in the list view.
//  *
//  *  @example
//  * <!-- HTML component -->
//  * <c-pss-create-proposal-button></c-pss-create-proposal-button>
//  *
//  *@augments LightningElement
//  */
// class PssCreateProposalButton extends LightningElement {
//   /**
//    * Custom Label:
//    * submitButtonLabel-PSS_Solution_Submit
//    *
//    * @type {object}
//    * @private
//    */
//   labels = {
//     submitButtonLabel,
//   }

//   /**
//    * Boolean to show the button visibility in the list view page
//    *
//    * @type {boolean}
//    * @private
//    */
//   showSolutionButton;

//   /**
//    * To get the current page parameters
//    *
//    * @param {object} CurrentPageReference featching current page parameters
//    * @private
//    */
//   @wire(CurrentPageReference)
//   currentPageReference;

//   /**
//    * Method to get the boolean value from the class
//    * and render the button on the list view screen
//    *
//    * @private
//    */
//   connectedCallback() {
//     this.init();
//     getSoulutionButtonVisibility()
//       .then((result) => {
//         this.showSolutionButton = result;
//         const autoCreateSolution = this.currentPageReference.state.createSolution;
//         if (this.showSolutionButton && autoCreateSolution) {
//           this.handleClick();
//         }
//       })
//       .catch((error) => {
//         handleError(error, 'pssCreateProposalButton - buttonVisibility');
//       });
//   }

//   /**
//    * Async function that handles getting the labels and calling functions that are dependant on label values.
//    *
//    * @private
//    */
//   async init() {
//     await this.updateLabels();
//   }

//   /**
//    * Calls the imported method to update the label values.
//    *
//    * @private
//    */
//   async updateLabels() {
//     try {
//       // This call uses the default validation logic
//       this.labels = await getAllLabels(this.labels, getCustomLabels);
//     } catch (error) {
//       handleError(error, 'pssCreateProposalButton - updateLabels');
//     }
//   }

//   /** Boolean to show whether the modal popup should be shown or not.
//    *
//    * @type {boolean}
//    * @private
//    */
//   openModal;

//   /** When submit a solution button is clicked a popup will open with
//    * all the location accounts in the system.
//    *
//    * @private
//    *
//    */
//   handleClick() {
//     this.openModal = true;
//   }

//   /**
//    * Method to close the popup when click on cancel or close buttom
//    *
//    * @private
//    *
//    */
//   closeModal() {
//     this.openModal = false;
//   }
// }
// export default PssCreateProposalButton;