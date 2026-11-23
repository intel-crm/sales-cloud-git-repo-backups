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
private class Core_MDF_BulkClaimServerController_Test{
    
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
        bypassFunctionKeys.add('Bypass_Activity_ApprovalProcess');
        bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
        bypassFunctionKeys.add('ByPass_LegacyBudgetCreationError');
        bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        //permission set
        PermissionSet ccfPayAdmin = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
        PermissionSet rmfPayAdmin = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Payment_Adm' LIMIT 1];
        PermissionSet financeuser = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
        
        // Creating channel program with utility class
        List<ChannelProgram> channelProgList = new List<ChannelProgram>();    
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram(Core_MDF_CCP_ConstantClass.CCF_PROGRAM , 'Client CoMarketing Fund', false);
        channelProgList.add(cp);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', false);
        channelProgList.add(cp2);
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
        budget.Core_MDF_Budget_Type_Txt__c='OEM CMP';
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
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13', 'Gaming', 'Intel® Core™ i7 Processor','Yes',Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-10, System.today().addDays(15), 20000, 'Always Connected PC', virtualCorpAccount.Id, 'Desktop', false);
        camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        camp.Core_MDF_Custom_Reimbursement_Rate_pct__c = '10';
        
        Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13', 'Gaming', 'Intel® Core™ i7 Processor','Yes',Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-10, System.today().addDays(15), 20000, 'Always Connected PC', virtualCorpAccount.Id, 'Desktop', false);
        camp1.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        
        Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13', 'Gaming', 'Intel® Core™ i7 Processor','Yes',Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-10, System.today().addDays(15), 20000, 'Always Connected PC', virtualCorpAccount.Id, 'Desktop', false);
        camp2.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
       
        cmpList.add(camp);
        cmpList.add(camp1);
        cmpList.add(camp2);
        
        Campaign rmfCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp RMF', 'Enthusiast Gaming', 'Intel® Core™ i7 Processor','Yes',Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today()-10, System.today().addDays(15), 10000, 'Always Connected PC', rmfVCAccount.Id, 'All-in-One Desktop', false);
        rmfCamp.Core_MDF_Opal_Budget_Type_Txt__c = 'Retail MDF';
        cmpList.add(rmfCamp);
        
        
        system.runas(sysAdminUser){
        Database.insert(cmpList);
        }
        PartnerFundRequest testRMFPartnerFundRequest= Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(rmfCamp.Id),
                                                                                                          Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,
                                                                                                          String.valueof(rmfVCAccount.id), rmfAllocation, null, 'INDIA',
                                                                                                          'Small and Medium Business',
                                                                                                          'Chromebook',
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
        //testRMFPartnerFundRequest.Core_MDF_Reimbursement_Rate_pct__c='50%';
        testRMFPartnerFundRequest.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        
        PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id),
                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                          String.valueof(virtualCorpAccount.id), allocation, budget, 'INDIA',
                                                                                                          'Consumer',
                                                                                                          'Desktop',
                                                                                                          'Intel® Core™ i5 Processor',
                                                                                                          'Digital Media',
                                                                                                          'EcosystemPartner.com',
                                                                                                          'Draft',
                                                                                                          false);

        //testPartnerFundRequest.Core_MDF_Budget_Type_txt__c = 'CCF 1.0';
        testPartnerFundRequest.Core_MDF_Activity_SubType_nm__c = 'Email';
        testPartnerFundRequest.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        testPartnerFundRequest.Core_MDF_Start_Date__c = system.today();
        testPartnerFundRequest.Core_MDF_End_Date__c	 = system.today().addDays(3);
        testPartnerFundRequest.Amount=5000;
        testPartnerFundRequest.Core_MDF_Country_nm__c = 'INDIA';
        testPartnerFundRequest.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequest.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        PartnerFundRequest testPartnerFundRequest2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id),
                                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                           String.valueof(virtualCorpAccount2.id), allocation2, null, 'INDIA',
                                                                                                           'Consumer',
                                                                                                           'Desktop',
                                                                                                           'Intel® Core™ i5 Processor',
                                                                                                           'Digital Media',
                                                                                                           'EcosystemPartner.com',
                                                                                                           'Draft',
                                                                                                           false);

        //testPartnerFundRequest2.Core_MDF_Budget_Type_txt__c = 'CCF 1.0';
        //testPartnerFundRequest2.Core_MDF_Activity_SubType_nm__c = 'Email';
        testPartnerFundRequest2.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        testPartnerFundRequest2.Core_MDF_Start_Date__c = system.today();
        testPartnerFundRequest2.Core_MDF_End_Date__c = system.today().addDays(3);
        testPartnerFundRequest2.Amount=5000;
        testPartnerFundRequest.Core_MDF_Country_nm__c = 'INDIA';
        testPartnerFundRequest2.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequest2.Core_MDF_Reimbursement_Rate_txt__c = '50%';
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
        testPartnerFundRequest3.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
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
        
        testPartnerFundRequest4.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
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
        testPartnerFundRequest5.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
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
        
        testPartnerFundRequest6.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
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
        testPartnerFundRequest7.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
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
        //pfrs.add(testPartnerFundRequest5); //CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY
       	pfrs.add(testPartnerFundRequest6);
       pfrs.add(testPartnerFundRequest7);
        pfrs.add(testPartnerFundRequest8);
        pfrs.add(testRMFPartnerFundRequest);
        
        //bankuser
        List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
        
        Core_MDF_Bank__c bank =  Core_MDF_CCP_TestDataUtility.createBank(intelAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', false, '1231231230');
        bank.Core_MDF_Effective_Date__c = System.today().addDays(-2);
        Core_MDF_Bank__c rmfBank =  Core_MDF_CCP_TestDataUtility.createBank(intelAccount.Id, 'Core_MDF_Retail_Marketing_Funds', false, '1231231245');
        rmfBank.Core_MDF_Intel_Company_Code__c = '650';
        rmfBank.Core_MDF_Tax_codes_cd__c = 'I0';
        rmfBank.Core_MDF_Effective_Date__c = System.today().addDays(-2);
        Core_MDF_Bank__c rmfBank2 =  Core_MDF_CCP_TestDataUtility.createBank(intelAccount.Id, 'Core_MDF_Retail_Marketing_Funds', false, '1231231250');
        rmfBank2.Core_MDF_Intel_Company_Code__c = '420';
        rmfBank2.Core_MDF_Tax_codes_cd__c = 'UZ';
        rmfBank2.Core_MDF_Effective_Date__c = System.today().addDays(-2);
        bankList.add(bank);
        bankList.add(rmfBank);
        bankList.add(rmfBank2);
        system.runas(sysAdminUser){
        	Database.insert(bankList);
        //}
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
        }
        
        Test.startTest();
        system.runas(sysAdminUser){
            insert pfrs;
        //database.insert(pfrs);
        }
        //database.insert(pfrs);
        
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
        testClaim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
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
        testClaim2.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        List<PartnerFundClaim> claims = new List<PartnerFundClaim>();
        claims.add(testClaim);
        claims.add(testClaim2);
        insert claims;
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
        
        List<Core_MDF_CCP_Custom_Metadata_Utility__c> mdtutilityList = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtUtility = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        mdtUtility.Core_MDF_Category__c = 'Bulk Claim Template';
		mdtUtility.Core_MDF_Field_2_txt__c = 'Core_MDF_Claim_Nm__c';
        mdtUtility.Core_MDF_Field_1_txt__c = 'Text';
        mdtUtility.Core_MDF_Sort_Order_Nbr__c = 0;
        mdtUtility.Core_MDF_Field_3_txt__c	 = 'Title';
        mdtUtility.Core_MDF_Checkbox_Field_1_Ind__c = True;
        mdtUtility.Core_MDF_Checkbox_Field_2_Ind__c = False;
        mdtUtility.Core_MDF_Checkbox_Field_3_Ind__c = False;
        mdtUtility.Core_MDF_Checkbox_Field_4_Ind__c = False;
        mdtUtility.Core_MDF_Checkbox_Field_5_Ind__c = False;
        mdtUtility.Core_MDF_Checkbox_Field_6_Ind__c = False;
        mdtUtility.Core_MDF_Checkbox_Field_7_Ind__c = True;
        mdtUtility.Core_MDF_Checkbox_Field_8_Ind__c = True;
        mdtUtility.Core_MDF_Checkbox_Field_9_Ind__c = True;
        mdtUtility.Core_MDF_Checkbox_Field_10_Ind__c = True;
        mdtUtility.Core_MDF_Name_Criteria__c = 'Title';
        mdtUtility.Core_MDF_Sub_Category__c  = 'PartnerFundClaim';
        mdtUtility.Core_MDF_Program__c = 'Retail Marketing Funds';
        mdtutilityList.add(mdtUtility);   
        
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtUtility1 = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        mdtUtility1.Core_MDF_Category__c = 'Bulk Claim Template';
		mdtUtility1.Core_MDF_Field_2_txt__c = 'Core_MDF_Activity_Nbr__c';
        mdtUtility1.Core_MDF_Field_1_txt__c = 'Text';
        mdtUtility1.Core_MDF_Sort_Order_Nbr__c = 1;
        mdtUtility1.Core_MDF_Field_3_txt__c	 = 'RequestId';
        mdtUtility1.Core_MDF_Checkbox_Field_1_Ind__c = True;
        mdtUtility1.Core_MDF_Checkbox_Field_2_Ind__c = False;
        mdtUtility1.Core_MDF_Checkbox_Field_3_Ind__c = False;
        mdtUtility1.Core_MDF_Checkbox_Field_4_Ind__c = False;
        mdtUtility1.Core_MDF_Checkbox_Field_5_Ind__c = False;
        mdtUtility1.Core_MDF_Checkbox_Field_6_Ind__c = False;
        mdtUtility1.Core_MDF_Checkbox_Field_7_Ind__c = True;
        mdtUtility1.Core_MDF_Checkbox_Field_8_Ind__c = True;
        mdtUtility1.Core_MDF_Checkbox_Field_9_Ind__c = True;
        mdtUtility1.Core_MDF_Checkbox_Field_10_Ind__c = True;
        mdtUtility1.Core_MDF_Name_Criteria__c = 'RequestId';
        mdtUtility1.Core_MDF_Sub_Category__c  = 'PartnerFundClaim';
        mdtUtility1.Core_MDF_Program__c = 'Client CoMarketing Fund';
        mdtutilityList.add(mdtUtility1);   
        
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtUtility2 = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        mdtUtility2.Core_MDF_Category__c = 'Bulk Claim Template';
		mdtUtility2.Core_MDF_Field_2_txt__c = 'Core_MDF_Ad_Run_Start_Dt__c';
        mdtUtility2.Core_MDF_Field_1_txt__c = 'Date';
        mdtUtility2.Core_MDF_Sort_Order_Nbr__c = 2;
        mdtUtility2.Core_MDF_Field_3_txt__c	 = 'Core_MDF_Ad_Run_Start_Date__c';
        mdtUtility2.Core_MDF_Checkbox_Field_1_Ind__c = True;
        mdtUtility2.Core_MDF_Checkbox_Field_2_Ind__c = False;
        mdtUtility2.Core_MDF_Checkbox_Field_3_Ind__c = False;
        mdtUtility2.Core_MDF_Checkbox_Field_4_Ind__c = False;
        mdtUtility2.Core_MDF_Checkbox_Field_5_Ind__c = False;
        mdtUtility2.Core_MDF_Checkbox_Field_6_Ind__c = False;
        mdtUtility2.Core_MDF_Checkbox_Field_7_Ind__c = True;
        mdtUtility2.Core_MDF_Checkbox_Field_8_Ind__c = True;
        mdtUtility2.Core_MDF_Checkbox_Field_9_Ind__c = True;
        mdtUtility2.Core_MDF_Checkbox_Field_10_Ind__c = True;
        mdtUtility2.Core_MDF_Name_Criteria__c = 'Core_MDF_Ad_Run_Start_Dt__c';
        mdtUtility2.Core_MDF_Sub_Category__c  = 'PartnerFundClaim';
        mdtUtility2.Core_MDF_Program__c = 'Client CoMarketing Fund';
        mdtutilityList.add(mdtUtility2);           
        
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtUtility3 = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        mdtUtility3.Core_MDF_Category__c = 'Bulk Claim Template';
		mdtUtility3.Core_MDF_Field_2_txt__c = 'Core_MDF_Country_Location_nm__c';
        mdtUtility3.Core_MDF_Field_1_txt__c = 'Picklist';
        mdtUtility3.Core_MDF_Sort_Order_Nbr__c = 4;
        mdtUtility3.Core_MDF_Field_3_txt__c	 = 'Core_MDF_Country_Location_nm__c';
        mdtUtility3.Core_MDF_Checkbox_Field_1_Ind__c = True;
        mdtUtility3.Core_MDF_Checkbox_Field_2_Ind__c = False;
        mdtUtility3.Core_MDF_Checkbox_Field_3_Ind__c = False;
        mdtUtility3.Core_MDF_Checkbox_Field_4_Ind__c = False;
        mdtUtility3.Core_MDF_Checkbox_Field_5_Ind__c = False;
        mdtUtility3.Core_MDF_Checkbox_Field_6_Ind__c = False;
        mdtUtility3.Core_MDF_Checkbox_Field_7_Ind__c = True;
        mdtUtility3.Core_MDF_Checkbox_Field_8_Ind__c = True;
        mdtUtility3.Core_MDF_Checkbox_Field_9_Ind__c = True;
        mdtUtility3.Core_MDF_Checkbox_Field_10_Ind__c = True;
        mdtUtility3.Core_MDF_Name_Criteria__c = 'Core_MDF_Country_Location_nm__c';
        mdtUtility3.Core_MDF_Sub_Category__c  = 'PartnerFundClaim';
        mdtUtility3.Core_MDF_Program__c = 'Client CoMarketing Fund';
        mdtutilityList.add(mdtUtility3);                 
        
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtUtility4 = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        mdtUtility4.Core_MDF_Category__c = 'Bulk Claim Template';
		mdtUtility4.Core_MDF_Field_2_txt__c = 'Core_MDF_Total_Amt__c';
        mdtUtility4.Core_MDF_Field_1_txt__c = 'Number';
        mdtUtility4.Core_MDF_Sort_Order_Nbr__c = 12;
        mdtUtility4.Core_MDF_Field_3_txt__c	 = 'Core_MDF_Total_Invoice_Amount_Local__c';
        mdtUtility4.Core_MDF_Checkbox_Field_1_Ind__c = True;
        mdtUtility4.Core_MDF_Checkbox_Field_2_Ind__c = False;
        mdtUtility4.Core_MDF_Checkbox_Field_3_Ind__c = False;
        mdtUtility4.Core_MDF_Checkbox_Field_4_Ind__c = False;
        mdtUtility4.Core_MDF_Checkbox_Field_5_Ind__c = False;
        mdtUtility4.Core_MDF_Checkbox_Field_6_Ind__c = False;
        mdtUtility4.Core_MDF_Checkbox_Field_7_Ind__c = True;
        mdtUtility4.Core_MDF_Checkbox_Field_8_Ind__c = True;
        mdtUtility4.Core_MDF_Checkbox_Field_9_Ind__c = True;
        mdtUtility4.Core_MDF_Checkbox_Field_10_Ind__c = True;
        mdtUtility4.Core_MDF_Name_Criteria__c = 'Core_MDF_Total_Invoice_Amount_Local__c';
        mdtUtility4.Core_MDF_Sub_Category__c  = 'PartnerFundClaim';
        mdtUtility4.Core_MDF_Program__c = 'Client CoMarketing Fund';
        mdtutilityList.add(mdtUtility4);  
        
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtUtility5 = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        mdtUtility5.Core_MDF_Category__c = 'Bulk Claim Template';
		mdtUtility5.Core_MDF_Field_2_txt__c = 'Core_MDF_Inv_Receipt_Cur_Cd__c';
        mdtUtility5.Core_MDF_Field_1_txt__c = 'Picklist';
        mdtUtility5.Core_MDF_Sort_Order_Nbr__c = 11;
        mdtUtility5.Core_MDF_Field_3_txt__c	 = 'Core_MDF_Currency__c';
        mdtUtility5.Core_MDF_Checkbox_Field_1_Ind__c = True;
        mdtUtility5.Core_MDF_Checkbox_Field_2_Ind__c = False;
        mdtUtility5.Core_MDF_Checkbox_Field_3_Ind__c = False;
        mdtUtility5.Core_MDF_Checkbox_Field_4_Ind__c = False;
        mdtUtility5.Core_MDF_Checkbox_Field_5_Ind__c = False;
        mdtUtility5.Core_MDF_Checkbox_Field_6_Ind__c = False;
        mdtUtility5.Core_MDF_Checkbox_Field_7_Ind__c = True;
        mdtUtility5.Core_MDF_Checkbox_Field_8_Ind__c = True;
        mdtUtility5.Core_MDF_Checkbox_Field_9_Ind__c = True;
        mdtUtility5.Core_MDF_Checkbox_Field_10_Ind__c = True;
        mdtUtility5.Core_MDF_Name_Criteria__c = 'Core_MDF_Currency__c';
        mdtUtility5.Core_MDF_Sub_Category__c  = 'PartnerFundClaim';
        mdtUtility5.Core_MDF_Program__c = 'Client CoMarketing Fund';
        mdtutilityList.add(mdtUtility5); 
        
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtUtility6 = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        mdtUtility6.Core_MDF_Category__c = 'Bulk Claim Template';
		mdtUtility6.Core_MDF_Field_2_txt__c = 'Core_MDF_Activity_SubType_nm__c';
        mdtUtility6.Core_MDF_Field_1_txt__c = 'Picklist';
        mdtUtility6.Core_MDF_Sort_Order_Nbr__c = 5;
        mdtUtility6.Core_MDF_Field_3_txt__c	 = 'Core_MDF_Activity_SubType_nm__c';
        mdtUtility6.Core_MDF_Checkbox_Field_1_Ind__c = True;
        mdtUtility6.Core_MDF_Checkbox_Field_2_Ind__c = False;
        mdtUtility6.Core_MDF_Checkbox_Field_3_Ind__c = False;
        mdtUtility6.Core_MDF_Checkbox_Field_4_Ind__c = False;
        mdtUtility6.Core_MDF_Checkbox_Field_5_Ind__c = False;
        mdtUtility6.Core_MDF_Checkbox_Field_6_Ind__c = False;
        mdtUtility6.Core_MDF_Checkbox_Field_7_Ind__c = True;
        mdtUtility6.Core_MDF_Checkbox_Field_8_Ind__c = True;
        mdtUtility6.Core_MDF_Checkbox_Field_9_Ind__c = True;
        mdtUtility6.Core_MDF_Checkbox_Field_10_Ind__c = True;
        mdtUtility6.Core_MDF_Name_Criteria__c = 'Core_MDF_Activity_SubType_nm__c';
        mdtUtility6.Core_MDF_Sub_Category__c  = 'PartnerFundClaim';
        mdtUtility6.Core_MDF_Program__c = 'Client CoMarketing Fund';
        mdtutilityList.add(mdtUtility6); 
        
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtUtility7 = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        mdtUtility7.Core_MDF_Category__c = 'Bulk Claim Template';
		mdtUtility7.Core_MDF_Field_2_txt__c = 'Core_MDF_Bank_Nbr__c';
        mdtUtility7.Core_MDF_Field_1_txt__c = 'Text';
        mdtUtility7.Core_MDF_Sort_Order_Nbr__c = 7;
        mdtUtility7.Core_MDF_Field_3_txt__c	 = 'Core_MDF_Bank__c';
        mdtUtility7.Core_MDF_Checkbox_Field_1_Ind__c = True;
        mdtUtility7.Core_MDF_Checkbox_Field_2_Ind__c = False;
        mdtUtility7.Core_MDF_Checkbox_Field_3_Ind__c = False;
        mdtUtility7.Core_MDF_Checkbox_Field_4_Ind__c = False;
        mdtUtility7.Core_MDF_Checkbox_Field_5_Ind__c = False;
        mdtUtility7.Core_MDF_Checkbox_Field_6_Ind__c = False;
        mdtUtility7.Core_MDF_Checkbox_Field_7_Ind__c = True;
        mdtUtility7.Core_MDF_Checkbox_Field_8_Ind__c = True;
        mdtUtility7.Core_MDF_Checkbox_Field_9_Ind__c = True;
        mdtUtility7.Core_MDF_Checkbox_Field_10_Ind__c = True;
        mdtUtility7.Core_MDF_Name_Criteria__c = 'Core_MDF_Bank__c';
        mdtUtility7.Core_MDF_Sub_Category__c  = 'PartnerFundClaim';
        mdtUtility7.Core_MDF_Program__c = 'Client CoMarketing Fund';
        mdtutilityList.add(mdtUtility7); 
        
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtUtility8 = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        mdtUtility8.Core_MDF_Category__c = 'Bulk Claim Template';
		mdtUtility8.Core_MDF_Field_2_txt__c = 'Core_MDF_Bank_Account_Nbr__c';
        mdtUtility8.Core_MDF_Field_1_txt__c = 'Text';
        mdtUtility8.Core_MDF_Sort_Order_Nbr__c = 8;
        mdtUtility8.Core_MDF_Field_3_txt__c	 = 'Core_MDF_Bank__c';
        mdtUtility8.Core_MDF_Checkbox_Field_1_Ind__c = True;
        mdtUtility8.Core_MDF_Checkbox_Field_2_Ind__c = False;
        mdtUtility8.Core_MDF_Checkbox_Field_3_Ind__c = False;
        mdtUtility8.Core_MDF_Checkbox_Field_4_Ind__c = False;
        mdtUtility8.Core_MDF_Checkbox_Field_5_Ind__c = False;
        mdtUtility8.Core_MDF_Checkbox_Field_6_Ind__c = False;
        mdtUtility8.Core_MDF_Checkbox_Field_7_Ind__c = True;
        mdtUtility8.Core_MDF_Checkbox_Field_8_Ind__c = True;
        mdtUtility8.Core_MDF_Checkbox_Field_9_Ind__c = True;
        mdtUtility8.Core_MDF_Checkbox_Field_10_Ind__c = True;
        mdtUtility8.Core_MDF_Name_Criteria__c = 'Core_MDF_Bank__c';
        mdtUtility8.Core_MDF_Sub_Category__c  = 'PartnerFundClaim';
        mdtUtility8.Core_MDF_Program__c = 'Client CoMarketing Fund';
        mdtutilityList.add(mdtUtility8);     
        
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtUtility9 = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        mdtUtility9.Core_MDF_Category__c = 'BulkClaim';
        mdtUtility9.Core_MDF_Is_Active_Ind__c = True;
        mdtUtility9.Core_MDF_Name_Criteria__c = 'Tax_Req';
        mdtUtility9.Core_MDF_Sub_Category__c  = 'MDF';
        mdtUtility9.Core_MDF_Program__c = 'Client CoMarketing Fund';
        mdtUtility9.Core_MDF_Value__c = 'False';
        mdtutilityList.add(mdtUtility9);    
        
       	Core_MDF_CCP_Custom_Metadata_Utility__c mdtUtility10 = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        mdtUtility10.Core_MDF_Category__c = 'BulkClaim';
        mdtUtility10.Core_MDF_Is_Active_Ind__c = True;
        mdtUtility10.Core_MDF_Name_Criteria__c = 'Tax_Req';
        mdtUtility10.Core_MDF_Sub_Category__c  = 'OEM CMP';
        mdtUtility10.Core_MDF_Program__c = 'Client CoMarketing Fund';
        mdtUtility10.Core_MDF_Value__c = 'False';
        mdtutilityList.add(mdtUtility10);     
        
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtUtility11 = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        mdtUtility11.Core_MDF_Category__c = 'BulkClaim';
        mdtUtility11.Core_MDF_Is_Active_Ind__c = True;
        mdtUtility11.Core_MDF_Checkbox_Field_1_Ind__c = true;
        mdtUtility11.Core_MDF_Checkbox_Field_2_Ind__c = true;
        mdtUtility11.Core_MDF_Checkbox_Field_3_Ind__c = False;
        mdtUtility11.Core_MDF_Checkbox_Field_4_Ind__c = False;
        mdtUtility11.Core_MDF_Checkbox_Field_5_Ind__c = False;
        mdtUtility11.Core_MDF_Checkbox_Field_6_Ind__c = False;
        mdtUtility11.Core_MDF_Checkbox_Field_7_Ind__c = True;
        mdtUtility11.Core_MDF_Checkbox_Field_8_Ind__c = True;
        mdtUtility11.Core_MDF_Checkbox_Field_9_Ind__c = True;
        mdtUtility11.Core_MDF_Checkbox_Field_10_Ind__c = True;
        mdtUtility11.Core_MDF_Sub_Category__c  = 'OEM CMP';
        mdtUtility11.Core_MDF_Program__c = 'Client CoMarketing Fund';
        mdtutilityList.add(mdtUtility11); 
        insert mdtutilityList;                
         
    }
    
    //Test Method to test Successful Insertion and Duplicate Record Insertion of RMF Claim Stage Records
    /*@isTest static void testRMFParseFileAndDuplicateRecordInsertion() {
        
        
        User sysAdminUser = [SELECT Id,LanguageLocaleKey FROM USER WHERE LanguageLocaleKey = 'en_US' LIMIT 1];
        System.runAs(sysAdminUser){
            
            List<Account> rmfAccounts = [Select Id, Name,Core_MDF_CoMarketing_Ultimate_Account__c   from Account where Name = 'Test RMF VC Acc New' limit 1];
            List<PartnerFundRequest> activityRecordList = [Select id, Title, Core_MDF_Activity_Number__c,ChannelPartner.Core_MDF_Active_Ind__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where ChannelPartnerId =:rmfAccounts[0].Id limit 1];
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c,Core_MDF_Bank_Account_Number__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231245'];
            //Core_MDF_Bank__c bankRecord2 = [Select id, Name, Core_MDF_Supplier_Number__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231250'];
            
            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today();
            Datetime dt = system.today();
            String dateString = dt.format(dateFormatString);
            Datetime dt1 = system.today()+1;
            String dateString1 = dt1.format(dateFormatString);
             Datetime dt2 = system.today()+2;
            String dateString2 = dt2.format(dateFormatString);
            Datetime dt3 = system.today()-8;
            String dateString3 = dt3.format(dateFormatString);
            
            String csvString = 'Claim Name,Activity #,"Execution Start Date(DD-MMM-YY)","Execution End Date(DD-MMM-YY)",Country,"Bank (Supplier ID)","Bank Account Number(last 4 digits)",Proof Of Cost Currency,"Total Amount (Local)","Costs not Reimbursable (Local)",Invoice Type,Claim Comments'+
                                '\n Dell RMF Claim from Bulk 1,' + activityRecordList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',AFGHANISTAN,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c +',' + 'USD,100,0,Service Invoice to Intel (VAT may apply),RMFClaim1 '+
                                '\n Dell RMF Claim from Bulk 2,' + activityRecordList[0].Core_MDF_Activity_Number__c + ',' + dateString1 + ',' + dateString1 + ',AFGHANISTAN,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + 'USD,200,0,Service Invoice to Intel (VAT may apply),RMFClaim1 '+
                                '\n Dell RMF Claim from Bulk 3,' + activityRecordList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString1 + ',AFGHANISTAN,' + '1231231250' + ','+ bankRecord.Core_MDF_Bank_Account_Number__c + ',' + 'USD,50,0,,RMFClaim1 '+
                                '\n Dell RMF Claim from Bulk dublicate 1 ,' + activityRecordList[0].Core_MDF_Activity_Number__c + ',' + dateString1 + ',' + dateString1 + ',AFGHANISTAN,' + '1231231250' + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + 'USD,50,0,Reimbursement Request for 3rd party payment (NET cost only),RMFClaim1 dublicate '+
                                '\n Dell RMF Claim from Bulk 4,' + activityRecordList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString2 + ',AFGHANISTAN,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + 'USD,100,0,Reimbursement Request for 3rd party payment (NET cost only),RMFClaim1 '+
                                '\n Dell RMF Claim from Bulk 5,' + activityRecordList[0].Core_MDF_Activity_Number__c + ',' + dateString1 + ',' + dateString1 + ',AFGHANISTAN,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + 'USD,101,0,Reimbursement Request for 3rd party payment (NET cost only),RMFClaim1 '+
                                '\n Dell RMF Claim from Bulk 6,' + activityRecordList[0].Core_MDF_Activity_Number__c + ',' + dateString3 + ',' + dateString3 + ',AFGHANISTAN,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + '1234' + ',' + 'USD,101,0,Service Invoice to Intel (VAT may apply),RMFClaim1 ';
            
            
                                //'\n Dell RMF Claim from Bulk dublicate 1,' + activityRecordList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',AFGHANISTAN,' + '1231231250' + ',' + 'USD,50,Yes,,RMFClaim1 dublicate ';
            csvString = csvString + '\n Dell RMF Claim from Bulk 1,' + activityRecordList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',AFGHANISTAN,' + '1231231250' + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + 'USD,200,0,Service Invoice to Intel (VAT may apply),RMFClaim1' ;
            Blob myBlob = Blob.valueof(csvString);
            String base64Data = EncodingUtil.base64Encode(myBlob);
            String fileName = 'fileName.csv';            

            
            ChannelProgram channelProgram = [Select id from ChannelProgram where Name = 'Retail Marketing Funds'];
            
            Core_MDF_BulkClaimServerController.fetchRecordTypeMetaData();
            
            Core_MDF_Claim_Batch__c claimbatchinstance = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c Where Core_MDF_Program_Id__c =: channelProgram.Id LIMIT 1];
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram WHERE Id =:channelProgram.Id LIMIT 1].Core_MDF_Technical_Program_Name__c;
            /*Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                                               Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c, Core_MDF_Claim_Field_API_Name__c
                                                                                                                                               FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                                               WHERE Core_MDF_Channel_program__c = :channelProgramName
                                                                                                                                               AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);*/
/*Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c> metadataIdToRecordMap = new Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c>([SELECT Id, Name, Core_MDF_Field_2_txt__c, Core_MDF_Field_1_txt__c, Core_MDF_Sort_Order_Nbr__c, Core_MDF_Field_3_txt__c, Core_MDF_Checkbox_Field_1_Ind__c, Core_MDF_Name_Criteria__c, Core_MDF_Program__c FROM Core_MDF_CCP_Custom_Metadata_Utility__c WHERE Core_MDF_Program__c = :channelProgramName AND Core_MDF_Sub_Category__c =:Label.Core_MDF_PFCText  AND Core_MDF_Category__c = :Core_MDF_CCP_ConstantClass.BULK_CLAIM_TEMPLATE ORDER BY Core_MDF_Sort_Order_Nbr__c]);
            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                     FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                     WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];
            Test.startTest();
            
            
            List<Core_MDF_Claim_Batch_Stage__c> listOfbatchStagerecords = Core_MDF_BulkClaimServerController.validateDataType(metadataIdToRecordMap,myBlob,rmfAccounts[0].Core_MDF_CoMarketing_Ultimate_Account__c ,channelProgram.Id);
            Core_MDF_BulkClaimServerController.insertClaimBatchStageRecords(listOfbatchStagerecords,claimbatchinstance,recordType);
            
            
            //Core_MDF_Claim_Batch_Stage__c batchStage = [select id, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c from Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id AND Core_MDF_Processing_Status_Nm__c =: Label.Core_MDF_In_Progress_Status limit 1];
            Core_MDF_Claim_Batch_Stage__c batchStage = [select id, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c, Core_MDF_Bank_Account_Nbr__c from Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id /*AND Core_MDF_Processing_Status_Nm__c ='Submitted'*/ //limit 1];
            
            /*assert.areNotEqual(Null,batchStage.Id);
            try{
                Database.delete(batchStage);
            }catch(Exception e)
            {assert.areEqual(e.getMessage().contains(Label.Core_MDF_Claim_Cannot_BeDeleted),True);}
            
            Core_MDF_ClaimInsert_Batch c = new Core_MDF_ClaimInsert_Batch(System.now());
            Database.executeBatch(c,200);
            
            List<Core_MDF_Claim_Batch_Stage__c> batchStageForLinkingAuditDoc = [select id, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c, Core_MDF_Claim_Nm__c, Core_MDF_Bank_Account_Nbr__c from Core_MDF_Claim_Batch_Stage__c]; //WHERE Core_MDF_Claim_Nm__c IN ('Dell RMF Claim from Bulk 5','Dell RMF Claim from Bulk 6') limit 2];
            
            
            List<Core_MDF_Audit_Document__c> CMDList = new List<Core_MDF_Audit_Document__c>();
            Core_MDF_Audit_Document__c CMD = new Core_MDF_Audit_Document__c();
            CMD.Core_MDF_Claim_Batch_Record__c = batchStageForLinkingAuditDoc[0].Id;
            CMD.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
            CMD.Core_MDF_Document_Title__c = 'Test Docs';
            CMD.Core_MDF_App_Document_Types_nm__c ='Proof of Cost;Proof of Branding;Proof of Execution';
            CMDList.add(CMD);
            Core_MDF_Audit_Document__c CMD2 = new Core_MDF_Audit_Document__c();
            CMD2.Core_MDF_Claim_Batch_Record__c = batchStageForLinkingAuditDoc[0].Id;
            CMD2.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
            CMD2.Core_MDF_Document_Title__c = 'Test Docs';
            CMD2.Core_MDF_App_Document_Types_nm__c ='Proof of Cost;Proof of Branding;Proof of Execution';
            CMDList.add(CMD2);
            Database.insert(CMDList);
            
            batchStageForLinkingAuditDoc[0].Core_MDF_Processing_Status_Nm__c ='Submitted';
            batchStageForLinkingAuditDoc[1].Core_MDF_Processing_Status_Nm__c ='Submitted';
            //batchStageForLinkingAuditDoc.Core_MDF_Ad_Run_Start_Dt__c = system.today()+1;
            //batchStageForLinkingAuditDoc.Core_MDF_Ad_Run_End_Dt__c = system.today()+1;
            Database.update(batchStageForLinkingAuditDoc);
            
            Core_MDF_ClaimInsert_Batch c1 = new Core_MDF_ClaimInsert_Batch(System.now());
            Database.executeBatch(c1,200);
            
            /*Core_MDF_ClaimInsert_Batch instancevar = new Core_MDF_ClaimInsert_Batch();
            Database.QueryLocator ql = instancevar.start(null);
            instancevar.execute(null,listOfbatchStagerecords);
            instancevar.Finish(null);*/
            
            /*try{Core_MDF_BulkClaimServerController.parseFile(base64Data, fileName, channelProgram.Id);}catch(Exception e){}
        }
        Test.stopTest();  
    }*/
    
    //Test Method to fetchUserAndTemplateDetails 
    @isTest static void testFetchUserAndTemplateDetails() {
        
        User sysAdminUser = [SELECT Id,LanguageLocaleKey FROM USER WHERE LanguageLocaleKey = 'en_US' LIMIT 1];
        System.runAs(sysAdminUser){

        Test.startTest();
        User japaneseUser = [Select Id from User WHERE LanguageLocaleKey = 'ja' LIMIT 1];
        List <String> fetchUserList = new List <String>();
        fetchUserList = Core_MDF_BulkClaimServerController.fetchUserAndTemplateDetails('CCF');
        assert.areEqual(FALSE,fetchUserList.contains('PowerPartner'));
       	Core_MDF_BulkClaimServerController.displayInfoMessage();
        Test.stopTest();
        }
    }
    
    //Test Method to test Successful Insertion and Duplicate Record Insertion of Claim Stage Records
    @isTest static void testParseFileAndDuplicateRecordInsertion() {
        
        
        User sysAdminUser = [SELECT Id,LanguageLocaleKey FROM USER WHERE LanguageLocaleKey = 'en_US' LIMIT 1];
        System.runAs(sysAdminUser){
            
            List<Account> accounts = [Select Id, Name, Core_MDF_CoMarketing_Ultimate_Account__c  from Account where Name in ('Test Acc New 2','Test Acc New 3')];
            List<PartnerFundRequest> activityRecordList = [Select id, Title, Core_MDF_Activity_Number__c,ChannelPartner.Core_MDF_Active_Ind__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where ChannelPartnerId IN :accounts limit 2];
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c, Core_MDF_Bank_Account_Number__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];
            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today();
            Datetime dt = system.today();
            String dateString = dt.format(dateFormatString);
           
            String csvString = 'Claim Name,Activity #,"Execution Start Date(DD-MMM-YY)","Execution End Date(DD-MMM-YY)","Country","Activity Subtype",Media Vehicle,"Bank (Supplier ID)","Bank Account Number(last 4 digits)","Proof Of Cost Date(DD-MMM-YY)",Proof Of Cost Number,Proof Of Cost Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments'+
                ' \n Dell DCF Claim from Bulk 1!,' + activityRecordList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,,,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',1234,USD,10,0,0,DCFClaim11' +
                '\n Dell DCF Claim from Bulk 1!,' + activityRecordList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,,999,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',1234,USD,10,0,0,DCFClaim12' +
                '\n Dell DCF Claim from Bulk 3,' + activityRecordList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,,999,' + '8956565623' + ',' + '1235' + ',' + dateString + ',1234,USD,10,0,0,DCFClaim13 '+
                '\n Dell DCF Claim from Bulk 3,' + activityRecordList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,,999,' + '1234589565' + ',' + '1235' + ',' + dateString + ',1234,USD,10,0,0,DCFClaim13 '+
                '\n Dell DCF Claim from Bulk4!,' + activityRecordList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,,999,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',1234,USD,10,0,0,DCFClaim14';
            csvString = csvString + '\n Dell DCF Claim from Bulk 4!,' + activityRecordList[1].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,,online,' + '1231231230' + ',' + '1245' + ',' + dateString + ',12345,USD,50,0,0,DCFClaim15' ;
            Blob myBlob = Blob.valueof(csvString);
            String base64Data = EncodingUtil.base64Encode(myBlob);
            String fileName = 'fileName.csv';            

            
            ChannelProgram channelProgram = [Select id from ChannelProgram where Name =: Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
            
            Core_MDF_BulkClaimServerController.fetchRecordTypeMetaData();
            
            Core_MDF_Claim_Batch__c claimbatchinstance = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c LIMIT 1];
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram WHERE Id =:channelProgram.Id LIMIT 1].Core_MDF_Technical_Program_Name__c;
            /*Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                                               Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c, Core_MDF_Claim_Field_API_Name__c
                                                                                                                                               FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                                               WHERE Core_MDF_Channel_program__c = :channelProgramName
                                                                                                                                               AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);*/
            Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c> metadataIdToRecordMap = new Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c>([SELECT Id, Name, Core_MDF_Field_2_txt__c, Core_MDF_Field_1_txt__c, Core_MDF_Sort_Order_Nbr__c, Core_MDF_Field_3_txt__c, Core_MDF_Checkbox_Field_1_Ind__c, Core_MDF_Name_Criteria__c, Core_MDF_Program__c FROM Core_MDF_CCP_Custom_Metadata_Utility__c
                                                                                                                                         WHERE Core_MDF_Program__c = :channelProgramName 
                                                                                                                                         AND Core_MDF_Sub_Category__c =:Label.Core_MDF_PFCText  
                                                                                                                                         AND Core_MDF_Category__c = 'bulk claim template'
                                                                                                                                         ORDER BY Core_MDF_Sort_Order_Nbr__c]);

            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                     FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                     WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];
            
            Test.startTest();
            List<Core_MDF_Claim_Batch_Stage__c> listOfbatchStagerecords = Core_MDF_BulkClaimServerController.validateDataType(metadataIdToRecordMap,myBlob,accounts[0].Core_MDF_CoMarketing_Ultimate_Account__c,channelProgram.Id);
            Core_MDF_BulkClaimServerController.insertClaimBatchStageRecords(listOfbatchStagerecords,claimbatchinstance,recordType);
            
            
            //Core_MDF_Claim_Batch_Stage__c batchStage = [select id, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c from Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id AND Core_MDF_Processing_Status_Nm__c =: Label.Core_MDF_In_Progress_Status limit 1];
            Core_MDF_Claim_Batch_Stage__c batchStage = [select id, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c, Core_MDF_Bank_Account_Nbr__c from Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id /*AND Core_MDF_Processing_Status_Nm__c ='Submitted'*/ limit 1];
            assert.areNotEqual(Null,batchStage.Id);
            Core_MDF_BatchStageClaimController.fetchClaimRecordType(batchStage.ID);
            try{
                Database.delete(batchStage);
            }catch(Exception e)
            {assert.areEqual(e.getMessage().contains(Label.Core_MDF_Claim_Cannot_BeDeleted),True);}
            
            Core_MDF_ClaimInsert_Batch c = new Core_MDF_ClaimInsert_Batch(System.now());
            Database.executeBatch(c,200);
            try{Core_MDF_BulkClaimServerController.parseFile(base64Data, fileName, channelProgram.Id);}catch(Exception e){}
        }
        Test.stopTest();
        
        
    }
    
    //Test Method to test the Update scenarios on Claim Batch Stage Records
    @isTest static void testUpdateScenariosOnClaimBatchStageRecords() {
        
        
        User sysAdminUser = [SELECT Id,LanguageLocaleKey FROM User WHERE LanguageLocaleKey='en_US' LIMIT 1];
        System.runAs(sysAdminUser){
            
            Account intelAccount = [Select id from Account where Name = 'Test Acc New 1'];
            
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram  LIMIT 1].Core_MDF_Technical_Program_Name__c;
            /*Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                                               Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c,Core_MDF_Claim_Field_API_Name__c
                                                                                                                                               FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                                               WHERE Core_MDF_Channel_program__c = :channelProgramName
                                                                                                                                               AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);*/
            Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c> metadataIdToRecordMap = new Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c>([SELECT Id, Name, Core_MDF_Field_2_txt__c, Core_MDF_Field_1_txt__c, Core_MDF_Sort_Order_Nbr__c, Core_MDF_Field_3_txt__c, Core_MDF_Checkbox_Field_1_Ind__c, Core_MDF_Name_Criteria__c, Core_MDF_Program__c 
                                                                                                                                         FROM Core_MDF_CCP_Custom_Metadata_Utility__c 
                                                                                                                                         WHERE Core_MDF_Program__c = :channelProgramName 
                                                                                                                                         AND Core_MDF_Sub_Category__c =:Label.Core_MDF_PFCText 
                                                                                                                                         AND Core_MDF_Category__c = 'bulk claim template'
                                                                                                                                         ORDER BY Core_MDF_Sort_Order_Nbr__c]);
            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                     FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                     WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];
            
            ChannelProgram channelProgram = [Select id from ChannelProgram where Name =:Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
            
            PartnerFundRequest activityRecord = [Select id, Title, Core_MDF_Activity_Number__c,Core_MDF_Start_Date__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where Title = 'test' Limit 1];
            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today();
            Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
            String dateString = dt.format(dateFormatString);
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c, Core_MDF_Bank_Status__c, Core_MDF_Program__c, Core_MDF_Bank_Account_Number__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];
            String fileName = 'file1.csv';
            Core_MDF_Claim_Batch__c claimbatchinstance = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c LIMIT 1];
            String csvStringForFailedRecord = 'Claim Name,Activity #,"Execution Start Date  (YYYY-MM-DD)","Execution End Date (YYYY-MM-DD)","Country","Activity Subtype","Media Vehicle","Bank","Bank Account Number(last 4 digits)","Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Dell DCF Claim from Bulk 1,' 
            + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,7011,' + '1245678981'+ ',' + '1243'+ ',' +dateString + ',1234,USD,10,0,0,DCF2Claim2';
            Blob myBlob = Blob.valueof(csvStringForFailedRecord);
            Test.startTest();
            List<Core_MDF_Claim_Batch_Stage__c> listOfbatchStagerecords = Core_MDF_BulkClaimServerController.validateDataType(metadataIdToRecordMap,myBlob,intelAccount.Id,channelProgram.Id);
            Core_MDF_BulkClaimServerController.insertClaimBatchStageRecords(listOfbatchStagerecords,claimbatchinstance,recordType);
            
            /*Core_MDF_Claim_Batch_Stage__c failedStageRecord = [SELECT id,Core_MDF_Claim_Reference_Nbr__c,Core_MDF_Is_Duplicate_ind__c,Core_MDF_Create_Duplicate_ind__c,Core_MDF_Ad_Run_End_Dt__c, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c,Core_MDF_Bank_Account_Nbr__c FROM Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id AND Core_MDF_Is_Duplicate_ind__c =FALSE AND Core_MDF_Processing_Status_Nm__c =: Label.Core_MDF_Claim_Batch_Failed  AND  Core_MDF_Media_Vehicle_txt__c='7011' limit 1];
            failedStageRecord.Core_MDF_Ad_Run_End_Dt__c = System.today();
            failedStageRecord.Core_MDF_Media_Vehicle_txt__c = '239sdk834';
            failedStageRecord.Core_MDF_Bank_Nbr__c = bankRecord.Core_MDF_Supplier_Number__c;
            database.update(failedStageRecord);
            assert.areNotEqual(Null,failedStageRecord.Id);
            failedStageRecord = [SELECT Core_MDF_Processing_Status_Nm__c,Core_MDF_Claim_Reference_Nbr__c FROM Core_MDF_Claim_Batch_Stage__c WHERE ID =: failedStageRecord.Id LIMIT 1];*/            
        }
    }
    @isTest static void testUIErrorMessages() {
        
        
        User sysAdminUser = [SELECT Id,LanguageLocaleKey FROM User WHERE LanguageLocaleKey='en_US' LIMIT 1];
        System.runAs(sysAdminUser){
             Account intelAccount = [Select id from Account where Name = 'Test Acc New 1'];
            
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram  LIMIT 1].Core_MDF_Technical_Program_Name__c;
            /*Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                                               Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c
                                                                                                                                               FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                                               WHERE Core_MDF_Channel_program__c = :channelProgramName
                                                                                                                                               AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);*/
            Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c> metadataIdToRecordMap = new Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c>([SELECT Id, Name, Core_MDF_Field_2_txt__c, Core_MDF_Field_1_txt__c, Core_MDF_Sort_Order_Nbr__c, Core_MDF_Field_3_txt__c, Core_MDF_Checkbox_Field_1_Ind__c, Core_MDF_Name_Criteria__c, Core_MDF_Program__c FROM Core_MDF_CCP_Custom_Metadata_Utility__c 
                                                                                                                                         WHERE Core_MDF_Program__c = :channelProgramName 
                                                                                                                                         AND Core_MDF_Sub_Category__c =:Label.Core_MDF_PFCText 
                                                                                                                                         AND Core_MDF_Category__c = 'bulk claim template' ORDER BY Core_MDF_Sort_Order_Nbr__c]);
            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                     FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                     WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];
            
            ChannelProgram channelProgram = [Select id from ChannelProgram where Name = 'Client'];
            
            PartnerFundRequest activityRecord = [Select id, Title, Core_MDF_Activity_Number__c,Core_MDF_Start_Date__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where Title = 'OEM CMP Activity' Limit 1];
            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today();
            Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
            String dateString = dt.format(dateFormatString);
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c, Core_MDF_Bank_Status__c, Core_MDF_Program__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];
            String fileName = 'file1.csv';
            Core_MDF_Claim_Batch__c claimbatchinstance = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c LIMIT 1];
            // Invalid Activity Sub Type error
            String csvStringForRecord = 'Claim Name,Activity #,"Execution Start Date  (YYYY-MM-DD)","Execution End Date (YYYY-MM-DD)","Country","Activity Subtype","Media Vehicle","Bank","Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Dell DCF Claim from Bulk 1,' + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,'+'Banner/Display;Video;qwerty'+',7011,' + null+ ',' + dateString + ',1234,USD,10,0,0,Dell DCFClaim1';
            //Multiple countries error
            csvStringForRecord = csvStringForRecord + '\n Dell DCF Claim from Bulk 1,' + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India;Germany,'+'Banner/Display;Video'+',7011,' + null+ ',' + dateString + ',1234,USD,10,0,0,Dell DCFClaim1';
            // Invalid currency error
            csvStringForRecord = csvStringForRecord + '\n Dell DCF Claim from Bulk 1,' + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,'+'Banner/Display;Video'+',7011,' + null+ ',' + dateString + ',1234,ABC,10,0,0,Dell DCFClaim1';
            // Activity number missing error
            csvStringForRecord = csvStringForRecord + '\n Dell DCF Claim from Bulk 1,' + '' + ',' + dateString + ',' + dateString + ',Indian,'+'Banner/Display;Video'+',7011,' + null+ ',' + dateString + ',1234,USD,10,0,0,Dell DCFClaim1';
            // Invalid country error
            csvStringForRecord = csvStringForRecord + '\n Dell DCF Claim from Bulk 1,' + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',Indian,'+'Banner/Display;Video'+',7011,' + null+ ',' + dateString + ',1234,USD,10,0,0,Dell DCFClaim1';
            // Invalid Decimal error
            csvStringForRecord = csvStringForRecord + '\n Dell DCF Claim from Bulk 1,' + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,'+'Banner/Display,Video'+',7011@,' + null+ ',' + dateString + ',1234,USD,10,0,0,Claim1';            
            csvStringForRecord = csvStringForRecord + '\n Dell DCF Claim from Bulk 1,' + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,'+'Banner/Display'+',7011,' + null+ ',' + dateString + ',1234,USD,10,0,0,Claim1';            
            Blob myBlob = Blob.valueof(csvStringForRecord);
            Test.startTest();
            try{
                List<Core_MDF_Claim_Batch_Stage__c> listOfbatchStagerecords = Core_MDF_BulkClaimServerController.validateDataType(metadataIdToRecordMap,myBlob,intelAccount.Id,channelProgram.Id);
                Core_MDF_BulkClaimServerController.insertClaimBatchStageRecords(listOfbatchStagerecords,claimbatchinstance,recordType);
            }catch(exception e){
                assert.areEqual(e.getMessage(), e.getMessage());
            }            
            Test.stopTest();
        }
        
    }
    
    @isTest static void testValidationErrorMessages() {
        
        
        User sysAdminUser = [SELECT Id,LanguageLocaleKey FROM User WHERE LanguageLocaleKey='en_US' LIMIT 1];
        System.runAs(sysAdminUser){
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram  LIMIT 1].Core_MDF_Technical_Program_Name__c;
            ChannelProgram channelProgram = [Select id from ChannelProgram where Name = 'Client'];
            Account intelAccount = [Select id from Account where Name = 'Test Acc New 1'];
            
            /*Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                                               Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c,Core_MDF_Claim_Field_API_Name__c
                                                                                                                                               FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                                               WHERE Core_MDF_Channel_program__c = :channelProgramName
                                                                                                                                               AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);*/
            Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c> metadataIdToRecordMap = new Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c>([SELECT Id, Name, Core_MDF_Field_2_txt__c, Core_MDF_Field_1_txt__c, Core_MDF_Sort_Order_Nbr__c, Core_MDF_Field_3_txt__c, Core_MDF_Checkbox_Field_1_Ind__c, Core_MDF_Name_Criteria__c, Core_MDF_Program__c FROM Core_MDF_CCP_Custom_Metadata_Utility__c WHERE Core_MDF_Program__c = :channelProgramName AND Core_MDF_Sub_Category__c =:Label.Core_MDF_PFCText  AND Core_MDF_Category__c = :Core_MDF_CCP_ConstantClass.BULK_CLAIM_TEMPLATE ORDER BY Core_MDF_Sort_Order_Nbr__c]);

            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                     FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                     WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];
            
            List<String> pfrTitleList = new List<String>();
            pfrTitleList.add('OEM CMP Activity');
            pfrTitleList.add('MDF Activity');
            pfrTitleList.add('CCF 1.0 Activity');
            List<PartnerFundRequest> pfrList = [Select id, Title, Core_MDF_Activity_Number__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Start_Date__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where Title In: pfrTitleList Limit 3];
            Map<String,PartnerFundRequest> pfrMap = new Map<String,PartnerFundRequest>();
            for(PartnerFundRequest pfr : pfrList){
                pfrMap.put(pfr.Core_MDF_Budget_Type_nm__c, pfr);
            }
            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today();
            Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
            String dateString = dt.format(dateFormatString);
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c, Core_MDF_Bank_Account_Number__c, Core_MDF_Bank_Status__c, Core_MDF_Program__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];
            String fileName = 'file1.csv';
            Core_MDF_Claim_Batch__c claimbatchinstance = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c LIMIT 1];
            // Invalid Activity Sub Type error
            String csvStringForRecord = 'Claim Name,Activity #,"Execution Start Date  (YYYY-MM-DD)","Execution End Date (YYYY-MM-DD)","Country","Activity Subtype","Media Vehicle","Bank","Bank Account Number(last 4 digits)","Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Bulk Claim 1,' + pfrMap.get('OEM CMP').Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,'+'Video'+',7011,' + '1234567898'+ ',' + '1246' + ',' +dateString + ',1234,USD,10,0,0,Bulk Claim Claim1';                      
            //Multiple countries on Activity error
            csvStringForRecord = csvStringForRecord + '\n Bulk Claim 2,' + pfrMap.get('OEM CMP').Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,'+'Banner/Display'+',7011,' + '1234567894' + ',' + '1234' + ',' + dateString + ',1234,USD,10,0,0,Bulk Claim Claim1';
            //Media Vehicle mandatory error
            csvStringForRecord = csvStringForRecord + '\n Bulk Claim 3,' + pfrMap.get('OEM CMP').Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,'+'Banner/Display'+ ',' + null + ',' + '1234567894'+ ',' + '1234' + ',' + dateString + ',1234,USD,10,0,0,Bulk Claim Claim1';
            // MDF claim error
            //csvStringForRecord = csvStringForRecord + '\n Bulk Claim 4,' + pfrMap.get('MDF').Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,'+'Banner/Display'+',7011,' + '1234567894' + ',' + '1234' + ',' +  dateString + ',1234,USD,10,0,0,Bulk Claim Claim1';
            //invalid activity error
            csvStringForRecord = csvStringForRecord + '\n Bulk Claim 5,' + 3156799 + ',' + dateString + ',' + dateString + ',,'+'Banner/Display'+',,' + '1234567894' + ',' + '1234'+ ',' + dateString + ',1234,USD,10,0,0,Bulk Claim Claim1';         
            //Bank error
            csvStringForRecord = csvStringForRecord + '\n Bulk Claim 6,' + pfrMap.get('OEM CMP').Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,'+'Banner/Display'+',7899,' + '6788678856'+ ',' + '1234'+ ',' + dateString + ',1234,USD,10,0,0,Bulk Claim Claim1';          
            //Bank error
            csvStringForRecord = csvStringForRecord + '\n Bulk Claim 7,' + pfrMap.get('OEM CMP').Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,'+'Banner/Display'+',7899,' + '6788678856'+ ',' + '1246'+ ',' + dateString + ',1234,USD,10,0,0,Bulk Claim Claim1';          
            //Media vehicle inapplicable error
            //csvStringForRecord = csvStringForRecord + '\n Bulk Claim 8,' + pfrMap.get('CCF 1.0').Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,,7899,' + 6788+ ',' + dateString + ',1234,USD,10,0,0,Bulk Claim Claim1';
            //no error
            csvStringForRecord = csvStringForRecord + '\n Bulk Claim 9,' + pfrMap.get('OEM CMP').Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,'+'Banner/Display'+',7011,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',1234,USD,10,0,0,Bulk Claim Claim1';
            
            Blob myBlob = Blob.valueof(csvStringForRecord);
            Test.startTest();
            List<Core_MDF_Claim_Batch_Stage__c> listOfbatchStagerecords = Core_MDF_BulkClaimServerController.validateDataType(metadataIdToRecordMap,myBlob,intelAccount.Id,channelProgram.Id);
            Core_MDF_BulkClaimServerController.insertClaimBatchStageRecords(listOfbatchStagerecords,claimbatchinstance,recordType);     
            Core_MDF_ClaimInsert_Batch c = new Core_MDF_ClaimInsert_Batch();
            Database.executeBatch(c,200);
            List<Core_MDF_Claim_Batch_Stage__c> failedStageRecList = new List<Core_MDF_Claim_Batch_Stage__c>();
            Map<String,Core_MDF_Claim_Batch_Stage__c> cbsMap = new Map<String,Core_MDF_Claim_Batch_Stage__c>();
            For(Core_MDF_Claim_Batch_Stage__c cbs : [SELECT id,Core_MDF_Activity_Nbr__c, Core_MDF_Activity_SubType_nm__c,Core_MDF_Country_Location_nm__c,Core_MDF_Claim_Nm__c,Core_MDF_Claim_Reference_Nbr__c,Core_MDF_Is_Duplicate_ind__c,Core_MDF_Create_Duplicate_ind__c,Core_MDF_Ad_Run_End_Dt__c, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c, Core_MDF_Bank_Account_Nbr__c FROM Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id AND Core_MDF_Is_Duplicate_ind__c =FALSE AND Core_MDF_Processing_Status_Nm__c =: Label.Core_MDF_Claim_Batch_Failed  AND  Core_MDF_Claim_Nm__c LIKE 'Bulk Claim %' ORDER BY Core_MDF_Claim_Nm__c]){
                cbsMap.put(cbs.Core_MDF_Claim_Nm__c,cbs);
            }
            Core_MDF_Claim_Batch_Stage__c failedStageRecord = cbsMap.get('Bulk Claim 1');
            //failedStageRecord.Core_MDF_Activity_SubType_nm__c = 'Email';
           /* Core_MDF_Claim_Batch_Stage__c failedStageRecord1 = cbsMap.get('Bulk Claim 2');
            failedStageRecord1.Core_MDF_Country_Location_nm__c = 'Germany';
            Core_MDF_Claim_Batch_Stage__c failedStageRecord2 = cbsMap.get('Bulk Claim 3');
            failedStageRecord2.Core_MDF_Media_Vehicle_txt__c = '';
            Core_MDF_Claim_Batch_Stage__c failedStageRecord3 = cbsMap.get('Bulk Claim 4');
            failedStageRecord3.Core_MDF_Media_Vehicle_txt__c = '3432';
            Core_MDF_Claim_Batch_Stage__c failedStageRecord4 = cbsMap.get('Bulk Claim 5');
            failedStageRecord4.Core_MDF_Activity_Nbr__c = '343892';
            Core_MDF_Claim_Batch_Stage__c failedStageRecord5 = cbsMap.get('Bulk Claim 6');
            failedStageRecord5.Core_MDF_Bank_Nbr__c = null;
            Core_MDF_Claim_Batch_Stage__c failedStageRecord6 = cbsMap.get('Bulk Claim 7');
            failedStageRecord6.Core_MDF_Country_Location_nm__c = null;*/
            //Core_MDF_Claim_Batch_Stage__c failedStageRecord7 = cbsMap.get('Bulk Claim 8');
            //failedStageRecord7.Core_MDF_Media_Vehicle_txt__c = '379';
            //failedStageRecList.add(failedStageRecord);
            /*failedStageRecList.add(failedStageRecord1);
            failedStageRecList.add(failedStageRecord2);
            failedStageRecList.add(failedStageRecord3);
            failedStageRecList.add(failedStageRecord4);
            failedStageRecList.add(failedStageRecord5);
            failedStageRecList.add(failedStageRecord6);
            //failedStageRecList.add(failedStageRecord7);*/
            //Database.update(failedStageRecList);
            //assert.areEqual(Label.Core_MDF_Claim_Batch_Failed,failedStageRecord.Core_MDF_Processing_Status_Nm__c);
            Test.stopTest();
        }
        
    }
    
    //Test Method to test the UI Validations on Uploading the CSV File AND Insert/Update failing Stage Records
    @isTest static void testUIValidationsAndFailedStageScenarios() {
        
        
        User sysAdminUser = [SELECT ID FROM User WHERE LanguageLocaleKey='en_US' LIMIT 1];
        System.runAs(sysAdminUser){
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram  LIMIT 1].Core_MDF_Technical_Program_Name__c;
            Account intelAccount = [Select id from Account where Name = 'Test Acc New 1'];
            
            /*Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                                               Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c,Core_MDF_Claim_Field_API_Name__c
                                                                                                                                               FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                                               WHERE Core_MDF_Channel_program__c = :channelProgramName
                                                                                                                                               AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);*/
            Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c> metadataIdToRecordMap = new Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c>([SELECT Id, Name, Core_MDF_Field_2_txt__c, Core_MDF_Field_1_txt__c, Core_MDF_Sort_Order_Nbr__c, Core_MDF_Field_3_txt__c, Core_MDF_Checkbox_Field_1_Ind__c, Core_MDF_Name_Criteria__c, Core_MDF_Program__c 
                                                                                                                                         FROM Core_MDF_CCP_Custom_Metadata_Utility__c 
                                                                                                                                         WHERE Core_MDF_Program__c = :channelProgramName 
                                                                                                                                         AND Core_MDF_Sub_Category__c =:Label.Core_MDF_PFCText  
                                                                                                                                         AND Core_MDF_Category__c = 'bulk claim template' ORDER BY Core_MDF_Sort_Order_Nbr__c]);

            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                     FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                     WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];
            
            Core_MDF_Claim_Batch__c claimbatchinstance = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c LIMIT 1];
            PartnerFundRequest activityRecord = [Select id, Title, Core_MDF_Activity_Number__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where Title = 'test' Limit 1];
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c, Core_MDF_Bank_Status__c, Core_MDF_Program__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];
            ChannelProgram channelProgram = [Select id from ChannelProgram where Name = 'Client'];

            
            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today();
            Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
            String dateString = dt.format(dateFormatString);
            
            String csvStringForFailedRecord2 = 'Claim Name,Activity #,"Execution Start Date (YYYY-MM-DD)","Execution End Date (YYYY-MM-DD)","Country","Activity Subtype","Media Vehicle",Bank,Bank Account Number(last 4 digits),"Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Dell DCF Claim from Bulk 1,' 
            + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,701189,' + '1234567895'+ ',' + '1246'+ ',' + dateString + ',1234,USD,10,0,0,Dell DCF Bulk Claim1';
            Blob myBlob2 = Blob.valueof(csvStringForFailedRecord2);
            Test.startTest();
            List<Core_MDF_Claim_Batch_Stage__c> listOfbatchStagerecords = Core_MDF_BulkClaimServerController.validateDataType(metadataIdToRecordMap,myBlob2,intelAccount.Id,channelProgram.Id);
            Core_MDF_BulkClaimServerController.insertClaimBatchStageRecords(listOfbatchStagerecords,claimbatchinstance,recordType);
            
            Core_MDF_Claim_Batch_Stage__c failedStageRecord2 = [SELECT id,Core_MDF_Claim_Reference_Nbr__c,Core_MDF_Is_Duplicate_ind__c,Core_MDF_Create_Duplicate_ind__c,Core_MDF_Ad_Run_End_Dt__c, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c from Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id AND Core_MDF_Is_Duplicate_ind__c =FALSE /*AND  Core_MDF_Media_Vehicle_txt__c='701189'*/ limit 1];
            failedStageRecord2.Core_MDF_Media_Vehicle_txt__c = null;
            database.update(failedStageRecord2);
            failedStageRecord2 = [SELECT Core_MDF_Claim_Reference_Nbr__c FROM Core_MDF_Claim_Batch_Stage__c WHERE ID =: failedStageRecord2.Id LIMIT 1];
            assert.areEqual(null,failedStageRecord2.Core_MDF_Claim_Reference_Nbr__c);
            
            String csvString3 = 'Claim Name,Activity #,"Execution Start Date (YYYY-MM-DD)","Execution End Date (YYYY-MM-DD)","Country","Activity Subtype","Media Vehicle,Bank","Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Dell DCF Claim from Bulk 1,' + activityRecord.Core_MDF_Activity_Number__c + ',' + '18/02/2019' + ',' + dateString + ',India,Email,701189,' + null+ ',' + dateString + ',1234,USD,10,0,0,Dell DCF Bulk Claim1';
            Blob myBlob3 = Blob.valueof(csvString3);
            String base64Data = EncodingUtil.base64Encode(myBlob3);
            String fileName = 'MyName';
            String uiExceptionError = Core_MDF_BulkClaimServerController.parseFile(base64Data,fileName,channelProgram.Id);
            assert.areEqual(False,uiExceptionError.contains('UIExceptionError'));
            Test.stopTest();
        }
        
    }
    // To Create Claim from batch stage
    @isTest static void testFetchClaimRecType() {
        
        
        User sysAdminUser = [SELECT Id,LanguageLocaleKey FROM USER WHERE LanguageLocaleKey = 'en_US' LIMIT 1];
        System.runAs(sysAdminUser){
            
            List<Account> accounts = [Select Id, Name, Core_MDF_CoMarketing_Ultimate_Account__c  from Account where Name in ('Test Acc New 2','Test Acc New 3')];
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c, Core_MDF_Bank_Account_Number__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];
            List<PartnerFundRequest> pfrList = [Select id, Title, Core_MDF_Activity_Number__c,ChannelPartner.Core_MDF_Active_Ind__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Fund_Request_Status__c,Core_MDF_Country_nm__c,Core_MDF_ActivityCategory__c,Core_MDF_Activity_Types__c,Core_MDF_Activity_SubType_nm__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Program__c  from PartnerFundRequest where ChannelPartnerId = :accounts limit 2];
            
            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today();
            Date wdate = Date.today().addDays(-1);
            Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
            Datetime wrongdt = Datetime.newInstance(wdate.year(), wdate.month(),wdate.day());
            String dateString = dt.format(dateFormatString);
            String wrongDateString = wrongdt.format(dateFormatString);
            
            String csvString = 'Claim Name,Activity #,"Execution Start Date  (YYYY-MM-DD)","Execution End Date (YYYY-MM-DD)","Country","Activity Subtype","Media Vehicle,Bank,Bank Account Number(last 4 digits)","Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Dell DCF Claim from Bulk 1,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,Krishna1011,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',1234,USD,10,0,0,Dell DCF Bulk Claim1 \n Dell DCF Claim from Bulk 1,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString +',India,Email,99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',1234,USD,10,0,0,Dell DCF Bulk Claim1 \n Dell DCF Claim from Bulk 3,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString +',1234,USD,10,0,0,Dell DCF Bulk Claim1';
            csvString = csvString + '\n Dell DCF Claim from Bulk 4,' + pfrList[1].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email' +',Krishna1014,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',12345,USD,50,0,0,Dell DCF Bulk Claim1' ;
            Blob myBlob = Blob.valueof(csvString);
            String base64Data = EncodingUtil.base64Encode(myBlob);
            String fileName = 'fileName.csv';
            
            ChannelProgram channelProgram = [Select id,Name from ChannelProgram where Name = 'Client'];
            Test.startTest();    
            Core_MDF_BulkClaimServerController.fetchRecordTypeMetaData();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            Core_MDF_BulkClaimServerController.fetchAvailActSubTypeValues(channelProgram.Name);
            List<String> countryList = Core_MDF_BulkClaimServerController.fetchAvailCountries();
            assert.isNotNull(countryList);
            List<Core_MDF_BulkClaimServerController.PickListWrapper> currencyList = Core_MDF_BulkClaimServerController.fetchAvailCurrencies();           
            assert.isNotNull(currencyList);
            
            Core_MDF_Claim_Batch__c claimbatchinstance = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c LIMIT 1];
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram WHERE Id =:channelProgram.Id LIMIT 1].Core_MDF_Technical_Program_Name__c;
            /*Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                                               Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c,Core_MDF_Claim_Field_API_Name__c
                                                                                                                                               FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                                               WHERE Core_MDF_Channel_program__c = :channelProgramName
                                                                                                                                               AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);*/
            Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c> metadataIdToRecordMap = new Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c>([SELECT Id, Name, Core_MDF_Field_2_txt__c, Core_MDF_Field_1_txt__c, Core_MDF_Sort_Order_Nbr__c, Core_MDF_Field_3_txt__c, Core_MDF_Checkbox_Field_1_Ind__c, Core_MDF_Name_Criteria__c, Core_MDF_Program__c 
                                                                                                                                         FROM Core_MDF_CCP_Custom_Metadata_Utility__c 
                                                                                                                                         WHERE Core_MDF_Program__c = :channelProgramName 
                                                                                                                                         AND Core_MDF_Sub_Category__c =:Label.Core_MDF_PFCText  
                                                                                                                                         AND Core_MDF_Category__c = 'bulk claim template' ORDER BY Core_MDF_Sort_Order_Nbr__c]);

            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                     FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                     WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];
            
            
            List<Core_MDF_Claim_Batch_Stage__c> listOfbatchStagerecords = Core_MDF_BulkClaimServerController.validateDataType(metadataIdToRecordMap,myBlob,accounts[0].Core_MDF_CoMarketing_Ultimate_Account__c,channelProgram.Id);
            Core_MDF_BulkClaimServerController.insertClaimBatchStageRecords(listOfbatchStagerecords,claimbatchinstance,recordType);
            String jobId = System.schedule('claimbsvd111','0 15 * * * ?', new Core_MDF_ClaimInsert_Schedule(System.now()));
            assert.areEqual(bankRecord.Core_MDF_Supplier_Number__c,'1231231230'); 
        }
        
    }
    @isTest static void testActivityUpdate() {
        
        Test.startTest();
        User sysAdminUser = [SELECT Id,LanguageLocaleKey FROM USER WHERE LanguageLocaleKey = 'en_US' LIMIT 1];
        System.runAs(sysAdminUser){
            
            List<Account> accounts = [Select Id, Name from Account where Name in ('Test Acc New 1','Test Acc New 2','Test Acc New 4','Test Acc New 5')];
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];
            List<PartnerFundRequest> pfrList = [Select id, Title, Core_MDF_Activity_Number__c,ChannelPartner.Core_MDF_Active_Ind__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Fund_Request_Status__c, Core_MDF_Start_Date__c from PartnerFundRequest where ChannelPartnerId In :accounts limit 3];
            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today();
            Date wdate = Date.today().addDays(-1);
            Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
            Datetime wrongdt = Datetime.newInstance(wdate.year(), wdate.month(),wdate.day());
            String dateString = dt.format(dateFormatString);
            String wrongDateString = wrongdt.format(dateFormatString);
            
            String csvString = 'Claim Name,Activity #,"Execution Start Date  (YYYY-MM-DD)","Execution End Date (YYYY-MM-DD)","Country","Activity Subtype",Media Vehicle,Bank,"Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Dell DCF Claim from Bulk 1,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',Krishna1011,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim from Bulk 7 Claim1 \n Dell DCF Claim from Bulk 1,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim from Bulk 7 Claim1 \n Dell DCF Claim from Bulk 3,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim from Bulk 7 Claim1';
            csvString = csvString + '\n Dell DCF Claim from Bulk 4,' + pfrList[1].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,Krishna1015,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim from Bulk 7 Claim1' ;
            csvString = csvString + '\n Dell DCF Claim from Bulk 5,' + pfrList[1].Core_MDF_Activity_Number__c + ',' + wrongDateString + ',' + dateString + ',India,Email,Krishna1016,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim from Bulk 7 Claim1' ;
            csvString = csvString + '\n Dell DCF Claim from Bulk 6,' + pfrList[2].Core_MDF_Activity_Number__c + ',' + wrongDateString + ',' + dateString + ',India,Email,Krishna1017,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim from Bulk 7 Claim1' ;
            csvString = csvString + '\n Dell DCF Claim from Bulk 7,' + pfrList[2].Core_MDF_Activity_Number__c + ',' + wrongDateString + ',' + dateString + ',India,Email,Krishna1018,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim from Bulk 7 Claim1' ;
            Blob myBlob = Blob.valueof(csvString);
            String base64Data = EncodingUtil.base64Encode(myBlob);
            String fileName = 'fileName.csv';
            
            ChannelProgram channelProgram = [Select id from ChannelProgram where Name = 'Client'];
            
            Core_MDF_BulkClaimServerController.fetchRecordTypeMetaData();
            
            Core_MDF_Claim_Batch__c claimbatchinstance = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c LIMIT 1];
            
            
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram WHERE Id =:channelProgram.Id LIMIT 1].Core_MDF_Technical_Program_Name__c;
            /*Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                                               Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c
                                                                                                                                               FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                                               WHERE Core_MDF_Channel_program__c = :channelProgramName
                                                                                                                                               AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);*/
            Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c> metadataIdToRecordMap = new Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c>([SELECT Id, Name, Core_MDF_Field_2_txt__c, Core_MDF_Field_1_txt__c, Core_MDF_Sort_Order_Nbr__c, Core_MDF_Field_3_txt__c, Core_MDF_Checkbox_Field_1_Ind__c, Core_MDF_Name_Criteria__c, Core_MDF_Program__c FROM Core_MDF_CCP_Custom_Metadata_Utility__c 
                                                                                                                                         WHERE Core_MDF_Program__c = :channelProgramName 
                                                                                                                                         AND Core_MDF_Sub_Category__c =:Label.Core_MDF_PFCText 
                                                                                                                                         AND Core_MDF_Category__c = 'bulk claim template' ORDER BY Core_MDF_Sort_Order_Nbr__c]);

            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                     FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                     WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];
            
            
            List<Core_MDF_Claim_Batch_Stage__c> claimBatchStageRecordList = new List <Core_MDF_Claim_Batch_Stage__c>();
            Core_MDF_Claim_Batch_Stage__c claimStageInstance = new Core_MDF_Claim_Batch_Stage__c();
            claimStageInstance.Core_MDF_Activity_Nbr__c=pfrList[0].Core_MDF_Activity_Number__c; 
            claimStageInstance.Core_MDF_Ad_Run_End_Dt__c=System.today();
            claimStageInstance.Core_MDF_Ad_Run_Start_Dt__c=System.today();
            claimStageInstance.Core_MDF_Bank_Nbr__c=bankRecord.Core_MDF_Supplier_Number__c;
            claimStageInstance.Core_MDF_Claim_Comment_txt__c='test';
            claimStageInstance.Core_MDF_Claim_Nm__c='test1';
            claimStageInstance.Core_MDF_Batch_ID__c=claimbatchinstance.Id;
            claimStageInstance.Core_MDF_Inv_Receipt_Cur_Cd__c='USD';
            claimStageInstance.Core_MDF_Inv_Receipt_Dt__c=System.today();
            claimStageInstance.Core_MDF_Inv_Receipt_Nbr__c='1234';
            claimStageInstance.Core_MDF_Media_Vehicle_txt__c='test1';
            claimStageInstance.Core_MDF_Non_Reimbursable_Amt__c=0;
            claimStageInstance.Core_MDF_Taxes_Local_Amt__c=0;
            claimStageInstance.Core_MDF_Total_Amt__c=10;
            claimStageInstance.Core_MDF_Country_Location_nm__c = 'India';
            claimStageInstance.Core_MDF_Activity_SubType_nm__c = 'email';
            claimStageInstance.RecordTypeId= Schema.SObjectType.Core_MDF_Claim_Batch_Stage__c.getRecordTypeInfosByDeveloperName().get(recordType.Core_MDF_ClaimStage_RecordType_txt__c).getRecordTypeId();
            
            
            Core_MDF_Claim_Batch_Stage__c claimStageInstance2 = new Core_MDF_Claim_Batch_Stage__c();
            claimStageInstance2.Core_MDF_Activity_Nbr__c=pfrList[1].Core_MDF_Activity_Number__c; 
            claimStageInstance2.Core_MDF_Ad_Run_End_Dt__c=System.today();
            claimStageInstance2.Core_MDF_Ad_Run_Start_Dt__c=System.today().adddays(1);
            claimStageInstance2.Core_MDF_Bank_Nbr__c=bankRecord.Core_MDF_Supplier_Number__c;
            claimStageInstance2.Core_MDF_Claim_Comment_txt__c='test';
            claimStageInstance2.Core_MDF_Claim_Nm__c='test1';
            claimStageInstance2.Core_MDF_Batch_ID__c=claimbatchinstance.Id;
            claimStageInstance2.Core_MDF_Inv_Receipt_Cur_Cd__c='USD';
            claimStageInstance2.Core_MDF_Inv_Receipt_Dt__c=System.today();
            claimStageInstance2.Core_MDF_Inv_Receipt_Nbr__c='1234';
            claimStageInstance2.Core_MDF_Media_Vehicle_txt__c='test1';
            claimStageInstance2.Core_MDF_Non_Reimbursable_Amt__c=0;
            claimStageInstance2.Core_MDF_Taxes_Local_Amt__c=0;
            claimStageInstance2.Core_MDF_Total_Amt__c=10;
            claimStageInstance2.Core_MDF_Country_Location_nm__c = 'India';
            claimStageInstance2.Core_MDF_Activity_SubType_nm__c = 'email';
            claimStageInstance2.RecordTypeId= Schema.SObjectType.Core_MDF_Claim_Batch_Stage__c.getRecordTypeInfosByDeveloperName().get(recordType.Core_MDF_ClaimStage_RecordType_txt__c).getRecordTypeId();
            
            
            Core_MDF_Claim_Batch_Stage__c claimStageInstance3 = new Core_MDF_Claim_Batch_Stage__c();
            claimStageInstance3.Core_MDF_Activity_Nbr__c=pfrList[1].Core_MDF_Activity_Number__c; 
            claimStageInstance3.Core_MDF_Ad_Run_End_Dt__c=System.today();
            claimStageInstance3.Core_MDF_Ad_Run_Start_Dt__c=System.today();
            claimStageInstance3.Core_MDF_Bank_Nbr__c=bankRecord.Core_MDF_Supplier_Number__c;
            claimStageInstance3.Core_MDF_Claim_Comment_txt__c='test';
            claimStageInstance3.Core_MDF_Claim_Nm__c='test1';
            claimStageInstance3.Core_MDF_Batch_ID__c=claimbatchinstance.Id;
            claimStageInstance3.Core_MDF_Inv_Receipt_Cur_Cd__c='USD';
            claimStageInstance3.Core_MDF_Inv_Receipt_Dt__c=System.today();
            claimStageInstance3.Core_MDF_Inv_Receipt_Nbr__c='1234';
            claimStageInstance3.Core_MDF_Media_Vehicle_txt__c='test2';
            claimStageInstance3.Core_MDF_Non_Reimbursable_Amt__c=0;
            claimStageInstance3.Core_MDF_Taxes_Local_Amt__c=0;
            claimStageInstance3.Core_MDF_Total_Amt__c=10;
            claimStageInstance3.Core_MDF_Country_Location_nm__c = 'India';
            claimStageInstance3.Core_MDF_Activity_SubType_nm__c = 'email';
            claimStageInstance3.RecordTypeId= Schema.SObjectType.Core_MDF_Claim_Batch_Stage__c.getRecordTypeInfosByDeveloperName().get(recordType.Core_MDF_ClaimStage_RecordType_txt__c).getRecordTypeId();
            
            Core_MDF_Claim_Batch_Stage__c claimStageInstance5 = new Core_MDF_Claim_Batch_Stage__c();
            claimStageInstance5.Core_MDF_Activity_Nbr__c=pfrList[1].Core_MDF_Activity_Number__c; 
            claimStageInstance5.Core_MDF_Ad_Run_End_Dt__c=System.today();
            claimStageInstance5.Core_MDF_Ad_Run_Start_Dt__c=System.today();
            claimStageInstance5.Core_MDF_Bank_Nbr__c=bankRecord.Core_MDF_Supplier_Number__c;
            claimStageInstance5.Core_MDF_Claim_Comment_txt__c='test';
            claimStageInstance5.Core_MDF_Claim_Nm__c='test1';
            claimStageInstance5.Core_MDF_Batch_ID__c=claimbatchinstance.Id;
            claimStageInstance5.Core_MDF_Inv_Receipt_Cur_Cd__c='USD';
            claimStageInstance5.Core_MDF_Inv_Receipt_Dt__c=System.today();
            claimStageInstance5.Core_MDF_Inv_Receipt_Nbr__c='1234';
            claimStageInstance5.Core_MDF_Media_Vehicle_txt__c='test2';
            claimStageInstance5.Core_MDF_Non_Reimbursable_Amt__c=0;
            claimStageInstance5.Core_MDF_Taxes_Local_Amt__c=0;
            claimStageInstance5.Core_MDF_Total_Amt__c=10;
            claimStageInstance5.Core_MDF_Country_Location_nm__c = 'India';
            claimStageInstance5.Core_MDF_Activity_SubType_nm__c = 'email';
            claimStageInstance5.RecordTypeId= Schema.SObjectType.Core_MDF_Claim_Batch_Stage__c.getRecordTypeInfosByDeveloperName().get(recordType.Core_MDF_ClaimStage_RecordType_txt__c).getRecordTypeId();
            
            
            Core_MDF_Claim_Batch_Stage__c claimStageInstance4 = new Core_MDF_Claim_Batch_Stage__c();
            claimStageInstance4.Core_MDF_Activity_Nbr__c=pfrList[2].Core_MDF_Activity_Number__c; 
            claimStageInstance4.Core_MDF_Ad_Run_End_Dt__c=System.today();
            claimStageInstance4.Core_MDF_Ad_Run_Start_Dt__c=System.today().adddays(1);
            claimStageInstance4.Core_MDF_Bank_Nbr__c=bankRecord.Core_MDF_Supplier_Number__c;
            claimStageInstance4.Core_MDF_Claim_Comment_txt__c='test';
            claimStageInstance4.Core_MDF_Claim_Nm__c='test1';
            claimStageInstance4.Core_MDF_Batch_ID__c=claimbatchinstance.Id;
            claimStageInstance4.Core_MDF_Inv_Receipt_Cur_Cd__c='USD';
            claimStageInstance4.Core_MDF_Inv_Receipt_Dt__c=System.today();
            claimStageInstance4.Core_MDF_Inv_Receipt_Nbr__c='1234';
            claimStageInstance4.Core_MDF_Media_Vehicle_txt__c='test312345655';
            claimStageInstance4.Core_MDF_Non_Reimbursable_Amt__c=0;
            claimStageInstance4.Core_MDF_Taxes_Local_Amt__c=0;
            claimStageInstance4.Core_MDF_Total_Amt__c=10;
            claimStageInstance4.Core_MDF_Country_Location_nm__c = 'India';
            claimStageInstance4.Core_MDF_Activity_SubType_nm__c = 'email';
            claimStageInstance4.RecordTypeId= Schema.SObjectType.Core_MDF_Claim_Batch_Stage__c.getRecordTypeInfosByDeveloperName().get(recordType.Core_MDF_ClaimStage_RecordType_txt__c).getRecordTypeId();
            
            claimBatchStageRecordList.add(claimStageInstance);
            claimBatchStageRecordList.add(claimStageInstance2);
            claimBatchStageRecordList.add(claimStageInstance3);
            claimBatchStageRecordList.add(claimStageInstance4);
            claimBatchStageRecordList.add(claimStageInstance5);
            insert claimBatchStageRecordList;
            
            //PartnerFundRequest testPartnerFundRequest = [Select Id,Core_MDF_Start_Date__c from PartnerfundRequest limit 1];
            //Core_MDF_Bank__c bank = [Select id, Name, Core_MDF_Supplier_Number__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];

            //List<PartnerFundClaim> pfc = [select Core_MDF_Claim_Batch_Stage__r.Core_MDF_Media_Vehicle_txt__c from PartnerFundClaim limit 1/*where Core_MDF_Claim_Batch_Stage__r.Core_MDF_Media_Vehicle_txt__c='test312345655'*/];
            PartnerFundClaim testClaim = Core_MDF_CCP_TestDataUtility.createClaim('Dell DCF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                              pfrList[0].Id, 
                                                                              pfrList[0].Core_MDF_Start_Date__c, pfrList[0].Core_MDF_Start_Date__c, 
                                                                              1234, 
                                                                              System.today(), bankRecord.ID, false);
        	testClaim.Core_MDF_Media_Vehicle__c = 'Kri1011';
        	testClaim.Core_MDF_Currency__c = 'USD';
        	testClaim.Core_MDF_Invoice_Number__c = '1234';
        	testClaim.Core_MDF_Total_Invoice_Amount_Local__c = 10;
        	testClaim.Core_MDF_Taxes_Local__c = 0;
        	testClaim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            testClaim.Core_MDF_Claim_Batch_Stage__c = claimBatchStageRecordList[0].Id;
            List<PartnerFundClaim> pfc = new List<PartnerFundClaim>();
            pfc.add(testClaim);
            Core_MDF_ClaimStage_ServiceHandler.stageAndClaimRecWrapper wraplist = new Core_MDF_ClaimStage_ServiceHandler.stageAndClaimRecWrapper();            
            Core_MDF_ClaimStage_ServiceHandler.stageAndClaimRecWrapper wrapInstance = new Core_MDF_ClaimStage_ServiceHandler.stageAndClaimRecWrapper();
            wrapInstance = Core_MDF_ClaimStage_ServiceHandler.handleDuplicateClaimsOnUpdate(pfc,wrapInstance);
            //wraplist.add(pfc);
            wraplist.nonduplicateClaims.addAll(pfc);
            Core_MDF_BatchClaimHelper.insertClaimsAndUpdateClaimStageRecords(wraplist);
            wraplist.failedStageRecordsList.add(claimBatchStageRecordList[2]);
            Core_MDF_BatchClaimHelper.insertClaimsAndUpdateClaimStageRecords(wraplist);
            assert.areEqual(claimStageInstance5.Core_MDF_Media_Vehicle_txt__c,'test2');
            Database.executeBatch(new Core_MDF_Batch_ClaimInsert(pfc), 5);
            Set<Id> allocationIds = new Map<Id, PartnerFundAllocation>(
    [SELECT Id FROM PartnerFundAllocation]).keySet();
            List<Id> claimsList1 = new List<Id>(new Map<Id,PartnerFundClaim>([SELECT id, Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Audit_Hold__c,Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Criteria_Hold_Ind__c, Core_MDF_Document_Hold_Ind__c, Core_MDF_Status__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim LIMIT 10]).keySet());
            List<PartnerFundClaim> claimsList2 = new Map<Id,PartnerFundClaim>([SELECT id, Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Audit_Hold__c,Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Criteria_Hold_Ind__c, Core_MDF_Document_Hold_Ind__c, Core_MDF_Status__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim LIMIT 10]).values();
            //Core_MDF_Queueable_Process_PAF_Claim claimqueueable = new Core_MDF_Queueable_Process_PAF_Claim(allocationIds);
            Id jobId = System.enqueueJob(new Core_MDF_Queueable_Process_PAF_Claim(allocationIds));
            Core_MDF_Batch_UpdateStatusOnClaim batch = new Core_MDF_Batch_UpdateStatusOnClaim(claimsList1);
            Database.executeBatch(new Core_MDF_Batch_UpdateStatusOnClaim(claimsList1),5);
            batch.execute(null,claimsList2);
        Test.stopTest();
        }
            
    }//Test Method to test Successful Insertion and Duplicate Record Insertion of Claim Stage Records
    @isTest static void testStageClaimErrorRecord() {
        
        
        User sysAdminUser = [SELECT Id,LanguageLocaleKey FROM USER WHERE LanguageLocaleKey = 'en_US' LIMIT 1];
        System.runAs(sysAdminUser){
            Test.startTest();  
            List<Account> accounts = [Select Id, Name from Account where Name in ('Test Acc New 2','Test Acc New 3')];
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];
            List<PartnerFundRequest> pfrList = [Select id, Title, Core_MDF_Activity_Number__c,ChannelPartner.Core_MDF_Active_Ind__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where ChannelPartnerId in :accounts limit 2];
            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today().adddays(2);
            Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
            String dateString = dt.format(dateFormatString);
            
            String csvString = 'Claim Name,Activity #,"Execution Start Date  (YYYY-MM-DD)","Execution End Date (YYYY-MM-DD)","Country","Activity Subtype",Media Vehicle,Bank,"Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Dell DCF Claim from Bulk 1,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',Krishna1011,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1 \n Dell DCF Claim from Bulk 1,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',Krishna1011,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1 \n Dell DCF Claim from Bulk 1,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1 \n Dell DCF Claim from Bulk 3,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1';
            csvString = csvString + '\n Dell DCF Claim from Bulk 4,' + pfrList[1].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,Krishna12344,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            csvString = csvString + '\n Dell DCF Claim from Bulk 4,' + pfrList[1].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,Krishna12344,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            Blob myBlob = Blob.valueof(csvString);
            String base64Data = EncodingUtil.base64Encode(myBlob);
            String fileName = 'fileName.csv';
            
            ChannelProgram channelProgram = [Select id from ChannelProgram where Name = 'Client'];
            
            Core_MDF_BulkClaimServerController.fetchRecordTypeMetaData();
            
            Core_MDF_Claim_Batch__c claimbatchinstance1 = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c LIMIT 1];
            
            
            
            String channelProgramName1 = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram WHERE Id =:channelProgram.Id LIMIT 1].Core_MDF_Technical_Program_Name__c;
            /*Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap1 = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                                                Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c
                                                                                                                                                FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                                                WHERE Core_MDF_Channel_program__c = :channelProgramName1
                                                                                                                                                AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);*/
            Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c> metadataIdToRecordMap = new Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c>([SELECT Id, Name, Core_MDF_Field_2_txt__c, Core_MDF_Field_1_txt__c, Core_MDF_Sort_Order_Nbr__c, Core_MDF_Field_3_txt__c, Core_MDF_Checkbox_Field_1_Ind__c, Core_MDF_Name_Criteria__c, Core_MDF_Program__c FROM Core_MDF_CCP_Custom_Metadata_Utility__c 
                                                                                                                                         WHERE Core_MDF_Program__c = :channelProgramName1 
                                                                                                                                         AND Core_MDF_Sub_Category__c =:Label.Core_MDF_PFCText  
                                                                                                                                         AND Core_MDF_Category__c = 'bulk claim template' ORDER BY Core_MDF_Sort_Order_Nbr__c]);

            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType1 = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                      FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                      WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName1 LIMIT 1];
            
            List<Core_MDF_Claim_Batch_Stage__c> claimBatchStageRecordList = new List <Core_MDF_Claim_Batch_Stage__c>();
            Core_MDF_Claim_Batch_Stage__c claimStageInstance4 = new Core_MDF_Claim_Batch_Stage__c();
            claimStageInstance4.Core_MDF_Activity_Nbr__c=pfrList[1].Core_MDF_Activity_Number__c; 
            claimStageInstance4.Core_MDF_Ad_Run_End_Dt__c=System.today();
            claimStageInstance4.Core_MDF_Ad_Run_Start_Dt__c=System.today().adddays(1);
            claimStageInstance4.Core_MDF_Bank_Nbr__c=bankRecord.Core_MDF_Supplier_Number__c;
            claimStageInstance4.Core_MDF_Claim_Comment_txt__c='test';
            claimStageInstance4.Core_MDF_Claim_Nm__c='test1';
            claimStageInstance4.Core_MDF_Batch_ID__c=claimbatchinstance1.Id;
            claimStageInstance4.Core_MDF_Inv_Receipt_Cur_Cd__c='USD';
            claimStageInstance4.Core_MDF_Inv_Receipt_Dt__c=System.today();
            claimStageInstance4.Core_MDF_Inv_Receipt_Nbr__c='1234';
            claimStageInstance4.Core_MDF_Media_Vehicle_txt__c='test312345655';
            claimStageInstance4.Core_MDF_Non_Reimbursable_Amt__c=0;
            claimStageInstance4.Core_MDF_Taxes_Local_Amt__c=0;
            claimStageInstance4.Core_MDF_Total_Amt__c=0;
            claimStageInstance4.Core_MDF_Processing_Status_Nm__c = 'Submitted';
            claimStageInstance4.Core_MDF_Retry_Count_Nbr__c = 0;
            claimStageInstance4.RecordTypeId= Schema.SObjectType.Core_MDF_Claim_Batch_Stage__c.getRecordTypeInfosByDeveloperName().get(recordType1.Core_MDF_ClaimStage_RecordType_txt__c).getRecordTypeId();
            claimStageInstance4.Core_MDF_Country_Location_nm__c = 'INDIA';
            claimStageInstance4.Core_MDF_Activity_SubType_nm__c = 'email';
            claimStageInstance4.Core_MDF_Request_Id__c = pfrList[1].id;
            
            claimBatchStageRecordList.add(claimStageInstance4);
            
            insert claimBatchStageRecordList;
            Core_MDF_ClaimInsert_Batch c1 = new Core_MDF_ClaimInsert_Batch();
            Database.executeBatch(c1,200);
            claimStageInstance4.Core_MDF_Media_Vehicle_txt__c = 'test316745655';
            Database.update(claimStageInstance4);
            
            Core_MDF_ClaimInsert_Batch c = new Core_MDF_ClaimInsert_Batch();
            Database.executeBatch(c,200);
            
            try{Core_MDF_BulkClaimServerController.parseFile(base64Data, fileName, channelProgram.Id);}catch(Exception e){}
            Test.stopTest();
            assert.areEqual(bankRecord.Core_MDF_Supplier_Number__c,'1231231230');
        }
  
    }
    
    
    
    @isTest static void testStageClaimFlowRecord() {
        
        
        User sysAdminUser = [SELECT Id,LanguageLocaleKey FROM USER WHERE LanguageLocaleKey = 'en_US' LIMIT 1];
        System.runAs(sysAdminUser){
            
            List<Account> accounts = [Select Id, Name from Account where Name in ('Test Acc New 2','Test Acc New 3')];
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];
            List<PartnerFundRequest> pfrList = [Select id, Title, Core_MDF_Activity_Number__c,ChannelPartner.Core_MDF_Active_Ind__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where ChannelPartnerId in :accounts limit 2];
            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today();
            Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
            String dateString = dt.format(dateFormatString);
            
            String csvString = 'Claim Name,Activity #,"Execution Start Date  (YYYY-MM-DD)","Execution End Date (YYYY-MM-DD)","Country","Activity Subtype",Media Vehicle,Bank,"Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Dell DCF Claim from Bulk 1,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',Krishna1011,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1 \n Dell DCF Claim from Bulk 1,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1 \n Dell DCF Claim from Bulk 3,' + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1';
            csvString = csvString + '\n Dell DCF Claim from Bulk 4,' + pfrList[1].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,Krishna12344,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            Blob myBlob = Blob.valueof(csvString);
            String base64Data = EncodingUtil.base64Encode(myBlob);
            String fileName = 'fileName.csv';
            
            ChannelProgram channelProgram = [Select id from ChannelProgram where Name = 'Client'];
            
            Core_MDF_BulkClaimServerController.fetchRecordTypeMetaData();
            
            Core_MDF_Claim_Batch__c claimbatchinstance1 = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c LIMIT 1];
            
            
            
            String channelProgramName1 = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram WHERE Id =:channelProgram.Id LIMIT 1].Core_MDF_Technical_Program_Name__c;
            /*Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap1 = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                                                Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c
                                                                                                                                                FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                                                WHERE Core_MDF_Channel_program__c = :channelProgramName1
                                                                                                                                                AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);*/
            Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c> metadataIdToRecordMap1 = new Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c>([SELECT Id,Core_MDF_Field_2_txt__c,Core_MDF_Field_1_txt__c,Core_MDF_Sort_Order_Nbr__c,
                                                                                                                                                Core_MDF_Field_3_txt__c, Core_MDF_Checkbox_Field_1_Ind__c
                                                                                                                                                FROM Core_MDF_CCP_Custom_Metadata_Utility__c
                                                                                                                                                WHERE Core_MDF_Category__c = 'bulk claim template' AND Core_MDF_Program__c = :channelProgramName1
                                                                                                                                                AND Core_MDF_Sub_Category__c =:Label.Core_MDF_PFCText]);
            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType1 = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                      FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                      WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName1 LIMIT 1];
            Test.startTest();  
            List<Core_MDF_Claim_Batch_Stage__c> claimBatchStageRecordList = new List<Core_MDF_Claim_Batch_Stage__c>();
            Core_MDF_Claim_Batch_Stage__c claimStageInstance4 = new Core_MDF_Claim_Batch_Stage__c();
            claimStageInstance4.Core_MDF_Activity_Nbr__c=pfrList[1].Core_MDF_Activity_Number__c; 
            claimStageInstance4.Core_MDF_Ad_Run_End_Dt__c=System.today();
            claimStageInstance4.Core_MDF_Ad_Run_Start_Dt__c=System.today().adddays(1);
            claimStageInstance4.Core_MDF_Bank_Nbr__c=bankRecord.Core_MDF_Supplier_Number__c;
            claimStageInstance4.Core_MDF_Request_Id__c ='';
            claimStageInstance4.Core_MDF_Claim_Comment_txt__c='test';
            claimStageInstance4.Core_MDF_Claim_Nm__c='test1';
            claimStageInstance4.Core_MDF_Batch_ID__c=claimbatchinstance1.Id;
            claimStageInstance4.Core_MDF_Inv_Receipt_Cur_Cd__c='USD';
            claimStageInstance4.Core_MDF_Inv_Receipt_Dt__c=System.today();
            claimStageInstance4.Core_MDF_Inv_Receipt_Nbr__c='1234';
            claimStageInstance4.Core_MDF_Media_Vehicle_txt__c='test312345655';
            claimStageInstance4.Core_MDF_Non_Reimbursable_Amt__c=0;
            claimStageInstance4.Core_MDF_Taxes_Local_Amt__c=0;
            claimStageInstance4.Core_MDF_Total_Amt__c=10;
            claimStageInstance4.Core_MDF_Processing_Status_Nm__c = 'Failed';
            claimStageInstance4.Core_MDF_Retry_Count_Nbr__c = 0;
            claimStageInstance4.RecordTypeId= Schema.SObjectType.Core_MDF_Claim_Batch_Stage__c.getRecordTypeInfosByDeveloperName().get(recordType1.Core_MDF_ClaimStage_RecordType_txt__c).getRecordTypeId();
            
            
            Core_MDF_Claim_Batch_Stage__c claimStageInstance5 = new Core_MDF_Claim_Batch_Stage__c();
            claimStageInstance5.Core_MDF_Activity_Nbr__c=pfrList[1].Core_MDF_Activity_Number__c; 
            claimStageInstance5.Core_MDF_Ad_Run_End_Dt__c=System.today();
            claimStageInstance5.Core_MDF_Ad_Run_Start_Dt__c=System.today().adddays(1);
            claimStageInstance5.Core_MDF_Bank_Nbr__c=bankRecord.Core_MDF_Supplier_Number__c;
            claimStageInstance5.Core_MDF_Claim_Comment_txt__c='test';
            claimStageInstance5.Core_MDF_Claim_Nm__c='test1';
            claimStageInstance5.Core_MDF_Batch_ID__c=claimbatchinstance1.Id;
            claimStageInstance5.Core_MDF_Inv_Receipt_Cur_Cd__c='USD';
            claimStageInstance5.Core_MDF_Inv_Receipt_Dt__c=System.today();
            claimStageInstance5.Core_MDF_Inv_Receipt_Nbr__c='1234';
            claimStageInstance5.Core_MDF_Media_Vehicle_txt__c='test312345655';
            claimStageInstance5.Core_MDF_Non_Reimbursable_Amt__c=0;
            claimStageInstance5.Core_MDF_Taxes_Local_Amt__c=0;
            claimStageInstance5.Core_MDF_Total_Amt__c=10;
            claimStageInstance5.Core_MDF_Processing_Status_Nm__c = 'Submitted';
            claimStageInstance5.Core_MDF_Retry_Count_Nbr__c = 0;
            claimStageInstance5.RecordTypeId= Schema.SObjectType.Core_MDF_Claim_Batch_Stage__c.getRecordTypeInfosByDeveloperName().get(recordType1.Core_MDF_ClaimStage_RecordType_txt__c).getRecordTypeId();
            claimBatchStageRecordList.add(claimStageInstance5);
            claimBatchStageRecordList.add(claimStageInstance4);
            Map<id,Core_MDF_Claim_Batch_Stage__c> cbmap = new  Map<id,Core_MDF_Claim_Batch_Stage__c>();
            insert claimBatchStageRecordList;
            for(Core_MDF_Claim_Batch_Stage__c cb:claimBatchStageRecordList){
                cbmap.put(cb.id,cb);
            }
            
            List<List<Core_MDF_Claim_Batch_Stage__c>>  claimBatchStageStatus = new List<List<Core_MDF_Claim_Batch_Stage__c>>();
            
            claimBatchStageStatus.add(claimBatchStageRecordList);
            Core_MDF_ClaimStage_ServiceHandler.isValidForReprocessing(claimBatchStageStatus);            
            Core_MDF_ClaimStage_ServiceHandler.isValidForUpdate(claimBatchStageRecordList,cbmap);
            try{Core_MDF_BulkClaimServerController.parseFile(base64Data, fileName, channelProgram.Id);}catch(Exception e){}
            Test.stopTest();
            assert.areEqual(bankRecord.Core_MDF_Supplier_Number__c,'1231231230');
        }
  
    }
    
    @isTest static void testJobLimitException() {
        
        
        User sysAdminUser = [SELECT Id,LanguageLocaleKey FROM USER WHERE LanguageLocaleKey = 'en_US' LIMIT 1];
        System.runAs(sysAdminUser){
            
            List<Account> accounts = [Select Id, Name,Core_MDF_CoMarketing_Ultimate_Account__c  from Account where Name in ('Test Acc New 2','Test Acc New 3','Test Acc New 4','Test Acc New 6','Test Acc New 7')];
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c, Core_MDF_Bank_Account_Number__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];
            List<PartnerFundRequest> pfrList = [Select id, Title, Core_MDF_Activity_Number__c,ChannelPartner.Core_MDF_Active_Ind__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where ChannelPartnerId In: accounts];
            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today();
            Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
            String dateString = dt.format(dateFormatString);
            Date d1 = Date.today().addDays(100);
            Datetime dt1 = Datetime.newInstance(d1.year(), d1.month(),d1.day());
            String dateString1 = dt1.format(dateFormatString);
            String csvString = 'Claim Name,Activity #,"Execution Start Date  (YYYY-MM-DD)","Execution End Date (YYYY-MM-DD)","Country","Activity Subtype",Media Vehicle,"Bank","Bank Account Number(last 4 digits)","Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Dell DCF Claim from Bulk 1,' 
            + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,Krishna1011,' + bankRecord.Core_MDF_Supplier_Number__c + ',' +  bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1 \n Dell DCF Claim from Bulk 1,' 
            + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' +  bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1 \n Dell DCF Claim from Bulk 3,' 
            + pfrList[0].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1';
            csvString = csvString + '\n Dell DCF Claim from Bulk 4,' + pfrList[1].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,online,' +bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',12345,USD,5,0,0,Claim1' ;
            //no activity subtype
            csvString = csvString + '\n Dell DCF Claim from Bulk 5,' + pfrList[1].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,,Krishna1,' +bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            //no country
            csvString = csvString + '\n Dell DCF Claim from Bulk 6,' + pfrList[2].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',,Email,Krishna1,' +bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            //no bank
            csvString = csvString + '\n Dell DCF Claim from Bulk 7,' + pfrList[2].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,Krishna1,'  + '8956232323'+ ',' + '1235' + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            //no country on activity
            csvString = csvString + '\n Dell DCF Claim from Bulk 8,' + pfrList[3].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,Krishna1,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c  + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            //country invalid for activity
            csvString = csvString + '\n Dell DCF Claim from Bulk 9 ,' + pfrList[2].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',GERMANY,Email,Krishna1,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            //Activity subtype invalid for activity
            csvString = csvString + '\n Dell DCF Claim from Bulk 10 ,' + pfrList[2].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,Krishna1,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            //no media vehicle
            csvString = csvString + '\n Dell DCF Claim from Bulk 11,' + pfrList[1].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',India,Email,Krishna1,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            //test claim insert
            csvString = csvString + '\n Dell DCF Claim from Bulk 4,' + pfrList[1].Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString1 + ',India,Email,online,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + bankRecord.Core_MDF_Bank_Account_Number__c + ',' + dateString + ',12345,USD,5,0,0,Claim1' ;
            Blob myBlob = Blob.valueof(csvString);
            String base64Data = EncodingUtil.base64Encode(myBlob);
            String fileName = 'fileName.csv';
            
            ChannelProgram channelProgram = [Select id from ChannelProgram where Name = 'Client'];
            Core_MDF_BulkClaimServerController.fetchRecordTypeMetaData();
            
            Core_MDF_Claim_Batch__c claimbatchinstance = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c LIMIT 1];
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram WHERE Id =:channelProgram.Id LIMIT 1].Core_MDF_Technical_Program_Name__c;
            /*Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                                               Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c,Core_MDF_Claim_Field_API_Name__c
                                                                                                                                               FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                                               WHERE Core_MDF_Channel_program__c = :channelProgramName
                                                                                                                                               AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);*/
            Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c> metadataIdToRecordMap = new Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c>([SELECT Id, Name, Core_MDF_Field_2_txt__c, Core_MDF_Field_1_txt__c, Core_MDF_Sort_Order_Nbr__c, Core_MDF_Field_3_txt__c, Core_MDF_Checkbox_Field_1_Ind__c, Core_MDF_Name_Criteria__c, Core_MDF_Program__c 
                                                                                                                                         FROM Core_MDF_CCP_Custom_Metadata_Utility__c 
                                                                                                                                         WHERE Core_MDF_Program__c = :channelProgramName 
                                                                                                                                         AND Core_MDF_Sub_Category__c =:Label.Core_MDF_PFCText  
                                                                                                                                         AND Core_MDF_Category__c = 'bulk claim template' ORDER BY Core_MDF_Sort_Order_Nbr__c]);

            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                     FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                     WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];
            
            Test.startTest();
            List<Core_MDF_Claim_Batch_Stage__c> listOfbatchStagerecords = Core_MDF_BulkClaimServerController.validateDataType(metadataIdToRecordMap,myBlob,accounts[0].Core_MDF_CoMarketing_Ultimate_Account__c,channelProgram.Id);
            Core_MDF_BulkClaimServerController.insertClaimBatchStageRecords(listOfbatchStagerecords,claimbatchinstance,recordType);
            
            
            //Core_MDF_Claim_Batch_Stage__c batchStage = [select id, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c from Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id AND Core_MDF_Processing_Status_Nm__c =: Label.Core_MDF_In_Progress_Status limit 1];
            List<Core_MDF_Claim_Batch_Stage__c> batchStageList = [select id, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c, Core_MDF_Bank_Account_Nbr__c from Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id/* AND Core_MDF_Processing_Status_Nm__c ='Submitted' limit 1 */];
            try{
                Database.update(batchStageList);
                Database.delete(batchStageList);
            }catch(Exception e)
            {assert.areEqual(e.getMessage().contains(Label.Core_MDF_Claim_Cannot_BeDeleted),True);}
            
            
            /*for(Integer i=0;i<100;i++) {
                System.schedule('testbulkClaim111'+i,'0 15 * * * ?', new Core_MDF_ClaimInsert_Schedule());
            }*/
            
            
            Core_MDF_ClaimInsert_Batch c = new Core_MDF_ClaimInsert_Batch(System.now());
            Database.executeBatch(c,200);            
            try{Core_MDF_BulkClaimServerController.parseFile(base64Data, fileName, channelProgram.Id);}catch(Exception e){}
        }
        Test.stopTest();       
    } 
    
    /***************************************************************************************************** 
    Method Name :    MockHttpResponseGenerator class
    Description:    This method is for mock callout of the http response
    Added By   :    Accenture - HP 
    Modified By:                      Date:10/05/2021                      Changes:None  
    ******************************************************************************************************/
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            assert.isNotNull(res);
            return res;
        
        }
    }
}