import { LightningElement, track } from 'lwc';
import getReltioHierarchy from '@salesforce/apex/UCD_ReltioAccountHierarchyController.getReltioHierarchy';

export default class ReltioAccountHierarchyPOC extends LightningElement {

    @track reltioData;
    
    connectedCallback() {
        getReltioHierarchy()
            .then(result => {
                this.reltioData = result;
                console.log('check data : ',this.reltioData)
            })
            .catch(error => {

            })    
    }


}