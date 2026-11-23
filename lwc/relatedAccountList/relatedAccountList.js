import { LightningElement, api, wire, track } from 'lwc';
import fetchRelatedAccounts from '@salesforce/apex/UCD_RelatedAccountController.fetchRelatedAccounts';

export default class RelatedAccountList extends LightningElement {

    @api recordId;
    @track accounts = [];
    @track count = 0;
    @track displayData = false;

    @wire(fetchRelatedAccounts, { accountChangeReviewId: '$recordId' })
    wiredAccounts({ error, data }) {
        if (data) {
            console.log('check data : ',data);


            if(data != undefined && data != '' && data.count >= 0){
                this.displayData = true;
                this.accounts = data;
                this.count = this.accounts.count;
            } else {
                this.displayData = false;
            }
        } else if (error) {
            console.log('check error : ',error);
            //todo handle error
        } else {
            this.displayData = false;
        }
    }
}