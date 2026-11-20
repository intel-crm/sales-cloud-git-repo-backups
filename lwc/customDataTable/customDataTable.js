import LightningDatatable from 'lightning/datatable';
import DatatablePicklistTemplate from './picklistTemplate.html'; 
import {loadStyle} from 'lightning/platformResourceLoader';
import core_IPS_dataTableRes from '@salesforce/resourceUrl/core_IPS_dataTableRes';
export default class CustomDataTable extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: DatatablePicklistTemplate,
            typeAttributes: ['label', 'placeholder','options', 'value', 'context'],
            editable: true
        },
    };

    constructor() {
        super();
        Promise.all([
            loadStyle(this, core_IPS_dataTableRes),
        ]).then(() => {})
    }
}