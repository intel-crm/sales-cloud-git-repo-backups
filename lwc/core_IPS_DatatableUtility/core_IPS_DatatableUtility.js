import { LightningElement, api, track } from 'lwc';
import getQueryResult from '@salesforce/apex/Core_IPS_NewMapHomePageController.getQueryResult';

export default class Core_IPS_DatatableUtility extends LightningElement {
    @api hideCheckboxColumn;
    @api showRowNumberColumn;
    @api numAndCheckboxBothCols;
    @api normalDataTable;
    @api enableInfiniteLoading;
    @api records;
    @api queryString;
    @api columns;
    @api numberOfRowsToShow;
    @api heightInRem;
    @api selectedRows;

    @track rowsToShow = [];

    offset = 0;
    addMoreDataCounter = true;
    dataTableHeightStyle;

    connectedCallback() {
        console.log('Core_IPS_DatatableUtility ::: connectedCallback called');
        if (this.heightInRem !== undefined && this.heightInRem !== null) {
            this.dataTableHeightStyle = "height: " + this.heightInRem + "rem";
        } else {
            this.dataTableHeightStyle = "height: 10rem";
        }
        if (this.numAndCheckboxBothCols) {
            this.hideCheckboxColumn = false;
            this.showRowNumberColumn = false;
        }
        if (this.normalDataTable) {
            this.numAndCheckboxBothCols = false;
            this.hideCheckboxColumn = false;
            this.showRowNumberColumn = false;
        }
        if (this.queryString !== undefined && this.queryString !== null && this.records !== undefined && this.records !== null) {
            getQueryResult({ queryString: this.queryString })
                .then(result => {
                    if (result) {
                        this.records = result;
                    }
                })
                .catch(error => {
                    console.error('Core_IPS_DatatableUtility : Error loading records in data table. Error : ', JSON.stringify(error));
                })
        }
        if (this.records !== undefined && this.records !== null) {
            if (this.numberOfRowsToShow === undefined || this.numberOfRowsToShow === null) {
                this.numberOfRowsToShow = this.records.length;
            }
            this.initialDisplay();
        }
    }

    initialDisplay() {
        let newData = [];

        for (let i = this.offset; i < this.offset + parseInt(this.numberOfRowsToShow, Number); i++) {
            if (i < this.records.length) {
                newData.push(this.records[i]);
            } else {
                this.addMoreDataCounter = false;
                break;
            }
        }
        this.offset += parseInt(this.numberOfRowsToShow, Number);
        this.rowsToShow = [...this.rowsToShow, ...newData];
    }

    onLoadMoreHandler() {
        this.addMoreData();

        if (this.addMoreDataCounter === false) {
            this.enableInfiniteLoading = false;
        }
    }

    addMoreData() {
        let newData = [];

        for (let i = this.offset; i < this.offset + parseInt(this.numberOfRowsToShow, Number); i++) {
            if (i < this.records.length) {
                newData.push(this.records[i]);
            } else {
                this.addMoreDataCounter = false;
                break;
            }
        }
        this.offset += parseInt(this.numberOfRowsToShow, Number);
        this.rowsToShow = [...this.rowsToShow, ...newData];
    }

    getSelectedRecords(event) {
        const selectedRecordEvent = new CustomEvent("recordselection", {
            bubbles: true,
            composed: true,
            detail: {
                selectedRows: event.detail.selectedRows,

            }
        });
        this.dispatchEvent(selectedRecordEvent);
    }

    handleRowActions(event) {
        const handleRowActionsEvent = new CustomEvent("rowactions", {
            detail: {
                actionName: event.detail.action.name,
                row: event.detail.row
            }

        });
        this.dispatchEvent(handleRowActionsEvent);
    }
}