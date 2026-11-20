import { LightningElement, api, track } from 'lwc';

export default class Core_IPS_ModelToViewDatatableUtility extends LightningElement {
    @api modalTitle;
    @api modalHideCheckboxColumn;
    @api modalShowRowNumberColumn;
    @api modalEnableInfiniteLoading;
    @api modalNumAndCheckboxBothCols;
    @api modalNormalDataTable;
    @api records;
    @api columns;
    @api modalNumberOfRowsToShow;
    @api modalTableHeightInRem;
    @api modalTablePreSelectedRows;
    @api messageText1;
    @api messageText2;

    @api isPrevBtnRequired;

    @track messageText1Present = false;
    @track messageText2Present = false;

    connectedCallback() {
        if(this.records === undefined || this.records === null || (this.records !== undefined && this.records !== null && this.records.length === 0)) {
            this.messageText1Present = true;
        }
    }
    
    saveHandler() {
        const handleRowActionsEvent = new CustomEvent("submitclick", {});
        this.dispatchEvent(handleRowActionsEvent);
    }

    closeModal() {
        const handleRowActionsEvent = new CustomEvent("closemodal", {});
        this.dispatchEvent(handleRowActionsEvent);
    }

    prevHandler() {
        const handleRowActionsEvent = new CustomEvent("prevclick", {});
        this.dispatchEvent(handleRowActionsEvent);
    }

    getSelectedRecords(event) {
        if(event.detail.selectedRows.length > 0) {
            this.messageText1Present = false;
        } else {
            this.messageText1Present = true;
        }
    }
}