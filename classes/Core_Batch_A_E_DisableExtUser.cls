/*************************************************************************************************************************************************
Apex Class Name : Core_Batch_A_E_DisableExtUser 
Created Date    : 18/09/2020
Function        : This batch apex is used to disable partner/customer user and to update user's FederationIdentifier field value after 
				  deletion of User from AGS system to overcome IPS issue. 
**************************************************************************************************************************************************
* Developer                   Date                   Description
* ------------------------------------------------------------------------------------------------------------------------------------------------
* Sonali Mehetre            18/09/2020             US731342 - Pipeline: IPS Issue fix implementation

*************************************************************************************************************************************************/

global class Core_Batch_A_E_DisableExtUser implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strEmailDomain = '%@intel.com';
        List<String> lstProfilesToConsider = System.Label.Core_A_E_DisableExtUsers_Profile.split(',');
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id, IsActive, IsPortalEnabled, FederationIdentifier, Core_Is_FederationId_Valid_Ind__c FROM User'+
            			' WHERE IsActive = FALSE AND IsPortalEnabled = TRUE AND Contact.Core_Login_Status__c IN (\'Deleted\',\'Downgrade to B2C\') AND'+
            			' Core_Is_FederationId_Valid_Ind__c = FALSE AND (NOT Email Like :strEmailDomain) AND Profile.Name IN: lstProfilesToConsider';
           
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext BC, List<User> lstOfUser) {        
        // enqueue the job for processing
		System.enqueueJob(new Core_Batch_A_E_DisableExtUser_Queue(lstOfUser));
    }
    
    global void finish(Database.BatchableContext BC) { }
    
}