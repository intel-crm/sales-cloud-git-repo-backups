trigger PricingRoutingRuleTrigger on Pricing_Routing_Rules__c (after insert, after update) {
	 Set<String> updatedDecisionTableSet = new Set<String>();
    
    for (Pricing_Routing_Rules__c routeRuleRec : Trigger.new) {
        String decisionTableAPIName = routeRuleRec.Pricing_Decision_Table_Name_Txt__c; 
        if (String.isNotBlank(decisionTableAPIName)) {
            updatedDecisionTableSet.add(decisionTableAPIName);
        }
    }
    
    List<Pricing_Decision_Table_Refresh__e> eventsToPublish = new List<Pricing_Decision_Table_Refresh__e>();
    for(String decisionTableName : updatedDecisionTableSet) {
        eventsToPublish.add(new Pricing_Decision_Table_Refresh__e(
            Pricing_Decision_Table_Name_Txt__c = decisionTableName
        ));  
    }
   
    List<Database.SaveResult> results = EventBus.publish(eventsToPublish);
    for (Database.SaveResult sr : results) {
        if (!sr.isSuccess()) {
            System.debug(LoggingLevel.ERROR, 'Publish error: ' + sr.getErrors());
        }
    }
    /*if (!updatedDecisionTableSet.isEmpty()) {
        System.enqueueJob(new Pricing_DecisionTableRefresh_Queue( new List<String>(updatedDecisionTableSet), 0));
    }*/
}