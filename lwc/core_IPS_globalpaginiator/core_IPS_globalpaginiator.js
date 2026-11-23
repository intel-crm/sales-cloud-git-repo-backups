import { LightningElement } from 'lwc';

export default class Core_IPS_globalpaginiator extends LightningElement {
    previousHandler() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    nextHandler() {
        this.dispatchEvent(new CustomEvent('next'));
    }
}