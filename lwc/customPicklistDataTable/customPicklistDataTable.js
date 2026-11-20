import LightningDatatable from 'lightning/datatable';
import picklistEditTemplate from './picklistEditTemplate.html';
export default class CustomPicklistDataTable extends LightningDatatable {

    static customTypes = {
        picklistEditTemplate: {
            template: picklistEditTemplate,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','name']
        }
    };
}