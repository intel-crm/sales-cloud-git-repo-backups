/******************************************************************************************************************************************
Class Name  : ER_Batch_AE_ACM_Integration
Test Class Name : ER_Batch_AE_ACM_Integration_Test, Coverage:89%
Version     : 1.0 
Created Date: 22 MAY 2024
Function    : Handles Logic to generate payload for changes in Account, Contact and CMF Group in batch
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Durga Bhavani            22/05/2024              Original version
*	****************************************************************************************************************************************/
public class ER_Batch_AE_ACM_Integration implements Database.Batchable<sObject>{
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_Batch_AE_ACM_Integration';
    public static string params = '';
    public static string moduleName = System.Label.ER_ACM_Module_Name;
    public static string accountIntegration = System.Label.ER_ACM_Content_AccountId; 
    public static string contactIntegration = System.Label.ER_ACM_Content_ContactId; 
    public static string CMFGIntegration = System.Label.ER_ACM_Content_CMFG; 
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        if(Test.isRunningTest()) {
            query = 'Select Content__c,Content_Type__c,Message_Status__c,Module_Name__c,Queue_Type__c from ACM_Integration_Message_Queue__c where Message_Status__c = \'New\' and Module_Name__c=:moduleName and Queue_Type__c =\'Outbound\'  limit 200';
        }
        else
        {
            query = 'Select Content__c,Content_Type__c,Message_Status__c,Module_Name__c,Queue_Type__c from ACM_Integration_Message_Queue__c where Message_Status__c = \'New\' and Module_Name__c=:moduleName and Queue_Type__c =\'Outbound\' '; 
        }
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<ACM_Integration_Message_Queue__c> integrationMessages){
        try{
            System.debug('Integration Messages'+integrationMessages.size());
            if(!integrationMessages.isEmpty()) {
                Set<Id> CMFGIds = new Set<Id>();
                Set<Id> AccountIds = new Set<Id>();
                Set<Id> ContactIds = new Set<Id>();
                for(ACM_Integration_Message_Queue__c integrationMessage : integrationMessages) {
                    
                    if(integrationMessage.Content_Type__c == CMFGIntegration ){
                        CMFGIds.add(integrationMessage.Content__c);   
                    }
                    else if(integrationMessage.Content_Type__c == accountIntegration){
                        AccountIds.add(integrationMessage.Content__c);
                    }
                    else if(integrationMessage.Content_Type__c == contactIntegration){
                        ContactIds.add(integrationMessage.Content__c);
                    }    
                }
                
                if(!CMFGIds.isEmpty()){
                    ER_SalesCloud_Integration.GenerateCMFOutboundMessage(CMFGIds);
                }
                if(!AccountIds.isEmpty()){
                    ER_SalesCloud_Integration.GenerateAnEAccountOBM(AccountIds);
                }
                if(!ContactIds.isEmpty()){
                    ER_SalesCloud_Integration.GenerateContactOBMAnE(ContactIds);
                }
                
            }
        }
        catch (Exception ex) {
            System.debug('exception'+ex);
            ER_SalesCloud_Integration.createLogEntry('ER_Batch_AE_ACM_Integration', ex, LOG_ENTRY_ERROR, 'High',params);   
            
        }
        
    }
    public void finish(Database.BatchableContext bc) {
    }
    
}