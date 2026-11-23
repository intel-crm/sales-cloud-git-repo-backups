import { LightningElement, api, wire, track } from 'lwc';
//import method from the Apex Class
import loadData from "@salesforce/apex/CustomerDisclaimer.getResourceName";

export default class NonDisclosureAgreement extends LightningElement {

    @api resourceData;

    @wire(loadData)
  wiredResourceData({data,error}) {
    if (data) {
      console.log(data);
      this.resourceData = data;
    } else if (error) {
      console.log(error);
    }
  }
 
}