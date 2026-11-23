import { LightningElement, track } from 'lwc';
import getActiveProducts from '@salesforce/apex/IPA_DDR_Helper.getActiveProducts';
import saveAll from '@salesforce/apex/IPA_DDR_Helper.saveLeadAndProducts';

export default class IpaLeadForm extends LightningElement {
    customerName = '';
    website = '';
    decisionMaker = '';
    oppName = '';
    oppSummary = '';
    decisionDate = '';
    budget = '';

    addProducts = false;

    @track productRows = [{ id:1, productId:'', productName:'', quantity:1, searchResults:[] }];
    rowId = 2;

    get buttonLabel() {
        return this.addProducts ? 'Finish' : 'Save';
    }

    handleChange(event) {
        this[event.target.name] = event.target.value;
    }

    handleToggle(event) {
        this.addProducts = event.target.checked;
    }

    addRow() {
        this.productRows = [...this.productRows, { id:this.rowId++, productId:'', productName:'', quantity:1, searchResults:[] }];
    }

    removeRow(event) {
        const i = event.target.dataset.index;
        this.productRows.splice(i,1);
        this.productRows = [...this.productRows];
    }

    handleQuantity(event) {
        const i = event.target.dataset.index;
        this.productRows[i].quantity = parseInt(event.target.value,10);
    }

    handleProductInput(event) {
        const i = event.target.dataset.index;
        const key = event.target.value;
        if(!key) {
            this.productRows[i].searchResults = [];
            return;
        }
        getActiveProducts({ searchKey: key })
            .then(res => {
                this.productRows[i].searchResults = res.map(p => ({ label:p.Name, value:p.Id }));
            })
            .catch(err => console.error('Error fetching products:', err));
    }

    selectProduct(event) {
        const i = event.target.dataset.index;
        this.productRows[i].productId = event.target.dataset.id;
        this.productRows[i].productName = event.target.innerText;
        this.productRows[i].searchResults = [];
        this.productRows = [...this.productRows];
    }

    handleSave() {
        // Build clean payload
        const payload = {
            customerName: this.customerName || null,
            website: this.website || null,
            decisionMaker: this.decisionMaker || null,
            oppName: this.oppName || null,
            oppSummary: this.oppSummary || null,
            decisionDate: this.decisionDate ? this.decisionDate : null,
            budget: this.budget ? parseFloat(this.budget) : null,
            products: this.addProducts
                ? this.productRows.map(({ productId, productName, quantity }) => ({
                      productId: productId || null,
                      productName: productName || null,
                      quantity: quantity != null ? parseInt(quantity, 10) : 0
                  }))
                : []
        };

        console.log('Payload sent to Apex:', JSON.stringify(payload, null, 2));

        // Send as JSON string
        saveAll({ data: JSON.stringify(payload) })
            .then(() => {
                alert('Lead created successfully!');
            })
            .catch(err => {
                console.error('Error from Apex:', err);
                alert(err?.body?.message || 'Unknown error');
            });
    }
}