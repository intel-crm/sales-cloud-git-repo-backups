class pssPartnerSelectionModal extends NavigationMixin(LightningElement){}
// import {
//   LightningElement, track,
// } from 'lwc';
// import getPartners from '@salesforce/apex/PSS_PartnersOnSolution.partnersOnSolutionSearch';
// import getPermissionSet from '@salesforce/apex/PSS_PartnersOnSolution.getPermissionset';
// import getCustomLabels from '@salesforce/apex/PSS_CustomLabelsForLWC.customLabelsForParnerSelectionModel';
// import getContacts from '@salesforce/apex/PSS_PartnersOnSolution.getPartnerContacts';
// import retrievePicklistValues from '@salesforce/apex/PSS_PartnersOnSolution.getPickListValuesIntoList';
// import { NavigationMixin } from 'lightning/navigation';
// import { handleError } from 'c/ipaErrorServiceMarketplace';
// import { getAllLabels } from 'c/coreIntcLabels';

// import ipamURL from '@salesforce/label/c.PSS_Solution_URL';
// import submitLabel from '@salesforce/label/c.PMP_LeadGen_Submit';
// import cancelLabel from '@salesforce/label/c.PMP_Cancel';
// import partnerName from '@salesforce/label/c.PMP_Partner_Name';
// import partnerNameRequired from '@salesforce/label/c.PMP_Edit_Storefront_Partner_Name_Error';
// import partnerDetails from '@salesforce/label/c.PSS_Partner_Details';
// import chooseOneLabel from '@salesforce/label/c.PMP_LeadGen_ChooseOne';
// import contactNameLabel from '@salesforce/label/c.PSS_ContactName_PartnerModal';
// import contactRequiredLabel from '@salesforce/label/c.PSS_ContactRequiredLabel_PartnerModal';

// import solutionDetails from '@salesforce/label/c.PSS_Solution_Details';
// import chooseSolutionProgram from '@salesforce/label/c.PSS_Choose_Solution_ProgramValue';
// import programRequiredLabel from '@salesforce/label/c.PSS_Program_RequiredLabel';
// import partnerSolutionsLabel from '@salesforce/label/c.PSS_Partner_Solution';
// import noResultsLabel from '@salesforce/label/c.PMP_Results_No_Results_Found';

// const createEditSolution = 'create-edit-solution/';
// const createEditSolutionAdmin = 'create-edit-solution?';
// const pssCompany = '&PSS_company_Id__c=';
// const permissionSet = 'PMP_Internal_Intel_Admin';
// const pssAssignedToCon = '&ArdiraSurvey__Assigned_To_Contact__c=';
// const pssPartnerProgram = 'PSS_Solution_Category_Nm__c=';
// const rRKLabel = 'Intel RFP Ready Kits';
// const aIIPLabel = 'Intel AI: In Production';
// const mRSLabel = 'Intel Market Ready Solutions';
// const dCGLabel = 'Intel Data Center-Centric Solutions';

// /** A component used to set the parnername for Solution.
//  *
//  * This component is exposed on Submit Solution Button in Solution List View Page.
//  * coreIntcModal and coreIntcSelect are used as child components in this component.
//  *
//  * @example
//  * <!-- HTML component -->
//  * <c-pss-partner-solution-modal onclosemodal={closeModal}></c-pss-partner-solution-modal>
//  *
//  * @augments NavigationMixin
//  * @augments LightningElement
//  */
// class pssPartnerSelectionModal extends NavigationMixin(LightningElement) {
//   /** variable to store the selected PartnerName/MPI name from the picklist.
//    *
//    * @type {string}
//    * @private
//    */
//   partnerValue = '';

//   /** variable to store the selected PartnerName/MPI label from the searcbbox.
//    *
//    * @type {string}
//    * @private
//    */
//   selectedPartnerLabel = '';

//   /** variable to store the selected ContactName from the picklist.
//    *
//    * @type {string}
//    * @private
//    */
//   contactValue = '';

//   /** variable to store the url to navigate based on the logged in user permissionset.
//    *
//    * @type {string}
//    * @private
//    */
//   urlToNavigate;

//   /** variable to store the PermissionSet Name which are retrieved from apex controller
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track permissionSetName = [];

//   /**
//    * variable to store the permissionset of logged in user
//    *
//    * @type {boolean}
//    * @private
//    */
//   assignedPermissionset = false;

//   /** Variable to check whether the Partner/MPI is selected or not
//    * It returns true if the picklist value is selected.
//    *
//    * @type {boolean}
//    * @private
//    */
//   isPartnerSelected = false;

//   /** Variable to check whether the contact is selected or not
//    * It returns true if the picklist value is selected.
//    *
//    * @type {boolean}
//    * @private
//    */
//   isContactSelected = false;

//   /** variable to store the currentpage url, used for navigations.
//    *
//    * @type {string}
//    * @private
//    */
//   pageURL;

//   /** variable to store the partner data which is retrieved from the apex controller
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track partnerItems = [];

//   /** variable to store the contact data which is retrieved from the apex controller
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track contactItems = [];

//   /**
//    * varisble to load spinner when data is loading
//    *
//    * @type {boolean}
//    * @private
//    */
//   isSpinner;

//   /** variable to enable or disable the button when the partner and contact in picklist component is selected.
//    * It returns true when the picklist value is updated and the button visibility is controlled on this.
//    *
//    * @type {boolean}
//    * @private
//    */
//   isSubmitBtnDisabled = true;

//   /** variable to enable or disable the component when the Contact in picklist component is selected.
//    *
//    * @type {boolean}
//    * @private
//    */
//   isContactDisabled = true;

//   /** variable to open the modal based on conditions
//    *
//    * @type {boolean}
//    * @private
//    */
//   openModal = false;

//   /** variable to show the Partner Program based on conditions
//    *
//    * @type {boolean}
//    * @private
//    */
//   isPartnerProgram = false;

//   /**
//    * variable to disble and enable the submit button for partner program popup
//    *
//    * @type {boolean}
//    * @private
//    */
//   isPrpgramSubmitDisabled = true;

//   /**
//    * variable to store the selected partner program
//    *
//    * @type {string}
//    * @private
//    */
//   selectedProgram;

//   /**
//    * variable to store the program data retrieved from apex controller
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track programItems = [];

//   /** This variable is used to set the result value of Search apex controller
//    *
//    * @type {object[]}
//    * @private
//    */
//   @track typeaheadOptions = [];

//   /** This variable is used to set the results to zero if the search result is not found.
//    *
//    * @type {string}
//    * @private
//    */
//   noResultsFound;

//   /** variable to save keyword given in the searchbox.
//    *
//    * @type {string}
//    * @private
//    */
//   searchQuery = '';

//   /** This variable is used to set true if keyword is being searched else false.
//    * This is to set the spinner from Child component coreIntcSearch
//    *
//    * @type {boolean}
//    * @private
//    */
//   currentlySearching = false;

//   /**
//    * variable enabled if createSolution variable exists in page url.
//    *
//    * @type {boolean}
//    * @private
//    */
//   isAEMRedirection = false;

//   /**
//    * variable to enable if the redirection is from AEM else it will be false.
//    *
//    * @type {boolean}
//    * @private
//    */
//   isAEM = false;

//   /**
//    * variable to store the category name from AEM redirection.
//    *
//    * @type {string}
//    * @private
//    */
//   solutionCategoryFromAEM;

//   /** all custom labels used in the component were stored in the labels.
//    *
//    * @type {object}
//    */
//   labels = {
//     ipamURL,
//     createEditSolution,
//     createEditSolutionAdmin,
//     pssCompany,
//     submitLabel,
//     cancelLabel,
//     permissionSet,
//     partnerName,
//     partnerNameRequired,
//     partnerDetails,
//     chooseOneLabel,
//     pssAssignedToCon,
//     contactNameLabel,
//     contactRequiredLabel,
//     pssPartnerProgram,
//     solutionDetails,
//     chooseSolutionProgram,
//     programRequiredLabel,
//     rRKLabel,
//     mRSLabel,
//     aIIPLabel,
//     partnerSolutionsLabel,
//     dCGLabel,
//     noResultsLabel,
//   };

//   /**
//    * Calls the init method that will handle getting the labels and calling functions that are
//    * dependant on label values.
//    *
//    * @private
//    */
//   connectedCallback() {
//     this.init();
//   }

//   /**
//    * Async function that handles getting the labels and calling functions that are dependant on label values.
//    *
//    * @private
//    */
//   async init() {
//     await this.updateLabels();
//     this.getPermissionSetData();
//     this.getPicklist();
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
//       handleError(error, 'pssSolutionDetail - updateLabels');
//     }
//   }

//   /**
//    * method to check for the AEM page and redirect to IOTG path based on permissionsets.
//    *
//    * @private
//    */
//   aemPageRedirection() {
//     if (window.location.href.indexOf('createSolution') !== -1) {
//       this.isAEM = true;
//       this.solutionCategoryFromAEM = ((new URL(window.location.href))).searchParams.get('PSS_Solution_Category_Nm__c');
//       this.isAEMRedirection = ((new URL(window.location.href))).searchParams.get('createSolution');
//       if (this.solutionCategoryFromAEM === 'IOTG') {
//         this.selectedProgram = 'IOTG';
//       } else if (this.solutionCategoryFromAEM === 'DCG') {
//         this.selectedProgram = 'DCG';
//       } else if (this.solutionCategoryFromAEM === 'partnerSolutions') {
//         this.selectedProgram = 'Partner Solution';
//       }
//       this.isIntelAdmin();
//       if (this.assignedPermissionset) {
//         this.openModal = true;
//         this.isPartnerProgram = false;
//       } else {
//         this.openModal = false;
//         this.navigateToWebPage();
//       }
//     }
//   }

//   /** method to retrieve the picklist values from apex controller
//    *
//    * @private
//    */
//   getPicklist() {
//     retrievePicklistValues()
//       .then((result) => {
//         const picklistItems = [];
//         picklistItems.push({ label: this.labels.chooseOneLabel, value: '', Selected: this.labels.chooseOneLabel });
//         for (let i = 0; i < result.length; i += 1) {
//           if (result[i] === 'IOTG') {
//             picklistItems.push({ label: `${this.labels.mRSLabel} | ${this.labels.rRKLabel}`, value: result[i] });
//           } else if (result[i] === 'DCG') {
//             picklistItems.push({ label: this.labels.dCGLabel, value: result[i] });
//           } else if (result[i] === 'Partner Solution') {
//             picklistItems.push({ label: this.labels.partnerSolutionsLabel, value: result[i] });
//           }
//         }
//         this.programItems = picklistItems;
//       })
//       .catch((error) => {
//         handleError(error, 'pssPartnerSelectionModal - retrievePicklistValues');
//       });
//   }


//   /** method to select option from program picklist. This method will be fired when the picklist value is updated
//    *
//    * @param {event} event to get the selected value from the picklist
//    * @private
//    */
//   handleProgramChange(event) {
//     this.selectedProgram = event.target.value;
//     if (this.selectedProgram) {
//       this.isPrpgramSubmitDisabled = false;
//     } else {
//       this.isPrpgramSubmitDisabled = true;
//     }
//   }

//   /**
//    * Method to return the values of program data in the picklist component which is displayed in UI
//    *
//    * @returns {object[]} programItems
//    * @private
//    */
//   get programOptions() {
//     return this.programItems;
//   }

//   /**
//    * searches the input given in the search field in UI
//    *
//    * @param {string} Keyword The keyword is an input used from the input of the searchbox.
//    * @private
//    */
//   getPartnerData(Keyword) {
//     this.searchQuery = Keyword.trim();
//     this.currentlySearching = this.searchQuery !== '';
//     this.typeaheadOptions = [];
//     this.noResultsFound = '';
//     if (this.searchQuery) {
//       getPartners({ partnerName: Keyword })
//         .then((result) => {
//           const partnerNameItems = [];
//           if (result.length > 0) {
//             for (let i = 0; i < result.length; i += 1) {
//               partnerNameItems.push({
//                 key: `option-${i}`,
//                 idx: i,
//                 label: result[i].Name,
//                 originalLabel: result[i].Name,
//                 value: result[i].Id,
//               });
//             }

//             this.typeaheadOptions = partnerNameItems;
//           } else {
//             this.noResultsFound = this.labels.noResultsLabel;
//           }

//           this.currentlySearching = false;
//         })
//         .catch((error) => {
//           handleError(error, 'pssPartnerSelectionModal - getPartners');
//         });
//     }
//   }

//   /**
//    * Method to return all the permission sets to control the component based on permission sets.
//    *
//    * @private
//    */
//   getPermissionSetData() {
//     getPermissionSet()
//       .then((result) => {
//         for (let i = 0; i < result.length; i += 1) {
//           this.permissionSetName.push(result[i].PermissionSet.Name);
//         }
//         this.aemPageRedirection();
//         this.showModal();
//       })
//       .catch((error) => {
//         handleError(error, 'pssPartnerSelectionModal - getPermissionSet');
//       });
//   }

//   /**
//    * Method to open the modal when submit solution is clicked.
//    * Partner Slection modal is displayed only for Intel Admins.
//    *
//    * @private
//    */
//   showModal() {
//     if (!this.isAEM) {
//       this.isIntelAdmin();
//       if (this.assignedPermissionset) {
//         this.openModal = true;
//         this.isPartnerProgram = false;
//       } else {
//         this.openModal = true;
//         this.isPartnerProgram = true;
//       }
//     }
//   }

//   /**
//    * method to check if logged in user is intel admin or not
//    *
//    * @private
//    */
//   isIntelAdmin() {
//     this.assignedPermissionset = this.permissionSetName.includes(this.labels.permissionSet);
//   }

//   /**
//    * Method to close the modal when Cancel button is clicked
//    * It calls the close method of coteIntcModal's close method.
//    *
//    * @private
//    */
//   closeModal() {
//     this.openModal = false;
//     this.dispatchEvent(new CustomEvent('closemodal'));
//     this.template.querySelector('c-core-intc-modal').closeModal();
//   }

//   /**
//    * When the patner is selected from the picklist component,
//    * redirects Partner Program picklist modal.
//    *
//    * @private
//    */
//   onSubmit() {
//     if (this.isAEMRedirection) {
//       this.isPartnerProgram = false;
//       this.navigateToWebPage();
//       this.template.querySelector('c-core-intc-modal').closeModal();
//       this.openModal = false;
//     } else {
//       this.isPartnerProgram = true;
//       this.getPicklist();
//     }
//   }

//   /**
//    * when the patner is selected from the picklist component, redirects to create edit solution page.
//    *
//    * @private
//    */
//   onPartnerSubmission() {
//     this.navigateToWebPage();
//     this.isPartnerProgram = false;
//     this.template.querySelector('c-core-intc-modal').closeModal();
//     this.openModal = false;
//   }

//   /** Method to close the modal when inverse button of modal is clicked
//    *
//    * @private
//    */
//   closePartnerModal() {
//     this.openModal = false;
//     this.dispatchEvent(new CustomEvent('closemodal'));
//   }

//   /**
//    * method to get all the Contact records from the apex controller,
//    * and store the values as contactItems in a picklist component on the UI.
//    *
//    * @private
//    */
//   getContactData() {
//     this.isSpinner = true;
//     this.isContactDisabled = true;
//     getContacts({ companyId: this.partnerValue })
//       .then((result) => {
//         const contactNameItems = [];
//         contactNameItems.push({ label: this.labels.chooseOneLabel, value: '', Selected: this.labels.chooseOneLabel });

//         if (result.length > 0) {
//           for (let i = 0; i < result.length; i += 1) {
//             contactNameItems.push({ label: result[i].Name, value: result[i].Id });
//           }
//         }
//         this.contactItems = contactNameItems;
//         this.isSpinner = false;
//       })
//       .catch((error) => {
//         handleError(error, 'pssPartnerSelectionModal - getContacts');
//       });
//   }

//   /**
//    * Method to return the values of Contact data in the picklist component which is displayed in UI
//    *
//    * @returns {object[]} contactItems
//    * @private
//    */
//   get contactOptions() {
//     return this.contactItems;
//   }

//   /** method to select option from contact picklist. This method will be fired when the picklist value is updated
//    * to store the selected value from the picklist.
//    *
//    * @param {event} event to get the selected value from the picklist
//    * @private
//    */
//   handleContactChange(event) {
//     this.contactValue = event.target.value;
//     if (this.contactValue) {
//     this.isContactSelected = true;
//     } else {
//       this.isContactSelected = false;
//     }
//     this.isSubmitDisabled();
//   }

//   /** disable submit button if any of the component on modal is not selected
//    *
//    * @private
//    */
//   isSubmitDisabled() {
//     if (this.isPartnerSelected === true && this.isContactSelected === true) {
//       this.isSubmitBtnDisabled = false;
//     } else {
//       this.isSubmitBtnDisabled = true;
//     }
//   }

//   /**
//    * method to navigate to create edit solution page
//    *
//    * @private
//    */
//   navigateToWebPage() {
//     // Navigate to a URL
//     let url = '';
//     this.pageURL = window.location.origin;
//     this.isIntelAdmin();

//     if (this.assignedPermissionset) {
//       url = this.pageURL + this.labels.ipamURL + this.labels.createEditSolutionAdmin
//             + this.labels.pssPartnerProgram + this.selectedProgram + this.labels.pssCompany + this.partnerValue
//             + this.labels.pssAssignedToCon + this.contactValue;
//     } else {
//       url = this.pageURL + this.labels.ipamURL + this.labels.createEditSolutionAdmin + this.labels.pssPartnerProgram + this.selectedProgram;
//     }

//     this[NavigationMixin.Navigate]({
//       type: 'standard__webPage',
//       attributes: {
//         url,
//       },
//     },
//     true);// Replaces the current page in your browser history with the URL
//   }

//   /**
//    * handles search input - finished typing
//    *
//    * @param {event} event finished typing event from Searchbox
//    * @private
//    */
//   handleFinishedTyping(event) {
//     const keyWordVal = event.detail.keywordValue.trim();
//     event.stopPropagation();
//     if (keyWordVal.length > 2) {
//       this.getPartnerData(keyWordVal);
//     } else {
//       this.typeaheadOptions = [];
//       this.getContactData();
//       this.isContactDisabled = true;
//       this.noResultsFound = '';
//       this.isSubmitBtnDisabled = true;
//     }
//   }

//   /**
//    * Method to clear search string from SearchBox
//    *
//    * @param {event} event The event fired when clear button is clicked in searchbox.
//    * @private
//    */
//   handleClearKeyword(event) {
//     event.stopPropagation();
//     this.currentlySearching = false;
//     this.typeaheadOptions = [];
//     this.noResultsFound = '';
//     this.getContactData();
//     this.isContactDisabled = true;
//     this.isSubmitBtnDisabled = true;
//     this.isContactSelected = false;
//   }

//   /**
//    * handles typeahead option selected.
//    *
//    * @param {event} event selected option event from Searchbox.
//    * @private
//    */
//   handleSelectedOption(event) {
//     event.stopPropagation();
//     const { optionValue } = event.detail;
//     if (this.searchQuery.length !== 0) {
//       this.partnerValue = optionValue;
//       this.isPartnerSelected = true;
//       this.isContactDisabled = true;
//       this.contactItems = [];
//       this.getContactData();
//       this.isContactDisabled = false;
//       this.isSubmitDisabled();
//     }
//   }
// }

// export default pssPartnerSelectionModal;