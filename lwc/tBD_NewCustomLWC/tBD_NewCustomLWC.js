import { LightningElement, api, wire,track } from 'lwc';
import fetchDealProductExtract from '@salesforce/apex/PCC_DealProductExtract.fetchDealProductExtract';
import fetchDealProdType from '@salesforce/apex/PCC_DealProductExtract.fetchDealProductExtract';
import NAME_FIELD from '@salesforce/schema/Core_Design_Registration_Product__c.Name';
export default class TBD_NewCustomLWC extends LightningElement {
  //  fields = [NAME_FIELD];
   @api message;
   searchTerm = '';
   @track recordId = '';
   searchResults = [];
   //@track filterSearchResults = [];
   @track isFinancialProduct;
   @track selectedProductId;
   timer;
   @api recordTypeA = '012Df000003baOX';
    // connectedCallback(){
    //     //handleDealProductSelection(event){
    //         this.retrieveMessage();
    // }

    handleSearchChange(event) {
        window.clearTimeout(this.timer)
        this.searchTerm = event.target.value.toLowerCase();
        //this.filterSearchResults = this.values.filter(value => value.toLowerCase().includes(searchTerm));
        this.timer = setTimeout(()=>{
            this.fetchSearchResults()
        }, 1000)
        
    }

    fetchSearchResults() {
        console.log('Inside retrieve');
        if (this.searchTerm) {
            fetchDealProductExtract({searchTerm : this.searchTerm})
                .then(result => {
                    console.log('result',result);
                    this.searchResults = result; 
                })
                .catch(error => {
                    console.error('Error retrieving message:', error);
                });
        }
        else {
            this.searchResults = [];
        }
    }

    handleSelectedProduct(event){
        console.log('Clicked list item:', event.currentTarget); 
        console.log('Data ID:', event.currentTarget.dataset.id);
        this.searchTerm = event.target.innerText;
        this.selectedProductId = event.currentTarget.dataset.id;  
        this.searchResults = [];
    }

    handleSubmitProduct(){
        console.log('Inside handleSubmitProducts');
        fetchDealProdType({ recId: this.selectedProductId})
        .then(result => {
            console.log('this.selectedProductId result --',result);
            const booleanResult = Array.isArray(result) ? result[0] : result;
            this.isFinancialProduct = true;
           // this.recordId = 'aE0Df000000CcJ7KAK';
            console.log('Is Fin Product in Handle --',this.isFinancialProduct);
            // createRecord({
                
            //     apiName: 'Core_Design_Registration_Product__c',
            //     fields: {
                    
            //         Name: 'New Record Name',
                    
            //     },
            //     recordTypeId: '012Df000003baOXIAY' 
            // })
            // .then(result => {
            //     console.log('Inside Create record');
            //     this.newRecordId = result.id;
            //     this.recordTypeId = '012Df000003baOXIAY';
            // })
        })
        .catch(error => {
            this.error = error;

        });
        
    }

    handleRecordFormSubmit(event){
        console.log('New or updated Record Id:', recordId);
    }
}