import { LightningElement ,track,wire } from 'lwc';
import getPBE from '@salesforce/apex/PSG_ManagePricebookController.getPricebookEntries';
import getPriceList from '@salesforce/apex/PSG_ManagePricebookController.getPriceList';
import getListPrice from '@salesforce/apex/PSG_ManagePricebookController.getListPrice';
import updatePBE from '@salesforce/apex/PSG_ManagePricebookController.updatePricebookentries';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import updateLP from '@salesforce/apex/PSG_ManagePricebookController.updateListPrices';
import { NavigationMixin } from 'lightning/navigation';


// datatable columns
const columns = [
    {   label: 'Product(OPN)', fieldName: 'product', wrapText: true,hideDefaultActions: true,initialWidth: 180,sortable:true,
        typeattribute :{
            label: {
                fieldName: 'Id'
            },
            target :'_blank'
        }}, 
        {   label: 'Product Name', fieldName: 'prodUrl',type:'url',wrapText: true, editable : false,hideDefaultActions: true,initialWidth: 140,sortable:true,typeAttributes: {
            label: {
                fieldName: 'prodName'
            },
            target: '_blank'
        },},
    {   label: 'Active', fieldName: 'prodActive',type:'boolean',editable : false,hideDefaultActions: true,initialWidth: 80,sortable:true,ellAttributes: {
        alignment: 'right'
    }},
    {   label: 'Disty Cost', fieldName: 'distyCost', type: 'currency', sortable:true,editable : true,hideDefaultActions: true,initialWidth: 120,cellAttributes: {
        alignment: 'left'
    }},
    {   label: 'Min Order Qty', fieldName: 'minimumQty', editable : true,hideDefaultActions: true,initialWidth: 120,sortable:true},
    {   label: 'Multi Order Qty', fieldName: 'multipleQty',editable : true,hideDefaultActions: true,initialWidth: 120,sortable:true},
    {
        label: 'View',
        type: 'button-icon',
        initialWidth: 75,
        typeAttributes: {
            iconName: 'action:preview',
            title: 'Preview',
            variant: 'border-filled',
            alternativeText: 'View'
        },
        cellAttributes: {
            alignment: 'Center'
        }
    },
];

const listpriceColumns =[
    {   label: 'Range', fieldName: 'range',editable : false,hideDefaultActions: true,initialWidth: 120,cellAttributes: {
        alignment: 'left'
    }},
    {   label: 'Min Qty', fieldName: 'lbound',editable : false,hideDefaultActions: true,initialWidth: 120,cellAttributes: {
        alignment: 'left'
    }},
    {   label: 'Max Qty', fieldName: 'Ubound',editable : false,hideDefaultActions: true,initialWidth: 120,cellAttributes: {
        alignment: 'left'
    }},
    {   label: 'Unit Price', fieldName: 'unitPrice', type:'currency',editable : true,hideDefaultActions: true,initialWidth: 120,
    cellAttributes: {
        alignment: 'left'
    }},
    {
        label: 'View',
        type: 'button-icon',
        initialWidth: 120,
        typeAttributes: {
            iconName: 'action:preview',
            title: 'Preview',
            variant: 'border-filled',
            alternativeText: 'View'
        },
        cellAttributes: {
            alignment: 'Center'
        }
    },
];
const options = [];
export default class Psg_ManagePriceBookEntries extends NavigationMixin(LightningElement) {
    @track options=options;
    @track pbedata = [];//price book entry data
    @track lpdata =[];//list price data
    @track pbeColumns = columns;
    @track lpColumns = listpriceColumns;
    @track selectedrow;
    @track strSearchedKey ='';
    @track pricebookEntryId;
    @track errorMsg;
    @track errors ={};
    selectedPriceBookId;
    searchedValue;

    /*************************************SEARCH********************************* */
    handleSearch(event) {
        this.searchedValue = event.detail.value;
        console.log('strSearchedKey::'+ this.searchedValue.length +'selectedPriceBookId'+this.selectedPriceBookId);

        let searchValue = this.searchedValue.length;
        this.lpdata = undefined;
        if(this.selectedPriceBookId){
            if(searchValue < 3){
                if(searchValue > 0){
                   this.strSearchedKey = undefined;
                   console.log('searchValue::'+searchValue);
                   this.errorMsg ='Enter Product Name/OPN to search with min 3 letters';
                   this.pbedata = undefined;
                }else{
                   this.errorMsg = undefined;
                   this.strSearchedKey = ''; 
                   return refreshApex(this.wiredPBEResult);
                }
                    
           }else{
                   console.log('Success::'+searchValue);
                   this.strSearchedKey = event.detail.value;
                   this.pbedata = undefined;
                   this.pricebookEntryId = undefined;
                   this.errorMsg = undefined;
           }
        }else{
            this.errorMsg = 'Select Price Book';
        }
    }

    /************************DROP DOWN FOR PRICEBOOK SELECTION*************************** */
    handleChange(event) {
        this.lpdata = undefined;
        this.pbedata = undefined;
        this.pricebookEntryId = undefined;
        this.errorMsg = undefined;
        this.pbedata = undefined;
        this.lpdata = undefined;
        if(event.detail.value){
            this.selectedPriceBookId = event.detail.value;
        }else{
            this.errorMsg ='Select Price book and OPN to display Price list Item(s)';
            this.strSearchedKey = undefined;
            this.showTable = false;
        }
    }

    
  
    /*********************************************WIRE DATA************************************************ */
    wiredPBEResult;
    wiredLPResult;

    @wire(getPBE,{strPriceBookId : '$selectedPriceBookId' , strProductName : '$strSearchedKey'})
    wirepbeData(result) {
        this.wiredPBEResult = result;
        if (result.data) {
            this.pbedata = result.data;
            this.errorMsg = undefined;
            console.log('Inside Wired getPBEcount record returned:: '+result.data.length);
            if(result.data.length == 0){
                this.errorMsg = 'No price list item(s) to display.';
            }
        } else {
            this.pbedata = undefined;
            this.errorMsg = undefined;
        }
    }
    @wire(getListPrice,{strPriceBookId : '$selectedPriceBookId' , strProductName : '$strSearchedKey', strPriceBookEntryId : '$pricebookEntryId'})
    wirelpData(result) {
        this.wiredLPResult = result;
        if (result.data) {
            console.log('Inside Wired getListPrice count record returned:: '+result.data.length);
            this.lpdata = result.data;
            this.errorMsg = undefined;
            if(result.data.length == 0){
                this.errorMsg = 'No Volume Discount item(s) to display for the selected price list item.';
            }
        } else {
            this.lpdata = undefined;
            this.errorMsg = undefined;
        }
    }

    @wire(getPriceList)
    wiredPriceList({ error, data }) {
        console.log('Inside Wired getPriceList');
        if (data) {
            console.log('Inside Wired getPriceList data length'+data.length);
            for( var i=0; i<data.length; i++) {
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
        updatePBE({pbeWrapperforUpdate:updatedFields })
        .then(result =>{
            console.log( JSON.stringify( "Apex update result: " + result ) );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Price item list updated successfully.',
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
                        variant: 'error'
                    })
                );
            }
            
        }).finally(() => {
            this.draftValuespbe = [];
        });
    }

    handlelpDataSave(event){
        
        const updatedFields = event.detail.draftValues;
        console.log('Updated items',JSON.stringify(updatedFields)+'<---->'+'<---->'+updatedFields.length);  
        const updatedRecords =[];
        for(let index = 0 ; index < updatedFields.length ;index++){
            updatedRecords.push(updatedFields[index]);

        }
        console.log('updatedRecords'+JSON.stringify(updatedRecords)+'<==>'+updatedRecords.length);

        updateLP({lpWrapperforUpdate : updatedRecords})
        .then(result => {
            console.log( JSON.stringify( "Apex update result: " + result ) );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record(s) updated',
                    variant: 'success'
                })
            );
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
        //console.log('I will load the page with price book ID::'+this.selectedPriceBookId+'and product search key'+this.strSearchedKey);
        return refreshApex(this.wiredPBEResult); 
    }

    loadListPriceDataForSelectedProduct(event){
        const selectedRows = event.detail.selectedRows;
        console.log('selectedRows::'+selectedRows);
        if(selectedRows.length >0){
            this.strProductName = selectedRows[0].product;
            this.pricebookEntryId = selectedRows[0].Id;
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

    /*****************************************NAVIGATION********************************* */
    recordId ;
    objectApiName;
    handleRowAction(event) {
        const row = event.detail.row;
        this.recordId = row.Id;
        this.ObjectApiName = 'core_cpq_list_price__c';
        console.log('rowID::'+JSON.stringify(row));
        this.navigateToRecordPage(this.ObjectApiName,this.recordId)
    }

    handlePBERowAction(event){
        const row = event.detail.row;
        this.recordId = row.Id;
        this.ObjectApiName = 'pricebookentry';
        console.log('rowID::'+JSON.stringify(row));
        this.navigateToRecordPage(this.ObjectApiName,this.recordId)
    }
    navigateToRecordPage(ObjectApiName,recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: ObjectApiName,
                actionName: 'view'
            }
        });
    }  
    
    
    /*******************************************ERROR HANDLING**************************** */
    triggerError(rowId) {
        const _errors = {
            rows: {
                ...this.errors.rows, [rowId]: {
                    title: 'Price cannot be negative value',
                    messages: ['Enter a valid amount.'],
                    fieldNames: ['unitPrice']
                }
            },
            table: {
                title: 'Your entry cannot be saved. Fix the errors and try again.',
                messages: ['We found 1 error. ...', 'Error on unitPrice amount']
            }
        };

        this.errors = _errors;

    }

    handleCellChange(event) {

        const rowId = event.detail.draftValues[0].id
        let fieldName;
        console.log("draftValues = ", JSON.stringify(event.detail.draftValues[0]));

        const unitPrice = parseFloat(event.detail.draftValues[0].unitPrice);
    }

    removeRowError(rowId) {
        if (rowId) {
            delete this.errors.rows[rowId];
        }
    }
}