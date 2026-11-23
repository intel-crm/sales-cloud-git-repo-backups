import { LightningElement, api,wire,track } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Core_IPS_Nested_milestone_Cmp extends LightningElement {
    @api recordId;
    @track isUpdateAvailable = false;

    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback(){
        console.log('Connect call back from milsstne_Nested');
        this.recordId = this.currentPageReference.attributes.recordId;
        console.log(this.recordId);
    }
    handlechange(evt){
        this.myValue = evt.target.value;
        console.log('Current value of the input: ' + evt.target.value);
        this.isUpdateAvailable = true;
    }
    handleSuccess(){
        console.log("Success");
this.showSuccessToast();
    }
    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Record Updated',
            message: 'Record Updated  ',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        this.isUpdateAvailable = false;
    }
}