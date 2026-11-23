import { LightningElement, api } from 'lwc';
import createAccountPlanAndReturnPdfLWC from '@salesforce/apex/createAccountPlanAndReturnPdfLWC.createAccountPlanAndReturnPdfLWC';

export default class AccountPlanGenerate extends LightningElement {
    @api recordId;
    hasRendered = false; // prevent multiple runs

    renderedCallback() {
        if (this.recordId && !this.hasRendered) {
            this.hasRendered = true;
            this.handleGeneratePlan();
        }
    }

    handleGeneratePlan() {
        console.log('Generating Account Plan for Account Id:', this.recordId);

        createAccountPlanAndReturnPdfLWC({ accountId: this.recordId })
            .then(result => {
                if (result && result.htmlContent) {
                    const blob = new Blob([result.htmlContent], { type: 'text/html' });
                    const reader = new FileReader();

                    reader.onload = () => {
                        const link = document.createElement('a');
                        link.href = reader.result;
                        link.download = 'AccountPlan_' + this.recordId + '.html';
                        document.body.appendChild(link);
                        link.click();
                        document.body.removeChild(link);

                        this.showToast('Success', 'Account Plan HTML downloaded.', 'success');
                    };

                    reader.readAsDataURL(blob);
                } else {
                    this.showToast('Error', 'No HTML returned from Apex.', 'error');
                }
            })
            .catch(error => {
                console.error('Error downloading Account Plan:', error);
                const message = error.body && error.body.message ? error.body.message : 'Unexpected error';
                this.showToast('Error', message, 'error');
            });
    }

    showToast(title, message, variant) {
        alert(`${title}: ${message}`);
    }
}