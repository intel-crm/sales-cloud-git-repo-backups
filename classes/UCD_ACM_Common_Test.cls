@isTest
public class UCD_ACM_Common_Test {
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
        
        // Create End Customer Deal Account Location child
        Account locChildAcc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestLocChildAccount','End Customer Deal Account','UNFD_LOC_CUST');
        locChildAcc.parentId = ctryChildAcc.Id;
        //insert locChildAcc;
        
        // Create End Customer Deal Account
        Account acc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestChildAccount','End Customer Deal Account','UNFD_GLBL_CUST');
        acc.parentId = parentAccount.Id;
        acc.Core_Survivor_Account_Id__c = parentAccount.Id;
        insert acc;
        
        // Create Requested Account
        Account requestedAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestChildAccount1','Requested Account','UNFD_GLBL_CUST');
        insert requestedAccount;
        
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
        
        // Create Compliance Watch List
        List<Core_Account_Compliance_Watch_List__c> complianceWatchLists = new List<Core_Account_Compliance_Watch_List__c>();
        complianceWatchLists.add(UCD_ACM_Cntrlr_TestDataInitialization.createComplianceWatchList(acc.Id,'NOTRDOUT'));
        complianceWatchLists.add(UCD_ACM_Cntrlr_TestDataInitialization.createComplianceWatchList(acc.Id,'DPL'));
        insert complianceWatchLists;
        
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
        
        Account intChildAccWithBpId3 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestChildAccountWithBpId3','Intel Account','UNFD_CTRY_CUST');
        intChildAccWithBpId3.Core_Business_Party_Id__c = '12';
        intChildAccWithBpId3.parentId = parentAccountWithBpId2.Id;
        system.runAs(us){
            insert intChildAccWithBpId3;
        }
        
        Account intChildAccWithBpId4 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestChildAccountWithBpId4','End Customer Deal Account','UNFD_LOC_CUST');
        intChildAccWithBpId4.Core_Business_Party_Id__c = '1234';
        intChildAccWithBpId4.parentId = parentAccountWithBpId1.Id;
        system.runAs(us){
            insert intChildAccWithBpId4;
        }
       
        
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
    private static void checkHierarchyFields(){
      /*  Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        Account intChildAcc1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestIntChildAccount1','End Customer Deal Account','UNFD_INTRMD_CUST');
        intChildAcc1.parentId = parentAccount.Id;
        Account intChildAcc2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestIntChildAccount2','End Customer Deal Account','UNFD_INTRMD_CUST');
        intChildAcc2.parentId = intChildAcc1.Id;
        Account ctryChildAcc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestCtryChildAccount','End Customer Deal Account','UNFD_CTRY_CUST');
        ctryChildAcc.parentId = intChildAcc2.Id;
        Account locChildAcc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestLocChildAccount','End Customer Deal Account','UNFD_LOC_CUST');
        locChildAcc.parentId = ctryChildAcc.Id;*/

        List<Account> accountsBeforeUpdate = [Select Id,Parent.Core_Business_Party_Id__c,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c,Core_Data_Simplified_Account_Nm__c from account where (Name = 'TestIntChildAccount1' )];       

        
        //newAccounts[0].ParentId = parentAccount[0].Id;
        List<Account> pAccount = [Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'TestParentAccount'];
		Account parentAccount = new Account();
        parentAccount.Id = pAccount[0].Id;
            List<Account> intChildAcc1 = [Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'TestChildAccountWithBpId1'];
            List<Account> intChildAcc2 = [Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'TestParentAccountWithBpId2'];
            List<Account> ctryChildAcc = [Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'TestChildAccountWithBpId3'];
            List<Account> locChildAcc = [Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'TestChildAccountWithBpId4'];
          
            
        Test.startTest();     
        //UCD_ACM_Common.hasSecondaryIntermediateParent(intChildAcc2);
         UCD_ACM_Common.setHierarchyFields(ctryChildAcc[0],parentAccount);
          UCD_ACM_Common.setHierarchyFields(locChildAcc[0],parentAccount);
        UCD_ACM_Common.setHierarchyFields(accountsBeforeUpdate[0],null);
    
        Test.stopTest();
     //   System.assertEquals('UNFD_GLBL_CUST', acc.Industry,'Industry should match');
        System.assertEquals(accountsBeforeUpdate[0].Core_Unified_Global_Customer_BP_Id__c, accountsBeforeUpdate[0].Parent.Core_Business_Party_Id__c,'Industry should match');
          
    }
             @isTest
    private static void whenSetIntegrationMessage(){
        UCD_ACM_UnitOfWork unitOfwork = new UCD_ACM_UnitOfWork();
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'TestIntChildAccount1' )];       
        
        List<Account> newAccounts = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'TestIntChildAccount1')];
        
        List<Account> accountsAfterUpdate = new List<Account>();
        accountsAfterUpdate.addAll(newAccounts);
        List<Account> accounts = Database.query('Select Id,Name from account where name like \'%TestIntChildAccount%\'');
        Set<Id> accountIds = (new Map<Id,Account>(accounts)).keySet();
        test.startTest();
        UCD_ACM_Common.updateACMIntegrationMessage(unitOfwork,accountIds);
        unitOfWork.commitWork();
        test.stopTest();
        List<ACM_Integration_Message_Queue__c> intMessageQueue = [select id from ACM_Integration_Message_Queue__c]; 
        system.debug('intMessageQueue--'+intMessageQueue.size());
        System.assertEquals(2,intMessageQueue.size(),'size should equal');
    }
    
    @isTest
    private static void checkIntegrationMessageUpdate(){
        UCD_ACM_UnitOfWork unitOfwork = new UCD_ACM_UnitOfWork();
        List<Account> accountsBeforeUpdate = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name = 'TestIntChildAccount1' )];       
        
        List<Account> newAccounts = [Select Id,Core_Business_Party_Id__c,RecordTypeId,Core_Account_Reference_Source_Name__c,ParentId,Core_Customer_Aggregation_Type__c from account where (Name =  'TestIntChildAccount1')];
        
        List<Account> accountsAfterUpdate = new List<Account>();
        accountsAfterUpdate.addAll(newAccounts);
        
      //  List<ACM_Integration_Message_Queue__c> integrationMessage = [Select Id,Content__c,Content_Type__c,Message_Status__c,Module_Name__c,Queue_Type__c,Source_System__c,Custom_Filter__c from ACM_Integration_Message_Queue__c where Message_Status__c = 'Success'];
      //  System.debug('list'+integrationMessage);
      //  integrationMessage[0].Message_Status__c = 'Success';
        
        Test.startTest();
        	UCD_ACM_Common.updateACMIntegrationMessage(unitOfwork, new Set<Id>{newAccounts[0].Id});
            UCD_ACM_Common.hasSecondaryIntermediateParent(newAccounts[0]);
        Test.stopTest();
        List<ACM_Integration_Message_Queue__c> intMessageQueue = [select id from ACM_Integration_Message_Queue__c]; 
        
        System.assertEquals(1,intMessageQueue.size(),'size should equal');
      //  System.assertNotEquals('New', integrationMessage[0].Message_Status__c, 'Update Successful');
    }

    
    
}