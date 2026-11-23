import { LightningElement } from 'lwc';
import html2canvasResource from '@salesforce/resourceUrl/html2canvasfinal'; // Updated to use the new static resource name
import { loadScript } from 'lightning/platformResourceLoader';

export default class CaptureScreenshot extends LightningElement {
    isLibraryLoaded = false;

    renderedCallback() {
        if (this.isLibraryLoaded) {
            return;
        }

        loadScript(this, html2canvasResource)
            .then(() => {
                this.isLibraryLoaded = true;
                console.log('html2canvas library loaded successfully');
            })
            .catch(error => {
                console.error('Error loading html2canvas library:', error);
            });
    }

    captureScreenshot() {
        if (!this.isLibraryLoaded) {
            console.error('html2canvas library is not loaded yet');
            return;
        }
    
        console.log('html2canvas function:', window.html2canvas);
    
        if (typeof window.html2canvas !== 'function') {
            console.error('html2canvas function is not available');
            return;
        }
    
        // Use window.top.document.body for Salesforce Lightning context
        window.html2canvas(window.top.document.body, {
            useCORS: true,
            ignoreElements: (element) => element.tagName === 'IFRAME'
        })
        .then(canvas => {
            const link = document.createElement('a');
            link.download = 'screenshot.png';
            link.href = canvas.toDataURL();
            link.click();
        })
        .catch(error => {
            console.error('Error capturing screenshot:', error);
        });
    }
    
}