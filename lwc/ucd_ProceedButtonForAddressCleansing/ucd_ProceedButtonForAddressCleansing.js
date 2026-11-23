import { LightningElement,api } from 'lwc';
import {
    FlowNavigationFinishEvent,
    FlowNavigationNextEvent
  } from "lightning/flowSupport";
export default class Ucd_ProceedButtonForAddressCleansing extends LightningElement {
    @api availableActions = [];
    handleProceed(){
        if (this.availableActions.find((action) => action === "NEXT")) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
    handleCancel(){
        console.log('FinishMethod');
        const navigateNextEvent = new FlowNavigationFinishEvent();
        this.dispatchEvent(navigateNextEvent);
        console.log('FinishMethods');
        if (this.availableActions.find((action) => action === "FINISH")) {
            console.log('FinishMethod1');
            
        }
    }
}