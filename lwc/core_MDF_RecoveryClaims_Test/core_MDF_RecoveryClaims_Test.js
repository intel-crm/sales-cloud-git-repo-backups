import { LightningElement, api, track, wire } from 'lwc';
import getcolumnsForClaimsEligibleForRecovery from
    '@salesforce/apex/Core_MDF_RecoveryClaimReportViewCtrl.getcolumnsForClaimsEligibleForRecovery';
import getFilteredDataForClaimsEligibleForRecovery from 
    '@salesforce/apex/Core_MDF_Recovery_Helper.getClaimsBasedOnConditionsForUI';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
export default class Core_MDF_RecoveryClaims_Test extends LightningElement {
    error;
    @track preSelectedRows = [];
    my_ids = [];
    @api progValue;
    @api acctValue;
    @api quarter;
    @api loading;
    @track data = [];
    @track columns = [];

    
    /*@track items = [];
    @track page = 1;
    @track pageSize = 10; 
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track startingRecord = 1;
    @track endingRecord = 0;*/

    @track selectedRows;

    // in order to refresh your data, execute this function:
    refreshData() {
        let temp = []; let p = [];

        for (let i = 0; i < this.data.length; i++) {
            temp.push(this.data[i]);
        }

        for (let j = 0; j < this.preSelectedRows.length; j++) {
            p.push(this.preSelectedRows[j]);
        }

        this.data = temp;

        this.preSelectedRows = p;
        //return refreshApex();
    }
    draftValues = [];
    checkCellValue(event) {
        var tableInput = [];
        tableInput = event.detail.draftValues;
        console.log('onchange--->',JSON.stringify(tableInput));
        if(tableInput.length > 0){
            tableInput.forEach(field => {
                var Obj = {
                    Id: '',
                    recoveryAmount: '',
                    comments: ''
                }
                if(this.draftValues.length > 0){
                    var idMatchFound = false;
                    this.draftValues.forEach(draft => {
                        if(field.Id == draft.Id){
                            console.log('Id match');
                            idMatchFound = true;
                            if(field.recoveryAmount != undefined){
                                draft.recoveryAmount = field.recoveryAmount;
                            } 
                            if(field.comments != undefined){
                                draft.comment = field.comments;
                            }
                        }
                        });
                        if(!idMatchFound){
                            console.log('idMatchFound-->',idMatchFound);
                            Obj.Id = field.Id;
                            Obj.recoveryAmount = field.recoveryAmount;
                            Obj.comments = field.comments;}
                }else{
                    Obj.Id = field.Id;
                    Obj.recoveryAmount = field.recoveryAmount;
                    Obj.comments = field.comments;
                } 
                if(Obj.Id != ''){
                    this.draftValues.push(Obj);
                }
            });
        }
        console.log('Total Count--> (',this.draftValues.length, ') objList-->',JSON.stringify(this.draftValues));
    }

    handleSave(){
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('selectedRecords are ', JSON.stringify(selectedRecords));
    }

    getSelectedRec(event) {
        var s = event.detail.selectedRows;
        for (let i = 0; i < s.length; i++) {
            var currentcellId = this.preSelectedRows.find(x => x != s[i].Id);
        }
       // var y = this.data.find(c => c.Id == currentcellId).claimID;
      //  var isSelectedTrue = this.data.find(c => c.Id == currentcellId).selected;
        //if (isSelectedTrue) {
            var c = JSON.parse(JSON.stringify(this.columns));
            c[7].editable = true;
            c[9].editable = true;
            this.columns = [...c];
        //}
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('selectedRecords are ', JSON.stringify(selectedRecords));
        this.selectedRows = selectedRecords;

        /*if (this.data[0].mode == 'read') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Info',
                    message: 'Row action is not allowed',
                    variant: 'info'
                })
            );

            this.refreshData();
        }*/



        const custEvent = new CustomEvent(
            'saveclaimsforrecovery', {
            detail: this.selectedRows
        });
        this.dispatchEvent(custEvent);
    }


    //clicking on previous button this method will be called
    /*previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }

    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.data = this.items.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    } */
    @wire(getFilteredDataForClaimsEligibleForRecovery, { program: '$progValue', account: '$acctValue', quarter: '$quarter' })
    wiredFilterData({ error, data }) {
        if (data) {
            this.preSelectedRows = [];
            this.my_ids = [];
            console.log('wire return' + JSON.stringify(data));
            this.data = data.rows;


            for (let i = 0; i < data.selectedIdSet.length; i++) {
                this.my_ids.push(data.selectedIdSet[i]);
            }

            this.preSelectedRows = this.my_ids;

            console.log('preSelectedRows:' + this.preSelectedRows);

            //this.preSelectedRows = data.selectedIdSet;

            /*this.totalRecountCount = data.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
            this.data = this.items.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;*/

            this.error = undefined;
            this.loading = false;

            const custEvent = new CustomEvent(
                'callloading', {
                detail: this.loading
            });
            this.dispatchEvent(custEvent);

        } else if (error) {
            this.error = error;
            this.loading = false;

            const custEvent = new CustomEvent(
                'callloading', {
                detail: this.loading
            });
            this.dispatchEvent(custEvent);
        }
    }

    connectedCallback() {

        this.getColumns();

    }

    getColumns() {
        getcolumnsForClaimsEligibleForRecovery()
            .then(result => {
                this.columns = [...this.columns, ...result];
                //this.columns = result;
                console.log('column-->',JSON.stringify(this.columns));
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;

            });
    }
}