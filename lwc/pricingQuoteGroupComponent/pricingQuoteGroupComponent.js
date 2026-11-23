import { LightningElement, api, track, wire } from 'lwc';
import getMetadataColumns from '@salesforce/apex/Pricing_LinkQuotesController.getMetadataColumns';
import getQuoteGroupLinkStatus from '@salesforce/apex/Pricing_LinkQuotesController.getQuoteGroupLinkStatus';
import getQuoteGroup from '@salesforce/apex/Pricing_LinkQuotesController.getQuoteGroup';
import isReadOnlyUser from '@salesforce/apex/Pricing_LinkQuotesController.isReadOnlyUser';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import pricingPubSub from 'c/pricingPubSub';

export default class PricingQuoteGroupComponent extends LightningElement {
    @api recordId;
    @track resultList;
    @track quoteGroupList;
    @track dataTableColumns;
    @track errorMsg = '';
    @track sortBy;
    @track defaultSortDirection = 'asc';
    @track sortDirection;
    @track buttonTitle = 'Link Quote';
    @track showLinkComp = false;
    @track isDPMLegalFinanceUser = false;
    @track currentPageNumber;
    @track totalPages;
    @track totalNoOfRecords;
    @track recordsPerPage = 5;
    @track iterationStarting;
    @track iterationEnding;
    @track disablePagination = false;

    connectedCallback() {
        /*Registering the showQuoteLink event fired from pricingLinkQuotesComponent 
        and calling the showQuoteLink event handler*/
        isReadOnlyUser()
        .then((result) => {
            this.isDPMLegalFinanceUser = result;
        })
        .catch((error) => {
            console.log('Error is', this.error); 
        });
        pricingPubSub.register('showQuoteLink', this.showQuoteLink.bind(this));
    }

    @wire(getQuoteGroupLinkStatus, { quoteId: '$recordId' })
    Values({ error, data }) {
        getRecordNotifyChange([{ recordId: this.recordId }]);
        if (data) {
            this.buttonTitle = 'Manage Quote Group'; //Changing the button title if the Quote(s) are already linked to a Quote Group
            this.columnsClassification = 'Quote Group';
            this.getDataTableGrid();
            this.getQuoteGroupDtls();
        } else if (data == false) {
            this.buttonTitle = 'Link Quote';
            this.columnsClassification = 'Quote Group';
            this.disablePagination = true;
            this.currentPageNumber = this.totalPages = this.totalNoOfRecords = 0;
            this.getDataTableGrid();
        } else if (error) {
            console.log('error==>', JSON.stringify(error));
        }
    }

    showQuoteLink(showComp, closeModal) {
        console.log('Event called====');
        if (showComp == true && closeModal == true) { //if code block to display grid with Quote(s) and Quote Group on Link Quote button click
            this.buttonTitle = 'Manage Quote Group';
            this.getQuoteGroupDtls();
            this.showLinkComp = false;
        }
        else if (showComp == false && closeModal == true) { /*else if code block to display grid without any records when we 
                                                            select all the Quotes and click on Remove Link Quote button*/
            this.buttonTitle = 'Link Quote';
            this.quoteGroupList = '';
            this.disablePagination = true;
            this.currentPageNumber = this.totalPages = this.totalNoOfRecords = 0;
            this.resultList = '';
            this.getDataTableGrid();
            this.showLinkComp = false;
        }
        else if (showComp == true && closeModal == false) { /*else if code block to display grid with Quote(s) and Quote Group 
                                                            when we select Quote(s) and click on Remove Link Quote button*/
            this.buttonTitle = 'Manage Quote Group';
            this.getQuoteGroupDtls();
            this.showLinkComp = true;
        }
    }

    getDataTableGrid() {
        getMetadataColumns({ columnsCategory: this.columnsClassification })
            .then(result => {
                this.dataTableColumns = result;
            })
            .catch((error) => {
                console.log('Error getting Quote Group Columns-->' + JSON.stringify(error.body.message));
            });
    }

    getQuoteGroupDtls() {
        console.log(this.recordId);
        getQuoteGroup({ quoteId: this.recordId })
            .then(result => {
                this.resultList = result;
                this.quoteGroupList = [];
                this.iterationStarting = 0;
                this.iterationEnding = this.recordsPerPage;
                for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                    if (result[i] !== undefined) {
                        console.log('list22' + JSON.stringify(result[i]));
                        this.quoteGroupList.push(result[i]);
                    }
                }
                this.currentPageNumber = 1;
                this.totalNoOfRecords = result.length;
                this.totalPages = Math.ceil(result.length / this.recordsPerPage);
                this.template.querySelector('lightning-datatable').maxRowSelection = 0;
                this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
            })
            .catch((error) => {
                console.log('Error getting Quote Group Details-->' + JSON.stringify(error.body.message));
            });
    }

    invokeLinkQuotesComp() {
        this.showLinkComp = true;
    }

    handleSortdata(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.resultList));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.resultList = parseData;
        this.quoteGroupList = [];
        this.iterationStarting = 0;
        this.iterationEnding = this.recordsPerPage;
        for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
            if (this.resultList[i] !== undefined) {
                this.quoteGroupList.push(this.resultList[i]);
            }
        }
        this.currentPageNumber = 1;
        this.totalNoOfRecords = this.resultList.length;
        this.totalPages = Math.ceil(this.resultList.length / this.recordsPerPage);
        this.errorMsg = '';
        this.template.querySelector('lightning-datatable').maxRowSelection = 0;
        this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
    }

    onPreviousQG() {
        if (this.iterationStarting > 0) {
            this.currentPageNumber = this.currentPageNumber - 1;
            this.iterationStarting = this.iterationStarting - this.recordsPerPage;
            this.iterationEnding = this.iterationEnding - this.recordsPerPage;
            this.quoteGroupList = [];
            for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                if (this.resultList[i] !== undefined) {
                    this.quoteGroupList.push(this.resultList[i]);
                }
            }
            this.template.querySelector('lightning-datatable').maxRowSelection = 0;
            this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        }
    }

    onNextQG() {
        if (this.currentPageNumber < this.totalPages) {
            this.currentPageNumber = this.currentPageNumber + 1;
            this.iterationStarting = this.iterationStarting + this.recordsPerPage;
            this.iterationEnding = this.iterationEnding + this.recordsPerPage;
            this.quoteGroupList = [];
            for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                if (this.resultList[i] !== undefined) {
                    this.quoteGroupList.push(this.resultList[i]);
                }
            }
            this.template.querySelector('lightning-datatable').maxRowSelection = 0;
            this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        }
    }

    onLastQG() {
        if (this.currentPageNumber < this.totalPages) {
            this.currentPageNumber = this.totalPages;
            this.iterationStarting = (this.recordsPerPage * this.totalPages) - this.recordsPerPage;
            this.iterationEnding = this.recordsPerPage * this.totalPages;
            this.quoteGroupList = [];
            for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                if (this.resultList[i] !== undefined) {

                    this.quoteGroupList.push(this.resultList[i]);
                }
            }
            this.template.querySelector('lightning-datatable').maxRowSelection = 0;
            this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        }

    }

    onFirstQG() {
        if (this.iterationStarting > 0) {
            this.currentPageNumber = 1;
            this.iterationStarting = 0;
            this.iterationEnding = this.recordsPerPage;
            this.quoteGroupList = [];
            for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                if (this.resultList[i] !== undefined) {
                    this.quoteGroupList.push(this.resultList[i]);
                }
            }
            this.template.querySelector('lightning-datatable').maxRowSelection = 0;
            this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        }
    }

    get disablePreviousButtom() {
        return (this.iterationStarting === 0 || this.totalNoOfRecords == undefined || this.totalNoOfRecords == 0);
    }
    get disableNextButtom() {
        return (this.currentPageNumber === this.totalPages) || (this.currentPageNumber > this.totalPages);
    }

    get hasRecords() {
        if (this.disablePagination != true) {
            return (this.totalNoOfRecords !== 0);
        }
        else {
            return true;
        }
    }

    closeModal() {
        this.showLinkComp = false;
    }
}