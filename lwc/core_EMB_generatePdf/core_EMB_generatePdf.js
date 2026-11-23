import { LightningElement, api, wire, track } from 'lwc';
import getRecordDetails from '@salesforce/apex/Core_EMBgeneratePdfController.Core_EMBgeneratePdfController';
import jsPDF from '@salesforce/resourceUrl/jsPDF';
import html2canvas from '@salesforce/resourceUrl/html2canvas';
import { loadScript } from 'lightning/platformResourceLoader';

export default class RecordPdfGenerator extends LightningElement {
    @api recordId;
    recordData;
    libsLoaded = false;

    @track richTextContent = '';

    @wire(getRecordDetails, { recordId: '$recordId' })
    wiredRecord({ data, error }) {
        if (data) {
            this.recordData = data;
             this.richTextContent = data.CRM_Intels_Meeting_Objectives__c || '';
                     console.log('richTextContent....'+this.richTextContent);
                     console.log('this.recordData....'+this.recordData);
          //  this.richText();

        } else if (error) {
            console.error('Error loading record', error);
        }
    }

   /* renderedCallback() {
        // Check if the libraries are already loaded, if not, load them
        if (this.libsLoaded) return;
        this.libsLoaded = true;

        Promise.all([
            loadScript(this, jsPDF),
            loadScript(this, html2canvas)
        ])
        .then(() => {
            console.log('Libraries loaded');
        })
        .catch(error => {
            console.error('Error loading scripts', error);
        });

        // this.richText();
        /* setTimeout(() => {
                const richTextDiv = this.template.querySelector('.rich-text');
                console.log('richTextDiv...'+richTextDiv);
                if (richTextDiv && this.richTextContent && richTextDiv.innerHTML !== this.richTextContent) {
                    richTextDiv.innerHTML = this.richTextContent; // Set the rich text content
                    console.log(' richTextDiv.innerHTML....'+ richTextDiv.innerHTML);
                }
            }, 100);//
       
        
    } */
    /*   richText(){
                setTimeout(() => {
                const richTextDiv = this.template.querySelector('.rich-text');
                console.log('richTextDiv...'+richTextDiv);
                if (richTextDiv && this.richTextContent && richTextDiv.innerHTML !== this.richTextContent) {
                    richTextDiv.innerHTML = this.richTextContent; // Set the rich text content
                    console.log(' richTextDiv.innerHTML....'+ richTextDiv.innerHTML);
                }
            }, 100);
            
        }*/
    
    
   /* generatePdf() {
        // Ensure the #pdfContent element exists
        const content = this.template.querySelector('#pdfContent');
         console.log('content...'+content);
        if (content) {
            // Proceed with the PDF generation if #pdfContent is valid
            window.html2canvas(content).then(canvas => {
                const imgData = canvas.toDataURL('image/png');
                const pdf = new window.jspdf.jsPDF('p', 'mm', 'a4');
                const pdfWidth = pdf.internal.pageSize.getWidth();
                const imgProps = pdf.getImageProperties(imgData);
                const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;

                pdf.addImage(imgData, 'PNG', 0, 0, pdfWidth, pdfHeight);
                pdf.save(`${this.recordData.Name}-Summary.pdf`);
            }).catch(error => {
                console.error('Error generating PDF:', error);
            });
        } else {
            console.error('Error: #pdfContent element is still not available in the DOM');
        }
    }*/

   generatePDF() {
        // Wait for jsPDF to load
        const jsPDF =new window.jspdf.jsPDF;
        
        if (jsPDF) {
            // Create a new jsPDF instance
            const doc = new jsPDF();
            
            // Get the container to inject rich text content
            const richTextElement = this.template.querySelector('.rich-text-content');

            // Dynamically set the innerHTML to the rich text
            richTextElement.innerHTML = this.richText;

            // Use jsPDF to render HTML to PDF
            doc.html(richTextElement, {
                callback: function (doc) {
                    // Save the generated PDF
                    doc.save('generated-document.pdf');
                },
                x: 10,
                y: 10
            });
        } else {
            console.error('jsPDF is not loaded');
        }
    }
}