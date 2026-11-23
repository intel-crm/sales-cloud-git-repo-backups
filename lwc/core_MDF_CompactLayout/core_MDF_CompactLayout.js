import { LightningElement, api } from 'lwc';

export default class Core_MDF_CompactLayout extends LightningElement {
    @api recordId;
    @api name;
    @api value;
    @api tabicon;
}