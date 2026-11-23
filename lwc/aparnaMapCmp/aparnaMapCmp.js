/* eslint-disable no-console */
import {
    LightningElement,
    track,
    wire
} from 'lwc';

import homePageLabel from '@salesforce/label/c.Core_IPS_ProductAccessHome';

import isNewMapButtonVisible from '@salesforce/apex/Core_IPS_NewMapHomePageController.isNewMapButtonVisible';

import displayMapResults from '@salesforce/apex/Core_IPS_NewMapHomePageController.displayMapResults';




//columns to display
const ACC_PRODUCT__COLS = [{
        label: 'Map Name',
        fieldName: 'mapNavigationUrl', //wrapper variables to display columns
        type: 'url',
        typeAttributes: {label: {fieldName: 'mapName'},
            target: '_blank', 
        },
        sortable: true
    },
    {
        label: 'Status',
        fieldName: 'mapStatus'
    },
    {
        label: 'Product Focus Area',
        fieldName: 'mapPFA'
        
    },
	{
        label: 'Support Org Name',
        fieldName: 'orgNavigationUrl',
        type: 'url',
        typeAttributes: {label: {fieldName: 'mapOrg'},
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
   
];

export default class Core_IPS_New_MAP_HomePage extends LightningElement {
    label = {
        homePageLabel
    };
    @track recordsToDisplay = 30;
    @track isVisible = false;
    @track searchAccountText;
    @track searchProductText;
    @track searchMapName;
    @track searchOrgName;
    @track displayMapResult = [];
    @track showMapResult = false;
    @track column = ACC_PRODUCT__COLS;
    @track enableInfiniteLoading = true;

   
    @wire(isNewMapButtonVisible)
    wiredRecords({
        data
    }) {
        if (data) {
            this.isVisible = data;
        }
    }

   

    /*
        @wire(displayMapResults, {
            productKeys: '$searchProductText',
            accountKey: '$searchAccountText'
        }) wiredDisplay({
            data
        }) {
            if (data) {
                this.displayMapResult = data;
            }
        }
        */

    handleSearch() {
        let queryStr = 'SELECT Id, Name, LastModifiedBy.Name,Core_Product_Organization__r.Name,Core_Product_Organization__r.Core_Organization_Description__c,Accountid__c,Core_Name__c,Core_Status__c,Core_Product_Organization__c, Core_Support_Org_Name__c';
        if (this.searchAccountText !== undefined && this.searchAccountText !== null && this.searchAccountText !== '') {
            console.log('this.searchAccountText >>>>: ', this.searchAccountText);
            let account = '\'%' + this.searchAccountText  + '%\'';
            queryStr = queryStr + ', (SELECT id FROM MAP_Accounts__r where Core_Account__r.Name LIKE ' + account + ')';
        }
        if (this.searchProductText !== undefined && this.searchProductText !== null && this.searchProductText !== '') {
            console.log('this.searchProductText >>>>: ', this.searchProductText);
            let products = '\'%' + this.searchProductText  + '%\'';
            queryStr = queryStr + ', (SELECT id FROM MAP_Supported_Products__r where Core_Supported_Product_Name__c LIKE ' + products + ')';
        }
        queryStr = queryStr + ' FROM Core_IPS_MAP_PAR__c WHERE RecordType.Name =\'MAP\'';
        if (this.searchMapName !== undefined && this.searchMapName !== null && this.searchMapName !== '') {
            console.log('this.searchMapName >>>>: ', this.searchMapName);
            let mapName = '\'%' + this.searchMapName  + '%\'';
            queryStr = queryStr + ' AND Core_Name__c LIKE ' + mapName;
        }
        if (this.searchOrgName !== undefined && this.searchOrgName !== null && this.searchOrgName !== '') {
            console.log('this.searchOrgName >>>>: ', this.searchOrgName);
            let orgName = '\'%' + this.searchOrgName  + '%\'';
            queryStr = queryStr + ' AND Core_Support_Org_Name__c LIKE ' + orgName;
        }

        console.log('queryStr >>>>: ', queryStr);

        displayMapResults({
            queryString : queryStr
        })
        .then(result => {
            console.log("This is result: " + JSON.stringify(result))
            if (result.length > 0) {
                this.showMapResult = true;
                this.displayMapResult = result;
            }
        })
        .catch(error => {
            console.log("THis is the error: " + error)
        })
        /*
        displayMapResults({
                productKeys: this.searchProductText,
                accountKey: this.searchAccountText
            })
            .then(result => {
                console.log("This is result: " + JSON.stringify(result))
                if (result.length > 0) {
                    this.showMapResult = true;
                    this.displayMapResult = result;
                }
            })
            .catch(error => {
                console.log("THis is the error: " + error)
            })*/
    }

    handleClear() {
        this.searchProductText = '';
        this.searchAccountText = '';
        this.searchMapName = '';
        this.searchOrgName = '';
        console.log(this.displayMapResult.length)
        if (this.displayMapResult.length > 0) {
            this.showMapResult = false;
            this.displayMapResult = [];
        }
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