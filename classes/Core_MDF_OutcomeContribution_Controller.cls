public without sharing class Core_MDF_OutcomeContribution_Controller {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getVirtualAndNodeAccount(String recordId) {
        List<String> allAccountName = new List<String>();
        
        if (String.isNotBlank(recordId)) {
            // Step 1: Fetch related PartnerMarketingBudget
            List<PartnerMarketingBudget> budgetList = [SELECT Id, Core_MDF_Budget_Partner__c, Core_MDF_Budget_Partner__r.Name FROM PartnerMarketingBudget WHERE Id = :recordId LIMIT 1];
            
            if (!budgetList.isEmpty()) {
                PartnerMarketingBudget budget = budgetList[0];
                Id partnerAccId = budget.Core_MDF_Budget_Partner__c;
                
                // Add the Partner Account name
                if (budget.Core_MDF_Budget_Partner__r != null) {
                    allAccountName.add(budget.Core_MDF_Budget_Partner__r.Name);
                }
                
                // Step 2: Fetch child Accounts (Node Accounts)
                if (partnerAccId != null) {
                    for (Account acc : [ SELECT Id, Name FROM Account WHERE Core_MDF_Parent_Fund_Account__c = :partnerAccId]) {
                        allAccountName.add(acc.Name);
                    }
                }
            }
        }
        
        return allAccountName;
    }    
}