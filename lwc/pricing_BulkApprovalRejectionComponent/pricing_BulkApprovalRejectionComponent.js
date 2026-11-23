import { LightningElement, track, wire } from 'lwc';
import getWrapperClassList from '@salesforce/apex/Pricing_BulkApprovalRejectionController.getSubmittedRecords';
import processRecords from '@salesforce/apex/Pricing_BulkApprovalRejectionController.processRecords';
import getColumns from '@salesforce/apex/Pricing_BulkApprovalRejectionController.getMetadataColumns';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class Pricing_BulkApprovalRejectionComponent extends LightningElement {
    @track data;
    @track columns;
    @track sortedBy;
    @track sortedDirection;
    @track defaultSortDirection = 'asc';
    @track SortDirection = 'asc';
    @track sortedBy;
    @track disabled = true;
    @track isSpinner = false;
    resultData;

    /*connectedCallback() {
        console.log('Inside connected Callback');
        this.isSpinner = true;
        getColumns()
            .then(result => {
                this.columns = result;
                console.log(JSON.stringify(this.columns));
            })
            .catch(error => {
                console.log('Error --> ' + JSON.stringify(error));
                this.data = null;
                this.isSpinner = false
            });
        getWrapperClassList()
            .then(result => {
                this.data = result;
                console.log(JSON.stringify(this.data));
            })
            .catch(error => {
                console.log('Error --> ' + JSON.stringify(error));
                this.data = null;
                this.isSpinner = false
            });
        this.isSpinner = false;
    }*/

    @wire(getColumns)
    columnList(result) {
        this.isSpinner = true;
        console.log('Inside wire ColumnList');
        // this.columns = result;
        if (result.data) {
            this.columns = result.data;
            this.error = undefined;
        }
        else {
            this.columns = null;
            this.error = result.error;
        }
        this.isSpinner = false;
    }

    @wire(getWrapperClassList)
    wrapperClassList(result) {
        this.isSpinner = true;
        console.log('Inside wire wrapper');
        this.resultData = result;
        console.log(this.resultData);
        if (result.data) {
            this.data = result.data;
            this.error = undefined;
        }
        else {
            this.data = null;
            this.error = result.error;
        }
        this.isSpinner = false;
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = JSON.parse(JSON.stringify(this.data));
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;

    }

    sortBy(field, reverse, primer) {

        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };

    }

    handleApproveRejectAction(event) {
        this.isSpinner = true;
        var selectedRows = this.template.querySelector("lightning-datatable").getSelectedRows();
        var action = event.target.label;
        var quotelineIdList = [];
        console.log('SelectedRows' + selectedRows.length + ' : ' + JSON.stringify(selectedRows));
        console.log(action);
        if (selectedRows.length == 0) {
            const event = new ShowToastEvent({
                variant: 'Error',
                message: 'Please select Records to perform Action',
            });
            this.dispatchEvent(event);
            this.isSpinner = false;
        }
        else if (selectedRows.length > 0) {
            console.log('Inside else if');
            for (var i = 0; i < selectedRows.length; i++) {
                console.log(selectedRows[i].recordId + selectedRows[i].quoteLineNumber);
                quotelineIdList.push(selectedRows[i].recordId);
            }
            processRecords({ quoteLineIds: quotelineIdList, action: action })
                .then(result => {
                    if (result == 'Success') {
                        const event = new ShowToastEvent({
                            variant: 'Success',
                            message: 'Records Updated Successfully.',
                        });
                        this.dispatchEvent(event);
                    }
                })
                .then(_ => {
                    this.isSpinner = true;
                    console.log('refresh call Start');
                    refreshApex(this.resultData);
                    console.log('refresh call End');
                    this.isSpinner = false;
                    this.template.querySelector('lightning-datatable').maxRowSelection=0;
                    this.template.querySelector('lightning-datatable').maxRowSelection=5;
                })
                .catch(error => {
                    const event = new ShowToastEvent({
                        variant: 'Error',
                        message: 'Error updating Records.',
                    });
                    this.dispatchEvent(event);
                    console.log('Error --> ' + JSON.stringify(error));
                    this.isSpinner = false;
                });
        }

    }

    /*loadMoreData(event) {
        //Display a spinner to signal that data is being loaded
        event.target.isLoading = true;
        //Display "Loading" when more data is being loaded
        this.loadMoreStatus = 'Loading';
        fetchData(50).then((data) => {
            if (data.length >= this.totalNumberOfRows) {
                event.target.enableInfiniteLoading = false;
                this.loadMoreStatus = 'No more data to load';
            } else {
                const currentData = this.data;
                //Appends new data to the end of the table
                const newData = currentData.concat(data);
                this.data = newData;
                this.loadMoreStatus = '';
            }
            event.target.isLoading = false;
        });
    }*/
}