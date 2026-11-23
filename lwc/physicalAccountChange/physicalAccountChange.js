import { track, wire, LightningElement, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAppData from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getAppValues';
import getAccounts from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getAccounts';
import getNodeAccounts from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getAccountNodes';
import getObjectTransactions from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getObjectTransactions';
import getToUserForPhysical from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.getToUserForPhysical';
import updateOwner from '@salesforce/apex/Core_MDF_CCP_MassOwnerUpdate.updateOwner';

//custom labels
import programLabel from '@salesforce/label/c.Core_MDF_Program';
import accountLabel from '@salesforce/label/c.Core_MDF_Channel_Partner';
import nodeaccountLabel from '@salesforce/label/c.Core_MDF_Account_Node';
import selectProgram from '@salesforce/label/c.Core_MDF_LWC_SelectProgram_Label';
import selectAccount from '@salesforce/label/c.Core_MDF_LWC_SelectAccount_Label';
import getDataLabel from '@salesforce/label/c.Core_MDF_GetData';


export default class Core_MDF_MassOwnerUpdatePOC extends LightningElement {
    massOwnerMdtList;
    isProgramApplicable = false;
    showTypeOfFromUser = false;
    showIntelAccount = false;
    disbaleNodeAccount = true;
    showGetData = false;
    @track accountValueSelected = '';
    @track nodeAccountValueSelected = '';
    @track programValueSelected = '';
    @track objectValueSelected = '';
    @track allOptionsNotSelected = true;
    @track showTransactionDetails = false;
    @track selectedIds = [];
    @track selectedIdsNew = [];
    @track valueselected;
    @track recId;
    @track showToUser = true;
    @track showFromUser = false;
    @track show = false;
    @track showAccountOptions = false;
    @track ownerSelected = [];
    @track objRecordsList;
    @track appSelected = '';
    @track messageFlagNew = false;
    @track toUserList = [];
    @track fromUserList = [];
    @track ownerSelectedNew = [];
    @track recIdNew;
    @track ownerName = [];
    @track messageFlag = false;
    @track dynamiClassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
    @track dynamiClassnamenew = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
    @track valueselectedNew;
    @track valueselectedNew1;
    @track accountName = '';
    @track showUpdateOwnershipButton = false;
    @track nodeAccountName = '';
    @track disableFromUser = false;
    @track showProgram = false;
    @api item = { data: null, errors: null };
    disableUpdateOwnershipButton = false;
    records = '';
    programOptions = [];
    accountOptions = [];
    nodeAccountOptions = [];
    objectOptions = [];
    programOpt = [];
    appOptions = [];
    selectedRowIds = [];
    newselectedRowIds = [];
    fromUserOptions = [];
    toUserOptions = []
    toUserTypeSelected;
    programLabel = programLabel;
    accountLabel = accountLabel;
    selectProgram = selectProgram;
    selectAccount = selectAccount;
    nodeaccountLabel = nodeaccountLabel;
    getDataLabel = getDataLabel;
    programSelected = '';
    accountSelected = '';
    objectSelected = '';
    nodeAccountSelected = '';
    typeOfFromUser = '';
    typeofToUser = '';
    fromUserName = '';
    toUserName = '';
    isInternalUser = false;
    isPartnerUser = false;
    disableGetData = true;
    disableAccountOptions = false;
    showToUserDropdown = true;
    disableToUserDropdown = false;
    recordsList;
    updatedRecordList = [];
    showOwnershipUpdatedRecords = false;
    accountQueryFilter = 'Core_Account_Record_Type__c=\'Intel Account\' and Core_MDF_CoMarketingActive__c=true WITH SECURITY_ENFORCED order by Name asc';
    typeOfFromUserConst = ['External User', 'Internal User', 'System User'];
    typeOfToUserConst = ['External User', 'Internal User'];
    showSpinner = true;
    
    
  
    handleTypeOfToUserFilterChange(event) {
        this.typeofToUser = event.target.value;
        this.showToUserDropdown = true;
        this.showUpdateOwnershipButton = false;
    }

   
    searchToAccount(event) {
        this.toUserName = event.target.value;
        this.LoadingTextNew = true;
        console.log('in searching to user program', this.programValueSelected);
        console.log('in searching to user object', this.objectValueSelected);
        console.log('in searching to user user', this.toUserName);
        getToUserForPhysical({userName: this.toUserName})
            .then(result => {
                console.log('result', result);
                this.toUserList = result;
                this.LoadingTextNew = false;
                this.dynamiClassnamenew = result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open slds-size_3-of-12' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
                console.log('length' + result.length);
                if (result.length == 0) {
                    this.disableUpdateOwnershipButton = true;
                    this.messageFlagNew = true;
                    console.log('no record');
                }
                else {
                    this.messageFlagNew = false;
                    this.disableUpdateOwnershipButton = false;
                    console.log('record present');
                }
            })
            .catch(error => {
                console.log('-------error-------------' + error);
                console.log(error);
            });

    }
    setSelectedRecordNew(event) {
        this.ownerSelectedNew = [];
        this.recIdNew = event.currentTarget.dataset.id;
        var selectNameNew = event.currentTarget.dataset.name;
        console.log('to user', this.recIdNew);
        console.log(selectNameNew);
        this.valueselectedNew = selectNameNew;
        let newsObjectNew = { 'recId': this.recIdNew, 'recName': selectNameNew };
        this.selectedIdsNew.push(this.recIdNew);
        console.log('selectedids', this.selectedIdsNew);
        this.ownerSelectedNew.push(newsObjectNew);
        this.dynamiClassnamenew = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
        if (this.ownerSelectedNew != [] && this.ownerSelectedNew.length > 0) {
            this.showUpdateOwnershipButton = true;
        }

    }
    
    searchfromAccount(event) {
        this.toUserName = event.target.value;
        this.LoadingTextNew = true;
        console.log('in searching to user program', this.programValueSelected);
        console.log('in searching to user object', this.objectValueSelected);
        console.log('in searching to user user', this.toUserName);
        getToUserForPhysical({userName: this.toUserName})
            .then(result => {
                console.log('result', result);
                this.fromUserList = result;
                this.LoadingTextNew = false;
                this.dynamiClassnamenew = result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open slds-size_3-of-12' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
                console.log('length' + result.length);
                if (result.length == 0) {
                    this.disableUpdateOwnershipButton = true;
                    this.messageFlagNew = true;
                    console.log('no record');
                }
                else {
                    this.messageFlagNew = false;
                    this.disableUpdateOwnershipButton = false;
                    console.log('record present');
                }
            })
            .catch(error => {
                console.log('-------error-------------' + error);
                console.log(error);
            });

    }
    setFromAccount(event) {
        this.ownerSelectedNew = [];
        this.recIdNew = event.currentTarget.dataset.id;
        var selectNameNew = event.currentTarget.dataset.name;
        console.log('to user', this.recIdNew);
        console.log(selectNameNew);
        this.valueselectedNew1 = selectNameNew;
        let newsObjectNew = { 'recId': this.recIdNew, 'recName': selectNameNew };
        this.selectedIdsNew.push(this.recIdNew);
        console.log('selectedids', this.selectedIdsNew);
        this.ownerSelectedNew.push(newsObjectNew);
        this.dynamiClassnamenew = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_3-of-12';
        if (this.ownerSelectedNew != [] && this.ownerSelectedNew.length > 0) {
            this.showUpdateOwnershipButton = true;
        }

    }
   

  /* updateOwnerOnSelectedRecords() {
        this.showSpinner = true;
        updateOwner({ selectedRowIds: this.selectedRowIds, toUser: this.recIdNew, obj: this.objectValueSelected })
            .then(result => {
                //console.log(JSON.stringify('result', result));
                var bool = result;
                console.log('bool',bool);
                if (bool == true) {
                    this.selectedRowIds.forEach(selRow => {
                        let selRowIndex = this.objRecordsList.findIndex(objRec => objRec.Id === selRow);
                        if(this.checkForUndefinedEmptyAndNull(selRowIndex) && selRowIndex !== -1) {
                            this.updatedRecordList.push(this.objRecordsList[selRowIndex]);
                        }
                    });
                    this.showOwnershipUpdatedRecords = (this.updatedRecordList !== [] && this.updatedRecordList.length > 0) ? true : false;
                    console.log('updatedRecordList',this.updatedRecordList);
                    refreshApex(this.recordsList);
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Owner Updated successfully',
                        variant: 'success',
                        mode: 'dismissible'
                    });
                    this.dispatchEvent(evt);
                }
                this.showSpinner = false;

            }).catch(error => {
                this.showSpinner = false;
                console.log('-------error-------------' + error);
                console.log(error);
            });

    } */

    checkForUndefinedEmptyAndNull(input) {
        let isNotUndefinedEmptyAndNull = false;
        if (input !== undefined && input !== null && input !== "") {
            isNotUndefinedEmptyAndNull = true;
        } else {
            isNotUndefinedEmptyAndNull = false;
        }
        return isNotUndefinedEmptyAndNull;
    }

}