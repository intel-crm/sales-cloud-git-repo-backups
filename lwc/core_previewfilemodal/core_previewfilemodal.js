import { api, LightningElement } from 'lwc';

export default class Core_previewfilemodal extends LightningElement {

    @api url; // URL of the file to preview
    @api extension; // File extension
    @api downloadLink; // Download link for the file
    @api documentLabel; // Label for the document

    showFrame = false; // Flag to show iframe for PDF files
    showModal = false; // Flag to show modal
    showImage = false; // Flag to show image preview

    // Method to show the modal
    @api show() {
        if (this.extension === 'PNG' || this.extension === 'JPG') {
            this.showImage = true;
            this.showFrame = false;
        } else {
            this.showFrame = true;
            this.showImage = false;
        }
        this.showModal = true;
    }

    // Method to close the modal
    closeModal() {
        this.showModal = false;
        this.showFrame = false;
        this.showImage = false;
        this.url = '';

        // Dispatch event to notify parent component about modal visibility change
        const selectedEvent = new CustomEvent("progressvaluechange", {
            detail: false
        });
        this.dispatchEvent(selectedEvent);
    }

    // Method to handle file download
    handleDownload() {
        document.body.appendChild(this.downloadLink);
        this.downloadLink.click();
    }
}