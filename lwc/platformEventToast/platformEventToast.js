/*
*	Author:- Srishty Sharma
*	Description:- Platform Event Toast
*	Created:- 15/01/2021
*	Last Updated:- 15/01/2021
*/
import { LightningElement, api } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import currentUserId from '@salesforce/user/Id';

export default class PlatformEventToast extends LightningElement {

    @api toastKeys;
    @api toastTitle;
    @api toastMessage;
    @api toastVariant;
    @api toastMode;
    @api runInSystemMode;
    channelName = '/event/ToastEvent__e';
    subscription = {};

    connectedCallback() {
        this.toastKeys = this.toastKeys ? this.toastKeys.split(',').map(key => key.trim()) : '';
        const ci = this;
        const toastCallback = function(response) {
						console.log(JSON.stringify(response));
            let toastData = response['data']['payload'];
            if(
                toastData &&
                toastData['Key__c'] &&
                ci.toastKeys.includes(toastData['Key__c']) &&
                (
                    ci.runInSystemMode ||
                    (toastData['CreatedById'] === currentUserId)
                )
            ) {
                const toastEvent = new ShowToastEvent({
                    title: toastData['Title__c'] ? toastData['Title__c'] : ci.toastTitle,
                    message: toastData['Message__c'] ? toastData['Message__c'] : ci.toastMessage,
                    variant: toastData['Variant__c'] ? toastData['Variant__c'] : ci.toastVariant,
                    mode: toastData['Mode__c'] ? toastData['Mode__c'] : ci.toastMode
                });
                ci.dispatchEvent(toastEvent);
            }
        }
        subscribe(this.channelName, -1, toastCallback).then(response => {
            console.log('Subscribed to Platform Event Toast');
            this.subscription = response;
        });
        onError(error => {
            console.log('Error in Platform Event Toast'+error);
            console.log(error);
        });
    }

    disconnectedCallback() {
        unsubscribe(this.subscription, response => {
            console.log('Un-Subscribed from Platform Event Toast');
            console.log(response);
        });
    }
}