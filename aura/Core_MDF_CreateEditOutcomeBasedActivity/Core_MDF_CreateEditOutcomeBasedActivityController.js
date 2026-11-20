({
    doInit: function(component, event, helper) {
    try {
        component.set("v.showSpinner", true);
        // Initialize basic values
        helper.initializeBasicAttributes(component);
       
        component.set("v.newPFR.Core_MDF_Is_Outcome_Based_Ind__c",true);
        //component.set("v.newPFR.Core_MDF_Proposal_Based_Ind__c", false);
        
        // Set mode based on recordId
        // Added Skip PCT Approval for clone scenario
        if(helper.isNotBlank(component.get("v.recordId")) || helper.isNotBlank(component.get("v.checkCloneRecordId"))) {
            if(component.get("v.checkCloneAttribute")) {
                component.set("v.mode", "clone");
                component.set("v.checkStatusAttribute", false);
                component.set("v.recordId", component.get("v.checkCloneRecordId"));
                component.set("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c", false);
            }else {
                component.set("v.mode", "edit");
                //helper.onRegionChange(component, event, helper)
                var selectedRegion = component.get("v.newPFR.Core_MDF_Outcome_Region_nm__c");
                component.set("v.SelRegion", selectedRegion);

                // Fetch list filtered by region using allowed list from AllCountryOptions
                helper.fetchCountriesByRegionUsingAllOptions(component, selectedRegion);
            }
           
        } else {
            component.set("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c", false);
            component.set("v.checkStatusAttribute", false);
           
        }

         helper.loadInitialData(component);
         helper.checkUserEmailForAIAccess(component);
        
    } catch(error) {
        component.set("v.showSpinner", false);
        helper.displaySuccessErrorMsg('Error initializing component: ' + error.message, 'Error', 'error','dismissible');
    }
},
handleDescriptionChange: function(component, event, helper) {
    var newValue = event.getParam("value");
    component.set("v.newPFR.Core_MDF_Activity_Description__c", newValue);
    
    // Check conditions for auto-populating focus area
    var showAISuggestions = component.get("v.showAISuggestions");
    var mode = component.get("v.mode");
    
    if (showAISuggestions && mode === '') {
        // Check current focus area and its source
        var currentFocusArea = component.get("v.selectedFocusArea");
        var detectionSource = component.get("v.focusAreaDetectionSource");
        
        // Only auto-populate if:
        // 1. No focus area is set, OR
        // 2. Current focus area is default "Client Computing" and wasn't manually set, OR
        // 3. Focus area was previously set by description (allow description updates)
        var shouldUpdate = !currentFocusArea || 
                          currentFocusArea === '' || 
                          (currentFocusArea === 'Client Computing' && detectionSource !== 'manual' && detectionSource !== 'file') ||
                          detectionSource === 'description';
        
        if (shouldUpdate) {
            // Determine focus area from description
            var detectedFocusArea = helper.determineFocusAreaFromDescription(newValue);
            
            // Validate against available options
            var validatedFocusArea = helper.validateFocusAreaOption(component, detectedFocusArea);
            
            if (validatedFocusArea) {
                // Set the focus area
                component.set("v.selectedFocusArea", validatedFocusArea);
                component.set("v.newPFR.Core_MDF_Focus_Area_nm__c", validatedFocusArea);
                
                // Mark source as description
                component.set("v.focusAreaDetectionSource", "description");
                
                // Trigger focus area change to load dependent fields
                if (!component.get("v.initialFocusAreaLoaded")) {
                    helper.clearDependentFieldSelections(component);
                } else {
                    component.set("v.initialFocusAreaLoaded", false);
                }
                
                helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
                component.set("v.showDependentFields", true);
                
                console.log('Auto-populated Focus Area from description: ' + validatedFocusArea);
            }
        } else {
            console.log('Focus Area already set from ' + detectionSource + ': ' + currentFocusArea + ', not overriding with description analysis');
        }
    }
},

handleApplySuggestions: function(component, event, helper) {
    try { 
        var eventParams = event.getParams();
        
        var suggestions, rawData, originalSuggestions, selectedFields, userInputs, analysisType, filesAnalyzed;
        var aiRequestGroupId = 'AIReq_' + new Date().getTime() + '_' + Math.random().toString(36).substr(2, 9);
        
        // When LWC fires custom event, the data is in detail property
        if (eventParams) {
            // The event.detail contains the fired event's detail
            suggestions = eventParams.detail ? eventParams.detail.suggestions : eventParams.suggestions;
            rawData = eventParams.detail ? eventParams.detail.rawData : eventParams.rawData;
            originalSuggestions = eventParams.detail ? eventParams.detail.originalSuggestions : eventParams.originalSuggestions;
            selectedFields = eventParams.detail ? eventParams.detail.selectedFields : eventParams.selectedFields;
            userInputs = eventParams.detail ? eventParams.detail.userInputs : eventParams.userInputs;
            analysisType = eventParams.detail ? eventParams.detail.analysisType : eventParams.analysisType;
            filesAnalyzed = eventParams.detail ? eventParams.detail.filesAnalyzed : eventParams.filesAnalyzed;
        }
        
        // Define clearAiAccountSelection FIRST so it can be used in other functions
        var clearAiAccountSelection = function() {
            component.set('v.selectedAccount', null);
            component.set('v.newPFR.ChannelPartnerId', null);
            component.set('v.isAccountSelected', false);
            component.set('v.showAccountSuggestion', false);
            component.set('v.aiAccountSuggestion', '');
        };

        var applyResolvedAccount = function(accountRecord) {
            if (!accountRecord || !accountRecord.Id) {
                return false;
            }
            // Clear old budget types before stamping new account
            component.set('v.budgetTypeVal', []);
            component.set('v.selBudgetType', '');
            component.set('v.selectedAccount', {
                sobjectType: 'Account',
                Id: accountRecord.Id,
                Name: accountRecord.Name,
                Core_MDF_CoMarketing_Ultimate_Account__c: accountRecord.Core_MDF_CoMarketing_Ultimate_Account__c
            });
            component.set('v.newPFR.ChannelPartnerId', accountRecord.Id);
            component.set('v.isAccountSelected', true);
            component.set('v.showAccountSuggestion', false);
            component.set('v.extractedAccountName', accountRecord.Name || '');
            component.set('v.aiAccountSuggestion', '');
            component.set("v.partnerContactDomainsLoaded", false);
            helper.loadPartnerContactDomains(component, function() {
                helper.validatePartnerContactEmails(component);
            });
            return true;
        };

        var normalizeToken = function(value) {
            return value ? String(value).toLowerCase().replace(/[^a-z0-9]/g, '') : '';
        };

        var stripRegionSuffix = function(value) {
            if (!value) return value;
            var str = String(value).toLowerCase();
            // Remove common region suffixes: " region", " regions", " area", " areas"
            return str.replace(/\s+(region|regions|area|areas)\s*$/i, '').trim();
        };

        var normalizeBudgetKey = function(value) {
            return value ? String(value).toLowerCase().replace(/[^a-z0-9]/g, '') : '';
        };

        var applyOutcomeValuesWithRetry = function(payload, retriesLeft) {
            var lwcOutcomeActivityComp = component.find('activityOutcomeCmp');
            var outcomeChildComp = lwcOutcomeActivityComp;

            if (helper.isNotBlank(lwcOutcomeActivityComp) && lwcOutcomeActivityComp.length > 0) {
                outcomeChildComp = lwcOutcomeActivityComp[0];
            }

            if (outcomeChildComp && outcomeChildComp.applyAISuggestions) {
                try {
                    outcomeChildComp.applyAISuggestions({ outcomeActivityValues: payload });
                    return;
                } catch (outcomeApplyError) {
                    console.warn('Unable to push AI outcome activity values to child component:', outcomeApplyError);
                }
            }

            if (retriesLeft > 0) {
                window.setTimeout($A.getCallback(function() {
                    applyOutcomeValuesWithRetry(payload, retriesLeft - 1);
                }), 250);
            }
        };



        var validateAndApplyAiAccount = function(accountName, suggestionsPayload) {
            if (!accountName || !String(accountName).trim()) {
                console.warn('[AI ACCOUNT] Account name is empty - clearing selection');
                clearAiAccountSelection();
                helper.displaySuccessErrorMsg('AI suggested account is empty. Account was not applied.', 'Warning', 'warning', 'dismissible');
                return;
            }

            var resolveAction = component.get('c.resolveAccountByAIName');
            resolveAction.setParams({
                accountName: String(accountName).trim(),
                recordTypeDeveloperName: component.get('v.recordtypeDeveloperName')
            });

            resolveAction.setCallback(this, function(resolveResp) {
                var resolveState = resolveResp.getState();
                if (resolveState !== 'SUCCESS') {
                    console.error('[AI ACCOUNT] Apex call failed with state: ' + resolveState);
                    clearAiAccountSelection();
                    helper.displaySuccessErrorMsg('Suggested account could not be validated. Account was not applied.', 'Warning', 'warning', 'dismissible');
                    return;
                }

                var matchedAccount = resolveResp.getReturnValue();
                if (!matchedAccount || !matchedAccount.Id) {
                    console.warn('[AI ACCOUNT] Account not found or invalid');
                    clearAiAccountSelection();
                    helper.displaySuccessErrorMsg('Suggested account could not be found. Account was not applied.', 'Warning', 'warning', 'dismissible');
                    return;
                }

                // Account is valid and IPA eligible - stamp it immediately (no budget validation gate)
                if (!applyResolvedAccount(matchedAccount)) {
                    console.error('[AI ACCOUNT] Failed to apply resolved account');
                    clearAiAccountSelection();
                    helper.displaySuccessErrorMsg('Suggested account could not be applied.', 'Warning', 'warning', 'dismissible');
                    return;
                }

                // Optionally populate budget fields (graceful - no error if empty)
                helper.fetchBudgetTypesBasedOnBenefits(component);
                helper.fetchBudgetInfo(component);
            });

            $A.enqueueAction(resolveAction);
        };
        component.set('v.aiRequestGroupId', aiRequestGroupId);
        if (suggestions) {
            // Use originalSuggestions if available, otherwise use suggestions for tracking
            var suggestionsForTracking = originalSuggestions || suggestions;
            helper.initializeAiTracking(component, suggestionsForTracking, selectedFields, userInputs, analysisType, filesAnalyzed, aiRequestGroupId);
        }
    
    if (suggestions) {
        // Apply Basic Fields
        if (suggestions.campaignName) {
            component.set("v.newPFR.Title", suggestions.campaignName);
        }
        if (suggestions.campaignDescription) {
            component.set("v.newPFR.Core_MDF_Activity_Description__c", suggestions.campaignDescription);
        }
        if (suggestions.startDate) {
            component.set("v.newPFR.Core_MDF_Start_Date__c", suggestions.startDate);
        }
        
        if (suggestions.endDate) {
            component.set("v.newPFR.Core_MDF_End_Date__c", suggestions.endDate);
        }

        if (suggestions.startDate || suggestions.endDate) {
            var aiDateAccount = component.get("v.selectedAccount");
            if (aiDateAccount && aiDateAccount.Id) {
                if (component.get("v.mode") == "" || component.get("v.mode") == 'clone' || component.get("v.mode") == 'edit') {
                    if (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) {
                        helper.checkAvailAllocationAmt(component);
                        helper.fetchBudgetInfo(component);
                    }
                }
            }
        }
        
        if (suggestions.totalInvestment) {
            component.set("v.BudgetLocal", suggestions.totalInvestment);
            component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c", suggestions.totalInvestment);
        }
        
        if (suggestions.maxIntelInvestment) {
            component.set("v.maxIntelInvestment", suggestions.maxIntelInvestment);
            component.set("v.newPFR.Core_MDF_Maximum_Intel_Investment_amt__c", suggestions.maxIntelInvestment);
        }

        var normalizeNumericValue = function(value) {
            if (value === undefined || value === null || value === '') {
                return null;
            }
            if (typeof value === 'number') {
                return value;
            }
            var cleaned = String(value).replace(/[^0-9.-]/g, '');
            var parsed = parseFloat(cleaned);
            return isNaN(parsed) ? null : parsed;
        };

        var normalizeToArray = function(value) {
            if (Array.isArray(value)) {
                return value.filter(function(item) {
                    return item !== null && item !== undefined && String(item).trim() !== '';
                });
            }
            if (typeof value === 'string') {
                return value.split(';').map(function(item) {
                    return item.trim();
                }).filter(function(item) {
                    return item !== '';
                });
            }
            return [];
        };

        // ✅ NO GATE - Apply spending amount ONLY if explicitly provided by AI
        if (suggestions.spendingAmount !== undefined && suggestions.spendingAmount !== null && suggestions.spendingAmount !== '') {
            var aiSpendingAmount = normalizeNumericValue(suggestions.spendingAmount);
            if (aiSpendingAmount !== null) {
                component.set("v.BudgetLocal", aiSpendingAmount);
                component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c", aiSpendingAmount);
            }
        }

        // ✅ NO GATE - Apply spending percentage ONLY if explicitly provided by AI
        if (suggestions.spendingPercentage !== undefined && suggestions.spendingPercentage !== null && suggestions.spendingPercentage !== '') {
            var aiSpendingPercentage = normalizeNumericValue(suggestions.spendingPercentage);
            if (aiSpendingPercentage !== null) {
                component.set("v.newPFR.Core_MDF_Reimbursement_Rate__c", aiSpendingPercentage);
                component.set("v.SelReimbursementRate", aiSpendingPercentage + '%');
            }
        }

        // Apply account suggestion when account exists and is IPA eligible.
        if (suggestions.account) {
            var accountValue = suggestions.account;
            if (typeof accountValue === 'object' && accountValue !== null) {
                var accountName = accountValue.name || accountValue.Name;

                if (accountName) {
                    validateAndApplyAiAccount(accountName, suggestions);
                } else {
                    clearAiAccountSelection();
                    helper.displaySuccessErrorMsg('AI suggested account is invalid. Account was not applied.', 'Warning', 'warning', 'dismissible');
                }
            } else if (typeof accountValue === 'string' && accountValue.trim() !== '') {
                validateAndApplyAiAccount(accountValue, suggestions);
            } else {
                clearAiAccountSelection();
                helper.displaySuccessErrorMsg('AI suggested account is invalid. Account was not applied.', 'Warning', 'warning', 'dismissible');
            }
        }
        
        // Apply Focus Area
        if (suggestions.focusArea) {
            component.set("v.selectedFocusArea", suggestions.focusArea);
            component.set("v.newPFR.Core_MDF_Focus_Area_nm__c", suggestions.focusArea);
            // Trigger focus area change to load dependent fields
            helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
            component.set("v.showDependentFields", true);
        }
        
        // Apply Priority - with resolution to available options
        if (suggestions.priority) {
            var priorityOptions = component.get('v.priorityValues') || [];
            var resolvedPriority = suggestions.priority;
            
            if (Array.isArray(priorityOptions) && priorityOptions.length > 0) {
                var normalizedInput = normalizeToken(suggestions.priority);
                var priorityMatch = priorityOptions.find(function(option) {
                    return normalizeToken(option.value) === normalizedInput || normalizeToken(option.label) === normalizedInput;
                });
                
                // If no exact match, try fuzzy matching (like tactics do)
                if (!priorityMatch) {
                    priorityMatch = priorityOptions.find(function(option) {
                        var optionValueNorm = normalizeToken(option.value);
                        var optionLabelNorm = normalizeToken(option.label);
                        return (optionValueNorm && normalizedInput.indexOf(optionValueNorm) >= 0) ||
                            (optionLabelNorm && normalizedInput.indexOf(optionLabelNorm) >= 0) ||
                            (optionValueNorm && optionValueNorm.indexOf(normalizedInput) >= 0) ||
                            (optionLabelNorm && optionLabelNorm.indexOf(normalizedInput) >= 0);
                    });
                }
                
                resolvedPriority = priorityMatch ? priorityMatch.value : suggestions.priority;
            }
            
            component.set("v.SelPriority", resolvedPriority);
            component.set("v.newPFR.Core_MDF_Priority_nm__c", resolvedPriority);
        }
        
        // Apply Region first (controlling field for Country)
        var regionApplied = false;
        if (suggestions.region) {
            var regionOptions = component.get('v.regionvalues') || [];
            var resolvedRegion = suggestions.region;
            
            if (Array.isArray(regionOptions) && regionOptions.length > 0) {
                // Strip common suffixes like "region", "regions", "area", "areas" before normalization
                var cleanedInput = stripRegionSuffix(suggestions.region);
                var normalizedInput = normalizeToken(cleanedInput);
                var regionMatch = regionOptions.find(function(option) {
                    return normalizeToken(option.value) === normalizedInput || normalizeToken(option.label) === normalizedInput;
                });
                
                // If no exact match, try fuzzy matching
                if (!regionMatch) {
                    regionMatch = regionOptions.find(function(option) {
                        var optionValueNorm = normalizeToken(option.value);
                        var optionLabelNorm = normalizeToken(option.label);
                        return (optionValueNorm && normalizedInput.indexOf(optionValueNorm) >= 0) ||
                            (optionLabelNorm && normalizedInput.indexOf(optionLabelNorm) >= 0) ||
                            (optionValueNorm && optionValueNorm.indexOf(normalizedInput) >= 0) ||
                            (optionLabelNorm && optionLabelNorm.indexOf(normalizedInput) >= 0);
                    });
                }
                
                resolvedRegion = regionMatch ? regionMatch.value : cleanedInput;
            }
            
            component.set("v.SelRegion", resolvedRegion);
            component.set("v.newPFR.Core_MDF_Outcome_Region_nm__c", resolvedRegion);
            regionApplied = true;
        }
        
        // Apply multi-value fields
        var multiValueMappings = [
            { suggestion: 'country', component: 'selectedCountryOptions', pfr: 'Core_MDF_Country_nm__c', optionsAttr: 'AllCountryOptions' },
            { suggestion: 'targetAudience', component: 'selectedTargetAudienceOptions', pfr: 'Core_MDF_TargetAudience_nm__c', optionsAttr: 'AllTargetAudienceOptions' },
            { suggestion: 'brands', component: 'selectedBrandOptions', pfr: 'Core_MDF_Brand_nm__c', optionsAttr: 'AllBrandOptions' },
            { suggestion: 'technologies', component: 'selectedTechnologyOptions', pfr: 'Core_MDF_Technology_txt__c', optionsAttr: 'AllTechnologyOptions' },
            { suggestion: 'initiatives', component: 'selectedInitiativeOptions', pfr: 'Core_MDF_Initiative_nm__c', optionsAttr: 'AllInitiativeOptions' },
            { suggestion: 'ecosystemPartners', component: 'selectedEcosystemPartnerOptions', pfr: 'Core_MDF_EcosystemPartner_nm__c', optionsAttr: 'AllEcosystemPartner' },
            { suggestion: 'productTypes', component: 'selectedProductTypeOptions', pfr: 'Core_MDF_ProductType__c', optionsAttr: 'ProductTypeValues' },
            { suggestion: 'tactics', component: 'selectedTacticsOptions', pfr: 'Core_MDF_Tactics_nm__c', optionsAttr: 'activityTacticsOptions' },
            { suggestion: 'outcomeMetrics', component: 'selectedOutcomeMetricOptions', pfr: 'Core_MDF_Outcomes_nm__c', optionsAttr: 'outcomesDependants' }
        ];

        var resolveToAvailableOptionValues = function(mapping, values) {
            if (!mapping.optionsAttr || !Array.isArray(values) || values.length === 0) {
                return values;
            }

            var options = component.get('v.' + mapping.optionsAttr) || [];
            if (!Array.isArray(options) || options.length === 0) {
                return values;
            }

            return values.map(function(value) {
                var normalizedInput = normalizeToken(value);
                var match = options.find(function(option) {
                    return normalizeToken(option.value) === normalizedInput || normalizeToken(option.label) === normalizedInput;
                });

                if (!match && mapping.suggestion === 'tactics') {
                    match = options.find(function(option) {
                        var optionValueNorm = normalizeToken(option.value);
                        var optionLabelNorm = normalizeToken(option.label);
                        return (optionValueNorm && normalizedInput.indexOf(optionValueNorm) >= 0) ||
                            (optionLabelNorm && normalizedInput.indexOf(optionLabelNorm) >= 0) ||
                            (optionValueNorm && optionValueNorm.indexOf(normalizedInput) >= 0) ||
                            (optionLabelNorm && optionLabelNorm.indexOf(normalizedInput) >= 0);
                    });
                }

                return match ? match.value : value;
            });
        };
        
        // If region was applied and country is also suggested, defer country application to let filtering complete
        var countryDeferred = regionApplied && suggestions.country && normalizeToArray(suggestions.country).length > 0;
        
        multiValueMappings.forEach(function(mapping) {
            // Skip country if it's deferred (will be applied after region filtering completes)
            if (countryDeferred && mapping.suggestion === 'country') {
                return;
            }
            
            var normalizedValues = normalizeToArray(suggestions[mapping.suggestion]);
            if (normalizedValues.length > 0) {
                normalizedValues = resolveToAvailableOptionValues(mapping, normalizedValues);
                if (mapping.suggestion === 'outcomeMetrics') {
                    // Outcome Metric allows only one selected value in this form.
                    normalizedValues = [normalizedValues[0]];
                    component.set("v.prevSelectedOutcomes", normalizedValues);
                    component.set("v.selectedOutcomes", normalizedValues);
                    component.set("v.isOutcomeSelectionInvalid", false);
                    component.set("v.showActivityPurpose", true);
                }
                component.set("v." + mapping.component, normalizedValues);
                component.set("v.newPFR." + mapping.pfr, normalizedValues.join(';'));
            }
        });

        // Apply deferred country after region filtering completes (if region was applied)
        if (countryDeferred) {
            var countryMapping = { suggestion: 'country', component: 'selectedCountryOptions', pfr: 'Core_MDF_Country_nm__c', optionsAttr: 'AllCountryOptions' };
            var countryValues = normalizeToArray(suggestions.country);
            var selectedRegion = component.get("v.SelRegion");
            
            // Call helper to filter countries by region and apply when complete
            helper.fetchCountriesByRegionWithCallback(component, selectedRegion, countryValues, countryMapping, resolveToAvailableOptionValues, normalizeToken);
        }

        // Apply tactic metric suggestions (Goal Values / Spending Amount / Spending Percentage)
        // through the existing tactic metrics payload channel used at save time.
        var tacticMetricPayload = null;
        var selectedTactics = normalizeToArray(suggestions.tactics);
        var tacticCount = selectedTactics.length;
        
        if ((suggestions.tacticMetrics && typeof suggestions.tacticMetrics === 'object') ||
            suggestions.goalValues !== undefined ||
            (suggestions.spendingAmount !== undefined || suggestions.spendingPercentage !== undefined)) {
            
            // ✅ NO DEFAULTS, NO MATH, NO AUTO-DISTRIBUTION
            // Only use what AI explicitly provided
            tacticMetricPayload = {};

            if (suggestions.tacticMetrics && typeof suggestions.tacticMetrics === 'object') {
                tacticMetricPayload = JSON.parse(JSON.stringify(suggestions.tacticMetrics));
            }

            if (suggestions.goalValues !== undefined) {
                tacticMetricPayload.goalValues = suggestions.goalValues;
            }

            // Handle spending amount - ONLY if explicitly provided, NO calculation or distribution
            if (suggestions.spendingAmount !== undefined && suggestions.spendingAmount !== null && suggestions.spendingAmount !== '') {
                var payloadSpendingAmount = normalizeNumericValue(suggestions.spendingAmount);
                if (payloadSpendingAmount !== null) {
                    component.set("v.BudgetLocal", payloadSpendingAmount);
                    component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c", payloadSpendingAmount);
                }
            }

            // Handle spending percentage - ONLY if explicitly provided, NO calculation
            if (suggestions.spendingPercentage !== undefined && suggestions.spendingPercentage !== null && suggestions.spendingPercentage !== '') {
                var payloadSpendingPercentage = normalizeNumericValue(suggestions.spendingPercentage);
                if (payloadSpendingPercentage !== null) {
                    tacticMetricPayload.spendingPercentage = payloadSpendingPercentage;
                    component.set("v.newPFR.Core_MDF_Reimbursement_Rate__c", payloadSpendingPercentage);
                    component.set("v.SelReimbursementRate", payloadSpendingPercentage + '%');
                }
            }
            
            // Validate total spending doesn't exceed maxIntelInvestment
            if (suggestions.maxIntelInvestment) {
                var maxIntel = normalizeNumericValue(suggestions.maxIntelInvestment);
                if (maxIntel !== null && suggestions.spendingAmount) {
                    var totalSpending = normalizeNumericValue(suggestions.spendingAmount);
                    if (totalSpending > maxIntel) {
                        console.warn('[TACTIC METRICS] Info: Total spending ($' + totalSpending + ') is greater than max Intel investment ($' + maxIntel + '); tactic rows use Intel contribution allocation.');
                    }
                }
            }

            tacticMetricPayload.hasSuggestedTactics = true;

            if (Object.keys(tacticMetricPayload).length === 0) {
                tacticMetricPayload = null;
            }
        }
        
        if (tacticMetricPayload) {
            component.set("v.tacticMetricsValues", tacticMetricPayload);
            var lwcTacticMetricsComp = component.find("tacticMetrics");
            if (lwcTacticMetricsComp != null) {
                try {
                    // Ensure tactic metric rows exist before applying payload values.
                    // selectedTactics already populated above - reuse it

                    // If tactics are not explicitly selected but AI provided tactic metric keys,
                    // derive tactics from payload so goal values can map to rows.
                    if (selectedTactics.length === 0 && tacticMetricPayload && typeof tacticMetricPayload === 'object') {
                        var reservedTacticKeys = {
                            spendingAmount: true,
                            spendingPercentage: true,
                            goalValues: true,
                            tacticMetrics: true,
                            goalValue: true,
                            firstKpiValue: true,
                            hasSuggestedTactics: true
                        };

                        Object.keys(tacticMetricPayload).forEach(function(key) {
                            if (!reservedTacticKeys[key]) {
                                selectedTactics.push(key);
                            }
                        });

                        if (selectedTactics.length === 0 && tacticMetricPayload.goalValues && typeof tacticMetricPayload.goalValues === 'object') {
                            Object.keys(tacticMetricPayload.goalValues).forEach(function(key) {
                                if (key !== 'goalValue') {
                                    selectedTactics.push(key);
                                }
                            });
                        }
                    }

                    selectedTactics = selectedTactics.filter(function(value, index, self) {
                        return value && self.indexOf(value) === index;
                    });

                    tacticMetricPayload.hasSuggestedTactics = selectedTactics.length > 0;

                    if (selectedTactics.length === 0) {
                        return;
                    }

                    if (selectedTactics.length > 0) {
                        component.set("v.selectedTacticsOptions", selectedTactics);
                        component.set("v.newPFR.Core_MDF_Tactics_nm__c", selectedTactics.join(';'));
                    }

                    var childComp = lwcTacticMetricsComp;
                    if (helper.isNotBlank(lwcTacticMetricsComp[0])) {
                        childComp = lwcTacticMetricsComp[0];
                    }

                    if (childComp.handleTacticChange && selectedTactics.length > 0) {
                        childComp.handleTacticChange({ selectedTactics: selectedTactics });
                    }

                    window.setTimeout($A.getCallback(function() {
                        try {
                            if (childComp.applyAISuggestions) {
                                childComp.applyAISuggestions({ tacticMetrics: tacticMetricPayload });
                            } else if (childComp.applyAiSuggestions) {
                                childComp.applyAiSuggestions({ tacticMetrics: tacticMetricPayload });
                            } else if (childComp.setTacticMetricsValues) {
                                childComp.setTacticMetricsValues(tacticMetricPayload);
                            }
                        } catch (deferredApplyError) {
                            console.warn('Deferred AI tactic metrics apply failed:', deferredApplyError);
                        }
                    }), 0);
                } catch (tacticMetricsError) {
                    console.warn('Unable to push AI tactic metrics to child component:', tacticMetricsError);
                }
            }
        }

        // Ensure outcome section is available before stamping outcome values.
        var outcomePayload = null;
        if (suggestions.outcomeActivityValues && typeof suggestions.outcomeActivityValues === 'object') {
            outcomePayload = JSON.parse(JSON.stringify(suggestions.outcomeActivityValues));
        } else if (suggestions.outcomeMetrics) {
            var metricCandidates = normalizeToArray(suggestions.outcomeMetrics);
            if (metricCandidates.length > 0) {
                outcomePayload = {
                    outcomeMetric: metricCandidates[0]
                };
            }
        }

        if (outcomePayload && typeof outcomePayload === 'object') {
            component.set('v.showActivityPurpose', true);
            if (!outcomePayload.outcomeMetric && suggestions.outcomeMetrics) {
                var fallbackMetrics = normalizeToArray(suggestions.outcomeMetrics);
                if (fallbackMetrics.length > 0) {
                    outcomePayload.outcomeMetric = fallbackMetrics[0];
                }
            }

            var outcomeMetricFromValues = outcomePayload.outcomeMetric;
            if (outcomeMetricFromValues) {
                var resolvedOutcomeMetric = resolveToAvailableOptionValues({ optionsAttr: 'outcomesDependants' }, [outcomeMetricFromValues]);
                if (resolvedOutcomeMetric && resolvedOutcomeMetric.length > 0) {
                    component.set('v.prevSelectedOutcomes', resolvedOutcomeMetric);
                    component.set('v.selectedOutcomes', resolvedOutcomeMetric);
                    component.set('v.selectedOutcomeMetricOptions', resolvedOutcomeMetric);
                    component.set('v.newPFR.Core_MDF_Outcomes_nm__c', resolvedOutcomeMetric.join(';'));
                    component.set('v.isOutcomeSelectionInvalid', false);
                    component.set('v.showActivityPurpose', true);
                } else {
                    // Keep single-metric flow alive even when dependent options are still loading.
                    component.set('v.prevSelectedOutcomes', [outcomeMetricFromValues]);
                    component.set('v.selectedOutcomes', [outcomeMetricFromValues]);
                    component.set('v.selectedOutcomeMetricOptions', [outcomeMetricFromValues]);
                    component.set('v.newPFR.Core_MDF_Outcomes_nm__c', outcomeMetricFromValues);
                    component.set('v.isOutcomeSelectionInvalid', false);
                    component.set('v.showActivityPurpose', true);
                }
            }

            applyOutcomeValuesWithRetry(outcomePayload, 20);
            window.setTimeout($A.getCallback(function() {
                applyOutcomeValuesWithRetry(outcomePayload, 8);
            }), 900);
        }

       if (rawData) {
           component.set("v.newPFR.Core_MDF_AI_File_Data__c", rawData);
       }
    }
    } catch (applyError) {
       console.error('Error while applying AI suggestions:', applyError);
    }
},

focusAreaChange: function(component, event, helper){
    var selectedFocusArea = component.get("v.selectedFocusArea");
    
    if(helper.isNotBlank(selectedFocusArea)) {
        component.set("v.showSpinner", true);
        if(!component.get("v.initialFocusAreaLoaded")){
            helper.clearDependentFieldSelections(component);
        }else{
            component.set("v.initialFocusAreaLoaded", false);
        }
        
        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
            
        component.set("v.showSpinner", false);
        component.set("v.showDependentFields", true);
       
    }
},

//method called on change of Total Investment
calculateBudgetAmount: function(component, event, helper) {
    var budgetAmount = parseFloat(event.getSource().get("v.value")) || 0;
    var maxIntelContribution = parseFloat(component.get("v.maxIntelInvestment")) || 0;

    component.set("v.showErrorMsgForSpendingLimit", false);
    component.set("v.ErrorMsgForSpendingLimit", "");

    // Validate budget amount - must be at least $1 with no decimal points
    if (budgetAmount < 1) {
        component.set("v.showErrorMsgForSpendingLimit", true);
        component.set("v.ErrorMsgForSpendingLimit", $A.get("$Label.c.Core_MDF_TotalInvestment_grtthanzero_Error"));
    } else {
        // Clear error messages if validation passes
        component.set("v.showErrorMsgForSpendingLimit", false);
        component.set("v.ErrorMsgForSpendingLimit", "");
    }
    
    maxIntelContribution = component.get("v.maxIntelInvestment");
    
    if (maxIntelContribution!=null && budgetAmount >= maxIntelContribution && budgetAmount > 0) {
        component.set("v.showErrorMsgForMaxIntelInvest", false);
    } 
    else if (maxIntelContribution > budgetAmount && budgetAmount > 0) {
        component.set("v.showErrorMsgForMaxIntelInvest", true);
        component.set("v.ErrorMsgForMaxIntelInvest", $A.get("$Label.c.Core_MDF_MaxIntelInvest_Exceed_Error"));
    } 

    component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c", budgetAmount);
    component.set("v.BudgetLocal", budgetAmount);

    // Recalculate reimbursement rate based on new budget amount
    helper.calculateReimbursementRate(component, budgetAmount, maxIntelContribution,false);
},

//method called on change of Maximum Intel Investment
calculateMaxIntelInvestment: function(component, event, helper) {
    var maxIntelContribution = parseFloat(event.getSource().get("v.value")) || 0;
    
    var budgetAmount = parseFloat(component.get("v.BudgetLocal")) 
                    || parseFloat(component.get("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c")) || 0;

    // Check for decimal places in the input value
    var decimalPlaces = (maxIntelContribution.toString().split('.')[1] || []).length;
    
    // Reset error message visibility and content
    component.set("v.showErrorMsgForMaxIntelInvest", false);
    component.set("v.ErrorMsgForMaxIntelInvest", "");
    
    // Validate minimum amount and decimal places - must be at least $1 with no decimal points
    if (maxIntelContribution < 1 || decimalPlaces > 0) {
        component.set("v.showErrorMsgForMaxIntelInvest", true);
        component.set("v.ErrorMsgForMaxIntelInvest", $A.get("$Label.c.Core_MDF_MaxIntelInvest_grtthanzero_Error"));
        
    } 
    // Validate that maximum Intel investment doesn't exceed total budget amount
    else if (maxIntelContribution > budgetAmount && budgetAmount > 0) {
        component.set("v.showErrorMsgForMaxIntelInvest", true);
        component.set("v.ErrorMsgForMaxIntelInvest", $A.get("$Label.c.Core_MDF_MaxIntelInvest_Exceed_Error"));
    } 
    else {
        // Clear error messages if all validations pass
        component.set("v.showErrorMsgForMaxIntelInvest", false);
        component.set("v.ErrorMsgForMaxIntelInvest", "");
    }

    component.set("v.maxIntelInvestment", maxIntelContribution);
    component.set("v.newPFR.Core_MDF_Activity_Reimbursement_Amt_nbr__c", maxIntelContribution);

    // Recalculate reimbursement rate based on new maximum Intel investment
    helper.calculateReimbursementRate(component, budgetAmount, maxIntelContribution,true);
},


    hidePopup: function(component, event){
        var EventData = event.getParam("ButtonClick");
        var popupType = event.getParam("popupName");
        
        if(popupType == 'Event'){
            component.set("v.PopupButtonValue", EventData);
            component.set("v.PopupType", null);
        } else {
            component.set("v.ELCPopupButtonValue", EventData);
        }
        
        component.set("v.ShowEventPopup", false);
        
        if (EventData == false){
            component.set("v.PopupType", null);
            component.set("v.recordApplicableForActivityRules", true);
            component.set("v.goForSave", false);
        } else if(EventData == true){
            if(popupType == 'Event'){
                
                if(component.get("v.SelCategory") != $A.get("$Label.c.Core_MDF_Outcome_Based_CatType")){
                    component.set("v.EventMessage", $A.get("$Label.c.Core_MDF_Terms"));
                } else {
                    component.set("v.EventMessage", $A.get("$Label.c.core_mdf_terms_tactics_ELC_popup"));
                }
                component.set("v.AgreeButtonLabel", $A.get("$Label.c.Core_MDF_I_Understand"));            
                component.set("v.DisagreeButtonLabel", $A.get("$Label.c.Core_MDF_CancelOption"));
                component.set("v.PopupType", "ELC");
                component.set("v.ShowEventPopup", true);
            } else if(popupType == 'ELC'){
                component.set("v.ShowEventPopup", false);
            }     
        }
    },

uploadfile: function(component, event, helper) {
    // Existing logic
    component.set("v.ContentDocumentIds", event.getParam("uploadFilesIds"));
    component.set("v.Uploadfinished", event.getParam("fileUploaded"));
    if (event.getParam("fileUploaded")) {
        component.set("v.message", "");
        component.set("v.messageType", "");
        component.set("v.ChgndAttach", true);  
        
        // NEW: Focus area detection logic
        var showAISuggestions = component.get("v.showAISuggestions");
        var mode = component.get("v.mode");
        
        if (showAISuggestions && mode === '') {
            var uploadedFiles = event.getParam("uploadFilesIds");
            if (uploadedFiles && uploadedFiles.length > 0) {
                helper.detectFocusAreaFromUploadedFile(component, uploadedFiles);
            }
        }
    }
},
getSmartAISuggestions: function(component, event, helper) {
    var description = component.get("v.newPFR.Core_MDF_Activity_Description__c");
    var uploadedIds = component.get("v.ContentDocumentIds");
    var recordTypeDeveloperName = 'Core_MDF_Intel_Partner_Alliance_Account_Based';
    
    // Determine what to analyze
    var hasDescription = description && description.trim() !== '';
    var hasFiles = uploadedIds && uploadedIds.length > 0;
    
    if (!hasDescription && !hasFiles) {
        helper.displaySuccessErrorMsg('Please enter a description or upload files before getting AI suggestions', 'Warning', 'warning', 'dismissible');
        return;
    }
    component.set("v.isLoadingAI", true);
    
    // Call the smart analysis helper method
    helper.performSmartAIAnalysis(component, description, uploadedIds, recordTypeDeveloperName);
},

    closeModalClosedActivtiy: function (component, event, helper) {
        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
            var homeEvent = $A.get("e.force:navigateToSObject");
            homeEvent.setParams({
                recordId: component.get("v.selectedLookUpRecord.Id"),
                slideDevName: "detail"
            });
            homeEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
        } else {
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                scope: "PartnerFundRequest"
            });
            homeEvent.fire();
        }
    },

	// Function called on click of Cancel or "X" on the layout 
    closeModal: function(component, event, helper) {
        if((component.get("v.mode") == 'clone' || component.get("v.mode") == 'edit')){
        	var homeEvent = $A.get("e.force:navigateToSObject");
            homeEvent.setParams({
                recordId: component.get("v.recordId"),
                slideDevName: "detail"
            });
            homeEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
        }else{
           var homeEvent = $A.get("e.force:navigateToObjectHome");
                homeEvent.setParams({
                    scope: "PartnerFundRequest"
                });
                homeEvent.fire();
                $A.get("e.force:closeQuickAction").fire(); 
        }  
         $A.get('e.force:refreshView').fire(); 
    },    
    setCtryResetCPLed: function(component, event, helper) {
        var selctryLst = component.get("v.selectedCountryOptions");
        var ctryOpts = "";
        for(var i=0; i<selctryLst.length; i++ ){
            if(i!=selctryLst.length-1)
                ctryOpts+=selctryLst[i]+";";
            else
                ctryOpts+=selctryLst[i];            
        }  
        
        //component.set("v.SelMarketValue",ctryOpts);
        component.set("v.newPFR.Core_MDF_Country_nm__c",ctryOpts);
    },

    
   onTacticsChange:function(component, event, helper){
        var selectedTactics = event.getParam('value');
        var selectedTacticsOptions = "";
        if(!$A.util.isEmpty(selectedTactics) && selectedTactics != undefined){
                for(var i=0; i<selectedTactics.length; i++ ){
                    if(i!=selectedTactics.length-1)
                        selectedTacticsOptions+=selectedTactics[i]+";";
                    else 
                    selectedTacticsOptions+=selectedTactics[i];            
                }
        }
        if(!$A.util.isEmpty(selectedTacticsOptions) && selectedTacticsOptions != undefined){
           
            component.set("v.newPFR.Core_MDF_Tactics_nm__c", selectedTacticsOptions);
            
            // Skip PCT Approval-Check if "Incentive" is selected in tactics to show PCT Approval checkbox
            var showPCTCheckbox = selectedTacticsOptions.includes('Incentive');
            component.set("v.showPCTApprovalCheckbox", showPCTCheckbox);
            //Reset the checkbox value when Incentive is not selected and Ensure boolean value, not undefined/null
            if (!showPCTCheckbox) {
                    component.set("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c", false);
            }
            else if (component.get("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c") === undefined || 
                     component.get("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c") === null) {
                component.set("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c", false);
            }
            
            var marketingTactics = $A.get("$Label.c.Core_MDF_Marketing_Act_Tactis").split(',');
            for(var index=0;index<marketingTactics.length;index++){
                if(selectedTacticsOptions.includes(marketingTactics[index])){
                    component.set("v.selActivityClassification",'Marketing');
                    break;
                }else{
                    component.set("v.selActivityClassification",'Sales');
                }
            
            }
        } 
       // Skip PCT Approval-Hide checkbox when no tactics selected
       else {
            component.set("v.showPCTApprovalCheckbox", false);
                component.set("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c", false);
        } 
        helper.checkSPIFActSecVisible(component);

        if(!$A.util.isEmpty(selectedTacticsOptions) && selectedTacticsOptions != undefined) {
            var lwcTacticMetricsComp = component.find("tacticMetrics");        
            var tacticMetricsValues;var isTacticMetricsModified;
            if (lwcTacticMetricsComp != null) {
                if(helper.isNotBlank(lwcTacticMetricsComp[0])){
                    tacticMetricsValues = lwcTacticMetricsComp[0].handleTacticChange({selectedTactics: component.get("v.selectedTacticsOptions")});
                }else{
                    tacticMetricsValues = lwcTacticMetricsComp.handleTacticChange({selectedTactics: component.get("v.selectedTacticsOptions")});
                }
               
            }
            
        }
   },
    // Anjali changes - Handler for Measurement Approach multi-select changes - converts to semicolon-separated string and manages conditional field visibility
    onMeasurementApproachChange: function(component, event, helper) {
        var selectedMeasurementApproach = event.getParam('value');
        var selectedMeasurementApproachOptions = "";
        if(!$A.util.isEmpty(selectedMeasurementApproach) && selectedMeasurementApproach != undefined){
                for(var i=0; i<selectedMeasurementApproach.length; i++ ){
                    if(i!=selectedMeasurementApproach.length-1)
                        selectedMeasurementApproachOptions+=selectedMeasurementApproach[i]+";";
                    else 
                    selectedMeasurementApproachOptions+=selectedMeasurementApproach[i];            
                }
        }
        if(!$A.util.isEmpty(selectedMeasurementApproachOptions) && selectedMeasurementApproachOptions != undefined){
            component.set("v.newPFR.Core_MDF_Measurement_Approach_nm__c", selectedMeasurementApproachOptions);
            
            // Anjali changes - Check if "Other (Specify)" is selected to show/hide the Other Measurement Approach text field
            var showOtherField = selectedMeasurementApproachOptions.includes('Other (Specify)');
            component.set("v.showOtherMeasurementApproachField", showOtherField);
            
            // Anjali changes - Clear the Other Measurement Approach field if "Other (Specify)" is not selected
            if (!showOtherField) {
                component.set("v.newPFR.Core_MDF_Other_Measurement_Approach_txt__c", "");
            }
        } else {
            component.set("v.showOtherMeasurementApproachField", false);
            component.set("v.newPFR.Core_MDF_Other_Measurement_Approach_txt__c", "");
        }
    },
    // Anjali changes - Handler for Focus Area change - re-fetches all dependent picklists (Brand, Audience, Initiative, Product Type, Technology, Measurement Approach)
    handleFocusAreaChange: function(component, event, helper) {
        // Re-fetch all dependent picklists when Focus Area changes
        if(component.get("v.measurementApproachPicklistValues")) {
            helper.fetchMultiMeasurementApproach(component);
        }
        if(component.get("v.MultiBrandTypes")) {
            helper.fetchMultiBrandType(component);
        }
        if(component.get("v.audiencePicklistValues")) {
            helper.fetchMultiTargetAudience(component);
        }
        if(component.get("v.initiativePicklistValues")) {
            helper.fetchMultiInitiative(component);
        }
        if(component.get("v.ProductTypes")) {
            helper.fetchProdType(component);
        }
        if(component.get("v.technologies")) {
            helper.fetchTechnologies(component);
        }
       if( !$A.util.isEmpty(component.get("v.selectedTacticsOptions"))){
           if(helper.checkEventTactics(component)==false){
                component.set("v.renderPrintQuestion", false);
                component.set("v.renderGovtQuestion", false);
                component.set("v.renderTechExplorationQuestSection", false);
            }
         }
        
    },
    
    // Skip PCT Approval-NEW METHOD - Handle PCT Approval checkbox changes
    handlePCTApprovalChange: function(component, event, helper) {
        var isChecked = event.getSource().get("v.checked");
        // Ensure it's a proper boolean value
        component.set("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c", Boolean(isChecked));
    },

    handleEmailValidation: function(component, event, helper) {
        if (!component.get("v.partnerContactDomainsLoaded")) {
            helper.loadPartnerContactDomains(component, function() {
                helper.validatePartnerContactEmails(component);
            });
            return;
        }

        helper.validatePartnerContactEmails(component);
    },

    handleEmailKeyup: function(component, event, helper) {
        var partnerContactValue = component.get("v.newPFR.Core_MDF_Partner_Contact_txt__c");

        if (!partnerContactValue || !String(partnerContactValue).trim()) {
            helper.resetPartnerContactValidation(component);
            return;
        }

        if (!component.get("v.partnerContactDomainsLoaded")) {
            helper.loadPartnerContactDomains(component, function() {
                helper.validatePartnerContactEmails(component);
            });
            return;
        }

        helper.validatePartnerContactEmails(component);
    },
	
   //Function called on change of Start Date
    createAdditionalfilter: function(component, event, helper) {
        helper.resetHelper(component);
        var checkStartDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
	
    if(checkStartDate) {
        var minDateString = $A.get("$Label.c.Core_MDF_IPA_AccountBased_StartDate");
        var minDate = new Date(minDateString);
        var selectedStartDate = new Date(checkStartDate);
        
        if(selectedStartDate < minDate) {
            // Show error using label
            helper.displaySuccessErrorMsg(
                $A.get("$Label.c.Core_MDF_Activity_Outcome_Startdate_Error"),
                "Error",
                "error",
                "sticky"
            );
            
            // Clear the invalid date
            component.set("v.newPFR.Core_MDF_Start_Date__c", null);
            
            return;
        }
    }
       
        
        // Only fetch budget if account is also selected
        var selectedAccount = component.get("v.selectedAccount");
        if(selectedAccount && selectedAccount.Id) {
            if (component.get("v.mode") == "" || component.get("v.mode") == 'clone' || component.get("v.mode") == 'edit'){
                if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) {
		            helper.checkAvailAllocationAmt(component);
                    helper.fetchBudgetInfo(component);
                }
            }
        } 
        
        component.set("v.startDate", component.get("v.newPFR.Core_MDF_Start_Date__c"));
    },

   

    //Function called on change of End Date
    createNewAdditionalfilter: function(component, event, helper) {
        var checkEndDate = component.get("v.newPFR.Core_MDF_End_Date__c");
        helper.resetHelper(component);
        
        // Only fetch budget if account is also selected
        var selectedAccount = component.get("v.selectedAccount");
        if(selectedAccount && selectedAccount.Id) {
            if (component.get("v.mode") == "" || component.get("v.mode") == 'clone' || component.get("v.mode") == 'edit'){
                if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) {
                    helper.fetchBudgetInfo(component);
                }
            }
        } 
        component.set("v.endDate", component.get("v.newPFR.Core_MDF_End_Date__c"));
    },

   saveBudget: function(component,event,helper){
        helper.checkAvailAllocationAmt(component);
        
    },

    customSave : function(component, event, helper) {
          
        var buttonClicked = event.getSource().getLocalId();
                
		if(buttonClicked == "SaveandNew"){
            component.set("v.isSaveandNew",true);
        }
        else{
            component.set("v.isSaveandNew",false);
        }
       
        //check for Event Popup and File upload
        //Component required validation
        var validData = component.find('NewForm').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if(!helper.validatePriorityFieldsImmediate(component)){
            validData = false; 
        }
        var localmsg = "";
		var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        /*if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")
          && (component.get("v.mode") != 'clone' && !component.get("v.externalper")) ){
            var Actreim=component.get("v.SelReimbursementRate");
            
            if(helper.isNotBlank(Actreim)){
             component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",component.get("v.SelReimbursementRate"));
            }
            
            
        }*/
        
		
        var isExternal = component.get("v.externalper");
        var isInternal = component.get("v.accmgrper");
        var budType = component.get("v.selBudgetType");
        var intelContri = component.get("v.maxIntelInvestment");
        var selectedCountry = component.get("v.selectedCountryOptions");
        var actStatus = component.get("v.CurrentStatus");
		var partnerContactValueForValidation = component.get("v.newPFR.Core_MDF_Partner_Contact_txt__c");
		var selectedPartnerContactAccount = component.get("v.selectedAccount");
		var partnerContactAccountId = selectedPartnerContactAccount && selectedPartnerContactAccount.Id ? selectedPartnerContactAccount.Id : component.get("v.newPFR.ChannelPartnerId");
		
		if(component.get("v.showErrorMsgForMaxIntelInvest")){
            validData = false; 
            localmsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
        }
        if(component.get("v.showErrorMsgForSpendingLimit")){
            validData = false; 
            localmsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
        }
        if(!helper.isNotBlank(component.get("v.BudgetLocal"))){
            validData = false; 
            localmsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
        }

        if(component.get("v.isOutcomeSelectionInvalid")){
            validData = false;
            localmsg = $A.get("$Label.c.Core_MDF_Campaign_Outcome_Validation");
        }

        var budgetAmount = parseFloat(component.get("v.BudgetLocal")) || 0;
        var maxIntelInvestment = parseFloat(component.get("v.maxIntelInvestment")) || 0;
    
        // Final validation before save
        if (maxIntelInvestment > budgetAmount && budgetAmount > 0) {
        component.set("v.showErrorMsgForMaxIntel", true);
        component.set("v.ErrorMsgForMaxIntel", "Maximum Intel Investment should not exceed Total Investment amount.");
        validData = false;
        localmsg = "Maximum Intel Investment should not exceed Total Investment amount.";
        }
        	 
        //Initiative None selection error
        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && helper.isNotBlank(component.get("v.newPFR.Core_MDF_Initiative_nm__c"))){
            var splitInitiative = [];
            splitInitiative = component.get("v.newPFR.Core_MDF_Initiative_nm__c").split(';');
            if(helper.isNotBlank(splitInitiative)){
                if(splitInitiative.includes('None') && splitInitiative.length>1){
                    localmsg = localmsg + $A.get("$Label.c.Core_MDF_Initiative_None_Selection_Error") + '\n';
                    validData = false;
                }
            }
        }
			 
        
		var todaysDate = helper.getTodayDateLocalTime();
        var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var oldStartDate = component.get("v.oldPFR.Core_MDF_Start_Date__c");
        var pfrStatus = component.get("v.newPFR.Core_MDF_Fund_Request_Status__c");
        var endDate = component.get("v.newPFR.Core_MDF_End_Date__c");
        var budgetType = component.get("v.selBudgetType");
        var mode = component.get("v.mode");
        var diffDate = Date.parse(startDate) - Date.parse(todaysDate);
        var dateDifference = diffDate/(3600*24*1000) ;
        
        
       if( mode == '' || mode == 'clone'){
        /*if(component.get("v.externalper") && component.get("v.SelCategory") == "Event" 
           &&  dateDifference < $A.get("$Label.c.Core_MDF_60DaysMoreThan_50K") && component.get("v.IPAIntelContri") >= $A.get("$Label.c.Core_MDF_ManagerApprovalThreshold")) {
            var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Event_60_Days");                                
            helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
            validData = false;
           }
        } */
		}
        
    	var recordTypeName = component.get("v.recordtypeDeveloperName");
        var proposalBasedCamp = component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c");
        
        //Throw error when Focus Area field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedFocusArea")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Focus_Area_Error_Msg_OutcomeBased") + '\n';
        }

        //Throw error when 
        
        
        //Throw error when Target Audience field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedTargetAudienceOptions")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_TargetAudienceError_OutcomeBased") + '\n';
        }
        
        //Throw error when Ecosystem Partner field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedEcosystemPartnerOptions")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_EcosystemPartner_ReqError_OB") + '\n';
        }

        //Throw error when Initiative field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedInitiativeOptions")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Initiative_Error_Msg_OutcomeBased") + '\n';
        }

        //Throw error when Brand field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedBrandOptions")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_BrandError_OutcomeBased") + '\n';
        }

        //Throw error when Technology field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedTechnologyOptions")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Error_Message_for_Technology") + '\n';
        }

        //Throw error when Product Type field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedProductTypeOptions")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_ProductTypeError_OutcomeBased") + '\n';
        }

        //Throw error when Outcome Metric field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedOutcomeMetricOptions")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Error_Message_for_Outcomes") + '\n';
        }

        //Throw error when Tactic field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedTacticsOptions")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Activity_Tactics_Error_OutcomeBased") + '\n';
        }

        // Anjali changes - Throw error when Measurement Approach field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedMeasurementApproachOptions")) ){
            validData = false;
			localmsg = localmsg + $A.get("$Label.c.Core_MDF_Measurement_Approach_error") + '\n';
        }

        // Anjali changes - Throw error when "Other (Specify)" is selected but Other Measurement Approach field is empty
        var measurementApproachValue = component.get("v.newPFR.Core_MDF_Measurement_Approach_nm__c");
        var otherMeasurementApproachValue = component.get("v.newPFR.Core_MDF_Other_Measurement_Approach_txt__c");
        
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && 
           !$A.util.isEmpty(measurementApproachValue) && 
           measurementApproachValue.includes('Other (Specify)') && 
           $A.util.isEmpty(otherMeasurementApproachValue)) {
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Empty_Field_Error") + '\n';
        }

        if (partnerContactValueForValidation && String(partnerContactValueForValidation).trim() && partnerContactAccountId && !component.get("v.partnerContactDomainsLoaded")) {
            helper.loadPartnerContactDomains(component, function() {
                helper.validatePartnerContactEmails(component);
            });
            return;
        }

        if(!helper.validatePartnerContactEmails(component)){
            validData = false;
            localmsg = localmsg + component.get("v.partnerContactErrorMsg") + '\n';
        }

        
	   
	   
	   
        
        //Removing the status value in clone condition
        if(component.get("v.SelectedStatus") != "" && component.get("v.checkCloneAttribute")){
            component.set("v.SelectedStatus","");
        }
        
		//Error for 'Budget Amount'
        var budgetAmount = component.find("BudgetAmount");
        var actSpendingAmount= component.get("v.BudgetLocal");
        
		//Error if not Acc mgr or Submitter 
        if(component.get("v.userWithoutAccess") && !((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType"))
              && helper.isCurrentUsrIsApprover(component)) && !component.get("v.priceReviewersPer") && !component.get("v.ipaL2Approver")){
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_CloneAccessError") + '\n';
            validData = false;
        }
        
        if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") ){
            if ($A.util.isEmpty(component.get("v.newPFR.Title")) ||
                $A.util.isEmpty(component.get("v.newPFR.Core_MDF_Activity_Description__c")) || 
                $A.util.isEmpty(component.get("v.newPFR.Core_MDF_Start_Date__c")) ||
                $A.util.isEmpty(component.get("v.newPFR.Core_MDF_End_Date__c")) ){ 
                    	
                var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");                                  
                helper.displaySuccessErrorMsg(alertMsg,"Error!","error","dismissible"); // call common method to display error
                validData = false;
            }
        } 
		
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var oldstdate = component.get("v.oldsdate");
        var stdate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var oldstatus = component.get("v.oldstatus");
        var accmgrper = component.get("v.accmgrper");
        var edate = component.get("v.newPFR.Core_MDF_End_Date__c");
        var oldedate = component.get("v.oldedate");
		
        if ((helper.isNotBlank(stdate) && helper.isNotBlank(oldstdate) && stdate>oldstdate) && accmgrper && oldstatus == 'In-Progress'  && !component.get("v.checkCloneAttribute"))
        {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Acc_Mgr_Date_Mod_Error") + '\n';
            validData = false;
        }
		
        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && component.get("v.isPropBasedCampaign") == false
		&& (component.get("v.selAvailableBudget") == null  || component.get("v.selAvailableBudget") == undefined || component.get("v.selAvailableBudget") ==""))
		{
			validData = false;
			localmsg = localmsg + $A.get("$Label.c.Core_MDF_AvailableBudget_ErrMsg") + '\n';            
		}
        
		var activityAmount = component.get("v.maxIntelInvestment");
		//Condition to save SPIF/Incentive segment on save of activity
        if(helper.checkSPIFTactics(component)) {
            var lwcSegmentcomp = component.find("segmentComp");        
            var segmentValues;var isSegmentModified;var spifAmount;
            if (lwcSegmentcomp != null) {
                if(helper.isNotBlank(lwcSegmentcomp[0])){
                    segmentValues = lwcSegmentcomp[0].getSegmentValues();
                    isSegmentModified = lwcSegmentcomp[0].isSegmentModified();
                    spifAmount = lwcSegmentcomp[0].fetchSPIFAmount();
                }else{
                    segmentValues = lwcSegmentcomp.getSegmentValues();
                    isSegmentModified = lwcSegmentcomp.isSegmentModified();
                    spifAmount = lwcSegmentcomp.fetchSPIFAmount();
                }
                component.set("v.segmentString",'');
                if(segmentValues.length == 0) {
                   if(lwcSegmentcomp){
                       if(lwcSegmentcomp[0] != undefined){
		              lwcSegmentcomp[0].isFormValid();
                    }
                       else{
		              lwcSegmentcomp.isFormValid();
                   }
                   }
                   validData = false;
		           component.set("v.newPFR.Core_MDF_SPIF_Segments_Available_ind__c",false);
                   var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
                   helper.displaySuccessErrorMsg(alertMsg,"Error!","error","dismissible");
                }
                else if(activityAmount < spifAmount){
                    validData = false;
                    var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
                    helper.displaySuccessErrorMsg(alertMsg,"Error!","error","dismissible");
                }
				else { 
                      if (helper.isNotBlank(segmentValues)) {                     
                          var segmentListStr = JSON.stringify(segmentValues);
                          component.set("v.segmentString", segmentListStr);
						  component.set("v.newPFR.Core_MDF_SPIF_Segments_Available_ind__c",true);
						  component.set("v.isSPIFSecModified",isSegmentModified);
                          if(component.get("v.isSPIFSecModified") && component.get("v.mode") == 'edit'){ 
                            component.set("v.newPFR.Core_MDF_SPIF_Modified_ind__c",true);
                          }
                          if(component.get("v.checkCloneAttribute")){
                              component.set("v.segmentString", segmentListStr);
                          }  
                      }
                }
            }
			if (component.get("v.isSPIFSecModified") == true && component.get("v.mode") == 'edit') {
			var todDate = helper.getTodayDateLocalTime();
			
			
			if(helper.isNotBlank(component.get("v.oldPFR.Core_MDF_Start_Date__c")) && component.get("v.oldPFR.Core_MDF_Start_Date__c") < todDate ){
				if( (helper.isNotBlank(component.get("v.newPFR.Core_MDF_Start_Date__c")) && component.get("v.newPFR.Core_MDF_Start_Date__c") < todDate ) ||
				   component.get("v.oldPFR.Core_MDF_Start_Date__c") != component.get("v.newPFR.Core_MDF_Start_Date__c")) {
					if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Revision Required')
					{ if(component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") == null){
						component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",$A.get("$Label.c.Core_MDF_ATF_RR"));
					}
					 
					 else if(!component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c").includes($A.get("$Label.c.Core_MDF_ATF_RR"))){
						 component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") +';' + $A.get("$Label.c.Core_MDF_ATF_RR"));}
					}
					
					else if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Planned'){
						if(component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") == null){
							component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",$A.get("$Label.c.Core_MDF_ATF_Planned_Status"));
						}
						else if(!component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c").includes($A.get("$Label.c.Core_MDF_ATF_Planned_Status")))
						{component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") +';' + $A.get("$Label.c.Core_MDF_ATF_Planned_Status"));}
					}
					else if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'In-Progress'){
						if(component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") == null){
							component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",$A.get("$Label.c.Core_MDF_ATF_In_Progress_Status"));
						}
						else if(!component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c").includes($A.get("$Label.c.Core_MDF_ATF_In_Progress_Status")))
						{component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") +';' + $A.get("$Label.c.Core_MDF_ATF_In_Progress_Status"));}
					}
				}
			}
		}
           
		var segDisplayComp = component.find("displaySegment");        
		var spifAmount;
		if (segDisplayComp != null) {
		   spifAmount = segDisplayComp.fetchSpifAmount();
		   component.set("v.newPFR.Core_MDF_SPIF_Segments_Available_ind__c",true);
		   if(activityAmount < spifAmount){
				validData = false;
				var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
				helper.displaySuccessErrorMsg(alertMsg,"Error!","error","dismissible");
			}
		}
            
        }
        
        if(!$A.util.isEmpty(component.get("v.selectedTacticsOptions")) && helper.isNotBlank(component.get("v.selectedTacticsOptions"))) {
            var lwcTacticMetricsComp = component.find("tacticMetrics");        
            var tacticMetricsValues;var isTacticMetricsModified;var isFormValid;
            if (lwcTacticMetricsComp != null) {
                if(helper.isNotBlank(lwcTacticMetricsComp[0])){
                    tacticMetricsValues = lwcTacticMetricsComp[0].getTacticMetricsValues();
                    isTacticMetricsModified = lwcTacticMetricsComp[0].isTacticMetricsModified();
                    isFormValid = lwcTacticMetricsComp[0].isFormValid();

                }else{
                    tacticMetricsValues = lwcTacticMetricsComp.getTacticMetricsValues();
                    isTacticMetricsModified = lwcTacticMetricsComp.isTacticMetricsModified();
                    isFormValid = lwcTacticMetricsComp.isFormValid();
                }
                if(!isFormValid){
                    var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");                                  
                    helper.displaySuccessErrorMsg(alertMsg,"Error!","error","dismissible"); 
                    validData = false;
                }
               component.set("v.tacticMetricsValues",'');
                if(tacticMetricsValues.length > 0){ 
                      if (helper.isNotBlank(tacticMetricsValues)) {                     
                          var tacticMetricsVal = JSON.parse(JSON.stringify(tacticMetricsValues));
                          component.set("v.tacticMetricsValues", tacticMetricsVal);
			              //component.set("v.isSPIFSecModified",isTacticMetricsModified);
                          if(isTacticMetricsModified && component.get("v.mode") == 'edit'){ 
                            component.set("v.newPFR.Core_MDF_Metrics_Modified_ind__c",true);
                          }
                          if(component.get("v.checkCloneAttribute")){
                              component.set("v.tacticMetricsValues", tacticMetricsVal);
                          }  
                      }
                }
            }
            
        }
        else{
            component.set("v.tacticMetricsValues", null);
        }
        //Akash, IPA outcome
        if(!$A.util.isEmpty(component.get("v.selectedAccount")) && helper.isNotBlank(component.get("v.selectedAccount"))){
        var lwcAccActivityComp = component.find("activityAccNode");
        var outcomeActivityAccNodeValues;
        var isAccountAllocationModified;
        
        const isValid = lwcAccActivityComp.validate();
        if (!isValid) {
            var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
            helper.displaySuccessErrorMsg(alertMsg, "Error!", "error","dismissible");
            validData = false;
            return;
        }
        
        try {
            outcomeActivityAccNodeValues = lwcAccActivityComp.getAllAccountAllocationDetails();
            isAccountAllocationModified = lwcAccActivityComp.isAccountAllocationModified();
        } catch (error) {
            console.error('Error in getAllActivityOutcomesDetails:', error);
        }
        
        if (outcomeActivityAccNodeValues && outcomeActivityAccNodeValues.length > 0) {
            var outcActivityVal = JSON.parse(JSON.stringify(outcomeActivityAccNodeValues));
            component.set("v.ActivityNodeAccValues", outcActivityVal);
            
            if(isAccountAllocationModified && component.get("v.mode") == 'edit'){ 
                component.set("v.newPFR.Core_MDF_Node_Acc_Map_Modified_ind__c", true);
            }
            
            if(component.get("v.checkCloneAttribute")){
                component.set("v.ActivityNodeAccValues", outcActivityVal);
            }
        }
    } else {
        component.set("v.ActivityNodeAccValues", null);
    }
        if ( !$A.util.isEmpty(component.get("v.selectedOutcomeMetricOptions")) && helper.isNotBlank(component.get("v.selectedOutcomeMetricOptions"))) {
            var lwcOutcomeActivityComp = component.find("activityOutcomeCmp");
            var outcomeActivityValues;
            var isFormValid;
            
            var lwcChild = lwcOutcomeActivityComp;
            if (helper.isNotBlank(lwcOutcomeActivityComp) && lwcOutcomeActivityComp.length > 0) {
                lwcChild = lwcOutcomeActivityComp[0];
            }
            if (lwcChild != null) {
                isFormValid = lwcChild.validate();
                if (!isFormValid) {
                    var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
                    helper.displaySuccessErrorMsg(alertMsg, "Error!", "error","dismissible");
                    validData = false;
                    return;
                }
                outcomeActivityValues = lwcChild.getAllActivityOutcomesDetails();
                component.set("v.outcomeActivityValues", "");
                
                if (outcomeActivityValues && outcomeActivityValues.length > 0) {
                    var outcomeActivityVal = JSON.parse(JSON.stringify(outcomeActivityValues));
                    component.set("v.outcomeActivityValues", outcomeActivityVal);
                }
            }
            } else {
                component.set("v.outcomeActivityValues", null);
            }
        
		
        var actStatus = component.get("v.CurrentStatus");
        var existingOwner = component.get("v.existingIntelOwner");
        var mode = component.get("v.mode");
        
        // If all the Entered Data are valid in terms of text or Number
        if(validData){
            
            if(helper.isNotBlank(component.get("v.selectedAccount").Id)){
                component.set("v.newPFR.ChannelPartnerId",component.get("v.selectedAccount").Id);
            }		
            
            //helper.calculateReimbursementRate(component, budgetAmount, maxIntelInvestment);
             // Skip PCT Approval-ENSURE BOOLEAN FIELDS ARE PROPERLY SET BEFORE SAVE
            var pctApproval = component.get("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c");
            if (pctApproval === null || pctApproval === undefined || pctApproval === "") {
                component.set("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c", false);
            } else {
                // Ensure it's a proper boolean
                component.set("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c", Boolean(pctApproval));
            }
            
			component.set("v.newPFR.Core_MDF_Focus_Area_nm__c",component.get("v.selectedFocusArea"));
			component.set("v.newPFR.Core_MDF_Activity_Classification_nm__c",component.get("v.selActivityClassification"));
			component.set("v.newPFR.Core_MDF_Tactics_nm__c",component.get("v.selectedTacticsOptions"));
            component.set("v.newPFR.Core_MDF_Outcomes_nm__c",component.get("v.selectedOutcomeMetricOptions"));
			component.set("v.newPFR.Core_MDF_ActivityCategory__c",$A.get("$Label.c.Core_MDF_Outcome_Based_CatType"));
            component.set("v.newPFR.Core_MDF_Activity_Types__c",$A.get("$Label.c.Core_MDF_Outcome_Based_CatType"));
			component.set("v.newPFR.Core_MDF_Proposal_Based_Ind__c",false);
            component.set("v.newPFR.Core_MDF_Is_Outcome_Based_Ind__c",true);
            //component.set("v.newPFR.Core_MDF_ProductType__c",component.get("v.SelProductType"));
            component.set("v.newPFR.Core_MDF_Priority_nm__c",component.get("v.SelPriority"));
			component.set("v.newPFR.Core_MDF_Priority_2_nm__c",component.get("v.SelPriority2"));
            component.set("v.newPFR.Core_MDF_Activity_Level_nm__c","Super Activity");
            //component.set("v.newPFR.Core_MDF_EcosystemPartner_nm__c",component.get("v.selectedEcosystemPartnerOptions"));
            //component.set("v.newPFR.Core_MDF_Technology_txt__c",component.get("v.selectedTechnologyOptions"));
            component.set("v.newPFR.RecordTypeId",component.get("v.recordtype"));
			component.set("v.newPFR.Core_MDF_Fund_Request_Status__c",component.get("v.CurrentStatus"));
			component.set("v.newPFR.Core_MDF_Budget_Currency_cd__c",$A.get("$Label.c.Core_MDF_PFR_Output_Currency"));
            component.set("v.newPFR.Core_MDF_Maximum_Intel_Investment_amt__c",component.get("v.maxIntelInvestment"));
			component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c",component.get("v.BudgetLocal"));
			//component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", component.get("v.SelReimbursementRate"));
			//component.set("v.newPFR.Core_MDF_Reimbursement_Rate_pct__c", component.get("v.SelReimbursementRate"));
			//component.set("v.newPFR.Core_MDF_Budget_Type_nm__c", component.get("v.selBudgetType"));		
            //component.set("v.newPFR.Core_MDF_Outcomes_nm__c", component.get("v.selectedOutcomeMetricOptions"));	
            //component.set("v.newPFR.Core_MDF_Initiative_nm__c", component.get("v.selectedInitiativeOptions"));
            component.set("v.newPFR.RequestedAmount", component.get("v.BudgetLocal"));
            component.set("v.newPFR.Core_MDF_Outcome_Region_nm__c", component.get("v.SelRegion"));
            component.set("v.newPFR.Core_MDF_Country_nm__c", component.get("v.selectedCountryOptions"));
            component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", 1);
                    	
            if(component.get("v.SelRegion")) {
            component.set("v.newPFR.Core_MDF_Outcome_Region_nm__c", component.get("v.SelRegion"));
            }

            // Making Id null in order to save New Record from clone
            if(component.get("v.checkCloneAttribute")){
			 
              component.set("v.newPFR.Id", null);
              component.set("v.recordId", null);
              component.set("v.newPFR.CreatedDate", null);
              component.set("v.newPFR.Core_MDF_Activity_Closure_Type__c", '');
              component.set("v.newPFR.BudgetId", null);  
              //component.set("v.newPFR.AllocationId", null);   

            }
            
            if(component.get("v.selAvailableBudget")) {
            component.set("v.newPFR.BudgetId", component.get("v.selAvailableBudget"));
            }
            
            if(component.get("v.SelectedStatus") != "" ){
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c",component.get("v.SelectedStatus"));
            }  
            
        if(((recordTypeDeveloperName == 'Core_MDF_Intel_Partner_Alliance')
                   && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false) && component.get("v.recordId") == null && component.get("v.ipaAcctMgr")){
              
            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c",1);                                     
            component.set("v.newPFR.Core_MDF_Approval_Stage__c",'L1 Approval');
        }
            
		if(component.get("v.SelectedStatus") != undefined && component.get("v.recordId") != null && (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")&&(component.get("v.isPropBasedCampaign") == false))){
            if (!component.get("v.SelectedStatus").includes($A.get("$Label.c.Core_MDF_Activity_Cancelled_Status")) &&
                    !$A.get("$Label.c.Core_MDF_PFR_Status_Closed").includes(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c"))) {
                helper.setIPAAccountBasedActivityStatus(component);
            }  
        }
            
		var editedFieldRequiresApproval = component.get("v.activityFieldSetList");
		var removeFieldNotReqVal = editedFieldRequiresApproval.toString().replace(',Core_MDF_Require_Additional_Review_ind__c', '');
		var convertArrayFieldSet = removeFieldNotReqVal.split(',');  
		if((helper.fieldEligibleForApprovalModified(component, convertArrayFieldSet)
			  || component.get("v.newPFR.Core_MDF_SPIF_Modified_ind__c") == true) && component.get("v.mode") == 'edit' &&
			 component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") != $A.get("$Label.c.Core_MDF_CCP_Planned_Status") &&
			 (component.get("v.ipaAcctMgr") || component.get("v.ipaL2Approver")) &&
			 ((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) 
			   && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)) {
			 component.set("v.newPFR.Core_MDF_Is_Field_Modified__c",true); 
		}
		//Outcome Based changes - to show govt question, Event, ELC Popup when selected tactics is Event
        if(!$A.util.isEmpty(component.get("v.selectedTacticsOptions")) && component.get("v.selectedTacticsOptions").includes('Event') && component.get("v.goForSave")==false){
            
            helper.isTacticsGovtEventQuesSecVisible(component);
	        helper.isTacticsEventPopUpVisible(component);
            helper.isTacticsELCPopUpVisible(component);
        }else{
            	component.set("v.goForSave",true);
                helper.saveHelperMethod(component, component.get("v.newPFR"));
            }
		//ATF Flag
        var todDate = helper.getTodayDateLocalTime();
        if(component.get("v.mode") == 'edit' && (helper.isNotBlank(component.get("v.oldPFR.Core_MDF_Start_Date__c")) && component.get("v.oldPFR.Core_MDF_Start_Date__c") < todDate) && component.get("v.Uploadfinished")){
        if( (component.get("v.newPFR.Core_MDF_Start_Date__c") < todDate ) ||
              component.get("v.oldPFR.Core_MDF_Start_Date__c") != component.get("v.newPFR.Core_MDF_Start_Date__c")) {
			   if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Revision Required')
			   { if(component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") == null){
			   component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",$A.get("$Label.c.Core_MDF_ATF_RR"));
			   }
           
                else if(!component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c").includes($A.get("$Label.c.Core_MDF_ATF_RR"))){
                    component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") +';' + $A.get("$Label.c.Core_MDF_ATF_RR"));}
					}
                
				else if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Planned'){
				if(component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") == null){
			   component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",$A.get("$Label.c.Core_MDF_ATF_Planned_Status"));
			   }
			 else if(!component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c").includes($A.get("$Label.c.Core_MDF_ATF_Planned_Status")))
                {component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") +';' + $A.get("$Label.c.Core_MDF_ATF_Planned_Status"));}
				}
           }
            }           
        } 
        else
        {
            if (localmsg != "")
            {
               
                
               
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": localmsg,
                    "type" : "error"
                    
                });
                toastEvent.fire();
                return;
            }
        }
    },

    // Add these methods to your existing controller

filterCountry: function (component, event, helper) {
    // Get the current country options (might be filtered by region)
    // If filter is completely empty (backspaced to nothing), reset and return
    var countryName = component.get("v.AllCountryOptions");
    if (!countryName || countryName.length === 0) {
        return;
    }
    var filterCountrySearch = new Array();
    var filterCountryNonSearch = new Array();
    
    if (helper.isNotBlank(component.get("v.countryFilter"))) {
        var countrySearch = component.get("v.countryFilter").toUpperCase();
        
        for (var index = 0; index < countryName.length; index++) {
            if (countryName[index].label.toUpperCase().includes(countrySearch)) {
                filterCountrySearch.push({
                    label: countryName[index].label,
                    value: countryName[index].value
                });
            } else {
                filterCountryNonSearch.push({
                    label: countryName[index].label,
                    value: countryName[index].value
                });
            }
        }
        component.set("v.AllCountryOptions", filterCountrySearch.concat(filterCountryNonSearch));
    } else {
        // Reset based on current region selection
        /*var selectedRegion = component.get("v.SelRegion");
        if(selectedRegion) {
            helper.filterCountriesByRegion(component, selectedRegion);
        } else {
            helper.setHardcodedCountryOptions(component);
        }*/
    }
        
},



onBrandChange: function (component, event, helper) {
    var selectedBrand = event.getParam('value');
    var selectedBrandOptions = "";
    
    if(!$A.util.isEmpty(selectedBrand) && selectedBrand != undefined){
        for(var i=0; i<selectedBrand.length; i++ ){
            if(i!=selectedBrand.length-1)
                selectedBrandOptions+=selectedBrand[i]+";";
            else 
                selectedBrandOptions+=selectedBrand[i];            
        }
    }
    
    if(!$A.util.isEmpty(selectedBrandOptions) && selectedBrandOptions != undefined){
        component.set("v.newPFR.Core_MDF_Brand_nm__c", selectedBrandOptions);
    }
    
    // Reset helper for dependent fields
    helper.resetHelper(component);
},

onTargetAudienceChange: function (component, event, helper) {
    var selectedTargetAudience = event.getParam('value');
    var selectedTargetAudienceOptions = "";
    
    if(!$A.util.isEmpty(selectedTargetAudience) && selectedTargetAudience != undefined){
        for(var i=0; i<selectedTargetAudience.length; i++ ){
            if(i!=selectedTargetAudience.length-1)
                selectedTargetAudienceOptions+=selectedTargetAudience[i]+";";
            else 
                selectedTargetAudienceOptions+=selectedTargetAudience[i];            
        }
    }
    
    if(!$A.util.isEmpty(selectedTargetAudienceOptions) && selectedTargetAudienceOptions != undefined){
        component.set("v.newPFR.Core_MDF_TargetAudience_nm__c", selectedTargetAudienceOptions);
    }
},

onInitiativesChange: function (component, event, helper) {
    var selectedInitiatives = event.getParam('value');
    var selectedInitiativeOptions = "";
    
    if(!$A.util.isEmpty(selectedInitiatives) && selectedInitiatives != undefined){
        for(var i=0; i<selectedInitiatives.length; i++ ){
            if(i!=selectedInitiatives.length-1)
                selectedInitiativeOptions+=selectedInitiatives[i]+";";
            else
                selectedInitiativeOptions+=selectedInitiatives[i];            
        }
    }
    
    if(!$A.util.isEmpty(selectedInitiativeOptions) && selectedInitiativeOptions != undefined){
        component.set("v.newPFR.Core_MDF_Initiative_nm__c", selectedInitiativeOptions);
    }
},

onEcosystemPartnerChange: function (component, event, helper) {
    var selectedEcosystemPartner = event.getParam('value');
    var selectedEcosystemPartnerOptions = "";
    
    if(!$A.util.isEmpty(selectedEcosystemPartner) && selectedEcosystemPartner != undefined){
        for(var i=0; i<selectedEcosystemPartner.length; i++ ){
            if(i!=selectedEcosystemPartner.length-1)
                selectedEcosystemPartnerOptions+=selectedEcosystemPartner[i]+";";
            else
                selectedEcosystemPartnerOptions+=selectedEcosystemPartner[i]; 
        }
    }
    
    if(selectedEcosystemPartnerOptions != undefined && selectedEcosystemPartnerOptions != null){              
        component.set("v.newPFR.Core_MDF_EcosystemPartner_nm__c", selectedEcosystemPartnerOptions);
    }
},

onTechnologyChange: function (component, event, helper) {
    var selectedTechnology = event.getParam('value');
    var selectedTechnologyOptions = "";
    
    if(!$A.util.isEmpty(selectedTechnology) && selectedTechnology != undefined){
        for(var i=0; i<selectedTechnology.length; i++ ){
            if(i!=selectedTechnology.length-1)
                selectedTechnologyOptions+=selectedTechnology[i]+";";
            else
                selectedTechnologyOptions+=selectedTechnology[i]; 
        }
    }
   
    if(!$A.util.isEmpty(selectedTechnologyOptions) && selectedTechnologyOptions != undefined){              
        component.set("v.newPFR.Core_MDF_Technology_txt__c", selectedTechnologyOptions);
        //var techie = component.get("v.selectedTechnologyOptions");
    }
}, 

onProductTypeOptionsChange: function (component, event, helper) {//made changes Alekhya
    var selectedProductType = event.getParam('value');
    var selectedProductTypeOptions = "";
    
    if(!$A.util.isEmpty(selectedProductType) && selectedProductType != undefined){
        for(var productType=0; productType<selectedProductType.length; productType++ ){
            if(productType!=selectedProductType.length-1)
                selectedProductTypeOptions+=selectedProductType[productType]+";";
            else
                selectedProductTypeOptions+=selectedProductType[productType]; 
        }
    }
    console.log(selectedProductTypeOptions);
    if(!$A.util.isEmpty(selectedProductTypeOptions) && selectedProductTypeOptions != undefined){              
        component.set("v.newPFR.Core_MDF_ProductType__c", selectedProductTypeOptions);
        //var techie = component.get("v.selectedProductTypeOptions");
        console.log(selectedProductTypeOptions);
    }
},     

onOutcomeMetricOptionsChange: function (component, event, helper) {
    var selectedOutcomeMetric = event.getParam('value');
    var prev = component.get("v.prevSelectedOutcomes");

    if(selectedOutcomeMetric.length === 0 && (!prev || prev.length === 0)) {
        component.set("v.prevSelectedOutcomes", []);
        component.set("v.selectedOutcomes", []);
        return;
    }
      
    if(selectedOutcomeMetric.length === 1) {

        var outcomeString = selectedOutcomeMetric[0];
        component.set("v.newPFR.Core_MDF_Outcomes_nm__c", outcomeString);
        component.set("v.showActivityPurpose", true);
        component.set("v.prevSelectedOutcomes", selectedOutcomeMetric.slice(0));
        component.set("v.selectedOutcomes", selectedOutcomeMetric);
        component.set("v.isOutcomeSelectionInvalid", false);
        
    } else if(selectedOutcomeMetric.length === 2 && prev.length === 1) {
        var newSelection = selectedOutcomeMetric.find(item => !prev.includes(item));
        if(newSelection) {
            component.set("v.newPFR.Core_MDF_Outcomes_nm__c", newSelection);
            component.set("v.showActivityPurpose", true);
            component.set("v.prevSelectedOutcomes", [newSelection]);
            component.set("v.selectedOutcomes", [newSelection]);
            component.set("v.isOutcomeSelectionInvalid", false);
            component.set("v.selectedOutcomeMetricOptions", [newSelection]);
        }
        
    } else {
        var alertMsg = $A.get("$Label.c.Core_MDF_Campaign_Outcome_Validation");
        helper.displaySuccessErrorMsg(alertMsg, "Error!", "error","dismissible");
        component.set("v.selectedOutcomeMetricOptions", prev);
    }
},

//Method to handle Priority change
handlePriority1Change: function(component, event, helper) {
    var selectedValue = event.getParam("value");
    component.set("v.SelPriority", selectedValue);
    helper.validatePriorityFieldsImmediate(component);
},

// Method to handle Priority 2 change  
handlePriority2Change: function(component, event, helper) {
    var selectedValue = event.getParam("value");
    component.set("v.SelPriority2", selectedValue);
    helper.validatePriorityFieldsImmediate(component);
},

// Function called on the change of Account
resetAccountattributes : function(component, event, helper){
    if(component.get("v.selectedAccount") == null || component.get("v.selectedAccount").Id == null){
        component.set("v.newPFR.ChannelPartnerId",null);
        //Akash, IPA outcome
        component.set("v.isAccountSelected",false);
    } 
    else{
        component.set("v.newPFR.ChannelPartnerId",component.get("v.selectedAccount").Id );
        //Akash, IPA outcome
        component.set("v.isAccountSelected",true);
    }
    
    // Only fetch budget if account is also selected
    var selectedAccount = component.get("v.selectedAccount");
    if(selectedAccount && selectedAccount.Id && component.get("v.selAvailableBudget")) {
        if (component.get("v.mode") == "" || component.get("v.mode") == 'clone' || component.get("v.mode") == 'edit'){
            if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) {
                helper.checkAvailAllocationAmt(component);
                helper.fetchBudgetInfo(component);
            }
        }
    }
    
    //Populate BudgetType field based on ABA
    if(selectedAccount && selectedAccount.Id){
        helper.fetchBudgetTypesBasedOnBenefits(component);
        helper.loadPartnerContactDomains(component, function() {
            helper.validatePartnerContactEmails(component);
        });
    }else{//Reset BudgetType if the account is Removed
        var budgetTypeOptionList = [];
        budgetTypeOptionList.push({label: "---None---", value: "" });
        component.set("v.budgetTypeVal", budgetTypeOptionList);
        component.set("v.newPFR.Core_MDF_Budget_Type_nm__c", '');
        component.set("v.selBudgetType", '');
        component.set("v.showBudgetTypeError", false);
        component.set("v.allowedPartnerContactDomains", []);
        component.set("v.partnerContactDomainsLoaded", false);
        helper.resetPartnerContactValidation(component);
    }
    
    },

    onRegionChange: function(component, event, helper) {
        var selectedRegion = null;
        if (event && event.getParam) 
            {selectedRegion = event.getParam('value');
            }
        if (!selectedRegion) {selectedRegion = component.get("v.SelRegion");}

        component.set("v.SelRegion", selectedRegion);

        // Fetch list filtered by region using allowed list from AllCountryOptions
        helper.fetchCountriesByRegionUsingAllOptions(component, selectedRegion);
    },

   onCountryChange: function(component, event, helper) {
    
        var selectedCountries = event.getParam('value');
        var selectedCountryOptions = "";

        if (!$A.util.isEmpty(selectedCountries) && selectedCountries != undefined) {
            for (var i = 0; i < selectedCountries.length; i++) {
                if (i != selectedCountries.length - 1)
                    selectedCountryOptions += selectedCountries[i] + ";";
                else
                    selectedCountryOptions += selectedCountries[i];
            }
        }

        if (!$A.util.isEmpty(selectedCountryOptions) && selectedCountryOptions != undefined) {
            component.set("v.newPFR.Core_MDF_Country_nm__c", selectedCountryOptions);
        }


},

    onBudgetTypeChange: function(component, event, helper) {
        
        var selectedBudgetType = event.getParam('value');
        //var selectedBudgetType = event.getSource().get("v.value");
        if(selectedBudgetType == '' ||selectedBudgetType == 'Account Plan'){
            component.set("v.newPFR.Core_MDF_Budget_Type_nm__c", selectedBudgetType);
        }
    },
        /*Commented this error as part of showing only Account Plan as Budget Type
        else{
            component.set("v.selBudgetType", "");
             helper.displaySuccessErrorMsg(
                $A.get("$Label.c.Core_MDF_Activity_Outcome_ProposalBT_Selection_Error"),
                "Error",
                "error",
                "sticky"
            );
        }*/
        handleCancel : function(component, event, helper) {
        var mode = component.get("v.mode");
        var communityUrl = component.get("v.externalper");
        var communityBaseUrl = $A.get("$Label.c.Core_MDF_PFRCommunityLink");
        var recordId= component.get("v.recordId");
        if(mode == 'edit' || mode == 'clone'){
            var url = communityUrl
            ? communityBaseUrl + 's/outcome-based-campaign-details?recordId=' + recordId
            : '/lightning/n/Core_MDF_Outcome_Based_Campaign_Detail?c__recordId=' + recordId;
            window.location.href = url;
        }else if(mode == ''){
            var url = communityUrl
            ? communityBaseUrl + 's/Core_MDF_Outcome_Based_Campaigns'
            : '/lightning/n/Core_MDF_Outcome_Based_Campaigns';
            window.location.href = url;
        }
    }


})