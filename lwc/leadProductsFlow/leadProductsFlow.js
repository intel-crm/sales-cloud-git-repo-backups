import { LightningElement, track, api } from 'lwc';
import getActiveProducts from '@salesforce/apex/IPA_DDR_LeadProductsHandler.getActiveProducts';

export default class LeadProductsFlow extends LightningElement {
    @track productRows = [
        { id: 1, productId: '', productName: '', quantity: 1, searchResults: [] }
    ];
    rowId = 2;

    // Output to Flow
    //@api productsOutput; // array of {productId, quantity}

    connectedCallback() {
        //this.updateOutput();
    }

    addRow() {
        this.productRows = [
            ...this.productRows,
            { id: this.rowId++, productId: '', productName: '', quantity: 1, searchResults: [] }
        ];
        //this.updateOutput();
    }

    removeRow(event) {
        const index = parseInt(event.target.dataset.index, 10);
        this.productRows.splice(index, 1);
        this.productRows = [...this.productRows]; // trigger reactivity
        //this.updateOutput();
    }

    handleQuantityChange(event) {
        const index = parseInt(event.target.dataset.index, 10);
        this.productRows[index].quantity = parseInt(event.target.value, 10);
        //this.updateOutput();
    }

    handleProductInput(event) {
        const index = parseInt(event.target.dataset.index, 10);
        const searchKey = event.target.value;

        if (!searchKey) {
            this.productRows[index].searchResults = [];
            this.productRows[index].productId = '';
            this.productRows[index].productName = '';
            //this.updateOutput();
            return;
        }

        getActiveProducts({ searchKey })
            .then(data => {
                this.productRows[index].searchResults = data.map(p => ({ label: p.Name, value: p.Id }));
            })
            .catch(error => {
                console.error(error);
            });
    }

    selectProduct(event) {
        const rowId = parseInt(event.target.dataset.rowid, 10);
        const productId = event.target.dataset.id;
        const productName = event.target.innerText;

        this.productRows = this.productRows.map(r => {
            if (r.id === rowId) {
                return { ...r, productId, productName, searchResults: [] };
            }
            return r;
        });
        //this.updateOutput();
    }

    // Flow output
    @api
    get productsOutput() {
        const output = this.productRows.map(r => ({
            productId: r.productId,
            productName: r.productName,
            quantity: r.quantity
        }));

        const json = JSON.stringify(output);
        console.log('FLOW GETTER OUTPUT:', json);

        return json;
    }

    // Flow validation
    @api
    validate() {
        if (!this.productRows || this.productRows.length === 0) {
            return { isValid: false, errorMessage: 'Please add at least one product.' };
        }

        for (let i = 0; i < this.productRows.length; i++) {
            const r = this.productRows[i];
            if (!r.productId) {
                return { isValid: false, errorMessage: `Select a product for row ${i + 1}` };
            }
            if (!r.quantity || r.quantity <= 0) {
                return { isValid: false, errorMessage: `Quantity must be greater than 0 in row ${i + 1}` };
            }
        }
        return { isValid: true };
    }
}