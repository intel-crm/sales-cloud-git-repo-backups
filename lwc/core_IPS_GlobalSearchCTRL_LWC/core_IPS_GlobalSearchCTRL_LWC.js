import { LightningElement, track } from 'lwc';
import getCaseList from '@salesforce/apex/core_IPS_GlobalCaseSearchCTRL_LWC.getCaseList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
const advCaseColumns = [


    {
        label: "CaseNumber",
        fieldName: "CaseNumber",
        type: "button",
        typeAttributes: { label: { fieldName: "CaseNumber" }, tooltip: "Name", target: "_self" }
    },
    { label: 'Status', fieldName: 'Status', type: 'text', },

    { label: 'Severity', fieldName: 'Core_Severity__c', type: 'text', },
    { label: 'Subject', fieldName: 'Subject', type: 'text', },
    { label: 'Product Name', fieldName: 'Core_IPS_Product_name__c', type: 'url', },
    { label: 'Project', fieldName: 'Core_IPS_Project_Case__c', type: 'text' },

    { label: 'Customer Reference', fieldName: 'Core_Customer_Reference_ID__c', type: 'Id' }
    //{ label: 'Close Date', fieldName: 'CloseDate', type: 'date', typeAttributes:{timeZone:'UTC', year:'numeric', month:'numeric', day:'numeric'}},
];
export default class Core_IPS_GlobalSearchCTRL_LWC extends NavigationMixin(LightningElement) {
    advCaseNum;
    advStatus;
    advProductName;
    advReferenceId;
    advSearcAll = '';
    advFromDate;
    advToDate;
    filterstring;
    advDataTable = [];
    advCaseColumns = advCaseColumns;
    filterstring = '';
    subStatusString = '';
    @track showSection = true;

    advhandleSearchAll(event) {
        this.advSearcAll = event.target.value;
    }
    advCaseNumOnchange(event) {
        this.advCaseNum = event.target.value;
        console.log('adv casenum', this.advCaseNum);

    }
    advHandleChangeStatus(event) {
        this.advStatus = event.target.value;
        console.log('adv advStatus', this.advStatus);
    }
    advCustomerRefrenceid(event) {
        this.advReferenceId = event.target.value;
        console.log('adv advReferenceId', this.advReferenceId);
    }
    advProductOnChange(event) {
        this.advProductName = event.target.value;
        console.log('adv advProductName', this.advProductName);


    }
    fromDateOnChange(event) {
        this.advFromDate = event.target.value;
        console.log('adv advFromDate', this.advFromDate);
    }
    toDateOnChange(event) {
        this.advToDate = event.target.value;
        console.log('adv todate', this.advToDate);
    }
    adcSearchBar() {
        // if(this.advSearcAll!=null && this.filterstring==''||null){
        //     getCaseList({ caseSearch: this.advSearcAll,filterStrEsc: '',subStatusEsc:''})
        //     .then(result => {
        //         console.log('only result', result);
        //         this.advDataTable=result;

        //         this.searchdata = true;

        //     })
        //     .catch(error => {
        //         const event = new ShowToastEvent({
        //             title: 'Error',
        //             variant: 'error',
        //             message: error.body.message,
        //         });
        //         this.dispatchEvent(event);
        //         this.advDataTable = null;

        //     });
        // }
        // else{
        this.filterstring = '';
        if (typeof this.advCaseNum !== 'undefined' && this.advCaseNum !== '') {
            this.filterstring = 'CaseNumber=' + this.advCaseNum + '#%#';

        }
        console.log('advansceugfufh', this.advCaseNum);
        // else{
        //     this.filterstring='';
        // }
        if (typeof this.advProductName !== 'undefined' && this.advProductName !== '') {
            this.filterstring = this.filterstring + 'ProductName=' + this.advProductName + '#%#';
        }
        // else{
        //     this.filterstring='';
        // }
        if (typeof this.advStatus !== 'undefined' && this.advStatus !== '') {
            this.filterstring = this.filterstring + 'Status=' + this.advStatus + '#%#';
        }
        // else{
        //     this.filterstring='';
        // }
        if (typeof this.advToDate !== 'undefined' && this.advToDate !== '') {
            this.filterstring = this.filterstring + 'CreatingDateTo=' + this.advToDate + '#%#';
        }
        // else{
        //     this.filterstring='';
        // }
        if (typeof this.advReferenceId !== 'undefined' && this.advReferenceId !== '') {
            this.filterstring = this.filterstring + 'Core_Customer_Reference_ID__c=' + this.advReferenceId + '#%#';
        }
        // else{
        //     this.filterstring='';
        // }
        if (typeof this.advFromDate !== 'undefined' && this.advFromDate !== '') {
            this.filterstring = this.filterstring + 'CreatingDateFrom=' + this.advFromDate + '#%#';
        }
        // else{
        //     this.filterstring='';
        // // }
        console.log('only filterstring', this.filterstring);

        getCaseList({ caseSearch: this.advSearcAll, filterStrEsc: this.filterstring, subStatusEsc: '' })
            .then(result => {
                console.log('only result', result);
                this.advDataTable = result;

                this.searchdata = true;
                this.filterstring = '';

            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body.message,
                });
                this.dispatchEvent(event);
                this.advDataTable = null;

            });
    }

    advhandleSearchKeyword() {
        this.adcSearchBar();
        this.filterstring = '';
        console.log('After  search button filterstring', this.filterstring);


    }
    value = ['option1'];

    get options() {
        return [
            { label: 'New', value: 'New' },
            { label: 'Open', value: 'New' },
            { label: 'Closed', value: 'Closed' },

        ];
    }

    get selectedValues() {
        return this.value.join(',');
    }


    handleAdvSearchBtn(event){
        if(this.showSection == false){
            this.showSection = true;
        }else if(this.showSection == true){
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
}