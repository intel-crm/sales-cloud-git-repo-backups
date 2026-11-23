import { LightningElement, track, wire, api } from 'lwc';
import hasIDCBusinessOps from '@salesforce/customPermission/SWS_IDC_Business_Ops';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
//import hasInquiryPermissionSet from '@salesforce/customPermission/Inquiry_Permission_Set';

export default class SWS_EmailMessage_DeleteButton_Error extends LightningElement {
    @track showMessage = false;
    @track message = '';
    isLoading = false;   
    
    get isDeleteRestricted(){
        this.isLoading = true;
        if(hasIDCBusinessOps){
            this.isLoading = false;
            this.showMessage = true;
            this.message = 'You do not have permission to delete this record.';
        }
        return hasIDCBusinessOps;
        //return hasIDCBusinessOps || hasInquiryPermissionSet;
    }



    /*@wire(getRecord, {
        recordId: USER_ID,
    })
    wiredRecord({error,data}){
        console.log(data);
        if(data){
            this.recordId = data.id;
            console.log("record id", recordId);
        }
        else{
            console.log(error);
        }
    }
    user;

    handleDelete() {
        console.log("record restricted", recordId)
        if (this.isDeleteRestricted.recordId) {
        console.log(recordId);
            this.showMessage = true;
            this.message = 'You do not have permission to delete this record.';
            return;
        }

        this.isLoading = false;
    }*/
}