import { LightningElement, api, track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addressVerification from '@salesforce/apex/UCD_ACM_AddressVerificationOnReqstQueue.addressVerification';
import { NavigationMixin } from 'lightning/navigation';
export default class Ucd_UpdateAccountRequestField extends NavigationMixin(LightningElement) {
    @track spinLoad=false;
    //@track errorMessages;
    //@track org;
    _recordId;
    @api
    get recordId(){
        return this._recordId;
    }
    set recordId(value){
        this._recordId=value;
        if(this._recordId){
            this.loqateAddressVerification(this._recordId);
        }
    }
    //@api recordId;
    loqateAddressVerification(recordId){
        this.spinLoad=true;
        console.log('RecordId7 '+recordId);
        addressVerification({accountReqId:recordId})
        .then(result =>{
            this.spinLoad=false;
            console.log('Field updated16');
            console.log('@@Orurl '+result);
            if(result.startsWith('Request')){
                console.log('@Error Request3');
                this.showToastErrorMessage('error','Error!','Account Request cannot be updated once approved');
                this.navigateToRecordPage();
            }
            else{
                console.log('@Success Request');
                window.location.href = result + recordId;
                this.showToastSuccessMessage('Success !','Account Request Record has been updated successfully','success')
            }
            //this.navigateToRecordPage();
        })
        .catch(error =>{
            console.log('Eroor updating field8',error);
        });
    }
    showToastSuccessMessage(title,message,variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    showToastErrorMessage(variant,title,message){
        const eve = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message,
        });
        this.dispatchEvent(eve); 
    }
    navigateToRecordPage() {
        console.log('&&@recordId1 '+this.recordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this._recordId,
                objectApiName: 'Account_Create_Request__c',
                actionName: 'view'
            }
        });
    }
}