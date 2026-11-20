import { api, LightningElement, track, wire } from 'lwc';
import lookUp from '@salesforce/apex/Core_MDF_CampaignCreatePage.searchParentAcc'; //to search parent account

export default class Core_MDF_ParentAccountLookup extends LightningElement {

    @api objName;
    @api label;
    @api required;
    @api iconName;
    @api filter = '';
    @api searchPlaceholder='Search';
    @api selectedRecord;
    @api disabled;

    @track selectedId;
    @track selectedName;
    @track records;
    @track isValueSelected;
    @track blurTimeout;

    searchTerm;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    @track inputValid = false;

    @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName', filter : '$filter'})
    wiredRecords({ error, data }) {
        if (data) {
            this.error = undefined;
            this.parentAccList = data;        
            this.records = data;
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
        if(this.selectedRecord != undefined && this.selectedRecord != null && this.selectedRecord != '') {
            this.selectedId = this.selectedRecord.Id;
            this.selectedName = this.selectedRecord.Name;
            this.isValueSelected = true;
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
            this.inputValid = false;
        }
        else{
            this.inputValid = true;
        }
    }

    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;

        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedId = selectedId;
        this.selectedName = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
        
    }

    @api handleRemovePill(event) {
        //DE113818: Campaign is getting saved even though the account field is not valid
        this.selectedName = '';
        if(!this.disabled) {
            this.isValueSelected = false;
            let selectedId = event.currentTarget.dataset.id;
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

    @api isValid() {
        if (this.required) {
            //DE113818: Campaign is getting saved even though the account field is not valid
            if(this.selectedName == ''||this.selectedName == null||this.selectedName == undefined){
                this.inputValid = false;
            }
            else {
                this.inputValid = true;
            }
            return this.inputValid;
        } else {
            return true;
        }
    }
}