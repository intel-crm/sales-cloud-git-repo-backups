import { LightningElement, api, track, wire } from 'lwc'; 
import getAccountsFromSBRResults from '@salesforce/apex/PRM_AdminRegistrationDuplicateDetails.getAccountsFromSBRResults';
import insertRecords from '@salesforce/apex/PRM_MatchingAccounts.insertRecords';
import getBlockedAccount from '@salesforce/apex/PRM_MatchingAccounts.getBlockedAccount';
import refreshRegistrationRequest from '@salesforce/apex/PRM_MatchingAccounts.refreshRegistrationRequest';
import searchAccount from '@salesforce/apex/PRM_MatchingAccounts.searchAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchCountryStateForAddress from '@salesforce/apex/PRM_AdminRegistrationDuplicateDetails.fetchCountryStateForAddress';
import country_Val from '@salesforce/schema/PRM_Registration_Request__c.PRM_Country__c';
import state_Val from '@salesforce/schema/PRM_Registration_Request__c.PRM_State_Province__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import systemAccMsg from '@salesforce/label/c.PRM_ACR_SystemAccError';
import inactiveAcc from '@salesforce/label/c.PRM_Request_Submitted_for_an_Inactive_Account';
import PRM_Secondary_Err_Msg from '@salesforce/label/c.PRM_Secondary_Err_Msg';
import PRM_BlockedAccountError from '@salesforce/label/c.PRM_BlockedAccountError';
import PRM_BlockedContactAdmins from '@salesforce/label/c.PRM_BlockedContactAdmins';
import PRM_BlockedAccAdmins from '@salesforce/label/c.PRM_BlockedAccAdmins';
import PRM_BlockedContError_IPA from '@salesforce/label/c.PRM_BlockedContError_IPA';



const fields = [country_Val, state_Val];

const columnsTable = [
    {
        label: 'Account Name',
        fieldName: 'accUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'accName' }, target: '_blank' },
        hideDefaultActions: 'true',
        sortable: 'true',
        initialWidth: 200,
        wrapText: true
    },
    { label: 'Primary Address', fieldName: 'address', hideDefaultActions: 'true', sortable: 'true', initialWidth: 250, wrapText: true },
    { label: 'Unified Id', fieldName: 'unifiedId', hideDefaultActions: 'true', sortable: 'true', initialWidth: 150, wrapText: true },
    { label: 'Unified Heirarchy', fieldName: 'unifiedHierarchy', hideDefaultActions: 'true', sortable: 'true', initialWidth: 150, wrapText: true },
    {
        label: 'Associated Unified Global',
        fieldName: 'parentAccUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'parentAccName' }, target: '_blank' },
        hideDefaultActions: 'true',
        sortable: 'true',
        initialWidth: 180,
        wrapText: true
    },
    { label: 'IPA Account', fieldName: 'ipaAccount', type: 'boolean', hideDefaultActions: 'true', sortable: 'true', initialWidth: 150, wrapText: true },
    { label: 'Biz Org Type', fieldName: 'bizOrgType', hideDefaultActions: 'true', sortable: 'true', initialWidth: 150, wrapText: true },
    { label: 'Partner Role', fieldName: 'partnerRole', hideDefaultActions: 'true', sortable: 'true', initialWidth: 150, wrapText: true },
    { label: 'Record Type', fieldName: 'recordType', hideDefaultActions: 'true', sortable: 'true', initialWidth: 150, wrapText: true },
    { label: 'GEC Block', fieldName: 'gecBlock', hideDefaultActions: 'true', sortable: 'true', initialWidth: 150, wrapText: true },
    { label: 'Account Owner', fieldName: 'accountOwner', hideDefaultActions: 'true', sortable: 'true', initialWidth: 150, wrapText: true },
    { label: 'Blocked Account from IPA', fieldName: 'blockedAccount', type: 'boolean', hideDefaultActions: 'true', sortable: 'true', initialWidth: 150, wrapText: true }];

export default class PRM_MatchingAccountList extends LightningElement {
    @api recordId;
    columnsTable = columnsTable;
    // accTable = accTable;
    @track accountList = [];
    @track accPresent = false;
    reuseBtnState = true;
    accId;
    selectedAcc;
    inputValue;
    reuseAcc = true;
    MatchingAccountList;
    showErrMsg = false;
    errMsg;
    showSelectedAcc = false;
    @track selectedAccData = [];
    noAccToShow = false;
    setpId;
    @track showSpinner = false;
    tempsetpId;
    checkPartner = false;
    @track pagedData = [];
    @track mapdata= new Map(); 
    @track mapValues=[];
    @track accforBlock;
    pageSize = 5; // Adjust the number of records per page
    currentPage = 1; // Current page
    @track totalPages = 0;
    queueId;
    accResult;
    selectedRow = [];
    addressResult;
    countryState;
    @track dupAccountDetails;
    isSystemAcc;
    isAccountInactive;
    showDupAccDetails = true;
    contPartnerRole;
    accExistingPartnerRoleACM;
    conToastMsg;
    isAdminUser=false;
    isAdminUserCont=false;
    isAdminUserAcc=false;
    validationmsg='';
    blockedAccount=false;
    blockedAccountMap=false;
    @wire(getRecord, { recordId: '$recordId', fields })
    regDetails;

    get countryVal() {
        return getFieldValue(this.regDetails.data, country_Val);
    }

    get stateVal() {
        return getFieldValue(this.regDetails.data, state_Val);
    }

    async handleSBRAccountFetch() {

        try {
            this.dupAccountDetails = await getAccountsFromSBRResults({ regRecId: this.recordId });
            console.log('blockedaccountsbr');
            
            this.accountList = this.dupAccountDetails.matchingAccList;
            console.log('this.accountList'+ JSON.stringify(this.accountList));
         
           
            if (this.accountList.length > 0) {
                this.accPresent = true;
            } else {
                this.noAccToShow = true;
            }
            // to show system account msg
            this.isSystemAcc = this.dupAccountDetails.isSystemAcc;
            if (this.isSystemAcc) {
                this.ShowToastMessages(systemAccMsg, 'sticky', 'error');
            }
//this.blockedAccountfromIPA=this.accountList.blockedAccount;
            this.isAccountInactive = this.dupAccountDetails.isAccountInactive; //Added by Vijay Agate as a part of TWC729-1727
            //Added by Vijay Agate as a part of TWC729-1727
            //When existing Contact associated to Inactive Account did self registration, showing message to activate Account
            if (this.isAccountInactive == true) {
                this.ShowToastMessages(inactiveAcc, 'sticky', 'error');
            }

            var regAccName = this.dupAccountDetails.accList;
            if (this.dupAccountDetails.isRegRequestDuplicate) {
                var msg1 = 'There are multiple requests from the user ' + regAccName.PRM_Email_ID__c + '. Search on the email Id field to view all pending requests submitted';
                this.ShowToastMessages(msg1, 'sticky', 'info');
            }

            var sfdcAccId = this.dupAccountDetails.salesforceAccountId;
            var existingAccountCon = this.dupAccountDetails.existingAccountContactEmail;
            var existingAccInfo = this.dupAccountDetails.existingAccInfo;
            var accountCon = this.dupAccountDetails.accountContactEmail;
            this.contPartnerRole = this.dupAccountDetails.existingContactPartnerRole;
            this.accExistingPartnerRoleACM = this.dupAccountDetails.accountExistingPartnerRoleACMCheck;
            this.isAdminUserCont=this.dupAccountDetails.isAdminUserCont;
            this.isAdminUserAcc=this.dupAccountDetails.isAdminUserAcc;
            if(this.isAdminUserCont){
                this.conToastMsg = PRM_BlockedContactAdmins;
                this.ShowToastMessages(this.conToastMsg, 'sticky', 'info');
            }
            if(this.isAdminUserAcc){
                this.conToastMsg = PRM_BlockedAccAdmins;
                this.ShowToastMessages(this.conToastMsg, 'sticky', 'info');
            }
            if (sfdcAccId && existingAccountCon) {
                var e = existingAccountCon.split(';');
                var existingAccountName = e[0];
                var newContactEmail = e[1];
                var existingPartnerRole = e[2];
                if (existingAccountName && newContactEmail) {
                    var msg;
                    console.log('Existing partner role:' + existingPartnerRole);

                    if (existingPartnerRole == 'true') {
                        console.log('here11--->');
                        msg = PRM_Secondary_Err_Msg;
                    } else {
                        console.log('here12--->');
                        msg = 'The user ' + newContactEmail + ' has requested to be associated with an existing Account ' + existingAccountName;
                    }

                    this.ShowToastMessages(msg, 'sticky', 'info');
                }
            }

            if (accountCon) {
                var e = accountCon.split(';');
                var accountName = e[1];
                var contactEmail = e[0];
                if (accountName && contactEmail) {
                    //Duplicate contact is an IPA Contact
                    if (this.contPartnerRole) {
                        //This contact is already part of the IPA Account - '<Account Name>' for the '<Partner Role>' Role
                        var msg = 'This contact is already part of the IPA Account - ' + accountName + '\n';
                        msg += 'for ' + this.contPartnerRole + ' role.';

                        this.ShowToastMessages(msg, 'sticky', 'info');
                    } else {
                        //DE87425 Changes
                        if (this.accExistingPartnerRoleACM) {
                            this.conToastMsg = PRM_Secondary_Err_Msg;
                        } else {
                            this.conToastMsg = 'The user ' + contactEmail + ' is already associated with ' + accountName + '.\n';
                            this.conToastMsg += 'Approve the Request to approve IPA program request for ' + accountName + '.';
                        }
                        this.ShowToastMessages(this.conToastMsg, 'sticky', 'info');
                    }
                }
            }

            if (this.dupAccountDetails.isMatchingContact) {
                this.showDupAccDetails = false;
            }
            
        } catch (error) {
            this.ShowToastMessages('Error Occurred. Please contact your System Administrator.', 'dismissal', 'error');
            console.log('error-->' + error);
        }

    }

    async connectedCallback() {
        console.log(' blockedAccountfromIPA:');
        await this.handleSBRAccountFetch();
        this.totalPages = this.getTotalPages();
        this.updatePagedData();
    }

    handleReuseAccount() {
        this.showErrMsg = false;
        this.checkValidId(this.inputValue);
    }

    handleSelectedAcc() {
            this.reuseAccount(this.selectedRow[0].accId);
        
       
    }

    handleRowSelection(event) {
        this.selectedRow = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.reuseAcc = false;
    }

    handleInputChange(event) {
        console.log('event.target.value-->' + event.target.value);
        this.inputValue = event.target.value;
        this.reuseBtnState = false;
    }

    get conditionalStyle() {
        // Return the conditional CSS class based on hideApprove value
        return this.hideApprove ? 'disabled-button' : '';
    }

    async checkValidId(accId) {
        this.showSpinner = true;
        this.accResult = await searchAccount({ accntId: accId })
      //  this.blockedAccount = await getBlockedAccount({ accntId: accId })
        this.MatchingAccountList = this.accResult.accountList;
        if (this.accResult.errorMsg !== '') {
            this.errMsg = this.accResult.errorMsg;
            this.showErrMsg = true;
        }
        if (this.accResult.accountList !== null && this.accResult.accountList !== undefined) {
            //get the country and state value
            try{
                this.addressResult = await fetchCountryStateForAddress({ country: this.MatchingAccountList.BillingCountry, state: this.MatchingAccountList.BillingState });
            }catch (error) {
                this.ShowToastMessages('Error Occurred. Please contact your System Administrator.', 'dismissal', 'error');
                console.log('error-->' + error);
            }

            //get full address
            var fullAddress = '';
            if (this.MatchingAccountList.BillingStreet != null && this.MatchingAccountList.BillingStreet != undefined) {
                fullAddress += this.MatchingAccountList.BillingStreet;
            }
            if (this.MatchingAccountList.BillingCity != null && this.MatchingAccountList.BillingCity != undefined) {
                fullAddress += ', ' + this.MatchingAccountList.BillingCity;
            }
            if (this.addressResult.state != null && this.addressResult.state != undefined) {
                fullAddress += ', ' + this.addressResult.state;
            }
            if (this.addressResult.country != null && this.addressResult.country != undefined) {
                fullAddress += ', ' + this.addressResult.country;
            }
            if (this.MatchingAccountList.BillingPostalCode != null && this.MatchingAccountList.BillingPostalCode != undefined) {
                fullAddress += ', ' + this.MatchingAccountList.BillingPostalCode;
            }

            var parentUrl = '';
            //TWC729-7054 - Nandana - commented as part of removal of Core_Unified_Global_Customer__c
            /*if (this.MatchingAccountList.Core_Unified_Global_Customer__c != null) {
                parentUrl = '/' + this.MatchingAccountList.Core_Unified_Global_Customer__c;
            }*/
           //TWC729-7054 - Nandana - new logic as part of removal of Core_Unified_Global_Customer__c
            if (this.accResult.parentAccId != null) {
                parentUrl = '/' + this.accResult.parentAccId;
            }


            // Flatten the data before setting it
            const flattenedData = {
                Id: this.MatchingAccountList.Id,
                accName: this.MatchingAccountList.Name,
                ipaAccount: this.MatchingAccountList.Core_Intel_Partner_Alliance_PartnerGroup__c,
                partnerRole: this.MatchingAccountList.Core_IPA_Partner_Role__c,
                bizOrgType: this.MatchingAccountList.Core_Account_Type__c,
                accountOwner: this.MatchingAccountList.Owner.Name,
                OwnerId: this.MatchingAccountList.Owner.Id,
                accUrl: '/' + this.MatchingAccountList.Id,
                address: fullAddress,
                unifiedId: this.MatchingAccountList.Core_Business_Party_Id__c,
                unifiedHierarchy: this.MatchingAccountList.Unified_Hierarchy_View__c,
                recordType: this.MatchingAccountList.RecordType.Name,
                gecBlock: this.MatchingAccountList.Core_Export_Compliance_Block__c,
                parentAccName: this.MatchingAccountList.Core_Unified_Global_Customer_Name__c,
                parentAccUrl: parentUrl,
                blockedAccount : this.accResult.blockedAccount
            }
            this.selectedAccData = [flattenedData];
            this.showSelectedAcc = true;
            this.accPresent = false;
            this.noAccToShow = false;
        }
        this.showSpinner = false;
       console.log('this.blockedAccount'+this.blockedAccount);
       console.log(' this.selectedAccData '+ JSON.stringify(this.selectedAccData ));
      // console.log('this.blockedAccountfromIPA'+JSON.stringify(blockedAccountfromIPA));
     this.blockedAccount= this.accResult.blockedAccount;
    }
    // async  getBlockedAccountMap(accId) {
    //     try {
    //         // Call the Apex method
    //         const result = await getBlockedAccount({ accntId: accId });
            
    //         // Convert the result (which is an object) to a Map
    //         this.mapdata = new Map(Object.entries(result));
    //         this.mapValues = Array.from(this.mapData.values()); // Extracting values into an array
    //         // for (let i = 0; i < mapValues.length; i++) {
    //         //     if(this.mapValues[i].includes(true)){
    //         //         this.blockedAccount=true;
    //         //     }
    //         // }
    //         const requiredData = true; // The data you're checking for
    //         this.blockedAccount = this.mapdata.has(this.getKeyFromValue(requiredData));
    //         console.log(' this.blockedAccount'+ this.blockedAccount);
    //        // console.log('Accounts blockedAccount:', this.blockedAccount);
    //         return blockedAccount;
    //     } catch (err) {
    //         this.error = err;
    //         console.error('Error fetching accounts map:', this.error);
    //         return null;
    //     }
    // }

    getKeyFromValue(value) {
        for (let [key, val] of this.mapdata) {
            if (val === value) {
                return key;
            }
        }
        return null; // Return null if the value is not found
    }

    async reuseAccount(accId) {
        //this.accforBlock=this.accId;
        const result = await getBlockedAccount({ accntId: accId });  
        // Convert the result (which is an object) to a Map
        this.mapdata = new Map(Object.entries(result));
        const requiredData = true; // The data you're checking for
        this.blockedAccount = this.mapdata.has(this.getKeyFromValue(requiredData));
        console.log(' this.blockedAccount'+ this.blockedAccount);
           // console.log('Accounts blockedAccount:', this.blockedAccount);
        console.log('accforBlock blocked'+accId);
        console.log('accforBlock blocked'+this.accId);
      console.log('value blocked'+ this.blockedAccount);
        if( this.blockedAccount){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: PRM_BlockedAccountError,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.showSpinner = false;
        }else{
        this.showSpinner = true;
        this.tempsetpId = await insertRecords({ regRequestId: this.recordId, AccountId: accId, recordId: this.recordId });
        this.showSpinner = false;
        if (this.tempsetpId !== null && this.tempsetpId !== '' && this.tempsetpId !== undefined) {
            window.location.href = '/' + this.recordId;
        }
    }
    }
    handleOnClose() {
        this.showSelectedAcc = false;
        this.accPresent = true;
        this.reuseAcc = true;
        this.unselectData();
    }

    async handleOnConfirm() {
        const selectedRecordId = this.selectedAccData[0].Id;
        if(this.blockedAccount){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: PRM_BlockedAccountError,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.showSpinner = false;
        }else{this.showSpinner = true;
        
            this.setpId = await insertRecords({ regRequestId: this.recordId, AccountId: selectedRecordId, recordId: this.recordId });
            this.showSpinner = false;
            if (this.setpId !== null && this.setpId !== '' && this.setpId !== undefined) {
                window.location.href = '/' + this.recordId;
            }}
        
    }

    async handleRefresh() {
        try {
            this.showSpinner = true;
            console.log(this.countryVal);
            console.log(this.stateVal);
            // Fetch country and state
            this.countryState = await fetchCountryStateForAddress({ country: this.countryVal, state: this.stateVal });
            console.log('this.countryState-->' + JSON.stringify(this.countryState));
            // Refresh registration request
            await refreshRegistrationRequest({
                recordId: this.recordId,
                checkExistingPartnerRole: this.checkPartner,
                country: this.countryState.country,
                state: this.countryState.state
            })
                .then((result) => {
                    window.location.reload();
                })
                .catch((error) => {
                    this.handleRefreshError(error);
                    console.log('refresh error-->' + error);
                });
        } catch (error) {
            this.handleRefreshError(error);
            console.log('refresh error-->' + error);
        }
    }

    handleRefreshError(error) {
        this.showSpinner = false; // Reset isLoading on error
        this.ShowToastMessages('Error Occurred While refereshing', 'dismissal', 'error');
    }

    handleFirst() {
        this.currentPage = 1;
        this.updatePagedData();
        this.reuseAcc = true;
        this.unselectData();
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updatePagedData();
        }
        this.reuseAcc = true;
        this.unselectData();
    }

    handleNext() {
        if (this.currentPage < this.getTotalPages()) {
            this.currentPage += 1;
            this.updatePagedData();
        }
        this.reuseAcc = true;
        this.unselectData();
    }

    handleLast() {
        this.currentPage = this.getTotalPages();
        this.updatePagedData();
        this.reuseAcc = true;
        this.unselectData();
    }

    updatePagedData() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        this.pagedData = this.accountList.slice(start, end);
        //this.pagedData =[flattenedData1].slice(start, end);
        console.log('this.accountList'+JSON.stringify(this.accountList));
        console.log('this.columnsTable'+JSON.stringify(this.columnsTable));
        console.log('this.pagedData'+JSON.stringify(this.pagedData));
        
    }

    unselectData() {
        const datatable = this.template.querySelector('lightning-datatable');
        if (datatable) {
            datatable.selectedRows = [];
        }
    }

    getTotalPages() {
        return Math.ceil(this.accountList.length / this.pageSize);
    }

    get isOnFirstPage() {
        return this.currentPage === 1;
    }

    get isOnLastPage() {
        return this.currentPage === this.totalPages;
    }

    get pageDetails() {
        return `Page ${this.currentPage} of ${this.totalPages}`;
    }

    //to show ToastMessages 
    ShowToastMessages(msg, mode, varient) {
        const event = new ShowToastEvent({
            message: msg,
            mode: mode,
            variant: varient
        });
        this.dispatchEvent(event);
    }

}