import { LightningElement, api, wire, track } from "lwc";
import getPOPvalue from "@salesforce/apex/test_fordelete_KPI.getPOPvalues";

export default class Core_MDF_POP_Translation extends LightningElement {

    result = '';
    haserror = false;
    displayHeader;
    @api recordId;
    @api objectApiName;

    @wire(getPOPvalue, {
        recordId: "$recordId",
        objectApiName: "$objectApiName"
    })
    loaddata({ data, error }) {
        console.log('Coming inside POP->');
        if (data) {
            this.result = data.datamap;
            this.displayHeader = data.displayHeader;
            console.log('POP-> ' + this.result);
        }
        if (error) {
            this.haserror = true;
            /* eslint-disable no-console*/
            console.log(this.error);
        }
    }

}