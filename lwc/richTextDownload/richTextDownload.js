import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import getRichTextFieldContent from '@salesforce/apex/RichTextPdfController.getRichTextContent';
import jsPDF from '@salesforce/resourceUrl/jsPDF'; // jsPDF static resource
import dompurify from '@salesforce/resourceUrl/DOMPurify'; // DOMPurify static resource

export default class RichTextToPdf extends LightningElement {
    @api recordId; // Record ID passed to the component
    fileName = 'RichTextContent.pdf'; // Default file name
    richTextContent; // Holds the fetched rich text content
    isLibrariesLoaded = false;

    connectedCallback() {
        // Load jsPDF and dompurify libraries
        Promise.all([loadScript(this, jsPDF), loadScript(this, dompurify)])
            .then(() => {
                this.isLibrariesLoaded = true;
            })
            .catch((error) => {
                console.error('Error loading libraries:', error);
            });
    }

    handleFileNameChange(event) {
        this.fileName = event.target.value;
    }

    downloadPDF() {
        if (!this.isLibrariesLoaded) {
            console.error('Libraries are not loaded.');
            return;
        }
    
        getRichTextFieldContent({ recordId: this.recordId })
            .then((content) => {
                console.log('Fetched content:', content);
                this.richTextContent = content;
    
                if (!this.richTextContent || typeof this.richTextContent !== 'string') {
                    console.error('Invalid or empty rich text content.');
                    this.richTextContent = '<div>No content available</div>';
                }
    
                // Sanitize and generate the PDF
                try {
                    // Validate and wrap rich text content
                    const validHtmlContent = `<div>${this.richTextContent || 'No content available'}</div>`;
                    console.log('Valid HTML Content:', validHtmlContent);
                
                    // Sanitize the HTML content
                    const sanitizedContent = window.DOMPurify.sanitize(validHtmlContent);
                    console.log('Sanitized HTML Content:', sanitizedContent);
                
                    // Generate the PDF with jsPDF
                    const pdf = new window.jspdf.jsPDF();
                    pdf.html(sanitizedContent, {
                        callback: (doc) => {
                            doc.save(this.fileName); // Download the file
                        },
                        x: 10,
                        y: 10,
                        width: 180, // Adjust content width if necessary
                    });
                } catch (error) {
                    console.error('Error sanitizing or generating PDF:', error);
                }
                
            })
            .catch((error) => {
                console.error('Error fetching rich text content:', error);
            });
    }
    
    
        
    }