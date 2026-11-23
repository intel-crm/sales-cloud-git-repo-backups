import { LightningElement, api, wire, track } from 'lwc';
import getHotButtons from '@salesforce/apex/CRM_APController.getHotButtons';
import saveHotButtons from '@salesforce/apex/CRM_APController.saveHotButtons';
import getPriorityPicklistValues from '@salesforce/apex/CRM_APController.getPriorityPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class HotButtonsSection extends LightningElement {
    @api recordId;
    @track hotButtons = [];
    draftValues = [];
    priorityOptions = [];

    wiredHotButtonsResult;
    
    // Modal fields
    @track isModalOpen = false;
    @track modalTitle = 'New Hot Button';
    @track modalDescription = '';
    @track modalPriority = '';
    @track editingId = null;

    // Columns config
    columns = [
        { label: 'Description', fieldName: 'CRM_Description__c', type: 'text', editable: false, wrapText: false },
        {
            type: 'action',
            typeAttributes: { rowActions: [{ label: 'Edit', name: 'edit' }] }
        }
    ];

    @wire(getPriorityPicklistValues)
    wiredPicklist({ error, data }) {
        if (data) {
            this.priorityOptions = data.map(value => ({ label: value, value: value }));
        } else if (error) {
            console.error('Error fetching picklist values', error);
        }
    }

    @wire(getHotButtons, { accountPlanId: '$recordId' })
    wiredHotButtons(result) {
        this.wiredHotButtonsResult = result;
        if (result.data) {
            this.hotButtons = result.data.map(hb => ({
                ...hb,
                priorityOptions: this.priorityOptions
            }));
        } else if (result.error) {
            this.showToast('Error', 'Failed to load hot buttons', 'error');
            console.error('Error fetching Hot Buttons:', result.error);
        }
    }

    // Opens the modal for a new hot button
    openNewModal() {
        this.modalTitle = 'New Hot Button';
        this.modalDescription = '';
        this.modalPriority = '';
        this.editingId = null;
        this.isModalOpen = true;
    }

    // Opens the modal for editing
    handleRowAction(event) {
        const row = event.detail.row;
        this.modalTitle = 'Edit Hot Button';
        this.modalDescription = row.CRM_Description__c;
        this.modalPriority = row.CRM_Priority__c;
        this.editingId = row.Id;
        this.isModalOpen = true;
    }

    handleModalDescriptionChange(event) {
        this.modalDescription = event.target.value;
    }

    handleModalPriorityChange(event) {
        this.modalPriority = event.detail.value;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleModalSave() {
        const newHotButton = {
            Id: this.editingId && !this.editingId.startsWith('new_') ? this.editingId : null,
            CRM_Description__c: this.modalDescription,
            CRM_Priority__c: this.modalPriority,
            CRM_Account_Plan__c: this.recordId
        };

        saveHotButtons({ hotButtons: [newHotButton] })
            .then(() => {
                this.showToast('Success', 'Hot Button saved successfully', 'success');
                this.closeModal();
                window.location.reload();
            })
            .catch(error => {
                console.error('Save Error:', error);
                this.showToast('Error', 'Failed to save Hot Button', 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}