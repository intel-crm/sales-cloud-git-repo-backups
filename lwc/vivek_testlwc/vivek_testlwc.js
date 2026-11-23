import { LightningElement } from 'lwc';
import checkWrapper from "@salesforce/apex/Vivek_testapex.getWrapper";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Vivek_testlwc extends LightningElement {

    message = '';

    connectedCallback(){
        this.fetchWrapper();
    }

    fetchWrapper(){
        checkWrapper().then((result) => {
            console.log('result->',result);
            console.log('result msg->',result.msg);
            console.log('result flg->',result.flg);
            this.message = result.msg;
            if(this.message==''){
                this.showToast();
            }           
        })
    }

    showToast(){
        const toastEvent = new ShowToastEvent({
            title: `${this.message}`,
            message: '',
            variant: 'success',
            
        });
        this.dispatchEvent(toastEvent);
    }
}