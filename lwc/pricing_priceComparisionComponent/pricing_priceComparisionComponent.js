import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuoteLineData from '@salesforce/apex/Pricing_PriceComparisionController.getQuoteLineDataforComparision';
import getColumnList from '@salesforce/apex/Pricing_PriceComparisionController.getDataTableColumns';
import getQLINumber from '@salesforce/apex/Pricing_PriceComparisionController.getQuoteLineNumber';
import getPredictedValue from '@salesforce/apex/Pricing_PriceComparisionController.getEstimatedECAPfromDiscovery';
import { CurrentPageReference } from 'lightning/navigation';
import noScopeError from '@salesforce/label/c.Pricing_PriceComparision_noScopeMsg';
import { loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/Pricing_xlsx";


export default class Pricing_priceComparisionComponent extends LightningElement {

    @track searchKey = '';
    @track quoteLineData = [];
    @track columnList = [];
    @track showDetails = false;
    @track search = '';
    @track showSpinner;
    @track isSpinner;
    @track columnData = [];
    @track searchResultData = [];
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    typingTimer;
    doneTypingInterval = 1500;
    currentPageReference;
    @track isNotNavigation = true;
    @track paginationList = [];

    @track totalRecords = 0;
    DEF_PAGE_SIZE = '10';
    @track pageSize = this.DEF_PAGE_SIZE; // ch
    @track totalPages = 0;
    @track pageNumber = 1;

    @track xlsHeader = []; // store all the headers of the the tables
    @track workSheetName = ''; // store all the sheets name of the the tables
    @track xlsData = []; // store all tables data
    @track filename = ''; // Name of the file
    @track dissableButton = false;

    @track maxValue = 0;
    @track minValue = 0;
    @track predictedValue = 0;

    get pageSizeOptions() {
        return [
            { "label": "10", value: '10' },
            { "label": "20", value: '20' },
            { "label": "40", value: '40' },
            { "label": "100", value: '100' },
            { "label": "500", value: '500' },
        ];
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        this.currentPageReference = currentPageReference;
        if (this.currentPageReference) {
            if (this.currentPageReference.state.c__qline !== undefined) {
                this.isNotNavigation = false;
                this.showSpinner = true;
                getQLINumber({ qliId: this.currentPageReference.state.c__qline })
                    .then(result => {
                        if (result.length !== undefined) {
                            this.searchKey = result;
                            this.handleClick();
                        }
                    })
                    .catch(error => {
                        console.error('error===>', JSON.stringify(error));
                        this.showSpinner = false;

                    });
            }
        }
    }

    handleChange(event) {
        this.searchKey = event.target.value;
    }

    handleSearchChange(event) {
        clearTimeout(this.typingTimer);
        this.search = event.target.value;
        if (this.search.length > 2) {
            this.typingTimer = setTimeout(function () { this.handleSearch(); }.bind(this), this.doneTypingInterval);
        }
        else {
            this.paginationList = this.quoteLineData;
            this.totalRecords = this.paginationList.length;
            this.paginationHelper();
        }
    }

    handleClick() {
        this.showSpinner = true;
        this.sortDirection = 'asc';
        this.getColumns();
        let count = 0;
        getQuoteLineData({
            qliNumber: this.searchKey,
            searchType: 'product'
        })
            .then(result => {
                if (result.length > 0) {
                    for (let i = 0; i < result.length; i++) {
                        if (result[i].ecapPrice != undefined) {
                            if (count == 0) {
                                this.maxValue = result[i].ecapPrice;
                                this.minValue = result[i].ecapPrice;
                                count++;
                            }
                            else {
                                if (result[i].ecapPrice > this.maxValue) {
                                    this.maxValue = result[i].ecapPrice;
                                }
                                if (result[i].ecapPrice < this.minValue) {
                                    this.minValue = result[i].ecapPrice;
                                }
                            }
                        }
                    }
                    this.sortedBy = 'quoteNumber';
                    this.showDetails = true;
                    this.quoteLineData = result;
                    this.paginationList = this.quoteLineData;
                    this.totalRecords = result.length;
                    this.pageSize = this.DEF_PAGE_SIZE;
                    this.paginationHelper();
                }
                else {
                    const toastMessage = new ShowToastEvent({
                        title: 'Information',
                        message: noScopeError,
                        variant: 'info',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(toastMessage);
                    this.showDetails = false;
                    this.showSpinner = false;
                }
            }).then(_ => {
                if (this.quoteLineData.length > 0) {
                    getPredictedValue({ qliNumber: this.searchKey })
                        .then(result => {
                            if (result) {
                                this.predictedValue = result;
                            }
                        })
                        .catch(error => {
                            this.showSpinner = false;
                        });
                }
                this.showSpinner = false;

            })
            .catch(error => {
                console.error('Error @ getQuoteLineData =>', JSON.stringify(error));
                this.showSpinner = false;
            });
    }

    getColumns() {
        getColumnList()
            .then(result => {
                this.columnList = result;
            })
            .catch(error => {
                console.error('error===>', JSON.stringify(error));
                this.showSpinner = false;

            });
    }

    handleSearch() {
        this.isSpinner = true;
        this.showSpinner = true;
        let searchString = this.search.trim();
        let searchData = [];
        for (let i in this.quoteLineData) {
            if ( (this.quoteLineData[i].project && this.quoteLineData[i].project.toLowerCase().includes(searchString.toLowerCase())) || 
                (this.quoteLineData[i].endCustomer && this.quoteLineData[i].endCustomer.toLowerCase().includes(searchString.toLowerCase())) ) {
                searchData.push(this.quoteLineData[i]);
            }
        }

        this.paginationList = searchData.length > 0 ? searchData : [];
        this.totalRecords = searchData.length;
        this.paginationHelper();
        this.showSpinner = false;
        this.isSpinner = false;
    }

    handleExport() {
        this.dissableButton = true;
        this.showSpinner = true;
        let data = [];
        let header = [];
        let rowData = new Set();
        let columnHeadertoNameMap = {};

        Promise.all([loadScript(this, workbook + "/xlsx.full.min.js")])
            .then(() => {
                this.showSpinner = true;
                for (let i = 0; i < this.columnList.length; i++) {
                    rowData.add(this.columnList[i].label);
                    columnHeadertoNameMap[this.columnList[i].label] = this.columnList[i].fieldName.includes('Url') ? this.columnList[i].fieldName.replace('Url', '') : this.columnList[i].fieldName;
                }
                rowData = Array.from(rowData);

                for (let i = 0; i < this.quoteLineData.length; i++) {
                    let arrayList = [];
                    for (let key in rowData) {
                        let rowKey = columnHeadertoNameMap[rowData[key]];
                        if (this.quoteLineData[i][rowKey] != undefined && (rowKey === 'approvedStartDate' || rowKey === 'approvedEndDate')) {
                            let datetoFormat = new Date(this.quoteLineData[i][rowKey].replaceAll('-', '/'));
                            let formattedDate = (datetoFormat.getMonth() + 1) + '/' + datetoFormat.getDate() + '/' + datetoFormat.getFullYear();
                            arrayList.push(formattedDate);
                        }
                        else {
                            arrayList.push(this.quoteLineData[i][rowKey]);
                        }
                    }
                    data.push(arrayList);
                }

                header = rowData;
                this.workSheetName = this.searchKey.trim();
                this.xlsFormatter(data, header);
                this.filename = 'Price Comparison for ' + this.searchKey.trim() + ".xlsx";
                this.download();
                this.showSpinner = false;
                this.dissableButton = false;
            })
            .catch(error => {
                console.error('error ===> ' + error);
                this.reset();
                this.showSpinner = false;
                this.dissableButton = false;
            });
    }

    download() {
        const XLSX = window.XLSX;
        let xlsData = this.xlsData;
        let xlsHeader = this.xlsHeader;
        let ws_name = this.worksheetName;
        let createXLSLFormatObj = Array(xlsData.length).fill([]);

        xlsHeader.forEach((item, index) => createXLSLFormatObj[index] = [item])

        /* form data key list */
        xlsData.forEach((item, selectedRowIndex) => {
            item.forEach((value, index) => {
                let xlsRowKey = Object.keys(item[index]);
                let innerRowData = [];
                xlsRowKey.forEach(item => {
                    innerRowData.push(value[item]);
                })
                createXLSLFormatObj[selectedRowIndex].push(innerRowData);
            })

        });
        /* creating new Excel */
        let wb = XLSX.utils.book_new();

        /* creating new worksheet */
        let ws = Array(createXLSLFormatObj.length).fill([]);
        for (let i = 0; i < ws.length; i++) {
            /* converting data to excel format and puhing to worksheet */
            let data = XLSX.utils.aoa_to_sheet(createXLSLFormatObj[i]);
            ws[i] = [...ws[i], data];

            /* Add worksheet to Excel */
            XLSX.utils.book_append_sheet(wb, ws[i][0], ws_name);
        }

        /* Write Excel and Download */
        XLSX.writeFile(wb, this.filename);
        this.reset();
    }

    xlsFormatter(data, label) {
        let Header = label;
        this.xlsHeader.push(Header);
        this.xlsData.push(data);
    }

    reset() {
        this.xlsHeader = [];
        this.workSheetName = '';
        this.xlsData = [];
    }

    async onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.paginationList = await this.sortBy(this.paginationList, sortedBy, sortDirection);
        this.paginationHelper();
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    sortBy(data, fieldname, direction) {
        fieldname = fieldname == 'quoteLineNumberUrl' ? 'quoteLineNumber' : fieldname;
        fieldname = fieldname == 'quoteNumberUrl' ? 'quoteNumber' : fieldname;
        let parseData = JSON.parse(JSON.stringify(data));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        return parseData;
    }

    get bDisableFirst() {
        return this.pageNumber == 1;
    }

    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }

    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }

    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }

    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }

    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }

    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }

    paginationHelper() {
        this.columnData = [];
        this.totalPages = Math.ceil(this.totalRecords / parseInt(this.pageSize));
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        for (let i = (this.pageNumber - 1) * parseInt(this.pageSize); i < this.pageNumber * parseInt(this.pageSize); i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.columnData.push(this.paginationList[i]);
        }
    }
}