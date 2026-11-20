import { LightningElement,api } from 'lwc';

export default class Partnersearchaccountnumber extends LightningElement {
    @api accountnumber;
    @api accountid;

    handleClick() {
        this.dispatchEvent(new CustomEvent('linkclicked', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { accountid: this.accountid }
            }
        }));
    }
}