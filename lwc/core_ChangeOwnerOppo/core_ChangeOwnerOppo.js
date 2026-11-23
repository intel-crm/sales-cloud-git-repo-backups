import { LightningElement , api, wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import ChangeOppoOwner from '@salesforce/apex/Core_OpportunityTakeOwnerController.ChangeOppoOwner';
import {  getRecordNotifyChange } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';

export default class Core_ChangeOwnerOppo extends NavigationMixin(LightningElement)  {
     @api recordId;
     @track loaded = true;
    //loaded = false;
  /*   @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.loaded = true;
            this.recordId = currentPageReference.state.recordId;
            console.log('this.recordId::'+this.recordId);
        }
    } */
    connectedCallback() {
        this.loaded = true;
        console.log('this callabck::',this.recordId);

        ChangeOppoOwner({oppoId: this.recordId})
        .then(result =>{
                console.log('this.success::'+this.loaded);
                 getRecordNotifyChange([{recordId: this.recordId}]);
                // this.dispatchEvent(new CloseActionScreenEvent());
                const event =    new ShowToastEvent( {
                title: 'Success',
                message: 'Opportunity Claimed successfully!!',
                variant: 'success'
                });
                
                this.dispatchEvent(event);
                this.loaded = false;
                console.log('this.success2::'+this.loaded);
                console.log('this.success2::'+event);
            })
            .catch(error =>{
                console.log('this.error::'+this.error);
                this.loaded = false;               
                const event =   new ShowToastEvent( {
                title: "Error on update",
                message: "Error on update!",
                variant: "error",
                mode: 'sticky',
                });
             //  this.dispatchEvent(event);

        });
     }
    /* onClose(){
         this.loaded = false;
         console.log('this.close::');
         this.dispatchEvent(new CloseActionScreenEvent());
     }*/

}