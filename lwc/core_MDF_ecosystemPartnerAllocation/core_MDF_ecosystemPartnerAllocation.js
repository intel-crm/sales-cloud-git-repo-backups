import { LightningElement, api, track } from 'lwc';
import getStoredEcosystemPartnerAllocations from '@salesforce/apex/Core_MDF_Ecosystem_Partner_Handler.getStoredEcosystemPartnerAllocations';
import Ecosystem_Percentage_Allocation from '@salesforce/label/c.Core_MDF_EcosystemPartnerAllocation';
import EcoSystem_Partner from '@salesforce/label/c.Core_MDF_EcoSystem_Partner';
import Percentage from '@salesforce/label/c.Core_MDF_Percentage';
import PercentageEqualHundred from '@salesforce/label/c.Core_MDF_Pecentage_Equal_100';

export default class EcosystemPartnerAllocation extends LightningElement {
    @api selectedEcosystemPartners = [];
    @api isReadOnly = false;
    @api mode = '';
    @api recordId;
    @api editable;
    @track ecosystemRows = [];
    @track originalRows = [];
    @track totalPercentage = 0;
    @track isEditMode = false;
    @track isInitialLoad = true;
    @track savedAllocations = [];
    @track showComponent = false;
    @track hasUserInteraction = false;
    @track touchedFields = new Set();
    @track Ecosystem_Percentage_Allocation = Ecosystem_Percentage_Allocation;
    @track EcoSystem_Partner = EcoSystem_Partner;
    @track Percentage = Percentage;
    @track PercentageEqualHundredError = PercentageEqualHundred;

    connectedCallback() {
        this.componentInitialized = true;
        this.initializeComponent();
    }

    initializeComponent() {
        if (this.mode === 'edit') {
            this.isReadOnly = false;
            this.isEditMode = true;
        } else if (this.mode === 'clone') {
            this.isReadOnly = false;
            this.isEditMode = false;
        } else if (this.mode === 'create') {
            this.isReadOnly = false;
            this.isEditMode = false;
        } else if (this.mode === '' && !this.recordId) {
            this.isReadOnly = false;
            this.isEditMode = false;
        } else if (this.mode === '' && this.recordId) {
            this.isReadOnly = true;
            this.isEditMode = false;
        } else {
            this.isReadOnly = true;
            this.isEditMode = false;
        }
        this.updateComponentVisibility();
        if (this.shouldLoadExistingData()) {
            this.loadExistingAllocationsFirst();
        } else {
            this.initializeEcosystemRows();
            this.originalRows = JSON.parse(JSON.stringify(this.ecosystemRows));
        }
        this.isInitialLoad = false;
    }

    @api
    get selectedEcosystemPartnerOptions() {
        return this.selectedEcosystemPartners;
    }
    
    set selectedEcosystemPartnerOptions(value) {
        this.selectedEcosystemPartners = value || [];
        this.updateComponentVisibility();
        
        // Set user interaction flag when partners are removed/changed externally
        if (this.componentInitialized && this.ecosystemRows.length > 0) {
            this.hasUserInteraction = true;
        }
        
        if (this.shouldLoadExistingData() && this.savedAllocations.length === 0) {
            this.loadExistingAllocationsFirst();
        } else {
            this.initializeEcosystemRows();
        }
    }
    shouldLoadExistingData() {
    if (!this.recordId) {
        return false;
    }
    
        switch(this.mode) {
            case 'clone':
            case 'create':
                return false;
            case 'edit':
            case '':
            default:
                return true;
        }
    }

    @api 
    handleEdit(editable) {
        if(this.mode == 'edit' && editable){
            this.isReadOnly = true;
        }
    }

    updateComponentVisibility() {
        if (this.isReadOnly) {
            this.showComponent = (this.savedAllocations && this.savedAllocations.length > 0) || 
                               (this.ecosystemRows && this.ecosystemRows.length > 0);
        } else {
            const hasValidPartners = this.hasValidEcosystemPartners();
            this.showComponent = hasValidPartners;
        }
    }
    isValidPartner(partner) {
    if (!partner) return false;
    
    let partnerValue;
    if (typeof partner === 'string') {
        partnerValue = partner;
    } else if (typeof partner === 'object') {
        partnerValue = partner.label || partner.value;
    } else {
        partnerValue = String(partner);
    }
    return partnerValue && 
           partnerValue !== 'None' && 
           partnerValue !== '--None--' && 
           partnerValue.trim() !== '';
    }

    hasValidEcosystemPartners() {
        if (!this.selectedEcosystemPartners || this.selectedEcosystemPartners.length === 0) {
            return false;
        }
        return this.selectedEcosystemPartners?.some(partner => this.isValidPartner(partner)) || false;
    }

    async loadExistingAllocationsFirst() {
        try {
            const allocations = await getStoredEcosystemPartnerAllocations({ activityId: this.recordId });
            this.savedAllocations = allocations || [];
            
            this.updateComponentVisibility();
            
            if (this.isReadOnly) {
                this.createRowsFromSavedAllocations();
            } else {
                this.initializeEcosystemRows();
            }
        } catch (error) {
            console.error('Error loading ecosystem partner allocations:', error);
            this.savedAllocations = [];
            this.updateComponentVisibility();
            
            if (this.isReadOnly) {
                this.ecosystemRows = [];
                this.totalPercentage = 0;
                this.originalRows = [];
            } else {
                this.initializeEcosystemRows();
            }
        }
    }

    createRowsFromSavedAllocations() {
        if (!this.savedAllocations || this.savedAllocations.length === 0) {
            this.ecosystemRows = [];
            this.totalPercentage = 0;
            this.originalRows = [];
            this.updateComponentVisibility();
            return;
        }

        this.ecosystemRows = this.savedAllocations.map((allocation, index) => ({
            id: this.generateId(),
            ecosystemPartner: allocation.ecosystemPartner,
            percent: allocation.percent || 0,
            formattedPercent: `${allocation.percent || 0}%`,
            errorEcosystem: false,
            errorPercent: false,
            errorOverPercent: false,
            errorTotalPercent: false,
            rowClass: ''
        }));
        this.originalRows = JSON.parse(JSON.stringify(this.ecosystemRows));
        this.calculateTotalPercentage();
        this.updateFormattedValues();
        this.updateComponentVisibility();
    }

    initializeEcosystemRows() {
        if (!this.selectedEcosystemPartners || this.selectedEcosystemPartners.length === 0) {
            this.ecosystemRows = [];
            this.totalPercentage = 0;
            this.updateComponentVisibility();
            return;
        }
        
        const validPartners = this.selectedEcosystemPartners?.filter(partner => this.isValidPartner(partner)) || [];
        if (validPartners.length === 0) {
            this.ecosystemRows = [];
            this.totalPercentage = 0;
            this.updateComponentVisibility();
            return;
        }
        
        const newRows = [];
        validPartners.forEach((partner, index) => {
            const partnerName = typeof partner === 'string' ? partner : (partner.label || partner.value);
            const existingRow = this.ecosystemRows.find(row => row.ecosystemPartner === partnerName);
            const savedAllocation = this.savedAllocations.find(allocation => 
                allocation.ecosystemPartner === partnerName
            );
            
            let initialPercent = 0;
            if (savedAllocation) {
                initialPercent = savedAllocation.percent || 0;
            } else if (existingRow) {
                initialPercent = existingRow.percent || 0;
            } else if (validPartners.length === 1) {
            }
            
            if (existingRow && !savedAllocation) {
                newRows.push(existingRow);
            } else {
                newRows.push({
                    id: this.generateId(),
                    ecosystemPartner: partnerName,
                    percent: initialPercent,
                    formattedPercent: `${initialPercent}%`,
                    errorEcosystem: false,
                    errorPercent: false,
                    errorOverPercent: false,
                    errorTotalPercent: false,
                    rowClass: ''
                });
            }
        });

        this.ecosystemRows = newRows;
        
        // Mark all fields as touched when partners are removed and we have user interaction
        if (this.hasUserInteraction && this.componentInitialized) {
            this.touchedFields.clear();
            this.ecosystemRows.forEach((row, index) => {
                this.touchedFields.add(index);
            });
        }
        
        if (this.isInitialLoad || this.mode === 'edit') {
            this.originalRows = JSON.parse(JSON.stringify(this.ecosystemRows));
        }
        
        this.calculateTotalPercentage();
        this.validatePercentages();
        this.updateFormattedValues();
        this.updateComponentVisibility();
        this.isInitialLoad = false;
    }

    generateId() {
        return 'ecosystem_' + Math.random().toString(36).substr(2, 9);
    }
    handlePercentBlur(event) {
        const index = parseInt(event.target.dataset.index);
        this.touchedFields.add(index);
        this.validatePercentages();
        this.ecosystemRows = [...this.ecosystemRows];
    }

handlePercentChange(event) {
    if (this.isReadOnly) {
        return;
    }
    
    this.hasUserInteraction = true;
    
    const index = parseInt(event.target.dataset.index);
    this.touchedFields.add(index);
    
    const inputValue = event.target.value;
    
    if (inputValue === '' || inputValue === null || inputValue === undefined) {
        this.ecosystemRows[index].percent = 0;
    } else {
        let newPercent = parseFloat(inputValue) || 0;
        if (newPercent < 0) newPercent = 0;
        if (newPercent > 100) newPercent = 100;
        this.ecosystemRows[index].percent = Math.round(newPercent * 100) / 100;
    }
    
    this.updateFormattedValues(index);
    this.calculateTotalPercentage();
    this.validatePercentages();
    this.ecosystemRows = [...this.ecosystemRows];
}

calculateTotalPercentage() {
    this.totalPercentage = this.ecosystemRows.reduce((total, row) => {
        return total + (parseFloat(row.percent) || 0);
    }, 0);
    this.totalPercentage = Math.round(this.totalPercentage * 100) / 100;
}

validatePercentages() {
    let hasErrors = false;
    
    // Remove the early return for hasUserInteraction when we have touched fields
    if (!this.hasUserInteraction && this.touchedFields.size === 0) {
        return true;
    }
    
    const totalPercentage = this.totalPercentage;
    const isTotalValid = totalPercentage === 0 || (totalPercentage >= 99 && totalPercentage <= 101);
    const hasMultiplePartners = this.ecosystemRows.length > 1;
    const hasZeroPercentage = hasMultiplePartners && totalPercentage > 0 && this.ecosystemRows.some(row => {
        const percent = parseFloat(row.percent) || 0;
        return percent === 0;
    });
    
    this.ecosystemRows.forEach((row, index) => {
        row.errorPercent = false;
        row.errorOverPercent = false;
        row.errorTotalPercent = false;
        row.errorZeroPercent = false;
        row.rowClass = '';
        
        // Check if field is touched OR if we have user interaction (for external changes)
        if (this.touchedFields.has(index) || this.hasUserInteraction) {
            const percent = parseFloat(row.percent) || 0;
            
            if (percent < 0) {
                row.errorPercent = true;
                row.rowClass = 'error-row';
                hasErrors = true;
            } else if (percent > 100) {
                row.errorOverPercent = true;
                row.rowClass = 'error-row';
                hasErrors = true;
            }
        }
        
        const isLastRow = index === this.ecosystemRows.length - 1;
        const hasIndividualErrors = row.errorPercent || row.errorOverPercent || row.errorZeroPercent;
        
        // Show total percentage error if invalid total and (field is touched OR we have user interaction)
        if (!isTotalValid && isLastRow && !hasIndividualErrors && 
            (this.hasUserInteraction || this.touchedFields.has(index))) {
            row.errorTotalPercent = true;
            row.rowClass = 'error-row';
            hasErrors = true;
        }
    });
    
    this.updateRowErrorDisplay();
    return !hasErrors;
}
    updateRowErrorDisplay() {
        this.ecosystemRows = this.ecosystemRows.map(row => ({
            ...row,
            showTotalPercentError: !row.errorPercent && !row.errorOverPercent && !row.errorZeroPercent && row.errorTotalPercent
        }));
    }

updateFormattedValues(index = null) {
    if (index !== null) {
        const row = this.ecosystemRows[index];
        const percent = parseFloat(row.percent) || 0;
        row.formattedPercent = `${percent % 1 === 0 ? percent.toFixed(0) : percent.toFixed(2)}%`;
    } else {
        this.ecosystemRows = this.ecosystemRows.map(row => {
            const percent = parseFloat(row.percent) || 0;
            return {
                ...row,
                formattedPercent: `${percent % 1 === 0 ? percent.toFixed(0) : percent.toFixed(2)}%`
            };
        });
    }
}

    get totalPercentageClass() {
        if (this.totalPercentage === 100) {
            return 'slds-text-color_success';
        } else {
            return 'slds-text-color_error';
        }
    }

    get formattedTotalPercentage() {
        return this.totalPercentage;
    }

    @api
    isEcosystemAllocationModified() {
        if (!this.originalRows || this.originalRows.length !== this.ecosystemRows.length) {
            return true;
        }
        for (let i = 0; i < this.ecosystemRows.length; i++) {
            const current = this.ecosystemRows[i];
            const original = this.originalRows[i];

            if (!current || !original) {
                return true;
            }
            if (current.ecosystemPartner !== original.ecosystemPartner ||
                this.normalizeValue(current.percent) !== this.normalizeValue(original.percent)) {
                return true;
            }
        }

        return false;
    }
    handleEcosystemPartnerRemoval(updatedPartners) {
        this.hasUserInteraction = true;
        this.selectedEcosystemPartners = updatedPartners || [];
        
        // Mark all remaining fields as touched
        this.touchedFields.clear();
        this.ecosystemRows.forEach((row, index) => {
            this.touchedFields.add(index);
        });
        
        this.initializeEcosystemRows();
    }

    normalizeValue(value) {
        if (value === null || value === undefined || value === '') {
            return 0;
        }
        const num = parseFloat(value);
        return isNaN(num) ? 0 : num;
    }

    @api
    validate() {
        if (this.ecosystemRows.length === 0) {
            return true;
        }

        // Check native lightning-input validity (catches -ve and decimal errors)
        const inputs = this.template.querySelectorAll('lightning-input[type="number"]');
        let allNativeValid = true;
        inputs.forEach(input => {
            if (!input.reportValidity()) {
                allNativeValid = false;
            }
        });
        if (!allNativeValid) {
            return false;
        }

        // Also check for negative/decimal values explicitly in the data
        const hasInvalidValues = this.ecosystemRows.some(row => {
            const val = parseFloat(row.percent);
            return val < 0 || !Number.isInteger(val);
        });
        if (hasInvalidValues) {
            return false;
        }

        const hasFieldErrors = this.ecosystemRows.some(row =>
            row.errorPercent || row.errorOverPercent || row.errorZeroPercent
        );
        if (hasFieldErrors) {
            return false;
        }

        const totalPercentage = this.totalPercentage;
        const isTotalValid = totalPercentage === 0 || (totalPercentage >= 99 && totalPercentage <= 101);
        return isTotalValid;
    }

    @api
    shouldEnforceValidation() {
        return this.ecosystemRows.length > 0;
    }

    @api
    getEcosystemPartnerAllocations() {
        if (this.ecosystemRows.length === 0) {
            return [];
        }
        return this.ecosystemRows.map(row => ({
            ecosystemPartner: row.ecosystemPartner,
            percent: parseInt(row.percent) || 0
        }));
    }
}