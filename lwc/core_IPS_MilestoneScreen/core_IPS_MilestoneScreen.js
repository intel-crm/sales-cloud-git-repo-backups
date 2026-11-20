/* eslint-disable no-console */
import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import { CurrentPageReference } from "lightning/navigation";

import getcaseMilestones from '@salesforce/apex/Core_IPS_MilestoneScreen_Controller.getcaseMilestones';

export default class Core_IPS_MilestoneScreen extends LightningElement {
    @api recordidNew;
    @api recordId ;
    @track milestoneData;
    @track isDataAvailable = false;

    @track columns = [{
            label: 'MileStoneType Name',
            fieldName: 'milestoneTypeName'
        },
        {
            label: 'Case Number',
            fieldName: 'caseNumber'
        },
        {
            label: 'Completion date',
            fieldName: 'completionDate',
            type : 'date'
        },
        {
            label: 'Target Date',
            fieldName: 'targetDate',
            type : 'date'
        },
        {
            label: 'Business Hours',
            fieldName: 'BusinessHoursName'
        },
        {
            label: 'Time Remaining in Hours',
            fieldName: 'TimeRemaininginHours',
            type: 'number'
        },
        {
            label: 'Time Remaining in Days',
            fieldName: 'TimeRemaininginDays',
            type: 'number'
        },
        {
            label: 'Violated',
            fieldName: 'isViolated',
            type: 'boolean'
        },
        {
            label: 'Completed',
            fieldName: 'isCompleted',
            type: 'boolean'
        },
    ];
    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback(){
        console.log('Connect call back from milsstne Screen ');
        //this.recordId = this.currentPageReference.attributes.recordId;

        //this.recordId='5003F000006D69lQAC';
        console.log(this.recordId);
    }

    @wire(getcaseMilestones, {
        caseId: '$recordId'
    }) wiredRecord({
        data,
        error
    }) {
        if (data) {
            this.milestoneData = data;
            console.log("data: " + JSON.stringify(data));
            this.isDataAvailable = true;
        }
        if (error) {
            console.log("error: " + JSON.stringify(error));
        }
    }


}