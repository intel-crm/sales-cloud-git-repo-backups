import { LightningElement, api, track, wire } from 'lwc';
import getReportData from '@salesforce/apex/Pricing_ReportExportController.getReportData';
import getColumnHeaders from '@salesforce/apex/Pricing_ReportExportController.getColumnHeaders';
export default class Pricing_ReportExportQA extends LightningElement {
    @api recordId;
    @track dataList;
    @track columnList;
    @track columnDivider = ',';
    @track lineDivider = '\r\n';
    @track csvStringResult = '';
    @track counter = 0;

    @wire(getReportData, { quoteIdParam: '$recordId' })
    getReportDetails({ error, data }) {
        if (data) {
            this.dataList = data;
            console.log(this.dataList);
            this.error = undefined;
        } else if (error) {
            console.log(error.body.message);
            this.error = error;
            this.dataList = undefined;
        }
    }

    @wire(getColumnHeaders, { quoteIdParam: '$recordId' })
    getColumnDetails({ error, data }) {
        if (data) {
            this.columnList = data;
            console.log(this.columnList);
            this.error = undefined;
        } else if (error) {
            console.log(error.body.message);
            this.error = error;
            this.columnList = undefined;
        }
    }

    @api invoke() {
        if (this.dataList != null) {
            const reportData = this.dataList;
            const keys = this.columnList;
            this.csvStringResult += keys.join(this.columnDivider);
            this.csvStringResult += this.lineDivider;
            for (var i = 0; i < reportData.length; i++) {
                if (this.csvStringResult == '' || this.csvStringResult == null) {
                    this.csvStringResult += keys;
                    this.csvStringResult += this.lineDivider;
                }
                this.csvStringResult += '"' + reportData[i] + '"' + this.columnDivider;
                this.counter++;
                if (this.counter == keys.length) {
                    this.csvStringResult += this.lineDivider;
                    this.counter = 0;
                }
            }
        }
        if (this.csvStringResult != null) {
            var hiddenElement = document.createElement('a');
            hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(this.csvStringResult);
            hiddenElement.target = '_self';
            hiddenElement.download = 'ExportData.csv';
            document.body.appendChild(hiddenElement);
            hiddenElement.click();
        }
        this.csvStringResult = '';
    }
}