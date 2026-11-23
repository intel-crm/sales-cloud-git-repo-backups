import { loadScript } from 'lightning/platformResourceLoader';
import { LightningElement, api } from 'lwc';
import uploadScreenshot from '@salesforce/apex/ScreenshotController.uploadScreenshot';

export default class CaptureScreenshot extends LightningElement {
    @api recordId;

    captureScreenshot() {
        // Load html2canvas dynamically
        Promise.all([
            loadScript(this, 'https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js')
        ])
        .then(() => {
            // Capture the screenshot
            html2canvas(document.body).then(canvas => {
                const imageBase64 = canvas.toDataURL('image/png').split(',')[1]; // Extract Base64 part
                // Call Apex to upload the screenshot
                uploadScreenshot({ recordId: this.recordId, base64Image: imageBase64 })
                    .then(fileId => {
                        alert(`Screenshot uploaded successfully. File ID: ${fileId}`);
                    })
                    .catch(error => {
                        console.error('Error uploading screenshot:', error);
                    });
            });
        })
        .catch(error => {
            console.error('Error loading html2canvas:', error);
        });
    }
}