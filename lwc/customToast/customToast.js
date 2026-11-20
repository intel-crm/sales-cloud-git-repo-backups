import { LightningElement,api,track } from 'lwc';
export default class CustomToast extends LightningElement {
    @api messageList = [];
    @api timeOut = 8000; //default close after 3 secs
    @track type = 'dismissible'; //default dismissible
    @api notificationType = 'info';
    @api topClass = 'slds-notify slds-notify_toast slds-theme_info';
    @api headerMessage = 'Review';
    @track showToastBar = false;
    
    connectedCallback() {  
        if(this.notificationType == 'warning') {
            this.topClass = 'slds-notify slds-notify_toast slds-theme_warning';
            this.iconName = 'utility:warning';
        }
        else if(this.notificationType == 'success') {
            this.topClass = 'slds-notify slds-notify_toast slds-theme_success';
            this.iconName = 'utility:success';
        }
        else if(this.notificationType == 'error') {
            this.topClass = 'slds-notify slds-notify_toast slds-theme_error';
            this.iconName = 'utility:error';
        }
        else {
            this.topClass = 'slds-notify slds-notify_toast slds-theme_info';
            this.iconName = 'utility:info';
        }
    }
    @api
    showToast(type) {
        this.type = type;
        this.showToastBar = true;
        if(this.type == 'dismissible') {
            setTimeout(() => {
                this.closeComp();
            }, this.timeOut);
        }
        else if(this.type == 'sticky') {
            console.log('no dismissal');
        }
    }  
    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.notificationType + ' slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }
    closeComp() {
        this.showToastBar = false;
        this.notificationType = '';
        this.messageList = [];
    }
}