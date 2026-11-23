import { LightningElement, track } from 'lwc';
import isWarningVisible from '@salesforce/apex/Core_MDF_CCP_UtilityClass.isWarningVisible';
import getNotificationMessage from '@salesforce/apex/Core_MDF_dynamicUrlsOnCommunity.getHomeContent';

export default class Core_MDF_CommunityNotification extends LightningElement {
    @track isVisible = false;
    @track notificationMessage = '';

    connectedCallback() {
        this.checkVisibility();
    }

    checkVisibility() {
        isWarningVisible()
            .then(result => {
                this.isVisible = result;
                if(this.isVisible){
                    this.fetchNotificationMesssage();
                }
            })
            .catch(error => {
                console.error('Error fetching visibility:', error);
            });
    }

    fetchNotificationMesssage(){
        getNotificationMessage({ sectionCode : 'Home_CommunityNotification' })
        .then((result) => {
            if(result && result[0].contentLabel){
                //this.notificationMessage = this.stripHtmlTags(result[0].contentLabel);//result[0].contentLabel;
                this.notificationMessage = result[0].contentLabel;
                this.renderNotificationMessage();
            }
        })
        .catch((error) => {
            this.notificationMessage = '';
            console.error('Error:', this.error);
        });

    }

    renderNotificationMessage() {
        const notificationElement = this.template.querySelector('.notification-message');
        if (notificationElement) {
            notificationElement.innerHTML = this.notificationMessage;
        }
    }

    /*stripHtmlTags(html) {
        const tempElement = document.createElement('div');  
        tempElement.innerHTML = html;
        return tempElement.innerText || tempElement.textContent;
    }*/

    renderedCallback() {
        if (this.notificationMessage) {
            this.renderNotificationMessage();
        }
    }
}