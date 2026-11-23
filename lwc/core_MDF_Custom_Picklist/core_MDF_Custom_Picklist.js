import LightningDatatable from 'lightning/datatable';
import picklistColumn from './core_MDF_CustomPicklistColumn.html';
import pickliststatic from './core_MDF_CustomPicklist.html';
import checkboxStatic from './core_MDF_CustomCheckbox.html';
import multiselectpicklistColumn from './core_MDF_MultiPicklistColumn.html';
import urlColumn from './core_MDF_CustomUrl.html';


export default class Core_MDF_Custom_Picklist extends LightningDatatable {
    static customTypes = {
        picklistColumn: {
            template: pickliststatic,
            editTemplate: picklistColumn,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','name']
        },
        checkboxStatic: {
            template: checkboxStatic,
            standardCellLayout: true,
            typeAttributes: ['label', 'value', 'checked']
        },
        multiselectpicklistColumn: {
            template: multiselectpicklistColumn,
            editTemplate: multiselectpicklistColumn,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','name', 'editable']
        },
        urlColumn: {
            template: urlColumn,
            editTemplate: urlColumn,
            standardCellLayout: true,
            typeAttributes: ['label', 'value', 'context', 'variant','name','title', 'target']
        }
        
    };

    handleRowSelection(event){
        console.log('@@Select ->',event.detail.value);
    }
}