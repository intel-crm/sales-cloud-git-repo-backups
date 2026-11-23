@isTest(SeeAllData=false)
private class Core_MDF_RMF_SchNotification_Batch_Test {
    
    /*@TestSetup static void setUpData(){
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating User with utility class 
        List<User> usrList=new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'TestUser123';
        usr.profileId = systemAdminProfile.Id;
        usrList.add(usr);
        Database.insert(usrList);
        System.runAs(usr){
            List<ChannelProgram> channelProgramList = new List<ChannelProgram>();
            List<Account> comarketingAccountsList = new List<Account>();
            List<Campaign> campaignList = new List<Campaign>();
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            
            List<String> bypassFunctionKeys = new List<String>();
            //adding bypass feature to bypass access validation
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('byPass_Cancel_Activity');
            bypassFunctionKeys.add('Core_MDF_Bypass_ATFBatchUpdate');
            
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            
            Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Dell Corporation', NULL,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
            dellCorpAccount.BillingCity = 'Test City';         
            dellCorpAccount.BillingCountry= 'AUS';
            dellCorpAccount.BillingStreet= 'Test Street';
            dellCorpAccount.BillingState= 'TAS';
            dellCorpAccount.Core_Geo__c= 'APJ';
            dellCorpAccount.BillingCountryCode = 'JPN';
            database.insert(dellCorpAccount);
            
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);        
            channelProgramList.add(cp1);
            
            database.insert(channelProgramList);
            
            Account dellRMFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell RMF Virtual Corp', cp1.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
            dellRMFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
            dellRMFVirtualCorp.Core_Geo__c = 'APJ';
            dellRMFVirtualCorp.BillingCountryCode = 'JPN'; //Other Non Japan country is United States
            comarketingAccountsList.add(dellRMFVirtualCorp);
            
            Database.insert(comarketingAccountsList);   
            
            Campaign rsaMDCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm2','Gaming','9ᵗʰ Gen', 'No', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', Date.newInstance(2021, 05, 01), Date.newInstance(2021, 05, 29), 100000, 'Instore innovation', dellRMFVirtualCorp.Id,'Desktop', false); 
            rsaMDCamp.Core_MDF_Budget_Type_txt__c ='RSA MD';
            rsaMDCamp.Core_MDF_Activity_Category_Type__c =null;
            rsaMDCamp.Core_MDF_Reimbursement_Rate__c='100%';
            rsaMDCamp.Core_MDF_Technology__c = 'Intel vPro®';
            campaignList.add(rsaMDCamp);
            
            Test.startTest();
            database.insert(campaignList);
            
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(rsaMDCamp.Id),string.valueof(dellRMFVirtualCorp.id),
                                                                                        System.today(),System.today(),false);
            pfr1.Title = 'Testing Partner Fund Request Batch';
            //pfr1.Core_MDF_Budget_Type_txt__c = 'RSA MD';
            pfr1.Core_MDF_Budget_Type_nm__c='RSA MD';
            pfr1.Core_MDF_Reimbursement_Rate_pct__c = '100%';
            pfr1.RequestedAmount =1000;
            pfr1.Amount=1000;
            pfr1.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr1.Core_MDF_Start_Date__c = Date.newInstance(2021, 05, 01);
            pfr1.Core_MDF_End_Date__c = Date.newInstance(2021, 05, 29);
            pfr1.ChannelPartnerId = string.valueof(dellRMFVirtualCorp.id);
            pfrList.add(pfr1);
            Database.insert(pfrList);
            
            Test.stopTest();
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();  
        }
    }
    @isTest static void testRMFScheduleNotification(){
        User usr=[Select Id from User where LastName='TestUser123'];
        system.runAs(usr){
            ChannelProgram retailCP = [SELECT ID From ChannelProgram where Name = 'Retail Marketing Funds'];
            Account acc = [SELECT ID From Account where Name = 'Dell RMF Virtual Corp'];
            Id payment_MD_Record_Type = Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_RMF_MD').getRecordTypeId();
            Test.startTest();
            Core_MDF_RMF_ScheduledNotification_Batch batchToSchNotification = new Core_MDF_RMF_ScheduledNotification_Batch('APJ');
            Core_MDF_RMF_ScheduledNotification_Batch.todaysMonth = '1';
            database.executebatch(batchToSchNotification, 200);
            Test.stopTest();
        }
    }
    
    @isTest static void testRMFScheduleNotification1(){
        User usr=[Select Id from User where LastName='TestUser123'];
        system.runAs(usr){
            ChannelProgram retailCP = [SELECT ID From ChannelProgram where Name = 'Retail Marketing Funds'];
            Id payment_MD_Record_Type = Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_RMF_MD').getRecordTypeId();
            Test.startTest();
            Core_MDF_RMF_ScheduledNotification_Batch batchToSchNotification = new Core_MDF_RMF_ScheduledNotification_Batch('APJ');
            Core_MDF_RMF_ScheduledNotification_Batch.todaysMonth = '5';
            Core_MDF_RMF_ScheduledNotification_Batch.todaysDay = '21';
            database.executebatch(batchToSchNotification, 200);
            Test.stopTest();
        }
    }
    @isTest static void testRMFScheduleNotification2(){
        User usr=[Select Id from User where LastName='TestUser123'];
        system.runAs(usr){
            ChannelProgram retailCP = [SELECT ID From ChannelProgram where Name = 'Retail Marketing Funds'];
            List<PartnerFundRequest> pfrList = [Select Id, Core_MDF_Fund_Request_Status__c,Tolabel(ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode), 
                                                Core_MDF_Program__c, ChannelPartnerId, Core_MDF_End_Date__c from PartnerFundRequest where 
                                                Title = 'Testing Partner Fund Request Batch'];
            Id payment_MD_Record_Type = Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_RMF_MD').getRecordTypeId();
            Test.startTest();
            Core_MDF_RMF_ScheduledNotification_Batch.todaysMonth = '10';
            Core_MDF_RMF_ScheduledNotification_Batch.todaysDay = '15';
            Core_MDF_RMF_ScheduledNotification_Batch batchToSchNotification = new Core_MDF_RMF_ScheduledNotification_Batch('APJ');
            Database.QueryLocator ql = batchToSchNotification.start(null);
            batchToSchNotification.execute(null, pfrList);
            Assert.isNotNull(pfrList);
            Test.stopTest();
        }
    }
    
    @isTest static void testRMFScheduleNotification3(){
        User usr=[Select Id from User where LastName='TestUser123'];
        system.runAs(usr){
            ChannelProgram retailCP = [SELECT ID From ChannelProgram where Name = 'Retail Marketing Funds'];
            List<PartnerFundRequest> pfrList = [Select Id, Core_MDF_Fund_Request_Status__c,Tolabel(ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode), 
                                                Core_MDF_Program__c, ChannelPartnerId, Core_MDF_End_Date__c from PartnerFundRequest where 
                                                Title = 'Testing Partner Fund Request Batch'];
            Id payment_MD_Record_Type = Schema.SObjectType.Core_MDF_Payment__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_RMF_MD').getRecordTypeId();
            Test.startTest();
            Core_MDF_RMF_ScheduledNotification_Batch.todaysMonth = '1';
            Core_MDF_RMF_ScheduledNotification_Batch.todaysDay = '15';
            Core_MDF_RMF_ScheduledNotification_Batch batchToSchNotification = new Core_MDF_RMF_ScheduledNotification_Batch('APJ');
            Database.QueryLocator ql = batchToSchNotification.start(null);
            batchToSchNotification.execute(null, pfrList);
            Assert.isNotNull(pfrList);
            Test.stopTest();
        }
    }*/
}