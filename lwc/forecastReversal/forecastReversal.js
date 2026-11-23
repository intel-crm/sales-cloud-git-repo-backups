import { LightningElement,api, track } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import reverseForecast from '@salesforce/apex/Core_OpportunityForecastController.changeRTForCancelForecast';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
export default class ForecastReversal extends LightningElement {
    //To hold Account Record Id
@api recordId;

confirmationMsg = 'Are you sure you want to unlock?';
successMsg = 'Sucess';
errorMsg = 'Application Error';
@track isModalOpen = false;
@track isLoading = false;

handleClick() {
    // to open modal set isModalOpen tarck value as true
    this.isModalOpen = true;
}

closeModal() {
    // to close modal set isModalOpen tarck value as false
    this.isModalOpen = false;
}
unlockForecast(){
    this.isLoading = true;
    reverseForecast({forecastID: this.recordId})
                        .then((result) => {
                            console.log('**test**',result);
                            if(result=='Success'){
                                
                                    const evt = new ShowToastEvent({
                                        title: 'Success',
                                        message: this.successMsg,
                                        variant: 'success',
                                        mode: 'dismissable'
                                    });
                                    this.dispatchEvent(evt);
                                    // Notify LDS that you've changed the record outside its mechanisms.
                                    getRecordNotifyChange([{recordId: this.recordId}]);
                                    this.isLoading = false; 
                                    eval("$A.get('e.force:refreshView').fire();");
                            }
                            else{
                                this.isLoading = false;
                                //show application error or valid error
                                const evt = new ShowToastEvent({
                                    title: 'Error',
                                    message: result,
                                    variant: 'error',
                                    mode: 'dismissable'
                                });
                                this.dispatchEvent(evt);
                                
                            } })
                        .catch((error) => {//show application error
                            this.isLoading = false;
                            console.log('**error**',error);
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: this.errorMsg,
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        });
                        this.isModalOpen = false;
                    }

}