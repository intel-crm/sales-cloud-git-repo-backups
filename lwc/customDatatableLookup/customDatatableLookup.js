import { LightningElement } from 'lwc';
import LightningDatatable from 'lightning/datatable';
//import core_ips_customLookupLexTemplate from './supportedproductLookup.html';
import coreipscustomLookupLexTemplate from './accountLookup.html';
import DatatablePicklistTemplate from './picklistTemplate.html';
export default class CustomDatatableLookup extends LightningDatatable {

    static customTypes = {
        Lookup: {
            template: DatatablePicklistTemplate,
            typeAttributes: ['label', 'placeholder','iconName', 'sObjectName', 'isRequired'],
        },
        /*SPLookup: {
            template: DatatableSpLookupTemplate,
            typeAttributes: ['label', 'placeholder','iconName', 'sObjectName', 'isRequired'],
        }*/
    };

}