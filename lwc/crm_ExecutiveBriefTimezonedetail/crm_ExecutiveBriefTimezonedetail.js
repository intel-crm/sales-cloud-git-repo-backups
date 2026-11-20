import { LightningElement, api, wire, track } from 'lwc';
import getAllTimezones from '@salesforce/apex/CRM_ExecutiveMeetingBrief_Utility.getAllTimezones';
import getExecutiveMeetingBriefData from '@salesforce/apex/CRM_ExecutiveMeetingBrief_Utility.getExecutiveMeetingBriefData';
import { updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Crm_ExecutiveBrief_timezonePicker extends LightningElement {

    @api recordId;
    @api value;

    @track timezoneOptions = [];
    @track filteredOptions = [];
    @track searchKey = '';
    @track showDropdown = false;
    //@track errorMessage = '';

    // ✅ Load all timezones
    @wire(getAllTimezones)
    wiredTimezones({ data, error }) {
        if (data) {
            this.timezoneOptions = data;
            this.filteredOptions = data;
        } else if (error) {
            console.error('Timezone load error', error);
        }
    }

   
connectedCallback() {
    
    this.boundHandler = this.handleOutsideClick;

    document.addEventListener('mousedown', this.boundHandler);
    this.getExecutiveMeetingBriefData();

}


disconnectedCallback() {
    document.removeEventListener('mousedown', this.boundHandler);
}

handleOutsideClick = (event) => {
        const wrapper = this.template.querySelector('.timezone-wrapper');

        if (!wrapper) return;

        // ✅ Check click inside component
        if (wrapper.contains(event.target)) {
            return;
        }

        // ✅ Close dropdown
        this.showDropdown = false;
    };



    // ✅ Load current record value
    getExecutiveMeetingBriefData() {
        getExecutiveMeetingBriefData({ executiveMeetingId: this.recordId })
            .then(data => {
                this.value = data?.CRM_Time_Zone__c || '';

                // Set label in input
                const selected = this.timezoneOptions.find(opt => opt.value === this.value);
                if (selected) {
                    this.searchKey = selected.label;
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please select the Meeting Timezone',
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error => {
                console.error('Error fetching record', error);
            });
    }

    // ✅ Search logic
    /*handleSearch(event) {
        this.searchKey = event.target.value.toLowerCase();

        this.filteredOptions = this.timezoneOptions.filter(option =>
            option.label.toLowerCase().includes(this.searchKey)
        );
    }*/

    // ✅ Show dropdown
    
handleItemMouseDown(event) {
    // ✅ Prevent document mousedown from firing
    event.stopPropagation();
}

handleInputMouseDown(event) {
    event.stopPropagation();
}


handleFocus() {
    setTimeout(() => {
        this.showDropdown = true;
        this.filteredOptions = this.timezoneOptions;
    }, 100);
}


    // ✅ Select value
    handleSelect(event) {
        const selectedValue = event.currentTarget.dataset.value;
        const selected = this.timezoneOptions.find(opt => opt.value === selectedValue);

        this.value = selected.value;
        this.searchKey = selected.label;
        this.showDropdown = false;
        
        // ✅ clear error
        //this.errorMessage = '';

        this.updateTimezone();
}
    // ✅ Update record
    updateTimezone() {
    const isEmpty = !this.value;

    const fields = {
        Id: this.recordId,
        CRM_Time_Zone__c: isEmpty ? null : this.value
    };

    updateRecord({ fields })
        .then(() => {

            // ✅ Show success ONLY when value exists
            if (!isEmpty) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Time Zone updated',
                        variant: 'success'
                    })
                );
            }

            return getRecordNotifyChange([{ recordId: this.recordId }]);
        })
        .catch(error => {
            console.error('Error updating record', error);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Unable to update Time Zone',
                    variant: 'error'
                })
            );
        });
    }

    get comboboxClass() {
    return `slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ${
        this.showDropdown ? 'slds-is-open' : ''
    }`;
}

get noResults() {
    return this.filteredOptions.length === 0;
}


handleSearch(event) {
    const input = event.target.value;
    this.searchKey = input;

    if (!input) {
        this.value = null;   // ✅ important
        
        // ✅ Set error message
        //this.errorMessage = 'Meeting Timezone is required';
        
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select the Meeting Timezone',
                    variant: 'error'
                })
            );

        this.updateTimezone(); // ✅ clears backend
        this.filteredOptions = this.timezoneOptions;
        return;
    }
    // ✅ Clear error if user types something
    this.errorMessage = '';

    this.filteredOptions = this.timezoneOptions.filter(option =>
        option.label.toLowerCase().includes(input.toLowerCase())
    );

    this.showDropdown = true;
}
}