import { LightningElement } from 'lwc';
import lbrDashboardURL from '@salesforce/label/c.pbi_crm_homepage_url';
export default class Pbi_OnPrem_Embed extends LightningElement {

    get fullUrl() {
        return lbrDashboardURL;
    };
    showError(){
        alert("Please log into VPN to view the PET dashboard")
    }
    
}