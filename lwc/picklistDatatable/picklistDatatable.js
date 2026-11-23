import { LightningElement, api, track } from 'lwc';

export default class PicklistDatatable extends LightningElement {
    @api label;
    @api placeholder;
    @api options;
    @api value;
    @api context;
    @track showPicklist = false;

    closePicklist() {
        console.log('@@@ onblue handler event');
        this.showPicklist = false;
    }
    connectedCallback(){
        if(this.options.length>1){
            this.ifOptions=true;
        }
    }
    handleChange(event) {
        //show the selected value on UI
        console.log('@@@ handle onchange triggered');
        this.value = event.detail.value;
 
        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('picklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context, value: this.value }
            }
        }));
        this.showPicklist = false;
    }
 
    handleClick(event) {
        this.showPicklist = true;
    }
}