import { LightningElement, track, wire, api } from 'lwc';
import submitRegistrationDetails from '@salesforce/apex/ER_Lead_Request_to_Eloqua.submitRegistrationDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import EloquaLabel from '@salesforce/label/c.Eloqua_Label';

export default class ER_Lead_Request_to_Eloqua extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @track isLoading = false;
    @track error;
    @track leadId;
    
    label = {
        EloquaLabel
    };

    leadCreation() {
        this.isLoading = true;
        console.log("test recordId: "+this.recordId);
        submitRegistrationDetails({requestId : this.recordId})
        .then(result => {
          this.leadId = result;
          console.log("test result: "+result);
          
          if(result == null){
            const event = new ShowToastEvent({
            
                message: 'Lead is already Present!!!',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            this.closeAction();
          }
          else{
           
            const event = new ShowToastEvent({
            
                message: 'Lead Created Successfully!',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            this.redirectTolead();
        }
          
     })
        .catch(error => {
            this.isLoading = false;
            this.error = error;
            console.log("error-: "+JSON.stringify(error));
            const evt = new ShowToastEvent({
                
                message: 'Error! Record does not found!',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.closeAction();
        });
    }

    redirectTolead() {
        console.log("in close");
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.leadId,    
                objectApiName: 'Core_Lead_Staging__c',      
                actionName: 'view'
            }
        });
     }

     closeAction() {
        console.log("in close");
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'PRM_Registration_Request__c',
                actionName: 'view'
            }
        });
     }
        
}