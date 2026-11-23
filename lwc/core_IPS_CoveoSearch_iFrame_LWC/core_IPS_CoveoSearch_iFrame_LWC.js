import { LightningElement,api,track } from 'lwc';

export default class Core_IPS_CoveoSearch_iFrame_LWC extends LightningElement {

    
    @api recordId;
    @track recordUrl
    connectedCallback(){
        const url = '/apex/Core_IPS_CustomCoveoPanel';

       const hostUrl = window.location.origin;
    
      const  DomainUrl = hostUrl.concat(url);
    
        this.recordUrl = DomainUrl.concat('?id='+this.recordId);
    }

    
    
}