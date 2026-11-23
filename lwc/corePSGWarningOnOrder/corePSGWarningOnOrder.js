/*
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------- 
* Srishty Sharma           22-Jan-2020              US862469:Price & Quantity Logic of a Order Product for different types of orders
*
*/
import { LightningElement } from 'lwc';
/*import { subscribe, onError } from 'lightning/empApi'; //streaming api to subscribe to change data capture event
import validateQuantity from '@salesforce/apex/Sales_DisplayWarning.validateQuantity'; // apex method import
*/
export default class CorePSGWarningOnOrder extends LightningElement {
		/*@api objectApiName;//to get the object id from URL
		@api recordId;//to get the record id from URL
		@track showWarning = false;
    @track warningMessage;
		channelName = '/data/';
		


		connectedCallback() {
				if (this.objectApiName.endsWith('__c')) {
            // Custom object
            this.channelName = this.channelName + this.objectApiName.substring('0', this.objectApiName.length-3) + '__ChangeEvent';
        }
        else {
            // Standard object
            this.channelName = this.channelName + this.objectApiName + 'ChangeEvent';
        }
				const ci = this
				const changeDataCallback = function(response) { //callback function for change data capture event
						let modifiedRecords = response['data']['payload']['ChangeEventHeader']['recordIds'];//Retreiving the modified record ids from event data
						if(modifiedRecords.includes(ci.recordId)){ 
								ci.validateQuantityOnOrder();//calling the js method to call apex method once change data capture event is received
						}
				}
				subscribe(this.channelName, -1, changeDataCallback).then(response => { //subscribed to change data capture
            console.log('Subscribed to Platform Event Change Data');
        });
        onError(error => {
            console.log('Error in Platform Event Change Data'+JSON.stringify(error));
            console.log(error);
        });
        
				ci.validateQuantityOnOrder();
		}
		
		validateQuantityOnOrder(){
				validateQuantity({ orderId: this.recordId }) //calling apex method
						.then(result => {
						this.warningMessage = result;
						if(this.warningMessage!=null){
								this.showWarning = true;
						}
						else{
								this.showWarning = false;
						}
						this.error = undefined;
				})
						.catch(error => {
						this.error = error;
						this.warningMessage = undefined;
				});
		}*/
   
}