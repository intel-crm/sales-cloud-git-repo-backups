import { LightningElement, api, track } from 'lwc';
import generatePdfAndReturnBase64 from '@salesforce/apex/CRM_GeneratePDF_EMBController.getPdfBase64';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GeneratePdfDownloader extends LightningElement {
    @api recordId;
    @track loading = false;


    async handleClick() {
        this.loading = true;
        try {
            const base64 = await generatePdfAndReturnBase64({ recordId: this.recordId });
            if (base64) {
            const link = document.createElement('a');
            link.href = 'data:application/pdf;base64,' + base64;
            link.download = 'Executive Meeting Brief__' + this.recordId + '.pdf';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            }else {
                console.error('Error', 'No PDF URL returned.', 'error');
            }
           
        } catch (error) {
            console.error('Error', error.body?.message || 'Error generating PDF.', 'error');
        }finally {
            this.loading = false;
        }

    }
}