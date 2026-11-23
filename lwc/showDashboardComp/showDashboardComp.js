import { LightningElement, api,wire } from 'lwc';
import UPDATEREPORT from '@salesforce/apex/showDashboardClass.updateReport';
export default class ShowDashboardComp extends LightningElement {
@api recordId;

@wire (UPDATEREPORT,{recId: '$recordId'}) records;
connectedCallback(){    
    console.log('Record Id:'+this.recordId);
}

}