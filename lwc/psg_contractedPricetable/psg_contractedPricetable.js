import { LightningElement, track, wire } from 'lwc';
import cpRecords from '@salesforce/apex/QuoteLogic.getContractedPriceRecords';
import ID_FIELD from '@salesforce/schema/SBQQ__ContractedPrice__c.Id';
import PRICE_FIELD from '@salesforce/schema/SBQQ__ContractedPrice__c.SBQQ__Price__c';
import QUANTITY from '@salesforce/schema/SBQQ__ContractedPrice__c.PSG_Quantity_EAU_Nbr__c';
import EFFECTIVE_DATE from '@salesforce/schema/SBQQ__ContractedPrice__c.SBQQ__EffectiveDate__c';
import LOWER_QTY from '@salesforce/schema/SBQQ__ContractedPrice__c.PSG_Lower_Qty_Nbr__c';
import UPPER_QTY from '@salesforce/schema/SBQQ__ContractedPrice__c.PSG_Upper_Qty_Nbr__c';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

const columns = [{
    label: 'CP Number', fieldName: 'Name', type: 'cpnumber', typeAttributes: {
        cpnumber: { fieldName: 'Name' }, recordId:{fieldName: 'id'}
    },
},
{ label: 'Quantity(EAM)', fieldName: 'PSG_Quantity_EAU_Nbr__c', type: 'number', editable: 'true', },
{ label: 'Price', fieldName: 'SBQQ__Price__c', type: 'currency', },
{ label: 'Effective Date', fieldName: 'SBQQ__EffectiveDate__c', type: 'date', editable: 'true', },
{ label: 'Lower Quantity', fieldName: 'PSG_Lower_Qty_Nbr__c', type: 'number', editable: 'true', },
{ label: 'Upper Quantity', fieldName: 'PSG_Upper_Qty_Nbr__c', type: 'number', editable: 'true', }];
const NO_OF_RECORDS_PER_PAGE = 5;
export default class Psg_contractedPricetable extends NavigationMixin(LightningElement) {

    @track columns = columns;
    @track data;
    @track pageOf = 1;
    @track receivedData;
    @track totalPages;
    @track recordsPerPage = NO_OF_RECORDS_PER_PAGE;
    @track error = undefined;
    @track start;
    @track end;
    @track loadMore = false;
    @track loadPrev = false;
    @track addNewRecords = false;
    @track dataAvailable = false;
    // connectedCallback() {
    //     this.pageOf = 1;
    //     cpRecords().then(result => {
    //         if (result) {
    //             this.receivedData = result;
    //             this.start = parseInt((this.pageOf - 1) * this.recordsPerPage);
    //             this.end = parseInt(this.start) + parseInt(this.recordsPerPage);
    //             this.totalPages = Math.ceil(result.length / this.recordsPerPage);
    //             this.data = this.receivedData.slice(this.start, this.end);
    //             //this.noFPages = Math.ceil(this.records.length / pagesize);
    //             this.loadMore = (this.pageOf >= 1 && this.totalPages <= this.pageOf) ? true : false;
    //             this.loadPrev = (this.pageOf === 1) ? true : false;

    //         }
    //     })
    //         .catch(error => {
    //             this.error = error;
    //         })
    // }
    updateRecords(evt) {
        // this.addNewRecords = true;
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'SBQQ__ContractedPrice__c',
                actionName: 'new'
            },
        });

    }
    onNextClick() {
        console.log('>> on click next ' + this.receivedData);
        this.pageOf++;
        this.loadMore = (this.pageOf >= 1 && this.totalPages <= this.pageOf) ? true : false;
        this.loadPrev = (this.pageOf === 1) ? true : false;
        this.start = parseInt((this.pageOf - 1) * this.recordsPerPage);
        this.end = parseInt(this.start) + parseInt(this.recordsPerPage);
        this.data = this.receivedData.slice(this.start, this.end);

    }
    onPrevClick() {
        this.pageOf--;
        this.loadMore = (this.pageOf >= 1 && this.totalPages <= this.pageOf) ? true : false;
        this.loadPrev = (this.pageOf === 1) ? true : false;
        this.start = parseInt((this.pageOf - 1) * this.recordsPerPage);
        this.end = parseInt(this.start) + parseInt(this.recordsPerPage);
        this.data = this.receivedData.slice(this.start, this.end);

    }

    @wire(cpRecords) cpList({ error, data }) {
        if (data) {
            this.dataAvailable = true;
            this.receivedData = data;
            console.log(':>>' + JSON.stringify(data));
            this.start = parseInt((this.pageOf - 1) * this.recordsPerPage);
            this.end = parseInt(this.start) + parseInt(this.recordsPerPage);
            this.totalPages = Math.ceil(data.length / this.recordsPerPage);
            this.data = this.receivedData.slice(this.start, this.end);
            //this.noFPages = Math.ceil(this.records.length / pagesize);
            this.loadMore = (this.pageOf >= 1 && this.totalPages <= this.pageOf) ? true : false;
            this.loadPrev = (this.pageOf === 1) ? true : false;

        }
        if (error) {
            this.dataAvailable = false;
            console.log('Error ' + error);
        }
    }
    closeModel() {
        this.addNewRecords = false;
    }
    handleSave(event) {
        this.dataAvailable = false;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = event.detail.draftValues[0].Id;
        fields[PRICE_FIELD.fieldApiName] = event.detail.draftValues[0].SBQQ__Price__c;
        fields[QUANTITY.fieldApiName] = event.detail.draftValues[0].PSG_Quantity_EAU_Nbr__c;
        fields[EFFECTIVE_DATE.fieldApiName] = event.detail.draftValues[0].SBQQ__EffectiveDate__c;
        fields[LOWER_QTY.fieldApiName] = event.detail.draftValues[0].PSG_Lower_Qty_Nbr__c;
        fields[UPPER_QTY.fieldApiName] = event.detail.draftValues[0].PSG_Upper_Qty_Nbr__c;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contact updated',
                        variant: 'success'
                    })
                );
                // Display fresh data in the datatable
                return refreshApex(this.data).then(() => {
                    this.dataAvailable = true;
                    // Clear all draft values in the datatable
                    this.draftValues = [];

                });
            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating or reloading record',
                        message: error.body,
                        variant: 'error'
                    })
                );
            });
    }

}