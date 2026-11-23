import { LightningElement, api, track } from 'lwc';

export default class ReusableDatatable extends LightningElement {
    @api columns = [];
    @api rows = [];
    @api hidecheckbox = false;
    @api hidebottombar = false;
    @api title;

    @track errorMessages = [];
    editedRowsMap = {}; // outcome -> full row

    get hasErrors() {
        return Array.isArray(this.errorMessages) && this.errorMessages.length > 0;
    }

    handleCellChange(event) {
        const draftValues = event.detail.draftValues;
        this.errorMessages = [];
    
        draftValues.forEach((draftRow) => {
            const rowId = draftRow.id;
            const originalRow = this.rows.find(row => row.id === rowId) || {};
            const key = originalRow.outcome;
    
            // Merge draft with previous edits (if any), then with original row
            const previous = this.editedRowsMap[key] || {};
            const updatedRow = {
                ...originalRow,
                ...previous,
                ...draftRow
            };
    
            this.editedRowsMap[key] = updatedRow;
    
            // Validation
            this.columns.forEach((column) => {
                const value = updatedRow[column.fieldName];
    
                if (column.required) {
                    if (value === undefined || value === null || value === '') {
                        this.errorMessages.push(`Row "${key}": ${column.label} is required.`);
                    }
                }
    
                if (column.type === 'number' && column.typeAttributes?.minimum !== undefined) {
                    const min = column.typeAttributes.minimum;
                    if (value !== undefined && value !== '' && Number(value) <= min) {
                        this.errorMessages.push(`Row "${key}": ${column.label} must be greater than ${min}.`);
                    }
                }
    
                if (column.type === 'text' && column.typeAttributes?.maxLength) {
                    const maxLen = column.typeAttributes.maxLength;
                    const val = value || '';
                    if (val.length > maxLen) {
                        this.errorMessages.push(`Row "${key}": ${column.label} cannot exceed ${maxLen} characters.`);
                    }
                }
            });
        });
    
        // Always emit full rows
        const updatedFullRows = Object.values(this.editedRowsMap);
        this.dispatchEvent(new CustomEvent('tableupdate', { detail: updatedFullRows }));
    }       
    
}