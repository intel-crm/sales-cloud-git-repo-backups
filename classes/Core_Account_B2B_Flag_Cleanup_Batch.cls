/**************************************************************************************
Apex Class Name : Core_Account_B2B_Flag_Cleanup_Batch 
Created Date: 4th Oct 2024
Description : Batch class to update Account B2B Flag to flase when associated contact B2B Flag is false
* Modification Log :
* Developer                 Date               		Description
* ----------------------------------------------------------------------------
* Madhumitha                 4th-Oct-2024             	Original Version
*************************************************************************************/
global without sharing class Core_Account_B2B_Flag_Cleanup_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public static String BatchCompletionResult = '';
    public static String BatchCompletionMessage = '';
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        String query = '';
        
        if(Test.isRunningTest()){
            query='SELECT Id, Core_B2B_Entitlement__c, (SELECT Id, Core_Contact_B2B_Indicator__c FROM Contacts WHERE Core_Contact_B2B_Indicator__c = TRUE) FROM Account WHERE Core_B2B_Entitlement__c = TRUE';
        } else{
            query='SELECT Id, Core_B2B_Entitlement__c, (SELECT Id, Core_Contact_B2B_Indicator__c FROM Contacts WHERE Core_Contact_B2B_Indicator__c = TRUE) FROM Account WHERE Core_B2B_Entitlement__c = TRUE';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> B2BFlagedAccountList) {
        // Delete the records in the current scope
        try {
            if (!B2BFlagedAccountList.isEmpty()) {
                List<Account> accList = new List<Account>();
                //Loop through all the Accounts where B2B flag is TRUE
                for(Account acc : B2BFlagedAccountList){
                    //Loop through all the contacts in that Account and see if at least 1 contact has Core_Contact_B2B_Indicator__c flag = TRUE
                    Boolean b2bAccount = false;
                    for(Contact con : acc.Contacts){
                        b2bAccount = true;
                    }
                    
                    if(!b2bAccount){
                        acc.Core_B2B_Entitlement__c = false;
                        accList.add(acc);
                    }
                }
                system.debug('Following ' + accList.Size() + ' Accounts are eligible to be updated to Core_B2B_Entitlement__c = False: ' + accList);
                Database.update (accList,false);
                BatchCompletionMessage = 'Core_Account_B2B_Flag_Cleanup_Batch batch Successful.';
                BatchCompletionResult = 'Successfully executed batch and deleted ' + accList.size(); 
            }
        } catch (DmlException e) {
            BatchCompletionMessage = 'Core_Account_B2B_Flag_Cleanup_Batch batch Failed.';
            BatchCompletionResult = 'Error in updating B2B flag on Accounts. Exception Occured: ' + e.getMessage();
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        String LOG_ENTRY_ORIGIN   = 'SFDC';
        String LOG_ENTRY_PROJECT  = 'Entitlement';
        String LOG_ENTRY_INFO     = 'info';
        String LOG_ENTRY_SCOPE    = 'Account B2B flag updation';
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