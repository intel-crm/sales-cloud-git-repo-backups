import { LightningElement,api,wire,track} from 'lwc';
import fetchAvailCurrencies from '@salesforce/apex/Core_MDF_BulkClaimServerController.fetchAvailCurrencies';

export default class Core_MDF_BulkClaimGuidelines extends LightningElement {
    @api program;
    @track currencyList= [];
    @wire(fetchAvailCurrencies)wiredCurrencyData({data,error}) {
        if (data) {
            console.log('data',data);
            this.currencyList = data;
            console.log('currencyList',this.currencyList);
        }else if (error) {
            console.log('error',error);
        }
   }
}