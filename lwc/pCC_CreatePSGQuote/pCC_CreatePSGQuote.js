import { LightningElement, track, api } from 'lwc';
import createPSGQuoteonSiebelNew from '@salesforce/apex/Core_SalesSupportHomeController.createPSGQuoteonSiebelNew';

export default class PCC_CreatePSGQuote extends LightningElement {
    @api recordId;
    @track showSpinner = false;
    @track showErrorMessage = false;
    @track isPartner = false;
    @track bOpportunityValidForQuoteCreation = true;
    @track errorMessage=[];
    @track isButtonDisabled= false;
    quotingFunctionalityMessage = 'The Quoting functionality is only applicable to Opportunities with at least one FPGA Product, and with the First Customer Ship Date and Volume values populated. The Account must be marked as PSG - reach out to your Intel contact with issues related to Account validation.';
    opportunityId;

    createQuote1() {
        this.showErrorMessage = false;
        this.showSpinner = true;
        if (this.recordId) {
            createPSGQuoteonSiebelNew({ soppId: this.recordId })
                .then(result => {
                    this.bOpportunityValidForQuoteCreation = result.bOpportunityValidForQuoteCreation;
                    this.isPartner = result.isPartner;
                    if (!this.bOpportunityValidForQuoteCreation) {
                        this.showErrorMessage = true;
                        this.errorMessage = result.errorMessage;
                        this.showSpinner = false;
                        this.isButtonDisabled = this.errorMessage.length > 0;


                    }
                })
                .catch(error => {
                    this.showErrorMessage = true;
                    this.errorMessage = error.body.message;
                    this.showSpinner = false;
                    this.isButtonDisabled = this.errorMessage.length > 0;


                });
        } else {
            console.error('Opportunity Id is not available.');
        }
    
    }

    

    connectedCallback() {
        if (this.userUITheme !== 'Theme3') {
            this.showSLDS = true;
        }
    }
   

    get userUITheme() {
        return new URLSearchParams(window.location.search).get('theme');
    }
}