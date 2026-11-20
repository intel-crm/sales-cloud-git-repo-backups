import { LightningElement, track, api, wire } from 'lwc';
import getRelatedDuplicates from '@salesforce/apex/PCC_Deal_FindRelatedDuplicateDeals.getRelatedDuplicates';
import { getRecord } from "lightning/uiRecordApi";

import RECORDTYPE from '@salesforce/schema/Core_Design_Registration__c.RecordTypeId';
const DEAL_COLUMN = [
    {
        label: 'Related Duplicate', fieldName: 'duplicateUrl', type: 'url', initialWidth: 200, wrapText: true, typeAttributes: { label: { fieldName: "duplicateDealName" }, tooltip: "duplicateDealName", target: "_blank" }
    },
    {
        label: 'Project Name', fieldName: 'projectName', type: 'Text', wrapText: true, initialWidth: 300
    },
    {
        label: 'Match Probability', wrapText: true, fieldName: 'percentage', type: 'percent', typeAttributes: { step: '0.01' }
    },

    {
        label: 'Object Type', wrapText: true, fieldName: 'objectType', type: 'Text'
    },
]

export default class ShowDuplicateDeals extends LightningElement {
    @track gridColumns;
    @api recordId;
    @track data;
    @track hasData = false;
    @track gridData;
    @track loaded = false;
    @track title = 'Potential Duplicates';

    //pagination
    // Pagination properties
    @track pageSize = 10; // Number of records per page
    @track currentPage = 1; // Current page number

    // Total number of records (assuming all records are fetched at once)
    @track totalRecords;

    // Calculate total number of pages
    get totalPages() {
        return Math.ceil(this.totalRecords / this.pageSize);
    }

    // Calculate start index of records to display on current page
    get startIndex() {
        return (this.currentPage - 1) * this.pageSize;
    }


    get prevDisabled() {
        return this.currentPage === 1
    }

    get nextDisabled() {
        return this.currentPage === this.totalPages;
    }

    // Calculate end index of records to display on current page
    get endIndex() {
        return Math.min(this.startIndex + this.pageSize - 1, this.totalRecords - 1);
    }
    //END pagination

    // get recordType details

    @wire(getRecord, { recordId: "$recordId", fields: [RECORDTYPE] })
    recordTypeDetails({ data, error }) {

        if (data) {
            const newColumns = [...DEAL_COLUMN];
            if (data.recordTypeInfo.name.includes('Design')) {
                newColumns.push({
                    label: 'Owner', fieldName: 'ownerId', type: 'url', initialWidth: 200, wrapText: true, typeAttributes: { label: { fieldName: "ownerName" }, tooltip: "ownerName", target: "_blank" }
                });
            }
            this.gridColumns = newColumns;

        }
        if (error) {
            console.log('error deal -->', error);
        }
    }



    getRelatedDuplicatesMethod() {
        getRelatedDuplicates({ recordId: this.recordId })
            .then(result => {

                let tmp = [];
                this.totalRecords = result.length; // Set total number of records
                this.hasData = result.length > 0 ? true : false;
                if (!this.title.includes(this.totalRecords)) {
                    this.title += ' (' + this.totalRecords + ')';
                }

                result.map((item) => {

                    let ddrtemp = {};
                    ddrtemp.url = '/' + item?.drId;
                    ddrtemp.duplicateUrl = '/' + item?.duplicateDealId;
                    ddrtemp.drName = item?.drName;
                    ddrtemp.duplicateDealName = item?.duplicateDealName;
                    ddrtemp.percentage = item?.percentage / 100;
                    ddrtemp.objectType = item?.objectType;
                    ddrtemp.projectName = item?.projectName;
                    ddrtemp.ownerId = item?.ownerId ? '/' + item?.ownerId : '';
                    ddrtemp.ownerName = item?.ownerName;
                    ddrtemp.matchType = item?.percentage >= 100 ? 'Exact Match' : 'Partial Match';
                    tmp.push(ddrtemp);
                })
                this.data = tmp;
                this.gridData = this.data;
                this.loaded = true;
                this.handleSortByPercentage();
                this.gridData = this.data.slice(this.startIndex, this.endIndex + 1);
            })
            .catch(error => {
                this.loaded = true;
                console.log('Error -->', error);
            })
    }

    connectedCallback() {

        console.log('Data1 -->', this.data);
        if (this.recordId !== null && this.recordId !== undefined && this.recordId.length > 0) {
            this.getRelatedDuplicatesMethod();
        }
    }
    // Method to sort the data by percentage
    sortByPercentage() {
        // Clone the array to avoid mutating the original data
        let sortedData = [...this.data];
        // Custom comparator function to sort by percentage
        sortedData.sort((b, a) => {
            return a.percentage - b.percentage;
        });
        // Update the data with the sorted array
        this.data = sortedData;
    }

    // Method to handle sorting based on percentage column
    handleSortByPercentage() {
        // Call the method to sort by percentage
        this.sortByPercentage();
    }

    // Method to handle previous page button click
    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.getRelatedDuplicatesMethod();
        }
    }

    // Method to handle next page button click
    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.getRelatedDuplicatesMethod();
        }
    }

}