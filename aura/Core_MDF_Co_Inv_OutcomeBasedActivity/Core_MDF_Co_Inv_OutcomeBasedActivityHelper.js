({
    logDebug: function (tag, data) {
        try {
            console.log("[Co-Inv-Outcome] " + tag, data);
        } catch (e) {
            // no-op
        }
    },

    logWarn: function (tag, data) {
        try {
            console.warn("[Co-Inv-Outcome] " + tag, data);
        } catch (e) {
            // no-op
        }
    },

    initialize: function (component) {
        component.set("v.showSpinner", true);
        this.logDebug("initialize:start", {
            mode: component.get("v.mode"),
            recordId: component.get("v.recordId")
        });

        component.set("v.newPFR.Core_MDF_Is_Outcome_Based_Ind__c", true);
        component.set("v.budgetAllocations", []);
        component.set("v.showBudgetTable", false);
        
        this.fetchBudgetTypePicklist(component);
        this.fetchRegion(component);
        this.initializeBudgetTable(component);
        
        component.set("v.showSpinner", false);
    },

    initializeBudgetTable: function (component) {
        component.set("v.budgetAllocations", []);
        component.set("v.totalPercentageAllocation", 0);
        component.set("v.totalAllocatedAmount", 0);
        component.set("v.budgetValidationError", "");
        component.set("v.showBudgetTable", false);
    },

    handleAccountChange: function (component) {
        var selectedAccount = component.get("v.selectedAccount");
        this.logDebug("handleAccountChange", selectedAccount);
    },

    validateDates: function (component) {
        var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var endDate = component.get("v.newPFR.Core_MDF_End_Date__c");
        
        if (startDate && endDate && startDate > endDate) {
            this.logWarn("validateDates", "Start date is after end date");
        }
    },

    calculateTotalInvestment: function (component) {
        var totalAmount = component.get("v.newPFR.RequestedAmount");
        this.logDebug("calculateTotalInvestment", totalAmount);
    },

    calculateMaxIntelInvestment: function (component) {
        var maxAmount = component.get("v.newPFR.Core_MDF_Maximum_Intel_Investment_amt__c");
        this.logDebug("calculateMaxIntelInvestment", maxAmount);
    },

    handleRegionChange: function (component) {
        var region = component.get("v.SelRegion");
        this.logDebug("handleRegionChange", region);
    },

    onBudgetTypeChange: function (component) {
        var budgetType = component.get("v.newPFR.Core_MDF_Budget_Type_nm__c");
        
        if (budgetType && budgetType !== "") {
            component.set("v.showBudgetTable", true);
            this.fetchAvailableBudgets(component, budgetType);
        } else {
            component.set("v.showBudgetTable", false);
            this.initializeBudgetTable(component);
        }

        this.logDebug("onBudgetTypeChange", budgetType);
    },

    // Budget Table Management Methods
    addBudgetAllocationRow: function (component) {
        var allocations = component.get("v.budgetAllocations");
        
        var newAllocation = {
            id: "budget_" + new Date().getTime(),
            budgetId: "",
            budgetName: "",
            budgetType: "",
            revenueSegment: "",
            availableAmount: 0,
            allocationPercentage: 0,
            allocatedAmount: 0
        };

        allocations.push(newAllocation);
        // Create a new array reference to trigger binding update
        var newAllocations = allocations.slice();
        component.set("v.budgetAllocations", newAllocations);
        
        this.logDebug("addBudgetAllocationRow", "New budget row added");
    },

    onBudgetSelect: function (component, index) {
        var allocations = component.get("v.budgetAllocations");
        
        if (index < 0 || index >= allocations.length) {
            this.logWarn("onBudgetSelect", "Invalid index: " + index);
            return;
        }

        var allocation = allocations[index];
        var selectedBudgetId = allocation.budgetId;

        this.logDebug("onBudgetSelect", {
            index: index,
            selectedBudgetId: selectedBudgetId,
            allocation: allocation
        });

        if (!selectedBudgetId || selectedBudgetId === "") {
            // Clear the row if no budget selected
            allocation.budgetName = "";
            allocation.budgetType = "";
            allocation.revenueSegment = "";
            allocation.availableAmount = 0;
            allocation.allocationPercentage = 0;
            allocation.allocatedAmount = 0;
            
            // Force update by creating new array reference
            var clearedAllocations = allocations.slice();
            clearedAllocations[index] = allocation;
            component.set("v.budgetAllocations", clearedAllocations);
            
            this.logDebug("onBudgetSelect:cleared", "Row cleared at index " + index);
            return;
        }

        // Find the selected budget from available budgets
        var availableBudgets = component.get("v.availableBudgets");
        var selectedBudget = null;
        
        for (var i = 0; i < availableBudgets.length; i++) {
            if (availableBudgets[i].budgetId === selectedBudgetId) {
                selectedBudget = availableBudgets[i];
                break;
            }
        }

        if (selectedBudget) {
            var budgetAvailableAmount = (selectedBudget.availableAmount !== undefined && selectedBudget.availableAmount !== null) ? parseFloat(selectedBudget.availableAmount) : 0;
            
            // Set actual available amount from budget (NOT capped)
            allocation.budgetName = selectedBudget.budgetName || "";
            allocation.budgetType = selectedBudget.budgetType || "";
            allocation.revenueSegment = selectedBudget.revenueSegment || "";
            allocation.availableAmount = budgetAvailableAmount;
            allocation.allocationPercentage = 0;
            allocation.allocatedAmount = 0;
            
            // Force update by creating new array reference
            var updatedAllocations = allocations.slice();
            updatedAllocations[index] = allocation;
            component.set("v.budgetAllocations", updatedAllocations);
            
            this.logDebug("onBudgetSelect:success", {
                index: index,
                budgetId: selectedBudgetId,
                budgetName: allocation.budgetName,
                budgetAvailableAmount: budgetAvailableAmount,
                availableAmount: allocation.availableAmount,
                updatedAllocation: updatedAllocations[index]
            });
        } else {
            this.logWarn("onBudgetSelect", "Budget " + selectedBudgetId + " not found in available budgets");
            this.logDebug("onBudgetSelect:availableBudgetIds", availableBudgets.map(function(b) { return b.budgetId; }));
        }
    },

    addSelectedBudgetToAllocations: function (component) {
        var select = component.find("availableBudgetSelect");
        var selectedBudgetId = select.get("v.value");
        
        if (!selectedBudgetId || selectedBudgetId === "") {
            var toastEvent = $A.get("e.force:showToast");
            if (toastEvent) {
                toastEvent.setParams({
                    title: "Warning",
                    message: "Please select a budget from the dropdown",
                    type: "warning",
                    duration: 3000
                });
                toastEvent.fire();
            }
            return;
        }

        // Find the selected budget from available budgets
        var availableBudgets = component.get("v.availableBudgets");
        var selectedBudget = null;
        
        for (var i = 0; i < availableBudgets.length; i++) {
            if (availableBudgets[i].budgetId === selectedBudgetId) {
                selectedBudget = availableBudgets[i];
                break;
            }
        }

        if (!selectedBudget) {
            return;
        }

        // Check if budget already added
        var allocations = component.get("v.budgetAllocations");
        for (var i = 0; i < allocations.length; i++) {
            if (allocations[i].budgetId === selectedBudgetId) {
                var toastEvent = $A.get("e.force:showToast");
                if (toastEvent) {
                    toastEvent.setParams({
                        title: "Info",
                        message: "This budget is already added",
                        type: "info",
                        duration: 3000
                    });
                    toastEvent.fire();
                }
                return;
            }
        }

        // Add the selected budget to allocations
        allocations.push({
            id: selectedBudget.budgetId,
            budgetId: selectedBudget.budgetId,
            budgetName: selectedBudget.budgetName,
            budgetType: selectedBudget.budgetType || "",
            revenueSegment: selectedBudget.revenueSegment || "",
            availableAmount: selectedBudget.availableAmount,
            allocationPercentage: 0,
            allocatedAmount: 0
        });

        component.set("v.budgetAllocations", allocations);
        
        // Reset dropdown
        select.set("v.value", "");
        
        this.validateBudgetAllocations(component);
        this.logDebug("addSelectedBudgetToAllocations", "Budget added: " + selectedBudgetId);
    },


    removeBudgetAllocationRow: function (component, index) {
        var allocations = component.get("v.budgetAllocations");
        
        if (index >= 0 && index < allocations.length) {
            allocations.splice(index, 1);
            // Create a new array reference to trigger binding update
            var newAllocations = allocations.slice();
            component.set("v.budgetAllocations", newAllocations);
            this.validateBudgetAllocations(component);
            
            this.logDebug("removeBudgetAllocationRow", "Budget row removed at index: " + index);
        }
    },

    updateBudgetAllocation: function (component, index) {
        var allocations = component.get("v.budgetAllocations");
        var maxIntelInvestment = component.get("v.newPFR.Core_MDF_Maximum_Intel_Investment_amt__c");
        
        if (index >= 0 && index < allocations.length) {
            var allocation = allocations[index];
            var percentage = allocation.allocationPercentage;
            
            // Allocated Amount = (Max Intel Investment × %) / 100
            if (percentage !== null && percentage !== undefined && percentage !== "" && !isNaN(percentage)) {
                var percentageNum = parseFloat(percentage);
                var maxInvestNum = (maxIntelInvestment !== undefined && maxIntelInvestment !== null) ? parseFloat(maxIntelInvestment) : 0;
                
                // Calculate: (Max Intel Investment × %) / 100
                allocation.allocatedAmount = (maxInvestNum * percentageNum) / 100;
            } else {
                allocation.allocatedAmount = 0;
            }
            
            // Create a new array reference to trigger binding update
            var newAllocations = allocations.slice();
            newAllocations[index] = allocation;
            component.set("v.budgetAllocations", newAllocations);
            
            this.validateBudgetAllocations(component);
            this.logDebug("updateBudgetAllocation", {
                index: index,
                percentage: percentage,
                maxIntelInvestment: maxIntelInvestment,
                allocatedAmount: allocation.allocatedAmount
            });
        }
    },

    validateBudgetAllocations: function (component) {
        var allocations = component.get("v.budgetAllocations");
        var maxIntelInvestment = component.get("v.newPFR.Core_MDF_Maximum_Intel_Investment_amt__c");
        var totalPercentage = 0;
        var totalAllocatedAmount = 0;
        var validationError = "";

        if (allocations && allocations.length > 0) {
            allocations.forEach(function (allocation) {
                if (allocation.allocationPercentage) {
                    totalPercentage += parseFloat(allocation.allocationPercentage);
                }
                if (allocation.allocatedAmount) {
                    totalAllocatedAmount += parseFloat(allocation.allocatedAmount);
                }
            });

            if (allocations.some(function (a) { return a.allocationPercentage < 0; })) {
                validationError = "Allocation percentage cannot be negative";
            } else if (allocations.some(function (a) { return a.allocationPercentage > 100; })) {
                validationError = "Individual allocation percentage cannot exceed 100%";
            } else if (maxIntelInvestment && maxIntelInvestment > 0 && totalAllocatedAmount > maxIntelInvestment) {
                validationError = "Total allocation amount (" + Math.round(totalAllocatedAmount * 100) / 100 + ") cannot exceed Maximum Intel Investment (" + maxIntelInvestment + ")";
            }
        }

        component.set("v.totalPercentageAllocation", Math.round(totalPercentage * 100) / 100);
        component.set("v.totalAllocatedAmount", totalAllocatedAmount);
        component.set("v.budgetValidationError", validationError);

        this.logDebug("validateBudgetAllocations", {
            totalPercentage: totalPercentage,
            totalAllocatedAmount: totalAllocatedAmount,
            hasError: validationError !== ""
        });
    },

    // Budget Type Change Handler
    onBudgetTypeChange: function (component) {
        var budgetType = component.get("v.newPFR.Core_MDF_Budget_Type_nm__c");
        
        if (budgetType && budgetType !== "") {
            component.set("v.showBudgetTable", true);
            this.fetchAvailableBudgets(component, budgetType);
        } else {
            component.set("v.showBudgetTable", false);
            this.initializeBudgetTable(component);
        }

        this.logDebug("onBudgetTypeChange", budgetType);
    },

    fetchAvailableBudgets: function (component, budgetType) {
        var self = this;
        var action = component.get("c.fetchAvailableBudgetsForType");
        
        var selectedAccount = component.get("v.selectedAccount");
        var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var endDate = component.get("v.newPFR.Core_MDF_End_Date__c");
        
        this.logDebug("fetchAvailableBudgets:params", {
            budgetType: budgetType,
            selectedAccount: selectedAccount,
            startDate: startDate,
            endDate: endDate
        });
        
        action.setParams({
            budgetType: budgetType,
            accountId: selectedAccount && selectedAccount.Id ? selectedAccount.Id : "",
            startDate: startDate || "",
            endDate: endDate || ""
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            
            self.logDebug("fetchAvailableBudgets:callback", {
                state: state,
                returnValue: response.getReturnValue()
            });
            
            if (state === "SUCCESS") {
                var budgets = response.getReturnValue();
                var budgetList = [];
                
                self.logDebug("fetchAvailableBudgets:response", {
                    budgetsLength: budgets ? budgets.length : 0,
                    budgets: budgets
                });
                
                if (budgets && Array.isArray(budgets) && budgets.length > 0) {
                    budgets.forEach(function (budget) {
                        budgetList.push({
                            id: budget.budgetId,
                            budgetId: budget.budgetId,
                            budgetName: budget.budgetName,
                            budgetType: budget.budgetType,
                            revenueSegment: budget.revenueSegment || '',
                            availableAmount: budget.availableAmount,
                            allocationPercentage: 0,
                            allocatedAmount: 0
                        });
                    });
                }

                component.set("v.availableBudgets", budgetList);
                self.logDebug("fetchAvailableBudgets:success", {
                    budgetListLength: budgetList.length,
                    budgetList: budgetList
                });
            } else {
                self.logWarn("fetchAvailableBudgets:error", {
                    state: state,
                    error: response.getError()
                });
            }
        });

        $A.enqueueAction(action);
    },

    handleMultiSelectChange: function (component, selectedValues, attributePath) {
        component.set(attributePath, selectedValues);
        this.logDebug("handleMultiSelectChange", {
            path: attributePath,
            values: selectedValues
        });
    },

    fetchRegion: function (component) {
        var action = component.get("c.fetchOutcomeRegions");
        var self = this;

        action.setCallback(this, function (response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var regions = response.getReturnValue();
                var regionList = [];
                
                if (regions) {
                    Object.keys(regions).forEach(function (key) {
                        regionList.push({
                            label: regions[key],
                            value: key
                        });
                    });
                }

                component.set("v.regionvalues", regionList);
                self.logDebug("fetchRegion:success", regionList);
            } else {
                self.logWarn("fetchRegion:error", response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    fetchBudgetTypePicklist: function (component) {
        var action = component.get("c.getBudgetTypePicklistForCoInv");
        var self = this;

        action.setCallback(this, function (response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var budgetTypes = response.getReturnValue();
                var budgetTypeList = [];
                
                if (budgetTypes && Array.isArray(budgetTypes)) {
                    budgetTypes.forEach(function (type) {
                        budgetTypeList.push({
                            label: type,
                            value: type
                        });
                    });
                }

                component.set("v.budgetTypeVal", budgetTypeList);
                self.logDebug("fetchBudgetTypePicklist:success", budgetTypeList);
            } else {
                self.logWarn("fetchBudgetTypePicklist:error", response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    isNotBlank: function (value) {
        return value !== null && value !== undefined && value !== "";
    }
})