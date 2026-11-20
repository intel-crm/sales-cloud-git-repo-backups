@isTest
public class UCD_ACM_UpdateHierarchyFieldsQueTest {
	private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
    
     @TestSetup
    private static void setCommonData(){
        // Create a reltio user
        User us = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration'].Id,
            FirstName = 'Reltio',
            LastName = 'SFDC Connector',
            Email = 'Test@example.com',
            Username = 'Test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'Test Title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert us;
        // Create Parent Account
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        insert parentAccount;

        // Create End Customer Deal Account Intermediate1 child
        Account intChildAcc1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestIntChildAccount1','End Customer Deal Account','UNFD_INTRMD_CUST');
        intChildAcc1.parentId = parentAccount.Id;
        insert intChildAcc1;

        // Create End Customer Deal Account Intermediate2 child
        Account intChildAcc2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestIntChildAccount2','End Customer Deal Account','UNFD_INTRMD_CUST');
        intChildAcc2.parentId = intChildAcc1.Id;
        insert intChildAcc2;

        // Create End Customer Deal Account Country child
        Account ctryChildAcc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestCtryChildAccount','End Customer Deal Account','UNFD_CTRY_CUST');
        ctryChildAcc.parentId = intChildAcc2.Id;
        insert ctryChildAcc;

		
        // Create End Customer Deal Account
        Account acc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestChildAccount','End Customer Deal Account','UNFD_GLBL_CUST');
        acc.parentId = parentAccount.Id;
        acc.Core_Survivor_Account_Id__c = parentAccount.Id;
        insert acc;
        
        // Create Requested Account
        Account reuestedAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestChildAccount1','Requested Account','UNFD_GLBL_CUST');
        insert reuestedAccount;
        
        // Create Business Type
        List<Business_Types__c> businessTypes = new List<Business_Types__c>();
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Direct Price Exception','DIR_PRC_EXCPT'));
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Supply Demand Revenue','SD_REV'));
        insert businessTypes;
        
        // Create Account Business Type
        List<Account_Business_Types__c> accountBusinessTypes = new List<Account_Business_Types__c>();
        For(Business_Types__c businessType : businessTypes){
            accountBusinessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createAccountBusinessType(acc.Id,businessType.Id));
        }
        insert accountBusinessTypes;
        
        // Create Parent Account With Business Party Id
        List<Account> accountToInsertForBpId = new List<Account>();
        Account parentAccountWithBpId1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccountWithBpId1','Intel Account','UNFD_GLBL_CUST');
        parentAccountWithBpId1.Core_Business_Party_Id__c = '12345';
        insert parentAccountWithBpId1;
        
        Account parentAccountWithBpId2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccountWithBpId2','Intel Account','UNFD_GLBL_CUST');
        parentAccountWithBpId2.Core_Business_Party_Id__c = '123456';
        insert parentAccountWithBpId2;
        
        Account parentAccountWithBpId3 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccountWithBpId3','End Customer Deal Account','UNFD_GLBL_CUST');
        parentAccountWithBpId3.Core_Business_Party_Id__c = '123456';
        insert parentAccountWithBpId3;
        
        //Create Child Account With Business Party Id
        Account intChildAccWithBpId1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestChildAccountWithBpId1','Intel Account','UNFD_INTRMD_CUST');
        intChildAccWithBpId1.Core_Business_Party_Id__c = '12345';
        intChildAccWithBpId1.ParentId = parentAccountWithBpId3.Id;
        system.runAs(us){
            insert intChildAccWithBpId1;
        }
        
        Account intChildAccWithBpId2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestChildAccountWithBpId2','End Customer Deal Account','UNFD_INTRMD_CUST');
        intChildAccWithBpId2.Core_Business_Party_Id__c = '123456';
        intChildAccWithBpId2.parentId = parentAccountWithBpId2.Id;
        system.runAs(us){
            insert intChildAccWithBpId2;
        }
        
        Account intChildAccWithBpId3 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestChildAccountWithBpId3','Intel Account','UNFD_INTRMD_CUST');
        intChildAccWithBpId3.Core_Business_Party_Id__c = '12';
        intChildAccWithBpId3.parentId = parentAccountWithBpId2.Id;
        system.runAs(us){
            insert intChildAccWithBpId3;
        }
        
        Account intChildAccWithBpId4 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestChildAccountWithBpId4','End Customer Deal Account','UNFD_INTRMD_CUST');
        intChildAccWithBpId4.Core_Business_Party_Id__c = '1234';
        intChildAccWithBpId4.parentId = parentAccountWithBpId1.Id;
        system.runAs(us){
            insert intChildAccWithBpId4;
        }

    }
    
    @isTest
    private static void whenUpdateHierarchyFieldsWithTrue(){
        Account account = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Simplified_Local_Language_Nm__c,Unified_Hierarchy_View__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'TestParentAccount' LIMIT 1];
        Set<Id> loggingAccountIds = new Set<Id>(); 
        loggingAccountIds.add(account.Id);
        UCD_ACM_UpdateHierarchyFieldsQueueable updateJob = new UCD_ACM_UpdateHierarchyFieldsQueueable(loggingAccountIds);
        test.startTest();
        System.enqueueJob(updateJob);
        test.stopTest();
        System.assertNotEquals(updateJob,null);

    }
}