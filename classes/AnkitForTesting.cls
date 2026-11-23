@IsTest
public with sharing class AnkitForTesting {
    

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
        channelProgram.name = 'ChannelPartnerRecord';
        channelProgram.Core_MDF_Channel_Program_Unique_Id_nm__c= '123';
        channelProgram.PRM_inactind__c = true;
        channelProgram.PRM_programCode__c = 'test';
        insert channelProgram;
       // unitOfWork.registerNew(channelProgram);


        
        Group testGroup = new Group();
        testGroup.Name = 'testGroup';
        testGroup.DeveloperName = 'Core_MDF_CCP_GRP';
        insert testGroup;
        //unitOfWork.registerNew(testGroup);



        // Create Parent Account
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        parentAccount.Core_Data_Country_Nm__c = 'India';
        parentAccount.Industry = 'Agriculture';
        parentAccount.Core_Sub_Industry__c = 'Animal Production';
        parentAccount.Core_Sales_Groups__c='EMEA Partner Holding';
        unitOfWork.registerNew(parentAccount);


        // Create End Customer Deal Account
        Account acc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestPlatformEvent','End Customer Deal Account','UNFD_GLBL_CUST');
        acc.parentId = parentAccount.Id;
        acc.Core_Survivor_Account_Id__c = parentAccount.Id;
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        unitOfWork.registerNew(acc);
        //insert acc;

        // Create Heirarchy Child Account
        Account childAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestHeirarchyChildAccount','Intel Account','UNFD_CTRY_CUST');
        unitOfWork.registerNew(childAccount);

        // Create Heirarchy Child Account
        Account flChild = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('FirstLevelChild1','Intel Account','UNFD_INTRMD_CUST');
        flChild.ParentId = parentAccount.Id;
        //insert flChild;
        unitOfWork.registerNew(flChild);

        // Create Heirarchy Child Account
        Account slChild = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('SecondLevelChild1','Intel Account','UNFD_CTRY_CUST');
        slChild.ParentId = flChild.Id;
        //insert slChild;
        unitOfWork.registerNew(slChild);
        

        

        Account partnerAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestPartnerAccount','Partner Account Group','UNFD_GLBL_CUST');
        unitOfWork.registerNew(partnerAccount);
        //insert partnerAccount;


        












        Boolean result = unitOfWork.commitWork();
        System.debug('result===>'+result);
         List<Account> lstAccount = [Select id from Account];
         System.debug('lstAccount==>'+lstAccount);
         TriggerHandler.bypass('Core_AccountTriggerHandler');

         Account marketingAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('MarketingRecordType','CoMarketing','UNFD_GLBL_CUST');
        marketingAccount.Core_MDF_External_Group_Id__c = testGroup.Id;
        marketingAccount.Core_MDF_Parent_Fund_Account__c = parentAccount.Id;
        marketingAccount.Core_MDF_Channel_Program__c = channelProgram.Id;
        //unitOfWork.registerNew(marketingAccount);
        insert marketingAccount;

        Account marketingNode1Account = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Test IPA Node Account 1','CoMarketing','UNFD_GLBL_CUST');
        marketingNode1Account.Core_MDF_External_Group_Id__c = testGroup.Id;
        marketingNode1Account.Core_MDF_Parent_Fund_Account__c = marketingAccount.Id;
        marketingNode1Account.Core_MDF_Channel_Program__c = channelProgram.Id;
        //unitOfWork.registerNew(marketingNode1Account);
        insert marketingNode1Account;

        
        Account marketingNode2Account = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Test IPA Node Account 2','CoMarketing','UNFD_GLBL_CUST');
        marketingNode2Account.Core_MDF_External_Group_Id__c = testGroup.Id;
        marketingNode2Account.Core_MDF_Parent_Fund_Account__c = marketingNode1Account.Id;
        marketingNode2Account.Core_MDF_Channel_Program__c = channelProgram.Id;
        //unitOfWork.registerNew(marketingNode2Account);
        insert marketingNode2Account;

        
        Account marketingNode3Account = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Test IPA Node Account 3','CoMarketing','UNFD_GLBL_CUST');
        marketingNode3Account.Core_MDF_External_Group_Id__c = testGroup.Id;
        marketingNode3Account.Core_MDF_Parent_Fund_Account__c = marketingNode2Account.Id;
        marketingNode3Account.Core_MDF_Channel_Program__c = channelProgram.Id;
        //unitOfWork.registerNew(marketingNode3Account);
        insert marketingNode3Account;

        
        Account marketingNode4Account = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('Test IPA Node Account 4','CoMarketing','UNFD_GLBL_CUST');
        marketingNode4Account.Core_MDF_External_Group_Id__c = testGroup.Id;
        marketingNode4Account.Core_MDF_Parent_Fund_Account__c = marketingNode3Account.Id;
        marketingNode4Account.Core_MDF_Channel_Program__c = channelProgram.Id;
        //unitOfWork.registerNew(marketingNode4Account);
        insert marketingNode4Account;


   
    }


        @isTest
        private static void whenRestrictUpdatingSFFields(){
            List<Account> oldAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,ShippingCountryCode,ShippingCountry from Account where Name = 'TestPlatformEvent'];
            Account newAccount = oldAccount[0];
            newAccount.Name = 'UpdatedTestPlatformEvent';
            Test.startTest();
            Core_AccountTriggerHandlerController.checkRetailCampaignShare(new List<Account>{newAccount});
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
            Core_AccountTriggerHandlerController.validateAccountHierarchy(new List<Account>{newAccount},oldAccount);
            Core_MDF_AccountServiceHandler.validateAccountHierarchy(new List<Account>{newAccount},oldAccount);
            Test.stopTest();
        }

        @isTest
        private static void whenAccountChangeCheckDupCheck(){
            List<Account> allAccounts = [Select id,name,RecordTypeId,BillingCountryCode,Core_Account_Record_Type_Dup_Check__c from Account where name = 'TestParentAccount'];
            Test.startTest();
            Core_AccountTriggerHandlerController.accountRecordTypeDupFieldUpdate(allAccounts);
            Test.stopTest();
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
        private static void whenPreventMultipleVCForSameProg(){

                List<Account> listAccount = [Select Id,Core_MDF_Channel_Program__c,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry from Account where Name = 'MarketingRecordType']; 
                List<ChannelProgram> channelProgram = [SELECT id , name,Core_MDF_Channel_Program_Unique_Id_nm__c,PRM_inactind__c,PRM_programCode__c FROM ChannelProgram ];

            	listAccount[0].Core_MDF_Channel_Program__c = channelProgram[0].Id ;
                Test.startTest();
                Core_AccountTriggerHandlerController.preventMultipleVCForSameProg(listAccount);
                Test.stopTest();
        }


        @isTest
        private static void whenValidateTierValues(){
                List<Account> lstAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry from Account where Name = 'TestParentAccount'];
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
                List<Account> listAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,Core_MDF_Channel_Program__c from Account where Name = 'MarketingRecordType']; 
                Test.startTest();
            	Core_AccountTriggerHandlerController.createGroupForComarketingAccount(listAccount);
                Core_MDF_AccountServiceHandler.createGroupForComarketingAccount(listAccount);
                Test.stopTest();
        }


        @isTest
        private static void whenSharingWithNewAcctGrps(){
                List<Account> listAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry from Account where Name = 'TestPlatformEvent']; 
                Test.startTest();
            	Core_AccountTriggerHandlerController.sharingWithNewAcctGrps(listAccount);
                Core_MDF_AccountServiceHandler.sharingWithNewAcctGrps(listAccount);
                Test.stopTest();
        }

        
        
        @isTest
        private static void whenValidateMDFParentFundAccChanges(){
            
                List<Group> testGroup1 = [Select id, Name, DeveloperName from Group Where Name = 'testGroup'];

                List<ChannelProgram> channelPrograms = [select id, Core_MDF_Channel_Program_Unique_Id_nm__c, PRM_inactind__c,PRM_programCode__c,Core_MDF_Technical_Program_Name__c from ChannelProgram];
                channelPrograms[0].Core_MDF_Technical_Program_Name__c = 'Retail Marketing Funds';

                List<Account> listAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,Core_MDF_Parent_Fund_Account__c,Core_MDF_External_Group_Id__c from Account where Name = 'MarketingRecordType'];
                List<Account> fundAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,Core_MDF_External_Group_Id__c from Account where Name = 'TestPlatformEvent']; 

                listAccount[0].Core_MDF_Parent_Fund_Account__c = fundAccount[0].Id ;
                listAccount[0].Core_MDF_External_Group_Id__c = testGroup1[0].id;
                listAccount[0].Core_MDF_Channel_Program__c = channelPrograms[0].Id ;

                Map<Id,Account> accountById = new Map<Id,Account>([Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet,Core_MDF_Parent_Fund_Account__c from Account where Name = 'MarketingRecordType']); 

                Test.startTest();
            	Core_AccountTriggerHandlerController.validateMDFParentFundAccChanges(listAccount,accountById);
                Core_MDF_AccountServiceHandler.validateMDFParentFundAccChanges(listAccount,accountById);
                Test.stopTest();
        }


        @isTest
        private static void whenCreateNodeSharingGroup(){
                Map<Id,Account> accountById = new Map<Id,Account>([Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'MarketingRecordType']); 
                Test.startTest();
            	Core_AccountTriggerHandlerController.createNodeSharingGroup(accountById);
                Core_MDF_AccountServiceHandler.createNodeSharingGroup(accountById);
                Test.stopTest();
        }


        @isTest
        private static void whenAccountObjectAfterDelete(){
                List<Account> listAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,BillingCity,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Core_Account_Country__c,Core_Account_State_Province__c,Core_CIM_ID__c from Account where Name = 'TestParentAccount'];
                Test.startTest();
                Core_AccountTriggerHandlerController.accountObjectAfterDelete(null,null,listAccount,null);
                Test.stopTest();
        }


        @isTest
        private static void whenAccountRecordTypeAfterUpdate(){
                List<Account> newAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry from Account where Name = 'TestParentAccount'];
                List<Account> partnerAccount = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry from Account where Name = 'TestPartnerAccount'];

                Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
                accGroupMem.Core_Partner_Account_Id__c =partnerAccount[0].Id;
                accGroupMem.Core_Intel_Account_Id__c =newAccount[0].Id;
                insert accGroupMem;

                List<Account> newAccountforMap = [Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'TestParentAccount'];
                newAccountforMap[0].RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
                Map<Id,Account> newAccountMap = new  Map<Id,Account>(newAccountforMap);

                Map<Id,Account> oldAccountMap = new Map<Id,Account>([Select Id,Name,Core_Business_Party_Id__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet from Account where Name = 'TestParentAccount']);
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
                List<Account> oldAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,OwnerId from Account where Name = 'TestParentAccount'];
                oldAccount[0].ownerId = UserInfo.getUserId();
                Map<Id,Account> oldMapAccount = new Map<Id,Account> (oldAccount);
                List<Account> newAccount = [Select Id,Name,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,OwnerId from Account where Name = 'TestParentAccount'];
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
                List<Account> listAccount = [Select Id,Name,Core_Account_Type__c,Core_IPA_Partner_Segment__c,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Prime_Account_Name__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_IPA_One_Partner_Id__c from Account where Name = 'TestPlatformEvent'];
                Map<Id,Account> accountById = new Map<Id,Account>([Select Id,Name,Core_IPA_Partner_Segment__c,Core_Survivor_Account_Id__c,Core_Business_Party_Id__c,Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Nm__c,Core_Customer_Aggregation_Type__c,ParentId,RecordTypeId,BillingCountryCode,BillingCountry,ShippingCountryCode,ShippingCountry,BillingCity,BillingStreet,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_IPA_One_Partner_Id__c,Core_Account_Type__c from Account where Name = 'TestPlatformEvent']); 
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
                Test.startTest();
                update newAccount;
                newAccount.Core_Business_Party_Id__c = '849679';
                update newAccount;
                Test.stopTest(); 
            }
        }


        @isTest
        private static void testUpdateHROnNodeAccounts() {
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
                
            //Co-Marketing Account
            Account acc = [Select Id, Name,RecordTypeId from Account where Name =: 'MarketingRecordType' limit 1];
            acc.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
            acc.Core_Geo__c = 'APJ';
            upsert acc;
            
            //Create a co-Marketing Node account as child of another Co-Marketing Node Account
            List<Account> accList = new List<Account>();
            Account acc1 = new Account();
            acc1.Name = 'Test CoMarketing Account - child Account';
            acc1.Core_MDF_Parent_Fund_Account__c = acc.Id;
            acc1.RecordTypeId = acc.RecordTypeId;
            acc1.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
            acc1.Core_Geo__c ='APJ';
            accList.add(acc1);
            
            Test.startTest();
            
            //Success scenario
            Core_AccountTriggerHandlerController.updateHostRegionOnNodeAccounts(accList);
            Core_MDF_AccountServiceHandler.updateHostRegionOnNodeAccounts(accList);
            //Exception scenario
            List<Account> emptyAccList;
            Core_AccountTriggerHandlerController.updateHostRegionOnNodeAccounts(emptyAccList);
            Core_MDF_AccountServiceHandler.updateHostRegionOnNodeAccounts(emptyAccList);
    
            Test.stopTest();
        }


        @isTest
        private static void testUpdateHROnNodeAccountsGeo() {
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
                
            //Co-Marketing Account
            Account acc = [Select Id, Name,RecordTypeId from Account where Name =: 'MarketingRecordType' limit 1];
            acc.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
            acc.Core_Geo__c = 'APJ';
            upsert acc;
            
            //Create a co-Marketing Node account as child of another Co-Marketing Node Account
            List<Account> accList = new List<Account>();
            Account acc1 = new Account();
            acc1.Name = 'Test CoMarketing Account - child Account';
            acc1.Core_MDF_Parent_Fund_Account__c = acc.Id;
            acc1.RecordTypeId = acc.RecordTypeId;
            acc1.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
            accList.add(acc1);
            
            Test.startTest();
            
            //Success scenario
            Core_AccountTriggerHandlerController.updateHostRegionOnNodeAccounts(accList);
            Test.stopTest();
        }

        
        @isTest
        private static void testUpdateHROnNodeAccountsSubGeo() {
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
                
            //Co-Marketing Account
            Account acc = [Select Id, Name,RecordTypeId from Account where Name =: 'MarketingRecordType' limit 1];
            acc.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
            acc.Core_Geo__c = 'APJ';
            upsert acc;
            
            //Create a co-Marketing Node account as child of another Co-Marketing Node Account
            List<Account> accList = new List<Account>();
            Account acc1 = new Account();
            acc1.Name = 'Test CoMarketing Account - child Account';
            acc1.Core_MDF_Parent_Fund_Account__c = acc.Id;
            acc1.RecordTypeId = acc.RecordTypeId;
            acc1.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
            acc1.Core_Geo__c ='ASMO';
            acc1.Core_Sub_Geo__c='LAR';
            accList.add(acc1);
            
            Test.startTest();
            
            //Success scenario
            Core_AccountTriggerHandlerController.updateHostRegionOnNodeAccounts(accList);
            Test.stopTest();
        }

        @isTest
        private static void testProcessCCPTriggerUpdates() {
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
            
            
             //Co-Marketing Account
            Account virtualCorpAcc = [Select Id, Name,RecordTypeId from Account where Name =: 'MarketingRecordType' limit 1];
            virtualCorpAcc.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
            virtualCorpAcc.Core_Geo__c = 'APJ';
            virtualCorpAcc.BillingCity='Pune';
            virtualCorpAcc.BillingCountry='IND';
            virtualCorpAcc.BillingCountryCode = 'IND';
            virtualCorpAcc.BillingState = 'MH';
            virtualCorpAcc.BillingStateCode = 'MH'; 
            virtualCorpAcc.BillingStreet = 'TestStreet';
            virtualCorpAcc.Core_MDF_Active_Ind__c =true;
            upsert virtualCorpAcc;
            
            //Create Virtual Corp Account
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Core_MDF_Co_Marketing_Record_Type_Name).getRecordTypeId();
            
            
            //Create Node Account 1
            Account nodeAcc1 = [Select Id, Name from Account where Name =: 'Test IPA Node Account 1' limit 1];
            nodeAcc1.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
            nodeAcc1.BillingCity='Pune';
            nodeAcc1.BillingCountry='IND';
            nodeAcc1.BillingCountryCode = 'IND';
            nodeAcc1.BillingState = 'MH';
            nodeAcc1.BillingStateCode = 'MH'; 
            nodeAcc1.BillingStreet = 'TestStreet';
            nodeAcc1.Core_MDF_Active_Ind__c =true;
            upsert nodeAcc1;
            
            //Create Node Account 2
            Account nodeAcc2 = [Select Id, Name from Account where Name =: 'Test IPA Node Account 2' limit 1];
            nodeAcc2.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
            nodeAcc2.BillingCity='Pune';
            nodeAcc2.BillingCountry='IND';
            nodeAcc2.BillingCountryCode = 'IND';
            nodeAcc2.BillingState = 'MH';
            nodeAcc2.BillingStateCode = 'MH'; 
            nodeAcc2.BillingStreet = 'TestStreet';
            nodeAcc2.Core_MDF_Active_Ind__c =true;
            upsert nodeAcc2;
            
            //Create Node Account 3
            Account nodeAcc3 = [Select Id, Name from Account where Name =: 'Test IPA Node Account 3' limit 1];
            nodeAcc3.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
            nodeAcc3.BillingCity='Pune';
            nodeAcc3.BillingCountry='IND';
            nodeAcc3.BillingCountryCode = 'IND';
            nodeAcc3.BillingState = 'MH';
            nodeAcc3.BillingStateCode = 'MH'; 
            nodeAcc3.BillingStreet = 'TestStreet';
            nodeAcc3.Core_MDF_Active_Ind__c =true;
            upsert nodeAcc3;
            
            //Create Node Account 4
            Account nodeAcc4 = [Select Id, Name from Account where Name =: 'Test IPA Node Account 4' limit 1];
            nodeAcc4.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
            nodeAcc4.BillingCity='Pune';
            nodeAcc4.BillingCountry='IND';
            nodeAcc4.BillingCountryCode = 'IND';
            nodeAcc4.BillingState = 'MH';
            nodeAcc4.BillingStateCode = 'MH'; 
            nodeAcc4.BillingStreet = 'TestStreet';
            nodeAcc4.Core_MDF_Active_Ind__c =true;
            upsert nodeAcc4;
            
            Test.startTest();
            
            List<Account> listAccount = [Select Id, Core_Geo__c,Core_Sub_Geo__c,Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketingActive__c, Core_MDF_CoMarketingAgency__c, Core_MDF_Channel_Program__c, RecordTypeId from Account where Name =: 'MarketingRecordType' limit 1];
            
            Map<Id,Account> newMap= new Map<Id,Account>(listAccount);
            List<Account> oldAccount = [Select Id, Core_Geo__c,Core_Sub_Geo__c,Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketingActive__c, Core_MDF_CoMarketingAgency__c, Core_MDF_Channel_Program__c, RecordTypeId from Account where Name =: 'MarketingRecordType' limit 1];
            oldAccount[0].Core_Geo__c= 'EMEA';
            
            Map<Id,Account> oldMap = new Map<Id,Account>(oldAccount);
            Core_AccountTriggerHandlerController.processCCPTriggerUpdates(listAccount,newMap,oldMap,'before update');
            Core_AccountTriggerHandlerController.processCCPTriggerUpdates(listAccount,newMap,oldMap,'before insert');
            Core_AccountTriggerHandlerController.processCCPTriggerUpdates(listAccount,newMap,oldMap,'after update');
            
            //Exception Scenario
            List<Account> emptyAccList;
            Core_AccountTriggerHandlerController.updateHostRegionAfterVirtualCorpUpdate(emptyAccList,oldMap);
            Core_MDF_AccountServiceHandler.updateHostRegionAfterVirtualCorpUpdate(emptyAccList,oldMap);
            Test.stopTest();
        }  


        @isTest
        private static void testUpdateHostRegionAfterVirtualCorpUpdate() {
            
            //Role
            UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
            // Creating User with utility class 
            User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr.UserRoleId = usRole.Id;
            insert usr;
            
            PermissionSet programAdmin = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Program_Adm' LIMIT 1];
            PermissionSetAssignment psAssignment1 = new PermissionSetAssignment(PermissionSetId = programAdmin.Id, AssigneeId = usr.Id);
            insert psAssignment1;
            
            SetupEntityAccess objSEA = new SetupEntityAccess();
            objSEA.SetupEntityId = [Select id from CustomPermission where DeveloperName ='Core_MDF_CCP_users_with_Region_Field_Edit_Access_on_CoMarketing_Account'][0].Id;
            objSEA.ParentId = programAdmin.Id;
            insert objSEA;

            System.runAs(usr){
                Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
                
                Account virtualCorpAcc = [Select Id, Name,RecordTypeId from Account where Name =: 'MarketingRecordType' limit 1];
                virtualCorpAcc.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
                virtualCorpAcc.Core_Geo__c = 'APJ';
                virtualCorpAcc.BillingCity='Pune';
                virtualCorpAcc.BillingCountry='IND';
                virtualCorpAcc.BillingCountryCode = 'IND';
                virtualCorpAcc.BillingState = 'MH';
                virtualCorpAcc.BillingStateCode = 'MH'; 
                virtualCorpAcc.BillingStreet = 'TestStreet';
                virtualCorpAcc.Core_MDF_Active_Ind__c =true;
                upsert virtualCorpAcc;
                
                //Create Node Account 1
                Account nodeAcc1 = [Select Id, Name from Account where Name =: 'Test IPA Node Account 1' limit 1];
                nodeAcc1.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
                nodeAcc1.BillingCity='Pune';
                nodeAcc1.BillingCountry='IND';
                nodeAcc1.BillingCountryCode = 'IND';
                nodeAcc1.BillingState = 'MH';
                nodeAcc1.BillingStateCode = 'MH'; 
                nodeAcc1.BillingStreet = 'TestStreet';
                nodeAcc1.Core_MDF_Active_Ind__c =true;
                upsert nodeAcc1;
                
                //Create Node Account 2
                Account nodeAcc2 = [Select Id, Name from Account where Name =: 'Test IPA Node Account 2' limit 1];
                nodeAcc2.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
                nodeAcc2.BillingCity='Pune';
                nodeAcc2.BillingCountry='IND';
                nodeAcc2.BillingCountryCode = 'IND';
                nodeAcc2.BillingState = 'MH';
                nodeAcc2.BillingStateCode = 'MH'; 
                nodeAcc2.BillingStreet = 'TestStreet';
                nodeAcc2.Core_MDF_Active_Ind__c =true;
                upsert nodeAcc2;
                
                //Create Node Account 3
                Account nodeAcc3 = [Select Id, Name from Account where Name =: 'Test IPA Node Account 3' limit 1];
                nodeAcc3.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
                nodeAcc3.BillingCity='Pune';
                nodeAcc3.BillingCountry='IND';
                nodeAcc3.BillingCountryCode = 'IND';
                nodeAcc3.BillingState = 'MH';
                nodeAcc3.BillingStateCode = 'MH'; 
                nodeAcc3.BillingStreet = 'TestStreet';
                nodeAcc3.Core_MDF_Active_Ind__c =true;
                upsert nodeAcc3;
                
                //Create Node Account 4
                Account nodeAcc4 = [Select Id, Name from Account where Name =: 'Test IPA Node Account 4' limit 1];
                nodeAcc4.Core_MDF_Channel_Program__c = channelProgramDetailsOfIPA.Core_MDF_Program_ID__c;
                nodeAcc4.BillingCity='Pune';
                nodeAcc4.BillingCountry='IND';
                nodeAcc4.BillingCountryCode = 'IND';
                nodeAcc4.BillingState = 'MH';
                nodeAcc4.BillingStateCode = 'MH'; 
                nodeAcc4.BillingStreet = 'TestStreet';
                nodeAcc4.Core_MDF_Active_Ind__c =true;
                upsert nodeAcc4;
                
                Test.startTest();
                
                List<Account> listAccount = [Select Id, Core_Geo__c,Core_Sub_Geo__c,Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketingActive__c, Core_MDF_CoMarketingAgency__c, Core_MDF_Channel_Program__c, RecordTypeId from Account where Name =: 'Test IPA Node Account 1' limit 1];
                
                Map<Id,Account> newMap= new Map<Id,Account>(listAccount);
                List<Account> oldAccount = [Select Id, Core_Geo__c,Core_Sub_Geo__c,Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketingActive__c, Core_MDF_CoMarketingAgency__c, Core_MDF_Channel_Program__c, RecordTypeId from Account where Name =: 'Test IPA Node Account 1' limit 1];
                oldAccount[0].Core_Geo__c= 'EMEA';
                
                Map<Id,Account> oldMap = new Map<Id,Account>(oldAccount);
                Core_AccountTriggerHandlerController.processCCPTriggerUpdates(listAccount,newMap,oldMap,'before update');
                //Exception Scenario
                Map<Id, Account> nullMap;
                Core_AccountTriggerHandlerController.restrictHostRegionUpdateOnNodeAccounts(nullMap,oldMap);
                Core_MDF_AccountServiceHandler.restrictHostRegionUpdateOnNodeAccounts(nullMap,oldMap);
                Test.stopTest();
            }
        } 

        @isTest
        private static void whenpublishAccount(){
            List<Account> listAccount = [Select Id,Core_Business_Partner_Id__c, Core_Geo__c,Core_Sub_Geo__c,Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketingActive__c, Core_MDF_CoMarketingAgency__c, Core_MDF_Channel_Program__c, RecordTypeId from Account where Name =: 'TestParentAccount' limit 1];
            
            Map<Id,Account> newMap= new Map<Id,Account>(listAccount);
            List<Account> oldAccount = [Select Id,Unified_Hierarchy_View__c,KCR_Process_Outcome_Temp__c,Core_Data_Country_Nm__c,Core_Customer_Aggregation_Type__c,Core_Business_Partner_Id__c, Core_Geo__c,Core_Sub_Geo__c,Core_MDF_Parent_Fund_Account__c, Core_MDF_CoMarketingActive__c, Core_MDF_CoMarketingAgency__c, Core_MDF_Channel_Program__c, RecordTypeId from Account where Name =: 'TestParentAccount' limit 1];
            oldAccount[0].Core_Business_Partner_Id__c= 'EMEA';                 
            Test.startTest();
                Core_AccountTriggerHandlerController.publishAccount(oldAccount);
            Test.stopTest();
        }
        


}