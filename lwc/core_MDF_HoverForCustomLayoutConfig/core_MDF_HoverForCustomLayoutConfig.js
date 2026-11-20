import { LightningElement, api } from 'lwc';

export default class Core_MDF_HoverForCustomLayoutConfig extends LightningElement {
    @api recordid;
    @api name;
    @api value;
    @api tabicon;
}