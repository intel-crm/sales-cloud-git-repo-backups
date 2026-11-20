import { LightningElement, api, wire } from 'lwc';
import { getRecord} from 'lightning/uiRecordApi';
export default class ACM_CustomLink_Section extends LightningElement {
    isOpen = true;
    @api recordId;
    accountName;
    billingAddress;

    
    toggleSection() {
        this.isOpen = !this.isOpen;
    }

    get arrowIcon() {
        console.log('#arr ',this.isOpen);
        return this.isOpen ? 'utility:chevrondown' : 'utility:chevronright';
    }

        // Wire Account data
    
    @wire(getRecord, { recordId: '$recordId', fields: [
        'Account.Name',
        'Account.BillingStreet',
        'Account.BillingCity',
        'Account.BillingState',
        'Account.BillingCountry'
    ] })
    wiredAccount({ error, data }) {
        if (data) {
            this.accountName = data.fields.Name.value;
            this.billingAddress = 
                `${data.fields.BillingStreet.value || ''} ${data.fields.BillingCity.value || ''} ${data.fields.BillingState.value || ''} ${data.fields.BillingCountry.value || ''}`;
        } else if (error) {
            console.error(error);
        }
    }

    get googleSearchUrl() {
        return this.accountName ? `https://www.google.com/search?q=${encodeURIComponent(this.accountName)}` : '#';
    }

    get googleMapUrl() {
        return this.billingAddress ? `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(this.billingAddress)}` : '#';
    }

    get financial(){
        return this.accountName ? `https://www.google.com/finance?q=${encodeURIComponent(this.accountName)}` : '#';
    }
}