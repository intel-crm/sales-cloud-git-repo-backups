import { LightningElement, api } from 'lwc';
import numberError from '@salesforce/label/c.Core_MDF_KPI_Number_Error';

export default class Core_MDF_CustomDataTable extends LightningElement {
    @api title;
    @api columns = [];
    @api tableData = [];
    @api validate() {
        const inputs = this.template.querySelectorAll('lightning-input, lightning-textarea');
        let isValid = true;
        const errorLabels = new Set(); 
        inputs.forEach(input => {
            if (!input.reportValidity()) {
                isValid = false;
                errorLabels.add('Field is invalid or required.');
            }
        });    
        return {
            isValid,errors: Array.from(errorLabels)
        };
    }
    
    get rows() {
        if (this.columns && this.tableData) {
            return this.tableData.map(row => {
                return {
                    ...row,
                    fields: this.columns.map(col => {
                        const valueKey = col.displayField || col.fieldName;
                        return {
                            key: col.fieldName,
                            value: row[valueKey],
                            editable: col.editable || false,
                            typeIsNumber: col.type === 'number',
                            typeIsTextArea: col.type === 'textarea',
                            typeIsText: col.type === 'text',
                            class: col.type === 'textarea' ? 'slds-cell-wrap' : '',
                            required: col.required || false,
                            min: col.min,
                            max: col.max,
                            step: col.step,
                            maxLength: col.maxLength,
                            helpText: col.helpText
                        };
                    })
                };
            });
        }
        return [];
    }       

    handleCellChange(event) {
        const rowId = event.target.dataset.rowId;
        const colKey = event.target.dataset.colKey;
        const newValue = event.target.value;
        const input = event.target
        if (input.type === 'number' && (input.step === '1' || input.step === 1)) {
            if (input.type === 'number') {
                if (!/^\d+$/.test(newValue)) {
                    input.setCustomValidity(numberError);
                    input.title = numberError;
                    input.reportValidity();
                    return;
                } else {
                    input.setCustomValidity("");
                    input.title = '';
                    input.reportValidity();
                }
            }
        }
        const updatedRows = this.tableData.map(row => {
            if (row.id === rowId) {
                return { ...row, [colKey]: newValue };
            }
            return row;
        });

        this.tableData = updatedRows;
        this.dispatchEvent(new CustomEvent('tablechange', { detail: updatedRows }));
    }
}