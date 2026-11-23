import { LightningElement,track, wire, api  } from 'lwc';
import getAllProgressRecords from '@salesforce/apex/HotButtons_Controller.getAllProgressRecords';

export default class HotButtons extends LightningElement {
    @track records = [];
    @api accountPlanId; // This will be passed to the component from the parent page (e.g., Account or Opportunity ID)

    // Fetch data from Apex controller, passing the parentId
    @wire(getAllProgressRecords, { accountPlanId: '$accountPlanId' })
    wiredProgressData({ error, data }) {
        if (data) {
            // Store the data in the records array
            this.records = data;
        } else if (error) {
            console.error('Error fetching progress data', error);
        }
    }
}