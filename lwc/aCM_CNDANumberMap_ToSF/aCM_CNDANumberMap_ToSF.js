import { LightningElement,api,track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import getContracts from '@salesforce/apex/ACM_CNDA_SearchAndSelect.ExecuteAPI';

export default class ACM_CNDANumberMap_ToSF extends LightningElement {
    @track data;

    columns = [
        { label: 'Counterparty Name', fieldName: 'counterparty_name' },
        { label: 'Contract Number', fieldName: 'contract_number' },
        { label: 'Country', fieldName: 'counterparty_country' },
        { label: 'City', fieldName: 'counterparty_city' },
        { label: 'State/Province', fieldName: 'counterparty_state_province' },
        { label: 'Contact Name', fieldName: 'intel_contact_name' },
        { label: 'Contract Type', fieldName: 'contract_type0' },
        { label: 'Contract Subtype', fieldName: 'contract_subtype' }
    
    ];

    @api recordId;
    connectedCallback() {
        console.log('Record ID : '+ this.recordId);
    getContracts({AcctID: this.recordId})
    .then(result =>{
        this.showSpinner = false;
        console.log(result);
        this.data = JSON.parse(result);
        }).catch(error =>
            {
                this.showSpinner = false;
                console.log(error);
                }
        );
    }

    getSelectedRecords() {
        console.log('Method entry');
        var selectedRec =  this.template.querySelector("lightning-datatable").getSelectedRows();
        if(selectedRec.length > 0){
            console.log('selectedRecords are ', selectedRec);
   
            let ids = '';
            selectedRec.forEach(currentItem => {
                ids = currentItem.contract_number + ';' + ids;
                ;
            });
            this.selectedNDA = ids;
            console.log(this.selectedNDA);
            
            const fields = {}; // Prepare fields to update
            fields.Id = this.recordId; // Record Id
            fields.Core_CNDA_Number__c = this.selectedNDA; // New value from API response
            const recordInput = { fields };
            updateRecord(recordInput)
            .then(() => {
                console.log('Account update');
            })
            .catch(error => {
                console.log('Account update failed');
            });
        }   
      }

}