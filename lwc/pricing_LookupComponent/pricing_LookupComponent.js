import { LightningElement, track, api, wire } from 'lwc';
import searchRecords from '@salesforce/apex/Pricing_SystematicTenderLimitation.searchRecords';

export default class Pricing_LookupComponent extends LightningElement {
    @api objectApiName;  // Object API Name (e.g., Account)
    @api fieldApiName;   // Field API Name (e.g., Name)
    @api selectedRecordId;
    @track searchResults = [];
    @track showDropdown = false;

    handleSearch(event) {
        const searchKey = event.target.value;
        if (searchKey.length > 2) {
            searchRecords({ objectApiName: this.objectApiName, fieldApiName: this.fieldApiName, searchKey })
                .then(results => {
                    this.searchResults = results;
                    this.showDropdown = true;
                })
                .catch(error => {
                    console.error(error);
                });
        } else {
            this.searchResults = [];
            this.showDropdown = false;
        }
    }

    handleSelect(event) {
        this.selectedRecordId = event.currentTarget.dataset.id;
        const selectedRecordName = event.currentTarget.dataset.name;
        this.showDropdown = false;

        this.dispatchEvent(new CustomEvent('recordselect', {
            detail: { recordId: this.selectedRecordId, recordName: selectedRecordName }
        }));
    }
}