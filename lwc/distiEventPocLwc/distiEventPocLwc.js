import { LightningElement,track } from 'lwc';
import { subscribe, onError } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class DistiEventPocLwc extends LightningElement {

    subscription = {};
    @track evtData;
    channelName = '/event/Disti_event_poc__e';

    connectedCallback() {
        this.handleSubscribe();
    }

    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const self = this;
        const messageCallback = function (response) {
            console.log('Response is ', JSON.stringify(response));
            var obj = JSON.parse(JSON.stringify(response));
            self.evtData = obj.data.payload;
            console.log('Payload iss ', JSON.stringify(self.evtData));
            const evt = new ShowToastEvent({
                title: 'Platform event received',
                message: `DR Name- ${self.evtData.DR_Name__c}, Queue Name- ${self.evtData.Queue_Name__c}`,
                variant: 'success',
                mode: 'dismissable'
            });
            self.dispatchEvent(evt);
        };
 
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }
 
    //handle Error
    registerErrorListener() {
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }

}