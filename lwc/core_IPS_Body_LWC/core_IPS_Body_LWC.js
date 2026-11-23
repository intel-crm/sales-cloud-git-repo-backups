import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import communityPath from '@salesforce/community/basePath';
import uId from '@salesforce/user/Id';
import getAllCaseRecords from '@salesforce/apex/Core_IPS_TestAllRecords.getAllCaseRecords';
import projectDataAndColumnValues from '@salesforce/apex/Core_Ips_ProjectDataTable_Lwc_Ctrl.projectFieldColumnValues';
import getAllProducts from '@salesforce/apex/Core_Ips_ProductDataTable_LWC_Ctrl.ProductFieldAndDataValues';
import getAllContacts from '@salesforce/apex/Core_Ips_ContactDataTable_LWC_Ctrl.ContactFieldAndDataValues';
import getContactAndAccountDetails from '@salesforce/apex/Core_IPS_TestAllRecords.getContactAndAccountDetails';
import getSearchResult from '@salesforce/apex/Core_IPS_TestAllRecords.getSearchResult';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import MyIntelBusiness from '@salesforce/label/c.Core_IPS_MyIntelBussiness_LWC';
import ResourceDesignCenter from '@salesforce/label/c.Core_IPS_ResourceDesignCenter_LWC';
import VIP from '@salesforce/label/c.Core_IPS_VIP_LWC';
import Custom from '@salesforce/resourceUrl/CustomCSS_LWC';
import { loadStyle } from 'lightning/platformResourceLoader'
import PortalSiteURL from '@salesforce/label/c.Core_IPS_PortalSiteURL_LWC';
import LOCALE from '@salesforce/i18n/locale';
import getLoggedInPermissonSet from '@salesforce/apex/core_IPS_getPermssionSetName_Ctrl.getLoggedInPermissonSets';
const projectcolumns = [{
    label: 'Project Name',
    fieldName: 'linkProject',
    type: 'url',
    typeAttributes: {
        label: { fieldName: 'Name' },
        target: '_self'
    },
    sortable: 'true'
}];
const productColumns = [{
    label: 'New Case',
    fieldName: 'linkProductNewCase',
    type: 'url',
    sortable: true,
    typeAttributes: {
        label: 'New Case',
        target: '_self'
    },
    initialWidth: 75,
},
{
    label: 'Intel Product Name',
    fieldName: 'linkProduct',
    type: 'url',
    sortable: true,
    typeAttributes: {
        label: { fieldName: 'Name' },
        target: '_self'
    }
}
];
const productInactiveColumns = [{
    label: 'Error',
    fieldName: 'CaseNav',
    type: 'url',
    typeAttributes: {
        label: 'CaseNav',
        target: '_self'
    }
},
{
    label: 'Intel Product Name',
    fieldName: 'linkProduct',
    type: 'url',
    typeAttributes: {
        label: { fieldName: 'Name' },
        target: '_self'
    }
}
];
const contactColumns = [
    { label: 'Name', fieldName: 'Name', type: 'text', sortable: 'true' },
    { label: 'Account', fieldName: 'AccountName', type: 'text', sortable: 'true' },
    { label: 'Email', fieldName: 'Email', type: 'text', sortable: 'true' },
    {
        label: 'Created Date',
        fieldName: 'CreatedDate',
        type: 'date',
        sortable: 'true',
        typeAttributes: {
            day: 'numeric',
            month: 'numeric',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            hour12: true
        }
    },
    { label: 'Created Date Format', fieldName: 'createdDateFormat', type: 'text', sortable: 'true', }, //new
];
const globalcasecolumns = [{
    label: 'Action',
    fieldName: 'linkCaseComment',
    type: 'url',
    initialWidth: 77,
    typeAttributes: {
        label: 'Comment',
        target: '_self'
    },
    wrapText: true,
    hideDefaultActions: true,
}, {
    label: 'Case',
    fieldName: 'linkCase',
    type: 'url',
    initialWidth: 79,
    sortable: 'true',
    typeAttributes: {
        label: { fieldName: 'CaseNumber' },
        target: '_self'
    },
    wrapText: true,
    hideDefaultActions: true,
},
{ label: 'Status', fieldName: 'Status', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 70, },
{ label: 'Sub Status', fieldName: 'Core_Sub_Status__c', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 70, },
{ label: 'Severity', fieldName: 'Core_Severity__c', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 70, },
{ label: 'Subject', fieldName: 'Subject', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 250, },
{ label: 'Product Name', fieldName: 'Core_IPS_Product_name__c', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 200, },
{ label: 'Project', fieldName: 'ProjectName', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 150, },

{ label: 'Contact Name', fieldName: 'Core_Contact_Name__c', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 150, },
{ label: 'Opened', fieldName: 'Createddate', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 144, },
{ label: 'Modified', fieldName: 'LastModifieddate', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 144, },
{ label: 'Legacy ID', fieldName: 'Core_IPS_Legacy_IPS_ID__c', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 90, },
{ label: 'Case Category', fieldName: 'Core_External_Issue_Category__c', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 90, },
{ label: 'Case Sub Category', fieldName: 'Core_External_Issue_Subcategory__c', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 150, },
{ label: 'Closed', fieldName: 'Closeddate', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 96, },
{ label: 'Customer Reference ID', fieldName: 'Core_Customer_Reference_ID__c', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 150, },

{ label: 'Last Modified DateFormat', fieldName: 'LastModifieddateFormat', type: 'text', sortable: 'true', },
{ label: 'Date/Time ClosedFormat', fieldName: 'CloseddateFormat', type: 'text', sortable: 'true', },
{ label: 'Date OpenedFormat', fieldName: 'CreateddateFormat', type: 'text', sortable: 'true', },

];
const globalprojectcolumns = [{
    label: 'Project Name',
    fieldName: 'linkProj',
    type: 'url',
    sortable: 'true',
    typeAttributes: {
        label: { fieldName: 'Name' },
        target: '_self'
    },
    wrapText: true,
    hideDefaultActions: true,
},
{ label: 'Description', fieldName: 'Core_Project_Description__c', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', },
{ label: 'Status', fieldName: 'Core_Status__c', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 90, }
];
const globalproductColumns = [{
    label: 'Intel Product Name',
    fieldName: 'linkProd',
    type: 'url',
    sortable: 'true',
    typeAttributes: {
        label: { fieldName: 'Name' },
        target: '_self'
    },
    wrapText: true,
    hideDefaultActions: true,
},
{ label: 'Project Id', fieldName: 'Core_IPS_Project_Id__c', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', initialWidth: 90, },
{ label: 'Premier Support Project', fieldName: 'ProjectName', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', },
{ label: 'Account Name', fieldName: 'AccountName', type: 'text', sortable: 'true', wrapText: 'true', hideDefaultActions: 'true', },
];
export default class Core_IPS_Body_LWC extends NavigationMixin(LightningElement) {
    @track userId = uId;
    @track accId;
    @track caseRecords = true;
    initialRecords;
    @track projectRecords;
    projectInitialRecords;
    @track productRecords;
    productInitialRecords;
    @track contactRecords;
    contactInitialRecords;
    @track error;
    @track conShowMsg;
    @track prdShowMsg;
    @track projShowMsg;
    @track casevalue = 'allCases';
    @track projectvalue = 'AllProjects';
    @track productvalue = 'ActiveProducts';
    @track contactvalue = 'MyContacts';
    @track CaseCreation = false;
    @track page = 1;
    @track items = [];
    @track data = [];
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 10;
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track recordsToDisplay = [];
    @track projectcolumns = projectcolumns;
    @track productColumns = productColumns;
    @track contactColumns = contactColumns;
    @track rowNumberOffset;
    @track cse;
    @track projcse;
    @track productCse;
    @track contactCse;
    @track recordId;
    @track searchValue;
    @track isAllTablesVisible = false;
    projcolumnsResult;
    @track prodcolumnsResult;
    @track concolumnsResult;
    @track conRecToDisplay;
    @track pdtRecToDisplay;
    @track prjRecToDisplay = [];
    @track globalcasecolumns = globalcasecolumns;
    @track globalprojectcolumns = globalprojectcolumns;
    @track globalproductColumns = globalproductColumns;
    @track prjshowmsg;
    @track caseShowmsg;
    @track pdtShowmsg;
    //sorting variables
    @track sortProjectBy;
    @track sortProjectDirection;
    @track sortProductBy;
    @track sortProductDirection;
    @track sortContactBy;
    @track sortContactDirection;
    @track sortGlobalProductDirection;
    @track sortGlobalProjectDirection;
    @track sortGlobalCaseDirection;
    @track GlobalCaseSortBy;
    @track GlobalProjectSortBy;
    @track GlobalProductSortBy;
    @track fewCaseList = [];
    @track paginatedContacts = [];
    @track paginatedProjects = [];
    rowOffSet = 0;
    rowLimit = 25;
    @track cases = true;
    projects = false;
    products = false;
    contacts = false;
    @track selectedItem = 'allCases';
    @track currentContent = 'allCases';
    @track currentContent;
    @track updatedCount = 12;
    @track isSpinner;
    //Constructor is invoked when component is created/loaded. 
    constructor() {
        super();
        this.getCases();
    }
    label = {
        MyIntelBusiness,
        ResourceDesignCenter,
        VIP
    };
    @track isDddAvailable = false;
    permissionSetNames;
    async getLoggedInPermissonSetOfUser() {
        await getLoggedInPermissonSet()
            .then(res => {
                this.permissionSetNames = res.map(rec => {
                    if (rec.PermissionSet.Label.includes('DDR Permission Set')) {
                        this.isDddAvailable = true;
                    }
                    return rec.PermissionSet.Label
                });
            })
            .catch(err => {
                console.log('error permisson set', err);
            })
    }
    async connectedCallback() {
        await this.getLoggedInPermissonSetOfUser();
        loadStyle(this, Custom);
        this.cases = true;
        this.caseRecords = true;
        if (this.currentContent == undefined) {
            this.cases = true;
        }
        let techStack = JSON.parse(sessionStorage.getItem("tech"));
        sessionStorage.setItem("techstack", "casecreation");

        let localSelectedItem = sessionStorage.getItem("selectedItem");
        if (localSelectedItem != this.selectedItem || localSelectedItem === null || localSelectedItem == undefined) {
            this.selectedItem = localSelectedItem;
        }
        getContactAndAccountDetails({ UsrId: this.userId })
            .then(result => {
                this.accId = result[0].Id;
            })
            .catch(error => {
                this.accId = null;
            });
        if (this.selectedItem == 'allProjects') {
            this.getProjects();
        }
        if (this.selectedItem == 'intelProducts') {
            this.getProducts();
        }
        if (this.selectedItem == 'allContacts') {
            this.getContacts();
        }
        let cols = this.globalcasecolumns;
        this.globalcasecolumns = cols.filter(c => c.fieldName != 'LastModifieddateFormat' && c.fieldName != 'CloseddateFormat' && c.fieldName != 'CreateddateFormat');

    }

    @track renderedCount = 0;
    renderedCallback() {
        loadStyle(this, Custom);
        if (this.currentContent == '') {
            this.cases = true;
            this.selectedItem = 'allCases';
        }
        if (this.selectedItem == '') {
            this.cases = true;
            this.selectedItem = 'allCases';
        }
    }
    //fetching cases
    getCases() {
        getAllCaseRecords({ caseListView: this.casevalue })
            .then(result => {
                this.items = result;
                this.totalRecountCount = result.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                this.caseRecords = this.items.slice(0, this.pageSize);
                this.endingRecord = this.pageSize;
                this.initialRecords = result;
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while getting Cases',
                        message: error.message,
                        variant: 'error'
                    }),
                );
                this.caseRecords = undefined;
                this.initialRecords = undefined;
            });
    }
    @track getProjectsCount = 0;
    loadMoreStatus;
    //fetching projects
    getProjects() {
        this.isSpinner = true;
        this.cases = false;
        this.getProjectsCount++;
        if (this.selectedItem != "allProjects") {
            this.selectedItem = "allProjects";
            sessionStorage.setItem("selectedItem", this.selectedItem);
        }
        // This to hide Global search data tables after clicking projects vertical navigation
        this.isAllTablesVisible = false;
        return projectDataAndColumnValues({ projectListView: this.projectvalue })
            .then(result => {
                if (result.prjDataTableData.length > 0) {
                    this.isSpinner = false;
                    this.projShowMsg = true;
                    let sObjectRelatedFieldListValues = [];
                    let rows = JSON.parse(JSON.stringify(result));
                    for (let row of rows.prjDataTableData) {
                        const finalSobjectRow = {}
                        let rowIndexes = Object.keys(row);
                        rowIndexes.forEach((rowIndex) => {
                            const relatedFieldValue = row[rowIndex];
                            if (relatedFieldValue.constructor === Object) {
                                this.HeaderColumns(relatedFieldValue, finalSobjectRow, rowIndex)
                            } else {
                                finalSobjectRow[rowIndex] = relatedFieldValue;
                            }
                        });
                        sObjectRelatedFieldListValues.push(finalSobjectRow);
                    }
                    this.DataTableResponseWrappper = rows;
                    this.prjRecToDisplay = sObjectRelatedFieldListValues;
                    this.prjRecToDisplay = JSON.parse(JSON.stringify(this.prjRecToDisplay));
                    this.projcolumnsResult = projectcolumns.concat(result.prjDataTableColumns);
                    let projcopyresult = [];
                    for (const n of this.projcolumnsResult) {
                        let copyObj = { ...n };
                        copyObj.sortable = true;
                        copyObj.wrapText = true;
                        copyObj.hideDefaultActions = true;
                        projcopyresult.push(copyObj);
                    }
                    this.projcolumnsResult = projcopyresult;
                    this.prjRecToDisplay.forEach(record => {
                        record.linkProject = communityPath + '/project-detail?recordId=' + record.Id;
                    });
                    this.projectRecords = rows;
                    this.projpagenation(this.prjRecToDisplay);
                    this.projrefreshPageination();
                } else {
                    this.projShowMsg = false;
                    if (this.projShowMsg == false) {
                        this.isSpinner = false;
                    }
                }
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while getting Projects',
                        message: error.message,
                        variant: 'error'
                    }),
                );
                this.projectRecords = undefined;
                this.projectInitialRecords = undefined;
            });
    }
    projpagenation(recordsList) {
        this.prjRecToDisplay = recordsList;
        if (this.prjRecToDisplay.length <= 5) {
            this.paginatedProjects = this.prjRecToDisplay;
        } else if (this.prjRecToDisplay.length > 5) {
            this.paginatedProjects = this.prjRecToDisplay.slice(0, 5);
        }
    }
    projrefreshPageination() {
        if (this.isprojectpagination == false) {
            this.isprojectpagination = true;
        } else {
            this.isprojectpagination = false;
        }
    }
    HeaderColumns = (fieldValue, finalSobjectRow, fieldName) => {
        let rowIndexes = Object.keys(fieldValue);
        rowIndexes.forEach((key) => {
            let finalKey = fieldName + '.' + key;
            finalSobjectRow[finalKey] = fieldValue[key];
        })
    }
    //Sorting Project Data
    doProjectSorting(event) {
        this.sortProjectBy = event.detail.fieldName;
        this.sortProjectDirection = event.detail.sortDirection;
        this.prjsortData(event.detail.fieldName, event.detail.sortDirection)
    }
    prjsortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.prjRecToDisplay));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.prjRecToDisplay = parseData;
        this.projpagenation(this.prjRecToDisplay);
        this.projrefreshPageination();
    }
    //fetching products
    @track storedPdtRecToDisplay;
    getProductsCount = 0;
    prodSearchResults;
    getProducts() {
        sessionStorage.setItem("techstack", "casecreation");
        this.isSpinner = true;
        this.cases = false;
        if (this.selectedItem != "intelProducts") {
            this.selectedItem = "intelProducts";
            sessionStorage.setItem("selectedItem", this.selectedItem);
        }
        // This to hide Global search data tables after clicking products vertical navigation
        this.isAllTablesVisible = false;
        getAllProducts({ productListView: this.productvalue })
            .then(result => {
                if (result.prodDataTableData.length > 0) {
                    this.isSpinner = false;
                    this.prdShowMsg = true;
                    let sObjectRelatedFieldListValues = [];
                    let rows = result;
                    for (let row of rows.prodDataTableData) {
                        const finalSobjectRow = {}
                        let rowIndexes = Object.keys(row);
                        rowIndexes.forEach((rowIndex) => {
                            const relatedFieldValue = row[rowIndex];
                            if (relatedFieldValue.constructor === Object) {
                                this.HeaderColumns(relatedFieldValue, finalSobjectRow, rowIndex)
                            } else {
                                finalSobjectRow[rowIndex] = relatedFieldValue;
                            }
                        });
                        sObjectRelatedFieldListValues.push(finalSobjectRow);
                    }
                    this.DataTableResponseWrappper = rows;
                    this.pdtRecToDisplay = sObjectRelatedFieldListValues;
                    console.log('myintel product', this.pdtRecToDisplay);
                    this.storedPdtRecToDisplay = this.pdtRecToDisplay;
                    this.prodcolumnsResult = productColumns.concat(result.prodDataTableColumns);
                    let prodcopyresult = [];
                    for (const n of this.prodcolumnsResult) {
                        let prodcopyObj = { ...n };
                        prodcopyObj.sortable = true;
                        prodcopyObj.wrapText = true;
                        prodcopyObj.hideDefaultActions = true;
                        prodcopyresult.push(prodcopyObj);
                    }
                    //console.log('soma 1 '+JSON.stringify(this.pdtRecToDisplay));
                    this.prodcolumnsResult = prodcopyresult;
                    this.pdtRecToDisplay.forEach(record => {
                        //let rec = JSON.stringify(record).replace('Core_IPS_Product_Organization__r.Name','ORGNAME');
                        //let parsedrecord = JSON.parse(rec);
                        //console.log('parsedrecord '+ JSON.stringify(parsedrecord));
                        record.linkProduct = communityPath + '/product-detail?recordId=' + record.Id;
                        //console.log('get record',JSON.stringify(record.Core_Product_Organization__r.Name));
                        if (record.Status == 'Active') {
                            if ((record.Core_IPS_Project__c === undefined || record.Core_IPS_Project__c == undefined) && (record.Core_IPS_Project_Name__c === undefined || record.Core_IPS_Project_Name__c == undefined)) {
                                record.linkProductNewCase = communityPath + '/new-case?assetId=' + record.Id + '&assetName=' + record.Name + '&mode=' + 'create' + '&supOrgNum=' + record?.Core_Product_Organization__r?.Name;
                            } else if (record.Core_IPS_Project__c != undefined && record.Core_IPS_Project_Status__c != 'Active') {
                                record.linkProductNewCase = communityPath + '/case-error';
                            } else {

                                // Niyaz record.linkProductNewCase = communityPath + '/new-case?assetId=' + record.Id + '&assetName=' + record.Name + '&premiersupprojrojId=' + record.Core_IPS_Project__c + '&premiersupprojrojName=' + record.Core_IPS_Project_Name__c + '&mode=' + 'create'+'&supOrgNum='+record?.Core_Product_Organization__r?.Name;
                                /*START Niyaz -- 12/06/2025 --- added as part of vulnerability fix */
                                record.linkProductNewCase = communityPath + '/new-case?' +
                                    'assetId=' + encodeURIComponent(record.Id) +
                                    '&assetName=' + encodeURIComponent(record.Name) +
                                    '&premiersupprojrojId=' + encodeURIComponent(record.Core_IPS_Project__c || '') +
                                    '&premiersupprojrojName=' + encodeURIComponent(record.Core_IPS_Project_Name__c || '') +
                                    '&mode=create' +
                                    '&supOrgNum=' + encodeURIComponent(record?.Core_Product_Organization__r?.Name || '');
                                /*END Niyaz -- 12/06/2025 */
                            }
                        }
                        else {
                            record.linkProductNewCase = communityPath + '/case-error';
                        }
                    });
                    this.productRecords = rows;
                    this.pagenation(this.pdtRecToDisplay);
                    this.refreshPageination();
                } else {
                    this.prdShowMsg = false;
                    if (this.prdShowMsg == false) {
                        this.isSpinner = false;
                    }
                }
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while getting Products',
                        message: error.message,
                        variant: 'error'
                    }),
                );
                this.productRecords = undefined;
                this.productInitialRecords = undefined;
            });
        this.prodSearchResults = this.pdtRecToDisplay;
    }
    refreshPageination() {
        if (this.isrefreshPageination == false) {
            this.isrefreshPageination = true;
        } else {
            this.isrefreshPageination = false;
        }
    }
    paginatedProducts;
    pagenation(recordsList) {
        this.pdtRecToDisplay = recordsList;
        if (this.recordsToDisplay.length <= 5) {
            this.paginatedCases = this.pdtRecToDisplay;
        } else if (this.pdtRecToDisplay.length > 5) {
            this.paginatedProducts = this.pdtRecToDisplay.slice(0, 5);
        }
    }
    @track allPdtRecToDisplay;
    @track allProductRecords;
    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'You Cannot Create the Case On Inactive Product',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    pagenation(recordsList) {
        this.productInitialRecords = recordsList;
        this.totalRecountCount = recordsList.length;
        this.endingRecord = this.pageSize;
        this.productCse = recordsList;
    }
    @track getCasesCount = 0;
    // This to hide Global search data tables after clicking case vertical navigation
    hideGlobalTables() {
        this.isAllTablesVisible = false;
        this.getCasesCount = this.getCasesCount + 1;
        if (this.selectedItem != "allCases") {
            this.selectedItem = "allCases";
            sessionStorage.setItem("selectedItem", this.selectedItem);
        }
    }
    //Sorting Product Data
    doProductSorting(event) {
        this.sortProductBy = event.detail.fieldName;
        this.sortProductDirection = event.detail.sortDirection;
        this.prodsortData(event.detail.fieldName, event.detail.sortDirection)
    }
    prodsortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.pdtRecToDisplay));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.pdtRecToDisplay = parseData;
        this.pagenation(this.pdtRecToDisplay);
        this.refreshPageination();
    }
    //fetching contacts
    contactCount;
    getContacts() {
        // This to hide Global search data tables after clicking Contacts vertical navigation
        this.isSpinner = true;
        this.cases = false;
        if (this.selectedItem != "allContacts") {
            this.selectedItem = "allContacts";
            sessionStorage.setItem("selectedItem", this.selectedItem);
        }
        this.isAllTablesVisible = false;
        getAllContacts({ contactListView: this.contactvalue })
            .then(result => {
                this.contactCount = result.conDataTableData.length;
                if (result.conDataTableData.length > 0) {
                    this.isSpinner = false;
                    this.conShowMsg = true;
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
                    for (let row of rows.conDataTableData) {
                        const finalSobjectRow = {}
                        let rowIndexes = Object.keys(row);
                        rowIndexes.forEach((rowIndex) => {
                            const relatedFieldValue = row[rowIndex];
                            if (relatedFieldValue.constructor === Object) {
                                this.HeaderColumns(relatedFieldValue, finalSobjectRow, rowIndex)
                            } else {
                                finalSobjectRow[rowIndex] = relatedFieldValue;
                            }
                        });
                        sObjectRelatedFieldListValues.push(finalSobjectRow);
                    }
                    this.DataTableResponseWrappper = rows;
                    this.conRecToDisplay = sObjectRelatedFieldListValues;
                    this.conRecToDisplay = JSON.parse(JSON.stringify(this.conRecToDisplay));
                    this.concolumnsResult = result.conDataTableColumns;
                    let concopyresult = [];
                    for (const n of this.concolumnsResult) {
                        let concopyObj = { ...n };
                        concopyObj.sortable = true;
                        concopyObj.wrapText = true;
                        concopyObj.hideDefaultActions = true;
                        concopyresult.push(concopyObj);
                    }
                    this.concolumnsResult = concopyresult;

                    this.contactRecords = rows;
                    this.conRecToDisplay.forEach(record => {
                        if (record.CreatedDate) {
                            let dt = new Date(record.CreatedDate);
                            record.createdDateFormat = record.CreatedDate;//new
                            record.CreatedDate = new Intl.DateTimeFormat(locale, options).format(dt);

                            // record.CreatedDate = new Intl.DateTimeFormat('en-US', { timeZone: timezone, year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute: '2-digit' }, options).format(dt);
                        }
                    });
                    this.contactpagenation(this.conRecToDisplay);
                    this.conrefreshPageination();
                } else {
                    this.conShowMsg = false;
                    if (this.conShowMsg == false) {
                        this.isSpinner = false;
                    }
                }
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while getting Contacts',
                        message: error.message,
                        variant: 'error'
                    }),
                );
                this.contactRecords = undefined;
                this.contactInitialRecords = undefined;
            });
    }
    contactpagenation(recordsList) {
        this.conRecToDisplay = recordsList;
        if (this.conRecToDisplay.length <= 5) {
            this.paginatedContacts = this.conRecToDisplay;
        } else if (this.conRecToDisplay.length > 5) {
            this.paginatedContacts = this.conRecToDisplay.slice(0, 5);
        }
    }
    conrefreshPageination() {
        if (this.isContactrefreshPageination == false) {
            this.isContactrefreshPageination = true;
        } else {
            this.isContactrefreshPageination = false;
        }
    }
    //Sorting Contact Data
    doContactSorting(event) {
        this.sortContactBy = event.detail.fieldName;
        this.sortContactDirection = event.detail.sortDirection;
        this.sortContactData(event.detail.fieldName, event.detail.sortDirection)
    }
    coltype; //new
    sortContactData(fieldname, direction) {
        //new changes
        let column = this.concolumnsResult.find(c => c.fieldName === fieldname);
        this.coltype = column.type;

        if (fieldname == 'CreatedDate') {
            fieldname = 'createdDateFormat';
        }
        //new changes end

        let parseData = JSON.parse(JSON.stringify(this.conRecToDisplay));

        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            //changes

            if (fieldname == 'createdDateFormat') {
                var dx = new Date(x);
                var dy = new Date(y);

                return isReverse * (dx.getTime() - dy.getTime());
            }
            else {
                return isReverse * ((x > y) - (y > x));
            }
            //changes end
            // return isReverse * ((x > y) - (y > x));
        });
        this.conRecToDisplay = parseData;
        this.contactpagenation(this.conRecToDisplay);
        this.conrefreshPageination();
    }
    handleSelect(event) {
        const selected = event.detail.name;
        this.currentContent = selected;
        if (selected == 'allCases') {
            this.cases = true;
        } else {
            this.cases = false;
        }
        if (selected == 'allProjects') {
            this.projects = true;
        } else {
            this.projects = false;
        }
        if (selected == 'intelProducts') {
            this.products = true;
        } else {
            this.products = false;
        }
        if (selected == 'allContacts') {
            this.contacts = true;
        } else {
            this.contacts = false;
        }
    }
    ProjectKeyChange(event) {
        const searchKey = event.target.value.toLowerCase();
        const searchFieldName = event.target.className;
        if (searchKey) {
            if (this.prjRecToDisplay) {
                let recs = [];
                for (let key of this.prjRecToDisplay) {
                    let valuesArray = Object.values(key);
                    for (let val of valuesArray) {
                        if (val) {
                            if (val.toString().toLowerCase().includes(searchKey)) {
                                recs.push(key);
                                break;
                            }
                        }
                    }
                    this.prjRecToDisplay = recs;
                    if (this.prjRecToDisplay.length > 0) {
                        this.projShowMsg = true;
                    } else {
                        this.projShowMsg = false;
                    }
                }
                this.pagenation(this.prjRecToDisplay);
                this.projrefreshPageination();
            }
        } else {
            this.getProjects();
        }
    }
    ProductKeyChange(event) {
        const searchKey = event.target.value.toLowerCase();
        const searchFieldName = event.target.className;
        if (searchKey) {
            if (this.pdtRecToDisplay) {
                this.prodSearchResults = this.pdtRecToDisplay;
                let recs = [];
                for (let key of this.pdtRecToDisplay) {
                    let valuesArray = Object.values(key);
                    for (let val of valuesArray) {
                        if (val) {
                            if (val.toString().toLowerCase().includes(searchKey)) {
                                recs.push(key);
                                break;
                            }
                        }
                    }
                    this.pdtRecToDisplay = recs;
                    if (this.pdtRecToDisplay.length > 0) {
                        this.prdShowMsg = true;
                    } else {
                        this.prdShowMsg = false;
                    }
                }
                this.pagenation(this.pdtRecToDisplay);
                this.refreshPageination();
            }
        } else {
            this.getProducts();
        }
    }
    //checkTempBoolean = true;
    @track temptotalContactList = [];
    ContactKeyChange(event) {
        this.temptotalContactList = this.conRecToDisplay;
        const searchKey = event.target.value.toLowerCase();
        if (searchKey) {
            if (this.conRecToDisplay) {
                let recs = [];
                for (let key of this.conRecToDisplay) {
                    let valuesArray = Object.values(key);
                    for (let val of valuesArray) {
                        if (val) {
                            if (val.toString().toLowerCase().includes(searchKey)) {
                                recs.push(key);
                                break;
                            }
                        }
                    }
                    this.conRecToDisplay = recs;
                    if (this.conRecToDisplay.length > 0) {
                        this.conShowMsg = true;
                    } else {
                        this.conShowMsg = false;
                    }
                }
            }
            this.contactpagenation(this.conRecToDisplay);
            this.conrefreshPageination();
        } else {
            this.getContacts();
        }
    }
    get caseoptions() {
        return [
            { label: 'Sort Cases', value: 'sortCases' },
            { label: 'All Cases', value: 'allCases' },
            { label: 'My Open Cases', value: 'myOpenCases' },
            { label: 'My Closed Cases', value: 'myClosedCases' },
            { label: 'My Recently Created Cases', value: 'myRecentlyCreatedCases' },
            { label: 'My Recently Modified Cases', value: 'myRecentlyModifiedCases' },
            { label: 'My Recently Viewed Cases', value: 'myRecentlyViewedCases' },
            { label: 'My Recently Closed Cases', value: 'myRecentlyClosedCases' },
            { label: 'My Interested Party Cases', value: 'myInterestedPartyCases' },
        ];
    }
    get projectoptions() {
        return [
            { label: 'All Projects', value: 'AllProjects' },

        ];
    }
    get productoptions() {
        return [
            { label: 'My Active Intel Products', value: 'ActiveProducts' },
            { label: 'All Intel Products', value: 'AllProducts' },
        ];
    }
    get contactoptions() {
        return [
            { label: 'My Contacts', value: 'MyContacts' },
        ];
    }
    handleCaseNavigation(event) {
        this.casevalue = event.detail.value;
        this.getCases();
    }
    handleProjectNavigation(event) {
        this.projectvalue = event.detail.value;
    }
    @track isrefreshPageination = false;
    refreshPageination() {
        if (this.isrefreshPageination == false) {
            this.isrefreshPageination = true;
        } else {
            this.isrefreshPageination = false;
        }
    }
    handleProductNavigation(event) {
        this.productvalue = event.detail.value;
        this.getProducts();

    }
    //Navigate to case create page 
    handleNewCaseNavigate() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'new-case'
            },
            state: {
                mode: 'create'
            }
        });
    }
    handleNewProjectNavigate() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'new-project'
            },
        });
    }

    doSomething() { }
    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }
    //clicking on next button this method will be called
    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);
        }
    }
    //this method displays records page by page
    displayRecordPerPage(page) {

        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount) ?
            this.totalRecountCount : this.endingRecord;
        this.caseRecords = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }
    // this method validates the data and creates the csv file to download
    downloadCSVFile() {
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();
        // getting keys from data
        this.caseRecords.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });
        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;
        // main for loop to get the data based on key value
        for (let i = 0; i < this.caseRecords.length; i++) {
            let colValue = 0;
            // validating keys in data
            for (let key in rowData) {
                if (rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if (colValue > 0) {
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.caseRecords[i][rowKey] === undefined ? '' : this.caseRecords[i][rowKey];
                    csvString += '"' + value + '"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }
        // Creating anchor element to download
        let downloadElement = document.createElement('a');
        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'Case Data.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();
    }
    handleRowActionedit(event) {
        this.recordId = event.detail.row.Id;
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'edit-projects'
            },
            state: {
                recordId: this.recordId
            }
        });

    }
    handleprojPaginatorChange(event) {
        this.prjRecToDisplay = event.detail;
        this.rowNumberOffset = this.prjRecToDisplay[0].rowNumber - 1;
        this.initialRecords = event.detail;
    }
    handleprodPaginatorChange(event) {
        this.paginatedProducts = event.detail;
    }
    handlecontPaginatorChange(event) {
        this.conRecToDisplay = event.detail;
        this.rowNumberOffset = this.conRecToDisplay[0].rowNumber - 1;
        this.initialRecords = event.detail;
    }
    ///// NewCase button Navigation////
    @api assetId;
    handleRowActionproducts(event) {
        this.assetId = event.detail.row.Id;
    }
    // Added by chetan as part of SF error fix 
    timer
    @api caseInfo = 'democheck';
    hanldeProgressValueChange(event) {
        this.searchValue = event.detail;
        console.log('Ck>> global  search', this.searchValue);
        this.projects = false;
        this.products = false;
        this.contacts = false;
        if (this.searchValue == '') {
            this.globalcaserecordsToDisplay = [];
            this.globalpdtRecToDisplay = [];
            this.globalprjRecToDisplay = [];
            this.isAllTablesVisible = false;
            if (this.currentContent == 'allCases') {
                this.cases = true;
            }
            if (this.currentContent == 'allProjects') {
                this.projects = true;
            }
            if (this.currentContent == 'intelProducts') {
                this.products = true;
            }
            if (this.currentContent == 'allContacts') {
                this.contacts = true;
            }
        } else {
            this.isAllTablesVisible = true;
            this.getSearchResult();
            this.cases = false;
        }
    }
    @track globalcaserecordsToDisplay = [];
    @track globalpdtRecToDisplay = [];
    @track globalprjRecToDisplay = [];
    @track globalCaseCse = [];
    //global search js method
    isprojectpagination;
    getSearchResult() {
        console.log('CK>> JS method called');

        getSearchResult({ searchKey: this.searchValue })
            .then(result => {
                console.log('CK>> Result fetched');
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
                //Case Data table 
                //let caseData = JSON.parse(JSON.stringify(result[0]));

                if (result.projlist.length > 0) {
                    this.prjshowmsg = true;
                } else {
                    this.prjshowmsg = false;
                }
                if (result.prodlist.length > 0) {
                    this.pdtShowmsg = true;
                } else {
                    this.pdtShowmsg = false;
                }

                let caseresult = result.caselist;
                let caseData = JSON.parse(JSON.stringify(caseresult));

                caseData.forEach(function (item) {

                    item.ProjectName = item.Core_IPS_Project_Case__r != undefined || item.Core_IPS_Project_Case__r != null ? item.Core_IPS_Project_Case__r.Name : '';
                    item.linkCase = communityPath + '/case-detail?recordId=' + item.Id + '&isCase=true';
                    item.linkCaseComment = communityPath + '/case-detail?recordId=' + item.Id + '&isCase=false';
                    if (item.CreatedDate) {
                        item.CreateddateFormat = item.CreatedDate;
                        let dt = new Date(item.CreatedDate);
                        item.Createddate = new Intl.DateTimeFormat(locale, options).format(dt);


                    }
                    if (item.LastModifiedDate) {
                        item.LastModifieddateFormat = item.LastModifiedDate;
                        let dt = new Date(item.LastModifiedDate);
                        item.LastModifieddate = new Intl.DateTimeFormat(locale, options).format(dt);


                    }
                    if (item.ClosedDate) {
                        item.CloseddateFormat = item.ClosedDate;
                        let dt = new Date(item.ClosedDate);
                        item.Closeddate = new Intl.DateTimeFormat(locale, options).format(dt);


                    }
                });
                //Product Data table 
                let prodresult = result.prodlist;
                let Data = JSON.parse(JSON.stringify(prodresult));
                Data.forEach(function (item) {
                    item.AccountName = item.Account != undefined || item.Account != null ? item.Account.Name : '';
                    item.ProjectName = item.Core_IPS_Project__r != undefined || item.Core_IPS_Project__r != null ? item.Core_IPS_Project__r.Name : '';
                    item.linkProd = communityPath + '/product-detail?recordId=' + item.Id;
                });
                //Project Data table

                let projresult = result.projlist;

                let projData = JSON.parse(JSON.stringify(projresult));

                projData.forEach(function (item) {
                    item.linkProj = communityPath + '/project-detail?recordId=' + item.Id;
                });
                if (caseData.length > 0) {
                    this.caseShowmsg = true;
                    this.globalcaserecordsToDisplay = caseData;

                } else {
                    this.caseShowmsg = false;
                }
                if (Data.length > 0) {
                    this.pdtShowmsg = true;
                    this.globalpdtRecToDisplay = Data;
                } else {
                    this.pdtShowmsg = false;
                }
                if (projData.length > 0) {
                    this.prjshowmsg = true;
                    this.globalprjRecToDisplay = projData;
                } else {
                    this.prjShowmsg = false;
                }
                this.globalCasepagenation(this.globalcaserecordsToDisplay);
                this.refreshCasePageination();
                this.globalProjpagenation(this.globalprjRecToDisplay);
                this.globalProjrefreshPageination();
                this.globalProdpagenation(this.globalpdtRecToDisplay);
                this.globalProdrefreshPageination();
            })
            .catch(error => {
                console.log('Error Message--' + error);
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body.message,
                });
                this.dispatchEvent(event);
                this.globalpdtRecToDisplay = null;
                this.globalprjRecToDisplay = null;
                this.globalcaserecordsToDisplay = null;
                this.isAllTablesVisible = false;
            });
    }
    globalCasepagenation(recordsList) {
        this.globalcaserecordsToDisplay = recordsList;
        if (this.globalcaserecordsToDisplay.length <= 5) {
            this.fewCaseList = this.globalcaserecordsToDisplay;
        } else if (this.globalcaserecordsToDisplay.length > 5) {
            this.fewCaseList = this.globalcaserecordsToDisplay.slice(0, 5);
        }

    }
    refreshCasePageination() {
        if (this.isglobalCaserefreshPageination == false) {

            this.isglobalCaserefreshPageination = true;
        } else {

            this.isglobalCaserefreshPageination = false;
        }

    }
    globalProjpagenation(recordsList) {
        this.globalprjRecToDisplay = recordsList;
        if (this.globalprjRecToDisplay.length <= 5) {
            this.projPaginationList = this.globalprjRecToDisplay;
        } else if (this.globalprjRecToDisplay.length > 5) {
            this.projPaginationList = this.globalprjRecToDisplay.slice(0, 5);
        }
    }
    globalProjrefreshPageination() {
        if (this.isglobalProjrefreshPageination == false) {
            this.isglobalProjrefreshPageination = true;
        } else {
            this.isglobalProjrefreshPageination = false;
        }
    }
    globalProdpagenation(recordsList) {
        this.globalpdtRecToDisplay = recordsList;
        if (this.globalpdtRecToDisplay.length <= 5) {
            this.prodPaginationList = this.globalpdtRecToDisplay;
        } else if (this.globalpdtRecToDisplay.length > 5) {
            this.prodPaginationList = this.globalpdtRecToDisplay.slice(0, 5);
        }
    }
    globalProdrefreshPageination() {
        if (this.isglobalProdrefreshPageination == false) {
            this.isglobalProdrefreshPageination = true;
        } else {
            this.isglobalProdrefreshPageination = false;
        }
    }
    globalcasePaginatorChange(event) {
        this.fewCaseList = event.detail;
        this.rowNumberOffset = this.globalcaserecordsToDisplay[0].rowNumber - 1;
        this.initialRecords = event.detail;
    }
    @track projPaginationList = [];
    globalprojPaginatorChange(event) {
        this.projPaginationList = event.detail;
        this.rowNumberOffset = this.globalprjRecToDisplay[0].rowNumber - 1;
        this.initialRecords = event.detail;
    }
    @track prodPaginationList = [];
    globalPrdPaginatorChange(event) {
        this.prodPaginationList = event.detail;
        this.rowNumberOffset = this.globalpdtRecToDisplay[0].rowNumber - 1;
        this.initialRecords = event.detail;
    }
    //sorting Global Search Case Data Table
    doGlobalCaseSorting(event) {
        this.GlobalCaseSortBy = event.detail.fieldName;
        this.sortGlobalCaseDirection = event.detail.sortDirection;
        this.sortGlobalCaseDataData(event.detail.fieldName, event.detail.sortDirection)
    }
    coltype;
    sortGlobalCaseDataData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.globalcaserecordsToDisplay));
        //console.log('parsedata--'+parseData.length);
        let column = this.globalcasecolumns.find(c => c.fieldName === fieldname);
        this.coltype = column.type;


        if (fieldname == 'Createddate') {
            fieldname = 'CreateddateFormat';
        }
        else if (fieldname == 'Closeddate') {
            fieldname = 'CloseddateFormat';

        }
        else if (fieldname == 'LastModifieddate') {
            fieldname = 'LastModifieddateFormat';
        }

        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';

            if (fieldname === 'CreateddateFormat' || fieldname === 'CloseddateFormat' || fieldname === 'LastModifieddateFormat') {
                var dx = new Date(x);
                var dy = new Date(y);
                return isReverse * (dx.getTime() - dy.getTime());
            }
            else {
                return isReverse * ((x > y) - (y > x));
            }
        });
        this.globalcaserecordsToDisplay = parseData;
        this.globalCasepagenation(this.globalcaserecordsToDisplay);
        this.refreshCasePageination();
    }
    //Sorting for Global Search Project Data table
    doGlobalProjectSorting(event) {
        this.GlobalProjectSortBy = event.detail.fieldName;
        this.sortGlobalProjectDirection = event.detail.sortDirection;
        this.sortGlobalProjectDataData(event.detail.fieldName, event.detail.sortDirection)
    }
    sortGlobalProjectDataData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.globalprjRecToDisplay));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.globalprjRecToDisplay = parseData;

        this.globalProjpagenation(this.globalprjRecToDisplay);
        this.globalProjrefreshPageination();
    }
    //sorting for Global Search Product Data Table
    doGlobalProductSorting(event) {
        this.GlobalProductSortBy = event.detail.fieldName;
        this.sortGlobalProductDirection = event.detail.sortDirection;
        this.sortGlobalProductDataData(event.detail.fieldName, event.detail.sortDirection)
    }
    sortGlobalProductDataData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.globalpdtRecToDisplay));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.globalpdtRecToDisplay = parseData;
        this.globalProdpagenation(this.globalpdtRecToDisplay);
        this.globalProdrefreshPageination();
    }
    globalCaseRowAction(event) {
        const row = event.detail.row.Id;
        this.recordId = event.detail.row.Id;
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'case-detail'
            },
            state: {
                recordId: this.recordId
            }
        });
    }
    navigateToPreference() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'preferencepage'
            },
        });
    }
    navigateToDisclaimer() {
        const Discurl = '/' + PortalSiteURL + '/s/confidentiality-statement#';
        const orginUrl1 = window.location.origin;
        const orginUrl = encodeURI(orginUrl1);
        this.finalUrl = orginUrl.concat(Discurl);
        window.open(this.finalUrl);
    }
    handleCasePaginationChange(event) {
        this.fewCaseList = event.detail;
    }
    handlePaginationContacts(event) {
        this.paginatedContacts = event.detail;
    }
    handlePaginationProjects(event) {
        this.paginatedProjects = event.detail;
    }
}