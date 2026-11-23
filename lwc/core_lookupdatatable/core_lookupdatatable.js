import { track} from 'lwc';
import LightningDatatable from 'lightning/datatable';
import DatatableLookupTemplate from './core_lookuptemplate.html';
import DatatablePicklistTemplate from './core_picklisttemplate.html';

export default class LookupDataTable extends LightningDatatable {

    @track showLookup = true;

    static customTypes = {
        lookup:
        {
          template: DatatableLookupTemplate,
          typeAttributes: ['label', 'placeholder', 'options', 'value', 'valueName', 'context','fieldApiName','objectApiName','rowId','EnableInlineEdit'],
         },
         picklist: {
            template: DatatablePicklistTemplate,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context','fieldApiName','objectApiName','EnableInlineEdit'],
        },
    };
}