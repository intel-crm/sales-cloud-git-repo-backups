import { LightningElement, api } from 'lwc';
import addressVerification from "@salesforce/apex/UCD_ACM_AddressVerificationOnReqstQueue.addressVerification";

export default class AddressVerificationScreen extends LightningElement {
    @api recordId;
    @api showModal=false;
    addressDetails={}
    /*closedModal(){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }*/
    handleOk(){
        const selectedEvent=new CustomEvent('addressselected',{
            detail : {addressDetails:this.addressDetails}
        });
        this.dispatchEvent(selectedEvent);
        //this.closedModal();
    }
}