import { LightningElement, track, api } from 'lwc';
import getCaseList from '@salesforce/apex/Core_IPS_CaseAdvanceSearch_CTRL.getCaseList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import communityPath from '@salesforce/community/basePath';
import Custom from '@salesforce/resourceUrl/CustomCSS_LWC';
import { loadStyle } from 'lightning/platformResourceLoader'
import TIME_ZONE from '@salesforce/i18n/timeZone';
const advCaseColumns = [


    {
        label: 'Case Number',
        fieldName: 'linkCase',
        type: 'url',
        sortable: 'true',
        typeAttributes: {
            label: { fieldName: 'CaseNumber' },
            target: '_self'
        },
        wrapText: 'true',
        hideDefaultActions: 'true',

    },
    { label: 'Status', fieldName: 'Status', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', },
    { label: 'Sub Status', fieldName: 'Core_Sub_Status__c', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', },

    { label: 'Severity', fieldName: 'Core_Severity__c', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 75, },
    { label: 'Subject', fieldName: 'Subject', type: 'text', wrapText: 'true', hideDefaultActions: 'true', },
    { label: 'Product Name', fieldName: 'Core_IPS_Product_name__c', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', },
    { label: 'Project', fieldName: 'ProjectName', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', },
    { label: 'Account Name', fieldName: 'core_Account_Name__c', type: 'text', sortable: 'true', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', },
    //{ label: 'Created Date', fieldName: 'Core_AAQC_case_created_by_loggedin_user__c', type: 'text', sortable: 'true',wrapText: 'true', hideDefaultActions: 'true', },
    //{ label: 'Last Modified', fieldName: 'Core_IPS_Last_Update__c', type: 'Number', sortable: 'true',wrapText: 'true', hideDefaultActions: 'true', }
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', },
    { label: 'Modified', fieldName: 'LastModifiedDate', type: 'Number', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', },

    { label: 'Last ModifiedeFormat', fieldName: 'LastModifiedDateFormat', type: 'text', sortable: 'true', },
    { label: 'Created DateFormat', fieldName: 'CreatedDateFormat', type: 'text', sortable: 'true', },
    

]; //////

export default class Core_IPS_CaseAdvanceSearch_LWC extends NavigationMixin(LightningElement) {

    advCaseNum;
    advStatus;
    advProductName;
    advReferenceId;
    @api advSearcAll = '';
    advFromDate;
    advToDate;

    advDataTable;
    advCaseColumns = advCaseColumns;
    filterstring = '';
    subStatusString = '';
    @track showSection = true;
    showDataTable = false;
    Substatusvalue;
    norecordsToDisplay;
    @track AdvSortDirection;
    @track AdvSortedBy;
    @track AdvpaginatedCases = [];
    @track isSpinner;
    advhandleSearchAll(event) {
        this.advSearcAll = event.target.value;
    }
    advCaseNumOnchange(event) {
        this.advCaseNum = event.target.value;


    }


    advCustomerRefrenceid(event) {
        this.advReferenceId = event.target.value;

    }
    advProductOnChange(event) {
        this.advProductName = event.target.value;



    }
    fromDateOnChange(event) {
        this.advFromDate = event.target.value;

    }
    toDateOnChange(event) {
        this.advToDate = event.target.value;

    }
    value = [''];

    get options() {
        return [
            { label: 'New', value: '\'New\'' },
            { label: 'Open', value: '\'Open\'' },
            { label: 'Closed', value: '\'Closed\'' },
        ];
    }

    get selectedValues() {
        return this.value.join(',');
    }
    @track openchek = false;
    @track closechek = false;
    handleChange(event) {
        this.value = event.detail.value;
        if (this.value != null || '') {
            this.advStatus = this.value;
        } else {
            this.advStatus = '';
        }
        console.log('value------>' + this.value);
        if (this.advStatus == '\'New\'') {
            this.openchek = false;
            this.closechek = false;
        }

        if (this.advStatus == '\'Open\'') {
            this.openchek = true;
            this.closechek = false;
        } else {
            this.openchek = false;
            this.Substatusvalue = '';
        }
        if (this.advStatus == '\'Closed\'') {
            this.closechek = true;
            this.openchek = false;
        } else {
            this.closechek = false;
            this.Substatusvalue = '';
            yy
        }
        if (this.value == '') {
            this.advStatus == '';
        }
        console.log('this.advStatus-->', this.advStatus);
    }

    adcSearchBar() {

        this.isSpinner = true;
        this.filterstring = '';
        if (typeof this.advCaseNum !== 'undefined' && this.advCaseNum !== '') {
            this.filterstring = 'CaseNumber=' + this.advCaseNum + '#%#';

        }


        if (typeof this.advProductName !== 'undefined' && this.advProductName !== '') {
            this.filterstring = this.filterstring + 'ProductName=' + this.advProductName + '#%#';
        }

        if (typeof this.advStatus !== 'undefined' && this.advStatus != '') {
            this.filterstring = this.filterstring + 'Status=' + this.advStatus + '#%#';
        }

        if (typeof this.advToDate !== 'undefined' && this.advToDate !== '' && this.advToDate !== null) {
            this.filterstring = this.filterstring + 'CreatingDateTo=' + this.advToDate + '#%#';
        }

        if (typeof this.advReferenceId !== 'undefined' && this.advReferenceId !== '') {
            this.filterstring = this.filterstring + 'Core_Customer_Reference_ID__c=' + this.advReferenceId + '#%#';
        }

        if (typeof this.advFromDate !== 'undefined' && this.advFromDate !== '' && this.advFromDate !== null) {
            this.filterstring = this.filterstring + 'CreatingDateFrom=' + this.advFromDate + '#%#';
        }

        console.log('this.filtersryring---->', this.filterstring);

        getCaseList({ caseSearch: this.advSearcAll || '', filterStr: this.filterstring, subStatus: this.Substatusvalue || '' })

        .then(result => {



                if (result.length > 0) {
                    this.isSpinner = false;
                }
                const options = {
                    year: 'numeric',
                    month: 'numeric',
                    day: 'numeric',
                    hour: 'numeric',
                    minute: 'numeric',
                    hour12: true
                };
                const timezone = TIME_ZONE;


                console.log('result', result);
                if (result == '' || null) {
                    this.norecordsToDisplay = true;
                    this.isSpinner = false;
                }
                let cols = this.advCaseColumns;
                this.advCaseColumns = cols.filter(c => c.fieldName != 'LastModifiedDateFormat' && c.fieldName != 'CreatedDateFormat' );
        
                this.advDataTable = result;

                this.advCaseColumns.forEach(item => {
                    if (item['fieldName'] == 'linkCase' || item['fieldName'] == 'Status' || item['fieldName'] == 'Core_Severity__c') {
                        item.initialWidth = 80;
                    } else if (item['fieldName'] == 'Core_Sub_Status__c') {
                        item.initialWidth = 92;
                    }
                });

                this.searchdata = true;
                this.filterstring = '';
                if (this.advDataTable.length > 0) {

                    this.showDataTable = true;
                    this.norecordsToDisplay = false;

                } else {
                    this.showDataTable = false;

                }

                console.log('fuehrfyerf', JSON.stringify(this.advDataTable));
                this.advDataTable = JSON.parse(JSON.stringify(this.advDataTable));
                this.advDataTable.forEach(item => {
                    // console.log('item',item);
                    // item.ProjectName = item.Core_IPS_Project__r != undefined || item.Core_IPS_Project__r != null ? item?.Core_IPS_Project_Case__r.Name : '';
                    //console.log('item1',item.ProjectName);
                    item.linkCase = communityPath + '/case-detail?recordId=' + item.Id;
                    item.ProjectName = item?.Core_IPS_Project_Case__r?.Name
                    if (item.CreatedDate) {
                        item.CreatedDateFormat = item.CreatedDate;
                        let dt = new Date(item.CreatedDate);
                        item.CreatedDate = new Intl.DateTimeFormat('en-US', { timeZone: timezone, year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute: '2-digit' }, options).format(dt);
                    }
                    if (item.LastModifiedDate) {
                        item.LastModifiedDateFormat = item.LastModifiedDate;
                        let dt = new Date(item.LastModifiedDate);
                        item.LastModifiedDate = new Intl.DateTimeFormat('en-US', { timeZone: timezone, year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute: '2-digit' }, options).format(dt);
                    }

                    // console.log('result123',item?.Core_IPS_Project_Case__r.Name);
                });
                console.log('length', this.advDataTable.length);

                this.pagenation(this.advDataTable);
                this.refreshPageination();
            })
            .catch(error => {
                this.isSpinner = false;
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body.message,
                });
                //console.log('error-'+error);
                this.dispatchEvent(event);
                this.advDataTable = null;

            });


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
        //    console.log('Records in Pagination ',this.recordsList);
        console.log('Records in Pagination 2 ', recordsList.length);
        console.log('Records in Pagination 2 ', JSON.stringify(recordsList));


        this.advDataTable = recordsList;
        console.log('inside pagination -->', this.advDataTable.length);
        if (this.advDataTable.length <= 5) {
            this.AdvpaginatedCases = this.advDataTable;
            console.log('Inside if ', this.AdvpaginatedCases.length);
        } else if (this.advDataTable.length > 5) {
            this.AdvpaginatedCases = this.advDataTable.slice(0, 5);
            console.log('Inside else if ', this.AdvpaginatedCases.length);
        }
    }

    advhandleSearchKeyword() {
        sessionStorage.setItem("AdvanceSearch", "Search");
        sessionStorage.removeItem('CaseNav');
        this.isSpinner = false;
        this.adcSearchBar();
        sessionStorage.removeItem('ProjectCase');
        sessionStorage.removeItem('CaseNav');
        sessionStorage.removeItem('ProdDetail');
        sessionStorage.removeItem('ProjectDetail');


    }


    handleAdvSearchBtn(event) {
        if (this.showSection == false) {
            this.showSection = true;
        } else if (this.showSection == true) {
            this.showSection = false;
        }

    }
    handleNavigateBack() {

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }
    connectedCallback() {

            loadStyle(this, Custom);

            let testURL1 = window.location.href;
            let testURL = encodeURI(testURL1);
            let newURL = new URL(testURL).searchParams;
            this.advSearcAll = newURL.get('searchValue');
        }
        // accordianSection = '';

    handleToggleSection(event) {
        if (this.accordianSection.length === 0) {
            this.accordianSection = ''
        } else {
            this.accordianSection = 'Account'
        }

    }
    get option1() {
        return [
            { label: 'Customer Requesting Close*', value: 'Customer Requesting Close*' },
            { label: 'Customer Requesting Reopen', value: 'Customer Requesting Reopen' },
            { label: 'Deferred', value: 'Deferred' },
           // { label: 'Deferred', value: 'Deferred' },
            { label: 'Escalated to Engineering', value: 'Escalated to Engineering' },
            { label: 'Investigating', value: 'Investigating' },
            { label: 'Reproduced', value: 'Reproduced' },
            { label: 'Waiting for Customer Clarification*', value: 'Waiting for Customer Clarification*' },
            { label: 'Waiting for Customer Verification*', value: 'Waiting for Customer Verification*' },
            { label: 'Waiting for Ingredient*', value: 'Waiting for Ingredient*' }
        ];

    }
    tre;
    handleChange1(event) {
        if (this.openchek = true) {
            this.tre = event.detail.value;

            this.Substatusvalue = this.tre + ",";
        } else{
            this.Substatusvalue = '';
        }

      

    }
    get option2() {
        return [
            { label: 'No Response from Customer', value: 'No Response from Customer' },
            { label: 'Resolved', value: 'Resolved' },
            { label: 'Unresolved', value: 'Unresolved' },
        ];
    }
    closetre;
    handleChange2(event) {
        if (this.closechek == true) {
            this.closetre = event.detail.value;

            this.Substatusvalue = this.closetre + ",";

        } else {
            this.Substatusvalue = '';


        }

    }
    handleTablePaginationChange(event) {
        console.log('calling handleCasePaginationChange ** ', event.detail);
        this.AdvpaginatedCases = event.detail;
    }
    doAdvSorting(event) {
        this.AdvSortedBy = event.detail.fieldName;
        this.AdvSortDirection = event.detail.sortDirection;
        this.sortAdvCaseDataData(event.detail.fieldName, event.detail.sortDirection)
    }
    coltype;
    sortAdvCaseDataData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.advDataTable));
        let column = this.advCaseColumns.find(c=>c.fieldName===fieldname);
        this.coltype = column.type;
            
        if(fieldname == 'CreatedDate')  {
            fieldname = 'CreatedDateFormat';
        }
        else if(fieldname == 'LastModifiedDate'){
            fieldname = 'LastModifiedDateFormat';
        }
            
        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1 : -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            console.log('x='+x+'\ny='+y);
            if(fieldname==='CreatedDateFormat' || fieldname==='LastModifiedDateFormat') {
                var dx = new Date(x);
                var dy = new Date(y);
                return isReverse * (dx.getTime() - dy.getTime());
            }  
            else{
                return isReverse * ((x > y) - (y > x));
            }    
        });
        this.advDataTable = parseData;

        this.pagenation(this.advDataTable);
        this.refreshPageination();

    }


    //to handle Enter key press
    handleEnterKeyPress(event) {
        console.log(' key press capturing');
        if (event.keyCode === 13) {
            this.advhandleSearchKeyword();
            console.log('inside Enter key clicked inside');
        }
    }

}