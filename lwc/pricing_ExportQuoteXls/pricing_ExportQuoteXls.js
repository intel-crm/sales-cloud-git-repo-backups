import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getQuoteLineData from '@salesforce/apex/pricing_ExportQuotes.getQuoteLineData';

const FIELDS = ['SBQQ__Quote__c.Name'];
export default class Pricing_ExportQuoteXls extends LightningElement {
    @api recordId;

    @track xlsHeader = []; // store all the headers of the the tables
    @track workSheetNameList = []; // store all the sheets name of the the tables
    @track xlsData = []; // store all tables data
    @track filename = "Demo.xlsx"; // Name of the file

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            console.log('error wiredRecord : =>>>', error);
        } else if (data) {
            this.filename = '' + data.fields.Name.value + '.xlsx';
        }
    }

    @api invoke() {
        getQuoteLineData({ recordId: this.recordId })
            .then(result => {
                console.log('result' + JSON.stringify(result));
                for (var key in result) {
                    this.xlsFormatter(result[key], key);
                }
                console.log('Before download');
                this.download();
            })
            .catch(error => {
                console.error(error);
            });
    }

    xlsFormatter(data, sheetName) {
        let Header = Object.keys(data[0]);
        this.xlsHeader.push(Header);
        this.workSheetNameList.push(sheetName);
        this.xlsData.push(data);
    }

    download() {
        console.log('download');
        const XLSX = window.XLSX;
        let xlsData = this.xlsData;
        let xlsHeader = this.xlsHeader;
        let ws_name = this.workSheetNameList;
        let createXLSLFormatObj = Array(xlsData.length).fill([]);
        xlsHeader.forEach((item, index) => createXLSLFormatObj[index] = [item])

        xlsData.forEach((item, selectedRowIndex) => {
            let xlsRowKey = Object.keys(item[0]);
            item.forEach((value, index) => {
                var innerRowData = [];
                xlsRowKey.forEach(item => {
                    innerRowData.push(value[item]);
                })
                createXLSLFormatObj[selectedRowIndex].push(innerRowData);
            })

        });

        var wb = XLSX.utils.book_new();
        var ws = Array(createXLSLFormatObj.length).fill([]);
        for (let i = 0; i < ws.length; i++) {
            let data = XLSX.utils.aoa_to_sheet(createXLSLFormatObj[i]);
            ws[i] = [...ws[i], data];

            XLSX.utils.book_append_sheet(wb, ws[i][0], ws_name[i]);
        }
        XLSX.writeFile(wb, this.filename);
        this.reset();
    }

    reset() {
        this.xlsHeader = [];
        this.workSheetNameList = [];
        this.xlsData = [];
    }
}