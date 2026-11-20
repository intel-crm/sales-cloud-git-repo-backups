import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import datatableMultiPicklist from '@salesforce/resourceUrl/Core_MDF_SpendingTargetMultiPicklist';

export default class Core_MDF_CustomMultipicklistColumn extends LightningElement {
    @api label;
    @api placeholder;
    @api options;
    @api value;
    @api context;
    @api editable;
    @track showPicklist = false;
    isRendered = false;
    @track yaxis;

    renderedCallback() {
        if (!this.isRendered) {
            Promise.all([
                loadStyle(this, datatableMultiPicklist),
            ]).then(() => { });
        }

        this.isRendered = true;
    }

    handleSelectOptionList(event) {
        //show the selected value on UI
        let picklistValues = '';

        if (event.detail) {
            picklistValues = event.detail.join(';');
        }

        console.log(picklistValues);
        this.value = picklistValues;

        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('multiselectpicklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context, value: this.value }
            }
        }));
    }

    handleClick(event) {
        this.yaxis = event.clientY;
        this.showPicklist = true;
    }

    closePicklist() {
        this.showPicklist = false;
    }
}