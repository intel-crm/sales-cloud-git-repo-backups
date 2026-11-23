import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

//import approveAccountChangeRequest from "@salesforce/apex/UCD_ACM_UpdateAccountChnageRequest.approveAccountChangeRequest";
import {NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UCD_ACM_ApproveAccountChangeReq extends NavigationMixin(LightningElement) {

   /* @track _recordId;
    @track isLoading = false;
    @api 
    get recordId(){
        return this._recordId;
    }
    set recordId(value){
        this.setAttribute('recordId',value);
        this._recordId = value;
        console.log('recordId--> ',this._recordId);
        this.isLoading = true;
        approveAccountChangeRequest({recId:this._recordId})
        .then((result)=>{
            
            this.isLoading = false;
            console.log('recordId inside cond--> ',this._recordId);

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                  recordId: this._recordId,
                  objectApiName: 'Account_Create_Request__c',
                  actionName: 'view',
                },
              });
              if(result){
                const evt = new ShowToastEvent({
                    title: 'Done!',
                    message: 'Your record is approved',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
            }else{
                const evt = new ShowToastEvent({
                    title: 'Error!',
                    message: 'Your record is not approved',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
             
            eval("$A.get('e.force:refreshView').fire();")

        })

    }
    
    /*connectedCallback(){
        
    }*/
}