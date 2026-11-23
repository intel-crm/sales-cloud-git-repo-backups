import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { loadScript } from 'lightning/platformResourceLoader';
import jsPDFLibrary from '@salesforce/resourceUrl/JsPDFLibrary';
import html2canvasLibrary from '@salesforce/resourceUrl/html2canvas';
import CRM_REACTIVE_TALKING_POINTS_FIELD from '@salesforce/schema/Executive_Meeting_Brief__c.CRM_Reactive_Talking_Points__c';
import CRM_PROACTIVE_TALKING_POINTS_FIELD from '@salesforce/schema/Executive_Meeting_Brief__c.CRM_Proactive_Talking_Points__c';

export default class GeneratePdfButton extends LightningElement {
    @api recordId;
    @track jsPDFInitialized = false;

    @wire(getRecord, { recordId: '$recordId', fields: [CRM_REACTIVE_TALKING_POINTS_FIELD, CRM_PROACTIVE_TALKING_POINTS_FIELD] })
    record;

    renderedCallback() {
        if (!this.jsPDFInitialized) {
            this.jsPDFInitialized = true;
            Promise.all([
                loadScript(this, jsPDFLibrary),
                loadScript(this, html2canvasLibrary)
            ])
            .then(() => {
                console.log('jsPDF and html2canvas loaded successfully');
            })
            .catch(error => console.error('Error loading libraries', error));
        }
    }

    handleGeneratePdf() {
        console.log('Inside handle generatepdf method:' + this.recordId);
        if (this.record.data) {
            console.log('PDF DATA IS:' + JSON.stringify(this.record.data));
            const reactivePoints = this.record.data.fields.CRM_Reactive_Talking_Points__c.value;
            const proactivePoints = this.record.data.fields.CRM_Proactive_Talking_Points__c.value;
            console.log('PROACTIVE IS:' + proactivePoints);
            console.log('REACTIVE IS:' + reactivePoints);

            // Set the content of the container elements
            const reactiveElement = this.template.querySelector('#reactiveContent');
            const proactiveElement = this.template.querySelector('#proactiveContent');

            if (reactiveElement && proactiveElement) {
                reactiveElement.innerHTML = reactivePoints;
                proactiveElement.innerHTML = proactivePoints;

                this.generatePdf(reactiveElement, proactiveElement);
            } else {
                console.error('Elements not found in the DOM');
            }
        } else if (this.record.error) {
            console.log('PDF ERROR:', this.record.error);
        }
    }

    generatePdf(reactiveElement, proactiveElement) {
        if (window.jspdf && window.html2canvas) {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF();

            doc.setFontSize(12);
            doc.text('Executive Meeting Brief', 10, 10);

            // Use html2canvas to capture the HTML content
            html2canvas(reactiveElement).then(canvas => {
                const imgData = canvas.toDataURL('image/png');
                doc.addImage(imgData, 'PNG', 10, 30, 180, canvas.height * 180 / canvas.width);
                html2canvas(proactiveElement).then(canvas => {
                    const imgData = canvas.toDataURL('image/png');
                    doc.addPage();
                    doc.addImage(imgData, 'PNG', 10, 30, 180, canvas.height * 180 / canvas.width);
                    doc.save('Executive_Meeting_Brief.pdf');
                });
            });
        } else {
            console.error('jsPDF or html2canvas is not loaded');
        }
    }
}