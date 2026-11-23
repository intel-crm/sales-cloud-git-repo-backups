import { LightningElement, wire } from 'lwc';

import coreIntcToastMessages from '@salesforce/messageChannel/coreIntcToastMessages__c';
import { publish, MessageContext } from 'lightning/messageService';

export default class TestComp extends LightningElement {
  @wire(MessageContext)
  messageContext;

  ind = 0;

  sendMessage() {
    const payload = { message: `hi${this.ind}`, displayToast: true, id: this.ind };
    publish(this.messageContext, coreIntcToastMessages, payload);
    this.ind += 1;
  }

  closeToast() {
    try {
      const payload = { displayToast: false, id: this.ind };
      publish(this.messageContext, coreIntcToastMessages, payload);
      this.ind -= 1;
    } catch (e) {
      console.error(e);
    }
  }
}