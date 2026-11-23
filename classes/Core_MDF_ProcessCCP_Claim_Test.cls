/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_Claim_Test
* Version     : 1.0 
* Created Date: 11-12-2018
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture-JV                    11/12/2018                    Created to test Partner Fund Claim Process functionality. 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_ProcessCCP_Claim_Test {
    /****************************************************************************************************************************************
Method Name:                                   setUpData
Description:                                   Created to prepare data for testing 
Added By:                                      Accenture – VD  -  18-Dec-2019
Modified By:           Date:                   Changes: 
Accenture – VD        18-Dec-2019              Refactored to follow best practice
*****************************************************************************************************************************************/   
    @TestSetup static void setUpData(){
        /*Core_MDF_Configuration__c picConfig = new Core_MDF_Configuration__c();
        picConfig.name='Core_MDF_SecondsToDelayPICBatch';
        picConfig.Core_MDF_Value__c='5';
        picConfig.Core_MDF_Category__c ='Claim';
        insert picConfig;*/
        
        List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing'}, true, false));       
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Allocation_Reservation','Bypass_GeoBased_Allocation_Sharing'}, true, false));   
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Bank_Check','Bypass_Bank_Internal_Sharing', 'Core_MDF_PFR_Field_Update_Bypass', 'Core_MDF_PFR_Bypass_EcosystemUpdate','Core_MDF_EnableATFFlagUpdateBatch', 'Core_MDF_BypassATFFlagUpdate', 'Amount_Zero_Update', 'Core_MDF_Bypass_IUPGMAssignment', 'Core_MDF_Bypass_ABTRev_ActCancel', 'Core_MDF_Bypass_ABTRev_ActManClosure', 'Core_MDF_Bypass_ABTRev_ActRejectRecall', 'Core_MDF_Bypass_ABTRev_ActAmtDecrease', 'Core_MDF_Bypass_Frwd_AutoBdgtTransfer', 'Core_MDF_Bypass_Before_FrwdBT','Core_MDF_BypassCancelPFR','Bypass_ShareActivityWithUsers', 'Bypass_ShareActivityWithAccNodeGroup', 'Core_MDF_Bypass_IntelOwnerNotification', 'Bypass_geoLeadApprovalProcess','Core_MDF_Bypass_PFREmailNotification', 'Core_MDF_Bypass_Rev_AutoBdgtTransfer',
                    'Bypass_Bank_External_Sharing','Bypass_Bank_Program_InActivation_Check','Bypass_Bank_ABM_Sharing','Bypass_MDF_Budget_Access_Validation','Bypass_MDF_Budget_Status_Validation',  'Core_MDF_Budget_Act_Date_Validation', 'Bypass_UniqueFieldPopulationAllocation', 'Bypass_SharePfaWithAccountExtGrp'}, true, false));
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing','ReleaseFundsOnActivity','ByPass_BlockLegacyBudgetCreation', 'byPassShareUnshareCampaignRecord', 'byPassCampaignAndRelatedRecords',  'Bypass_UpdateActivityFields', 'Bypass_ValidateActivityWithCampaign','Core_MDF_Bypass_ATFBatchUpdate', 'Bypass_PaymentsBulkAPISharing', 'byPass_Cancel_Activity', 'Bypass_ClaimAdjReq_Share_Internal_Usrs', 'Bypass_ClaimAdjReq_Share_External_Usrs', 'Bypass_Claim_AdjReq_Amount_Validation'}, true, false)); 
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Core_MDF_AccountOnBeforeInsert','Core_MDF_AccountOnBeforeUpdate','Core_MDF_AccountOnAfterInsert','Core_MDF_AccountOnAfterUpdate','Core_MDF_MultipleVCForSameProg', 'Core_MDF_UpdateHostRegionOnNodeAcc', 'Core_MDF_ValidatePFAChange',  'Core_MDF_IPA_Account_Region_Check', 'Core_MDF_createGroupForAccountNode','Core_MDF_ShareAccountsWithGroups', 'Core_MDF_Account_node_share', 'Core_MDF_UpdateHostRegionAfterVCUpdate', 'Core_MDF_ValidatePFAChangeOnAftrUpdt', 'Core_MDF_ProcessPGMCreation', 'Core_MDF_VirtualCorpInsertionLogic'}, true, false)); //Bypass_addDelayInPICBatch
                         

        Database.insert(transactions);
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', true);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        PermissionSet ccfPayAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
        PermissionSet claimSubmitterPS = [SELECT Id, Name From PermissionSet WHERE Name='Core_MDF_CCP_External_Claim_Submitter' LIMIT 1];
        PermissionSet rmfPayAdmPS = [SELECT Id, Name From PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Payment_Adm' LIMIT 1];
        PermissionSet ccfActMgr = [SELECT Id, Name From PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
        PermissionSet ccfBudgetLdr = [SELECT Id, Name From PermissionSet WHERE Name='Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
        PermissionSet retailFinMgr = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Finance_Manager' LIMIT 1];
        //PermissionSet ipaProgramAdmin = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_IPA_Program_Adm' LIMIT 1];
        

        Account accRecord = Core_MDF_CCP_TestDataUtility.createAccount ('Intel Test Account', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        accRecord.BillingCity = 'Test City';         
        accRecord.BillingCountry= 'AUS';
        accRecord.BillingStreet= 'Test Street'; 
        Database.insert(accRecord);   
        
        Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Dell Corporation', NULL,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        dellCorpAccount.BillingCity = 'Test City';         
        dellCorpAccount.BillingCountry= 'AUS';
        dellCorpAccount.BillingStreet= 'Test Street';
        dellCorpAccount.BillingState= 'TAS';
        dellCorpAccount.Core_Geo__c= 'APJ';
        database.insert(dellCorpAccount);
        
        //Creating Contact for Partner User
        List<Contact> contList = new List<Contact>();
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(accRecord.Id,false);
        contList.add(conRecord1);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(accRecord.Id,false);
        contList.add(conRecord2);
        
        Database.insert(contList);
        
        //Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, false);
                
        Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
        Database.insert(erpmEngagementCCF);
        
        Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client User',null ,'Intel® Partner Investment Center','CCF User',erpmEngagementCCF.Id , true,'Client',false);
        Database.insert(entitlementCCF); 
        
        Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCF.Id ,true,'Complete', false);
        Database.insert(contactEntitlementCCF);  
        
        // Creating User with utility class 
        List<User> usrList = new List<User>();
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usrList.add(usr);
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        usrList.add(usr1);
        
        User claimCase = Core_MDF_CCP_TestDataUtility.createUser(false);
        claimCase.Email = 'clmcase@example.com';
        claimCase.Profile = ccpCoreProfile;
        usrList.add(claimCase);
        
        Database.insert(usrList);
        
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        insert grp;
        
        system.runAs(usr){
        GroupMember gm = new GroupMember();
        gm.GroupId = grp.Id;
        gm.UserOrGroupId = usr1.Id;
        insert gm;
        
        List<PermissionSetAssignment> assignPermissionList = new List<PermissionSetAssignment>();    
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = claimCase.Id;
        assignPermissionSetObj.PermissionSetId = clmCaseRevPS.Id;
        assignPermissionList.add(assignPermissionSetObj);
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = claimCase.Id;
        assignPermissionSetObj1.PermissionSetId = ccfPayAdmPS.Id;
        assignPermissionList.add(assignPermissionSetObj1);
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = usr1.Id;
        assignPermissionSetObj2.PermissionSetId = claimSubmitterPS.Id;
        assignPermissionList.add(assignPermissionSetObj2);
        PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();
        assignPermissionSetObj3.AssigneeId = claimCase.Id;
        assignPermissionSetObj3.PermissionSetId = rmfPayAdmPS.Id;
        assignPermissionList.add(assignPermissionSetObj3);
        PermissionSetAssignment assignPermissionSetObj4 = new PermissionSetAssignment();
        assignPermissionSetObj4.AssigneeId = claimCase.Id;
        assignPermissionSetObj4.PermissionSetId = ccfActMgr.Id;
        assignPermissionList.add(assignPermissionSetObj4);
        PermissionSetAssignment assignPermissionSetObj5 = new PermissionSetAssignment();
        assignPermissionSetObj5.AssigneeId = usr.Id;
        assignPermissionSetObj5.PermissionSetId = ccfBudgetLdr.Id;
        assignPermissionList.add(assignPermissionSetObj5);
        PermissionSetAssignment assignPermissionSetObj6 = new PermissionSetAssignment();
        assignPermissionSetObj6.AssigneeId = usr.Id;
        assignPermissionSetObj6.PermissionSetId = retailFinMgr.Id;
        assignPermissionList.add(assignPermissionSetObj6);
        system.runas(usr){
        Database.insert(assignPermissionList);
            
        }

        }
        
        // Creating Intel Account with utility class
        /*Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Dell Corporation', NULL,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        dellCorpAccount.BillingCity = 'Test City';         
        dellCorpAccount.BillingCountry= 'AUS';
        dellCorpAccount.BillingStreet= 'Test Street';
        Database.insert(dellCorpAccount); 
        dellCorpAccount.IsPartner = true;
        dellCorpAccount.Core_MDF_CoMarketingActive__c = true;
        Database.update(dellCorpAccount);*/
        
        // Creating Co-marketing Account with utility class
        Account dellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF Virtual Corp', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFVirtualCorp.Core_MDF_Parent_Fund_Account__c = accRecord.Id;
        Database.insert(dellCCFVirtualCorp);
        
        List<Account> lstVirAcct1 = new List<Account>();
        List<Account> lstVirAcct2 = new List<Account>();
        
        // Creating Co-marketing Account with utility class
        Account dellCCFEMEA = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF EMEA', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFEMEA.Core_MDF_Parent_Fund_Account__c = dellCCFVirtualCorp.Id;
        lstVirAcct1.add(dellCCFEMEA);
        
        Account dellCCFAPAC = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF APAC', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        dellCCFAPAC.Core_MDF_Parent_Fund_Account__c = dellCCFVirtualCorp.Id;
        lstVirAcct1.add(dellCCFAPAC);
        
        Database.insert(lstVirAcct1);
        
        //Areefa:Test.startTest();
        
        // Creating Co-marketing Account with utility class
        Account dellEMEAFrance = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF EMEA France', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellEMEAFrance.Core_MDF_Parent_Fund_Account__c = dellCCFEMEA.Id;
        dellEMEAFrance.Core_MDF_Auto_Transfer_Account__c = dellCCFVirtualCorp.Id;
        dellEMEAFrance.Core_MDF_Enabled_Auto_Transfer__c = True;
        lstVirAcct2.add(dellEMEAFrance);
        
        Account dellCCFAPACIndia = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF APAC India', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFAPACIndia.Core_MDF_Parent_Fund_Account__c = dellCCFAPAC.Id;
        dellCCFAPACIndia.Core_MDF_Auto_Transfer_Account__c = dellCCFVirtualCorp.ID;
        dellCCFAPACIndia.Core_MDF_Enabled_Auto_Transfer__c = True;
        lstVirAcct2.add(dellCCFAPACIndia);
        
        Database.insert(lstVirAcct2);
        
        Account dellRMFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell RMF Virtual Corp', cp2.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        dellRMFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellRMFVirtualCorp.Core_Geo__c = 'APJ';
        database.insert(dellRMFVirtualCorp);
        
        Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(accRecord.Id,'Internal',accRecord.Id,cp.Id,'PGM_TEST',true);
       // Test.startTest();
        System.runAs(usr){
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(dellCCFAPACIndia.Id,usr1.Id, true);
        }
        //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(dellCCFAPACIndia.Id,usr1.Id, true);
        
        // Create PMB for the above Account
            
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,dellCCFVirtualCorp.Id,cp.Id,100000,
                                                                                      System.today().addDays(-15),System.today().addDays(15),false);
        pmbRecord.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        system.runas(usr){
        database.insert(pmbRecord);
        }
        // Create PFA records for the above accounts :
        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
        

        PartnerFundAllocation pfaDellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFVirtualCorp',pmbRecord, dellCCFVirtualCorp, 10000,false);
        pfaList.add(pfaDellCCFVirtualCorp);
        PartnerFundAllocation pfaDellCCFEMEA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFEMEA',pmbRecord, dellCCFEMEA, 1000, false);
        pfaList.add(pfaDellCCFEMEA);
        PartnerFundAllocation pfaDellCCFAPAC = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFAPAC',pmbRecord, dellCCFAPAC, 1000,false);
        pfaList.add(pfaDellCCFAPAC);
        PartnerFundAllocation pfaDellCCFFrance = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFFrance',pmbRecord, dellEMEAFrance, 1000, false);
        pfaList.add(pfaDellCCFFrance);
        PartnerFundAllocation pfaDellCCFIndia = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFIndia',pmbRecord, dellCCFAPACIndia, 1000,false);
        pfaList.add(pfaDellCCFIndia);
        system.runas(usr){
        Database.insert(pfaList);
        }
        
         //inserting custom records needed for claim insertion
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7+ Processor', 'Yes',Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF
                                                                    , 'Client CoMarketing Fund', System.today().addDays(-10), System.today().addDays(+10), 
                                                                    10000, 'Consumer Chromebook', dellCCFVirtualCorp.Id, '2-in-1', false);
        camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        System.runAs(claimCase){
        database.insert(camp);
        }
        //Test.stopTest();
        
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        PartnerFundRequest franceActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                  String.valueof(dellEMEAFrance.id),pfaDellCCFFrance,pmbRecord,'INDIA',
                                                                                                  'Consumer',
                                                                                                  'Desktop',
                                                                                                  'Intel® Core™ i5 Processor',
                                                                                                  'Broadcast (Pre-2025)',
                                                                                                  'Podcast',
                                                                                                  'Draft',
                                                                                                  false);
        franceActivity.Title = 'France Activity';
        franceActivity.Core_MDF_Activity_Description__c = 'France Activity';
        franceActivity.Core_MDF_Start_Date__c = System.today().addDays(-3);
        franceActivity.Core_MDF_End_Date__c = System.today().addDays(+5);
        franceActivity.RequestedAmount = 7000;
        franceActivity.Core_MDF_pagespayingfor__c = 15;
        franceActivity.Amount=0;
        franceActivity.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        franceActivity.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        pfrList.add(franceActivity);
        
        
        PartnerFundRequest indiaActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFAPACIndia.id),pfaDellCCFIndia,pmbRecord,
                                                                                                 'ANGOLA','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast (Pre-2025)','Podcast','Draft'
                                                                                                 ,false);
        indiaActivity.Title = 'indiaActivity';
        indiaActivity.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity.Core_MDF_Start_Date__c = System.today().addDays(-3);
        indiaActivity.Core_MDF_End_Date__c = System.today().addDays(+5);
        indiaActivity.RequestedAmount = 100;
        indiaActivity.Core_MDF_Channel_Partner_Led__c = True;
        indiaActivity.Amount=0;
        indiaActivity.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        indiaActivity.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        pfrList.add(indiaActivity);
        
        PartnerFundRequest indiaActivity1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFAPAC.id),pfaDellCCFIndia,pmbRecord,
                                                                                                 'ANGOLA','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast (Pre-2025)','Podcast','Draft'
                                                                                                 ,false);
        indiaActivity1.Title = 'indiaActivity1';
        indiaActivity1.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity1.Core_MDF_Start_Date__c = System.today().addDays(-3);
        indiaActivity1.Core_MDF_End_Date__c = System.today().addDays(+5);
        indiaActivity1.RequestedAmount = 100;
        indiaActivity1.Core_MDF_Channel_Partner_Led__c = True;
        indiaActivity1.Amount=0;
        indiaActivity1.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        indiaActivity1.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        pfrList.add(indiaActivity1);
        
        //Database.insert(pfrList);
        
        PartnerFundRequest indiaActivity2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFAPAC.id),pfaDellCCFIndia,pmbRecord,
                                                                                                 'ANGOLA','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast (Pre-2025)','Podcast','Draft'
                                                                                                 ,false);
        indiaActivity2.Title = 'indiaActivity2';
        indiaActivity2.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity2.Core_MDF_Start_Date__c = System.today().addDays(-3);
        indiaActivity2.Core_MDF_End_Date__c = System.today().addDays(+5);
        indiaActivity2.RequestedAmount = 100;
        indiaActivity2.Core_MDF_Channel_Partner_Led__c = True;
        indiaActivity2.Amount=0;
        indiaActivity2.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        indiaActivity2.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        pfrList.add(indiaActivity2);
        
        Database.insert(pfrList);
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        Core_MDF_Bank__c indiaBank = new Core_MDF_Bank__c();
        system.runAs(claimCase){
        indiaBank = Core_MDF_CCP_TestDataUtility.createBank(accRecord.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
        indiaBank.Core_MDF_Payment_Currency_Cd__c = 'USD';
        indiaBank.Core_MDF_Bank_Status__c = 'Active';
        //indiaBank.Core_MDF_Hold_Payments_from_AP_file_ind__c = 'Yes';
        //indiaBank.Core_MDF_Hold_Reason_txt__c = 'Test';        
        Database.insert(indiaBank);
        }
         //creating ABM for indiaBank
        List<Core_MDF_Account_Bank_Mapping__c> abmlist = new List<Core_MDF_Account_Bank_Mapping__c>();              
        

        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFAPACIndia.Id,indiaBank.Id,false); 
        abmlist.add(abm);
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellEMEAFrance.Id,indiaBank.Id,false); 
        abmlist.add(abm1);
        Database.insert(abmlist);  
        
        Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm1','Gaming','9ᵗʰ Gen','No', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-22), System.today().addDays(20), 100000, 'Instore innovation', dellRMFVirtualCorp.Id,'Desktop', false); 
        retailCampaign.Core_MDF_Is_Opal__c='No';
        retailCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Retail MDF';
        retailCampaign.Core_MDF_Activity_Category_Type__c =null;
        retailCampaign.Core_MDF_Reimbursement_Rate__c='100%';
        retailCampaign.Core_MDF_Technology__c = 'Intel vPro®';
        
        database.insert(retailCampaign);
        
        /*PartnerMarketingBudget  pmbRecord1 = Core_MDF_CCP_TestDataUtility.createRetailBudget('Dell RMF PMB',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,dellRMFVirtualCorp.Id,cp2.Id,1000000,System.today().addDays(-15),System.today().addDays(15),false, 'Retail MDF');
        pmbRecord1.IsIgnoreValidation = true;
        pmbRecord1.Core_MDF_Budget_Status__c = 'Released';
        //pmbRecord1.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
       system.runas(usr){
        database.insert(pmbRecord1);
       }
        
        PartnerFundAllocation retailAlloc = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('retailAlloc',pmbRecord1,dellRMFVirtualCorp,20000.0,false);
        system.runas(usr){
            database.insert(retailAlloc);
        }*/
        
        List<PartnerMarketingBudget> budgetLst = new List<PartnerMarketingBudget>();        

        PartnerMarketingBudget retailMDFbudget = Core_MDF_CCP_TestDataUtility.createRetailBudget('Dell RMF PMB',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,dellRMFVirtualCorp.Id,
                                                                                                 cp2.Id,200000,System.today()-25,System.today()+125, false,'Retail MDF');
        retailMDFbudget.Core_MDF_Budget_Status__c = 'Released';
        retailMDFbudget.IsIgnoreValidation = true;
        budgetLst.add(retailMDFbudget);
        Test.startTest();
        System.runAs(usr){
        Database.insert(budgetLst);
        }
                        List<Core_MDF_Audit_Rules_Engine__c> ruleList = new List<Core_MDF_Audit_Rules_Engine__c>();
        
        Core_MDF_Audit_Rules_Engine__c rule5 = new Core_MDF_Audit_Rules_Engine__c();
        rule5.Core_MDF_Object_Nm__c= 'PartnerFundClaim';
        rule5.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
        rule5.Core_MDF_Field_Nm__c= 'Core_MDF_Requested_Reimbursement_Amt__c';
        rule5.Core_MDF_Operator_Nm__c= 'Greater Than';
        rule5.Core_MDF_Budget_Type_Multi_Nm__c= 'MDF;MDF+;OEM CMP';
        rule5.Core_MDF_Value_Txt__c= '0';
        rule5.Core_MDF_Immediate_Ind__c= 'Yes';
        rule5.Core_MDF_Effective_Dt__c= System.today()-1;
        rule5.Core_MDF_Active_Ind__c= true;
        rule5.Core_MDF_Rule_Type_Nm__c= 'PIC';
        rule5.Core_MDF_Region_Cd__c = 'WW';
        ruleList.add(rule5);
        Database.insert(rule5);
        
        Core_MDF_Audit_Rules_Engine__c rule6 = new Core_MDF_Audit_Rules_Engine__c();
        rule6.Core_MDF_Object_Nm__c= 'PartnerFundClaim';
        //rule6.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
        rule6.Core_MDF_Field_Nm__c= 'Core_MDF_Requested_Reimbursement_Amt__c';
        rule6.Core_MDF_Operator_Nm__c= 'Greater Than';
        //rule6.Core_MDF_Budget_Type_Multi_Nm__c= 'MDF;MDF+;OEM CMP';
        rule6.Core_MDF_Value_Txt__c= '2';
        //rule6.Core_MDF_Immediate_Ind__c= 'Yes';
        rule6.Core_MDF_Effective_Dt__c= System.today()-1;
        rule6.Core_MDF_Active_Ind__c= true;
        rule6.Core_MDF_Rule_Type_Nm__c= 'Audit';
        //rule6.Core_MDF_Region_Cd__c = 'WW';
        ruleList.add(rule6);
        Database.insert(rule6);   

    Test.stopTest();
        List<PartnerFundAllocation> allocList = new List<PartnerFundAllocation>();
        PartnerFundAllocation retailMDFAllocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('retailAlloc',retailMDFbudget,dellRMFVirtualCorp,200.0,false);
        allocList.add(retailMDFAllocation);
        Database.insert(allocList);
       
        Core_MDF_Bank__c retailBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
        retailBank.Core_MDF_Intel_Company_Code__c = '150';
        retailBank.name = 'retailBank';
        retailBank.Core_MDF_Currency_cd__c = 'USD';
        retailBank.Core_MDF_Payment_Currency_Cd__c = 'USD';
        retailBank.Core_MDF_Tax_codes_cd__c = 'I0';
        retailBank.Core_MDF_Bank_Location__c = 'US';
        retailBank.Core_MDF_Bank_Status__c = 'Active';   
        retailBank.Core_MDF_Effective_Date__c=System.today().addDays(-1);
        retailBank.Core_MDF_Supplier_Country_txt__c = 'US';  
        retailBank.Core_MDF_Supplier_City_txt__c = 'New York';  
        retailBank.Core_MDF_Supplier_Region_txt__c = 'New York';  
        retailBank.Core_MDF_Supplier_Postal_Code_cd__c = '728378';  
        retailBank.Core_MDF_VAT_pct__c = '10';
         system.runAs(claimCase){
         database.insert(retailBank);
        }
       PartnerFundRequest indiaActivity4 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(retailCampaign.Id),string.valueof(dellRMFVirtualCorp.id),
                            System.today()-5,System.today()+5,false);
        indiaActivity4.Title = 'indiaActivity4';
        indiaActivity4.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
        indiaActivity4.Core_MDF_Country_nm__c = 'INDIA';
        indiaActivity4.Core_MDF_Reimbursement_Rate_pct__c = '100%';
        indiaActivity4.RequestedAmount =1000;
        indiaActivity4.Amount=1000;
        indiaActivity4.Core_MDF_Reimbursement_Rate_txt__c='60%';
        indiaActivity4.Core_MDF_Product_Category_txt__c ='Notebook/Mobile';
        indiaActivity4.AllocationId = retailMDFAllocation.Id;
        indiaActivity4.Core_MDF_TargetAudience__c = 'Small and Medium Business';
        database.insert(indiaActivity4);
        
        Core_MDF_Account_Bank_Mapping__c abm2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellRMFVirtualCorp.Id,retailBank.Id,false);
        database.insert(abm2);
        
        //Test.startTest();
        List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
        claimFunctionalityNameTriggerExecution.Core_Trigger_Events__c = 'after insert';
        claimFunctionalityNameTriggerExecution.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution.Name = 'fundReservation';
        claimFunctionalityNameTriggerExecution.Core_Description__c = 'description';
        executionList.add(claimFunctionalityNameTriggerExecution);
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution2 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution2.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution2.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
        claimFunctionalityNameTriggerExecution2.Core_Trigger_Events__c = 'before insert';
        claimFunctionalityNameTriggerExecution2.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution2.Name = 'checkESDHoldAndUpdateClaimStatus';
        claimFunctionalityNameTriggerExecution2.Core_Description__c = 'check ESD hold for the bank selected on Claim and change Claim status to Hold if it is on ESD Hold';
        executionList.add(claimFunctionalityNameTriggerExecution2);
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution1 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution1.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution1.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
        claimFunctionalityNameTriggerExecution1.Core_Trigger_Events__c = 'before insert';
        claimFunctionalityNameTriggerExecution1.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution1.Name = 'duplicateClaimCheck';
        claimFunctionalityNameTriggerExecution1.Core_Description__c = 'check ESD hold for the bank selected on Claim and change Claim status to Hold if it is on ESD Hold';
        executionList.add(claimFunctionalityNameTriggerExecution1);
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution3 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution3.Core_Active__c = false;
        claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'before upate, after update';
        claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution3.Name = 'checkAndSendClaimsToAudit';
        claimFunctionalityNameTriggerExecution3.Core_Description__c = 'test';
        executionList.add(claimFunctionalityNameTriggerExecution3);
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution4 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution4.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution4.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution4.Core_Trigger_Events__c = 'before insert, before update';
        claimFunctionalityNameTriggerExecution4.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution4.Name = 'Core_MDF_chkClaimAmtAgainstActBgtAmt';
        claimFunctionalityNameTriggerExecution4.Core_Description__c = 'description';
        executionList.add(claimFunctionalityNameTriggerExecution4);
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution5 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution5.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution5.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution5.Core_Trigger_Events__c = 'after update';
        claimFunctionalityNameTriggerExecution5.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution5.Name = 'reserveFundsforNode';
        claimFunctionalityNameTriggerExecution5.Core_Description__c = 'description';
        executionList.add(claimFunctionalityNameTriggerExecution5);
        
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution6 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution6.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution6.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution6.Core_Trigger_Events__c = 'after insert, after update';
        claimFunctionalityNameTriggerExecution6.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution6.Name = 'checkAndSendClaimsForPIC';
        claimFunctionalityNameTriggerExecution6.Core_Description__c = 'description';
        executionList.add(claimFunctionalityNameTriggerExecution6);
        
        Database.insert(executionList);

        /*Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount aObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount bObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount cObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> listvar = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
        
        aObj.inputCurrency ='ZMK';
        aObj.inputAmount = 250.00;
        aObj.inputDate= System.today();
        bObj.inputCurrency ='INR';
        bObj.inputAmount = 350.00;
        bObj.inputDate= System.today();
        cObj.inputCurrency ='USD';
        cObj.inputAmount = 350.00;
        cObj.inputDate= System.today();
        listvar.add(aObj);
        listvar.add(bObj);
        listvar.add(cObj);
        Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(listvar);*/
        //Test.stopTest();
        
        /*Core_MDF_Audit_Rules_Engine__c rule6 = new Core_MDF_Audit_Rules_Engine__c();
        rule6.Core_MDF_Object_Nm__c= 'PartnerFundClaim';
        rule6.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
        rule6.Core_MDF_Field_Nm__c= 'Core_MDF_Requested_Reimbursement_Amt__c';
        rule6.Core_MDF_Operator_Nm__c= 'Greater Than';
        rule6.Core_MDF_Budget_Type_Multi_Nm__c= 'CCF 1.0';
        rule6.Core_MDF_Value_Txt__c= '2000';
        rule6.Core_MDF_Immediate_Ind__c= 'Yes';
        rule6.Core_MDF_Effective_Dt__c= System.today()-1;
        rule6.Core_MDF_Active_Ind__c= true;
        rule6.Core_MDF_Rule_Type_Nm__c= 'Audit';
        rule6.Core_MDF_Region_Cd__c = 'WW';
        ruleList.add(rule6);
        Database.insert(rule6);  */      
    }
    
    // Test method to test fundreservation for Claims whose Amount is less than current Allocation
    /*@isTest static void testPFCFundReservationScnearioOne(){
        List<Core_Trigger_Executions__c> transactions = Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                                                            'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                                                            'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                                                            'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, false);   

        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        //User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        
        PartnerFundRequest indiaActivity = [SELECT Title,Core_MDF_Start_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        Test.startTest();
        //Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        Account accRecord = [Select id from Account where Name = 'Intel Test Account'];
        Account dellCCFAPACIndia = [Select id from Account where Name = 'Dell CCF APAC India'];
        System.runAs(clmCaseUser){
        //Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(accRecord.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c WHERE Name = 'Test' limit 1];
        
        //creating ABM for indiaBank
        //Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFAPACIndia.Id,indiaBank.Id,true);
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        System.runAs(clmCaseUser){
            
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   101, 
                                                                                   System.today().addDays(-1), indiaBank.ID, false);
            PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today().addDays(-1), indiaBank.ID, false);
            claimListToBeProcessed.add(indiaClaim);
            claimListToBeProcessed.add(indiaClaim2);
            
            try{
                Database.insert(transactions);

                Database.insert(claimListToBeProcessed);
                PartnerFundClaim reservedClaim = [Select Status From PartnerFundClaim WHERE Id = :indiaClaim.Id LIMIT 1];
                //System.assertEquals(reservedClaim.Status, Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Approved'));
                 assert.areEqual(reservedClaim.Status, 'Submitted'); 
                //Database.update(claimListToBeProcessed);
            }catch(Exception e){
                
            }
            
        }
        }  
        Test.stopTest();      
    }*/
    // Test method to test fundreservation for Claims whose Amount is less than current Allocation
    /*@isTest static void testPFCFundReservationScnearioDup(){
        List<Core_Trigger_Executions__c> transactions = Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                                                            'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                                                            'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                                                            'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, false);
        
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        //User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        //Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        Test.startTest();
        Account accRecord = [Select id from Account where Name = 'Intel Test Account'];
        Account dellCCFAPACIndia = [Select id from Account where Name = 'Dell CCF APAC India'];
        System.runAs(clmCaseUser){
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c WHERE Name = 'Test' limit 1];
        //Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(accRecord.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
        //indiaBank.Core_MDF_Hold_Payments_from_AP_file_ind__c = 'Yes';
        //indiaBank.Core_MDF_Hold_Reason_txt__c = 'Test';        
        //Database.insert(indiaBank);
        
         //creating ABM for indiaBank
        //Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFAPACIndia.Id,indiaBank.Id,true);
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        //System.runAs(clmCaseUser){
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   100, 
                                                                                   System.today().addDays(-1), indiaBank.ID, false);
            indiaClaim.Core_MDF_Currency__c='USD';
            //Database.insert(indiaClaim);
            PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claims', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today().addDays(-1), indiaBank.ID, false);
            indiaClaim2.Core_MDF_Currency__c='USD';
            PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('India Claimr', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    101, 
                                                                                    System.today().addDays(-1), indiaBank.ID, false);
            indiaClaim3.Core_MDF_Currency__c='USD';
            PartnerFundClaim indiaClaim4 = Core_MDF_CCP_TestDataUtility.createClaim('India Claimss', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    102, 
                                                                                    System.today().addDays(-1), indiaBank.ID, false);
            indiaClaim4.Core_MDF_Currency__c='USD';
            claimListToBeProcessed.add(indiaClaim);
            claimListToBeProcessed.add(indiaClaim4);
            claimListToBeProcessed.add(indiaClaim3);
            claimListToBeProcessed.add(indiaClaim2);
            
            try{
                            
                Database.insert(transactions);
                Database.insert(claimListToBeProcessed);
                assert.areEqual(indiaClaim2.Core_MDF_Duplicate_Claim__c, false);
                List<Core_MDF_Claim_Utility.ReleaseHoldParams> wrapList = new List<Core_MDF_Claim_Utility.ReleaseHoldParams>();
                Core_MDF_Claim_Utility.ReleaseHoldParams obj1 = new Core_MDF_Claim_Utility.ReleaseHoldParams();
                obj1.inputClaims = claimListToBeProcessed;
                obj1.releaseReason = new List<String>{Label.Core_MDF_Audit_Hold};
                    wrapList.add(obj1);
                Core_MDF_Claim_Utility.invokeReleaseHold(wrapList);
                Database.update(claimListToBeProcessed);
            }catch(Exception e){
                
            }
            Test.stopTest(); 
        }  
               
    }*/
    
    // Test method to test fundreservation for Claims whose Amount is more than 
    // current Allocation without Auto Transfer Enabled
    /*@isTest static void testPFCFundReservationScnearioTwo(){
        
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
         PartnerFundRequest indiaActivity = [SELECT Id,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        //Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        Account accRecord = [Select id from Account where Name = 'Intel Test Account'];


        Account dellCCFAPACIndia = [Select id from Account where Name = 'Dell CCF APAC India'];
        
        Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(accRecord.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
        
        Test.startTest();
         //creating ABM for indiaBank
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFAPACIndia.Id,indiaBank.Id,true);
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        System.runAs(clmCaseUser){
            
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   3000, 
                                                                                   System.today(), indiaBank.ID, false);
            PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    2500, 
                                                                                     System.today(), indiaBank.ID, false);
            claimListToBeProcessed.add(indiaClaim);
            claimListToBeProcessed.add(indiaClaim2);
          
                Database.insert(claimListToBeProcessed);
                PartnerFundClaim reservedClaim = [Select Status From PartnerFundClaim WHERE Id = :indiaClaim.Id LIMIT 1];
                System.assertEquals(reservedClaim.Status, System.Label.Core_MDF_Status_Approved);               
           
        } 
        Test.stopTest();
    }  */ 
    
    // Test method to test fundreservation for Claims whose Amount is more than 
    // current Allocation with Auto Transfer Enabled and Satisfying the Claim Amount
      @isTest static void testPFCFundReservationScnearioThree(){
        Test.startTest();
        List<Core_Trigger_Executions__c> transactions = Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                                                            'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                                                            'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                                                            'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, false);   

        Account  dellEMEAFranceAcc = [Select Id from Account where Name = 'Dell CCF EMEA France' Limit 1];
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        PartnerFundRequest franceActivity = [SELECT Id,ChannelPartner.Core_MDF_Auto_Transfer_Account__c,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='France Activity' limit 1];
        
        
        //Core_MDF_Bank__c franceBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        Account accRecord = [Select id from Account where Name = 'Intel Test Account'];
        Account dellCCFAPACIndia = [Select id from Account where Name = 'Dell CCF APAC India'];
        System.runAs(clmCaseUser){
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c WHERE Name = 'Test' limit 1];
        //Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(accRecord.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
        //indiaBank.Core_MDF_Hold_Payments_from_AP_file_ind__c = 'Yes';
        //indiaBank.Core_MDF_Hold_Reason_txt__c = 'Test';        
        //Database.insert(indiaBank);
        
         //creating ABM for indiaBank
         /* List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFAPACIndia.Id,indiaBank.Id,false);
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellEMEAFranceAcc.Id,indiaBank.Id,false);
          abmList.add(abm);
          abmList.add(abm1);
          database.insert(abmList);*/
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        //System.runAs(clmCaseUser){
            PartnerFundClaim franceClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    franceActivity.Id, 
                                                                                    franceActivity.Core_MDF_Start_Date__c, franceActivity.Core_MDF_Start_Date__c, 
                                                                                    30000, 
                                                                                     System.today(), indiaBank.ID, false);
            franceClaim.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';                                                                       
            PartnerFundClaim franceClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                     franceActivity.Id, 
                                                                                     franceActivity.Core_MDF_Start_Date__c, franceActivity.Core_MDF_Start_Date__c, 
                                                                                     5000, 
                                                                                      System.today(), indiaBank.ID, false);
            franceClaim2.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            claimListToBeProcessed.add(franceClaim);
            claimListToBeProcessed.add(franceClaim2);
           // try{
                    
                Database.insert(transactions);
                Database.insert(claimListToBeProcessed);
                PartnerFundClaim reservedClaim = [Select Status From PartnerFundClaim WHERE Id = :franceClaim.Id LIMIT 1];
                 assert.areEqual(reservedClaim.Status, Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted'));
                claimListToBeProcessed[0].Core_MDF_Total_Invoice_Amount_Local__c = 20;
                Database.update(claimListToBeProcessed);
            //}catch(Exception e){}
        } 
        Test.stopTest();
    }
    
    @isTest
    static void testESDHoldSubmitted()
    {
        Test.startTest();
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        Account dellCorpAccount = [SELECT ID From Account Where Name='Intel Test Account' Limit 1];
        Account  dellEMEAFranceAcc = [Select Id from Account where Name = 'Dell CCF EMEA France' Limit 1];
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundRequest franceActivity = [SELECT Id,ChannelPartner.Core_MDF_Auto_Transfer_Account__c,BudgetId,AllocationId,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='France Activity' limit 1];
        System.runAs(clmCaseUser){
        List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
        Core_MDF_Bank__c franceBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231231');
        //franceBank.Core_MDF_Bank_Status__c = 'Hold';
        franceBank.Core_MDF_ESD_Hold_Indicator__c = true;
        //update franceBank;
        bankList.add(franceBank);
        
        Core_MDF_Bank__c franceBank2 = [Select ID,Core_MDF_Bank_Status__c,Core_MDF_ESD_Hold_Indicator__c,Core_MDF_ESD_Update__c,Core_MDF_Hold_Payments_from_AP_file_ind__c from Core_MDF_Bank__c WHERE
                                        Core_MDF_Supplier_Number__c = '1231231230'   limit 1];
        
        //update franceBank2;
        bankList.add(franceBank2); 
        
        Database.update(banklist);
        
        //creating ABM for franceBank
        List<Core_MDF_Account_Bank_Mapping__c> abmlist = new List<Core_MDF_Account_Bank_Mapping__c>();

        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellEMEAFranceAcc.Id,franceBank.Id,false);
        abmlist.add(abm);
        //Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellEMEAFranceAcc.Id,franceBank.Id,false);
        //abmlist.add(abm1);
        
        Database.insert(abmlist);
        
        //System.runAs(clmCaseUser){
                        

            PartnerFundClaim franceClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim2', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    franceActivity.Id, 
                                                                                    franceActivity.Core_MDF_Start_Date__c, franceActivity.Core_MDF_Start_Date__c, 
                                                                                    300, 
                                                                                    System.today().addDays(-1), franceBank.ID, false);
            franceClaim.Core_MDF_Currency__c='USD';
            franceClaim.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            claimListToBeProcessed.add(franceClaim);
            
            Database.insert(claimListToBeProcessed);
            
            PartnerFundClaim reservedClaim = [Select Core_MDF_Status__c,Core_MDF_ESD_Hold__c From PartnerFundClaim WHERE Id = :franceClaim.Id LIMIT 1];
            //System.assertEquals(reservedClaim.Core_MDF_Status__c, Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold')); 
             assert.areEqual(reservedClaim.Core_MDF_ESD_Hold__c, true); 
            //claimListToBeProcessed[0].Core_MDF_Bank__c = franceBank2.Id;
            //Database.update(claimListToBeProcessed);
            claimListToBeProcessed[0].Core_MDF_Bank__c = franceBank.Id;
            Database.update(claimListToBeProcessed); 
            List<PartnerFundClaim> claimListToBeProcessed1 = [Select id,Core_MDF_Status__c,Core_MDF_Claim_Previous_Status__c,Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c,
                                                              Core_MDF_Audit_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Document_Hold_Ind__c,
                                                              Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_ESD_Hold__c,Core_MDF_Member_Manual_Hold_Ind__c, Core_MDF_VAT_Hold_Ind__c,Core_MDF_Bank_Doc_Hold_Ind__c
                                                              from PartnerFundClaim where Title = 'India Claim2'];
            //System.assertEquals(claimListToBeProcessed1[0].Core_MDF_Claim_Previous_Status__c,'Hold');
            Core_MDF_Claim_Utility.releaseHold(claimListToBeProcessed1,new List<String>{Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ESD_Hold')});
        }
        Test.stopTest();
    }
    
    @isTest
    static void testESDHoldPaymentDue()
    {
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
    Test.startTest();
        Account dellCorpAccount = [SELECT ID From Account Where Name='Intel Test Account' Limit 1];
        Account  dellEMEAFranceAcc = [Select Id from Account where Name = 'Dell CCF EMEA France' Limit 1];
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundRequest franceActivity = [SELECT Id,ChannelPartner.Core_MDF_Auto_Transfer_Account__c,BudgetId,AllocationId,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='France Activity' limit 1];
    System.runAs(clmCaseUser){    
    List<Core_MDF_Bank__c> banklist = new List<Core_MDF_Bank__c>();
    Core_MDF_Bank__c franceBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231231');
        //franceBank.Core_MDF_Bank_Status__c = 'Hold';
        franceBank.Core_MDF_ESD_Hold_Indicator__c = true;
        //update franceBank;
    banklist.add(franceBank);
        
 /*  Core_MDF_Bank__c franceBank2 = [Select ID,Core_MDF_Bank_Status__c,Core_MDF_ESD_Hold_Indicator__c,Core_MDF_ESD_Update__c,Core_MDF_Hold_Payments_from_AP_file_ind__c from Core_MDF_Bank__c WHERE
                                        Core_MDF_Supplier_Number__c = '1231231230'   limit 1]; */
     Core_MDF_Bank__c franceBank2 = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231232');
        //update franceBank2;
    banklist.add(franceBank2); 
    
    Database.update(banklist);
        
    //creating ABM for franceBank
    List<Core_MDF_Account_Bank_Mapping__c> abmlist = new List<Core_MDF_Account_Bank_Mapping__c>();
    
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellEMEAFranceAcc.Id,franceBank.Id,false);
    abmlist.add(abm);
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellEMEAFranceAcc.Id,franceBank2.Id,false);
    abmlist.add(abm1);
    
    Database.insert(abmlist);
    
        System.runAs(clmCaseUser){
            PartnerFundClaim franceClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim2', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    franceActivity.Id, 
                                                                                    franceActivity.Core_MDF_Start_Date__c, franceActivity.Core_MDF_Start_Date__c, 
                                                                                    300, 
                                                                                    System.today().addDays(-1), franceBank.ID, false);
            franceClaim.Core_MDF_Currency__c='USD';
            franceClaim.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            claimListToBeProcessed.add(franceClaim);
      
            Database.insert(claimListToBeProcessed);
      
            PartnerFundClaim reservedClaim = [Select Core_MDF_Status__c,Core_MDF_ESD_Hold__c From PartnerFundClaim WHERE Id = :franceClaim.Id LIMIT 1];
            //System.assertEquals(reservedClaim.Core_MDF_Status__c, Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold')); 
            System.assertEquals(reservedClaim.Core_MDF_ESD_Hold__c, true);
      
            claimListToBeProcessed[0].Core_MDF_Bank__c = franceBank2.Id;
            Database.update(claimListToBeProcessed);
      
            claimListToBeProcessed[0].Core_MDF_Bank__c = franceBank.Id;
            Database.update(claimListToBeProcessed); 
      
            List<PartnerFundClaim> claimListToBeProcessed1 = [Select id,Core_MDF_Status__c,Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c,Core_MDF_Claim_Previous_Status__c,Core_MDF_Audit_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Criteria_Hold_Ind__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_ESD_Hold__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Document_Hold_Ind__c from PartnerFundClaim where Title = 'India Claim2'];
            claimListToBeProcessed1[0].Core_MDF_Claim_Previous_Status__c= 'Payment Due';
             
             assert.areEqual(claimListToBeProcessed1[0].Core_MDF_Claim_Previous_Status__c,'Payment Due');
            Core_MDF_Claim_Utility.releaseHold(claimListToBeProcessed1,new List<String>{Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ESD_Hold')});
        }
            Test.stopTest();
        
        }
      
    }
    
    /*@isTest
    static void validatefundReservationCheckOnInsert(){
        List<Core_Trigger_Executions__c> transactions = Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                                                            'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                                                            'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                                                            'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, false);   
        
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
         Test.startTest();
        Core_Trigger_Executions__c checkAudit = [SELECT Id, Name, Core_Active__c, Core_Object__c FROM Core_Trigger_Executions__c where Name = 'checkAndSendClaimsToAudit' limit 1];        
        checkAudit.Core_Active__c = true;
        Database.update(checkAudit);
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        //Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        Account accRecord = [Select id from Account where Name = 'Intel Test Account'];
        Account dellCCFAPACIndia = [Select id from Account where Name = 'Dell CCF APAC India'];
          
        System.runAs(clmCaseUser){
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c WHERE Name = 'test' limit 1];
        //Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(accRecord.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
        //indiaBank.Core_MDF_Hold_Payments_from_AP_file_ind__c = 'Yes';
        //indiaBank.Core_MDF_Hold_Reason_txt__c = 'Test';        
        //Database.insert(indiaBank);
        //Test.startTest();
         //creating ABM for indiaBank
        //Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFAPACIndia.Id,indiaBank.Id,true);
         
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        //System.runAs(clmCaseUser){
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   101, 
                                                                                   System.today().addDays(-1), indiaBank.ID, false);
            PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim3', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today().addDays(-1), indiaBank.ID, false);
            claimListToBeProcessed.add(indiaClaim);
            claimListToBeProcessed.add(indiaClaim2);
            
            try{
                Database.insert(transactions);
                Database.insert(claimListToBeProcessed);
                //Covering the Edit Controller for the Lightning component
                String indiaClaim2Id = indiaClaim2.Id;
                Core_MDF_PartnerFundClaim_Edit.fetchClaimById(indiaClaim2Id);
                Database.update(claimListToBeProcessed);
                indiaClaim2.Core_MDF_AuditSelectionInProgress__c = false;
                Database.update(claimListToBeProcessed);
                List<Id> claimId = new List<Id>();    
                claimId.add(indiaClaim2.Id);
               Test.stopTest();
                Core_MDF_ProcessCCP_Claim.isClaimEligible(indiaClaim2,null,false);
                PartnerFundClaim reservedClaim = [Select Core_MDF_Status__c From PartnerFundClaim WHERE Id = :indiaClaim2.Id LIMIT 1];
    
                //System.assertEquals(reservedClaim.Core_MDF_Status__c, Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Payment_Due')); 
            }catch(Exception e){
                
            }
        } 
       
    }  */
    
    /* Test Method to Check the OwnerID Change of the Claim Record */
     @isTest
    static void testClaimOwnerChange()
    {
       Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users'}, true, true);
        PartnerFundClaim claim1 = new PartnerFundClaim();
        Map<Id,PartnerFundClaim> claimsMap= new Map<Id,PartnerFundClaim>(); 
        List<PartnerFundClaim> claimList= new List<PartnerFundClaim>();
        test.startTest();
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        //Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        Account accRecord = [Select id from Account where Name = 'Intel Test Account'];
       
        Account dellCCFAPACIndia = [Select id from Account where Name = 'Dell CCF APAC India'];
        System.runAs(clmCaseUser){
    Core_MDF_Bank__c indiaBank = [Select id from Core_MDF_Bank__c where Name = 'Test'];
        //indiaBank.Core_MDF_Hold_Payments_from_AP_file_ind__c = 'Yes';
        //indiaBank.Core_MDF_Hold_Reason_txt__c = 'Test';        
        //Database.insert(indiaBank);
        
         //creating ABM for indiaBank
        //Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFAPACIndia.Id,indiaBank.Id,true);
          
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        //System.runAs(clmCaseUser){
        
            claim1 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                              indiaActivity.Id, 
                                                              indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                              105, 
                                                              System.today().addDays(-1), indiaBank.ID, false);
            claim1.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = true;
            claim1.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            Database.insert(claim1);
            claimsMap.put(claim1.Id, claim1); 
        
        
        claim1.ownerId = UserInfo.getUserId();
        Database.update(claim1);       
        }
        claimList.add(claim1);       
        assert.areEqual(claimsMap.size(), 1);
        test.stopTest();
        Core_MDF_ProcessCCP_Claim.setBankDocHoldonEligibleClaims(claimList);
        Core_MDF_PFC_Sharing.recalculateShareClaimWhenOwnerChange(claimList, claimsMap);
      
    }
    
    /* Test Method to check reserve funds for Node */
    @isTest
    static void testReserveFundsforNode()
    {
        Test.startTest();
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        Account dellCorpAccount = [SELECT ID From Account Where Name='Intel Test Account' Limit 1];
        Account  dellEMEAFranceAcc = [Select Id from Account where Name = 'Dell CCF EMEA France' Limit 1];
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundRequest franceActivity = [SELECT Id,ChannelPartner.Core_MDF_Auto_Transfer_Account__c,BudgetId,AllocationId,ChannelPartner.Core_MDF_Enabled_Auto_Transfer__c,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='France Activity' limit 1];
        System.runAs(clmCaseUser){
        List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
        Core_MDF_Bank__c franceBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231231');
        //franceBank.Core_MDF_Bank_Status__c = 'Hold';
        franceBank.Core_MDF_ESD_Hold_Indicator__c = true;
        //update franceBank;
        bankList.add(franceBank);
        Database.update(banklist);
        
        //creating ABM for franceBank
        List<Core_MDF_Account_Bank_Mapping__c> abmlist = new List<Core_MDF_Account_Bank_Mapping__c>();
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellEMEAFranceAcc.Id,franceBank.Id,false);
        abmlist.add(abm);
        Database.insert(abmlist);
        
        //System.runAs(clmCaseUser){
            PartnerFundClaim franceClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim V1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    franceActivity.Id, 
                                                                                    franceActivity.Core_MDF_Start_Date__c, franceActivity.Core_MDF_Start_Date__c, 
                                                                                    300, 
                                                                                    System.today().addDays(-1), franceBank.ID, false);
            franceClaim.Core_MDF_Currency__c='USD';
            franceClaim.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            claimListToBeProcessed.add(franceClaim);
            Database.insert(claimListToBeProcessed);
            claimListToBeProcessed[0].Core_MDF_Status__c = 'Hold';
            claimListToBeProcessed[0].Status= 'Rejected';
            Database.update(claimListToBeProcessed);
            assert.areEqual(claimListToBeProcessed[0].Core_MDF_Status__c,'Hold');
        }
        Test.stopTest();
    }

  /*@isTest
    static void testOwnerChangeWhenSTPTrue(){
        Test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        PartnerFundClaim claim1 = new PartnerFundClaim();
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        Account accRecord = [Select id from Account where Name = 'Intel Test Account'];
        Account dellCCFAPACIndia = [Select id from Account where Name = 'Dell CCF APAC India'];
        User partnerUser = [Select Id from User Where Email = 'test1@example.com' limit 1];
        Map<Id, PartnerFundClaim> newClaimMap = new Map<Id, PartnerFundClaim>();
        Map<Id, PartnerFundClaim> tempClaimMap = new Map<Id, PartnerFundClaim>();
        System.runAs(clmCaseUser){
        Core_MDF_Bank__c indiaBank = [Select id from Core_MDF_Bank__c where Name = 'Test'];
            User partnerUser1 = [Select Id from User Where Email = 'test1@example.com' limit 1];
            PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
            
            claim1 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                              indiaActivity.Id, 
                                                              indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                              105, 
                                                              System.today().addDays(-1), indiaBank.ID, false);
            claim1.Core_MDF_Claim_Submitter_Id__c = partnerUser1.Id;
            claim1.Core_MDF_To_Be_Audited_Ind__c = true;
            
            Database.insert(claim1);
            newClaimMap.put(claim1.Id, claim1);
        }
        //newClaimMap = Core_MDF_ProcessCCP_Claim.changeOwnerToClaimSubmitterOnSTPTrue(newClaimMap,tempClaimMap);
        system.assertNotEquals(claim1 ,null);
        Test.stopTest();
    }   */ 
    @isTest
    static void testSetBankDocHoldonEligibleClaims(){
        
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        PartnerFundClaim claim1 = new PartnerFundClaim();
        Test.startTest();
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        Account accRecord = [Select id from Account where Name = 'Intel Test Account'];
        Account dellCCFAPACIndia = [Select id from Account where Name = 'Dell CCF APAC India'];
        User partnerUser = [Select Id from User Where Email = 'test1@example.com' limit 1];
        List<PartnerFundClaim> newClaimList = new List<PartnerFundClaim>();
        Map<Id, PartnerFundClaim> tempClaimMap = new Map<Id, PartnerFundClaim>();
        System.runAs(clmCaseUser){
    Core_MDF_Bank__c indiaBank = [Select id from Core_MDF_Bank__c where Name = 'Test'];
            User partnerUser1 = [Select Id from User Where Email = 'test1@example.com' limit 1];
            
            PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
         
            claim1 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                              indiaActivity.Id, 
                                                              indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                              105, 
                                                              System.today().addDays(-1), indiaBank.ID, false);
            claim1.Core_MDF_Claim_Submitter_Id__c = partnerUser1.Id;
           // claim1.Core_MDF_To_Be_Audited_Ind__c = true;
            newClaimList.add(claim1);
        }
        Core_MDF_ProcessCCP_Claim.setBankDocHoldonEligibleClaims(newClaimList);
        
        Test.stopTest();
    }   
    
 
    @isTest
    static void testOEMCMPClaims(){
        Test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        PartnerFundClaim claim1 = new PartnerFundClaim();
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        Account accRecord = [Select id from Account where Name = 'Intel Test Account'];
        Account dellCCFAPACIndia = [Select id from Account where Name = 'Dell CCF APAC India'];
        User partnerUser = [Select Id from User Where Email = 'test1@example.com' limit 1];
        List<PartnerFundClaim> newClaimList = new List<PartnerFundClaim>();
        Map<Id, PartnerFundClaim> tempClaimMap = new Map<Id, PartnerFundClaim>();
        System.runAs(clmCaseUser){
    Core_MDF_Bank__c indiaBank = [Select id from Core_MDF_Bank__c where Name = 'Test'];
            User partnerUser1 = [Select Id from User Where Email = 'test1@example.com' limit 1];
            PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
         
            claim1 = Core_MDF_CCP_TestDataUtility.createClaim('UtilityClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, indiaActivity.Id, System.today()-1, System.today()-1, 50.00, System.today()-1, indiaBank.Id, false);
       claim1.Core_MDF_Budget_Type_Options_Nm__c = 'OEM CMP';
       claim1.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
       
            Database.insert(claim1);
            claim1.Core_MDF_Total_Invoice_Amount_Local__c = 20;
            
            update claim1;
            
            //Added by Ealisha
        PartnerFundClaim claimCreated = [Select Id FROM PartnerFundClaim WHERE Title = 'UtilityClaim' LIMIT 1];
            tempClaimMap.put(claimCreated.Id,claimCreated);
            Core_MDF_ProcessCCP_Claim.SendClaimIdToClaimPredictionObj(tempClaimMap);
        
             assert.areEqual(20,claim1.Core_MDF_Total_Invoice_Amount_Local__c );
        }
        test.stopTest();
    }
     @isTest static void testReserveFundsOnActivity(){
      Test.startTest(); 
       User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
      System.runAs(clmCaseUser){
      Core_MDF_Bank__c retailProgBank = [Select ID,Core_MDF_Program__c,Core_MDF_Supplier_Country_txt__c from Core_MDF_Bank__c where Core_MDF_Program__c = 'Core_MDF_Retail_Marketing_Funds'  limit 1];
      PartnerFundRequest retailActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_Budget_Type_nm__c from PartnerFundRequest where Title='indiaActivity4' limit 1];
      
        List<PartnerFundClaim> listOfClaims = new List<PartnerFundClaim>();
        PartnerFundClaim retailMdfClaim = Core_MDF_CCP_TestDataUtility.createClaim('Retail MDF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, retailActivity.Id, System.today().addDays(-2), System.today().addDays(-2), 50.00, System.today().addDays(-2), retailProgBank.Id, false);
        retailMdfClaim.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
        Database.insert(retailMdfClaim);
        retailMdfClaim.Core_MDF_Type_Txt__c ='Claim';
        retailMdfClaim.Core_MDF_Currency__c='USD';
        retailMdfClaim.Core_MDF_Country_Location_nm__c= 'India'; 
        retailMdfClaim.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
        retailMdfClaim.Core_MDF_VAT_Eligibility_Ind__c = false;
        retailMdfClaim.Core_MDF_To_Be_Audited_Ind__c=true;
        retailMdfClaim.Core_MDF_Region_Cd__c='APJ';
        retailMdfClaim.Core_MDF_Status__c ='Payment Due';
        retailMdfClaim.Core_MDF_PIC_Review_Completed__c = true;
         Database.update(retailMdfClaim);
        retailActivity.Core_MDF_Fund_Request_Status__c = 'Closed';
        Database.Update(retailActivity);
  
        retailMdfClaim.Core_MDF_Status__c = 'Cancelled';
        Database.update(retailMdfClaim);
        assert.areEqual(retailMdfClaim.Core_MDF_Status__c,'Cancelled' );
        
    }
         test.stopTest();
   }
    
    @isTest
    static void testDelayInPICBatch(){
        Core_MDF_Configuration__c picConfig = new Core_MDF_Configuration__c();
        picConfig.name='Core_MDF_SecondsToDelayPICBatch';
        picConfig.Core_MDF_Value__c='5';
        picConfig.Core_MDF_Category__c ='Claim';
        insert picConfig;
     
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
            'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
            'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
            'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);

        Test.startTest();
        PartnerFundClaim claim1 = new PartnerFundClaim();
        User clmCaseUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        Account accRecord = [Select id from Account where Name = 'Intel Test Account'];
        Account dellCCFAPACIndia = [Select id from Account where Name = 'Dell CCF APAC India'];
        User partnerUser = [Select Id from User Where Email = 'test1@example.com' limit 1];
        List<PartnerFundClaim> newClaimList = new List<PartnerFundClaim>();
        Map<Id, PartnerFundClaim> tempClaimMap = new Map<Id, PartnerFundClaim>();
        System.runAs(clmCaseUser){
      Core_MDF_Bank__c indiaBank = [Select id from Core_MDF_Bank__c where Name = 'Test'];
            User partnerUser1 = [Select Id from User Where Email = 'test1@example.com' limit 1];
            PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
         
            claim1 = Core_MDF_CCP_TestDataUtility.createClaim('UtilityClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, indiaActivity.Id, System.today()-1, System.today()-1, 50.00, System.today()-1, indiaBank.Id, false);
           claim1.Core_MDF_Budget_Type_Options_Nm__c = 'OEM CMP';
            claim1.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
       
            Database.insert(claim1);
        }
        test.stopTest();
    }

}