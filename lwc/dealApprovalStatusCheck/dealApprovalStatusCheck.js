import { LightningElement ,api,track,wire} from 'lwc';
import { subscribe, onError } from 'lightning/empApi';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import PROCESS_MSG_FIELD from '@salesforce/schema/Core_Design_Registration__c.PCC_Deal_Approval_Process_Message__c';
import OPPORTUNITY_ID_FIELD from '@salesforce/schema/Core_Design_Registration__c.Core_Opportunity_Id__c';
import REG_TYPE_FIELD from '@salesforce/schema/Core_Design_Registration__c.PCC_Registration_Type__c';
import { RefreshEvent } from 'lightning/refresh';

export default class DealApprovalStatusCheck extends LightningElement {

    subscription = {};
    @track evtData;
    channelName = '/event/PCC_Deal_Approval_Process_Communication__e';
    @api recordId;
    errorMsg;
    successMsg;
    displaySprinner = false;
    title;

    connectedCallback() {
        this.handleSubscribe();
        setTimeout(() => {
            this.dispatchEvent(new RefreshEvent());;
        }, 20000);
    }

    @wire(getRecord, { recordId: "$recordId", fields:[PROCESS_MSG_FIELD, OPPORTUNITY_ID_FIELD, REG_TYPE_FIELD] })
    dealRec({data,error}) {
        if (data) {
            let processMsg = getFieldValue(data, PROCESS_MSG_FIELD);
            let regType = getFieldValue(data, REG_TYPE_FIELD);
            let opportunityId = getFieldValue(data, OPPORTUNITY_ID_FIELD);
            let objName;
            this.title = regType === 'Deal Registration' ? 'Opportunity and Quote Creation Status' : 'Opportunity Creation Status';

            if (!this.successMsg && !this.errorMsg) {
                if (processMsg) {
                    this.displaySprinner = false;
                    if (processMsg.includes('Successfully processed')) {
                        this.successMsg = (processMsg.includes('PDI') ||  regType === 'Design Registration') ? 'Opportunity created successfully' : 'Opportunity and Quote records are created successfully';
                        this.errorMsg = null;
                    }
                    else {
                        objName = processMsg.includes('creating Quote') ? 'Quote' : 'Opportunity';
                        this.errorMsg = `Error occurred while processing ${objName}. Please raise an IT support ticket`;
                    }
                }
                else if (regType === 'Design Registration' && opportunityId) {
                    this.displaySprinner = false;
                    this.successMsg =  'Opportunity created successfully';
                }
                else {
                    this.displaySprinner = true;
                }
            }
        }
    }
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const self = this;
        const messageCallback = function (response) {
            var obj = JSON.parse(JSON.stringify(response));
            self.evtData = obj.data.payload;

            if (self.recordId === self.evtData.PCC_Record_ID__c && self.evtData.PCC_Type__c === 'Refresh') {
                self.dispatchEvent(new RefreshEvent());
            }

            if (self.recordId === self.evtData.PCC_Record_ID__c && self.evtData.PCC_Type__c === 'Create' && self.evtData.PCC_Object__c === 'Opportunity') {
                self.displaySprinner = true;
                if (self.evtData.PCC_Retry__c === true) {
                    self.errorMsg = null;
                }                
            }
            else if (self.recordId === self.evtData.PCC_Record_ID__c && self.evtData.PCC_Type__c === 'Failure' && self.evtData.PCC_Error_Message__c) {
                let errorEvtMsg = self.evtData.PCC_Error_Message__c;
                self.errorMsg = `Error occurred while processing ${self.evtData.PCC_Object__c}. Please raise an IT support ticket`;
                self.displaySprinner = false;
                self.successMsg = null;
                if (!errorEvtMsg.includes('Resubmission')) {
                    self.dispatchEvent(new RefreshEvent());
                }
            }
            else if (self.recordId === self.evtData.PCC_Record_ID__c && self.evtData.PCC_Type__c === 'Success') {
                self.successMsg = self.evtData.PCC_Object__c === 'Quote' ? 'Opportunity and Quote records are created successfully' : 'Opportunity created successfully';
                self.displaySprinner = false;
                self.errorMsg = null;
                self.dispatchEvent(new RefreshEvent());
            }
        };
 
        // Invoke subscribe method of empApi. Pass refere'nce to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            this.subscription = response;
        });
    }
 
    //handle Error
    registerErrorListener() {
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }
}