import { LightningElement,api,track,wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import validateProdName from '@salesforce/apex/Core_IPS_Refresh_SupProdName_LEX.validateProdName'; 
import Core_IPS_Lightning_Base_URL from '@salesforce/label/c.Core_IPS_Lightning_Base_URL';
export default class Core_IPS_RefreshNameLEX extends NavigationMixin(LightningElement) {
@track isLoading = false;
@track currentPageReference;
url;
@wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        
}

get recordId() {
    return this.currentPageReference?.state?.recordId;
}

connectedCallback(){
 this.showPopup = true;
}

@wire(getRecord, { recordId: '$recordId' })
record;
showPopup;
errorMessage;
handleValidateProdName(){
    this.isLoading=true;
    console.log('---recordId---' +this.recordId);
    validateProdName({supProdId : this.recordId})
    .then(result => {
        console.log('---result---' +result);
        if(result==true){ 
            this.errorMessage = false;
            this.showPopup = true;
            console.log('after renaming prod ');
            this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(
               new ShowToastEvent({
                  title: 'Success',
                  message: 'Record updated Successfully!!',
                  variant: 'success'
               })
            );  
            
            
            let curul = Core_IPS_Lightning_Base_URL+'/lightning/r/Core_IPS_Supported_Product__c/'+this.recordId+'/view';
            location.replace(curul);  
        }  
           
    })
    .catch(error =>{
        //console.log('---error---' +JSON.stringify(error));
        this.errorMessage = true;
        this.showPopup = false;
   
     })
}

navigateToDetailPage(){
    this.dispatchEvent(new CloseActionScreenEvent());    
}

updateRecordView1() {
    setTimeout(() => {
         eval("$A.get('e.force:refreshView').fire();");
    }, 3000); 
 }

 //show/hide spinner
 handleIsLoading(isLoading) {
    this.isLoading = isLoading;
}

updateRecordView(recordId) {
    updateRecord({fields: { Id: recordId }});
    
}
}