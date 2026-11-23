import { LightningElement, api } from 'lwc';
//import { CurrentPageReference } from 'lightning/navigation';

export default class ContactWarningMessage extends LightningElement {
   // @wire(CurrentPageReference) pageRef;
    @api recordId;
    /*get isCreatePage(){
        return this.pageRef &&
                this.pageRef.state &&
                this.pageRef.state.pageAttributes &&
                this.pageRef.state.pageAttributes.objectApiName === 'Contact' &&
                this.pageRef.state.pageAttributes.recordTypeId === undefined;
    }*/
    get isCreatePage(){
        return !this.recordId;
    }
}