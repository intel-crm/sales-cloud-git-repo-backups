trigger PricingDecisionTableEventTrigger on Pricing_Decision_Table_Refresh__e (after insert) {
    // A Set automatically removes duplicate API names within the same event batch
    Set<String> uniqueTableNames = new Set<String>();
    
    for (Pricing_Decision_Table_Refresh__e eventRecord : Trigger.New) {
        if (String.isNotBlank(eventRecord.Pricing_Decision_Table_Name_Txt__c)) {
            uniqueTableNames.add(eventRecord.Pricing_Decision_Table_Name_Txt__c.trim());
        }
    }
    
    if (!uniqueTableNames.isEmpty()) {
        System.enqueueJob(new Pricing_DecisionTableRefresh_Queue(new List<String>(uniqueTableNames), 0));
    }
}