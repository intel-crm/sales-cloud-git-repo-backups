import { LightningElement, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import avaamoJs from '@salesforce/resourceUrl/loadAvaamoJSfile';
import getJWToken from "@salesforce/apex/loadChatBotController.getJWToken";

export default class LoadChatBot extends LightningElement {
    connectedCallback() {

        loadScript(this, avaamoJs).then(() => {
            loadBot();
            console.log('this is in chatbot');
        });

    }

    @wire(getJWToken, {

    })
    loaddata({ data, error }) {
        //eval("$A.get('e.force:refreshView').fire();");
        if (data) {
            this.result = data;
            console.log("data->" + this.result);
        }
        if (error) {
            this.haserror = true;
            /* eslint-disable no-console*/
            console.log(this.error);
        }
    }



}