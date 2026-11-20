import { LightningElement, track } from 'lwc';
import Pricing_IQR_FAQ from '@salesforce/resourceUrl/Pricing_IQR_FAQ';

export default class Pricing_IntelFAQ extends LightningElement {
    @track faqs;

    connectedCallback() {
        let request = new XMLHttpRequest();   // NOSONAR
        request.open('GET', Pricing_IQR_FAQ, false);
        request.send(null);
        this.faqs = JSON.parse(request.responseText);
    }
}