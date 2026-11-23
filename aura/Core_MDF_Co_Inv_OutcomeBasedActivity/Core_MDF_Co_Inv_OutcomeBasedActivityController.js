({
    doInit: function (component, event, helper) {
        helper.initialize(component);
    },

    onAccountChange: function (component, event, helper) {
        helper.handleAccountChange(component);
    },

    onDateChange: function (component, event, helper) {
        helper.validateDates(component);
    },

    onTotalInvestmentChange: function (component, event, helper) {
        helper.calculateTotalInvestment(component);
    },

    onMaxIntelInvestmentChange: function (component, event, helper) {
        helper.calculateMaxIntelInvestment(component);
    },

    onRegionChange: function (component, event, helper) {
        helper.handleRegionChange(component);
    },

    onBudgetTypeChange: function (component, event, helper) {
        helper.onBudgetTypeChange(component);
    },

    // Budget Table Methods
    addBudgetAllocation: function (component, event, helper) {
        helper.addBudgetAllocationRow(component);
    },

    removeBudgetAllocation: function (component, event, helper) {
        var source = event.getSource();
        var auraId = source.get('v.aura:id');
        if (auraId) {
            var parts = auraId.split('_');
            var index = parseInt(parts[parts.length - 1]);
            if (!isNaN(index)) {
                helper.removeBudgetAllocationRow(component, index);
            }
        }
    },

    onPercentageChange: function (component, event, helper) {
        var source = event.getSource();
        var auraId = source.get('v.aura:id');
        if (auraId) {
            var parts = auraId.split('_');
            var index = parseInt(parts[parts.length - 1]);
            if (!isNaN(index)) {
                helper.updateBudgetAllocation(component, index);
            }
        }
    },

    validateBudgetAllocations: function (component, event, helper) {
        helper.validateBudgetAllocations(component);
    },

    onSelectBudget: function (component, event, helper) {
        // Method triggered when a budget is selected from dropdown in table
        var source = event.getSource();
        var auraId = source.get('v.aura:id');
        
        // Extract index from aura:id which is budgetSelect_0, budgetSelect_1, etc.
        var index = -1;
        if (auraId) {
            var parts = auraId.split('_');
            if (parts.length >= 2) {
                index = parseInt(parts[parts.length - 1]);
            }
        }
        
        if (!isNaN(index) && index >= 0) {
            helper.onBudgetSelect(component, index);
        } else {
            console.warn("Could not extract index from auraId: " + auraId);
        }
    },

    addBudgetAllocation: function (component, event, helper) {
        helper.addBudgetAllocationRow(component);
    },

    // Multi-select handlers
    setEcosystemPartner: function (component, event, helper) {
        var selectedValues = component.get("v.selectedEcosystemPartnerOptions");
        helper.handleMultiSelectChange(component, selectedValues, "v.ecosystemAllocations");
    },

    setInitiative: function (component, event, helper) {
        var selectedValues = component.get("v.selectedInitiativeOptions");
        helper.handleMultiSelectChange(component, selectedValues, "v.selectedInitiativeOptions");
    },

    setBrand: function (component, event, helper) {
        var selectedValues = component.get("v.selectedBrandOptions");
        helper.handleMultiSelectChange(component, selectedValues, "v.selectedBrandOptions");
    },

    setTechnology: function (component, event, helper) {
        var selectedValues = component.get("v.selectedTechnologyOptions");
        helper.handleMultiSelectChange(component, selectedValues, "v.selectedTechnologyOptions");
    },

    setOutcomeMetric: function (component, event, helper) {
        var selectedValues = component.get("v.selectedOutcomeMetricOptions");
        helper.handleMultiSelectChange(component, selectedValues, "v.selectedOutcomeMetricOptions");
    },

    setOutcomeType: function (component, event, helper) {
        var selectedValues = component.get("v.selectedOutcomeTypeOptions");
        helper.handleMultiSelectChange(component, selectedValues, "v.selectedOutcomeTypeOptions");
    },

    setTactics: function (component, event, helper) {
        var selectedValues = component.get("v.selectedTacticsOptions");
        helper.handleMultiSelectChange(component, selectedValues, "v.selectedTacticsOptions");
    },

    setMeasurementApproach: function (component, event, helper) {
        var selectedValues = component.get("v.selectedMeasurementApproachOptions");
        helper.handleMultiSelectChange(component, selectedValues, "v.selectedMeasurementApproachOptions");
    },

    setApprover: function (component, event, helper) {
        var selectedValues = component.get("v.selectedApproverOptions");
        helper.handleMultiSelectChange(component, selectedValues, "v.selectedApproverOptions");
    },

    setExtActSubmitter: function (component, event, helper) {
        var selectedValues = component.get("v.selectedExtActSubmitterOptions");
        helper.handleMultiSelectChange(component, selectedValues, "v.selectedExtActSubmitterOptions");
    }
})