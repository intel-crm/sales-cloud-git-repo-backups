global class Core_OpportunityLineItemBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, OpportunityId, Core_PW_Quantity__c, Core_PW_Sales_Price__c, 
                                         Core_Production_Win_Total_Price__c,Core_PW_Approved_Quantity__c, Core_PW_Approved_Sales_Price__c, 
                                         Core_PW_Approved_Total_Price__c
                                         FROM OpportunityLineItem
                                         WHERE Core_Status__c NOT IN ('Lost', 'Cancelled', 'Production lost', 
                                                                     'Production Cancelled', 'Delete In Progress (<15 min)')]);
    }
    
   global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope) {
    Map<Id, Decimal> opportunityIdToTotalPWAmount = new Map<Id, Decimal>();

    for (OpportunityLineItem oppProduct : scope) {
        if (oppProduct.Core_PW_Quantity__c != null && oppProduct.Core_PW_Sales_Price__c != null &&
            oppProduct.Core_PW_Quantity__c != 0 && oppProduct.Core_PW_Sales_Price__c != 0) {
            Decimal totalPWAmount = opportunityIdToTotalPWAmount.containsKey(oppProduct.OpportunityId) ?
                                    opportunityIdToTotalPWAmount.get(oppProduct.OpportunityId) : 0;
            totalPWAmount += oppProduct.Core_Production_Win_Total_Price__c;
            opportunityIdToTotalPWAmount.put(oppProduct.OpportunityId, totalPWAmount);
        }
    }

    List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

    for (Id opportunityId : opportunityIdToTotalPWAmount.keySet()) {
        opportunitiesToUpdate.add(new Opportunity(Id = opportunityId, 
                                                   Core_PW_Amount__c = opportunityIdToTotalPWAmount.get(opportunityId)));
    }

    update opportunitiesToUpdate;
}
    
    global void finish(Database.BatchableContext BC) {
     

    }
}