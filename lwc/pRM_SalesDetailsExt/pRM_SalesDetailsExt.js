import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getExtSalesDetails from "@salesforce/apex/PRM_External_Objects_Data.getExtSalesDetails1";
import { exportAsCSV } from "c/pRM_Utils";
import AccountNo from "@salesforce/label/c.PRM_Account_No";
import InvoiceNumberCol from "@salesforce/label/c.PRM_Invoice_Number";
import InvoicedDate from "@salesforce/label/c.PRM_Invoiced_Date";
import FormFactor from "@salesforce/label/c.PRM_Form_Factor";
import IntelBrand from "@salesforce/label/c.PRM_Intel_Brand";
import ProductNumber from "@salesforce/label/c.PRM_Product_Number";
import InvoicedUnits from "@salesforce/label/c.PRM_Invoiced_Units";
import PRM_DashboardDownloadLimit from "@salesforce/label/c.PRM_DashboardDownloadLimit";
import DistriButor from "@salesforce/label/c.PRM_Distributor_Name";
import SalesType from "@salesforce/label/c.PRM_Sales_Type";
import dtSeleError from "@salesforce/label/c.PRM_Date_Selection_Error";
import dtSeleErrorMsg from "@salesforce/label/c.PRM_Date_Selection_Error_Message";
import noRecordsError from "@salesforce/label/c.PRM_No_Records_Error";
import noRecordsErrorMsg from "@salesforce/label/c.PRM_No_Records_Error_Message";
import noDataError from "@salesforce/label/c.PRM_Criteria_Search_Error";
import noDataErrorMsg from "@salesforce/label/c.PRM_Search_Criteria_Error_Message";
import noInvoiceErrorMsg from "@salesforce/label/c.PRM_No_Invoice_Error_Message";
import header from "@salesforce/label/c.PRM_Sales_Data_Header";
import invoiceNumberPlaceholder from "@salesforce/label/c.PRM_Invoice_Number_Placeholder";
import lblFrom from "@salesforce/label/c.PRM_From";
import lblTO from "@salesforce/label/c.PRM_To";
import filterBtn from "@salesforce/label/c.PRM_Filter_Button";
import exportBtn from "@salesforce/label/c.PRM_Export_Button";
import prevBtn from "@salesforce/label/c.PRM_Previous_Button";
import nextBtn from "@salesforce/label/c.PRM_Next_Button";
import startDatePlaceHolder from "@salesforce/label/c.PRM_Start_Date";
import endDatePlaceHolder from "@salesforce/label/c.PRM_End_Date";
import salesRecordError from "@salesforce/label/c.PRM_No_Sales_Records_Message";
import salesDetailsDatasetName from "@salesforce/label/c.PRM_Sales_Details_Dataset";
import pgSize from "@salesforce/label/c.PRM_SOD_Training_Page_Size";
import orLabel from "@salesforce/label/c.PRM_OR";
import ProductOrderingCode from "@salesforce/label/c.PRM_Old_Material";
import ProductCodeNumber from "@salesforce/label/c.PRM_item_id";
import MeasurementPeriod from "@salesforce/label/c.PRM_Measurement_Period";
import {NavigationMixin} from 'lightning/navigation';
import getIntegerList from "@salesforce/apex/Core_MDF_CustomLabelConfig.getIntegerList";
const columns = [
    {
        label: AccountNo,
        fieldName: "account_number", // account_number
        type: "text",
        cellAttributes: { alignment: "center" }
    },
    {
        label: InvoiceNumberCol,
        fieldName: "invoice_number", // invoice_number
        type: "text",
        cellAttributes: { alignment: "center" }
        // initialWidth: 120
    },
    {
        label: InvoicedDate,
        fieldName: "invoice_date", // invoice_date
        type: "text",
        cellAttributes: { alignment: "center" }
    },
    {
        label: FormFactor,
        fieldName: "form_factor", // form_factor
        type: "text",
        cellAttributes: { alignment: "center" }
    },
    {
        label: ProductOrderingCode,
        fieldName: "productOrderingCode", //intel_brand
        type: "text",
        cellAttributes: { alignment: "center" }
    },
    {
        label: ProductCodeNumber,
        fieldName: "productCodeNumber", //product_number
        type: "text",
        cellAttributes: { alignment: "center" }
    },
    {
        label: InvoicedUnits,
        fieldName: "sales_out_units", //sales_out_units
        type: "number",
        cellAttributes: { alignment: "center" }
    },
    {
        label: DistriButor,
        fieldName: "distributor_name", //distributor_name
        type: "text",
        cellAttributes: { alignment: "center" }
        // initialWidth: 120
    },
    {
        label: SalesType,
        fieldName: "sales_type", //sales_type
        type: "text",
        cellAttributes: { alignment: "center" }
        // initialWidth: 200
    },
    {
        label: MeasurementPeriod,
        fieldName: "Measurement_Period",
        type: "text",
        cellAttributes: { alignment: "center" }
        // initialWidth: 200
    }
];

export default class PRM_SalesDetailsExt extends NavigationMixin(LightningElement) {
    salesRecordErrorLbl = salesRecordError;
    headerLbl = header;
    dtFrom = lblFrom;
    dtTo = lblTO;
    lblOR = orLabel;
    nextBtnLbl = nextBtn;
    prevBtnLbl = prevBtn;
    startDatePlaceHolderlbl = startDatePlaceHolder;
    endDatePlaceHolderlbl = endDatePlaceHolder;
    exportBtnLbl = exportBtn;
    filterBtnLbl = filterBtn;
    invoiceNumberLbl = InvoiceNumberCol;
    invoiceNumberPlaceholderLbl = invoiceNumberPlaceholder;
    measurementPeriod = MeasurementPeriod;
    columns = columns;

    @track isFilterOn = false;
    @track isData = false;
    @track currentpage = 1;
    @track pagesize = parseInt(pgSize);
    @track hasRender;
    @track count = 1;
    @track endDate = "";
    @track startDate = "";
    @track spinner = false;
    @track invoiceNumber = "";
    @track records = [];
    @track error;
    @track loadMore = false;
    @track loadPrev = false;
    @track doRun = false;
    @track lastInv = "";
    @track prevtInv = "";
    @track prevtInv1 = "";
    @track diffDays;
    @track lInv;
    @track fInv;
    @track exprtData;
    dataSetName = salesDetailsDatasetName;
    @track isDataAvailable;
    @track prevInvLst1 = [];
    @track allRecordsExport = [];
    @track isFilterData = false;
    offsetCount = 0;
    lastInvtoPass = '';
    showBtmButton = false;

    handleExport() {
        this.offsetCount = (this.currentpage - 1) *  this.pagesize;
        if (this.isFilterOn) {
            exportAsCSV(
                this.dataSetName,
                this.currentpage,
                this.allRecordsExport
            );
            console.log("isFilterOn" + this.isFilterOn);
        } else {
            console.log(">>>>>>11111");
            getExtSalesDetails({
                invoiceNumber: "",
                lastInv: this.lastInv,
                prevInv: "",
                prevInv1: "",
                pageSize: this.pagesize,
                startDate: "",
                endDate: "",
                isDownload: true,
                lastInvtoPass: this.lastInvtoPass
            })
                .then((result) => {
                    console.log('>>>>result.limitBreached : '+result.limitBreached);
                    if (
                        result != null &&
                        result != undefined /*&&
                        !result.limitBreached*/
                    ) {
                        exportAsCSV(this.dataSetName, this.currentpage, result.wrap);
                    } /*else {
                        this[NavigationMixin.GenerateUrl]({
                            type: 'standard__webPage',
                            attributes: {
                                url: "/apex/prm_downloadVF?invoiceNumber="+this.invoiceNumber+"&startDate"+this.startDate+"&endDate="+this.endDate+"&dataType=salesData",
                            }
                        }).then(generatedUrl => {
                            window.open(generatedUrl, "_blank", "toolbar=no,scrollbars=no,resizable=no,top=200,left=200,width=800,height=400");
                        });
                    }*/
                })
                .catch((error) => {
                    console.log("Error :" + JSON.stringify(error));
                });
            console.log("isFilterOnelse" + this.isFilterOn);
        }
    }
    setInvoiceNumber(event) {
        const invoice = event.target.value;
        //console.log('set Invoice number :' + invoice);
        if (
            this.invoice !== null ||
            invoice.length > 0 ||
            invoice !== undefined
        ) {
            this.invoiceNumber = invoice;
        } else {
            this.invoiceNumber = "";
        }
    }
    getStringDate(dt) {
        //console.log('you are inside string date');
        let year;
        let month;
        let day;
        year = dt.getFullYear();
        month = (1 + dt.getMonth()).toString();
        month = month.length > 1 ? month : "0" + month;
        day = dt.getDate().toString();
        day = day.length > 1 ? day : "0" + day;
        return year + "-" + month + "-" + day;
    }
    setEndDate(event) {
        let dt = new Date(event.target.value);
        // console.log('Received date :' + dt);
        this.endDate = this.getStringDate(dt);
        if (
            this.endDate == "1970-01-01" ||
            this.endDate == "NaN-NaN-NaN" ||
            this.endDate === undefined
        ) {
            this.endDate = "";
        }
        //console.log(" Converted Date" + this.endDate);
    }
    setStartDate(event) {
        let dt = new Date(event.target.value);
        this.startDate = this.getStringDate(dt);
        if (
            this.startDate == "1970-01-01" ||
            this.startDate == "NaN-NaN-NaN" ||
            this.startDate === undefined
        ) {
            this.startDate = "";
        }
        //console.log(" STart Date :" + this.startDate);
    }

    criteriaSearch() {
        this.currentpage = 1;
        this.prevInvLst1 = [];
        // console.log('clicked');
        const dateDiffrence =
            Date.parse(this.endDate) - Date.parse(this.startDate);
        this.diffDays = Math.ceil(dateDiffrence / (1000 * 60 * 60 * 24));
        // console.log("Date difference :" + this.diffDays);

        if (
            this.diffDays > 30 ||
            Date.parse(this.startDate) > Date.parse(this.endDate)
        ) {
            //  console.log('from if :');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: dtSeleError,
                    message: dtSeleErrorMsg,
                    variant: "error"
                })
            );
        } else {
            this.isFilterOn = false;
            //  console.log('From invoice :' + this.invoiceNumber + 'invoice length :' + this.invoiceNumber.length + 'start date length ' + this.startDate.length + 'End date length :' + this.endDate.length)
            if (
                this.invoiceNumber.length !== 0 &&
                this.startDate.length === 0 &&
                this.endDate.length === 0
            ) {
                //   console.log('Your are inside invoice number...');
                //  console.log('From invoice :' + this.invoiceNumber);
                this.startDate = "";
                this.endDate = "";
                this.lastInv = "";
                this.prevtInv = "";
                this.loadMore = true;
                this.hasRender = false;
                this.isFilterOn = true;
                this.renderedCallback();
            } else if (
                this.invoiceNumber.length !== 0 &&
                this.startDate.length !== 0 &&
                this.endDate.length !== 0
            ) {
                //console.log('Inside all true');
                this.lastInv = "";
                this.prevtInv = "";
                this.hasRender = false;
                this.loadMore = false;
                this.isFilterOn = true;
                this.renderedCallback();
            } else if (
                this.invoiceNumber.length === 0 &&
                (this.startDate.length !== 0 || this.endDate.length !== 0)
            ) {
                this.isFilterOn = true;
                if (this.startDate.length !== 0 && this.endDate.length === 0) {
                    this.endDate = this.startDate;
                }
                if (this.endDate.length === 0 && this.endDate.length !== 0) {
                    this.startDate = "";
                    this.endDate = "";
                }
                //                console.log('From and To Date....');
                this.invoiceNumber = "";
                this.lastInv = "";
                this.prevtInv = "";
                this.hasRender = false;
                this.renderedCallback();
            } else {
                this.doRun = true;
                if (this.doRun) {
                    //                  console.log('from click btn :');
                    this.startDate = "";
                    this.endDate = "";
                    this.lastInv = "";
                    this.prevtInv = "";
                    this.hasRender = false;
                    this.loadPrev = true;
                    this.renderedCallback();
                }
            }
        }
    }
    isEmpty(obj) {
        for (var key in obj) {
            if (obj.hasOwnProperty(key)) return false;
        }
        return true;
    }
    handlNext() {
        if (!this.isFilterOn) {
            this.startDate = "";
            this.endDate = "";
        }
        this.currentpage = this.currentpage + 1;
        this.invoiceNumber = "";
        this.lastInv = this.lInv; // last row invoice number || order by Invoice_nbr__c
        this.prevtInv = "";
        this.prevtInv1 = "";
        //    console.log('Last Invoice :' + this.lastInv);
        this.hasRender = false;
        this.renderedCallback();
    }
    handlePrev() {
        if (!this.isFilterOn) {
            this.startDate = "";
            this.endDate = "";
        }
        this.currentpage = this.currentpage - 1;
        this.invoiceNumber = "";
        this.lastInv = "";
        //   console.log('Current page :' + this.currentpage);
        this.prevtInv = this.prevInvLst1[this.currentpage - 1];
        this.prevtInv1 = this.prevInvLst1[this.currentpage];
        this.prevInvLst1.pop(this.currentpage);

        //   console.log('Prev Invoice:' + this.prevtInv + 'Prev inv1' + this.prevtInv1 + 'new list :' + this.prevInvLst1);
        this.hasRender = false;
        this.renderedCallback();
    }
    getInfoToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: noRecordsError,
                message: noRecordsErrorMsg,
                variant: "info"
            })
        );
    }
    getDataFromFN(recordsList) {
        //  console.log('Inside fun');
        const record = recordsList[recordsList.length - 1];
        //  console.log('records retrieved :' + JSON.stringify(record));
        this.lastInv = record.invoice_number; //invoice_number
        this.lInv = record.invoice_number; //invoice_number
        this.prevtInv = recordsList[0].invoice_number; //invoice_number
        this.fInv = recordsList[0].invoice_number; //invoice_number
        this.loadPrev = this.currentpage === 1 ? true : false;
        if (!this.prevInvLst1.includes(this.fInv)) {
            this.prevInvLst1.push(this.fInv);
        }
        //  console.log('Previous Invoice List :' + this.prevInvLst1);
        //  console.log('Previous Invoice List :' + typeof (this.prevInvLst1[this.currentpage - 1]));
    }
    commonCode() {
        //   console.log('You are inside from next click');
        this.spinner = true;
        this.isData = false;
        //   console.log('Start Date :' + this.startDate + ' End Date :' + this.endDate + ' Inv' + this.invoiceNumber + 'Prev Invoice ' + this.prevtInv + 'Prev Invoice1 ' + this.prevtInv1);
        if (this.hasRender === false) {
            getExtSalesDetails({
                invoiceNumber: this.invoiceNumber,
                lastInv: this.lastInv,
                prevInv: this.prevtInv,
                prevInv1: this.prevtInv1,
                pageSize: this.pagesize,
                startDate: this.startDate,
                endDate: this.endDate,
                isDownload: false,
                lastInvtoPass: 0
            })
                .then((result) => {
                    if (result.wrap.length == 0) {
                        this.allRecordsExport = result.wrap;
                        this.records = result.wrap;
                        this.showBtmButton = this.records.length > 50 ? true : false; 
                        //     console.log('Last invoice :' + this.lastInv + 'Lenght of inv' + this.lastInv.length);
                        this.spinner = false;
                        this.hasRender = true;
                        this.isData = false;
                        this.loadPrev = true;
                        this.loadMore = true;
                        if (
                            this.startDate.length > 0 &&
                            this.endDate.length > 0 &&
                            this.invoiceNumber.length > 0
                        ) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: noDataError,
                                    message: noDataErrorMsg,
                                    variant: "info"
                                })
                            );
                        } else if (
                            this.startDate.length <= 0 &&
                            this.endDate.length <= 0 &&
                            this.invoiceNumber.length > 0
                        ) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: noDataError,
                                    message: noInvoiceErrorMsg,
                                    variant: "info"
                                })
                            );
                        }
                        this.isDataAvailable = true;
                        this.currentpage = 0;
                    } else if (result.length > this.pagesize) {
                        this.allRecordsExport = result.wrap;
                        const record = result.wrap.slice(
                            this.pagesize,
                            this.pagesize + 1
                        );
                        //    console.log('Data from record' + JSON.stringify(record));
                        this.lastInv = record[0].invoice_number; //invoice_number
                        this.lInv = record[0].invoice_number; //invoice_number
                        //     console.log('You are inside records > 200' + ' Last invoice number :' + this.lastInv);
                        this.spinner = false;
                        this.loadMore = false;
                        this.hasRender = true;
                        this.isData = true;
                        this.records = result.wrap.slice(0, this.pagesize);
                        this.showBtmButton = this.records.length > 50 ? true : false; 
                        console.log('Data from record' + JSON.stringify(this.records));
                        this.lastInvtoPass = this.records[0].invoice_number;
                        console.log('Passed data<1 ' + this.lastInvtoPass);
                        this.exprtData = this.records;
                        this.getDataFromFN(this.records);
                        this.isDataAvailable =
                            this.records.length < 1 ? true : false;
                        //    console.log('Last invoice number :' + this.lastInv + 'Prev inv :' + this.prevtInv);
                    } else {
                        this.allRecordsExport = result.wrap;
                        this.isData = true;
                        //   console.log('Invoice number inside :' + this.invoiceNumber);
                        this.loadMore =
                            result.wrap.length < this.pagesize ? true : false;
                        this.records = result.wrap;
                        this.showBtmButton = this.records.length > 50 ? true : false; 
                        this.lastInvtoPass = this.records[0].invoice_number;
                        console.log('Passed data<1 ' + this.lastInvtoPass);
                        this.exprtData = this.records;
                        //     console.log('Passed data<2 ' + this.exprtData);
                        this.getDataFromFN(this.records);
                        this.isDataAvailable =
                            this.records.length < 1 ? true : false;
                        //     console.log('Last invoice number :' + this.lastInv + 'Prev inv :' + this.prevtInv);
                        this.error = undefined;
                        this.spinner = false;
                        //     console.log('Records retr :' + JSON.stringify(this.records));
                        this.doRun = false;
                        this.hasRender = true;
                    }
                })
                .catch((error) => {
                    this.spinner = false;
                    this.error = error;
                    this.records = [];
                    this.hasRender = true;
                    //    console.log('Error :' + error);
                });
        }
    }

    renderedCallback() {
        console.log(this.lblOR);
        // console.log(' >> :' + AccountNo + '>> ' + InvoiceNumberCol + '>> ' + InvoicedDate + '>> ' + FormFactor + '>> ' + IntelBrand + '>> ' + ProductNumber + '>> ' + InvoicedUnits + '>> ' + SalesType + '>> ' + DistriButor);
        if (
            this.startDate == undefined ||
            this.endDate == undefined ||
            this.invoiceNumber === undefined
        ) {
            this.startDate = "";
            this.endDate = "";
            this.invoiceNumber = undefined;
        } else {
            this.startDate = "" + this.startDate;
            this.endDate = "" + this.endDate;
        }
        //   console.log('from render :' + this.hasRender);
        this.startDate = "" + this.startDate;
        this.endDate = "" + this.endDate;

        //        console.log('current page' + this.currentpage + ' count' + this.count);
        if (this.count === 1) {
            this.hasRender = false;
        }
        if (this.hasRender === false) {
            //          console.log('current page' + this.currentpage + ' count' + this.count);
            //        console.log('Render is running..' + this.hasRender);
            this.count++;
            this.commonCode();
        }
        console.log('isDownload'+this.isDownload);
        this.downloadUrl = window.location.origin+'/ipa/s/downloads';
    }
}