import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/Pricing_xlsx";
import getQLIData from '@salesforce/apex/Pricing_RunExportController.getQLIData';
import personaCheck from '@salesforce/apex/Pricing_RunExportController.personaCheck';
import pricingReview from '@salesforce/label/c.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview';
import rpmPS from '@salesforce/label/c.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager';
import noQli from '@salesforce/label/c.Pricing_Tender_Run_Export_Error';

export default class Pricing_ReportExport extends LightningElement {
    @api recordId;
    @track xlsHeader = []; // store all the headers of the the tables
    @track workSheetNameList = []; // store all the sheets name of the the tables
    @track xlsData = []; // store all tables data
    @track filename = "Report.xlsx"; // Name of the file
    isRPM = false;
    connectedCallback(){
        personaCheck({psName : [rpmPS]})
            .then(result => {
                this.isRPM = result;
                this.getAllDeatils();
            })
            .catch(error => {
                this.showToast(error.body.message);
                this.reset();
                console.log("failure");
            });
    }
    
        getAllDeatils() {
        let data = [];
        let header = [];
        Promise.all([loadScript(this, workbook + "/xlsx.full.min.js")])
            .then(() => {
                getQLIData({recordId : this.recordId})
                    .then(result => {
                        for (var key in result) {
                            data = [];
                            header = [];
                            for(var headerKey in result[key]){
                                data = result[key][headerKey];
                                header = headerKey.split(',');
                            }
                            data.sort(this.getSortOrder(header.indexOf("Quote Line Number")));
                            this.xlsFormatter(data,key,header);
                            this.filename = 'IQR - '+data[0][header.indexOf("Quote Number")]+' - INTEL CONFIDENTIAL'+".xlsx";
                        };
                            this.download();
                    })
                    .catch(error => {
                        console.error(error);
                        this.showToast(error.body.message);
                        this.reset();
                        
                    });
            })
            .catch(error => {
                console.error(error);
                this.showToast(error.body.message);
                this.reset();
                console.log("failure");
            });
    }

    //Comparer Function    
    getSortOrder(prop) {
        return function (a, b) {
            if (a[prop] > b[prop]) {
                return 1;
            } else if (a[prop] < b[prop]) {
                return -1;
            }
            return 0;
        }
    }  
    
    // formating the data to send as input to  xlsxMain component
    xlsFormatter(data, sheetName,label) {
        let Header = label;
        this.xlsHeader.push(Header);
        this.workSheetNameList.push(sheetName);
        this.xlsData.push(data);
    }
    
    download() {
        const XLSX = window.XLSX;
        let xlsData = this.xlsData;
        let xlsHeader = this.xlsHeader;
        let ws_name = this.workSheetNameList;
        let createXLSLFormatObj = Array(xlsData.length).fill([]);
        //let xlsRowsKeys = [];
        
        if(xlsData.length === 0){
            this.showToast(this.isRPM ? noQli.replace('{{pricingReview}}',pricingReview) : noQli.replace('{{pricingReview}}',''));
        }
        else{
            /* form header list */
            xlsHeader.forEach((item, index) => createXLSLFormatObj[index] = [item])
                
                /* form data key list */
                xlsData.forEach((item, selectedRowIndex)=> {
                    item.forEach((value, index) => {
                        let xlsRowKey = Object.keys(item[index]);
                        var innerRowData = [];
                        xlsRowKey.forEach(item=>{
                            innerRowData.push(value[item]);
                        })
                            createXLSLFormatObj[selectedRowIndex].push(innerRowData);
                    })
                        
                        });
            /* creating new Excel */
            var wb = XLSX.utils.book_new();
            
            /* creating new worksheet */
            var ws = Array(createXLSLFormatObj.length).fill([]);
            for (let i = 0; i < ws.length; i++) {
                /* converting data to excel format and puhing to worksheet */
                let data = XLSX.utils.aoa_to_sheet(createXLSLFormatObj[i]);
                ws[i] = [...ws[i], data];
                
                /* Add worksheet to Excel */
                XLSX.utils.book_append_sheet(wb, ws[i][0], ws_name[i]);
            }
            
            /* Write Excel and Download */
            XLSX.writeFile(wb, this.filename);
        }
        this.reset();
    }
    
    showToast(message){
        const variant = 'error';
        const event = new ShowToastEvent({
            title: '',
            message: message,
            variant: variant
          });
        this.dispatchEvent(event);
    }
    
    reset(){
        this.xlsHeader = []; // store all the headers of the the tables
        this.workSheetNameList = []; // store all the sheets name of the the tables
        this.xlsData = []; // store all tables data
        const closeAction = new CustomEvent("CloseExport");
        this.dispatchEvent(closeAction);
    }
}