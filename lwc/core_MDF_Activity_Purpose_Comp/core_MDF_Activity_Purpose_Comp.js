import { LightningElement, wire, track, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import CORE_MDF_OBJECT from '@salesforce/schema/Core_MDF_Activity_Outcome__c';
import getActivityOutcomes from '@salesforce/apex/Core_MDF_Activity_Purpose_Controller.getActivityOutcomes';
import BASELINE_PERIOD_FIELD from '@salesforce/schema/Core_MDF_Activity_Outcome__c.Core_MDF_Baseline_Period_nm__c';
import OUTCOME_METRIC_FIELD from '@salesforce/schema/Core_MDF_Activity_Outcome__c.Core_MDF_Outcome_Metric_nm__c';
// Custom Labels
import numberError from '@salesforce/label/c.Core_MDF_KPI_Number_Error';
import ResultValue from '@salesforce/label/c.Core_MDF_Result_Value';
import BaslineValue from '@salesforce/label/c.Core_MDF_Baseline_Value';
import GoalValue from '@salesforce/label/c.Core_MDF_Goal_Value';
import BaselinePeriod from '@salesforce/label/c.Core_MDF_Baseline_Period';
import OutComeMetric from '@salesforce/label/c.Core_MDF_Outcome_Metric';
import BaseLineHexlpText from '@salesforce/label/c.Core_MDF_BaselineQnty_Helptxt';
import GoalValueHexlpText from '@salesforce/label/c.Core_MDF_GoalQnty_Helptxt';
import BaselinePeriodHelptxt from '@salesforce/label/c.Core_MDF_Baseline_Period_Act';
import ResultValueHelptxt from '@salesforce/label/c.Core_MDF_Result_Value_Act';
import CampaignPurposeHeader from '@salesforce/label/c.Core_MDF_Activity_Purpose_Header';
import BrandandTechnology from '@salesforce/label/c.Core_MDF_Brand_and_Technology';
import IncreaseBy from '@salesforce/label/c.Core_MDF_Increase_by';
import DecreaseBy from '@salesforce/label/c.Core_MDF_Decrease_by';
import From from '@salesforce/label/c.Core_MDF_from';
import To from '@salesforce/label/c.Core_MDF_to';
import For from '@salesforce/label/c.Core_MDF_for';
import And from '@salesforce/label/c.Core_MDF_and';
import CannotbeZero from '@salesforce/label/c.Core_MDF_cannotbezeroLabel';
import CompleteThisField from '@salesforce/label/c.Core_MDF_CompleteThisField_ErrorMessage';

export default class ActivityPurposeComp extends LightningElement {
    // ===== Labels =====
    @track ResultValue = ResultValue;
    @track BaslineValue = BaslineValue;
    @track GoalValue = GoalValue;
    @track BaselinePeriod = BaselinePeriod;
    @track OutComeMetric = OutComeMetric;
    @track BaseLineHexlpText = BaseLineHexlpText;
    @track GoalValueHexlpText = GoalValueHexlpText;
    @track CampaignPurposeHeader = CampaignPurposeHeader;
    @track BrandandTechnology = BrandandTechnology;
    @track IncreaseBy = IncreaseBy;
    @track DecreaseBy = DecreaseBy;
    @track From = From;
    @track To = To;
    @track For = For;
    @track And = And;
    @track CompleteThisField = CompleteThisField;
    @track BaselinePeriodHelptxt = BaselinePeriodHelptxt;
    @track ResultValueHelptxt = ResultValueHelptxt;
    @track CannotbeZero = CannotbeZero;
    // ===== Tracked Properties =====
    @track baselineOptions = [];
    @track selectedBaselineValue = '';
    @track selectedGoalValue = '';
    @track selectedBaseline = '';
    @track selectedResult = '';
    @track outcomes = [];
    @track description = '';
    @track isDisabled = true;
    @track isOutcomeBasedActivityVisible = false;

    // ===== API Properties =====
    @api selectedTechnologyOptions;
    @api selectedBrandOptions;
    @api recordId;
    @api isReadOnly;
    @api mode;
    @api editable;
    @api Activitystatus;
    @api isOutcomeBasedActivity;

    // ===== Private / helper variables =====
    numberError = numberError;

    // Outcome metric: store BOTH api and label (UI shows label; backend uses api)
    outcomeApi = '';
    outcomeLabel = '';

    // picklist maps
    picklistLoaded = false;
    apiToLabel = {};   // { apiValue: label }
    labelToApi = {};   // { label: apiValue }

    // ===== Wire Methods =====
    @wire(getObjectInfo, { objectApiName: CORE_MDF_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: BASELINE_PERIOD_FIELD
    })
    baselinePicklist({ data, error }) {
        if (data) {
            this.baselineOptions = data.values.map(({ label, value }) => ({
                label,
                value
            }));

            // 🔥 If we already loaded existing record, reapply value after options arrive
            if (this.selectedBaseline) {
                this.selectedBaseline = this.selectedBaseline; // forces re-render
            }
        } else if (error) {
            console.error('Baseline picklist error', error);
        }
    }

    // Load outcome picklist and build mappings (label <-> api)
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: OUTCOME_METRIC_FIELD
    })
    wiredOutcomePicklist({ data, error }) {
        if (data) {
            this.apiToLabel = {};
            this.labelToApi = {};
            data.values.forEach(item => {
                // build both directions
                this.apiToLabel[item.value] = item.label;
                this.labelToApi[item.label] = item.value;
            });
            this.picklistLoaded = true;

            // If we already have an API value from parent/load, convert to label now
            if (this.outcomeApi) {
                this.outcomeLabel = this.apiToLabel[this.outcomeApi] || this.outcomeApi;
            }

            // If we only have a label (from backend) and outcomeApi is empty, populate outcomeApi
            if (!this.outcomeApi && this.outcomeLabel) {
                const mappedApi = this.labelToApi[this.outcomeLabel];
                if (mappedApi) this.outcomeApi = mappedApi;
            }
        } else if (error) {
            console.error('Outcome picklist load error', error);
        }
    }

    // ===== Setter / Getter for parent-provided value =====
    // Parent may send API value OR an array [apiValue]. We handle both.
    @api
    set selectedOutcomeMetricOptions(apiValue) {
        if (!apiValue) {
            this.outcomeApi = '';
            this.outcomeLabel = '';
            return;
        }

        const finalApiValue = Array.isArray(apiValue) ? apiValue[0] : apiValue;
        this.outcomeApi = finalApiValue;

        if (this.picklistLoaded) {
            this.outcomeLabel = this.apiToLabel[finalApiValue] || finalApiValue;
        } else {
            // temporarily show API until picklist loads and we can convert
            this.outcomeLabel = finalApiValue;
        }

        // Reset dependent inputs when outcome changes
        this.resetInputBox();
    }

    get selectedOutcomeMetricOptions() {
        // Expose API to parent if requested; parent expected API values usually
        return this.outcomeApi;
    }

    // ===== Lifecycle =====
    connectedCallback() {

        if (this.Activitystatus === 'Closed') {
            this.isDisabled = false;
        }

        if (this.isOutcomeBasedActivity) {
            this.isOutcomeBasedActivityVisible = true;
        }

        if (['Edit', 'Clone', ''].includes(this.mode)) {
            this.isReadOnly = false;
        }

        if (this.recordId) {
            this.loadOutcomes();
        }
    }

    // this method is used to change the class of the div
    get divClass() {
        return this.isReadOnly ? 'slds-p-around_medium scrollable-table' : '';
    }
    // ===== Data Loading =====
    loadOutcomes() {
        if (!this.recordId) return;

        getActivityOutcomes({ activityId: this.recordId })
            .then(result => {
                this.outcomes = result || [];

                if (result?.length > 0) {
                    const record = result[0];
                    // Backend may return API value or LABEL. Try to handle both:
                    const returnedOutcome = record.outcomeMetric || '';

                    if (!returnedOutcome) {
                        this.outcomeApi = '';
                        this.outcomeLabel = '';
                    } else {
                        // If picklist has mapping for returnedOutcome as API -> label, treat as API
                        if (this.picklistLoaded && this.apiToLabel[returnedOutcome]) {
                            this.outcomeApi = returnedOutcome;
                            this.outcomeLabel = this.apiToLabel[returnedOutcome];
                        } else if (this.picklistLoaded && this.labelToApi[returnedOutcome]) {
                            // Backend returned label
                            this.outcomeLabel = returnedOutcome;
                            this.outcomeApi = this.labelToApi[returnedOutcome];
                        } else {
                            // picklist not loaded yet OR unknown; save into label and leave api blank (will try to map later)
                            // prefer storing label for UI
                            this.outcomeLabel = returnedOutcome;
                            this.outcomeApi = this.labelToApi[returnedOutcome] || '';
                        }
                    }
                    this.selectedBaselineValue = record.baselineValue || '';
                    this.selectedGoalValue = record.goalValue || '';
                    this.selectedBaseline = this.findMatchingBaselineValue(record.baseLinePeriod);
                    this.selectedResult = record.resultValue || '';
                    this.description = record.Description || '';
                    this.isOutcomeBasedActivityVisible = record.isOutcomebaseActivity || false;
                }
            })
            .catch(error => console.error('Error fetching outcomes:', error));
    }

    // ===== Reset =====
    // If outcome metric value is change then all the inputbox get reset
    resetInputBox() {
        this.selectedBaselineValue = '';
        this.selectedBaseline = '';
        this.selectedGoalValue = '';
        this.selectedResult = '';
        // clear actual UI values too (safe-guard)
        try {
            const elems = this.template.querySelectorAll('lightning-input, lightning-combobox');
            if (elems) {
                elems.forEach(element => {
                    if (element) element.value = '';
                });
            }
        } catch (e) {
            // ignore if DOM not ready
        }
    }

    findMatchingBaselineValue(labelFromApex) {
        if (!labelFromApex || !this.baselineOptions) return '';

        const match = this.baselineOptions.find(
            opt => opt.label.toLowerCase() === labelFromApex.toLowerCase()
        );

        return match ? match.value : '';
    }

    // ===== Event Handlers =====
    handleInputChangeBaselineValue(event) {
        this.validateNumber(event);
        this.selectedBaselineValue = event.target.value || '';
    }

    handleInputChangeGoalValue(event) {
        this.validateNumber(event);
        this.selectedGoalValue = event.target.value || '';
    }

    handleInputChangeBaseline(event) {
        this.selectedBaseline = event.target.value || '';
    }

    handleResultChanged(event) {
        this.validateNumber(event);
        this.selectedResult = event.target.value || '';
    }

    // ===== Validation =====
    validateNumber(event) {
        const input = event.target;
        const value = parseFloat(input.value);

        if (isNaN(value) || value < 0 || !Number.isInteger(value)) {
            input.setCustomValidity(this.numberError);
        } else {
            input.setCustomValidity('');
        }
        input.reportValidity();
    }
    
    // Performs UI validation on fields and returns true if all are valid
    @api
    validate() {
        let allValid = true;

        // validate lightning-input fields
        const allInputs = this.template.querySelectorAll('lightning-input');
        allInputs.forEach(input => {

            // Skip ignored inputs when disabled
            if (input.dataset.ignore === 'true' && this.isDisabled == true) {
                return;
            }
            const value = input.value;
            const fieldId = input.dataset.id;
            input.setCustomValidity('');

            const numValue = Number(value);

            // ---------------------------------------------------
            // CASE: OPTIONAL VALUE — not required
            // If empty, don't validate at all
            // If has value → validate numeric rules
            // ---------------------------------------------------
            if (fieldId === 'optionalValue') {

                if (!value) {
                    return; // no validation needed
                }

                if (isNaN(numValue) || numValue < 0 || !Number.isInteger(numValue)) {
                    input.setCustomValidity(this.numberError);
                    allValid = false;
                }

                input.reportValidity();
                return;
            }
            // ---------------------------------------------------
            // CASE: REQUIRED FIELDS (all except optionalValue)
            // ---------------------------------------------------
            if (!value) {
                input.setCustomValidity(this.numberError);
                input.reportValidity();
                allValid = false;
                return;
            }
            // numeric validation for required fields
            if (isNaN(numValue) || numValue < 0 || !Number.isInteger(numValue)) {
                input.setCustomValidity(this.numberError);
                allValid = false;
            }
            if (!input.reportValidity()) {
                allValid = false;
            }
        });

        // validate lightning-combobox fields
        const comboInputs = this.template.querySelectorAll('lightning-combobox');
        comboInputs.forEach(combo => {

            if (combo.dataset.ignore === 'true' && this.isDisabled == true) {
                return;
            }

            combo.setCustomValidity('');

            if (!combo.value) {
                combo.setCustomValidity(this.CompleteThisField);
                allValid = false;
            }

            combo.reportValidity();
        });

        return allValid;
    }




    // ===== Computed Getters =====
    // Returns formatted % difference between goal and baseline as “Increase by” or “Decrease by”
    get prepareIncreaseDecreaseLabel() {
        if (this.selectedGoalValue && this.selectedBaselineValue) {
            const goalValue = parseFloat(this.selectedGoalValue);
            const baseValue = parseFloat(this.selectedBaselineValue);
            // Baseline must be non-zero, as it serves as the denominator in the % change formula
            if (isNaN(goalValue) || isNaN(baseValue)) {
                return '';

            }
            // Calculate percentage change between goal and baseline.
            // If baseline = 0, avoid division by zero by treating baseline as 1.
            // Otherwise use standard formula: (goal - baseline) / baseline * 100
            let goalBaselineChangePercent = baseValue === 0 ? (goalValue * 100) : (((goalValue - baseValue) / baseValue) * 100);

            // Remove .00 if integer
            const formattedGoalBaselineChangePercent =
                Number.isInteger(goalBaselineChangePercent)
                    ? Math.abs(goalBaselineChangePercent)
                    : Math.abs(goalBaselineChangePercent).toFixed(2);

            if (goalBaselineChangePercent >= 0) {
                return `${this.IncreaseBy} ${formattedGoalBaselineChangePercent}%`;
            } else {
                return `${this.DecreaseBy} ${formattedGoalBaselineChangePercent}%`;
            }
        }
        return '';
    }
    // Checks whether all required form fields have values
    get isAllFieldsPopulated() {
        if (this.isReadOnly) {
            return false;
        }

        const isBaselineValueFilled = !!(this.selectedBaselineValue && this.selectedBaselineValue.toString().trim());
        const isGoalValueFilled = !!(this.selectedGoalValue && this.selectedGoalValue.toString().trim());
        const isBaselineFilled = !!(this.selectedBaseline && this.selectedBaseline.trim());
        const isBrandFilled = !!(this.selectedBrandOptions && this.selectedBrandOptions.toString().trim());
        const isTechFilled = !!(this.selectedTechnologyOptions && this.selectedTechnologyOptions.toString().trim());

        return (
            isBaselineValueFilled &&
            isGoalValueFilled &&
            isBaselineFilled &&
            isBrandFilled &&
            isTechFilled
        );
    }

    // ===== Wrapper Data =====
    @api
    getAllActivityOutcomesDetails() {
        const multiplied = this.prepareIncreaseDecreaseLabel || '';
        const baseline = this.selectedBaselineValue || '';
        const goal = this.selectedGoalValue || '';
        const baselinePeriod = this.selectedBaseline || '';
        const brands = this.selectedBrandOptions || '';
        const techs = this.selectedTechnologyOptions || '';
        const resultValue = this.selectedResult || '';

        const Description = `${multiplied} (${this.From} ${baseline} ${this.To} ${goal}) ${baselinePeriod} ${this.For} ${brands} ${this.And} ${techs}`;

        // Ensure we send API value to backend. If outcomeApi is empty but we have a label, map it.
        let apiToSend = this.outcomeApi;
        if (!apiToSend && this.outcomeLabel && this.labelToApi[this.outcomeLabel]) {
            apiToSend = this.labelToApi[this.outcomeLabel];
        }

        return [
            {
                outcomeMetric: apiToSend || '', // API value required by backend
                baselineValue: baseline,
                goalValue: goal,
                baseLinePeriod: baselinePeriod,
                resultValue: resultValue,
                Description: Description
            }
        ];
    }
}