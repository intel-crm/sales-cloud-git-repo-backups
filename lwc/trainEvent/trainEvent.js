import { LightningElement } from 'lwc';

export default class TrainEvent extends LightningElement {
showButton = false;
handleChange(event) {
const name = event.target.value;
 console.log('the value is:', name);
this.showButton = true;
const selectEvent = new CustomEvent('mycustomevent', {
detail: name
 });
this.dispatchEvent(selectEvent);
 }
connectedCallback() {
 console.log('the connected callback is called');
 };

renderedCallback() {
 console.log('the rendered callback is called');
}
}