import { LightningElement, api } from 'lwc';
import generatePDF from '@salesforce/apex/AccountPlanController.generatePDF';

export default class AccountPlanPDF extends LightningElement {
    @api recordId; // Pass the Account Plan record Id

    handleDownloadPDF() {
        generatePDF({ recordId: this.recordId })
            .then((pdfData) => {
                const blob = new Blob([pdfData], { type: 'application/pdf' });
                const link = document.createElement('a');
                link.href = URL.createObjectURL(blob);
                link.download = `AccountPlan_${this.recordId}.pdf`;
                link.click();
            })
            .catch((error) => {
                console.error('Error generating PDF:', error);
            });
    }
}