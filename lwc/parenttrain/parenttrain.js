import { LightningElement } from 'lwc';

export default class Parenttrain extends LightningElement {
    msg;

    handleCustomEvent(event) {

        const textVal = event.detail;

        this.msg = textVal;

    }}