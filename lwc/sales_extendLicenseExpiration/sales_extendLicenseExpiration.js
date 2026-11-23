import { LightningElement,track, wire} from 'lwc';
// import server side apex class method 
import getOrdersList from '@salesforce/apex/sales_extendLicenseExpirationUtility.getOrdersList';
// import standard toast event 
import {ShowToastEvent} from 'lightning/platformShowToastEvent'
 
export default class customSearch extends LightningElement {
    searchValue = '';
	@wire(getOrdersList, {searchKey: '$searchValue'})
	orders;
    
    @track ordersRecord;
    searchValue = '';
 
    // update searchValue var when input field value change
    searchKeyword(event) {
        this.searchValue = event.target.value;
    }
 
    // call apex method on button click 
    handleSearchKeyword() {
        
        if (this.searchValue !== '') {
            getOrdersList({
                    searchKey: this.searchValue
                })
                .then(result => {
                    // set @track contacts variable with return contact list from server  
                    this.ordersRecord = result;
                })
                .catch(error => {
                   
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: error.body.message,
                    });
                    this.dispatchEvent(event);
                    // reset contacts var with null   
                    this.ordersRecord = null;
                });
        } else {
            // fire toast event if input field is blank
            const event = new ShowToastEvent({
                variant: 'error',
                message: 'Search text missing..',
            });
            this.dispatchEvent(event);
        }
    }
}