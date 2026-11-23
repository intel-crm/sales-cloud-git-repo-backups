import { LightningElement, api,track } from 'lwc';
import { subscribe, onError } from 'lightning/empApi';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class test_AI_Warning_Msg extends LightningElement {
    @api recordId;
    @track showModal = false;
    @track message = '';
    subscription = null;
    //channelName = '/event/Pricing_AI_Host_Node_Soft_Warning__e';

    connectedCallback() {
        // Subscribe only if recordId exists
        if (!this.recordId) return;

        // Subscribe to Platform Event
        /*subscribe(this.channelName, -1, (event) => this.handleEvent(event))
            .then((sub) => {
                this.subscription = sub;
                console.log('Subscribed to Platform Event:', this.channelName);
            })
            .catch((err) => console.error('Subscription failed', err));

        // Error handling
        onError((error) => {
            console.error('Platform Event error', error);
        });*/
    }

    handleEvent(event) {
        const payload = event?.data?.payload;
        if (!payload) return;

        if (payload.RecordId__c === this.recordId && payload.AI_Host_Node_Value__c) {
            this.message ='By selecting AI Host Node to true you validate this is an AI Host Node Opportunity and meets the eligibility requirements for Promotion pricing. Please refer to Program Details for Eligibility';
            this.showModal = true;
        }
    }

    handleOk() {
        this.showModal = false;
    }
}