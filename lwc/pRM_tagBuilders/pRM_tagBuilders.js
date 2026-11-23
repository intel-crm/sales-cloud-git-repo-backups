import { LightningElement, wire, track, api } from 'lwc';
import serachAccs from '@salesforce/apex/PRM_IPA_Affiliations.fetchAccsData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import accountIdErrorMsg from '@salesforce/label/c.PRM_searchMsg';
import search from '@salesforce/label/c.PRM_Search';
import noRecords from '@salesforce/label/c.PRM_NoRecords';
import AccountName from '@salesforce/label/c.PRM_Account_Name';
import AccountNo from '@salesforce/label/c.PRM_Account_No';
import PartnerRole from '@salesforce/label/c.PRM_Partner_Role';
import Country from '@salesforce/label/c.PRM_Country';
import PhoneColumn from '@salesforce/label/c.PRM_Phone_Column';
import validationMsg from '@salesforce/label/c.PRM_validationMsg';
import NoIPAAccount from '@salesforce/label/c.PRM_No_IPA_Accounts';
import { refreshApex } from '@salesforce/apex';
import inserttagbuilder from '@salesforce/apex/PRM_IPA_Affiliations.tagBuilders';
import { loadStyle } from 'lightning/platformResourceLoader';
import CUSTOMCSS from '@salesforce/resourceUrl/multilineToastMessage';

const columns = [
    {
        label: AccountName,
        fieldName: 'accountName',
        type: 'text'
    }, {
        label: AccountNo,
        fieldName: 'accountNum',
        type: 'text'
    }, {
        label: PartnerRole,
        fieldName: 'acmpartnerRole',
        type: 'text'
    }, {
        label: Country,
        fieldName: 'accCountry',
        type: 'text'
    }, {
        label: PhoneColumn,
        fieldName: 'accountPhoneNo',
        type: 'text'
    }, {
        label: 'Notes',
        fieldName: 'notes',
        type: 'text',
        editable: true,
    },
];
export default class PRM_tagBuilders extends LightningElement {

    label = {
        search,
        noRecords,
        validationMsg,
        NoIPAAccount
    };



    strSearchAccNameOrId = '';
    @track searchData = []; @track columns = columns;
    @api isLoaded = false;
    @track errorMsg = '';
    @track isSearchData = false;
    @track error;
    @track rowData = [];
    @track isData = true;
    @track selectedrows = [];
    @api selectedRecordLst = [];
    @track tempSelectedlst = [];
    @track finalSelAccounts;
    @track isNoRecordsReturned = false;
    @track errorInputTxt = '';
    @api recordId;
    @track finalSelDataToEport = []; //To export selected list
    isCssLoaded = false;
    handleAccountNameOrID(event) {
        this.strSearchAccNameOrId = event.detail.value;
    }
    connectedCallback() {
        this.searchData = [];
        this.isSearchData = false;
        //this.isData = false;        
        let finalList = JSON.parse(JSON.stringify(this.selectedRecordLst));
        if (this.selectedRecordLst !== null && this.selectedRecordLst !== undefined && this.selectedRecordLst.length > 0) {
            this.showDownloadButton = true;
            this.isData = true;
        }
        if (this.selectedRecordLst === null || this.selectedRecordLst === undefined || this.selectedRecordLst.length === 0) {
            this.isData = false;
        }

    }

    renderedCallback(){
        console.log('this.isCssLoaded'+this.isCssLoaded);
        if(this.isCssLoaded) 
        return
        this.isCssLoaded = true;
        loadStyle(this,CUSTOMCSS).then(()=>{
            console.log('loaded111');
        })
        .catch(error=>{
            console.log('error to load11');
        });
    }

    async toggleSteps(event) {
        // var el = this.template.querySelector('lightning-datatable');
        // //alert('---el'+el);
        // var selectedr = el.getSelectedRows();
        // // if(selectedr.length == 0 || selectedr == undefined){
        // //     alert('Select an account');
        // // }
        // // else if (selectedr.length > 0 && selectedr !== undefined) {
        // this.finalSelAccounts = JSON.parse(JSON.stringify(selectedr));
        // console.log('finalSelAccounts------>'+JSON.stringify(selectedr));
        // // alert('---finalSelAccounts '+ JSON.stringify(selectedr));
        
        var el = this.template.querySelector('lightning-datatable');
        var selectedr = el.getSelectedRows();
        console.log('selectedr--->' + JSON.stringify(selectedr));

        const updatedFields = this.template.querySelector('lightning-datatable').draftValues;;
        console.log('updatedFields---' + JSON.stringify(updatedFields));

        updatedFields.forEach(element => {
            selectedr.forEach(dr => {
                if (element.id == dr.accountId) {
                    dr.accNotes = element.notes;
                }
            });
        });

        this.finalSelAccounts = JSON.parse(JSON.stringify(selectedr));

        console.log('this.finalSelAccounts---->' + JSON.stringify(this.finalSelAccounts));

        await inserttagbuilder({ AccountIds: this.finalSelAccounts, currentbuilderId: this.recordId })
            .then(result => {

                console.log(JSON.stringify('Apex update result: ' + result));
                console.log(JSON.stringify('Apex update result:111 ' + result.message));
                if(result.message != 'Success'){
                    this.displayShowToastMessage(result.message, 'Error', 'error');
                }else{
                    this.displayShowToastMessage('Tagged Partner Successfully', 'Successful', 'success');
                }

                this.searchData = [];
                this.isSearchData = false;
                this.isLoaded = false;
                this.isNoRecordsReturned = false;
            }).catch(error => {
                this.displayShowToastMessage(JSON.stringify(error.body.message), 'Error', 'error');
                console.log('Error is ' + JSON.stringify(error));

            });
    }

    // check for account
    handleSearch() {
        this.selectedrows = [];
        this.isLoaded = !this.isLoaded;
        // console.log(typeof (this.strSearchAccNameOrId.length));
        if (!this.strSearchAccNameOrId) {
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: 'Error',
            //         message: PRM_EmptySearchInput_ErrMsg,
            //         variant: 'error',
            //     }),
            // );
            this.errorInputTxt = 'Enter something to search';
            this.searchData = [];
            this.isSearchData = false;
            this.isLoaded = false;
            this.isNoRecordsReturned = false;
            return;
        }
        if (this.strSearchAccNameOrId.length < 3 && this.strSearchAccNameOrId.length > 0 && !this.strSearchAccNameOrId.startsWith('00')) {
            // console.log('accountIdErrorMsg1 :' + accountIdErrorMsg);
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: 'Error',
            //         message: PRM_InputCharacterLimit_ErrMsg,
            //         variant: 'error',
            //     }),
            // );
            this.errorInputTxt = 'Please enter more than 3 characters';
            this.searchData = [];
            this.isSearchData = false;
            this.isLoaded = false;
            this.isNoRecordsReturned = false;
            return;
        }
        // if ((this.strSearchAccNameOrId.length != 15 || this.strSearchAccNameOrId.length != 18 || this.strSearchAccNameOrId.length > 18) && this.strSearchAccNameOrId.startsWith('00')) {
        //     // console.log('accountIdErrorMsg2 :' + accountIdErrorMsg);
        //     // this.dispatchEvent(
        //     //     new ShowToastEvent({
        //     //         title: 'Error',
        //     //         message: accountIdErrorMsg,// need to add custom labels for output msg
        //     //         variant: 'error',
        //     //     }),
        //     // );
        //     this.errorInputTxt = 'Please Enter 15 or 18 character Account Id. ';
        //     this.searchData = [];
        //     this.isSearchData = true;
        //     this.isLoaded = false;
        //     return;
        // }
        serachAccs({ accountName: this.strSearchAccNameOrId, currentbuilderId: this.recordId })
            .then(returnedResult => {
                if (returnedResult !== null && returnedResult !== undefined && returnedResult.length > 0) {
                    //result.push(returnedResult);
                    this.searchData = returnedResult;
                    this.isSearchData = true;
                    this.isLoaded = false;
                    this.selectedrows = [];
                    this.errorInputTxt = '';
                    this.isNoRecordsReturned = false;
                    return refreshApex(this.searchData);
                }
                else {
                    this.searchData = [];
                    this.isSearchData = false;
                    this.isNoRecordsReturned = true;
                    this.isLoaded = false;
                    this.errorInputTxt = '';
                }
                console.log('searchData ' + this.searchData);
                console.log('isLoaded  ' + this.isLoaded);
                // if(returnedResult == null || returnedResult == undefined || returnedResult.length == 0)
                // return refreshApex(this.searchData);
            })
            .catch(error => {
                this.error = error;
                if (this.error !== undefined || this.error !== '') {
                    console.log('CatchBlockErr', this.error);
                }
                this.isLoaded = false;
                this.searchData = [];
                this.isSearchData = false;
            });
    }


    displayShowToastMessage(errorMessage, title, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: errorMessage,
            variant: variant,
            mode: 'sticky'
        });

        this.dispatchEvent(toastEvent);

    }
}