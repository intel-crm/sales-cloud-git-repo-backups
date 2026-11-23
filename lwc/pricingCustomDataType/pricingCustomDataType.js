import LightningDatatable from 'lightning/datatable';
import customPickList from './pricingcustomPickList.html';

export default class PricingCustomDataType extends LightningDatatable {
    static customTypes = {
        backDateReasonPicklist: {
            template: customPickList,
            standardCellLayout: true,
            typeAttributes: ['label', 'value', 'placeholder', 'options'],
        }
    }
}