import { LightningElement } from 'lwc';

export default class Sales_refreshComponentPage extends LightningElement {

connectedCallback(){
    this.windowURL = String(window.location);
    console.log('window url'+this.windowURL);
}

}