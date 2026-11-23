import { LightningElement,api,track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import jsPDFLibrary from '@salesforce/resourceUrl/JsPDFLibrary';
import getstripHtmlTags from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getstripHtmlTags';
import DOMPurify from '@salesforce/resourceUrl/DOMPurify';

export default class Core_Generate_PDF_For_EMB extends LightningElement {
    @api recordid;
    @track richTextField;

    jsPDFInitialized = false;
    renderedCallback() {
        if (!this.jsPDFInitialized) {
            this.jsPDFInitialized = true;
            Promise.all([
                loadScript(this, jsPDFLibrary),
                loadScript(this, DOMPurify)
            ]).then(() => {
                    this.fetchStripHtmlTags();
                })
                .catch(error => console.error('Error loading libraries', error));
        }
    }


    fetchStripHtmlTags(){
        getstripHtmlTags().then(result => {
            this.richTextField = result;
            console.log('richtextfield without tags'+this.richTextField);
        }).catch(error => {
            this.error = error;
        })
    }
    richTextContent = '<p><span style="font-family: Cambria, serif; font-size: 12pt;">Understand SRF product advantage, ecosystem partner readiness and future Xeon roadmap </span><span style="font-family: Cambria, serif; font-size: 16px; color: rgb(68, 68, 68);">Understand SRF product advantage, ecosystem partner readiness and future Xeon roadmap U</span><strong style="font-family: Cambria, serif; font-size: 16px; color: rgb(68, 68, 68);">nderstand SRF product advantage, ecosystem partner readiness and future Xeon roadmap</strong></p><ul><li><span style="font-family: Cambria, serif; font-size: 16px;">﻿</span><span style="font-family: Cambria, serif; font-size: 16px; background-color: rgb(255, 255, 255);">test</span></li><li><span style="font-family: Cambria, serif; font-size: 16px; background-color: rgb(255, 255, 255);">Bullet </span></li><li><span style="font-family: Cambria, serif; font-size: 16px; background-color: rgb(255, 255, 255);">points</span><img src="https://intel--crmdevsls3.sandbox.file.force.com/servlet/rtaImage?eid=aCwDf00000003xk&amp;feoid=00NDf00000QMoy6&amp;refid=0EMDf0000002nZO" alt="rtaImage.jpg"></img></li></ul>'; // Example content
    get sanitizedContent() {
        return DOMPurify.sanitize(this.richTextContent);
    }
    

    generatePDF() {
        console.log('inside generate pdf');
        if(this.jsPDFInitialized){
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const content = this.sanitizedContent;

        // Add content to PDF
        doc.html(content, {
            callback: function (doc) {
                doc.save('rich-text.pdf');
            },
            x: 10,
            y: 10
        });
       // doc.text(this.richTextField,10,10);
        doc.save('Sample.pdf');
    }else{
        console.error('jsPDF is not initialized.');
    }
    }
    
}