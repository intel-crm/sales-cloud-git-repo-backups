public class ER_Batch_AE_CMFGroup_Integration implements Database.Batchable<sObject>{
     public Database.QueryLocator start(Database.BatchableContext bc) {

      String query = '';
         query = 'Select Content__c,Content_Type__c,Message_Status__c,Module_Name__c,Queue_Type__c from ACM_Integration_Message_Queue__c where Message_Status__c = \'New\' and  Queue_Type__c =\'Outbound\' ORDER BY LastModifiedDate';
         return Database.getQueryLocator(query);
     }
     public void execute(Database.BatchableContext bc, List<ACM_Integration_Message_Queue__c> integrationMessages){

      if(!integrationMessages.isEmpty()) {
          Set<Id> CMFGIds= new Set<Id>();
          Set<Id> AccountIds= new Set<Id>();
          Set<Id> ContactIds= new Set<Id>();
          for(ACM_Integration_Message_Queue__c integrationMessage : integrationMessages) {
              
              if(integrationMessage.Content_Type__c =='A&E CMF Group Integration'){
               CMFGIds.add(integrationMessage.Content__c);
                  
              }
              if(integrationMessage.Content_Type__c =='A&E Account Integration'){
               AccountIds.add(integrationMessage.Content__c);
              }
              if(integrationMessage.Content_Type__c =='A&E Contact Integration'){
               ContactIds.add(integrationMessage.Content__c);
              }
              
              
          }
      }
     }
    public void finish(Database.BatchableContext bc) {
   }

}