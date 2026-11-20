public class UCD_ACM_AccountPlatformEvent_Batch implements Database.Batchable<sObject>{
	
   public Database.QueryLocator start(Database.BatchableContext bc) {

      String query = '';
      if(!Test.isRunningTest()) {
         Datetime delayTime = Datetime.now().addMinutes(Integer.valueOf(System.Label.UCD_PleaformEvents_DeplayTime)); 
          query = 'Select Content__c,Content_Type__c,Message_Status__c,Module_Name__c,Queue_Type__c,Source_System__c from ACM_Integration_Message_Queue__c where (Message_Status__c = \'New\' or Message_Status__c = \'Error\') and Retry_Count__c <= 3 and ((Module_Name__c=\'ACM\' and Content_Type__c = \'AccountId\' and Queue_Type__c =\'Outbound\' and Source_System__c = \'Reltio\' AND LastModifiedDate <= :delayTime) OR (Module_Name__c=\'SBR\' and Content_Type__c = \'ARQId\' and Queue_Type__c =\'Outbound\' and Source_System__c = \'SBR\')) ORDER BY LastModifiedDate';
      } else {
          query = 'Select Content__c,Content_Type__c,Message_Status__c,Module_Name__c,Queue_Type__c,Source_System__c from ACM_Integration_Message_Queue__c where (Message_Status__c = \'New\' or Message_Status__c = \'Error\') and Retry_Count__c <= 3 and ((Module_Name__c=\'ACM\' and Content_Type__c = \'AccountId\' and Queue_Type__c =\'Outbound\' and Source_System__c = \'Reltio\') OR (Module_Name__c=\'SBR\' and Content_Type__c = \'ARQId\' and Queue_Type__c =\'Outbound\' and Source_System__c = \'SBR\')) ORDER BY LastModifiedDate';
      }
      return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext bc, List<ACM_Integration_Message_Queue__c> integrationMessages) {

      if(!integrationMessages.isEmpty()) {
         
         Set<Id> accountIds = new Set<Id>();
         Set<Id> arqIds = new Set<Id>();

         for(ACM_Integration_Message_Queue__c integrationMessage : integrationMessages) {
            if(integrationMessage.Content_Type__c == 'AccountId') {
               accountIds.add(integrationMessage.Content__c);
            }
            else if (integrationMessage.Content_Type__c == 'ARQId') {
               arqIds.add(integrationMessage.Content__c);
            }
         }

         if(!accountIds.isEmpty()) {
            UCD_ACM_AccountService.publishAccountChangeEvent(accountIds);
         }

         if(!arqIds.isEmpty()) {
            UCD_ACM_AccountService.publishAccountRequestPlatformEvent(arqIds);
         }
      }
   }

   public void finish(Database.BatchableContext bc) {
   }
}