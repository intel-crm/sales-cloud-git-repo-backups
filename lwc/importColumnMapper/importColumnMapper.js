import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class ImportColumnMapper extends LightningElement {

    @api detectedColumnsJson = '[]';
    @api companyNameColumn   = '';
    @api productColumn       = '';
    @api ownerEmailColumn    = '';
    @api notesColumn         = '';
    @api columnMappingJson   = '';

    @track mappingFields = [
        { 
            key: 'company_name', 
            label: 'Company Name', 
            required: true, 
            value: '' 
        },
        { 
            key: 'product', 
            label: 'Product', 
            required: true, 
            value: '' 
        },
        { 
            key: 'owner_email', 
            label: 'Owner Email', 
            required: false, 
            value: '' 
        },
        { 
            key: 'notes', 
            label: 'Notes', 
            required: false, 
            value: '' 
        }
    ];

    get columnOptions() {
        const cols = JSON.parse(
            this.detectedColumnsJson || '[]');
        const options = [
            { label: '-- Select Column --', value: '' }
        ];
        cols.forEach(col => {
            options.push({ label: col, value: col });
        });
        return options;
    }

    handleChange(event) {
        const key   = event.target.name;
        const value = event.detail.value;

        this.mappingFields = this.mappingFields.map(f => {
            if (f.key === key) {
                return { ...f, value: value };
            }
            return f;
        });

        if (key === 'company_name') 
            this.companyNameColumn = value;
        if (key === 'product')      
            this.productColumn = value;
        if (key === 'owner_email')  
            this.ownerEmailColumn = value;
        if (key === 'notes')        
            this.notesColumn = value;

        this.columnMappingJson = JSON.stringify({
            company_name: this.companyNameColumn,
            product:      this.productColumn,
            owner_email:  this.ownerEmailColumn,
            notes:        this.notesColumn
        });

        // Dispatch for each output
        this.dispatchEvent(
            new FlowAttributeChangeEvent(
                'companyNameColumn', 
                this.companyNameColumn
            )
        );
        this.dispatchEvent(
            new FlowAttributeChangeEvent(
                'productColumn', 
                this.productColumn
            )
        );
        this.dispatchEvent(
            new FlowAttributeChangeEvent(
                'ownerEmailColumn', 
                this.ownerEmailColumn
            )
        );
        this.dispatchEvent(
            new FlowAttributeChangeEvent(
                'notesColumn', 
                this.notesColumn
            )
        );
        this.dispatchEvent(
            new FlowAttributeChangeEvent(
                'columnMappingJson', 
                this.columnMappingJson
            )
        );
    }

    @api
    validate() {
        const required = this.mappingFields
            .filter(f => f.required);
        const allMapped = required
            .every(f => f.value !== '');

        if (!allMapped) {
            return {
                isValid: false,
                errorMessage: 
                    'Please map Company Name and ' +
                    'Product columns before continuing.'
            };
        }
        return { isValid: true };
    }
}