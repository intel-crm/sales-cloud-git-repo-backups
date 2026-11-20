import { LightningElement , api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {  getRecordNotifyChange } from 'lightning/uiRecordApi';
import ChangeOppoOwner from '@salesforce/apex/Core_OpportunityTakeOwnerController.ChangeOppoOwner';

export default class OpportunityTakeOwnership extends LightningElement {
    @api recordId ;
    renderedCallback() {
        
        console.log('in render:');
        ChangeOppoOwner({oppoId: this.recordId  })
        .then((Opportunity) => {
            
            const event = new ShowToastEvent({
                title: 'Success',
                message: 'Opportunity Claimed successfully',
                variant: 'success',
            });
            this.dispatchEvent(event);
             
           getRecordNotifyChange([{recordId: this.recordId}]);
           const closeevent = new CustomEvent("popupclose");
           this.dispatchEvent(closeevent);
            console.log('get notify:'+getRecordNotifyChange([{recordId: this.recordId}]));
        })
     
        .catch((error) => {
            console.log('Error::'+error);
            const event = new ShowToastEvent({
                title: "Error on update",
                message: error.body.message,
                variant: "error",
                mode: 'sticky',
            });
            this.dispatchEvent(event);
        });
       
    }
  
}