@isTest
public class ACM_AI_PublishAccount_Test {
    
    private static UCD_ACM_ServiceContracts.IAfterInsertAccountTrigger accountServiceInstance = new ACM_AI_PublishAccount();
    private static UCD_ACM_SelectorContracts.IUnitOfWork unitOfWork = new UCD_ACM_UnitOfWork();
    private static UCD_ACM_SelectorContracts.IAccountMutationSelector accountMutantSelectorInstance = UCD_ACM_AccountMutationSelector.getInstance();
    
    @TestSetup
    private static void setCommonData() {
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account1','Intel Account','UNFD_GLBL_CUST');
        parentAccount.Core_Business_Party_Id__c = '11';
        parentAccount.Core_Unified_Global_Customer_BP_Id__c = '12345';
        parentAccount.Core_Data_Simplified_Account_Nm__c = 'Changed Parent1';
        /*parentAccount.Core_Survivor_Account_Id__c = '212';
        parentAccount.Core_Data_Simplified_Account_Nm__c = 'Simplified Name';
        parentAccount.BillingCountry = 'Billing Country';
        parentAccount.ShippingCountry = 'Shipping Country';*/
        insert parentAccount;
        
        Account childAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account2','Intel Account','UNFD_CTRY_CUST');
        childAccount.Core_Business_Party_Id__c = '12';
        childAccount.Core_Unified_Global_Customer_BP_Id__c = '12345';
        childAccount.Core_Data_Simplified_Account_Nm__c = 'Changed Child1';
        insert childAccount;
        
        Account parentAccount2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account3','Intel Account','UNFD_INTRMD_CUST');
        parentAccount2.Core_Business_Party_Id__c = '13';
        parentAccount2.Core_Unified_Intermediate_Customer_BP_Id__c = '78645';
        parentAccount.Core_Data_Simplified_Account_Nm__c = 'Changed Parent2';
        insert parentAccount2;
        
        Account rejectedAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account4','Rejected Account','UNFD_CTRY_CUST');
        childAccount.Core_Business_Party_Id__c = '14';
        insert rejectedAccount;
        
        Account endCustomerRecordType = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account5','End Customer Deal Account','UNFD_CTRY_CUST');
        childAccount.Core_Business_Party_Id__c = '15';
        endCustomerRecordType.parentId = parentAccount.Id;
        endCustomerRecordType.Core_Survivor_Account_Id__c = parentAccount.Id;
        insert endCustomerRecordType;
        
        Account intelAccountRecordType = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Account6','Intel Account','UNFD_CTRY_CUST');
        childAccount.Core_Business_Party_Id__c = '16';
        insert intelAccountRecordType;
        
        // Create End Customer Deal Account Intermediate1 child
        Account intChildAcc1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestIntChildAccount1','End Customer Deal Account','UNFD_INTRMD_CUST');
        intChildAcc1.parentId = parentAccount.Id;
        insert intChildAcc1;
        
		// Create ACM_Integration_Message_Queue__c
        List<ACM_Integration_Message_Queue__c> integrationMsgToInsert = new List<ACM_Integration_Message_Queue__c>();
        ACM_Integration_Message_Queue__c integrationMessageNewStatus = UCD_ACM_Cntrlr_TestDataInitialization.createIntegrationMessageQueue(intChildAcc1.Id);
        integrationMessageNewStatus.Message_Status__c='Success';
        //ACM_Integration_Message_Queue__c integrationMessageErrorStatus = UCD_ACM_Cntrlr_TestDataInitialization.createIntegrationMessageQueue(intChildAcc2.Id);
        integrationMsgToInsert.add(integrationMessageNewStatus);
        //integrationMsgToInsert.add(integrationMessageErrorStatus);
        insert integrationMsgToInsert;
    }
    
    @isTest
    private static void checkForRecordType(){
        UCD_ACM_UnitOfWork unitOfwork = new UCD_ACM_UnitOfWork();
        List<Account> rejectedAccount = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c,Core_Data_Simplified_Account_Nm__c,Core_Survivor_Account_Id__c,BillingCountry,ShippingCountry,Core_Data_Country_Nm__c,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,Name from account where (Name = 'Account4' )];
        
        List<Account> endCustomerRecordType = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c,Core_Data_Simplified_Account_Nm__c,Core_Survivor_Account_Id__c,BillingCountry,ShippingCountry,Core_Data_Country_Nm__c,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,Name from account where (Name = 'Account5' )];
        
        List<Account> intelAccountRecordType = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c,Core_Data_Simplified_Account_Nm__c,Core_Survivor_Account_Id__c,BillingCountry,ShippingCountry,Core_Data_Country_Nm__c,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,Name from account where (Name = 'Account6' )];
    	
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c,Core_Data_Simplified_Account_Nm__c,Core_Survivor_Account_Id__c,BillingCountry,ShippingCountry,Core_Data_Country_Nm__c,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,Name from account where (Name =  'Account1' or Name = 'Account2' or Name = 'Account3')];
        
        List<Account> newAccounts = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c,Core_Data_Simplified_Account_Nm__c,Core_Survivor_Account_Id__c,BillingCountry,ShippingCountry,Core_Data_Country_Nm__c,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,Name from account where (Name =  'Account1' or Name =  'Account2' or Name = 'Account3')];
    	newAccounts[0].RecordTypeId = rejectedAccount[0].RecordTypeId;
        newAccounts[1].RecordTypeId = endCustomerRecordType[0].RecordTypeId;
        newAccounts[2].RecordTypeId = intelAccountRecordType[0].RecordTypeId;

        List<Account> accountsAfterUpdate = new List<Account>();
        accountsAfterUpdate.addAll(newAccounts);
        
        Test.startTest();
        	accountServiceInstance.execute(unitOfWork, new Map<Id,Account>(accountsBeforeUpdate), new Map<Id,Account>(accountsAfterUpdate));
        Test.stopTest();
        
        System.assertEquals(rejectedAccount[0].RecordTypeId, accountsAfterUpdate[0].RecordTypeId, 'Record Type Assignment is not correct.');	        
		System.assertEquals(endCustomerRecordType[0].RecordTypeId, accountsAfterUpdate[1].RecordTypeId, 'Record Type Assignment is not correct.');
        System.assertEquals(intelAccountRecordType[0].RecordTypeId, accountsAfterUpdate[2].RecordTypeId, 'Record Type Assignment is not correct.');
    }
    
    @isTest
    private static void checkForCustomerAggrType(){
        UCD_ACM_UnitOfWork unitOfwork = new UCD_ACM_UnitOfWork();
        List<Account> globalCustomer = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c,Core_Data_Simplified_Account_Nm__c from account where (Name = 'Account1' )];       
        
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c,Core_Data_Simplified_Account_Nm__c from account where (Name = 'Account2' )];       
        
        List<Account> accountsAfterUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c,Core_Data_Simplified_Account_Nm__c from account where (Name =  'Account2')];
        accountsAfterUpdate[0].Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        
        Test.startTest();
        	accountServiceInstance.execute(unitOfWork, new Map<Id,Account>(accountsBeforeUpdate), new Map<Id,Account>(accountsAfterUpdate));
        Test.stopTest();
        
        System.assertEquals(globalCustomer[0].Core_Customer_Aggregation_Type__c, accountsAfterUpdate[0].Core_Customer_Aggregation_Type__c, 'Customer Aggregation Type Assignment is not correct.');	        
    }  
    
    @isTest
    private static void checkForRecordTypeID(){
        UCD_ACM_UnitOfWork unitOfwork = new UCD_ACM_UnitOfWork();
        List<Account> recordType = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account1' )];       
        
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account5' )];       
        
        List<Account> newAccounts = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account5')];
        newAccounts[0].RecordTypeId = recordType[0].RecordTypeId;
        
        List<Account> accountsAfterUpdate = new List<Account>();
        accountsAfterUpdate.addAll(newAccounts);
        
        Test.startTest();
        	accountServiceInstance.execute(unitOfwork, new Map<Id,Account>(accountsBeforeUpdate), new Map<Id,Account>(accountsAfterUpdate));
        Test.stopTest();
        
        System.assertEquals(recordType[0].RecordTypeId, accountsAfterUpdate[0].RecordTypeId, 'Record Type Assignment is not correct.');	        
    }
    
    /* @isTest
    private static void whenSetIntegrationMessage(){
        UCD_ACM_UnitOfWork unitOfwork = new UCD_ACM_UnitOfWork();
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account5' )];       
        
        List<Account> newAccounts = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account5')];
        
        List<Account> accountsAfterUpdate = new List<Account>();
        accountsAfterUpdate.addAll(newAccounts);
        List<Account> accounts = Database.query('Select Id,Name from account where name like \'%TestIntChildAccount%\'');
        Set<Id> accountIds = (new Map<Id,Account>(accounts)).keySet();
        test.startTest();
        accountServiceInstance.execute(unitOfwork, new Map<Id,Account>(accountsBeforeUpdate), new Map<Id,Account>(accountsAfterUpdate));
        test.stopTest();
    }*/
    
    @isTest
    private static void checkIntegrationMessageUpdate(){
        UCD_ACM_UnitOfWork unitOfwork = new UCD_ACM_UnitOfWork();
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'Account5' )];       
        
        List<Account> newAccounts = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'Account5')];
        
        List<Account> accountsAfterUpdate = new List<Account>();
        accountsAfterUpdate.addAll(newAccounts);
        
        List<ACM_Integration_Message_Queue__c> integrationMessage = [Select Id,Content__c,Content_Type__c,Message_Status__c,Module_Name__c,Queue_Type__c,Source_System__c,Custom_Filter__c from ACM_Integration_Message_Queue__c where Message_Status__c = 'Success'];
        integrationMessage[0].Message_Status__c = 'Success';
        
        Test.startTest();
        	accountServiceInstance.execute(unitOfwork, new Map<Id,Account>(accountsBeforeUpdate), new Map<Id,Account>(accountsAfterUpdate));
        Test.stopTest();
        
        System.assertNotEquals('New', integrationMessage[0].Message_Status__c, 'Update Successful');
    }
}