public class UCD_ACM_AccountPlatformEvent_Batch implements Database.Batchable<sObject>{
	public Database.QueryLocator start(Database.BatchableContext BC){
      String query = 'Select Content__c,Content_Type__c,Message_Status__c,Module_Name__c,Queue_Type__c,Source_System__c from ACM_Integration_Message_Queue__c where (Message_Status__c = \'New\' or Message_Status__c = \'Error\') and Retry_Count__c <= 3 and Module_Name__c=\'ACM\' and Content_Type__c = \'AccountId\' and Queue_Type__c =\'Outbound\' and Source_System__c = \'Reltio\' ORDER BY LastModifiedDate';
      return Database.getQueryLocator(query);
   }
    public void execute(Database.BatchableContext BC, List<ACM_Integration_Message_Queue__c> integrationMessages){
      if(integrationMessages != null && integrationMessages.size() > 0){
         Set<Id> accountIds = new Set<Id>();
         for(ACM_Integration_Message_Queue__c integrationMessage : integrationMessages){
             accountIds.add(integrationMessage.Content__c);
         }
         if(accountIds.size() > 0){
            UCD_ACM_AccountService.publishAccountChangeEvent(accountIds);
         }
      }
    }
    public void finish(Database.BatchableContext BC){
   }
}