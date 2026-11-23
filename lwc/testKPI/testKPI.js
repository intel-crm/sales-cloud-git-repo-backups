import { LightningElement, track, api } from 'lwc';
import getKPIAttributes from '@salesforce/apex/Core_MDF_KPI_FieldsController.getKPIValues';
import labelAppError from '@salesforce/label/c.Core_MDF_KPI_ErrorMsg';

export default class Core_MDF_KPI_Fields extends LightningElement {
    // Global Variables
    @api selectedValues = {};
    @api inputValues = {};
    @api showForm = false;

    //Local variables
    @track error = false;
    @track errorMsg = labelAppError;
    @track kpiValues = {};
    @track kpiVisibility = {};
    @track kpiPicValues = {};
    @track kpiLabels = {};
    @track loaded = true;
        
    // Hide the component if other then retail
    @api compVisibility() {
        // eslint-disable-next-line no-console
        console.log('inside compVisibility');
        //const isKpi;
        this.showForm = false;
        if (this.kpiVisibility != null) {
            // eslint-disable-next-line no-console
            console.log('inside if condition');
            // eslint-disable-next-line guard-for-in
            for (let key in this.kpiVisibility) {
                console.log('inside for loop');
                if (key != null && this.kpiVisibility[key] === true) {
                    this.showForm = true;
                    break;
                }
            }
        }
        // eslint-disable-next-line no-console
        console.log('this.showForm- '+this.showForm);
        const isKpi = this.showForm;
        // eslint-disable-next-line no-restricted-globals
        //this.fireKiEvent();
        // Creates the event with the contact ID data.
        const selectedEvent = new CustomEvent('kpiEvent', { detail : {isKpi}});

        // Dispatches the event.
        this.dispatchEvent(selectedEvent); 
        return this.showForm;
    }

fireKiEvent(){
    // eslint-disable-next-line no-console
    console.log('inside fireKiEvent');
    //event.preventDefault();

    // Creates the event with the contact ID data.
    const selectedEvent = new CustomEvent('kpiEvent', { isKpiVisible: this.showForm});

    // Dispatches the event.
    this.dispatchEvent(selectedEvent);  
}

    // Initilize the values
    connectedCallback() {
        this.loaded = false;
        //console.log('KPIconencted');
        const kpiconnected = new CustomEvent('kpiconnected', {
            value: true
        });
        this.dispatchEvent(kpiconnected);
    }

    // Global method will be called from parent component
    @api loadKPIAttributes(inputParams) {
        console.log('inside loadKPIAttributes'+inputParams);
        var isKpiVisible;
        this.inputValues = inputParams;
        this.loaded = false;
        //console.log('LoadKPICalled');
        getKPIAttributes({
            inputValues : JSON.stringify(inputParams)
        })
        .then(data => {
            console.log('KPI Fields data->' + data);
            this.loaded = true;
            this.kpiVisibility = data.visibility;
            this.kpiPicValues = data.picValues;
            this.kpiValues = data.recordValue;
            console.log('KPI Values>' + this.kpiValues);
            this.kpiLabels = data.labels;
            isKpiVisible = this.compVisibility();
            // eslint-disable-next-line no-console
            console.log('isKpiVisible - '+isKpiVisible);
        })
        .catch(e =>{
            console.log('error->' + e);
            console.log('error->' + e.message);
            console.log('error->' + e.name);
            this.loaded = true;
            this.error = true;
        })
        // eslint-disable-next-line no-console
        console.log('isKpiVisible - '+isKpiVisible);
    return isKpiVisible;
    }

    // Method to create properties for the local variable with required fields
    defineProp = function (obj, key, value) {
        var config = {
            value: value,
            writable: true,
            enumerable: true,
            configurable: true
        };
        Object.defineProperty(obj, key, config);
    };

    // Global method will be called from parent component to ready the selected values
    @api getKPIValues() {
        this.error = false;

        if (this.isFormValid())
        {
            try {
                // create required fields for the response object
                for (let key in this.kpiVisibility) {
                    if (key != null && this.kpiVisibility[key] === true) {
                        this.defineProp(this.selectedValues, (key + '__c'), null);
                    }
                }
                // Loop the pick list fields and read the values
                let comboElements = this.template.querySelectorAll("lightning-combobox");
                comboElements.forEach(element => {
                    if (element != null) {
                        this.setAttributeValues(element);
                    }
                });

                // loop the input fields and read the values
                let inputElements = this.template.querySelectorAll("lightning-input");
                inputElements.forEach(element => {
                    if (element != null) {
                        this.setAttributeValues(element);
                    }
                });
            } catch (error) {
                this.error = true;
            }
        }
        return this.selectedValues;
    }

    //Assign the selected values to response object
    setAttributeValues(element) {

        let eleValue = element.value;
        let eleName = element.name;

        for (let key in this.selectedValues) {
            if (key != null) {
                if (key === (eleName + '__c')) {
                    this.selectedValues[key] = eleValue;
                }
            }
        }
    }

    @api
    isFormValid(){
        var isValid = false;
        var allInputValid = false;
        var allComboValid = false;

        allInputValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        //console.log('checkValidity->' + inputCmp.checkValidity());
                        return validSoFar && inputCmp.checkValidity();
            }, true);

        allComboValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        //console.log('checkValiditycombo->' + inputCmp.checkValidity());
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        //console.log('allInputValid->' + allInputValid);
        //console.log('allComboValid->' + allComboValid);
        if (allInputValid && allComboValid){
            isValid = true;
        }
        return isValid;
    }

    renderedCallback(){
        this.setEditStatus();
    }
    setEditStatus(){
        
        //alert('kpi edit status->' + this.inputValues.enableKPI);
        // Loop the pick list fields and read the values
        let comboElements = this.template.querySelectorAll("lightning-combobox");
        comboElements.forEach(element => {
            if (element != null) {
                element.disabled = !this.inputValues.enableKPI;
            }
        });

        // loop the input fields and read the values
        let inputElements = this.template.querySelectorAll("lightning-input");
        inputElements.forEach(element => {
            if (element != null) {
                element.disabled = !this.inputValues.enableKPI;
            }
        });
    }
}