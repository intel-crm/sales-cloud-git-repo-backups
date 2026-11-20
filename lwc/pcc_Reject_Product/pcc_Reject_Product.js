import { LightningElement, api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import rejectDesignReg from '@salesforce/apex/Core_ApproveRejectDR_LexController.rejectDesignReg';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import COMMENTS from '@salesforce/schema/Core_Design_Registration_Product__c.Core_Comment_Txt__c';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import User_Name from '@salesforce/schema/User.Name';

const fields = [COMMENTS];

export default class pcc_Reject_Product extends LightningElement {
   @api recordId;
   @api objectApiName;
   isLoading = false;
   @track comments = '';
   @track showRejectReason =false;
   success = false;
   failed = false;
   alertMsg ='';
   UserName='';

   @wire(getRecord,{recordId:USER_ID,fields:[User_Name]})

   wiredUser({error,data}){
    if(data){
        this.UserName=data.fields.Name.value;
    }else if(error){
        console.error('Error retrieving user data: ',error);}
    }


   handleReasonChange(event){
    const currentDate = new Date().toLocaleDateString();
    const username = this.UserName;
    if(event.detail.value){
    this.comments = currentDate + " " + username + " : " + event.detail.value; }  
    else{
        this.comments = null;
    }
   }

    handleSaveButton(){
        this.showRejectReason = false;
        this.isLoading = true;
        if(this.recordId != null){
                if(!this.comments){
                this.isLoading = false;
                this.showToast('Error','Please enter the comments before rejecting','error');
                
            }else if(this.comments.length > 0){
                var desRegId = this.recordId.toString();
                rejectDesignReg({drId : desRegId, rejComments : this.comments})
            .then(result => {
                this.success = true;
                this.isLoading =false;
                
                this.alertMsg =result;
                console.log(this.alertMsg); 
                getRecordNotifyChange([{recordId: this.recordId}]);
            })
            .catch(error => { 
                this.failed = true;
                this.showToast('Failed!','There was some error while rejecting product!','Error');
            });
        }
            }
            
    }

   closeQuickAction() {
    
   this.dispatchEvent(new CloseActionScreenEvent());
}

   showToast(title, message, variant) {
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(evt);
}
}