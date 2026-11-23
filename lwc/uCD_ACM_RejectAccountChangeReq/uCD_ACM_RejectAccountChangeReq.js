import { LightningElement,api,wire,track} from 'lwc';

import rejectAccountChangeRequest from "@salesforce/apex/UCD_ACM_UpdateAccountChnageRequest.rejectAccountChangeRequest";
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { refreshApex } from '@salesforce/apex';

export default class UCD_ACM_RejectAccountChangeReq extends NavigationMixin(LightningElement) {
    @track rejectionReason;
    @track _recordId;
    @track isLoading = false;
    @api 
    get recordId(){
        return this._recordId;
    }
    set recordId(value){
        this.setAttribute('recordId',value);
        this._recordId = value;
        console.log('recordId--> ',this._recordId);
        
    }

    handleOnChange(event){
      this.rejectionReason = event.target.value;
      console.log('this.rejectionReason--> ',this.rejectionReason);
    }
    handleSave(event){
      this.isLoading = true;
      console.log('this.rejectionReason--> ',this.rejectionReason);
        rejectAccountChangeRequest({recId:this._recordId,rejectionReason:this.rejectionReason})
        .then((result)=>{
          console.log('result--> ',result);
            this.isLoading = false;
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                  recordId: this._recordId,
                  objectApiName: 'Account_Create_Request__c',
                  actionName: 'view',
                },
              });
              refreshApex();
              this.dispatchEvent(new CloseActionScreenEvent());
              this.dispatchEvent(
                new ShowToastEvent({
                title: 'Done!',
                message: 'Your record is rejected',
                variant: 'success',
            }));
            eval("$A.get('e.force:refreshView').fire();")
        });
    }
    
    handleCancel(event){
      this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
          recordId: this._recordId,
          objectApiName: 'Account_Create_Request__c',
          actionName: 'view',
        },
      });
    }

}