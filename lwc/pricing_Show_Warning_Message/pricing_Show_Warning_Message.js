import { LightningElement, api } from 'lwc';
import { subscribe, onError } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class pricing_Show_Warning_Message extends LightningElement {
    @api recordId;
    subscription = null;
    channelName = '/event/Pricing_AI_Host_Node_Soft_Warning__e';

    connectedCallback() {
        if (!this.recordId) return;

        subscribe(this.channelName, -1, (event) => this.handleEvent(event))
            .then((sub) => {
                this.subscription = sub;
            })
            .catch((err) => console.error('Subscription failed', err));

        onError((error) => console.error('Platform Event error', error));
    }

    handleEvent(event) {
        const payload = event?.data?.payload;
        if (!payload || payload.RecordId__c !== this.recordId) return;

        const message ='By checking the AI Host Node field, you validate this quote meets the eligibility requirements for AI Host Node promotion pricing.'
           
  if (payload.AI_Host_Node_Value__c){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Warning',
                message,
                variant: 'warning',
                mode: 'sticky'
            })
        );
    }
    }
}