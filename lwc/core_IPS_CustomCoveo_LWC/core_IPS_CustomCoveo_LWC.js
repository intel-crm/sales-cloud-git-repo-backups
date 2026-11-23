import { LightningElement, track, wire } from 'lwc';
import  getGroup from "@salesforce/apex/Core_IPS_CoveoPageCtrl_LWC.getGroup";

export default class Core_IPS_CustomCoveo_LWC extends LightningElement {

    @track data;
    @track error;
    connectedCallback(){
        this.coveoGroup();
    }
    coveoGroup(){
        getGroup().then(result => {
            this.data = result;
            this.error = undefined;
        }).catch(error => {
             this.error = error;
             this.data = undefined;
        })
    }
}