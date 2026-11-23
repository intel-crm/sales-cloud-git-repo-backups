import { LightningElement, track, wire } from 'lwc';
import getRecords from '@salesforce/apex/Pricing_SystematicTenderLimitation.getSystematicTenderLimitation';
import saveRecords from '@salesforce/apex/Pricing_SystematicTenderLimitation.saveRecords';
import searchAccounts from '@salesforce/apex/Pricing_SystematicTenderLimitation.searchAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Pricing_Systematic_Tender_Limitation__c';
import PICKLIST_FIELD from '@salesforce/schema/Pricing_Systematic_Tender_Limitation__c.Pricing_Quote_Type__c';
import systematicFields from '@salesforce/label/c.Pricing_Systematic_Fields';


export default class CustomEditableTable extends LightningElement {
    @track records = [];
    @track picklistValues = [];
    @track searchResults = [];
    @track isAddRow = false;
    originalRecords = []; // Stores original data for reverting
    updatedRecords = [];
    @track fieldstoDisplay;
    @track accountMap = new Map();
    @track isDisableCancel = false;
    @track recordsList = [];
    @track account = null;
    @track message = '';

    @track searchKey = '';
    @track sortedBy = 'QuoteType'; // Default sort column
    @track sortDirection = 'asc';
    @track count = 0;

    connectedCallback(){
        this.fieldstoDisplay = systematicFields.split(',');
        this.getSystematicRecords() 
        this.sortData(this.sortedBy, this.sortDirection);
    }

    sortData(field, direction) {
        let sortedRecords = [...this.records];
        sortedRecords.sort((a, b) => {
            let valueA = a[field] ? a[field].toLowerCase() : '';
            let valueB = b[field] ? b[field].toLowerCase() : '';

            return direction === 'asc'
                ? valueA.localeCompare(valueB)
                : valueB.localeCompare(valueA);
        });

        this.records = sortedRecords;
    }

    // Handles column sorting
    handleSort(event) {
        const field = event.currentTarget.dataset.field;
        this.sortDirection = this.sortedBy === field && this.sortDirection === 'asc' ? 'desc' : 'asc';
        this.sortedBy = field;
        this.sortData(field, this.sortDirection);
    }

    // Getter function to determine the icon for sorting
    getSortIcon(field) {
        return this.sortedBy === field ? (this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown') : 'utility:sortable';
    }


    // Fetch Picklist values
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PICKLIST_FIELD })
    wiredPicklistValues({ data, error }) {
        if (data) {
            this.picklistValues = data.values.map(item => ({ label: item.label, value: item.value }));
        }
    }

    // Fetch Existing Records
    getSystematicRecords() {
        getRecords()
        .then(result => {
            console.log('records1233', JSON.stringify(result));

            this.accountMap = new Map();

            for (var key in result) {
                if (result[key] != undefined && result[key] != null) {
                    this.accountMap.set(result[key].Pricing_Account__c + '-' + result[key].Pricing_Quote_Type__c,result[key])
                    this.records.push({
                        ...result[key],
                        accountName: result[key].Pricing_Account__r ? result[key].Pricing_Account__r.Name : '',
                        accountId: result[key].Pricing_Account__c,
                        isEditable: false,
                        isNew: false
                    });
                }
            }
          
            this.originalRecords = JSON.parse(JSON.stringify(this.records)); // Deep copy
            
        })
        .catch(error => {
            console.error('Error fetching records:', JSON.stringify(error));
        });
    }



 handleChange(event) {
        const field = event.target.name; // Make sure this is defined
        const recordId = event.target.dataset.id;
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
        const rowKey = event.target.dataset.recordkey; 
        this.isDisableCancel = false;

        this.records.forEach(rec => {

                    let updatedRecord = this.records.find(rec => (rec.Id === recordId || (rec.uniqueKey === rowKey && rec.isNew)));
                    if (updatedRecord) {
                    updatedRecord[field] = value;

                        let existingRecord = this.updatedRecords.find(rec => (rec.Id === recordId || (rec.uniqueKey === rowKey && rec.isNew)));
                        if (existingRecord) {
                            existingRecord[field] = value; // Update the value in updatedRecords
                        } else {
                            this.updatedRecords.push({ ...updatedRecord }); // Add to updatedRecords if not already present
                        }

                    }
        });

    }


    // Add a New Row
    addRow() {
        this.isAddRow = true;
        this.isDisableCancel = false;
        this.account = null;
        
        console.log('this.records:'+this.records);
        //const newRecord  //= { Id: null, uniqueKey: 'temp_' + Date.now(), Pricing_Account__c: '', accountName: '', Pricing_Quote_Type__c: '', Pricing_Active_cb__c: false, Pricing_Exception_Quota__c: 0 ,isEditable: true , isNew: true};
        this.records = [
            ...this.records,
            { Id: null, uniqueKey: 'temp_' + this.count, Pricing_Account__c: '', accountName: '', Pricing_Quote_Type__c: '', Pricing_Active_cb__c: false, Pricing_Exception_Quota__c: 0 ,isEditable: true , isNew: true, searchKey: '', recordsList: [], message: ''}
        ];
        /*for (let i in this.records) {
            this.records.push(
            { Id: null, uniqueKey: 'temp_' + i, Pricing_Account__c: '', accountName: '', Pricing_Quote_Type__c: '', Pricing_Active_cb__c: false, Pricing_Exception_Quota__c: 0 ,isEditable: true , isNew: true, searchKey: ''}
            );
        }*/
       this.count++;
        console.log('this.records in row:'+JSON.stringify(this.records));
    }

    handleSave() {
        
        const errors = this.validateRecords();
        if (errors.length > 0) {
            this.showToast('Error', errors.join('\n'), 'error'); // Show validation errors
        } else {
            //this.isDisableCancel = true;
            if (this.updatedRecords.length > 0) {
                saveRecords({ records: this.updatedRecords })
                .then(result => {
                        this.showToast('Success', 'Records saved successfully!', 'success');
                        this.records.forEach((rec, index) => {
                            const matchingRecord = result.find(savedRec =>
                                (rec.Id && savedRec.Id === rec.Id) ||
                                (!rec.Id && rec.uniqueKey && savedRec.Pricing_Account__c === rec.Pricing_Account__c)
                            );

                            if (matchingRecord) {
                                this.records[index] = {
                                    ...matchingRecord,
                                    Id: matchingRecord.Id,
                                    accountName: matchingRecord.Pricing_Account__r ? matchingRecord.Pricing_Account__r.Name : '',
                                    isEditable: false,
                                    isNew: false,
                                    uniqueKey: undefined 
                                };
                            }
                        });
                        this.originalRecords = JSON.parse(JSON.stringify(this.records));
                        this.updatedRecords = []; 
                    
                    })
                    .catch(error => {
                        console.error("Error saving records:", JSON.stringify(error));
                    });
            } else {
                this.showToast('Error', 'No changes to save!', 'Error');
            }
        }
        
    }

    validateRecords() {
        let errors = [];
        for (let i in this.updatedRecords) {
            if(this.updatedRecords[i].Pricing_Exception_Quota__c <= 0){
                //errors.push('Number must be a greater than 0');
            }

            if(this.updatedRecords[i].isNew && this.accountMap.has(this.updatedRecords[i].Pricing_Account__c + '-' + this.updatedRecords[i].Pricing_Quote_Type__c)){
                errors.push('Already exists records with same account and type');
            }

            if(this.updatedRecords[i].isNew && (this.updatedRecords[i].Pricing_Account__c == null || this.updatedRecords[i].Pricing_Account__c == '')){
                errors.push('Account is mandatory while saving record' );
            }

            if(this.updatedRecords[i].isNew && (this.updatedRecords[i].Pricing_Quote_Type__c == null || this.updatedRecords[i].Pricing_Quote_Type__c == '') ){
                errors.push('Quote Type is mandatory while saving record' );
            }

        }

        return errors;
    }


    handleCancel() {

        console.log('this.records:'+JSON.stringify(this.records));
        // Remove newly added rows (Id === null)
    //this.records = this.records.filter(rec => rec.Id !== null);

    // Revert existing records to their original values
    this.records = this.originalRecords.filter(rec => rec.Id !== null);;

    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }


    handleKeyChange(event) {
    const recordKey = event.target.dataset.recordkey; 
    const value = event.target.value;

    // Find the record in the list using recordKey for newly added rows
    let record = this.records.find(rec => rec.uniqueKey === recordKey);
    if (record) {

        console.log('recordKey:'+recordKey);
        record.searchKey = value;
        console.log('record.searchKey:'+record.uniqueKey);

        if (value.length > 2) { // Search when 3+ characters entered
            searchAccounts({ searchKey: value })
                .then(result => {
                    record.recordsList = result.length > 0 ? result : [];
                    record.message = result.length > 0 ? '' : 'No accounts found.';
                    this.records = [...this.records]; // Refresh UI
                })
                .catch(error => {
                    console.error('Error fetching accounts:', error);
                    record.recordsList = [];
                    record.message = 'Error fetching accounts';
                    this.records = [...this.records];
                });
        } else {
            record.recordsList = [];
            record.message = '';
            this.records = [...this.records];
        }
    }

       /* if (this.searchKey.length > 2) { // Only search when 3+ characters entered
            searchAccounts({ searchKey: this.searchKey })
                .then(result => {
                    if (result.length > 0) {
                        this.recordsList = result;
                        this.message = '';
                    } else {
                        this.recordsList = [];
                        this.message = 'No accounts found.';
                    }
                })
                .catch(error => {
                    console.error('Error fetching accounts:', error);
                    this.recordsList = [];
                });
        } else {
            this.recordsList = [];
            this.message = '';
        }*/
    }

    onRecordSelection(event) {
        const accountId = event.currentTarget.dataset.id;
        const accountName = event.currentTarget.dataset.name;
        const rowKey = event.currentTarget.dataset.recordkey;

        this.account = { Id: accountId, Name: accountName };

        let record = this.records.find(rec => rec.uniqueKey === rowKey);
    if (record) {
        record.Pricing_Account__c = accountId;
        record.accountName = accountName;
        record.searchKey = accountName; // Display selected account name
        record.recordsList = []; // Hide search results
        this.records = [...this.records]; // Refresh UI
    }

        /*this.records = this.records.map(rec => {
            if (rec.uniqueKey === rowKey) {
                return { ...rec, Pricing_Account__c: accountId, accountName: accountName };
            }
            return rec;
        });*/
        //this.recordsList = [];

    }
      // Clear Selection
      removeRecordOnLookup(event) {
        const rowKey = event.currentTarget.dataset.recordkey;
        this.account = null;
        let record = this.records.find(rec => rec.uniqueKey === rowKey);
    if (record) {
        record.Pricing_Account__c = null;
        record.accountName = '';
        record.searchKey = '';
        record.recordsList = [];
        this.records = [...this.records]; // Refresh UI
    }
        //this.recordsList = [];
    }

}