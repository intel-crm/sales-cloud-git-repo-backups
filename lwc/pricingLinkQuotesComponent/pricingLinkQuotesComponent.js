import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMetadataColumns from '@salesforce/apex/Pricing_LinkQuotesController.getMetadataColumns';
import getQuotes from '@salesforce/apex/Pricing_LinkQuotesController.getQuotes';
import getQuoteNumber from '@salesforce/apex/Pricing_LinkQuotesController.getQuoteNumber';
import getQuoteLinkStatus from '@salesforce/apex/Pricing_LinkQuotesController.getQuoteLinkStatus';
import findRecords from '@salesforce/apex/Pricing_LinkQuotesController.findRecords';
import linkQuotes from '@salesforce/apex/Pricing_LinkQuotesController.linkQuotes';
import linkQuoteWoGrp from '@salesforce/apex/Pricing_LinkQuotesController.linkQuoteWoGrp';
import getQuoteGroup from '@salesforce/apex/Pricing_LinkQuotesController.getQuoteGroup';
import removeQuoteLink from '@salesforce/apex/Pricing_LinkQuotesController.removeQuoteLink';
import verifyLinkStatus from '@salesforce/apex/Pricing_LinkQuotesController.verifyLinkStatus';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import pricingPubSub from 'c/pricingPubSub';
import toolTip from '@salesforce/label/c.Pricing_Tender_Quote_Group_Tooltip';
import noQuotesFound from '@salesforce/label/c.Pricing_Quote_Group_No_Quotes_Error_Msg';

const TITLE_TEXT = 'Success!';
const VAR_TEXT = 'success';
const MODE = 'dismissable';
const MSG_TEXT_Save = 'Quote(s) were linked successfully to the Quote Group - ';
const MSG_TEXT_RemoveLink = 'Quote(s) were successfully removed from the Quote Group.';

const TITLE_TEXTERROR = 'Error!';
const VAR_TEXTERROR = 'error';
const MODE_ERROR = 'dismissable';
const MSG_TEXT_Error = 'There was an error in linking the Quote(s). Please try again.';
const MSG_TEXT_RemoveLinkError = 'There was an error in removing the Quote(s) from the Quote Group.';

export default class PricingLinkQuotesComponent extends LightningElement {
label = {
    toolTip
};
@api recordId;
@track resultList;
@track quoteList;
@track quoteRecsList;
@track quoteGroupList;
@track quoteNumList = [];
@track groupName;
@track quoteNumber;
@track dataTableColumns;
@track errorMsg = '';
@track isSpinner = false;
@track showRecsGrid = true;
@track quoteRecId;
@track searchKey = '';
@track searchVal = 'Quote Number';
@track isUnlink = false;
@track sortBy;
@track defaultSortDirection = 'asc';
@track sortDirection;
@api recordidfromgrp;
selectedRowsArr = [];
selectedRowsPagesMap = new Map();
rowsPageSelection = [];
rowsPageSelectionDummy = [];
@track unSelectedRowsList = [];
selRows = [];
flag = false; 
@track currentPageNumber;
@track totalPages;
@track totalNoOfRecords;
@track recordsPerPage = 5;
@track iterationStarting;
@track iterationEnding;
@track disablePagination = false;
@track noQuoteRecords = false;
@track noQuotesErrMsg;

rows = [];

connectedCallback() {
    if (this.recordidfromgrp != undefined && this.recordidfromgrp != '') {
        this.quoteRecId = this.recordidfromgrp;
        this.getQuoteNumber();
        this.isQuoteLinked();
    }
}

isQuoteLinked() {
    this.isSpinner = true;
    getQuoteLinkStatus({ quoteId: this.quoteRecId })
        .then(result => {
            if (result == true) {
                this.showRecsGrid = false;
                this.columnsClassification = 'Quote Group';
                getMetadataColumns({ columnsCategory: this.columnsClassification })
                    .then(result => {
                        this.dataTableColumns = result;
                    })
                    .catch((error) => {
                        this.isSpinner = false;
                        console.log('Error getting Quote Group Columns-->' + JSON.stringify(error.body.message));
                    });
                this.getQuoteGroupDtls();
            }
            else {
                this.showRecsGrid = true;
                this.columnsClassification = 'Quote';
                getMetadataColumns({ columnsCategory: this.columnsClassification })
                    .then(result => {
                        this.dataTableColumns = result;
                    })
                    .catch((error) => {
                        this.isSpinner = false;
                        console.log('Error getting Quote Columns-->' + JSON.stringify(error.body.message));
                    });
                this.getQuoteDetails();
            }
        })
        .catch((error) => {
            this.isSpinner = false;
            console.log('Error getting Quote Details-->' + JSON.stringify(error.body.message));
        });
}

getQuoteGroupDtls() {
    //this.isSpinner = true;
    getQuoteGroup({ quoteId: this.quoteRecId })
        .then(result => {
            this.resultList = result;
            this.quoteGroupList = [];
            this.iterationStarting = 0;
            this.iterationEnding = this.recordsPerPage;
            for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                if (result[i] !== undefined) {
                    this.quoteGroupList.push(result[i]);
                }
            }
            this.currentPageNumber = 1;
            this.totalNoOfRecords = result.length;
            this.totalPages = Math.ceil(result.length / this.recordsPerPage);
            this.isSpinner = false;
        })
        .catch((error) => {
            this.isSpinner = false;
            console.log('Error getting Quote Group Details-->' + JSON.stringify(error.body.message));
        });
}

getQuoteDetails() {
    getQuotes({ quoteId: this.quoteRecId })
        .then(result => {
            this.resultList = result;
            if (this.resultList == '' || this.resultList == undefined) {
                this.isSpinner = false;
                this.quoteGroupList = '';
                this.disablePagination = true;
                this.currentPageNumber = this.totalPages = this.totalNoOfRecords = 0;
                this.noQuoteRecords = true;
                this.noQuotesErrMsg = noQuotesFound;
            }
            else {
                this.quoteList = [];
                this.iterationStarting = 0;
                this.iterationEnding = this.recordsPerPage;
                for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                    if (result[i] !== undefined) {
                        this.quoteList.push(result[i]);
                    }
                }
                this.currentPageNumber = 1;
                this.totalNoOfRecords = result.length;
                this.totalPages = Math.ceil(result.length / this.recordsPerPage);
                this.isSpinner = false;
            }
        })
        .catch((error) => {
            this.isSpinner = false;
            console.log('Error getting Quote Details-->' + JSON.stringify(error.body.message));
        });
}

handleSearch(event) {
    this.isSpinner = true;
    //this.selectedRowsPagesMap = {};
    if (this.rowsPageSelection != undefined && this.rowsPageSelection != '') {
        this.selectedRowsPagesMap.set(this.currentPageNumber, this.rowsPageSelection);
    }
    if (this.selectedRowsPagesMap.size > 0 && this.selectedRowsPagesMap.get(this.currentPageNumber) != null) {
        if (this.selectedRowsPagesMap.get(this.currentPageNumber).length > 0) {
            this.selectedRowsPagesMap.forEach(e => {
                for (let [key, value] of Object.entries(e)) {
                    this.quoteNumList.push(value);
                }
                });
        }
    }
    if (this.searchKey == '' || this.searchKey == undefined) {
        this.getQuoteDetails();
        this.errorMsg = '';
        this.isSpinner = false;
    }
    else {
        if (this.searchVal == '' || this.searchVal == undefined) {
            this.searchVal = 'Quote Number';
            this.errorMsg = '';
            this.isSpinner = false;
        }
        findRecords({ quoteId: this.quoteRecId, searchKey: this.searchKey, searchCriteria: this.searchVal })
            .then((result) => {
                if (result.length === 0) {
                    this.quoteList = '';
                    this.totalNoOfRecords = 0;
                    this.totalPages = 1;
                    this.errorMsg = 'No Records Found';
                    this.isSpinner = false;
                } else {
                    this.quoteList = [];
                    this.resultList = result;
                    this.iterationStarting = 0;
                    this.iterationEnding = this.recordsPerPage;
                    for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                        if (result[i] !== undefined) {
                            this.quoteList.push(result[i]);
                        }
                    }
                    this.currentPageNumber = 1;
                    this.totalNoOfRecords = result.length;
                    this.totalPages = Math.ceil(result.length / this.recordsPerPage);
                    this.errorMsg = '';
                    this.isSpinner = false;
                    this.template.querySelector('lightning-datatable').maxRowSelection = 0;
                    this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
                }
            })
            .catch((error) => {
                this.errorMsg = '';
                this.isSpinner = false;
                console.log('Error fetching records-->' + JSON.stringify(error.body.message));
            });
    }
}

getQuoteNumber() {
    getQuoteNumber({ quoteId: this.quoteRecId })
        .then(result => {
            this.quoteNumber = result;
        })
        .catch((error) => {
            this.isSpinner = false;
            console.log('Error getting Quote Number-->' + JSON.stringify(error.body.message));
        });
}

get options() {
    return [
        { label: 'Quote Number', value: 'Quote Number' },
        { label: 'Quote Type', value: 'Quote Type' },
        { label: 'End Customer', value: 'End Customer' },
        { label: 'Project', value: 'Project' }
    ];
}

handleSearchCriteria(event) {
    this.searchVal = event.target.value;
}

handleReset() {
    this.errorMsg = '';
    this.searchKey = '';
    this.searchVal = 'Quote Number';
    this.isSpinner = true;
    this.selectedRowsPagesMap = new Map();
    this.quoteNumList = [];
    this.getQuoteDetails();
    this.isSpinner = false;
    this.template.querySelector('lightning-datatable').maxRowSelection = 0;
    this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
}

handleSortData(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(event.detail.fieldName, event.detail.sortDirection);
}

sortData(fieldname, direction) {
    if (this.rowsPageSelection != undefined) {
        this.selectedRowsPagesMap.set(this.currentPageNumber, this.rowsPageSelection);
    }
    /*if (this.selectedRowsPagesMap.size > 0) {
        this.selectedRowsPagesMap.forEach(e => {
            for (let [key, value] of Object.entries(e)) {
                this.quoteNumList.push(value);
            }
        });
    }*/
    let parseData = JSON.parse(JSON.stringify(this.resultList));
    // Return the value stored in the field
    let keyValue = (a) => {
        return a[fieldname];
    };
    let isReverse = direction === 'asc' ? 1 : -1;
    parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : ''; // handling null values
        y = keyValue(y) ? keyValue(y) : '';
        // sorting values based on direction
        return isReverse * ((x > y) - (y > x));
    });
    this.resultList = parseData;
    this.quoteList = [];
    this.iterationStarting = 0;
    this.iterationEnding = this.recordsPerPage;
    for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
        if (this.resultList[i] !== undefined) {
            this.quoteList.push(this.resultList[i]);
        }
    }
    let qnum = [];
    for (let i = 0; i < this.resultList.length; i++) {
        if (this.resultList[i] !== undefined) {
            qnum.push(this.resultList[i].quoteNumber);
        }
    }
    let pageNumber = 1;
    let sortRowsPagesMap = new Map();
    if (this.selectedRowsPagesMap.size > 0) {
        this.selectedRowsPagesMap.forEach(e => {
            for (let [key, value] of Object.entries(e)) {
                if(qnum.includes(value)){
                    pageNumber = Math.ceil((qnum.indexOf(value)+1)/5);
                    if(sortRowsPagesMap.has(pageNumber)){
                        sortRowsPagesMap.get(pageNumber).push(value);
                    }
                    else{
                        sortRowsPagesMap.set(pageNumber,[value]);
                    }
                }
                
            }
        });
    }
    this.selectedRowsPagesMap = new Map(sortRowsPagesMap);
    this.currentPageNumber = 1;
    this.totalNoOfRecords = this.resultList.length;
    this.totalPages = Math.ceil(this.resultList.length / this.recordsPerPage);
    this.errorMsg = '';
    this.template.querySelector('lightning-datatable').maxRowSelection = 0;
    this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
    this.rows = [];
        if (this.selectedRowsPagesMap.size > 0 && this.selectedRowsPagesMap.get(this.currentPageNumber) != null) {
            if (this.selectedRowsPagesMap.get(this.currentPageNumber).length > 0) {
                for (let i = 0; i < this.selectedRowsPagesMap.get(this.currentPageNumber).length; i++) {
                    this.rows.push(this.selectedRowsPagesMap.get(this.currentPageNumber)[i]);
                }
                this.selectedRowsArr = this.rows;
            }
        }
    this.rowsPageSelection = this.selectedRowsPagesMap.get(this.currentPageNumber) != null ? this.selectedRowsPagesMap.get(this.currentPageNumber) : [];
}

handleSortGroupData(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortGroupData(event.detail.fieldName, event.detail.sortDirection);
}

sortGroupData(fieldname, direction) {
    if (this.rowsPageSelection != undefined) {
        this.selectedRowsPagesMap.set(this.currentPageNumber, this.rowsPageSelection);
    }
    let parseData = JSON.parse(JSON.stringify(this.resultList));
    // Return the value stored in the field
    let keyValue = (a) => {
        return a[fieldname];
    };
    let isReverse = direction === 'asc' ? 1 : -1;
    parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : ''; // handling null values
        y = keyValue(y) ? keyValue(y) : '';
        // sorting values based on direction
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
    let qnum = [];
    for (let i = 0; i < this.resultList.length; i++) {
        if (this.resultList[i] !== undefined) {
            qnum.push(this.resultList[i].quoteNumber);
        }
    }
    let pageNumber = 1;
    let sortRowsPagesMap = new Map();
    if (this.selectedRowsPagesMap.size > 0) {
        this.selectedRowsPagesMap.forEach(e => {
            for (let [key, value] of Object.entries(e)) {
                if(qnum.includes(value)){
                    pageNumber = Math.ceil((qnum.indexOf(value)+1)/5);
                    if(sortRowsPagesMap.has(pageNumber)){
                        sortRowsPagesMap.get(pageNumber).push(value);
                    }
                    else{
                        sortRowsPagesMap.set(pageNumber,[value]);
                    }
                }
                
            }
        });
    }
    this.selectedRowsPagesMap = new Map(sortRowsPagesMap);
    this.currentPageNumber = 1;
    this.totalNoOfRecords = this.resultList.length;
    this.totalPages = Math.ceil(this.resultList.length / this.recordsPerPage);
    this.errorMsg = '';
    this.template.querySelector('lightning-datatable').maxRowSelection = 0;
    this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
    this.rows = [];
        if (this.selectedRowsPagesMap.size > 0 && this.selectedRowsPagesMap.get(this.currentPageNumber) != null) {
            if (this.selectedRowsPagesMap.get(this.currentPageNumber).length > 0) {
                for (let i = 0; i < this.selectedRowsPagesMap.get(this.currentPageNumber).length; i++) {
                    this.rows.push(this.selectedRowsPagesMap.get(this.currentPageNumber)[i]);
                }
                this.selectedRowsArr = this.rows;
            }
        }
    this.rowsPageSelection = this.selectedRowsPagesMap.get(this.currentPageNumber) != null ? this.selectedRowsPagesMap.get(this.currentPageNumber) : [];
}

handleRowAction(event) {
    const selectedRows = event.detail.selectedRows;
    this.rowsPageSelectionDummy = [];
    for (let i = 0; i < selectedRows.length; i++) {
        if (!this.rowsPageSelectionDummy.includes(selectedRows[i].quoteNumber)) {
            this.rowsPageSelectionDummy.push(selectedRows[i].quoteNumber);
        }
    }
    if (this.rowsPageSelectionDummy != undefined) {
        this.rowsPageSelection = this.rowsPageSelectionDummy;
    }
    else {
        this.rowsPageSelection = this.rowsPageSelection;
    }
}

handleRowUnlinkAction(event) {
    const selectedRows = event.detail.selectedRows;
    this.rowsPageSelectionDummy = [];
    for (let i = 0; i < selectedRows.length; i++) {
        if (!this.rowsPageSelectionDummy.includes(selectedRows[i].quoteNumber)) {
            this.rowsPageSelectionDummy.push(selectedRows[i].quoteNumber);
        }
    }
    if (this.rowsPageSelectionDummy != undefined) {
        this.rowsPageSelection = this.rowsPageSelectionDummy;
    }
    else {
        this.rowsPageSelection = this.rowsPageSelection;
    }
}

handleLinkQuotes() {
    this.isSpinner = true;
    if (this.rowsPageSelection != undefined) {
        this.selectedRowsPagesMap.set(this.currentPageNumber, this.rowsPageSelection);
    }
    if (this.selectedRowsPagesMap.size > 0) {
        this.selectedRowsPagesMap.forEach(e => {
            for (let [key, value] of Object.entries(e)) {
                this.quoteNumList.push(value);
            }
        });
    }
    if (this.quoteNumList == '' || this.quoteNumList == undefined || this.quoteNumList == null) {
        this.isSpinner = false;
        this.errorMsg = 'Please select Quote record(s) that need to be linked.';
    }
    else {
        verifyLinkStatus({ quoteNbrs: this.quoteNumList })
            .then(result => {
                getRecordNotifyChange([{ recordId: this.quoteRecId }]);
                if (result == 'true') {
                    this.errorMsg = '';
                    this.linkQuoteToGroup();
                }
                else if ((result != 'true') && (result != 'false')) {
                    this.groupName = result;
                    linkQuoteWoGrp({ quoteNumList: this.quoteNumList, groupName: this.groupName, quoteId: this.quoteRecId })
                        .then(result => {
                            getRecordNotifyChange([{ recordId: this.quoteRecId }]);
                            this.errorMsg = '';
                            this.isSpinner = false;
                            this.selectedRowsPagesMap = {};
                            const toastMessageSave = new ShowToastEvent({
                                title: TITLE_TEXT,
                                message: MSG_TEXT_Save + result + '.',
                                variant: VAR_TEXT,
                                mode: MODE
                            });
                            this.dispatchEvent(toastMessageSave);
                            /*Firing the showQuoteLink event to be handled in the pricingQuoteGroupComponent.
                            This event is fired to get the latest Quote(s) associated to the Quote Group after linking*/
                            pricingPubSub.fireLinkEvent('showQuoteLink', true, true);
                        })
                        .catch((error) => {
                            this.errorMsg = '';
                            this.isSpinner = false;
                            this.selectedRowsPagesMap = {};
                            //this.quoteNumList = [];
                            const toastMessageError = new ShowToastEvent({
                                title: TITLE_TEXTERROR,
                                message: MSG_TEXT_Error,
                                variant: VAR_TEXTERROR,
                                mode: MODE_ERROR
                            });
                            this.dispatchEvent(toastMessageError);
                        });
                }
                else if (result == 'false') {
                    this.isSpinner = false;
                    this.errorMsg = 'Quote(s) selected already have a Quote Group associated with it. Please try again with different Quote(s).';
                    this.quoteNumList = [];
                }
            })
            .catch((error) => {
                this.errorMsg = '';
                this.isSpinner = false;
                this.selectedRowsPagesMap = new Map();
                const toastMessageError = new ShowToastEvent({
                    title: TITLE_TEXTERROR,
                    message: MSG_TEXT_Error,
                    variant: VAR_TEXTERROR,
                    mode: MODE_ERROR
                });
                this.dispatchEvent(toastMessageError);
            });
    }
}

linkQuoteToGroup() {
    linkQuotes({ quoteNumList: this.quoteNumList, quoteId: this.quoteRecId })
        .then(result => {
            getRecordNotifyChange([{ recordId: this.quoteRecId }]);
            this.errorMsg = '';
            this.isSpinner = false;
            this.selectedRowsPagesMap = {};
            const toastMessageSave = new ShowToastEvent({
                title: TITLE_TEXT,
                message: MSG_TEXT_Save + result + '.',
                variant: VAR_TEXT,
                mode: MODE
            });
            this.dispatchEvent(toastMessageSave);
            /*Firing the showQuoteLink event to be handled in the pricingQuoteGroupComponent.
            This event is fired to get the latest Quote(s) associated to the Quote Group after linking*/
            pricingPubSub.fireLinkEvent('showQuoteLink', true, true);
        })
        .catch((error) => {
            this.errorMsg = '';
            this.isSpinner = false;
            //this.quoteNumList = [];
            this.selectedRowsPagesMap = new Map();
            const toastMessageError = new ShowToastEvent({
                title: TITLE_TEXTERROR,
                message: MSG_TEXT_Error,
                variant: VAR_TEXTERROR,
                mode: MODE_ERROR
            });
            this.dispatchEvent(toastMessageError);
        });
}

removeQuoteLink() {
    this.isSpinner = true;
    if (this.rowsPageSelection != undefined) {
        this.selectedRowsPagesMap.set(this.currentPageNumber, this.rowsPageSelection);
    }
    if (this.selectedRowsPagesMap.size > 0) {
        this.selectedRowsPagesMap.forEach(e => {
            for (let [key, value] of Object.entries(e)) {
                this.quoteNumList.push(value);
            }
        });
    }
    if (this.quoteNumList == '' || this.quoteNumList == undefined) {
        this.isSpinner = false;
        this.errorMsg = 'Please select Quote records that need to be removed from the Quote Group.';
    }
    else {
        removeQuoteLink({ quoteId: this.quoteRecId, quoteNbrs: this.quoteNumList })
            .then(result => {
                getRecordNotifyChange([{ recordId: this.quoteRecId }]);
                this.errorMsg = '';
                this.isSpinner = false;
                const toastMessageSave = new ShowToastEvent({
                    title: TITLE_TEXT,
                    message: MSG_TEXT_RemoveLink,
                    variant: VAR_TEXT,
                    mode: MODE
                });
                this.dispatchEvent(toastMessageSave);
                this.resultList = result;
                if (this.resultList == undefined || this.resultList == '' || this.resultList == null || this.quoteNumList.includes(this.quoteNumber)) {
                    this.isUnlink = true;
                    /*Firing the showQuoteLink event to be handled in the pricingQuoteGroupComponent.
                    This event is fired on Remove Link done on all the Quotes in the grid, 
                    which will invoke a method to display a datatable grid without any records.*/
                    pricingPubSub.fireLinkEvent('showQuoteLink', false, true);
                    this.selectedRowsPagesMap = {};
                }
                else {
                    this.quoteGroupList = [];
                    this.quoteNumList = [];
                    this.iterationStarting = 0;
                    this.iterationEnding = this.recordsPerPage;
                    for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                        if (result[i] !== undefined) {
                            this.quoteGroupList.push(result[i]);
                        }
                    }
                    /*Firing the showQuoteLink event to be handled in the pricingQuoteGroupComponent.
                    This event is fired on Remove Link done on Quote(s) in the grid, 
                    which will invoke a method to display a datatable grid with records.*/
                    pricingPubSub.fireLinkEvent('showQuoteLink', true, false);
                    this.currentPageNumber = 1;
                    this.totalNoOfRecords = result.length;
                    this.totalPages = Math.ceil(result.length / this.recordsPerPage);
                    this.template.querySelector('lightning-datatable').maxRowSelection = 0;
                    this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
                }
            })
            .catch((error) => {
                this.errorMsg = '';
                this.isSpinner = false;
                this.selectedRowsPagesMap = new Map();
                const toastMessageError = new ShowToastEvent({
                    title: TITLE_TEXTERROR,
                    message: MSG_TEXT_RemoveLinkError,
                    variant: VAR_TEXTERROR,
                    mode: MODE_ERROR
                });
                this.dispatchEvent(toastMessageError);
            });
    }
}

handleKeyChange(event) {
    const searchKey = event.target.value;
    this.searchKey = searchKey;
}

onPrevious() {
    if (this.rowsPageSelection != undefined){
        this.selectedRowsPagesMap.set(this.currentPageNumber, this.rowsPageSelection);
    }
    if (this.iterationStarting > 0) {
        this.currentPageNumber = this.currentPageNumber - 1;
        this.iterationStarting = this.iterationStarting - this.recordsPerPage;
        this.iterationEnding = this.iterationEnding - this.recordsPerPage;
        this.quoteList = [];
        for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
            if (this.resultList[i] !== undefined) {
                this.quoteList.push(this.resultList[i]);
            }
        }
        this.template.querySelector('lightning-datatable').maxRowSelection = 0;
        this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        this.rows = [];
        if (this.selectedRowsPagesMap.size > 0 && this.selectedRowsPagesMap.get(this.currentPageNumber) != null) {
            if (this.selectedRowsPagesMap.get(this.currentPageNumber).length > 0) {
                for (let i = 0; i < this.selectedRowsPagesMap.get(this.currentPageNumber).length; i++) {
                    this.rows.push(this.selectedRowsPagesMap.get(this.currentPageNumber)[i]);
                }
                this.selectedRowsArr = this.rows;
            }
        }
        this.rowsPageSelection = this.selectedRowsPagesMap.get(this.currentPageNumber) != null ? this.selectedRowsPagesMap.get(this.currentPageNumber) : [];
    }
}

onNext() {
    if (this.rowsPageSelection != undefined){
        this.selectedRowsPagesMap.set(this.currentPageNumber, this.rowsPageSelection);
    }
    if (this.currentPageNumber < this.totalPages) {
        this.currentPageNumber = this.currentPageNumber + 1;
        this.iterationStarting = this.iterationStarting + this.recordsPerPage;
        this.iterationEnding = this.iterationEnding + this.recordsPerPage;
        this.quoteList = [];
        for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
            if (this.resultList[i] !== undefined) {
                this.quoteList.push(this.resultList[i]);
            }
        }
        this.template.querySelector('lightning-datatable').maxRowSelection = 0;
        this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        this.rows = [];
        if (this.selectedRowsPagesMap.size > 0 && this.selectedRowsPagesMap.get(this.currentPageNumber) != null) {
            if (this.selectedRowsPagesMap.get(this.currentPageNumber).length > 0) {
                for (let i = 0; i < this.selectedRowsPagesMap.get(this.currentPageNumber).length; i++) {
                    this.rows.push(this.selectedRowsPagesMap.get(this.currentPageNumber)[i]);
                }
                this.selectedRowsArr = this.rows;
            }
        }
        this.rowsPageSelection = this.selectedRowsPagesMap.get(this.currentPageNumber) != null ? this.selectedRowsPagesMap.get(this.currentPageNumber) : [];
    }
}

get disablePreviousButtom() {
    return (this.iterationStarting === 0 || this.totalNoOfRecords == 0);
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

onLast() {
    if (this.rowsPageSelection != undefined){
        this.selectedRowsPagesMap.set(this.currentPageNumber, this.rowsPageSelection);
    }
    if (this.currentPageNumber < this.totalPages) {
        this.currentPageNumber = this.totalPages;
        this.iterationStarting = (this.recordsPerPage * this.totalPages) - this.recordsPerPage;
        this.iterationEnding = this.recordsPerPage * this.totalPages;
        this.quoteList = [];
        for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
            if (this.resultList[i] !== undefined) {

                this.quoteList.push(this.resultList[i]);
            }
        }
        this.template.querySelector('lightning-datatable').maxRowSelection = 0;
        this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        this.rows = [];
        if (this.selectedRowsPagesMap.size > 0 && this.selectedRowsPagesMap.get(this.currentPageNumber) != null) {
            if (this.selectedRowsPagesMap.get(this.currentPageNumber).length > 0) {
                for (let i = 0; i < this.selectedRowsPagesMap.get(this.currentPageNumber).length; i++) {
                    this.rows.push(this.selectedRowsPagesMap.get(this.currentPageNumber)[i]);
                }
                this.selectedRowsArr = this.rows;
            }
        }
        this.rowsPageSelection = this.selectedRowsPagesMap.get(this.currentPageNumber) != null ? this.selectedRowsPagesMap.get(this.currentPageNumber) : [];
    }

}

onFirst() {
    if (this.rowsPageSelection != undefined){
        this.selectedRowsPagesMap.set(this.currentPageNumber, this.rowsPageSelection);
    }
    if (this.iterationStarting > 0) {
        this.currentPageNumber = 1;
        this.iterationStarting = 0;
        this.iterationEnding = this.recordsPerPage;
        this.quoteList = [];
        for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
            if (this.resultList[i] !== undefined) {
                this.quoteList.push(this.resultList[i]);
            }
        }
        this.template.querySelector('lightning-datatable').maxRowSelection = 0;
        this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        this.rows = [];
        if (this.selectedRowsPagesMap.size > 0 && this.selectedRowsPagesMap.get(this.currentPageNumber) != null) {
            if (this.selectedRowsPagesMap.get(this.currentPageNumber).length > 0) {
                for (let i = 0; i < this.selectedRowsPagesMap.get(this.currentPageNumber).length; i++) {
                    this.rows.push(this.selectedRowsPagesMap.get(this.currentPageNumber)[i]);
                }
                this.selectedRowsArr = this.rows;
            }
        }
        this.rowsPageSelection = this.selectedRowsPagesMap.get(this.currentPageNumber) != null ? this.selectedRowsPagesMap.get(this.currentPageNumber) : [];
    }
}

onPreviousQG() {
    if (this.rowsPageSelection != undefined) {
        this.selectedRowsPagesMap.set(this.currentPageNumber, this.rowsPageSelection);
    }
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
        this.rows = [];
        if (this.selectedRowsPagesMap.size > 0 && this.selectedRowsPagesMap.get(this.currentPageNumber) != null) {
            if (this.selectedRowsPagesMap.get(this.currentPageNumber).length > 0) {
                for (let i = 0; i < this.selectedRowsPagesMap.get(this.currentPageNumber).length; i++) {
                    this.rows.push(this.selectedRowsPagesMap.get(this.currentPageNumber)[i]);
                }
                this.selectedRowsArr = this.rows;
            }
        }
        this.rowsPageSelection = this.selectedRowsPagesMap.get(this.currentPageNumber) != null ? this.selectedRowsPagesMap.get(this.currentPageNumber) : [];
    }
}

onNextQG() {
    if (this.rowsPageSelection != undefined) {
        this.selectedRowsPagesMap.set(this.currentPageNumber, this.rowsPageSelection);
    }
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
        this.rows = [];
        if (this.selectedRowsPagesMap.size > 0 && this.selectedRowsPagesMap.get(this.currentPageNumber) != null) {
            if (this.selectedRowsPagesMap.get(this.currentPageNumber).length > 0) {
                for (let i = 0; i < this.selectedRowsPagesMap.get(this.currentPageNumber).length; i++) {
                    this.rows.push(this.selectedRowsPagesMap.get(this.currentPageNumber)[i]);
                }
                this.selectedRowsArr = this.rows;
            }
        }
        this.rowsPageSelection = this.selectedRowsPagesMap.get(this.currentPageNumber) != null ? this.selectedRowsPagesMap.get(this.currentPageNumber) : [];
    }
}

onLastQG() {
    if (this.rowsPageSelection != undefined) {
        this.selectedRowsPagesMap.set(this.currentPageNumber, this.rowsPageSelection);
    }
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
        this.rows = [];
        if (this.selectedRowsPagesMap.size > 0 && this.selectedRowsPagesMap.get(this.currentPageNumber) != null) {
            if (this.selectedRowsPagesMap.get(this.currentPageNumber).length > 0) {
                for (let i = 0; i < this.selectedRowsPagesMap.get(this.currentPageNumber).length; i++) {
                    this.rows.push(this.selectedRowsPagesMap.get(this.currentPageNumber)[i]);
                }
                this.selectedRowsArr = this.rows;
            }
        
        }
        this.rowsPageSelection = this.selectedRowsPagesMap.get(this.currentPageNumber) != null ? this.selectedRowsPagesMap.get(this.currentPageNumber) : [];
    }

}

onFirstQG() {
    if (this.rowsPageSelection != undefined) {
        this.selectedRowsPagesMap.set(this.currentPageNumber, this.rowsPageSelection);
    }
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
        this.rows = [];
        if (this.selectedRowsPagesMap.size > 0 && this.selectedRowsPagesMap.get(this.currentPageNumber) != null) {
            if (this.selectedRowsPagesMap.get(this.currentPageNumber).length > 0) {
                for (let i = 0; i < this.selectedRowsPagesMap.get(this.currentPageNumber).length; i++) {
                    this.rows.push(this.selectedRowsPagesMap.get(this.currentPageNumber)[i]);
                }
                this.selectedRowsArr = this.rows;
            }
        }
        this.rowsPageSelection = this.selectedRowsPagesMap.get(this.currentPageNumber) != null ? this.selectedRowsPagesMap.get(this.currentPageNumber) : [];
    }
}

}