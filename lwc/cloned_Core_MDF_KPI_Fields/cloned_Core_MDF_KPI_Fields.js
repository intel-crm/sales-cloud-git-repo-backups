import { LightningElement, track, api } from 'lwc';
import getKPIAttributes from '@salesforce/apex/Core_MDF_KPI_FieldsController.getKPIValues';
import labelAppError from '@salesforce/label/c.Core_MDF_KPI_ErrorMsg';

export default class Cloned_Core_MDF_KPI_Fields extends LightningElement {
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
    @track storePercentageofPotentialWinner = ''; //to store potential winner/ number expected percentage
    @track cmpPotentialExpected = true;

   //US917622 - opal changes potential winner/number of expected -start 
    @track inputValueObject = {
    Core_MDF_Num_of_Potential_Winners_nbr  : null,
    Core_MDF_No_of_Expected_Participants_nbr  : null,                     
    };
     //US917622 - opal changes potential winner/number of expected -end 

    // Hide the component if other then retail
    @api compVisibility() {
        this.showForm = false;

        if (this.kpiVisibility != null) {
            for (let key in this.kpiVisibility) {
                if (key != null && this.kpiVisibility[key] === true) {
                    this.showForm = true;
                    break;
                }
            }
        }

        // Send the event to parent control to control the visibility logic
        const isKpiApplicable = this.showForm;
        const kpiCompVisibilityEvent = new CustomEvent('kpiCompVisibilityEvent', { detail: { isKpiApplicable } });
        this.dispatchEvent(kpiCompVisibilityEvent);

        return this.showForm;
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

        this.inputValues = inputParams;
        this.loaded = false;
        //console.log('LoadKPICalled');
        getKPIAttributes({
            inputValues: JSON.stringify(inputParams)
        })
            .then(data => {
                //console.log('KPI Fields data->' + data);
                this.loaded = true;
                this.kpiVisibility = data.visibility;
                this.kpiPicValues = data.picValues;
                this.kpiValues = data.recordValue;
                this.kpiLabels = data.labels;
                this.compVisibility();
            })
            .catch(e => {
                console.log('error->' + e);
                console.log('error->' + e.message);
                console.log('error->' + e.name);
                this.loaded = true;
                this.error = true;
            })

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

        if (this.isFormValid()) {
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

                let txtAreaElements = this.template.querySelectorAll("lightning-textarea");
                txtAreaElements.forEach(element => {
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
    isFormValid() {
        var isValid = false;
        var allInputValid = false;
        var allComboValid = false;
        var allTextAreaValid = false;

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

        allTextAreaValid = [...this.template.querySelectorAll('lightning-textarea')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                //console.log('checkValiditycombo->' + inputCmp.checkValidity());
                return validSoFar && inputCmp.checkValidity();
            }, true);
        //console.log('allInputValid->' + allInputValid);
        //console.log('allComboValid->' + allComboValid);
        if (allInputValid && allComboValid && allTextAreaValid) {
            isValid = true;
        }
        return isValid;
    }

    renderedCallback() {
        this.setEditStatus();
    }
    setEditStatus() {

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

        let txtAreaElements = this.template.querySelectorAll("lightning-textarea");
        txtAreaElements.forEach(element => {
            if (element != null) {
                element.disabled = !this.inputValues.enableKPI;
            }
        });
    }

    @api
    isMetricFieldModified(metricsNewValues) {
        let newKPIValues = metricsNewValues; // metricsNewValues - new metrics values
        let oldKPIValues = this.kpiValues;  // this.kpiValues - old metrics values
        let isMetricFieldUpdated = false; 

        for (let newKey in newKPIValues) {
            for(let oldKey in oldKPIValues) { 
                if((oldKey+'__c' == newKey) && oldKPIValues[oldKey] != newKPIValues[newKey]) {
                    isMetricFieldUpdated = true;
                    break;
                }
            }
        }
 
        return isMetricFieldUpdated;
    }

    // restrict e,+,-,E characters in  input type number
    isNumericOnly(event) { 
        const charCode = (event.which) ? event.which : event.keyCode;
        
        if (charCode == 101 || charCode == 69 || charCode == 45 || charCode == 43 || charCode == 46) {
            event.stopPropagation();
            event.preventDefault();
            return false;
        }
        return true;
    }
//US917622 - opal changes potential winner/number of expected -start 
callPotentialCheck(event){
    let inputElements = this.template.querySelectorAll("lightning-input");
    inputElements.forEach(element => {
        if(element != null){
            this.inputValueObject[element.name] = element.value;                
        }
    });
    if(event.target.name === 'Core_MDF_Num_of_Potential_Winners_nbr'  || event.target.name === 'Core_MDF_No_of_Expected_Participants_nbr'){
    let potentWinn = '';
    let expNum = '';
    let calPer = '';
    
    if(event.target.name === 'Core_MDF_Num_of_Potential_Winners_nbr') {
        potentWinn =parseFloat(event.target.value);
    }else if(this.inputValueObject.Core_MDF_Num_of_Potential_Winners_nbr !== null && this.inputValueObject.Core_MDF_Num_of_Potential_Winners_nbr !== undefined){
        potentWinn = parseFloat(this.inputValueObject.Core_MDF_Num_of_Potential_Winners_nbr);
    }
    if(event.target.name === 'Core_MDF_No_of_Expected_Participants_nbr') {
        expNum = parseFloat(event.target.value);
    }else if(this.inputValueObject.Core_MDF_No_of_Expected_Participants_nbr !== null && this.inputValueObject.Core_MDF_No_of_Expected_Participants_nbr !== undefined){
        expNum = parseFloat(this.inputValueObject.Core_MDF_No_of_Expected_Participants_nbr);
    }
    if(( isNaN(potentWinn) == false ) && (isNaN(expNum) == false )){
        console.log('expNum1'+expNum);
        console.log('potentWinn1'+potentWinn);
        if(expNum >= potentWinn){
            this.storePercentageofPotentialWinner = '';
            calPer = parseFloat((potentWinn / expNum) * 100 );
            this.storePercentageofPotentialWinner = calPer;
            this.cmpPotentialExpected = true;
        }
        else{
            this.cmpPotentialExpected = false; //set to false if potential winner is greater then expected number
        }
    }
}
}

@api
checkValidationPotentialWinners() {
    let inputElements = this.template.querySelectorAll("lightning-input");
    if(inputElements.length == 0){
        this.storePercentageofPotentialWinner = '';
        this.cmpPotentialExpected =true;
    }
    let isMetricPotentialWinnerCheck = ''; 
    if(this.storePercentageofPotentialWinner !== '' && this.cmpPotentialExpected === true ){
        if(this.storePercentageofPotentialWinner > 33){
            isMetricPotentialWinnerCheck = 'perExceedError'; 
        }
    }else if(this.cmpPotentialExpected === false){
        isMetricPotentialWinnerCheck = 'noExpPotCheck';
    }
    return isMetricPotentialWinnerCheck;
}
//US917622 - opal changes potential winner/number of expected -end 

}