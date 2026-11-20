import { LightningElement } from 'lwc';

export default class Core_IPS_handleListPageNavigation extends LightningElement {
    connectedCallback(){
        location.href = location.origin + '/IPS/s/';
    }
}