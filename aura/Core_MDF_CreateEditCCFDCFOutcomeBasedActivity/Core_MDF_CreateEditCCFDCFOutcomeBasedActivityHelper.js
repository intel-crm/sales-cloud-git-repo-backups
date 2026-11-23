({
    logDebug: function (tag, data) {
        try {
            console.log("[CCFDCF-Outcome] " + tag, data);
        } catch (e) {
            // no-op
        }
    },

    logWarn: function (tag, data) {
        try {
            console.warn("[CCFDCF-Outcome] " + tag, data);
        } catch (e) {
            // no-op
        }
    },

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

        // Clone hosts pass the source ID through checkCloneRecordId rather than recordId.
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

        // In CCF/DCF create flow, recordId can be the parent Campaign id.
        // Only load an existing activity record when explicitly in edit/clone mode.
        var shouldLoadExistingRecord = !!component.get("v.recordId") &&
            (component.get("v.mode") === "edit" || component.get("v.checkCloneAttribute") === true);

        this.logDebug("initialize:shouldLoadExistingRecord", {
            shouldLoadExistingRecord: shouldLoadExistingRecord,
            mode: component.get("v.mode"),
            checkCloneAttribute: component.get("v.checkCloneAttribute")
        });

        if (shouldLoadExistingRecord) {
            this.loadPFR(component);
            return;
        }

        component.set("v.newPFR.Core_MDF_Is_Outcome_Based_Ind__c", true);
        component.set("v.newPFR.Core_MDF_Activity_Level_nm__c", "Super Activity");
        component.set("v.newPFR.Core_MDF_ActivityCategory__c", $A.get("$Label.c.Core_MDF_Outcome_Based_CatType"));
        component.set("v.newPFR.Core_MDF_Activity_Types__c", $A.get("$Label.c.Core_MDF_Outcome_Based_CatType"));
        component.set("v.newPFR.Core_MDF_Program__c", this.getBudgetProgram(component));
        component.set("v.newPFR.Core_MDF_Reimbursement_Rate__c", parseInt($A.get("$Label.c.Core_MDF_ReimburesementNum")));
        component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", $A.get("$Label.c.Core_MDF_ReimburementVal"));
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

    initializePicklists: function (component) {
        var devName = component.get("v.recordtypeDeveloperName");
        var name = component.get("v.recordtypeName");
        var candidates = [];

        if (this.isNotBlank(devName)) {
            candidates.push(devName);
        }
        if (this.isNotBlank(name) && candidates.indexOf(name) === -1) {
            candidates.push(name);
        }

        this.logDebug("initializePicklists:candidates", candidates);

        this.activityPickerWithFallback(component, candidates, 0);
    },

    activityPickerWithFallback: function (component, recordTypeCandidates, index) {
        if (!recordTypeCandidates || index >= recordTypeCandidates.length) {
            return;
        }

        var candidate = recordTypeCandidates[index];
        var pickLabel = $A.get("$Label.c.Core_MDF_ActvityCategoryAndType");
        var pickListFields = (pickLabel ? pickLabel.split(",") : []);
        var knownFields = [
            "Core_MDF_Priorities__c",
            "Core_MDF_Priority_nm__c",
            "Core_MDF_Priority__c",
            "Core_MDF_Outcome_Region_nm__c",
            "Core_MDF_Country_nm__c",
            "Core_MDF_TargetAudience__c",
            "Core_MDF_ProductType__c",
            "Core_MDF_Brand_nm__c",
            "Core_MDF_Initiative_nm__c",
            "Core_MDF_Channel_Partner__c",
            "Core_MDF_Ecosystem_Partner__c",
            "Core_MDF_Other_Channel_Partner__c",
            "Core_MDF_Technology_txt__c",
            "Core_MDF_Technology__c",
            "Core_MDF_Outcomes_nm__c",
            "Core_MDF_Measurement_Approach_nm__c"
        ];

        for (var k = 0; k < knownFields.length; k++) {
            if (pickListFields.indexOf(knownFields[k]) === -1) {
                pickListFields.push(knownFields[k]);
            }
        }

        var action = component.get("c.mainPicklistFetcher");
        action.setParams({
            recordTypeName: candidate
        });

        this.logDebug("activityPickerWithFallback:request", {
            candidate: candidate,
            index: index,
            totalCandidates: recordTypeCandidates.length
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state !== "SUCCESS") {
                this.logWarn("activityPickerWithFallback:non-success", {
                    candidate: candidate,
                    state: state,
                    errors: response.getError()
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

            var hasPriority = !!(result.picklistFieldValues["Core_MDF_Priorities__c"] ||
                result.picklistFieldValues["Core_MDF_Priority_nm__c"] ||
                result.picklistFieldValues["Core_MDF_Priority__c"]);

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
                if (!fieldDef) {
                    continue;
                }
                this.initActcategoryandType(component, fieldName, fieldDef.controllerValues, fieldDef.values);
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
            this.fetchMemberAcceptors(component);
            return;
        }

        action = component.get("c.getOutcomeCampaignAccount");
        action.setParams({
            campaignId: recordId
        });

        action.setCallback(this, function (response) {
            if (response.getState() !== "SUCCESS") {
                this.logWarn("initializeCreateContext:non-success", {
                    state: response.getState(),
                    errors: response.getError()
                });
            } else {
                var campaignAccount = response.getReturnValue();
                if (campaignAccount && campaignAccount.Id) {
                    component.set("v.selectedAccount", campaignAccount);
                    //component.set("v.newPFR.CampaignId", recordId);
                }
            }

            this.fetchBudgetTypesBasedOnBenefits(component);
            this.fetchMemberAcceptors(component);
        });

        $A.enqueueAction(action);
    },

    loadPFR: function (component) {
        var recordId = component.get("v.recordId");
        if (!recordId) {
            return;
        }

        this.logDebug("loadPFR:start", { recordId: recordId });

        component.set("v.showSpinner", true);
        var action = component.get("c.loadPFRRecord");
        action.setParams({
            pfrId: recordId
        });

        action.setCallback(this, function (response) {
            component.set("v.showSpinner", false);
            if (response.getState() !== "SUCCESS") {
                this.logWarn("loadPFR:non-success", {
                    state: response.getState(),
                    errors: response.getError()
                });
                return;
            }

            var result = response.getReturnValue();
            if (!result) {
                this.logWarn("loadPFR:empty-result", null);
                return;
            }

            // Suppress the Core_MDF_Budget_Type_nm__c "change" handler's clearBudgetSelection while we
            // populate the loaded record below - otherwise it wipes selAvailableBudget/BudgetId that this
            // function is about to set from the record before fetchBudgetTypesBasedOnBenefits can reconcile it.
            // Cleared once fetchBudgetTypesBasedOnBenefits (invoked at the end of this callback) resolves.
            component.set("v.isInitialRecordLoad", true);

            component.set("v.newPFR", result);
            component.set("v.isAdditionalReviewReqd", component.get("v.checkCloneAttribute") ? false : Boolean(result.Core_MDF_Require_Additional_Review_ind__c));

            if (result.RecordType) {
                component.set("v.recordtypeName", result.RecordType.Name);
                component.set("v.recordtypeDeveloperName", result.RecordType.DeveloperName);
                this.setAccountFilter(component);
                this.activityPicker(component, result.RecordType.DeveloperName || result.RecordType.Name);
            }

            if (result.ChannelPartner && result.ChannelPartner.Id) {
                component.set("v.selectedAccount", result.ChannelPartner);
            }

            if (result.Core_MDF_Country_nm__c) {
                component.set("v.selectedCountryOptions", result.Core_MDF_Country_nm__c.split(';'));
            }

            if (result.Core_MDF_TargetAudience__c || result.Core_MDF_TargetAudience_nm__c) {
                component.set("v.selectedTargetAudienceOptions", (result.Core_MDF_TargetAudience__c || result.Core_MDF_TargetAudience_nm__c).split(';'));
            }

            if (result.Core_MDF_ProductType__c) {
                component.set("v.selectedProductTypeOptions", result.Core_MDF_ProductType__c.split(';'));
            }

            if (result.Core_MDF_Channel_Partner__c || result.Core_MDF_Ecosystem_Partner__c) {
                var ecoPartnerRaw = result.Core_MDF_Channel_Partner__c || result.Core_MDF_Ecosystem_Partner__c;
                var ecoValues = ecoPartnerRaw.split(';').map(function (value) {
                    return value.trim();
                });
                component.set("v.selectedEcosystemPartnerOptions", ecoValues);
                component.set("v.showOtherEcosystemPartner", ecoValues.indexOf("Others") !== -1 || ecoValues.indexOf("Other") !== -1);
            }
            if (result.Core_MDF_Other_Channel_Partner__c) {
                component.set("v.newPFR.Core_MDF_Other_Channel_Partner__c", result.Core_MDF_Other_Channel_Partner__c);
            }

            if (result.Core_MDF_Priorities__c || result.Core_MDF_Priority__c) {
                var priorityValue = result.Core_MDF_Priorities__c || result.Core_MDF_Priority__c;
                component.set("v.SelPriority", priorityValue);
                component.set("v.newPFR.Core_MDF_Priorities__c", priorityValue);
                component.set("v.newPFR.Core_MDF_Priority__c", priorityValue);
            }

            if (result.Core_MDF_Outcome_Region_nm__c) {
                component.set("v.SelRegion", result.Core_MDF_Outcome_Region_nm__c);
                component.set("v.newPFR.Core_MDF_Outcome_Region_nm__c", result.Core_MDF_Outcome_Region_nm__c);
            }

            if (result.Core_MDF_Intel_Activity_Owner_Id__c) {
                component.set("v.selectedApproverOptions", [result.Core_MDF_Intel_Activity_Owner_Id__c]);
                component.set("v.newPFR.Core_MDF_Intel_Activity_Owner_Id__c", result.Core_MDF_Intel_Activity_Owner_Id__c);
            }

            if (result.Core_MDF_Member_Acceptor_Id__c) {
                component.set("v.selectedExtActSubmitterOptions", result.Core_MDF_Member_Acceptor_Id__c.split(';'));
                component.set("v.newPFR.Core_MDF_Member_Acceptor_Id__c", result.Core_MDF_Member_Acceptor_Id__c);
            }

            if (result.BudgetId || result.Core_MDF_Budget_id__c) {
                var budgetId = result.BudgetId || result.Core_MDF_Budget_id__c;
                component.set("v.selAvailableBudget", budgetId);
                component.set("v.newPFR.BudgetId", budgetId);
                component.set("v.newPFR.Core_MDF_Budget_id__c", budgetId);
            }

            if (result.Core_MDF_Budget_Type_nm__c) {
                component.set("v.newPFR.Core_MDF_Budget_Type_nm__c", result.Core_MDF_Budget_Type_nm__c);
            }

            if (result.Core_MDF_Tactics_nm__c) {
                component.set("v.selectedTacticsOptions", result.Core_MDF_Tactics_nm__c.split(';'));
                this.updateIncentiveSectionVisibility(component);
            }

            // fetchBudgetTypesBasedOnBenefits resolves budgetType then chains fetchBudgetInfo/fetchApprovers itself;
            // calling fetchApprovers directly here too raced it with a stale blank budgetType and clobbered results.
            this.fetchBudgetTypesBasedOnBenefits(component);
            this.fetchMemberAcceptors(component);
            this.loadOutcomePurposeDetails(component);

            this.logDebug("loadPFR:end", {
                selectedAccountId: component.get("v.selectedAccount") ? component.get("v.selectedAccount").Id : null,
                selectedPriority: component.get("v.SelPriority"),
                selectedRegion: component.get("v.SelRegion"),
                selectedBudgetId: component.get("v.selAvailableBudget")
            });
        });

        $A.enqueueAction(action);
    },

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
            navigateToRecord.setParams({
                recordId: recordId,
                slideDevName: "detail"
            });
            navigateToRecord.fire();
            return;
        }

        var navigateHome = $A.get("e.force:navigateToObjectHome");
        if (navigateHome) {
            navigateHome.setParams({
                scope: "PartnerFundRequest"
            });
            navigateHome.fire();
        }
    },

    showToast: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title: title,
                message: message,
                type: type,
                duration: 5000
            });
            toastEvent.fire();
        }
    },

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
        if (!recordType) {
            return;
        }
        this.activityPickerWithFallback(component, [recordType], 0);
    },

    initActcategoryandType: function (component, fldname, scontrolvalues, sfieldcompletevalues) {
        if (!Array.isArray(sfieldcompletevalues)) {
            return;
        }

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
                    if (!childPickField[key]) {
                        childPickField[key] = [];
                    }
                    childPickField[key].push({
                        class: "optionClass",
                        label: item.label,
                        value: item.value
                    });
                }
            } else {
                if (!isDependentMap && ParPickField.length === 0 && fldname !== "Core_MDF_Country_nm__c") {
                    ParPickField.push({
                        class: "optionClass",
                        label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                        value: ""
                    });
                }
                ParPickField.push({
                    class: "optionClass",
                    label: item.label,
                    value: item.value
                });
            }
        }

        if (ParPickField.length > 0) {
            childPickField[""] = ParPickField;
            if (fldname === "Core_MDF_Tactics_nm__c") {
                component.set("v.activityTacticsOptions", this.localizeSubType(component, ParPickField, false));
            }
        }

        if (fldname === "Core_MDF_Focus_Area_nm__c") {
            component.set("v.focusArea", childPickField);
        } else if (fldname === "Core_MDF_Priorities__c" || fldname === "Core_MDF_Priority_nm__c" || fldname === "Core_MDF_Priority__c") {
            component.set("v.priority", childPickField);
        } else if (fldname === "Core_MDF_Outcome_Region_nm__c") {
            component.set("v.regions", childPickField);
        } else if (fldname === "Core_MDF_Country_nm__c") {
            component.set("v.CountryPicklistValues", childPickField);
        } else if (fldname === "Core_MDF_TargetAudience__c" || fldname === "Core_MDF_TargetAudience_nm__c") {
            component.set("v.audiencePicklistValues", childPickField);
        } else if (fldname === "Core_MDF_ProductType__c") {
            component.set("v.ProductTypes", childPickField);
        } else if (fldname === "Core_MDF_Brand_nm__c") {
            component.set("v.MultiBrandTypes", childPickField);
        } else if (fldname === "Core_MDF_Initiative_nm__c") {
            component.set("v.initiativePicklistValues", childPickField);
        } else if (fldname === "Core_MDF_Channel_Partner__c" || fldname === "Core_MDF_EcosystemPartner_nm__c" || fldname === "Core_MDF_Ecosystem_Partner__c" || fldname === "Core_MDF_Other_Channel_Partner__c") {
            component.set("v.MultiEcoPartnerTypes", childPickField);
        } else if (fldname === "Core_MDF_Technology_txt__c" || fldname === "Core_MDF_Technology__c") {
            component.set("v.technologies", childPickField);
        } else if (fldname === "Core_MDF_Outcomes_nm__c") {
            component.set("v.outcomes", childPickField);
        } else if (fldname === "Core_MDF_Measurement_Approach_nm__c") {
            component.set("v.measurementApproachPicklistValues", childPickField);
        }
    },

    setChildPicklistValues: function (component, controllingValues, dependentValues) {
        var childPicklistValue = [];
        if (!dependentValues) {
            return childPicklistValue;
        }

        var effectiveController = controllingValues;
        if (!effectiveController && dependentValues[""]) {
            effectiveController = "";
        }

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

    case_insensitive_sort: function (a, b) {
        return (a.label || "").toLowerCase().localeCompare((b.label || "").toLowerCase());
    },

    localizeSubType: function (component, options, addNone) {
        var localizedMap = component.get("v.apitoLabelConvert") || {};
        var localizedOptions = [];

        if (addNone) {
            localizedOptions.push({
                label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                value: ""
            });
        }

        for (var i = 0; i < options.length; i++) {
            var option = options[i];
            if (!option || option.value === "") {
                continue;
            }
            var label = localizedMap[option.value] ? localizedMap[option.value] : option.label;
            localizedOptions.push({
                label: label,
                value: option.value,
                class: option.class || "optionClass"
            });
        }

        return localizedOptions;
    },

    getAllDependentOptions: function (dependentMap) {
        var combined = [];
        var seen = {};
        if (!dependentMap) {
            return combined;
        }
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
        if (this.isNotBlank(selectedFocusArea)) {
            return selectedFocusArea;
        }

        // CCF/DCF outcome-based activity does not expose a Focus Area or Campaign controller,
        // so dependent picklists must fall back to all valid values rather than filtering by a blank controller.
        var isRecordTypeDriven = fieldName === "Core_MDF_Country_nm__c" ||
            fieldName === "Core_MDF_Outcome_Region_nm__c" ||
            fieldName === "Core_MDF_Outcomes_nm__c" ||
            fieldName === "Core_MDF_Priorities__c" ||
            fieldName === "Core_MDF_Priority_nm__c" ||
            fieldName === "Core_MDF_TargetAudience__c" ||
            fieldName === "Core_MDF_Channel_Partner__c" ||
            fieldName === "Core_MDF_Other_Channel_Partner__c";

        if (isRecordTypeDriven) {
            return component.get("v.recordtypeDeveloperName") || component.get("v.recordtypeName") || "";
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

    fetchPriority: function (component) {
        var controllingValue = this.getEffectiveControllingValue(component, "Core_MDF_Priorities__c");
        var values = this.getOptionsForControllerOrAll(component, controllingValue, component.get("v.priority"));
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
                    state: response.getState(),
                    errors: response.getError()
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
        var recTypeKey = component.get("v.recordtypeDeveloperName") || component.get("v.recordtypeName");
        var values = this.setChildPicklistValues(component, recTypeKey, component.get("v.CountryPicklistValues"));
        values = this.localizeSubType(component, values, false);
        component.set("v.CountryDependants", values);
        component.set("v.AllCountryOptionsMain", values);
        component.set("v.AllCountryOptions", values);
        if (component.get("v.SelRegion")) {
            this.fetchCountriesByRegionUsingAllOptions(component, component.get("v.SelRegion"));
        }
    },

    fetchMultiTargetAudience: function (component) {
        var controllingValue = this.getEffectiveControllingValue(component, "Core_MDF_TargetAudience__c");
        var values = this.getOptionsForControllerOrAll(component, controllingValue, component.get("v.audiencePicklistValues"));
        values = this.localizeSubType(component, values, false);
        component.set("v.MultiTargetAudienceValues", values);
        component.set("v.AllTargetAudienceOptions", values);
    },

    fetchProdType: function (component) {
        var controllingValue = this.getEffectiveControllingValue(component, "Core_MDF_ProductType__c");
        var values = this.getOptionsForControllerOrAll(component, controllingValue, component.get("v.ProductTypes"));
        values = this.localizeSubType(component, values, false);
        component.set("v.ProductTypeDependent", values);
        component.set("v.ProductTypeValues", values);
    },

    fetchMultiBrandType: function (component) {
        var controllingValue = this.getEffectiveControllingValue(component, "Core_MDF_Brand_nm__c");
        var values = this.getOptionsForControllerOrAll(component, controllingValue, component.get("v.MultiBrandTypes"));
        values = this.localizeSubType(component, values, false);
        component.set("v.MultiBrandValues", values);
        component.set("v.AllBrandOptions", values);
    },

    fetchMultiInitiative: function (component) {
        var controllingValue = this.getEffectiveControllingValue(component, "Core_MDF_Initiative_nm__c");
        var values = this.getOptionsForControllerOrAll(component, controllingValue, component.get("v.initiativePicklistValues"));
        values = this.localizeSubType(component, values, false);
        component.set("v.MultiInitiativeValues", values);
        component.set("v.AllInitiativeOptions", values);
    },

    fetchMultiEcoPartnerType: function (component) {
        var controllingValue = this.getEffectiveControllingValue(component, "Core_MDF_Channel_Partner__c");
        var values = this.getOptionsForControllerOrAll(component, controllingValue, component.get("v.MultiEcoPartnerTypes"));
        values = this.localizeSubType(component, values, false);
        component.set("v.MultiEcoPartnerValues", values);
        component.set("v.AllEcosystemPartner", values);
    },

    fetchTechnologies: function (component) {
        var controllingValue = this.getEffectiveControllingValue(component, "Core_MDF_Technology_txt__c");
        var values = this.getOptionsForControllerOrAll(component, controllingValue, component.get("v.technologies"));
        values = this.localizeSubType(component, values, false);
        component.set("v.technologiesDependant", values);
        component.set("v.AllTechnologyOptions", values);
    },

    /*fetchOutcomeMetric: function(component) {
        var recTypeKey = component.get("v.recordtypeDeveloperName") || component.get("v.recordtypeName");
        var values = this.setChildPicklistValues(component, recTypeKey, component.get("v.outcomes"));
        values = this.localizeSubType(component, values, false);
        component.set("v.outcomesDependants", values);
        component.set("v.outcomeMetricOptions", values);
    },*/
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
        var controllingValue = this.getEffectiveControllingValue(component, "Core_MDF_Measurement_Approach_nm__c");
        var values = this.getOptionsForControllerOrAll(component, controllingValue, component.get("v.measurementApproachPicklistValues"));
        values = this.localizeSubType(component, values, false);
        component.set("v.measurementApproachValues", values);
        component.set("v.measurementApproachOptions", values);
    },

    fetchApprovers: function (component) {
        var selectedAccount = component.get("v.selectedAccount");
        if (!selectedAccount || !selectedAccount.Id) {
            this.logWarn("fetchApprovers:missing-account", selectedAccount);
            component.set("v.AllApproverOptions", []);
            component.set("v.selectedApproverOptions", []);
            component.set("v.showNoIntelOwnerMessage", false);
            return;
        }

        var action = component.get("c.getIntelActivityOwnersByRegionCountry");
        action.setParams({
            accId: selectedAccount.Id,
            selectedRegion: component.get("v.SelRegion") || "",
            countryList: component.get("v.selectedCountryOptions") || []
        });

        this.logDebug("fetchApprovers:request", {
            accId: selectedAccount.Id,
            selectedRegion: component.get("v.SelRegion") || "",
            country: component.get("v.selectedCountryOptions") || [],
            defaultRegion: "WW"
        });

        action.setCallback(this, function (response) {
            if (response.getState() !== "SUCCESS") {
                this.logWarn("fetchApprovers:non-success", {
                    state: response.getState(),
                    errors: response.getError()
                });
                return;
            }
            var result = response.getReturnValue();
            var ownerValues = [];
            if (result && result.intelActivityOwnerList) {
                for (var i = 0; i < result.intelActivityOwnerList.length; i++) {
                    ownerValues.push({
                        label: result.intelActivityOwnerList[i].fullName,
                        value: result.intelActivityOwnerList[i].userId
                    });
                }
            }
            component.set("v.AllApproverOptions", ownerValues);
            component.set("v.displayApprovers", ownerValues.length > 0);
            component.set("v.showNoIntelOwnerMessage", ownerValues.length === 0);
            this.logDebug("fetchApprovers:result", {
                ownerCount: ownerValues.length,
                selectedOwnerBeforeNormalize: (component.get("v.selectedApproverOptions") || [])[0] || component.get("v.newPFR.Core_MDF_Intel_Activity_Owner_Id__c")
            });

            var selectedOwner = (component.get("v.selectedApproverOptions") || [])[0] || component.get("v.newPFR.Core_MDF_Intel_Activity_Owner_Id__c");
            if (selectedOwner) {
                var found = false;
                for (var j = 0; j < ownerValues.length; j++) {
                    if (ownerValues[j].value === selectedOwner) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    ownerValues.unshift({
                        label: (component.get("v.newPFR.Core_MDF_Intel_Activity_Owner_Id__r") && component.get("v.newPFR.Core_MDF_Intel_Activity_Owner_Id__r").Name) || "Selected Owner",
                        value: selectedOwner
                    });
                    component.set("v.AllApproverOptions", ownerValues);
                }
                component.set("v.selectedApproverOptions", [selectedOwner]);
                component.set("v.newPFR.Core_MDF_Intel_Activity_Owner_Id__c", selectedOwner);
            } else {
                this.defaultIntelActivityOwner(component);
            }
        });
        $A.enqueueAction(action);
    },

    defaultIntelActivityOwner: function (component) {
        var selectedAccount = component.get("v.selectedAccount");
        var action;
        if (!selectedAccount || !selectedAccount.Id) {
            return;
        }

        action = component.get("c.getDefaultIntelActivityOwnerByRegionCountry");
        action.setParams({
            accId: selectedAccount.Id,
            selectedRegion: component.get("v.SelRegion") || "",
            countryList: component.get("v.selectedCountryOptions") || []
        });

        action.setCallback(this, function (response) {
            var defaultOwnerId = response.getReturnValue();
            if (response.getState() !== "SUCCESS") {
                this.logWarn("defaultIntelActivityOwner:non-success", {
                    state: response.getState(),
                    errors: response.getError()
                });
                return;
            }

            if (defaultOwnerId && !(component.get("v.selectedApproverOptions") || [])[0]) {
                component.set("v.selectedApproverOptions", [defaultOwnerId]);
                component.set("v.newPFR.Core_MDF_Intel_Activity_Owner_Id__c", defaultOwnerId);
            }
        });
        $A.enqueueAction(action);
    },

    fetchMemberAcceptors: function (component) {
        var selectedAccount = component.get("v.selectedAccount");
        if (!selectedAccount || !selectedAccount.Id) {
            component.set("v.AllExtActSubmitterOptions", []);
            component.set("v.selectedExtActSubmitterOptions", []);
            return;
        }

        var action = component.get("c.getMemberactivityOwners");
        action.setParams({
            accId: selectedAccount.Id,
            isPlannedEdit: false
        });

        action.setCallback(this, function (response) {
            if (response.getState() !== "SUCCESS") {
                return;
            }
            var result = response.getReturnValue() || [];
            var ownerValues = [];
            for (var i = 0; i < result.length; i++) {
                ownerValues.push({
                    label: result[i].fullName,
                    value: result[i].userId
                });
            }
            component.set("v.AllExtActSubmitterOptions", ownerValues);
            component.set("v.displayExtActSubmitters", ownerValues.length > 0);
        });
        $A.enqueueAction(action);
    },

    onRegionChange: function (component) {
        var region = component.get("v.SelRegion");
        component.set("v.newPFR.Core_MDF_Outcome_Region_nm__c", region);
        component.set("v.selectedCountryOptions", []);
        component.set("v.newPFR.Core_MDF_Country_nm__c", "");
        if (this.isNotBlank(region)) {
            this.fetchCountriesByRegion(component, region);
        } else {
            component.set("v.AllCountryOptions", component.get("v.AllCountryOptionsMain"));
            this.fetchApprovers(component);
        }
    },

    fetchCountriesByRegion: function (component, region) {
        var action = component.get("c.getCountryOptionsByRegion");
        action.setParams({
            region: region
        });

        action.setCallback(this, function (response) {
            if (response.getState() !== "SUCCESS") {
                this.logWarn("fetchCountriesByRegion:non-success", {
                    state: response.getState(),
                    errors: response.getError()
                });
                component.set("v.AllCountryOptions", []);
                this.fetchApprovers(component);
                return;
            }

            component.set("v.AllCountryOptions", response.getReturnValue() || []);
            this.fetchApprovers(component);
        });

        $A.enqueueAction(action);
    },

    fetchCountriesByRegionUsingAllOptions: function (component, region) {
        var masterList = component.get("v.AllCountryOptionsMain") || [];
        if (masterList.length === 0) {
            return;
        }

        var allowedLabels = masterList.map(function (c) {
            return c.label;
        });

        var action = component.get("c.getCountryLabelsByRegion");
        action.setParams({
            region: region,
            allowedCountryLabels: allowedLabels
        });

        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var serverList = response.getReturnValue() || [];
                serverList.sort();
                var options = [];
                for (var i = 0; i < serverList.length; i++) {
                    options.push({
                        label: serverList[i],
                        value: serverList[i]
                    });
                }
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

        var filterCountrySearch = [];
        var filterCountryNonSearch = [];
        for (var index = 0; index < countryName.length; index++) {
            if ((countryName[index].value || "").toUpperCase().includes(search)) {
                filterCountrySearch.push(countryName[index]);
            } else {
                filterCountryNonSearch.push(countryName[index]);
            }
        }
        component.set("v.AllCountryOptions", filterCountrySearch.concat(filterCountryNonSearch));
    },

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

        if (marketingValue) {
            combinedValues.push(marketingValue);
        }

        if (businessValue) {
            combinedValues.push(businessValue);
        }

        return combinedValues.join("\n");
    },

    syncOtherBrandsTechnologies: function (component) {
        var combinedOtherBrandsTechnologies = this.combineOtherBrandsTechnologies(
            component.get("v.marketingOtherBrandsTechnologies"),
            component.get("v.businessOtherBrandsTechnologies")
        );

        component.set(
            "v.newPFR.Core_MDF_Other_Brands_Technologies_txt__c",
            combinedOtherBrandsTechnologies
        );
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

        if (!recordId) {
            return;
        }

        var action = component.get("c.getActivityOutcomes");

        action.setParams({
            activityId: recordId
        });

        action.setCallback(this, function (response) {
            if (response.getState() !== "SUCCESS") {
                return;
            }

            var outcomes = response.getReturnValue() || [];

            component.set("v.isLoadingOutcomePurpose", true);

            for (var i = 0; i < outcomes.length; i++) {
                var outcome = outcomes[i];
                var metric = outcome.outcomeMetricApi || outcome.outcomeMetric;

                if (outcome.outcomeType === "Marketing") {
                    component.set("v.selectedMarketingOutcomeMetricOptions", metric ? [metric] : []);
                    component.set(
                        "v.selectedMarketingBrandOptions",
                        outcome.brandValues ? outcome.brandValues.split(";") : []
                    );
                    component.set(
                        "v.selectedMarketingTechnologyOptions",
                        outcome.technologyValues ? outcome.technologyValues.split(";") : []
                    );
                    component.set(
                        "v.marketingOtherBrandsTechnologies",
                        outcome.otherBrandsTechnologies || ""
                    );
                }

                if (outcome.outcomeType === "Business") {
                    component.set("v.selectedBusinessOutcomeMetricOptions", metric ? [metric] : []);
                    component.set(
                        "v.selectedBusinessBrandOptions",
                        outcome.brandValues ? outcome.brandValues.split(";") : []
                    );
                    component.set(
                        "v.selectedBusinessTechnologyOptions",
                        outcome.technologyValues ? outcome.technologyValues.split(";") : []
                    );
                    component.set(
                        "v.businessOtherBrandsTechnologies",
                        outcome.otherBrandsTechnologies || ""
                    );
                }
            }

            this.syncSelectedOutcomeMetrics(component);
            this.syncBrandTechnologySelections(component);
            this.syncOtherBrandsTechnologies(component);

            window.setTimeout(
                $A.getCallback(function () {
                    component.set("v.isLoadingOutcomePurpose", false);
                }),
                0
            );
        });

        $A.enqueueAction(action);
    },
    getBudgetProgram: function (component) {
        var recordType = (component.get("v.recordtypeDeveloperName") || component.get("v.recordtypeName") || "").toLowerCase();
        if (recordType.indexOf("data_center") !== -1 || recordType.indexOf("datacenter") !== -1 ||
            recordType.indexOf("data centre") !== -1 || recordType.indexOf("dcf") !== -1) {
            return "Data Center CoMarketing Fund";
        }
        if (recordType.indexOf("ccf") !== -1 || recordType.indexOf("client") !== -1) {
            return "Client CoMarketing Fund";
        }
        return "Client CoMarketing Fund";
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

    fetchBudgetTypesBasedOnBenefits: function (component) {
        var selectedAccount = component.get("v.selectedAccount");
        if (!selectedAccount || !selectedAccount.Id) {
            this.logWarn("fetchBudgetTypesBasedOnBenefits:missing-account", selectedAccount);
            this.clearBudgetSelection(component);
            component.set("v.budgetStr", []);
            component.set("v.isInitialRecordLoad", false);
            return;
        }

        var action = component.get("c.getCCFDCFStandardBudgetTypes");
        action.setParams({
            program: this.getBudgetProgram(component)
        });

        this.logDebug("fetchBudgetTypesBasedOnBenefits:request", {
            accountId: selectedAccount.Id,
            program: this.getBudgetProgram(component)
        });

        action.setCallback(this, function (response) {
            if (response.getState() !== "SUCCESS") {
                this.logWarn("fetchBudgetTypesBasedOnBenefits:non-success", {
                    state: response.getState(),
                    errors: response.getError()
                });
                this.clearBudgetSelection(component);
                component.set("v.budgetStr", []);
                component.set("v.isInitialRecordLoad", false);
                return;
            }

            var result = response.getReturnValue() || {};
            var budgetTypeOptions = [{
                label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                value: ""
            }];
            for (var key in result) {
                if (result[key]) {
                    budgetTypeOptions.push({
                        label: result[key],
                        value: key
                    });
                }
            }
            component.set("v.budgetTypeVal", budgetTypeOptions);
            this.logDebug("fetchBudgetTypesBasedOnBenefits:result", {
                optionCount: budgetTypeOptions.length,
                optionValues: budgetTypeOptions
            });

            // Budget Type must be an explicit user choice (or already set on the loaded record) -
            // auto-picking the first option fired budget/approver queries with the wrong type and hid real data.
            var selected = component.get("v.newPFR.Core_MDF_Budget_Type_nm__c");
            if (this.isNotBlank(selected)) {
                this.fetchBudgetInfo(component);
                this.fetchApprovers(component);
            }
            // Safe to let genuine user-driven Budget Type changes clear/refetch again from here on.
            component.set("v.isInitialRecordLoad", false);
        });

        $A.enqueueAction(action);
    },

    clearBudgetSelection: function (component) {
        component.set("v.selAvailableBudget", "");
        component.set("v.newPFR.BudgetId", null);
        component.set("v.newPFR.Core_MDF_Budget_id__c", null);
        component.set("v.newPFR.AllocationId", null);
        component.set("v.isShowAllocationAmt", false);
        component.set("v.showAllocationAmtMsg", "");
    },

    fetchAdditionalReviewPermission: function (component) {
        var permissionSetName = $A.get("$Label.c.Core_MDF_OpalAccountManagers");
        if (!permissionSetName) {
            return;
        }

        var permissionsets = {
            opalAccountManagers: permissionSetName.split(",")
        };
        var action = component.get("c.userHasPermissionSet");
        action.setParams({ permissionsets: permissionsets });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var userPermissions = response.getReturnValue().userPermissions || {};
                component.set("v.isLoggedInUserLevelOneApprover", userPermissions.opalAccountManagers === true);
            } else {
                this.logWarn("fetchAdditionalReviewPermission:non-success", response.getError());
            }
        });
        $A.enqueueAction(action);
    },


    fetchBudgetInfo: function (component) {
        var currentBudgetId = component.get("v.selAvailableBudget");
        if (!this.isNotBlank(currentBudgetId)) {
            currentBudgetId = null;
        }

        var selectedAccount = component.get("v.selectedAccount");
        if (!selectedAccount || !selectedAccount.Id) {
            this.logWarn("fetchBudgetInfo:missing-account", selectedAccount);
            this.clearBudgetSelection(component);
            component.set("v.budgetStr", []);
            component.set("v.budgetHelpMessage", "Select an account to load available budgets.");
            return;
        }

        var budgetType = component.get("v.newPFR.Core_MDF_Budget_Type_nm__c");
        if (!this.isNotBlank(budgetType)) {
            this.logWarn("fetchBudgetInfo:missing-budgetType", null);
            this.clearBudgetSelection(component);
            component.set("v.budgetStr", []);
            component.set("v.budgetHelpMessage", "Select a budget type to load available budgets.");
            return;
        }

        var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var endDate = component.get("v.newPFR.Core_MDF_End_Date__c");
        if (!startDate || !endDate) {
            this.logWarn("fetchBudgetInfo:missing-dates", {
                startDate: startDate,
                endDate: endDate
            });
            this.clearBudgetSelection(component);
            component.set("v.budgetStr", []);
            component.set("v.budgetHelpMessage", "Enter start date and end date to load available budgets.");
            return;
        }

        // Apex filters budgets by Core_MDF_Ultimate_Account_Id__c, not the selected Channel Partner's own Id.
        var ultimateAccountId = selectedAccount.Core_MDF_CoMarketing_Ultimate_Account__c || selectedAccount.Id;

        component.set("v.showSpinner", true);
        component.set("v.budgetHelpMessage", "");
        var action = component.get("c.fetchBudgetInfo");
        action.setParams({
            accountId: ultimateAccountId,
            startDate: startDate,
            endDate: endDate,
            budgetType: budgetType,
            isIPAAccBased: false,
            currentBudgetId: currentBudgetId
        });

        this.logDebug("fetchBudgetInfo:request", {
            accountId: ultimateAccountId,
            startDate: startDate,
            endDate: endDate,
            budgetType: budgetType,
            currentBudgetId: currentBudgetId
        });

        action.setCallback(this, function (response) {
            component.set("v.showSpinner", false);
            if (response.getState() !== "SUCCESS") {
                this.logWarn("fetchBudgetInfo:non-success", {
                    state: response.getState(),
                    errors: response.getError()
                });
                component.set("v.budgetStr", []);
                this.clearBudgetSelection(component);
                component.set("v.budgetHelpMessage", "Unable to load available budgets. Please try again.");
                return;
            }

            var result = response.getReturnValue() || [];
            var availableBudget = [];
            var hasCurrentBudget = false;
            for (var i = 0; i < result.length; i++) {
                var startVal = result[i].StartDate ? result[i].StartDate.replaceAll("-", "/") : "";
                var endVal = result[i].EndDate ? result[i].EndDate.replaceAll("-", "/") : "";
                if (currentBudgetId && result[i].Id === currentBudgetId) {
                    hasCurrentBudget = true;
                }
                availableBudget.push({
                    key: result[i].Id,
                    value: result[i].Core_MDF_budget_ref_nbr__c + " : " + result[i].Title + " : " + result[i].Core_MDF_Budget_Type_Txt__c + " : " + startVal + " - " + endVal
                });
            }

            component.set("v.budgetStr", availableBudget);
            component.set("v.budgetHelpMessage", availableBudget.length === 0 ? "No available budget found for the selected account, dates, and budget type." : "");
            this.logDebug("fetchBudgetInfo:result", {
                budgetCount: availableBudget.length,
                firstBudget: availableBudget.length > 0 ? availableBudget[0] : null
            });
            if (availableBudget.length === 1) {
                component.set("v.selAvailableBudget", availableBudget[0].key);
                component.set("v.newPFR.BudgetId", availableBudget[0].key);
                component.set("v.newPFR.Core_MDF_Budget_id__c", availableBudget[0].key);
                this.checkAvailAllocationAmt(component);
            } else if (hasCurrentBudget) {
                component.set("v.selAvailableBudget", currentBudgetId);
                component.set("v.newPFR.BudgetId", currentBudgetId);
                component.set("v.newPFR.Core_MDF_Budget_id__c", currentBudgetId);
                this.checkAvailAllocationAmt(component);
            } else {
                this.clearBudgetSelection(component);
            }
        });

        $A.enqueueAction(action);
    },

    checkAvailAllocationAmt: function (component) {
        var formatter = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
        });

        var selectedAccount = component.get("v.selectedAccount");
        var accountId = (selectedAccount && selectedAccount.Id) ? selectedAccount.Id : null;

        var selectedbudget = component.get("v.selAvailableBudget");
        if (selectedbudget == null || selectedbudget == undefined || selectedbudget == "") {
            this.clearBudgetSelection(component);
            return;
        }

        var mode = component.get("v.mode");
        var recordTypeDevName;
        if (mode == '' || mode == null || mode == undefined) {
            recordTypeDevName = component.get("v.recordtypeDeveloperName");
        } else if (mode == 'edit' || mode == 'clone') {
            recordTypeDevName = component.get("v.newPFR.RecordType.DeveloperName");
        } else {
            recordTypeDevName = component.get("v.recordtypeDeveloperName");
        }

        component.set("v.newPFR.Core_MDF_Budget_id__c", selectedbudget);
        component.set("v.newPFR.BudgetId", selectedbudget);

        var action = component.get("c.checkAvailableAllocAmt");
        action.setParams({
            pfr: component.get("v.newPFR"),
            recordType: recordTypeDevName,
            accountId: accountId,
            budgetId: selectedbudget
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var amountToBeDisplayed = result.amountToBeDisplayed;
                var allocationId = result.allocationId;
                var isAutoEnabled = result.isAutoEnabled;

                if (amountToBeDisplayed != $A.get("$Label.c.Core_MDF_ZeroAllocationAmount")) {
                    if (isAutoEnabled == true) {
                        component.set("v.showAllocationAmtMsg",
                            $A.get("$Label.c.Core_MDF_AllocationAmountAvailableMsg") + " " +
                            formatter.format(amountToBeDisplayed) + " " +
                            $A.get("$Label.c.Core_MDF_AllocationAmountAutoEnabled"));
                    } else {
                        component.set("v.showAllocationAmtMsg",
                            $A.get("$Label.c.Core_MDF_AllocationAmountAvailableMsg") + " " +
                            formatter.format(amountToBeDisplayed));
                    }
                    component.set("v.isShowAllocationAmt", true);
                    // Stamp AllocationId on the PFR so node activities get it stamped correctly on save
                    component.set("v.newPFR.AllocationId", allocationId);
                } else {
                    if (this.isNotBlank(component.get("v.selAvailableBudget"))) {
                        component.set("v.isShowAllocationAmt", true);
                        component.set("v.showAllocationAmtMsg", amountToBeDisplayed);
                    } else {
                        component.set("v.isShowAllocationAmt", false);
                        component.set("v.showAllocationAmtMsg", '');
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

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
        component.set("v.selAvailableBudget", "");
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
    },



    saveRecord: function (component, isSaveAndNew) {
        var self = this;
        var newPFR = component.get("v.newPFR");

        if (!newPFR.Title || !component.get("v.selectedAccount.Id") || !newPFR.Core_MDF_Start_Date__c ||
            !newPFR.Core_MDF_End_Date__c || !newPFR.Core_MDF_Activity_Description__c) {
            self.showToast("Error", "Please complete all required fields before saving.", "error");
            return;
        }
        var marketingSelections = component.get("v.selectedMarketingOutcomeMetricOptions") || [];
        var businessSelections = component.get("v.selectedBusinessOutcomeMetricOptions") || [];
        var marketingMetric = marketingSelections.length > 0 ? marketingSelections[0] : "";
        var businessMetric = businessSelections.length > 0 ? businessSelections[0] : "";

        if (!marketingMetric && !businessMetric) {
            self.showToast("", $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage"), "error");
            return;
        }

        var selectedBudget = component.get("v.selAvailableBudget");
        if (this.isNotBlank(newPFR.Core_MDF_Budget_Type_nm__c) && !this.isNotBlank(selectedBudget)) {
            newPFR.BudgetId = null;
            newPFR.Core_MDF_Budget_id__c = null;
            self.showToast("Error", "Please select an available budget before saving.", "error");
            return;
        }

        // Additional client-side validations for CCF/DCF required picklists
        var selectedCountry = component.get("v.selectedCountryOptions") || [];
        var selectedTargetAudience = component.get("v.selectedTargetAudienceOptions") || [];
        var selectedProductType = component.get("v.selectedProductTypeOptions") || [];
        var selectedEcoPartners = component.get("v.selectedEcosystemPartnerOptions") || [];

        // Country (Market) must be selected
        if (selectedCountry.length === 0) {
            self.showToast("Error", $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage") || "Please select at least one market.", "error");
            return;
        }

        // Target Audience must be selected
        if (selectedTargetAudience.length === 0) {
            var taMsg = $A.get("$Label.c.Core_MDF_TargetAudienceError_OutcomeBased") || $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage");
            self.showToast("Error", taMsg, "error");
            return;
        }

        // Product Type must be selected
        if (selectedProductType.length === 0) {
            var ptMsg = $A.get("$Label.c.Core_MDF_ProductTypeError_OutcomeBased") || $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage");
            self.showToast("Error", ptMsg, "error");
            return;
        }

        // Ecosystem Partner must be selected
        if (selectedEcoPartners.length === 0) {
            var ecoMsg = $A.get("$Label.c.Core_MDF_EcosystemPartner_ReqError_OB") || $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage");
            self.showToast("Error", ecoMsg, "error");
            return;
        }

        // Financial validations: total investment and max intel investment
        var requestedAmount = parseFloat(newPFR.RequestedAmount) || 0;
        if (requestedAmount <= 0) {
            var spendMsg = $A.get("$Label.c.Core_MDF_TotalInvestment_grtthanzero_Error") || "Total investment must be greater than zero.";
            // set inline and toast
            component.set("v.showErrorMsgForSpendingLimit", true);
            component.set("v.ErrorMsgForSpendingLimit", spendMsg);
            self.showToast("Error", spendMsg, "error");
            return;
        }

        var maxIntel = parseFloat(newPFR.Core_MDF_Maximum_Intel_Investment_amt__c) || 0;
        if (maxIntel <= 0) {
            var maxZeroMsg = $A.get("$Label.c.Core_MDF_MaxIntelInvest_grtthanzero_Error") || "Maximum intel investment must be greater than zero.";
            component.set("v.showErrorMsgForMaxIntelInvest", true);
            component.set("v.ErrorMsgForMaxIntelInvest", maxZeroMsg);
            self.showToast("Error", maxZeroMsg, "error");
            return;
        }

        // Disallow fractional intel amounts (must be whole numbers)
        if (Math.floor(maxIntel) !== maxIntel) {
            var maxDecimalMsg = $A.get("$Label.c.Core_MDF_MaxIntelInvest_grtthanzero_Error") || "Maximum intel investment must be a whole number.";
            component.set("v.showErrorMsgForMaxIntelInvest", true);
            component.set("v.ErrorMsgForMaxIntelInvest", maxDecimalMsg);
            self.showToast("Error", maxDecimalMsg, "error");
            return;
        }

        if (maxIntel > requestedAmount) {
            var exceedMsg = $A.get("$Label.c.Core_MDF_MaxIntelInvest_Exceed_Error") || "Maximum intel investment cannot exceed total investment.";
            component.set("v.showErrorMsgForMaxIntelInvest", true);
            component.set("v.ErrorMsgForMaxIntelInvest", exceedMsg);
            self.showToast("Error", exceedMsg, "error");
            return;
        }

        // Measurement Approach required when outcome metrics selected
        var selectedMeasurementApproach = component.get("v.selectedMeasurementApproachOptions") || [];
        if ((marketingSelections.length > 0 || businessSelections.length > 0) && selectedMeasurementApproach.length === 0) {
            var measMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error") || "At least one Measurement Approach must be selected.";
            self.showToast("Error", measMsg, "error");
            return;
        }

        // Tactics selection required
        var selectedTactics = component.get("v.selectedTacticsOptions") || [];
        if (selectedTactics.length === 0) {
            var tactMsg = $A.get("$Label.c.Core_MDF_Activity_Tactics_Error_OutcomeBased") || "Please select at least one tactic.";
            self.showToast("Error", tactMsg, "error");
            return;
        }

        // Initiative selection guidance (if picklist present)
        var selectedInitiatives = component.get("v.selectedInitiativeOptions") || [];
        if (selectedInitiatives.length === 0) {
            var initMsg = $A.get("$Label.c.Core_MDF_Initiative_None_Selection_Error") || "Please select an initiative.";
            self.showToast("Error", initMsg, "error");
            return;
        }

        var tacticMetricsValues = [];
        if ((component.get("v.selectedTacticsOptions") || []).length > 0) {
            var tacticMetricsComponent = component.find("tacticMetrics");
            if (tacticMetricsComponent) {
                var tacticMetricsChild = this.isNotBlank(tacticMetricsComponent[0])
                    ? tacticMetricsComponent[0] : tacticMetricsComponent;
                if (!tacticMetricsChild.isFormValid()) {
                    self.showToast("Error", "Please complete all tactic metrics before saving.", "error");
                    return;
                }
                tacticMetricsValues = tacticMetricsChild.getTacticMetricsValues() || [];
            }
        }

        var segmentValues = [];
        if (component.get("v.isSPIFSecAvailable")) {
            var segmentComponent = component.find("segmentComp");
            if (segmentComponent) {
                var segmentChild = this.isNotBlank(segmentComponent[0])
                    ? segmentComponent[0] : segmentComponent;
                segmentValues = segmentChild.getSegmentValues() || [];
                if (segmentValues.length === 0 || !segmentChild.isFormValid()) {
                    self.showToast("Error", "Please complete the incentive details before saving.", "error");
                    return;
                }
                component.set("v.segmentString", JSON.stringify(segmentValues));
            }
        }

        this.syncSelectedOutcomeMetrics(component);
        this.syncBrandTechnologySelections(component);
        this.syncOtherBrandsTechnologies(component);
        // This component only ever creates/edits/clones CCF/DCF Outcome Based activities, which
        // intentionally have no CampaignId (see initializeCreateContext). The server-side validation
        // in Core_MDF_PartnerFundRequestCreatePage.savenSendRecordId only requires a CampaignId when
        // Core_MDF_Is_Outcome_Based_Ind__c is false, so this flag must always be true here. It was only
        // being set during the "create" path (initialize()); on edit/clone the flag depended on whatever
        // loadPFR's query happened to return, which could come back blank and wrongly trigger
        // "Please select a Campaign in order to submit activity." Force it here for every mode.
        newPFR.Core_MDF_Is_Outcome_Based_Ind__c = true;
        newPFR.ChannelPartnerId = component.get("v.selectedAccount.Id");
        newPFR.Core_MDF_Program__c = this.getBudgetProgram(component);
        newPFR.Core_MDF_Require_Additional_Review_ind__c = Boolean(component.get("v.isAdditionalReviewReqd"));
        if (component.get("v.mode") !== "edit" &&
            component.get("v.isLoggedInUserLevelOneApprover") &&
            (newPFR.Core_MDF_Budget_Type_nm__c === $A.get("$Label.c.Core_MDF_BudgetType_MDF") ||
                newPFR.Core_MDF_Budget_Type_nm__c === $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus") ||
                newPFR.Core_MDF_Budget_Type_nm__c === $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
                newPFR.Core_MDF_Budget_Type_nm__c === $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP"))) {
            newPFR.Core_MDF_Approval_Step_Completed__c = 1;
            newPFR.Core_MDF_Approval_Stage__c = 'L1 Approval';
        }
        // Without this, Salesforce falls back to the org/profile default RecordType on insert
        // instead of the CCF/DCF type the user actually selected in the type selector.
        newPFR.RecordTypeId = component.get("v.recordtype");
        newPFR.Core_MDF_Priorities__c = component.get("v.SelPriority");
        newPFR.Core_MDF_Priority__c = component.get("v.SelPriority");
        newPFR.Core_MDF_Priority_2_nm__c = "";
        newPFR.Core_MDF_Outcome_Region_nm__c = component.get("v.SelRegion");
        newPFR.Core_MDF_Member_Acceptor_Id__c = (component.get("v.selectedExtActSubmitterOptions") || []).join(";");
        newPFR.Core_MDF_Intel_Activity_Owner_Id__c = (component.get("v.selectedApproverOptions") || [])[0];
        newPFR.Core_MDF_Country_nm__c = (component.get("v.selectedCountryOptions") || []).join(";");
        newPFR.Core_MDF_TargetAudience__c = (component.get("v.selectedTargetAudienceOptions") || []).join(";");
        newPFR.Core_MDF_ProductType__c = (component.get("v.selectedProductTypeOptions") || []).join(";");
        // newPFR.Core_MDF_Brand_nm__c = (component.get("v.selectedBrandOptions") || []).join(";");
        newPFR.Core_MDF_Channel_Partner__c = (component.get("v.selectedEcosystemPartnerOptions") || []).join(";");
        newPFR.Core_MDF_Ecosystem_Partner__c = (component.get("v.selectedEcosystemPartnerOptions") || []).join(";");
        newPFR.Core_MDF_Other_Channel_Partner__c = component.get("v.newPFR.Core_MDF_Other_Channel_Partner__c") || "";
        newPFR.Core_MDF_Initiative_nm__c = (component.get("v.selectedInitiativeOptions") || []).join(";");
        //newPFR.Core_MDF_Technology_txt__c = (component.get("v.selectedTechnologyOptions") || []).join(";");
        // newPFR.Core_MDF_Outcomes_nm__c = (component.get("v.selectedOutcomeMetricOptions") || []).join(";");
        newPFR.Core_MDF_Tactics_nm__c = (component.get("v.selectedTacticsOptions") || []).join(";");
        newPFR.Core_MDF_Measurement_Approach_nm__c = (component.get("v.selectedMeasurementApproachOptions") || []).join(";");
        newPFR.Core_MDF_Brand_nm__c =
            (component.get("v.selectedBrandOptions") || []).join(";");

        newPFR.Core_MDF_Technology_txt__c =
            (component.get("v.selectedTechnologyOptions") || []).join(";");

        newPFR.Core_MDF_Outcomes_nm__c =
            (component.get("v.selectedOutcomeMetricOptions") || []).join(";");

        newPFR.Core_MDF_Outcome_Type_nm__c =
            (component.get("v.selectedOutcomeTypeOptions") || []).join(";");

        var maxIntelContribution = parseFloat(newPFR.Core_MDF_Maximum_Intel_Investment_amt__c) || 0;
        newPFR.Core_MDF_Maximum_Intel_Investment_amt__c = maxIntelContribution;
        newPFR.Core_MDF_Activity_Reimbursement_Amt_nbr__c = maxIntelContribution;

        newPFR.BudgetId = this.isNotBlank(selectedBudget) ? selectedBudget : null;
        newPFR.Core_MDF_Budget_id__c = this.isNotBlank(selectedBudget) ? selectedBudget : null;

        newPFR.Core_MDF_Other_Brands_Technologies_txt__c =
            component.get("v.newPFR.Core_MDF_Other_Brands_Technologies_txt__c") || "";
        var ecosystemAllocations = null;
        var lwcEcosystemComp = component.find("ecosystemAllocation");
        if (lwcEcosystemComp) {
            var shouldEnforce = lwcEcosystemComp.shouldEnforceValidation();
            if (shouldEnforce && !lwcEcosystemComp.validate()) {
                self.showToast("Error", "Please complete the ecosystem partner allocation before saving.", "error");
                return;
            }
            ecosystemAllocations = lwcEcosystemComp.getEcosystemPartnerAllocations();
            if (ecosystemAllocations) {
                component.set("v.ecosystemAllocations", ecosystemAllocations);
            }
        }

        var outcomeActivityValues = [];

        var marketingPurposeComponent = null;
        var businessPurposeComponent = null;
        var marketingPurposeValid = true;
        var businessPurposeValid = true;

        // Check the exact parent selections used in the save payload.
        // Do not allow a stale child value to hide an empty parent selection.
        var hasSelection = function(values) {
            return Array.isArray(values) && values.some(function(value) {
                return value !== null &&
                    value !== undefined &&
                    String(value).trim() !== "";
            });
        };

        if (marketingMetric) {
            marketingPurposeComponent = this.getPurposeComponent(
                component,
                "marketingActivityOutcomeCmp"
            );

            // Always call the child, even when Brand/Technology are missing.
            marketingPurposeValid = !!marketingPurposeComponent &&
                marketingPurposeComponent.validate();

            if (
                !hasSelection(component.get("v.selectedMarketingBrandOptions")) ||
                !hasSelection(component.get("v.selectedMarketingTechnologyOptions"))
            ) {
                marketingPurposeValid = false;
            }
        }

        if (businessMetric) {
            businessPurposeComponent = this.getPurposeComponent(
                component,
                "businessActivityOutcomeCmp"
            );

            businessPurposeValid = !!businessPurposeComponent &&
                businessPurposeComponent.validate();

            if (
                !hasSelection(component.get("v.selectedBusinessBrandOptions")) ||
                !hasSelection(component.get("v.selectedBusinessTechnologyOptions"))
            ) {
                businessPurposeValid = false;
            }
        }

        // Return only AFTER both selected sections have been checked.
        if (!marketingPurposeValid || !businessPurposeValid) {
            var invalidSections = [];

            if (!marketingPurposeValid) {
                invalidSections.push(
                    $A.get("$Label.c.Core_MDF_Marketing_Purpose")
                );
            }

            if (!businessPurposeValid) {
                invalidSections.push(
                    $A.get("$Label.c.Core_MDF_Business_Purpose")
                );
            }

            self.showToast(
                "",
                invalidSections.join(" / ") + ": " +
                    $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage"),
                "error"
            );

            return;
        }

        if (marketingMetric) {
            var marketingOutcomeValues =
                marketingPurposeComponent.getAllActivityOutcomesDetails() || [];

            if (marketingOutcomeValues.length === 0) {
                self.showToast(
                    "",
                    $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage"),
                    "error"
                );
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

            outcomeActivityValues =
                outcomeActivityValues.concat(marketingOutcomeValues);
        }

        if (businessMetric) {
            var businessOutcomeValues =
                businessPurposeComponent.getAllActivityOutcomesDetails() || [];

            if (businessOutcomeValues.length === 0) {
                self.showToast(
                    "",
                    $A.get("$Label.c.Core_MDF_CompleteThisField_ErrorMessage"),
                    "error"
                );
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

            outcomeActivityValues =
                outcomeActivityValues.concat(businessOutcomeValues);
        }

        // Collect account node allocation data from the core_MDF_Outcome_Based_Acc_Node LWC
        var activityNodeAccValues = null;
        if (!$A.util.isEmpty(component.get("v.selectedAccount")) && this.isNotBlank(component.get("v.selectedAccount"))) {
            var lwcAccActivityComp = component.find("activityAccNode");
            if (lwcAccActivityComp) {
                var isAccNodeValid = lwcAccActivityComp.validate();
                if (!isAccNodeValid) {
                    self.showToast("Error", "Please complete all required account node allocation fields before saving.", "error");
                    return;
                }
                try {
                    var outcomeActivityAccNodeValues = lwcAccActivityComp.getAllAccountAllocationDetails();
                    var isAccountAllocationModified = lwcAccActivityComp.isAccountAllocationModified();
                    if (outcomeActivityAccNodeValues && outcomeActivityAccNodeValues.length > 0) {
                        activityNodeAccValues = JSON.parse(JSON.stringify(outcomeActivityAccNodeValues));
                        component.set("v.ActivityNodeAccValues", activityNodeAccValues);
                        if (isAccountAllocationModified && component.get("v.mode") === "edit") {
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

        component.set("v.showSpinner", true);

        var action = component.get("c.savenSendRecordId");
        action.setParams({
            pfr: newPFR,
            contentdocumentids: component.get("v.ContentDocumentIds"),
            budgetException: false,
            recType: component.get("v.recordtypeDeveloperName"),
            segmentAndProduct: component.get("v.segmentString"),
            BudId: this.isNotBlank(selectedBudget) ? selectedBudget : null,
            isPropIndicator: false,
            mdfReimbursement: null,
            tacticMetrics: tacticMetricsValues.length > 0 ? tacticMetricsValues : null,
            outcomeActivity: outcomeActivityValues.length > 0 ? outcomeActivityValues : null,
            outcomeAccountNode: this.isNotBlank(component.get("v.ActivityNodeAccValues")) ? component.get("v.ActivityNodeAccValues") : null,
            ecosystemPartner: ecosystemAllocations && ecosystemAllocations.length > 0 ? ecosystemAllocations : null
        });

        action.setCallback(this, function (response) {
            component.set("v.showSpinner", false);
            var state = response.getState();

            if (state === "SUCCESS") {
                self.showToast("Success", newPFR.Title + " was created successfully.", "success");
                if (isSaveAndNew) {
                    self.resetForSaveAndNew(component);
                } else {
                    var newRecordId = response.getReturnValue();
                    self.closeModal(component);
                    // Refresh the underlying list/detail view and open the newly created activity.
                    $A.get("e.force:refreshView").fire();
                    if (newRecordId) {
                        // Navigate to Outcome Based Details page, matching Core_MDF_CreateEditOutcomeBasedActivity behavior
                        var communityUrl = component.get("v.externalper");
                        var communityBaseUrl = $A.get("$Label.c.Core_MDF_PFRCommunityLink");
                        
                        // Use direct URL navigation to avoid error popups
                        setTimeout(function() {
                            var url = communityUrl
                                ? communityBaseUrl + 's/outcome-based-campaign-details?recordId=' + newRecordId
                                : '/lightning/n/Core_MDF_Outcome_Based_Campaign_Detail?c__recordId=' + newRecordId;
                            window.location.href = url;
                        }, 500);
                    }
                }
            } else {
                var errors = response.getError();
                var returnValue = null;
                try {
                    returnValue = response.getReturnValue();
                } catch (e) {
                    // ignore
                }

                // Detailed console logging for temporary debug
                try {
                    console.error("saveRecord failed", {
                        state: state,
                        errors: errors,
                        returnValue: returnValue,
                        rawResponse: response
                    });
                } catch (e) {
                    // no-op
                }

                this.logWarn("saveRecord:non-success", {
                    state: state,
                    errorMessages: (errors || []).map(function (e) { return e && e.message; }),
                    rawErrors: JSON.parse(JSON.stringify(errors || [])),
                    returnValue: returnValue
                });

                var message = (errors && errors[0] && errors[0].message) ? errors[0].message : (returnValue && returnValue.message) ? returnValue.message : "Failed to save the record. Please try again.";

                // Short toast for user + pointer to console for details
                self.showToast("Error", message + " (see browser console for details)", "error");
            }
        });

        $A.enqueueAction(action);
    }

})