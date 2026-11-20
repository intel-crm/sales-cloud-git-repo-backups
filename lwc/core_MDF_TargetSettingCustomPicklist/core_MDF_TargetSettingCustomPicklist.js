import LightningDatatable from 'lightning/datatable';
import picklistColumn from './core_MDF_CustomPicklistColumn.html';
import pickliststatic from './core_MDF_CustomPicklist.html'

export default class Core_MDF_TargetSettingCustomPicklist extends LightningDatatable {
    static customTypes = {
        picklistColumn: {
            template: pickliststatic,
            editTemplate: picklistColumn,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','name']
        }
    };
}