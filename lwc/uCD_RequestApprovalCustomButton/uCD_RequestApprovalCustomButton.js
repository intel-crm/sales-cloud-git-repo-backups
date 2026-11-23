import { LightningElement, api, track  } from 'lwc';
import {
    FlowNavigationBackEvent,
    FlowNavigationNextEvent
  } from "lightning/flowSupport";
export default class UCD_RequestApprovalCustomButton extends LightningElement {
    @api availableActions = [];
    @api reactiveValue;
    @track locationOrCountry = false;
    @track country = false;

    renderedCallback(){
        
        setTimeout(() => {
          console.log('this.reactiveValue',this.reactiveValue);
      },2000);
        if(this.reactiveValue === 'UNFD_LOC_CUST' || 'UNFD_CTRY_CUST' ){
            this.locationOrCountry = true;
        };
 }
    
  handleNext() {
    if (this.availableActions.find((action) => action === "NEXT")) {
      const navigateNextEvent = new FlowNavigationNextEvent();
      this.dispatchEvent(navigateNextEvent);
    }
  }
}