import { LightningElement , wire, api} from 'lwc';
import getTrackerSteps from '@salesforce/apex/PRM_DisplayTrackerCtrl.getTrackerSteps';

export default class PRM_DisplayTracker extends LightningElement {
    @api recordId;
    @api trackerType;
    @api lookupApiName;
    @api displayLabel;
    stepRecs;
    errr;

    @wire(getTrackerSteps,{recId : '$recordId',type : '$trackerType', lookupApiName: '$lookupApiName'}) steps({ error, data }) {
    if (data) {
        console.log('@NJ data',JSON.stringify(data));
        this.stepRecs = data;
    } else if (error) {
        this.errr = error.body.message;
    }
}

    
}