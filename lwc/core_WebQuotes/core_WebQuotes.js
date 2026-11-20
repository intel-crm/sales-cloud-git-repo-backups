import { LightningElement,api,wire,track } from 'lwc';
import pullWebQuotes from '@salesforce/apex/Core_WebQuotesController.pullWebQuotes';
const columns = [
    { label: 'RFQ ID',
    fieldName: 'quote_link',
    type: 'url',
    typeAttributes: { label: { fieldName: 'quote_name' }, target: '_blank' },initialWidth: 180},
    { label: 'Creation Type', fieldName: 'creation_type', type: 'string' ,initialWidth: 180},
    { label: 'Creator', fieldName: 'creator', type: 'string' ,initialWidth: 180},
    { label: 'Product Description', fieldName: 'prd_dsc', type: 'string' ,initialWidth: 180},
    { label: 'DPA Number', fieldName: 'dpa_number', type: 'string' ,initialWidth: 180},
    { label: 'DPA Valid From', fieldName: 'dpa_vld_fr_dt', type: 'string' ,initialWidth: 180},
    { label: 'DPA Expiry Date', fieldName: 'dpa_expr_dt', type: 'string' ,initialWidth: 180},
    { label: 'Approved Quantity', fieldName: 'approved_quantity', type: 'string' ,initialWidth: 180},
    { label: 'Disti Cost/Intel Price', fieldName: 'disti_cost', type: 'decimal' ,initialWidth: 180},
    { label: 'Approved Price', fieldName: 'aprv_prc', type: 'string' ,initialWidth: 180},
];
export default class Core_WebQuotes extends LightningElement {
    @api recordId;
    @track webQuotes=[];
    @track result = [];
    countWebqoute;
    itemCount;
    columns = columns;
    noData=true;
    bQuotesErrorFlag=false;
    bQuotesErrorMessage;
   
//using @wire with dynamic parameters to get the WebQuotes
   @wire(pullWebQuotes,{OppId: '$recordId'}) WebQuotes({ error, data }) {
       if (data) {
           this.result = data;
           this.webQuotes=this.result.WebQuoteList === undefined ? [] : this.result.WebQuoteList;
           this.bQuotesErrorFlag=this.result.bQuotesErrorFlag === undefined ? false : this.result.bQuotesErrorFlag;
           this.bQuotesErrorMessage=this.result.bQuotesErrorMessage;
           console.log('data'+JSON.stringify(this.data));
           if(this.bQuotesErrorFlag === false){
                this.countWebqoute='('+this.webQuotes.length+')';
           }
           this.itemCount=this.webQuotes.length===1? '1 item' : this.webQuotes.length + ' items';
           if(this.webQuotes.length === 0){
                this.noData=true;
           }else{
            this.noData=false;

           }
       } else if (error) {
           this.error = error;
        }
   }
}