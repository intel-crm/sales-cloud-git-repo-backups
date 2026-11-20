import {LightningElement,wire,track,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import regreqApproveRejectNew from '@salesforce/apex/PRM_Registration_Req_Approve_Reject.regreqApproveRejectNew';
import fetchApprovalRecord from '@salesforce/apex/PRM_Registration_Req_Approve_Reject.fetchApprovalRecord';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import STATUS from '@salesforce/schema/PRM_Registration_Request__c.PRM_Status__c';
import REG_REQ_APPROVED from '@salesforce/label/c.PRM_Reg_Req_Approved';
import REG_REQ_REJECTED from '@salesforce/label/c.PRM_Reg_Req_Rejected';
import APPROVED from '@salesforce/label/c.PRM_Status_Approved';
import NEW from '@salesforce/label/c.PRM_Status_New';
import REJECTED from '@salesforce/label/c.PRM_Status_Rejected';
import PRM_CDB_ValidationInProgress from '@salesforce/label/c.PRM_CDB_Company_Validation_In_Progress_Msg';
import checkCompanyValidationStatus from '@salesforce/apex/PRM_Registration_Req_Approve_Reject.checkCompanyValidationStatus';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

const fields = [STATUS];
export default class Prm_RegReq_Rejection extends LightningElement {
    @api recordId;
    isSpinner = false;
    recordDetail;
    @track comments = '';
    showRejectReason =false;
    @track formMessage;
    displayOtherReasonField = false;
    status;
    callFetchApproval = true;
    @track resultdata;

    renderedCallback(){
        if(this.callFetchApproval){
            this.fetchApprovalRecordJS();
        }
    }

    async fetchApprovalRecordJS(){
        if(this.recordId){
            this.resultdata = await fetchApprovalRecord({regReqId :this.recordId});
           if(!this.resultdata.workItemId && this.callFetchApproval){
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'You Dont have access to Reject this record.',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
                this.closeAction();
                return;
           }
            checkCompanyValidationStatus({ regReqId: this.recordId })
                  .then(result2 => {
                       console.log('Apex returned: ', result2);
			            var enableForAllFlag = result2.enableForAllFlag? result2.enableForAllFlag.toLowerCase():'null';
                         if (enableForAllFlag =='true' && result2.isValidationInProgress){
                              
                                this.showtoastMessage(
                                  'Warning!',
                                   PRM_CDB_ValidationInProgress,
                                   'warning'
                                )
                        }
                
                    }).catch(error2 => {
                     console.log('>>>>result error 2' + JSON.stringify(error2))
                    })
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredRecord({error, data}) {
        try {
            if (error) {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error occurred',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
                console.log('in error block',error);
            } else if (data) {
                this.recordDetail = data;
                this.status = getFieldValue( this.recordDetail, STATUS);
               if(this.status === NEW || this.status == 'Pending'){
                    this.showSave = true;
                    this.showRejectReason = true;
                }else if(this.status === APPROVED){
                    this.formMessage = REG_REQ_APPROVED;
                    //this.rrApproved = true;
                }else if(this.status === REJECTED){
                    this.formMessage = REG_REQ_REJECTED;
                    //this.rrRejected = true;
                }
            }
        } catch (error) {
        }
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleReasonChange(event){
        this.comments = event.detail.value;   
    }

    handleSaveButton(){
        this.isSpinner = true;
        if(this.recordId != null){
            if( this.comments === undefined || this.comments == null || this.comments == ''){
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Rejection Reason cannot be None',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
                this.isSpinner = false;

            }else if(this.comments.length > 0){
                regreqApproveRejectNew({regReqId : this.recordId, approvalInstanceId : this.resultdata.workItemId, aprovalType : 'Rejected', reason : this.comments})
            .then(result => {
                var temp = result;
                console.log('>>>>>result2'+JSON.stringify(temp));
                if(result.flag){
                    const evt = new ShowToastEvent({
                        title: 'Info',
                        message: 'Registration Request is Rejected.',
                        variant: 'success'
                    });
                    this.dispatchEvent(evt);
                    getRecordNotifyChange([{recordId: this.recordId}]);
                    this.callFetchApproval = false;

                }else {
                    const evt = new ShowToastEvent({
                        title: 'Info',
                        message: result.message != null ? result.message : 'There is some error while rejecting registration.',
                        variant: 'error'
                    });
                    this.dispatchEvent(evt);
                }
                this.isSpinner = false;
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => { 
                this.isSpinner = false;
                console.log('error while processing'+ JSON.stringify(error));
            });
        }
            }
    }

     showtoastMessage (title, message, varient) {
     const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: varient
    })
    this.dispatchEvent(evt)
  }

}