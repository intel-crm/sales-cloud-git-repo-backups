import { LightningElement, track, api } from 'lwc';
export default class HelloWorld extends LightningElement {
    @track greeting = 'World';
    @api param1;
    @api caseObj;
    changeHandler(event) {
        this.greeting = event.target.value;
    }
}