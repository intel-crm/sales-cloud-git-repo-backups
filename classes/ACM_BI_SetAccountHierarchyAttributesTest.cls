@isTest
public class ACM_BI_SetAccountHierarchyAttributesTest {
    
   private static UCD_ACM_ServiceContracts.IBeforeInsertAccountTrigger accountServiceInstance = new ACM_BI_SetAccountHierarchyAttributes();

    @TestSetup
    private static void setCommonData() {
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account1','Intel Account','UNFD_GLBL_CUST');
        parentAccount.Core_Data_Simplified_Account_Nm__c = 'Changed Parent1';
        insert parentAccount;
        
        Account childAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account2','Intel Account','UNFD_CTRY_CUST');
        childAccount.Core_Data_Simplified_Account_Nm__c = 'Changed Child1';
        insert childAccount;
        
        Account parentAccount2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account3','Intel Account','UNFD_INTRMD_CUST');
        parentAccount2.Core_Data_Simplified_Account_Nm__c = 'Changed Child2';
        insert parentAccount2;
        
        Account rejectedAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account4','Rejected Account','UNFD_CTRY_CUST');
        insert rejectedAccount;
        
        Account requestedAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account5','Requested Account','UNFD_CTRY_CUST');
        insert requestedAccount;
        
        Account nullAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account6','Intel Account','');
        insert nullAccount;
       
    }
    
    @isTest
    private static void customerTypeException(){
        List<Account> globalCustomer = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account1' )];       
        
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account3' )];       
        
        List<Account> accountsAfterUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account3')];
        accountsAfterUpdate[0].Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        
        Test.startTest();
        	accountServiceInstance.execute(new List<Account> (accountsAfterUpdate));
        Test.stopTest();
        
        System.assertEquals(globalCustomer[0].Core_Customer_Aggregation_Type__c, accountsAfterUpdate[0].Core_Customer_Aggregation_Type__c, 'Customer Aggregation Type Assignment is not correct.');	        
    }
    
    @isTest
    private static void checkforcustomerTypeNotNull(){
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c,ParentId from account where (Name = 'Account6' )];       
                
        List<Account> accountsAfterUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,Core_Customer_Aggregation_Type__c,ParentId from account where (Name =  'Account6')];
        accountsAfterUpdate[0].Core_Customer_Aggregation_Type__c = 'UNFD_CTRY_CUST';
        
        Test.startTest();
                	accountServiceInstance.execute(new List<Account>(accountsAfterUpdate));
        Test.stopTest();
        
        System.assertEquals('UNFD_CTRY_CUST', accountsAfterUpdate[0].Core_Customer_Aggregation_Type__c, 'Customer Aggregation Type Assignment is not correct.');	        
    }
    @isTest
    private static void checkForParentId(){
        List<Account> parentAccount = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account1')];
        
        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account2' )];
        
        List<Account> newAccounts = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account2')];
        newAccounts[0].ParentId = parentAccount[0].Id;

        Test.startTest();
        	accountServiceInstance.execute(new List<Account> (newAccounts));
        Test.stopTest();
		
        System.assertEquals(parentAccount[0].Id, newAccounts[0].ParentId, 'Parent assignment is not correct.');
        System.assertEquals('UNFD_CTRY_CUST', newAccounts[0].Core_Customer_Aggregation_Type__c, 'Parent assignment is not correct.');
    }
    
    @isTest
    private static void checkForRejected_RequestedAccount(){
        List<Account> globalCustomer = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account1' )];
        
        List<Account> countryCustomer = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account2' )];
    	
        List<Account> oldAccounts = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account4' or Name = 'Account5')];
        
        List<Account> accountsAfterInsert = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account4' or Name =  'Account5')];
    	accountsAfterInsert[0].RecordTypeId = globalCustomer[0].RecordTypeId;
        accountsAfterInsert[1].RecordTypeId = countryCustomer[0].RecordTypeId;

        List<Account> newAccounts = new List<Account>();
        newAccounts.addAll(accountsAfterInsert);
        
        Test.startTest();
        	accountServiceInstance.execute(new List<Account> (newAccounts));
        Test.stopTest();
        
        System.assertEquals(globalCustomer[0].RecordTypeId, newAccounts[0].RecordTypeId, 'Record Type Assignment is not correct.');	        
		System.assertEquals(countryCustomer[0].RecordTypeId, newAccounts[1].RecordTypeId, 'Record Type Assignment is not correct.');	        
    }
    
    @isTest
    private static void checkForGlobalCustomer(){
        List<Account> globalCustomer = [Select Id,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account1' )];       
        
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account2' )];       
        
        List<Account> accountsAfterUpdate = [Select Id,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account2')];
        accountsAfterUpdate[0].Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        
        Test.startTest();
        	accountServiceInstance.execute(new List<Account>(accountsAfterUpdate));
        Test.stopTest();
        
        System.assertEquals(globalCustomer[0].Core_Customer_Aggregation_Type__c, accountsAfterUpdate[0].Core_Customer_Aggregation_Type__c, 'Customer Aggregation Type Assignment is not correct.');	        
    }
    
    @isTest
    private static void checkForIntermediateCustomer(){
        List<Account> intermediateCustomer = [Select Id,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account3' )];       
        
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account2' )];       
        
        List<Account> accountsAfterUpdate = [Select Id,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account2')];
        accountsAfterUpdate[0].Core_Customer_Aggregation_Type__c = 'UNFD_INTRMD_CUST';
        
        Test.startTest();
        	accountServiceInstance.execute(new List<Account>(accountsAfterUpdate));
        Test.stopTest();
        
        System.assertEquals(intermediateCustomer[0].Core_Customer_Aggregation_Type__c, accountsAfterUpdate[0].Core_Customer_Aggregation_Type__c, 'Customer Aggregation Type Assignment is not correct.');	        
    }
    
}