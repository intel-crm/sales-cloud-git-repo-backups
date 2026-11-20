import { LightningElement, api, track } from 'lwc';
import No_Consumption_Values_Message from '@salesforce/label/c.Pricing_No_Consumption_Values_Message';

export default class PricingMultiSelectPicklistLwc extends LightningElement {
    @track displayText = '';
    @track selectedValues = [];
    @track optionData = [];
    @track optionDataCopy = [];
    @track showDropdown = false;
    @track showTitle = '';
    @track searchKey = '';
    @track isDisabledTxt = false;
    @track NoConsumptionValuesMessage = No_Consumption_Values_Message;

    noSearchResult = false;

    @api isDisabled;
    @api helpText;
    @api label;
    @track isChanged = true;
    @track counter = 0;

    @api
    get values() {
        return this.selectedValues;
    }
    set values(value) {
        this.selectedValues = value;
        this.setOptionValues();
    }

    @api
    get options() {
        return this.optionData;
    }
    set options(value) {
        if (Array.isArray(value)) {
            this.optionData = [...value];
        }
    }

    // this method will set picklist Options value
    setOptionValues() {
        this.counter++;
        const optionData = this.optionData ? JSON.parse(JSON.stringify(this.optionData)) : [];
        let valuesStr = this.selectedValues !== null && this.selectedValues !== undefined && this.selectedValues !== '' ? JSON.parse(JSON.stringify(this.selectedValues)) : [];
        let values = [];
        if(typeof valuesStr === "string"){
            let remainingValues = valuesStr.replace(/,\s*/g, ',');
            const optionValues = optionData
                .map(option => ({ value: option.value.replace(/,\s*/g, ','), original: option.value }))
                .sort((first, second) => second.value.length - first.value.length);
            while (remainingValues) {
                const match = optionValues.find(option =>
                    remainingValues === option.value || remainingValues.startsWith(`${option.value},`)
                );
                if (!match) {
                    const separatorIndex = remainingValues.indexOf(',');
                    if (separatorIndex === -1) break;
                    remainingValues = remainingValues.substring(separatorIndex + 1);
                    continue;
                }
                values.push(match.original);
                remainingValues = remainingValues.substring(match.value.length);
                if (remainingValues.startsWith(',')) remainingValues = remainingValues.substring(1);
            }
        }else{
            values = JSON.parse(JSON.stringify(valuesStr));
        }
        let selectedValues = [];
        if (values.length > 0) {
            optionData.forEach(option => {
                if (values.includes(option.value)) { // checking do we have active Option to checkmark(SELECT) from SELECTED VALUes
                    option.selected = true;
                    this.isChanged = true;
                    selectedValues.push(option.value);
                }
            });
            this.displayText = String(selectedValues);
        }
        this.optionData = optionData;
        this.selectedValues = JSON.parse(JSON.stringify(selectedValues));
        if (this.counter < 5 && this.isChanged && (this.optionData != [] || this.optionData != '' || this.optionData != null) && this.optionData.length > 0) {
            this.dispatchEvent(new CustomEvent('loadvalue', { detail: this.selectedValues.length > 0 ? this.selectedValues : [] }));
            this.isChanged = false;
        }
        this.searchLogic();
    }

    renderedCallback() {
        this.isDisabledTxt = (this.displayText == '' || this.displayText == undefined) && this.isDisabled ? true : false;
    }

    // handle event on click of picklist option and send selected value to parent comp 
    selectItem(event) {
        const selectedVal = event.currentTarget.dataset.id;
        if (selectedVal) {
            const options = JSON.parse(JSON.stringify(this.optionData));
            let any = [];
            options.forEach(option => {
                if (option.value === selectedVal) {
                    option.selected = !option.selected;
                }
                if (option.selected) {
                    any.push(option.value);
                }
            });
            this.optionData = options;
            this.optionDataCopy = options;
            this.sendValues();
            this.displayText = any;
            event.preventDefault();
        }
    }

    // this method will display availbale picklist option values 
    showOptions() {
        if (this.isDisabled === false && this.optionData) {
            const options = JSON.parse(JSON.stringify(this.optionData));
            options.forEach(option => {
                option.isVisible = true;
            });
            if (options.length > 0) {
                this.showDropdown = true;
            }
            this.optionData = options;
        }
    }

    // handle dropdown visibility
    handleBlur() {
        this.showDropdown = false;
    }

    // dispatch event and send picklist values to parent comp
    sendValues() {
        const values = this.optionData.filter(option => option.selected).map(option => option.value);
        this.dispatchEvent(new CustomEvent('valuechange', { detail: values }));
    }

    //this function is used to filter/search the dropdown list based on user input
    handleSearch(event) {
        this.searchKey = event.target.value;
        this.searchLogic();
    }

    // search logic 
    searchLogic() {
        if (this.searchKey === '' || this.searchKey === ' ' || this.searchKey === null || this.searchKey === undefined) {
            this.optionDataCopy = this.optionData;
        }
        if (this.searchKey.length > 0) {
            this.optionDataCopy = this.optionData.filter(option => option.label.toLowerCase().includes(this.searchKey.toLowerCase()));
            this.optionDataCopy.length > 0 ? this.noSearchResult = false : this.noSearchResult = true;
        } else {
            this.optionDataCopy = this.optionData;
        }
    }

}