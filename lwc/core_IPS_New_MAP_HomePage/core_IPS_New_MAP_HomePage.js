/* eslint-disable no-console */
import {
    LightningElement,
    track,
    wire
} from 'lwc';
import HideLightningHeader from '@salesforce/resourceUrl/HideLightningHeader';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
//above 2 imports are to hide page headers
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import homePageLabel from '@salesforce/label/c.Core_IPS_ProductAccessHome';
import SUPPORTORG_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.Core_Product_Organization__c';
import MAPNAME_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.Core_Name__c';
import DESC_FIELD from '@salesforce/schema/Core_IPS_MAP_PAR__c.Core_IPS_MAP_Description__c';

import isNewMapButtonVisible from '@salesforce/apex/Core_IPS_NewMapHomePageController.isNewMapButtonVisible';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord} from 'lightning/uiRecordApi';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PRODUCTACCESS_OBJECT from '@salesforce/schema/Core_IPS_MAP_PAR__c';

import getQueryResult from '@salesforce/apex/Core_IPS_NewMapHomePageController.getQueryResult';

//columns to display
const ACC_PRODUCT__COLS = [{
        label: 'MAP Name',
        fieldName: 'mapNavigationUrl', //wrapper variables to display columns
        type: 'url',
        typeAttributes: {label: {fieldName: 'mapName'},
            target: '_blank', 
        },
        cellAttributes: { class: 'slds-text-color_error slds-text-title_bold'},
        sortable: true,
    },
    {
        label: 'Access Flag',
        fieldName: 'accessFlag'
    },
    {
        label: 'Product Focus Area',
        fieldName: 'mapPFA'
        
    },
	{
        label: 'Support Org Name',
        fieldName: 'orgNavigationUrl',
        type: 'url',
        typeAttributes: {label: {fieldName: 'mapOrgName'},
            target: '_blank', 
        },
        sortable: true
        
    },
    {
        label: 'Last Modified By',
        fieldName: 'modifiedByUrl',
        type: 'url',
        typeAttributes: {label: {fieldName: 'mapModifiedBy'},
            target: '_blank', 
        },
    },
    {
        label: 'Access Record',
        fieldName: 'mapNumber'
    },  
];

export default class Core_IPS_New_MAP_HomePage extends NavigationMixin(LightningElement) {
    @track mapRecord;

    connectedCallback() {
        loadStyle(this, HideLightningHeader)
    }
    @wire(getRecord, { recordId: '$currentPageReference.attributes.recordId' })
    mapRecord;
    label = {
        homePageLabel
    };
    //fields = [MAPNAME_FIELD, DESC_FIELD, SUPPORTORG_FIELD];
    mapNameField = MAPNAME_FIELD;
    descriptionField = DESC_FIELD;
    supportOrgField = SUPPORTORG_FIELD;

    @track openmodel = false;
    @wire(getObjectInfo, { objectApiName: PRODUCTACCESS_OBJECT })
        objectInfo;

  
    createNewMap(){
        this.openmodel = true
    }
    closeModal() {
        this.openmodel = false
    }
    handleSubmit(event) {
        this.modelSpinnerOn = true;
        const fields = event.detail.fields;
        const rtis = this.objectInfo.data.recordTypeInfos;
        let mapRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'MAP');
        console.log('in submitt');
        console.log(event.detail.id);

        fields.RecordTypeId = mapRecordTypeId; //'012o0000000TPVnAAO'; // modify a field
        //this.template.querySelector('lightning-record-form').submit(fields);
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.isEditEnabled = false;
        console.log('handleSubmit called');
    }

    handleCancel() {
        this.mode = 'view';
        this.isEditEnabled = true;
        this.openmodel = false
        console.log('handlecancel called');
    }
    
    handleSuccess(event) {
        this.modelSpinnerOn = false;
        if(this.recordId === undefined || this.recordId === null) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/lightning/r/' +event.detail.id  + '/view'
                }
            },
            true // Replaces the current page in your browser history with the URL
            );
        }
    }

    handleError() {
        this.modelSpinnerOn = false;
        this.mode = 'view';
        this.isEditEnabled = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Record saving failed!',
                variant: 'error',
            }),
        );
    }

    @track recordsToDisplay = 30;
    @track isVisible = false;
    @track searchAccountText;
    @track searchProductText;
    @track searchMapName;
    @track searchOrgName;
    @track displayMapResult = [];
    //@track showMapResult = false;
    @track column = ACC_PRODUCT__COLS;
    @track enableInfiniteLoading = true;
    @track whereClause = '';
    //@track queryStr;
    //@track isQueryStrPresent = false;
    @track isMapResultPresent = false;
    @track mapRecords;
    @track spinnerOn = false;
    @track modelSpinnerOn = false;

    @wire(isNewMapButtonVisible)
    wiredRecords({
        data
    }) {
        if (data) {
            this.isVisible = data;
            console.log('this.isVisible *******:::', this.isVisible);
        }
    }

    handleSearch() {
        this.isMapResultPresent = false;
        this.mapRecords = undefined;
        this.spinnerOn = true;

        let searchQueryStr = 'SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name,Core_Product_Organization__r.Name,Core_Product_Organization__r.Core_IPS_Support_Org_Name__c,Core_Product_Organization__r.Core_Organization_Description__c,Core_Name__c,Core_Status__c,Core_Product_Organization__c, Core_Support_Org_Name__c,Core_IPS_MAP_Access_Flag__c FROM Core_IPS_MAP_PAR__c WHERE RecordType.Name =\'MAP\' ';


        //this.queryStr = 'SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name,Core_Product_Organization__r.Name,Core_Product_Organization__r.Core_IPS_Support_Org_Name__c,Core_Product_Organization__r.Core_Organization_Description__c,Core_Name__c,Core_Status__c,Core_Product_Organization__c, Core_Support_Org_Name__c,Core_IPS_MAP_Access_Flag__c';
        if (this.searchAccountText !== undefined && this.searchAccountText !== null && this.searchAccountText !== '') {
            console.log('this.searchAccountText >>>>: ', this.searchAccountText);
            let account = '\'%' + this.searchAccountText  + '%\'';
            //this.queryStr = this.queryStr + ', (SELECT id FROM MAP_Accounts__r where Core_Account__r.Name LIKE ' + account + ')';
            //this.whereClause =' And Id In(Select Core_MAP_PAR__c from Core_IPS_MAP_Account__c where Core_Account__r.Name like ' + account + ' )';
            searchQueryStr = searchQueryStr + ' AND Id IN (SELECT Core_MAP_PAR__c FROM Core_IPS_MAP_Account__c WHERE Core_Account__r.Name LIKE ' + account + ' )';
        }
        if (this.searchProductText !== undefined && this.searchProductText !== null && this.searchProductText !== '') {
            console.log('this.searchProductText >>>>: ', this.searchProductText);
            let products = '\'%' + this.searchProductText  + '%\'';
            //this.queryStr = this.queryStr + ', (SELECT id FROM MAP_Supported_Products__r where Core_Supported_Product_Name__c LIKE ' + products + ')';
            //this.whereClause = this.whereClause+ ' And Id In(Select Core_MAP_PAR__c from Core_IPS_MAP_Product__c where Core_Supported_Product_Name__c like ' + products + ' OR Core_MAP_Supported_Product__r.Core_Supported_Product_Alias__c like ' + products + ') ';
            searchQueryStr = searchQueryStr + ' AND Id IN (SELECT Core_MAP_PAR__c FROM Core_IPS_MAP_Product__c WHERE Core_Supported_Product_Name__c LIKE ' + products + ' OR Core_MAP_Supported_Product__r.Core_Supported_Product_Alias__c LIKE ' + products + ') ';
        }
        //this.queryStr = this.queryStr + ' FROM Core_IPS_MAP_PAR__c WHERE RecordType.Name =\'MAP\'' +  this.whereClause;
        //console.log('-->ranjini1'+this.queryStr);
        if (this.searchMapName !== undefined && this.searchMapName !== null && this.searchMapName !== '') {
            console.log('this.searchMapName >>>>: ', this.searchMapName);
            let mapName = '\'%' + this.searchMapName  + '%\'';
            //this.queryStr = this.queryStr + ' AND (Core_Name__c LIKE ' + mapName + ' OR Name LIKE ' + mapName + ') ';
            //this.whereClause = '';
            searchQueryStr = searchQueryStr + ' AND (Core_Name__c LIKE ' + mapName + ' OR Name LIKE ' + mapName + ') ';
        }
        if (this.searchOrgName !== undefined && this.searchOrgName !== null && this.searchOrgName !== '') {
            console.log('this.searchOrgName >>>>: ', this.searchOrgName);
            let orgName = '\'%' + this.searchOrgName  + '%\'';
            //this.queryStr = this.queryStr + ' AND (Core_Support_Org_Name__c LIKE ' + orgName + ' OR Core_Product_Organization__r.Name LIKE ' + orgName+ ') ' ;
            searchQueryStr = searchQueryStr + ' AND (Core_Support_Org_Name__c LIKE ' + orgName + ' OR Core_Product_Organization__r.Name LIKE ' + orgName+ ') ' ;
        }
        //Added for US517853:To restict PAR Hidden MAPS for internal users-Aparna

        if(this.isVisible !== undefined && this.isVisible!== null && this.isVisible === true){
            console.log('this.isVisible---->',this.isVisible);
            console.log('not displaying PAR hidden products for users apart from SOA,IT admin and Sys Admin');
            //this.queryStr = this.queryStr + 'AND Core_IPS_MAP_Access_Flag__c !=\'Par Hidden\' AND Core_IPS_MAP_Access_Flag__c !=\'\'';
            searchQueryStr = searchQueryStr + ' AND Core_IPS_MAP_Access_Flag__c !=\'Par Hidden\' AND Core_IPS_MAP_Access_Flag__c !=\'\'';
        }

        if(this.isVisible !== undefined && this.isVisible!== null && this.isVisible === false){
            console.log('this.isVisible---->',this.isVisible);
            console.log('displaying PAR hidden products for users apart from SOA,IT admin and Sys Admin');
            //this.queryStr = this.queryStr + 'AND (Core_IPS_MAP_Access_Flag__c =\'Par Hidden\' OR Core_IPS_MAP_Access_Flag__c =\'Approval Required\' OR Core_IPS_MAP_Access_Flag__c=\'Auto Approve\' OR Core_IPS_MAP_Access_Flag__c =\'\')';
            //this.whereClause = '';
            searchQueryStr = searchQueryStr + ' AND (Core_IPS_MAP_Access_Flag__c =\'Par Hidden\' OR Core_IPS_MAP_Access_Flag__c =\'Approval Required\' OR Core_IPS_MAP_Access_Flag__c=\'Auto Approve\' OR Core_IPS_MAP_Access_Flag__c =\'\')';
        }
        //this.queryStr = this.queryStr + ' ORDER BY LastModifiedDate DESC ';
        searchQueryStr =  searchQueryStr + ' ORDER BY LastModifiedDate DESC ';
        //end for US517853

        //this.isQueryStrPresent = true;

        //console.log('queryStr >>>>: ', this.queryStr);
        console.log('searchQueryStr >>>>: ', searchQueryStr);
        //getQueryResult({queryString : this.queryStr})
        getQueryResult({queryString : searchQueryStr})
            .then(data => {
                if(data) {
                    let dataWrapper = [];
                    for(let i=0;i<data.length;i++) {
                        let obj = {
                            'Id' : data[i].Id,
                            'mapName' : data[i].Core_Name__c,
                            'mapNumber' : data[i].Name,
                            'mapStatus' : data[i].Core_Status__c,
                            'accessFlag' : data[i].Core_IPS_MAP_Access_Flag__c,
                            'mapOrg' : data[i].Core_Product_Organization__r.Name,
                            'mapOrgName' : data[i].Core_Product_Organization__r.Core_IPS_Support_Org_Name__c,
                            'mapModifiedBy' : data[i].LastModifiedBy.Name,
                            'mapPFA' : data[i].Core_Product_Organization__r.Core_Organization_Description__c,
                            'mapNavigationUrl' :  '/lightning/r/' + data[i].Id + '/view',
                            'orgNavigationUrl' : '/lightning/r/' + data[i].Core_Product_Organization__r.Id + '/view',
                            'modifiedByUrl' : '/lightning/r/' + data[i].LastModifiedById + '/view'
                        };
                        dataWrapper = [...dataWrapper, obj];
                    }
                    this.mapRecords = dataWrapper;
                    this.isMapResultPresent = true;
                    this.spinnerOn = false;
                }
            })
            .catch(error => {
                console.error('Core_IPS_New_MAP_HomePage ::: Error in loading MAP records. Error : ', JSON.stringify(error));
                this.spinnerOn = false;
            })
    }

    handleClear() {
        this.searchProductText = '';
        this.searchAccountText = '';
        this.searchMapName = '';
        this.searchOrgName = '';
        console.log(this.displayMapResult.length)
        if (this.displayMapResult.length > 0) {
            //this.showMapResult = false;
            this.displayMapResult = [];
        }
        //this.queryStr = '';
        //this.isQueryStrPresent = false;
        this.mapRecords = undefined;
        this.isMapResultPresent = false;
    }

    handleSearchProductText(event) {
        this.searchProductText = event.detail.value;
    }

    handleSearchAccountText(event) {
        this.searchAccountText = event.detail.value;
    }
    handleSearchMapName(event) {
        this.searchMapName = event.detail.value;
    }
    handleSearchOrgName(event) {
        this.searchOrgName = event.detail.value;
    }
}