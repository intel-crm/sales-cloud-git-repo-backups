@isTest(SeeAllData=false)
public class Core_MDF_Recovery_Utility_Test {
    @TestSetup
    static void makeData() {
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        insert usr;
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User';
        testUser.UserRoleId = usRole.Id;
        Database.insert(testUser);
        
        
        Map<String,String> psNamToIdMap = new Map<String, String>();
        for(PermissionSet payAdmPS : [SELECT Id, Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_CCF_Payment_Adm','Core_MDF_CCP_Internal_Retail_Payment_Adm','Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr')]){
            psNamToIdMap.put(payAdmPS.Name, payAdmPS.Id);
        }
        //userList.add(usr1);
        // Creating User with utility class 
        User paymentAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
        paymentAdmin.LastName = 'Payment Admin';
        //paymentAdmin.UserRoleId = usRole.Id;
        insert paymentAdmin;
        
        List<PermissionSetAssignment> psAssignmentList = new List<PermissionSetAssignment>();
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = paymentAdmin.Id;
        assignPermissionSetObj1.PermissionSetId = psNamToIdMap.get('Core_MDF_CCP_Internal_CCF_Payment_Adm');
        psAssignmentList.add(assignPermissionSetObj1);
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = paymentAdmin.Id;
        assignPermissionSetObj2.PermissionSetId = psNamToIdMap.get('Core_MDF_CCP_Internal_Retail_Payment_Adm');
        psAssignmentList.add(assignPermissionSetObj2);
        PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();
        assignPermissionSetObj3.AssigneeId = testUser.Id;
        assignPermissionSetObj3.PermissionSetId = psNamToIdMap.get('Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr');
        psAssignmentList.add(assignPermissionSetObj3);
        system.runas(usr){
            insert psAssignmentList;
        }
        
        List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing'}, true, false));       
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Allocation_Reservation','Bypass_GeoBased_Allocation_Sharing'}, true, false));   
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Bank_Check','Bypass_Bank_Internal_Sharing',
            'Bypass_Bank_External_Sharing','Bypass_Bank_Program_InActivation_Check','Bypass_Account_Program_based_Sharing','Bypass_Bank_ABM_Sharing','Bypass_Claims_Sharing_Internal_Users'}, true, false));
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing','Bypass_ValidatePartnerScoreforUpdate'}, true, false));                 
        
        System.RunAs(testUser){
            Database.insert(transactions);
            
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            Core_MDF_Configuration__c config9 = new Core_MDF_Configuration__c();
            config9.Core_MDF_Value__c = '30';
            config9.Name = 'Core_MDF_RecoveryClaimUpdateBatch_Size';
            insert config9;
            //Create Channel Program
            ChannelProgram ccfCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            ChannelProgram retCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', true);
            
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
            //adding intel acc for rmf
            Account recoveryIntelAccRMF = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery Test Account RMF', NULL, Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);   
            recoveryIntelAccRMF.BillingCity = 'Recovery City 6';         
            recoveryIntelAccRMF.BillingCountry= 'IND';
            recoveryIntelAccRMF.BillingStreet= 'Recovery Street 2';
            recoveryIntelAccRMF.Core_MDF_CoMarketingActive__c = true;
            recoveryIntelAccRMF.Core_Geo__c = 'APJ';
            //recoveryIntelAcc2.IsPartner = true;
            intelAccList.add(recoveryIntelAccRMF);
            Database.insert(intelAccList);
            
            //Create Virtual Corp
            List<Account> virtualAccList = new List<Account>();
            Account recoveryCCFVC = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery CCF Virtual Corp', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            recoveryCCFVC.Core_MDF_Parent_Fund_Account__c = recoveryIntelAcc.Id;
            recoveryCCFVC.Core_MDF_CoMarketingActive__c = true;
            //recoveryCCFVC.IsPartner = true;
            //virtualAccList.add(recoveryCCFVC);
            insert recoveryCCFVC;
            Account recoveryCCFEMEA = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery CCF EMEA', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            recoveryCCFEMEA.Core_MDF_Parent_Fund_Account__c = recoveryCCFVC.Id;
            recoveryCCFEMEA.Core_MDF_Active_Ind__c = true;
            //recoveryCCFEMEA.IsPartner = true;
            //virtualAccList.add(recoveryCCFEMEA);
            insert recoveryCCFEMEA;
            Account recoveryCCFVC2 = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery CCF Virtual Corp 2', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            recoveryCCFVC2.Core_MDF_Parent_Fund_Account__c = recoveryIntelAcc2.Id;
            recoveryCCFVC2.Core_MDF_CoMarketingActive__c = true;
            recoveryCCFVC2.Core_MDF_CoMarketing_Ultimate_Account__c = recoveryIntelAcc2.Id;
            recoveryCCFVC2.Core_MDF_Active_Ind__c = true;
            // recoveryCCFVC2.IsPartner = true;
            virtualAccList.add(recoveryCCFVC2);
            //RMF Account
            Account recoveryRetVC = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery RMF Virtual Corp', retCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            recoveryRetVC.Core_MDF_Parent_Fund_Account__c = recoveryIntelAccRMF.Id;
            recoveryRetVC.Core_MDF_CoMarketingActive__c = true;
            recoveryRetVC.Core_MDF_CoMarketing_Ultimate_Account__c = recoveryIntelAccRMF.Id;
            recoveryRetVC.Core_MDF_Active_Ind__c = true;
            recoveryRetVC.Core_Geo__c = 'APJ';
            virtualAccList.add(recoveryRetVC);
            
            Account recoveryEMEAFrance = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery CCF EMEA France', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            recoveryEMEAFrance.Core_MDF_Parent_Fund_Account__c = recoveryCCFEMEA.Id;
            //recoveryEMEAFrance.Core_MDF_Auto_Transfer_Account__c = recoveryCCFVC.Id;
            recoveryEMEAFrance.Core_MDF_CoMarketing_Ultimate_Account__c = recoveryIntelAcc.Id;
            //recoveryEMEAFrance.Core_MDF_Enabled_Auto_Transfer__c = True;
            recoveryEMEAFrance.Core_MDF_CoMarketingActive__c = true;
            recoveryEMEAFrance.Core_MDF_Active_Ind__c = true;
            virtualAccList.add(recoveryEMEAFrance);
            Database.insert(virtualAccList);
            
            recoveryIntelAcc.IsPartner = true;
            recoveryIntelAcc2.IsPartner = true;
            recoveryCCFVC.IsPartner = true;
            recoveryCCFVC2.IsPartner = true;
            recoveryEMEAFrance.IsPartner = true;
            recoveryRetVC.IsPartner = true;
            intelAccListtobeupdated.add(recoveryIntelAcc);
            intelAccListtobeupdated.add(recoveryIntelAcc2);
            intelAccListtobeupdated.add(recoveryCCFVC);
            intelAccListtobeupdated.add(recoveryCCFVC2);
            intelAccListtobeupdated.add(recoveryEMEAFrance);
            Database.update(intelAccListtobeupdated);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Account_id__c = recoveryCCFVC2.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr';
            iupgm.Core_MDF_Program_nm__c = Core_MDF_CCP_ConstantClass.CCF_TECHNICAL_PROGRAM_NAME;
            iupgm.Core_MDF_User_id__c = testUser.Id;
            iupgm.Core_MDF_Active_Ind__c = true;
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
            iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Account Plan';
            insert iupgm;
            
            List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget  recoveryPmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Recovery PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,recoveryCCFVC.Id,ccfCP.Id,100000,System.today().addDays(-10),System.today().addDays(10),false);
            recoveryPmbRecord.Core_MDF_Budget_Type_Txt__c ='OEM CMP';
            pmbList.add(recoveryPmbRecord);
            PartnerMarketingBudget  recoveryPmbRecord2 = Core_MDF_CCP_TestDataUtility.createBudget('Recovery PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,recoveryCCFVC2.Id,ccfCP.Id,100000,System.today().addDays(-10),System.today().addDays(10),false);
            recoveryPmbRecord2.Core_MDF_Budget_Type_Txt__c ='OEM CMP';
            pmbList.add(recoveryPmbRecord2);
            //adding for RMF
            PartnerMarketingBudget  recoveryPmbRecordforRMF = Core_MDF_CCP_TestDataUtility.createBudget('Recovery PMB RMF',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,recoveryRetVC.Id,retCP.Id,100000,System.today().addDays(-10),System.today().addDays(10),false);
            recoveryPmbRecordforRMF.Core_MDF_Budget_Type_Txt__c ='Retail MDF';
            pmbList.add(recoveryPmbRecordforRMF);
            Database.insert(pmbList);
            
            List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
            PartnerFundAllocation pfaRecoveryCCFFrance = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaRecoveryCCFFrance',recoveryPmbRecord, recoveryEMEAFrance, 1000, false);
            PartnerFundAllocation pfarecoveryCCFVC2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfarecoveryCCFVC2',recoveryPmbRecord2, recoveryCCFVC2, 1000, false);
            PartnerFundAllocation pfarecoveryRetVC = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfarecoveryRetVC',recoveryPmbRecordforRMF, recoveryRetVC, 1000, false);
            pfaList.add(pfaRecoveryCCFFrance);
            pfaList.add(pfarecoveryCCFVC2);
            pfaList.add(pfarecoveryRetVC);
            Database.insert(pfaList);
            List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
            Core_MDF_Bank__c recoveryBank = Core_MDF_CCP_TestDataUtility.createBank(recoveryIntelAcc.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
            recoveryBank.Core_MDF_Bank_Status__c = 'Active';
            Core_MDF_Bank__c recoveryBank2 = Core_MDF_CCP_TestDataUtility.createBank(recoveryIntelAcc2.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231231');
            recoveryBank2.Core_MDF_Bank_Status__c = 'Active';
            Core_MDF_Bank__c recoveryBankRMF = Core_MDF_CCP_TestDataUtility.createBank(recoveryIntelAccRMF.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231232');
            recoveryBankRMF.Core_MDF_Intel_Company_Code__c='150';
            recoveryBankRMF.Core_MDF_Tax_codes_cd__c = 'V3';
            recoveryBankRMF.Core_MDF_Bank_Status__c = 'Active';
            bankList.add(recoveryBank);
            bankList.add(recoveryBank2);
            bankList.add(recoveryBankRMF);
            //system.runas(paymentAdmin){
            Database.insert(bankList);
            //}
            
            //update Banklist;
            //Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(recoveryEMEAFrance.Id,recoveryBank.Id,true);
            //Core_MDF_Account_Bank_Mapping__c abm2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(recoveryCCFVC2.Id,recoveryBank2.Id,true);
            //Core_MDF_Account_Bank_Mapping__c abm_rmf = Core_MDF_CCP_TestDataUtility.createAccountBankMap(recoveryIntelAccRMF.Id,recoveryBankRMF.Id,true);
            Test.startTest();
            List<Campaign> campList = new List<Campaign>();
            Campaign recoveryCamp = Core_MDF_CCP_TestDataUtility.createCampaign('ARP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', recoveryCCFVC.Id, '2-in-1', false);
            recoveryCamp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF;MDF+';
            recoveryCamp.Core_MDF_Supports_legacy_program__c='MDF or both CMP & MDF';
            Campaign recoveryCamp2 = Core_MDF_CCP_TestDataUtility.createCampaign('ARP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', recoveryCCFVC2.Id, '2-in-1', false);
            recoveryCamp2.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF;MDF+';
            recoveryCamp2.Core_MDF_Supports_legacy_program__c='MDF or both CMP & MDF';
            Campaign recoveryCampRMF = Core_MDF_CCP_TestDataUtility.createCampaign('RMF Campaign','Gaming','Intel® Core™ i7+ Processor','No', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', recoveryRetVC.Id, '2-in-1', false);
            //recoveryCampRMF.Core_MDF_Opal_Budget_Type_Txt__c = 'Retail MDF';
            //recoveryCampRMF.Core_MDF_Supports_legacy_program__c='Yes';
            recoveryCampRMF.Core_MDF_Budget_Type_txt__c='Retail MDF';
            campList.add(recoveryCamp);
            campList.add(recoveryCamp2);
            campList.add(recoveryCampRMF);
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
            // adding for rmf
            Core_MDF_Campaign_Budgets__c campBudgetRMF = new Core_MDF_Campaign_Budgets__c();
            campBudgetRMF.Core_MDF_Budget_Name_Id__c = recoveryPmbRecordforRMF.id;
            campBudgetRMF.Core_MDF_Campaign_Id__c=recoveryCampRMF.id;
            campBudgetRMF.Core_MDF_Budget_Amt__c=363636;
            campBudgetRMF.Core_MDF_Reimbursement_Rate_Pct__c='50%';
            campBudgetRMF.Core_MDF_Reimbursement_Amt__c= 200000;
            campBudgetRMF.Core_MDF_Active_ind__c=true;
            campBudgList.add(campBudget);
            campBudgList.add(campBudget2);
            campBudgList.add(campBudgetRMF);
            Database.insert(campBudgList);
            
            List<Core_MDF_Configuration__c> configMDF = new List<Core_MDF_Configuration__c>();
            Core_MDF_Configuration__c configPS = new Core_MDF_Configuration__c();
            
            configPS.Core_MDF_Value__c = '1000';
            
            configPS.Name = 'Core_MDF_PScore_Edit_Buffer_Days';
            
            configMDF.add(configPS);
            
            Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
            config.NAME = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            config.Core_MDF_Value__c='3';
            config.Core_MDF_Category__c ='Bank Document Hold Logic';
            configMDF.add(config);
            insert configMDF;
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            PartnerFundRequest recoveryRMFActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(recoveryCampRMF.Id), 
                                                                                                           Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,
                                                                                                           String.valueof(recoveryRetVC.id),pfarecoveryRetVC,recoveryPmbRecordforRMF,'INDIA',
                                                                                                           'Business',
                                                                                                           'Chromebook',
                                                                                                           'Intel® 10ᵗʰ Gen',
                                                                                                           'Broadcast',
                                                                                                           'Podcast',
                                                                                                           'Draft',
                                                                                                           false);
            recoveryRMFActivity.Title = 'RMF Test Activity';
            recoveryRMFActivity.Core_MDF_Activity_Description__c = 'RMF Test Activity';
            recoveryRMFActivity.Core_MDF_Start_Date__c = System.today().addDays(-2);
            recoveryRMFActivity.Core_MDF_End_Date__c = System.today().addDays(+2);
            recoveryRMFActivity.RequestedAmount = 1000;
            recoveryRMFActivity.Core_MDF_pagespayingfor__c = 15;
            recoveryRMFActivity.Amount=1000;
            recoveryRMFActivity.Core_MDF_Budget_Type_nm__c= 'Retail MDF';
            recoveryRMFActivity.Core_MDF_Reimbursement_Rate_pct__c='100%';
            recoveryRMFActivity.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            recoveryRMFActivity.Core_MDF_Channel_Partner_Led__c = true;
            
            PartnerFundRequest recoveryFranceActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(recoveryCamp.Id), 
                                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                              String.valueof(recoveryEMEAFrance.id),pfaRecoveryCCFFrance,recoveryPmbRecord,'INDIA',
                                                                                                              'Consumer',
                                                                                                              'Desktop',
                                                                                                              'Intel® Core™ i5 Processor',
                                                                                                              'Broadcast',
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
                                                                                                               'Broadcast',
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
                                                                                                                  'Broadcast',
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
            pfrList.add(recoveryRMFActivity);
            Database.insert(pfrList);
            Test.stopTest();
            
            List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            String quarter = qtr[1];
            List<String> quarterYear = quarter.split(' ');
            
            List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
            PartnerFundClaim recoveryClaimRMF = Core_MDF_CCP_TestDataUtility.createClaim('RMF Test Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail,recoveryRMFActivity.Id,
                                                                                         recoveryRMFActivity.Core_MDF_Start_Date__c, 
                                                                                         recoveryRMFActivity.Core_MDF_Start_Date__c,300,System.today(),recoveryBankRMF.ID,false);
            recoveryClaimRMF.Core_MDF_PIC_Review_Completed__c = true;
            recoveryClaimRMF.Core_MDF_BackendReviewSelection_Ind__c = false;
            recoveryClaimRMF.Amount = 300;
            recoveryClaimRMF.Core_MDF_Currency__c='USD'; 
            recoveryClaimRMF.Core_MDF_Number_of_Attendees_Nbr__c = 10;
            recoveryClaimRMF.Core_MDF_Country_Location_nm__c = 'INDIA';
            recoveryClaimRMF.Core_MDF_Region_Cd__c='APJ';
            recoveryClaimRMF.Core_MDF_Recovery_Hold_Ind__c = true;
            recoveryClaimRMF.Core_MDF_Type_Txt__c ='Claim';
            recoveryClaimRMF.Core_MDF_VAT_Eligibility_Ind__c = false;
            recoveryClaimRMF.Core_MDF_To_Be_Audited_Ind__c=true;
            recoveryClaimRMF.Core_MDF_Status__c ='Payment Due';
            recoveryClaimRMF.Core_MDF_Quarter_Year_txt__c= quarterYear[0] + '-' + quarterYear[1];
            recoveryClaimRMF.Core_MDF_Ad_Run_Start_Date__c = system.today().addDays(-1);
            recoveryClaimRMF.Core_MDF_Ad_Run_End_Date__c = system.today();
            recoveryClaimRMF.Core_MDF_Country_Location_nm__c= 'GERMANY';
            recoveryClaimRMF.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            recoveryClaimRMF.Core_MDF_Invoice_Date__c = system.today();
            recoveryClaimRMF.Core_MDF_Invoice_Number__c = '123';
            recoveryClaimRMF.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            recoveryClaimRMF.Core_MDF_Taxes_Local__c = 0;
            pfcList.add(recoveryClaimRMF);
            
            PartnerFundClaim recoveryClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,recoveryFranceActivity.Id,
                                                                                       recoveryFranceActivity.Core_MDF_Start_Date__c, 
                                                                                       recoveryFranceActivity.Core_MDF_Start_Date__c,300,System.today(),null,false);
            recoveryClaim1.Core_MDF_PIC_Review_Completed__c = true;
            recoveryClaim1.Core_MDF_BackendReviewSelection_Ind__c = false;
            recoveryClaim1.Amount = 300;
            recoveryClaim1.Core_MDF_Recovery_Hold_Ind__c = true;
            recoveryClaim1.Core_MDF_Currency__c='USD'; 
            recoveryClaim1.Core_MDF_Number_of_Attendees_Nbr__c= 10;
            recoveryClaim1.Core_MDF_Ad_Run_Start_Date__c = system.today().addDays(-1);
            recoveryClaim1.Core_MDF_Ad_Run_End_Date__c = system.today();
            recoveryClaim1.Core_MDF_Country_Location_nm__c= 'GERMANY';
            recoveryClaim1.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            recoveryClaim1.Core_MDF_Invoice_Date__c = system.today();
            recoveryClaim1.Core_MDF_Invoice_Number__c = '123';
            recoveryClaim1.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            recoveryClaim1.Core_MDF_Taxes_Local__c = 0;
            pfcList.add(recoveryClaim1);
            
            PartnerFundClaim recoveryClaimAcc2 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim 2', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,recoveryFranceActivity2.Id,
                                                                                          recoveryFranceActivity2.Core_MDF_Start_Date__c, 
                                                                                          recoveryFranceActivity2.Core_MDF_Start_Date__c,300,System.today(),null,false);
            recoveryClaimAcc2.Core_MDF_PIC_Review_Completed__c = true;
            recoveryClaimAcc2.Core_MDF_BackendReviewSelection_Ind__c = false;
            recoveryClaimAcc2.Amount = 300;
            recoveryClaimAcc2.Core_MDF_Recovery_Hold_Ind__c = true;
            recoveryClaimAcc2.Core_MDF_Currency__c='USD';
            recoveryClaimAcc2.Core_MDF_Number_of_Attendees_Nbr__c= 10;
            recoveryClaimAcc2.Core_MDF_Ad_Run_Start_Date__c = system.today().addDays(-1);
            recoveryClaimAcc2.Core_MDF_Ad_Run_End_Date__c = system.today();
            recoveryClaimAcc2.Core_MDF_Country_Location_nm__c= 'GERMANY';
            recoveryClaimAcc2.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            recoveryClaimAcc2.Core_MDF_Invoice_Date__c = system.today();
            recoveryClaimAcc2.Core_MDF_Invoice_Number__c = '123';
            recoveryClaimAcc2.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            recoveryClaimAcc2.Core_MDF_Taxes_Local__c = 0;
            pfcList.add(recoveryClaimAcc2);
            
            PartnerFundClaim recoveryClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,recoveryFranceActivity.Id,
                                                                                       recoveryFranceActivity.Core_MDF_Start_Date__c, 
                                                                                       recoveryFranceActivity.Core_MDF_Start_Date__c,300,System.today(),null,false);
            recoveryClaim2.Core_MDF_PIC_Review_Completed__c = true;
            recoveryClaim2.Core_MDF_BackendReviewSelection_Ind__c = false;
            recoveryClaim2.Amount = 30;
            recoveryClaim2.Core_MDF_Recovery_Hold_Ind__c = true;
            recoveryClaim2.Core_MDF_Currency__c='USD'; 
            recoveryClaim2.Core_MDF_Number_of_Attendees_Nbr__c= 10;
            recoveryClaim2.Core_MDF_Ad_Run_Start_Date__c = system.today().addDays(-1);
            recoveryClaim2.Core_MDF_Ad_Run_End_Date__c = system.today();
            recoveryClaim2.Core_MDF_Country_Location_nm__c= 'GERMANY';
            recoveryClaim2.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            recoveryClaim2.Core_MDF_Invoice_Date__c = system.today();
            recoveryClaim2.Core_MDF_Invoice_Number__c = '123';
            recoveryClaim2.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            recoveryClaim2.Core_MDF_Taxes_Local__c = 0;
            pfcList.add(recoveryClaim2);
            
            
            PartnerFundClaim recoveryClaimSP = Core_MDF_CCP_TestDataUtility.createClaim('France Claim SP', 
                                                                                        Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,recoveryFranceActivityMDFP.Id,
                                                                                        recoveryFranceActivity.Core_MDF_Start_Date__c, 
                                                                                        recoveryFranceActivity.Core_MDF_Start_Date__c,300,System.today(),null,false);
            recoveryClaimSP.Core_MDF_Document_Submission_Missed_Ind__c = true;
            recoveryClaimSP.Amount = 300;
            recoveryClaimSP.Core_MDF_Currency__c='USD'; 
            recoveryClaimSP.Core_MDF_Number_of_Attendees_Nbr__c= 10;
            recoveryClaimSP.Core_MDF_Ad_Run_Start_Date__c = system.today().addDays(-1);
            recoveryClaimSP.Core_MDF_Ad_Run_End_Date__c = system.today();
            recoveryClaimSP.Core_MDF_Country_Location_nm__c= 'GERMANY';
            recoveryClaimSP.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            recoveryClaimSP.Core_MDF_Invoice_Date__c = system.today();
            recoveryClaimSP.Core_MDF_Invoice_Number__c = '123';
            recoveryClaimSP.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            recoveryClaimSP.Core_MDF_Taxes_Local__c = 0;
            pfcList.add(recoveryClaimSP);
            Database.insert(pfcList);
            
            Core_MDF_Partnership_Score__c partnershipScore = new Core_MDF_Partnership_Score__c();
            partnershipScore.Core_MDF_Account_Id__c = recoveryIntelAcc.id;
            partnershipScore.Core_MDF_Channel_Program_Id__c  = ccfCP.Id;
            partnershipScore.Core_MDF_Quarter_Year_Nm__c = quarter;
            partnershipScore.Core_MDF_Zone_nm__c = 'A3';
            partnershipScore.Core_MDF_Quarter_nm__c = quarterYear[0];
            partnershipScore.Core_MDF_Year_nm__c  = quarterYear[1];
            partnershipScore.Core_MDF_Virtual_Corp_Account_Id__c = recoveryCCFVC.Id;
            partnershipScore.Core_MDF_External_Id__c = string.valueof(ccfCP.Id) + string.valueof(recoveryCCFVC.id) + quarter;
            insert partnershipScore;
            
            Core_MDF_Partnership_Score__c partnershipScore2 = new Core_MDF_Partnership_Score__c();
            partnershipScore2.Core_MDF_Account_Id__c = recoveryIntelAcc2.id;
            partnershipScore2.Core_MDF_Channel_Program_Id__c  = ccfCP.Id;
            partnershipScore2.Core_MDF_Quarter_Year_Nm__c = quarter;
            partnershipScore2.Core_MDF_Zone_nm__c = 'A3';
            partnershipScore2.Core_MDF_Quarter_nm__c = quarterYear[0];
            partnershipScore2.Core_MDF_Year_nm__c  = quarterYear[1];
            partnershipScore2.Core_MDF_Virtual_Corp_Account_Id__c = recoveryCCFVC2.Id;
            partnershipScore2.Core_MDF_External_Id__c = string.valueof(ccfCP.Id) + string.valueof(recoveryCCFVC2.id) + quarter;
            insert partnershipScore2;
            
            Core_MDF_Partnership_Score__c partnershipScoreRMF = new Core_MDF_Partnership_Score__c();
            partnershipScoreRMF.Core_MDF_Account_Id__c = recoveryIntelAccRMF.id;
            partnershipScoreRMF.Core_MDF_Channel_Program_Id__c  = retCP.Id;
            partnershipScoreRMF.Core_MDF_Quarter_Year_Nm__c = quarter;
            partnershipScoreRMF.Core_MDF_Zone_nm__c = 'A3';
            partnershipScoreRMF.Core_MDF_Quarter_nm__c = quarterYear[0];
            partnershipScoreRMF.Core_MDF_Year_nm__c  = quarterYear[1];
            partnershipScoreRMF.Core_MDF_Virtual_Corp_Account_Id__c = recoveryRetVC.Id;
            partnershipScoreRMF.Core_MDF_External_Id__c = string.valueof(ccfCP.Id) + string.valueof(recoveryRetVC.id) + quarter;
            insert partnershipScoreRMF;
            
            List<Core_MDF_Partnership_Score__c> pssList = [select id, Core_MDF_Account_Id__c from Core_MDF_Partnership_Score__c];
            Core_MDF_Partnership_Score__c ps = [select id, Core_MDF_Account_Id__c from Core_MDF_Partnership_Score__c where Core_MDF_Account_Id__r.Name='Recovery Test Account RMF' limit 1];
            List<Core_MDF_Partnership_Score_Detail__c> psdList = new List<Core_MDF_Partnership_Score_Detail__c>();
            
            Core_MDF_Partnership_Score_Detail__c psd_rmf = new Core_MDF_Partnership_Score_Detail__c();
            psd_rmf.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
            psd_rmf.Core_MDF_Carry_Over_Amt__c = 1000;
            psd_rmf.Core_MDF_Region_Cd__c = 'APJ';
            psd_rmf.Core_MDF_Recovered_Amt__c=0.00;
            psd_rmf.Core_MDF_Partnership_Score_Id__c = ps.Id;
            psd_rmf.Core_MDF_Node_Account_Id__c = recoveryRetVC.Id;
            psd_rmf.Core_MDF_External_Id__c = string.valueof(retCP.Id) + string.valueof(recoveryRetVC.Id) + quarter +'Retail MDF'+'APJ';
            psdList.add(psd_rmf); 
            
            Core_MDF_Partnership_Score_Detail__c psd1 = new Core_MDF_Partnership_Score_Detail__c();
            psd1.Core_MDF_Budget_Type_nm__c = 'MDF';
            psd1.Core_MDF_Carry_Over_Amt__c = 1000;
            psd1.Core_MDF_Region_Cd__c = 'APJ';
            psd1.Core_MDF_Recovered_Amt__c=0.00;
            psd1.Core_MDF_Partnership_Score_Id__c = pssList[0].id;
            psd1.Core_MDF_External_Id__c = string.valueof(ccfCP.Id) + string.valueof(pssList[0].Core_MDF_Account_Id__c) + quarter +'MDF'+'APJ';
            psdList.add(psd1);  
            
            Core_MDF_Partnership_Score_Detail__c psd2 = new Core_MDF_Partnership_Score_Detail__c();
            psd2.Core_MDF_Budget_Type_nm__c = 'MDF';
            psd2.Core_MDF_Carry_Over_Amt__c = 1000;
            psd2.Core_MDF_Region_Cd__c = 'ASMO';
            psd2.Core_MDF_Recovered_Amt__c=0.00;
            psd2.Core_MDF_Partnership_Score_Id__c = pssList[0].id;
            psd2.Core_MDF_External_Id__c = string.valueof(ccfCP.Id) + string.valueof(pssList[0].Core_MDF_Account_Id__c) + quarter +'MDF'+'ASMO';
            psdList.add(psd2);
            Core_MDF_Partnership_Score_Detail__c psd3 = new Core_MDF_Partnership_Score_Detail__c();
            psd3.Core_MDF_Budget_Type_nm__c = 'MDF+';
            psd3.Core_MDF_Carry_Over_Amt__c = 1000;
            psd3.Core_MDF_Region_Cd__c = 'ASMO';
            psd3.Core_MDF_Recovered_Amt__c =0.00;
            psd3.Core_MDF_Partnership_Score_Id__c = pssList[0].id;
            psd3.Core_MDF_External_Id__c = string.valueof(ccfCP.Id) + string.valueof(pssList[0].Core_MDF_Account_Id__c) + quarter +'MDF+'+'ASMO';
            psdList.add(psd3);
            
            Core_MDF_Partnership_Score_Detail__c psd4 = new Core_MDF_Partnership_Score_Detail__c();
            psd4.Core_MDF_Budget_Type_nm__c = 'MDF';
            psd4.Core_MDF_Carry_Over_Amt__c = 1000;
            psd4.Core_MDF_Region_Cd__c = 'APJ';
            psd4.Core_MDF_Recovered_Amt__c=0.00;
            psd4.Core_MDF_Partnership_Score_Id__c = pssList[1].id;
            psd4.Core_MDF_External_Id__c = string.valueof(ccfCP.Id) + string.valueof(pssList[1].Core_MDF_Account_Id__c) + quarter +'MDF'+'APJ';
            psdList.add(psd4);  
            insert psdList;
            
            List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
            for(PartnerFundClaim claim:[select id,Core_MDF_Status__c,Core_MDF_Region_Cd__c from PartnerFundClaim]){
                claim.Core_MDF_Status__c = 'Payment Due';
                claimList.add(claim);
            }
            Database.update(claimList);
        }
    }
    
    @isTest static void testRecoveryBatch1() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Assert.areEqual(usr.LastName,'User Test');
        Database.insert(usr);
        system.runAs(usr) {
            Test.startTest(); 
            Set<Id> claimIdSet = new Set<Id>();
            for(PartnerFundClaim claim : [select Id,Core_MDF_Status__c,Core_MDF_Region_Cd__c, Amount from PartnerFundClaim])
            {
                claimIdSet.add(claim.Id);
            }
            
            Core_MDF_Recovery_Batch obj = new Core_MDF_Recovery_Batch('Client CoMarketing Fund','MDF','Q4 2023');
            Id jobId = database.executeBatch(obj);
            
            Core_MDF_Recovery_Batch obj2 = new Core_MDF_Recovery_Batch('Client CoMarketing Fund','','','','','Payment Run',false,false);
            Id jobId2 = database.executeBatch(obj2);
            Test.stopTest();
            /* Core_MDF_Recovery_Utility.updatePartnershipScoreDetailMapping(claimIdSet);
List<Core_MDF_Partnership_Score_Detail__c> detailist = [Select Id, Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c, Core_MDF_Region_Cd__c,Core_MDF_Budget_Type_nm__c, Core_MDF_Quarter_Year_Nm__c,Core_MDF_Partnership_Score_Id__c,Core_MDF_Recovered_Amt__c
From Core_MDF_Partnership_Score_Detail__c Where Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund' and Core_MDF_Budget_Type_nm__c = 'MDF' and Core_MDF_Quarter_Year_Nm__c = 'Q3 2023'];
for(Core_MDF_Partnership_Score_Detail__c psd : detailist){
if(psd.Core_MDF_Region_Cd__c == 'ASMO')
{
System.assertEquals(50, psd.Core_MDF_Recovered_Amt__c);   
}
else if(psd.Core_MDF_Region_Cd__c == 'APJ')
{
System.assertEquals(100, psd.Core_MDF_Recovered_Amt__c);
}
}*/
        }
    }
    
    @isTest static void testRecoveryBatch2() {
        
        Test.startTest();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
            Map<id,decimal> eligibleClaims = new Map<id,decimal>();
            
            Set<Id> claimIdSet = new Set<Id>();
            List<id> accountIds = new List<id>();
            for(Account acc: [select id, Name from Account limit 10]){
                accountIds.add(acc.Id);
            }
            Account accountRecord = [select id, Name from Account where name='Recovery RMF Virtual Corp' limit 1];
            
            List<PartnerFundClaim> claim = [select id from PartnerFundClaim where Core_MDF_Budget_Type_Options_Nm__c = 'Retail MDF' limit 2];
            PartnerFundClaim claim2 = [select id,Amount from PartnerFundClaim where Title='RMF Test Claim' limit 1];
            eligibleClaims.put(claim2.Id,claim2.Amount);
            List<Core_MDF_Recovery__c> rrList = Core_MDF_Recovery_Utility.createRecoveryRecords(eligibleClaims);  
            
            List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            String quarter = qtr[1];
            List<String> quarterYear = quarter.split(' ');
            
            List<Core_MDF_Partnership_Score_Detail__c> detailist2 = [Select Id, Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Region_Cd__c,Core_MDF_Budget_Type_nm__c, Core_MDF_Quarter_Year_Nm__c,Core_MDF_Partnership_Score_Id__c,Core_MDF_Recovered_Amt__c,Core_MDF_Node_Account_Id__c
                                                                     From Core_MDF_Partnership_Score_Detail__c Where Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = 'Retail Marketing Funds' and Core_MDF_Budget_Type_nm__c = 'Retail MDF' and Core_MDF_Quarter_Year_Nm__c =: quarter];
            
            Core_MDF_Recovery_Request__c rr = new Core_MDF_Recovery_Request__c();
            rr.Core_MDF_Claim_Id__c = claim2.id;
            rr.Core_MDF_Account_Id__c = accountRecord.id;
            rr.Core_MDF_Recovery_Amount_Amt__c = 100;
            rr.Core_MDF_Program_Nm__c = 'Retail Marketing Funds';
            rr.Core_MDF_Quarter_Year_Nm__c = quarter;
            rr.Core_MDF_Active_Ind__c = true;
            rr.Core_MDF_Recovered_Budget_Nm__c = 'Retail MDF;APJ=100';
            rr.Core_MDF_Claim_External_ID__c = claim2.id;
            rr.Core_MDF_RecoveredPartnershipScoreDetail__c=detailist2[0].Id+'-'+'1';
            // rrList.add(rr);
            Assert.areEqual(rr.Core_MDF_Program_Nm__c,'Retail Marketing Funds');
            Database.insert(rr);
            List<Core_MDF_Recovery_Request__c> recoveryReqList = [select Id, Core_MDF_RecoveredPartnershipScoreDetail__c from Core_MDF_Recovery_Request__c limit 1];
            Core_MDF_Recovery_Utility.updatePartnershipScoreDetailMapping(recoveryReqList);
            claimIdSet.add(claim2.id);
            String accounts = detailist2[0].Core_MDF_Node_Account_Id__c;
            Core_MDF_Recovery_Batch obj = new Core_MDF_Recovery_Batch('Retail Marketing Funds','Retail MDF',quarter,accounts);
            Id jobId = database.executeBatch(obj);
            
            Core_MDF_Recovery_Utility.populateClaimToConsumedPSD(claim2.Id,detailist2[0].Id);
            
            String programBudgetTypeQuarter = 'Client CoMarketing Fund;MDF;' + quarter;     
            List<RecoveryRecoveryRequestWrap> wrapperList = new List<RecoveryRecoveryRequestWrap>();
            List<String> budgetTypeList = new List<String>();
            budgetTypeList.add('MDF');
            
            List<String> regionList = new List<String>();
            regionList.add('APJ');
            
            
            Core_MDF_Recovery_Batch.recoveryDataWrapper recoveryWrapperAccList0 = new Core_MDF_Recovery_Batch.recoveryDataWrapper();
            recoveryWrapperAccList0.accntListId = accountIds;
            recoveryWrapperAccList0.bdgtTypeList = budgetTypeList;
            //recoveryWrapperAccList.regionList = regionList;
            
            //Core_MDF_Recovery_Utility.runEligibilityLogicToGetRecoveryRecords(programBudgetTypeQuarter,recoveryWrapperAccList0);
            
            Core_MDF_Recovery_Batch.recoveryDataWrapper recoveryWrapperAccList = new Core_MDF_Recovery_Batch.recoveryDataWrapper();
            recoveryWrapperAccList.accntListId = accountIds;
            recoveryWrapperAccList.bdgtTypeList = budgetTypeList;
            recoveryWrapperAccList.regionList = regionList;
            recoveryWrapperAccList.source = 'Payment Run';
            recoveryWrapperAccList.isPreSelClaim_RecvryDone = false;
            
            wrapperList = Core_MDF_Recovery_Utility.runEligibilityLogicToGetRecoveryRecords(programBudgetTypeQuarter,recoveryWrapperAccList);
            
            String programBudgetTypeQuarter2 = 'Retail Marketing Funds;Retail MDF;' + quarter; 
            String programBudgetTypeQuarter3 = 'Intel Partner Alliance;Proposal II MDF;' + quarter;
            Core_MDF_Recovery_Batch.recoveryDataWrapper recoveryWrapperAccList2 = new Core_MDF_Recovery_Batch.recoveryDataWrapper();
            recoveryWrapperAccList2.accntListId = accountIds;
            recoveryWrapperAccList2.bdgtTypeList = new List<String>{'Retail MDF'};
                recoveryWrapperAccList2.source = 'Payment Run';
            recoveryWrapperAccList2.isPreSelClaim_RecvryDone = false;
            //recoveryWrapperAccList.regionList = regionList;
            
            Core_MDF_Recovery_Utility.runEligibilityLogicToGetRecoveryRecords(programBudgetTypeQuarter2,recoveryWrapperAccList2);
            
            Core_MDF_Recovery_Batch.recoveryDataWrapper recoveryWrapperAccList3 = new Core_MDF_Recovery_Batch.recoveryDataWrapper();
            recoveryWrapperAccList3.accntListId = accountIds;
            recoveryWrapperAccList3.bdgtTypeList = budgetTypeList;
            recoveryWrapperAccList3.regionList = regionList;
            recoveryWrapperAccList3.source = 'Payment Run';
            recoveryWrapperAccList3.isPreSelClaim_RecvryDone = false;
            
            Core_MDF_Recovery_Utility.runEligibilityLogicToGetRecoveryRecords(programBudgetTypeQuarter3,recoveryWrapperAccList3);
            Test.stopTest();
            //Core_MDF_Recovery_Utility.updatePartnershipScoreDetailMapping(claimIdSet);
        }    
    }
    
    
    @isTest static void testReduceBusinessDays() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
            Date startDate = Date.newInstance(2023, 6, 1);
            Integer[] businessDaysToReduceList = new Integer[]{1, 5, 10, 15};
                test.startTest();
            for(Integer businessDaysToReduce : businessDaysToReduceList) {
                Date finalDate = Core_MDF_Recovery_Utility.reduceBusinessDays(startDate, businessDaysToReduce);
                System.assertNotEquals(null, finalDate);
                Integer weekdays = 0;
                while (startDate > finalDate) {
                    if (!Core_MDF_PFC_VAT_ServiceHandler.isWeekendDay(startDate)) {
                        weekdays++;
                    }
                    startDate = startDate.addDays(-1);
                }
                System.assertEquals(businessDaysToReduce, weekdays);
            } 
            test.stopTest();
        }
    }
    
    @isTest static void testPrepareBatchSchedulerInstance() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
            String program = 'Retail Marketing Funds';
            DateTime scheduleTime = DateTime.now();
            String recoveryDate = String.valueOf(System.today().addDays(7));
            test.startTest();
            Core_MDF_Batch_Scheduler__c schedulerInstance = Core_MDF_Recovery_Utility.prepareBatchSchedulerInstance(program, scheduleTime, recoveryDate);
            System.assertNotEquals(null, schedulerInstance);
            test.stopTest();
        }
    }
    
    @IsTest static void testGetRecoveryAdmins() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Assert.areEqual(usr.LastName, 'User Test');
        Database.insert(usr);
        system.runAs(usr) {
            List<String> psNameList = new List<String>{
                'Core_MDF_CCP_CCF_External_Recovery_Administrator',
                    'Core_MDF_CCP_DCF_External_Recovery_Administrator',
                    'Core_MDF_CCP_IPA_External_Recovery_Administrator'
                    };
                        Test.startTest();
            //Core_MDF_Recovery_Utility.getRecoveryAdmins(psNameList);
            Test.stopTest();  
        }
    }
    
    
    @IsTest static void testPerformRecoveryUpdates() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Assert.areEqual(usr.LastName, 'User Test');
        Database.insert(usr);
        system.runAs(usr) {
            Map<Id, Decimal> eligibleClaims = new Map<Id, Decimal>();
            List<Id> accountIds = new List<Id>();
            for (Account acc : [SELECT Id FROM Account LIMIT 10]) {
                accountIds.add(acc.Id);
            }
            
            Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Recovery RMF Virtual Corp' LIMIT 1];
            PartnerFundClaim claim1 = [SELECT Id, Amount FROM PartnerFundClaim WHERE Title='France Claim' LIMIT 1];
            PartnerFundClaim claim2 = [SELECT Id, Amount FROM PartnerFundClaim WHERE Title = 'RMF Test Claim' LIMIT 1];
            eligibleClaims.put(claim2.Id, claim2.Amount);
            
            List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            String quarter = qtr[1];
            List<String> quarterYear = quarter.split(' ');
            
            List<Core_MDF_Recovery__c> rrList = Core_MDF_Recovery_Utility.createRecoveryRecords(eligibleClaims);
            List<Core_MDF_Partnership_Score_Detail__c> detailList = [
                SELECT Id, Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c, Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c,
                Core_MDF_Region_Cd__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Quarter_Year_Nm__c, Core_MDF_Partnership_Score_Id__c, Core_MDF_Recovered_Amt__c, Core_MDF_Node_Account_Id__c
                FROM Core_MDF_Partnership_Score_Detail__c
                WHERE Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = 'Retail Marketing Funds'
                AND Core_MDF_Budget_Type_nm__c = 'Retail MDF'
                AND Core_MDF_Quarter_Year_Nm__c =: quarter
            ];
            
            List<Core_MDF_Recovery_Request__c> rrListNew = new List<Core_MDF_Recovery_Request__c>();
            Core_MDF_Recovery_Request__c rr = new Core_MDF_Recovery_Request__c();
            rr.Core_MDF_Claim_Id__c = claim2.Id;
            rr.Core_MDF_Account_Id__c = accountRecord.Id;
            rr.Core_MDF_Recovery_Amount_Amt__c = 100;
            rr.Core_MDF_Program_Nm__c = 'Retail Marketing Funds';
            rr.Core_MDF_Quarter_Year_Nm__c = quarter;
            rr.Core_MDF_Active_Ind__c = true;
            rr.Core_MDF_Recovered_Budget_Nm__c = 'Retail MDF;APJ=100';
            rr.Core_MDF_Claim_External_ID__c = quarter + '=Retail MDF=APJ=claimId';
            rr.Core_MDF_RecoveredPartnershipScoreDetail__c = detailList[0].Id + '-' + '1';
            rrListNew.add(rr);
            Database.insert(rrListNew);
            
            Map<Id, Decimal> claimToAmtMap = new Map<Id, Decimal>();
            for (Core_MDF_Recovery_Request__c recoveryReq : rrListNew) {
                claimToAmtMap.put(recoveryReq.Core_MDF_Claim_Id__c, 200.0);
            }
            
            Test.startTest();
            Core_MDF_Recovery_Utility.performRecoveryUpdates(claimToAmtMap, quarter);
            Map<Id, Decimal> claimToAmtMap2 = new Map<Id, Decimal>();
            //claim2.Id
            claimToAmtMap2.put(claim2.Id,20.0);
            Core_MDF_Recovery_Utility.performRecoveryUpdates(claimToAmtMap2, quarter);
            
            Core_MDF_Recovery_Utility.reduceBusinessDays(System.today(), 5);
            Core_MDF_Recovery_Utility.prepareBatchSchedulerInstance('Intel Partner Alliance', System.now(), '2024-05-13');
            
            
            Test.stopTest();
        }
    }
    
    @isTest static void testnotifyRecoveryAdmin() {
        Map<String,String> psNamToIdMap = new Map<String, String>();
        for(PermissionSet payAdmPS : [SELECT Id, Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_CCF_External_Recovery_Administrator','Core_MDF_CCP_DCF_External_Recovery_Administrator','Core_MDF_CCP_IPA_External_Recovery_Administrator','Core_MDF_CCP_RMF_External_Recovery_Administrator')]){
            psNamToIdMap.put(payAdmPS.Name, payAdmPS.Id);
        }
        
        List<Id> accountIds = new List<Id>();
        for (Account acc : [SELECT Id FROM Account LIMIT 10]) {
            accountIds.add(acc.Id);
        }
        Account accountRecord = [select id, Name from Account where name='Recovery Test Account RMF' limit 1];
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'ContactEmail',
            Email = 'testcontact@example.com',
            AccountId = accountRecord.Id,
            MailingCountry ='India'
        );
         Test.startTest();
        insert testContact;
        Assert.areEqual(testContact.LastName, 'ContactEmail');
        Core_AGS_Role__c agsRoleRMF = Core_MDF_CCP_TestDataUtility.createAgsRole('Co-Marketing(Salesforce)-RMF User', 'Co-Marketing(Salesforce)-RMF User', true, true);
        Core_ERPM_Engagement__c erpmEngagementRMF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('RPS_Retailer', 'RPS_Retailer', 'DEDUPGPRET', 'SEC', true, false);
        Database.insert(erpmEngagementRMF);
        
        Core_Entitlement__c entitlementRMF = Core_MDF_CCP_TestDataUtility.createEntitlement('RMF User',agsRoleRMF.Id ,'Intel® Partner Investment Center','RMF User',erpmEngagementRMF.Id , true,'Retail Marketing Funds (RMF)',false);
        Database.insert(entitlementRMF); 
        
        Core_Contact_Entitlement__c contactEntitlementRMF_C1 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(testContact.Id,entitlementRMF.Id ,true,'Complete', false);
        Database.insert(contactEntitlementRMF_C1);  
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 1];
        user usr = [select id from user where email ='sysadmin@example.com' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'UserEMAIL',
            Email = 'testuserEMAIL@example.com',
            Username = 'testuserEMAIL11062025@example.com',
            Alias = 'testE',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = testProfile.Id,
            ContactId = testContact.Id
        );
       
        insert testUser;
        List<PermissionSetAssignment> psAssignmentList = new List<PermissionSetAssignment>();
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = testUser.Id;
        assignPermissionSetObj1.PermissionSetId = psNamToIdMap.get('Core_MDF_CCP_CCF_External_Recovery_Administrator');
        psAssignmentList.add(assignPermissionSetObj1);
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = testUser.Id;
        assignPermissionSetObj2.PermissionSetId = psNamToIdMap.get('Core_MDF_CCP_RMF_External_Recovery_Administrator');
        psAssignmentList.add(assignPermissionSetObj2);
        PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();
        assignPermissionSetObj3.AssigneeId = testUser.Id;
        assignPermissionSetObj3.PermissionSetId = psNamToIdMap.get('Core_MDF_CCP_IPA_External_Recovery_Administrator');
        psAssignmentList.add(assignPermissionSetObj3);
        system.runas(usr){
            insert psAssignmentList;
        }
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        insert grp;
        
        system.runAs(usr){
            GroupMember gm = new GroupMember();
            gm.GroupId = grp.Id;
            gm.UserOrGroupId = testUser.Id;
            insert gm;
        }
        ChannelProgram retCP = [Select id from ChannelProgram where name ='Retail Marketing Funds'];
        //Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(accountRecord.Id,'Internal',accountRecord.Id,retCP.Id,'PGM_TEST',true);
        
        //Custom settings
        List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c settings1 = new Core_Trigger_Executions__c();
        settings1.Name = 'Core_MDF_Account_node_share';
        settings1.Core_Active__c = True;
        settings1.Core_Class_Name__c = 'Core_Account';
        settings1.Core_Description__c = 'method is used Create PNUM based External sharing group';
        settings1.Core_Object__c = 'Account';
        settings1.Core_Trigger_Events__c = 'after insert';
        executionList.add(settings1);
        
        Core_Trigger_Executions__c settings2 = new Core_Trigger_Executions__c();
        settings2.Name = 'Bypass_Duplicate_AcctUserMapping_Check';
        settings2.Core_Active__c = True;
        settings2.Core_Class_Name__c = 'Core_MDF_PNUM_Mapping_ServiceHandler';
        settings2.Core_Description__c = 'method is used Create PNUM based External sharing group';
        settings2.Core_Object__c = 'Core_MDF_Partner_Node_User_Mapping__c';
        settings2.Core_Trigger_Events__c = 'before insert';
        executionList.add(settings2);
        
        Core_Trigger_Executions__c settings3 = new Core_Trigger_Executions__c();
        settings3.Name = 'Core_MDF_validateAccountUserAccess';
        settings3.Core_Class_Name__c = 'Core_MDF_PNUM_Mapping_ServiceHandler';
        settings3.Core_Description__c = 'method is used Create PNUM based External sharing group';
        settings3.Core_Object__c = 'Core_MDF_Partner_Node_User_Mapping__c';
        settings3.Core_Trigger_Events__c = 'before insert';
        settings3.Core_Active__c = True;
        executionList.add(settings3);
        
        Core_Trigger_Executions__c settings4 = new Core_Trigger_Executions__c();
        settings4.Name = 'Bypass_AcctUserMapping_Obj_Share';
        settings4.Core_Active__c = True;
        settings4.Core_Class_Name__c = 'Core_MDF_PNUM_Mapping_ServiceHandler';
        settings4.Core_Description__c = 'method is used Create PNUM based External sharing group';
        settings4.Core_Object__c = 'Core_MDF_Partner_Node_User_Mapping__c';
        settings4.Core_Trigger_Events__c = 'after insert';
        executionList.add(settings4);
        
        Core_Trigger_Executions__c settings5 = new Core_Trigger_Executions__c();
        settings5.Name = 'Core_MDF_Bypass_Manual_Share';
        settings5.Core_Active__c = True;
        settings5.Core_Class_Name__c = 'Core_MDF_PNUM_Mapping_ServiceHandler';
        settings5.Core_Description__c = 'method is used Create PNUM based External sharing group';
        settings5.Core_Object__c = 'Core_MDF_Partner_Node_User_Mapping__c';
        settings5.Core_Trigger_Events__c = 'after insert';
        executionList.add(settings5);
        
        Database.insert(executionList);
        Account accountRecord1 = [select id, Name from Account where name='Recovery RMF Virtual Corp' limit 1];
        AccountShare accshareRecordRMF = new AccountShare();
        accshareRecordRMF.AccountId = accountRecord1.Id;
        accshareRecordRMF.UserOrGroupId = testUser.Id;
        accshareRecordRMF.RowCause = 'Manual';
        accshareRecordRMF.AccountAccessLevel = 'Read';
        accshareRecordRMF.OpportunityAccessLevel = 'None';
        accshareRecordRMF.CaseAccessLevel = 'None';
        insert accshareRecordRMF;
        
        AccountShare accshareRecordTestAcc = new AccountShare();
        accshareRecordTestAcc.AccountId = accountRecord.Id;
        accshareRecordTestAcc.UserOrGroupId = testUser.Id;
        accshareRecordTestAcc.RowCause = 'Manual';
        accshareRecordTestAcc.AccountAccessLevel = 'Read';
        accshareRecordTestAcc.OpportunityAccessLevel = 'None';
        accshareRecordTestAcc.CaseAccessLevel = 'None';
        insert accshareRecordTestAcc;
        
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new list<Core_MDF_Partner_Node_User_Mapping__c>();
        Core_MDF_Partner_Node_User_Mapping__c pnum1 = new Core_MDF_Partner_Node_User_Mapping__c();
        pnum1.Core_MDF_Account__c = accountRecord1.Id;
        pnum1.Core_MDF_User__c = testUser.Id;
        pnumList.add(pnum1);
        insert pnumList;
        Core_MDF_Recovery_Utility.RecoveryAdminProgramMapping userProgramWrap = new Core_MDF_Recovery_Utility.RecoveryAdminProgramMapping();
        userProgramWrap.user = testUser;
        userProgramWrap.Program = Core_MDF_CCP_ConstantClass.CCF_PROGRAM;
        
        Core_MDF_Recovery_Utility.RecoveryNotificationMapping testnotifyMap = new Core_MDF_Recovery_Utility.RecoveryNotificationMapping();
        testnotifyMap.program = Core_MDF_CCP_ConstantClass.CCF_PROGRAM;
        testnotifyMap.months = '';
        testnotifyMap.weekAndDay = '';
        testnotifyMap.reminderDays = '';
        
        List<Core_MDF_Recovery_Utility.RecoveryAdminProgramMapping> userProgramWrapList = new List<Core_MDF_Recovery_Utility.RecoveryAdminProgramMapping>();
        userProgramWrapList.add(userProgramWrap);
        
        List<String> psNameList = new List<String>{
            'Core_MDF_CCP_CCF_External_Recovery_Administrator',
                'Core_MDF_CCP_DCF_External_Recovery_Administrator',
                'Core_MDF_CCP_IPA_External_Recovery_Administrator',
                'Core_MDF_CCP_RMF_External_Recovery_Administrator'
                };
                    
                    String pgmToExecDateStr = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Program_Recovery_Date_Mapping');
        Map<String,String> pgmToExecDateMap = new Map<String,String>();
        for(string pgmToExecDate : pgmToExecDateStr.split(',')){
            List<string> record = pgmToExecDate.split(':');
            pgmToExecDateMap.put(record[0],record[1]);
        }
        List<String> internalActManagersPSList = new List<String>();
        Set<String> programNamesSet = new Set<String>();
        String intActManagersPrgToPSMappingStr = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Int_Acc_Mangr_Program_To_PS_Map');
        for(String psToProgram : intActManagersPrgToPSMappingStr.split(',')){
            List<string> record = psToProgram.split(':');
            internalActManagersPSList.add(record[0]);
            programNamesSet.add(record[1]);
        }
        
        Map<String, String> programToRecoveryDateMap = new Map<String, String>();
        programToRecoveryDateMap.put(Core_MDF_CCP_ConstantClass.IPA_PROGRAM, Date.today().addDays(1).format());
        programToRecoveryDateMap.put(Core_MDF_CCP_ConstantClass.CCF_PROGRAM, Date.today().addDays(2).format());
        programToRecoveryDateMap.put(Core_MDF_CCP_ConstantClass.RMF_PROGRAM, '2023-11-26');
        programToRecoveryDateMap.put(Core_MDF_CCP_ConstantClass.DCF_PROGRAM, Date.today().addDays(3).format());
        
        List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
        String quarter = qtr[1];
        List<String> quarterYear = quarter.split(' ');
        List<Core_MDF_Partnership_Score_Detail__c> psdList = [SELECT Id, Core_MDF_Partnership_Score_Id__c, Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c, Core_MDF_Account_Id__c, Core_MDF_Program_Nm__c, Core_MDF_Node_Account_Id__c, Core_MDF_Node_Account_Id__r.Name, Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c
                                                              FROM Core_MDF_Partnership_Score_Detail__c];
        
        
        try {
            
            Core_MDF_Recovery_Utility.notifyRecoveryAdmin(psNameList, programToRecoveryDateMap, psdList);
            Core_MDF_Recovery_Utility.sendRecoveryDashboardNotification(psNameList, quarter, psdList);
            Core_MDF_Recovery_Utility.notifyInternalActManagersOnRecoveryDataLoad(psNameList, new List<String>{'testPS'}, pgmToExecDateMap, programNamesSet, psdList, 'RecoveryIntAccMngrNotification', true);
            
        } catch (Exception ex) {
            System.debug('Exception occurred: ' + ex.getMessage());
        }
        Test.stopTest();
    }
    @isTest static void testNotifications()
    {   
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Assert.areEqual(usr.LastName, 'User Test');
        Database.insert(usr);
        system.runAs(usr) {
            Core_MDF_Configuration__c config = new  Core_MDF_Configuration__c();
            config.name = 'Core_MDF_PScore_Edit_Buffer_Days';
            config.Core_MDF_Value__c = '365';
            insert config;
            Test.startTest();
            ChannelProgram ccfCP = [Select id from ChannelProgram where name=:Core_MDF_CCP_ConstantClass.CCF_PROGRAM];
            Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New ', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            insert intelAccount;
            List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            string quarter = qtr[1];
            List<String> quarterYear = quarter.split(' ');
            List<Core_MDF_Partnership_Score__c> psList = new List<Core_MDF_Partnership_Score__c>();
            Core_MDF_Partnership_Score__c ps1 = new Core_MDF_Partnership_Score__c();
            ps1.Core_MDF_Account_Id__c  = intelAccount.Id;
            ps1.Core_MDF_Channel_Program_Id__c =ccfCP.Id;
            ps1.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            ps1.Core_MDF_Quarter_nm__c = quarterYear[0];
            ps1.Core_MDF_Year_nm__c = quarterYear[1];
            ps1.Core_MDF_Quarter_Year_Nm__c = quarter;
            ps1.Core_MDF_Zone_nm__c = 'C1';
            psList.add(ps1);
            
            insert psList;
            
            Core_MDF_Partnership_Score_Detail__c psd = new Core_MDF_Partnership_Score_Detail__c();
            psd.Core_MDF_Budget_Type_nm__c = 'MDF+';
            psd.Core_MDF_Region_Cd__c = 'APJ';
            psd.Core_MDF_Partnership_Score_Id__c = ps1.id;
            psd.Core_MDF_Recovered_Amt__c = 100.00;
            insert psd;
            
            Core_MDF_Partnership_Score_Detail__c psd1 = new Core_MDF_Partnership_Score_Detail__c();
            psd1.Core_MDF_Budget_Type_nm__c = 'MDF+';
            psd1.Core_MDF_Carry_Over_Amt__c = 123;
            psd1.Core_MDF_Region_Cd__c = 'APJ';
            psd1.Core_MDF_Partnership_Score_Id__c = ps1.id;
            psd1.Core_MDF_Recovered_Amt__c = 100.00;
            psd1.Core_MDF_Partnership_Score_Detail_Id__c = psd.Id;
            
            insert psd1;
            Core_MDF_Batch_IAH_Pull batch = new Core_MDF_Batch_IAH_Pull(true);
            Database.executeBatch(batch);  
            Test.stopTest();
        }
    }
    @isTest static void testRecoveryBatch3() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Assert.areEqual(usr.LastName, 'User Test');
        Database.insert(usr);
        system.runAs(usr) {
            Test.startTest();
            Set<Id> claimIdSet = new Set<Id>();
            List<id> accountIds = new List<id>();
            Account accountRecord = [select id from Account limit 1];
            List<PartnerFundClaim> claim = [select id from PartnerFundClaim where Core_MDF_Budget_Type_Options_Nm__c = 'MDF' limit 2];
            PartnerFundClaim claim2 = [select id from PartnerFundClaim where Core_MDF_Budget_Type_Options_Nm__c = 'MDF+' limit 1];
            accountIds.add(accountRecord.id);
            
            List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            String quarter = qtr[1];
            List<String> quarterYear = quarter.split(' ');
            
            
            Core_MDF_Recovery_Request__c rr = new Core_MDF_Recovery_Request__c();
            rr.Core_MDF_Claim_Id__c = claim2.id;
            rr.Core_MDF_Account_Id__c = accountRecord.id;
            rr.Core_MDF_Recovery_Amount_Amt__c = 100;
            rr.Core_MDF_Program_Nm__c = 'Client CoMarketing Fund';
            rr.Core_MDF_Quarter_Year_Nm__c = quarter;
            rr.Core_MDF_Active_Ind__c = true;
            rr.Core_MDF_Ready_to_Recover_Ind__c = true;
            rr.Core_MDF_Recovered_Budget_Nm__c = 'MDF+;ASMO=100';
            rr.Core_MDF_Claim_External_ID__c = claim2.id;
            // rrList.add(rr);
            
            
            Database.insert(rr);
            claimIdSet.add(claim2.id);
            List<Core_MDF_Partnership_Score_Detail__c> detailist2 = [Select Id, Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Region_Cd__c,Core_MDF_Budget_Type_nm__c, Core_MDF_Quarter_Year_Nm__c,Core_MDF_Partnership_Score_Id__c,Core_MDF_Recovered_Amt__c
                                                                     From Core_MDF_Partnership_Score_Detail__c Where Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund' and Core_MDF_Budget_Type_nm__c = 'MDF+' and Core_MDF_Quarter_Year_Nm__c =: quarter];
            Core_MDF_Recovery_Batch obj = new Core_MDF_Recovery_Batch('Client CoMarketing Fund',  ''    ,  '',  '', '', 'Payment Run', False, False);
            Id jobId = database.executeBatch(obj);
            Core_MDF_Recovery_Batch obj3 = new Core_MDF_Recovery_Batch('Intel Partner Alliance',  ''    ,  '',  '', 'APJ', 'Payment Run', False, False);
            Id jobId3 = database.executeBatch(obj3);
            Core_MDF_Recovery_Batch obj4 = new Core_MDF_Recovery_Batch('Retail Marketing Funds',  ''    ,  '');
            Id jobId4 = database.executeBatch(obj4);
            String acc =  accountIds.toString();
            Core_MDF_Recovery_Batch obj5 = new Core_MDF_Recovery_Batch('Retail Marketing Funds',  '' ,''   , '');
            Id jobId5 = database.executeBatch(obj5);
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
            Id jobId2 = database.executeBatch(obj2);
            //Core_MDF_Batch_UpdateRecoveryClaims(finalRecoveryList);
            Test.stopTest();
            //Core_MDF_Recovery_Utility.updatePartnershipScoreDetailMapping(claimIdSet);
            
        }
    }
    @isTest static void testRecoveryBatchGenerateInstance() {
        object obj = Core_MDF_Recovery_Batch.generateInstance('{"pgm":"","bgtType":"","qtrYr":"","accounts":""}','Core_MDF_Recovery_Batch(string pgm, string bgtType, string qtrYr, string accounts)');
        Core_MDF_Recovery_Batch.generateInstance('{"pgm":"","bgtTypes":"","qtrYr":"","accounts":"","regions":"","source":"","isRecReq_RecvryDone":false,"isPreSelClaim_RecvryDone":false}','Core_MDF_Recovery_Batch(string pgm, string bgtTypes, string qtrYr, string accounts,string regions,string source,boolean isRecReq_RecvryDone,boolean isPreSelClaim_RecvryDone)');
        Core_MDF_Recovery_Batch.generateInstance('{"pgm":"","bgtType":"","qtrYr":""}','Core_MDF_Recovery_Batch(string pgm, string bgtType, string qtrYr)');
        assert.areNotEqual(obj,null);
    }
    
    @isTest static void testDeterminePreviousQuartYear() {
        Date qtr2 = Date.newInstance(2024,4,03);
        Core_MDF_Recovery_Batch.determinePreviousQuartYear(qtr2);
        Date qtr3 = Date.newInstance(2024,7,03);
        Core_MDF_Recovery_Batch.determinePreviousQuartYear(qtr3);
        Date qtr4 = Date.newInstance(2024,10,03);
        Core_MDF_Recovery_Batch.determinePreviousQuartYear(qtr4);
        Core_MDF_Recovery_Batch.runBatch('Intel Partner Alliance','','Q4 2024','','','Payment run',false,false);
    }
    
    @isTest static void testRecoveryBatch4() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Assert.areEqual(usr.LastName, 'User Test');
        Database.insert(usr);
        system.runAs(usr) {
            Set<Id> claimIdSet = new Set<Id>();
            List<id> accountIds = new List<id>();
            List<string> budget = new List<string>();
            List<string> region = new List<string>();
            Account accountRecord = [select id from Account limit 1];
            List<PartnerFundClaim> claim = [select id,Core_MDF_Budget_Type_Options_Nm__c, Core_MDF_Region_Cd__c,Core_MDF_Program__c, ChannelPartnerId, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Recovery_Hold_Ind__c from PartnerFundClaim where Core_MDF_Budget_Type_Options_Nm__c = 'MDF' limit 2];
            PartnerFundClaim claim2 = [select id,Core_MDF_Budget_Type_Options_Nm__c, Core_MDF_Region_Cd__c,Core_MDF_Program__c, ChannelPartnerId, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Recovery_Hold_Ind__c  from PartnerFundClaim where Core_MDF_Budget_Type_Options_Nm__c = 'MDF+' limit 1];
            claim.add(claim2);
            accountIds.add(accountRecord.id);
            budget.add('MDF');
            budget.add('MDF+');
            budget.add('Retail MDF');
			region.add('APJ');
			region.add('ASMO');
			String program ='Client CoMarketing Fund';
            List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            String quarter = qtr[1];
            List<String> quarterYear = quarter.split(' ');
            
            
           /* Core_MDF_Recovery_Request__c rr = new Core_MDF_Recovery_Request__c();
            rr.Core_MDF_Claim_Id__c = claim2.id;
            rr.Core_MDF_Account_Id__c = accountRecord.id;
            rr.Core_MDF_Recovery_Amount_Amt__c = 100;
            rr.Core_MDF_Program_Nm__c = 'Client CoMarketing Fund';
            rr.Core_MDF_Quarter_Year_Nm__c = quarter;
            rr.Core_MDF_Active_Ind__c = true;
            rr.Core_MDF_Ready_to_Recover_Ind__c = true;
            rr.Core_MDF_Recovered_Budget_Nm__c = 'MDF+;ASMO=100';
            rr.Core_MDF_Claim_External_ID__c = claim2.id;
            // rrList.add(rr);
            
            
            Database.insert(rr);
            claimIdSet.add(claim2.id);
            List<Core_MDF_Partnership_Score_Detail__c> detailist2 = [Select Id, Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Region_Cd__c,Core_MDF_Budget_Type_nm__c, Core_MDF_Quarter_Year_Nm__c,Core_MDF_Partnership_Score_Id__c,Core_MDF_Recovered_Amt__c
                                                                     From Core_MDF_Partnership_Score_Detail__c Where Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund' and Core_MDF_Budget_Type_nm__c = 'MDF+' and Core_MDF_Quarter_Year_Nm__c =: quarter];*/
            Core_MDF_Batch_ClmRemoveRecoveryHold obj = new Core_MDF_Batch_ClmRemoveRecoveryHold(accountIds, budget, region, program);
            Id jobId = database.executeBatch(obj);
            string quarterYear1 = Core_MDF_Recovery_Batch.determinePreviousQuartYear(System.Today());
            //List<string> qyear = new list<string>();
            //qyear.add(quarterYear1);
            String month_data = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Current_Month');
            obj.execute(null,claim);
            Integer currMonth = obj.getCurrMonth(month_data);
            Integer currMonths = obj.getCurrMonth(null);
            obj.populateKeySet(program,quarterYear1);
            List<PartnerFundClaim> claims = obj.populateClaimList(claim,quarterYear1,program);
            //Core_MDF_Recovery_Utility.updatePartnershipScoreDetailMapping(claimIdSet);
            
        }
    }
}