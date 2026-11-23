import { LightningElement, api } from 'lwc';
import numberError from '@salesforce/label/c.Core_MDF_KPI_Number_Error';

export default class Core_MDF_CustomDataTable extends LightningElement {
    @api title;
    @api tableData = [];
    isCellActive = false;
    // Row identity field. Defaults to 'id' to preserve existing Aura callers; Flow usage passes 'Id'.
    @api keyField = 'id';
    // Opt-in row selection (checkboxes). Defaults to false so existing callers are unaffected.
    @api enableRowSelection = false;

    _columnsRaw;
    _parsedColumns = [];
    // Public getter/setter must preserve the declared String type (see meta.xml) so Flow's
    // automatic output reflection doesn't see a type mismatch; the parsed array is exposed
    // separately via parsedColumns for internal template/logic use.
    @api
    get columns() {
        return this._columnsRaw;
    }
    set columns(value) {
        this._columnsRaw = value;
        this._parsedColumns = typeof value === 'string' ? JSON.parse(value) : (value || []);
    }

    get parsedColumns() {
        return this._parsedColumns;
    }

    get scrollWrapperClass() {
        return this.isCellActive ? 'slds-scrollable_x table-overflow-visible' : 'slds-scrollable_x';
    }

    handleCellFocus() {
        this.isCellActive = true;
    }

    selectedKeys = new Set();

    // Optional input to restore checkbox state after a screen is redisplayed (e.g. validation error).
    // Accepts an array or JSON string of key values; defaults are a no-op for existing callers.
    @api
    get preSelectedKeys() {
        return Array.from(this.selectedKeys);
    }
    set preSelectedKeys(value) {
        const parsed = typeof value === 'string' ? JSON.parse(value || '[]') : (value || []);
        this.selectedKeys = new Set(parsed);
    }

    // Flow-facing output: full row records currently selected.
    @api
    get selectedRows() {
        return this.tableData.filter(row => this.selectedKeys.has(row[this.keyField]));
    }

    @api validate() {
        const inputs = this.template.querySelectorAll('lightning-input, lightning-textarea, lightning-combobox');
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

    get showSelectAll() {
        return this.enableRowSelection;
    }

    get isAllSelected() {
        return this.tableData.length > 0 && this.selectedKeys.size === this.tableData.length;
    }

    get headerColumns() {
        return this.parsedColumns.map(col => ({
            ...col,
            headerClass: col.cellClass
                ? `slds-grid slds-grid_vertical-align-center ${col.cellClass}`
                : 'slds-grid slds-grid_vertical-align-center',
            columnStyle: this.buildWidthStyle(col.width)
        }));
    }

    // Accepts numbers (treated as px) or any valid CSS width string (e.g. '12rem', '20%'); omitted/invalid values keep default table sizing.
    buildWidthStyle(width) {
        if (width === undefined || width === null || width === '') {
            return '';
        }
        const value = typeof width === 'number' ? `${width}px` : width;
        return `width: ${value};`;
    }

    get rows() {
        if (this.parsedColumns && this.tableData) {
            return this.tableData.map(row => {
                const rowKey = row[this.keyField];
                return {
                    ...row,
                    _key: rowKey,
                    _selected: this.selectedKeys.has(rowKey),
                    fields: this.parsedColumns.map(col => {
                        const valueKey = col.displayField || col.fieldName;
                        return {
                            key: col.fieldName,
                            value: row[valueKey],
                            editable: col.editable || false,
                            typeIsNumber: col.type === 'number',
                            typeIsTextArea: col.type === 'textarea',
                            typeIsText: col.type === 'text',
                            typeIsDate: col.type === 'date',
                            typeIsPicklist: col.type === 'picklist',
                            class: col.cellClass || (col.type === 'textarea' ? 'slds-cell-wrap' : ''),
                            required: col.required || false,
                            min: col.min,
                            max: col.max,
                            step: col.step,
                            maxLength: col.maxLength,
                            options: col.options,
                            placeholder: col.placeholder,
                            helpText: col.helpText,
                            columnStyle: this.buildWidthStyle(col.width)
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
            if (String(row[this.keyField]) === rowId) {
                return { ...row, [colKey]: newValue };
            }
            return row;
        });

        this.tableData = updatedRows;
        this.dispatchEvent(new CustomEvent('tablechange', { detail: updatedRows }));
    }

    handleRowSelectToggle(event) {
        const rowKey = event.target.dataset.rowId;
        const checked = event.target.checked;
        const updatedKeys = new Set(this.selectedKeys);
        if (checked) {
            updatedKeys.add(rowKey);
        } else {
            updatedKeys.delete(rowKey);
        }
        this.selectedKeys = updatedKeys;
        this.dispatchEvent(new CustomEvent('rowselection', { detail: this.selectedRows }));
    }

    handleSelectAllToggle(event) {
        const checked = event.target.checked;
        this.selectedKeys = checked
            ? new Set(this.tableData.map(row => row[this.keyField]))
            : new Set();
        this.dispatchEvent(new CustomEvent('rowselection', { detail: this.selectedRows }));
    }
}