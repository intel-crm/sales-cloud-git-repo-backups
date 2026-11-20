import { LightningElement, track, api, wire } from 'lwc';
import getAllCaseRecords from '@salesforce/apex/Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues';
import communityPath from '@salesforce/community/basePath';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import Salesforce_Images from '@salesforce/resourceUrl/Portal_Icon_LWC';
import Custom from '@salesforce/resourceUrl/CustomCSS_LWC';
import { loadStyle } from 'lightning/platformResourceLoader'
import { refreshApex } from '@salesforce/apex';
import LOCALE from '@salesforce/i18n/locale';
//Minhaj changes
// import wordWrapTable from '@salesforce/resourceUrl/wordWrapTable';

const columns = [{
        label: 'Action',
        fieldName: 'linkCaseComment',
        type: 'url',
        initialWidth: 77,
        typeAttributes: {
            label: 'Comment',
            target: '_self'
        }
    },
    {
        label: 'Case Number',
        fieldName: 'linkCase',
        type: 'url',
        initialWidth: 79,
        typeAttributes: {
            label: { fieldName: 'CaseNumber' },
            target: '_self'
        }
    },
    { label: 'Last Modified DateFormat', fieldName: 'LastModifiedDateFormat', type: 'text', sortable: 'true', },
    { label: 'Date/Time ClosedFormat', fieldName: 'ClosedDateFormat', type: 'text', sortable: 'true', },
    { label: 'Date/Time OpenedFormat', fieldName: 'CreatedDateFormat', type: 'text', sortable: 'true', },
    { label: 'Latest Comment TimeStampFormat', fieldName: 'Core_Last_Case_Comment_TimestampFormat__c', type: 'text', sortable: 'true', },

];
export default class Core_IPS_GenericListView_Cmp extends LightningElement {
    @track Selectedcasevalue;
    @track error;
    @track columns = columns;
    @track cse; //All Cases available for data table    
    @track showTable = false; //Used to render table after we get the data from apex controller    
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
    @api initialRecords;
    @track DataTableResponseWrappper;
    @track finalSObjectDataList;
    @track columns = columns;
    @track columnsResult;
    @track error;
    @track ShowCseTable;
    @track caseRecords;
    initialRecords;
    @track page = 1;
    @track items = [];
    @track data = [];
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track showLoadingSpinner = false;

    //Sorting Data
    @track sortBy;
    @track sortDirection;
    @track paginatedCases = [];
    @track tempArray = [];
    @track isSpinner;
    StaticIcon = `${Salesforce_Images}#idSvg`;
    get caseoptions() {
        return [
            { label: 'All Cases', value: 'AllCases' },
            { label: 'Recently Viewed Cases', value: 'Recently_Viewed_Cases' },
            { label: 'All Cases-Detail View', value: 'All_Cases_Detail_View' },
            { label: 'My Account Cases', value: 'My_Account_Cases' },
            { label: 'All Open Cases-Detail View', value: 'All_Open_Cases_Detail_View' },
            { label: 'My Open Cases', value: 'My_Open_Cases' },
            { label: 'My Closed Cases', value: 'My_Closed_Cases' },
            { label: 'My Recently Updated Cases', value: 'My_Recently_Updates_Cases' },
        ];
    }
    constructor() {
        super();
        let pinnedItems = localStorage.getItem('storedListViewName');
        if (pinnedItems != null && pinnedItems != undefined && pinnedItems != '') {
            this.Selectedcasevalue = pinnedItems;
        } else {
            this.Selectedcasevalue = 'My_Open_Cases';
        }
        this.getCase();
    }

    /*renderedCallback(){
         loadStyle(this, wordWrapTable)
        .then(() => console.log('Files loaded.'))
        .catch(error => console.log("Error " + error.body.message));
    }*/

    @track caseSearchResults;
    columnHeaders = {};
    connectedCallback() {
        console.log('minhaj locale', LOCALE);
        console.log('minhaj time zone', TIME_ZONE);
        loadStyle(this, Custom);
    }
    getCase() {
        this.isSpinner = true;
        sessionStorage.setItem("CaseNav", "NavigateCase");
        getAllCaseRecords({ caseListView: this.Selectedcasevalue })
            .then(result => {
                if (result.lstDataTableData.length > 0) {
                    this.ShowCseTable = true;
                    this.isSpinner = false;
                    let sObjectRelatedFieldListValues = [];
                    let rows = result;
                    const timezone = TIME_ZONE;
                    const locale = LOCALE;
                    const options = {
                        timeZone: timezone,
                        year: 'numeric',
                        month: 'numeric',
                        day: 'numeric',
                        hour: 'numeric',
                        minute: 'numeric',
                        hour12: true
                    };

                    for (let row of rows.lstDataTableData) {
                        const finalSobjectRow = {}
                        let rowIndexes = Object.keys(row);
                        rowIndexes.forEach((rowIndex) => {
                            const relatedFieldValue = row[rowIndex];
                            if (relatedFieldValue.constructor === Object) {
                                this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)
                            } else {
                                finalSobjectRow[rowIndex] = relatedFieldValue;
                            }

                        });
                        sObjectRelatedFieldListValues.push(finalSobjectRow);
                    }
                    this.DataTableResponseWrappper = rows;
                    this.recordsToDisplay = sObjectRelatedFieldListValues;
                    
                    let col = [...columns].filter(c => c.fieldName != 'LastModifiedDateFormat' && c.fieldName != 'ClosedDateFormat' && c.fieldName != 'CreatedDateFormat' && c.fieldName != 'Core_Last_Case_Comment_TimestampFormat__c');

                    if(this.Selectedcasevalue == 'My_Closed_Cases'){
                        let cols = [...col].filter(c => c.fieldName != 'linkCaseComment');
                        //let cols = [...columns].filter(col => col.fieldName != 'linkCaseComment');
                        this.columnsResult = cols.concat(result.lstDataTableColumns);
                    }
                    else{
                        this.columnsResult = col.concat(result.lstDataTableColumns);
                        //this.columnsResult = columns.concat(result.lstDataTableColumns);
                    }
                    this.columnsResult.forEach(item => {
                        item.sortable = true;
                        item.wrapText = true;
                        item.hideDefaultActions = true;
                        
                        if (item['fieldName'] == 'Subject') {

                            item.initialWidth = 450;

                        }

                        if (item['fieldName'] == 'Core_Sub_Status__c' || item['fieldName'] == 'Owner.FirstName') {

                            item.initialWidth = 90;

                        }

                         if(item['fieldName'] == 'Status'|| item['fieldName'] == 'Core_Severity__c' ){

                            item.initialWidth = 68;

                        }

                        if(item['fieldName'] == 'Core_IPS_Product_name__c'){

                            item.initialWidth = 200;

                        }

                        if(item['fieldName'] == 'Core_IPS_Project_Case__r.Name'){

                            item.initialWidth = 130;

                        }

                        if(item['fieldName'] == 'Core_Contact_Name__c'||item['fieldName'] == 'Account.Name' ){

                            item.initialWidth = 100;

                        }

                        if(item['fieldName'] =='Core_External_Issue_Subcategory__c'){

                            item.initialWidth = 200;

                        }

                        if (item['fieldName'] == 'ClosedDate' ||item['fieldName'] == 'CreatedDate' || item['fieldName'] == 'CreatedDateFormat' || item['fieldName'] == 'LastModifiedDate' || item['fieldName'] == 'Core_Last_Case_Comment_Timestamp__c') {

                            item.type = 'date/Time';

                            item.initialWidth = 96;

                        }
                        if(item['fieldName'] =='Core_External_Issue_Category__c'){

                            item.initialWidth = 150;
                        }
                        if(item['fieldName'] == 'CreatedDate'){
                            item.label = 'Opened' 
                        }
                        if(item['fieldName'] == 'LastModifiedDate'){
                                        item.label = 'Modified';  
                                    }
                        if(item['fieldName'] == 'ClosedDate'){
                                        item.label = 'Closed';                        
                        }
                        if(item['fieldName'] == 'Core_Last_Case_Comment__c'){
                              item.initialWidth = 450;
                        }


                        /*if (item['fieldName'] == 'Subject') {
                            item.initialWidth = 230;
                        }else*/
                        //if (item['fieldName'] == 'Core_Sub_Status__c' || item['fieldName'] == 'Owner.FirstName') {
                        //    item.initialWidth = 84;
                        //}
                        /*else if(item['fieldName'] == 'Status'){ //|| item['fieldName'] == 'Core_Severity__c'){
                            item.initialWidth = 68;
                        }*/
                        /*if (item['fieldName'] == 'ClosedDate' || item['fieldName'] == 'LastModifiedDate') {
                            item.type = 'date/Time';
                        }*/
                    });
                    this.tempArray = this.recordsToDisplay;
                    this.recordsToDisplay.forEach(record => {
                        if (record.CreatedDate) {
                            record.CreatedDateFormat = record.CreatedDate;
                            let dt = new Date(record.CreatedDate);
                            record.CreatedDate = new Intl.DateTimeFormat(locale, options).format(dt);
                          
                            // record.CreatedDate = new Intl.DateTimeFormat('en-US', { timeZone: timezone, year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute: '2-digit' }, options).format(dt);
                        }
                        if (record.LastModifiedDate) {
                            record.LastModifiedDateFormat = record.LastModifiedDate;
                            let dt = new Date(record.LastModifiedDate);
                            record.LastModifiedDate = new Intl.DateTimeFormat(locale, options).format(dt);

                            // record.LastModifiedDate = new Intl.DateTimeFormat('en-US', { timeZone: timezone, year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute: '2-digit' }, options).format(dt);
                        }
                        if (record.ClosedDate) {
                            record.ClosedDateFormat = record.ClosedDate;
                            let dt = new Date(record.ClosedDate);
                            record.ClosedDate = new Intl.DateTimeFormat(locale, options).format(dt);

                            //record.ClosedDate = new Intl.DateTimeFormat('en-US', { timeZone: timezone, year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute: '2-digit' }, options).format(dt);
                        }
                        if (record.Core_Last_Case_Comment_Timestamp__c) {
                            record.Core_Last_Case_Comment_TimestampFormat__c = record.Core_Last_Case_Comment_Timestamp__c;
                            let dt = new Date(record.Core_Last_Case_Comment_Timestamp__c);
                            record.Core_Last_Case_Comment_Timestamp__c = new Intl.DateTimeFormat(locale, options).format(dt);

                            //record.Core_Last_Case_Comment_Timestamp__c = new Intl.DateTimeFormat('en-US', { timeZone: timezone, year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute: '2-digit' }, options).format(dt);
                        }
                        
                        if(record.Core_Last_Case_Comment__c){
                            record.Core_Last_Case_Comment__c = record.Core_Last_Case_Comment__c.replace( /(<([^>]+)>)/ig," ");
                        }
                        record.linkCase = communityPath + '/case-detail?recordId=' + record.Id + '&isCase=true';
                        record.linkCaseComment = communityPath + '/case-detail?recordId=' + record.Id + '&isCase=false';
                    });
                    this.pagenation(this.recordsToDisplay);
                    this.refreshPageination();
                } else {
                    this.ShowCseTable = false;
                    if (this.ShowCseTable == false) {
                        this.isSpinner = false;
                    }
                }
            })
            .catch((error) => {
                console.log('error ---> ' + JSON.stringify(error));
            });
        this.initialRecords = this.recordsToDisplay;
        this.caseSearchResults = this.recordsToDisplay;
        this.showTable = true;
    }
    _flattenTransformation = (fieldValue, finalSobjectRow, fieldName) => {
        let rowIndexes = Object.keys(fieldValue);
        rowIndexes.forEach((key) => {
            let finalKey = fieldName + '.' + key;
            finalSobjectRow[finalKey] = fieldValue[key];
        })
    }
    handleChangeCaseListView(event) {
        this.Selectedcasevalue = event.detail.value;
        localStorage.setItem('storedListViewName', this.Selectedcasevalue);
        this.getCase();
    }
    @track caseSearchResults;
    countDataLoad = 0;
    allRecordsToDisplay;
    handleKeyChangeSearch(event) {
        this.countDataLoad++;
        if (this.countDataLoad == 1) {
            this.allRecordsToDisplay = this.recordsToDisplay;
        } else {
            this.recordsToDisplay = this.allRecordsToDisplay;
        }
        const searchKey = event.target.value.toLowerCase();
        const searchFieldName = event.target.className;
        if (searchKey) {
            if (this.recordsToDisplay) {
                this.caseSearchResults = this.recordsToDisplay;
                let recs = [];
                for (let key of this.recordsToDisplay) {
                    let valuesArray = Object.values(key);
                    for (let val of valuesArray) {
                        if (val) {
                            if (val.toString().toLowerCase().includes(searchKey)) {
                                recs.push(key);
                                break;
                            }
                        }
                    }
                    this.recordsToDisplay = recs;
                    if (this.recordsToDisplay.length > 0) {
                        this.ShowCseTable = true;
                    } else {
                        this.ShowCseTable = false;
                    }
                }
                this.pagenation(this.recordsToDisplay);
                this.refreshPageination();
            }
        } else {
            this.getCase();
        }
    }
    downloadCSVFile() {
        const options = {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            hour: 'numeric',
            minute: 'numeric',
            hour12: true
        };
        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();
        let rec = this.columnHeaders;
        let csvrec = this.recordsToDisplay;
        let csvFileRec = csvrec.map(({ Id, linkCase, Core_IPS_Project_Case__c, Core_IPS_Premier_Support_Project_ID__c,linkCaseComment,CreatedDateFormat,LastModifiedDateFormat, ...rest }) => {
            return rest
        })
        csvFileRec.forEach(function(record) {
            Object.keys(record).forEach(function(key) {
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
                    colValue++;
                }
            }
            csvString += rowEnd;
        }
        let downloadElement = document.createElement('a');
        var blob = new Blob([csvString]);

        downloadElement.href = 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURIComponent(csvString);;
        downloadElement.target = '_self';
        downloadElement.download = this.Selectedcasevalue + '.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
        document.body.removeChild(downloadElement);
    }
    @api recordId;
    //Sorting Case Data
    handleSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection)
    }
    coltype;
    
    sortData(fieldname, direction) {
        
        let column = this.columnsResult.find(c=>c.fieldName===fieldname);
        this.coltype = column.type;
        
        if(fieldname == 'CreatedDate')  {
            fieldname = 'CreatedDateFormat';
        }
        else if(fieldname == 'ClosedDate'){
            fieldname = 'ClosedDateFormat';
        }
        else if(fieldname == 'LastModifiedDate'){
            fieldname = 'LastModifiedDateFormat';
        }
        else if(fieldname == 'Core_Last_Case_Comment_Timestamp__c'){
            fieldname = 'Core_Last_Case_Comment_TimestampFormat__c';
        }
        
        
        let parseData = JSON.parse(JSON.stringify(this.recordsToDisplay));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            
            if(this.coltype==='date/time' || this.coltype==='date/Time') {
                if(x==''){
                    x=0;
                }
                if(y==''){
                    y=0;
                }
                var dx = new Date(x);
                var dy = new Date(y);
                return isReverse * (dx.getTime() - dy.getTime());
            }  
            else{
                return isReverse * ((x > y) - (y > x));
            }    
            
        });
        this.recordsToDisplay = parseData;
        this.pagenation(this.recordsToDisplay);
        this.refreshPageination();
    }
    @track isrefreshPageination = false;
    refreshPageination() {
        if (this.isrefreshPageination == false) {
            this.isrefreshPageination = true;
        } else {
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
}