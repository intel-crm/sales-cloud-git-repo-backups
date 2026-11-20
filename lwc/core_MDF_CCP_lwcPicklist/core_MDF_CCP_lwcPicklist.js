import { api, LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import leaflet from '@salesforce/resourceUrl/CustomDataTable';
export default class Core_MDF_CCP_lwcPicklist extends LightningElement {
    @api label;
    @api placeholder;
    @api value;
    @api options = [];
    @api parentrecord;
    @api fieldnameapi;
    @track optionData;

   connectedCallback(){
    var optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : null;
    this.optionData = optionData;
        Promise.all([
            loadStyle(this, leaflet)
        ]).then(() => {
            console.log('OUTPUT : '+'Style Loaded');
        });
    }

    handleChange(event){
        const eventPick = new CustomEvent('picklistchanged', {
            bubbles : true,
            composed : true,
            cancelable : true,
            detail: {
                data : {
                    selectedValue : event.target.value,
                    relatedRecord : this.parentrecord,
                    fieldnameapi : this.fieldnameapi,
                }
            }
        });
        this.dispatchEvent(eventPick);
    }
}