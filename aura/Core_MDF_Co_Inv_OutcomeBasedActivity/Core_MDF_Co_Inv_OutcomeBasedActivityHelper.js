({
    // ═══════════════════════════════════════════════════════════════
    // LOGGING UTILITIES
    // ═══════════════════════════════════════════════════════════════
    logDebug: function (tag, data) {
        try {
            console.log("[CCFDCF-Outcome] " + tag, data !== undefined ? data : "");
        } catch (e) { /* no-op */ }
    },

    logWarn: function (tag, data) {
        try {
            console.warn("[CCFDCF-Outcome] " + tag, data !== undefined ? data : "");
        } catch (e) { /* no-op */ }
    },

    // ═══════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════
    initialize: function (component) {
        component.set("v.showSpinner", true);
        this.fetchAdditionalReviewPermission(component);
        this.logDebug("initialize:start", {
            mode: component.get("v.mode"),
            recordId: component.get("v.recordId"),
            recordtypeName: component.get("v.recordtypeName"),
            recordtypeDeveloperName: component.get("v.recordtypeDeveloperName")
        });

        var fields = $A.get("$Label.c.Core_MDF_PFRPicklistField");
        if (fields) {
            this.convertApitoLable(component, fields.split(","));
        }

        if (component.get("v.checkCloneAttribute") === true &&
            this.isNotBlank(component.get("v.checkCloneRecordId"))) {
            component.set("v.recordId", component.get("v.checkCloneRecordId"));
        }

        if (this.isNotBlank(component.get("v.recordId"))) {
            component.set("v.mode",
                component.get("v.checkCloneAttribute") === true ? "clone" : "edit");
        } else if (!this.isNotBlank(component.get("v.mode"))) {
            component.set("v.mode", "create");
        }

        var shouldLoadExistingRecord = !!component.get("v.recordId") &&
            (component.get("v.mode") === "edit" ||
                component.get("v.checkCloneAttribute") === true);

        this.logDebug("initialize:shouldLoadExistingRecord", {
            shouldLoadExistingRecord: shouldLoadExistingRecord,
            mode: component.get("v.mode"),
            checkCloneAttribute: component.get("v.checkCloneAttribute")
        });

        // Initialize budget table
        this.initializeBudgetTable(component);

        if (shouldLoadExistingRecord) {
            this.loadPFR(component);
            return;
        }

        component.set("v.newPFR.Core_MDF_Is_Outcome_Based_Ind__c", true);
        component.set("v.newPFR.Core_MDF_Activity_Level_nm__c", "Super Activity");
        component.set("v.newPFR.Core_MDF_ActivityCategory__c",
            $A.get("$Label.c.Core_MDF_Outcome_Based_CatType"));
        component.set("v.newPFR.Core_MDF_Activity_Types__c",
            $A.get("$Label.c.Core_MDF_Outcome_Based_CatType"));
        component.set("v.newPFR.Core_MDF_Program__c", this.getBudgetProgram(component));
        component.set("v.newPFR.Core_MDF_Reimbursement_Rate__c",
            parseInt($A.get("$Label.c.Core_MDF_ReimburesementNum")));
        component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",
            $A.get("$Label.c.Core_MDF_ReimburementVal"));
        this.setAccountFilter(component);

        this.fetchRegion(component);
        this.initializePicklists(component);
        this.initializeCreateContext(component);

        this.logDebug("initialize:end", {
            selectedAccount: component.get("v.selectedAccount"),
            selectedBudgetType: component.get("v.newPFR.Core_MDF_Budget_Type_nm__c")
        });
        component.set("v.showSpinner", false);
    },

    // ═══════════════════════════════════════════════════════════════
    // BUDGET TABLE INITIALIZATION
    // ═══════════════════════════════════════════════════════════════
    initializeBudgetTable: function (component) {
        component.set("v.budgetAllocations", []);
        component.set("v.availableBudgets", []);
        component.set("v.totalPercentageAllocation", 0);
        component.set("v.totalAllocatedAmount", 0);
        component.set("v.remainingAmount", 0);
        component.set("v.budgetValidationError", "");
        component.set("v.showBudgetTable", false);
    },

    // ═══════════════════════════════════════════════════════════════
    // PICKLIST INITIALIZATION
    // ═══════════════════════════════════════════════════════════════
    initializePicklists: function (component) {
        var devName = component.get("v.recordtypeDeveloperName");
        var name = component.get("v.recordtypeName");
        var candidates = [];
        var isCoInv = /co_inv|co-inv|coinv/i.test((devName || "") + " " + (name || ""));

        if (isCoInv) {
            // No Co-Inv picklist record type exists; Co-Inv uses the DCF picklist record type.
            candidates.push($A.get("$Label.c.Core_MDF_DCF_RecordTypeName"));
        } else {
            if (this.isNotBlank(devName)) { candidates.push(devName); }
            if (this.isNotBlank(name) && candidates.indexOf(name) === -1) {
                candidates.push(name);
            }
        }

        this.logDebug("initializePicklists:candidates", candidates);
        this.activityPickerWithFallback(component, candidates, 0);
    },

    activityPickerWithFallback: function (component, recordTypeCandidates, index) {
        if (!recordTypeCandidates || index >= recordTypeCandidates.length) { return; }

        var candidate = recordTypeCandidates[index];
        var pickLabel = $A.get("$Label.c.Core_MDF_ActvityCategoryAndType");
        var pickListFields = (pickLabel ? pickLabel.split(",") : []);
        var knownFields = [
            "Core_MDF_Priorities__c", "Core_MDF_Priority_nm__c", "Core_MDF_Priority__c",
            "Core_MDF_Outcome_Region_nm__c", "Core_MDF_Country_nm__c",
            "Core_MDF_TargetAudience__c", "Core_MDF_ProductType__c",
            "Core_MDF_Brand_nm__c", "Core_MDF_Initiative_nm__c",
            "Core_MDF_Channel_Partner__c", "Core_MDF_Ecosystem_Partner__c",
            "Core_MDF_Other_Channel_Partner__c", "Core_MDF_Technology_txt__c",
            "Core_MDF_Technology__c", "Core_MDF_Outcomes_nm__c",
            "Core_MDF_Measurement_Approach_nm__c"
        ];

        for (var k = 0; k < knownFields.length; k++) {
            if (pickListFields.indexOf(knownFields[k]) === -1) {
                pickListFields.push(knownFields[k]);
            }
        }

        var action = component.get("c.mainPicklistFetcher");
        action.setParams({ recordTypeName: candidate });

        this.logDebug("activityPickerWithFallback:request", {
            candidate: candidate,
            index: index,
            totalCandidates: recordTypeCandidates.length
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state !== "SUCCESS") {
                this.logWarn("activityPickerWithFallback:non-success", {
                    candidate: candidate, state: state, errors: response.getError()
                });
                this.activityPickerWithFallback(component, recordTypeCandidates, index + 1);
                return;
            }

            var result = response.getReturnValue();
            if (!result || !result.picklistFieldValues) {
                this.logWarn("activityPickerWithFallback:empty-picklistFieldValues", {
                    candidate: candidate,
                    hasResult: !!result,
                    keys: result ? Object.keys(result) : []
                });
                this.activityPickerWithFallback(component, recordTypeCandidates, index + 1);
                return;
            }

            var hasPriority = !!(
                result.picklistFieldValues["Core_MDF_Priorities__c"] ||
                result.picklistFieldValues["Core_MDF_Priority_nm__c"] ||
                result.picklistFieldValues["Core_MDF_Priority__c"]
            );

            if (!hasPriority) {
                this.logWarn("activityPickerWithFallback:missing-priority", {
                    candidate: candidate,
                    availableFields: Object.keys(result.picklistFieldValues || {})
                });
                this.activityPickerWithFallback(component, recordTypeCandidates, index + 1);
                return;
            }

            for (var i = 0; i < pickListFields.length; i++) {
                var fieldName = pickListFields[i];
                var fieldDef = result.picklistFieldValues[fieldName] ||
                    result.picklistFieldValues[fieldName.toLowerCase()] ||
                    result.picklistFieldValues[fieldName.toUpperCase()];
                if (!fieldDef) { continue; }
                this.initActcategoryandType(
                    component, fieldName,
                    fieldDef.controllerValues, fieldDef.values
                );
            }

            this.fetchPriority(component);
            this.fetchSecondPriority(component);
            this.fetchRegion(component);
            this.fetchCountry(component);
            this.fetchMultiTargetAudience(component);
            this.fetchProdType(component);
            this.fetchMultiBrandType(component);
            this.fetchMultiInitiative(component);
            this.fetchMultiEcoPartnerType(component);
            this.fetchTechnologies(component);
            this.fetchOutcomeMetric(component);
            this.fetchMeasurementApproach(component);

            this.logDebug("activityPickerWithFallback:success", {
                candidate: candidate,
                priorityValuesCount: (component.get("v.priorityValues") || []).length,
                ecosystemPartnerValuesCount: (component.get("v.AllEcosystemPartner") || []).length
            });
        });

        $A.enqueueAction(action);
    },

    initializeCreateContext: function (component) {
        var recordId = component.get("v.recordId");
        var action;

        if (!recordId) {
            this.fetchBudgetTypesBasedOnBenefits(component);
            return;
        }

        action = component.get("c.getOutcomeCampaignAccount");
        action.setParams({ campaignId: recordId });

        action.setCallback(this, function (response) {
            if (response.getState() !== "SUCCESS") {
                this.logWarn("initializeCreateContext:non-success", {
                    state: response.getState(), errors: response.getError()
                });
            } else {
                var campaignAccount = response.getReturnValue();
                if (campaignAccount && campaignAccount.Id) {
                    component.set("v.selectedAccount", campaignAccount);
                }
            }
            this.fetchBudgetTypesBasedOnBenefits(component);
        });

        $A.enqueueAction(action);
    },

    // ═══════════════════════════════════════════════════════════════
    // LOAD EXISTING PFR (EDIT / CLONE)
    // ═══════════════════════════════════════════════════════════════
    loadPFR: function (component) {
        var recordId = component.get("v.recordId");
        if (!recordId) { return; }

        this.logDebug("loadPFR:start", { recordId: recordId });
        component.set("v.showSpinner", true);

        var action = component.get("c.loadPFRRecord");
        action.setParams({ pfrId: recordId });

        action.setCallback(this, function (response) {
            component.set("v.showSpinner", false);
            if (response.getState() !== "SUCCESS") {
                this.logWarn("loadPFR:non-success", {
                    state: response.getState(), errors: response.getError()
                });
                return;
            }

            var result = response.getReturnValue();
            if (!result) {
                this.logWarn("loadPFR:empty-result", null);
                return;
            }

            component.set("v.isInitialRecordLoad", true);
            component.set("v.newPFR", result);
            component.set("v.isAdditionalReviewReqd",
                component.get("v.checkCloneAttribute")
                    ? false
                    : Boolean(result.Core_MDF_Require_Additional_Review_ind__c));

            if (result.RecordType) {
                component.set("v.recordtypeName", result.RecordType.Name);
                component.set("v.recordtypeDeveloperName", result.RecordType.DeveloperName);
                this.setAccountFilter(component);
                this.activityPicker(
                    component,
                    result.RecordType.DeveloperName || result.RecordType.Name
                );
            }

            if (result.ChannelPartner && result.ChannelPartner.Id) {
                component.set("v.selectedAccount", result.ChannelPartner);
            }

            if (result.Core_MDF_Country_nm__c) {
                component.set("v.selectedCountryOptions",
                    result.Core_MDF_Country_nm__c.split(';'));
            }

            if (result.Core_MDF_TargetAudience__c || result.Core_MDF_TargetAudience_nm__c) {
                component.set("v.selectedTargetAudienceOptions",
                    (result.Core_MDF_TargetAudience__c ||
                        result.Core_MDF_TargetAudience_nm__c).split(';'));
            }

            if (result.Core_MDF_ProductType__c) {
                component.set("v.selectedProductTypeOptions",
                    result.Core_MDF_ProductType__c.split(';'));
            }

            if (result.Core_MDF_Channel_Partner__c || result.Core_MDF_Ecosystem_Partner__c) {
                var ecoPartnerRaw = result.Core_MDF_Channel_Partner__c ||
                    result.Core_MDF_Ecosystem_Partner__c;
                var ecoValues = ecoPartnerRaw.split(';').map(function (v) {
                    return v.trim();
                });
                component.set("v.selectedEcosystemPartnerOptions", ecoValues);
                component.set("v.showOtherEcosystemPartner",
                    ecoValues.indexOf("Others") !== -1 || ecoValues.indexOf("Other") !== -1);
            }

            if (result.Core_MDF_Other_Channel_Partner__c) {
                component.set("v.newPFR.Core_MDF_Other_Channel_Partner__c",
                    result.Core_MDF_Other_Channel_Partner__c);
            }

            if (result.Core_MDF_Priorities__c || result.Core_MDF_Priority__c) {
                var priorityValue = result.Core_MDF_Priorities__c || result.Core_MDF_Priority__c;
                component.set("v.SelPriority", priorityValue);
                component.set("v.newPFR.Core_MDF_Priorities__c", priorityValue);
                component.set("v.newPFR.Core_MDF_Priority__c", priorityValue);
            }

            if (result.Core_MDF_Outcome_Region_nm__c) {
                component.set("v.SelRegion", result.Core_MDF_Outcome_Region_nm__c);
                component.set("v.newPFR.Core_MDF_Outcome_Region_nm__c",
                    result.Core_MDF_Outcome_Region_nm__c);
            }

            if (result.Core_MDF_Budget_Type_nm__c) {
                component.set("v.newPFR.Core_MDF_Budget_Type_nm__c",
                    result.Core_MDF_Budget_Type_nm__c);
                // Show budget table since type is set
                component.set("v.showBudgetTable", true);
            }

            if (result.Core_MDF_Tactics_nm__c) {
                component.set("v.selectedTacticsOptions",
                    result.Core_MDF_Tactics_nm__c.split(';'));
                this.updateIncentiveSectionVisibility(component);
            }

            this.fetchBudgetTypesBasedOnBenefits(component);
            this.loadOutcomePurposeDetails(component);

            // Load existing budget allocations for edit/clone
            this.loadExistingBudgetAllocations(component, result);

            this.logDebug("loadPFR:end", {
                selectedAccountId: component.get("v.selectedAccount")
                    ? component.get("v.selectedAccount").Id : null,
                selectedPriority: component.get("v.SelPriority"),
                selectedRegion: component.get("v.SelRegion")
            });
        });

        $A.enqueueAction(action);
    },

    // ═══════════════════════════════════════════════════════════════
    // LOAD EXISTING BUDGET ALLOCATIONS (EDIT / CLONE)
    // ═══════════════════════════════════════════════════════════════
    loadExistingBudgetAllocations: function (component, result) {
        // If the loaded record has budget allocation data, restore it
        // This assumes the Apex loadPFRRecord returns budgetAllocations
        // as a list of allocation objects on the result wrapper
        if (result.budgetAllocations && result.budgetAllocations.length > 0) {
            var budgetType = component.get("v.newPFR.Core_MDF_Budget_Type_nm__c");
            if (budgetType && budgetType !== "") {
                component.set("v.showBudgetTable", true);
                // Fetch available budgets first, then restore allocations
                this.fetchAvailableBudgetsAndRestore(
                    component, budgetType, result.budgetAllocations
                );
            }
        } else if (result.BudgetId || result.Core_MDF_Budget_id__c) {
            // Legacy single-budget support: create one allocation row
            var budgetId = result.BudgetId || result.Core_MDF_Budget_id__c;
            var budgetType2 = component.get("v.newPFR.Core_MDF_Budget_Type_nm__c");
            if (budgetId && budgetType2) {
                component.set("v.showBudgetTable", true);
                this.fetchAvailableBudgetsAndRestore(component, budgetType2, [{
                    budgetId: budgetId,
                    allocationPercentage: 100,
                    allocatedAmount: parseFloat(
                        component.get("v.newPFR.Core_MDF_Maximum_Intel_Investment_amt__c")
                    ) || 0
                }]);
            }
        }
    },

    fetchAvailableBudgetsAndRestore: function (component, budgetType, allocationsToRestore) {
        var self = this;
        var action = component.get("c.fetchAvailableBudgetsForType");
        var selectedAccount = component.get("v.selectedAccount");
        var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var endDate = component.get("v.newPFR.Core_MDF_End_Date__c");

        action.setParams({
            budgetType: budgetType,
            accountId: (selectedAccount && selectedAccount.Id) ? selectedAccount.Id : "",
            startDate: startDate || "",
            endDate: endDate || ""
        });

        action.setCallback(this, function (response) {
            if (!component.isValid()) { return; }
            if (response.getState() !== "SUCCESS") {
                self.logWarn("fetchAvailableBudgetsAndRestore:error", response.getError());
                return;
            }

            var budgets = response.getReturnValue() || [];
            var budgetList = budgets.map(function (b) { return self.mapBudget(b); });

            component.set("v.availableBudgets", budgetList);

            // Restore allocation rows
            var maxIntelInvest = parseFloat(
                component.get("v.newPFR.Core_MDF_Maximum_Intel_Investment_amt__c")
            ) || 0;

            var restoredRows = allocationsToRestore.map(function (alloc) {
                var matchedBudget = null;
                for (var i = 0; i < budgetList.length; i++) {
                    if (budgetList[i].budgetId === alloc.budgetId) {
                        matchedBudget = budgetList[i];
                        break;
                    }
                }

                var pct = parseFloat(alloc.allocationPercentage) || 0;
                var storedAmt = parseFloat(alloc.allocatedAmount) || 0;
                var amt = storedAmt > 0
                    ? storedAmt
                    : (maxIntelInvest > 0
                        ? Math.round((maxIntelInvest * pct) / 100 * 100) / 100
                        : 0);
                if (maxIntelInvest > 0) {
                    pct = Math.round((amt / maxIntelInvest) * 100 * 100) / 100;
                }

                return {
                    id: "row_" + new Date().getTime() + "_" + Math.random(),
                    budgetId: alloc.budgetId || "",
                    budgetName: matchedBudget ? matchedBudget.budgetName : "",
                    budgetType: matchedBudget ? matchedBudget.budgetType : "",
                    revenueSegment: matchedBudget ? matchedBudget.revenueSegment : "",
                    availableAmount: matchedBudget ? matchedBudget.availableAmount : 0,
                    allocationPercentage: pct,
                    allocatedAmount: amt,
                    amountError: ""
                };
            });

            component.set("v.budgetAllocations", restoredRows);
            self.validateBudgetAllocations(component);

            self.logDebug("fetchAvailableBudgetsAndRestore:done", {
                budgetCount: budgetList.length,
                restoredRows: restoredRows.length
            });
        });

        $A.enqueueAction(action);
    },

    // ═══════════════════════════════════════════════════════════════
    // INCENTIVE SECTION VISIBILITY
    // ═══════════════════════════════════════════════════════════════
    updateIncentiveSectionVisibility: function (component) {
        var selectedTactics = component.get("v.selectedTacticsOptions") || [];
        var spifTactics = $A.get("$Label.c.Core_MDF_Spif_Tactics") || "";
        var isAvailable = selectedTactics.some(function (tactic) {
            return spifTactics.indexOf(tactic) !== -1;
        });
        component.set("v.isSPIFSecAvailable", isAvailable);
        if (!isAvailable) {
            component.set("v.segmentString", "");
        }
    },

    // ═══════════════════════════════════════════════════════════════
    // CLOSE MODAL
    // ═══════════════════════════════════════════════════════════════
    closeModal: function (component) {
        var parentComponent = component.get("v.parentComponent");
        if (parentComponent) {
            var overlay = parentComponent.get("v.modalOverlay");
            if (overlay) {
                overlay.close();
                parentComponent.set("v.modalOverlay", null);
                return;
            }
        }

        var closeQuickAction = $A.get("e.force:closeQuickAction");
        if (closeQuickAction) {
            closeQuickAction.fire();
            return;
        }

        var recordId = component.get("v.recordId");
        var navigateToRecord = $A.get("e.force:navigateToSObject");
        if (recordId && navigateToRecord) {
            navigateToRecord.setParams({ recordId: recordId, slideDevName: "detail" });
            navigateToRecord.fire();
            return;
        }

        var navigateHome = $A.get("e.force:navigateToObjectHome");
        if (navigateHome) {
            navigateHome.setParams({ scope: "PartnerFundRequest" });
            navigateHome.fire();
        }
    },

    // ═══════════════════════════════════════════════════════════════
    // TOAST
    // ═══════════════════════════════════════════════════════════════
    showToast: function (title, message, type) {
        if (type === "error") {
            console.warn("[CCFDCF-Outcome] showToast error:", title, message,
                new Error().stack);
        }
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title: title, message: message, type: type, duration: 5000
            });
            toastEvent.fire();
        }
    },

    // ═══════════════════════════════════════════════════════════════
    // UTILITY
    // ═══════════════════════════════════════════════════════════════
    isNotBlank: function (value) {
        return value !== undefined && value !== null && value !== "";
    },

    convertApitoLable: function (component, fieldlist) {
        var action = component.get("c.getLabelApiMapforPicklistfields");
        action.setParams({
            objName: "Core_MDF_Custom_Picklist__c",
            pfrPiclistField: fieldlist
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.apitoLabelConvert", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    activityPicker: function (component, recordType) {
        if (!recordType) { return; }
        this.activityPickerWithFallback(component, [recordType], 0);
    },

    initActcategoryandType: function (component, fldname, scontrolvalues, sfieldcompletevalues) {
        if (!Array.isArray(sfieldcompletevalues)) { return; }

        var controllingFieldValues = JSON.stringify(scontrolvalues || {}).slice(1, -1);
        var confieldmap = {};

        if (controllingFieldValues !== "") {
            var res = controllingFieldValues.split(",");
            for (var index = 0; index < res.length; index++) {
                var keyvalue = res[index].split(":");
                confieldmap[keyvalue[1]] = keyvalue[0].slice(1, -1);
            }
        }

        var childPickField = {};
        var ParPickField = [];
        var isDependentMap = scontrolvalues && Object.keys(scontrolvalues).length > 0;

        for (var i = 0; i < sfieldcompletevalues.length; i++) {
            var item = sfieldcompletevalues[i];
            if (item.validFor && item.validFor.length > 0) {
                for (var j = 0; j < item.validFor.length; j++) {
                    var key = confieldmap[item.validFor[j]];
                    if (!childPickField[key]) { childPickField[key] = []; }
                    childPickField[key].push({
                        class: "optionClass", label: item.label, value: item.value
                    });
                }
            } else {
                if (!isDependentMap && ParPickField.length === 0 &&
                    fldname !== "Core_MDF_Country_nm__c") {
                    ParPickField.push({
                        class: "optionClass",
                        label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                        value: ""
                    });
                }
                ParPickField.push({
                    class: "optionClass", label: item.label, value: item.value
                });
            }
        }

        if (ParPickField.length > 0) {
            childPickField[""] = ParPickField;
            if (fldname === "Core_MDF_Tactics_nm__c") {
                component.set("v.activityTacticsOptions",
                    this.localizeSubType(component, ParPickField, false));
            }
        }

        if (fldname === "Core_MDF_Focus_Area_nm__c") {
            component.set("v.focusArea", childPickField);
        } else if (fldname === "Core_MDF_Priorities__c" ||
            fldname === "Core_MDF_Priority_nm__c" ||
            fldname === "Core_MDF_Priority__c") {
            component.set("v.priority", childPickField);
        } else if (fldname === "Core_MDF_Outcome_Region_nm__c") {
            component.set("v.regions", childPickField);
        } else if (fldname === "Core_MDF_Country_nm__c") {
            component.set("v.CountryPicklistValues", childPickField);
        } else if (fldname === "Core_MDF_TargetAudience__c" ||
            fldname === "Core_MDF_TargetAudience_nm__c") {
            component.set("v.audiencePicklistValues", childPickField);
        } else if (fldname === "Core_MDF_ProductType__c") {
            component.set("v.ProductTypes", childPickField);
        } else if (fldname === "Core_MDF_Brand_nm__c") {
            component.set("v.MultiBrandTypes", childPickField);
        } else if (fldname === "Core_MDF_Initiative_nm__c") {
            component.set("v.initiativePicklistValues", childPickField);
        } else if (fldname === "Core_MDF_Channel_Partner__c" ||
            fldname === "Core_MDF_EcosystemPartner_nm__c" ||
            fldname === "Core_MDF_Ecosystem_Partner__c" ||
            fldname === "Core_MDF_Other_Channel_Partner__c") {
            component.set("v.MultiEcoPartnerTypes", childPickField);
        } else if (fldname === "Core_MDF_Technology_txt__c" ||
            fldname === "Core_MDF_Technology__c") {
            component.set("v.technologies", childPickField);
        } else if (fldname === "Core_MDF_Outcomes_nm__c") {
            component.set("v.outcomes", childPickField);
        } else if (fldname === "Core_MDF_Measurement_Approach_nm__c") {
            component.set("v.measurementApproachPicklistValues", childPickField);
        }
    },

    setChildPicklistValues: function (component, controllingValues, dependentValues) {
        var childPicklistValue = [];
        if (!dependentValues) { return childPicklistValue; }

        var effectiveController = controllingValues;
        if (!effectiveController && dependentValues[""]) { effectiveController = ""; }

        var childValueOptionsMap = dependentValues[effectiveController];
        if (!childValueOptionsMap && dependentValues[""]) {
            childValueOptionsMap = dependentValues[""];
        }

        if (childValueOptionsMap) {
            for (var index = 0; index < childValueOptionsMap.length; index++) {
                childPicklistValue.push(childValueOptionsMap[index]);
            }
            return childPicklistValue;
        }

        childPicklistValue.push({
            class: "optionClass",
            label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
            value: ""
        });
        return childPicklistValue;
    },

    localizeSubType: function (component, options, addNone) {
        var localizedMap = component.get("v.apitoLabelConvert") || {};
        var localizedOptions = [];

        if (addNone) {
            localizedOptions.push({
                label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"), value: ""
            });
        }

        for (var i = 0; i < options.length; i++) {
            var option = options[i];
            if (!option || option.value === "") { continue; }
            var label = localizedMap[option.value] ? localizedMap[option.value] : option.label;
            localizedOptions.push({
                label: label, value: option.value, class: option.class || "optionClass"
            });
        }
        return localizedOptions;
    },

    getAllDependentOptions: function (dependentMap) {
        var combined = [];
        var seen = {};
        if (!dependentMap) { return combined; }
        for (var key in dependentMap) {
            var arr = dependentMap[key] || [];
            for (var i = 0; i < arr.length; i++) {
                var val = arr[i].value;
                if (!seen[val]) {
                    seen[val] = true;
                    combined.push(arr[i]);
                }
            }
        }
        return combined;
    },

    getEffectiveControllingValue: function (component, fieldName) {
        var selectedFocusArea = component.get("v.selectedFocusArea");
        if (this.isNotBlank(selectedFocusArea)) { return selectedFocusArea; }

        var isRecordTypeDriven = fieldName === "Core_MDF_Country_nm__c" ||
            fieldName === "Core_MDF_Outcome_Region_nm__c" ||
            fieldName === "Core_MDF_Outcomes_nm__c" ||
            fieldName === "Core_MDF_Priorities__c" ||
            fieldName === "Core_MDF_Priority_nm__c" ||
            fieldName === "Core_MDF_TargetAudience__c" ||
            fieldName === "Core_MDF_Channel_Partner__c" ||
            fieldName === "Core_MDF_Other_Channel_Partner__c";

        if (isRecordTypeDriven) {
            return component.get("v.recordtypeDeveloperName") ||
                component.get("v.recordtypeName") || "";
        }
        return "";
    },

    getOptionsForControllerOrAll: function (component, controllingValue, dependentMap) {
        if (!dependentMap || Object.keys(dependentMap).length === 0) {
            return [{
                class: "optionClass",
                label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                value: ""
            }];
        }
        if (dependentMap && dependentMap[controllingValue]) {
            return this.setChildPicklistValues(component, controllingValue, dependentMap);
        }
        if (dependentMap && dependentMap[""]) {
            return this.setChildPicklistValues(component, "", dependentMap);
        }
        var allVals = this.getAllDependentOptions(dependentMap);
        allVals.unshift({
            class: "optionClass",
            label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
            value: ""
        });
        return allVals;
    },

    // ═══════════════════════════════════════════════════════════════
    // PICKLIST FETCHERS
    // ═══════════════════════════════════════════════════════════════
    fetchPriority: function (component) {
        var controllingValue = this.getEffectiveControllingValue(
            component, "Core_MDF_Priorities__c"
        );
        var values = this.getOptionsForControllerOrAll(
            component, controllingValue, component.get("v.priority")
        );
        values = this.localizeSubType(component, values, true);
        component.set("v.priorityDependent", values);
        component.set("v.priorityValues", values);
    },

    fetchSecondPriority: function (component) {
        // Not applicable for CCF/DCF form.
    },

    fetchRegion: function (component) {
        var action = component.get("c.getOutcomeRegionPicklistValues");
        action.setCallback(this, function (response) {
            if (response.getState() !== "SUCCESS") {
                this.logWarn("fetchRegion:non-success", {
                    state: response.getState(), errors: response.getError()
                });
                return;
            }
            var values = response.getReturnValue() || [];
            component.set("v.regionDependants", values);
            component.set("v.regionvalues", values);
        });
        $A.enqueueAction(action);
    },

    fetchCountry: function (component) {
        var recTypeKey = component.get("v.recordtypeDeveloperName") ||
            component.get("v.recordtypeName");
        var values = this.setChildPicklistValues(
            component, recTypeKey, component.get("v.CountryPicklistValues")
        );
        values = this.localizeSubType(component, values, false);
        component.set("v.CountryDependants", values);
        component.set("v.AllCountryOptionsMain", values);
        component.set("v.AllCountryOptions", values);
        if (component.get("v.SelRegion")) {
            this.fetchCountriesByRegionUsingAllOptions(
                component, component.get("v.SelRegion")
            );
        }
    },

    fetchMultiTargetAudience: function (component) {
        var controllingValue = this.getEffectiveControllingValue(
            component, "Core_MDF_TargetAudience__c"
        );
        var values = this.getOptionsForControllerOrAll(
            component, controllingValue, component.get("v.audiencePicklistValues")
        );
        values = this.localizeSubType(component, values, false);
        component.set("v.MultiTargetAudienceValues", values);
        component.set("v.AllTargetAudienceOptions", values);
    },

    fetchProdType: function (component) {
        var controllingValue = this.getEffectiveControllingValue(
            component, "Core_MDF_ProductType__c"
        );
        var values = this.getOptionsForControllerOrAll(
            component, controllingValue, component.get("v.ProductTypes")
        );
        values = this.localizeSubType(component, values, false);
        component.set("v.ProductTypeDependent", values);
        component.set("v.ProductTypeValues", values);
    },

    fetchMultiBrandType: function (component) {
        var controllingValue = this.getEffectiveControllingValue(
            component, "Core_MDF_Brand_nm__c"
        );
        var values = this.getOptionsForControllerOrAll(
            component, controllingValue, component.get("v.MultiBrandTypes")
        );
        values = this.localizeSubType(component, values, false);
        component.set("v.MultiBrandValues", values);
        component.set("v.AllBrandOptions", values);
    },

    fetchMultiInitiative: function (component) {
        var controllingValue = this.getEffectiveControllingValue(
            component, "Core_MDF_Initiative_nm__c"
        );
        var values = this.getOptionsForControllerOrAll(
            component, controllingValue, component.get("v.initiativePicklistValues")
        );
        values = this.localizeSubType(component, values, false);
        component.set("v.MultiInitiativeValues", values);
        component.set("v.AllInitiativeOptions", values);
    },

    fetchMultiEcoPartnerType: function (component) {
        var controllingValue = this.getEffectiveControllingValue(
            component, "Core_MDF_Channel_Partner__c"
        );
        var values = this.getOptionsForControllerOrAll(
            component, controllingValue, component.get("v.MultiEcoPartnerTypes")
        );
        values = this.localizeSubType(component, values, false);
        component.set("v.MultiEcoPartnerValues", values);
        component.set("v.AllEcosystemPartner", values);
    },

    fetchTechnologies: function (component) {
        var controllingValue = this.getEffectiveControllingValue(
            component, "Core_MDF_Technology_txt__c"
        );
        var values = this.getOptionsForControllerOrAll(
            component, controllingValue, component.get("v.technologies")
        );
        values = this.localizeSubType(component, values, false);
        component.set("v.technologiesDependant", values);
        component.set("v.AllTechnologyOptions", values);
    },

    fetchOutcomeMetric: function (component) {
        var outcomes = component.get("v.outcomes") || {};
        var marketingValues = this.setChildPicklistValues(component, "Marketing", outcomes);
        var businessValues = this.setChildPicklistValues(component, "Business", outcomes);

        marketingValues = this.localizeSubType(component, marketingValues, false);
        businessValues = this.localizeSubType(component, businessValues, false);

        component.set("v.marketingOutcomeMetricOptions", marketingValues);
        component.set("v.businessOutcomeMetricOptions", businessValues);
        component.set("v.outcomesDependants", marketingValues.concat(businessValues));
        component.set("v.outcomeMetricOptions", marketingValues.concat(businessValues));
    },

    fetchMeasurementApproach: function (component) {
        var controllingValue = this.getEffectiveControllingValue(
            component, "Core_MDF_Measurement_Approach_nm__c"
        );
        var values = this.getOptionsForControllerOrAll(
            component, controllingValue, component.get("v.measurementApproachPicklistValues")
        );
        values = this.localizeSubType(component, values, false);
        component.set("v.measurementApproachValues", values);
        component.set("v.measurementApproachOptions", values);
    },

    // ═══════════════════════════════════════════════════════════════
    // REGION / COUNTRY
    // ═══════════════════════════════════════════════════════════════
    onRegionChange: function (component) {
        var region = component.get("v.SelRegion");
        component.set("v.newPFR.Core_MDF_Outcome_Region_nm__c", region);
        component.set("v.selectedCountryOptions", []);
        component.set("v.newPFR.Core_MDF_Country_nm__c", "");
        if (this.isNotBlank(region)) {
            this.fetchCountriesByRegion(component, region);
        } else {
            component.set("v.AllCountryOptions", component.get("v.AllCountryOptionsMain"));
        }
    },

    fetchCountriesByRegion: function (component, region) {
        var action = component.get("c.getCountryOptionsByRegion");
        action.setParams({ region: region });

        action.setCallback(this, function (response) {
            if (response.getState() !== "SUCCESS") {
                this.logWarn("fetchCountriesByRegion:non-success", {
                    state: response.getState(), errors: response.getError()
                });
                component.set("v.AllCountryOptions", []);
                return;
            }
            component.set("v.AllCountryOptions", response.getReturnValue() || []);
        });
        $A.enqueueAction(action);
    },

    fetchCountriesByRegionUsingAllOptions: function (component, region) {
        var masterList = component.get("v.AllCountryOptionsMain") || [];
        if (masterList.length === 0) { return; }

        var allowedLabels = masterList.map(function (c) { return c.label; });
        var action = component.get("c.getCountryLabelsByRegion");
        action.setParams({ region: region, allowedCountryLabels: allowedLabels });

        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var serverList = response.getReturnValue() || [];
                serverList.sort();
                var options = serverList.map(function (s) {
                    return { label: s, value: s };
                });
                component.set("v.AllCountryOptions", options);
            }
        });
        $A.enqueueAction(action);
    },

    filterCountry: function (component) {
        var countryName = component.get("v.AllCountryOptionsMain") || [];
        var search = (component.get("v.countryFilter") || "").toUpperCase();
        if (!search) {
            component.set("v.AllCountryOptions", countryName);
            return;
        }
        var filterSearch = [];
        var filterNonSearch = [];
        for (var index = 0; index < countryName.length; index++) {
            if ((countryName[index].value || "").toUpperCase().includes(search)) {
                filterSearch.push(countryName[index]);
            } else {
                filterNonSearch.push(countryName[index]);
            }
        }
        component.set("v.AllCountryOptions", filterSearch.concat(filterNonSearch));
    },

    // ═══════════════════════════════════════════════════════════════
    // OUTCOME METRIC SYNC
    // ═══════════════════════════════════════════════════════════════
    handleOutcomeMetricSelectionChange: function (component, outcomeType, oldValues, newValues) {
        oldValues = oldValues || [];
        newValues = newValues || [];

        if (component.get("v.isLoadingOutcomePurpose")) {
            this.syncSelectedOutcomeMetrics(component);
            return;
        }

        var oldMetric = oldValues.length > 0 ? oldValues[0] : "";
        var newMetric = newValues.length > 0 ? newValues[0] : "";

        if (oldMetric !== newMetric && outcomeType === "marketing") {
            component.set("v.selectedMarketingBrandOptions", []);
            component.set("v.selectedMarketingTechnologyOptions", []);
            component.set("v.marketingOtherBrandsTechnologies", "");
        }

        if (oldMetric !== newMetric && outcomeType === "business") {
            component.set("v.selectedBusinessBrandOptions", []);
            component.set("v.selectedBusinessTechnologyOptions", []);
            component.set("v.businessOtherBrandsTechnologies", "");
        }

        this.syncSelectedOutcomeMetrics(component);
        this.syncBrandTechnologySelections(component);
        this.syncOtherBrandsTechnologies(component);
    },

    syncSelectedOutcomeMetrics: function (component) {
        var marketingSelections = component.get("v.selectedMarketingOutcomeMetricOptions") || [];
        var businessSelections = component.get("v.selectedBusinessOutcomeMetricOptions") || [];
        var selectedOutcomes = [];
        var selectedOutcomeTypes = [];

        if (marketingSelections.length > 0) {
            selectedOutcomes.push(marketingSelections[0]);
            selectedOutcomeTypes.push("Marketing");
        }
        if (businessSelections.length > 0) {
            selectedOutcomes.push(businessSelections[0]);
            selectedOutcomeTypes.push("Business");
        }

        component.set("v.selectedOutcomeMetricOptions", selectedOutcomes);
        component.set("v.selectedOutcomeTypeOptions", selectedOutcomeTypes);
        component.set("v.newPFR.Core_MDF_Outcomes_nm__c", selectedOutcomes.join(";"));
        component.set("v.newPFR.Core_MDF_Outcome_Type_nm__c", selectedOutcomeTypes.join(";"));
    },

    mergeUniqueSelections: function (firstValues, secondValues) {
        firstValues = firstValues || [];
        secondValues = secondValues || [];
        var combinedValues = firstValues.concat(secondValues);
        var seenValues = {};
        var finalValues = [];
        for (var i = 0; i < combinedValues.length; i++) {
            var value = combinedValues[i];
            if (value && !seenValues[value]) {
                seenValues[value] = true;
                finalValues.push(value);
            }
        }
        return finalValues;
    },

    syncBrandTechnologySelections: function (component) {
        var combinedBrands = this.mergeUniqueSelections(
            component.get("v.selectedMarketingBrandOptions"),
            component.get("v.selectedBusinessBrandOptions")
        );
        var combinedTechnologies = this.mergeUniqueSelections(
            component.get("v.selectedMarketingTechnologyOptions"),
            component.get("v.selectedBusinessTechnologyOptions")
        );
        component.set("v.selectedBrandOptions", combinedBrands);
        component.set("v.selectedTechnologyOptions", combinedTechnologies);
        component.set("v.newPFR.Core_MDF_Brand_nm__c", combinedBrands.join(";"));
        component.set("v.newPFR.Core_MDF_Technology_txt__c", combinedTechnologies.join(";"));
    },

    combineOtherBrandsTechnologies: function (marketingValue, businessValue) {
        var combinedValues = [];
        marketingValue = (marketingValue || "").trim();
        businessValue = (businessValue || "").trim();
        if (marketingValue) { combinedValues.push(marketingValue); }
        if (businessValue) { combinedValues.push(businessValue); }
        return combinedValues.join("\n");
    },

    syncOtherBrandsTechnologies: function (component) {
        var combined = this.combineOtherBrandsTechnologies(
            component.get("v.marketingOtherBrandsTechnologies"),
            component.get("v.businessOtherBrandsTechnologies")
        );
        component.set("v.newPFR.Core_MDF_Other_Brands_Technologies_txt__c", combined);
    },

    getPurposeComponent: function (component, auraId) {
        var purposeComponent = component.find(auraId);
        if (purposeComponent && this.isNotBlank(purposeComponent[0])) {
            return purposeComponent[0];
        }
        return purposeComponent;
    },

    loadOutcomePurposeDetails: function (component) {
        var recordId = component.get("v.recordId");
        if (!recordId) { return; }

        var action = component.get("c.getActivityOutcomes");
        action.setParams({ activityId: recordId });

        action.setCallback(this, function (response) {
            if (response.getState() !== "SUCCESS") { return; }

            var outcomes = response.getReturnValue() || [];
            component.set("v.isLoadingOutcomePurpose", true);

            for (var i = 0; i < outcomes.length; i++) {
                var outcome = outcomes[i];
                var metric = outcome.outcomeMetricApi || outcome.outcomeMetric;

                if (outcome.outcomeType === "Marketing") {
                    component.set("v.selectedMarketingOutcomeMetricOptions",
                        metric ? [metric] : []);
                    component.set("v.selectedMarketingBrandOptions",
                        outcome.brandValues ? outcome.brandValues.split(";") : []);
                    component.set("v.selectedMarketingTechnologyOptions",
                        outcome.technologyValues ? outcome.technologyValues.split(";") : []);
                    component.set("v.marketingOtherBrandsTechnologies",
                        outcome.otherBrandsTechnologies || "");
                }

                if (outcome.outcomeType === "Business") {
                    component.set("v.selectedBusinessOutcomeMetricOptions",
                        metric ? [metric] : []);
                    component.set("v.selectedBusinessBrandOptions",
                        outcome.brandValues ? outcome.brandValues.split(";") : []);
                    component.set("v.selectedBusinessTechnologyOptions",
                        outcome.technologyValues ? outcome.technologyValues.split(";") : []);
                    component.set("v.businessOtherBrandsTechnologies",
                        outcome.otherBrandsTechnologies || "");
                }
            }

            this.syncSelectedOutcomeMetrics(component);
            this.syncBrandTechnologySelections(component);
            this.syncOtherBrandsTechnologies(component);

            window.setTimeout($A.getCallback(function () {
                component.set("v.isLoadingOutcomePurpose", false);
            }), 0);
        });

        $A.enqueueAction(action);
    },

    // ═══════════════════════════════════════════════════════════════
    // BUDGET PROGRAM / ACCOUNT FILTER
    // ═══════════════════════════════════════════════════════════════
    getBudgetProgram: function (component) {
        var recordType = (
            component.get("v.recordtypeDeveloperName") ||
            component.get("v.recordtypeName") || ""
        ).toLowerCase();
        // Co-Inv is managed under the DCF program.
        if (recordType.indexOf("co_inv") !== -1 ||
            recordType.indexOf("co-inv") !== -1 ||
            recordType.indexOf("coinv") !== -1) {
            return "Co-Inv";
        }
        if (recordType.indexOf("data_center") !== -1 ||
            recordType.indexOf("datacenter") !== -1 ||
            recordType.indexOf("data centre") !== -1 ||
            recordType.indexOf("dcf") !== -1) {
            return "Data Center CoMarketing Fund";
        }
        if (recordType.indexOf("ccf") !== -1 || recordType.indexOf("client") !== -1) {
            return "Client CoMarketing Fund";
        }
        return "Co-Inv";
    },

    setAccountFilter: function (component) {
        var budgetProgram = this.getBudgetProgram(component);
        var aFilter = "RecordType.DeveloperName= @quote;Core_MDF_Co_Marketing@quote;" +
            " AND isPartner=true" +
            " AND Core_MDF_Active_Ind__c = true" +
            " AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c=@quote;" +
            budgetProgram + "@quote;";
        component.set("v.additionalAccFilter", aFilter);
    },

    // ═══════════════════════════════════════════════════════════════
    // BUDGET TYPE FETCHER (for picklist options)
    // ═══════════════════════════════════════════════════════════════
    fetchBudgetTypesBasedOnBenefits: function (component) {
        var selectedAccount = component.get("v.selectedAccount");
        if (!selectedAccount || !selectedAccount.Id) {
            this.logWarn("fetchBudgetTypesBasedOnBenefits:missing-account", selectedAccount);
            this.initializeBudgetTable(component);
            component.set("v.isInitialRecordLoad", false);
            return;
        }

        var action = component.get("c.getCCFDCFStandardBudgetTypes");
        action.setParams({ program: this.getBudgetProgram(component) });

        action.setCallback(this, function (response) {
            if (response.getState() !== "SUCCESS") {
                this.logWarn("fetchBudgetTypesBasedOnBenefits:non-success", {
                    state: response.getState(), errors: response.getError()
                });
                this.initializeBudgetTable(component);
                component.set("v.isInitialRecordLoad", false);
                return;
            }

            var result = response.getReturnValue() || {};
            var budgetTypeOptions = [{
                label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"), value: ""
            }];
            for (var key in result) {
                if (result[key]) {
                    budgetTypeOptions.push({ label: result[key], value: key });
                }
            }
            component.set("v.budgetTypeVal", budgetTypeOptions);

            var selected = component.get("v.newPFR.Core_MDF_Budget_Type_nm__c");
            if (this.isNotBlank(selected)) {
                component.set("v.showBudgetTable", true);
                this.fetchAvailableBudgets(component, selected);
            }
            component.set("v.isInitialRecordLoad", false);
        });

        $A.enqueueAction(action);
    },

    // ═══════════════════════════════════════════════════════════════
    // BUDGET TYPE CHANGE HANDLER
    // ═══════════════════════════════════════════════════════════════
    onBudgetTypeChange: function (component) {
        var budgetType = component.get("v.newPFR.Core_MDF_Budget_Type_nm__c");

        if (budgetType && budgetType !== "") {
            component.set("v.budgetAllocations", []);
            component.set("v.totalPercentageAllocation", 0);
            component.set("v.totalAllocatedAmount", 0);
            component.set("v.remainingAmount", 0);
            component.set("v.budgetValidationError", "");
            component.set("v.showBudgetTable", true);
            this.fetchAvailableBudgets(component, budgetType);
        } else {
            this.initializeBudgetTable(component);
        }

        this.logDebug("onBudgetTypeChange", budgetType);
    },

    // ═══════════════════════════════════════════════════════════════
    // FETCH AVAILABLE BUDGETS FROM APEX
    // ═══════════════════════════════════════════════════════════════
    // Dropdown label: Budget Number - Budget Name - Co-Selling / Co-Marketing
    mapBudget: function (b) {
        var parts = [];
        if (b.budgetNumber) { parts.push(b.budgetNumber); }
        parts.push(b.budgetName);
        if (b.coSelling) { parts.push("Co-Selling"); }
        if (b.coMarketing) { parts.push("Co-Marketing"); }
        return {
            budgetId: b.budgetId,
            budgetName: b.budgetName,
            budgetNumber: b.budgetNumber || "",
            budgetType: b.budgetType || "",
            revenueSegment: b.revenueSegment || "",
            displayLabel: parts.join(" - "),
            availableAmount: (b.availableAmount !== null &&
                b.availableAmount !== undefined)
                ? parseFloat(b.availableAmount) : 0
        };
    },

    fetchAvailableBudgets: function (component, budgetType) {
        var self = this;
        var action = component.get("c.fetchAvailableBudgetsForType");
        var selectedAccount = component.get("v.selectedAccount");
        var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var endDate = component.get("v.newPFR.Core_MDF_End_Date__c");

        this.logDebug("fetchAvailableBudgets:params", {
            budgetType: budgetType,
            accountId: selectedAccount ? selectedAccount.Id : null,
            startDate: startDate,
            endDate: endDate
        });

        action.setParams({
            budgetType: budgetType,
            accountId: (selectedAccount && selectedAccount.Id) ? selectedAccount.Id : "",
            startDate: startDate || "",
            endDate: endDate || ""
        });

        action.setCallback(this, function (response) {
            if (!component.isValid()) { return; }
            var state = response.getState();

            if (state === "SUCCESS") {
                var budgets = response.getReturnValue() || [];
                var budgetList = budgets.map(function (b) { return self.mapBudget(b); });
                component.set("v.availableBudgets", budgetList);
                self.logDebug("fetchAvailableBudgets:success", {
                    count: budgetList.length, budgetList: budgetList
                });
            } else {
                self.logWarn("fetchAvailableBudgets:error", {
                    state: state, error: response.getError()
                });
            }
        });

        $A.enqueueAction(action);
    },

    // ═══════════════════════════════════════════════════════════════
    // BUDGET TABLE: SELECTION HANDLER
    // ═══════════════════════════════════════════════════════════════
    onBudgetSelected: function (component, index, selectedBudgetId) {
        var allocations = component.get("v.budgetAllocations");

        if (index < 0 || index >= allocations.length) {
            this.logWarn("onBudgetSelected", "Invalid index: " + index);
            return;
        }

        var allocation = JSON.parse(JSON.stringify(allocations[index]));
        allocation.budgetId = selectedBudgetId || "";

        if (!selectedBudgetId || selectedBudgetId === "") {
            allocation.budgetName = "";
            allocation.budgetType = "";
            allocation.revenueSegment = "";
            allocation.availableAmount = 0;
            allocation.allocationPercentage = 0;
            allocation.allocatedAmount = 0;
            allocation.amountError = "";

            var clearedList = allocations.slice();
            clearedList[index] = allocation;
            component.set("v.budgetAllocations", clearedList);
            this.validateBudgetAllocations(component);
            return;
        }

        var availableBudgets = component.get("v.availableBudgets");
        var selectedBudget = null;
        for (var i = 0; i < availableBudgets.length; i++) {
            if (availableBudgets[i].budgetId === selectedBudgetId) {
                selectedBudget = availableBudgets[i];
                break;
            }
        }

        if (!selectedBudget) {
            this.logWarn("onBudgetSelected", "Budget not found: " + selectedBudgetId);
            return;
        }

        var budgetAvailableAmt = (
            selectedBudget.availableAmount !== null &&
            selectedBudget.availableAmount !== undefined
        ) ? parseFloat(selectedBudget.availableAmount) : 0;

        allocation.budgetName = selectedBudget.budgetName || "";
        allocation.budgetType = selectedBudget.budgetType || "";
        allocation.revenueSegment = selectedBudget.revenueSegment || "";
        allocation.availableAmount = budgetAvailableAmt;
        allocation.allocationPercentage = 0;
        allocation.allocatedAmount = 0;
        allocation.amountError = "";

        var updatedList = allocations.slice();
        updatedList[index] = allocation;
        component.set("v.budgetAllocations", updatedList);
        this.validateBudgetAllocations(component);

        this.logDebug("onBudgetSelected:success", {
            index: index, budgetId: selectedBudgetId,
            budgetName: allocation.budgetName,
            availableAmount: allocation.availableAmount
        });
    },

    // ═══════════════════════════════════════════════════════════════
    // BUDGET TABLE: AMOUNT CHANGE
    // ═══════════════════════════════════════════════════════════════
    updateAllocationByAmount: function (component, index, rawValue) {
        var allocations = component.get("v.budgetAllocations");

        if (index < 0 || index >= allocations.length) {
            this.logWarn("updateAllocationByAmount", "Invalid index: " + index);
            return;
        }

        var allocation = JSON.parse(JSON.stringify(allocations[index]));
        var enteredAmt = parseFloat(rawValue);

        if (isNaN(enteredAmt)) {
            allocation.allocatedAmount = 0;
            allocation.allocationPercentage = 0;
            allocation.amountError = (rawValue === "" || rawValue === null ||
                rawValue === undefined) ? "" : "Please enter a valid number.";
        } else if (enteredAmt < 0) {
            allocation.allocatedAmount = 0;
            allocation.allocationPercentage = 0;
            allocation.amountError = "Amount cannot be negative.";
        } else {
            allocation.allocatedAmount = enteredAmt;
            allocation.allocationPercentage = this.calculatePercentage(component, enteredAmt);
            allocation.amountError = "";
        }

        var newList = allocations.slice();
        newList[index] = allocation;
        component.set("v.budgetAllocations", newList);
        this.validateBudgetAllocations(component);

        this.logDebug("updateAllocationByAmount", {
            index: index, enteredAmt: enteredAmt,
            allocationPercentage: allocation.allocationPercentage
        });
    },

    // Percentage of Maximum Intel Investment represented by an amount
    calculatePercentage: function (component, amount) {
        var maxIntelInvest = parseFloat(
            component.get("v.newPFR.Core_MDF_Maximum_Intel_Investment_amt__c")
        ) || 0;
        return maxIntelInvest > 0
            ? Math.round((amount / maxIntelInvest) * 100 * 100) / 100
            : 0;
    },

    // ═══════════════════════════════════════════════════════════════
    // BUDGET TABLE: RECALCULATE ALL ROWS
    // ═══════════════════════════════════════════════════════════════
    recalculateAllAllocations: function (component) {
        var self = this;
        var allocations = component.get("v.budgetAllocations");
        var maxIntelInvest = parseFloat(
            component.get("v.newPFR.Core_MDF_Maximum_Intel_Investment_amt__c")
        ) || 0;

        if (!allocations || allocations.length === 0) {
            component.set("v.remainingAmount", maxIntelInvest);
            return;
        }

        var recalculated = allocations.map(function (row) {
            var cloned = JSON.parse(JSON.stringify(row));
            var amt = parseFloat(cloned.allocatedAmount) || 0;
            cloned.allocationPercentage = self.calculatePercentage(component, amt);
            return cloned;
        });

        component.set("v.budgetAllocations", recalculated);
        this.validateBudgetAllocations(component);
    },

    // ═══════════════════════════════════════════════════════════════
    // BUDGET TABLE: VALIDATE
    // ═══════════════════════════════════════════════════════════════
    validateBudgetAllocations: function (component) {
        var allocations = component.get("v.budgetAllocations");
        var maxIntelInvest = parseFloat(
            component.get("v.newPFR.Core_MDF_Maximum_Intel_Investment_amt__c")
        ) || 0;

        var totalPct = 0;
        var totalAmt = 0;
        var globalError = "";

        if (allocations && allocations.length > 0) {
            allocations.forEach(function (row) {
                var pct = parseFloat(row.allocationPercentage);
                var amt = parseFloat(row.allocatedAmount);
                if (!isNaN(pct)) { totalPct += pct; }
                if (!isNaN(amt)) { totalAmt += amt; }
            });

            totalPct = Math.round(totalPct * 100) / 100;
            totalAmt = Math.round(totalAmt * 100) / 100;

            if (maxIntelInvest > 0 && totalAmt > maxIntelInvest) {
                globalError = "Total allocated amount ($" + totalAmt.toFixed(2) +
                    ") exceeds Maximum Intel Investment ($" +
                    maxIntelInvest.toFixed(2) + ").";
            }

            var hasEmptyBudget = allocations.some(function (row) {
                return !row.budgetId || row.budgetId === "";
            });
            if (!globalError && hasEmptyBudget) {
                globalError = "One or more rows have no budget selected. " +
                    "Please select a budget or remove the empty row.";
            }
        }

        var remaining = maxIntelInvest > 0
            ? Math.round((maxIntelInvest - totalAmt) * 100) / 100
            : 0;

        component.set("v.totalPercentageAllocation", totalPct);
        component.set("v.totalAllocatedAmount", totalAmt);
        component.set("v.remainingAmount", remaining);
        component.set("v.budgetValidationError", globalError);
    },

    // ═══════════════════════════════════════════════════════════════
    // BUDGET TABLE: ADD ROW
    // ═══════════════════════════════════════════════════════════════
    addBudgetAllocationRow: function (component) {
        var allocations = component.get("v.budgetAllocations");
        allocations.push({
            id: "row_" + new Date().getTime(),
            budgetId: "",
            budgetName: "",
            budgetType: "",
            revenueSegment: "",
            availableAmount: 0,
            allocationPercentage: 0,
            allocatedAmount: 0,
            amountError: ""
        });
        component.set("v.budgetAllocations", allocations.slice());
        this.logDebug("addBudgetAllocationRow",
            "Row added. Total rows: " + allocations.length);
    },

    // ═══════════════════════════════════════════════════════════════
    // BUDGET TABLE: REMOVE ROW
    // ═══════════════════════════════════════════════════════════════
    removeBudgetAllocationRow: function (component, index) {
        var allocations = component.get("v.budgetAllocations");
        if (index >= 0 && index < allocations.length) {
            allocations.splice(index, 1);
            component.set("v.budgetAllocations", allocations.slice());
            this.validateBudgetAllocations(component);
            this.logDebug("removeBudgetAllocationRow", "Removed row at index: " + index);
        }
    },

    // ═══════════════════════════════════════════════════════════════
    // DATE VALIDATION
    // ═══════════════════════════════════════════════════════════════
    validateDates: function (component) {
        var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var endDate = component.get("v.newPFR.Core_MDF_End_Date__c");
        if (startDate && endDate && startDate > endDate) {
            this.logWarn("validateDates", "Start date is after end date");
        }
    },

    // ═══════════════════════════════════════════════════════════════
    // ADDITIONAL REVIEW PERMISSION
    // ═══════════════════════════════════════════════════════════════
    fetchAdditionalReviewPermission: function (component) {
        var permissionSetName = $A.get("$Label.c.Core_MDF_OpalAccountManagers");
        if (!permissionSetName) { return; }

        var permissionsets = { opalAccountManagers: permissionSetName.split(",") };
        var action = component.get("c.userHasPermissionSet");
        action.setParams({ permissionsets: permissionsets });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var userPermissions = response.getReturnValue().userPermissions || {};
                component.set("v.isLoggedInUserLevelOneApprover",
                    userPermissions.opalAccountManagers === true);
            } else {
                this.logWarn("fetchAdditionalReviewPermission:non-success",
                    response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    // ═══════════════════════════════════════════════════════════════
    // RESET FOR SAVE AND NEW
    // ═══════════════════════════════════════════════════════════════
    resetForSaveAndNew: function (component) {
        component.set("v.newPFR", {
            sobjectType: "PartnerFundRequest",
            Title: "",
            RequestedAmount: 0,
            Core_MDF_Start_Date__c: "",
            Core_MDF_End_Date__c: "",
            Core_MDF_Activity_Description__c: "",
            Core_MDF_Budget_Type_nm__c: "",
            Core_MDF_Maximum_Intel_Investment_amt__c: 0,
            Core_MDF_Is_Outcome_Based_Ind__c: true,
            Core_MDF_Outcome_Type_nm__c: "",
            Core_MDF_Outcomes_nm__c: "",
            Core_MDF_Brand_nm__c: "",
            Core_MDF_Technology_txt__c: "",
            Core_MDF_Other_Brands_Technologies_txt__c: "",
            Core_MDF_ActivityCategory__c: $A.get("$Label.c.Core_MDF_Outcome_Based_CatType"),
            Core_MDF_Activity_Types__c: $A.get("$Label.c.Core_MDF_Outcome_Based_CatType")
        });

        component.set("v.selectedCountryOptions", []);
        component.set("v.selectedTargetAudienceOptions", []);
        component.set("v.selectedProductTypeOptions", []);
        component.set("v.selectedBrandOptions", []);
        component.set("v.selectedEcosystemPartnerOptions", []);
        component.set("v.selectedInitiativeOptions", []);
        component.set("v.selectedTechnologyOptions", []);
        component.set("v.selectedOutcomeMetricOptions", []);
        component.set("v.selectedTacticsOptions", []);
        component.set("v.selectedMeasurementApproachOptions", []);
        component.set("v.showPCTApprovalCheckbox", false);
        component.set("v.isSPIFSecAvailable", false);
        component.set("v.segmentString", "");
        component.set("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c", false);
        component.set("v.isAdditionalReviewReqd", false);
        component.set("v.newPFR.Core_MDF_Attribution_Variance_Pos_txt__c", null);
        component.set("v.newPFR.Core_MDF_Attribution_Variance_Neg_txt__c", null);
        component.set("v.SelPriority", "");
        component.set("v.SelRegion", "");
        component.set("v.tacticMetricsValues", []);
        component.set("v.ContentDocumentIds", []);
        component.set("v.selectedOutcomeTypeOptions", []);
        component.set("v.selectedMarketingOutcomeMetricOptions", []);
        component.set("v.selectedBusinessOutcomeMetricOptions", []);
        component.set("v.selectedMarketingBrandOptions", []);
        component.set("v.selectedMarketingTechnologyOptions", []);
        component.set("v.selectedBusinessBrandOptions", []);
        component.set("v.selectedBusinessTechnologyOptions", []);
        component.set("v.marketingOtherBrandsTechnologies", "");
        component.set("v.businessOtherBrandsTechnologies", "");

        // Reset budget table
        this.initializeBudgetTable(component);
    },

    // ═══════════════════════════════════════════════════════════════
    // SAVE RECORD
    // ═══════════════════════════════════════════════════════════════
    saveRecord: function (component, isSaveAndNew) {
        var self = this;
        var newPFR = component.get("v.newPFR");

        // ── Basic required field validation ──────────────────────
        if (!newPFR.Title || !component.get("v.selectedAccount.Id") ||
            !newPFR.Core_MDF_Start_Date__c || !newPFR.Core_MDF_End_Date__c ||
            !newPFR.Core_MDF_Activity_Description__c) {
            self.showToast("Error",
                "Please complete all required fields before saving.", "error");
            return;
        }

        // ── Outcome metric validation ─────────────────────────────
        var marketingSelections =
            component.get("v.selectedMarketingOutcomeMetricOptions") || [];
        var businessSelections =
            component.get("v.selectedBusinessOutcomeMetricOptions") || [];
        var marketingMetric = marketingSelections.length > 0 ? marketingSelections[0] : "";
        var businessMetric = businessSelections.length > 0 ? businessSelections[0] : "";

        if (!marketingMetric && !businessMetric) {
            self.showToast("",
                $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage"), "error");
            return;
        }

        // ── Budget allocation validation ──────────────────────────
        var budgetAllocations = component.get("v.budgetAllocations") || [];
        if (this.isNotBlank(newPFR.Core_MDF_Budget_Type_nm__c)) {
            if (budgetAllocations.length === 0) {
                self.showToast("Error",
                    "Please add at least one budget allocation before saving.", "error");
                return;
            }

            // Run full validation
            this.validateBudgetAllocations(component);
            var budgetError = component.get("v.budgetValidationError");
            if (budgetError && budgetError !== "") {
                self.showToast("Error", budgetError, "error");
                return;
            }

            // Each entered amount must not exceed the budget's available amount
            var availableBudgets = component.get("v.availableBudgets") || [];
            var rows = budgetAllocations.map(function (row) {
                var cloned = JSON.parse(JSON.stringify(row));
                var available = parseFloat(cloned.availableAmount);
                for (var i = 0; i < availableBudgets.length; i++) {
                    if (availableBudgets[i].budgetId === cloned.budgetId) {
                        available = parseFloat(availableBudgets[i].availableAmount);
                        break;
                    }
                }
                available = isNaN(available) ? 0 : available;
                var enteredAmt = parseFloat(cloned.allocatedAmount) || 0;
                cloned.allocatedAmount = enteredAmt;
                cloned.allocationPercentage = self.calculatePercentage(component, enteredAmt);
                cloned.amountError = enteredAmt > available
                    ? "Amount exceeds the available budget amount ($" +
                      available.toFixed(2) + ")."
                    : "";
                return cloned;
            });
            component.set("v.budgetAllocations", rows);
            var exceeding = rows.filter(function (row) { return row.amountError; });
            if (exceeding.length > 0) {
                self.showToast("Error",
                    "Amount entered for " + (exceeding[0].budgetName || "the selected budget") +
                    " exceeds the available budget amount ($" +
                    (parseFloat(exceeding[0].availableAmount) || 0).toFixed(2) + ").",
                    "error");
                return;
            }

            // Total allocated amount must equal Maximum Intel Investment
            var totalAmt = component.get("v.totalAllocatedAmount");
            var maxIntel = parseFloat(newPFR.Core_MDF_Maximum_Intel_Investment_amt__c) || 0;
            if (totalAmt <= 0 || (maxIntel > 0 && Math.abs(totalAmt - maxIntel) > 0.005)) {
                self.showToast("Error",
                    "Total budget allocation must equal the Maximum Intel Investment" +
                    (maxIntel > 0 ? " ($" + maxIntel.toFixed(2) + ")" : "") +
                    ". Current total: $" + (totalAmt || 0).toFixed(2) + ".", "error");
                return;
            }
        }

        // ── Country (Market) validation ───────────────────────────
        var selectedCountry = component.get("v.selectedCountryOptions") || [];
        if (selectedCountry.length === 0) {
            self.showToast("Error",
                $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage") ||
                "Please select at least one market.", "error");
            return;
        }

        // ── Target Audience validation ────────────────────────────
        var selectedTargetAudience =
            component.get("v.selectedTargetAudienceOptions") || [];
        if (selectedTargetAudience.length === 0) {
            var taMsg = $A.get("$Label.c.Core_MDF_TargetAudienceError_OutcomeBased") ||
                $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage");
            self.showToast("Error", taMsg, "error");
            return;
        }

        // ── Product Type validation ───────────────────────────────
        var selectedProductType = component.get("v.selectedProductTypeOptions") || [];
        if (selectedProductType.length === 0) {
            var ptMsg = $A.get("$Label.c.Core_MDF_ProductTypeError_OutcomeBased") ||
                $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage");
            self.showToast("Error", ptMsg, "error");
            return;
        }

        // ── Ecosystem Partner validation ──────────────────────────
        var selectedEcoPartners =
            component.get("v.selectedEcosystemPartnerOptions") || [];
        if (selectedEcoPartners.length === 0) {
            var ecoMsg = $A.get("$Label.c.Core_MDF_EcosystemPartner_ReqError_OB") ||
                $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage");
            self.showToast("Error", ecoMsg, "error");
            return;
        }

        // ── Financial validations ─────────────────────────────────
        var requestedAmount = parseFloat(newPFR.RequestedAmount) || 0;
        if (requestedAmount <= 0) {
            var spendMsg = $A.get("$Label.c.Core_MDF_TotalInvestment_grtthanzero_Error") ||
                "Total investment must be greater than zero.";
            component.set("v.showErrorMsgForSpendingLimit", true);
            component.set("v.ErrorMsgForSpendingLimit", spendMsg);
            self.showToast("Error", spendMsg, "error");
            return;
        }

        var maxIntel = parseFloat(
            newPFR.Core_MDF_Maximum_Intel_Investment_amt__c
        ) || 0;
        if (maxIntel <= 0) {
            var maxZeroMsg =
                $A.get("$Label.c.Core_MDF_MaxIntelInvest_grtthanzero_Error") ||
                "Maximum intel investment must be greater than zero.";
            component.set("v.showErrorMsgForMaxIntelInvest", true);
            component.set("v.ErrorMsgForMaxIntelInvest", maxZeroMsg);
            self.showToast("Error", maxZeroMsg, "error");
            return;
        }

        if (Math.floor(maxIntel) !== maxIntel) {
            var maxDecimalMsg =
                $A.get("$Label.c.Core_MDF_MaxIntelInvest_grtthanzero_Error") ||
                "Maximum intel investment must be a whole number.";
            component.set("v.showErrorMsgForMaxIntelInvest", true);
            component.set("v.ErrorMsgForMaxIntelInvest", maxDecimalMsg);
            self.showToast("Error", maxDecimalMsg, "error");
            return;
        }

        if (maxIntel > requestedAmount) {
            var exceedMsg =
                $A.get("$Label.c.Core_MDF_MaxIntelInvest_Exceed_Error") ||
                "Maximum intel investment cannot exceed total investment.";
            component.set("v.showErrorMsgForMaxIntelInvest", true);
            component.set("v.ErrorMsgForMaxIntelInvest", exceedMsg);
            self.showToast("Error", exceedMsg, "error");
            return;
        }

        // ── Measurement Approach validation ───────────────────────
        // var selectedMeasurementApproach =
        //     component.get("v.selectedMeasurementApproachOptions") || [];
        // if ((marketingSelections.length > 0 || businessSelections.length > 0) &&
        //     selectedMeasurementApproach.length === 0) {
        //     var measMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error") ||
        //         "At least one Measurement Approach must be selected.";
        //     self.showToast("Error", measMsg, "error");
        //     return;
        // }

        // ── Tactics validation ────────────────────────────────────
        var selectedTactics = component.get("v.selectedTacticsOptions") || [];
        if (selectedTactics.length === 0) {
            var tactMsg =
                $A.get("$Label.c.Core_MDF_Activity_Tactics_Error_OutcomeBased") ||
                "Please select at least one tactic.";
            self.showToast("Error", tactMsg, "error");
            return;
        }

        // // ── Initiative validation ─────────────────────────────────
        // var selectedInitiatives = component.get("v.selectedInitiativeOptions") || [];
        // if (selectedInitiatives.length === 0) {
        //     var initMsg =
        //         $A.get("$Label.c.Core_MDF_Initiative_None_Selection_Error") ||
        //         "Please select an initiative.";
        //     self.showToast("Error", initMsg, "error");
        //     return;
        // }

        // ── Tactic Metrics validation ─────────────────────────────
        var tacticMetricsValues = [];
        if (selectedTactics.length > 0) {
            var tacticMetricsComponent = component.find("tacticMetrics");
            if (tacticMetricsComponent) {
                var tacticMetricsChild = this.isNotBlank(tacticMetricsComponent[0])
                    ? tacticMetricsComponent[0] : tacticMetricsComponent;
                if (!tacticMetricsChild.isFormValid()) {
                    self.showToast("Error",
                        "Please complete all tactic metrics before saving.", "error");
                    return;
                }
                tacticMetricsValues = tacticMetricsChild.getTacticMetricsValues() || [];
            }
        }

        // ── Segment / SPIF validation ─────────────────────────────
        var segmentValues = [];
        if (component.get("v.isSPIFSecAvailable")) {
            var segmentComponent = component.find("segmentComp");
            if (segmentComponent) {
                var segmentChild = this.isNotBlank(segmentComponent[0])
                    ? segmentComponent[0] : segmentComponent;
                segmentValues = segmentChild.getSegmentValues() || [];
                if (segmentValues.length === 0 || !segmentChild.isFormValid()) {
                    self.showToast("Error",
                        "Please complete the incentive details before saving.", "error");
                    return;
                }
                component.set("v.segmentString", JSON.stringify(segmentValues));
            }
        }

        // ── Sync all multi-select fields ──────────────────────────
        this.syncSelectedOutcomeMetrics(component);
        this.syncBrandTechnologySelections(component);
        this.syncOtherBrandsTechnologies(component);

        // ── Populate PFR fields before save ──────────────────────
        newPFR.Core_MDF_Is_Outcome_Based_Ind__c = true;
        newPFR.ChannelPartnerId = component.get("v.selectedAccount.Id");
        newPFR.Core_MDF_Program__c = this.getBudgetProgram(component);
        newPFR.Core_MDF_Require_Additional_Review_ind__c =
            Boolean(component.get("v.isAdditionalReviewReqd"));

        if (component.get("v.mode") !== "edit" &&
            component.get("v.isLoggedInUserLevelOneApprover") &&
            (newPFR.Core_MDF_Budget_Type_nm__c ===
                $A.get("$Label.c.Core_MDF_BudgetType_MDF") ||
                newPFR.Core_MDF_Budget_Type_nm__c ===
                $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus") ||
                newPFR.Core_MDF_Budget_Type_nm__c ===
                $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
                newPFR.Core_MDF_Budget_Type_nm__c ===
                $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP"))) {
            newPFR.Core_MDF_Approval_Step_Completed__c = 1;
            newPFR.Core_MDF_Approval_Stage__c = 'L1 Approval';
        }

        newPFR.RecordTypeId = component.get("v.recordtype");
        newPFR.Core_MDF_Priorities__c = component.get("v.SelPriority");
        newPFR.Core_MDF_Priority__c = component.get("v.SelPriority");
        newPFR.Core_MDF_Priority_2_nm__c = "";
        newPFR.Core_MDF_Outcome_Region_nm__c = component.get("v.SelRegion");
        newPFR.Core_MDF_Country_nm__c =
            (component.get("v.selectedCountryOptions") || []).join(";");
        newPFR.Core_MDF_TargetAudience__c =
            (component.get("v.selectedTargetAudienceOptions") || []).join(";");
        newPFR.Core_MDF_ProductType__c =
            (component.get("v.selectedProductTypeOptions") || []).join(";");
        newPFR.Core_MDF_Channel_Partner__c =
            (component.get("v.selectedEcosystemPartnerOptions") || []).join(";");
        newPFR.Core_MDF_Ecosystem_Partner__c =
            (component.get("v.selectedEcosystemPartnerOptions") || []).join(";");
        newPFR.Core_MDF_Other_Channel_Partner__c =
            component.get("v.newPFR.Core_MDF_Other_Channel_Partner__c") || "";
        newPFR.Core_MDF_Initiative_nm__c =
            (component.get("v.selectedInitiativeOptions") || []).join(";");
        newPFR.Core_MDF_Tactics_nm__c =
            (component.get("v.selectedTacticsOptions") || []).join(";");
        newPFR.Core_MDF_Measurement_Approach_nm__c =
            (component.get("v.selectedMeasurementApproachOptions") || []).join(";");
        newPFR.Core_MDF_Brand_nm__c =
            (component.get("v.selectedBrandOptions") || []).join(";");
        newPFR.Core_MDF_Technology_txt__c =
            (component.get("v.selectedTechnologyOptions") || []).join(";");
        newPFR.Core_MDF_Outcomes_nm__c =
            (component.get("v.selectedOutcomeMetricOptions") || []).join(";");
        newPFR.Core_MDF_Outcome_Type_nm__c =
            (component.get("v.selectedOutcomeTypeOptions") || []).join(";");

        var maxIntelContribution = parseFloat(
            newPFR.Core_MDF_Maximum_Intel_Investment_amt__c
        ) || 0;
        newPFR.Core_MDF_Maximum_Intel_Investment_amt__c = maxIntelContribution;
        newPFR.Core_MDF_Activity_Reimbursement_Amt_nbr__c = maxIntelContribution;

        // Use first budget allocation's budgetId for legacy BudgetId field
        var primaryBudgetId = (budgetAllocations.length > 0 && budgetAllocations[0].budgetId)
            ? budgetAllocations[0].budgetId : null;
        newPFR.BudgetId = primaryBudgetId;
        newPFR.Core_MDF_Budget_id__c = primaryBudgetId;

        newPFR.Core_MDF_Other_Brands_Technologies_txt__c =
            component.get("v.newPFR.Core_MDF_Other_Brands_Technologies_txt__c") || "";

        // ── Ecosystem Partner Allocation ──────────────────────────
        var ecosystemAllocations = null;
        var lwcEcosystemComp = component.find("ecosystemAllocation");
        if (lwcEcosystemComp) {
            var shouldEnforce = lwcEcosystemComp.shouldEnforceValidation();
            if (shouldEnforce && !lwcEcosystemComp.validate()) {
                self.showToast("Error",
                    "Please complete the ecosystem partner allocation before saving.",
                    "error");
                return;
            }
            ecosystemAllocations = lwcEcosystemComp.getEcosystemPartnerAllocations();
            if (ecosystemAllocations) {
                component.set("v.ecosystemAllocations", ecosystemAllocations);
            }
        }

        // ── Outcome Purpose validation ────────────────────────────
        var outcomeActivityValues = [];
        var marketingPurposeComponent = null;
        var businessPurposeComponent = null;
        var marketingPurposeValid = true;
        var businessPurposeValid = true;

        var hasSelection = function (values) {
            return Array.isArray(values) && values.some(function (value) {
                return value !== null && value !== undefined &&
                    String(value).trim() !== "";
            });
        };

        if (marketingMetric) {
            marketingPurposeComponent = this.getPurposeComponent(
                component, "marketingActivityOutcomeCmp"
            );
            marketingPurposeValid = !!marketingPurposeComponent &&
                marketingPurposeComponent.validate();
            if (!hasSelection(component.get("v.selectedMarketingBrandOptions")) ||
                !hasSelection(component.get("v.selectedMarketingTechnologyOptions"))) {
                marketingPurposeValid = false;
            }
        }

        if (businessMetric) {
            businessPurposeComponent = this.getPurposeComponent(
                component, "businessActivityOutcomeCmp"
            );
            businessPurposeValid = !!businessPurposeComponent &&
                businessPurposeComponent.validate();
            if (!hasSelection(component.get("v.selectedBusinessBrandOptions")) ||
                !hasSelection(component.get("v.selectedBusinessTechnologyOptions"))) {
                businessPurposeValid = false;
            }
        }

        if (!marketingPurposeValid || !businessPurposeValid) {
            var invalidSections = [];
            if (!marketingPurposeValid) {
                invalidSections.push($A.get("$Label.c.Core_MDF_Marketing_Purpose"));
            }
            if (!businessPurposeValid) {
                invalidSections.push($A.get("$Label.c.Core_MDF_Business_Purpose"));
            }
            self.showToast("",
                invalidSections.join(" / ") + ": " +
                $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage"),
                "error");
            return;
        }

        if (marketingMetric) {
            var marketingOutcomeValues =
                marketingPurposeComponent.getAllActivityOutcomesDetails() || [];
            if (marketingOutcomeValues.length === 0) {
                self.showToast("",
                    $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage"), "error");
                return;
            }
            marketingOutcomeValues[0].outcomeMetric = marketingMetric;
            marketingOutcomeValues[0].outcomeType = "Marketing";
            marketingOutcomeValues[0].brandValues =
                (component.get("v.selectedMarketingBrandOptions") || []).join(";");
            marketingOutcomeValues[0].technologyValues =
                (component.get("v.selectedMarketingTechnologyOptions") || []).join(";");
            marketingOutcomeValues[0].otherBrandsTechnologies =
                component.get("v.marketingOtherBrandsTechnologies") || "";
            outcomeActivityValues = outcomeActivityValues.concat(marketingOutcomeValues);
        }

        if (businessMetric) {
            var businessOutcomeValues =
                businessPurposeComponent.getAllActivityOutcomesDetails() || [];
            if (businessOutcomeValues.length === 0) {
                self.showToast("",
                    $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage"), "error");
                return;
            }
            businessOutcomeValues[0].outcomeMetric = businessMetric;
            businessOutcomeValues[0].outcomeType = "Business";
            businessOutcomeValues[0].brandValues =
                (component.get("v.selectedBusinessBrandOptions") || []).join(";");
            businessOutcomeValues[0].technologyValues =
                (component.get("v.selectedBusinessTechnologyOptions") || []).join(";");
            businessOutcomeValues[0].otherBrandsTechnologies =
                component.get("v.businessOtherBrandsTechnologies") || "";
            outcomeActivityValues = outcomeActivityValues.concat(businessOutcomeValues);
        }

        // ── Account Node Allocation ───────────────────────────────
        var activityNodeAccValues = null;
        if (!$A.util.isEmpty(component.get("v.selectedAccount")) &&
            this.isNotBlank(component.get("v.selectedAccount"))) {
            var lwcAccActivityComp = component.find("activityAccNode");
            if (lwcAccActivityComp) {
                var isAccNodeValid = lwcAccActivityComp.validate();
                if (!isAccNodeValid) {
                    self.showToast("Error",
                        "Please complete all required account node allocation fields " +
                        "before saving.", "error");
                    return;
                }
                try {
                    var outcomeActivityAccNodeValues =
                        lwcAccActivityComp.getAllAccountAllocationDetails();
                    var isAccountAllocationModified =
                        lwcAccActivityComp.isAccountAllocationModified();
                    if (outcomeActivityAccNodeValues &&
                        outcomeActivityAccNodeValues.length > 0) {
                        activityNodeAccValues = JSON.parse(
                            JSON.stringify(outcomeActivityAccNodeValues)
                        );
                        component.set("v.ActivityNodeAccValues", activityNodeAccValues);
                        if (isAccountAllocationModified &&
                            component.get("v.mode") === "edit") {
                            newPFR.Core_MDF_Node_Acc_Map_Modified_ind__c = true;
                        }
                    }
                } catch (e) {
                    console.error("Error retrieving account node allocation details:", e);
                }
            }
        } else {
            component.set("v.ActivityNodeAccValues", null);
        }

        // ── Build budget allocations payload ──────────────────────
        // Pass the full budget allocations array to Apex
        var budgetAllocationsPayload = budgetAllocations.map(function (alloc) {
            return {
                budgetId: alloc.budgetId,
                allocationPercentage: alloc.allocationPercentage,
                allocatedAmount: alloc.allocatedAmount
            };
        });

        component.set("v.showSpinner", true);

        var action = component.get("c.savenSendRecordId");
        action.setParams({
            pfr: newPFR,
            contentdocumentids: component.get("v.ContentDocumentIds"),
            budgetException: false,
            recType: component.get("v.recordtypeDeveloperName"),
            segmentAndProduct: component.get("v.segmentString"),
            BudId: primaryBudgetId,
            isPropIndicator: false,
            mdfReimbursement: null,
            tacticMetrics: tacticMetricsValues.length > 0 ? tacticMetricsValues : null,
            outcomeActivity: outcomeActivityValues.length > 0
                ? outcomeActivityValues : null,
            outcomeAccountNode: this.isNotBlank(
                component.get("v.ActivityNodeAccValues"))
                ? component.get("v.ActivityNodeAccValues") : null,
            ecosystemPartner: ecosystemAllocations && ecosystemAllocations.length > 0
                ? ecosystemAllocations : null,
            budgetAllocations: budgetAllocationsPayload.length > 0
                ? budgetAllocationsPayload : null
        });

        action.setCallback(this, function (response) {
            component.set("v.showSpinner", false);
            var state = response.getState();

            if (state === "SUCCESS") {
                self.showToast("Success",
                    newPFR.Title + " was created successfully.", "success");

                // Create the associated Co-Inv Partner Marketing Budget record
                if (component.get("v.mode") !== "edit") {
                    self.createCoInvPartnerMarketingBudget(component, newPFR, response.getReturnValue());
                }

                if (isSaveAndNew) {
                    self.resetForSaveAndNew(component);
                } else {
                    var newRecordId = response.getReturnValue();
                    self.closeModal(component);
                    $A.get("e.force:refreshView").fire();
                    if (newRecordId) {
                        var communityUrl = component.get("v.externalper");
                        var communityBaseUrl =
                            $A.get("$Label.c.Core_MDF_PFRCommunityLink");
                        setTimeout(function () {
                            var url = communityUrl
                                ? communityBaseUrl +
                                's/outcome-based-campaign-details?recordId=' +
                                newRecordId
                                : '/lightning/n/Core_MDF_Outcome_Based_Campaign_Detail' +
                                '?c__recordId=' + newRecordId;
                            window.location.href = url;
                        }, 500);
                    }
                }
            } else {
                var errors = response.getError();
                var returnValue = null;
                try { returnValue = response.getReturnValue(); } catch (e) { /* ignore */ }

                try {
                    console.error("saveRecord failed", {
                        state: state, errors: errors,
                        returnValue: returnValue, rawResponse: response
                    });
                } catch (e) { /* no-op */ }

                this.logWarn("saveRecord:non-success", {
                    state: state,
                    errorMessages: (errors || []).map(function (e) {
                        return e && e.message;
                    }),
                    rawErrors: JSON.parse(JSON.stringify(errors || [])),
                    returnValue: returnValue
                });

                var message = (errors && errors[0] && errors[0].message)
                    ? errors[0].message
                    : (returnValue && returnValue.message)
                        ? returnValue.message
                        : "Failed to save the record. Please try again.";

                self.showToast("Error",
                    message + " (see browser console for details)", "error");
            }
        });

        $A.enqueueAction(action);
    },

    // ═══════════════════════════════════════════════════════════════
    // CREATE CO-INV PARTNER MARKETING BUDGET (post PFR save)
    // ═══════════════════════════════════════════════════════════════
    createCoInvPartnerMarketingBudget: function (component, newPFR, pfrId) {
        var self = this;
        var accountId = component.get("v.selectedAccount.Id");
        var maxIntelAmount = parseFloat(
            newPFR.Core_MDF_Maximum_Intel_Investment_amt__c
        ) || 0;

        // Account Node allocation rows (accountId/percent/amount) captured during saveRecord;
        // one PartnerFundAllocation will be created per row against the new budget.
        var accountNodeAllocations = component.get("v.ActivityNodeAccValues") || [];

        var action = component.get("c.createCoInvPartnerMarketingBudget");
        action.setParams({
            accountId: accountId,
            budgetTitle: newPFR.Title,
            amount: maxIntelAmount,
            startDate: newPFR.Core_MDF_Start_Date__c,
            endDate: newPFR.Core_MDF_End_Date__c,
            accountNodeAllocations: accountNodeAllocations,
            pfrId: pfrId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state !== "SUCCESS") {
                var errors = response.getError();
                try {
                    console.error("createCoInvPartnerMarketingBudget failed", {
                        state: state, errors: errors
                    });
                } catch (e) { /* no-op */ }
                self.logWarn("createCoInvPartnerMarketingBudget:non-success", {
                    state: state,
                    errorMessages: (errors || []).map(function (e) {
                        return e && e.message;
                    })
                });
            }
        });

        $A.enqueueAction(action);
    }
})