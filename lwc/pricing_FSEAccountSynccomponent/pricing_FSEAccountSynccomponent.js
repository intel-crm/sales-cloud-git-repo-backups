import { LightningElement,api } from 'lwc';

export default class Pricing_FSEAccountSynccomponent extends LightningElement {
    @api invoke() {
        console.log("Hi, I'm an action.");
      }
}