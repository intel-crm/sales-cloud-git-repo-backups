/*****************************************************************************************************
Class Name  : Core_MDF_OutcomeBudgetMappingHandler
Description : Tracks budget consumption for Outcome Based activities in Core_MDF_Outcome_Budget_Mapping__c.
              - Available amount of a budget = Remaining amount of its active mapping record when one exists,
                otherwise the standard Amount of the PartnerMarketingBudget.
              - On save, every selected budget is validated first and then its mapping record is created
                (first consumption) or updated (subsequent consumption).
*****************************************************************************************************/
public with sharing class Core_MDF_OutcomeBudgetMappingHandler {
    private static final Decimal TOLERANCE = 0.005;

    public class BudgetAllocation {
        public String budgetId;
        public Decimal allocatedAmount;
        public Decimal allocationPercentage;
    }

    public class BudgetBalance {
        public Id budgetId;
        public String budgetName;
        public Decimal standardAmount;
        public Decimal remainingAmount;
        public Core_MDF_Outcome_Budget_Mapping__c mapping;
    }

    /* Remaining amount from the mapping record when it exists, else the standard budget amount */
    public static Decimal resolveAvailableAmount(Decimal standardAmount, Core_MDF_Outcome_Budget_Mapping__c mapping) {
        Decimal standard = standardAmount != null ? standardAmount : 0;
        if (mapping == null) {
            return standard;
        }
        if (mapping.Core_MDF_Remaining_Amount_nbr__c != null) {
            return mapping.Core_MDF_Remaining_Amount_nbr__c;
        }
        Decimal total = mapping.Core_MDF_Total_Amt_on_Budget_nbr__c != null
            ? mapping.Core_MDF_Total_Amt_on_Budget_nbr__c : standard;
        Decimal consumed = mapping.Core_MDF_Consumed_Amount_nbr__c != null
            ? mapping.Core_MDF_Consumed_Amount_nbr__c : 0;
        return total - consumed;
    }

    /* Latest active mapping record per budget */
    public static Map<Id, Core_MDF_Outcome_Budget_Mapping__c> getActiveMappings(Set<Id> budgetIds) {
        Map<Id, Core_MDF_Outcome_Budget_Mapping__c> mappingByBudget = new Map<Id, Core_MDF_Outcome_Budget_Mapping__c>();
        if (budgetIds == null || budgetIds.isEmpty()) {
            return mappingByBudget;
        }
        for (Core_MDF_Outcome_Budget_Mapping__c mapping : [
            SELECT Id, Core_MDF_BudgetId__c, Core_MDF_Total_Amt_on_Budget_nbr__c,
                   Core_MDF_Consumed_Amount_nbr__c, Core_MDF_Remaining_Amount_nbr__c, CreatedDate
            FROM Core_MDF_Outcome_Budget_Mapping__c
            WHERE Core_MDF_BudgetId__c IN :budgetIds
            AND Core_MDF_Active_Ind__c = true
        ]) {
            Core_MDF_Outcome_Budget_Mapping__c existing = mappingByBudget.get(mapping.Core_MDF_BudgetId__c);
            if (existing == null || mapping.CreatedDate > existing.CreatedDate) {
                mappingByBudget.put(mapping.Core_MDF_BudgetId__c, mapping);
            }
        }
        return mappingByBudget;
    }

    /* lockBudgets serialises concurrent saves against the same budget until the transaction ends */
    public static Map<Id, BudgetBalance> getBudgetBalances(Set<Id> budgetIds, Boolean lockBudgets) {
        Map<Id, BudgetBalance> balances = new Map<Id, BudgetBalance>();
        List<PartnerMarketingBudget> budgets = lockBudgets
            ? [SELECT Id, Title, Amount FROM PartnerMarketingBudget WHERE Id IN :budgetIds FOR UPDATE]
            : [SELECT Id, Title, Amount FROM PartnerMarketingBudget WHERE Id IN :budgetIds];

        Map<Id, Core_MDF_Outcome_Budget_Mapping__c> mappings = getActiveMappings(budgetIds);
        for (PartnerMarketingBudget budget : budgets) {
            BudgetBalance balance = new BudgetBalance();
            balance.budgetId = budget.Id;
            balance.budgetName = budget.Title;
            balance.standardAmount = budget.Amount != null ? budget.Amount : 0;
            balance.mapping = mappings.get(budget.Id);
            balance.remainingAmount = resolveAvailableAmount(balance.standardAmount, balance.mapping);
            balances.put(budget.Id, balance);
        }
        return balances;
    }

    /* Validates the selected budgets against their available amounts. Intended to run first on save. */
    public static void validateBudgetAmounts(Object rawAllocations) {
        Map<Id, Decimal> requestedByBudget = getRequestedAmounts(rawAllocations);
        if (requestedByBudget.isEmpty()) {
            return;
        }
        validate(requestedByBudget, getBudgetBalances(requestedByBudget.keySet(), false));
    }

    /* Creates/updates one mapping record per selected budget. Must run in the same transaction as the save. */
    public static void consumeBudgetAmounts(Object rawAllocations) {
        Map<Id, Decimal> requestedByBudget = getRequestedAmounts(rawAllocations);
        if (requestedByBudget.isEmpty()) {
            return;
        }
        Map<Id, BudgetBalance> balances = getBudgetBalances(requestedByBudget.keySet(), true);
        validate(requestedByBudget, balances);

        List<Core_MDF_Outcome_Budget_Mapping__c> toInsert = new List<Core_MDF_Outcome_Budget_Mapping__c>();
        List<Core_MDF_Outcome_Budget_Mapping__c> toUpdate = new List<Core_MDF_Outcome_Budget_Mapping__c>();
        for (Id budgetId : requestedByBudget.keySet()) {
            BudgetBalance balance = balances.get(budgetId);
            Decimal consumed = requestedByBudget.get(budgetId);
            Decimal remaining = (balance.remainingAmount - consumed).setScale(2);

            if (balance.mapping == null) {
                toInsert.add(new Core_MDF_Outcome_Budget_Mapping__c(
                    Core_MDF_BudgetId__c = budgetId,
                    Core_MDF_Active_Ind__c = true,
                    Core_MDF_Total_Amt_on_Budget_nbr__c = balance.standardAmount,
                    Core_MDF_Consumed_Amount_nbr__c = consumed,
                    Core_MDF_Remaining_Amount_nbr__c = remaining
                ));
            } else if (consumed > 0) {
                Decimal previouslyConsumed = balance.mapping.Core_MDF_Consumed_Amount_nbr__c != null
                    ? balance.mapping.Core_MDF_Consumed_Amount_nbr__c : 0;
                balance.mapping.Core_MDF_Consumed_Amount_nbr__c = (previouslyConsumed + consumed).setScale(2);
                balance.mapping.Core_MDF_Remaining_Amount_nbr__c = remaining;
                toUpdate.add(balance.mapping);
            }
        }
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    private static void validate(Map<Id, Decimal> requestedByBudget, Map<Id, BudgetBalance> balances) {
        for (Id budgetId : requestedByBudget.keySet()) {
            BudgetBalance balance = balances.get(budgetId);
            if (balance == null) {
                throwError('The selected budget could not be found or you do not have access to it.');
            }
            if (requestedByBudget.get(budgetId) > balance.remainingAmount + TOLERANCE) {
                throwError('Amount entered for ' + balance.budgetName + ' (' + requestedByBudget.get(budgetId).setScale(2)
                    + ') exceeds the available budget amount (' + balance.remainingAmount.setScale(2) + ').');
            }
        }
    }

    /* Total requested amount per budget; the same budget selected in several rows is summed */
    private static Map<Id, Decimal> getRequestedAmounts(Object rawAllocations) {
        Map<Id, Decimal> requestedByBudget = new Map<Id, Decimal>();
        if (rawAllocations == null) {
            return requestedByBudget;
        }
        List<BudgetAllocation> allocations;
        try {
            allocations = (List<BudgetAllocation>) JSON.deserialize(
                JSON.serialize(rawAllocations), List<BudgetAllocation>.class);
        } catch (Exception e) {
            throwError('Invalid budget allocation data.');
        }
        for (BudgetAllocation allocation : allocations) {
            if (allocation == null) {
                continue;
            }
            Id budgetId = toBudgetId(allocation.budgetId);
            Decimal amount = allocation.allocatedAmount != null ? allocation.allocatedAmount : 0;
            if (amount < 0) {
                throwError('Amount cannot be negative.');
            }
            Decimal current = requestedByBudget.containsKey(budgetId) ? requestedByBudget.get(budgetId) : 0;
            requestedByBudget.put(budgetId, (current + amount).setScale(2));
        }
        return requestedByBudget;
    }

    private static Id toBudgetId(String rawId) {
        try {
            Id budgetId = Id.valueOf(rawId);
            if (budgetId.getSObjectType() == PartnerMarketingBudget.SObjectType) {
                return budgetId;
            }
        } catch (Exception e) {
            // handled below
        }
        throwError('One or more selected budgets are invalid. Please select a valid budget.');
        return null;
    }

    private static void throwError(String message) {
        AuraHandledException ex = new AuraHandledException(message);
        ex.setMessage(message);
        throw ex;
    }
}