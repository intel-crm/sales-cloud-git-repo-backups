import { LightningElement,wire,track } from 'lwc';
import getCustomLabels from '@salesforce/apex/MDFCustomLabels.getCustomLabels'

export default class CustomMetaDataLWC extends LightningElement {
    @track labelsMap = [];
    connectedCallback(){
        this.handleLoad();
    }
    handleLoad(){
        getCustomLabels ()
        .then(result => {
                    this.labelsMap = JSON.parse(result);
        })
        .catch(error => {
        });
}
}