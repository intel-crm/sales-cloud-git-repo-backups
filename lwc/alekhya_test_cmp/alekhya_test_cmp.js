import { LightningElement,wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getObjectRecords from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getObjectRecords'; // Apex method to fetch records

const columns = [ // Define columns for lightning-datatable
    // Define your columns here based on the fields you want to display
    // Example: 
    { label: 'Name', fieldName: 'Name', type: 'text', sortable: true, disabled: false},
    { label: 'Owner Name', fieldName: 'ownerName', type: 'text', sortable: true, disabled: false},
    { label: 'Owner email', fieldName: 'ownerEmail', type: 'text',  sortable: true, disabled: false}
];

export default class Alekhya_test_cmp extends LightningElement {
    objects = []; // Array to hold objects with records
    userId; // Current user's Id

    connectedCallback() {
        // Fetch current user's Id
        this.userId = '005g00000090fyYAAQ'; // Replace with actual logic to fetch current user's Id

        // Initialize objects array with your custom object data
        this.objects = [
            { apiName: 'Lead', label: 'Lead', records: [] },
            { apiName: 'Opportunity', label: 'Oppportunity', records: [] },
        ];

        // Fetch data for each object initially
        this.fetchObjectData();
    }

    fetchObjectData() {
        
        // Loop through each object and fetch records
        this.objects.forEach(object => {
            console.log('objects.apiName',object.apiName);
            getObjectRecords({userId: this.userId, objectname: object.apiName})
                .then(result => {
                    console.log('result',result);
                    let res=[];
                    result.forEach(currentItem => {
                    res = [...res, { Id: currentItem.Id, Name: currentItem.Name, ownerName: currentItem.Owner.Name,ownerEmail: currentItem.Owner.Email }];
                    });
                    object.records = res;
                    console.log('obj records',object.records);
                    
                })
                .catch(error => {
                    console.error('Error fetching data:', error);
                });
        });
        console.log('object',this.objects);
    }

    handleAccordionToggle(event) {
        // Handle accordion toggle if needed
        //this.objectname = event.target.value;
        //console.log('objname',this.objectname);
        let evnt = event.target.value;
        console.log('event at 52');
        
    }


}