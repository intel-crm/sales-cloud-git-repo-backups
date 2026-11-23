import { LightningElement,api,track,wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import validateProdName from '@salesforce/apex/Core_IPS_Refresh_SupProdName_LEX.validateProdName'; 
export default class Core_IPS_Refresh_Name_LEX extends NavigationMixin(LightningElement) {
 
@track currentPageReference;
@track currentPageReference;
@wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
}

get recordId() {
    return this.currentPageReference?.state?.c__recordId;
}

handleValidateProdName(){
    console.log('---recordId---' +this.recordId);
    //validateProdName({recordId:'$recordId'})
    validateProdName({recordId:this.recordId})
    .then(result => {
        console.log('---result---' +result);
        if(result==true){
            this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(
               new ShowToastEvent({
                  title: 'Success',
                  message: 'Record updated Successfully!!',
                  variant: 'success'
               })
            );
        }    
    })
    .catch(error =>{
        console.log('---error---' +JSON.stringify(error));
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
    console.log('---recordId---' +this.recordId);
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            objectApiName: 'Core_IPS_Supported_Product__c',
            actionName: 'view'
        }
    });    
}

}