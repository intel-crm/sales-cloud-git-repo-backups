import { LightningElement, track } from 'lwc';
export default class Business_Review_Email_LWC extends LightningElement {


@track sendEmail = false;
    changeToggle(event) {
         console.log('Inside changeToggle method:'+element);
         this.sendEmail = !this.sendEmail;
    }

}