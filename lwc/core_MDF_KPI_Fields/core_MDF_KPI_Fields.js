import { LightningElement, track, api } from 'lwc';
import getKPIAttributes from '@salesforce/apex/Core_MDF_KPI_FieldsController.getKPIValues';
import labelAppError from '@salesforce/label/c.Core_MDF_KPI_ErrorMsg';
import IPAProgramLabel from '@salesforce/label/c.Core_MDF_IPA_Program_Name';
import pfcObjectName from '@salesforce/label/c.Core_MDF_PFCText';
import {OLD_KPI_FIELDS_ALL} from 'c/core_MDF_utilityModule';
import othersHelpText from '@salesforce/label/c.Core_MDF_KPI_Others_Help_Text';
import decimalError from '@salesforce/label/c.Core_MDF_KPI_Decimal_Error';
import numberError from '@salesforce/label/c.Core_MDF_KPI_Number_Error';
import logErrorImperative from '@salesforce/apex/Core_MDF_KPIDetailPage.logErrorImperative'; //Unhandeled Exception fix added by Shravani


export default class Core_MDF_KPI_Fields extends LightningElement {
    // Global Variables
    @api selectedValues = {};
    @api inputValues = {};
    @api showForm = false;
    @api ipaclone;
    @api ipaclonemetricsvalue;
    @api isProposalBased;
    @api recordId;
    @api isProposalBasedActivity;
    @api isNEXActivity;
    @api kpiQtyFieldValuesFromAct;
    @api clearedOnClone;
    @api decimalApplicable;
    @api mode;



    //Local variables
    @track error = false;
    @track errorMsg = labelAppError;
    @track IPAProgram = IPAProgramLabel;
    @track kpiValues = {};
    @track kpiVisibility = {};
    @track kpiPicValues = {};
    @track kpiLabels = {};
    @track kpiRequiredFields = {};
    @track loaded = true;
    @track storePercentageofPotentialWinner = ''; //to store number of winner/store potential winner
    @track cmpPotentialExpected = true;
    @track isEOLedFields = {};
    @track kpiDisabledFields = {};
    pfcObjectName = pfcObjectName;
    @track othersHelpText = othersHelpText;
    @track decimalError = decimalError;
    @track numberError = numberError;
    objectName;
    program;


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
        //enable this for IPA outcome based in future - AI PIC
        if (this.objectName == this.pfcObjectName && isKpiApplicable && this.program !== this.IPAProgram) {
            //VB -> To get Initial values
            let kpiFieldsAndValMap = {};
            if (this.kpiVisibility != null && this.kpiVisibility != undefined && this.kpiVisibility != '') {
                for (let key in this.kpiVisibility) {
                    if (this.kpiVisibility[key] == true) {
                        let kpiVal = this.kpiValues[key] == undefined ? '' : this.kpiValues[key];
                        kpiFieldsAndValMap[key+'__c'] = kpiVal;
                    }
                }
            }
            const kpiDetailsOnLoad = new CustomEvent('kpiFieldDetailsOnLoad', { detail: { kpiFieldsAndValMap } });
            this.dispatchEvent(kpiDetailsOnLoad);
        }


        const kpiCompVisibilityEvent = new CustomEvent('kpiCompVisibilityEvent', { detail: { isKpiApplicable } });
        this.dispatchEvent(kpiCompVisibilityEvent);

        return this.showForm;
    }

    // Initilize the values
    connectedCallback() {
        this.loaded = false;
        const kpiconnected = new CustomEvent('kpiconnected', {
            value: true
        });
        this.dispatchEvent(kpiconnected);
    }

    // Global method will be called from parent component
    @api loadKPIAttributes(inputParams) {

        this.inputValues = inputParams;
        this.objectName = inputParams.objName;
        this.program = inputParams.program;
        this.loaded = false;
        //console.log('LoadKPICalled');
        getKPIAttributes({
            inputValues: JSON.stringify(inputParams)
        })
            .then(data => {
                //console.log('KPI Fields data->' + data);
                this.loaded = true;
                this.error = false;
                this.kpiVisibility = Object.create(data.visibility);
                this.kpiPicValues = data.picValues;

                this.kpiLabels = data.labels;
                /* US1017582: Technical: [RMF] - [Activity] - Metrics to be made optional - start */
                const metaDataValues = data.metaDataValues;
                this.kpiValues = data.recordValue;
                const selValuesOnActivity = data.activityRecValue;//Used in case of edit claim
                this.mdfKpiVisibility = {};
                if(metaDataValues !== undefined && metaDataValues !== null && metaDataValues !== '') {
                    var kpiVisibilityClone = JSON.parse(JSON.stringify(data.visibility));
                    for (let index = 0; index < metaDataValues.length; index++) {
                        const fieldAPIName = metaDataValues[index].Core_MDF_Field_4_txt__c;
                        const fieldName = metaDataValues[index].Core_MDF_Field_4_txt__c.replace('__c', '');
                        if (this.inputValues.objName === this.pfcObjectName && this.inputValues.program === this.IPAProgram) {
                            //Added by VB - IPA KPI Metrics
                            //Create, Clone,Edit - Holds values from activity
                            const isFieldValPresentOnAct = this.validateValSelection(selValuesOnActivity, fieldName);
                            if (OLD_KPI_FIELDS_ALL.includes(fieldAPIName)) {
                                this.mdfKpiVisibility[fieldName] = isFieldValPresentOnAct ? true : false;
                                this.kpiVisibility = this.mdfKpiVisibility;
                                this.kpiRequiredFields[fieldAPIName] = isFieldValPresentOnAct ? true : false;
                            } else {
                                this.mdfKpiVisibility[fieldName] = true;
                                this.kpiVisibility = this.mdfKpiVisibility;
                                this.kpiRequiredFields[fieldAPIName] = isFieldValPresentOnAct ? true : false;
                            }
                        } else {
                            this.kpiRequiredFields[metaDataValues[index].Core_MDF_Field_4_txt__c] = metaDataValues[index].Core_MDF_Checkbox_Field_7_Ind__c;

                        }
                        if (metaDataValues[index].Core_MDF_Checkbox_Field_6_Ind__c) {
                            this.isEOLedFields[fieldName] = fieldAPIName;
                        }
                    }

                    //changes for IPA KPI Metrics - commented above if and added below if
                    if (this.clearedOnClone) {
                        var recordValueClone = {};
                        for (var key in data.recordValue) {
                            recordValueClone[key] = '';
                        }
                        this.kpiValues = recordValueClone;
                    } else {
                        this.kpiValues = data.recordValue;
                    }

                    if (Object.keys(this.isEOLedFields).length > 0) {

                        for(var key in this.isEOLedFields){
                            kpiVisibilityClone[key] = false;
                        }

                        for (var key in data.recordValue) {
                            if (this.mode == 'edit') {
                                if (this.isEOLedFields.hasOwnProperty(key) && data.recordValue[key] != "" && data.recordValue[key] != null && data.recordValue[key] != undefined) {
                                    this.kpiDisabledFields[key] = true;
                                    kpiVisibilityClone[key] = true;
                                }
                                else {
                                    this.kpiDisabledFields[key] = false;
                                }
                            }
                            else {
                                if (this.isEOLedFields.hasOwnProperty(key)) {
                                    kpiVisibilityClone[key] = false;
                                }
                                else {
                                    if (kpiVisibilityClone[key] == true) {
                                        kpiVisibilityClone[key] = true;
                                    }
                                }
                            }
                        }
                        this.kpiVisibility = kpiVisibilityClone;
                    }
                }
                /* US1017582: Technical: [RMF] - [Activity] - Metrics to be made optional - end */
                this.compVisibility();
            })
            .catch(e => {
                console.log('error->' + e);
                console.log('error->' + e.message);
                console.log('error->' + e.name);
                this.loaded = true;
                this.error = true;
                //START: Unhandled exception fix added by Sharavani 
                // Logs error received from Apex and persists it for tracking purposes
                const errorPayload = {
                        message: e?.body?.message,
                        stackTrace: e?.body?.stackTrace,
                        exceptionType: e?.body?.exceptionType,
                        pageErrors: e?.body?.pageErrors,
                        fieldErrors: e?.body?.fieldErrors
                    };

                    logErrorImperative({
                        errorMessage: JSON.stringify(errorPayload),
                        objectApiName: this.objectName
                    });
                //END: Unhandled exception fix added by Sharavani 

            });
    }
    validateValSelection(kpiValues, fieldName) {
        let areValuesSelected;
        if(kpiValues[fieldName] !== "" && kpiValues[fieldName] !== null && kpiValues[fieldName] !== undefined) {
            areValuesSelected = true;
        } else {
            areValuesSelected = false;
        }
        return areValuesSelected;
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
        if (this.inputValues.program != this.IPAProgram) {
            this.setEditStatus();
        }
        else{
            if(this.inputValues.enableKPI == false){
                this.setEditStatus();
            }
        }
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
               	let oldval=oldKPIValues[oldKey].toString();
                if((oldKey+'__c' == newKey) && oldKPIValues[oldKey] != newKPIValues[newKey]) {
                    if (typeof newKPIValues[newKey]==='string' && typeof oldKPIValues[oldKey]==='string' &&
                     oldKPIValues[oldKey].trim()== newKPIValues[newKey].trim()){
                        isMetricFieldUpdated = false;
                    }else{
                    isMetricFieldUpdated = true;
                    }
                   
                    break;
                }
            }
            let key = newKey;
            key = key.slice(0, -3);
            if(oldKPIValues[key] === undefined && newKPIValues[newKey] !== undefined && newKPIValues[newKey] !== null && newKPIValues[newKey] !== '') {
                isMetricFieldUpdated = true;
                break;
            }
        }
 
        return isMetricFieldUpdated;
    }

    // restrict e,+,-,E characters in  input type number
    isNumericOnly(event) { 
        const charCode = (event.which) ? event.which : event.keyCode;
        var dataType = event.target.getAttribute('data-type');

        if(charCode == 46){ // restrict "." value for non decimal fields
            if(!((this.decimalApplicable != undefined && this.decimalApplicable) && (dataType != null && dataType == 'Decimal'))){ // restrict "." value for non decimal fields
                event.stopPropagation();
                event.preventDefault();
                return false;
            }
        }
        if (charCode == 101 || charCode == 69 || charCode == 45 || charCode == 43) {
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
        let winPartHasInpVal = true;
        let isMetricPotentialWinnerCheck = '';
        if (inputElements.length == 0) {
            this.storePercentageofPotentialWinner = '';
            this.cmpPotentialExpected = true;
        }
        if (inputElements.length > 0) {
            if (this.inputValues.objName == 'PartnerFundClaim') {
                inputElements.forEach(ele => {
                    if (ele.value === '' || ele.value === undefined || ele.value === null) {
                        winPartHasInpVal = false;
                    }
                });
            }
        }

        if((this.inputValues.objName === 'PartnerFundClaim' && winPartHasInpVal) || this.inputValues.objName === 'PartnerFundRequest') {
            isMetricPotentialWinnerCheck = this.determineValidationErrMessage();
        }
        return isMetricPotentialWinnerCheck;
    }


    determineValidationErrMessage() {
        let isMetricPotentialWinnerCheck = '';
        if (this.storePercentageofPotentialWinner !== '' && this.cmpPotentialExpected === true) {
            if (this.storePercentageofPotentialWinner > 33) {
                isMetricPotentialWinnerCheck = 'perExceedError';
            }
        } else if (this.cmpPotentialExpected === false) {
            isMetricPotentialWinnerCheck = 'noExpPotCheck';
        }
        return isMetricPotentialWinnerCheck;
    } 

}