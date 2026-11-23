import { LightningElement, api, track, wire } from 'lwc';

import {
  subscribe,
  unsubscribe,
  MessageContext
} from 'lightning/messageService';

import dynamicTableMessageChannel from '@salesforce/messageChannel/coreDynamicTableMessageChannel__c';

export default class DatatableLookup extends LightningElement {

    @api rowId;
    @api targetFieldApiName ;
    @api targetObjectApiName ;
    @api enableInlineEdit;
    @api valueName;
    @api value;
    @track lookupdisabled = true;
    @track showEditForm = false;
    @track showViewForm = true;
    @track wireFieldName = '';
    @track lookupRecordid;
    @track lookupRecordValue;
    @track lookupRecordURL;
    subscription = null;

    @wire(MessageContext)
    messageContext;

    subscribeToMessageChannel() {
      if (!this.subscription) {
          this.subscription = subscribe(
              this.messageContext,
              dynamicTableMessageChannel,
              (message) => this.handleMessage(message)
          );
      }
  }

  unsubscribeToMessageChannel() {
      unsubscribe(this.subscription);
      this.subscription = null;
  }

  handleMessage(message) {
    this.showEditForm = message.showEditForm;
    this.showViewForm = message.showViewForm;
}
    connectedCallback() {
          this.subscribeToMessageChannel();
      }

      disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }
    handleClick(event) {
        this.showEditForm = true;
        this.showViewForm = false;
    }

    handleUndoClick(event){
      this.showEditForm = false;
      this.showViewForm = true;

    }

    handleLookupFieldChange(event) {
       if(event.detail.value[0] !== '' && event.detail.value[0] !== null) {
         this.lookupRecordid = event.detail.value[0];

        }

        const rowId = this.rowId;
        const fieldNameValue=this.targetFieldApiName;
        const lookupId=event.detail.value;
         const selectedEvent = new CustomEvent('lookupselect', {
             composed: true,
             bubbles: true,
             cancelable: true,
             detail: {
                  'rowId':rowId,
                  'lookupId': lookupId,
                  'fieldName': fieldNameValue,
             },
         });
         this.dispatchEvent(selectedEvent);
    }
}