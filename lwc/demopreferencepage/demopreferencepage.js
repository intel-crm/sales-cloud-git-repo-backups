import { LightningElement,api,track,wire } from 'lwc';
import doSearch from '@salesforce/apex/core_Ips_InterestedParties_CTRL.doSearch';

export default class Demopreferencepage extends LightningElement {
    

    valesss;
    connectedCallback() {
    console.log('do search values');
        doSearch({search: '*'})
            .then(result => {
                console.log('results', result);
                this.valesss=result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.accounts = undefined;
            })
    }
}