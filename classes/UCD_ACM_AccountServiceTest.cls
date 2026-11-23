@IsTest
public class UCD_ACM_AccountServiceTest{
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
        /*Account locChildAcc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestLocChildAccount','End Customer Deal Account','UNFD_LOC_CUST');
        locChildAcc.parentId = ctryChildAcc.Id;
        insert locChildAcc;*/

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

        //Account_Create_Request__c accountCreateRequest = UCD_ACM_Cntrlr_TestDataInitialization.createApproveAccountRequest('TestApproveAcctreq','India');
        //insert accountCreateRequest;

        //Account_Create_Request__c accountCreateRejectRequest = UCD_ACM_Cntrlr_TestDataInitialization.createRejectAccountRequest('TestRejectedAccRequest','India');
        //insert accountCreateRejectRequest;
        
        // To cover catch block
        //UCD_ACM_AccountService.isTestException = true;
    }
    
    @isTest
    private static void whenCreateBusinessOrganizationReq(){
        List<UCD_ACM_Models.AccountModel> accountModel = new List<UCD_ACM_Models.AccountModel>();
        List <UCD_ACM_Models.BusinessOrganizationResponseforService> responseModel = new List <UCD_ACM_Models.BusinessOrganizationResponseforService>();
        accountModel.add(UCD_ACM_AccountTestData.getAccountModel('TestAccount','UNFD_CTRY_CUST','DIR_PRC_EXCPT','Test','Test@test.com','India','IND'));
    	accountModel.add(UCD_ACM_AccountTestData.getAccountModel('TestAccount1','UNFD_CTRY_CUST','DIR_PRC_EXCPT','Test','Test@test.com','India','IND'));
        test.startTest();
        responseModel = accountServiceInstance.createBusinessOrganizationRequest(accountModel);
        system.assertEquals('TestAccount', responseModel[0].AccountData.Name);
        test.stopTest();
    }
    @isTest
    private static void whenCreateBusinessOrganizationWithError(){
        List<UCD_ACM_Models.AccountModel> accountModel = new List<UCD_ACM_Models.AccountModel>();
        List <UCD_ACM_Models.BusinessOrganizationResponseforService> responseModel = new List <UCD_ACM_Models.BusinessOrganizationResponseforService>();
        accountModel.add(UCD_ACM_AccountTestData.getAccountModel('TestAccount','','DIR_PRC_EXCPT','Test','Test@test.com','India','IND'));
    	test.startTest();
        UCD_ACM_AccountService.isTestException = true;
        responseModel = accountServiceInstance.createBusinessOrganizationRequest(accountModel);
        system.assertEquals('TestAccount', responseModel[0].AccountData.Name);
        test.stopTest();
    }
    
    @isTest
    private static void whenGetAccountsToPublishEvent(){
        Set<Id> accountIds = new Set<Id>();
        Account account = [Select Id from Account where Name = 'TestChildAccount' LIMIT 1];
		accountIds.add(account.Id);
        test.startTest();
        List<Account> accounts = UCD_ACM_AccountService.getAccountsToPublishEvent(accountIds);
        test.stopTest();
    }
    
    @isTest
    private static void whenUpdateAccRecordType(){
        Map<Id,Account> oldAccountById = new Map<Id,Account>([Select Id,Name,Core_Business_Party_Id__c,RecordTypeId from Account where Name = 'TestChildAccount1']);
        Account newAccount = new Account();
        newAccount.Id = oldAccountById.Values().Id;
        newAccount.Name = oldAccountById.Values().Name;
        newAccount.Core_Business_Party_Id__c = oldAccountById.Values().Core_Business_Party_Id__c;
        newAccount.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('End Customer Deal Account').getRecordTypeId();
        test.startTest();
        accountServiceInstance.updateAccRecordTypeByBpId(new List<Account>{newAccount},oldAccountById);
        accountServiceInstance.restrictUpdatingSFFields(new List<Account>{newAccount},oldAccountById.Values());
        test.stopTest();
    }
    
    @isTest
    private static void whenGetBusinessOrganization(){
        Account account = [Select Id,Core_Data_Simplified_Local_Language_Nm__c,Unified_Hierarchy_View__c from account where Name = 'TestChildAccount' LIMIT 1];
        UCD_ACM_BusinessOrganizationModel readAPIModel = UCD_ACM_AccountTestData.getBusinessOrganizationModel(new List<String>{account.Id});
        test.startTest();
        UCD_ACM_BusinessOrganizationModel.BusinessOrganizationResponse readAPIResponse = accountServiceInstance.getBusinessOrganization(readAPIModel);
        test.stopTest();
    }
    
    @isTest
    private static void whenpublishAccountChangeEvent(){
        List<Account> accounts = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Simplified_Local_Language_Nm__c,Unified_Hierarchy_View__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'TestChildAccount' LIMIT 1];
    	test.startTest();
        UCD_ACM_AccountService.publishAccountChangeEvent(new Set<Id>{accounts[0].Id});
        accountServiceInstance.updateACMIntegrationMessage(new Set<Id>{accounts[0].Id});
        test.stopTest();
    }
    
    @isTest
    private static void whenUpdateHierarchyFieldsWithTrue(){
        Account account = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Simplified_Local_Language_Nm__c,Unified_Hierarchy_View__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet,Core_Unified_Global_Customer__r.Core_Business_Party_Id__c,Core_Unified_Global_Customer__r.Core_Data_Simplified_Account_Nm__c from Account where Name = 'TestParentAccount' LIMIT 1];
        test.startTest();
        accountServiceInstance.updateHierarchyFields(account,true);
        test.stopTest();
    }
    /*@isTest
    private static void whenUpdateHierarchyFieldsWithFalse(){
        Account account = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet,Core_Unified_Global_Customer__r.Core_Business_Party_Id__c,Core_Unified_Global_Customer__r.Core_Data_Simplified_Account_Nm__c from Account where Name = 'TestLocChildAccount' LIMIT 1];
    	test.startTest();
        accountServiceInstance.updateHierarchyFields(account,false);
        test.stopTest();
    }*/
    
    @isTest
    private static void whenGetAccountMap(){
        Account account = [Select Id,Name from Account limit 1];
        Test.startTest();
        Map<Id,Account> accountById = accountServiceInstance.getAccountMap(new Set<Id>{account.Id},'Id,Name');
        system.assertEquals(account.Name, accountById.get(account.Id).Name);
        
        try{
            Map<Id,Account> accountById1 = accountServiceInstance.getAccountMap(new Set<Id>{'8fuh87rh'},'Id,Name');
        }catch(Exception e){
            system.assertEquals('Invalid id: 8fuh87rh',e.getMessage());
        }
                
        try{
            Map<Id,Account> accountById2 = accountServiceInstance.getAccountMap(new Set<Id>{''},'Id,Name');
        }catch(Exception e){
            system.assertEquals('Invalid id: ',e.getMessage());
        }
        
        Test.stopTest();
    }
    
    
    @isTest
    private static void whenGetBusinessTypeMap(){
        Business_Types__c businessType = [Select Id,Name from Business_Types__c limit 1];
        Test.startTest();
        Map<Id,Business_Types__c> businessTypeById = accountServiceInstance.getBusinessTypeMap(new Set<Id>{businessType.Id},'Id,Name');
        system.assertEquals(businessType.Name, businessTypeById.get(businessType.Id).Name);
        
        try{
            Map<Id,Business_Types__c> businessTypeById1 = accountServiceInstance.getBusinessTypeMap(new Set<Id>{'8fuh87rh'},'Id,Name');
        }catch(Exception e){
            system.assertEquals('Invalid id: 8fuh87rh',e.getMessage());
        }
        
        try{
            Map<Id,Business_Types__c> businessTypeById2 = accountServiceInstance.getBusinessTypeMap(new Set<Id>{''},'Id,Name');
        }catch(Exception e){
            system.assertEquals('Invalid id: ',e.getMessage());
        }
        
        Test.stopTest();
    }
    @isTest
    private static void whenUpdateACMIntegrationMessage(){
        Account account = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Simplified_Local_Language_Nm__c,Unified_Hierarchy_View__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'TestChildAccount'];
    	test.startTest();
        accountServiceInstance.updateACMIntegrationMessage(new Set<Id>{account.Id});
        test.stopTest();
    }
    @isTest
    Private static void whenonUpdatedOrMergedAccountsInMDM(){
        List<Account> parentAccounts = [Select Id,Name,RecordtypeId,LastModifiedById from Account Where Name = 'TestParentAccountWithBpId3' LIMIT 1];
        List<Account> accounts = [Select Id,Name,ParentId,RecordtypeId,LastModifiedById from Account Where Name = 'TestChildAccountWithBpId3' LIMIT 1];
        accounts[0].Core_Business_Party_Id__c = '12345';
        test.startTest();
        accountServiceInstance.onUpdatedOrMergedAccountsInMDM(parentAccounts,accounts,new Set<String>{accounts[0].Core_Business_Party_Id__c},new Set<Id>{parentAccounts[0].Id});
        test.stopTest();
    }

    @isTest
    private static void whenupdateRecordtype(){
        List<Account> accounts = [Select Id,Name,ParentId,RecordtypeId,LastModifiedById from Account Where Name = 'TestChildAccountWithBpId3' LIMIT 1];
        test.startTest();
        accountServiceInstance.updateRecordtype(accounts, new Map<Id, Account>(accounts));
        test.stopTest();
    }

    @isTest
    private static void whenupdateParentAccountRecordtype(){
        List<Account> accounts = [Select Id,Name,ParentId,RecordtypeId,LastModifiedById from Account Where Name = 'TestChildAccountWithBpId3' LIMIT 1];
        test.startTest();
        accountServiceInstance.updateParentAccountRecordtype(accounts, new Map<Id, Account>(accounts));
        test.stopTest();
    }

    @isTest
    private static void getComplianceWatchListByAccountId(){
        List<Account> accounts = [Select Id,Name,ParentId,RecordtypeId,LastModifiedById from Account Where Name = 'TestChildAccountWithBpId3' LIMIT 1];
        test.startTest();
        accountServiceInstance.getComplianceWatchListByAccountId(new Set<Id>{accounts[0].Id});
        test.stopTest();
    }

    @isTest
    private static void getActiveBusinessTypeForAccount(){
        List<Account> accounts = [Select Id,Name,ParentId,RecordtypeId,LastModifiedById from Account Where Name = 'TestChildAccountWithBpId3' LIMIT 1];
        test.startTest();
        accountServiceInstance.getActiveBusinessTypeForAccount(new Set<Id>{accounts[0].Id});
        test.stopTest();
    }
}