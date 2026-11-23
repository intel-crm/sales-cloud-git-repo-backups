import { api, LightningElement, track, wire } from 'lwc';
import getTacticMappings from '@salesforce/apex/Core_MDF_Tactics_Controller.getTacticMappings';
import getSavedKpiData from '@salesforce/apex/Core_MDF_Tactics_Controller.getSavedKpiData';
import getPicklistLabels from '@salesforce/apex/Core_MDF_Tactics_Controller.getPicklistLabels';
import saveKpiData from '@salesforce/apex/Core_MDF_Tactics_Controller.saveKpiData';
import tactics from '@salesforce/label/c.Core_MDF_Activity_Tactics';
import tactics_help_text from '@salesforce/label/c.Core_MDF_Tactics_Help_Text';
import tactic_Metrics from '@salesforce/label/c.Core_MDF_Tactic_Metrics';
import tactic_metrics_help_text from '@salesforce/label/c.Core_MDF_Tactic_Metrics_Help_Text';
import goal_Values from '@salesforce/label/c.Core_MDF_Goal_Values';
import goal_Values_Help_Text from '@salesforce/label/c.Core_MDF_Goal_Values_Help_Text';
import spending_Percentage from '@salesforce/label/c.Core_MDF_Spending_Percentage';
import spending_Percentage_Help_Text from '@salesforce/label/c.Core_MDF_Spending_Percentage_Help_Text';
import goal_Value_Decimal_Error from '@salesforce/label/c.Core_MDF_Goal_Value_Decimal_Error';
import spending_Value_Decimal_Error from '@salesforce/label/c.Core_MDF_Spending_Percentage_Decimal_Error';
import Core_MDF_KpiSection_Label from '@salesforce/label/c.Core_MDF_KpiSection_Label';
import SPENDING_AMOUNT_LABEL from '@salesforce/label/c.Core_MDF_Spending_Amount';
import SPENDING_AMOUNT_HELP_TEXT_LABEL from '@salesforce/label/c.Core_MDF_Spending_Amount_Help_Text';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class KpiTable extends LightningElement {


    @api actTactics;
    @api mode;
    @api recordId;
    @api ipaclone;
    @api isDetail;
    @api isProposalBased;
    @api editable;
    @api programName = 'Client';

    @track selectedTactics = [];
    @track data = [];
    allMappings = {};
    hasRendered = false;
    @track originalData = [];
    @track tactics = tactics;
    @track tactics_help_text = tactics_help_text;
    @track tactic_Metrics = tactic_Metrics;
    @track tactic_metrics_help_text = tactic_metrics_help_text;
    @track goal_Values = goal_Values;
    @track goal_Values_Help_Text = goal_Values_Help_Text;
    @track spending_Percentage = spending_Percentage;
    @track spending_Percentage_Help_Text = spending_Percentage_Help_Text;
    @track goal_Value_Decimal_Error = goal_Value_Decimal_Error;
    @track spending_Value_Decimal_Error = spending_Value_Decimal_Error;
    spendingAmountLabel = SPENDING_AMOUNT_LABEL;
    spendingamountHelpTextLabel = SPENDING_AMOUNT_HELP_TEXT_LABEL;
    @track metrics = Core_MDF_KpiSection_Label;
    @track isMetricsVisible = false;
    @track intelContributionValue;
    picklistLabelMap = {};

    
    @wire(getPicklistLabels)
wiredPicklistLabels({ data, error }) {
    if (data) {
        this.picklistLabelMap = data;
    } else if (error) {
    }
}

        @wire(getTacticMappings, { programName: '$programName' })
        wiredMappings({ data, error }) {
            if (data && Array.isArray(data)) {
                // Build allMappings using only API names — no localization
                this.allMappings = {};
                data.forEach(item => {
                    const tactic = item.tactic; // English tactic API name
                    if (item.kpiFields?.length && item.percentageField) {
                        this.allMappings[tactic] = {
                            firstKpi: { label: item.kpiFields[0], value: '' }, // label = API name
                            otherKpis: item.kpiFields.slice(1).map(apiName => ({ label: apiName, value: '' })),
                            percentageField: item.percentageField,
                            percentageValue: ''
                        };
                    }
                });

                // Load localized data if in edit/clone mode
                if (this.recordId && this.mode !== '' && !this.ipaclone) {
                    this.loadSavedKpiData();
                }

                // If default tactics already available, handle initial display
                if (this.actTactics && Object.keys(this.actTactics).length > 0) {
                    this.handleTacticChange(this.actTactics);
                }

                if (this.data.length > 0) {
                    this.isMetricsVisible = true;
                }
            } else if (error) {
                
            }
        }

        connectedCallback(){
            if(this.mode == 'edit' && this.editable){
                this.isDetail = true;
            }

        }

        @api handleEdit(editable) {
            if(this.mode == 'edit' && editable){
                this.isDetail = true;
            }
        }

        @api
        set intelContribution(value) {
            this.intelContributionValue = parseFloat(value);
            this.updateIntelContributionValue();
        }
        get intelContribution() {
            return this.intelContributionValue;
        }

        updateIntelContributionValue(){
            if(!this.data || isNaN(this.intelContributionValue)) return;
              this.data = this.data.map(row => {
                let percentageValue = parseFloat(row.percentageValue);
                row.intelContri = ((this.intelContributionValue * percentageValue) / 100).toFixed(2);
                return {...row};});
        }
    
      @api handleTacticChange(params) {
    if (params.selectedTactics != undefined && params.selectedTactics != null && params.selectedTactics != '') {
        this.selectedTactics = JSON.parse(JSON.stringify(params.selectedTactics));
    } else {
        this.selectedTactics = JSON.parse(JSON.stringify(this.actTactics));
    }

    const previousDataMap = new Map(this.data.map(row => [row.tactic.api || row.tactic, row]));

    this.data = this.selectedTactics.map((tacticApi, index) => {
        const template = this.allMappings[tacticApi];
        if (!template) {
            console.warn(`No mapping found for tactic: ${tacticApi}`);
            return null;
        }

        const previousRow = previousDataMap.get(tacticApi);

        // Get localized labels dynamically from picklistLabelMap
        const tacticLabel = this.picklistLabelMap[tacticApi] || tacticApi;
        const percentageLabel = this.picklistLabelMap[template.percentageField] || template.percentageField;

        return {
            id: `${index}-${tacticApi}-${Date.now()}`,
            tactic: { api: tacticApi, label: tacticLabel },
            percentageField: { api: template.percentageField, label: percentageLabel },
            percentageValue: previousRow?.percentageValue ?? '',
            intelContri: previousRow?.percentageValue ? ((this.intelContributionValue * previousRow.percentageValue) / 100).toFixed(2) : 0,
            firstKpi: {
                api: template.firstKpi.label,
                label: this.picklistLabelMap[template.firstKpi.label] || template.firstKpi.label,
                value: previousRow?.firstKpi?.value ?? ''
            },
            otherKpis: template.otherKpis.map((kpi, i) => ({
                api: kpi.label,
                label: this.picklistLabelMap[kpi.label] || kpi.label,
                value: previousRow?.otherKpis?.[i]?.value ?? ''
            })),
            rowspan: template.otherKpis.length + 1
        };
    }).filter(row => row !== null);

    this.originalData = JSON.parse(JSON.stringify(this.data));

    if (this.data.length > 0) {
        this.isMetricsVisible = true;
    }
}

    
        handleKpiChange(event) {
            const rowId = event.target.dataset.id;
            const index = event.target.dataset.kpiIndex;
            const newValue = parseFloat(event.target.value);
        
            const updatedData = [...this.data];
            const row = updatedData.find(item => item.id == rowId);
        
            if (row) {
                if (index === undefined || index === null || index === 'first') {
                    row.firstKpi.value = newValue;
                } else {
                    const kpiIdx = parseInt(index);
                    if (!isNaN(kpiIdx)) {
                        row.otherKpis[kpiIdx].value = newValue;
                    }
                }
            }
        
            this.data = updatedData;
        }

        handleAmountChange(event) {
            const rowId = event.target.dataset.id;
            const newValue = parseFloat(event.target.value);
        
            const updatedData = [...this.data];
            const row = updatedData.find(item => item.id == rowId);
        
            if (row) {
                row.intelContri = isNaN(newValue) ? 0 : newValue;
                // recalc % based on entered amount
                row.percentageValue = this.intelContributionValue && !isNaN(newValue)
                    ? ((newValue / this.intelContributionValue) * 100).toFixed(2)
                    : 0;
            }
        
            this.data = updatedData;
        }
    
        handlePercentageChange(event) {
            const rowId = event.target.dataset.id;
            const newValue = parseFloat(event.target.value);
        
            const updatedData = [...this.data];
            const row = updatedData.find(item => item.id == rowId);
            if (row) {

                row.percentageValue = isNaN(newValue) ? 0 : newValue;
                // recalc amount based on %
                row.intelContri = this.intelContributionValue && !isNaN(newValue) ? ((newValue * this.intelContributionValue) / 100).toFixed(2) : 0;
    }
        
            this.data = updatedData;
        }
        @api handleSave() {
            const payload = JSON.parse(JSON.stringify(this.data));
             return saveKpiData({ rawRecords: payload, pfrId: this.recordId, isProposalBased: true })
                .then(result => {
                    return result;
                })
                .catch(error => {
                    const message = error.body && error.body.message ? error.body.message : 'An error occurred';
                    this.showToast('Error', message, 'error');
                    return Promise.reject(error);
                });
        }
    
        showToast(title, message, variant) {
            this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
        }    

        @api getTacticMetricsValues(){
            const payload = JSON.parse(JSON.stringify(this.data));
            return payload;
        }

        @api isTacticMetricsModified() {
            if (!this.originalData || this.originalData.length !== this.data.length) {
                return true;
            }

            for (let i = 0; i < this.data.length; i++) {
                const current = this.data[i];
                const original = this.originalData[i];

                if (current.tactic.api !== original.tactic.api ||
                    current.percentageValue !== original.percentageValue ||
                    current.firstKpi.value !== original.firstKpi.value) {
                    return true;
                }

                if (current.otherKpis.length !== original.otherKpis.length) {
                    return true;
                }

                for (let j = 0; j < current.otherKpis.length; j++) {
                    if (current.otherKpis[j].value !== original.otherKpis[j].value) {
                        return true;
                    }
                }
            }

            return false;
        }

        formatDecimal(val) {
            const num = val != null && val != '' && val != undefined ? parseFloat(val) : '';
            if (num === '') return '';
            return Number.isInteger(num) ? String(num) : String(num.toFixed(2)).replace(/\.?0+$/,'');
        }
        
            
        loadSavedKpiData() {
    getSavedKpiData({ pfrId: this.recordId })
        .then((result) => {
            if (result.length === 0) return;
            let rowId = 1;

            if(this.isDetail){//To show in the Detail page
                this.intelContributionValue = (result[0].intelContribution ? result[0].intelContribution : 0.0);
            }

            this.data = result.map(tactic => {
                const row = {
                    id: rowId++,
                    tactic: { api: tactic.tactic, label: tactic.tacticLabel },
                    percentageField: { api: tactic.percentageField, label: tactic.percentageFieldLabel },
                    percentageValue: tactic.percentageValue,
                    intelContri: tactic.percentageValue != '' && tactic.percentageValue != null && tactic.percentageValue != undefined && !isNaN(tactic.percentageValue) ? ((tactic.percentageValue*this.intelContributionValue) / 100).toFixed(2) : 0,
                    firstKpi: {
                        api: tactic.firstKpi?.api || '',
                        label: tactic.firstKpi?.label || '',
                        value: this.formatDecimal(tactic.firstKpi?.value) ?? null
                    },
                    otherKpis: tactic.otherKpis.map(kpi => ({
                        api: kpi.api,
                        label: kpi.label,
                        value: this.formatDecimal(kpi.value) ?? null
                    })),
                    rowspan: tactic.otherKpis.length + 1
                };
                return row;
            });

            this.originalData = JSON.parse(JSON.stringify(this.data));
                    if(this.data.length > 0){
                        this.isMetricsVisible = true;
                    }
        })
        .catch(error => {
        });
}

    // restrict e,+,-,E characters in  input type number
    isNumericOnly(event) {
        const charCode = (event.which) ? event.which : event.keyCode;
        if (charCode == 101 || charCode == 69 || charCode == 45 || charCode == 43) {
            event.stopPropagation();
            event.preventDefault();
            return false;
        }
        return true;
    }

     @api
    isFormValid() {
        var isValid = false;
        var allInputValid = false;

        allInputValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allInputValid ) {
            isValid = true;
        }
        return isValid;
    }

   /* getLocalizedLabel(options, apiValue){
        const match = options.find(opt => opt.value === apiValue);
        return match?.label || apiValue;
    }*/

}