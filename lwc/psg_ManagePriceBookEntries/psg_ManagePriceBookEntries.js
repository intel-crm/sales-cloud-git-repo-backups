import { LightningElement ,track,wire } from 'lwc';
import getPBE from '@salesforce/apex/PSG_ManagePricebookController.getPricebookEntries';
import getPriceList from '@salesforce/apex/PSG_ManagePricebookController.getPriceList';
import getListPrice from '@salesforce/apex/PSG_ManagePricebookController.getListPrice';
import updatePBE from '@salesforce/apex/PSG_ManagePricebookController.updatePricebookentries';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import updateLP from '@salesforce/apex/PSG_ManagePricebookController.updateListPrices';


// datatable columns
const columns = [
    {   label: 'Product(OPN)', fieldName: 'product', wrapText: true,hideDefaultActions: true,initialWidth: 200,sortable:true}, 
    //{   label: 'OPN', fieldName: 'opn',sortable: true, wrapText: true,fixedWidth: 100},
    {   label: 'List Price', fieldName: 'unitPrice',type: 'currency', editable : true,hideDefaultActions: true ,initialWidth: 120
        ,cellAttributes: {
            alignment: 'left'
        }},
    {   label: 'Disty Cost', fieldName: 'distyCost', type: 'currency', sortable:true,editable : true,hideDefaultActions: true,initialWidth: 120,cellAttributes: {
        alignment: 'left'
    }},
    {   label: 'Speed', fieldName: 'speed',editable : true,hideDefaultActions: true,initialWidth: 80,sortable:true,},
    {   label: 'Min Order Qty', fieldName: 'minimumQty', editable : true,hideDefaultActions: true,initialWidth: 80,sortable:true},
    {   label: 'Multi Order Qty', fieldName: 'multipleQty',editable : true,hideDefaultActions: true,initialWidth: 80,sortable:true},
];

const listpriceColumns =[
    {   label: 'Name', fieldName: 'range',editable : true,hideDefaultActions: true},
    {   label: 'Min Qty', fieldName: 'lbound',editable : true,hideDefaultActions: true},
    {   label: 'Max Qty', fieldName: 'Ubound',editable : true,hideDefaultActions: true},
    {   label: 'Unit Price', fieldName: 'unitPrice', type:'currency',editable : true,hideDefaultActions: true,
    cellAttributes: {
        alignment: 'left'
    }},
    {   label: 'Description', fieldName: 'decription',editable : true,hideDefaultActions: true,}
];
const options =[
    { label: '--None--', value: '' },
];
export default class Psg_ManagePriceBookEntries extends LightningElement {
    @track options=options;
    @track showListPrice = true;
    @track pbedata = [];//price book entry data
    @track lpdata =[];//list price data
    @track pbeColumns = columns;
    @track lpColumns = listpriceColumns;
    @track selectedrow;
    @track strSearchedKey;
    @track pricebookEntryId;
    @track errorMsg;
    @track noRecords;
    selectedPriceBookId;
    loaded = false;
    searchedValue;

    /*************************************SEARCH********************************* */
    handleSearch(event) {
        this.searchedValue = event.detail.value;
        console.log('strSearchedKey::'+ this.searchedValue.length);
        if(this.searchedValue.length >=3 ){
            this.strSearchedKey = event.detail.value;
        }else{
            this.errorMsg ='Enter Product Name/OPN to search with min 3 letter';
            this.pbedata = undefined;
            this.lpdata = undefined;
        }
        
    }

    /************************DROP DOWN FOR PRICEBOOK SELECTION*************************** */
    handleChange(event) {
        //this.selectedPriceBookId = event.detail.value;
        if(event.detail.value){
            this.selectedPriceBookId = event.detail.value;
        }else{
            this.errorMsg ='Select Price book to display Product/OPN(s)';
            this.pbedata = undefined;
            this.lpdata = undefined;
            this.showTable = false;
        }
    }

    
  
    /*********************************************WIRE DATA************************************************ */
    wiredPBEResult;
    wiredLPResult;

    @wire(getPBE,{strPriceBookId : '$selectedPriceBookId' , strProductName : '$strSearchedKey'})
    wirepbeData(result) {
        console.log('What stopped me getting called'+result.data+'<00>'+result.error);
        this.wiredPBEResult = result;
        if (result.data) {
            this.pbedata = result.data;
            this.showListPrice = true;
            this.errorMsg = undefined;
        } else {
            if(this.strSearchedKey){
                this.errorMsg = 'No record found';
            }
            this.pbedata = undefined;

        }
    }
    @wire(getListPrice,{strPriceBookId : '$selectedPriceBookId' , strProductName : '$strSearchedKey', strPriceBookEntryId : '$pricebookEntryId'})
    wirelpData(result) {
        this.wiredLPResult = result;
        if (result.data) {
            this.lpdata = result.data;
            this.showListPrice = true;
            this.errorMsg = undefined;
            
        } else {
            if(this.strSearchedKey){
                this.errorMsg = 'No record found';
                this.lpdata = undefined;
                this.loaded = false;
            }
            
        }
    }

    @wire(getPriceList)
    wiredPriceList({ error, data }) {
        console.log('Why am i not called'+data);
        if (data) {
            for( var i=0; i<data.length; i++) {
                console.log('id=' + data[i].Id);
                this.options = [...this.options ,{value: data[i].Id , label: data[i].Name}];                                   
            }                
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
            console.log('error'+error);
        }
    }
    
    /****************************************************HANDLE SAVE **********************************************/

    @track draftValueslp =[];
    @track draftValuespbe = [];
    handlepbeDataSave(event){        
        const updatedFields = event.detail.draftValues;
        console.log('Updated items',JSON.stringify(updatedFields)+'<---->'+'<---->'+event.detail.draftValues[0].Id);
        updatePBE({data:updatedFields })
        .then(result =>{
            console.log( JSON.stringify( "Apex update result: " + result ) );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Pirce item list updated successfully.',
                    variant: 'success'
                })
            );
            this.draftValuespbe = [];
            return refreshApex(this.wiredPBEResult);
        })
        .catch(error => {
            console.log( 'Error is ' + JSON.stringify( error ) );
            if(error && error.length > 0){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating or refreshing records',
                       // message: error.body.message,
                        variant: 'error'
                    })
                );
            }
            
        }).finally(() => {
            this.draftValuespbe = [];
        });
    }

    handlelpDataSave(event){
        console.log('Am i not getting called????');
        const updatedFields = event.detail.draftValues;
        console.log('Updated items',JSON.stringify(updatedFields)+'<---->'+'<---->'+event.detail.draftValues[0].Id);       
        updateLP({data : updatedFields})
        .then(result => {
            console.log( JSON.stringify( "Apex update result: " + result ) );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record(s) updated',
                    variant: 'success'
                })
            );
            this.noRecords = undefined;
            this.draftValueslp = [];
            return refreshApex(this.wiredLPResult);
        })
        .catch(error => {
            console.log( 'Error is ' + JSON.stringify( error ) );
            if(error){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating or refreshing records',
                        //message: error.body.message,
                        variant: 'error'
                    })
                );
            }
        }).finally(() => {
            this.draftValueslp = [];
        });

    }

    /**************************************LOAD DATA******************************************************** */
    
    loadPBEDataWithProductKey(){
        console.log('I will load the page with price book ID::'+this.selectedPriceBookId+'and product search key'+this.strSearchedKey);
        return refreshApex(this.wiredPBEResult); 
    }

    loadListPriceDataForSelectedProduct(event){
        const selectedRows = event.detail.selectedRows;
        console.log('selectedRows::'+selectedRows);
        if(selectedRows.length >0){
            this.strProductName = selectedRows[0].product;
            this.pricebookEntryId = selectedRows[0].Id;
            this.loaded = true;
            return refreshApex(this.wiredLPResult);
        }
        
    }

    get priceListOptions() {
        return this.options;
    }


    /*************************************************SORTING ****************************************/
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.pbedata];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.pbedata = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}