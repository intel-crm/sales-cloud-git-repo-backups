import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import jsPDFLibrary from '@salesforce/resourceUrl/JsPDFLibrary';
import autoTableLibrary from '@salesforce/resourceUrl/AutoTable';
import ChartJSResource from '@salesforce/resourceUrl/chartJs';
import getAccountPlan from '@salesforce/apex/CRM_AccountPlanController.getAccountPlan';
import getHotButtons from '@salesforce/apex/CRM_APController.getHotButtons';

export default class GeneratePDFCmp extends LightningElement {
    @api recordId;
    accountplan = {};
    hotButtonIssues = [];
    jsPDFInitialized = false;
    autoTableLoaded = false;
    chartJSLoaded = false;

    renderedCallback() {
        if (!this.jsPDFInitialized) {
            this.jsPDFInitialized = true;
            Promise.all([
                loadScript(this, jsPDFLibrary),
                loadScript(this, autoTableLibrary),
                loadScript(this, ChartJSResource)
            ])
                .then(() => {
                    this.autoTableLoaded = true;
                    this.chartJSLoaded = true;
                    this.fetchCurrentData();
                    this.fetchHotButtonIssues();
                })
                .catch(error => console.error('Error loading libraries', error));
        }
    }

    fetchCurrentData() {
        getAccountPlan({ recordId: this.recordId })
            .then(result => {
                this.accountplan = result || {};
            })
            .catch(error => {
                console.error('Error fetching account plan:', error);
            });
    }

    fetchHotButtonIssues() {
        getHotButtons({ accountPlanId: this.recordId })
            .then(result => {
                this.hotButtonIssues = result || [];
            })
            .catch(error => {
                console.error('Error fetching hot button issues:', error);
            });
    }

    async generatePDF() {
        if (!this.autoTableLoaded || !this.chartJSLoaded) {
            console.error('Libraries not initialized.');
            return;
        }

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF('l', 'mm', 'a4');
        let startY = 15;

        // Page Header
        doc.setFont('Helvetica', 'bold');
        doc.setFontSize(16);
        doc.text('Customer Name One-Pager', 10, startY);
        doc.setFontSize(11);
        doc.text(`Fiscal Year: ${new Date().getFullYear()}`, 10, startY + 7);
        startY += 15;

        // Section Header Function
        const addSection = (title, x, y, width = 90) => {
            doc.setFillColor(30, 144, 255);
            doc.setTextColor(255, 255, 255);
            doc.rect(x, y, width, 10, 'F');
            doc.setFontSize(12);
            doc.text(title, x + 5, y + 7);
            doc.setTextColor(0, 0, 0);
            return y + 15;
        };

        // Define column positions
        let leftX = 10, centerX = 105, rightX = 200;
        let leftY = startY, centerY = startY, rightY = startY;

        // Left Column - Customer Overview
        leftY = addSection('Customer Overview', leftX, leftY);
        leftY = this.addTable(doc, leftX, leftY, ['Metric', 'Value'], [
            ['Market Cap (as of DATE)', this.accountplan?.Core_Market_Cap__c || 'N/A'],
            ['Revenue', this.accountplan?.Core_Revenue__c || 'N/A'],
            ['Net Income', this.accountplan?.Core_Net_Income__c || 'N/A'],
            ['Account Revenue', this.accountplan?.Core_Account_Revenue__c || 'N/A'],
            ['Intel Contra Investment', this.accountplan?.Intel_Contra_Investment__c || 'N/A'],
            ['Intel Sales Headcount', this.accountplan?.Core_Employees__c || 'N/A']
        ]);

        // Row 1: Account Revenue & Hot Button Issues
        centerY = addSection('Account Revenue ($M)', centerX, startY);
        centerY = await this.addChart(doc, centerX, centerY);

        rightY = addSection('Hot Button Issues', rightX, startY);
        rightY = this.addTable(doc, rightX, rightY, ['Name', 'Description', 'Priority'], 
            this.hotButtonIssues.map(issue => [
                issue.Name || 'N/A',
                issue.CRM_Description__c || 'N/A',
                issue.CRM_Priority__c || 'N/A'
            ])
        );

        // Ensure the next row starts at the same Y position
        let rowY = Math.max(leftY, centerY, rightY) + 10;

        // Row 2: Relationship Assessment, Transformational Opportunities & Help Needed (same row)
        leftY = addSection('Relationship Assessment', leftX, rowY);
        leftY = this.addTable(doc, leftX, leftY, null, [
            ['Assessment 1', 'Value 1'],
            ['Assessment 2', 'Value 2'],
            ['Assessment 3', 'Value 3']
        ]);

        centerY = addSection('Transformational Opportunities', centerX, rowY);
        centerY = this.addTable(doc, centerX, centerY, null, [
            ['Example:', 'Add text'],
            ['Example:', 'Add text']
        ]);

        rightY = addSection('Help Needed', rightX, rowY);
        rightY = this.addTable(doc, rightX, rightY, null, [
            ['Example:', 'Add text'],
            ['Example:', 'Add text']
        ]);

        doc.save('Customer_OnePager.pdf');
    }

    addTable(doc, startX, startY, head, body) {
        doc.autoTable({
            startY,
            margin: { left: startX },
            head: head ? [head] : undefined,
            body,
            styles: { fontSize: 9, cellPadding: 2 },
            theme: 'grid',
            tableWidth: 90,
            columnStyles: {
                0: { cellWidth: 30 }, // Name
                1: { cellWidth: 40 }, // Description
                2: { cellWidth: 20 }  // Priority
            }
        });
        return doc.lastAutoTable.finalY + 5;
    }

    async addChart(doc, x, y) {
        return new Promise((resolve) => {
            let canvas = document.createElement('canvas');
            canvas.width = 250;
            canvas.height = 120;
            let ctx = canvas.getContext('2d');

            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: ['2020', '2021', '2022', '2023'],
                    datasets: [{
                        label: 'Revenue ($M)',
                        data: [10, 12, 15, 18],
                        backgroundColor: ['#ff6384', '#36a2eb', '#ffce56', '#4bc0c0']
                    }]
                },
                options: {
                    responsive: false,
                    maintainAspectRatio: false,
                    legend: { display: false },
                    scales: {
                        y: { beginAtZero: true }
                    }
                }
            });

            setTimeout(() => {
                let imgData = canvas.toDataURL('image/png');
                doc.addImage(imgData, 'PNG', x, y, 80, 40);
                resolve(y + 45);
            }, 500);
        });
    }
}