import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerListener, unregisterAllListeners } from 'c/core_IPS_Pubsub';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getQueryResult from '@salesforce/apex/Core_IPS_NewMapHomePageController.getQueryResult';
import getFAEAffiliatedMapAccounts from '@salesforce/apex/Core_IPS_NewMapHomePageController.getFAEAffiliatedMapAccounts';

const ACCESS_LINEITEM__COLS = [{
        label: 'Line Number',
        fieldName: 'lineItemUrl',
        type: 'url',
        typeAttributes: {label: {fieldName: 'lineItemNumber'},
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
        label: 'Supported Product',
        fieldName: 'supportedProductUrl',
        type: 'url',
        typeAttributes: {label: {fieldName: 'supportedProductName'},
            target: '_blank', 
        },
    },
    {
        label: 'Line Item Status',
        fieldName: 'lineItemStatus',
    },
    {
        label: 'Line Item Approval Status',
        fieldName: 'lineItemApprovalStatus'   
    },
    {
        label: 'Intel Product',
        fieldName: 'intelProductUrl',
        type: 'url',
        typeAttributes: {label: {fieldName: 'intelProductName'},
            target: '_blank', 
        },
    }/*,
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
    }*/
];

export default class Core_IPS_MapLineItemRelatedList extends NavigationMixin(LightningElement) {

    hideCheckboxColumn = false;
    showRowNumberColumn = false;
    enableInfiniteLoading = true;
    numAndCheckboxBothCols = false;
    normalDataTable = true;
    numberOfRowsToShow = 5;
    heightInRem = 12;
    
    lightningCardTitle = 'Product Access Line Items';

    @track dataToShow;
    @track isDataAvailable = false;
    @track columns = ACCESS_LINEITEM__COLS;
    @track mapRecordId;

    @track isCurUsrOrgAdminMember = false;

    @wire(CurrentPageReference)
        currentPageReference;

    connectedCallback() {
        console.log('Core_IPS_MapLineItemRelatedList ::: connectedCalback called');
        this.mapRecordId = this.currentPageReference.attributes.recordId;
        this.queryString = 'SELECT Id, LastModifiedDate, Name, Core_Account__c, Core_Account__r.Name, Core_Supported_Product__c, Core_Supported_Product__r.Core_Supported_Product_Name__c, Core_Status__c, Core_Intel_Product__c, Core_Intel_Product__r.Name, Core_Line_Item_Approval_Status__c  FROM Core_IPS_Map_Par_Line_Item__c WHERE Core_MAP_PAR__c = \''+ this.mapRecordId  + '\''; 
        registerListener('isCurUsrOrgAdminMemberPublish', this.isCurUsrOrgAdminMemberSubscribe, this);
        registerListener('isAddProductVisiblePublish', this.isAddProductVisibleSubscribe, this);
        //this.getRecords();
    }

    isCurUsrOrgAdminMemberSubscribe(isUsrOrgAdmin) {
        this.isCurUsrOrgAdminMember = isUsrOrgAdmin;
        console.log('Core_IPS_MapLineItemRelatedList ::: this.isCurUsrOrgAdminMember ::: ', this.isCurUsrOrgAdminMember);
    }

    isAddProductVisibleSubscribe(flag) {
        if(flag) {
        
            //this.isNotAdminUser = true;
            getFAEAffiliatedMapAccounts({
                queryString : this.queryString
            }).then(data =>{
                console.log('result ', data);
                if(data) {
                    let dataWrapper = [];
                    for(let i=0;i<data.length;i++) {
                        let obj = {
                            'Id' : data[i].Id,
                            'lineItemNumber' : data[i].Name, 
                            'lineItemUrl': '/lightning/r/' + data[i].Id + '/view',
                            'accountName' : data[i].Core_Account__r.Name,
                            'accountUrl' : '/lightning/r/' + data[i].Core_Account__c + '/view',
                            'supportedProductName' : data[i].Core_Supported_Product__r.Core_Supported_Product_Name__c,
                            'supportedProductUrl' : '/lightning/r/' + data[i].Core_Supported_Product__c + '/view',
                            'lineItemStatus' : data[i].Core_Status__c,
                            'intelProductName' : '',
                            'intelProductUrl' : '',
                            'lineItemApprovalStatus' : data[i].Core_Line_Item_Approval_Status__c
                            };
                            if(data[i].Core_Intel_Product__c !== undefined && data[i].Core_Intel_Product__c !== null && data[i].Core_Intel_Product__c !== '' ) {
                                obj.intelProductName = data[i].Core_Intel_Product__r.Name; 
                                obj.intelProductUrl = '/lightning/r/' + data[i].Core_Intel_Product__c + '/view'; 
                            }
                            dataWrapper = [...dataWrapper, obj]
                    }
                    this.dataToShow = dataWrapper;
                    this.isDataAvailable = true;
                }
            }).catch(error => {
                console.error('Core_IPS_MapLineItemRelatedList ::: Error in loading getFAEAffiliatedMapAccounts. Error : ', JSON.stringify(error));
            })
        } else {
            //this.isNotAdminUser = false;
            this.getRecords();
        }
    }

    getRecords() {
        //this.mapRecordId = this.currentPageReference.attributes.recordId;
        //this.queryString = 'SELECT Id, Name, Core_Account__c, Core_Account__r.Name, Core_Supported_Product__c, Core_Supported_Product__r.Core_Supported_Product_Name__c, Core_Status__c, Core_Intel_Product__c, Core_Intel_Product__r.Name, Core_Line_Item_Approval_Status__c  FROM Core_IPS_Map_Par_Line_Item__c WHERE Core_MAP_PAR__c = \''+ this.mapRecordId  + '\''; 
        getQueryResult({queryString : this.queryString})
            .then(data => {
                if(data) {
                    let dataWrapper = [];
                    for(let i=0;i<data.length;i++) {
                        let obj = {
                            'Id' : data[i].Id,
                            'lineItemNumber' : data[i].Name, 
                            'lineItemUrl': '/lightning/r/' + data[i].Id + '/view',
                            'accountName' : (data[i].Core_Account__r !== undefined)?data[i].Core_Account__r.Name:'',
                            'accountUrl' : (data[i].Core_Account__r !== undefined)?'/lightning/r/' + data[i].Core_Account__c + '/view':'',
                            'supportedProductName' : (data[i].Core_Supported_Product__r !== undefined)?data[i].Core_Supported_Product__r.Core_Supported_Product_Name__c:'',
                            'supportedProductUrl' : (data[i].Core_Supported_Product__r !== undefined)?'/lightning/r/' + data[i].Core_Supported_Product__c + '/view':'',
                            'lineItemStatus' : data[i].Core_Status__c,
                            'intelProductName' : '',
                            'intelProductUrl' : '',
                            'lineItemApprovalStatus' : data[i].Core_Line_Item_Approval_Status__c
                          };
                          if(data[i].Core_Intel_Product__c !== undefined && data[i].Core_Intel_Product__c !== null && data[i].Core_Intel_Product__c !== '' ) {
                              obj.intelProductName = data[i].Core_Intel_Product__r.Name; 
                              obj.intelProductUrl = '/lightning/r/' + data[i].Core_Intel_Product__c + '/view'; 
                          }
                          dataWrapper = [...dataWrapper, obj]
                    }
                    this.dataToShow = dataWrapper;
                    this.isDataAvailable = true;
                }
            })
            .catch(error => {
                console.error('Core_IPS_MapLineItemRelatedList ::: Error in loading records. Error : ', JSON.stringify(error));
            })
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
                console.error('Core_IPS_MapLineItemRelatedList ::: Error in deleting record. Error : ', JSON.stringify(error));
            });
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