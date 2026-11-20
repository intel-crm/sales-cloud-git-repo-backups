/****************************************************************************************************************************************
* Component Name  : Core_MDF_Searchable_Dropdownlist
* Version     : 1.0 
* Created Date: 24-05-2022
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Sandesh H        24/05/2022                    Create to get Dropdown List with search functionality.
*****************************************************************************************************************************************/

import { LightningElement, api, track } from 'lwc';
import Core_MDF_SearchableDropdownListCSS from '@salesforce/resourceUrl/Core_MDF_SearchableDropdownListCSS';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class Core_MDF_Searchable_Dropdownlist extends LightningElement {
    @api inputDataList;  //Holding the Data List provided from Parent component
    @api fieldLabel = null; //Label of Input field
    @api isRequired = false; //Flag for required
    @api delay = 350; //Time delay for search component
    @api requiredMessage = 'Complete this field.'; //Field required Message
    @api defaultListMessage = 'No records found.'; //Message to display if inputDataList is empty
    @api placeHolder = null; // Placeholder of Input field
    @api selectedItemName = ''; // Default selected item Name
    @api fieldDisabled = false; //Flag for Disabled

    @track listItems; //Holding the list that is going to displayed on dropdown

    delaytimeout;
    showDropDown = false;
    hasListToDisplay = false;
    showSpinner = false;


    connectedCallback() {
        loadStyle(this, Core_MDF_SearchableDropdownListCSS);//To load css from static resource
    }

    //Method to open dropdown list, reset the field
    handleInputFieldClicked(event) {
        //check if field is not Disabled
        if (this.fieldDisabled != true) {
            this.resetParameters();
            //open the dropdown list
            this.showDropDown = true;
            //check if inputDataList is not empty
            if (this.inputDataList.length > 0) {
                //Flag for List to display
                this.hasListToDisplay = true
            } else {
                this.hasListToDisplay = false;
            }
        }
    }

    //This method will dispatch the field clear event to parent in case any dependent field can be cleared or changed
    handleOnInputValueChanged(event) {
        //getting input field value
        const inputFieldValue = event.target.value;
        //find the input field
        let searchInputField = this.template.querySelector('.searchBox');
        //check if field is not Disabled
        if (this.fieldDisabled != true) {
            //check if inputDataList is not empty
            if (inputFieldValue == null || inputFieldValue == '') {
                this.dispatchEvent(new CustomEvent('inputFieldValueClear'));
                //check if field in required
                if (this.isRequired == true) {
                    //show custom required field message
                    searchInputField.setCustomValidity(this.requiredMessage);
                    searchInputField.reportValidity();
                }
            }
        }
    }

    //Method to handle key press on input field
    handleKeyPress(event) {
        //getting input field value
        const searchKey = event.target.value;
        //this.setInputValue(searchKey);
        //check delay time out
        if (this.delaytimeout) {
            window.clearTimeout(this.delaytimeout);
        }
        //check if inputDataList is not empty
        if (this.inputDataList.length > 0) { //
            this.delaytimeout = setTimeout(() => {
                //filter dropdown list based on search key parameter
                this.filterDropdownList(searchKey);
            }, this.delay);
        }
    }

    //Method to filter dropdown list
    filterDropdownList(key) {
        //check if key is not null
        if (key != null && key != '' && this.inputDataList.length > 0) {
            //filter the input list based on key
            const filteredInputDataList = this.inputDataList.filter(item => item.Name.toLowerCase().includes(key.toLowerCase()));
            this.listItems = filteredInputDataList;
        }
    }

    //Method to handle selected item from listbox
    itemListSelectHandler(event) {
        //get selected Id and Name from List
        const selectedId = event.target.closest('li').dataset.value;
        const selectedName = event.target.closest('li').dataset.label;
        //set selected Name to Input field
        this.setInputValue(selectedName);
        //closed the dropdown list
        this.showDropDown = false;
        //array to store selected Id and Name
        const selectedItem = {};
        selectedItem["Id"] = selectedId;
        selectedItem["Name"] = selectedName;
        //dispatch event to send selected data to parent component
        this.dispatchEvent(new CustomEvent('selectedItem', { detail: { selectedItem } }));
    }

    //Method to reset necessary properties
    resetParameters() {
        this.setInputValue("");
        //set inputDataList to listItem to display in Listbox
        this.listItems = this.inputDataList;
        //find the input field
        let searchInputField = this.template.querySelector('.searchBox');
        //check if field in required
        if (this.isRequired == true) {
            //check if input field is empty
            if (this.selectedItemName == '') {
                //show custom required field message
                searchInputField.setCustomValidity(this.requiredMessage);
            }
            searchInputField.reportValidity();
        }

    }

    //Method to set itemName to Input Field
    setInputValue(itemName) {
        this.selectedItemName = itemName;
    }

    //Method to toggle dropdown state
    toggleDropDown() {
        if (this.showDropDown) {
            this.showDropDown = false;
        }
    }

    //getter setter for dropDownClass
    get dropDownClass() {
        return (this.showDropDown ? "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open" : "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click");
    }

    //Method to reset the input field value
    @api
    inputClearValue() {
        this.selectedItemName = "";
    }

    //check if Dropdown list is selected
    validateInputField() {
        //find the input field
        let searchInputField = this.template.querySelector('.searchBox');
        //check if field in required
        if (this.isRequired == true) {
            //check if input field is not empty
            if (this.selectedItemName != '') {
                //remove custom required field message
                searchInputField.setCustomValidity("");
            }
            searchInputField.reportValidity();
        }
    }
}