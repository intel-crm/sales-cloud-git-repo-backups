({
    doInit: function (component, event, helper) {
        helper.initialize(component);
    },

    handleCancel: function (component, event, helper) {
        helper.closeModal(component);
    },

    handlePriority1Change: function (component, event, helper) {
        component.set("v.newPFR.Core_MDF_Priorities__c", component.get("v.SelPriority"));
        component.set("v.newPFR.Core_MDF_Priority__c", component.get("v.SelPriority"));
    },

    onRegionChange: function (component, event, helper) {
        helper.onRegionChange(component);
    },

    filterCountry: function (component, event, helper) {
        helper.filterCountry(component);
    },

    onCountryChange: function (component, event, helper) {
        component.set("v.newPFR.Core_MDF_Country_nm__c",
            (component.get("v.selectedCountryOptions") || []).join(";"));
    },

    onTargetAudienceChange: function (component, event, helper) {
        component.set("v.newPFR.Core_MDF_TargetAudience__c",
            (component.get("v.selectedTargetAudienceOptions") || []).join(";"));
    },

    onProductTypeChange: function (component, event, helper) {
        component.set("v.newPFR.Core_MDF_ProductType__c",
            (component.get("v.selectedProductTypeOptions") || []).join(";"));
    },

    onInitiativeChange: function (component, event, helper) {
        component.set("v.newPFR.Core_MDF_Initiative_nm__c",
            (component.get("v.selectedInitiativeOptions") || []).join(";"));
    },

    onEcoPartnerChange: function (component, event, helper) {
        var ecoOptions = component.get("v.selectedEcosystemPartnerOptions") || [];
        var hasOther = ecoOptions.indexOf("Others") !== -1 || ecoOptions.indexOf("Other") !== -1;
        component.set("v.showOtherEcosystemPartner", hasOther);
        if (!hasOther) {
            component.set("v.newPFR.Core_MDF_Other_Channel_Partner__c", "");
        }
        component.set("v.newPFR.Core_MDF_Channel_Partner__c", ecoOptions.join(";"));
        component.set("v.newPFR.Core_MDF_Ecosystem_Partner__c", ecoOptions.join(";"));
    },

    handleEcosystemPartnerRemove: function (component, event, helper) {
        var eventDetail = event.getParam('detail');
        var updatedPartners = eventDetail.updatedPartners;
        component.set("v.selectedEcosystemPartnerOptions", updatedPartners);
        var lwcEcosystemComp = component.find("ecosystemAllocation");
        if (lwcEcosystemComp) {
            lwcEcosystemComp.handleEcosystemPartnerRemoval(updatedPartners);
        }
    },

    onMarketingOutcomeMetricChange: function (component, event, helper) {
        helper.handleOutcomeMetricSelectionChange(
            component,
            "marketing",
            event.getParam("oldValue") || [],
            component.get("v.selectedMarketingOutcomeMetricOptions") || []
        );
    },

    onBusinessOutcomeMetricChange: function (component, event, helper) {
        helper.handleOutcomeMetricSelectionChange(
            component,
            "business",
            event.getParam("oldValue") || [],
            component.get("v.selectedBusinessOutcomeMetricOptions") || []
        );
    },

    onMarketingBrandChange: function (component, event, helper) {
        helper.syncBrandTechnologySelections(component);
    },

    onMarketingTechnologyChange: function (component, event, helper) {
        helper.syncBrandTechnologySelections(component);
    },

    onBusinessBrandChange: function (component, event, helper) {
        helper.syncBrandTechnologySelections(component);
    },

    onBusinessTechnologyChange: function (component, event, helper) {
        helper.syncBrandTechnologySelections(component);
    },

    onTacticsChange: function (component, event, helper) {
        var selectedTactics = component.get("v.selectedTacticsOptions") || [];
        component.set("v.newPFR.Core_MDF_Tactics_nm__c", selectedTactics.join(";"));

        var showPCTCheckbox = selectedTactics.includes('Incentive');
        component.set("v.showPCTApprovalCheckbox", showPCTCheckbox);
        helper.updateIncentiveSectionVisibility(component);

        if (!showPCTCheckbox) {
            component.set("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c", false);
        } else if (component.get("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c") === undefined ||
            component.get("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c") === null) {
            component.set("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c", false);
        }

        if (selectedTactics.length > 0) {
            var tacticMetricsComponent = component.find("tacticMetrics");
            if (tacticMetricsComponent) {
                if (helper.isNotBlank(tacticMetricsComponent[0])) {
                    tacticMetricsComponent[0].handleTacticChange({ selectedTactics: selectedTactics });
                } else {
                    tacticMetricsComponent.handleTacticChange({ selectedTactics: selectedTactics });
                }
            }
        } else {
            component.set("v.tacticMetricsValues", []);
        }
    },

    handlePCTApprovalChange: function (component, event, helper) {
        var isChecked = event.getSource().get("v.checked");
        component.set("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c", Boolean(isChecked));
    },

    onMeasurementApproachChange: function (component, event, helper) {
        component.set("v.newPFR.Core_MDF_Measurement_Approach_nm__c",
            (component.get("v.selectedMeasurementApproachOptions") || []).join(";"));
    },

    resetAccountattributes: function (component, event, helper) {
        helper.fetchBudgetTypesBasedOnBenefits(component);
    },

    onDateChange: function (component, event, helper) {
        helper.validateDates(component);
        var budgetType = component.get("v.newPFR.Core_MDF_Budget_Type_nm__c");
        if (budgetType && budgetType !== "") {
            helper.fetchAvailableBudgets(component, budgetType);
        }
    },

    onBudgetTypeChange: function (component, event, helper) {
        if (component.get("v.isInitialRecordLoad") === true) {
            return;
        }
        helper.onBudgetTypeChange(component);
    },

    onTotalInvestmentChange: function (component, event, helper) {
        var totalInvestment = parseFloat(event.getSource().get("v.value")) || 0;
        component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c", totalInvestment);
        component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", 1);
    },

    onMaxIntelInvestmentChange: function (component, event, helper) {
        var maxIntelContribution = parseFloat(event.getSource().get("v.value")) || 0;
        component.set("v.newPFR.Core_MDF_Maximum_Intel_Investment_amt__c", maxIntelContribution);
        component.set("v.newPFR.Core_MDF_Activity_Reimbursement_Amt_nbr__c", maxIntelContribution);
        helper.recalculateAllAllocations(component);
    },

    // ─────────────────────────────────────────────
    // BUDGET TABLE: ADD ROW
    // ─────────────────────────────────────────────
    addBudgetAllocation: function (component, event, helper) {
        helper.addBudgetAllocationRow(component);
    },

    // ─────────────────────────────────────────────
    // BUDGET TABLE: REMOVE ROW
    // ─────────────────────────────────────────────
    removeBudgetAllocation: function (component, event, helper) {
        var source = event.getSource();
        var name = source.get("v.name");
        var index = -1;
        if (name) {
            var parts = name.split("_");
            index = parseInt(parts[parts.length - 1]);
        }
        if (!isNaN(index) && index >= 0) {
            helper.removeBudgetAllocationRow(component, index);
        }
    },

    // ─────────────────────────────────────────────
    // BUDGET TABLE: SELECT BUDGET FROM DROPDOWN
    // ─────────────────────────────────────────────
    onBudgetSelect: function (component, event, helper) {
        var source = event.getSource();
        var selectedBudgetId = source.get("v.value");
        var name = source.get("v.name");
        var index = -1;
        if (name) {
            var parts = name.split("_");
            index = parseInt(parts[parts.length - 1]);
        }
        if (!isNaN(index) && index >= 0) {
            helper.onBudgetSelected(component, index, selectedBudgetId);
        }
    },

    // ─────────────────────────────────────────────
    // BUDGET TABLE: AMOUNT INPUT CHANGE
    // ─────────────────────────────────────────────
    onAmountChange: function (component, event, helper) {
        var source = event.getSource();
        var enteredValue = source.get("v.value");
        var name = source.get("v.name");
        var index = -1;
        if (name) {
            var parts = name.split("_");
            index = parseInt(parts[parts.length - 1]);
        }
        if (!isNaN(index) && index >= 0) {
            helper.updateAllocationByAmount(component, index, enteredValue);
        }
    },

    handleSave: function (component, event, helper) {
        helper.saveRecord(component, false);
    },

    handleSaveAndNew: function (component, event, helper) {
        helper.saveRecord(component, true);
    }
})