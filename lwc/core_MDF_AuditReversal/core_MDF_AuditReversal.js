import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import reverseAuditDecision from '@salesforce/apex/Core_MDF_ReverseAuditDecision.reverseAuditDecision';
import Core_MDF_Reverse_Audit_Confirm_Message from '@salesforce/label/c.Core_MDF_Reverse_Audit_Confirm_Message';
import Core_MDF_Success_Msg from '@salesforce/label/c.Core_MDF_CCF_DCF_SUCCESS';
import Core_MDF_Error_Msg from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import getScorecardRecord from '@salesforce/apex/Core_MDF_ReverseAuditDecision.getScorecardRecord';

export default class Core_MDF_AuditReversal extends LightningElement {

//To hold Account Record Id
@api recordId;
@track resultFromCase;
confirmationMsg = Core_MDF_Reverse_Audit_Confirm_Message;
successMsg = Core_MDF_Success_Msg;
errorMsg = Core_MDF_Error_Msg;
@track isModalOpen = false;
@track isLoading = false;
@track scorecardRecord;

// Wire method to automatically call getScorecardRecord when component loads
@wire(getScorecardRecord, { caseId: '$recordId' })
    wiredScorecardRecord({ error, data }) {
        if (data) {
            this.scorecardRecord = data;
            console.log('Scorecard record loaded:', data);
        } else if (error) {
            console.log('Error loading scorecard record:', error);
        }
}

handleClick() {
    // to open modal set isModalOpen tarck value as true
    this.isModalOpen = true;
}

closeModal() {
    // to close modal set isModalOpen tarck value as false
    this.isModalOpen = false;
}
callReverseAudit(){
    this.isLoading = true;
    reverseAuditDecision({caseId: this.recordId, scorecardRecord: this.scorecardRecord})
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