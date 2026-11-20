import { LightningElement,api,track,wire } from 'lwc';
import Remove_PSO from '@salesforce/label/c.Remove_PSO';
import Remove_PSO_Confirmation from '@salesforce/label/c.Remove_PSO_Confirmation';
import Remove_PSO_Success_Alert from '@salesforce/label/c.Remove_PSO_Success_Alert';
import Remove_PSO_Failure_Alert from '@salesforce/label/c.Remove_PSO_Failure_Alert';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord } from 'lightning/uiRecordApi';
import runBatchfromLWC from '@salesforce/apex/Core_IPS_RemovePSO_Batch_Handler_LEX.runBatchfromLWC'; 

export default class Core_IPS_RemovePSO_LEX extends NavigationMixin(LightningElement) {
@track isLoading = false;
@track currentPageReference;
label = {
        Remove_PSO,
        Remove_PSO_Confirmation,
        Remove_PSO_Success_Alert,
        Remove_PSO_Failure_Alert
    };

@wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        
}
get recordId() {
    return this.currentPageReference?.state?.recordId;
}

@wire(getRecord, { recordId: '$recordId' })
record;

handleRunBatchFromLWC(event){
    this.isLoading=true;
   
    runBatchfromLWC({ContactIdVar : this.recordId})
    .then((result)=>{
       

        this.dispatchEvent(new CloseActionScreenEvent());
        if(result){
        this.dispatchEvent(
               new ShowToastEvent({
                  title: 'Success',
                  message: Remove_PSO_Success_Alert,
                  variant: 'success'
               })
            );
        }
        else{
            this.dispatchEvent(
               new ShowToastEvent({
                  title: 'info ',
                  message: Remove_PSO_Failure_Alert,
                  variant: 'info'
               })
            ); 
        }
          
    })
    .catch(error =>{
      
        this.dispatchEvent(
               new ShowToastEvent({
                   title: 'Error!',
                   message: 'Something went wrong. Check your record',
                   variant: 'error'
                })
        )
    })
}
navigateToDetailPage(){
  
    this.dispatchEvent(new CloseActionScreenEvent());    
}

 //show/hide spinner
 handleIsLoading(isLoading) {
    this.isLoading = isLoading;
}

 //show/hide spinner
 handleIsLoading(isLoading) {
    this.isLoading = isLoading;
}


}