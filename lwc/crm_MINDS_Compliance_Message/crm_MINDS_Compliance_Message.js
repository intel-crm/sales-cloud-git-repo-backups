import { LightningElement,api,track } from 'lwc';
import Core_Opp_Guardrail_message from '@salesforce/label/c.Core_Opp_Guardrail_message';

export default class Crm_MINDS_Compliance_Message extends LightningElement {

    label = {Core_Opp_Guardrail_message};
    @api minimumHeight;
    @track header;
    @track url;
    @track guardrail;
    @track nonIntel;
    @track nonIntelUrl;

    get headerStyling() {
        if (this.minimumHeight) {
            return 'height:'+this.minimumHeight+'px;';
        }
    }

    constructor(){
        super();
        const splitedStrings = this.label.Core_Opp_Guardrail_message.split(";");
        if(splitedStrings.length > 4){
            this.header       = splitedStrings[0];
            this.url          = splitedStrings[1];
            this.guardrail    = splitedStrings[2];
            this.nonIntel     = splitedStrings[3];
            this.nonIntelUrl  = splitedStrings[4];
        }
    }

}