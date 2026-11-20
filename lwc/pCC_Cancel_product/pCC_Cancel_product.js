import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Core_Design_Registration_Product__c.Core_Design_Product_Status_Nm__c';
import cancelProductMethod from '@salesforce/apex/Core_DDR_Cancel_Product_Controller.cancelProduct';
import updatingComments from '@salesforce/apex/Core_DDR_Cancel_Product_Controller.updatingComments';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import COMMENTS from '@salesforce/schema/Core_Design_Registration_Product__c.Core_Comment_Txt__c';
import USER_ID from '@salesforce/user/Id';
import User_Name from '@salesforce/schema/User.Name';

const fields = [COMMENTS];

export default class PCC_Cancel_product extends LightningElement {
    @api recordId;
    @track comments = '';
    status;
    alertMsg='';
    cancelButton=true;
    otherAlert=false;
    cancelledProduct = false;
    expiredProduct = false;
    exception = false;
    success = false;
    showCommentsPopup = false;
    firstRun=true;
    disableSave=false;
    UserName='';

    @wire(getRecord,{recordId:USER_ID,fields:[User_Name]})

    wiredUser({error,data}){
    if(data){
        this.UserName=data.fields.Name.value;
    }else if(error){
        console.error('Error retrieving user data: ',error);}
    }
    
    @track isLoading = true;
    handleReasonChange(event){
        const currentDate = new Date().toLocaleDateString();
        const username = this.UserName;
        if (event.detail.value){
            this.comments = currentDate + " " + username + " : " + event.detail.value;
        }
        else {
            this.comments = undefined;
        }
       }
       @wire(getRecord, {
        recordId: "$recordId",
        fields: [
            STATUS_FIELD
        ]
    })
    loadFields({ error, data }) {
        if(this.firstRun){
            if(data){
                this.otherAlert=true;
                this.showCommentsPopup = false;
                this.status = getFieldValue(data, STATUS_FIELD);            
                if (this.status == 'Cancelled') {
                    this.isLoading = false;
                    this.cancelledProduct = true;
                }
                if (this.status == 'Expired') {
                    this.isLoading = false;
                    this.expiredProduct = true;
                }else{
                    cancelProductMethod({ recId: this.recordId })
                .then(result => {
                    this.isLoading = false;
                    var retValue = result;
                    console.log('return val;ue',retValue);
                    if(retValue){
                    this.alertMsg = retValue;
                }
                else{
                    this.cancelButton=false;
                    this.showCommentsPopup=true;
                }
                })
                .catch(error => {
                    this.isLoading = false;
                    this.exception = true;
                    console.error('Error occurred while calling Apex method:', error);
                });
                
            }
        }
        else if (error) {
            this.isLoading = false;
            this.exception = true;
            console.error('Error occurred while retrieving record:', error);
        }}
        }
        
        handleSaveButton(){
            this.otherAlert=false;
            
        if(this.recordId != null){
            if( this.comments === undefined || this.comments == null || this.comments == ''){
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Comments are Mandatory',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
                this.isSpinner = false;

            }else if(this.comments.length > 0)
            {
                this.isLoading = true;
                updatingComments({ recId: this.recordId, cancelComments : this.comments})
            .then(result => {
                this.isLoading = false;
                this.firstRun=false; 
                this.success = true;
                this.showCommentsPopup=false;
                this.otherAlert=true;
                this.cancelButton=true;
                this.disableSave=true;
                console.log('line117'); 
                //this.sendClosePopupToAura();
                getRecordNotifyChange([{recordId: this.recordId}]);
            })
            .catch(error => { 
                this.isLoading = false;
                this.failed = true;
                console.log('error while processing'+error);
                const event = new ShowToastEvent({
                    title: 'Failed!',
                    message: 'There was some error while cancelling product!',
                   variant: 'Error'
                });
                this.dispatchEvent(event);
            });
        }
    }

    }

    sendClosePopupToAura() {
        const booleanEvent = new CustomEvent('sendClosePopup');
        this.dispatchEvent(booleanEvent);
    }
}