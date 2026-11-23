global class CCP_HealthCheck_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
     global Database.QueryLocator start(Database.BatchableContext bc) {
            String query;
            query='Select Id, Name, is_active__c, params__c, method__c, Authentication_Type__c, AccessToken__c, client_id__c, client_secret__c, User__r.Email, User__r.Id	 from CCP_Apis_Healthheck__c where is_active__c=True' ;
            return Database.getQueryLocator(query);
        }
    
    public void execute(Database.BatchableContext BC, list<CCP_Apis_Healthheck__c> scope){
        CCP_Healthcheck.apisHealthCheck(scope);
    }
    public void finish(Database.BatchableContext BC){
        
    }
}