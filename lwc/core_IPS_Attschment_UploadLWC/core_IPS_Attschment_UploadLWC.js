import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class Core_IPS_Attschment_UploadLWC extends NavigationMixin(LightningElement) {


    handlenaviagateattachment(){
        this.attachfilesection = true;
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'case-detail'
            },state: {
                recordId: this.recordId
            }
        });
        this.selected = 'attachments';
    }
}