import { LightningElement,wire,track,api } from 'lwc';

import submitApproval from '@salesforce/apex/Core_SubmitOpptSupportRequest.submitApproval';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import { updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import ID_FIELD from '@salesforce/schema/Core_Opportunity_Support__c.Id';
import OPP_STATUS from '@salesforce/schema/Core_Opportunity_Support__c.Core_Status__c';

export default class Core_SubmitOpptSupportRequest extends LightningElement {
    @api recordId;
    @track opptSuppReqs;
    @track error;
    showErrorMessage = false;
    errorMessage;
    
    @wire(submitApproval, {opptSuppReqId: '$recordId'}) 
    submitApproval({error, data}){
     //   console.log('inside line 41'+data);
        if(data != undefined){
       //     console.log('inside data@'+data);
            this.opptSuppReqs = data;
            if(!data){
                    console.log('inside isThereAnOpenOpptSupportReq  @');
                    this.toastTitle = "Sucessessss";
                    const OppSupp = {};
                    OppSupp[ID_FIELD.fieldApiName] = this.recordId;
                    OppSupp[OPP_STATUS.fieldApiName] =  'Submitted';
                    const oppSuppUpdate = {fields : OppSupp};
                    updateRecord(oppSuppUpdate)
                    .then(() => {
                        this.dispatchEvent(new CloseActionScreenEvent());
                        //alert('status submitted ');
                            var url = window.location.href; 
                        var value = url.substr(0,url.lastIndexOf('/') + 1);                                      
                        window.history.back();
                        setTimeout(function() {
                            window.location.reload();
                        }, 1000);
                        
                    })
                    .catch(error => {
                        //alert('error ');
                    //    console.log('error'+JSON.stringify(error));
                        //this.displaymessage('Error while updating Opportunity description',error,'error');                        
                    });               
                }
            else{
                this.showErrorMessage = true;
                this.errorMessage = 'Opportunity Support request is in pending for Approval';
            }

        }else{
          //  console.log('inside else @'+JSON.stringify(error));           
        }
    }
    handleCancelNew(){
        this.dispatchEvent(new CloseActionScreenEvent());
     
    } 

}