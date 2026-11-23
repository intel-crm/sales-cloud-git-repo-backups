// aiFieldSuggestions.js
import { LightningElement, api, track } from 'lwc';
import analyzeDescriptionWithAI from '@salesforce/apex/Core_MDF_PartnerFundRequestCreatePage.analyzeDescriptionWithAI';
import analyzeFileWithAI from '@salesforce/apex/Core_MDF_PartnerFundRequestCreatePage.analyzeFileWithAI';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AiFieldSuggestions extends LightningElement {
    @api description = '';
    @api recordTypeDeveloperName = '';
    
    @track showModal = false;
    @track isLoading = false;
    @track suggestions = {};
    @track errorMessage = '';
    @track selectedFields = {};
    @track userInputs = {};
    
    // Fields that allow user input
    editableFields = ['activityName', 'startDate', 'endDate', 'totalInvestment', 'maxIntelInvestment'];
    
    get hasSuggestions() {
        return Object.keys(this.suggestions).length > 0 && 
               (this.suggestions.activityName || 
                this.suggestions.startDate || 
                this.suggestions.endDate || 
                this.suggestions.totalInvestment || 
                this.suggestions.maxIntelInvestment ||
                this.suggestions.focusArea || 
                this.suggestions.priority || 
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
        return Object.keys(this.suggestions).filter(fieldName => {
            const value = this.suggestions[fieldName];
            return value && (typeof value === 'string' || (Array.isArray(value) && value.length > 0));
        }).length;
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
    
    hasSelectedFields() {
        return Object.values(this.selectedFields).some(selected => selected === true);
    }
    
    @api
    openModal(description, recordTypeDeveloperName) {
        this.description = description;
        this.recordTypeDeveloperName = recordTypeDeveloperName;
        this.showModal = true;
        this.errorMessage = '';
        this.suggestions = {};
        this.selectedFields = {};
        this.userInputs = {};
        this.analyzeDescription();
    }
    @api
openModalForFileAnalysis(contentDocumentIds, recordTypeDeveloperName) {
    this.recordTypeDeveloperName = recordTypeDeveloperName;
    this.showModal = true;
    this.errorMessage = '';
    this.suggestions = {};
    this.selectedFields = {};
    this.userInputs = {};
    this.isLoading = true;
    this._analyzeFiles(contentDocumentIds);
}

// Add this new private method
async _analyzeFiles(contentDocumentIds) {
    try {
        console.log('Analyzing files with IDs:', contentDocumentIds);
        
        const result = await analyzeFileWithAI({
            contentDocumentIds: contentDocumentIds,
            recordTypeDeveloperName: this.recordTypeDeveloperName
        });
        
        console.log('File AI Analysis Result:', result);
        
        if (result && result.success) {
            this.suggestions = this.processAIResponse(result.data);
            
            const filesAnalyzed = result.filesAnalyzed;
            if (filesAnalyzed && filesAnalyzed.length > 0) {
                // Show which files were analyzed
                this._filesAnalyzedNote = `Analyzed: ${filesAnalyzed.join(', ')}`;
            }
            
            this.initializeSelectedFields();
            this.initializeUserInputs();
        } else {
            this.errorMessage = result.error || 'Failed to analyze uploaded files';
        }
    } catch (error) {
        console.error('Error in file AI analysis:', error);
        this.errorMessage = 'An error occurred while analyzing the uploaded files';
    } finally {
        this.isLoading = false;
    }
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
        
        console.log('Field selection changed:', fieldName, isChecked);
        console.log('Current selectedFields:', this.selectedFields);
    }
    
    handleUserInput(event) {
        const fieldName = event.target.dataset.field;
        const value = event.target.value;
        
        this.userInputs = {
            ...this.userInputs,
            [fieldName]: value
        };
        
        console.log('User input changed:', fieldName, value);
    }
    
    selectAllFields() {
        const newSelectedFields = {};
        const newUserInputs = {};
        
        // Select all available suggestion fields
        Object.keys(this.suggestions).forEach(fieldName => {
            const value = this.suggestions[fieldName];
            if (value && (typeof value === 'string' || (Array.isArray(value) && value.length > 0))) {
                newSelectedFields[fieldName] = true;
                
                // Initialize user inputs for editable fields
                if (this.editableFields.includes(fieldName)) {
                    newUserInputs[fieldName] = this.suggestions[fieldName];
                }
            }
        });
        
        this.selectedFields = newSelectedFields;
        this.userInputs = { ...this.userInputs, ...newUserInputs };
        console.log('Select All - selectedFields:', this.selectedFields);
        
        // Force re-render of checkboxes
        this.updateCheckboxesInDOM();
    }
    
    clearAllFields() {
        this.selectedFields = {};
        console.log('Clear All - selectedFields:', this.selectedFields);
        
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
    
    async analyzeDescription() {
        if (!this.description || this.description.trim() === '') {
            this.errorMessage = 'Description is required for AI analysis';
            return;
        }
        
        this.isLoading = true;
        this.errorMessage = '';
        
        try {
            console.log('Calling AI with description:', this.description);
            console.log('Record Type:', this.recordTypeDeveloperName);
            
            const result = await analyzeDescriptionWithAI({
                description: this.description,
                recordTypeDeveloperName: this.recordTypeDeveloperName
            });
            
            console.log('AI Analysis Result:', result);
            
            if (result && result.success) {
                this.suggestions = this.processAIResponse(result.data);
                console.log('Processed suggestions:', this.suggestions);
                
                // Initialize selectedFields and userInputs with all suggestions selected by default
                this.initializeSelectedFields();
                this.initializeUserInputs();
            } else {
                this.errorMessage = result.error || 'Failed to analyze description with AI';
            }
        } catch (error) {
            console.error('Error in AI analysis:', error);
            this.errorMessage = 'An error occurred while analyzing the description';
        } finally {
            this.isLoading = false;
        }
    }
    
    initializeSelectedFields() {
        const initialSelectedFields = {};
        
        // Auto-select all available suggestions by default
        Object.keys(this.suggestions).forEach(fieldName => {
            const value = this.suggestions[fieldName];
            if (value && (typeof value === 'string' || (Array.isArray(value) && value.length > 0))) {
                initialSelectedFields[fieldName] = true;
            }
        });
        
        this.selectedFields = initialSelectedFields;
        console.log('Initialized selectedFields:', this.selectedFields);
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
        console.log('Initialized userInputs:', this.userInputs);
    }
    
    processAIResponse(aiData) {
        const processed = {};
        
        // Process Basic Fields with confidence check
        if (aiData.activityName && aiData.activityNameConfidence >= 80) {
            processed.activityName = aiData.activityName;
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
        
        return processed;
    }
    
    applySuggestions() {
        // Only include selected suggestions
        const selectedSuggestions = {};
        
        Object.keys(this.selectedFields).forEach(fieldName => {
            if (this.selectedFields[fieldName]) {
                // For editable fields, use user input if available, otherwise use AI suggestion
                if (this.editableFields.includes(fieldName) && this.userInputs[fieldName] !== undefined) {
                    selectedSuggestions[fieldName] = this.userInputs[fieldName];
                } else if (this.suggestions[fieldName]) {
                    selectedSuggestions[fieldName] = this.suggestions[fieldName];
                }
            }
        });
        
        if (Object.keys(selectedSuggestions).length === 0) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning',
                message: 'Please select at least one field to apply suggestions',
                variant: 'warning'
            }));
            return;
        }
        
        // Dispatch event to parent component with selected suggestions only
        const applyEvent = new CustomEvent('applysuggestions', {
            detail: {
                suggestions: selectedSuggestions
            }
        });
        this.dispatchEvent(applyEvent);
        
        // Show success toast
        const selectedCount = Object.keys(selectedSuggestions).length;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: `${selectedCount} AI suggestion${selectedCount > 1 ? 's' : ''} applied to the form`,
            variant: 'success'
        }));
        
        this.closeModal();
    }
}