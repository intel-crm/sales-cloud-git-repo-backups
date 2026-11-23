public without sharing class UpsertProductInboundStagingBatch implements Database.Batchable<SObject>{
    public Database.queryLocator start(Database.BatchableContext BC) {
        return Database.getQuerylocator([Select Id,level_1_epm_id__c,level_2_epm_id__c,level_3_epm_id__c,level_4_epm_id__c,level_5_epm_id__c,Core_Unique_ID__c From Product_Inbound_Staging__c]);
    }
    public void execute(Database.BatchableContext BC, List<SObject> productStaging) {
        for (Product_Inbound_Staging__c pis : (List<Product_Inbound_Staging__c>)productStaging) {
            String l1 = pis.level_1_epm_id__c;
            String l2 = pis.level_2_epm_id__c;
            String l3 = pis.level_3_epm_id__c;
            String l4 = pis.level_4_epm_id__c;
            String l5 = pis.level_5_epm_id__c;
            
            pis.Core_Unique_ID__c = 
                (l5 != null ? l5+';' : '')+
                (l4 != null ? l4 + ';' : '') +
                (l3 != null ? l3 +';' : '')+
                (l2 != null ? l2 + ';' : '')+
                l1;
            
        }
        UPDATE productStaging;
    }
    public void finish(Database.BatchableContext BC) {
    } 
}