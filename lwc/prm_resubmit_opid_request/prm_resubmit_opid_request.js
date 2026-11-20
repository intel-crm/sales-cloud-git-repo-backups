import { LightningElement,api,track,wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
/*import getOPID_Ids from '@salesforce/apex/PRM_VXRecommendation_Utility.getOPID_Ids';*/
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class Resubmit_OPID_Request extends LightningElement {
@api recordId;
@track inboundMessageSize;
@track error;
@track isLoading = false;

handleonResubmit (){
    this.handleIsLoading(true);  
    /* getOPID_Ids({recId : this.recordId})
    .then(result =>{
        this.inboundMessageSize = result;
        if(this.inboundMessageSize == 0 || this.inboundMessageSize == null){
            updateRecord({ fields: { Id: this.recordId }})
            this.updateRecordView();
            this.dispatchEvent(new CloseActionScreenEvent());           
            this.showToast('Success', 'You have Resubmitted for OPID', 'success');           
            }
        else{
            this.updateRecordView();
            this.dispatchEvent(new CloseActionScreenEvent());
            this.showToast('Warning', 'OPID Already processed', 'warning'); 
            
        } 
    })
    .catch(error =>{
        this.error = error;
        this.showToast('Error Occured', this.error, 'error'); 
        this.dispatchEvent(new CloseActionScreenEvent());
    })
    .finally(()=>{
        this.handleIsLoading(false);
    });*/
    
}

handleIsLoading(isLoading) {
    this.isLoading = isLoading;
}

closeModal(){
    this.dispatchEvent(new CloseActionScreenEvent());
}

showToast(title, message, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event);
}

updateRecordView() { 
    setTimeout(() => {
        eval("$A.get('e.force:refreshView').fire();");
   }, 1000); 
}

}