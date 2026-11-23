// aiFieldSuggestions.js
import { LightningElement, api, track } from 'lwc';
import analyzeDescriptionWithAI from '@salesforce/apex/Core_MDF_AiFieldSuggestions.analyzeDescriptionWithAI';
import analyzeFileWithAI from '@salesforce/apex/Core_MDF_AiFieldSuggestions.analyzeFileWithAI';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Core_MDF_AiFieldSuggestions extends LightningElement {
    @api description = '';
    @api recordTypeDeveloperName = '';
    
    @track showModal = false;
    @track isLoading = false;
    @track suggestions = {};
    @track errorMessage = '';
    @track selectedFields = {};
    @track userInputs = {};
    
    // AI Tracking - store analysis metadata
    _filesAnalyzed = [];
    _analysisMode = '';
    
    // Fields that allow user input
    editableFields = ['campaignName','campaignDescription', 'startDate', 'endDate', 'totalInvestment', 'maxIntelInvestment'];

    // Getter for filesAnalyzed
    get filesAnalyzed() {
        return this._filesAnalyzed || [];
    }

    // Getter for analysisMode
    get analysisMode() {
        return this._analysisMode || '';
    }

    isFieldValuePresent(value) {
        return value !== null && value !== undefined && value !== '' &&
            (typeof value === 'string' ||
            typeof value === 'number' ||
            (Array.isArray(value) && value.length > 0) ||
            (typeof value === 'object' && Object.keys(value).length > 0));
    }

    toAuraSafePayload(value) {
        try {
            return JSON.parse(JSON.stringify(value));
        } catch (e) {
            return null;
        }
    }
    
    get hasSuggestions() {
        return Object.keys(this.suggestions).length > 0 && 
               (this.suggestions.campaignName || 
                this.suggestions.campaignDescription ||
                this.suggestions.startDate || 
                this.suggestions.endDate || 
                this.suggestions.totalInvestment || 
                this.suggestions.maxIntelInvestment ||
                this.suggestions.account ||
                this.suggestions.outcomeActivityValues ||
                this.suggestions.spendingAmount ||
                this.suggestions.focusArea || 
                this.suggestions.priority || 
                this.suggestions.region || 
                (this.suggestions.country && this.suggestions.country.length > 0) ||
                (this.suggestions.targetAudience && this.suggestions.targetAudience.length > 0) ||
                (this.suggestions.brands && this.suggestions.brands.length > 0) ||
                (this.suggestions.technologies && this.suggestions.technologies.length > 0) ||
                (this.suggestions.initiatives && this.suggestions.initiatives.length > 0) ||
                (this.suggestions.ecosystemPartners && this.suggestions.ecosystemPartners.length > 0) ||
                (this.suggestions.productTypes && this.suggestions.productTypes.length > 0) ||
                (this.suggestions.tactics && this.suggestions.tactics.length > 0) ||
                (this.suggestions.outcomeMetrics && this.suggestions.outcomeMetrics.length > 0));
    }
    
    get isApplyDisabled() {
        return this.isLoading || !this.hasSelectedFields();
    }
    
    get selectedFieldsCount() {
        return Object.values(this.selectedFields).filter(selected => selected === true).length;
    }
    
    get totalFieldsCount() {
        let count = Object.keys(this.suggestions).filter(fieldName => {
            const value = this.suggestions[fieldName];
            return this.isFieldValuePresent(value);
        }).length;

        // Add count for individual outcome fields (they are nested but counted separately)
        const outcomeValues = this.suggestions.outcomeActivityValues;
        if (outcomeValues && typeof outcomeValues === 'object') {
            if (this.isFieldValuePresent(outcomeValues.baselineValue)) count++;
            if (this.isFieldValuePresent(outcomeValues.goalValue)) count++;
            if (this.isFieldValuePresent(outcomeValues.baselinePeriod)) count++;
            // Subtract 1 for outcomeActivityValues since it's being broken into components
            count--;
        }

        return count;
    }

    get accountDisplayValue() {
        const account = this.suggestions.account;
        if (!account) {
            return '';
        }
        if (typeof account === 'string') {
            return account;
        }
        return account.name || account.Name || account.id || account.Id || 'Suggested account';
    }

    get tacticMetricsSummary() {
        const tacticMetrics = this.suggestions.tacticMetrics;
        if (!tacticMetrics || typeof tacticMetrics !== 'object') {
            return '';
        }
        const goalHint = this.goalValuesSummary;
        const count = Object.keys(tacticMetrics).length;
        if (goalHint) {
            return `Tactic metrics detected (${count} entries) - ${goalHint}`;
        }
        return count > 0 ? `Tactic metrics data detected (${count} entries)` : 'Tactic metrics data detected';
    }

    get goalValuesSummary() {
        const goalValues = this.suggestions.goalValues;
        if (goalValues === null || goalValues === undefined || goalValues === '') {
            return '';
        }

        if (typeof goalValues === 'number' || typeof goalValues === 'string') {
            return `Goal value: ${goalValues}`;
        }

        if (typeof goalValues !== 'object') {
            return '';
        }

        if (goalValues.goalValue !== undefined && goalValues.goalValue !== null && goalValues.goalValue !== '') {
            return `Goal value: ${goalValues.goalValue}`;
        }

        const entries = Object.keys(goalValues).map(key => {
            const value = goalValues[key];
            if (value && typeof value === 'object') {
                const nested = value.goalValue ?? value.firstKpiValue ?? '';
                return nested !== '' ? `${key}: ${nested}` : '';
            }
            return `${key}: ${value}`;
        }).filter(Boolean);

        if (entries.length === 0) {
            return 'Goal values detected';
        }

        return entries.slice(0, 2).join(', ');
    }

    get outcomeActivitySummary() {
        const values = this.suggestions.outcomeActivityValues;
        if (!values || typeof values !== 'object') {
            return '';
        }

        const parts = [];
        if (this.isFieldValuePresent(values.outcomeMetric)) {
            parts.push(`Metric: ${values.outcomeMetric}`);
        }
        if (this.isFieldValuePresent(values.baselineValue)) {
            parts.push(`Baseline: ${values.baselineValue}`);
        }
        if (this.isFieldValuePresent(values.goalValue)) {
            parts.push(`Goal: ${values.goalValue}`);
        }
        if (this.isFieldValuePresent(values.baselinePeriod)) {
            parts.push(`Period: ${values.baselinePeriod}`);
        }
        if (this.isFieldValuePresent(values.resultValue)) {
            parts.push(`Result: ${values.resultValue}`);
        }

        return parts.length > 0 ? parts.join(' | ') : 'Outcome activity values detected';
    }

    get baselineValueSummary() {
        const values = this.suggestions.outcomeActivityValues;
        if (!values || typeof values !== 'object') {
            return '';
        }
        return this.isFieldValuePresent(values.baselineValue) ? `${values.baselineValue}` : '';
    }

    get goalValueSummary() {
        const values = this.suggestions.outcomeActivityValues;
        if (!values || typeof values !== 'object') {
            return '';
        }
        return this.isFieldValuePresent(values.goalValue) ? `${values.goalValue}` : '';
    }

    get baselinePeriodSummary() {
        const values = this.suggestions.outcomeActivityValues;
        if (!values || typeof values !== 'object') {
            return '';
        }
        return this.isFieldValuePresent(values.baselinePeriod) ? `${values.baselinePeriod}` : '';
    }

    get isOutcomeBaselineValueValid() {
        const values = this.suggestions.outcomeActivityValues;
        return values && typeof values === 'object' && this.isFieldValuePresent(values.baselineValue);
    }

    get isOutcomeGoalValueValid() {
        const values = this.suggestions.outcomeActivityValues;
        return values && typeof values === 'object' && this.isFieldValuePresent(values.goalValue);
    }

    get isOutcomeBaselinePeriodValid() {
        const values = this.suggestions.outcomeActivityValues;
        return values && typeof values === 'object' && this.isFieldValuePresent(values.baselinePeriod);
    }
    
    get selectionSummary() {
        return `${this.selectedFieldsCount} of ${this.totalFieldsCount} fields selected`;
    }
    
    get isUserInputDisabled() {
        const disabled = {};
        this.editableFields.forEach(field => {
            disabled[field] = !this.selectedFields[field];
        });
        return disabled;
    }
    
    get isTacticMetricsValid() {
        const tm = this.suggestions.tacticMetrics;
        return tm && typeof tm === 'object' && Object.keys(tm).length > 0;
    }
    
    get isGoalValuesValid() {
        const gv = this.suggestions.goalValues;
        return this.isFieldValuePresent(gv) && gv !== null;
    }
    
    get isTacticsValid() {
        const tactics = this.suggestions.tactics;
        return Array.isArray(tactics) && tactics.length > 0;
    }
    
    get tacticTableRows() {
        const tactics = this.suggestions.tactics || [];
        const tacticMetrics = this.suggestions.tacticMetrics || {};
        const rows = [];
        
        tactics.forEach(tacticName => {
            const tacticData = tacticMetrics[tacticName] || {};
            const metricsObj = tacticData.metrics || {};
            
            const metrics = Object.keys(metricsObj).map(metricName => ({
                name: metricName,
                goalValue: metricsObj[metricName]?.goalValue ?? 'N/A'
            }));
            
            rows.push({
                tacticName: tacticName,
                metrics: metrics,
                spendingAmount: tacticData.spendingAmount ? `$${Number(tacticData.spendingAmount).toLocaleString()}` : 'N/A',
                maxIntelInvestment: tacticData.maxIntelInvestment ? `$${Number(tacticData.maxIntelInvestment).toLocaleString()}` : 'N/A'
            });
        });
        
        return rows;
    }
    
    validateAndProcessTacticMetrics(tacticMetrics, tactics, globalSpendingAmount, globalMaxIntel) {
        // NO validation, NO auto-distribution, NO math
        // Only return what AI explicitly provided
        if (!tacticMetrics || typeof tacticMetrics !== 'object') {
            return null;
        }
        return tacticMetrics;
    }
    
    hasSelectedFields() {
        return Object.values(this.selectedFields).some(selected => selected === true);
    }
    @api
    openModalWithResults(combinedResult, recordTypeDeveloperName) {
        this.recordTypeDeveloperName = recordTypeDeveloperName;
        this.showModal = true;
        this.errorMessage = '';
        this.isLoading = false;
        this.description = (combinedResult && combinedResult.description) ? combinedResult.description : this.description;
        
        // Process the combined results
        this.suggestions = this.processAIResponse(combinedResult.suggestions);
        this.fileRawData = combinedResult.rawData;
        this._analysisMode = combinedResult.analysisMode;
        this._filesAnalyzed = combinedResult.filesAnalyzed;
        
        this.initializeSelectedFields();
        this.initializeUserInputs();
    }
    
    closeModal() {
        this.showModal = false;
        this.isLoading = false;
        this.suggestions = {};
        this.selectedFields = {};
        this.userInputs = {};
        this.errorMessage = '';
    }
    
    handleFieldSelection(event) {
        const fieldName = event.target.dataset.field;
        const isChecked = event.target.checked;
        
        // Create a new object to trigger reactivity
        this.selectedFields = {
            ...this.selectedFields,
            [fieldName]: isChecked
        };
        
        // If unchecking an editable field, reset its user input to AI suggestion
        if (!isChecked && this.editableFields.includes(fieldName)) {
            this.userInputs = {
                ...this.userInputs,
                [fieldName]: this.suggestions[fieldName]
            };
        }
        
    }
    
    handleUserInput(event) {
        const fieldName = event.target.dataset.field;
        const value = event.target.value;
        
        this.userInputs = {
            ...this.userInputs,
            [fieldName]: value
        };
        
    }
    
    selectAllFields() {
        const newSelectedFields = {};
        const newUserInputs = {};
        
        Object.keys(this.suggestions).forEach(fieldName => {
            const value = this.suggestions[fieldName];
            if (this.isFieldValuePresent(value)) {
                newSelectedFields[fieldName] = true;
                
                if (this.editableFields.includes(fieldName)) {
                    newUserInputs[fieldName] = this.suggestions[fieldName];
                }
            }
        });
        
        this.selectedFields = newSelectedFields;
        this.userInputs = { ...this.userInputs, ...newUserInputs };
        this.updateCheckboxesInDOM();
    }
    
    clearAllFields() {
        this.selectedFields = {};
        
        // Force re-render of checkboxes
        this.updateCheckboxesInDOM();
    }
    
    updateCheckboxesInDOM() {
        // Use setTimeout to ensure DOM is updated after reactive property changes
        setTimeout(() => {
            const checkboxes = this.template.querySelectorAll('input[type="checkbox"]');
            checkboxes.forEach(checkbox => {
                const fieldName = checkbox.dataset.field;
                checkbox.checked = this.selectedFields[fieldName] || false;
            });
        }, 100);
    }
    
    initializeSelectedFields() {
        const initialSelectedFields = {};
        
        Object.keys(this.suggestions).forEach(fieldName => {
            const value = this.suggestions[fieldName];
            if (this.isFieldValuePresent(value)) {
                initialSelectedFields[fieldName] = true;
            }
        });

        // Initialize the three new outcome fields
        const outcomeValues = this.suggestions.outcomeActivityValues;
        if (outcomeValues && typeof outcomeValues === 'object') {
            if (this.isFieldValuePresent(outcomeValues.baselineValue)) {
                initialSelectedFields.outcomeBaselineValue = true;
            }
            if (this.isFieldValuePresent(outcomeValues.goalValue)) {
                initialSelectedFields.outcomeGoalValue = true;
            }
            if (this.isFieldValuePresent(outcomeValues.baselinePeriod)) {
                initialSelectedFields.outcomeBaselinePeriod = true;
            }
            // Don't initialize outcomeActivityValues itself since we're breaking it into components
            delete initialSelectedFields.outcomeActivityValues;
        }
        
        this.selectedFields = initialSelectedFields;
    }
    
    initializeUserInputs() {
        const initialUserInputs = {};
        
        // Initialize user inputs for editable fields with AI suggestions
        this.editableFields.forEach(fieldName => {
            if (this.suggestions[fieldName]) {
                initialUserInputs[fieldName] = this.suggestions[fieldName];
            }
        });
        
        this.userInputs = initialUserInputs;
    }

    extractAccountHintFromDescription() {
        const text = (this.description || '').trim();
        if (!text) {
            return null;
        }

        const normalizeCandidate = (raw) => {
            if (!raw) {
                return null;
            }
            let candidate = String(raw)
                .replace(/[\n\r\t]+/g, ' ')
                .replace(/\s+/g, ' ')
                .trim();

            candidate = candidate.replace(/^[,.;:\-\s]+|[,.;:\-\s]+$/g, '');
            candidate = candidate.replace(/^(and|the|a|an)\s+/i, '').trim();

            if (!candidate || candidate.length < 3) {
                return null;
            }
            return candidate;
        };

        // Pattern 0 (highest priority): "IPA - <name>" or "IPA â€“ <name>" â€” account names start with "IPA -"
        const ipaNamePattern = /\b(IPA\s*[\-\u2013]\s*[a-z0-9_&()'.,\s]{2,80})/i;
        const ipaNameMatch = text.match(ipaNamePattern);
        if (ipaNameMatch && ipaNameMatch[1]) {
            const candidate = normalizeCandidate(ipaNameMatch[1]);
            if (candidate) {
                return candidate;
            }
        }

        // Pattern 1: "<name> account" (common user phrasing)
        const tailPattern = /\b([a-z0-9_&()'.,\-\s]{2,80}?)\s+account\b/ig;
        let match;
        let lastCandidate = null;
        while ((match = tailPattern.exec(text)) !== null) {
            const candidate = normalizeCandidate(match[1]);
            if (candidate) {
                lastCandidate = candidate;
            }
        }
        if (lastCandidate) {
            return lastCandidate;
        }

        // Pattern 2: "account: <name>" / "account - <name>"
        const leadPattern = /\baccount\s*[:\-]\s*([a-z0-9_&()'.,\-\s]{2,80})/i;
        const leadMatch = text.match(leadPattern);
        if (leadMatch && leadMatch[1]) {
            return normalizeCandidate(leadMatch[1]);
        }

        // Pattern 3: "with <name> teams/stakeholders/channels/partner" (common IPA phrasing)
        const withPhrasePattern = /\bwith\s+([a-z0-9_&()'.,\-\s]{2,80}?)\s+(teams?|stakeholders?|channels?|partners?|partner)\b/ig;
        while ((match = withPhrasePattern.exec(text)) !== null) {
            const candidate = normalizeCandidate(match[1]);
            if (candidate) {
                return candidate;
            }
        }

        // Pattern 4: short fuzzy "ipa <token>" / "<token> ipa" phrases.
        const ipaTokenPattern = /\b(ipa\s+[a-z0-9_&()'.,\-]{2,40}|[a-z0-9_&()'.,\-]{2,40}\s+ipa)\b/ig;
        while ((match = ipaTokenPattern.exec(text)) !== null) {
            const candidate = normalizeCandidate(match[1]);
            if (candidate) {
                return candidate;
            }
        }

        return null;
    }
    
    processAIResponse(aiData) {
        const processed = {};
        const normalizeNumericValue = (value) => {
            if (value === undefined || value === null || value === '') {
                return null;
            }
            if (typeof value === 'number') {
                return value;
            }
            const cleaned = String(value).replace(/[^0-9.-]/g, '');
            const parsed = parseFloat(cleaned);
            return Number.isNaN(parsed) ? null : parsed;
        };
        const normalizeOutcomeActivityValues = (value) => {
            if (!value) {
                return null;
            }

            let raw = value;
            if (Array.isArray(raw)) {
                raw = raw.find(item => item && typeof item === 'object') || null;
            }
            if (!raw || typeof raw !== 'object') {
                return null;
            }

            if (raw.outcomeActivityValues && typeof raw.outcomeActivityValues === 'object') {
                raw = raw.outcomeActivityValues;
            }

            const normalizePeriod = (periodValue) => {
                if (!this.isFieldValuePresent(periodValue)) {
                    return null;
                }
                const text = String(periodValue).trim();
                if (!text) {
                    return null;
                }

                const periodMap = {
                    sameperiodasthiscampaignoneyearbefore: 'Same period as this campaign, one year before',
                    sameperiodasthiscampaignonehalfbefore: 'Same period as this campaign, one half before',
                    sameperiodasthiscampaignonequarterbefore: 'Same period as this campaign, one quarter before'
                };

                const key = text.toLowerCase().replace(/[^a-z0-9]/g, '');
                return periodMap[key] || text;
            };

            const metricValue = raw.outcomeMetric ?? raw.metric ?? raw.outcome ?? raw.outcomeMetrics;
            const baselineValue = normalizeNumericValue(raw.baselineValue ?? raw.baseLineValue ?? raw.baseline);
            const goalValue = normalizeNumericValue(raw.goalValue ?? raw.goal ?? raw.targetValue);
            const resultValue = normalizeNumericValue(raw.resultValue ?? raw.result ?? raw.actualValue);
            const baselinePeriod = normalizePeriod(raw.baselinePeriod ?? raw.baseLinePeriod ?? raw.period);

            const normalized = {};
            if (Array.isArray(metricValue) && metricValue.length > 0 && this.isFieldValuePresent(metricValue[0])) {
                normalized.outcomeMetric = String(metricValue[0]).trim();
            } else if (this.isFieldValuePresent(metricValue)) {
                normalized.outcomeMetric = String(metricValue).trim();
            }
            if (baselineValue !== null) {
                normalized.baselineValue = baselineValue;
            }
            if (goalValue !== null) {
                normalized.goalValue = goalValue;
            }
            if (baselinePeriod) {
                normalized.baselinePeriod = baselinePeriod;
            }
            if (resultValue !== null) {
                normalized.resultValue = resultValue;
            }

            return Object.keys(normalized).length > 0 ? normalized : null;
        };

        const normalizePeriodKey = (value) => {
            if (!this.isFieldValuePresent(value)) {
                return '';
            }
            return String(value).toLowerCase().replace(/[^a-z0-9]/g, '');
        };

        const scoreOutcomeValues = (value) => {
            if (!value || typeof value !== 'object') {
                return 0;
            }
            let score = 0;
            if (this.isFieldValuePresent(value.outcomeMetric)) score += 1;
            if (this.isFieldValuePresent(value.baselineValue)) score += 2;
            if (this.isFieldValuePresent(value.goalValue)) score += 2;
            if (this.isFieldValuePresent(value.baselinePeriod)) score += 1;
            return score;
        };

        const isLikelyDefaultOutcomeValues = (value) => {
            if (!value || typeof value !== 'object') {
                return false;
            }
            const baseline = normalizeNumericValue(value.baselineValue);
            const goal = normalizeNumericValue(value.goalValue);
            const periodKey = normalizePeriodKey(value.baselinePeriod);
            return baseline === 100 &&
                goal === 120 &&
                periodKey === 'sameperiodasthiscampaignoneyearbefore';
        };

        const mergeOutcomeValues = (aiValues, descriptionValues) => {
            if (!aiValues && !descriptionValues) {
                return null;
            }
            if (!aiValues) {
                return descriptionValues;
            }
            if (!descriptionValues) {
                return aiValues;
            }

            const aiScore = scoreOutcomeValues(aiValues);
            const descriptionScore = scoreOutcomeValues(descriptionValues);
            const aiLooksDefault = isLikelyDefaultOutcomeValues(aiValues);

            if (descriptionScore > aiScore || (aiLooksDefault && descriptionScore >= 2)) {
                return {
                    ...aiValues,
                    ...descriptionValues
                };
            }

            return {
                ...descriptionValues,
                ...aiValues
            };
        };
        const extractOutcomeFromDescription = () => {
            const source = (this.description || '').replace(/\r/g, '');
            if (!source) {
                return null;
            }

            const parseNumber = (text) => {
                if (!text) {
                    return null;
                }
                const cleaned = String(text).replace(/[^0-9.-]/g, '');
                const parsed = parseFloat(cleaned);
                return Number.isNaN(parsed) ? null : parsed;
            };

            const parseOutcomeBlock = (metricName, metricBody) => {
                const baselineMatch = metricBody.match(/Baseline\s+Value\s*:\s*([^\n]+)/i) || metricBody.match(/Baseline\s*:\s*([^\n]+)/i);
                const goalMatch = metricBody.match(/Goal\s+Value\s*:\s*([^\n]+)/i) || metricBody.match(/Goal\s*:\s*([^\n]+)/i);
                const periodMatch = metricBody.match(/Baseline\s+Period\s*:\s*([^\n]+)/i) || metricBody.match(/Period\s*:\s*([^\n]+)/i);

                const extracted = {};
                if (metricName && String(metricName).trim()) {
                    extracted.outcomeMetric = String(metricName).trim();
                }
                const baselineNum = parseNumber(baselineMatch && baselineMatch[1]);
                if (baselineNum !== null) {
                    extracted.baselineValue = baselineNum;
                }
                const goalNum = parseNumber(goalMatch && goalMatch[1]);
                if (goalNum !== null) {
                    extracted.goalValue = goalNum;
                }
                if (periodMatch && periodMatch[1]) {
                    extracted.baselinePeriod = String(periodMatch[1]).trim();
                }

                extracted.__score = 0;
                if (this.isFieldValuePresent(extracted.outcomeMetric)) extracted.__score += 1;
                if (this.isFieldValuePresent(extracted.baselineValue)) extracted.__score += 2;
                if (this.isFieldValuePresent(extracted.goalValue)) extracted.__score += 2;
                if (this.isFieldValuePresent(extracted.baselinePeriod)) extracted.__score += 1;
                return extracted;
            };

            const candidates = [];

            const blockRegex = /(?:Primary\s+)?Outcome\s+Metric(?:\s*\d+)?\s*:\s*([^\n]+)([\s\S]*?)(?=(?:Primary\s+)?Outcome\s+Metric(?:\s*\d+)?\s*:|$)/gi;
            let blockMatch;
            while ((blockMatch = blockRegex.exec(source)) !== null) {
                const candidate = parseOutcomeBlock(blockMatch[1], blockMatch[2] || '');
                if (candidate.__score > 0) {
                    candidates.push(candidate);
                }
            }

            // Also support inline/non-numbered format:
            // Metric: X | Baseline: Y | Goal: Z | Period: P
            const inlineMatch = source.match(/Metric\s*:\s*([^|\n]+)\|\s*Baseline(?:\s+Value)?\s*:\s*([^|\n]+)\|\s*Goal(?:\s+Value)?\s*:\s*([^|\n]+)(?:\|\s*(?:Baseline\s+)?Period\s*:\s*([^\n]+))?/i);
            if (inlineMatch) {
                const inlineBody = `Baseline Value: ${inlineMatch[2]}\nGoal Value: ${inlineMatch[3]}\n${inlineMatch[4] ? `Baseline Period: ${inlineMatch[4]}` : ''}`;
                const inlineCandidate = parseOutcomeBlock(inlineMatch[1], inlineBody);
                if (inlineCandidate.__score > 0) {
                    candidates.push(inlineCandidate);
                }
            }

            // Support freeform block where metric is a standalone line, e.g.:
            // Volume
            // - Baseline Value: 100
            // - Goal Value: 500
            // - Baseline Period: Same period as this campaign, one year before
            const standaloneMetricBlockRegex = /(?:^|\n)\s*(?!primary\s+outcome\s+metric\b)(?!outcome\s+metrics?\b)(?!campaign\s+overview\b)(?!campaign\s+details\b)(?!marketing\s+tactics\b)(?!technology\s+focus\b)(?!product\s+types\b)(?!brand\s+pillars\b)(?!campaign\s+execution\s+strategy\b)(?!account\b)([a-z][^\n:]{1,120})\s*\n\s*[-*]?\s*Baseline\s+Value\s*:\s*([^\n]+)\s*\n\s*[-*]?\s*Goal\s+Value\s*:\s*([^\n]+)(?:\s*\n\s*[-*]?\s*Baseline\s+Period\s*:\s*([^\n]+))?/gim;
            let standaloneMatch;
            while ((standaloneMatch = standaloneMetricBlockRegex.exec(source)) !== null) {
                const standaloneMetric = standaloneMatch[1] ? String(standaloneMatch[1]).trim() : '';
                const standaloneBody = `Baseline Value: ${standaloneMatch[2]}\nGoal Value: ${standaloneMatch[3]}\n${standaloneMatch[4] ? `Baseline Period: ${standaloneMatch[4]}` : ''}`;
                const standaloneCandidate = parseOutcomeBlock(standaloneMetric, standaloneBody);
                if (standaloneCandidate.__score > 0) {
                    candidates.push(standaloneCandidate);
                }
            }

            // Support prose-style sentences, e.g.:
            // "a baseline of 100 leads and a goal of 500 leads measured against the same period one year before"
            // "baseline of 50, goal of 150"
            // "starting from 10 with a target of 30"
            // "from 100 to 500 leads"
            if (candidates.length === 0) {
                const prosePatterns = [
                    // "a baseline of X [metric] and a goal of Y [metric] [period phrase]"
                    /\ba\s+baseline\s+of\s+(\d[\d,.]*)\s*(?:\w+\s*)?(?:and\s+a?\s*goal\s+of\s+(\d[\d,.]*))?/i,
                    // "baseline of X ... goal of Y"
                    /\bbaseline\s+of\s+(\d[\d,.]*)[\s\S]{0,80}?goal\s+of\s+(\d[\d,.]*)/i,
                    // "from X to Y [metric]"
                    /\bfrom\s+(\d[\d,.]*)\s+to\s+(\d[\d,.]*)/i,
                    // "target X ... baseline Y" or "goal X ... starting from Y"
                    /\btarget(?:ing)?\s+(\d[\d,.]*)[\s\S]{0,80}?baseline\s+(?:of\s+)?(\d[\d,.]*)/i,
                    // "starting at X with a target of Y"
                    /\bstarting\s+(?:at|from)\s+(\d[\d,.]*)[\s\S]{0,80}?target\s+(?:of\s+)?(\d[\d,.]*)/i
                ];

                const periodPhraseMap = [
                    { pattern: /same\s+period[^.]*one\s+year\s+before/i, value: 'Same period as this campaign, one year before' },
                    { pattern: /one\s+year\s+(?:ago|prior|before)/i, value: 'Same period as this campaign, one year before' },
                    { pattern: /year\s+over\s+year/i, value: 'Same period as this campaign, one year before' },
                    { pattern: /same\s+period[^.]*one\s+half\s+before/i, value: 'Same period as this campaign, one half before' },
                    { pattern: /same\s+period[^.]*one\s+quarter\s+before/i, value: 'Same period as this campaign, one quarter before' }
                ];

                // Try to find metric name near the prose baseline/goal statement
                const metricKeywords = [
                    'leads', 'opportunities', 'pipeline', 'deal wins', 'revenue',
                    'impressions', 'clicks', 'conversions', 'registrations', 'attendees',
                    'views', 'downloads', 'meetings', 'accounts', 'contacts'
                ];

                for (const prosePattern of prosePatterns) {
                    const proseMatch = source.match(prosePattern);
                    if (!proseMatch) continue;

                    const num1 = parseNumber(proseMatch[1]);
                    const num2 = parseNumber(proseMatch[2]);
                    if (num1 === null) continue;

                    // Determine which is baseline and which is goal
                    // For "from X to Y" and "baseline of X, goal of Y", num1 = baseline, num2 = goal
                    // For "target X ... baseline Y", num1 = goal, num2 = baseline
                    let baselineNum, goalNum;
                    if (prosePattern.source.includes('target')) {
                        baselineNum = num2;
                        goalNum = num1;
                    } else {
                        baselineNum = num1;
                        goalNum = num2;
                    }

                    const proseCandidate = {};
                    if (baselineNum !== null) proseCandidate.baselineValue = baselineNum;
                    if (goalNum !== null) proseCandidate.goalValue = goalNum;

                    // Look for period phrase in surrounding sentence
                    const matchIndex = source.search(prosePattern);
                    const surroundingText = source.substring(Math.max(0, matchIndex - 50), Math.min(source.length, matchIndex + 250));
                    for (const { pattern, value } of periodPhraseMap) {
                        if (pattern.test(surroundingText)) {
                            proseCandidate.baselinePeriod = value;
                            break;
                        }
                    }

                    // Look for metric keyword near the match
                    const nearbyText = surroundingText.toLowerCase();
                    for (const keyword of metricKeywords) {
                        if (nearbyText.includes(keyword)) {
                            // Map common keywords to formal metric names
                            const metricMap = {
                                leads: 'Volume - Leads',
                                opportunities: 'Revenue - Pipelines/Opportunities',
                                pipeline: 'Revenue - Pipelines/Opportunities',
                                'deal wins': 'Volume - Deal Wins',
                                revenue: 'Revenue - Pipelines/Opportunities'
                            };
                            proseCandidate.outcomeMetric = metricMap[keyword] || keyword;
                            break;
                        }
                    }

                    proseCandidate.__score = 0;
                    if (this.isFieldValuePresent(proseCandidate.outcomeMetric)) proseCandidate.__score += 1;
                    if (this.isFieldValuePresent(proseCandidate.baselineValue)) proseCandidate.__score += 2;
                    if (this.isFieldValuePresent(proseCandidate.goalValue)) proseCandidate.__score += 2;
                    if (this.isFieldValuePresent(proseCandidate.baselinePeriod)) proseCandidate.__score += 1;

                    if (proseCandidate.__score >= 2) {
                        candidates.push(proseCandidate);
                        break; // use first prose match only
                    }
                }
            }

            if (candidates.length === 0) {
                return null;
            }

            candidates.sort((a, b) => b.__score - a.__score);
            const best = { ...candidates[0] };
            delete best.__score;
            return Object.keys(best).length > 0 ? best : null;
        };
        
        // Process Basic Fields with confidence check
        if (aiData.campaignName && aiData.campaignNameConfidence >= 80) {
            processed.campaignName = aiData.campaignName;
        }

        if (aiData.campaignDescription && aiData.campaignDescriptionConfidence >= 80) {
        processed.campaignDescription = aiData.campaignDescription;
        }

        if (aiData.startDate && aiData.startDateConfidence >= 80) {
            processed.startDate = aiData.startDate;
        }
        
        if (aiData.endDate && aiData.endDateConfidence >= 80) {
            processed.endDate = aiData.endDate;
        }
        
        if (aiData.totalInvestment && aiData.totalInvestmentConfidence >= 80) {
            processed.totalInvestment = aiData.totalInvestment;
        }
        
        if (aiData.maxIntelInvestment && aiData.maxIntelInvestmentConfidence >= 80) {
            processed.maxIntelInvestment = aiData.maxIntelInvestment;
        }

        const accountHint = this.extractAccountHintFromDescription();

        // Process newly enabled account/tactic metrics/spending fields.
        // Only accept account hints that start with "IPA -" — all valid IPA accounts follow
        // this naming convention. Patterns 1-4 in extractAccountHintFromDescription() are too
        // loose for narrative descriptions (e.g. Pattern 3 matches "with European customers and
        // partners" → "European customers and"). Requiring the "IPA -" prefix ensures only
        // explicitly named IPA accounts (Pattern 0) are used from description text.
        if (accountHint && /^ipa\s*[-\u2013]/i.test(accountHint)) {
            processed.account = { name: accountHint };
        } else if (this.isFieldValuePresent(aiData.account)) {
            processed.account = aiData.account;
        } else if (this.isFieldValuePresent(aiData.accountName) &&
            (aiData.accountNameConfidence === undefined || aiData.accountNameConfidence >= 60)) {
            processed.account = { name: String(aiData.accountName).trim() };
        }

        // Only add tacticMetrics if it's a non-empty object with actual entries
        if (aiData.tacticMetrics && typeof aiData.tacticMetrics === 'object' && 
            Object.keys(aiData.tacticMetrics).length > 0 &&
            (aiData.tacticMetricsConfidence === undefined || aiData.tacticMetricsConfidence >= 80)) {
            
            // Validate multi-tactic distribution
            const tacticMetricsValidated = this.validateAndProcessTacticMetrics(
                aiData.tacticMetrics, 
                aiData.tactics, 
                aiData.spendingAmount,
                aiData.maxIntelInvestment
            );
            
            if (tacticMetricsValidated) {
                processed.tacticMetrics = tacticMetricsValidated;
            }
        }

        // Only add goalValues if it has actual values (not null/empty)
        if (this.isFieldValuePresent(aiData.goalValues) && aiData.goalValues !== null &&
            (aiData.goalValuesConfidence === undefined || aiData.goalValuesConfidence >= 80)) {
            processed.goalValues = aiData.goalValues;
        }

        const normalizedOutcomeActivityValues = normalizeOutcomeActivityValues(aiData.outcomeActivityValues);
        const descriptionOutcomeValues = extractOutcomeFromDescription();

        const mergedOutcomeActivityValues = mergeOutcomeValues(normalizedOutcomeActivityValues, descriptionOutcomeValues);
        if (mergedOutcomeActivityValues) {
            processed.outcomeActivityValues = mergedOutcomeActivityValues;
        }

        if (aiData.spendingAmount !== undefined && aiData.spendingAmount !== null &&
            (aiData.spendingAmountConfidence === undefined || aiData.spendingAmountConfidence >= 80)) {
            processed.spendingAmount = aiData.spendingAmount;
        }

        if (aiData.spendingPercentage !== undefined && aiData.spendingPercentage !== null &&
            (aiData.spendingPercentageConfidence === undefined || aiData.spendingPercentageConfidence >= 80)) {
            processed.spendingPercentage = aiData.spendingPercentage;
        }
        
        // Process Focus Area
        if (aiData.focusArea && aiData.focusAreaConfidence >= 80) {
            processed.focusArea = aiData.focusArea;
        }
        
        // Process Priority
        if (aiData.priority && aiData.priorityConfidence >= 80) {
            processed.priority = aiData.priority;
        }
        
        // Process arrays - only include if they have values
        const arrayFields = [
            'country', 'targetAudience', 'brands', 'technologies', 'initiatives', 
            'ecosystemPartners', 'productTypes', 'tactics', 'outcomeMetrics'
        ];
        
        arrayFields.forEach(field => {
            if (aiData[field] && Array.isArray(aiData[field]) && aiData[field].length > 0) {
                processed[field] = aiData[field];
            }
        });

        if ((!Array.isArray(processed.outcomeMetrics) || processed.outcomeMetrics.length === 0) &&
            processed.outcomeActivityValues && this.isFieldValuePresent(processed.outcomeActivityValues.outcomeMetric)) {
            processed.outcomeMetrics = [processed.outcomeActivityValues.outcomeMetric];
        }

        if (processed.outcomeActivityValues &&
            !this.isFieldValuePresent(processed.outcomeActivityValues.outcomeMetric) &&
            Array.isArray(processed.outcomeMetrics) && processed.outcomeMetrics.length > 0) {
            processed.outcomeActivityValues.outcomeMetric = processed.outcomeMetrics[0];
        }

        if ((!processed.outcomeActivityValues || typeof processed.outcomeActivityValues !== 'object') &&
            Array.isArray(processed.outcomeMetrics) && processed.outcomeMetrics.length > 0) {
            processed.outcomeActivityValues = {
                outcomeMetric: processed.outcomeMetrics[0]
                // NO default fallback values - only include what AI explicitly provides
            };
        }

        if (processed.outcomeActivityValues && typeof processed.outcomeActivityValues === 'object') {
            // NO default fallback values - only use what AI provides
        }

        // Enforce concrete defaults so suggestion cards are actionable and pre-selected.

        // 2) Do not force any hardcoded account fallback.

        const maxIntelForSpending = normalizeNumericValue(processed.maxIntelInvestment);
        const hasValidMaxIntelForSpending = maxIntelForSpending !== null && maxIntelForSpending > 0;

        // Spending fields must remain empty when max Intel investment is missing.
        if (!hasValidMaxIntelForSpending) {
            delete processed.spendingAmount;
            delete processed.spendingPercentage;
        }

        // 3) If tactics exist, ONLY use explicitly provided values - NO defaults, NO math, NO auto-distribution
        if (Array.isArray(processed.tactics) && processed.tactics.length > 0) {
            // Initialize tacticMetrics object if not present
            if (!this.isFieldValuePresent(processed.tacticMetrics) || typeof processed.tacticMetrics !== 'object') {
                processed.tacticMetrics = {};
            }
            // Only log what's being used
        }
        
        return processed;
    }
    
    applySuggestions() {
        try {
            // Only include selected suggestions
            const selectedSuggestions = {};

            Object.keys(this.selectedFields).forEach(fieldName => {
                if (this.selectedFields[fieldName]) {
                    // For editable fields, use user input if available, otherwise use AI suggestion
                    if (this.editableFields.includes(fieldName) && this.userInputs[fieldName] !== undefined) {
                        selectedSuggestions[fieldName] = this.userInputs[fieldName];
                    } else if (this.isFieldValuePresent(this.suggestions[fieldName])) {
                        selectedSuggestions[fieldName] = this.suggestions[fieldName];
                    }
                }
            });

            // âœ… ONLY include values that user explicitly selected - NO auto-population

            // Keep outcome payload complete so baseline/goal/period are not replaced by defaults.
            const hasSelectedOutcomeMetric = Array.isArray(selectedSuggestions.outcomeMetrics) && selectedSuggestions.outcomeMetrics.length > 0;
            const hasSelectedOutcomeBaseline = this.selectedFields.outcomeBaselineValue === true;
            const hasSelectedOutcomeGoal = this.selectedFields.outcomeGoalValue === true;
            const hasSelectedOutcomePeriod = this.selectedFields.outcomeBaselinePeriod === true;
            const hasSelectedOutcomeComponents = hasSelectedOutcomeBaseline || hasSelectedOutcomeGoal || hasSelectedOutcomePeriod;
            

            // Build outcomeActivityValues from individual selected components
            if (hasSelectedOutcomeComponents) {
                const outcomeActivityValues = this.suggestions.outcomeActivityValues && typeof this.suggestions.outcomeActivityValues === 'object' 
                    ? { ...this.suggestions.outcomeActivityValues }
                    : {};

                
                // Only include selected components, remove unselected ones
                if (!hasSelectedOutcomeBaseline && outcomeActivityValues.baselineValue !== undefined) {
                    delete outcomeActivityValues.baselineValue;
                }
                if (!hasSelectedOutcomeGoal && outcomeActivityValues.goalValue !== undefined) {
                    delete outcomeActivityValues.goalValue;
                }
                if (!hasSelectedOutcomePeriod && outcomeActivityValues.baselinePeriod !== undefined) {
                    delete outcomeActivityValues.baselinePeriod;
                }

                
                // Only add outcomeActivityValues if it has any components left
                if (Object.keys(outcomeActivityValues).length > 0) {
                    selectedSuggestions.outcomeActivityValues = outcomeActivityValues;
                }

            }

            // Ensure outcome metrics are paired with outcome values
            if (hasSelectedOutcomeComponents && !hasSelectedOutcomeMetric) {
                const metricFromValues = this.suggestions.outcomeActivityValues && this.suggestions.outcomeActivityValues.outcomeMetric;
                if (this.isFieldValuePresent(metricFromValues)) {
                    selectedSuggestions.outcomeMetrics = [metricFromValues];
                } else if (Array.isArray(this.suggestions.outcomeMetrics) && this.suggestions.outcomeMetrics.length > 0) {
                    selectedSuggestions.outcomeMetrics = [this.suggestions.outcomeMetrics[0]];
                }
            }

            if (hasSelectedOutcomeMetric && !hasSelectedOutcomeComponents && this.suggestions.outcomeActivityValues && typeof this.suggestions.outcomeActivityValues === 'object') {
                selectedSuggestions.outcomeActivityValues = this.suggestions.outcomeActivityValues;
            }

            if (Object.keys(selectedSuggestions).length === 0) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Warning',
                    message: 'Please select at least one field to apply suggestions',
                    variant: 'warning'
                }));
                return;
            }

            const auraSafeSuggestions = this.toAuraSafePayload(selectedSuggestions);
            const auraSafeRawData = this.toAuraSafePayload(this.fileRawData);
            const auraSafeOriginalSuggestions = this.toAuraSafePayload(this.suggestions);
            const auraSafeSelectedFields = this.toAuraSafePayload(this.selectedFields);
            const auraSafeUserInputs = this.toAuraSafePayload(this.userInputs);

            if (!auraSafeSuggestions) {
                throw new Error('Failed to build suggestion payload');
            }

            // Determine analysis type based on what was used
            let analysisType = 'Description';
            if (this.fileRawData && Object.keys(this.fileRawData).length > 0) {
                analysisType = this.description ? 'Combined' : 'File';
            }

            // Get list of analyzed files
            const filesAnalyzed = this.filesAnalyzed || [];

            // Dispatch event to parent component with selected suggestions and tracking data
            const applyEvent = new CustomEvent('applysuggestions', {
                detail: {
                    suggestions: auraSafeSuggestions,
                    rawData: auraSafeRawData,
                    originalSuggestions: auraSafeOriginalSuggestions,
                    selectedFields: auraSafeSelectedFields,
                    userInputs: auraSafeUserInputs,
                    analysisType: analysisType,
                    filesAnalyzed: filesAnalyzed
                }
            });
            this.dispatchEvent(applyEvent);

            const selectedCount = Object.keys(auraSafeSuggestions).length;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: `${selectedCount} AI suggestion${selectedCount > 1 ? 's' : ''} applied to the form`,
                variant: 'success'
            }));

            this.closeModal();
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: `Unable to apply AI suggestions: ${error && error.message ? error.message : 'Unknown error'}`,
                variant: 'error'
            }));
            // eslint-disable-next-line no-console
            console.error('AI suggestion apply failed:', error);
        }
    }
}