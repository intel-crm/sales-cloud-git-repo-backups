import { LightningElement, track, wire } from 'lwc';
import redirectAutomate from '@salesforce/apex/Core_IPS_ContactloginDisclaimerCtrl_LWC.redirectAutomate';
export default class Core_IPS_PortalHomePage_LWC extends LightningElement {
    @track isActive;
    connectedCallback(){
        redirectAutomate()
            .then((result) => {
                if(result == 'success'){
                    this.isActive = true;
                    
                }
                if(result == 'fail'){
                    this.isActive = false;                   
                }
            })
            .catch((error) => {
            });
    }
}