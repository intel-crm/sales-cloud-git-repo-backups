/**************************************************************************************
Apex Class Name : Core_Draco_RoleCleanup_Batch
Version     : 1.0 
Created Date: 22nd Aug 2024
Description : Batch to cleanup account based portal roles 
* Modification Log : 
* Developer                 Date               		Description
* ----------------------------------------------------------------------------
* Sharmila                  22-Aug-2024             	Original Version
*************************************************************************************/
global without sharing class Core_Draco_RoleCleanup_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public static String BatchCompletionResult = '';
    public static String BatchCompletionMessage = '';
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        String query = '';
        Integer queryLimit = Integer.valueOf(Label.Core_Draco_RoleCleanup_BatchSize);
        if(Test.isRunningTest()){
            query='SELECT Id, Name, DeveloperName, PortalAccountId FROM Userrole WHERE DeveloperName = \'MobileNetworksPartnerUser\'';
        } else{
            query='SELECT Id, Name, DeveloperName, PortalAccountId FROM Userrole WHERE PortalType IN (\'Partner\', \'CustomerPortal\') AND PortalAccountId NOT IN (SELECT AccountId FROM User WHERE UserType IN (\'PowerPartner\', \'PowerCustomerSuccess\', \'CustomerSuccess\')) LIMIT :queryLimit';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> portalRolesToDelete) {
        // Delete the records in the current scope
        try {
            if (!portalRolesToDelete.isEmpty()) {
                Database.delete(portalRolesToDelete, false);
                BatchCompletionMessage = 'Core_Draco_RoleCleanup_Batch batch Successful.';
                BatchCompletionResult = 'Successfully executed batch and deleted ' + portalRolesToDelete.size() + ' roles';
                    
            }
        } catch (DmlException e) {
            BatchCompletionMessage = 'Core_Draco_RoleCleanup_Batch batch Failed.';
            BatchCompletionResult = 'Error in deleting Roles following roles: ' + portalRolesToDelete + '. Exception Occured: ' + e.getMessage();
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        String LOG_ENTRY_ORIGIN   = 'SFDC';
        String LOG_ENTRY_PROJECT  = 'Entitlement';
        String LOG_ENTRY_INFO     = 'info';
        String LOG_ENTRY_SCOPE    = 'Portal Role Deletion';
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
                Core_Origin__c = LOG_ENTRY_ORIGIN,
                Core_Project__c = LOG_ENTRY_PROJECT,
                Core_Scope__c = LOG_ENTRY_SCOPE,
                Core_Severity__c = LOG_ENTRY_INFO,
                Core_Message__c = BatchCompletionMessage,
                Core_When__c = system.now(),
                Core_Details__c = BatchCompletionResult,
                Core_sObjectId__c = null,
                Core_sObjectType__c = null,
                Core_Tags__c = null
            );
         insert objCLE;
    }
}