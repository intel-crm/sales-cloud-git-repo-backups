@isTest
public class ACM_AU_SetAccountHierarchyAttributesTest {
    
   private static UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger accountServiceInstance = new ACM_AU_SetAccountHierarchyAttributes();
   private static UCD_ACM_SelectorContracts.IUnitOfWork unitWork = new UCD_ACM_UnitOfWork();

    @TestSetup
    private static void setCommonData() {
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account1','Intel Account','UNFD_GLBL_CUST');
        insert parentAccount;
        
        Account childAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account2','Intel Account','UNFD_CTRY_CUST');
        insert childAccount;
        
        Account parentAccount2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account3','Intel Account','UNFD_GLBL_CUST');
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
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        List<Account> globalCustomer = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Customer_Aggregation_Type__c,Core_Account_Reference_Source_Name__c,ParentId from account where (Name = 'Account6' )];       
        
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId from account where (Name = 'Account3' )];       
        
        List<Account> accountsAfterUpdate = [Select Id,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId from account where (Name =  'Account3')];
        
        Test.startTest();
        	accountServiceInstance.execute(unitwork, new Map<Id,Account>(globalCustomer), new Map<Id,Account>(accountsAfterUpdate));
        Test.stopTest();
        
        System.assertEquals(null, globalCustomer[0].Core_Customer_Aggregation_Type__c, 'Customer Aggregation Type Assignment is not correct.');	        
    }
    
    @isTest
    private static void checkForParentId(){
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        List<Account> parentAccount = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account1')];
        
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account2' )];
        
        List<Account> accountsAfterUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account2')];
        accountsAfterUpdate[0].ParentId = parentAccount[0].Id;
		
        Test.startTest();
        	accountServiceInstance.execute(unitwork, new Map<Id,Account>(accountsBeforeUpdate), new Map<Id,Account>(accountsAfterUpdate));
        Test.stopTest();
		
        System.assertEquals(parentAccount[0].Id, accountsAfterUpdate[0].ParentId, 'Parent assignment is not correct.');	        
    }
    
    @isTest
    private static void checkForCustomerAggrType(){
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        List<Account> globalCustomer = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account1' )];       
        
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account2' )];       
        
        List<Account> accountsAfterUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account2')];
        accountsAfterUpdate[0].Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        
        Test.startTest();
        	accountServiceInstance.execute(unitwork, new Map<Id,Account>(accountsBeforeUpdate), new Map<Id,Account>(accountsAfterUpdate));
        Test.stopTest();
        
        System.assertEquals(globalCustomer[0].Core_Customer_Aggregation_Type__c, accountsAfterUpdate[0].Core_Customer_Aggregation_Type__c, 'Customer Aggregation Type Assignment is not correct.');	        
    }  

    @isTest
    private static void checkForRecordTypeID(){
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        List<Account> recordType = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account1' )];       
        
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account2' )];       
        
        List<Account> accountsAfterUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account2')];
        accountsAfterUpdate[0].RecordTypeId = recordType[0].RecordTypeId;
        
        Test.startTest();
        	accountServiceInstance.execute(unitwork, new Map<Id,Account>(accountsBeforeUpdate), new Map<Id,Account>(accountsAfterUpdate));
        Test.stopTest();
        
        System.assertEquals(recordType[0].RecordTypeId, accountsAfterUpdate[0].RecordTypeId, 'Record Type Assignment is not correct.');	        
    }
    
    @isTest
    private static void checkForRejected_RequestedAccount(){
        UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        List<Account> rejectedAccount = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account4' )];
        
        List<Account> requestedAccount = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account5' )];
    	
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account1' or Name = 'Account2')];
        
        List<Account> newAccounts = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account1' or Name =  'Account2')];
    	newAccounts[0].RecordTypeId = rejectedAccount[0].RecordTypeId;
        newAccounts[1].RecordTypeId = requestedAccount[0].RecordTypeId;

        List<Account> accountsAfterUpdate = new List<Account>();
        accountsAfterUpdate.addAll(newAccounts);
        
        Test.startTest();
        	accountServiceInstance.execute(unitwork, new Map<Id,Account>(accountsBeforeUpdate), new Map<Id,Account>(accountsAfterUpdate));
        Test.stopTest();
        
        System.assertEquals(rejectedAccount[0].RecordTypeId, accountsAfterUpdate[0].RecordTypeId, 'Record Type Assignment is not correct.');	        
		System.assertEquals(requestedAccount[0].RecordTypeId, accountsAfterUpdate[1].RecordTypeId, 'Record Type Assignment is not correct.');	        
    }
    
    @isTest
    private static void checkIntegrationMessage(){
        
        Test.startTest();
        	//accountServiceInstance.execute(unitwork, new Map<Id,Account>(accountsBeforeUpdate), new Map<Id,Account>(accountsAfterUpdate));
        Test.stopTest();
    }
    
}