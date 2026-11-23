import {LightningElement, wire,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import retrieveListViewData from '@salesforce/apex/PMP_OfferingSearchController.retrieveListViewData';//IPA2.0 + US TWC4497-1631
import buttonVisibility from '@salesforce/apex/PMP_Utility.isLoggedInUserAdmin';
import aemURLStart from '@salesforce/label/c.PMP_AEM_Offering_URL';//IPA2.0 + US TWC4497-1631
import aemURLOffEnd from '@salesforce/label/c.PMP_AEM_Offering_URL_Part_2';//IPA2.0 + US TWC4497-1631
import getCompanyLink from '@salesforce/apex/PMP_StaticConstants_Offering.returnCompany';//IPA2.0 + US TWC4497-1631
import noRecords from '@salesforce/label/c.PRM_NoRecords';
import formatDateTime from '@salesforce/i18n/dateTime';
// IPA2.0 + US TWC4497-1631
// const columnsOfferings = [
//     { label: 'Partner Offering Lifecycle Status', fieldName: 'PMP_Partner_Offering_Lifecycle_Status_Nm__c', type: 'text' },
//     { label: 'Offering Name', fieldName: 'Name', type: 'text' },
//     { label: 'View Offerings', fieldName: 'linkEng', type: 'url',typeAttributes: { label: 'ENG', target: '_blank'} },
//     { label: 'Edit', fieldName: 'Edit_Record', type: 'url', typeAttributes: { label: 'Edit', target: '_blank'} },
//     { label: 'Clone', fieldName: 'Clone_Record', type: 'url', typeAttributes: { label: 'Clone', target: '_blank'} },
//     { label: 'Company Information', fieldName: 'Company_Record' ,type: 'url', typeAttributes: { label: {fieldName: 'Company'}, target: '_blank'}},
//     { label: 'Marketplace Admin', fieldName: 'IntelAdmin' ,type: 'url', typeAttributes: { label: {fieldName: 'IntelAdminName'}, target: '_blank'}},
//     { label: 'Category', fieldName: 'PMP_Category_nm__c' , type: 'text'},
//     { label: 'Sub Category', fieldName: 'PMP_Sub_Category_nm__c' , type: 'text'},
//     { label: 'Is Published', fieldName: 'PMP_Is_Published_Ind__c' , type: 'boolean'},
//     { label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'date', typeAttributes: { year: 'numeric', month: 'numeric', day: '2-digit', hour: '2-digit', minute: '2-digit', hour12: true }, cellAttributes: { alignment: 'left' }, cellClass: 'slds-cell-wrap', formatter: formatDateTime },
//     { label: 'Last Modified By', fieldName: 'LastModified', type: 'url', typeAttributes: { label: {fieldName: 'LastModifiedName'}, target: '_blank'} },    
//     { label: 'Partner Program Segment', fieldName: 'PMP_Business_Segment_Nm__c' , type: 'text'},
//     { label: 'Translation Status', fieldName: 'PMP_Translation_Lifecycle_Status_nm__c' , type: 'text'},
//     { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: { year: 'numeric', month: 'numeric', day: '2-digit', hour: '2-digit', minute: '2-digit', hour12: true }, cellAttributes: { alignment: 'left' }, cellClass: 'slds-cell-wrap', formatter: formatDateTime },
//     { label: 'Partner Offering Visibility Name', fieldName: 'PMP_Partner_Offering_Visibility_Nm__c' , type: 'text'}
// ];

const columnsPartners = [
    { label: 'Partner Name', fieldName: 'Partner_Name', type: 'url', typeAttributes: { label: {fieldName: 'Partner'}, target: '_blank'} },
    { label: 'Transaction Lifecycle Status', fieldName: 'PMP_Company_Lifecycle_Status_Nm__c', type: 'text' },
    { label: 'Account', fieldName: 'Account' ,type: 'url', typeAttributes: { label: {fieldName: 'AccountName'}, target: '_blank'}},
    { label: 'Intel Marketplace Admin', fieldName: 'IntelAdmin' ,type: 'url', typeAttributes: { label: {fieldName: 'IntelAdminName'}, target: '_blank'}},
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: { year: 'numeric', month: 'numeric', day: '2-digit', hour: '2-digit', minute: '2-digit', hour12: true }, cellAttributes: { alignment: 'left' }, cellClass: 'slds-cell-wrap', formatter: formatDateTime },
    { label: 'Program Membership', fieldName: 'PMP_Account_Program_Membership__c' , type: 'text'},
    { label: 'Partner Program', fieldName: 'PMP_Partner_Program_nm__c' , type: 'text'},
    { label: 'Input Language', fieldName: 'PMP_Company_Information_Language_Nm__c' , type: 'text'},
    //{ label: 'Address', fieldName: 'PMP_Account_Address_Txt__c' , type: 'text'},
    //{ label: 'View Partners', fieldName: 'PMP_View_Partners_Txt__c' , type: 'text'},
    { label: 'Translation Status', fieldName: 'PMP_Translation_Lifecycle_Status_nm__c' , type: 'text'},
    { label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'date', typeAttributes: { year: 'numeric', month: 'numeric', day: '2-digit', hour: '2-digit', minute: '2-digit', hour12: true }, cellAttributes: { alignment: 'left' }, cellClass: 'slds-cell-wrap', formatter: formatDateTime }
];

// const columnsSolutions = [
//     { label: 'Solution Name', fieldName: 'Solution_Name', type: 'url', typeAttributes: { label: {fieldName: 'Solution'}, target: '_blank'} },
//     { label: 'Status', fieldName: 'PSS_Partner_Solution_Lifecycle_Status_Nm__c', type: 'text' },
//     { label: 'View Offering', fieldName: 'Offering', type: 'url', typeAttributes: { label: {fieldName: 'OfferingName'}, target: '_blank'} },
//     { label: 'Solution Applicable', fieldName: 'PSS_Programs_Applicable_Nm__c' , type: 'text'},
//     { label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'date', typeAttributes: { year: 'numeric', month: 'numeric', day: '2-digit', hour: '2-digit', minute: '2-digit', hour12: true }, cellAttributes: { alignment: 'left' }, cellClass: 'slds-cell-wrap', formatter: formatDateTime },
//     { label: 'Last Modified By', fieldName: 'LastModified', type: 'url', typeAttributes: { label: {fieldName: 'LastModifiedName'}, target: '_blank'} },
//     { label: 'Created By', fieldName: 'CreatedId' , type: 'url', typeAttributes: { label: {fieldName: 'CreatedName'}, target: '_blank'}},
//     { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: { year: 'numeric', month: 'numeric', day: '2-digit', hour: '2-digit', minute: '2-digit', hour12: true }, cellAttributes: { alignment: 'left' }, cellClass: 'slds-cell-wrap', formatter: formatDateTime },
//     { label: 'Storefront Status', fieldName: 'Partner_Status__c' , type: 'text'}
    
// ];
 
export default class PMP_createSearchDatatable extends LightningElement {
    listViewResults = [];
    // columnsOfferings;IPA2.0 + US TWC4497-1631
    columnsPartners;
    //columnsSolutions;
    searchKey;
    columns;
    showData = false;
    @track dynamicColumns;
    @track isShowModal = false;
    @track isAdmin = false;
    /*@track v_Offset=0;
    @track v_TotalRecords;
    @track page_size = 5;*/
    @track recordEnd = 0;
    @track recordStart = 0;
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track loaderSpinner = false;
    @track error = null;
    @track pageSize = 10;    
    @track isPrev = true;
    @track isNext = true;
    recordsToDisplay = [];
    @track error1 = null;
    searchName;
    searchHeading;
	placeholderSearch;
    @track isLoading = false;
    companyLink;
    showNoRec = false;

    labels = {
        aemURLStart,
        aemURLOffEnd,//IPA2.0 + US TWC4497-1631
        noRecords
      }

    connectedCallback(){
        this.isLoggedInUserAdmin();
        let pageUrl = window.location.href;
        // IPA2.0 + US TWC4497-1631
        // if(pageUrl.includes('PMP_Partner_Offering__c')){
        //     this.objectName = 'PMP_Partner_Offering__c';
        //     this.columns = columnsOfferings;
        //     this.searchName = 'Find Offerings';
        //     this.searchHeading = 'Search Partner Offerings';
		// 	this.placeholderSearch = 'Search by Partner Offering Name';

        // }
        if(pageUrl.includes('PMP_Company__c')){
            this.objectName = 'PMP_Company__c';
            this.columns = columnsPartners;
            this.searchName = 'Find Partners';
            this.searchHeading = 'Search Partners';
			this.placeholderSearch = 'Search by Partner Name';
        }
        // if(pageUrl.includes('partner-solution-list')){
        //     this.objectName = 'partner-solution-list';
        //     this.columns = columnsSolutions;
        //     this.searchName = 'Find Solutions';
        //     this.searchHeading = 'Search Partner Solutions';
		// 	this.placeholderSearch = 'Search by Partner Solution Name';
        // }

        getCompanyLink() 
        .then(result =>{
                this.companyLink = result.split(',');
                console.log('comapnylink-->'+result);
        })
        .catch(error => {
            this.error = error;
        })
        
    }
    isLoggedInUserAdmin(){
        buttonVisibility()
            .then(result => {
                this.isAdmin = result;
                console.log('@@Admin=='+this.isAdmin);
                
            })
            .catch(error => {
                this.error = error;
            });
    }

    searchData(){
        /*Need to check if this is needed */
        if(this.searchKey.length <= 1){
            const event = new ShowToastEvent({
                title: 'Alert!',
                message: 'Please enter more than 1 characters',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
        else {
            this.isLoading = true;
        retrieveListViewData({keyword: this.searchKey,objectName: this.objectName})
            .then(result => {
               let tempRecs = [];
               let i = 0;
                result.forEach( ( record ) => {
                    let tempRec = Object.assign( {}, record );  
                    let urlString = window.location.href;
                    let tempLink;
                    let baseURL = urlString.substring(0, urlString.indexOf('/s'));
                    // const tempRecDate = new Date(tempRec.PMP_Partner_Offering_End_Dt__c);IPA2.0 + US TWC4497-1631
                    const today = new Date();
                    // IPA2.0 + US TWC4497-1631
                    // if(urlString.includes( 'PMP_Partner_Offering__c')){
                    //     if(!(tempRec.PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Retired' || (tempRec.PMP_Business_Segment_Nm__c && tempRec.PMP_Business_Segment_Nm__c.includes('IoT') && tempRec.PMP_Translated_Languages__c && !tempRec.PMP_Translated_Languages__c.includes('English')))){
                    //             tempRec.Edit_Record =  baseURL + this.companyLink[1]+ tempRec.Id + this.companyLink[2] ;
                    //         }
                        
                    //     tempRec.Clone_Record = baseURL + this.companyLink[1] + tempRec.Id+ this.companyLink[3];
                    //     tempRec.LastModified = baseURL +this.companyLink[4] + tempRec.LastModifiedById;
                    //     tempRec.LastModifiedName = tempRec.LastModifiedBy.Name;
                    //     if(tempRec.PMP_Company_Id__c != null){
                    //         tempRec.Company_Record = baseURL + this.companyLink[0] + tempRec.PMP_Company_Id__c;
                    //         tempRec.Company = tempRec.PMP_Company_Id__r.Name;
                    //     }
                        
                    //     if(tempRec.PMP_Intel_Admin_Id__c != null){
                    //         tempRec.IntelAdmin = baseURL + this.companyLink[4] + tempRec.PMP_Intel_Admin_Id__c;
                    //         tempRec.IntelAdminName = tempRec.PMP_Intel_Admin_Id__r.Name;
                    //         }
                    //     if(tempRec.PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Approved' && tempRec.PMP_Pre_Release_Item_Count_Num__c == 0 && tempRecDate >= today && tempRec.PMP_Translated_Languages__c && tempRec.PMP_Translated_Languages__c.includes('English')){
                    //              tempRec.linkEng = this.labels.aemURLStart +'us/en' + this.labels.aemURLOffEnd + tempRec.PMP_Published_Copy_Id_Txt__c + '/' + tempRec.PMP_Partner_Offering_Nm__c+ '.html';
                    //              }
                    // }
                    if(urlString.includes('PMP_Company__c' )){
                        tempRec.Partner_Name = baseURL + this.companyLink[0] + tempRec.Id;
                        tempRec.Partner = tempRec.Name;
                        if(tempRec.PMP_Intel_Admin_Id__c != null){
                            tempRec.IntelAdmin = baseURL +this.companyLink[4] + tempRec.PMP_Intel_Admin_Id__c;
                            tempRec.IntelAdminName = tempRec.PMP_Intel_Admin_Id__r.Name;
                        }
                    }
                    // if(urlString.includes('partner-solution-list' )){
                    //     tempRec.Solution_Name = baseURL + this.companyLink[5] + tempRec.Id;
                    //     tempRec.Solution = tempRec.PSS_Proposal_Name_Txt__c;
                    //     tempRec.LastModified = baseURL +this.companyLink[4] + tempRec.LastModifiedById;
                    //     tempRec.LastModifiedName = tempRec.LastModifiedBy.Name;
                    //     tempRec.CreatedId = baseURL +this.companyLink[4] + tempRec.CreatedById;
                    //     tempRec.CreatedName = tempRec.CreatedBy.Name;
                    //     // IPA2.0 + US TWC4497-1631
                    //     // if(tempRec.PSS_Partner_Offering__c != null){
                    //     //     tempRec.Offering = baseURL +this.companyLink[6] + tempRec.PSS_Partner_Offering__c;
                    //     //     tempRec.OfferingName = tempRec.PSS_Partner_Offering__r.Name;
                    //     // }
                        
                    // }
                    tempRecs.push( tempRec );
                    i++;
                });
                this.listViewResults = tempRecs;
                console.log('Data--> :' + JSON.stringify(this.listViewResults));
                this.totalRecords = this.listViewResults.length;
                if(this.listViewResults.length > 0) {
                    this.showData = true;
                    this.isLoading = false;
                    this.getTableData();
                } else{
                    this.showData = false;
                    this.isLoading = false;
                    this.showNoRec = true;
                }
            })
            .catch(error => {
                this.error1 = error;
                this.listViewResults = [];
                this.isLoading = false;
                console.log('Error :' + JSON.stringify(this.error1));
            });
        }
    }


    handleKeyChange(event){
        this.searchKey = event.target.value;
        //console.log('keyload'+event.keyCode);
        if(event.target.value <= 0){
            this.showData = false;
            this.listViewResults = '';
            this.searchkey = '';
            this.showNoRec = false;
            this.resetValues();
        }
        
    }

    showModalBox() {  
        this.isShowModal = true;
        this.resetValues();
        this.searchKey = ''; 
        this.showNoRec = false;
    }

    hideModalBox() {  
        this.isShowModal = false;
        this.resetValues();
    }

    handlePageNextAction(){
        this.pageNumber = this.pageNumber+1;
        this.getTableData();
    }
 
   
    handlePagePrevAction(){
        this.pageNumber = this.pageNumber-1;
        this.getTableData();
    }

    getTableData(){
        this.recordsToDisplay = [];
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        var offsetTemp = (this.pageNumber-1) * this.pageSize;
        this.recordStart =   offsetTemp + 1;
        var recEndTemp = this.pageSize * this.pageNumber;
        this.recordEnd = this.totalRecords >= recEndTemp ? recEndTemp : this.totalRecords;
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
        this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
        
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.listViewResults[i]);
            console.log('@@recordsToDisplay=='+JSON.stringify(this.recordsToDisplay));
        }

    }
     
    resetValues(){
        this.showData = false;
        this.listViewResults = '';
        //this.searchKey = '';
        this.recordEnd = 0;
        this.recordStart = 0;
        this.pageNumber = 1;
        this.totalRecords = 0;
        this.totalPages = 0;
        this.isNext = true;
        this.isPrev = true;
    }

    formatDateTime(dateTimeString) {
        if (dateTimeString) {
            const date = new Date(dateTimeString);
            const options = { day: 'numeric', month: 'numeric', year: 'numeric', hour: 'numeric', minute: 'numeric', hour12: true, second: 'numeric' };
            const formattedDate = new Intl.DateTimeFormat('en-US', options).format(date);
            // Replace dashes (-) with slashes (/)
            return formattedDate.replace(/-/g, '/');
        }
        return null;
    }
        
    
}