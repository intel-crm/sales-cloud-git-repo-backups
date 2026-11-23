import { LightningElement,track } from 'lwc';

export default class UCD_ACM_AccountUserInactiveNotification extends LightningElement {

        @track isShowModal = true;
        banner='Account Owner is Inactive';
    
        get message() {
        return this.banner;}

        closeModal(){
                this.isShowModal = false;
            }
}