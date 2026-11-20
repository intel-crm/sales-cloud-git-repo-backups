import { LightningElement, api, wire } from 'lwc';
import getRelatedRecords from '@salesforce/apex/EnhancedEditRelatedRecordsCtrl.getRelatedRecords';
import getFieldsetFields from '@salesforce/apex/EnhancedEditRelatedRecordsCtrl.getFieldsetFields';
import { refreshApex } from '@salesforce/apex';


export default class EnhancedEditRelatedRecordsLwc extends LightningElement {
    @api mode;
    @api layoutType;
    @api relatedObjectApiName;
    @api recordId;
    @api sortBy;
    @api parenIdApi;
    @api picklistFieldApiName;
    @api labl;
    @api iconName;
    @api fieldSet;
    @api recordsChanged = false;
    @api pageSize;


    relatedRecordId;
    relatedRTId;
    error = false;
    noChild = false;
    options = [];
    relatedRcs = [];
    showRecord = false;
    showSelect = false;
    showSpinner = false;
    fieldsArray = [];
    showAllChildren = false;
    dataFromApex;
    showStandardSelection = true;
    searchResults;
    selectedValue;
    refreshRcrds = false;

    //Calling apex method to get the related child records based on the parent record id
    @wire(getRelatedRecords, {
        parentId: '$recordId',
        parentApiName: '$parenIdApi',
        objectApiName: '$relatedObjectApiName',
        picklistApiName: '$picklistFieldApiName',
        sortBy: '$sortBy',
        fieldSetName:'$fieldSet'
    })
    relatedRecs(result) {
        var i;
        const { data, error } = result;
        this.dataFromApex = result;
        if (data) {
            this.options = [];
            this.relatedRcs = [];
            if (data.length === 0) {
                //Setting boolean if there is no child records under the parent
                this.noChild = true;
            } else {
                this.recordsCount = data.length;               
                this.relatedRcs = data;
                // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                this.recordsChanged = !this.recordsChanged;
                this.lastSavedData = JSON.parse(JSON.stringify(this.relatedRcs)); 

                for (i = 0; i < data.length; i++) {
                    this.options.push({ Id: data[i].Id, PicklistValue: data[i][this.picklistFieldApiName], RTId: data[i].RecordTypeId });
                }
                //To set the latest created child record to display in edit mode by default
                this.relatedRecordId = data[0].Id;
                this.relatedRTId = data[0].RecordTypeId;
                if (this.refreshRcrds === false) {
                    this.showRecord = true;
                    this.showAllChildren = false;
                    if (data.length > 1) {
                        this.showSelect = true;
                    }
                }                          
            }
        } else if (error) {
            console.log('error is',error);
            this.error = true;
        }
    }

    @wire(getFieldsetFields, { objectName: '$relatedObjectApiName', fieldSetName: '$fieldSet'})
    fsFields({data,error}){
        if(data){
            let fieldsLocal = [];

            for (let i = 0; i < data.length; i++) {
                fieldsLocal.push(data[i].fieldName);
            }
            this.fieldsArray = fieldsLocal;
        }
        else if (error) {
            console.log('error is',error);
        }
    }

    get selectedLayoutType() {
        return this.layoutType === 'fieldset' ? '':this.layoutType;
    }


    //To change the related child record on change in the picklist option
    selectionChangeHandler(event) {
        this.relatedRecordId = event.target.value;
        this.relatedRTId = this.findRecordTypeId(event.target.value);
    }

    findRecordTypeId(recId) {
        var i;
        var rtId;
        for (i = 0; i < this.options.length; i++) {
            if (this.options[i].Id === recId) {
                rtId = this.options[i].RTId;
                break;
            }
        }
        return rtId;
    }

    handleSuccess() {
        return refreshApex(this.dataFromApex);
    }


    showAllChildrenMethod() {
        this.relatedRecordId = this.options[0].Id;
        this.relatedRTId = this.options[0].RecordTypeId;
        this.showAllChildren = true;
        this.showRecord = false;
        this.showSelect = false;
    }

    hideAllChildrenMethod() {
        this.showAllChildren = false;
        this.showRecord = true;
        this.showSelect = true;
        this.refreshRcrds = false;
    }

    switchToSearch() {
        this.showStandardSelection = false;
    }

    switchToStd() {
        this.showStandardSelection = true;
    }

    showPicklistOptions() {
        if (!this.searchResults) {
          this.searchResults = this.options;
        }
    }

    search(event) {
        this.searchResults = null;
        const input = event.detail.value.toLowerCase();
        const result = this.options.filter((picklistOption) =>
          picklistOption.PicklistValue.toLowerCase().includes(input)
        );
       
        setTimeout(()=> this.searchResults = result, 100);
        
    }

    selectSearchResult(event) {
        const selValue = event.currentTarget.dataset.value;
        this.selectedValue = event.currentTarget.dataset.value;
        this.selectedSearchResult = this.options.find(
          (picklistOption) => picklistOption.PicklistValue === selValue
        );
        this.relatedRecordId = this.selectedSearchResult.Id;
        this.relatedRTId = this.findRecordTypeId(this.selectedSearchResult.Id);
        this.clearSearchResults();
    }
    
    clearSearchResults() {
        this.searchResults = null;
    }

    refreshRecords(){
        this.refreshRcrds = true;
        refreshApex(this.dataFromApex);
    }

}