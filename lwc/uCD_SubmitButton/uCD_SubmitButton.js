import { LightningElement, api, track  } from 'lwc';
import {
    FlowNavigationBackEvent,
    FlowNavigationNextEvent
  } from "lightning/flowSupport";

export default class UCD_SubmitButton extends LightningElement {
    @api availableActions = [];
    handleNext() {
        if (this.availableActions.find((action) => action === "NEXT")) {
          const navigateNextEvent = new FlowNavigationNextEvent();
          this.dispatchEvent(navigateNextEvent);
        }
      }
}