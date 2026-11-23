import { LightningElement,track,wire,api} from 'lwc';
//import reasonforNoSSTlogs from '@salesforce/apex/Core_IPS_BugAssistController.reasonNoSSTlogs';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Case from '@salesforce/schema/Case'; // Replace with your object
import reasonForNotProvidingSSTlog from '@salesforce/schema/Case.Reason_for_not_providing_the_SST_Log__c';
import createIPSBugAssistAttachmentRecord from '@salesforce/apex/Core_IPS_BugAssistController.createIPSBugAssistAttachmentRecord';
import bugAssist_URL from '@salesforce/label/c.Core_IPS_Bug_Assist_URL';
import bugAssist_SSTLog from '@salesforce/label/c.Core_IPS_Bug_Assist_SST_Log';
import bugAssist_Reasons from '@salesforce/label/c.Core_IPS_Bug_Assist_Reason';
import Core_IPS_Required from '@salesforce/label/c.Core_IPS_Required';
import Log_File_Toggle_Message from '@salesforce/label/c.Core_IPS_Bug_Assist_Toggle_Warning';
import Uploaded_File_Label from '@salesforce/label/c.Core_IPS_Bug_Assist_Uploaded_File';
import fetchBugAssistRecord from '@salesforce/apex/Core_IPS_BugAssistController.fetchBugAssistRecord'; // Created by Deepaksai as part of BugAssist

export default class Core_IPS_BugAssist_form1_LWC extends LightningElement {

    @track showboolean1;
    @track showboolean2;
    @track selectedReason;
    @api bugAssistData;
    @api parentFieldValue; // To get Subject from Parent
    isFileNameExists = false;
    uploadedFileName = '';

    bugAssistURL = bugAssist_URL;
    bugAssistSSTLog = bugAssist_SSTLog;
    bugAssistReason = bugAssist_Reasons;
    requiredLabel = Core_IPS_Required;
    toggleMessage = Log_File_Toggle_Message;
    uploadedFileLabel = Uploaded_File_Label;
    bugAssistRecord ='';

    attachurl = '';
    reasonOptions = [];
    recordTypeId;
    bugAssistRecordId; // Created by Deepaksai as part of BugAssit
    isIframeLoaded = false; // Created by Deepaksai as part of BugAssist

    @api resetCheckBoxValues() {
        this.showboolean1 = false;
        this.showboolean2 = false;
        const sendResetData = new CustomEvent('valuereset',
            {detail :
                {
                    sstLogValueTF : null,
                }
            });
            this.dispatchEvent(sendResetData);
    }
    @wire(getObjectInfo, { objectApiName: Case })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId', 
        fieldApiName: reasonForNotProvidingSSTlog
    })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.reasonOptions = data.values;
        } else if (error) {
            console.error('Error while assingment of picklist values: ', error);
        }
    }

    connectedCallback(){
        // Created By Hassan Khan for Bank & Forth logic from different forms.
        if(this.bugAssistData != null){  
            if(this.bugAssistData.uploadedFileName){
                this.isFileNameExists = true;
                this.uploadedFileName = this.bugAssistData.uploadedFileName;
            }
            this.sstLogValueTF = this.bugAssistData.sstLogvalueTF;
            if (this.bugAssistData.sstLogvalueTF === false) {
                this.showboolean1 = false;
                this.showboolean2 = true;
                this.selectedReason = this.bugAssistData.selectedReason;
                this.hasSSTLogFile = true;
            }
            if (this.bugAssistData.sstLogvalueTF === true) {
                this.showboolean1 = true;
                this.showboolean2 = false;
                this.attachurl = this.bugAssistData.attachedUrl;
                this.bugAssistRecordId = this.bugAssistData.bugAssistRecordId;
                this.hasSSTLogFile = true;
            }
        }
        // START POC to capture iframe event by Deepaksai
        // window.addEventListener('message', this.OnUploadStatusMessage);
        window.addEventListener('message', (event) => {
            if(event.origin == 'https://eftlab.intel.com'){
                this.OnUploadStatusMessage(event.data);
            }
        }, false);
        // END - POC
    }
        // START POC to capture iframe event by Deepaksai
        eventStatuses= [];
        OnUploadStatusMessage(eventData) {
            this.isFileNameExists = false;
            const sendFileUploadStatus = new CustomEvent('sstuploadevent', {
                bubbles : true,
                composed : true,
                detail : String(eventData).split('|')[0] 
            });
            this.dispatchEvent(sendFileUploadStatus);
        }
        // END- POC

    // Created By Hassan Khan for URL Preparation 
    getIframeurl(recId,subject){
        const encodedSubject = encodeURIComponent(subject);
        this.attachurl = this.bugAssistURL + sessionStorage.getItem('bugAssistRecId') + '&title='+ encodedSubject;
    }

    // handleChange(event) {
    async handleChange(event) {
        this.isLogFileValueRequired = false;
        if (event.target.name == "yeschecked") {
            this.selectedReason = null;  // to clear the No option value while we select Yes option
            if (event.target.checked) {
                this.showboolean1 = true;
                this.showboolean2 = false;
                this.sstLogValueTF = this.showboolean1;
                this.hasSSTLogFile = true;
                this.isReasonRequired = false;
                this.isFileNameExists = this.bugAssistData ? this.bugAssistData.uploadedFileName ? true : false : false;
                this.uploadedFileName = this.isFileNameExists === true ? this.bugAssistData.uploadedFileName :'';
                // START Creation of IPS Bug Assist object record by Deepaksai
                try {
                    if (sessionStorage.getItem("bugAssistRecId") === null || sessionStorage.getItem("bugAssistRecId") === undefined) {
                        const bugAssistAttachmentRec = await createIPSBugAssistAttachmentRecord();
                        this.bugAssistRecordId = bugAssistAttachmentRec;
                        sessionStorage.setItem("bugAssistRecId", this.bugAssistRecordId);
                    } else {
                        this.bugAssistRecordId = sessionStorage.getItem('bugAssistRecId');
                        // fetch BugAssist Record
                        this.bugAssistRecord =  await fetchBugAssistRecord({recordId : this.bugAssistRecordId});
                        if(this.bugAssistRecord && this.bugAssistRecord.Core_Upload_Status__c === 'Complete') {
                            this.isFileNameExists = true;
                            this.uploadedFileName = this.bugAssistRecord.Core_File_Name__c; 
                        }

                    }
                    this.getIframeurl(this.bugAssistRecordId, ((this.parentFieldValue === null || this.parentFieldValue === undefined) && this.bugAssistData !== null && this.bugAssistData !== undefined) ? this.bugAssistData.subject : this.parentFieldValue.trim().length >0 ? this.parentFieldValue : this.bugAssistData.subject);
                    // this.getIframeurl(this.bugAssistRecordId, (this.bugAssistData !== null && this.bugAssistData !== undefined) ? this.bugAssistData.subject : this.subjectFromParentComponent);

                } catch (error) {
                    console.log('BUG ASSIST error', error);
                }
            } else {
                this.showboolean1 = undefined;
                //this.showboolean2 = true;
                this.sstLogValueTF = this.showboolean1;
            }
        }
        if (event.target.name == "nochecked") {
            if (event.target.checked) {
                this.showboolean1 = false;
                this.showboolean2 = true;
                this.sstLogValueTF = false;
                this.hasSSTLogFile = false;
                this.isFileNameExists = this.bugAssistData ? this.bugAssistData.uploadedFileName ? true : false : false;
                this.uploadedFileName = this.isFileNameExists === true ? this.bugAssistData.uploadedFileName :'';
            } else {
                //this.showboolean1 = true;
                this.showboolean2 = undefined;
                this.sstLogValueTF = this.showboolean2;
            }
        }
        this.senddatatoparent();
    }

    handleSelectReason(event){
        this.isReasonRequired = false;
        const selectedOption = event.detail.value;
        this.selectedReason = selectedOption;
        this.senddatatoparent();
    }

    //Method for sending data to Parent component
    senddatatoparent(){
        const sendData = new CustomEvent('send',
        {detail :
            {
                sstLogValueTF : this.sstLogValueTF,
                selectedReason : this.selectedReason,
                bugAssistRecId : this.bugAssistRecordId,
                bugAssistUrl : this.attachurl,  // Added for Back & Forth
                uploadedFileName : this.uploadedFileName //Added by Deepaksai to capture file name
            }
        });
        this.dispatchEvent(sendData);
    }

    isReasonRequired = false;
    @api validateReasonForNotProvidingLogFile(){
        this.isReasonRequired = true;
        this.template.querySelector('.validateReasonForNotProvidingLogFile')?.classList.add('showRequired'); 
        this.template.querySelector('.validateReasonForNotProvidingLogFile')?.scrollIntoView();
    }
    isLogFileValueRequired = false;
    @api validateSSTLogRequired(){
        this.isLogFileValueRequired = true;
        this.template.querySelector('.validateLogFile')?.classList.add('showRequired'); 
        this.template.querySelector('.validateLogFile')?.scrollIntoView();
    }

    @api bugAssistAttachmentData(bugAssistAttachmentData){
        this.bugAssistRecordData = bugAssistAttachmentData;
        this.isFileNameExists = this.bugAssistRecordData.fileName !== null ? true : false;
        this.uploadedFileName = this.bugAssistRecordData.fileName;
        this.senddatatoparent();
    }
    handleIframeURL(){
        this.isIframeLoaded = true;
    }
}