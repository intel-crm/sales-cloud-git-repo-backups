import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class Core_SolArea_Delete extends LightningElement {
   @api recordId;
   @api objectApiName;
 

   handleSuccess(e) {
        // Close the modal window and display a success toast
        this.dispatchEvent(new CloseActionScreenEvent());
        this.isDeleted__c = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Solution Marked as Delete!',
                variant: 'success'
            })
        );
   }

}