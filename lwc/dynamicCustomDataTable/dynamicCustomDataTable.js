/* eslint-disable guard-for-in */
/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement,wire,api } from 'lwc';
import getFieldsetFields from '@salesforce/apex/DynamicCustomDataTableCtrl.getFieldsetFields';
import updateRecords from '@salesforce/apex/DynamicCustomDataTableCtrl.updateRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DynamicCustomDataTable extends LightningElement {

    @api relatedObjectApiName;
    @api fieldSet;
    @api records;
    lastSavedData = [];
    lastSavedPaginationData = [];
    filteredRecs = [];
    errors;
    draftValues = [];
    columns;
    @api recordsChanged;
    showSpinner = true;
    sortBy;
    sortDirection;
    searchVal;
    totalRecords;
    @api pageSize;
    totalPages;
    pageNumber = 1;

    get bDisableFirst() {
        return this.pageNumber === 1;
    }
    get bDisableLast() {
        return this.pageNumber === this.totalPages;
    }

    get displayPagination() {
        return this.filteredRecs.length > 0;
    }

    @wire(getFieldsetFields, { objectName: '$relatedObjectApiName', fieldSetName: '$fieldSet', recordsChanged:'$recordsChanged'})
    fsFields({data,error}){
        if(data){
            let columnsLocal = [];
            let pickLovs = [];
            let pickKeys = [];
            let refs = [];

            for (let i = 0; i < data.length; i++) {
                if(data[i].dataType === 'picklistColumn'){
                    columnsLocal.push({label : data[i].label, fieldName: data[i].fieldName , type : data[i].dataType, editable: data[i].editable, sortable: "true",
                    typeAttributes: {placeholder: 'Choose Type', options: { fieldName: data[i].label+'lov' }, 
                    value: { fieldName: data[i].fieldName }, 
                    context: { fieldName: 'Id' }}});
                }
                else if (data[i].dataType === 'lookupColumn') {
                    columnsLocal.push({label : data[i].label, fieldName: data[i].fieldName , type : data[i].dataType, editable: false,sortable: "true",
                    typeAttributes: {object: this.relatedObjectApiName, fieldName: data[i].fieldName, 
                    value: { fieldName: data[i].fieldName }, 
                    context: { fieldName: 'Id' },
                    name: data[i].fieldName,  
                    fields: [data[i].refObjName+'.Name'],
                    target: '_self'
                    }});
                }
                else {
                    columnsLocal.push({label : data[i].label, fieldName: data[i].fieldName , type : data[i].dataType, editable: data[i].editable,sortable: "true"});
                }
                

                

                if (data[i].dataType === 'picklistColumn') {
                    let pickLvs = [];
                    for (let j = 0; j < data[i].picklistLovs.length; j++) {
                        pickLvs.push({'label':data[i].picklistLovs[j],'value':data[i].picklistLovs[j]});
                    }
                    pickLovs.push({[data[i].label+'lov'] : pickLvs});
                    pickKeys.push(data[i].label+'lov');
                } 
                else if(data[i].dataType === 'lookupColumn'){
                    refs.push(data[i].lookupNameRef);
                }
            }

            this.columns = columnsLocal;
            let resultLoc = this.records;
            for (let i = 0; i < pickKeys.length; i++) {
                // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                this.records = resultLoc.map((item) => ({
                    ...item,
                    [pickKeys[i]]: pickLovs[i][pickKeys[i]]      
                }));
                resultLoc = this.records;
            }

            for (let i = 0; i < refs.length; i++) {
                // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                this.records = resultLoc.map((item) => ({
                    ...item,
                        [(refs[i].split('_')[0]).toLowerCase()+'Link']: refs[i].split('_')[1] === 's'? 
                        (item[refs[i].split('_')[0]+'Id'] !== undefined ? item[refs[i].split('_')[0]+'Id'] : ''):
                        (item[refs[i].split('_')[0]+'__c'] !== undefined ? item[refs[i].split('_')[0]+'__c'] : ''),

                        [(refs[i].split('_')[0]).toLowerCase()+'Name']: refs[i].split('_')[1] === 's'? 
                        (item[refs[i].split('_')[0]+'Id'] !== undefined ? item[refs[i].split('_')[0]+'.Name'] : ''):
                        (item[refs[i].split('_')[0]+'__c'] !== undefined ? item[refs[i].split('_')[0]+'__r.Name'] : '')
         
                    }));
                resultLoc = this.records;
            }
            this.lastSavedData = JSON.parse(JSON.stringify(this.records));
            this.filteredRecs = JSON.parse(JSON.stringify(this.records));  
            this.totalRecords = this.records.length;
            this.paginationHelper(); 
            this.showSpinner = false;
        }
        else if (error) {
            console.log('error is',error);
        }
    }

    async handleSave(event) {
        var rowsError = {};
        this.errors = {};
        this.showSpinner = true;
        const updatedFields = event.detail.draftValues;
        console.log('updated fields',JSON.stringify(updatedFields));
        const result = await updateRecords({data: updatedFields,objectName:this.relatedObjectApiName});
        if(result.length === 0){
            this.searchVal = '';
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records updated',
                    variant: 'success'
                })
            );
        }
        else {
            this.showSpinner = false;
            for (let i = 0; i < result.length; i++) {
                rowsError[result[i].recordId] = {
                    messages: result[i].errors,
                    fieldNames: result[i].fields,
                    title: 'We found errors.'
                };
            }
            
            this.errors = {
                rows: rowsError
            }

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please correct errors in the highlighted cells',
                    variant: 'error'
                })
            );
            return;
        }
        
        this.draftValues = [];

        const selectedEvent = new CustomEvent("recordssaved");
       
          // Dispatches the event.
          this.dispatchEvent(selectedEvent);

        
    }

    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.records));
 
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
 
        //write changes back to original data
        this.records = [...copyData];
    }

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
        
 
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }

    lookupChanged(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let recordIdVal = dataRecieved.value !== undefined ? dataRecieved.value : null;
        let updatedItem = { Id: dataRecieved.context, [dataRecieved.fieldName]: recordIdVal  };
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    handleCellChange(event) {
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    handleCancel() {
        //remove draftValues & revert data changes
        this.records = JSON.parse(JSON.stringify(this.lastSavedPaginationData));
        this.draftValues = [];
        this.errors = {};
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.filteredRecs));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? (typeof keyValue(x) === 'string' ? keyValue(x).toLowerCase() : keyValue(x)) : ''; // handling null values
            y = keyValue(y) ? (typeof keyValue(y) === 'string' ? keyValue(y).toLowerCase() : keyValue(y)) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.filteredRecs = parseData;
        this.pageNumber = 1;
        this.paginationHelper();
    } 

    handleKeyChange(event) {
        this.searchVal = event.target.value;

        if(this.searchVal){
            let recs = [];
            for (let i = 0; i < this.lastSavedData.length; i++) {
                let recWoLov = JSON.parse(JSON.stringify(this.lastSavedData[i])); 
                Object.keys(recWoLov).forEach(function(key){
                    if (key.includes('lov')) {
                        delete recWoLov[key];
                    }
                });

                if (JSON.stringify(recWoLov).toLowerCase().includes(this.searchVal.toLowerCase())) {
                    recs.push(this.lastSavedData[i]);
                }
            }
            this.filteredRecs = recs;
            this.totalRecords = this.records.length;
        }
        else{
            this.filteredRecs = JSON.parse(JSON.stringify(this.lastSavedData));
            
        }
        this.totalRecords = this.filteredRecs.length;
        this.pageNumber = 1;
        this.paginationHelper();         
    }

    paginationHelper() {
        this.records = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            //this.records.push(this.lastSavedData[i]);
            this.records.push(this.filteredRecs[i]);
        }

        this.lastSavedPaginationData = this.records;
    }

    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
}