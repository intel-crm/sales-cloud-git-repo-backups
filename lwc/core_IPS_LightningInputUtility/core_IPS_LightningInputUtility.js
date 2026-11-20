/* eslint-disable no-console */
import {
    LightningElement,
    api
} from 'lwc';

export default class Core_IPS_LightningInputUtility extends LightningElement {
    @api label;
    @api placeholder;
    @api value;

    handleOnKeyPress(event){
        console.log('Pressed Enter Key');
        console.log(event.which);
        if(event.which === 13){
            const onEnterEvent = new CustomEvent("enter");
            this.dispatchEvent(onEnterEvent);
        }
       
    }

    handleOnChange(event) {
        this.value = event.target.value;
        console.log(event.target.value)
        const onchangeEvent = new CustomEvent("change", {
            detail: {
                value: this.value
            }
        });

        this.dispatchEvent(onchangeEvent);
    }
}