import { LightningElement, api, track, wire } from 'lwc';

import {
    subscribe,
    unsubscribe,
    MessageContext
} from 'lightning/messageService';

import dynamicTableMessageChannel from '@salesforce/messageChannel/coreDynamicTableMessageChannel__c';

export default class DatatablePicklist extends LightningElement {
    @api label;
    @api placeholder;
    @api options;
    @api value;
    @api context;
    @api targetFieldApiName ;
    @api targetObjectApiName;
    @api enableInlineEdit;
    @track picklistdisabled = true;
    @track showEditForm = false;
    @track showViewForm = true;
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

    handleChange(event) {
        //show the selected value on UI
        this.value = event.detail.value;
        const fieldNameValue=this.targetFieldApiName;
        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('picklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                'rowId':this.context,
                'value': this.value,
                'fieldName': fieldNameValue,
           },
        }));
    }
}