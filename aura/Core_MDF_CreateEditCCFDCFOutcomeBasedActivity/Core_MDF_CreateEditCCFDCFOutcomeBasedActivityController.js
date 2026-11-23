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
        component.set("v.newPFR.Core_MDF_Country_nm__c", (component.get("v.selectedCountryOptions") || []).join(";"));
        helper.fetchApprovers(component);
    },

    onTargetAudienceChange: function (component, event, helper) {
        component.set("v.newPFR.Core_MDF_TargetAudience__c", (component.get("v.selectedTargetAudienceOptions") || []).join(";"));
    },

    onProductTypeChange: function (component, event, helper) {
        component.set("v.newPFR.Core_MDF_ProductType__c", (component.get("v.selectedProductTypeOptions") || []).join(";"));
    },

    /*onBrandChange: function(component, event, helper) {
        component.set("v.newPFR.Core_MDF_Brand_nm__c", (component.get("v.selectedBrandOptions") || []).join(";"));
    },*/

    onInitiativeChange: function (component, event, helper) {
        component.set("v.newPFR.Core_MDF_Initiative_nm__c", (component.get("v.selectedInitiativeOptions") || []).join(";"));
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
        component.set("v.newPFR.Core_MDF_Other_Channel_Partner__c", component.get("v.newPFR.Core_MDF_Other_Channel_Partner__c") || "");
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

    /*onTechnologyChange: function(component, event, helper) {
        component.set("v.newPFR.Core_MDF_Technology_txt__c", (component.get("v.selectedTechnologyOptions") || []).join(";"));
    },*/

    /*onOutcomeMetricChange: function(component, event, helper) {
        component.set("v.newPFR.Core_MDF_Outcomes_nm__c", (component.get("v.selectedOutcomeMetricOptions") || []).join(";"));
    },*/
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
        component.set("v.newPFR.Core_MDF_Measurement_Approach_nm__c", (component.get("v.selectedMeasurementApproachOptions") || []).join(";"));
    },

    setApprover: function (component, event, helper) {
        var intelOwner = component.get("v.selectedApproverOptions") || [];
        component.set("v.newPFR.Core_MDF_Intel_Activity_Owner_Id__c", intelOwner.length > 0 ? intelOwner[0] : null);
    },

    setExtActSubmitter: function (component, event, helper) {
        var submitters = component.get("v.selectedExtActSubmitterOptions") || [];
        component.set("v.newPFR.Core_MDF_Member_Acceptor_Id__c", submitters.join(";"));
    },

    saveBudget: function (component, event, helper) {
        var selectedBudget = component.get("v.selAvailableBudget");
        component.set("v.newPFR.BudgetId", selectedBudget || null);
        component.set("v.newPFR.Core_MDF_Budget_id__c", selectedBudget || null);
        helper.checkAvailAllocationAmt(component);
    },

    resetAccountattributes: function (component, event, helper) {
        // fetchBudgetTypesBasedOnBenefits resolves budgetType then chains fetchBudgetInfo/fetchApprovers itself;
        // calling them directly here too raced it with a stale blank budgetType and clobbered results.
        helper.fetchBudgetTypesBasedOnBenefits(component);
        helper.fetchMemberAcceptors(component);
    },

    onDateChange: function (component, event, helper) {
        helper.clearBudgetSelection(component);
        helper.fetchBudgetInfo(component);
    },

    onBudgetTypeChange: function (component, event, helper) {
        // This "change" handler also fires when loadPFR programmatically populates Core_MDF_Budget_Type_nm__c
        // during edit/clone load, not just on user-driven picklist changes. In that case clearing the budget
        // selection here wiped out the record's already-loaded selAvailableBudget/BudgetId before
        // loadPFR's own fetchBudgetTypesBasedOnBenefits -> fetchBudgetInfo chain could reconcile it,
        // so the field rendered as "None". Skip the clear/refetch while that initial load is in progress.
        if (component.get("v.isInitialRecordLoad") === true) {
            return;
        }
        helper.clearBudgetSelection(component);
        helper.fetchBudgetInfo(component);
        helper.fetchApprovers(component);
    },
    onTotalInvestmentChange: function (component, event, helper) {
        // CCF/DCF has no currency conversion UI, but the backend trigger
        // (Core_MDF_Process_PartnerFundRequest.recalculateSpendingLimit) derives RequestedAmount
        // from Core_MDF_Budget_Amount_Local_amt__c * Core_MDF_Exchange_Rate_ptc__c and NPEs when
        // either is null. Mirror the entered amount into Local Amt and default the rate to 1
        // so Budget_Amount_Local_amt__c is saved and the backend calc/ToBeClosedDate stamping runs.
        var totalInvestment = parseFloat(event.getSource().get("v.value")) || 0;
        component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c", totalInvestment);
        component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", 1);
    },

    onMaxIntelInvestmentChange: function (component, event, helper) {
        var maxIntelContribution = parseFloat(event.getSource().get("v.value")) || 0;
        component.set("v.newPFR.Core_MDF_Maximum_Intel_Investment_amt__c", maxIntelContribution);
        component.set("v.newPFR.Core_MDF_Activity_Reimbursement_Amt_nbr__c", maxIntelContribution);
    },

    handleSave: function (component, event, helper) {
        helper.saveRecord(component, false);
    },

    handleSaveAndNew: function (component, event, helper) {
        helper.saveRecord(component, true);
    }
})