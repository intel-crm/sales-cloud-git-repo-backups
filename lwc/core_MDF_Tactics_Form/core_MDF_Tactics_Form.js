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
    pendingAiPayload = null;
    staticGoalFallbackValue = 100;

    normalizeToken(value) {
        return value ? String(value).toLowerCase().replace(/[^a-z0-9]/g, '') : '';
    }

    normalizeNumericValue(value) {
        if (value === undefined || value === null || value === '') {
            return null;
        }
        if (typeof value === 'number') {
            return value;
        }
        const cleaned = String(value).replace(/[^0-9.-]/g, '');
        const parsed = parseFloat(cleaned);
        return Number.isNaN(parsed) ? null : parsed;
    }

    resolveTacticApi(value) {
        if (!value) {
            return value;
        }

        if (this.allMappings[value]) {
            return value;
        }

        const normalizedValue = this.normalizeToken(value);
        const apiKeys = Object.keys(this.allMappings || {});

        for (let i = 0; i < apiKeys.length; i++) {
            const apiKey = apiKeys[i];
            if (this.normalizeToken(apiKey) === normalizedValue) {
                return apiKey;
            }
            const mappedLabel = this.picklistLabelMap[apiKey];
            if (mappedLabel && this.normalizeToken(mappedLabel) === normalizedValue) {
                return apiKey;
            }
        }

        return value;
    }

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

                // If AI payload arrived before mapping/rows were ready, apply it now.
                if (this.pendingAiPayload && this.data.length > 0) {
                    const queuedPayload = this.pendingAiPayload;
                    this.pendingAiPayload = null;
                    this.applyAISuggestions(queuedPayload);
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
                row.maxIntelInvest = this.intelContributionValue;
                return {...row};});
        }
    
      @api handleTacticChange(params) {
    if (params.selectedTactics != undefined && params.selectedTactics != null && params.selectedTactics != '') {
        this.selectedTactics = JSON.parse(JSON.stringify(params.selectedTactics));
    } else {
        this.selectedTactics = JSON.parse(JSON.stringify(this.actTactics));
    }

    this.selectedTactics = (this.selectedTactics || []).map(tactic => this.resolveTacticApi(tactic));

    const previousDataMap = new Map(this.data.map(row => [row.tactic.api || row.tactic, row]));

    this.data = this.selectedTactics.map((tacticApi, index) => {
        const template = this.allMappings[tacticApi];
        if (!template) {
            console.warn(`No mapping found for tactic: ${tacticApi}`);
            return null;
        }

        const previousRow = previousDataMap.get(tacticApi);

        const previousKpiValuesByApi = new Map();

        if (previousRow?.firstKpi?.api) {
            previousKpiValuesByApi.set(
                previousRow.firstKpi.api,
                previousRow.firstKpi.value
            );
        }

        (previousRow?.otherKpis || []).forEach(savedKpi => {
            if (savedKpi?.api) {
                previousKpiValuesByApi.set(
                    savedKpi.api,
                    savedKpi.value
                );
            }
        }); //Indu defect fix 

        // Get localized labels dynamically from picklistLabelMap
        const tacticLabel = this.picklistLabelMap[tacticApi] || tacticApi;
        const percentageLabel = this.picklistLabelMap[template.percentageField] || template.percentageField;

        return {
            id: `${index}-${tacticApi}-${Date.now()}`,
            tactic: { api: tacticApi, label: tacticLabel },
            percentageField: { api: template.percentageField, label: percentageLabel },
            percentageValue: previousRow?.percentageValue ?? '',
            intelContri: previousRow?.intelContri ?? '',
           
          //  intelContri: previousRow?.percentageValue ? ((this.intelContributionValue * previousRow.percentageValue) / 100).toFixed(2) : 0,
            maxIntelInvest:this.intelContributionValue,

            firstKpi: {
                api: template.firstKpi.label,
                label: this.picklistLabelMap[template.firstKpi.label] || template.firstKpi.label,
                //value: previousRow?.firstKpi?.value ?? ''
                value: previousKpiValuesByApi.get(template.firstKpi.label) ?? ''
            },
            otherKpis: template.otherKpis.map((kpi, i) => ({
                api: kpi.label,
                label: this.picklistLabelMap[kpi.label] || kpi.label,
                //value: previousRow?.otherKpis?.[i]?.value ?? '' 
                value: previousKpiValuesByApi.get(kpi.label) ?? '' //indu
            })),
            rowspan: template.otherKpis.length + 1
        };
    }).filter(row => row !== null);

    this.originalData = JSON.parse(JSON.stringify(this.data));

    if (this.data.length > 0) {
        this.isMetricsVisible = true;
    }

    if (this.pendingAiPayload && this.data.length > 0) {
        const queuedPayload = this.pendingAiPayload;
        this.pendingAiPayload = null;
        this.applyAISuggestions(queuedPayload);
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
            // Sync live DOM values so callers get the current input value even if
            // the user hasn't blurred the field yet (onchange not yet fired).
            try {
                const firstKpiInputs = this.template.querySelectorAll('lightning-input[data-kpi-index="first"]');
                firstKpiInputs.forEach(input => {
                    const rowId = input.dataset.id;
                    const row = payload.find(r => String(r.id) === String(rowId));
                    if (row && row.firstKpi !== undefined) {
                        const val = parseFloat(input.value);
                        if (!isNaN(val)) {
                            row.firstKpi.value = val;
                        }
                    }
                });
            } catch (e) {
                // DOM query errors should not prevent returning the data-backed payload
            }
            return payload;
        }

        @api applyAISuggestions(payloadWrapper) {
            if (!payloadWrapper || !payloadWrapper.tacticMetrics) {
                return;
            }
            console.log('Applying AI suggestions with payloadWrapper:', JSON.parse(JSON.stringify(payloadWrapper)));
            if (!this.allMappings || Object.keys(this.allMappings).length === 0 || !Array.isArray(this.data) || this.data.length === 0) {
                // Defer AI application until tactic rows and mappings are available.
                this.pendingAiPayload = payloadWrapper;
                // eslint-disable-next-line no-console
                console.warn('Queued AI tactic metrics payload until mappings/rows are ready.');
                return;
            }

            const payload = payloadWrapper.tacticMetrics;
            console.log('Applying AI suggestions with payload:', JSON.parse(JSON.stringify(payload)));
            let hasSuggestedTactics = payload && payload.hasSuggestedTactics === true;

            let payloadArray = [];
            let globalPayload = {};

            if (Array.isArray(payload)) {
                payloadArray = payload;
            } else if (payload && typeof payload === 'object') {
                const reservedKeys = new Set(['spendingAmount', 'spendingPercentage', 'goalValues', 'tacticMetrics', 'goalValue', 'firstKpiValue', 'hasSuggestedTactics']);

                if (Array.isArray(payload.tacticMetrics)) {
                    payloadArray = payload.tacticMetrics;
                } else if (payload.tacticMetrics && typeof payload.tacticMetrics === 'object') {
                    payloadArray = Object.keys(payload.tacticMetrics).map(key => {
                        const item = payload.tacticMetrics[key];
                        return (item && typeof item === 'object') ? { tactic: key, ...item } : { tactic: key, goalValue: item };
                    });
                }

                const dynamicTacticEntries = Object.keys(payload)
                    .filter(key => !reservedKeys.has(key))
                    .map(key => {
                        const item = payload[key];
                        return (item && typeof item === 'object') ? { tactic: key, ...item } : { tactic: key, goalValue: item };
                    });

                if (dynamicTacticEntries.length > 0) {
                    payloadArray = payloadArray.concat(dynamicTacticEntries);
                }

                globalPayload = {
                    spendingAmount: payload.spendingAmount,
                    spendingPercentage: payload.spendingPercentage,
                    goalValues: payload.goalValues,
                    goalValue: payload.goalValue,
                    firstKpiValue: payload.firstKpiValue
                };
            }

            const hasGoalValuesObject = globalPayload.goalValues && typeof globalPayload.goalValues === 'object' && Object.keys(globalPayload.goalValues).length > 0;
            if (!hasSuggestedTactics && (payloadArray.length > 0 || hasGoalValuesObject)) {
                hasSuggestedTactics = true;
            }

            const warnings = [];
            const rowTacticNorms = new Set(
                (this.data || []).map(row => {
                    const rowApi = row.tactic && row.tactic.api ? row.tactic.api : row.tactic;
                    const rowLabel = row.tactic && row.tactic.label ? row.tactic.label : '';
                    return [this.normalizeToken(rowApi), this.normalizeToken(rowLabel)];
                }).flat().filter(Boolean)
            );

            const unmappedTactics = payloadArray
                .map(item => (item && typeof item === 'object') ? (item.tactic || item.tacticName || item.tacticApi) : null)
                .filter(Boolean)
                .filter(name => !rowTacticNorms.has(this.normalizeToken(name)));

            if (unmappedTactics.length > 0) {
                warnings.push(`Some AI tactic metrics could not be mapped: ${unmappedTactics.slice(0, 3).join(', ')}`);
            }

            const extractGoalFromObject = (goalObject, rowContext) => {
                if (!goalObject || typeof goalObject !== 'object') {
                    return null;
                }

                const rowApi = rowContext.rowTacticApi;
                const rowLabel = rowContext.rowTacticLabel;
                const rowApiNorm = rowContext.rowTacticApiNorm;
                const rowLabelNorm = rowContext.rowTacticLabelNorm;
                const firstKpiApi = rowContext.firstKpiApi;
                const firstKpiLabel = rowContext.firstKpiLabel;

                let value = goalObject[firstKpiApi] ?? goalObject[firstKpiLabel] ?? goalObject[rowApi] ?? goalObject[rowLabel] ?? null;

                if (value === undefined || value === null || value === '') {
                    const keys = Object.keys(goalObject);
                    const tacticMatchKey = keys.find(key => {
                        const normKey = this.normalizeToken(key);
                        return normKey === rowApiNorm || normKey === rowLabelNorm;
                    });
                    if (tacticMatchKey) {
                        value = goalObject[tacticMatchKey];
                    }
                }

                if (value && typeof value === 'object') {
                    value = value.goalValue ?? value.firstKpiValue ?? value[firstKpiApi] ?? value[firstKpiLabel] ?? null;
                }

                return value;
            };

            if (payloadArray.length === 0) {
                payloadArray = [globalPayload];
            }

            // ✅ NO AUTO-ALLOCATION MATH - Only use what AI explicitly suggests
            // Removed preparedAllocations calculation that was scaling amounts
            console.log('[Tactics Form] NO allocation math - using ONLY AI-suggested per-tactic values as-is');
            const preparedAllocations = null;

            this.data = this.data.map(row => {
                const rowClone = { ...row };
                const allowGlobalSpendFallback = this.data.length === 1;
                const rowTacticApi = rowClone.tactic && rowClone.tactic.api ? rowClone.tactic.api : rowClone.tactic;
                const rowTacticLabel = rowClone.tactic && rowClone.tactic.label ? rowClone.tactic.label : '';
                const rowTacticApiNorm = this.normalizeToken(rowTacticApi);
                const rowTacticLabelNorm = this.normalizeToken(rowTacticLabel);

                const matched = payloadArray.find(item => {
                    if (!item || typeof item !== 'object') {
                        return false;
                    }
                    const itemTactic = item.tactic || item.tacticName || item.tacticApi;
                    const itemTacticNorm = this.normalizeToken(itemTactic);
                    return itemTacticNorm && (itemTacticNorm === rowTacticApiNorm || itemTacticNorm === rowTacticLabelNorm);
                }) || null;

                if (preparedAllocations && matched) {
                    const matchedIndex = payloadArray.findIndex(item => item === matched);
                    if (matchedIndex >= 0 && preparedAllocations[matchedIndex] !== undefined) {
                        const normalizedAmount = preparedAllocations[matchedIndex];
                        rowClone.intelContri = normalizedAmount;
                        rowClone.percentageValue = targetTotal > 0
                            ? Number(((normalizedAmount / targetTotal) * 100).toFixed(2))
                            : rowClone.percentageValue;
                    }
                }

                const usePreparedAllocation = !!(preparedAllocations && matched);

                const effectivePercentage = !usePreparedAllocation && matched && matched.spendingPercentage !== undefined
                    ? matched.spendingPercentage
                    : (allowGlobalSpendFallback ? globalPayload.spendingPercentage : undefined);
                if (effectivePercentage !== undefined && effectivePercentage !== null && effectivePercentage !== '') {
                    const pct = this.normalizeNumericValue(effectivePercentage);
                    if (pct !== null) {
                        rowClone.percentageValue = pct;
                        rowClone.intelContri = this.intelContributionValue && !isNaN(this.intelContributionValue)
                            ? ((pct * this.intelContributionValue) / 100).toFixed(2)
                            : rowClone.intelContri;
                    } else {
                        warnings.push(`Invalid spending percentage for tactic ${rowTacticLabel || rowTacticApi}; value was skipped.`);
                    }
                }

                const effectiveAmount = !usePreparedAllocation && matched && matched.spendingAmount !== undefined
                    ? matched.spendingAmount
                    : (allowGlobalSpendFallback ? globalPayload.spendingAmount : undefined);
                if (effectiveAmount !== undefined && effectiveAmount !== null && effectiveAmount !== '') {
                    const amt = this.normalizeNumericValue(effectiveAmount);
                    if (amt !== null) {
                        rowClone.intelContri = amt;
                        rowClone.percentageValue = this.intelContributionValue && !isNaN(this.intelContributionValue)
                            ? ((amt / this.intelContributionValue) * 100).toFixed(2)
                            : rowClone.percentageValue;
                    } else {
                        warnings.push(`Invalid spending amount for tactic ${rowTacticLabel || rowTacticApi}; value was skipped.`);
                    }
                }

                // Mirror handleKpiChange index logic:
                // data-kpi-index="first" → firstKpi.value
                // data-kpi-index={kpiIndex} (0,1,...) → otherKpis[i].value
                // Match AI metric key by label name to decide which slot to stamp.
                // metricsHandled = true on ANY match (firstKpi or otherKpis) to block fallback from double-stamping firstKpi.
                //
                // KPI labels from picklistLabelMap often include the tactic name as a prefix,
                // e.g. "Digital Media - # of downloads" for a KPI the AI calls "# of downloads".
                // So we also accept a suffix/contains match:
                //   kpiNorm.endsWith(aiKeyNorm)  →  "digitalmediaofdownloads".endsWith("ofdownloads") = true
                const kpiMatchesAiKey = (kpiNorm, aiKeyNorm) =>
                    aiKeyNorm.length > 0 && (kpiNorm === aiKeyNorm || kpiNorm.endsWith(aiKeyNorm));

                let metricsHandled = false;
                if (matched && matched.metrics && typeof matched.metrics === 'object') {
                    const metricsKeys = Object.keys(matched.metrics);
                    metricsKeys.forEach(metricKey => {
                        const metricEntry = matched.metrics[metricKey];
                        const metricGoal = (metricEntry && typeof metricEntry === 'object')
                            ? (metricEntry.goalValue ?? metricEntry.firstKpiValue ?? null)
                            : metricEntry;
                        if (metricGoal === null || metricGoal === undefined || metricGoal === '') return;
                        const metricKeyNorm = this.normalizeToken(metricKey);
                        const parsedGoal = this.normalizeNumericValue(metricGoal);
                        const stampValue = parsedGoal !== null ? parsedGoal : metricGoal;
                        // Match against firstKpi label (data-kpi-index="first")
                        if (rowClone.firstKpi) {
                            const fApiNorm = this.normalizeToken(rowClone.firstKpi.api);
                            const fLabelNorm = this.normalizeToken(rowClone.firstKpi.label);
                            if (kpiMatchesAiKey(fApiNorm, metricKeyNorm) || kpiMatchesAiKey(fLabelNorm, metricKeyNorm)) {
                                rowClone.firstKpi = { ...rowClone.firstKpi, value: stampValue };
                                metricsHandled = true;
                                return;
                            }
                        }
                        // Match against otherKpis[i] label (data-kpi-index={kpiIndex})
                        if (Array.isArray(rowClone.otherKpis)) {
                            const kpiIdx = rowClone.otherKpis.findIndex(kpi => {
                                const kApiNorm = this.normalizeToken(kpi.api);
                                const kLabelNorm = this.normalizeToken(kpi.label);
                                return kpiMatchesAiKey(kApiNorm, metricKeyNorm) || kpiMatchesAiKey(kLabelNorm, metricKeyNorm);
                            });
                            if (kpiIdx >= 0) {
                                rowClone.otherKpis = rowClone.otherKpis.map((kpi, i) =>
                                    i === kpiIdx ? { ...kpi, value: stampValue } : kpi
                                );
                                metricsHandled = true;
                            }
                        }
                    });
                    // No name match — fall back to first metric entry on firstKpi
                    if (!metricsHandled && metricsKeys.length > 0 && rowClone.firstKpi) {
                        const firstEntry = matched.metrics[metricsKeys[0]];
                        const firstGoal = (firstEntry && typeof firstEntry === 'object')
                            ? (firstEntry.goalValue ?? firstEntry.firstKpiValue ?? null)
                            : firstEntry;
                        if (firstGoal !== null && firstGoal !== undefined && firstGoal !== '') {
                            const parsedFirst = this.normalizeNumericValue(firstGoal);
                            rowClone.firstKpi = { ...rowClone.firstKpi, value: parsedFirst !== null ? parsedFirst : firstGoal };
                            metricsHandled = true;
                        }
                    }
                }

                // Fallback chain — only runs when matched.metrics had no usable data
                let goalValue = !metricsHandled && matched ? (matched.goalValue ?? matched.firstKpiValue) : null;
                if (!metricsHandled && (goalValue === undefined || goalValue === null || goalValue === '') && matched && matched.goalValues !== undefined) {
                    if (typeof matched.goalValues === 'object' && matched.goalValues !== null) {
                        goalValue = extractGoalFromObject(matched.goalValues, {
                            rowTacticApi: rowTacticApi,
                            rowTacticLabel: rowTacticLabel,
                            rowTacticApiNorm: rowTacticApiNorm,
                            rowTacticLabelNorm: rowTacticLabelNorm,
                            firstKpiApi: rowClone.firstKpi.api,
                            firstKpiLabel: rowClone.firstKpi.label
                        });
                    } else {
                        goalValue = matched.goalValues;
                    }
                }
                if (!metricsHandled && (goalValue === undefined || goalValue === null || goalValue === '') && globalPayload.goalValue !== undefined) {
                    goalValue = globalPayload.goalValue;
                }
                if (!metricsHandled && (goalValue === undefined || goalValue === null || goalValue === '') && globalPayload.firstKpiValue !== undefined) {
                    goalValue = globalPayload.firstKpiValue;
                }
                if (!metricsHandled && (goalValue === undefined || goalValue === null || goalValue === '') && globalPayload.goalValues !== undefined) {
                    if (typeof globalPayload.goalValues === 'object' && globalPayload.goalValues !== null) {
                        goalValue = extractGoalFromObject(globalPayload.goalValues, {
                            rowTacticApi: rowTacticApi,
                            rowTacticLabel: rowTacticLabel,
                            rowTacticApiNorm: rowTacticApiNorm,
                            rowTacticLabelNorm: rowTacticLabelNorm,
                            firstKpiApi: rowClone.firstKpi.api,
                            firstKpiLabel: rowClone.firstKpi.label
                        });
                    } else {
                        goalValue = globalPayload.goalValues;
                    }
                }
                // Apply fallback only when no extracted/mapped goal value exists.
                if (!metricsHandled && (goalValue === undefined || goalValue === null || goalValue === '') && hasSuggestedTactics) {
                    goalValue = this.staticGoalFallbackValue;
                }
                if (!metricsHandled && goalValue !== undefined && goalValue !== null && rowClone.firstKpi) {
                    const parsedGoal = this.normalizeNumericValue(goalValue);
                    rowClone.firstKpi = {
                        ...rowClone.firstKpi,
                        value: parsedGoal === null ? goalValue : parsedGoal
                    };
                }

                return rowClone;
            });

            // ✅ NO RECONCILIATION MATH - Keep amounts exactly as AI suggested them
            // Removed all rounding/adjustment logic that was modifying tactic values
            console.log('[Tactics Form] NO reconciliation math - keeping AI-suggested amounts unchanged');

            if (this.intelContributionValue && !isNaN(this.intelContributionValue)) {
                const totalAllocated = this.data.reduce((sum, row) => {
                    const amount = this.normalizeNumericValue(row.intelContri);
                    return sum + (amount !== null ? amount : 0);
                }, 0);

                if (totalAllocated > Number(this.intelContributionValue) + 0.01) {
                    warnings.push(`Total tactic allocation (${totalAllocated.toFixed(2)}) exceeds maximum Intel investment (${Number(this.intelContributionValue).toFixed(2)}).`);
                }
            }

            this.originalData = JSON.parse(JSON.stringify(this.data));

            if (warnings.length > 0) {
                const uniqueWarnings = Array.from(new Set(warnings));
                // eslint-disable-next-line no-console
                console.warn('[AI Tactic Metrics]', uniqueWarnings);
            }
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
                    intelContri: (tactic.spendingAmount !== null && tactic.spendingAmount !== undefined && tactic.spendingAmount !== '')
                    ? tactic.spendingAmount
                    : (tactic.percentageValue && !isNaN(tactic.percentageValue)
                    ? ((tactic.percentageValue * this.intelContributionValue) / 100).toFixed(2)
                    : 0),
                   // intelContri: tactic.percentageValue != '' && tactic.percentageValue != null && tactic.percentageValue != undefined && !isNaN(tactic.percentageValue) ? ((tactic.percentageValue*this.intelContributionValue) / 100).toFixed(2) : 0,
                    maxIntelInvest:this.intelContributionValue,
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