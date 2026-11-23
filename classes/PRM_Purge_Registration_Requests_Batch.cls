public class PRM_Purge_Registration_Requests_Batch implements Database.Batchable<sObject>{
    public static Database.QueryLocator start(Database.BatchableContext context){
        String statusNew = 'New';
        String nameIPA = 'Intel Partner Alliance';
        String statusPending = 'PENDING';
        System.debug('Batch query-> '+[Select id, PRM_Status__c, PRM_Email_Verification_Criteria__c,PRM_Channel_Program__c, PRM_Channel_Program__r.Name from PRM_Registration_Request__c]);
        String purgeRegreqs = 'select id, PRM_Status__c, PRM_Email_Verification_Criteria__c,PRM_Channel_Program__c, PRM_Channel_Program__r.Name from PRM_Registration_Request__c where CreatedDate < LAST_N_DAYS:46 and PRM_Channel_Program__r.name =: nameIPA and PRM_Email_Verification_Criteria__c =:statusPending and PRM_Status__c =: statusNew';
        List<PRM_Registration_Request__c> purgeRegreqsList = new List<PRM_Registration_Request__c>([select id, PRM_Status__c, PRM_Email_Verification_Criteria__c, PRM_Channel_Program__c, PRM_Channel_Program__r.Name from PRM_Registration_Request__c where CreatedDate < LAST_N_DAYS:46 and PRM_Channel_Program__r.name =: nameIPA and PRM_Email_Verification_Criteria__c =:statusPending and PRM_Status__c =: statusNew]);
        System.debug('purgeRegreqsList Size '+purgeRegreqsList.size()+' purgeRegreqsList '+purgeRegreqsList);
        return Database.getQueryLocator(purgeRegreqs);
    }
    public void execute(Database.BatchableContext context, List<PRM_Registration_Request__c> scope){
        PRM_Purge_Registration_Requests.purgeRecords(scope);
    }
    public void finish(Database.BatchableContext context){
    }
}