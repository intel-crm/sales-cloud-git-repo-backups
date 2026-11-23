trigger Core_MDF_RegionBudgetCampaign on Core_MDF_Regionwise_Campaign_Budget__c (before insert, before update, after insert, after update) {

    new Core_MDF_RegionBudgetHandler().run();
    
}