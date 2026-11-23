import { LightningElement, track } from 'lwc';
import fetchAccountRecords from '@salesforce/apex/Core_IPS_ListViewsCtrl_LWC.fetchAccountRecords';   
import { ShowToastEvent } from 'lightning/platformShowToastEvent';  

export default class LazyLoading_LWC extends LightningElement {
    @track _accountData = [];   
    @track error;   
    @track loadMoreStatus = '';   
    queryOffset;   
    currentCount = 0;   
    queryLimit;   
    totalRecordCount;   
    timesCalled = 0;   
    disableLoadMore = false;   
    fromConstructor;   
    @track accountColumns = [  
    ];   

    constructor() {   
        super();   
        this.queryOffset = 0;   
        this.queryLimit = 10;   
        this.fromConstructor = true;   
        this.fetchRecords();   
        this.currentCount = 10;   
        console.log('Called from Infinite Table Constructor '+this.queryOffset);   
    }   

    showToast(type, title, message, variant, mode) {   
        const evt = new ShowToastEvent({   
            type : type,   
            title: title,   
            message: message,   
            variant: variant,   
            mode: mode   
        });   
        this.dispatchEvent(evt);   
    }  

    handleLoadMore(event) {   
        if(this.disableLoadMore)   
            return;   
        if(this.fromConstructor == true) {   
            this.fromConstructor = false;   
            return;   
        }   
        const { target } = event;   
        //Display a spinner to signal that data is being loaded   
        target.isLoading = true;   
        if(this.totalRecordCount > this.queryOffset) {   
            this.queryOffset = this.queryOffset + 10;   
            this.fetchRecords()   
            .then(()=> {   
                target.isLoading = false;   
                if(this.totalRecordCount > (this.currentCount + 10))   
                    this.currentCount = this.currentCount + 10;   
                else   
                    this.currentCount = this.totalRecordCount;   
            });   
        }   
        else {   
            target.isLoading = false;   
            this.disableLoadMore = true;   
            this.loadMoreStatus = 'No more to load.';   
            this.showToast('Success', 'Success', 'All Account Records are Loaded!', 'success', 'dismissible');   
        }   
        console.log('Called from Infinite Table Handle More '+this.queryOffset);   
    }  
    
    fetchRecords() {   
        let newData;   
        return fetchAccountRecords({   
            queryLimit : this.queryLimit,    
            queryOffset:this.queryOffset   
        })   
        .then(result => {    
            this.totalRecordCount = result.totalRecordCount;   
            newData = JSON.parse(JSON.stringify(result.accRecords));   
            newData.forEach(function(entry) {   
                // flatten the data to that it can be directly consumed by data table   
                if (entry.CreatedBy){   
                    entry.CreatedByName = entry.CreatedBy.Name;   
                }   
            });   
            let newRecords = [...this._accountData, ...newData];   
            this._accountData = newRecords;   
            this.error = undefined;   
        })   
        .catch(error => {    
            this.error = error;   
            this.showToast('Error', 'Error', 'Error getting records from Server', 'error', 'sticky');   
        })   
    }  
    get accountData() {   
        return this._accountData.length  ? this._accountData : null;   
    }  
}