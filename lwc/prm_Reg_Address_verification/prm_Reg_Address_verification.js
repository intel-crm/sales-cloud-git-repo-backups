import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import addressVerification from '@salesforce/apex/UCD_ACM_AICleansedAddress.addressVerification';

export default class AddressVerificationFlow extends LightningElement {

    // Inputs from Flow
    @api organizationName;
    @api streetName;
    @api cityName;
    @api stateCode;
    @api countryCode;
    @api postalCode;

    // Outputs to Flow
    @api verifiedStreet;
    @api verifiedCity;
    @api verifiedStateCode;
    @api verifiedCountryCode;
    @api verifiedPostalCode;
    @api isAddressVerified = false;

    @track cleansedAddress = {};
    @track loading = false;
    @track showResults = false;
    @track selectedOption;
    @track showModal = false;
    openModal() {
        this.showModal = true;
        this.handleVerify();
    }

    closeModal() {
        this.showModal = false;
    }

    handleVerify() {
        this.loading = true;
        console.log('organizationName', this.organizationName);
        console.log('streetName', this.streetName);
        console.log('cityName', this.cityName);
        console.log('stateCode', this.stateCode);
        console.log('countryCode', this.countryCode);
        console.log('postalCode', this.postalCode);

        addressVerification({
            organizationName: this.organizationName,
            streetName: this.streetName,
            countryName: this.countryCode,
            stateName: this.stateCode,
            cityName: this.cityName,
            postalCode: this.postalCode
        })
            .then(result => {
                console.log('Address Verification Result',JSON.stringify(result));
                console.log('Verification Status', result?.verificationStatus);
                this.cleansedAddress = result || {};
                this.showResults = true;
            })
            .catch(error => {
                console.error(error);
                this.cleansedAddress = {};
                this.showResults = true;
            })
            .finally(() => {
                this.loading = false;
            });
    }

    get hasCleansedAddress() {
        const c = this.cleansedAddress;

        if (!c ||
            c.verificationStatus === 'Unverified' ||
            c.verificationStatus === 'Reverted') {
            return false;
        }

        return !!(
            c.streetName ||
            c.cityName ||
            c.stateName ||
            c.postalCode ||
            c.countryName
        );
    }
    get cleansedClass() {
        return this.selectedOption === 'cleansed'
            ? 'address-box address-box_selected'
            : 'address-box';
    }

    get enteredClass() {
        return this.selectedOption === 'entered'
            ? 'address-box address-box_selected'
            : 'address-box';
    }


    handleSelect(event) {
        this.selectedOption = event.currentTarget.dataset.option;

        if (this.selectedOption === 'cleansed') {
            this.verifiedStreet = this.cleansedAddress.streetName;
            this.verifiedCity = this.cleansedAddress.cityName;
            this.verifiedStateCode = this.cleansedAddress.stateCode;
            this.verifiedCountryCode = this.cleansedAddress.countryCode;
            this.verifiedPostalCode = this.cleansedAddress.postalCode;
            this.isAddressVerified = true;
        } else {
            this.verifiedStreet = this.streetName;
            this.verifiedCity = this.cityName;
            this.verifiedStateCode = this.stateCode;
            this.verifiedCountryCode = this.countryCode;
            this.verifiedPostalCode = this.postalCode;
            this.isAddressVerified = false;
        }
        console.log('selectedOption =', this.selectedOption);
        /*this.publishVerifiedAddress();*/
    }

    publishVerifiedAddress() {
        this.dispatchEvent(new FlowAttributeChangeEvent('verifiedStreet', this.verifiedStreet || ''));
        this.dispatchEvent(new FlowAttributeChangeEvent('verifiedCity', this.verifiedCity || ''));
        this.dispatchEvent(new FlowAttributeChangeEvent('verifiedStateCode', this.verifiedStateCode || ''));
        this.dispatchEvent(new FlowAttributeChangeEvent('verifiedCountryCode', this.verifiedCountryCode || ''));
        this.dispatchEvent(new FlowAttributeChangeEvent('verifiedPostalCode', this.verifiedPostalCode || ''));
        this.dispatchEvent(new FlowAttributeChangeEvent('isAddressVerified', this.isAddressVerified));
    }

    handleProceed() {
        if (!this.selectedOption) {
            return;
        }
        this.publishVerifiedAddress();
        this.closeModal();
    }
}