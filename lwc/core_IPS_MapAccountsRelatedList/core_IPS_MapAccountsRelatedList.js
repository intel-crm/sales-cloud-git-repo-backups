import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import { fireEvent  } from 'c/core_IPS_Pubsub';
import { registerListener, unregisterAllListeners } from 'c/core_IPS_Pubsub';
import Core_IPS_MsgIfNoLineItemSelected from '@salesforce/label/c.Core_IPS_MsgIfNoLineItemSelected';
import Core_IPS_MsgIfNoProductsPresentAddOnlyAccount from '@salesforce/label/c.Core_IPS_MsgIfNoProductsPresentAddOnlyAccount';
import LINEITEM_OBJECT from '@salesforce/schema/Core_IPS_Map_Par_Line_Item__c';
import getQueryResult from '@salesforce/apex/Core_IPS_NewMapHomePageController.getQueryResult';
import createLineItems from '@salesforce/apex/Core_IPS_NewMapHomePageController.createLineItems';
import addAccountToMAP from '@salesforce/apex/Core_IPS_NewMapHomePageController.addAccountToMAP';
import getFAEAffiliatedAccounts from '@salesforce/apex/Core_IPS_NewMapHomePageController.getFAEAffiliatedAccounts';
import getFAEAffiliatedMapAccounts from '@salesforce/apex/Core_IPS_NewMapHomePageController.getFAEAffiliatedMapAccounts';

const ACCESS_ACCOUNT__COLS = [{
        label: 'MAP Account ID',
        fieldName: 'mapAccountIdUrl', 
        type: 'url',
        typeAttributes: {label: {fieldName: 'mapAccountId'},
            target: '_blank', 
        },
        sortable: true
    },
    {
        label: 'Account',
        fieldName: 'accountUrl', 
        type: 'url',
        typeAttributes: {label: {fieldName: 'accountName'},
            target: '_blank', 
        },
    },
    {
        label: 'Account Owner',
        fieldName: 'accountOwnerUrl', 
        type: 'url',
        typeAttributes: {label: {fieldName: 'accountOwnerName'},
            target: '_blank', 
        },
    },
    {
        label: 'CNDA',
        fieldName: 'cndaNumber',
    },
    {
        label: 'Last Modified By',
        fieldName: 'lastModifiedByUrl',
        type: 'url',
        typeAttributes: {label: {fieldName: 'lastModifiedBy'},
            target: '_blank', 
        },
    },
    {
        label: 'Last Modified Date',
        fieldName: 'lastModifiedDate'   
    },
    { 
        type: 'action', 
        typeAttributes: { 
            rowActions: [
                { 
                    label: 'Edit', 
                    name: 'Edit' 
                },
                { 
                    label: 'Delete', 
                    name: 'Delete' 
                }                
            ]
        } 
    }
];

const LINEITEM_COLS = [
    {
        label: 'Supported Product Name',
        fieldName: 'supportedProductName'
    },
    {
        label: 'Account Name',
        fieldName: 'accountName'
    },
    {
        label: 'Support Org Name',
        fieldName: 'supportedOrgName'
    },
    {
        label: 'Approval Type',
        fieldName: 'approvalType'
    }
];

export default class Core_IPS_MapAccountsRelatedList extends NavigationMixin(LightningElement) {

    lightningCardTitle = "Product Access: Accounts";
    hideCheckboxColumn = false;
    showRowNumberColumn = false;
    enableInfiniteLoading = true;
    numAndCheckboxBothCols = false;
    normalDataTable = true;
    numberOfRowsToShow = 5;
    heightInRem = 12;

    lookupIconName = "standard:account";
    lookupSearchFieldName = "Name";
    lookupCountQueryString;
    lookupQueryString;
    
    modaltitle = 'Product Access Line Items';
    modalHideCheckboxColumn = false;
    modalShowRowNumberColumn = true;
    modalEnableInfiniteLoading = true;
    modalNumAndCheckboxBothCols = false;
    modalNormalDataTable = false;
    modalNumberOfRowsToShow = 5;
    heightInRem = 12;

    submitterComment = '';

    msgIfNoLineItemSelected = Core_IPS_MsgIfNoLineItemSelected; 
    msgIfNoProductsPresentAddOnlyAccount = Core_IPS_MsgIfNoProductsPresentAddOnlyAccount;

    @track noteIfLineItemNotPresent;// = 'No Line Items due to there are no products present. Click save to only add product.';
    @track lineItemPreviewCols = LINEITEM_COLS;
    @track bShowModal = false;
    @track bShowModalToGetComment = false;
    @track isAddAccountBtnEnabled = true;
    @track isDataAvailable = false;
    @track dataToShow;
    @track columns = ACCESS_ACCOUNT__COLS;
    @track mapRecordId;
    @track mapProductList;
    @track draftLineItems=[];
    @track draftLineItemsToShow=[];
    @track preSelectedLineItems=[];
    @track accountIdSet = new Set();
    @track queryString;

    @track spinnerOn = false;
    @track supportOrgId;
    @track isCurUsrOrgAdminMember = false;
    @track isLookupQueryPresent = false;

    @track FAEAccounts = [];
    @track isFAEAccountsPresent = false;
    @track isNotAdminUser = false;

    @track isNextBtnDisable = true;

    @track selectedAccountName = '';

    @wire(CurrentPageReference)
        currentPageReference;
    
    @wire(getObjectInfo, { objectApiName: LINEITEM_OBJECT })
        objectInfo;        
    
    connectedCallback() {
        console.log('Core_IPS_MapAccountsRelatedList ::: connectedCalback called');
        registerListener('supportOrgIdPublish', this.supportOrgIdSubscribe, this);
        registerListener('isCurUsrOrgAdminMemberPublish', this.isCurUsrOrgAdminMemberSubscribe, this);
        registerListener('isAddProductVisiblePublish', this.isAddProductVisibleSubscribe, this);
        this.mapRecordId = this.currentPageReference.attributes.recordId;
        this.queryString = 'SELECT  Id, Name, Core_Account__c, Core_Account__r.Name, Core_Account__r.Owner.Name,Core_Account__r.OwnerId , Core_Account__r.Core_CNDA_Number__c,  LastModifiedBy.Name, LastModifiedById, LastModifiedDate FROM Core_IPS_MAP_Account__c WHERE Core_MAP_PAR__c = \''+ this.mapRecordId  + '\''; 
        this.lookupQueryString = 'SELECT Id, Name, Core_CNDA_Number__c, Core_IPS_Active__c, Owner.Name FROM Account WHERE (Core_CNDA_Number__c != \'\' OR Core_CNDA_Number__c != Null) AND Core_IPS_Active__c=true AND Name LIKE :key ORDER BY Account.Name ASC NULLS LAST LIMIT :recordLimit';
        this.lookupCountQueryString = 'SELECT count() FROM Account WHERE (Core_CNDA_Number__c != \'\' OR Core_CNDA_Number__c != Null) AND Core_IPS_Active__c=true AND Name LIKE :key ';
        this.isLookupQueryPresent = true;
        //this.getMAPAccounts();
        registerListener('prodAccessProductListPublish', this.prodAccessProductListSubscribe, this);
    }

    supportOrgIdSubscribe(supOrgId) {
        this.supportOrgId = supOrgId;
    }

    isAddProductVisibleSubscribe(flag) {
        if(flag) {
            getFAEAffiliatedAccounts()
                .then(result => {
                    this.FAEAccounts = result;
                    if(this.FAEAccounts !== undefined && this.FAEAccounts !== null && this.FAEAccounts.length >= 0) {
                        this.isFAEAccountsPresent = true;
                    }
                    this.isNotAdminUser = true;
                    getFAEAffiliatedMapAccounts({
                        queryString : this.queryString
                    }).then(data =>{
                        //console.log('result ', data);
                        if(data) {
                            let dataWrapper = [];
                            fireEvent(this.currentPageReference, 'prodAccessAccountListPublish', data);
                            for(let i=0;i<data.length;i++) {
                                let dt1 = data[i].LastModifiedDate;
                                let obj = {
                                    'Id' : data[i].Id,
                                    'mapAccountId' : data[i].Name, 
                                    'mapAccountIdUrl': '/lightning/r/' + data[i].Id + '/view', //'/' + data[i].Id,
                                    'accountName' : data[i].Core_Account__r.Name,
                                    'accountUrl' : '/lightning/r/' + data[i].Core_Account__c + '/view', //'/' + data[i].Core_Account__c,
                                    'accountId' : data[i].Core_Account__c,
                                    'accountOwnerName' : data[i].Core_Account__r.Owner.Name,
                                    'accountOwnerUrl' : '/lightning/r/' + data[i].Core_Account__r.OwnerId + '/view', //'/' + data[i].Core_Account__r.OwnerId,
                                    'cndaNumber' : data[i].Core_Account__r.Core_CNDA_Number__c,
                                    'lastModifiedBy' : data[i].LastModifiedBy.Name,
                                    'lastModifiedByUrl' : '/lightning/r/' + data[i].LastModifiedById + '/view', //'/' + data[i].LastModifiedById,
                                    'lastModifiedDate' : new Date(dt1).toLocaleString()
                                  };
                                dataWrapper = [...dataWrapper, obj];
                                this.accountIdSet.add(data[i].Core_Account__c);
                            }
                            this.dataToShow = dataWrapper;
                            this.isDataAvailable = true;
                        }
                    }).catch(error => {
                        console.error('Core_IPS_MapAccountsRelatedList ::: Error in loading getFAEAffiliatedMapAccounts. Error : ', JSON.stringify(error));
                    })
                })
                .catch(error => {
                    console.error('Core_IPS_MapAccountsRelatedList ::: Error in loading getFAEAffiliatedAccounts. Error : ', JSON.stringify(error));
                })
        } else {
            this.isNotAdminUser = false;
            this.getMAPAccounts();
        }
    }

    isCurUsrOrgAdminMemberSubscribe(isUsrOrgAdmin) {
        this.isCurUsrOrgAdminMember = isUsrOrgAdmin;
    }

    prodAccessProductListSubscribe(products) {
        this.mapProductList = products;
    }

    getMAPAccounts() {
        //this.queryString = 'SELECT  Id, Name, Core_Account__c, Core_Account__r.Name, Core_Account__r.Owner.Name,Core_Account__r.OwnerId , Core_Account__r.Core_CNDA_Number__c,  LastModifiedBy.Name, LastModifiedById, LastModifiedDate FROM Core_IPS_MAP_Account__c WHERE Core_MAP_PAR__c = \''+ this.mapRecordId  + '\''; 
        getQueryResult({queryString : this.queryString})
            .then(data => {
                if(data) {
                    let dataWrapper = [];
                    fireEvent(this.currentPageReference, 'prodAccessAccountListPublish', data);
                    for(let i=0;i<data.length;i++) {
                        let dt1 = data[i].LastModifiedDate;
                        let obj = {
                            'Id' : data[i].Id,
                            'mapAccountId' : data[i].Name, 
                            'mapAccountIdUrl': '/lightning/r/' + data[i].Id + '/view', //'/' + data[i].Id,
                            'accountName' : data[i].Core_Account__r.Name,
                            'accountUrl' : '/lightning/r/' + data[i].Core_Account__c + '/view', //'/' + data[i].Core_Account__c,
                            'accountId' : data[i].Core_Account__c,
                            'accountOwnerName' : data[i].Core_Account__r.Owner.Name,
                            'accountOwnerUrl' : '/lightning/r/' + data[i].Core_Account__r.OwnerId + '/view', //'/' + data[i].Core_Account__r.OwnerId,
                            'cndaNumber' : data[i].Core_Account__r.Core_CNDA_Number__c,
                            'lastModifiedBy' : data[i].LastModifiedBy.Name,
                            'lastModifiedByUrl' : '/lightning/r/' + data[i].LastModifiedById + '/view', //'/' + data[i].LastModifiedById,
                            'lastModifiedDate' : new Date(dt1).toLocaleString()
                          };
                        dataWrapper = [...dataWrapper, obj];
                        this.accountIdSet.add(data[i].Core_Account__c);
                    }
                    this.dataToShow = dataWrapper;
                    this.isDataAvailable = true;
                }
            })
            .catch(error => {
                console.error('Core_IPS_MapAccountsRelatedList ::: Error in loading Core_IPS_MAP_Account__c records. Error : ', JSON.stringify(error));
            })
    }

    handleAccountChange(event) {
        this.selectedAccountRecord = event.detail.record;
        if(event.detail.recordId === undefined) {
            this.isAddAccountBtnEnabled = true;
        } else {
            this.isAddAccountBtnEnabled = false;
            this.selectedAccountName = this.selectedAccountRecord.Name;
        }
    }

    handleRowActions(event) {
        let actionName = event.detail.actionName;
        /*if(this.isCurUsrOrgAdminMember) {
            actionName = event.detail.actionName;
        } else {
            actionName = '';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Insufficient Privileges to Edit/Delete the Record.',
                    variant: 'error',
                }),
            );
        }*/
        let row = event.detail.row;
        // eslint-disable-next-line default-case
        switch (actionName) {
            case 'Edit':    this.editCurrentRecord(row);
                            break;
            case 'Delete':  this.deleteCurrentRecord(row);
                            break;
        }
    }

    editCurrentRecord(row) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.Id,
                actionName: 'edit',
            },
        });
    }

    deleteCurrentRecord(row) {
        this.spinnerOn = true;
        deleteRecord(row.Id)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record is Deleted!!!',
                        variant: 'success',
                    }),
                );
                this.spinnerOn = false;
                this.reloadCurrentPage();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error While Deleting record!!!',
                        variant: 'error',
                    }),
                );
                this.spinnerOn = false;
                console.error('Core_IPS_MapAccountsRelatedList ::: Error in deleting record. Error : ', JSON.stringify(error));
            });
    }

    openModalToSeeLineItems() {
        if(this.accountIdSet !== undefined 
            && this.accountIdSet !== null 
            && this.accountIdSet.has(this.selectedAccountRecord.Id)) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Account already present in this MAP',
                        variant: 'error',
                    })
                );
        } else {
            for(let i=0;i<this.mapProductList.length;i++){
                let obj = {
                    'Id' : (i+1),
                    'supportedProductName' : this.mapProductList[i].Core_Supported_Product_Name__c,
                    'supportedProductId' : this.mapProductList[i].Core_MAP_Supported_Product__c,
                    'accountName' : this.selectedAccountRecord.Name,
                    'accountId' : this.selectedAccountRecord.Id,
                    'supportedOrgName' : this.mapProductList[i].Core_MAP_PAR__r.Core_Support_Org_Name__c,
                    'approvalType' : this.mapProductList[i].Core_MAP_Supported_Product__r.Core_Flag_Status__c,
                    'lineItemStatus' : 'ACTIVE'
                }
                if(this.isCurUsrOrgAdminMember) {
                    obj.lineItemStatus = 'ACTIVE';
                    obj.approvalType = '';
                } else {
                    if(obj.approvalType === 'Approval Required' || obj.approvalType === 'Par Hidden') {
                        obj.lineItemStatus = 'PENDING';
                    }
                }
                this.draftLineItemsToShow = [...this.draftLineItemsToShow, obj ];
                this.preSelectedLineItems = [...this.preSelectedLineItems, (i+1)];
            }
            if(this.draftLineItemsToShow=== undefined || this.draftLineItemsToShow===null || this.draftLineItemsToShow.length===0  ) {
                this.isLineItemsEmpty = true;
                this.noteIfLineItemNotPresent = this.msgIfNoProductsPresentAddOnlyAccount; //'No Line Items due to there are no products present. Click save to only add Account.';
            } else {
                this.noteIfLineItemNotPresent = this.msgIfNoLineItemSelected; //'If you not selected any Line Items here these line items will be inserted with status as INACTIVE.';
            }
            this.bShowModal = true;
        }
    }

    getSelectedRecords(event) {
        this.draftLineItems = [];
        let selectedLineItems = [];
        selectedLineItems = [...selectedLineItems, ...event.detail.selectedRows];
        let selectedSet = new Set();
        for(let j=0;j<selectedLineItems.length;j++) {
            selectedSet.add(selectedLineItems[j].Id);
        }
        //console.log('selectedSet ', selectedSet);
        for(let i=0;i<this.draftLineItemsToShow.length;i++) {
            if(!selectedSet.has(this.draftLineItemsToShow[i].Id)) {
                this.draftLineItemsToShow[i].lineItemStatus = 'INACTIVE';
                this.draftLineItems = [...this.draftLineItems, this.draftLineItemsToShow[i] ];
            } else {
                if(this.isCurUsrOrgAdminMember) {
                    this.draftLineItemsToShow[i].lineItemStatus = 'ACTIVE';
                    this.draftLineItemsToShow[i].approvalType = '';
                } else {
                    if(this.draftLineItemsToShow[i].approvalType === 'Approval Required' || this.draftLineItemsToShow[i].approvalType === 'Par Hidden') {
                        this.draftLineItemsToShow[i].lineItemStatus = 'PENDING';
                    } else {
                        if(this.draftLineItemsToShow[i].approvalType === 'Auto Approve') {
                            this.draftLineItemsToShow[i].lineItemStatus = 'ACTIVE';
                        }
                    }
                }
                this.draftLineItems = [...this.draftLineItems, this.draftLineItemsToShow[i] ];
            }
        }
        //console.log('this.draftLineItems ', JSON.stringify(this.draftLineItems));
    }

    saveRecords() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        let mapRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'MAP');
        let lineItemList=[];
        this.spinnerOn = true;
        this.bShowModal = false;
        //let accountList = [];
        let account = {
            Core_MAP_PAR__c : this.mapRecordId,
            Core_Account__c : this.selectedAccountRecord.Id,
            Core_IPS_Submitter_Comments__c: this.submitterComment
        }
        //accountList = [...accountList, account];
        if(this.draftLineItems === undefined || this.draftLineItems === null || this.draftLineItems.length === 0  ) {
            this.draftLineItems = this.draftLineItemsToShow;
        }
        for(let i=0;i<this.draftLineItems.length;i++) {
            let obj = {
                Core_Account__c : this.draftLineItems[i].accountId,
                Core_Supported_Product__c : this.draftLineItems[i].supportedProductId,
                Core_MAP_PAR__c : this.mapRecordId,
                Core_Status__c : this.draftLineItems[i].lineItemStatus,
                Core_Approval_Type__c : this.draftLineItems[i].approvalType,
                RecordTypeId : mapRecordTypeId,
                Core_Submitter_Comments__c : this.submitterComment
            } 
            lineItemList = [...lineItemList, obj];
        }
        
        addAccountToMAP({mapAccount: account})
            .then(result =>{
                if(result !== undefined && result !== null && result.Status === 'success' ) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Account Added to MAP Successfully!',
                            variant: 'success',
                        })
                    );
                    this.template.querySelector("c-core_-i-p-s_-custom-lookup").removeSelected();
                    if(lineItemList !== undefined && lineItemList !== null && lineItemList.length>0) {
                        //createMapLineItems({mapLineItems : lineItemList})
                        createLineItems({mapLineItemList : lineItemList})
                        .then(result2 =>{
                            if(result2 !== undefined && result2 !== null && result2.Status === 'success' ) {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success',
                                        message: 'Product Access Line Items created Successfully!',
                                        variant: 'success',
                                    })
                                );
                                this.spinnerOn = false;
                                this.reloadCurrentPage();
                            }
                            if(result2 !== undefined && result2 !== null && result2.Status === 'error' ) {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error',
                                        message: 'Product Access Line Items : Insertion Failed! Please Contact System Admin. ',
                                        variant: 'error',
                                    })
                                );
                                this.spinnerOn = false;
                                console.error('Core_IPS_MapAccountsRelatedList ::: Error in inserting product line item records. Error : ', JSON.stringify(result));
                            }
                        })
                        .catch(error=>{
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Product Access Line Items : Due to some reason Insertion Failed! Please Contact System Admin.',
                                    variant: 'error',
                                }),
                            );
                            this.spinnerOn = false;
                            console.error('Core_IPS_MapAccountsRelatedList ::: Error in inserting product line item records. Error : ', JSON.stringify(error));
                        })
                        
                    }
                    if(lineItemList === undefined || lineItemList === null || lineItemList.length===0) {
                        this.spinnerOn = false;
                        this.reloadCurrentPage();
                    }
                }
                if(result !== undefined && result !== null && result.Status === 'error' ) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Product Access: Account. Insertion Failed! Please Contact System Admin.',
                            variant: 'error',
                        })
                    );
                    this.spinnerOn = false;
                    console.error('Core_IPS_MapAccountsRelatedList ::: Error in inserting Account in MAP. Error : ', JSON.stringify(result));
                }
            })
            .catch(error=>{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Product Access: Account. Due to some reason Insertion Failed! Please Contact System Admin.',
                        variant: 'error',
                    }),
                );
                this.spinnerOn = false;
                console.error('Core_IPS_MapAccountsRelatedList ::: Error in inserting account in MAP. Error : ', JSON.stringify(error));
            })
        this.draftLineItemsToShow = [];
    }

    openModalToGetComments() {
        this.bShowModalToGetComment = true;
    }

    handlesubmittercomment(event) {
        this.submitterComment = event.target.value;
        //console.log('this.submitterComment ', this.submitterComment.length);
        //console.log('event.target.value ', event.target.value);
        if(this.submitterComment !== undefined && this.submitterComment !== null && this.submitterComment !== '') {
            this.isNextBtnDisable = false;
        } else {
            this.isNextBtnDisable = true;
        }
        //console.log('this.isNextBtnDisable ', this.isNextBtnDisable);
    }

    closeGetCommentsModal() {    
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModalToGetComment = false;
        this.submitterComment = '';
        this.isAddAccountBtnEnabled = false;
        this.draftLineItemsToShow = [];
    }
 
    nextHandle() {
        this.bShowModalToGetComment = false;
        this.openModalToSeeLineItems();
    }

    prevHandler() {
        this.bShowModalToGetComment = true;
        this.bShowModal = false;
        this.isAddAccountBtnEnabled = false;
        this.draftLineItemsToShow = [];
    }

    closeModal() {    
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModal = false;
        this.isNextBtnDisable = true;
        this.submitterComment = '';
        this.isAddAccountBtnEnabled = false;
        this.draftLineItemsToShow = [];
    }

    reloadCurrentPage() {
        this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/lightning/r/' + this.mapRecordId  + '/view'
                }
            },
            true // Replaces the current page in your browser history with the URL
        );
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
}