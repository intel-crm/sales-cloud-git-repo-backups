/*
     * description : Test class for UCD_ACM_AccountHandler
     * params : NA
     * return : NA
     * author and date : Harshal Gosavi, 4th August 2021
     * Update Date: 25/10/2021.
     */
@IsTest
public class UCD_ACM_AccountHandlerTest {
    
  
    
    @TestSetup
    private static void setCommonData(){
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
        
        insert new Core_Trigger_Executions__c(Name='UCD_ACM_ExecutePlatformEvent',Core_Active__c = true,
                                             Core_Class_Name__c='Test',Core_Description__c='TestDescription',Core_Object__c='TestObject',
                                             Core_Trigger_Events__c = 'TestEvent');
        insert new Core_Trigger_Executions__c(Name='UCD_ACM_IgnoreUpdateAccountFields',Core_Active__c = true,
                                             Core_Class_Name__c='Test2',Core_Description__c='TestDescription2',Core_Object__c='TestObject2',
                                             Core_Trigger_Events__c = 'TestEvent2');
        insert new Core_Trigger_Executions__c(Name='UCD_ACM_UpdateRecordType',Core_Active__c = true,
                                             Core_Class_Name__c='Test3',Core_Description__c='TestDescription3',Core_Object__c='TestObject3',
                                             Core_Trigger_Events__c = 'TestEvent3');
        insert new Core_Trigger_Executions__c(Name='UCD_ACM_UpdateHierarchy',Core_Active__c = true,
                                            Core_Class_Name__c='Test4',Core_Description__c='TestDescription4',Core_Object__c='TestObject4',
                                            Core_Trigger_Events__c = 'TestEvent4');
        insert new Core_Trigger_Executions__c(Name='UCD_ACM_EnableInfoLog',Core_Active__c = true,
                                            Core_Class_Name__c='Test5',Core_Description__c='TestDescription5',Core_Object__c='TestObject5',
                                            Core_Trigger_Events__c = 'TestEvent5');
        insert new Core_Trigger_Executions__c(Name='UCD_ACM_EnableReltioSync', Core_Active__c = true, Core_Class_Name__c='Test6', Core_Description__c='TestDescription6', Core_Object__c='TestObject6', Core_Trigger_Events__c = 'TestEvent6');
        
        insert new Core_Trigger_Executions__c(Name='UCD_ACM_UpdateParentOnAccount',Core_Active__c = true,
                                            Core_Class_Name__c='Test5',Core_Description__c='TestDescription5',Core_Object__c='TestObject5',
                                            Core_Trigger_Events__c = 'TestEvent5');
        insert new Core_Trigger_Executions__c(Name='accountDupCheck',Core_Active__c = true,
                                            Core_Class_Name__c='Test5',Core_Description__c='TestDescription5',Core_Object__c='TestObject5',
                                            Core_Trigger_Events__c = 'TestEvent5');
        // Create Parent Account
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        insert parentAccount;

        // Create Heirarchy Child Account
        Account childAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestHeirarchyChildAccount','Intel Account','UNFD_CTRY_CUST');
        insert childAccount;
        
        // Create End Customer Deal Account
        Account acc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestPlatformEvent','End Customer Deal Account','UNFD_GLBL_CUST');
        acc.parentId = parentAccount.Id;
        acc.Core_Survivor_Account_Id__c = parentAccount.Id;
        insert acc;
        
        // Create Requested Account
        Account requestedAcc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('RequetedAccount','Requested Account','UNFD_GLBL_CUST');
        requestedAcc.Core_Data_Country_Nm__c = 'India';
        requestedAcc.BillingCountryCode = 'IND';
        requestedAcc.ShippingCountryCode = '';
        insert requestedAcc;

        // Create Parent Account
        Account parentAccount1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount1','Intel Account','UNFD_GLBL_CUST');
        insert parentAccount1;
        Account parentAccount2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount2','Intel Account','UNFD_GLBL_CUST');
        insert parentAccount2;
        // Create Heirarchy Child Account
        Account flChild = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('FirstLevelChild1','Intel Account','UNFD_INTRMD_CUST');
        flChild.ParentId = parentAccount1.Id;
        insert flChild;
        // Create Heirarchy Child Account
        Account slChild = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('SecondLevelChild1','Intel Account','UNFD_CTRY_CUST');
        slChild.ParentId = flChild.Id;
        insert slChild;
        // Create Heirarchy Child Account
        Account tlChild1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('ThirdLevelChild1','Intel Account','UNFD_LOC_CUST');
        tlChild1.ParentId = slChild.Id;
        insert tlChild1;
        // Create Heirarchy Child Account
        Account tlChild2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('ThirdLevelChild2','Intel Account','UNFD_LOC_CUST');
        tlChild2.ParentId = slChild.Id;
        insert tlChild2;
        
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
    }
    
    @isTest
    private static void whenTriggerPlatformEventOnUpdate(){
        Map<Id,Account> accountById = new Map<Id,Account>([Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'TestPlatformEvent']);
        Test.startTest();
        UCD_ACM_AccountHandler.triggerPlatformEventOnUpdate(getUpdatedAccounts(accountById),accountById);
        Test.stopTest();
    }


    @isTest
    private static void whenThrowException(){
        Map<Id,Account> accountById = new Map<Id,Account>([Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'TestPlatformEvent']);
        Test.startTest();
        UCD_ACM_AccountService.isTestException = true;
        UCD_ACM_AccountHandler.triggerPlatformEventOnUpdate(getUpdatedAccounts(accountById),accountById);
        UCD_ACM_AccountHandler.updateAccountRecordType(getUpdatedAccounts(accountById),accountById);
        UCD_ACM_AccountHandler.restrictUpdatingSFFields(getUpdatedAccounts(accountById),accountById.values());
        UCD_ACM_AccountHandler.updateHierarchyFields(null);
        UCD_ACM_AccountHandler.updateAccountAddress(null);

        Test.stopTest();
    }
    

    @isTest
    private static void whenRestrictUpdatingSFFields(){
        List<Account> oldAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry from Account where Name = 'TestPlatformEvent'];
        Account newAccount = oldAccount[0];
        newAccount.Name = 'UpdatedTestPlatformEvent';
        Test.startTest();
        UCD_ACM_AccountHandler.restrictUpdatingSFFields(new List<Account>{newAccount},oldAccount);
        Test.stopTest();
    }

    @isTest
    private static void whenAccountRecordTypeUpdate(){
        Map<Id,Account> accountById = new Map<Id,Account>([Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Country_Cd__c,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,BillingCity,BillingStreet from Account where Name = 'RequetedAccount' limit 1]) ;
        Test.startTest();
        UCD_ACM_AccountHandler.updateAccountRecordType(getUpdatedAccounts(accountById),accountById);
        Test.stopTest();
    }
    
    private static List<Account> getUpdatedAccounts(Map<Id,Account> accountById){
        List<Account> newaccounts = new List<Account>();
        For(Account account : accountById.values()){
            Account accountToUpdate = new Account();
            accountToUpdate.Id = account.Id;
            accountToUpdate.Name = 'Updated '+account.Name;
            accountToUpdate.Core_Customer_Aggregation_Type__c = account.Core_Customer_Aggregation_Type__c;
            accountToUpdate.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('End Customer Deal Account').getRecordTypeId();
            accountToUpdate.BillingCountryCode	= account.BillingCountryCode;
            accountToUpdate.BillingCity = account.BillingCity;
            accountToUpdate.BillingCountry = account.BillingCountry;
            accountToUpdate.BillingStreet = account.BillingStreet;
            accountToUpdate.Core_Business_Party_Id__c = account.Core_Business_Party_Id__c;
            accountToUpdate.ShippingCountryCode = account.ShippingCountryCode;
            accountToUpdate.ShippingCountry = account.ShippingCountry;
            accountToUpdate.Core_Survivor_Account_Id__c = account.Core_Survivor_Account_Id__c;
            accountToUpdate.ParentId = account.ParentId != null ? account.ParentId : null;
            newaccounts.add(accountToUpdate);
        }
        return newaccounts;
    }

    @isTest
    private static void whenParentChangeUpdateHierarchyFields(){
        Map<Id,Account> oldAccount = new Map<Id,Account>([Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'TestHeirarchyChildAccount' limit 1]);
        List<Account> pAccount = [Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'TestParentAccount'];
        Account newAccount = oldAccount.Values()[0];
        Account parentAccount = pAccount[0];
        newAccount.ParentId = parentAccount.Id;
        Test.startTest();
        UCD_ACM_AccountHandler.updateHierarchyFields(new List<Account>{newAccount}, oldAccount, false);
        Test.stopTest();
    }

    @isTest
    private static void whenAccountChangeCheckDupCheck(){
        List<Account> allAccounts = [Select id,name,RecordTypeId,Core_Account_Record_Type_Dup_Check__c from Account where name = 'TestParentAccount1'];
		Test.startTest();
        UCD_ACM_AccountHandler.accountRecordTypeDupFieldUpdate(allAccounts);
        Test.stopTest();
    }
    
    @isTest
    private static void whenCustAggrChangeUpdateHierarchyFields(){
        Map<Id,Account> oldAccount = new Map<Id,Account>([Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'TestHeirarchyChildAccount' limit 1]);
        Account newAccount = oldAccount.Values()[0];
        List<Account> newAcc = new List<Account>();
        newAccount.Core_Customer_Aggregation_Type__c = 'UNFD_INTRMD_CUST';
        Test.startTest();
        UCD_ACM_AccountHandler.updateHierarchyFields(new List<Account>{newAccount}, oldAccount, false);
        Test.stopTest();
    }

    @isTest
    private static void whenParentChangeUpdateChildHierarchyFields(){        
        Map<Id,Account> pAccount = new Map<Id,Account>([Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'TestParentAccount2' limit 1]);
        Map<Id,Account> flChild = new Map<Id,Account>([Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'FirstLevelChild1']);
        List<Account> newAccounts = getUpdatedHierarchyAccounts(flChild,pAccount.Values()[0]);

        // List<Account> slChild = [Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'SecondLevelChild1'];
        // Account slChildAccount = slChild[0];
        // slChildAccount.ParentId = parentAccount.Id;

        // List<Account> tlChild = [Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'ThirdLevelChild2'];
        // Account tlChildAccount = tlChild[0];
        // tlChildAccount.ParentId = flChildAccount.Id;

        // system.debug('Old ParentId is: '+flChild.Values()[0].ParentId);
        // system.debug('New ParentID is: '+flChildAccount.ParentId);
        // system.debug('Cust Aggr Type is: '+flChildAccount.Core_Customer_Aggregation_Type__c);
        Test.startTest();
        UCD_ACM_AccountHandler.updateHierarchyFields(newAccounts, flChild, true);
        // update slChildAccount;
        // update tlChildAccount;
        Test.stopTest();
    }

    private static List<Account> getUpdatedHierarchyAccounts(Map<Id,Account> accountById, Account parentAcct){
        List<Account> newaccounts = new List<Account>();
        For(Account account : accountById.values()){
            Account accountToUpdate = new Account();
            accountToUpdate.Id = account.Id;
            accountToUpdate.Name = account.Name;
            accountToUpdate.Core_Customer_Aggregation_Type__c = account.Core_Customer_Aggregation_Type__c;
            accountToUpdate.RecordTypeId = account.RecordTypeId;
            accountToUpdate.ParentId = parentAcct.Id;
            newaccounts.add(accountToUpdate);
        }
        return newaccounts;
    }
    
    @isTest
    private static void whenTriggerReltioSync(){
        Map<Id,Account> flChild = new Map<Id,Account>([Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'FirstLevelChild1']);
        Account acctFLChild = flChild.Values()[0];
        acctFLChild.Name = 'FirstLevelChild1 Chg';
        Test.startTest();
        update acctFLChild;
        Test.stopTest();
    }
    
    @isTest
    private static void whenUpdateParentOnAccount(){
        User us = [Select Id,Name from User where Name = 'Reltio SFDC Connector' LIMIT 1];
        Map<Id,Account> oldAccount = new Map<Id,Account>([Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,LastModifiedById from Account where Name = 'SecondLevelChild1' limit 1]);
        List<Account> pAccount = [Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,LastModifiedById from Account where Name = 'TestParentAccount'];
        Account newAccount = oldAccount.Values()[0];
        Account parentAccount = pAccount[0];

        system.runAs(us){
           	newAccount.ParentId = parentAccount.Id;
            newAccount.Core_Business_Party_Id__c = '789456';
            //newAccount.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            
            Test.startTest();
            update newAccount;
            newAccount.Core_Business_Party_Id__c = '849679';
            update newAccount;
            UCD_ACM_AccountHandler.updateParentOnAccount(new List<Account>{newAccount},oldAccount);
            Test.stopTest(); 
        }
        
    }
}