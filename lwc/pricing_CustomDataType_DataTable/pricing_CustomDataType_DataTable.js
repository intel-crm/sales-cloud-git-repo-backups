import LightningDatatable from 'lightning/datatable';
import pricing_customPickList from './pricing_customPickList.html';


export default class Pricing_CustomDataType_DataTable extends LightningDatatable {
    static customTypes = {
        backDateReasonPicklist: {
            template: pricing_customPickList,
            standardCellLayout: true,
            typeAttributes: ['label', 'value', 'placeholder', 'options'],
        }
    }
}