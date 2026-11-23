import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import sendEmail from '@salesforce/apex/Password_ResetController.sendEmail';
import getPasswordResetToken from '@salesforce/apex/Password_ResetController.GetPasswordResetToken';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class IntelPasswordReset extends NavigationMixin(LightningElement) {
    @api encryptedEmail;
    @api decryptedEmail;
    @api sendEmailResult;
    @api deCodedURLencryptedEmail = '';
    @api URL;
    @api passwordToken;
    @track boolVisible = false;
    @track inputText;
    @api isLoaded = false;
    //parameters = {};

    connectedCallback() {
        //this.parameters = this.getQueryParameters();    
        var encryptedData = ((new URL(window.location.href)).searchParams.get("var"));
        this.parameters = this.getQueryParameters();      
        if (this.deCodedURLencryptedEmail != '' && this.deCodedURLencryptedEmail != 'undefined') {
            console.log('Before calling DecryptEmail Apex method ---> ' + this.deCodedURLencryptedEmail);
            this.boolVisible = true;
            getPasswordResetToken({ encrypedInput : this.deCodedURLencryptedEmail })
                .then(result => {
                    console.log('DecryptEmail Method Password Reset Token Results - Silam ---->' + result);                    
                    this.passwordToken = result;
                    this.error = '';
                    //console.log('Before redicting to password reset page-- passwordToken ---> ' +passwordToken);
                    window.location.replace('https://signindev.intel.com/PasswordUpdate?var=' + result + '&culture=en&target=https://wcm-qa.intel.com/content/www/us/en/secure/partner/forms/ipa-account-search.html');
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            //url: 'https://signindev.intel.com/PasswordUpdate?var=' + result + '&culture=en&target=https://wcm-qa.intel.com/content/www/us/en/secure/partner/forms/ipa-account-search.html'
                        }
                    },
                        true // Replaces the current page in your browser history with the URL
                    );
                })
                .catch(error => {
                    console.error(error);
                    console.error('e.name => ' + error.name);
                    console.error('e.message => ' + error.message);
                    console.error('e.stack => ' + error.stack);
                    this.error = error;
                    console.log('handleSendEmail After error.message- Silam ---->' + error.message);

                    this.passwordToken = undefined;
                    this.boolVisible = false;
                });
        }
    }

    handleBlur(event) {
        this.inputText = event.target.value;
        console.log('input field value ----->' + this.inputText);
    }

    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);
        console.log('params - Silam ---->' + search);
        this.isLoaded = !this.isLoaded;
        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {

                console.log('decodeURIComponent(value) ---Silam ---> ' + decodeURIComponent(value));
                if (key == 'var') {
                    //console.log('decodeURIComponent(value) ---this.encryptedEmail Silam ---> ' + this.encryptedEmail);
                    this.deCodedURLencryptedEmail = decodeURIComponent(value);
                    console.log('decodeURIComponent(value) ---this.encryptedEmail Silam ---> ' + this.encryptedEmail);
                    return this.deCodedURLencryptedEmail;
                }
                return key === "" ? value : decodeURIComponent(value);
            });
        }
        console.log('params - Silam ---->' + params);
        return '';
    }

    handleSendEmail(event) {
        this.boolVisible = false;
        this.isLoaded = !this.isLoaded;
        console.log('inside handleSendEmail function - Silam ----> ' + this.inputText);
        sendEmail({ inputRequest: this.inputText })
            .then(result => {
                console.log('Email Success- Silam ---->' + result);
                this.passwordToken = result;
                this.error = undefined;
                
                const evt = new ShowToastEvent({
                    title: 'Toast Success',
                    message: 'Email Sent sucessful',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);

            })
            .catch(error => {
                console.error(error);
                this.passwordToken = undefined;
                this.boolVisible = false;
                const evt = new ShowToastEvent({
                    title: 'Toast Error',
                    message: 'Some unexpected error : ' + error,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });        
        //return this.decryptedEmail;
    }
    //console.log('test emailFieldValue - Silam --->' + this.emailFieldValue);
}