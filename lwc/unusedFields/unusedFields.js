import { LightningElement, track, wire, api } from 'lwc';
import getUnsedFields from '@salesforce/apex/Tooling_CustomFieldsCntrl.getUnusedFields';

import getCustomFieldIds from '@salesforce/apex/Tooling_CustomFieldsCntrl.getCustomFieldIds';


const columns = [
    { label: 'Object Name', fieldName: 'ObjectName', sortable: true }, {
        label: 'Field Name', fieldName: 'fieldURL', type: "url", target: "_blank", typeAttributes:
            { label: { fieldName: 'FieldName' } }
    }];

export default class UnusedFields extends LightningElement {
    @track pagesize =10;
    @track sortedDirection = 'asc';
    @track sortedBy;

    @api objectApiName = 'Account';
    columns = columns;
    @track hasData = false;
    @track loading = true;
    @track data = [];
    @track count = 0;
    @track _mapChildRelationships2FieldNames = [];
    @track _mapChildRelationshipsNames = [];
    @track noBatches = 0;

    prevBtnLbl = 'Prev';
    nextBtnLbl = 'Next';

    @track tableData = [];
    @track loadMore = true;
    @track loadPrev = false;
    @track currentpage=1;
    @track noOfPages =1;

   
    async findUnsedField(setOfIds) {
        await getUnsedFields({ fieldIds: setOfIds }).then(result => {
            if (result) {

                let resultData = JSON.parse(JSON.stringify(result));
                resultData.map(item => {
                    this.data.push(item);
                });

                const copy = [];
                this.data.map(item => {
                    if (item.ObjectName != null) {
                        copy.push(item);
                    }

                });
                this.data = copy;
                if (this.data.length > 0) {
                    this.count = this.data.length;
                    this.hasData = true;
                    this.loading = false;
                } else {
                    this.hasData = false;
                    this.loading = false;
                }
                this.noOfPages =Math.ceil(this.data.length/this.pagesize);
                this.getCurrentPageRecords();
            } else {
                this.loading = false;
                console.log('No Unsed custom fields found!');
            }

        }).catch(error => { this.loading = false; console.log("error -->", error); });
        
    }


    async connectedCallback() {
        await getCustomFieldIds().then(result => {
            if (result) {
                this.noBatches = Math.ceil(result.length / 200);
                let counter = 1;
                let start = 0;
                let end = 200;
                while (counter <= this.noBatches) {
                    this.findUnsedField(result.slice(start, end));
                    this.progressPercentage = (counter / this.noBatches) * 100;
                    this.allrecordProcessed = this.progressPercentage === 100 ? true : false;
                    counter++;
                    start = end + 1;
                    end = 200 * counter;
                }

            } else {
                this.loading = false;
                console.log('No custom fields returned!');
            }
        }).catch(error => { this.loading = false; })


    }

    updateColumnSorting(event) {
        var fieldName = event.detail.fieldName
        var sortDirection = event.detail.sortDirection;
        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.sortedBy = fieldName;
        this.sortData('', sortDirection);
        this.sortedDirection = sortDirection;// === 'asc' ? 'desc' : 'asc';
    }


    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        this.data = [];
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        this.data = [...parseData];

    }

    handleNext() {
        if (this.currentpage < this.noOfPages) {
            this.currentpage += 1;
            this.getCurrentPageRecords();
        }
    }

    handlePrevious() {
        if (this.currentpage >= this.noOfPages || this.currentpage > 1) {
            this.currentpage -= 1;
            this.getCurrentPageRecords();
        }

    }

    getCurrentPageRecords() {
        this.tableData = [];
        let start = parseInt((this.currentpage - 1) * this.pagesize);
        let end = parseInt(start) + parseInt(this.pagesize);
        this.tableData = this.data.slice(start, end);
        this.loadMore = (this.currentpage > 1 && this.noOfPages <= this.currentpage) ? true : false;
        this.loadPrev = (this.currentpage === 1) ? true : false;
        this.showingOfTotal = (this.currentpage === this.noOfPages) ? this.data.length : this.currentpage * this.pagesize;
    }
}