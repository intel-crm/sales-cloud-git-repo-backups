import { LightningElement, wire,track,api } from 'lwc';
import {   NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from '@salesforce/apex';
import searchProducts from '@salesforce/apex/CRM_VBS_SOAR_Controller.searchProducts';
import insertSoarProdsData from '@salesforce/apex/CRM_VBS_SOAR_Controller.insertSoarProdsData';
import fetchRecords from '@salesforce/apex/CRM_VBS_SOAR_Controller.fetchRecords';

const columns = [
    { label: 'Product Name',initialWidth: 550, fieldName: 'entryURL', type: 'url', sortable: true, typeAttributes: { label:{fieldName: 'entryName'}, target: '_blank'} },
    { label: 'List Price', fieldName: 'UnitPrice', type: 'currency', sortable: true, cellAttributes: { alignment: 'left' },initialWidth: 120 },
    { label: 'Available for New Designs', fieldName: 'Core_Avail_for_New_Designs__c',type: 'boolean', sortable: true, initialWidth: 130 },
    { label: 'Intel vPro Platform Eligibility', fieldName: 'Core_Intel_vPro_Platform_Eligibility__c',type: 'boolean',sortable: true, initialWidth: 155 },
    { label: 'OPN', fieldName: 'Core_OPN__c',type: 'text',sortable: true, initialWidth: 200 },
    { label: 'Active (Product)', fieldName: 'IsActive', type: 'boolean',sortable: true, initialWidth: 130 },
    { label: 'Sales Visible Flag', fieldName: 'Core_Sales_Visible_Flag__c',type: 'boolean',sortable: true,initialWidth: 130 },
];

export default class Crm_VBS_SOAR_AddProducts extends NavigationMixin(LightningElement) {

soarId;
@api recordId;
@track spinner=false;
@track showLoading=true;
showProductModal = true;
showQuantityModal = false;
disableBool = true;
@track productData = [];
productColumns = columns;
mapRecord=[];
rowCount=0;
blankRow = [];
itemColor = ['#0176d3','#181818'];
//-------removeRow----------
keyIndex = 0;
selectedRows = [{
            id: 0
        }];
//-------onchangefieldsvalue-------        
quantity;
totalprice;
vendor;
wip;
//--------lazyloading----------
totalNumberOfRows = 0; // stop the infinite load after this threshold count
rowLimit =50;
targetFetchDatatable; // capture the loadmore event to fetch data and stop infinite loading
lastId = '';
//--------search---------------
searchKey='';
filteredData = [];
delayTimeout;// Used for debouncing the search input
@track hasData=true;
ignoreMoreData=false;
lastSearchId = '';
targetDatatable; // capture the loadmore event to fetch data and stop infinite loading
//--------SortTable------------
defaultSortDirection = 'asc';
sortDirection = 'asc';
sortedBy;
//-------Errors-----------------
error;
errorMessageToDisplay='';
hasErrors=false;
rowNumbers=[];
rowSelerror='';
fieldError='';
//-------BackSelectionRows-------
@track preselectedRows=[];
@track containerPreSel=[];
//-------showBackToResultsButton---
showBackToResultsButton=false;
containerData=[];
//--------customToast-------
showErrorToast= false;
errorList=[];

    connectedCallback() {
        // Get the Opportunity Id from the record page context
        this.spinner=true;
        setTimeout(() => {
            this.soarId = this.recordId;}, 
            5);
        console.log("CC "+this.soarId+this.recordId);
        this.loadMoreData();
    }
   
    handleSearch(event){
        this.searchKey = event.target.value;
        console.log('searchKey@@@',this.searchKey);
        if(this.searchKey.length>2 && event.keyCode === 13){
            this.spinner=true;
            this.debounceFilter();  // Debounce to delay filtering for better performance
        }
        else if(this.searchKey.length == 0){
            this.productData=[];
            this.lastSearchId='';
            this.lastId='';
            this.preselectedRows = this.containerPreSel;
            console.log('this.preselectedRows',JSON.stringify(this.preselectedRows));
            this.hasData = !this.hasData;
            this.loadMoreData();
        }
    }
    // Debouncing function to delay filter invocation
    debounceFilter() {
        clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            console.log('debounceFilter');
            this.filterData();
        }, 600);
    }
    // Filtering function based on the search term
    filterData() {
        return searchProducts({limitSize: this.rowLimit, recId: this.lastSearchId, searchKey: this.searchKey})
          .then((data) => {
              if (data && data.entrys.length > 0) {
              this.totalNumberOfRows = data.totalRecords;
              console.log('fd',this.totalNumberOfRows,data.entrys.length);
              console.log('fd pd name',this.productData[0].Name.toLowerCase(), this.productData[0].Name.toLowerCase().includes(this.searchKey.toLowerCase()));
              let newData = data.entrys.map(product => (
                { 
                Id: product.Product2.Id,
                Name: product.Product2.Name,
                UnitPrice: product.UnitPrice,
                Core_Avail_for_New_Designs__c: product.Product2.Core_Avail_for_New_Designs__c,
                Core_Intel_vPro_Platform_Eligibility__c: product.Product2.Core_Intel_vPro_Platform_Eligibility__c,
                Core_OPN__c: product.Product2.Core_OPN__c, 
                IsActive: product.Product2.IsActive,
                Core_Sales_Visible_Flag__c: product.Product2.Core_Sales_Visible_Flag__c,
                entryURL: '/lightning/r/' + product.Id + '/view',
                entryName: product.Name
                })); 
                if(this.productData[0].Name.toLowerCase().includes(this.searchKey.toLowerCase())){
                   console.log('fd old',this.productData);
                   this.productData = [...this.productData, ...newData];
                }
                else{
                    this.productData = [...newData];
                    console.log('fd new',this.productData);
                }
                console.log('fd productData',this.productData);
                this.error = undefined;
                this.hasData=true;
                this.spinner=false;
                if (this.targetDatatable && this.productData.length >= this.totalNumberOfRows) {
                    this.targetDatatable.enableInfiniteLoading = false;
                }
                //Disable a spinner to signal that data has been loaded
                if (this.targetDatatable) {
                    this.targetDatatable.isLoading = false;
                }
              }
               else if(!(this.productData.length >= this.totalNumberOfRows)){
                    this.hasData=false;
                }
          })
          .catch((error) => {
            console.error('Error fetching more search records:', error);
            const evnt = new ShowToastEvent({
                    title : error.statusText +' !!',
                    message : error.body.exceptionType +'::'+ error.body.stackTrace,
                    variant : 'Error',
                    mode : 'dismissable'
                });
                this.dispatchEvent(evnt);
          })
          .finally(() => {
            this.spinner = false;
          });
    }

    loadMoreData() {
         return fetchRecords({limitSize: this.rowLimit, recId: this.lastId})
          .then((data) => {
              this.totalNumberOfRows = data.totalRecords;
              let newData = data.entrys.map(product => (
                { 
                Id: product.Product2.Id,
                Name: product.Product2.Name,
                UnitPrice: product.UnitPrice,
                Core_Avail_for_New_Designs__c: product.Product2.Core_Avail_for_New_Designs__c,
                Core_Intel_vPro_Platform_Eligibility__c: product.Product2.Core_Intel_vPro_Platform_Eligibility__c,
                Core_OPN__c: product.Product2.Core_OPN__c, 
                IsActive: product.Product2.IsActive,
                Core_Sales_Visible_Flag__c: product.Product2.Core_Sales_Visible_Flag__c,
                entryURL: '/lightning/r/' + product.Id + '/view',
                entryName: product.Name
                }));
                this.hasData=true; 
                this.preselectedRows = this.preselectedRows;
                console.log('200 this.preselectedRows',JSON.stringify(this.preselectedRows));
                this.productData = [...this.productData, ...newData];
                console.log('loadmoredata productData',this.productData);
                this.error = undefined;
                this.spinner=false;
                //stop scrolling when last data get captured
                if (this.targetFetchDatatable && this.productData.length >= this.totalNumberOfRows) {
                    this.targetFetchDatatable.enableInfiniteLoading = false;
                }
                //Disable a spinner to signal that data has been loaded
                if (this.targetFetchDatatable) {
                    this.targetFetchDatatable.isLoading = false;
                }
                
          }) 
          .catch((error) => {
                this.error = error;
                this.productData = undefined;
                console.error('error : ' + JSON.stringify(this.error));
                const evnt = new ShowToastEvent({
                    title : this.error.statusText +' !!',
                    message : this.error.body.exceptionType +'::'+ this.error.body.stackTrace,
                    variant : 'Error',
                    mode : 'dismissable'
                });
                this.dispatchEvent(evnt);
          });
    }
    loadMoreDataHandler(event) {
        if(this.searchKey==='' && !this.ignoreMoreData)
        {
        console.log('--ld searchKey--',this.searchKey);
        let datasize = this.productData.length;
        console.log('--ld datasize--',datasize);
        this.lastId = this.productData[datasize - 1].entryName;
        console.log('--ld lastId----'+this.lastId);
        const { target } = event;
        target.isLoading = true;
        this.targetFetchDatatable = event.target;
        this.loadMoreData()
            .then(()=> {
                target.isLoading = false;
            });  
        }
        else if(this.searchKey!=='' ) {
            console.log('--fd searchKey--',this.searchKey);
           let datasize = this.productData.length;
           console.log('--fd datasize--',datasize);
           this.lastSearchId = this.productData[datasize - 1].entryName;
           console.log('--fd lastSearchId----'+this.lastSearchId);
           const { target } = event;
           //target.isLoading = true;
           this.targetDatatable = event.target;
           if (this.targetDatatable && this.productData.length >= this.totalNumberOfRows) {
               target.isLoading = false;
                this.targetDatatable.enableInfiniteLoading = false;
                this.targetDatatable.isLoading = false;
           }
           else{
             target.isLoading = true;  
             this.filterData()
               .then(()=> {
                    target.isLoading = false;
                }); 
            }
        }
    }
    handleAddProduct() {
        this.showProductModal = true;
    }

    closeProductModal() {
        this.showProductModal = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'CRM_VBS_SOAR__c',
                actionName: 'view'
            },
        });
        eval("$A.get('e.force:refreshView').fire();");
    }
    closeQuantityModal() {
        this.showQuantityModal = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.soarId,
                objectApiName: 'CRM_VBS_SOAR__c',
                actionName: 'view'
            },
        });
        eval("$A.get('e.force:refreshView').fire();");
    }
    showSpinner() {
        this.showLoading = true;
        this.showQuantityModalPopup();
    }
    showQuantityModalPopup() {
        console.log('showQuantityModalPopup!!');
        this.showProductModal = false;
        this.showQuantityModal = true;
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('selectedRecords',selectedRecords);
        if(selectedRecords.length > 0){
            selectedRecords.forEach(currentItem => {
                this.mapRecord.push({ Id: ++this.keyIndex, key:currentItem.Id, value: currentItem.UnitPrice, Name: currentItem.Name, ErrorField: false, ErrorMsg: ''});
        }); 
        }        
        console.log('mapRecord::::'+JSON.stringify(this.mapRecord));
        this.blankRow=this.mapRecord;
        console.log('blankRow::::'+JSON.stringify(this.blankRow));
        clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.showLoading = false;
        }, selectedRecords.length*350);
    }
    showProductModalPopup(){
        var selectedIds = [];
        for(var i=0; i<this.mapRecord.length;i++){
          selectedIds.push(this.mapRecord[i].key);
        }
        this.preselectedRows=selectedIds;
        console.log('back ',this.preselectedRows);
        this.showProductModal = true;
        this.showQuantityModal = false;
        this.mapRecord=[];
        this.blankRow=[];
        //this.rowCount=0;
        //this.disableBool = true;
        this.hasErrors = false;
        this.fieldError= '';
        this.keyIndex = 0;
    }
    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        this.rowCount=this.selectedRows.length;
        if(this.searchKey.length>0){
            var selectedIds = [];
            for(var i=0; i<this.rowCount;i++){
                selectedIds.push(this.selectedRows[i].Id);
            }
           console.log('selectedIds',selectedIds); 
        }
        this.containerPreSel=selectedIds;
        console.log('this.containerPreSel',this.containerPreSel);
        console.log('rc',this.rowCount, this.selectedRows);
        if ( this.rowCount > 0 && this.rowCount<50) {
            this.disableBool = false;
            this.template.querySelector('div.itemColor').style.setProperty('--itemColor', this.itemColor[0]);
            this.rowSelerror=''; 
        } 
        else if (this.rowCount == 50) {
            this.disableBool = false;
            this.template.querySelector('div.itemColor').style.setProperty('--itemColor', this.itemColor[0]);
            this.rowSelerror='You can add only 50 items at a time. To add more, first finish up with these items.';
        }
        else {
            this.disableBool = true; 
            this.template.querySelector('div.itemColor').style.setProperty('--itemColor', this.itemColor[1]); 
            this.rowSelerror='';      
        }
    }   
    handleQuantityChange(event) {
        console.log('event',event.target.value);
        let value = event.target.value;
        const eventName = event.target.name;
        console.log('eventName',eventName);
        let blankRow = this.mapRecord;
        if (value%1 !== 0) {
            console.log('no integer; decimal present');
            this.hasErrors=true;
            blankRow[eventName].ErrorField=true;
            blankRow[eventName].Quantity = event.target.value;
            blankRow[eventName].ErrorMsg='Enter whole numbers.';
        }
        else{
            console.log('yes only integer');
            this.hasErrors=false;
            blankRow[eventName].ErrorMsg='';
            blankRow[eventName].Quantity = event.target.value;
            blankRow[eventName].ErrorField=false;
        }
        this.mapRecord = blankRow;
    }
    handleTPChange(event) {
        console.log('event',event.target.value);
        this.hasErrors=false;
        const eventName = event.target.name;
        let blankRow = this.mapRecord;
        console.log('eventName',eventName);
        blankRow[eventName].TP = event.target.value;
        this.mapRecord = blankRow;
    }
    handlePriceChange(event) {
        console.log('event',event.target.value);
        const eventName = event.target.name;
        let blankRow = this.mapRecord;
        console.log('eventName',eventName);
        blankRow[eventName].value = event.target.value;
        this.mapRecord = blankRow;
    }
    handleVendorChange(event) {
        console.log('event',event.target.value);
        const eventName = event.target.name;
        let blankRow = this.mapRecord;
        console.log('eventName',eventName);
        blankRow[eventName].Vendor = event.target.value;
        this.mapRecord = blankRow;
    }
    handleWIPChange(event) {
        console.log('event',event.target.value);
        const eventName = event.target.name;
        let blankRow = this.mapRecord;
        console.log('eventName',eventName);
        blankRow[eventName].WIP = event.target.value;
        this.mapRecord = blankRow;
    }
    saveData(){
        let blankRow = this.mapRecord; //mapRecord
        this.showLoading=true;
        this.hasErrors=false;
        let soarProdDataList = [];
        let soarProdIdList = [];
        //if(this.validateFields())&& blankRow[i].TP !== undefined {
        for(let i = 0; i < blankRow.length; i++){
            if(blankRow[i].Quantity !== undefined && blankRow[i].Quantity !== ''){
                this.mapRecord[i].ErrorField=false;
                let spData = new Object();
                spData.CRM_VBS_SOAR__c =                  this.soarId;
                spData.CRM_VBS_Quantity__c =              blankRow[i].Quantity;
                spData.CRM_VBS_Total_Price__c =           blankRow[i].TP;
                spData.CRM_VBS_UnitPrice__c=              blankRow[i].value;
                spData.CRM_VBS_Vendor__c=                 blankRow[i].Vendor;
                spData.CRM_VBS_Write_In_Product_Name__c = blankRow[i].WIP;
                spData.CRM_VBS_Product__c=                blankRow[i].key;
                soarProdDataList.push(spData);
                soarProdIdList.push(spData.CRM_VBS_Product__c);
            }
            else{
                this.mapRecord[i].ErrorField=true;
            }
        }
        console.log('blankRow',blankRow);
        console.log('soarProdDataList',soarProdDataList);
        if(soarProdDataList.length > 0 && soarProdDataList.length===blankRow.length)
        {
            insertSoarProdsData({soarProdDataString: JSON.stringify(soarProdDataList) , soarProdIds: soarProdIdList , soarId: this.soarId})
            .then(result => {
                if(result.hardStopList== undefined || result.hardStopList.length == 0) {
                    this.blankRow = []; 
                    this.hasErrors=false;
                    this.showLoading=false;
                    this.closeQuantityModal();
                    const evt = new ShowToastEvent({
                             title: soarProdDataList.length +" SOAR Product Record was updated",
                             variant: "success"
                            });
                    this.dispatchEvent(evt);
                    eval("$A.get('e.force:refreshView').fire();");
                }
                else{
                    console.log('result',result);
                    console.log('result.hardStopList',result.hardStopList);
                    this.rowNumbers=result.rowNumbers;
                    console.log('450 this.rowNumbers',this.rowNumbers);
                    for(let i = 0; i < this.mapRecord.length; i++){
                        if(this.rowNumbers.includes(this.mapRecord[i].Id)){
                            this.mapRecord[i].ErrorField=true;
                        }
                        else{
                            this.mapRecord[i].ErrorField=false;
                        }
                    }
                    this.errorMessageToDisplay = '';
                    this.errorList=[];
                    this.hasErrors=true;
                    for(let i = 0; i < result.hardStopList.length; i++){
                        this.errorList.push(result.hardStopList[i]);
                    }
                    this.showLoading=false;
                    this.showErrorToast = true;
                    this.template.querySelector('c-custom-toast').showToast("sticky");
                }
            }).catch(error => {
                this.hasErrors=true;
                //newly added start
                console.log('Inside catch oops error');
                //this.errorMessageToDisplay = 'An error occurred \n';
                this.errorMessageToDisplay = '';
                this.error = error;   
                console.log('Inside catch oops error'+this.error);
                if(this.error.body){
                   console.log('Inside error body'+this.error.body);
                   console.log('Inside error body type'+typeof this.error.body);
                   if (Array.isArray(this.error.body)) {
                       console.log('Inside array.isarray:'+this.error.body);
                       this.errorMessageToDisplay += this.error.body.map(e => e.message).join(', ');
                    }
                    else if(typeof this.error.body === 'object'){
                        let fieldErrors = this.error.body.fieldErrors;
                        let pageErrors = this.error.body.pageErrors;
                        let duplicateResults = this.error.body.duplicateResults;
                        let exceptionError = this.error.body.message;
                        console.log('Fielderror is:'+fieldErrors);
                        console.log('Page errors is:'+pageErrors);
                        console.log('Duplicateresults is:'+duplicateResults);
                        console.log('Exceptionerror is:'+exceptionError);
                        if(exceptionError && typeof exceptionError === 'string') {
                            this.errorMessageToDisplay += exceptionError;
                        }
                        if(fieldErrors){
                            for(var fieldName in fieldErrors){
                            let errorList = fieldErrors[fieldName];
                            for(var i=0; i < errorList.length; i++){
                                console.log('Field error status code is:'+errorList[i].statusCode);
                                console.log('Field error message is:'+errorList[i].message);
                                this.errorMessageToDisplay +=  errorList[i].message + ' ';
                            }
                            console.log('Fieldmsg is:'+this.errorMessageToDisplay);
                            }
                        }
                        if(pageErrors && pageErrors.length > 0){
                          for(let i=0; i < pageErrors.length; i++){
                            console.log('Page error status code is:'+pageErrors[i].statusCode);
                            console.log('Page error message is:'+pageErrors[i].message);
                            this.errorMessageToDisplay +=  pageErrors[i].message;
                          }
                        }
                       if(duplicateResults && duplicateResults.length > 0){
                           this.errorMessageToDisplay += 'duplicate result error';
                        }
                    }  
                }
                // handles errors from the lightning record edit form
                if(this.error.message){
                    this.errorMessageToDisplay += this.error.message;
                }
                if(this.error.detail){
                    this.errorMessageToDisplay += this.error.detail;
                }
                this.showLoading=false;
                const evnt = new ShowToastEvent({
                    title : 'Unexpected Error!',
                    message : this.errorMessageToDisplay,
                    variant : 'Error',
                    mode : 'dismissable'
                });
                this.dispatchEvent(evnt);
                })
        }
        else{
            this.hasErrors=true;
            this.showLoading=false;
            this.errorMessageToDisplay = 'Required Fields are missing';
            const evnt = new ShowToastEvent({
                title : 'Required Fields are missing',
                variant : 'Error',
                mode : 'dismissable'
                });
            this.dispatchEvent(evnt);
        }
    }
    
    validateFields() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            isValid = isValid &&   inputField.reportValidity();
        });
        return isValid;
    }

    onHandleSort(event) {
        console.log('sort',event.detail);
        this.sortedBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortedBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.productData));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.productData = parseData;
    } 
    removeRow(event) {
        if (this.mapRecord.length >= 2) {
            this.disableBool = false;
            let ct=0;
            let matched = false;
            this.mapRecord = this.mapRecord.filter(function (element) {
                console.log('removeRow ele id ',parseInt(element.Id));
                console.log('removeRow acc id ',parseInt(event.target.accessKey));
                debugger;
                if(parseInt(element.Id)  === parseInt(event.target.accessKey)){ //3
                    ct = element.Id;
                    console.log('3 ct',ct, matched);
                }
                else if(parseInt(element.Id) !== parseInt(event.target.accessKey) && parseInt(element.Id) > parseInt(event.target.accessKey)){
                    if( (parseInt(event.target.accessKey)-parseInt(element.Id)) === -1){
                       matched = true;
                       element.Id = ct;
                       console.log(' 4 ct',ct, element.Id, parseInt(element.Id), matched);
                    }
                    else{
                        element.Id = ++ct ; 
                        console.log('5 ct',ct, element.Id, parseInt(element.Id),);
                    }
                }
                if(parseInt(element.Id)  === parseInt(event.target.accessKey) && matched === true) {
                        return parseInt(element.Id)   === parseInt(event.target.accessKey);}
                else 
                      {return parseInt(element.Id)   !== parseInt(event.target.accessKey);}
            });
        }
        else{
            this.disableBool = true;
        } 
        console.log('returning removeRow',JSON.stringify(this.mapRecord));
    }
    get disableButton() {
        return !(this.rowCount>0);
    }
    showSelectedRecords() {
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        this.containerData =[];
        this.containerData = this.productData;
        this.productData = selectedRecords;
        this.ignoreMoreData=true;
        this.showBackToResultsButton=true;
    }
    showAll() {
        this.showBackToResultsButton=false;
        this.productData = this.containerData;
    }
}