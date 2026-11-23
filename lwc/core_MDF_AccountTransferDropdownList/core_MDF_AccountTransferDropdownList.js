import {LightningElement,api, track } from 'lwc';
const delay = 350;
import getSearchableList from '@salesforce/apex/Core_MDF_SearchableDropdownList.getSearchableList';
export default class Core_MDF_AccountTransferDropdownList extends LightningElement {

    //api fields
    @api sObjectAPIName;
    @api qureyFields;
    @api filterCriteria;
    @api fieldLabel = null;
    
    inputList; //options is accountList
    @track inputListToDisplay; //optionsToDisplay is accountListToDisplay

    //@track contacts;
    @track error;

    recordId; //value is accountId
    recordName; // label is accountName
    delaytimeout;
    showDropDown = false;
    hasListToDisplay = false;

    //@track options;

    connectedCallback(){ 
        getSearchableList({sObjectAPIName : this.sObjectAPIName,
            fieldsToReturn : this.qureyFields,
            whereClause : this.filterCriteria})
            .then(result => {
                this.inputList = result;
            })
            .catch(error => {
                this.error = error;
            });
     }

    //Method open dropdown list & reset the field
    handleInputClick(event) {
        //this.handleLoad();
        this.resetParameters();
        this.toggleDropDown();
        if(this.inputList != null && this.inputList != '') {
             this.hasListToDisplay = true
        } else {
             this.hasListToDisplay = false;
        }
    }

    //Method to handle key press on text input
    handleKeyPress(event) {
        const searchKey = event.target.value;
        this.setInputValue(searchKey);
        if (this.delaytimeout) {
            window.clearTimeout(this.delaytimeout);
        }
        if(this.inputList != null && this.inputList != ''){
            this.delaytimeout = setTimeout(() => {
                    //filter dropdown list based on search key parameter
                this.filterDropdownList(searchKey);
            }, delay);
        }
    }

    //Method to filter dropdown list
    filterDropdownList(key) {
        const filteredOptions = this.inputList.filter(item => item.objectLabel.toLowerCase().includes(key.toLowerCase()));
        this.inputListToDisplay = filteredOptions;
    }

    //Method to handle selected Account List in listbox
    optionListClickHandler(event) {
        const selectedId = event.target.closest('li').dataset.value;
        const selectedName = event.target.closest('li').dataset.label;
        this.setValues(selectedId, selectedName);
        this.toggleDropDown();
        const selectedSObject = {};
        selectedSObject["Id"] = selectedId;
        selectedSObject["Name"] = selectedName;
        this.dispatchEvent(new CustomEvent('select', { detail: {selectedSObject} }));
    }

    //Method to reset necessary properties
    resetParameters() {
        this.setInputValue("");
        this.inputListToDisplay = this.inputList;
    }

    //Method to set inputValue for search input box
    setInputValue(value) {
        this.recordName = value;
    }

    //Method to set AccountName and Account Id based on the parameter
    setValues(value, label) {
        this.recordName = label;
        this.recordId = value;
    }

    //Method to toggle dropdown state
    toggleDropDown() {
        if(this.showDropDown) {
            this.showDropDown = false;
        } else {
            this.showDropDown = true;
        }
    }
    
    //getter setter for dropDownClass
    get dropDownClass() {
        console.log('this.showDropDown-> '+this.showDropDown);
        return (this.showDropDown ? "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open" : "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click");
    }

    //Method to reset the Account Name
    @api
    lwcComponentClear(){
            this.recordName = "";
    }

    checkForToAccount() {
        //const ele = document.getElementById('toAccount');
        let toSObject = this.template.querySelector('.toSObject');
        //console.log("toAccount", toAccount.value);
        if(this.recordName == "") {
            toSObject.setCustomValidity('complete this field');
        } else {
            toSObject.setCustomValidity('');
        }
        toSObject.reportValidity();
       console.log('ele by Id', toSObject);
    }

    handleleave() {
        if(this.showDropDown) {
            this.showDropDown = false;
        }
    }
}