import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { refreshApex } from '@salesforce/apex';

import STAGE_FIELD from "@salesforce/schema/Opportunity.StageName";
import APPROVAL_STATUS_FIELD from "@salesforce/schema/Opportunity.Core_Approval_Status__c";
import SUBMITTED_DATE_FIELD from "@salesforce/schema/Opportunity.Core_Date_Submitted_for_Approval__c";

const FIELDS = ['Opportunity.Core_Approval_Status__c'];//['Opportunity.StageName','Opportunity.Core_Approval_Status__c','Opportunity.Core_Date_Submitted_for_Approval__c'];

export default class pCC_OpptyCustomLayout extends LightningElement {

    @api recordId;
    @api objectName = 'Opportunity';
    @track mode = 'readonly';
    @track stageName;
    @track statusVal;
    @track submittedforApprovalDate;
    @track editStatus = ['Qualify','Define','Develop'];
    steps = [
        { label: 'Qualify', value: 'Qualify' },
        { label: 'Define', value: 'Define' },
        { label: 'Develop', value: 'Develop' },
        { label: 'Design', value: 'Design' },
        { label: 'Closed', value: 'Closed' },
    ];

    @wire(getRecord, { recordId: '$recordId', fields: ['Opportunity.StageName'], optionalFields : ['Opportunity.Core_Approval_Status__c','Opportunity.Core_Date_Submitted_for_Approval__c']})
    opportunityVar ({data,error}) {
        console.log(data);
        if (data) {
            console.log('@@data Opp=='+JSON.stringify(data));
            this.stageName = getFieldValue(data, STAGE_FIELD);
            console.log('@@oppStatus 1=='+this.stageName);
            this.statusVal = getFieldValue(data, APPROVAL_STATUS_FIELD);
            console.log('@@oppStatus 2=='+this.statusVal);
            this.submittedforApprovalDate = getFieldValue(data, SUBMITTED_DATE_FIELD);
            if((this.editStatus.includes(this.stageName))|| (this.stageName === 'Design' && this.statusVal === 'Not Submitted')){
                this.mode = 'edit';
                console.log('@@inside if');
            }
            else
            {
                this.mode = 'readonly';
                console.log('@@inside else');
            }
            refreshApex(this.stageName);
       }
       else{
        console.log('@@Else Condition==',error);
       }
      };

      connectedCallback(){
        console.log('Record Idf -->', this.recordId);
      }
/*
    get stage() {
        this.stageName =  getFieldValue(this.opportunity.data, STAGE_FIELD);
        console.log('@@Stage=='+getFieldValue(this.opportunity.data, STAGE_FIELD));
    }

    get status() {
        this.statusVal = getFieldValue(this.opportunity.data, APPROVAL_STATUS_FIELD);
    }

    get submittedDate() {
        this.submittedforApprovalDate = getFieldValue(this.opportunity.data, SUBMITTED_DATE_FIELD);
    }
    /*
    handleSubmit(event){
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-form').submit(fields);
    }

    */
}