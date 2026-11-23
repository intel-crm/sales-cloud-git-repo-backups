import LightningDatatable from 'lightning/datatable';
import picklistEditTemplate from './picklistEditTemplate.html';
import myStaticStyles from '@salesforce/resourceUrl/HeightIPSParLex'

export default class CustomPicklistDataTable extends LightningDatatable {

    static customTypes = {
        picklistEditTemplate: {
            template: picklistEditTemplate,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','name']
        }
    };

    // connectedCallback() {
    //     loadStyle(this, myStaticStyles); 
    // }
}