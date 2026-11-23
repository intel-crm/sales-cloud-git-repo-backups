@isTest(SeeAllData=false)
public class Core_MDF_Batch_UpdateRecoveryClaimsTest {
    @TestSetup
    static void makeData() {
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'MDF Budget Loader';
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        PermissionSet ccfPaymentAdmin = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_CCF_MDF_Payment_Admin'];
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = usr.Id;
        assignPermissionSetObj1.PermissionSetId = ccfPaymentAdmin.Id;
        insert assignPermissionSetObj1;
        System.runAs(usr){
        //adding bypass feature to bypass access validation
			List<String> bypassFunctionKeys = new List<String>(); 
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing'}, true, false));       
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Allocation_Reservation','Bypass_GeoBased_Allocation_Sharing'}, true, false));   
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Bank_Check','Bypass_Bank_Internal_Sharing',
            'Bypass_Bank_External_Sharing','Bypass_Bank_Program_InActivation_Check','Bypass_Account_Program_based_Sharing','Bypass_Bank_ABM_Sharing','Bypass_Claims_Sharing_Internal_Users'}, true, false));
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing'}, true, false));                 
        Database.insert(transactions);
        
        //Create Channel Program
        ChannelProgram ccfCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
       // Highlight: Unused Local Variable - Indira
       // ChannelProgram rmfCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', true);
        
        //Create Intel Account
        List<Account> intelAccList = new List<Account>();
        List<Account> intelAccListtobeupdated = new List<Account>();
        Account recoveryIntelAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery Test Account', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        recoveryIntelAcc.BillingCity = 'Recovery City';         
        recoveryIntelAcc.BillingCountry= 'IND';
        recoveryIntelAcc.BillingStreet= 'Recovery Street';
        recoveryIntelAcc.Core_MDF_CoMarketingActive__c = true;
        intelAccList.add(recoveryIntelAcc);
        Account recoveryIntelAcc2 = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery Test Account 2', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        recoveryIntelAcc2.BillingCity = 'Recovery City 2';         
        recoveryIntelAcc2.BillingCountry= 'IND';
        recoveryIntelAcc2.BillingStreet= 'Recovery Street 2';
        recoveryIntelAcc2.Core_MDF_CoMarketingActive__c = true;
        //recoveryIntelAcc2.IsPartner = true;
        intelAccList.add(recoveryIntelAcc2);
        Database.insert(intelAccList);
        
        //Create Virtual Corp
        List<Account> virtualAccList = new List<Account>();
        Account recoveryCCFVC = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery CCF Virtual Corp', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        recoveryCCFVC.Core_MDF_Parent_Fund_Account__c = recoveryIntelAcc.Id;
        recoveryCCFVC.Core_MDF_CoMarketingActive__c = true;
        //recoveryCCFVC.IsPartner = true;
        insert recoveryCCFVC;
        Account recoveryCCFEMEA = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery CCF EMEA', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        recoveryCCFEMEA.Core_MDF_Parent_Fund_Account__c = recoveryCCFVC.Id;
        recoveryCCFEMEA.Core_MDF_Active_Ind__c = true;
        //recoveryCCFEMEA.IsPartner = true;
        insert recoveryCCFEMEA;
        Account recoveryCCFVC2 = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery CCF Virtual Corp 2', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        recoveryCCFVC2.Core_MDF_Parent_Fund_Account__c = recoveryIntelAcc2.Id;
        recoveryCCFVC2.Core_MDF_CoMarketingActive__c = true;
        recoveryCCFVC2.Core_MDF_CoMarketing_Ultimate_Account__c = recoveryIntelAcc2.Id;
        recoveryCCFVC2.Core_MDF_Active_Ind__c = true;
        // recoveryCCFVC2.IsPartner = true;
        virtualAccList.add(recoveryCCFVC2);
        
        Account recoveryEMEAFrance = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery CCF EMEA France', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        recoveryEMEAFrance.Core_MDF_Parent_Fund_Account__c = recoveryCCFEMEA.Id;
        //recoveryEMEAFrance.Core_MDF_Auto_Transfer_Account__c = recoveryCCFVC.Id;
        recoveryEMEAFrance.Core_MDF_CoMarketing_Ultimate_Account__c = recoveryIntelAcc.Id;
        //recoveryEMEAFrance.Core_MDF_Enabled_Auto_Transfer__c = True;
        recoveryEMEAFrance.Core_MDF_CoMarketingActive__c = true;
        recoveryEMEAFrance.Core_MDF_Active_Ind__c = true;
        //virtualAccList.add(recoveryEMEAFrance);
        Database.insert(virtualAccList);
        insert recoveryEMEAFrance;
        recoveryIntelAcc.IsPartner = true;
        recoveryIntelAcc2.IsPartner = true;
        recoveryCCFVC.IsPartner = true;
        recoveryCCFVC2.IsPartner = true;
        recoveryEMEAFrance.IsPartner = true;
        intelAccListtobeupdated.add(recoveryIntelAcc);
        intelAccListtobeupdated.add(recoveryIntelAcc2);
        intelAccListtobeupdated.add(recoveryCCFVC);
        intelAccListtobeupdated.add(recoveryCCFVC2);
        intelAccListtobeupdated.add(recoveryEMEAFrance);
        Database.update(intelAccListtobeupdated);
        
        List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
        PartnerMarketingBudget  recoveryPmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Recovery PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,recoveryCCFVC.Id,ccfCP.Id,100000,System.today().addDays(-10),System.today().addDays(10),false);
        recoveryPmbRecord.Core_MDF_Budget_Type_Txt__c ='OEM CMP';
        pmbList.add(recoveryPmbRecord);
        PartnerMarketingBudget  recoveryPmbRecord2 = Core_MDF_CCP_TestDataUtility.createBudget('Recovery PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,recoveryCCFVC2.Id,ccfCP.Id,100000,System.today().addDays(-10),System.today().addDays(10),false);
        recoveryPmbRecord2.Core_MDF_Budget_Type_Txt__c ='OEM CMP';
        pmbList.add(recoveryPmbRecord2);
        Database.insert(pmbList);
        
        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
        PartnerFundAllocation pfaRecoveryCCFFrance = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaRecoveryCCFFrance',recoveryPmbRecord, recoveryEMEAFrance, 1000, false);
        PartnerFundAllocation pfarecoveryCCFVC2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfarecoveryCCFVC2',recoveryPmbRecord2, recoveryCCFVC2, 1000, false);
        pfaList.add(pfaRecoveryCCFFrance);
        pfaList.add(pfarecoveryCCFVC2);
        Database.insert(pfaList);
        List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
        Core_MDF_Bank__c recoveryBank = Core_MDF_CCP_TestDataUtility.createBank(recoveryIntelAcc.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
        Core_MDF_Bank__c recoveryBank2 = Core_MDF_CCP_TestDataUtility.createBank(recoveryIntelAcc2.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231231');
        bankList.add(recoveryBank);
        bankList.add(recoveryBank2);
        Database.insert(bankList);
        // Highlight: Unused Local Variable - Indira
       // Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(recoveryEMEAFrance.Id,recoveryBank.Id,true);
       // Core_MDF_Account_Bank_Mapping__c abm2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(recoveryCCFVC2.Id,recoveryBank2.Id,true);
        Test.startTest();
        List<Campaign> campList = new List<Campaign>();
        Campaign recoveryCamp = Core_MDF_CCP_TestDataUtility.createCampaign('ARP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', recoveryCCFVC.Id, '2-in-1', false);
        recoveryCamp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF;MDF+';
        recoveryCamp.Core_MDF_Supports_legacy_program__c='MDF or both CMP & MDF';
        Campaign recoveryCamp2 = Core_MDF_CCP_TestDataUtility.createCampaign('ARP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', recoveryCCFVC2.Id, '2-in-1', false);
        recoveryCamp2.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF;MDF+';
        recoveryCamp2.Core_MDF_Supports_legacy_program__c='MDF or both CMP & MDF';
        campList.add(recoveryCamp);
        campList.add(recoveryCamp2);
        Database.insert(campList);
        
        List<Core_MDF_Campaign_Budgets__c> campBudgList = new List<Core_MDF_Campaign_Budgets__c>();
        Core_MDF_Campaign_Budgets__c campBudget = new Core_MDF_Campaign_Budgets__c();
        campBudget.Core_MDF_Budget_Name_Id__c = recoveryPmbRecord.id;
        campBudget.Core_MDF_Campaign_Id__c=recoveryCamp.id;
        campBudget.Core_MDF_Budget_Amt__c=363636;
        campBudget.Core_MDF_Reimbursement_Rate_Pct__c='55%';
        campBudget.Core_MDF_Reimbursement_Amt__c= 200000;
        campBudget.Core_MDF_Active_ind__c=true;
        Core_MDF_Campaign_Budgets__c campBudget2 = new Core_MDF_Campaign_Budgets__c();
        campBudget2.Core_MDF_Budget_Name_Id__c = recoveryPmbRecord.id;
        campBudget2.Core_MDF_Campaign_Id__c=recoveryCamp.id;
        campBudget2.Core_MDF_Budget_Amt__c=363636;
        campBudget2.Core_MDF_Reimbursement_Rate_Pct__c='55%';
        campBudget2.Core_MDF_Reimbursement_Amt__c= 200000;
        campBudget2.Core_MDF_Active_ind__c=true;
        campBudgList.add(campBudget);
        campBudgList.add(campBudget2);
        Database.insert(campBudgList);
        
        List<Core_MDF_Configuration__c> configMDF = new List<Core_MDF_Configuration__c>();
        Core_MDF_Configuration__c configPS = new Core_MDF_Configuration__c();
        
        configPS.Core_MDF_Value__c = '10';
        
        configPS.Name = 'Core_MDF_PScore_Edit_Buffer_Days';
        
        configMDF.add(configPS);
        
        Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
        config.NAME = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        config.Core_MDF_Value__c='3';
        config.Core_MDF_Category__c ='Bank Document Hold Logic';
        configMDF.add(config);
        
        Core_MDF_Configuration__c config1 = new Core_MDF_Configuration__c();
        config1.NAME = 'Core_MDF_RecoveryClaimUpdateBatch_Size';
        config1.Core_MDF_Value__c='30';
        config1.Core_MDF_Category__c ='	Claim Recovery';
        configMDF.add(config1);
        insert configMDF;
        Core_MDF_Configuration__c confign = new Core_MDF_Configuration__c();
		confign.Core_MDF_Value__c = '1000';
        confign.Name = 'Core_MDF_PScore_Edit_Buffer_Days';
		insert confign;
        
        
        
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        PartnerFundRequest recoveryFranceActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(recoveryCamp.Id), 
                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                          String.valueof(recoveryEMEAFrance.id),pfaRecoveryCCFFrance,recoveryPmbRecord,'INDIA',
                                                                                                          'Consumer',
                                                                                                          'Desktop',
                                                                                                          'Intel® Core™ i5 Processor',
                                                                                                          'Broadcast (Pre-2025)',
                                                                                                          'Podcast',
                                                                                                          'Draft',
                                                                                                          false);
        recoveryFranceActivity.Title = 'France Activity';
        recoveryFranceActivity.Core_MDF_Activity_Description__c = 'France Activity';
        recoveryFranceActivity.Core_MDF_Start_Date__c = System.today().addDays(-2);
        recoveryFranceActivity.Core_MDF_End_Date__c = System.today().addDays(+2);
        recoveryFranceActivity.RequestedAmount = 1000;
        recoveryFranceActivity.Core_MDF_pagespayingfor__c = 15;
        recoveryFranceActivity.Amount=1000;
        recoveryFranceActivity.Core_MDF_Budget_Type_nm__c= 'MDF';
        recoveryFranceActivity.Core_MDF_Reimbursement_Rate_pct__c='50%';
        recoveryFranceActivity.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        recoveryFranceActivity.Core_MDF_Channel_Partner_Led__c = true;
        
        PartnerFundRequest recoveryFranceActivity2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(recoveryCamp2.Id), 
                                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                           String.valueof(recoveryCCFVC2.id),pfarecoveryCCFVC2,recoveryPmbRecord2,'INDIA',
                                                                                                           'Consumer',
                                                                                                           'Desktop',
                                                                                                           'Intel® Core™ i5 Processor',
                                                                                                           'Broadcast (Pre-2025)',
                                                                                                           'Podcast',
                                                                                                           'Draft',
                                                                                                           false);
        recoveryFranceActivity2.Title = 'France Activity 2';
        recoveryFranceActivity2.Core_MDF_Activity_Description__c = 'France Activity';
        recoveryFranceActivity2.Core_MDF_Start_Date__c = System.today().addDays(-2);
        recoveryFranceActivity2.Core_MDF_End_Date__c = System.today().addDays(+2);
        recoveryFranceActivity2.RequestedAmount = 1000;
        recoveryFranceActivity2.Core_MDF_pagespayingfor__c = 15;
        recoveryFranceActivity2.Amount=1000;
        recoveryFranceActivity2.Core_MDF_Budget_Type_nm__c= 'MDF';
        recoveryFranceActivity2.Core_MDF_Reimbursement_Rate_pct__c='50%';
        recoveryFranceActivity2.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        recoveryFranceActivity2.Core_MDF_Channel_Partner_Led__c = true;
        
        
        PartnerFundRequest recoveryFranceActivityMDFP = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(recoveryCamp.Id), 
                                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                              String.valueof(recoveryEMEAFrance.id),pfaRecoveryCCFFrance,recoveryPmbRecord,'INDIA',
                                                                                                              'Consumer',
                                                                                                              'Desktop',
                                                                                                              'Intel® Core™ i5 Processor',
                                                                                                              'Broadcast (Pre-2025)',
                                                                                                              'Podcast',
                                                                                                              'Draft',
                                                                                                              false);
        recoveryFranceActivityMDFP.Title = 'France Activity SP';
        recoveryFranceActivityMDFP.Core_MDF_Activity_Description__c = 'France Activity SP';
        recoveryFranceActivityMDFP.Core_MDF_Start_Date__c = System.today().addDays(-2);
        recoveryFranceActivityMDFP.Core_MDF_End_Date__c = System.today().addDays(+2);
        recoveryFranceActivityMDFP.RequestedAmount = 1000;
        recoveryFranceActivityMDFP.Core_MDF_pagespayingfor__c = 15;
        recoveryFranceActivityMDFP.Amount=1000;
        recoveryFranceActivityMDFP.Core_MDF_Budget_Type_nm__c= 'MDF+';
        recoveryFranceActivityMDFP.Core_MDF_Reimbursement_Rate_pct__c='50%';
        recoveryFranceActivityMDFP.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        recoveryFranceActivityMDFP.Core_MDF_Channel_Partner_Led__c = true;
        pfrList.add(recoveryFranceActivity);
        pfrList.add(recoveryFranceActivity2);
        pfrList.add(recoveryFranceActivityMDFP);
        
        Database.insert(pfrList);
        
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        PartnerFundClaim recoveryClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,recoveryFranceActivity.Id,
                                                                                   recoveryFranceActivity.Core_MDF_Start_Date__c, 
                                                                                   recoveryFranceActivity.Core_MDF_Start_Date__c,300,System.today(),null,false);
        recoveryClaim1.Core_MDF_PIC_Review_Completed__c = true;
        recoveryClaim1.Core_MDF_BackendReviewSelection_Ind__c = false;
        recoveryClaim1.Amount = 300;
        recoveryClaim1.Core_MDF_Currency__c='USD'; 
        pfcList.add(recoveryClaim1);
        
        PartnerFundClaim recoveryClaimAcc2 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim 2', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,recoveryFranceActivity2.Id,
                                                                                      recoveryFranceActivity2.Core_MDF_Start_Date__c, 
                                                                                      recoveryFranceActivity2.Core_MDF_Start_Date__c,300,System.today(),null,false);
        recoveryClaimAcc2.Core_MDF_PIC_Review_Completed__c = true;
        recoveryClaimAcc2.Core_MDF_BackendReviewSelection_Ind__c = false;
        recoveryClaimAcc2.Amount = 300;
        recoveryClaimAcc2.Core_MDF_Currency__c='USD'; 
        pfcList.add(recoveryClaimAcc2); 
        
        PartnerFundClaim recoveryClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,recoveryFranceActivity.Id,
                                                                                   recoveryFranceActivity.Core_MDF_Start_Date__c, 
                                                                                   recoveryFranceActivity.Core_MDF_Start_Date__c,300,System.today(),null,false);
        recoveryClaim2.Core_MDF_PIC_Review_Completed__c = true;
        recoveryClaim2.Core_MDF_BackendReviewSelection_Ind__c = false;
        recoveryClaim2.Amount = 30;
        recoveryClaim2.Core_MDF_Currency__c='USD'; 
        pfcList.add(recoveryClaim2);
        Test.stopTest();
        
        PartnerFundClaim recoveryClaimSP = Core_MDF_CCP_TestDataUtility.createClaim('France Claim SP', 
                                                                                    Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,recoveryFranceActivityMDFP.Id,
                                                                                    recoveryFranceActivity.Core_MDF_Start_Date__c, 
                                                                                    recoveryFranceActivity.Core_MDF_Start_Date__c,300,System.today(),null,false);
        recoveryClaimSP.Core_MDF_Document_Submission_Missed_Ind__c = true;
        recoveryClaimSP.Amount = 300;
        recoveryClaimSP.Core_MDF_Currency__c='USD'; 
        pfcList.add(recoveryClaimSP);
        Database.insert(pfcList);
        Core_MDF_Partnership_Score__c partnershipScore = new Core_MDF_Partnership_Score__c();
        partnershipScore.Core_MDF_Account_Id__c = recoveryIntelAcc.id;
        partnershipScore.Core_MDF_Channel_Program_Id__c  = ccfCP.Id;
        partnershipScore.Core_MDF_Quarter_Year_Nm__c = 'Q3 2023';
        partnershipScore.Core_MDF_Zone_nm__c = 'A3';
        partnershipScore.Core_MDF_Quarter_nm__c = 'Q3';
        partnershipScore.Core_MDF_Year_nm__c  = '2023';
        partnershipScore.Core_MDF_External_Id__c = string.valueof(ccfCP.Id) + string.valueof(recoveryIntelAcc.id) + 'Q3 2023';
        insert partnershipScore;
        
        Core_MDF_Partnership_Score__c partnershipScore2 = new Core_MDF_Partnership_Score__c();
        partnershipScore2.Core_MDF_Account_Id__c = recoveryIntelAcc2.id;
        partnershipScore2.Core_MDF_Channel_Program_Id__c  = ccfCP.Id;
        partnershipScore2.Core_MDF_Quarter_Year_Nm__c = 'Q2 2023';
        partnershipScore2.Core_MDF_Zone_nm__c = 'A3';
        partnershipScore2.Core_MDF_Quarter_nm__c = 'Q2';
        partnershipScore2.Core_MDF_Carry_Over_Amt__c = 5;
        partnershipScore2.Core_MDF_Year_nm__c  = '2023';
        partnershipScore2.Core_MDF_External_Id__c = string.valueof(ccfCP.Id) + string.valueof(recoveryIntelAcc2.id) +  'Q2 2023';
        insert partnershipScore2;
        
        List<Core_MDF_Partnership_Score_Detail__c> psdList = new List<Core_MDF_Partnership_Score_Detail__c>();
        Core_MDF_Partnership_Score_Detail__c psd1 = new Core_MDF_Partnership_Score_Detail__c();
        psd1.Core_MDF_Budget_Type_nm__c = 'MDF';
        psd1.Core_MDF_Region_Cd__c = 'APJ';
        psd1.Core_MDF_Recovered_Amt__c=0.00;
        psd1.Core_MDF_Partnership_Score_Id__c = partnershipScore.Id;
        psd1.Core_MDF_External_Id__c = string.valueof(ccfCP.Id) + string.valueof(partnershipScore.Core_MDF_Account_Id__c) + 'Q2 2023'+'MDF'+'APJ';
        psdList.add(psd1);  
        
        Core_MDF_Partnership_Score_Detail__c psd2 = new Core_MDF_Partnership_Score_Detail__c();
        psd2.Core_MDF_Budget_Type_nm__c = 'MDF';
        psd2.Core_MDF_Region_Cd__c = 'ASMO';
        psd2.Core_MDF_Recovered_Amt__c=0.00;
        psd2.Core_MDF_Partnership_Score_Id__c = partnershipScore.Id;
        psd2.Core_MDF_External_Id__c = string.valueof(ccfCP.Id) + string.valueof(partnershipScore.Core_MDF_Account_Id__c) + 'Q2 2023'+'MDF'+'ASMO';
        psdList.add(psd2);
        Core_MDF_Partnership_Score_Detail__c psd3 = new Core_MDF_Partnership_Score_Detail__c();
        psd3.Core_MDF_Budget_Type_nm__c = 'MDF+';
        psd3.Core_MDF_Region_Cd__c = 'ASMO';
        psd3.Core_MDF_Recovered_Amt__c =0.00;
        psd3.Core_MDF_Partnership_Score_Id__c = partnershipScore.Id;
        psd3.Core_MDF_External_Id__c = string.valueof(ccfCP.Id) + string.valueof(partnershipScore.Core_MDF_Account_Id__c) + 'Q2 2023'+'MDF+'+'ASMO';
        psdList.add(psd3);
        Core_MDF_Partnership_Score_Detail__c psd4 = new Core_MDF_Partnership_Score_Detail__c();
        psd4.Core_MDF_Budget_Type_nm__c = 'MDF';
        psd4.Core_MDF_Region_Cd__c = 'APJ';
        psd4.Core_MDF_Recovered_Amt__c=0.00;
        psd4.Core_MDF_Partnership_Score_Id__c = partnershipScore2.Id;
        psd4.Core_MDF_External_Id__c = string.valueof(ccfCP.Id) + string.valueof(partnershipScore2.Core_MDF_Account_Id__c) + 'Q2 2023'+'MDF'+'APJ';
        psdList.add(psd4);  
        insert psdList;
        List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        for(PartnerFundClaim claim:[select id,Core_MDF_Status__c,Core_MDF_Region_Cd__c from PartnerFundClaim limit 1]){ //ATHR Fix - WW16
            claim.Core_MDF_Status__c = 'Payment Due';
            claimList.add(claim);
        }
        Database.update(claimList);
    }}
    
    @isTest static void testRecoveryBatch1() {
        Test.startTest(); 
        Set<Id> claimIdSet = new Set<Id>();
        for(PartnerFundClaim claim : [select Id,Core_MDF_Status__c,Core_MDF_Region_Cd__c, Amount from PartnerFundClaim limit 1]) //ATHR Fix - WW16
        {
            claimIdSet.add(claim.Id);
        }
        // Highlight: Unused Local Variable - Indira
      /*  final List<Core_MDF_Partnership_Score__c> psList =[Select Id, Core_MDF_Account_Id__c,Core_MDF_Program_nm__c, Core_MDF_Quarter_Year_Nm__c, Core_MDF_Balance_Amount_Amt__c
             From Core_MDF_Partnership_Score__c Where Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund'  
             and Core_MDF_Quarter_Year_Nm__c = 'Q2 2023']; //and Core_MDF_Balance_Amount_Amt__c > 0];  */
        final Core_MDF_Recovery_Batch obj = new Core_MDF_Recovery_Batch('Client CoMarketing Fund','MDF','Q2 2023');
        Assert.areEqual('Client CoMarketing Fund',obj.program,'Expected');
        database.executeBatch(obj);
        Test.stopTest();
    }
    
    @isTest static void testRecoveryBatch2() {
        Test.startTest();
        Set<Id> claimIdSet = new Set<Id>();
        List<id> accountIds = new List<id>();
        Account accountRecord = [select id from Account limit 1];
        // Highlight: Unused Local Variable - Indira
       // List<PartnerFundClaim> claim = [select id from PartnerFundClaim where Core_MDF_Budget_Type_Options_Nm__c = 'MDF' limit 2];
        PartnerFundClaim claim2 = [select id from PartnerFundClaim where Core_MDF_Budget_Type_Options_Nm__c = 'MDF+' limit 1];
        accountIds.add(accountRecord.id);
        
        
        Core_MDF_Recovery_Request__c rr = new Core_MDF_Recovery_Request__c();
        rr.Core_MDF_Claim_Id__c = claim2.id;
        rr.Core_MDF_Account_Id__c = accountRecord.id;
        rr.Core_MDF_Recovery_Amount_Amt__c = 100;
        rr.Core_MDF_Program_Nm__c = 'Client CoMarketing Fund';
        rr.Core_MDF_Quarter_Year_Nm__c = 'Q2 2023';
        rr.Core_MDF_Active_Ind__c = true;
        rr.Core_MDF_Ready_to_Recover_Ind__c = true;
        rr.Core_MDF_Recovered_Budget_Nm__c = 'MDF+;ASMO=100';
        rr.Core_MDF_Claim_External_ID__c = claim2.id;
        // rrList.add(rr);
        Assert.areEqual(rr.Core_MDF_Program_Nm__c, 'Client CoMarketing Fund');
        
        Database.insert(rr);
        claimIdSet.add(claim2.id);
        List<Core_MDF_Partnership_Score_Detail__c> detailist2 = [Select Id, Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Region_Cd__c,Core_MDF_Budget_Type_nm__c, Core_MDF_Quarter_Year_Nm__c,Core_MDF_Partnership_Score_Id__c,Core_MDF_Recovered_Amt__c
                                                                 From Core_MDF_Partnership_Score_Detail__c Where Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund' and Core_MDF_Budget_Type_nm__c = 'MDF+' and Core_MDF_Quarter_Year_Nm__c = 'Q2 2023'];
        Core_MDF_Recovery_Batch obj = new Core_MDF_Recovery_Batch('Client CoMarketing Fund',  ''    ,  '',  '', '', 'Payment Run', False, False);
        database.executeBatch(obj);
        Core_MDF_Recovery_Batch obj3 = new Core_MDF_Recovery_Batch('Intel Partner Alliance',  ''    ,  '',  '', 'APJ', 'Payment Run', False, False);
        database.executeBatch(obj3);
        Core_MDF_Recovery_Batch obj4 = new Core_MDF_Recovery_Batch('Retail Marketing Funds',  ''    ,  '');
        database.executeBatch(obj4);
        // Highlight: Unused Local Variable - Indira
       // String acc =  accountIds.toString();
        Core_MDF_Recovery_Batch obj5 = new Core_MDF_Recovery_Batch('Retail Marketing Funds',  '' ,''   , '');
        database.executeBatch(obj5);
        Core_MDF_Recovery__c recoveryObj = new Core_MDF_Recovery__c();
            recoveryObj.Core_MDF_Amount_Amt__c = 10;
            recoveryObj.Core_MDF_Claim_Id__c = claim2.id;
        if(detailist2.size()>0){
            recoveryObj.Core_MDF_PartnershipGradeMaintenance_Nbr__c = detailist2[0].Core_MDF_Partnership_Score_Id__c;
        }
        insert recoveryObj;
        List<RecoveryRecoveryRequestWrap> finalRecoveryList = new List<RecoveryRecoveryRequestWrap>();
        
        RecoveryRecoveryRequestWrap wrapperForRecoveryRecreq = new RecoveryRecoveryRequestWrap();
        //wrapperForRecoveryRecreq.recovery=recoveryObj;
        wrapperForRecoveryRecreq.recRequest=rr;
        
        finalRecoveryList.add(wrapperForRecoveryRecreq);
        
        Core_MDF_Batch_UpdateRecoveryClaims obj2 = new Core_MDF_Batch_UpdateRecoveryClaims(finalRecoveryList);
        database.executeBatch(obj2);
        //Core_MDF_Batch_UpdateRecoveryClaims(finalRecoveryList);
        Test.stopTest();
        //Core_MDF_Recovery_Utility.updatePartnershipScoreDetailMapping(claimIdSet);  
    }   
}