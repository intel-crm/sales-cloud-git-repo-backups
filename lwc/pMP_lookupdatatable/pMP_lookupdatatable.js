import { track} from 'lwc';
import LightningDatatable from 'lightning/datatable';
import DatatableLookupTemplate from './pMP_lookuptemplate.html';
import DatatablePicklistTemplate from './pMP_picklisttemplate.html';

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