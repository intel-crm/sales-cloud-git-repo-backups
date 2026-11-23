import { LightningElement, track, wire } from 'lwc';
import currentUserDetails from '@salesforce/apex/Prm_emailOptOutCtrl.getCurrentUserDetails';
import getPickListValues from '@salesforce/apex/Prm_emailOptOutCtrl.getPicklistValues';
import updateContact from '@salesforce/apex/Prm_emailOptOutCtrl.updateContact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import tradeComplianceHeader from '@salesforce/label/c.Core_IPS_TradeCompliancePreferences_SecHeader';
import tradeComplianceMessage from '@salesforce/label/c.Core_IPS_TradeComplianceMessage';
import tradeCompliance from '@salesforce/label/c.Core_IPS_TradeCompliance';
import tradePrimary from '@salesforce/label/c.Core_IPS_TradePrimary';
import tradePrimaryCntry from '@salesforce/label/c.Core_IPS_CountryOrRegion'

import emailSectionHeader from '@salesforce/label/c.Core_IPS_EmailPreferences_SecHeader';
import optOutMsg from '@salesforce/label/c.Core_IPS_EmailOptMessage';
import emailOptInMSG from '@salesforce/label/c.Core_IPS_EmailOptIn';
import emailOptOutMSG from '@salesforce/label/c.Core_IPS_EmailOptOut';
import outpOut from '@salesforce/label/c.Core_IPS_OptOut';
import outpIn from '@salesforce/label/c.Core_IPS_OptIn';

import errorMessage from '@salesforce/label/c.Core_IPS_CountryErrorMessage';

import timezoneHeader from '@salesforce/label/c.Core_IPS_TimeZone_SecHeader';
import timeZoneMessage from '@salesforce/label/c.Core_IPS_TimeZoneMessage';

import errorHeader from '@salesforce/label/c.DDR_Country_Region_Missing_Error_Message';
import successMessage from '@salesforce/label/c.DDR_Settings_Updated_Successfully'

import updateError from '@salesforce/label/c.DDR_Update_Failed_Error';
import updateFailedHeader from '@salesforce/label/c.DDR_Update_Failed_header';
import submiButtonLabel from '@salesforce/label/c.DDR_Submit';
import cancelButtonLabel from '@salesforce/label/c.PRM_Cancel_ButtonLabel';
import successHeader from '@salesforce/label/c.DDR_Success_Header';


export default class Prm_emailOptOut extends LightningElement {
    //Label Values
    cancelButtonLabel = cancelButtonLabel;
    submiButtonLabel = submiButtonLabel;
    tradeCompliance = tradeCompliance;
    tradePrimaryCntry = tradePrimary;
    tradePrimaryCntry = tradePrimaryCntry;
    emailSectionHeader = emailSectionHeader;
    emailOptInMSG = emailOptInMSG;
    optOutMsg = optOutMsg;
    emailOptOutMSG = emailOptOutMSG;
    timezoneHeader = timezoneHeader;
    timeZoneMessage = timeZoneMessage;
    tradeComplianceHeader = tradeComplianceHeader;
    tradeComplianceMessage = tradeComplianceMessage;
    outpOut = outpOut;
    outpIn = outpIn;

    //Properties
    @track tradeComplianceOptions = [{ label: 'Yes', value: 'true' }, { label: 'No', value: 'false' }];
    @track tradeComplianceValue;
    @track countryOptions;
    @track timeZoneOptions;
    @track selectedCountry;
    @track emailOptOut = true;
    @track userData;
    @track contactId;
    @track pageLoaded = false;
    @track runSpinner = false;
    @track timeZoneClass = '';
    @track countryClass = '';

    // Retrieve user details
    @wire(currentUserDetails)
    loggedInUserDetails({ data, error }) {
        if (data) {
          
            this.userData = data;
            this.selectedTimeZone = data?.TimeZoneSidKey;
            this.selectedCountry = data?.Contact?.Core_Country_Region__c;
            this.tradeComplianceValue = data?.Contact?.Core_MINDS__c ? 'true' : 'false';
            this.emailOptOut = Boolean(data?.Contact?.Core_IPS_Email_Opt_Out__c);
            this.contactId = data?.ContactId;
        }
        if (error) {
            console.log('Prm_emailOptOut.loggedInUserDetails : ', error);
        }
    }

    // Retrieve country picklist values
    @wire(getPickListValues, { objectApiName: 'Contact', fieldApiName: 'Core_Country_Region__c' })
    getCountries({ data, error }) {
        if (data) {
            
            // Map the picklist values to countryOptions
            this.countryOptions = data.map(option => ({
                label: option.label,
                value: option.value
            }));
        }
        if (error) {
            console.log('Prm_emailOptOut.getCountries : ', error);
        }
    }

    // Retrieve timezone picklist values
    @wire(getPickListValues, { objectApiName: 'User', fieldApiName: 'TimeZoneSidKey' })
    getTimeZone({ data, error }) {
        if (data) {
            
            // Map the picklist values to timeZoneOptions
            this.timeZoneOptions = data.map(option => ({
                label: option.label,
                value: option.value
            }));
        }
        if (error) {
            console.log('Prm_emailOptOut.getTimeZone : ', error);
        }
    }

    connectedCallback() {
        this.pageLoaded = true;
        this.runSpinner = false;
    }

    // Handle trade compliance value change
    handleTradeComplianceChange(event) {
        this.tradeComplianceValue = event.target.value;
        
    }

    // Handle timezone value change
    handleTimeZoneChange(event) {
        this.selectedTimeZone = event.target.value;
        
    }

    // Handle country value change
    handleCountryChange(event) {
        this.selectedCountry = event.target.value;
        
    }

    // Handle email opt-out checkbox change
    handleEmailOptOut(event) {
        this.emailOptOut = event.target.checked;
        
    }

    // Handle form submission
    handleSubmit() {
        if (this.selectedCountry === '-None-' || this.selectedCountry==null || this.selectedCountry ==undefined || this.selectedTimeZone === '-None-' || this.selectedTimeZone==null || this.selectedTimeZone==undefined) {
            // Display error toast if country or timezone is not selected
            this.dispatchEvent(new ShowToastEvent({
                title: errorHeader,
                message: errorMessage,
                variant: 'error',
            }));
        } else {
            this.runSpinner = true;
            const response = {
                response: {
                    tradeComplianceValue: this.tradeComplianceValue == 'true' ? true : false,
                    selectedTimeZone: this.selectedTimeZone,
                    selectedCountry: this.selectedCountry,
                    emailOptOut: this.emailOptOut,
                    contactId: this.contactId
                }
            };

            if (response !== null && response !== undefined) {
                // Call the Apex method to update the contact
                updateContact({ responses: JSON.stringify(response) })
                    .then(result => {
                        this.runSpinner = false;

                        // Display success toast
                        this.dispatchEvent(new ShowToastEvent({
                            title: successHeader,
                            message: successMessage,
                            variant: 'success',
                        }));
                    })
                    .catch(error => {
                        this.runSpinner = false;

                        // Display error toast
                        this.dispatchEvent(new ShowToastEvent({
                            title: updateFailedHeader,
                            message: updateError,
                            variant: 'error',
                        }));

                        console.log('Prm_emailOptOut.handleSubmit : ', error);
                    });
            }
        }
    }
}