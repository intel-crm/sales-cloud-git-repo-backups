import { LightningElement, wire } from 'lwc';
import LANG from '@salesforce/i18n/lang';

import act from '@salesforce/apex/PMP_OfferingDetailsController.getOfferingDetail'

export default class IpaProductDetail extends LightningElement {
    @wire(act, { "offeringId": 'a5b3b000000PTK6AAO',
                "bEditOffering":false,
                "bViewOffering":true,
                "bCompareOffering":false,
                "language": 'en_US',// language,
                langCode: LANG,
                isPreview: false
    })
    wiredAccount({ error, data }) {
        if (data) {
            console.log('data', data);
            // this.error = undefined;
        } else if (error) {
            console.log(error)
            // this.error = error;
            // this.record = undefined;
        }
    }

    connectedCallback() {
        
    }
}