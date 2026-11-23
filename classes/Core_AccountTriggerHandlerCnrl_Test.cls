@IsTest
public with sharing class Core_AccountTriggerHandlerCnrl_Test {
    private static List<Account> getUpdatedAccounts(Map<Id,Account> accountById){
        List<Account> newaccounts = new List<Account>();
        For(Account account : accountById.values()){
            Account accountToUpdate = new Account();
            accountToUpdate.Id = account.Id;
            accountToUpdate.Name = 'Updated '+account.Name;
            accountToUpdate.Core_Customer_Aggregation_Type__c = account.Core_Customer_Aggregation_Type__c;
            accountToUpdate.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('End Customer Deal Account').getRecordTypeId();
            accountToUpdate.BillingCountryCode  = account.BillingCountryCode;
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
        TriggerHandler.bypass('Core_AccountTriggerHandler');
        insert new Core_Trigger_Executions__c(Name='BypassAccTriggerOnSalesAssistUpdate',Core_Active__c = true,
                Core_Class_Name__c='Test',Core_Description__c='TestDescription',Core_Object__c='TestObject',
                Core_Trigger_Events__c = 'TestEvent');
        insert new Core_Trigger_Executions__c(Name='AccountTriggerExecution',Core_Active__c = true,
                Core_Class_Name__c='Test',Core_Description__c='TestDescription',Core_Object__c='TestObject',
                Core_Trigger_Events__c = 'TestEvent');
        insert new Core_Trigger_Executions__c(Name='UCD_ACM_EnableReltioSync', Core_Active__c = true, Core_Class_Name__c='Test6', Core_Description__c='TestDescription6', Core_Object__c='TestObject6', Core_Trigger_Events__c = 'TestEvent6');

        UCD_ACM_UnitOfWork unitOfWork = new UCD_ACM_UnitOfWork();

        ChannelProgram channelProgram = new ChannelProgram();
        channelProgram.Core_MDF_Channel_Program_Unique_Id_nm__c= '123';
        channelProgram.PRM_inactind__c = true;
        channelProgram.PRM_programCode__c = 'test';
        //channelProgram.Core_MDF_Technical_Program_Name__c = 'Channel MDF';
        //unitOfWork.registerNew(channelProgram);

                // Create Parent Account
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        parentAccount.Core_Data_Country_Nm__c = 'India';
        parentAccount.Industry = 'Agriculture';
        parentAccount.Core_Sub_Industry__c = 'Animal Production';
        parentAccount.Core_Sales_Groups__c='CCG Sales Group';
        unitOfWork.registerNew(parentAccount);

        Account partnerAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestPartnerAccount','Partner Account Group','UNFD_GLBL_CUST');
        unitOfWork.registerNew(partnerAccount);

        Account marketingAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('MarketingRecordType','CoMarketing','UNFD_GLBL_CUST');
        marketingAccount.Core_MDF_External_Group_Id__c = 'test';
        unitOfWork.registerNew(marketingAccount);

        //insert parentAccount;

        // Create Heirarchy Child Account
        Account childAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestHeirarchyChildAccount','Intel Account','UNFD_CTRY_CUST');
        //insert childAccount;
        unitOfWork.registerNew(childAccount);
        // Create End Customer Deal Account
        Account acc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestPlatformEvent','End Customer Deal Account','UNFD_GLBL_CUST');
        acc.parentId = parentAccount.Id;
        acc.Core_Survivor_Account_Id__c = parentAccount.Id;
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        //unitOfWork.registerNew(acc);
        insert acc;
        
        // Create Requested Account
        Account requestedAcc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('RequetedAccount','Requested Account','UNFD_GLBL_CUST');
        requestedAcc.Core_Data_Country_Nm__c = 'India';
        requestedAcc.BillingCountryCode = 'IND';
        requestedAcc.ShippingCountryCode = '';
        unitOfWork.registerNew(requestedAcc);
        //insert requestedAcc;

        // Create Parent Account
        Account parentAccount1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount1','Intel Account','UNFD_GLBL_CUST');
        //insert parentAccount1;
        unitOfWork.registerNew(parentAccount1);

        Account parentAccount2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount2','Intel Account','UNFD_GLBL_CUST');
        //insert parentAccount2;
        unitOfWork.registerNew(parentAccount2);
        // Create Heirarchy Child Account
        Account flChild = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('FirstLevelChild1','Intel Account','UNFD_INTRMD_CUST');
        flChild.ParentId = parentAccount1.Id;
        //insert flChild;
        unitOfWork.registerNew(flChild);
        // Create Heirarchy Child Account
        Account slChild = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('SecondLevelChild1','Intel Account','UNFD_CTRY_CUST');
        slChild.ParentId = flChild.Id;
        //insert slChild;
        unitOfWork.registerNew(slChild);
        // Create Heirarchy Child Account
        Account tlChild1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('ThirdLevelChild1','Intel Account','UNFD_LOC_CUST');
        tlChild1.ParentId = slChild.Id;
        //insert tlChild1;
        unitOfWork.registerNew(tlChild1);
        // Create Heirarchy Child Account
        Account tlChild2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('ThirdLevelChild2','Intel Account','UNFD_LOC_CUST');
        tlChild2.ParentId = slChild.Id;
        //insert tlChild2;
        unitOfWork.registerNew(tlChild2);

         // Create Business Type
        // List<Business_Types__c> businessTypes = new List<Business_Types__c>();
        Business_Types__c businessTypes1 = UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Direct Price Exception','DIR_PRC_EXCPT');
        Business_Types__c businessTypes2 = UCD_ACM_Cntrlr_TestDataInitialization.createBusinessType('Supply Demand Revenue','SD_REV');
        //insert businessTypes;
        unitOfWork.registerNew(businessTypes1);
        unitOfWork.registerNew(businessTypes2);
 
         // Create Account Business Type
         List<Account_Business_Types__c> accountBusinessTypes = new List<Account_Business_Types__c>();
         Schema.sObjectField schemaFields = Account_Business_Types__c.Account__c.getDescribe().getSObjectField();

       //  For(Business_Types__c businessType : businessTypes){
             //accountBusinessTypes.add(UCD_ACM_Cntrlr_TestDataInitialization.createAccountBusinessType(acc.Id,businessType.Id));,
             Account_Business_Types__c accBuisnessType1 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountBusinessType(acc.Id,businessTypes1.Id);
             Account_Business_Types__c accBuisnessType2 = UCD_ACM_Cntrlr_TestDataInitialization.createAccountBusinessType(acc.Id,businessTypes2.Id);
             //unitOfWork.registerNew(accBuisnessType2,schemaFields,acc);
             //unitOfWork.registerNew(accBuisnessType1,schemaFields,acc);
             //unitOfWork.registerNew(accBuisnessType1);
        // }
         //insert accountBusinessTypes;
 
         // Create Compliance Watch List
         List<Core_Account_Compliance_Watch_List__c> complianceWatchLists = new List<Core_Account_Compliance_Watch_List__c>();
         complianceWatchLists.add(UCD_ACM_Cntrlr_TestDataInitialization.createComplianceWatchList(acc.Id,'NOTRDOUT'));
         complianceWatchLists.add(UCD_ACM_Cntrlr_TestDataInitialization.createComplianceWatchList(acc.Id,'DPL'));
         //insert complianceWatchLists;
         //unitOfWork.registerNew(complianceWatchLists);

         unitOfWork.commitWork();

         List<Account> lstAccount = [Select id from Account];
         System.debug('lstAccount==>'+lstAccount);
         TriggerHandler.bypass('Core_AccountTriggerHandler');

    }


    @isTest
        private static void whenTriggerPlatformEventOnUpdate(){
            Map<Id,Account> accountById = new Map<Id,Account>([Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'TestPlatformEvent']);
            Test.startTest();
            Core_AccountTriggerHandlerController.triggerPlatformEventOnUpdate(getUpdatedAccounts(accountById),accountById);
            Test.stopTest();
        }
    
    
        @isTest
        private static void whenThrowException(){
            Map<Id,Account> accountById = new Map<Id,Account>([Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'TestPlatformEvent']);
            Test.startTest();
            UCD_ACM_AccountService.isTestException = true;
            Core_AccountTriggerHandlerController.triggerPlatformEventOnUpdate(getUpdatedAccounts(accountById),accountById);
            Core_AccountTriggerHandlerController.updateAccountRecordType(getUpdatedAccounts(accountById),accountById);
            Core_AccountTriggerHandlerController.restrictUpdatingSFFields(getUpdatedAccounts(accountById),accountById.values());
            Core_AccountTriggerHandlerController.updateHierarchyFields(null);
            Core_AccountTriggerHandlerController.updateAccountAddress(null);
            Test.stopTest();
        }
        
    
        @isTest
        private static void whenRestrictUpdatingSFFields(){
            List<Account> oldAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry from Account where Name = 'TestPlatformEvent'];
            Account newAccount = oldAccount[0];
            newAccount.Name = 'UpdatedTestPlatformEvent';
            Test.startTest();
            Core_AccountTriggerHandlerController.restrictUpdatingSFFields(new List<Account>{newAccount},oldAccount);
            Core_AccountTriggerHandlerController.checkRetailCampaignShare(new List<Account>{newAccount});
            
            Test.stopTest();
        }
    
        @isTest
        private static void whenAccountRecordTypeUpdate(){
            Map<Id,Account> accountById = new Map<Id,Account>([Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Country_Cd__c,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,BillingCity,BillingStreet from Account where Name = 'RequetedAccount' limit 1]) ;
            Test.startTest();
            Core_AccountTriggerHandlerController.updateAccountRecordType(getUpdatedAccounts(accountById),accountById);
            Test.stopTest();
        }
        
        @isTest
        private static void whenParentChangeUpdateHierarchyFields(){
            Map<Id,Account> oldAccount = new Map<Id,Account>([Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'TestHeirarchyChildAccount' limit 1]);
            List<Account> pAccount = [Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'TestParentAccount'];
            Account newAccount = oldAccount.Values()[0];
            Account parentAccount = pAccount[0];
            newAccount.ParentId = parentAccount.Id;
            Test.startTest();
            Core_AccountTriggerHandlerController.updateHierarchyFields(new List<Account>{newAccount}, oldAccount, false);
            Core_AccountTriggerHandlerController.validateAccountHierarchy(new List<Account>{newAccount},oldAccount);
            Test.stopTest();
        }
    
        @isTest
        private static void whenAccountChangeCheckDupCheck(){
            List<Account> allAccounts = [Select id,name,RecordTypeId,BillingCountryCode,Core_Account_Record_Type_Dup_Check__c from Account where name = 'TestParentAccount1'];
            Test.startTest();
            Core_AccountTriggerHandlerController.accountRecordTypeDupFieldUpdate(allAccounts);
            Test.stopTest();
        }
        
        @isTest
        private static void whenCustAggrChangeUpdateHierarchyFields(){
            Map<Id,Account> oldAccount = new Map<Id,Account>([Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'TestHeirarchyChildAccount' limit 1]);
            Account newAccount = oldAccount.Values()[0];
            List<Account> newAcc = new List<Account>();
            newAccount.Core_Customer_Aggregation_Type__c = 'UNFD_INTRMD_CUST';
            Test.startTest();
            Core_AccountTriggerHandlerController.updateHierarchyFields(new List<Account>{newAccount}, oldAccount, false);
            Test.stopTest();
        }
    
        @isTest
        private static void whenParentChangeUpdateChildHierarchyFields(){        
            Map<Id,Account> pAccount = new Map<Id,Account>([Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'TestParentAccount2' limit 1]);
            Map<Id,Account> flChild = new Map<Id,Account>([Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'FirstLevelChild1']);
            List<Account> newAccounts = getUpdatedHierarchyAccounts(flChild,pAccount.Values()[0]);
            Test.startTest();
            Core_AccountTriggerHandlerController.updateHierarchyFields(newAccounts, flChild, true);
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
            Core_AccountTriggerHandlerController.triggerReltioSync(System.TriggerOperation.AFTER_UPDATE,new List<Account>{acctFLChild},new Map<Id,Account>(new List<Account>{acctFLChild}),flChild.Values(),flChild);
            Test.stopTest();
        }
        
        @isTest
        private static void whenUpdateParentOnAccount(){
            List<Account> listOfAccount=[Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,LastModifiedById from Account where Name = 'TestParentAccount2'];
            List<Account> oldAccount =[Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,LastModifiedById from Account where Name = 'TestParentAccount2'];
            oldAccount[0].Core_Business_Party_Id__c='65432';
            Map<Id,Account> oldAccountMap=new Map<Id,Account>(oldAccount); 
            Test.startTest();
            Core_AccountTriggerHandlerController.updateParentOnAccount(listOfAccount,oldAccountMap);
            Test.stopTest();
    
        }

        @isTest
        private static void whenAccountObjectBeforeHandler(){
                List<Account> listAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,Core_Prime_Account_Name__c,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry from Account where Name = 'TestParentAccount'];
                Map<Id,Account> accountById = new Map<Id,Account>([Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'TestParentAccount']); 
                listAccount[0].Core_CPM_ID__c='cpm1234567890Id';
                Test.startTest();
                Core_AccountTriggerHandlerController.accountObjectBeforeHandler(listAccount,null,accountById);
                listAccount[0].Core_CPM_ID__c='cpm1234567890Id,cpm1234567890Id';
                Core_AccountTriggerHandlerController.accountObjectBeforeHandler(listAccount,null,accountById);
                Test.stopTest();
        }

        @isTest
        private static void whenUpdateAccountAddress(){
                List<Account> listAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry from Account where Name = 'TestParentAccount'];
                listAccount[0].BillingCountryCode = '';
                listAccount[0].ShippingCountryCode = '';

                Test.startTest();
                Core_AccountTriggerHandlerController.updateAccountAddress(listAccount);
                Test.stopTest();
        }

        @isTest
        private static void whenUpdateHierarchyFields(){
            List<Account> listAccount = [Select Id,Name,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId from Account where Name = 'TestHeirarchyChildAccount' limit 1];
            Test.startTest();
            Core_AccountTriggerHandlerController.updateHierarchyFields(listAccount);
            Test.stopTest();
        }
        
        @isTest
        private static void whenPreventMultipleVCForSameProg(){
                List<Account> listAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,Core_Data_Country_Cd__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry from Account where Name = 'MarketingRecordType']; 
                Test.startTest();
                Core_AccountTriggerHandlerController.preventMultipleVCForSameProg(listAccount);
                Test.stopTest();
        }

        @isTest
        private static void whenValidateTierValues(){
                List<Account> lstAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry from Account where Name = 'TestParentAccount1'];
                lstAccount[0].Core_Account_Tier__c = 'CCG-CCG';
                Test.startTest();                               
                Core_AccountTriggerHandlerController.validateTierValues(lstAccount);

                lstAccount[0].Core_Account_Tier__c = 'DCG-DCG';
                Core_AccountTriggerHandlerController.validateTierValues(lstAccount);

                lstAccount[0].Core_Account_Tier__c = 'GA-GA';
                Core_AccountTriggerHandlerController.validateTierValues(lstAccount);

                lstAccount[0].Core_Account_Tier__c = 'IOTG-IOTG';
                Core_AccountTriggerHandlerController.validateTierValues(lstAccount);

                lstAccount[0].Core_Account_Tier__c = 'ISG-ISG';
                Core_AccountTriggerHandlerController.validateTierValues(lstAccount);

                lstAccount[0].Core_Account_Tier__c = 'NTG-NTG';
                Core_AccountTriggerHandlerController.validateTierValues(lstAccount);

                lstAccount[0].Core_Account_Tier__c = 'PSG-PSG';
                Core_AccountTriggerHandlerController.validateTierValues(lstAccount);

                lstAccount[0].Core_Account_Tier__c = 'RSG-RSG';
                Core_AccountTriggerHandlerController.validateTierValues(lstAccount);

                Test.stopTest();
        }

        @isTest
        private static void whenCreateGroupForComarketingAccount(){
                List<Account> listAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,Core_Data_Country_Cd__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,Core_MDF_Channel_Program__c from Account where Name = 'MarketingRecordType']; 
                Test.startTest();
                Core_AccountTriggerHandlerController.createGroupForComarketingAccount(listAccount);
                Test.stopTest();
        }

        @isTest
        private static void whenSharingWithNewAcctGrps(){
                List<Account> listAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,Core_Data_Country_Cd__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry from Account where Name = 'TestPlatformEvent']; 
                Test.startTest();
                Core_AccountTriggerHandlerController.sharingWithNewAcctGrps(listAccount);
                Test.stopTest();
        }
        @isTest
        private static void whenValidateMDFParentFundAccChanges(){
                ChannelProgram channelProgram = new ChannelProgram();
                channelProgram.name = 'ChannelPartnerRecord';
                channelProgram.Core_MDF_Channel_Program_Unique_Id_nm__c= '123';
                channelProgram.PRM_inactind__c = true;
                channelProgram.PRM_programCode__c = 'test';
                insert channelProgram;

                List<ChannelProgram> channelPrograms = [select id, Core_MDF_Channel_Program_Unique_Id_nm__c, PRM_inactind__c,PRM_programCode__c,Core_MDF_Technical_Program_Name__c from ChannelProgram];
                channelPrograms[0].Core_MDF_Technical_Program_Name__c = 'Retail Marketing Funds';

                List<Account> listAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,Core_Data_Country_Cd__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,Core_MDF_Parent_Fund_Account__c,Core_MDF_External_Group_Id__c from Account where Name = 'MarketingRecordType'];
                List<Account> fundAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,Core_Data_Country_Cd__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,Core_MDF_External_Group_Id__c from Account where Name = 'TestPlatformEvent']; 

                listAccount[0].Core_MDF_Parent_Fund_Account__c = fundAccount[0].Id ;
                listAccount[0].Core_MDF_External_Group_Id__c = 'test';
                listAccount[0].Core_MDF_Channel_Program__c = channelPrograms[0].Id ;

                Map<Id,Account> accountById = new Map<Id,Account>([Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet,Core_MDF_Parent_Fund_Account__c from Account where Name = 'MarketingRecordType']); 

                Test.startTest();
                Core_AccountTriggerHandlerController.validateMDFParentFundAccChanges(listAccount,accountById);
                Test.stopTest();
        }


        @isTest
        private static void whenCreateNodeSharingGroup(){
                Map<Id,Account> accountById = new Map<Id,Account>([Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'MarketingRecordType']); 
                Test.startTest();
                Core_AccountTriggerHandlerController.createNodeSharingGroup(accountById);
                Test.stopTest();
        }

        @isTest
        private static void whenAccountObjectAfterDelete(){
                List<Account> listAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,BillingCity,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Core_Account_Country__c,Core_Account_State_Province__c,Core_CIM_ID__c from Account where Name = 'TestParentAccount1'];
                Test.startTest();
                Core_AccountTriggerHandlerController.accountObjectAfterDelete(null,null,listAccount,null);
                Test.stopTest();
        }
        
        @isTest
        private static void whenAccountRecordTypeAfterUpdate(){
                List<Account> newAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry from Account where Name = 'TestParentAccount1'];
                List<Account> partnerAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry from Account where Name = 'TestPartnerAccount'];

                Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
                accGroupMem.Core_Partner_Account_Id__c =partnerAccount[0].Id;
                accGroupMem.Core_Intel_Account_Id__c =newAccount[0].Id;
                insert accGroupMem;

                List<Account> newAccountforMap = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'TestParentAccount1'];
                newAccountforMap[0].RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
                Map<Id,Account> newAccountMap = new  Map<Id,Account>(newAccountforMap);

                Map<Id,Account> oldAccountMap = new Map<Id,Account>([Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'TestParentAccount1']);
                Test.startTest();
                Core_AccountTriggerHandlerController.accountRecordTypeAfterUpdate(newAccount,oldAccountMap,newAccountMap);
                Test.stopTest();
        }
        

        @isTest
        private static void whenAccountTeamAuditCompletion(){
                List<Account> listAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry from Account where Name = 'TestParentAccount'];
                Map<Id,Account> accountById = new Map<Id,Account>([Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'TestParentAccount']); 
                listAccount[0].Core_Account_Team_Audit_Complete__c=true;
                listAccount[0].Core_Account_Team_Audit_Due_Date__c=Date.today();
                Account acct = accountById.Values()[0];
                acct.Core_Account_Team_Audit_Complete__c=false;
                Test.startTest();
                Core_AccountTriggerHandlerController.accountTeamAuditCompletion(listAccount,accountById);
                Test.stopTest();
        }
        
        @isTest
        private static void whenmembershipFlagUpdate(){
                List<Account> oldAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,Core_Data_Country_Cd__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,OwnerId from Account where Name = 'TestParentAccount'];
                oldAccount[0].ownerId = UserInfo.getUserId();
                Map<Id,Account> oldMapAccount = new Map<Id,Account> (oldAccount);
                List<Account> newAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,Core_Data_Country_Cd__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,OwnerId from Account where Name = 'TestParentAccount'];
                newAccount[0].ownerId = Label.Core_Uncovered_Account_ID;

                List<Account> partnerAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry from Account where Name = 'TestPartnerAccount'];

                Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
                accGroupMem.Core_Partner_Account_Id__c =partnerAccount[0].Id;
                accGroupMem.Core_Intel_Account_Id__c =newAccount[0].Id;
                insert accGroupMem;
                
                Map<Id,Account> newMapAccount = new Map<Id,Account> (newAccount);
                Test.startTest();
                Core_AccountTriggerHandlerController.membershipFlagUpdate(oldAccount,newAccount,oldMapAccount,newMapAccount);
                Test.stopTest();
        }

        @isTest
        private static void whenInvokeRollUpScenario(){
                List<Account> listAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,Core_Data_Country_Cd__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_IPA_One_Partner_Id__c from Account where Name = 'TestPlatformEvent'];
                Map<Id,Account> accountById = new Map<Id,Account>([Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Data_Country_Cd__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_IPA_One_Partner_Id__c from Account where Name = 'TestPlatformEvent']); 
                Test.startTest();
                Core_AccountTriggerHandlerController.invokeRollUpScenario(listAccount,accountById);
                Test.stopTest();
        }

        @isTest
        private static void whenpreventUncoveredAccountChangeOnOppStatus(){
                Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
                List<Account> listAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,OwnerId from Account where Name = 'TestParentAccount'];
                listAccount[0].OwnerId = Label.Core_Uncovered_Account_ID;

                List<Account> oldAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,OwnerId from Account where Name = 'TestParentAccount'];
                oldAccount[0].OwnerId = UserInfo.getUserId();

                Map<Id,Account> accountById = new Map<Id,Account>(oldAccount);

                Opportunity oppForLoss = new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = newOppRecTypeId,
                AccountId = listAccount[0].Id,StageName = 'Qualifying', CloseDate = System.Date.today().addYears(1));
                insert oppForLoss;
               
                Test.startTest();
                Core_AccountTriggerHandlerController.preventUncoveredAccountChangeOnOppStatus(listAccount,accountById);
                Test.stopTest();
        }

        @isTest
        private static void whenPreventAEUserAccountOwnership(){
            List<Account> listAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,OwnerId from Account where Name = 'TestParentAccount'];
            
            List<Account> oldAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,OwnerId from Account where Name = 'TestParentAccount'];
            oldAccount[0].OwnerId = Label.Core_Uncovered_Account_ID;

            Map<Id,Account> accountById = new Map<Id,Account>(oldAccount);

            Core_AccountTriggerHandlerController.preventAEUserAccountOwnership(listAccount,accountById);
        }

        @isTest
        private static void whenPreventUncoveredAccountChange(){
            List<Account> listAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,OwnerId from Account where Name = 'TestParentAccount'];
            listAccount[0].OwnerId = Label.Core_Uncovered_Account_ID;

            List<Account> oldAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,OwnerId from Account where Name = 'TestParentAccount'];
            oldAccount[0].OwnerId = UserInfo.getUserId();

            Map<Id,Account> accountById = new Map<Id,Account>(oldAccount);
            Core_AccountTriggerHandlerController.preventUncoveredAccountChange(listAccount,accountById);
            
        }
        @isTest
        private static void whenUpdateParentOnAccountTest(){
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
                Core_AccountTriggerHandlerController.updateParentOnAccount(new List<Account>{newAccount},oldAccount);
                Test.stopTest(); 
            }
        }
}