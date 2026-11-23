import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RelatedListUtility extends LightningElement {
    @api lightningCardTitle;
    @api queryString;
    @api records;
    @api columns
    @api hideCheckboxColumn;
    @api showRowNumberColumn;
    @api enableInfiniteLoading;
    @api numAndCheckboxBothCols;
    @api normalDataTable;
    @api numberOfRowsToShow;
    @api heightInRem;

    @api enableSearchAndInsertRecFeature;
    @api lookupIconName;
    @api lookupSearchQueryString;
    @api lookupSearchFieldApiName;
    @api insertBtnLabel;
    @api relatedFieldApiName;
    @track isInsertBtnDisabled = true;
    @track isDataAvailable = false;


    @track uniqueIdSet = new Set();
    @track isLookupQueryPresent = false;

    connectedCallback() {
        if(this.records !== undefined && this.records !== null ) {
            this.isDataAvailable = true;
            for(let i=0; i<this.records.length; i++) {
                this.uniqueIdSet.add(this.records[i][this.relatedFieldApiName]);
            }            
        }
        if(this.lookupSearchQueryString !== undefined && this.lookupSearchQueryString !== null ) {
            this.isLookupQueryPresent = true;
        }
    }

    handleSelectRecordChange(event) {
        this.selectedRecord = event.detail.record;
        if(event.detail.recordId === undefined) {
            this.isInsertBtnDisabled = true;
        } else {
            this.isInsertBtnDisabled = false;
        }
    }

    insertRecord() {
        if(this.uniqueIdSet !== undefined 
            && this.uniqueIdSet !== null 
            && this.uniqueIdSet.has(this.selectedRecord.Id)) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Record is already present!!!',
                        variant: 'error',
                    })
                );
        } else {
            console.log('We can insert the selected record ', JSON.stringify(this.selectedRecord));
        }
    }
}