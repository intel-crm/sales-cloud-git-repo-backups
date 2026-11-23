import LightningDatatable from 'lightning/datatable';
import { api } from 'lwc';
import DatatablePicklistTemplate from './picklist-template.html';
import LookupTemplate from './lookup-template.html';

export default class CustomDataTable extends LightningDatatable {
   static customTypes = {
        picklist: {
            template: DatatablePicklistTemplate,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context','fieldapiname'],
        },
        lookup: {
            template: LookupTemplate,
            typeAttributes: ['uniqueId', 'object', 'icon', 'label', 'displayFields', 'displayFormat', 'placeholder', 'filters','defaultRecord']
        }
    };
    @api selectItem(prodRec){
        this.template.querySelector("LookupTemplate").selectItem(prodRec);  
    }
}