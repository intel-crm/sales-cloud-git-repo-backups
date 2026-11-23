import { LightningElement,api,wire,track} from 'lwc';
import getActivityRecords from '@salesforce/apex/Core_MDF_CampaignPFR_Controller.getActivityRecords'; 

export default class DatatableEx12 extends LightningElement {

    @api recordId;

    @track pfrList = [];
    @track hasValidData = false;

    @wire(getActivityRecords, {recordId: '$recordId'})
    wiredPFR(result){
        if(result.data){

            this.hasValidData = true;
            this.pfrList = result.data;
        }
        
    }
}