import { LightningElement, api, wire, track } from 'lwc';
import getQLDateFields from '@salesforce/apex/Pricing_FieldSetFormController.getQLDateFields';
export default class PricingDateComponent extends LightningElement {
    @api recordId;
    @api label;
    @api value;
}