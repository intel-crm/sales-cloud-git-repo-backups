import { LightningElement, track, api } from 'lwc';
import getNotificationMessage from '@salesforce/apex/Core_MDF_Notification.getContent';

export default class Core_MDF_Notification extends LightningElement {
    @track isVisible = false;
    @track notificationMessage = '';
    @api project = '';
    @api type = '';

    connectedCallback() {
        this.fetchNotificationMesssage();
    }

    fetchNotificationMesssage(){
        getNotificationMessage({ project: this.project, type : this.type })
        .then((result) => {
            if(result != undefined && result != ''){
                this.notificationMessage = result;
                this.isVisible = true;
            }
        })
        .catch((error) => {
            this.notificationMessage = '';
        });

    }
}