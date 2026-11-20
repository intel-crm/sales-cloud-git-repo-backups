trigger PricingRoutingRuleTrigger on Pricing_Routing_Rules__c (after insert, after update) {
	 Set<String> updatedDecisionTableSet = new Set<String>();
    
    for (Pricing_Routing_Rules__c routeRuleRec : Trigger.new) {
        String decisionTableAPIName = routeRuleRec.Pricing_Decision_Table_Name_Txt__c; 
        if (String.isNotBlank(decisionTableAPIName)) {
            updatedDecisionTableSet.add(decisionTableAPIName);
        }
    }
    
    if (!updatedDecisionTableSet.isEmpty()) {
        System.enqueueJob(new Pricing_DecisionTableRefresh_Queue( new List<String>(updatedDecisionTableSet), 0));
    }
}