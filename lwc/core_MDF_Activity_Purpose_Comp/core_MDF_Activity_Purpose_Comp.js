import { LightningElement, wire, track, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import CORE_MDF_OBJECT from '@salesforce/schema/Core_MDF_Activity_Outcome__c';
import getActivityOutcomes from '@salesforce/apex/Core_MDF_Activity_Purpose_Controller.getActivityOutcomes';
import isActivityPurposeVisible from '@salesforce/apex/Core_MDF_Activity_Purpose_Controller.isActivityPurposeVisible';
import BASELINE_PERIOD_FIELD from '@salesforce/schema/Core_MDF_Activity_Outcome__c.Core_MDF_Baseline_Period_nm__c';
import OUTCOME_METRIC_FIELD from '@salesforce/schema/Core_MDF_Activity_Outcome__c.Core_MDF_Outcome_Metric_nm__c';
import isResultValueEditable from '@salesforce/apex/Core_MDF_Activity_Purpose_Controller.isResultValueEditable'; //Added by shravani to check if the result value should be editable

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
import To from '@salesforce/label/c.Core_MDF_to_Ac';
import For from '@salesforce/label/c.Core_MDF_for';
import And from '@salesforce/label/c.Core_MDF_and_Ac';
import CannotbeZero from '@salesforce/label/c.Core_MDF_cannotbezeroLabel';
import CompleteThisField from '@salesforce/label/c.Core_MDF_CompleteThisField_ErrorMessage';
import ClosedBracket from '@salesforce/label/c.Core_MDF_CloseBracket';
import MarketingPurpose from '@salesforce/label/c.Core_MDF_Marketing_Purpose';
import BusinessPurpose from '@salesforce/label/c.Core_MDF_Business_Purpose';
import BrandsForOutcomeMetric from '@salesforce/label/c.Core_MDF_Brands_for_Outcome_Metric';
import TechnologiesForOutcomeMetric from '@salesforce/label/c.Core_MDF_Technologies_for_Outcome_Metric';
import OtherBrandsTechnologies from '@salesforce/label/c.Core_MDF_Activity_Other_OutcomeBrandsTechnologies';

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
    @track ClosedBracket = ClosedBracket;
    @track MarketingPurpose = MarketingPurpose;
    @track BusinessPurpose = BusinessPurpose;
    @track BrandsForOutcomeMetric = BrandsForOutcomeMetric;
    @track TechnologiesForOutcomeMetric = TechnologiesForOutcomeMetric;
    @track OtherBrandsTechnologies = OtherBrandsTechnologies;

    // ===== Tracked Properties =====
    @track baselineOptions = [];
    @track selectedBaselineValue = '';
    @track selectedGoalValue = '';
    @track selectedBaseline = '';
    @track selectedResult = '';
    @track outcomes = [];
    @track marketingOutcomes = [];
    @track businessOutcomes = [];
    @track description = '';
    @track isDisabled = true;
    @track isOutcomeBasedActivityVisible = false;
    @track selectedBaselineLabel = '';
    pendingCcfDcfBaselinePeriod = null; //indu

    // ===== API Properties =====
    @api selectedTechnologyOptions = []; // array
    @api selectedBrandOptions = [];      // array
    @api recordId;
    @api isReadOnly;
    @api mode;
    @api editable;
    @api Activitystatus;
    @api isOutcomeBasedActivity;
    @api outcomeType;
    _showHeader = true;

    @api
    get showHeader() {
        return this._showHeader;
    }

    set showHeader(value) {
        this._showHeader = value !== false && value !== 'false';
    }
    
    //@api labelValueMap = [];

    // ===== Private / helper variables =====
    numberError = numberError;

    // Outcome metric: store BOTH api and label (UI shows label; backend uses api)
    outcomeApi = '';
    outcomeLabel = '';

    // picklist maps
    picklistLoaded = false;
    apiToLabel = {};   // { apiValue: label }
    labelToApi = {};   // { label: apiValue }
    pendingAiOutcomePayload = null;
    lastAiOutcomePayload = null;
    hasAppliedAiOutcomeValues = false;

    picklistMap = {};  // Brand / Technology localization
    localizedBrand = '';
    localizedTechnology = '';

    // ===== Wire Methods =====
    @wire(getObjectInfo, { objectApiName: CORE_MDF_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: BASELINE_PERIOD_FIELD
    })
    baselinePicklist({ data, error }) {
        if (data) {
            this.baselineOptions = data.values.map(({ label, value }) => ({ label, value }));
            if (
                this.isCcfDcfPurpose &&
                this.pendingCcfDcfBaselinePeriod !== null
            ) {
                this.selectedBaseline = this.resolveBaselinePeriodValue(
                    this.pendingCcfDcfBaselinePeriod
                );

                this.pendingCcfDcfBaselinePeriod = null;
            }

            // If editing an existing record, show label for pre-populated value
            if (this.selectedBaseline) {
                const match = this.baselineOptions.find(opt => opt.value === this.selectedBaseline);
                if (match) this.selectedBaselineLabel = match.label;
            }

            this.applyPendingOutcomeAiPayload();
        } else if (error) {
            console.error('Baseline picklist error', error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: OUTCOME_METRIC_FIELD
    })
    wiredOutcomePicklist({ data, error }) {
        if (data) {
            this.apiToLabel = {};
            this.labelToApi = {};
            data.values.forEach(item => {
                this.apiToLabel[item.value] = item.label;
                this.labelToApi[item.label] = item.value;
            });
            this.picklistLoaded = true;

            if (this.outcomeApi) this.outcomeLabel = this.apiToLabel[this.outcomeApi] || this.outcomeApi;
            if (!this.outcomeApi && this.outcomeLabel) this.outcomeApi = this.labelToApi[this.outcomeLabel];

            this.applyPendingOutcomeAiPayload();
        } else if (error) console.error('Outcome picklist load error', error);
    }

    // ===== Parent-provided outcome setter =====
    @api
    set selectedOutcomeMetricOptions(apiValue) {
        if (!apiValue) {
            this.outcomeApi = '';
            this.outcomeLabel = '';
            return;
        }

        const finalApiValue = Array.isArray(apiValue) ? apiValue[0] : apiValue;
        const hasMetricChanged = this.outcomeApi !== finalApiValue;
        this.outcomeApi = finalApiValue;
        this.outcomeLabel = this.picklistLoaded ? (this.apiToLabel[finalApiValue] || finalApiValue) : finalApiValue;

        if (hasMetricChanged) {
            this.resetInputBox();
            if (this.lastAiOutcomePayload) {
                // Re-apply the most recent AI values after metric-driven reset.
                window.setTimeout(() => {
                    this.applyAISuggestions({ outcomeActivityValues: this.lastAiOutcomePayload });
                }, 0);
            }
        }
    }

    get selectedOutcomeMetricOptions() {
        return this.outcomeApi;
    }

    // ===== Brand / Technology Localization (PROD READY) =====

// Lookup map: value → label
labelLookup = new Map();

// Backing variable
_labelValueMap = [];

// ---------- API SETTER ----------
@api
set labelValueMap(value) {
    this._labelValueMap = value || [];
    this.buildLabelLookup();
}

get labelValueMap() {
    return this._labelValueMap;
}
get hasTypedOutcomes() {
    return this.marketingOutcomes.length > 0 ||
        this.businessOutcomes.length > 0;
}

get hasMarketingOutcomes() {
    return this.marketingOutcomes.length > 0;
}

get hasBusinessOutcomes() {
    return this.businessOutcomes.length > 0;
}

get hasTypedReadOnlyOutcomes() {
    return this.isReadOnly && this.hasTypedOutcomes;
}

get showLegacyReadOnlyDescription() {
    return this.isReadOnly && !this.hasTypedOutcomes;
}
// ---------- BUILD LOOKUP ----------
buildLabelLookup() {
    this.labelLookup.clear();

    // Case 1: Array format → [{ value, label }]
    if (Array.isArray(this._labelValueMap)) {
        this._labelValueMap.forEach(item => {
            if (!item) return;

            const value = item.value;
            const label = item.label;

            if (value && label) {
                const normalizedKey = this.normalize(value);
                this.labelLookup.set(normalizedKey, label);
            }
        });
    }
    // Case 2: Object format → { key: label }
    else if (typeof this._labelValueMap === 'object') {
        Object.keys(this._labelValueMap).forEach(key => {
            const label = this._labelValueMap[key];
            if (key && label) {
                const normalizedKey = this.normalize(key);
                this.labelLookup.set(normalizedKey, label);
            }
        });
    }
}

// ---------- NORMALIZATION (CRITICAL FIX) ----------
normalize(value) {
    return value
        ?.toString()
        .replace(/\u00A0/g, ' ') // NBSP → normal space
        .replace(/\s+/g, ' ')    // collapse spaces
        .trim();
}

    normalizeNumericValue(value) {
        if (value === null || value === undefined || value === '') {
            return null;
        }
        if (typeof value === 'number') {
            return Number.isNaN(value) ? null : value;
        }
        const cleaned = String(value).replace(/[^0-9.-]/g, '');
        const parsed = parseFloat(cleaned);
        return Number.isNaN(parsed) ? null : parsed;
    }

// ---------- LABEL RESOLVER ----------
getLabels(values) {
    if (!values) return '';

    const arr = Array.isArray(values)
        ? values
        : (typeof values === 'string' ? values.split(';') : []);

    return arr
        .map(v => {
            const normalized = this.normalize(v);
            return this.labelLookup.get(normalized);
        })
        .filter(Boolean)
        .join(', ');
}

// ---------- PUBLIC GETTERS ----------
get selectedBrandLabels() {
    
    const labels = this.getLabels(this.selectedBrandOptions);
        if (!labels) {
        return Array.isArray(this.selectedBrandOptions)
            ? this.selectedBrandOptions.join(', ')
            : this.selectedBrandOptions || '';
    }

    return labels;

}

get selectedTechnologyLabels() {
   
    const labels = this.getLabels(this.selectedTechnologyOptions);
    if (!labels) {
        return Array.isArray(this.selectedTechnologyOptions)
            ? this.selectedTechnologyOptions.join(', ')
            : this.selectedTechnologyOptions || '';
    }

    return labels;
}

        // ===== Lifecycle =====
    connectedCallback() {
        // START: Shravani | US: TWC702-15067 | Result Value editability validation enhancement
            if (this.Activitystatus === 'Closed' && this.recordId) {     // Check edit access only when Activity status is Closed
                isResultValueEditable({ activityId: this.recordId })
                    .then(isEditable => {
                        this.isDisabled = !isEditable;
                    })
                    .catch(error => {
                        console.error('Error checking editability:', error);
                        this.isDisabled = true; // Default to disabled on error
                    });
            }
        // END: Shravani | US: TWC702-15067
        if (this.isOutcomeBasedActivity) this.isOutcomeBasedActivityVisible = true;
        if (['Edit', 'Clone', ''].includes(this.mode)) this.isReadOnly = false;

        if (this.recordId) {
            isActivityPurposeVisible({ activityId: this.recordId })
                .then(isVisible => {
                    if (!isVisible) {
                        this.isOutcomeBasedActivityVisible = false;
                        return;
                    }

                    this.loadOutcomes();
                })
                .catch(error => {
                    console.error('Error checking Activity Purpose visibility:', error);
                    this.loadOutcomes();
                });
        }
    }

    get divClass() {
        return this.isReadOnly ? 'slds-p-around_medium scrollable-table' : '';
    }

    loadOutcomes() {
            if (!this.recordId) return;

            getActivityOutcomes({ activityId: this.recordId })
                .then(result => {
                    if (this.hasAppliedAiOutcomeValues) {
                        return;
                    }

                    this.outcomes = result || [];
                    this.marketingOutcomes =
                        this.outcomes.filter(item => item.outcomeType === 'Marketing');
                    this.businessOutcomes =
                        this.outcomes.filter(item => item.outcomeType === 'Business');

                    let record;

                    if (this.outcomeType) {
                        record = this.outcomes.find(
                            item => item.outcomeType === this.outcomeType
                        );
                    } else if (this.outcomes.length > 0) {
                        record = this.outcomes[0];
                    }

                    if (record) {
                        this.outcomeApi =
                            record.outcomeMetricApi || record.outcomeMetric || '';
                        this.outcomeLabel =
                            record.outcomeMetric ||
                            (
                                this.picklistLoaded
                                ? (this.apiToLabel[this.outcomeApi] || this.outcomeApi)
                                : this.outcomeApi
                            );

                        if (this.isCcfDcfPurpose) {
                            // Preserve zero and wait for picklist options when necessary.
                            this.selectedBaselineValue =
                                record.baselineValue == null ? '' : String(record.baselineValue);

                            this.selectedGoalValue =
                                record.goalValue == null ? '' : String(record.goalValue);

                            this.selectedResult =
                                record.resultValue == null ? '' : String(record.resultValue);

                            if (this.baselineOptions.length > 0) {
                                this.selectedBaseline =
                                    this.resolveBaselinePeriodValue(record.baseLinePeriod);

                                this.pendingCcfDcfBaselinePeriod = null;
                            } else {
                                this.selectedBaseline = '';
                                this.pendingCcfDcfBaselinePeriod = record.baseLinePeriod || '';
                            }
                        } else {
                            // Existing IPA behavior.
                            this.selectedBaselineValue = record.baselineValue || '';
                            this.selectedGoalValue = record.goalValue || '';
                            this.selectedBaseline =
                                this.findMatchingBaselineValue(record.baseLinePeriod);
                            this.selectedResult = (this.mode || '').toLowerCase() === 'clone' ? '' : (record.resultValue || '');
                            //this.selectedResult = record.resultValue || '';
                        }
                        this.description = record.Description || '';
                        this.isOutcomeBasedActivityVisible =
                            record.isOutcomebaseActivity || false;

                        if (this.outcomeType && this.isReadOnly) {
                            this.selectedBrandOptions =
                                record.brandValues
                                ? record.brandValues.split(';')
                                : [];
                            this.selectedTechnologyOptions =
                                record.technologyValues
                                ? record.technologyValues.split(';')
                                : [];
                        }

                        if (this.selectedBaseline) {
                            const match =
                                this.baselineOptions.find(
                                    opt => opt.value === this.selectedBaseline
                                );

                            if (match) {
                                this.selectedBaselineLabel = match.label;
                            }
                        }
                    }
                })
                .catch(error => console.error('Error fetching outcomes:', error));
        }

    findMatchingBaselineValue(labelFromApex) {
        if (!labelFromApex || !this.baselineOptions) return '';
        const match = this.baselineOptions.find(opt => opt.label.toLowerCase() === labelFromApex.toLowerCase());
        return match ? match.value : '';
    }

    resolveOutcomeMetricApi(metricValue) {
        if (!metricValue) {
            return '';
        }

        const normalizedMetric = this.normalize(metricValue);
        if (!normalizedMetric) {
            return '';
        }

        if (this.apiToLabel && this.apiToLabel[normalizedMetric]) {
            return normalizedMetric;
        }

        if (this.labelToApi && this.labelToApi[normalizedMetric]) {
            return this.labelToApi[normalizedMetric];
        }

        const labelMatch = Object.keys(this.labelToApi || {}).find(label => this.normalize(label) === normalizedMetric);
        if (labelMatch) {
            return this.labelToApi[labelMatch];
        }

        const apiMatch = Object.keys(this.apiToLabel || {}).find(apiName => this.normalize(apiName) === normalizedMetric);
        return apiMatch || '';
    }

    resolveBaselinePeriodValue(periodValue) {
        if (!periodValue || !Array.isArray(this.baselineOptions) || this.baselineOptions.length === 0) {
            return '';
        }

        const normalizedInput = this.normalize(periodValue).toLowerCase();
        const byValue = this.baselineOptions.find(option => this.normalize(option.value).toLowerCase() === normalizedInput);
        if (byValue) {
            return byValue.value;
        }

        const byLabel = this.baselineOptions.find(option => this.normalize(option.label).toLowerCase() === normalizedInput);
        return byLabel ? byLabel.value : '';
    }

    applyPendingOutcomeAiPayload() {
        if (!this.pendingAiOutcomePayload) {
            return;
        }

        const payload = this.pendingAiOutcomePayload;
        this.pendingAiOutcomePayload = null;
        this.applyAISuggestions({ outcomeActivityValues: payload });
    }

    resetInputBox() {
        if (this.isCcfDcfPurpose) {
            this.pendingCcfDcfBaselinePeriod = null;
        }
        this.selectedBaselineValue = '';
        this.selectedBaseline = '';
        this.selectedGoalValue = '';
        this.selectedResult = '';

        try {
            const elems = this.template.querySelectorAll('lightning-input, lightning-combobox');
            if (elems) elems.forEach(el => { if (el) el.value = ''; });
        } catch (e) { /* ignore */ }
    }

    @api
    applyAISuggestions(payloadWrapper) {
        if (!payloadWrapper) {
            return;
        }

        let payload = payloadWrapper.outcomeActivityValues || payloadWrapper;
        if (Array.isArray(payload)) {
            payload = payload.length > 0 ? payload[0] : null;
        }

        if (!payload || typeof payload !== 'object') {
            return;
        }

        this.lastAiOutcomePayload = JSON.parse(JSON.stringify(payload));

        if (!this.picklistLoaded || !Array.isArray(this.baselineOptions) || this.baselineOptions.length === 0) {
            this.pendingAiOutcomePayload = JSON.parse(JSON.stringify(payload));
            return;
        }

        const incomingOutcomeMetric = payload.outcomeMetric ?? payload.metric ?? payload.outcome ?? payload.outcomeMetrics;
        const incomingOutcomeMetricValue = Array.isArray(incomingOutcomeMetric) ? incomingOutcomeMetric[0] : incomingOutcomeMetric;
        const incomingOutcomeApi = this.resolveOutcomeMetricApi(incomingOutcomeMetricValue);

        // Keep form aligned to the selected outcome metric if already chosen on parent.
        const selectedOutcomeApi = this.resolveOutcomeMetricApi(this.outcomeApi || this.outcomeLabel);

        if (!selectedOutcomeApi && incomingOutcomeApi) {
            this.outcomeApi = incomingOutcomeApi;
            this.outcomeLabel = this.apiToLabel[incomingOutcomeApi] || incomingOutcomeApi;
        }

        const baselineValue = this.normalizeNumericValue(payload.baselineValue ?? payload.baseLineValue ?? payload.baseline);
        const goalValue = this.normalizeNumericValue(payload.goalValue ?? payload.goal ?? payload.targetValue);
        const resultValue = this.normalizeNumericValue(payload.resultValue ?? payload.result ?? payload.actualValue);
        const baselinePeriodValue = this.resolveBaselinePeriodValue(payload.baselinePeriod ?? payload.baseLinePeriod ?? payload.period);

        if (baselineValue !== null) {
            this.selectedBaselineValue = baselineValue;
            this.hasAppliedAiOutcomeValues = true;
        }

        if (goalValue !== null) {
            this.selectedGoalValue = goalValue;
            this.hasAppliedAiOutcomeValues = true;
        }

        if (resultValue !== null) {
            this.selectedResult = resultValue;
            this.hasAppliedAiOutcomeValues = true;
        }

        if (baselinePeriodValue) {
            this.selectedBaseline = baselinePeriodValue;
            this.hasAppliedAiOutcomeValues = true;
            const baselineMatch = this.baselineOptions.find(opt => opt.value === baselinePeriodValue);
            if (baselineMatch) {
                this.selectedBaselineLabel = baselineMatch.label;
            }
        }
    }

    // ===== Event Handlers =====
    handleInputChangeBaselineValue(event) {
        if (this.isCcfDcfPurpose) {
            this.pendingCcfDcfBaselinePeriod = null;
        }
        this.validateNumber(event);
        this.selectedBaselineValue = event.target.value || '';
    }

    handleInputChangeGoalValue(event) {
        this.validateNumber(event);
        this.selectedGoalValue = event.target.value || '';
    }

    handleInputChangeBaseline(event) {
        this.selectedBaseline = event.target.value || '';

        // ✅ Map API value → localized label
        if (this.selectedBaseline && this.baselineOptions?.length) {
            const match = this.baselineOptions.find(opt => opt.value === this.selectedBaseline);
            this.selectedBaselineLabel = match ? match.label : this.selectedBaseline;
        }
    }

    handleResultChanged(event) {
        this.validateNumber(event);
        this.selectedResult = event.target.value || '';
    }

    get isCcfDcfPurpose() {
        return this.outcomeType === 'Marketing' ||
            this.outcomeType === 'Business';
    }

    get isPurposeResultRequired() {
        // Preserve the existing IPA HTML requirement.
        // Result is optional for CCF/DCF.
        return !this.isCcfDcfPurpose;
    }

    isPurposeValueBlank(value) {
        return value === null ||
            value === undefined ||
            String(value).trim() === '';
    }

    hasPurposeSelection(value) {
        const values = Array.isArray(value)
            ? value
            : String(value || '').split(';');

        return values.some(item => !this.isPurposeValueBlank(item));
    }

    getPurposeNumberError(value, required) {
        if (this.isPurposeValueBlank(value)) {
            return required ? this.CompleteThisField : '';
        }

        const number = Number(value);

        if (
            !Number.isFinite(number) ||
            number < 0 ||
            !Number.isInteger(number)
        ) {
            return this.numberError;
        }

        return '';
    }

    validateNumber(event) {
        const input = event.target;

        if (this.isCcfDcfPurpose) {
            const isResult = input.dataset.id === 'optionalValue';

            input.setCustomValidity(
                this.getPurposeNumberError(input.value, !isResult)
            );
            input.reportValidity();
            return;
        }

        // Existing IPA behavior: unchanged.
        const value = parseFloat(input.value);

        if (isNaN(value) || value < 0 || !Number.isInteger(value)) {
            input.setCustomValidity(this.numberError);
        } else {
            input.setCustomValidity('');
        }

        input.reportValidity();
    }

    validateCcfDcfPurpose() {
        // Check the values themselves, not only the rendered controls.
        // This prevents an unrendered/hidden table from passing with
        // missing Baseline, Goal or Baseline Period.
        let allValid = true;

        if (
            this.isPurposeValueBlank(this.outcomeApi) ||
            !this.hasPurposeSelection(this.selectedBrandOptions) ||
            !this.hasPurposeSelection(this.selectedTechnologyOptions) ||
            this.getPurposeNumberError(this.selectedBaselineValue, true) ||
            this.getPurposeNumberError(this.selectedGoalValue, true) ||
            this.isPurposeValueBlank(this.selectedBaseline)
        ) {
            allValid = false;
        }

        // Result is optional. Validate its number only when editable.
        if (
            !this.isDisabled &&
            this.getPurposeNumberError(this.selectedResult, false)
        ) {
            allValid = false;
        }

        this.template.querySelectorAll('lightning-input').forEach(input => {
            const isResult = input.dataset.id === 'optionalValue';

            if (isResult && this.isDisabled) {
                return;
            }

            const error = this.getPurposeNumberError(
                input.value,
                !isResult
            );

            input.setCustomValidity(error);

            if (error || !input.checkValidity()) {
                allValid = false;
            }

            input.reportValidity();
        });

        this.template.querySelectorAll('lightning-combobox').forEach(combo => {
            const error = this.isPurposeValueBlank(combo.value)
                ? this.CompleteThisField
                : '';

            combo.setCustomValidity(error);

            if (error || !combo.checkValidity()) {
                allValid = false;
            }

            combo.reportValidity();
        });

        return allValid;
    }

    @api
    validate() {
        if (this.isCcfDcfPurpose) {
            return this.validateCcfDcfPurpose();
        }

        // Existing IPA validation: unchanged.
        let allValid = true;

        const allInputs = this.template.querySelectorAll('lightning-input');

        allInputs.forEach(input => {
            if (input.dataset.ignore === 'true' && this.isDisabled) return;

            const value = input.value;
            input.setCustomValidity('');

            if (!value) {
                input.setCustomValidity(this.numberError);
                allValid = false;
            }

            const numValue = Number(value);

            if (
                isNaN(numValue) ||
                numValue < 0 ||
                !Number.isInteger(numValue)
            ) {
                allValid = false;
            }

            input.reportValidity();
        });

        const comboInputs =
            this.template.querySelectorAll('lightning-combobox');

        comboInputs.forEach(combo => {
            if (combo.dataset.ignore === 'true' && this.isDisabled) return;

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
    get prepareIncreaseDecreaseLabel() {
        if (this.selectedGoalValue && this.selectedBaselineValue) {
            const goalValue = parseFloat(this.selectedGoalValue);
            const baseValue = parseFloat(this.selectedBaselineValue);
            if (isNaN(goalValue) || isNaN(baseValue)) return '';

            let percentChange = baseValue === 0 ? goalValue * 100 : ((goalValue - baseValue) / baseValue) * 100;
            const formatted = Number.isInteger(percentChange) ? Math.abs(percentChange) : Math.abs(percentChange).toFixed(2);
            return percentChange >= 0 ? `${this.IncreaseBy} ${formatted}` : `${this.DecreaseBy} ${formatted}`;
        }
        return '';
    }

    get isAllFieldsPopulated() {
        if (this.isReadOnly) return false;
        return !!(this.selectedBaselineValue && this.selectedGoalValue && this.selectedBaseline && this.selectedBrandOptions?.length && this.selectedTechnologyOptions?.length);
    }
    get outcomeApiToSend() {
        const raw = this.outcomeApi || this.outcomeLabel;

        if (!raw) {
            return '';
        }

        const resolvedApi = this.resolveOutcomeMetricApi(raw);

        return resolvedApi || raw;
    }

    @api
    getAllActivityOutcomesDetails() {
        const multiplied = this.prepareIncreaseDecreaseLabel || '';
        const baseline = this.isCcfDcfPurpose ? (this.isPurposeValueBlank(this.selectedBaselineValue) ? '' : String(this.selectedBaselineValue)) : (this.selectedBaselineValue || '');
        const goal = this.isCcfDcfPurpose ? (this.isPurposeValueBlank(this.selectedGoalValue) ? '' : String(this.selectedGoalValue)) : (this.selectedGoalValue || '');
        const baselinePeriod = this.selectedBaseline || '';
        const resultValue = this.isCcfDcfPurpose
            ? (this.isPurposeValueBlank(this.selectedResult)
                ? '' : String(this.selectedResult))
            : (this.selectedResult || '');
        const apiToSend = this.outcomeApiToSend;
            
 if (!apiToSend) {
        console.error(
            'Invalid Outcome – cannot resolve API value',
            this.outcomeLabel,
            this.outcomeApi
        );
    }


        return [
            {
                outcomeMetric: apiToSend,
                outcomeType: this.outcomeType || '',
                brandValues: Array.isArray(this.selectedBrandOptions)
                    ? this.selectedBrandOptions.join(';')
                    : (this.selectedBrandOptions || ''),
                technologyValues: Array.isArray(this.selectedTechnologyOptions)
                    ? this.selectedTechnologyOptions.join(';')
                    : (this.selectedTechnologyOptions || ''),
                baselineValue: baseline,
                goalValue: goal,
                baseLinePeriod: baselinePeriod,
                resultValue: resultValue
            }
        ];
    }
    get headerClass() {
                return !this.isReadOnly ? 'header-title' : '';

}
}