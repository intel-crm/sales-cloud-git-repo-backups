import { LightningElement } from 'lwc';
import getAccessLevel from '@salesforce/apex/Core_AccessLevelController.getAccessLevel';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccessLevelCheckLwc extends LightningElement {
    recId;
    userIdEmail;
    responseWrp;
    showSpinner = false;

    get disableCheck() {
        return !this.recId || !this.userIdEmail;
    }

    get disableReset() {
        return !this.recId && !this.userIdEmail;
    }

    get displaySharingInfo() {
        return this.responseWrp.sharingAccessLevel && this.responseWrp.sharingSource;
    }

    get displayAccessLevel() {
        return this.responseWrp && !this.responseWrp.errorMsg;
    }

    get displayViewAll() {
        return this.responseWrp.sharingSource === 'View All Access';
    }

    get displayModifyAll() {
        return this.responseWrp.sharingSource === 'Modify All Access';
    }

    get displayPublicGroupInfo() {
        return this.responseWrp.sharingSource === 'Public Group Member of a Child Group (Sharing Rule)' ||
        this.responseWrp.sharingSource === 'Public Group Member (Sharing Rule)';
    }

    get displayParentPublicGroupInfo() {
        return this.responseWrp.sharingSource === 'Public Group Member of a Child Group (Sharing Rule)' ;
    }

    get displayRoleInfo() {
        return this.responseWrp.sharingSource === 'Assigned Role (Sharing Rule)';
    }

    handleResetAll(){
        this.template.querySelectorAll('lightning-input').forEach(element => {
            this[element.name] = undefined;
            element.value = null;
        });
        this.responseWrp = null;
    }

    changeInput(event) {
        this[event.target.name] = event.target.value;
    }

    async checkAccessLevel(){
        this.showSpinner = true;
        this.responseWrp = await getAccessLevel({ recId: this.recId.trim(),userIdEmail:this.userIdEmail.trim()});
        if (this.responseWrp.errorMsg) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.responseWrp.errorMsg,
                    variant: 'error'
                })
            );
        }
        this.showSpinner = false;
    }
      
}