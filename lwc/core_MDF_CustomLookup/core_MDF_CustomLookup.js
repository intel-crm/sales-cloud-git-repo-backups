import { api, LightningElement, track, wire } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import lookUp from '@salesforce/apex/Core_MDF_CampaignCreatePage.search';

export default class customLookUp extends LightningElement {

    @api objName;
    @api label;
    @api required;
    @api iconName;
    @api filter = '';
    @api searchPlaceholder='Search';
    _selectedRecord;
    _selectedRecordId;
    _selectedRecordName;
    @api disabled;
    @api bypassSharing=false;
    @api programRecordType = '';

    // Exposed as Flow output so screens can read the selected record Id on navigation.
    @api selectedId;
    @track selectedName;
    @track records;
    @track isValueSelected;
    @track blurTimeout;

    searchTerm;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    @track inputValid = false;
    accountError = false;

    @api
    get selectedRecord() {
        return this._selectedRecord;
    }

    set selectedRecord(value) {
        this._selectedRecord = value;
        this.restoreSelectedRecord(value);
    }

    @api
    get selectedRecordId() {
        return this._selectedRecordId;
    }

    set selectedRecordId(value) {
        this._selectedRecordId = value;
        this.restoreSelectedRecordFields(value, this.selectedRecordName);
    }

    @api
    get selectedRecordName() {
        return this._selectedRecordName;
    }

    set selectedRecordName(value) {
        this._selectedRecordName = value;
        this.restoreSelectedRecordFields(this.selectedRecordId, value);
    }

    @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName', filter : '$filter', bypassSharing : '$bypassSharing'})
    wiredRecords({ error, data }) {
        if (data) {
            this.error = undefined;
            this.records = data;
            console.log('bypassSharing 34:'+this.bypassSharing);
        } else if (error) {
            this.error = error;
            console.log('customLookUp err '+JSON.stringify(this.error));
            this.records = undefined;
        }
    }

    connectedCallback() {
        if(this.disabled == undefined || this.disabled == null || this.disabled == '') {
            this.disabled = false;
        }
        this.restoreSelectedRecord(this.selectedRecord);
        this.restoreSelectedRecordFields(this.selectedRecordId, this.selectedRecordName);
        // Restore from selectedId if other inputs not provided (needed for Flow UseStoredValues)
        if((this.selectedRecordId == undefined || this.selectedRecordId == null || this.selectedRecordId === '') && 
           (this.selectedId != undefined && this.selectedId != null && this.selectedId !== '')) {
            this.isValueSelected = true;
            // Attempt to restore selectedName from sessionStorage (set during onSelect)
            const storedName = sessionStorage.getItem('lookupSelectedName_' + this.selectedId);
            if(storedName) {
                this.selectedName = storedName;
            }
            this.dispatchFlowAttributeChange('selectedId', this.selectedId);
        }
    }

    restoreSelectedRecord(record) {
        if(record != undefined && record != null && record != '') {
            this.selectedId = record.Id;
            this.selectedName = record.Name;
            this.isValueSelected = true;
            this.dispatchFlowAttributeChange('selectedId', record.Id);
        }
    }

    restoreSelectedRecordFields(recordId, recordName) {
        if(recordId != undefined && recordId != null && recordId !== '' && recordName != undefined && recordName != null && recordName !== '') {
            this.selectedId = recordId;
            this.selectedName = recordName;
            this.isValueSelected = true;
            this.dispatchFlowAttributeChange('selectedRecordId', recordId);
            this.dispatchFlowAttributeChange('selectedRecordName', recordName);
            this.dispatchFlowAttributeChange('selectedId', recordId);
        }
    }

    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open'; 
    }

    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
        //DE113818: Campaign is getting saved even though the account field is not valid
        if(this.searchTerm != '' && (this.selectedName == ''||this.selectedName == null||this.selectedName == undefined)){
            this.accountError = true;
            this.inputValid = false;
        }
        else{
            this.accountError = false;
            this.inputValid = true;
        }
    }

    onSelect(event) {
        console.log('@@LOOKUP-programRecordType:', this.programRecordType);
        console.log('@@LOOKUP-selectedId:', event.currentTarget.dataset.id);
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        let recordData = '';
        let selectedRecordDetails = {};
        if (this.programRecordType === 'Core_MDF_Co_GTM') {
            selectedRecordDetails = this.records.find(record => record.Id === selectedId);
            recordData = selectedRecordDetails;
        }
        else if (this.programRecordType === 'Core_MDF_Intel_Partner_Alliance') {
        selectedRecordDetails = this.records.find(record => record.Id === selectedId);
        console.log('@@LOOKUP-selectedRecordDetails:', JSON.stringify(selectedRecordDetails));
        recordData = {
            Id: selectedId,
            virtualCorpId: selectedRecordDetails?.Core_MDF_Virtual_Corp_Account_Id__c || selectedId
            };
        console.log('@@LOOKUP-recordData:', JSON.stringify(recordData));
        }else {
            console.log('@@LOOKUP-else condition hit');
            recordData = selectedId;
        }

        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  recordData });
        this.dispatchEvent(valueSelectedEvent);

        this.isValueSelected = true;
        this.selectedId = selectedId;
        this.dispatchFlowAttributeChange('selectedId', selectedId);
        this.selectedName = selectedName;
        this.dispatchFlowAttributeChange('selectedRecordId', selectedId);
        this.dispatchFlowAttributeChange('selectedRecordName', selectedName);
        // Store the selected name in sessionStorage for retrieval on component reconnect
        sessionStorage.setItem('lookupSelectedName_' + selectedId, selectedName);
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
        
    }

    @api handleRemovePill(event) {
        //DE113818: Campaign is getting saved even though the account field is not valid
        const oldSelectedId = this.selectedId;
        this.selectedName = '';
        this.selectedId = undefined;
        this.dispatchFlowAttributeChange('selectedRecordId', undefined);
        this.dispatchFlowAttributeChange('selectedRecordName', undefined);
        this.dispatchFlowAttributeChange('selectedId', undefined);
        // Clear the stored name from sessionStorage
        if(oldSelectedId) {
            sessionStorage.removeItem('lookupSelectedName_' + oldSelectedId);
        }
        console.log('handleRemovePill called');
        if(!this.disabled) {
            this.isValueSelected = false;
            let selectedId = event.currentTarget.dataset.id;
            console.log('handleRemovePill called');
            const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
            this.dispatchEvent(valueSelectedEvent);
        }
    }

    onChange(event) {
        this.searchTerm = event.target.value;
    }

    //DE114317 - Devint3 | QA3 | Accounts are not showing up in the Account field when moving to the account field by clicking on Tab button
    onFocus() {
        this.handleClick();
    }

    dispatchFlowAttributeChange(attributeName, attributeValue) {
        this.dispatchEvent(new FlowAttributeChangeEvent(attributeName, attributeValue));
    }

    @api isValid() {
        if (this.required) {
            //DE113818: Campaign is getting saved even though the account field is not valid
            if(this.selectedName == ''||this.selectedName == null||this.selectedName == undefined){
                this.inputValid = false;
                this.accountError = this.searchTerm != ''? true : false;
            }
            else {
                this.inputValid = true;
            }
            return this.inputValid;
        } else {
            return true;
        }
    }

    // Flow screen validation hook (Flow calls validate(), not isValid()).
    @api validate() {
        if (!this.isValid()) {
            return { isValid: false, errorMessage: 'Please select a value from the list before continuing.' };
        }
        return { isValid: true };
    }

    //this will be called from recovery js when external user logged in and only 1 account is accessible
    @api selectAccountOnRecoveryIfOneAccOnly(event){
        if(event.length == 1){
            this.selectedRecord = event.at(0);
            if(this.selectedRecord != undefined && this.selectedRecord != null && this.selectedRecord != '') {
                this.selectedId = this.selectedRecord.accountId;
                this.selectedName = this.selectedRecord.accountName;
                this.isValueSelected = true;
            }
        }
    }

    //this will be called from recovery js when external user logged in and only 1 account is accessible
    @api selectPassedAccount(id,name){
        if(id !== null && name !==null){
            //this.selectedRecord = event.at(0);
            //if(this.selectedRecord != undefined && this.selectedRecord != null && this.selectedRecord != '') {
                this.selectedId = id;
                this.selectedName = name;
                this.isValueSelected = true;
            //}
        }
    }
}