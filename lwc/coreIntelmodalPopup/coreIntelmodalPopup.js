import { LightningElement,track,api } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import currentUserId from '@salesforce/user/Id';

export default class CoreIntelmodalPopup extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded
    @track isModalOpen = false;
		@api recordId;
		@api toastKeys;
    @api toastTitle;
    @api toastMessage;
		@api runInSystemMode;
    channelName = '/event/ToastEvent__e';
    subscription = {};

    connectedCallback() {
        this.toastKeys = this.toastKeys ? this.toastKeys.split(',').map(key => key.trim()) : '';
				const ci = this;
				const toastCallback = function(response) {
						let toastData = response['data']['payload'];
						if(
								toastData && 
								toastData['Key__c'] &&
                (ci.toastKeys.includes(toastData['Key__c'])||ci.recordId==toastData['Key__c']) &&
								(
                    ci.runInSystemMode ||
                    (toastData['CreatedById'] === currentUserId)
                )
						){
								ci.toastTitle = toastData['Title__c'];
								ci.toastMessage = toastData['Message__c'];
								ci.isModalOpen = true;
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
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
}