import { LightningElement, api, track, wire } from 'lwc';
export default class Ucd_ACM_AddressVerificationNotify extends LightningElement {
    @track isShowModal = true;

    get message() {
        return 'The account address is verified.';
    }

    closeModal(){
        this.isShowModal = false;
    }
}