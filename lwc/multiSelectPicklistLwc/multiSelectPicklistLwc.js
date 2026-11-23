import { LightningElement, api, track } from 'lwc';

export default class MultiSelectPicklistLwc extends LightningElement {
    @track displayText = '';
    @track selectedValues = [];
    @track optionData = [];
    @track optionDataCopy = [];
    @track showDropdown = false;
    @track showTitle = '';
    @track searchKey = '';

    @api isDisabled;

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

    setOptionValues() {
        //this.showDropdown = false;
        const optionData = this.optionData ? JSON.parse(JSON.stringify(this.optionData)) : [];
        const values = this.selectedValues ? JSON.parse(JSON.stringify(this.selectedValues)) : [];
        if (values.length > 0) {
            let any = [];
            optionData.forEach(option => {
                if (values.includes(option.value)) {
                    option.selected = true;   
                    any.push(option.value);
                }
            });
            
            this.displayText = String(any);
        }
        this.selectedValues = values;
        this.optionData = optionData;
        this.searchLogic();
        
    }

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

    handleBlur() {
        this.showDropdown = false;
    }

    sendValues() {
        const values = this.optionData
            .filter(option => option.selected)
            .map(option => option.value);
        this.dispatchEvent(new CustomEvent('valuechange', {
            detail: values
        }));
    }

    //this function is used to filter/search the dropdown list based on user input
    handleSearch(event) {
        let any  = event.target.value.toLowerCase();
        this.searchKey = any.toLowerCase();
        this.searchLogic();        
    }

    searchLogic(){
        if(this.searchKey === '' || this.searchKey === ' ' || this.searchKey === null || this.searchKey === undefined){
            this.optionDataCopy = this.optionData;
        }
        if(this.searchKey.length > 0){
            this.optionDataCopy = this.optionData.filter(option => option.label.toLowerCase().includes(this.searchKey));
        }else{
            this.optionDataCopy = this.optionData;
        }
    }

}