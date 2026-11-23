// import { LightningElement,api } from 'lwc';

// export default class Core_MDF_generic_table_display extends LightningElement {
//     @api row1Label = 'test12';
//     @api rows;
//     @api columns;
//     @api items=['Outcomes','Baseline Quantity*','Goal Quantity*','Quantity','Outcome Criteria'];
//     rowLabel;
//     inputValues = {};
//     connectedCallback() {
//         if (this.items && this.items.length > 0) {
//             this.rowLabel = this.items[0];              // First item
//             this.items = this.items.slice(1);   // Rest of the items
//         }
//     }
    
    
//     handleInputChange(event) {
//         const field = event.target.name;
//         const value = event.target.value;
//         this.inputValues[field] = value;
//         console.log('Updated Values:', this.inputValues);
//     }
// }
import { LightningElement, api } from 'lwc';

export default class CoreMDFGenericTableDisplay extends LightningElement {
    @api row1Label = 'test12';

    // Map: Field label => Field type
    @api itemsMap = {
        'Outcomes': 'label',
        'Baseline Quantity*': 'number',
        'Goal Quantity*': 'number',
        'Quantity': 'number',
        'Outcome Criteria': 'text'
    };

    rowLabel;
    inputFields = []; // Array of { label, type }
    labelFields = []; // Array of { label }

    inputValues = {};

    connectedCallback() {
        const entries = Object.entries(this.itemsMap);

        if (entries.length > 0) {
            // First field is just the card title
            this.rowLabel = entries[0][0];

            // Split fields based on type
            const remaining = entries.slice(1);

            this.inputFields = remaining
                .filter(([label, type]) => type === 'number' || type === 'text')
                .map(([label, type]) => ({ label, type }));

            this.labelFields = remaining
                .filter(([label, type]) => type === 'label')
                .map(([label]) => ({ label }));
        }
    }

    handleInputChange(event) {
        const field = event.target.name;
        const value = event.target.value;
        this.inputValues[field] = value;
        console.log('Updated Values:', this.inputValues);
    }
}