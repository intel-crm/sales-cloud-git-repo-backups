import { LightningElement, api } from 'lwc';
//import getPdfBase64 from '@salesforce/apex/ExportRichTextPDFController.getPdfBase64';
 
export default class ExportRichTextPdf extends LightningElement {
    @api recordId;
 
 
    handleDownload() {
        getPdfBase64({ recordId: this.recordId })
        
            .then(base64 => {
                const byteCharacters = atob(base64);
                const byteNumbers = new Array(byteCharacters.length);
                for (let i = 0; i < byteCharacters.length; i++) {
                    byteNumbers[i] = byteCharacters.charCodeAt(i);
                }
                const byteArray = new Uint8Array(byteNumbers);
                const blob = new Blob([byteArray], { type: 'application/pdf' });
 
                const link = document.createElement('a');
                link.href = URL.createObjectURL(blob);
                link.download = 'record.pdf';
                link.click();
            })
            .catch(error => {
                console.error('Error generating PDF:', error);
                alert('Error: ' + error.body.message);
            });
    }
}