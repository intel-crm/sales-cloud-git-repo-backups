import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getListViewOptions from '@salesforce/apex/Core_IPS_InternalCaseExport.getListViewOptions';
import getRecentlyViewListCaseId from '@salesforce/apex/Core_IPS_InternalCaseExport.getRecentlyViewListCaseId';
import { getListUi } from 'lightning/uiListApi';
import CASE_OBJECT from '@salesforce/schema/Case';


export default class Case_List_Export extends LightningElement {
    @track Selectedcasevalue;
    @track error;
    @track showTable = false; //Used to render table after we get the data from apex controller    
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
    @track finalSObjectDataList;
    @track columnsResult;
    @track error;
    @track ShowCseTable;
    @track page = 1;
    @track items = [];
    @track data = [];
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 5;
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track showLoadingSpinner = false;
    //Sorting Data
    @track sortBy;
    @track sortDirection;
    @track paginatedCases = [];
    @track tempArray = [];
    @track caseoptions;
    @track columnsDynamic = [];
    @track finalRecords;
    @track mapOfLabels;
    @track caseOptionsNew = [];
    @track selectedFilterLabel = 'Recently Viewed Cases'

    @wire(getListUi, { objectApiName: CASE_OBJECT, pageSize: 1000 })
    listviewdata({ error, data }) {
        // 
        if (data) {
            // 
            for (let i = 0; i < data.lists.length; i++) {
                let obj = {};
                obj.label = data.lists[i].label;
                obj.value = data.lists[i].id;
                this.caseOptionsNew.push(obj);
            }
            // 
            this.caseoptions = this.caseOptionsNew;
            this.getListOfRecords(null);

        } else if (error) {

        }
    }

    connectedCallback() {
        getRecentlyViewListCaseId()
            .then(res => {
                this.Selectedcasevalue = res;
            })
            .catch(err => {

            })
    }

    async getListOfRecords(id) {
        this.showTable = false;
        this.ShowCseTable = false;
        await getListViewOptions({ strfilterId: id })
            .then((rec) => {
                // 
                let res = JSON.parse(JSON.stringify(rec.sObjectList));
                this.mapOfLabels = rec.fieldNameToLabelMap;

                for (var obj of res) {

                    for (var field in obj) {
                        if (typeof obj[field] == 'object') {

                            for (var innerObj in obj[field]) {
                                if (!innerObj.includes('Id')) {
                                    obj[field + "_" + innerObj] = obj[field][innerObj];
                                }
                            }

                            delete obj[field]
                        }
                        if (field.includes('Id')) {
                            delete obj[field];
                        }

                    }
                }

                // 
                if (res) {

                    for (var field of res) {
                        for (let fld in field) {
                            let tempObj = {};
                            tempObj['fieldName'] = fld;
                            // 
                            if (fld.toLowerCase() in this.mapOfLabels) {
                                tempObj['label'] = this.mapOfLabels[fld.toLowerCase()];
                            } else {
                                tempObj['label'] = fld;
                            }
                            if (fld.includes('date') || fld.includes('Date')) {
                                tempObj['type'] = 'date';
                                tempObj['typeAttributes'] = {
                                    day: 'numeric',
                                    month: 'short',
                                    year: 'numeric',
                                    hour: '2-digit',
                                    minute: '2-digit',
                                    second: '2-digit',
                                    hour12: true
                                }
                            } else {
                                tempObj['type'] = 'text';
                            }
                            if (!this.columnsDynamic.some(fil => fil.fieldName === fld)) {
                                this.columnsDynamic.push(tempObj);
                            }
                        }
                    }
                }

                this.finalRecords = res;
                this.showLoadingSpinner = false;
                this.ShowCseTable = true;
                this.showTable = true;

            })
            .catch(err => {

                this.showLoadingSpinner = false;

            });

    }

    handleChangeCaseListView(event) {
        this.finalRecords = [];
        this.columnsDynamic = [];
        this.showLoadingSpinner = true;

        this.selectedFilterLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.Selectedcasevalue = event.detail.value;

        this.getListOfRecords(this.Selectedcasevalue);


    }

    downloadCSVFile() {
        if (this.finalRecords.length > 10000) {
            this.showToastMessage();
        } else {
            const options = {
                year: 'numeric', month: 'numeric', day: 'numeric',
                hour: 'numeric', minute: 'numeric',
                hour12: true
            };

            let rowEnd = '\n';
            let csvString = '';
            let rowData = new Set();

            let csvrec = this.finalRecords;
            let csvFileRec = csvrec.map(({ Id, ...rest }) => {
                return rest
            })
            csvFileRec.forEach(function (record) {
                Object.keys(record).forEach(function (key) {
                    let str = JSON.stringify(key);
                    if (!str.match('Id')) {
                        rowData.add(key);

                    }

                });
            });

            rowData = Array.from(rowData);

            csvString += rowData.join(',');
            csvString += rowEnd;
            for (let i = 0; i < csvFileRec.length; i++) {
                let colValue = 0;
                for (let key in rowData) {
                    if (rowData.hasOwnProperty(key)) {
                        let rowKey = rowData[key];
                        if (colValue > 0) {
                            csvString += ',';
                        }
                        let value = csvFileRec[i][rowKey] === undefined ? '' : csvFileRec[i][rowKey];
                        let str = '"' + JSON.stringify(value, ['Name']) + '"';
                        str = str.replace(/,/g, '');
                        str = str.replace(/{/g, '');
                        str = str.replace(/Name":"/g, '');
                        str = str.replace(/""/g, '');
                        str = str.replace(/}/g, '');
                        csvString += str;
                        // 
                        colValue++;
                    }

                }

                csvString += rowEnd;
            }

            let downloadElement = document.createElement('a');
            var blob = new Blob([csvString]);

            downloadElement.href = 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURIComponent(csvString);;

            downloadElement.target = '_self';
            downloadElement.download = this.selectedFilterLabel + '.csv';
            document.body.appendChild(downloadElement);
            downloadElement.click();

            document.body.removeChild(downloadElement);

        }

    }
    @track isrefreshPageination = false;
    refreshPageination() {
        if (this.isrefreshPageination == false) {
            this.isrefreshPageination = true;
        }
        else {
            this.isrefreshPageination = false;
        }
    }

    pagenation(recordsList) {
        this.recordsToDisplay = recordsList;
        if (this.recordsToDisplay.length <= 5) {
            this.paginatedCases = this.recordsToDisplay;
        } else if (this.recordsToDisplay.length > 5) {
            this.paginatedCases = this.recordsToDisplay.slice(0, 5);

        }
    }

    handleCasePaginatorChange(event) {
        this.paginatedCases = event.detail;
    }
    showToastMessage() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Maximum export size of 10000 rows exceeded.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);

    }


    //Hassan added it 
    openVfPage() {
        window.open('/apex/Core_IPS_Case_List_View_Stub', '_blank'); // Opens in a new tab
    }
}