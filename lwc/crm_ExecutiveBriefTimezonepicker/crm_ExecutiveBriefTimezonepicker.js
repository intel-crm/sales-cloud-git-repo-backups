import { LightningElement, api, wire, track } from 'lwc';
import getAllTimezones
    from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getAllTimezones';
import { getRecord,updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import CRM_TIME_ZONE from '@salesforce/schema/Executive_Meeting_Brief__c.CRM_Time_Zone__c';

export default class EditTimezoneAction extends LightningElement {
    @api recordId;
    @track timezoneOptions = [];
    value;
    label;   // displayed label

    @wire(getAllTimezones)
    wiredTimezones({ data }) {
        if (data) {
            this.timezoneOptions = data;
            this.syncLabelToValue(); // 🔁 important
        }
    }

    /* ✅ Load existing record value */
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [CRM_TIME_ZONE]
    })
    wiredRecord({ data }) {
        if (data) {
            this.label = data.fields.CRM_Time_Zone__c.value;
            this.syncLabelToValue(); // 🔁 important
        }
    }

    /* ✅ Match saved label → option.value */
    syncLabelToValue() {
        if (!this.label || !this.timezoneOptions.length) {
            return;
        }

        const match = this.timezoneOptions.find(
            opt => opt.label === this.label
        );

        if (match) {
            this.value = match.value; // ✅ THIS fixes preselection
        }
    }

    handleChange(event) {
        const selectedValue = event.detail.value;

        const selectedOption = this.timezoneOptions.find(
            option => option.value === selectedValue
        );

        this.value = selectedValue;              
        this.label = selectedOption?.label;     
    }

    handleSave() {
        const fields = {
            Id: this.recordId,
            CRM_Time_Zone__c: this.label
        };

        updateRecord({ fields })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Timezone updated',
                        variant: 'success'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }
}