import { LightningElement, track, api } from 'lwc';
import labelCompleteThisFieldError from '@salesforce/label/c.Core_MDF_CompleteThisField_ErrorMessage';
import Core_MDF_MultiSelectPicklistCSS from '@salesforce/resourceUrl/Core_MDF_MultiSelectPicklistCSS';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class core_MDF_MultiSelectPicklist extends LightningElement {
    @api
    values = [];
    @track
    selectedvalues = [];
    @track budgetValues = [];
    @track selectionFlagFromPicklistComponent;
    @api required;
    @track disablePickilst = false;
    @api
    picklistlabel;
    showdropdown;
    @api noOfValuesGotSelectedLable;
    @api selectedValueCount;
    //@api enableRequired;
    @track enableRequired = false; // By defualt required will be false
    @api isRequired; // Pass the value when you call the component if it is required field
    @api placeholderText;
    @api utilisedModule;
    @track displayValues = false;
    selectedValuesArrayObj = [];

    label = {
        labelCompleteThisFieldError
    };

    handleleave() {
        let sddcheck = this.showdropdown;

        if (sddcheck) {
            this.showdropdown = false;
            this.fetchSelectedValues();
        }
    }

    connectedCallback() {
        loadStyle(this, Core_MDF_MultiSelectPicklistCSS);
        this.showdropdown = false;
        this.enableRequired = this.isRequired;
        console.log('showDropDown in connectedcall' + JSON.stringify(this.showdropdown));
        this.values.forEach(element => element.selected
            ? this.selectedvalues.push(element.value) : '');
        this.enableRequired = this.isRequired;
        this.placeholderText = this.placeholderText;
    }

    @api fetchSelectedValues() {
        this.selectedvalues = [];
        this.budgetValues = [];
        this.selectedValuesArrayObj = [];

        //get all the selected values
        this.template.querySelectorAll('c-core_-m-d-f_-campaign_-picklist_-selection').forEach(
            element => {
                if (element.selected) {
                    console.log('Awesome' + element.label);
                    let obj = { label: element.label, value: element.value };
                    this.budgetValues = [... this.budgetValues, obj];
                    this.selectedvalues.push(element.value);
                    let obj1 = {label: element.label, selected: element.selected, value: element.value, questionCode: element.questionCode, originalFileName: element.originalFileName, parentQueCode: element.parentQuestionCode};
                    this.selectedValuesArrayObj.push(obj1);
                } else {
                    let obj1 = {label: element.label, selected: element.selected, value: element.value, questionCode: element.questionCode, originalFileName: element.originalFileName, parentQueCode: element.parentQuestionCode};
                    this.selectedValuesArrayObj.push(obj1);
                }
            }
        );
        console.log('this.selectedvalues' + this.selectedvalues);
        //refresh original list
        this.refreshOrginalList();
    }

    @api refreshOrginalList() {
        const picklistvalues = this.values.map(eachvalue => ({ ...eachvalue }));

        picklistvalues.forEach((element, index) => {
            if (this.selectedvalues.includes(element.value)) {
                picklistvalues[index].selected = true;
            } else {
                picklistvalues[index].selected = false;
            }
        });
        this.values = picklistvalues;

    }

    @api clear() {
        const picklistvalues = this.values.map(eachvalue => ({ ...eachvalue }));

        picklistvalues.forEach((element, index) => {
            picklistvalues[index].selected = false;
        });
        this.values = picklistvalues;
        this.selectedvalues = [];
        this.selectedValuesArrayObj = [];

    }

    handleShowdropdown() {
        let sdd = this.showdropdown;
        console.log('this.showdropdown' + this.showdropdown);
        if (sdd) {
            this.showdropdown = false;
            this.fetchSelectedValues();
        } else {
            this.showdropdown = true;
        }
    }

    get selectedmessage() {
        if (this.selectedvalues.length) {
            let displayMessage = '';
            if (this.enableRequired) {
                this.isValid();
            }
            console.log('displayValues'+this.displayValues);
            if(this.displayValues){
                displayMessage = this.selectedvalues.length + ' ' + this.selectedvalues;
            }
            else{
                displayMessage = this.selectedvalues.length + ' ' + this.noOfValuesGotSelectedLable;
            }
            console.log('displayMessage'+displayMessage);
            return displayMessage;
        }
    }

    @api populateSelectedMessage(value) {
        this.selectedvalues.length = value;
    }
    @api disablePickilstMethod() {
        this.disablePickilst = true;
        this.enableRequired = false;
    }
    @api enablePickilstMethod() {
        this.disablePickilst = false;
        console.log('this.values3..' + JSON.stringify(this.values));
        if(this.utilisedModule == 'Claim'){
            this.enableRequired = false;
        console.log('this.values1..' + JSON.stringify(this.values));

        } else {
            this.enableRequired = true;
        console.log('this.values2..' + JSON.stringify(this.values));        
        }
    }
    onPicklistSelection(event) {
        this.fetchSelectedValues();
        const value = this.selectedvalues;
        const valueObj = this.selectedValuesArrayObj;
        //const selectedFile = this.selectedFiles;
        console.log('lwc event value', value)
        const valueChangeEvent = new CustomEvent('ValueSelection', {
            detail: { value }
        });
        const valueChangeLWCEvent = new CustomEvent('select', {
            detail: { value:  value}
        });
        const valueChangeLWCEventForPIC = new CustomEvent('select', {
            detail: { valueObj }
        });
       /* const valueChangeLWCEventForMOU = new CustomEvent('filterselection', { //Added by Alekhya for MOU testing
            detail: { value }
        });*/
        this.dispatchEvent(valueChangeEvent);
        if(this.utilisedModule === 'Claim') {
            this.dispatchEvent(valueChangeLWCEventForPIC);
        }
        /*else if(this.utilisedModule === 'MOU'){ //Added by Alekhya for MOU testing
            this.dispatchEvent(valueChangeLWCEventForMOU);
        }*/
        else {
            this.dispatchEvent(valueChangeLWCEvent);
        }
    }

    @api isValid() {
        const availableBudgetsCmp = this.template.querySelector(".availableBudgetsCmp");
        let isValid;
        if (!this.disablePickilst && this.selectedvalues.length === 0) {
            let errorMess = this.label.labelCompleteThisFieldError; //'Complete this field';
            //availableBudgetsCmp.setCustomValidity("Complete this field.");
            availableBudgetsCmp.setCustomValidity(errorMess);
            isValid = false;
        }
        else {
            availableBudgetsCmp.setCustomValidity('');
            isValid = true;
        }
        Promise.resolve().then(() => {
            availableBudgetsCmp.reportValidity();
        })
        return isValid;
    }
}