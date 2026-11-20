import { LightningElement,api } from 'lwc';

export default class ChildRow extends LightningElement {
    @api value;

    get isValueTrue(){
        if(this.value == 'true')
        return true;
        else return false;
    }
}