import { LightningElement, wire, track } from 'lwc';
import actList from '@salesforce/apex/testtable.accountList';
export default class Resizable_table_columns extends LightningElement {
    @track data;
    @wire(actList)
    accounts(result) {
        if (result.data) {
            this.data = result.data;
            console.log(JSON.stringify(this.data));
            this.error = undefined;

        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }
}