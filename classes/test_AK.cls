/*
* Class Name  : Core_MDF_BulkClaimServerController_Test 
* Version     : 1.0 
* Created Date: 11-04-2019
* Developer                             Date                          Description 
* -----------------------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Krishna Kulkarni         11/04/2019      Created Core_MDF_BulkClaimServerController_Test for testing every action from Core_MDF_BulkClaimServerController
* Accenture – JV                       15/04/2019      Modified entire class based on the changes made in functioanality   
-------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest(SeeAllData = false)
private class test_AK{
    
    
    
    //Set Up All Data
    @TestSetup static void setUpData() {
        
        List<Core_MDF_Configuration__c> confDataList = new List<Core_MDF_Configuration__c>();
        confDataList.add(new Core_MDF_Configuration__c(Name='BULK_CLAIM_JOB_MINUTES',Core_MDF_Value__c='3'));
        confDataList.add(new Core_MDF_Configuration__c(Name='BULK_CLAIM_SKIP_SAMEDAY_CHECK',Core_MDF_Value__c='true'));
        confDataList.add(new Core_MDF_Configuration__c(Name='BULK_CLAIM_MAX_JOB_EXCEPTION_MESSAGE',Core_MDF_Value__c='Test'));
        confDataList.add(new Core_MDF_Configuration__c(Name='BULK_CLAIM_SCHEDULED_JOB_LIMIT',Core_MDF_Value__c='119'));
        confDataList.add(new Core_MDF_Configuration__c(Name='BULK_CLAIM_BUDGET_TYPES_FOR_COUNTRY',Core_MDF_Value__c='CCF 1.0;DCF 1.0;OEM CMP;Service Provider CMP'));
        confDataList.add(new Core_MDF_Configuration__c(Name='BULK_CLAIM_RESTRICTED_BUDGET_TYPES',Core_MDF_Value__c='MDF;MDF+'));
        confDataList.add(new Core_MDF_Configuration__c(Name='BATCH_RECORD_LIMIT',Core_MDF_Value__c='30'));
        confDataList.add(new Core_MDF_Configuration__c(Name='RETRY_COUNT_LIMIT',Core_MDF_Value__c='5'));
        insert confDataList;        
        
        //adding bypass feature to bypass access validation
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        //permission set
        PermissionSet ccfPayAdmin = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
        PermissionSet rmfPayAdmin = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Payment_Adm' LIMIT 1];
        PermissionSet financeuser = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Finance_User' LIMIT 1];
        
        // Creating channel program with utility class
        List<ChannelProgram> channelProgList = new List<ChannelProgram>();
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram('Client Co-Marketing Fund', 'Client CoMarketing Fund', false);
        channelProgList.add(cp);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
        channelProgList.add(cp2);
        ChannelProgram cp3 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center CoMarketing Fund','Data Center CoMarketing Fund', false);
        channelProgList.add(cp3);
        Database.insert(channelProgList);
        
        Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        List<Contact> contactList = new List<Contact>();
        Contact ccfUserContact = Core_MDF_CCP_TestDataUtility.createContact(intelAccount.Id, false);
        ccfUserContact.Core_Audience_List__c = 'CCF User';
        contactList.add(ccfUserContact);
        Contact rmfUserContact = Core_MDF_CCP_TestDataUtility.createContact(intelAccount.Id, false);
        rmfUserContact.Core_Audience_List__c = 'RMF User';
        contactList.add(rmfUserContact);
        Database.insert(contactList);
        
        Id partnerProfileId = [SELECT Id FROM Profile WHERE Name = 'Partner' limit 1].Id;
        
        List<User> userList = new List<User>();
        User japaneseUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        japaneseUser.Email = 'testClaimSubmitter@example.com';
        japaneseUser.ContactId = ccfUserContact.Id;
        japaneseUser.ProfileId = partnerProfileId;
        japaneseUser.LanguageLocaleKey = 'ja';
        japaneseUser.isActive = true;
        userList.add(japaneseUser);
        
        User RMFUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        RMFUser.Email = 'testClaimSubmitterRMF@example.com';
        RMFUser.ContactId = rmfUserContact.Id;
        RMFUser.ProfileId = partnerProfileId;
        RMFUser.LanguageLocaleKey = 'ja';
        RMFUser.isActive = true;
        userList.add(RMFUser);
        
        User sysAdminUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdminUser.LanguageLocaleKey = 'en_US';
        userList.add(sysAdminUser);
        database.insert(userList);
        
        //adding permissionset to admin user
        List<PermissionSetAssignment> psList = new List<PermissionSetAssignment>();
       
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = sysAdminUser.Id;
        assignPermissionSetObj.PermissionSetId = ccfPayAdmin.Id;
        psList.add(assignPermissionSetObj);
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = sysAdminUser.Id;
        assignPermissionSetObj1.PermissionSetId = financeuser.Id;
        psList.add(assignPermissionSetObj1);
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = sysAdminUser.Id;
        assignPermissionSetObj2.PermissionSetId = rmfPayAdmin.Id;
        psList.add(assignPermissionSetObj2);
        system.runas(sysAdminUser){
            Database.insert(psList);
        }
        
        List<Account> accountsVC = new List<Account>();
        Account virtualCorpAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccount.Id, false);
        Account rmfVCAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test RMF VC Acc New', cp2.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccount.Id, false);
        rmfVCAccount.Core_Geo__c = 'EMEA';
        rmfVCAccount.Core_Sub_Geo__c = 'WEUR';
        accountsVC.add(virtualCorpAccount);
        accountsVC.add(rmfVCAccount);
        DataBase.insert(accountsVC);
        
        Account virtualCorpAccount2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 3', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, virtualCorpAccount.Id, false);
        Account virtualCorpAccount3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 4', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, virtualCorpAccount.Id, false);
        Account virtualCorpAccount4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 5', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, virtualCorpAccount.Id, false);
        Account virtualCorpAccount5 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 6', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, virtualCorpAccount.Id, false);
        Account virtualCorpAccount6 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 7', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, virtualCorpAccount.Id, false);
        List<Account> accounts = new List<Account>();
        accounts.add(virtualCorpAccount2);
        accounts.add(virtualCorpAccount3);
        accounts.add(virtualCorpAccount4);
        accounts.add(virtualCorpAccount5);
        accounts.add(virtualCorpAccount6);
        DataBase.insert(accounts);
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
                        
        List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();        
        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New', Core_MDF_CCP_TestDataUtility.budget_Record_Type, virtualCorpAccount.Id, cp.Id, 2000000, System.today() - 20, System.today().addDays(40), false);
        budget.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
        budget.IsIgnoreValidation = true;
        PartnerMarketingBudget budget1 = Core_MDF_CCP_TestDataUtility.createBudget('Test MDF Budget New', Core_MDF_CCP_TestDataUtility.budget_Record_Type, virtualCorpAccount.Id, cp.Id, 2000000, System.today() - 20, System.today().addDays(40), false);
        budget1.Core_MDF_Budget_Type_Txt__c='OEM CMP';
        budget1.IsIgnoreValidation = true;
        PartnerMarketingBudget budget2 = Core_MDF_CCP_TestDataUtility.createBudget('Test OEM CMP Budget New', Core_MDF_CCP_TestDataUtility.budget_Record_Type, virtualCorpAccount.Id, cp.Id, 2000000, System.today() - 20, System.today().addDays(40), false);
        budget2.Core_MDF_Budget_Type_Txt__c='OEM CMP';
        budget2.IsIgnoreValidation = true;
        
        PartnerMarketingBudget rmfBudget = Core_MDF_CCP_TestDataUtility.createBudget('Retail MDF Budget', Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type, rmfVCAccount.Id, cp2.Id, 5000000, System.today() - 25, System.today().addDays(25), false);
        rmfBudget.Core_MDF_Budget_Type_Txt__c='Retail MDF';
        rmfBudget.IsIgnoreValidation = true;
        pmbList.add(budget);
        pmbList.add(budget1);
        pmbList.add(budget2);
        pmbList.add(rmfBudget);
         system.runas(sysAdminUser){
        database.insert(pmbList);
         }
        /*List<PartnerMarketingBudget> pmbUpdateList = new List<PartnerMarketingBudget>();
        budget.IsIgnoreValidation = true;
        budget1.IsIgnoreValidation = true;
        budget2.IsIgnoreValidation = true;
        pmbUpdateList.add(budget);
        pmbUpdateList.add(budget1);
        pmbUpdateList.add(budget2);
        database.update(pmbUpdateList);*/
        
        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New', budget, virtualCorpAccount, 200000.0, false);
        PartnerFundAllocation allocation2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New2', budget, virtualCorpAccount2, 200000.0, false);
        PartnerFundAllocation allocation3 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New3', budget, virtualCorpAccount3, 200000.0, false);
        PartnerFundAllocation allocation4 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New4', budget, virtualCorpAccount4, 200000.0, false);
        PartnerFundAllocation allocation5 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New5', budget1, virtualCorpAccount4, 2000000.0, false);
        PartnerFundAllocation allocation6 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New6', budget2, virtualCorpAccount4, 2000000.0, false);
        pfaList.add(allocation);
        pfaList.add(allocation2);
        pfaList.add(allocation3);
        pfaList.add(allocation4);
        pfaList.add(allocation5);
        pfaList.add(allocation6);
        
        PartnerFundAllocation rmfAllocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation RMF', rmfBudget, rmfVCAccount, 500000.0, false);
        pfaList.add(rmfAllocation);
        Database.insert(pfaList);
        
        List<Campaign> cmpList = new List<Campaign>();
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13', 'Gaming', 'Intel® Core™ i7 Processor','Yes',Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', budget.StartDate, budget.EndDate, 20000, 'Always Connected PC', virtualCorpAccount.Id, 'Desktop', false);
        Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13', 'Gaming', 'Intel® Core™ i7 Processor','Yes',Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', budget.StartDate, budget.EndDate, 20000, 'Always Connected PC', virtualCorpAccount.Id, 'Desktop', false);
        camp1.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF';
        camp1.Core_MDF_Supports_legacy_program__c='MDF or both CMP & MDF';
        Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13', 'Gaming', 'Intel® Core™ i7 Processor','Yes',Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', budget.StartDate, budget1.EndDate, 20000, 'Always Connected PC', virtualCorpAccount.Id, 'Desktop', false);
        camp2.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        camp2.Core_MDF_Supports_legacy_program__c='CMP only';
        cmpList.add(camp);
        cmpList.add(camp1);
        cmpList.add(camp2);
        
        Campaign rmfCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp RMF', 'Enthusiast Gaming', 'Intel® Core™ i7 Processor','Yes',Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today()-10, System.today().addDays(15), 10000, 'Always Connected PC', rmfVCAccount.Id, 'All-in-One Desktop', false);
        rmfCamp.Core_MDF_Opal_Budget_Type_Txt__c = 'Retail MDF';
        rmfCamp.Core_MDF_Supports_legacy_program__c='MDF or both CMP & MDF';
        cmpList.add(rmfCamp);
        Database.insert(cmpList);
        
        PartnerFundRequest testRMFPartnerFundRequest= Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(rmfCamp.Id),
                                                                                                          Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,
                                                                                                          String.valueof(rmfVCAccount.id), rmfAllocation, null, 'INDIA',
                                                                                                          'Enthusiast Gaming',
                                                                                                          'All-in-One Desktop',
                                                                                                          'Intel® Core™ i7 Processor',
                                                                                                          'Digital Media',
                                                                                                          'NonPartner.com',
                                                                                                          'Draft',
                                                                                                          false);
        
        //testRMFPartnerFundRequest.Core_MDF_Budget_Type_txt__c = 'Retail MDF';
        testRMFPartnerFundRequest.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
        testRMFPartnerFundRequest.Core_MDF_Start_Date__c = system.today()-5;
        testRMFPartnerFundRequest.Core_MDF_End_Date__c = system.today().addDays(5);
        testRMFPartnerFundRequest.Amount=10000;
        testRMFPartnerFundRequest.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        testRMFPartnerFundRequest.Core_MDF_Fund_Request_Status__c = 'Planned';
        
        PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id),
                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                          String.valueof(virtualCorpAccount.id), allocation, budget, 'INDIA',
                                                                                                          'Consumer',
                                                                                                          'Desktop',
                                                                                                          'Intel® Core™ i5 Processor',
                                                                                                          'Digital Media',
                                                                                                          'IndustryPartner.com',
                                                                                                          'Draft',
                                                                                                          false);
        
        //testPartnerFundRequest.Core_MDF_Budget_Type_txt__c = 'CCF 1.0';
        testPartnerFundRequest.Core_MDF_Activity_SubType_nm__c = 'Email';
        //testPartnerFundRequest.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        testPartnerFundRequest.Core_MDF_Start_Date__c = system.today();
        testPartnerFundRequest.Core_MDF_End_Date__c = system.today().addDays(3);
        testPartnerFundRequest.Amount=5000;
        testPartnerFundRequest.Core_MDF_Country_nm__c = 'INDIA';
        testPartnerFundRequest.Core_MDF_Fund_Request_Status__c = 'Planned';
        PartnerFundRequest testPartnerFundRequest2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id),
                                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                           String.valueof(virtualCorpAccount2.id), allocation2, null, 'INDIA',
                                                                                                           'Consumer',
                                                                                                           'Desktop',
                                                                                                           'Intel® Core™ i5 Processor',
                                                                                                           'Digital Media',
                                                                                                           'IndustryPartner.com',
                                                                                                           'Draft',
                                                                                                           false);
        
        //testPartnerFundRequest2.Core_MDF_Budget_Type_txt__c = 'CCF 1.0';
        //testPartnerFundRequest2.Core_MDF_Activity_SubType_nm__c = 'Email';
        //testPartnerFundRequest2.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        testPartnerFundRequest2.Core_MDF_Start_Date__c = system.today();
        testPartnerFundRequest2.Core_MDF_End_Date__c = system.today().addDays(3);
        testPartnerFundRequest2.Amount=5000;
        testPartnerFundRequest.Core_MDF_Country_nm__c = 'INDIA';
        testPartnerFundRequest2.Core_MDF_Fund_Request_Status__c = 'Planned';
        
        PartnerFundRequest testPartnerFundRequest3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id),
                                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                           String.valueof(virtualCorpAccount3.id), allocation3, null, 'INDIA;AFGHANISTAN',
                                                                                                           'Consumer',
                                                                                                           'Desktop',
                                                                                                           'Intel® Core™ i5 Processor',
                                                                                                           'Broadcast',
                                                                                                           'Podcast',
                                                                                                           'Draft',
                                                                                                           false);
        
        //testPartnerFundRequest3.Core_MDF_Budget_Type_txt__c = 'CCF 1.0';
        //testPartnerFundRequest3.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        testPartnerFundRequest3.Core_MDF_Start_Date__c = system.today();
        testPartnerFundRequest3.Core_MDF_End_Date__c = system.today().addDays(2);
        testPartnerFundRequest3.Amount=0;
        testPartnerFundRequest3.Core_MDF_Country_nm__c = 'INDIA;AFGHANISTAN';
        testPartnerFundRequest3.Core_MDF_Fund_Request_Status__c = 'Planned';
        
        PartnerFundRequest testPartnerFundRequest4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id),
                                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                           String.valueof(virtualCorpAccount4.id), allocation4, null, 'INDIA',
                                                                                                           'Consumer',
                                                                                                           'Desktop',
                                                                                                           'Intel® Core™ i5 Processor',
                                                                                                           'Broadcast',
                                                                                                           'Podcast',
                                                                                                           'Draft',
                                                                                                           false);
        
        //testPartnerFundRequest4.Core_MDF_Budget_Type_txt__c = 'CCF 1.0';
        testPartnerFundRequest4.Core_MDF_Start_Date__c = system.today();
        testPartnerFundRequest4.Core_MDF_End_Date__c = system.today().addDays(6);
        testPartnerFundRequest4.Amount=0;
        testPartnerFundRequest4.Core_MDF_Country_nm__c = 'INDIA';
        testPartnerFundRequest4.Core_MDF_Fund_Request_Status__c = 'Planned';
        PartnerFundRequest testPartnerFundRequest5 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id),
                                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                           String.valueof(virtualCorpAccount5.id), allocation3, null,null,
                                                                                                           'Consumer',
                                                                                                           'Desktop',
                                                                                                           'Intel® Core™ i5 Processor',
                                                                                                           'Broadcast',
                                                                                                           'Podcast',
                                                                                                           'Draft',
                                                                                                           false);
        
        //testPartnerFundRequest5.Core_MDF_Budget_Type_txt__c = 'CCF 1.0';
        testPartnerFundRequest5.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        testPartnerFundRequest5.Title = 'CCF 1.0 Activity';
        testPartnerFundRequest5.Core_MDF_Start_Date__c = system.today();
        testPartnerFundRequest5.Core_MDF_End_Date__c = system.today().addDays(2);
        testPartnerFundRequest5.Amount=0;
        testPartnerFundRequest5.Core_MDF_Fund_Request_Status__c = 'Planned';
        PartnerFundRequest testPartnerFundRequest6 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id),
                                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                           String.valueof(virtualCorpAccount6.id), allocation3, null, 'India',
                                                                                                           'Consumer',
                                                                                                           'Desktop',
                                                                                                           'Intel® Core™ i5 Processor',
                                                                                                           'Digital Media',
                                                                                                           'NonPartner.com',
                                                                                                           'Draft',
                                                                                                           false);
        
        //testPartnerFundRequest6.Core_MDF_Budget_Type_txt__c = 'CCF 1.0';
        testPartnerFundRequest6.Core_MDF_Start_Date__c = system.today();
        testPartnerFundRequest6.Core_MDF_End_Date__c = system.today().addDays(4);
        testPartnerFundRequest6.Amount=0;
        testPartnerFundRequest6.Core_MDF_Fund_Request_Status__c = 'Planned';
        
        PartnerFundRequest testPartnerFundRequest7= Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id),
                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                          String.valueof(virtualCorpAccount4.id), allocation5, null, 'INDIA',
                                                                                                          'Consumer',
                                                                                                          'Desktop',
                                                                                                          'Intel® Core™ i5 Processor',
                                                                                                          'Digital Media',
                                                                                                          'NonPartner.com',
                                                                                                          'Draft',
                                                                                                          false);
        //testPartnerFundRequest7.Core_MDF_Budget_Type_txt__c = 'MDF';
        testPartnerFundRequest7.Core_MDF_Budget_Type_nm__c = 'MDF';
        testPartnerFundRequest7.Core_MDF_Activity_SubType_nm__c= 'Banner/Display;Other (NonPartner.com)';        
        testPartnerFundRequest7.Core_MDF_Start_Date__c = system.today();
        testPartnerFundRequest7.Core_MDF_End_Date__c = system.today().addDays(7);
        testPartnerFundRequest7.Amount=0;
        testPartnerFundRequest7.Title = 'MDF Activity';
        testPartnerFundRequest7.Core_MDF_Country_nm__c = 'INDIA';
        testPartnerFundRequest7.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequest7.Core_MDF_Reimbursement_Rate_pct__c='50%';
        testPartnerFundRequest7.Core_MDF_Reimbursement_Rate_txt__c = '50%';       
        
        PartnerFundRequest testPartnerFundRequest8= Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id),
                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                          String.valueof(virtualCorpAccount4.id), allocation6, null, 'INDIA',
                                                                                                          'Consumer',
                                                                                                          'Desktop',
                                                                                                          'Intel® Core™ i5 Processor',
                                                                                                          'Digital Media',
                                                                                                          'NonPartner.com',
                                                                                                          'Draft',
                                                                                                          false);
        //testPartnerFundRequest8.Core_MDF_Budget_Type_txt__c = 'OEM CMP';
        testPartnerFundRequest8.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        testPartnerFundRequest8.Core_MDF_Activity_SubType_nm__c= 'Banner/Display;Other (NonPartner.com)';        
        testPartnerFundRequest8.Core_MDF_Start_Date__c = system.today();
        testPartnerFundRequest8.Core_MDF_End_Date__c = system.today().addDays(4);
        testPartnerFundRequest8.Amount=0;
        testPartnerFundRequest8.Title = 'OEM CMP Activity';
        testPartnerFundRequest8.Core_MDF_Country_nm__c = 'INDIA;AFGHANISTAN';
        testPartnerFundRequest8.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequest8.Core_MDF_Reimbursement_Rate_pct__c='50%';
        testPartnerFundRequest8.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        
        
        
        List<PartnerFundRequest> pfrs = new List<PartnerFundRequest>();
        
        pfrs.add(testPartnerFundRequest); //issue 6 months:
        pfrs.add(testPartnerFundRequest2); //issue  6 months:
        pfrs.add(testPartnerFundRequest3); //issue 6 months:
        pfrs.add(testPartnerFundRequest4);
       	//pfrs.add(testPartnerFundRequest5); CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY
        pfrs.add(testPartnerFundRequest6);
        pfrs.add(testPartnerFundRequest7);
        pfrs.add(testPartnerFundRequest8);
        pfrs.add(testRMFPartnerFundRequest);
        
        //bankuser
        List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
        Core_MDF_Bank__c bank =  Core_MDF_CCP_TestDataUtility.createBank(intelAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', false, '1231231230');
        Core_MDF_Bank__c rmfBank =  Core_MDF_CCP_TestDataUtility.createBank(intelAccount.Id, 'Core_MDF_Retail_Marketing_Funds', false, '1231231245');
        rmfBank.Core_MDF_Intel_Company_Code__c = '650';
        rmfBank.Core_MDF_Tax_codes_cd__c = 'I0';
        Core_MDF_Bank__c rmfBank2 =  Core_MDF_CCP_TestDataUtility.createBank(intelAccount.Id, 'Core_MDF_Retail_Marketing_Funds', false, '1231231250');
        rmfBank2.Core_MDF_Intel_Company_Code__c = '420';
        rmfBank2.Core_MDF_Tax_codes_cd__c = 'UZ';
        bankList.add(bank);
        bankList.add(rmfBank);
        bankList.add(rmfBank2);
		Database.insert(bankList);
            bankList[0].Core_MDF_Bank_Status__c = 'Active'; 
        	bankList[0].Core_MDF_Bank_Location__c = 'IN';
            bankList[1].Core_MDF_Bank_Status__c = 'Active'; 
        	bankList[1].Core_MDF_Bank_Location__c = 'US';
        	bankList[2].Core_MDF_Bank_Status__c = 'Active'; 
        	bankList[2].Core_MDF_Bank_Location__c = 'GB';
            update bankList;

        
        List<Core_MDF_Account_Bank_Mapping__c> abmLst = new List<Core_MDF_Account_Bank_Mapping__c>();
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(virtualCorpAccount.Id, bank.id, false);
        Core_MDF_Account_Bank_Mapping__c abm2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(virtualCorpAccount2.Id, bank.id, false);
        Core_MDF_Account_Bank_Mapping__c abm3 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(virtualCorpAccount3.Id, bank.id, false);
        Core_MDF_Account_Bank_Mapping__c abm4 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(virtualCorpAccount4.Id, bank.id, false);
        Core_MDF_Account_Bank_Mapping__c rmfABM1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(rmfVCAccount.Id, rmfBank.id, false);
        Core_MDF_Account_Bank_Mapping__c rmfABM2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(rmfVCAccount.Id, rmfBank2.id, false);
        abmLst.add(abm1);
        abmLst.add(abm2);
        abmLst.add(abm3);
        abmLst.add(abm4);
        abmLst.add(rmfABM1);
        abmLst.add(rmfABM2);
        Database.insert(abmLst);
        
        Test.startTest();
        database.insert(pfrs);
        
        //adding before claim
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        
        PartnerFundClaim testClaim = Core_MDF_CCP_TestDataUtility.createClaim('Dell DCF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                              testPartnerFundRequest.Id, 
                                                                              testPartnerFundRequest.Core_MDF_Start_Date__c, testPartnerFundRequest.Core_MDF_Start_Date__c, 
                                                                              1234, 
                                                                              System.today(), bank.ID, false);
        testClaim.Core_MDF_Media_Vehicle__c = 'Kri1011';
        testClaim.Core_MDF_Currency__c = 'USD';
        testClaim.Core_MDF_Invoice_Number__c = '1234';
        testClaim.Core_MDF_Total_Invoice_Amount_Local__c = 10;
        testClaim.Core_MDF_Taxes_Local__c = 0;
        PartnerFundClaim testClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('Dell DCF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                               testPartnerFundRequest2.Id, 
                                                                               testPartnerFundRequest2.Core_MDF_Start_Date__c, testPartnerFundRequest2.Core_MDF_Start_Date__c, 
                                                                               1234, 
                                                                               System.today(), bank.ID, false);
        testClaim2.Core_MDF_Media_Vehicle__c = 'Kri1011';
        testClaim2.Core_MDF_Currency__c = 'USD';
        testClaim2.Core_MDF_Invoice_Number__c = '1234';
        testClaim2.Core_MDF_Total_Invoice_Amount_Local__c = 10;
        testClaim2.Core_MDF_Taxes_Local__c = 0;
        List<PartnerFundClaim> claims = new List<PartnerFundClaim>();
        claims.add(testClaim);
        claims.add(testClaim2);
        //database.insert(claims);

        Test.stopTest();
        
        List < Document > docList = new List < Document > ();
        Document document = new Document();
        document.ContentType = 'application/vnd.ms-excel';
        document.DeveloperName = 'Core_MDF1_Request_Template_CCF_DCF_en_US';
        document.IsPublic = true;
        document.Name = 'Request_Template_CCF_DCF_en_US';
        document.FolderId = [select id from folder where name = 'Bulk Claim Templates'].id;
        docList.add(document);
        
        Document document1 = new Document();
        document1.ContentType = 'application/vnd.ms-excel';
        document1.DeveloperName = 'Core_MDF1_Request_Template_CCF_DCF_ja';
        document1.IsPublic = true;
        document1.Name = 'Request_Template_CCF_DCF_ja';
        document1.FolderId = [select id from folder where name = 'Bulk Claim Templates'].id;
        docList.add(document1);
        
        Document document2 = new Document();
        document2.ContentType = 'application/vnd.ms-excel';
        document2.DeveloperName = 'Core_MDF_Request_Template_RMF_ja';
        document2.IsPublic = true;
        document2.Name = 'Request_Template_RMF_ja';
        document2.FolderId = [select id from folder where name = 'Bulk Claim Templates'].id;
        docList.add(document2);
        
        database.insert(docList);
        
        List<Core_MDF_Claim_Batch__c> claimbatchList = new List<Core_MDF_Claim_Batch__c>();
        
        Core_MDF_Claim_Batch__c claimbatchinstance = new Core_MDF_Claim_Batch__c();
        claimbatchinstance.Core_MDF_Program_Id__c =  cp.Id;
        claimbatchinstance.Core_MDF_Account__c = [SELECT ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c FROM 
                                                  PartnerFundRequest WHERE ID=:testPartnerFundRequest.Id].ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c;
        claimbatchList.add(claimbatchinstance);
        
        Core_MDF_Claim_Batch__c claimbatchinstanceRMF = new Core_MDF_Claim_Batch__c();
        claimbatchinstanceRMF.Core_MDF_Program_Id__c =  cp2.Id;
        claimbatchinstanceRMF.Core_MDF_Account__c = [SELECT ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c FROM 
                                                  PartnerFundRequest WHERE ID=:testRMFPartnerFundRequest.Id].ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c;
        claimbatchList.add(claimbatchinstanceRMF);
        Database.insert(claimbatchList);
         
    }
    @isTest static void testJobLimitException() {
        
        
        User sysAdminUser = [SELECT Id,LanguageLocaleKey FROM USER WHERE LanguageLocaleKey = 'en_US' LIMIT 1];
        System.runAs(sysAdminUser){
            
            List<Account> accounts = [Select Id, Name,Core_MDF_CoMarketing_Ultimate_Account__c  from Account where Name in ('Test Acc New 2','Test Acc New 3','Test Acc New 4','Test Acc New 6','Test Acc New 7')];
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];
            List<PartnerFundRequest> pfrList = [Select id, Title, Core_MDF_Activity_Number__c,ChannelPartner.Core_MDF_Active_Ind__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where ChannelPartnerId In: accounts];
            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today();
            Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
            String dateString = dt.format(dateFormatString);
            Date d1 = Date.today().addDays(100);
            Datetime dt1 = Datetime.newInstance(d1.year(), d1.month(),d1.day());
            String dateString1 = dt1.format(dateFormatString);
            String csvString = 'Claim Name,Activity #,"Execution Start Date  (YYYY-MM-DD)","Execution End Date (YYYY-MM-DD)","Country","Activity Subtype",Media Vehicle,Bank,"Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Dell DCF Claim from Bulk 1,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,Krishna1011,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1 \n Dell DCF Claim from Bulk 1,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1 \n Dell DCF Claim from Bulk 3,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1';
            csvString = csvString + '\n Dell DCF Claim from Bulk 4,' + pfrList[1].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,online,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,5,0,0,Claim1' ;
            //no activity subtype
            csvString = csvString + '\n Dell DCF Claim from Bulk 5,' + pfrList[1].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,,Krishna1,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            //no country
            csvString = csvString + '\n Dell DCF Claim from Bulk 6,' + pfrList[2].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',,Email,Krishna1,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            //no bank
            csvString = csvString + '\n Dell DCF Claim from Bulk 7,' + pfrList[2].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,Krishna1,'  + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            //no country on activity
            csvString = csvString + '\n Dell DCF Claim from Bulk 8,' + pfrList[3].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,Krishna1,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            //country invalid for activity
            csvString = csvString + '\n Dell DCF Claim from Bulk 9 ,' + pfrList[2].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',GERMANY,Email,Krishna1,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            //Activity subtype invalid for activity
            csvString = csvString + '\n Dell DCF Claim from Bulk 10 ,' + pfrList[2].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,Krishna1,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            //no media vehicle
            csvString = csvString + '\n Dell DCF Claim from Bulk 11,' + pfrList[1].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,Krishna1,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            //test claim insert
            csvString = csvString + '\n Dell DCF Claim from Bulk 4,' + pfrList[1].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString1 + ',India,Email,online,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,5,0,0,Claim1' ;
            Blob myBlob = Blob.valueof(csvString);
            String base64Data = EncodingUtil.base64Encode(myBlob);
            String fileName = 'fileName.csv';
            
            ChannelProgram channelProgram = [Select id from ChannelProgram where Name = 'Client Co-Marketing Fund'];
            Core_MDF_BulkClaimServerController.fetchRecordTypeMetaData();
            
            Core_MDF_Claim_Batch__c claimbatchinstance = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c LIMIT 1];
            System.debug('abc'+claimbatchinstance);
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram WHERE Id =:channelProgram.Id LIMIT 1].Core_MDF_Technical_Program_Name__c;
            Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                                               Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c,Core_MDF_Claim_Field_API_Name__c
                                                                                                                                               FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                                               WHERE Core_MDF_Channel_program__c = :channelProgramName
                                                                                                                                               AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);
            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                     FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                     WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];
            
            Test.startTest();
            List<Core_MDF_Claim_Batch_Stage__c> listOfbatchStagerecords = Core_MDF_BulkClaimServerController.validateDataType(metadataIdToRecordMap,myBlob,accounts[0].Core_MDF_CoMarketing_Ultimate_Account__c,channelProgram.Id);
            Core_MDF_BulkClaimServerController.insertClaimBatchStageRecords(listOfbatchStagerecords,claimbatchinstance,recordType);
            
            
            //Core_MDF_Claim_Batch_Stage__c batchStage = [select id, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c from Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id AND Core_MDF_Processing_Status_Nm__c =: Label.Core_MDF_In_Progress_Status limit 1];
            List<Core_MDF_Claim_Batch_Stage__c> batchStageList = [select id, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c from Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id/* AND Core_MDF_Processing_Status_Nm__c ='Submitted' limit 1 */];
            try{
                Database.update(batchStageList);
                Database.delete(batchStageList);
            }catch(Exception e)
            {System.assertEquals(e.getMessage().contains(Label.Core_MDF_Claim_Cannot_BeDeleted),True);}
            
            
            for(Integer i=0;i<100;i++) {
                System.schedule('testbulkClaim111'+i,'0 15 * * * ?', new Core_MDF_ClaimInsert_Schedule());
            }
            
            
            Core_MDF_ClaimInsert_Batch c = new Core_MDF_ClaimInsert_Batch(System.now());
            Database.executeBatch(c,200);            
            try{Core_MDF_BulkClaimServerController.parseFile(base64Data, fileName, channelProgram.Id);}catch(Exception e){System.debug('Exception'+e);}
        }
        Test.stopTest();       
    } 



}