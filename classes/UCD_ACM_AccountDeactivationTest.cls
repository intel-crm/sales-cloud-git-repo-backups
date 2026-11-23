@isTest
public class UCD_ACM_AccountDeactivationTest {
    
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
    
    @TestSetup
    private static void setCommonData() {
        // Delete any existing data
        delete [SELECT Id FROM Account_Business_Types__c WHERE Name LIKE 'Test%'];
        delete [SELECT Id FROM Core_Account_Compliance_Watch_List__c WHERE Name LIKE 'Test%'];
        delete [SELECT Id FROM Account WHERE Name = 'TestIntelAccount'];
        
        // Create user	
        Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration'].Id;
        User us = UCD_ACM_Cntrlr_TestDataInitialization.createUser(ProfileId);
        insert us;
        
        // Create Intel Account
        Account intelAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestIntelAccount', 'Intel Account', 'UNFD_GLBL_CUST');
        insert intelAccount;
        
        // Create Business Types
        List<Business_Types__c> businessTypes = new List<Business_Types__c>();
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Sales CRM', 'SLS_CRM'));
        businessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Supply Demand Revenue', 'SD_REV'));
        insert businessTypes;
        
        // Create Account Business Types
        List<Account_Business_Types__c> accountBusinessTypes = new List<Account_Business_Types__c>();
        for (Business_Types__c businessType : businessTypes) {
            accountBusinessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createAccountBusinessType(intelAccount.Id, businessType.Id));
        }
        insert accountBusinessTypes;
        
        // Create Compliance Watch List records
        List<Core_Account_Compliance_Watch_List__c> complianceWatchLists = new List<Core_Account_Compliance_Watch_List__c>();
        complianceWatchLists.add(UCD_ACM_Cntrlr_TestDataInitialization.createComplianceWatchList(intelAccount.Id, 'NOTRDOUT'));
        complianceWatchLists.add(UCD_ACM_Cntrlr_TestDataInitialization.createComplianceWatchList(intelAccount.Id, 'DPL'));
        insert complianceWatchLists;
    }
    
    @isTest
    private static void whenAccountDeactivated() {
        // Query for accounts and compliance watch lists
        Map<Id, Account> accountById = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Name = 'TestIntelAccount']);
        List<Core_Account_Compliance_Watch_List__c> lstAllAcctCWL = [SELECT Id FROM Core_Account_Compliance_Watch_List__c WHERE Core_Account_Id__c IN :accountById.keySet()];
        
        // Before running the test, verify that data exists
        System.assert(!accountById.isEmpty(), 'Account should exist');
        System.assert(!lstAllAcctCWL.isEmpty(), 'Compliance Watch List records should exist');
        
        // Validate Account Business Types before deletion
        List<Account_Business_Types__c> abtBefore = [SELECT Id FROM Account_Business_Types__c WHERE Account__c IN :accountById.keySet()];
        System.assertEquals(2, abtBefore.size(), 'There should be 2 Account Business Types before deactivation');
        
        Test.startTest();
        UCD_ACM_AccountDeactivation.removeUCDAttributes(accountById, lstAllAcctCWL);
        Test.stopTest();
        
        // Post conditions: check that CWL records are deleted
        List<Core_Account_Compliance_Watch_List__c> lstCWLAfter = [SELECT Id FROM Core_Account_Compliance_Watch_List__c WHERE Core_Account_Id__c IN :accountById.keySet()];
        System.assertEquals(0, lstCWLAfter.size(), 'CWL records should be deleted');
        
        // Check that Account Business Types are deleted
        List<Account_Business_Types__c> abtAfter = [SELECT Id FROM Account_Business_Types__c WHERE Account__c IN :accountById.keySet()];
        System.assertEquals(0, abtAfter.size(), 'Account Business Type records should be deleted');
    }
    
    @isTest
    private static void testRemoveBusinessTypeNoRecords() {
        Map<Id, Account> emptyAccountById = new Map<Id, Account>();
        List<Core_Account_Compliance_Watch_List__c> emptyCWLList = new List<Core_Account_Compliance_Watch_List__c>();
        
        Test.startTest();
        UCD_ACM_AccountDeactivation.removeUCDAttributes(emptyAccountById, emptyCWLList);
        Test.stopTest();
        
        // Assert that no Account Business Types were removed due to empty inputs
        List<Account_Business_Types__c> abtAfter = [SELECT Id FROM Account_Business_Types__c WHERE Account__c IN :emptyAccountById.keySet()];
        List<Core_Account_Compliance_Watch_List__c> cwlAfter = [SELECT Id FROM Core_Account_Compliance_Watch_List__c WHERE Core_Account_Id__c IN :emptyAccountById.keySet()];
        
        System.assertEquals(0, abtAfter.size(), 'No Account Business Types should be deleted because no input was provided.');
        System.assertEquals(0, cwlAfter.size(), 'No CWL records should be deleted because no input was provided.');
    }
    
    @isTest
    private static void testRemoveOnlyCWL() {
        // Query for the Intel account
        Map<Id, Account> accountById = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Name = 'TestIntelAccount']);
        List<Core_Account_Compliance_Watch_List__c> lstAllAcctCWL = [SELECT Id FROM Core_Account_Compliance_Watch_List__c WHERE Core_Account_Id__c IN :accountById.keySet()];
        
        // Empty map for accounts (no business types will be deleted)
        Map<Id, Account> emptyAccountById = new Map<Id, Account>();
        
        Test.startTest();
        UCD_ACM_AccountDeactivation.removeUCDAttributes(emptyAccountById, lstAllAcctCWL);
        Test.stopTest();
        
        // Verify CWL records are deleted but business types remain
        List<Core_Account_Compliance_Watch_List__c> lstCWLAfter = [SELECT Id FROM Core_Account_Compliance_Watch_List__c WHERE Core_Account_Id__c IN :accountById.keySet()];
        System.assertEquals(0, lstCWLAfter.size(), 'CWL records should be deleted');
        
        // Check that Account Business Types are not deleted (they should still exist)
        List<Account_Business_Types__c> abtAfter = [SELECT Id FROM Account_Business_Types__c WHERE Account__c IN :accountById.keySet()];
        System.assertNotEquals(0, abtAfter.size(), 'Account Business Types should not be deleted');
    }
    
    @isTest
    private static void testRemoveOnlyBusinessTypes() {
        Map<Id, Account> accountById = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Name = 'TestIntelAccount']);
        List<Core_Account_Compliance_Watch_List__c> emptyCWLList = new List<Core_Account_Compliance_Watch_List__c>();
        
        Test.startTest();
        UCD_ACM_AccountDeactivation.removeUCDAttributes(accountById, emptyCWLList);
        Test.stopTest();
        
        // List<Core_Account_Compliance_Watch_List__c> lstCWLAfter = [SELECT Id FROM Core_Account_Compliance_Watch_List__c WHERE Core_Account_Id__c IN :accountById.keySet()];
        // System.assertEquals(0, lstCWLAfter.size(), 'No CWL records should be deleted, as none were passed in');
        
        List<Account_Business_Types__c> abtAfter = [SELECT Id FROM Account_Business_Types__c WHERE Account__c IN :accountById.keySet()];
        System.assertEquals(0, abtAfter.size(), 'Account Business Type records should be deleted');
    }
    
    @isTest
    private static void testRemoveHierarchyAttr() {
        Account acc = [SELECT Id,Core_Unified_Global_Customer_BP_Id__c,Core_Unified_Global_Customer_Name__c,Core_Unified_Intermediate_Customer_BP_Id__c,Core_Unified_Intermediate_Customer_Name__c,Core_Unified_Intermdt_Customer_2_BP_Id__c,Core_Unified_Intermdt_Customer_2_Name__c,ParentId,Core_Parent_Business_Party_Id__c FROM Account WHERE Name = 'TestIntelAccount' LIMIT 1];
        Test.startTest();
        acc = UCD_ACM_AccountDeactivation.removeHierarchyAttr(acc);
        Test.stopTest();
        System.assertEquals(null, acc.Core_Unified_Global_Customer_BP_Id__c);
    }
}