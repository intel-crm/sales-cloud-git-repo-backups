import { LightningElement, api } from 'lwc';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 500;

export default class Core_MDF_CustomGenericLookup extends LightningElement {
    @api helpText = "helptext";
    @api showHelpText = false;
    @api label = "label";
    @api required;
    @api selectedIconName = "standard:account";
    @api objectLabel = "object label";
    @api objectApiName = "object api name";
    @api fieldApiName = "field api name";
    @api searchString = "";
    @api selectedRecordId;
    @api selectedRecordName;
    @api placeholder = "";
    // Format of records refer: Class: Core_MDF_CCP_GenericUtility -> Wrapper Class: CustomGenericLookupRecordsWrapper
    // [{
    //     "id": "",
    //     "mainField": "",
    //     "subField": "",
    // }]
    @api records = [];
    @api getDefaultLookupValue = false;

    inputValid = false;
    nonSelectionError = false;
    preventClosingOfSerachPanel = false;
    lookupFieldReference;

    get methodInput() {
        return this.searchString;
    }

    get showRecentRecords() {
        if (!this.records) {
            return false;
        }
        return this.records.length > 0;
    }

    //getting the default selected record
    connectedCallback() {
        if (this.selectedRecordId || this.getDefaultLookupValue) {
            this.fetchSobjectRecords(true);
        }
    }

    //call the apex method
    fetchSobjectRecords(setDefaultRecord) {
        // Creates the event
        const fetchRecordsEvent = new CustomEvent('getrecordsforgenericlookup', {
            detail: {
                searchKey: this.searchString,
                searchId: this.selectedRecordId,
                setDefaultRecord: setDefaultRecord,
                lookupFieldReference: this.lookupFieldReference
            }
        });
        //dispatching the custom event
        this.dispatchEvent(fetchRecordsEvent);
    }

    get isValueSelected() {
        return this.selectedRecordId;
    }

    @api
    isValid() {
        if (this.required && (!this.selectedRecordId || this.selectedRecordId == '')) {
            this.inputValid = false;
            return this.inputValid; // Return false if the required input is empty
        } else {
            this.inputValid = true;
        }
        return true;
    }

    @api
    reportInputValidity() {
        const inputElement = this.template.querySelector('lightning-input');
        if (inputElement) {
            inputElement.reportValidity();
        }
    }

    //handler for calling apex when user change the value in lookup
    handleChange(event) {
        this.searchString = event.target.value;
        this.lookupFieldReference = event.target.name;
        this.fetchSobjectRecords(false);
    }

    //handler for clicking outside the selection panel
    handleBlur() {
        this.records = [];
        this.preventClosingOfSerachPanel = false;
    }

    //handle the click inside the search panel to prevent it getting closed
    handleDivClick() {
        this.preventClosingOfSerachPanel = true;
    }

    //handler for deselection of the selected item
    handleCommit() {
        this.selectedRecordId = "";
        this.selectedRecordName = "";
        this.nonSelectionError = false;
    }

    //handler for selection of records from lookup result list
    handleSelect(event) {
        this.selectedRecordId = event.currentTarget.dataset.id;
        this.selectedRecordName = event.currentTarget.dataset.mainfield;
        this.records = [];
        // Creates the event
        const selectedEvent = new CustomEvent('valueselected', {
            detail: {
                selectedRecordId: event.currentTarget.dataset.id,
                lookupFieldReference: this.lookupFieldReference
            }
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
    }

    //to close the search panel when clicked outside of search input
    handleInputBlur(event) {
        // Debouncing this method: Do not actually invoke the Apex call as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            if (!this.preventClosingOfSerachPanel) {
                this.records = [];
            }
            this.preventClosingOfSerachPanel = false;
        }, DELAY);
        if (this.searchString != '' && (this.selectedRecordName == '' || this.selectedRecordName == null || this.selectedRecordName == undefined)) {
            this.nonSelectionError = true;
            this.inputValid = false;
        } else {
            this.nonSelectionError = false;
            this.inputValid = true;
        }
    }

}