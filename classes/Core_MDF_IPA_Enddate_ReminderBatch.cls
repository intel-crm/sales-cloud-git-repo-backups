public class Core_MDF_IPA_Enddate_ReminderBatch implements Database.Batchable<sObject>, Database.Stateful {
    Set<Id> pfrAccIdSet = new Set<Id>();
    public Database.QueryLocator start(Database.BatchableContext bc){
        String INTEL_PARTNER_ALLIANCE = Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM;
        String PLANNED = Core_MDF_CCP_ConstantClass.PFR_PLANNED_STATUS;
        Date TOMORROW_DATE = System.today() + 1;
        
        String query = 'SELECT Id ,Core_MDF_Fund_Request_Status__c,Core_MDF_Ultimate_Account_Id__c,'+
            'Core_MDF_ToBeClosedDate__c, Core_MDF_Program__c, ChannelPartnerId, Core_MDF_End_Date__c FROM PartnerFundRequest' +
            'WHERE Core_MDF_Program__c =:INTEL_PARTNER_ALLIANCE AND Core_MDF_Fund_Request_Status__c =: PLANNED'+
            'AND Core_MDF_End_Date__c =: TOMORROW_DATE' ;
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext batchableContext, List<PartnerFundRequest> pfrList) { 
        //FETCH ACCOUNT TO QUERY PNUM
        for(PartnerFundRequest pfr:pfrList){
            if(pfr.ChannelPartnerId !=null){
                pfrAccIdSet.add(pfr.ChannelPartnerId);
            }
        }
    }
    
    public void finish (Database.BatchableContext batchableContext) {
        //SEND EMAIL
        if(!pfrAccIdSet.isEmpty()){
             Core_MDF_ScheduledNotificationHandler.notifyIPAClaimSubmitter(pfrAccIdSet);
        }
    }
}