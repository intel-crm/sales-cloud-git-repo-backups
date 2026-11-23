import { LightningElement, api,track } from 'lwc';

export default class DatatablePicklist extends LightningElement {
    @api label;
    @api fieldapiname;
    @api placeholder;
    @api options;
    @api value;
    @api context;
    @track defaultValue;

    connectedCallback(){
        console.log('picklist '+this.defaultValue+' '+this.value);
        this.defaultValue = this.value;
    }
    handleChange(event) {
        //show the selected value on UI
        this.value = event.detail.value;
        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('picklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: {context: this.context, value: this.value ,fieldapiname: this.fieldapiname}
            }
        }));
    }

}