import { LightningElement,api,track, wire } from 'lwc';
import getColumns from '@salesforce/apex/PMP_DynamicTableGridController.getColumns';
import downloadcsv from '@salesforce/apex/PMP_DynamicTableGridController.downloadcsv';
import fetchRecords from '@salesforce/apex/PMP_DynamicTableGridController.fetchRecords';
import getSearchedRecords from '@salesforce/apex/PMP_DynamicTableGridController.getSearchedRecords';
import fetchRecordswithlookup from '@salesforce/apex/PMP_DynamicTableGridController.fetchRecordswithlookup';
import getFilterValues from '@salesforce/apex/PMP_DynamicTableGridController.getFilterValues';
import getRowCounts from '@salesforce/apex/PMP_DynamicTableGridController.getRowCount';
import { updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { publish, MessageContext } from 'lightning/messageService';
import dynamicTableMessageChannel from '@salesforce/messageChannel/pMP_DynamicTableMessageChannel__c';



export default class DynamicTableGrid extends LightningElement {

    @track selectedRecordType = '';
    @track fieldSetFields = [];
    @api searchResult =[];
    @track colList=[];
    @track columns=[];
    @track showResult = false;
    @track showpagination = true;
    @track showLookup = true;
    @track TotalColumn = [];
    @track selectedcolumn =[];
    @track draftValues = [];
    @track pageNumber = 1;
    @api pageSize ;
    @api currentFilter = 'All';
    @api currentfilterlabel = '';
    //@api totalRecords = [];
    @track isLastPage=false;
    @track isFirstPage=true;
    @track resultSize=0;
    @track disabled=true;
    @track wiredList = [];
    @track fromPageNumber = 0;
    @track toPageNumber = 0;
    @track totalRows = 0;
    @api objectName;
    @track isNewModalOpen=false;
    @track isRecordTypeNewModalOpen=false;
    @api fieldList=[];
    @track lookupNamefieldList = [];
    @track recordsToDisplay = []; //Records to be displayed on the page
    @api recordsToDisplayBkp = [];
    @track rowNumberOffset; //Row number
    @track disableFilter = false;
    @track recordTypeOptions=[];
    @track wiredLookupResult = [];
    @track wiredTotalRows=[];
    @track isModalOpen = false;
    @track showSearchBox = false;
    @api EnableSearch;
    @api EnableInlineEdit;
    @api EnablePagination;
    @api EnableSelectAndReorderColumns;
    @api EnableNewRecordCreation;
    @api EnableSorting;
    @api keyEntered= '';
    @api tempkeyEntered= '';
    @api prevkeyEntered = '';
    @track isExpanded = false;
    @track isLoaded = false;
    @track val = '';
    @api filter;

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    downButtonTrue = false;
    filterOptions = [];

    @wire(MessageContext)
    messageContext;

    renderedCallback(){
        this.isLoaded = true;
    }
    connectedCallback() {
        if(this.EnablePagination === false) {
            this.pageSize = 50000;
        }
    }

    getFilterValue(){
        return  {
            fields: this.selectedcolumn,
            filterValue : this.filter,
        };
    }

    get dropdownTriggerClass() {
        let classString = '';
        if (this.isExpanded) {
            classString =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view slds-is-open' ;
        } else {
            classString =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view' ;
        }
        return classString;
    }

    @wire(getFilterValues, {objectApiName : '$objectName'})
    handleStatus(value){
        const { data } = value;
        if(data){
            for(let i =0;i<data.length;i++){
                this.filterOptions.push({label : data[i].Filter_Label__c,value : data[i].Filter_Value__c, defaultfilter: data[i].Default_Filter__c });
            }
            for(let j =0;j<this.filterOptions.length;j++){
              if(this.filterOptions[j].defaultfilter === true){
                 this.currentfilterlabel = this.filterOptions[j].label;
                 this.filter = this.filterOptions[j].value;
                 break;
              }
            }
        } else {
            this.currentfilterlabel = 'All';
        }
    }

    handleClickExtend() {
        this.isExpanded = !this.isExpanded;
    }

    updateDataValues(updateItem) {
        const copyData = [... this.recordsToDisplay];
        copyData.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (const field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });

        //write changes back to original data
        this.recordsToDisplay = [...copyData];
    }

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        const copyDraftValues = [...this.draftValues];
        copyDraftValues.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (const field in updateItem) {
                    item[field] = updateItem[field].toString();
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

    handleSelection(event) {
        event.stopPropagation();
        const updatedItem = { Id: event.detail.rowId };
        updatedItem[event.detail.fieldName]=event.detail.lookupId.toString();
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

   handlePicklist(event){
    event.stopPropagation();

    const updatedItem = { Id: event.detail.rowId };
    updatedItem[event.detail.fieldName]=event.detail.value.toString();
    this.updateDraftValues(updatedItem);
    this.updateDataValues(updatedItem);
   }

    openModal() {
        // to open modal set isModalOpen track value as true
        this.isModalOpen = true;
    }

    closeModal() {
        // to close modal set isModalOpen track value as false
        this.isModalOpen = false;
    }

    openNewModal() {
        // to open modal set isModalOpen track value as true
        if(this.selectedRecordType !== '') {
            this.isNewModalOpen = true;
            this.isRecordTypeNewModalOpen = false;
        } else {
            alert('Please select Record type');
        }
    }

    closeNewModal() {
        // to close modal set isModalOpen tarck value as false
        this.isNewModalOpen = false;
    }

    handleRecordCreated(event){
        this.isNewModalOpen=false;
        this.pageNumber=1;
        this.fieldList=this.selectedcolumn;
        return refreshApex(this.wiredList);
       }

    handleRecordTypeSelect(event){
        this.selectedRecordType = event.detail.value;
    }

    openRecordTypeModal() {
        // to open modal set isModalOpen track value as true
        if(this.recordTypeOptions.length === 0){
            this.isNewModalOpen = true;
        } else{
            this.isRecordTypeNewModalOpen = true;
        }
    }
    closeRecordTypeModal() {
        // to close modal set isModalOpen track value as false
        this.isRecordTypeNewModalOpen = false;
    }

    submitDetails() {
        // to close modal set isModalOpen track value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
        this.fieldList = this.selectedcolumn;
        return refreshApex(this.wiredList);
    }

    handleChange(event) {
        // Get the list of the "value" attribute on all the selected options
        this.selectedcolumn = event.detail.value;
    }

    @wire(getObjectInfo, { objectApiName:'$objectName'})
    getRecordTypes({data,error}){
        if(data){
            this.recordTypeOptions = [];
            for(const i in data.recordTypeInfos){
                if(data.recordTypeInfos[i].name !== 'Master' || data.recordTypeInfos.length===1){
                    const target = {
                        value : '',
                        target : '',
                    };
                    target.value=i;
                    target.label = data.recordTypeInfos[i].name;
                    this.recordTypeOptions.push(target);
                }
            }
       }
       if(error){
            console.log('error --->',error);
        }
    }

    @wire(getRowCounts,{objectApiName: '$objectName', filterValue : '$filter'})
    getTotalRowCount(resultTotalRows){
        this.wiredTotalRows=resultTotalRows;
        if(resultTotalRows.data) {
            this.totalRows=resultTotalRows.data[0].expr0;
        }
    }

    onNext () {
        this.pageNumber = this.pageNumber+1;
        this.fieldList = this.selectedcolumn;
        return refreshApex(this.wiredList);
    }
    onPrev () {
        this.pageNumber = this.pageNumber-1;
        this.fieldList = this.selectedcolumn;
        return refreshApex(this.wiredList);
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                return primer(x[field]);
            }
            : function(x) {
                return x[field];
            };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.recordsToDisplay];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.recordsToDisplay = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    handleCancel(event) {
      return refreshApex(this.wiredList).then(() => {
        // Clear all draft values in the datatable
        this.draftValues = [];
       const payload = { showEditForm: false, showViewForm: true };

       publish(this.messageContext, dynamicTableMessageChannel, payload);

      });
    }

    handleSave(event) {
        const recordInputs =  event.detail.draftValues.slice().map((draft) => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
        const promises = recordInputs.map((recordInput) => updateRecord(recordInput));
        Promise.all(promises).then((Records) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'All Records updated',
                    variant: 'success',
                })
            );
            // Display fresh data in the datatable
            return this.handleCancel();
        }).catch((error) => {
        // Handle error
        console.log(error);
        });
    }



    @wire(getColumns, {objectApiName: '$objectName', fieldSetName: 'Column_Field_Set', EnableInlineEdit: '$EnableInlineEdit'})
    handleResult({error, data}) {
        if(data) {
            this.fieldSetFields = data;
            this.draftValues = [];

            for(let i=0;i<this.fieldSetFields.length;i++){
                if(this.fieldSetFields[i].fieldName==='nameURL'){
                    this.TotalColumn.push({label:this.fieldSetFields[i].label,value:'Id'}) ;
                } else {
                    this.TotalColumn.push({label:this.fieldSetFields[i].label,value:this.fieldSetFields[i].fieldName}) ;
                }
                this.colList.push(this.fieldSetFields[i].fieldName);
            }

            if(this.colList!==null){
                this.selectedcolumn=this.colList;
                this.fieldList = this.selectedcolumn;
                return this.wiredList;
            }
        }
        if(error) {
            console.log('Error :: ',error);
        }
        return null; //CodeScan
    }

    handleFilterChangeButton(event) {
        this.filter =  event.target.dataset.filter;
        this.currentfilterlabel = event.target.dataset.filterlabel;
        this.pageNumber = 1;
        refreshApex(this.wiredList);
    }

    handlePaginatorChange(event) {
        this.tempkeyEntered = event.target.value;
        if(event.keyCode === 13 && this.tempkeyEntered.length >= 2) {
            this.keyEntered = this.tempkeyEntered;
            this.prevkeyEntered = this.tempkeyEntered;
        } else if (event.keyCode === 13 && this.tempkeyEntered.length === 0 && this.prevkeyEntered.length >=2) {
            this.keyEntered = this.tempkeyEntered;
            refreshApex(this.wiredList);
        }
        this.pageNumber = 1;
    }

    @wire(getSearchedRecords, {fDetails : '$fieldList', objectApiName :'$objectName',pageSizeNumber :'$pageSize',
                pageNumberValue : '$pageNumber', filterValue : '$filter',key : '$keyEntered'})
    processSearchRecords({data,error}){
        if(data){
            const valueData = {
                data : [],
                error : '',
            };
            valueData.data = data;
            this.fetchData(valueData);
        }
        if(error){
            console.log('error is :::: ',error);
        }
    }

    @wire(fetchRecords, {fDetails : '$fieldList', objectApiName: '$objectName',pageSizeNumber: '$pageSize',
    pageNumberValue: '$pageNumber', filterValue : '$filter'})
    fetchData(resultData){
    this.wiredList=resultData;
    if(resultData.data) {
        this.columns = [];
        this.searchResult = [];
        this.lookupNamefieldList = [];
        this.recordsToDisplay = this.wiredList;
        this.recordsToDisplayBkp = [];
        this.showResult = false;
        this.showSearchBox = true;
        for(let i=0;i<this.fieldList.length;i++) {
            for(let j=0;j<this.fieldSetFields.length;j++){
                if(this.fieldList[i] === this.fieldSetFields[j].fieldName) {
                    this.columns = [...this.columns, {
                            label:this.fieldSetFields[j].label,
                            fieldName: this.fieldSetFields[j].fieldName,
                            type: this.fieldSetFields[j].fieldType,
                            typeAttributes: this.fieldSetFields[j].typeAttributes,
                            editable: (this.EnableInlineEdit === false)? false : this.fieldSetFields[j].editable,
                            wrapText: this.fieldSetFields[j].wrapText,
                            sortable: (this.EnableSorting === false)? false : this.fieldSetFields[j].sortable,
                        },
                    ];
                    if(this.fieldSetFields[i].fieldType === 'lookup') {
                        const lookupFieldName = this.fieldSetFields[i].fieldName;
                        if(lookupFieldName.indexOf('__c') !== -1){
                            this.lookupNamefieldList.push(lookupFieldName.replace('__c','__r.Name'));
                        }
                    }
                }
            }
        }
        const objName = this.objectName;
        const lghturl = '/lightning/r/';
        // const lghturlOff = '/lightning/r/PMP_Partner_Offering__c'; IPA2.0 + US TWC4497-1631
        const vw = '/view';
        const slh ='/';
        const result = resultData.data.map(function(el) {
            const target = {};
            for(const il in el){
                if(typeof el[il] === 'object'){
                    for(const ij in el[il]) {
                        if(ij==='Id'){
                            target[il+'Name'] = `${lghturl}`+this.objName+`${slh}`+el[il][ij]+`${vw}`;
                        }
                        if(ij==='Name'){
                            target[il+'.Name'] = el[il][ij];
                        }
                    }
                }
                if(il==='Id'){
                    target.nameURL = `${lghturl}`+this.objName+`${slh}`+el[il]+`${vw}`;
                }
                // IPA2.0 + US TWC4497-1631
                // if(il ==='PMP_Offering_Nm_Hyperlink__c') {
                //     const substr = el[il].substring(el[il].indexOf('>')+1,el[il].lastIndexOf('</a>'));
                //     target['Offering Name'] = substr;
                //     target.hyperlink = `${lghturl}`+this.objName+`${slh}`+el[il].substring(el[il].indexOf('/')+1,el[il].lastIndexOf('?'))+`${vw}`;
                // }
                if(il ==='PSS_Solution_Name_Id_Txt__c') {
                    const substr = el[il].substring(el[il].indexOf('>')+1,el[il].lastIndexOf('</a>'));
                    target['Solution Name'] = substr;
                    target.solnamehyperlink = `${lghturl}`+this.objName+`${slh}`+el[il].substring(el[il].indexOf('/')+1,el[il].indexOf('target')-2)+`${vw}`;
                }
                // IPA2.0 + US TWC4497-1631
                // if(il ==='PSS_View_Offering_Txt__c') {
                //     const substr = el[il].substring(el[il].indexOf('>')+1,el[il].lastIndexOf('</a>'));
                //     target['View Offering'] = substr;
                //     target.viewoffhyperlink = `${lghturlOff}`+`${slh}`+el[il].substring(el[il].indexOf('/')+1,el[il].indexOf('target')-2)+`${vw}`;
                // }
            }
                return Object.assign(target, el);
    },{objName:objName});
    const concatFieldlist = this.lookupNamefieldList.concat(this.fieldList);
    this.lookupNamefieldList = concatFieldlist;
        this.recordsToDisplay=result;
        this.recordsToDisplayBkp = [...this.recordsToDisplay];
        this.resultSize=result.length;
        this.searchResult =  result;

        if(this.pageNumber===1){
            this.isFirstPage=true;
        } else {
            this.isFirstPage=false;
        }
        this.fromPageNumber=(this.pageNumber-1)*this.pageSize+1;
        this.toPageNumber=(this.pageNumber-1)*this.pageSize+this.resultSize;
        if(resultData.data.length === 0){
            this.fromPageNumber = 0;
        }
        if(resultData.data.length <  this.pageSize || this.totalRows  === this.toPageNumber){
            this.isLastPage= true;
        } else{
            this.isLastPage= false;
        }
        fetchRecordswithlookup({fDetails: this.lookupNamefieldList , objectApiName: this.objectName ,pageSize: this.pageSize , pageNumber: this.pageNumber})
        .then((resultlookupdata) => {
            const resultlookup = resultlookupdata.map(function(el) {
                            const target = {};
                            for(const il in el){
                                if(typeof el[il] === 'object'){
                                    for(const ij in el[il]){
                                        if(ij==='Id'){
                                            target[il+'Name'] = `${lghturl}`+this.objName+`${slh}`+el[il][ij]+`${vw}`;
                                        }
                                        if(ij==='Name'){
                                            target[il+'.Name'] = el[il][ij];
                                        }
                                    }
                                }
                                if(il==='Id'){
                                    target.nameURL = `${lghturl}`+this.objName+`${slh}`+el[il]+`${vw}`;
                                }
                            }
                                return Object.assign(target, el);
                    },{objName:objName});
                    this.searchResult = resultlookup;
                    if(this.EnableSearch === true){
                        this.showSearchBox = true;
                    } else {
                        this.showSearchBox = false;
                    }

            })
            .catch((error) => {
                window.console.log(error);
            });
            this.showResult = true;
        } else if(resultData.error){
            console.log('fetchData'+JSON.stringify(resultData.error));
        }
    }

    downloadCSVFile() {
        downloadcsv({fDetails : this.fieldList, objectApiName: this.objectName,filterValue : this.filter}).then((result)=>{
            const downloadElement = document.createElement('a');
            downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(result);
            downloadElement.target = '_self';
            downloadElement.download = this.objectName+' Data.csv';
            downloadElement.click();
        }).catch((error) =>{
            console.log('the error is',+error);
        });
    }
}