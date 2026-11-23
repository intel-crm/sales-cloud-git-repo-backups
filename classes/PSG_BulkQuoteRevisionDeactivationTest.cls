/****************************************************************************************************
Apex Class Name : PSG_BulkQuoteRevisionDeactivationTest
Version         : 1.0 
Created Date    : 12/04/2023
Function        : Test class for PSG_BulkQuoteRevisionDeactivationBatch
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Adarsh Parashar            12/04/2023                Created
*****************************************************************************************************/
@isTest
private class PSG_BulkQuoteRevisionDeactivationTest {
	/*@TestSetup
    private static void testSetup(){
        Account acc = PSG_Test_Utility.createAccount();
		List<User> boUserList = PSG_Test_Utility.createBOUser();
        System.runAs(boUserList[0]){
            SBQQ.TriggerControl.disable();
			List<SBQQ__Quote__c> quoteList = PSG_Test_Utility.createQuote(acc.id,null,2);
        }
    }
    @isTest
    private static void testQuoteRevision(){ 
        List<User> lstUsers2 = PSG_Test_Utility.createAdminUser();
        List<String> quoteNoList = new List<String>();
        List<SBQQ__Quote__c> quoteList = [Select Id,name,core_cpq_active_cb__c,core_cpq_quote_type_nm__c from SBQQ__Quote__c];
        System.runAs(lstUsers2[0]){
            Test.startTest();
            for(SBQQ__Quote__c quote : quoteList){
                quoteNoList.add(quote.Name);
            }
            PSG_BulkQuoteRevisionDeactivationBatch reviseBatch = new PSG_BulkQuoteRevisionDeactivationBatch();
            reviseBatch.quoteNoList = quoteNoList;
        	reviseBatch.action = 'Revise';
            database.executeBatch(reviseBatch);
            System.assertEquals('Quote Revised','Quote Revised');
            Test.stopTest();
        }		
	}
    @isTest
    private static void testQuoteDeactivation(){ 
        List<User> lstUsers2 = PSG_Test_Utility.createAdminUser();
        List<String> quoteNoList = new List<String>();
        List<SBQQ__Quote__c> quoteList = [Select Id,name,core_cpq_active_cb__c from SBQQ__Quote__c];
        System.runAs(lstUsers2[0]){
            Test.startTest();
            for(SBQQ__Quote__c quote : quoteList){
                quoteNoList.add(quote.Name);
            }
            PSG_BulkQuoteRevisionDeactivationBatch deactivateBatch = new PSG_BulkQuoteRevisionDeactivationBatch();
            deactivateBatch.quoteNoList = quoteNoList;
        	deactivateBatch.action = 'De-activate';
            database.executeBatch(deactivateBatch);
            System.assertEquals('Quote Deactivated','Quote Deactivated');
            Test.stopTest();
        }		
	}
    */
}