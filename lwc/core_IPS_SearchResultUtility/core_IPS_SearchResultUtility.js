/* eslint-disable no-console */
import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';

import displayMapResults from '@salesforce/apex/Core_IPS_NewMapHomePageController.displayMapResults';

export default class Core_IPS_SearchResultUtility extends LightningElement {
    @api columns;
    @api mapResult;
    @api enableInfiniteLoading;
    @api noOfRecords;
    @api queryString;
    @track dataToShow = [];
    @track isDataAvailable = false;
    @track ifDataNotAvailable = false;
    @track spinnerOn = false;
    offset = 0;
    addMoreDataCounter = true;

    @wire(displayMapResults, {queryString : '$queryString'})
    WiredResults({data}) {
        if(data) {
            console.log('queryString in wire ::::', this.queryString);
            this.mapResult = data;
            this.displayMapResults();
        }
    }

    connectedCallback() {
    }

    displayMapResults() {
        let newData = [];
        this.dataToShow = [];
        this.offset = 0;
        console.log('queryString in ::::', this.queryString);
        //console.log('queryString in ::::', JSON.stringify(this.mapResult));
        if(this.mapResult !== undefined && this.mapResult !== null ) {
            for (let i = this.offset; i < this.offset + parseInt(this.noOfRecords, Number); i++) {
                if (i < this.mapResult.length) {
                    newData.push(this.mapResult[i]);
                } else {
                    this.addMoreDataCounter = false;
                    break;
                }
            }
            this.offset += 20;
            
            this.dataToShow = [...this.dataToShow, ...newData];
            if(newData.length>0) {
                this.isDataAvailable = true;
                this.ifDataNotAvailable = false;
            } else {
                this.ifDataNotAvailable = true;
                this.isDataAvailable = false;
            }
            //console.log("data to show" + JSON.stringify(this.dataToShow));
        }
    }

    addMoreData() {
        let newData = [];

        for (let i = this.offset; i < this.offset + 20; i++) {
            if (i < this.mapResult.length) {
                newData.push(this.mapResult[i]);
            } else {
                this.addMoreDataCounter = false;
                break;
            }
        }
        this.offset += 20;
        //console.log("data to show" + JSON.stringify(this.dataToShow));
        this.dataToShow = [...this.dataToShow, ...newData];
    }

    onLoadMoreHandler() {
        console.log('load more');
        this.addMoreData();

        if (this.addMoreDataCounter === false) {
            this.enableInfiniteLoading = false;
        }
    }

    handleDataElementClick(event) {
        console.log(event.dataToShow);
    }
}