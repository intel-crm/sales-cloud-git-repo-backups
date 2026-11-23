import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import { fireEvent  } from 'c/core_IPS_Pubsub';
import { registerListener, unregisterAllListeners } from 'c/core_IPS_Pubsub';
import Core_IPS_MsgIfNoLineItemSelected from '@salesforce/label/c.Core_IPS_MsgIfNoLineItemSelected';
import Core_IPS_MsgIfNoAccountsPresentAddOnlyProduct from '@salesforce/label/c.Core_IPS_MsgIfNoAccountsPresentAddOnlyProduct';
import LINEITEM_OBJECT from '@salesforce/schema/Core_IPS_Map_Par_Line_Item__c';
import createLineItems from '@salesforce/apex/Core_IPS_NewMapHomePageController.createLineItems';
import addSupportedProductToMAP from '@salesforce/apex/Core_IPS_NewMapHomePageController.addSupportedProductToMAP';
import getQueryResult from '@salesforce/apex/Core_IPS_NewMapHomePageController.getQueryResult';

const ACCESS_PRODUCT__COLS = [
    {
        label: 'MAP Product ID',
        fieldName: 'mapProductIdUrl',
        type: 'url',
        typeAttributes: {label: {fieldName: 'mapProductId'},
            target: '_blank', 
        },
        sortable: true
    },
    {
        label: 'Supported Product Name',
        fieldName: 'supportedProductName'
    },
    {
        label: 'Supported Product',
        fieldName: 'supportedProductUrl',
        type: 'url',
        typeAttributes: {label: {fieldName: 'supportedProduct'},
            target: '_blank', 
        }
        
    },
    {
        label: 'Access Flag',
        fieldName: 'accessFlag',
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

export default class Core_IPS_MapProductsRelatedList extends NavigationMixin(LightningElement) { 

    lightningCardTitle = "Product Access: Products";
    hideCheckboxColumn = false;
    showRowNumberColumn = false;
    enableInfiniteLoading = true;
    numAndCheckboxBothCols = false;
    normalDataTable = true;
    numberOfRowsToShow = 5;
    heightInRem = 12;

    lookupIconName = "standard:product";
    lookupSearchFieldName = "Core_Product__r.Name";
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

    msgIfNoLineItemSelected = Core_IPS_MsgIfNoLineItemSelected;
    msgIfNoAccountsPresentAddOnlyProduct = Core_IPS_MsgIfNoAccountsPresentAddOnlyProduct;
    
    @track noteIfLineItemNotPresent;// = 'No Line Items due to there are no accounts present. Click save to only add product.';

    @track spinnerOn = false;
    @track bShowModal = false;
    @track isAddProductBtnEnabled = true;
    @track dataToShow;
    @track enableInfiniteLoading = true;
    @track columns = ACCESS_PRODUCT__COLS;
    @track lineItemPreviewCols = LINEITEM_COLS;
    @track mapRecordId;
    @track supportOrgId;
    @track accountDataList;
    @track draftLineItems=[];
    @track draftLineItemsToShow=[];
    @track preSelectedLineItems=[];
    @track isLineItemsEmpty=false;
    @track objectInfo;
    @track isVisible=false;
    @track selectedProductRecord;
    @track fieldsToRetriveFromSearch = ' Core_Flag_Status__c, Core_Support_Org_Name__c, ';
    @track filtercondition = ' Core_EOIS__c = false and core_IPS_public_product__c = false ';
    @track queryString;
    @track isDataAvailable;

    @track lookupQueryString;
    @track isLookupQueryPresent = false;

    @track isCurUsrOrgAdminMember = false;

    @track supportedProdIdSet = new Set();

    @wire(CurrentPageReference)
        currentPageReference;
   
    @wire(getObjectInfo, { objectApiName: LINEITEM_OBJECT })
        objectInfo;

    connectedCallback() {
        registerListener('supportOrgIdPublish', this.supportOrgIdSubscribe, this);
        registerListener('isCurUsrOrgAdminMemberPublish', this.isCurUsrOrgAdminMemberPublishSubscribe, this);
        registerListener('isAddProductVisiblePublish', this.isAddProductVisibleSubscribe, this);
        registerListener('prodAccessAccountListPublish', this.prodAccessAccountListSubscribe, this);
        this.mapRecordId = this.currentPageReference.attributes.recordId;
        this.getMAPProducts();
    }

    isCurUsrOrgAdminMemberPublishSubscribe(isUsrOrgAdmin) {
        this.isCurUsrOrgAdminMember = isUsrOrgAdmin;
    }

    isAddProductVisibleSubscribe(flag) {
        this.isVisible = flag;
    }

    supportOrgIdSubscribe(supOrgId) {
        this.supportOrgId = supOrgId;
        if(this.supportOrgId !== undefined && this.supportOrgId !== null ) {
            /*Tushar -- 18/06/2026 --- Remove Core_Flag_Status__c = 'Par Hidden' as part of vulnerability fix. */
            this.lookupQueryString = 'SELECT Id, Core_Product__r.Name, Core_Supported_Product_Alias__c, Core_Product_Organization__c, Core_Flag_Status__c, Core_Support_Org_Name__c FROM Core_IPS_Supported_Product__c WHERE (Core_Product__r.Name LIKE :key OR Core_Supported_Product_Alias__c LIKE :key) AND Core_Product_Organization__c = \'' +this.supportOrgId + '\' AND Core_EOIS__c = false  AND (Core_Flag_Status__c =\'Approval Required\' OR Core_Flag_Status__c =\'Auto Approve\' ) LIMIT :recordLimit';
            this.lookupCountQueryString = 'SELECT count() FROM Core_IPS_Supported_Product__c WHERE (Core_Product__r.Name LIKE :key OR Core_Supported_Product_Alias__c LIKE :key) AND Core_Product_Organization__c = \'' +this.supportOrgId + '\' AND Core_EOIS__c = false  AND (Core_Flag_Status__c =\'Approval Required\' OR Core_Flag_Status__c =\'Auto Approve\' )';
            this.isLookupQueryPresent = true;
        }
    }

    prodAccessAccountListSubscribe(accData) {
        this.accountDataList = accData;
    }

    getMAPProducts() {
        this.mapRecordId = this.currentPageReference.attributes.recordId;
        this.queryString = 'SELECT  Id, Name, Core_Supported_Product_Name__c, Core_MAP_PAR__r.Core_Product_Organization__c,Core_MAP_PAR__r.Core_Support_Org_Name__c, Core_MAP_Supported_Product__r.Name, Core_MAP_Supported_Product__r.Core_Flag_Status__c, LastModifiedById, LastModifiedBy.Name, LastModifiedDate, Core_MAP_PAR__c, Core_MAP_Supported_Product__c FROM Core_IPS_MAP_Product__c WHERE Core_MAP_PAR__c = \''+ this.mapRecordId  + '\''; 
        getQueryResult({queryString : this.queryString})
            .then(data => {
                if(data) {
                    let dataWrapper = [];
                    fireEvent(this.currentPageReference, 'prodAccessProductListPublish', data);
                    for(let i=0;i<data.length;i++) {
                        let dt1 = data[i].LastModifiedDate;
                        let obj = {
                            'Id' : data[i].Id,
                            'mapProductId' : data[i].Name,
                            'supportedOrgId' : data[i].Core_MAP_PAR__r.Core_Product_Organization__c,
                            'supportedOrgName' :data[i].Core_MAP_PAR__r.Core_Support_Org_Name__c,
                            'supportedProductName' : data[i].Core_Supported_Product_Name__c,
                            'supportedProduct' : data[i].Core_MAP_Supported_Product__r.Name,
                            'accessFlag' : data[i].Core_MAP_Supported_Product__r.Core_Flag_Status__c,
                            'lastModifiedBy' : data[i].LastModifiedBy.Name,
                            'lastModifiedDate' : new Date(dt1).toLocaleString(),
                            'lastModifiedByUrl' : '/lightning/r/' + data[i].LastModifiedById + '/view',
                            'supportedProductUrl' : '/lightning/r/' + data[i].Core_MAP_Supported_Product__c + '/view',
                            'supportedProductId' :  data[i].Core_MAP_Supported_Product__c,
                            'mapProductIdUrl' : '/lightning/r/' + data[i].Id + '/view'
                        }
                        dataWrapper = [...dataWrapper, obj];
                        this.supportedProdIdSet.add(data[i].Core_MAP_Supported_Product__c);
                    }
                    this.dataToShow = dataWrapper;
                    this.isDataAvailable = true;
                }
            })
            .catch(error => {
                console.error('Core_IPS_MapProductsRelatedList ::: Error in loading Core_IPS_MAP_Product__c records. Error : ', JSON.stringify(error));
            })
    }
    
    handleSupportProductChange(event) {
        this.selectedProductRecord = event.detail.record;
        if(event.detail.recordId === undefined) {
            this.isAddProductBtnEnabled = true;
        } else {
            this.isAddProductBtnEnabled = false;
        }
    }

    openModalToSeeLineItems() {
        if(this.supportedProdIdSet !== undefined 
            && this.supportedProdIdSet !== null 
            && this.supportedProdIdSet.has(this.selectedProductRecord.Id)) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Product already present in this MAP',
                        variant: 'error',
                    })
                );
        } else {
            for(let i=0;i<this.accountDataList.length;i++){
                let obj = {
                    'Id' : (i+1),
                    'supportedProductName' : this.selectedProductRecord.Core_Product__r.Name,
                    'supportedProductId' : this.selectedProductRecord.Id,
                    'accountName' : this.accountDataList[i].Core_Account__r.Name,
                    'accountId' : this.accountDataList[i].Core_Account__c,
                    'supportedOrgName' : this.selectedProductRecord.Core_Support_Org_Name__c,
                    'approvalType' : this.selectedProductRecord.Core_Flag_Status__c,
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
                this.noteIfLineItemNotPresent = this.msgIfNoAccountsPresentAddOnlyProduct; //'No Line Items due to there are no accounts present. Click save to only add product.';
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
        for(let i=0;i<this.draftLineItemsToShow.length;i++) {
            if(!selectedSet.has(this.draftLineItemsToShow[i].Id)) {
                this.draftLineItemsToShow[i].lineItemStatus = 'INACTIVE';
                this.draftLineItems = [...this.draftLineItems, this.draftLineItemsToShow[i] ];
            }  else {
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
    }

    saveRecords() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        let mapRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'MAP');
        let lineItemList=[];
        this.spinnerOn = true;
        this.bShowModal = false;
        let productList = [];        
        let product = {
            Core_MAP_PAR__c : this.mapRecordId,
            Core_MAP_Supported_Product__c : this.selectedProductRecord.Id
        } 
        productList = [...productList, product];

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
                RecordTypeId : mapRecordTypeId
            } 
            lineItemList = [...lineItemList, obj];
        }

        addSupportedProductToMAP({mapProducts: productList })
            .then(result =>{
                if(result !== undefined && result !== null && result.Status === 'success' ) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Product Added to MAP Successfully!',
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
                                        message: 'Product Access Line Items : Insertion Failed! Please Contact System Admin.',
                                        variant: 'error',
                                    })
                                );
                                this.spinnerOn = false;
                                console.error('Core_IPS_MapProductsRelatedList ::: Error in inserting product line item records. Error : ', JSON.stringify(result));
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
                            console.error('Core_IPS_MapProductsRelatedList ::: Error in inserting product line item records. Error : ', JSON.stringify(error));
                        })
                        
                    }
                    if(lineItemList === undefined || lineItemList === null || lineItemList.length === 0) {
                        console.log('this.spinnerOn ', this.spinnerOn);
                        this.spinnerOn = false;
                        this.reloadCurrentPage();
                    }
                }
                if(result !== undefined && result !== null && result.Status === 'error' ) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Product Access: Product. Insertion Failed! Please Contact System Admin.',
                            variant: 'error',
                        })
                    );
                    this.spinnerOn = false;
                    console.error('Core_IPS_MapProductsRelatedList ::: Error in inserting supported product in MAP. Error : ', JSON.stringify(result));
                }
            })
            .catch(error=>{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Product Access: Product. Due to some reason Insertion Failed! Please Contact System Admin.',
                        variant: 'error',
                    }),
                );
                this.bShowModal = false;
                this.spinnerOn = false;
                console.error('Core_IPS_MapProductsRelatedList ::: Error in inserting supported product in MAP. Error : ', JSON.stringify(error));
            })
        this.draftLineItemsToShow = [];
    }
 
    closeModal() {    
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModal = false;
        this.isAddProductBtnEnabled = false;
        this.draftLineItemsToShow = [];
    }
    
    handleRowActions(event) {
        let actionName = '';
        let row = event.detail.row;
        if(this.isCurUsrOrgAdminMember) {
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
        }
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
                        title: 'Error While Deleting record!!!',
                        message: error.message,
                        variant: 'error',
                    }),
                );
                this.spinnerOn = false;
                console.error('Core_IPS_MapProductsRelatedList ::: Error in deleting record. Error : ', JSON.stringify(error));
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