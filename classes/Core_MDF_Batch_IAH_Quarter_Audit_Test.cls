@IsTest(SeeAllData=false)
public class Core_MDF_Batch_IAH_Quarter_Audit_Test {

    @TestSetup
    static void makeData() {
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        insert usr;
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User';
        testUser.UserRoleId = usRole.Id;
        Database.insert(testUser);
        
        
        Map<String,String> psNamToIdMap = new Map<String, String>();
        for(PermissionSet payAdmPS : [SELECT Id, Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_CCF_Payment_Adm','Core_MDF_CCP_Internal_Retail_Payment_Adm','Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr')]){
            psNamToIdMap.put(payAdmPS.Name, payAdmPS.Id);
        }
        User paymentAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
        paymentAdmin.LastName = 'Payment Admin';
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
            intelAccList.add(recoveryIntelAcc2);

            //adding intel acc for rmf
            Account recoveryIntelAccRMF = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery Test Account RMF', NULL, Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);   
            recoveryIntelAccRMF.BillingCity = 'Recovery City 6';         
            recoveryIntelAccRMF.BillingCountry= 'IND';
            recoveryIntelAccRMF.BillingStreet= 'Recovery Street 2';
            recoveryIntelAccRMF.Core_MDF_CoMarketingActive__c = true;
            recoveryIntelAccRMF.Core_Geo__c = 'APJ';
            intelAccList.add(recoveryIntelAccRMF);
            Database.insert(intelAccList);
            
            //Create Virtual Corp
            List<Account> virtualAccList = new List<Account>();
            Account recoveryCCFVC = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery CCF Virtual Corp', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            recoveryCCFVC.Core_MDF_Parent_Fund_Account__c = recoveryIntelAcc.Id;
            recoveryCCFVC.Core_MDF_CoMarketingActive__c = true;
            insert recoveryCCFVC;
            Account recoveryCCFEMEA = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery CCF EMEA', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            recoveryCCFEMEA.Core_MDF_Parent_Fund_Account__c = recoveryCCFVC.Id;
            recoveryCCFEMEA.Core_MDF_Active_Ind__c = true;
            insert recoveryCCFEMEA;
            Account recoveryCCFVC2 = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery CCF Virtual Corp 2', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            recoveryCCFVC2.Core_MDF_Parent_Fund_Account__c = recoveryIntelAcc2.Id;
            recoveryCCFVC2.Core_MDF_CoMarketingActive__c = true;
            recoveryCCFVC2.Core_MDF_CoMarketing_Ultimate_Account__c = recoveryIntelAcc2.Id;
            recoveryCCFVC2.Core_MDF_Active_Ind__c = true;
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
            recoveryEMEAFrance.Core_MDF_CoMarketing_Ultimate_Account__c = recoveryIntelAcc.Id;
            recoveryEMEAFrance.Core_MDF_CoMarketingActive__c = true;
            recoveryEMEAFrance.Core_MDF_Active_Ind__c = true;
            virtualAccList.add(recoveryEMEAFrance);
            Database.insert(virtualAccList);
            
            List<Group> grpList = new List<Group>();

            // Creating CCF External Group
            Group ccfgrp = new Group();
            ccfgrp.Name = 'Core CCP CCF External';
            ccfgrp.DeveloperName = 'Core_CCP_CCF_External';
            grpList.add(ccfgrp);

            // Creating CCF Internal Group
            Group intGrp = new Group();
            intGrp.Name = 'Core CCP RMF External';
            intGrp.DeveloperName = 'Core_CCP_RMF_External';
            grpList.add(intGrp);
			
            Database.insert(grpList);
            List<Core_MDF_Partner_Group_Mapping__c> extPgms = new List<Core_MDF_Partner_Group_Mapping__c>();
            // For CCF - ultimate accounts are recoveryIntelAcc and recoveryIntelAcc2
            extPgms.add(new Core_MDF_Partner_Group_Mapping__c(
                Core_MDF_Account__c = recoveryIntelAcc.Id,
                Core_MDF_Channel_Program__c = ccfCP.Id,
                Core_MDF_Type_Of_Access__c = 'External',
                Core_MDF_Inactive_Ind__c = false,
                Core_MDF_Group_Name__c = 'Core_CCP_CCF_External',
                Core_MDF_Group_Id__c = ccfgrp.Id
            ));
            extPgms.add(new Core_MDF_Partner_Group_Mapping__c(
                Core_MDF_Account__c = recoveryIntelAcc2.Id,
                Core_MDF_Channel_Program__c = ccfCP.Id,
                Core_MDF_Type_Of_Access__c = 'External',
                Core_MDF_Inactive_Ind__c = false,
                Core_MDF_Group_Name__c = 'Core_CCP_CCF_External',
                Core_MDF_Group_Id__c = ccfgrp.Id
            ));
            // For RMF - ultimate account is recoveryIntelAccRMF
            extPgms.add(new Core_MDF_Partner_Group_Mapping__c(
                Core_MDF_Account__c = recoveryIntelAccRMF.Id,
                Core_MDF_Channel_Program__c = retCP.Id,
                Core_MDF_Type_Of_Access__c = 'External',
                Core_MDF_Inactive_Ind__c = false,
                Core_MDF_Group_Name__c = 'Core_CCP_RMF_External',
                Core_MDF_Group_Id__c = intGrp.Id
            ));
            insert extPgms;
            
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
            Database.insert(bankList);
            
            Test.startTest();
            List<Campaign> campList = new List<Campaign>();
            Campaign recoveryCamp = Core_MDF_CCP_TestDataUtility.createCampaign('ARP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', recoveryCCFVC.Id, '2-in-1', false);
            recoveryCamp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF;MDF+';
            recoveryCamp.Core_MDF_Supports_legacy_program__c='MDF or both CMP & MDF';
            Campaign recoveryCamp2 = Core_MDF_CCP_TestDataUtility.createCampaign('ARP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', recoveryCCFVC2.Id, '2-in-1', false);
            recoveryCamp2.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF;MDF+';
            recoveryCamp2.Core_MDF_Supports_legacy_program__c='MDF or both CMP & MDF';
            Campaign recoveryCampRMF = Core_MDF_CCP_TestDataUtility.createCampaign('RMF Campaign','Gaming','Intel® Core™ i7+ Processor','No', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', recoveryRetVC.Id, '2-in-1', false);
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
                                                                                                           'Broadcast (Pre-2025)',
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
            
            List<Core_MDF_Partnership_Score__c> pssList = [select id, Core_MDF_Account_Id__c from Core_MDF_Partnership_Score__c limit 10]; //ATHR FIX - WW16
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
            for(PartnerFundClaim claim:[select id,Core_MDF_Status__c,Core_MDF_Region_Cd__c from PartnerFundClaim limit 10]){ //ATHR FIX - WW16
                claim.Core_MDF_Status__c = 'Payment Due';
                claimList.add(claim);
            }
            Database.update(claimList);
        }
    }

    @IsTest
    static void testQuarterAuditBatch() {
        Test.startTest();
        //Core_MDF_Scorecard__c scorecard = createPassingAuditData();

        PartnerFundClaim claim = [SELECT Id, ChannelPartnerId FROM PartnerFundClaim WHERE ChannelPartner.Name = 'Recovery RMF Virtual Corp' LIMIT 1];
        Case auditCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId(),
            AccountId = claim.ChannelPartnerId,
            Status = 'Closed',
            Origin = 'Manual Selection',
            Core_MDF_Status__c = 'Review Completed',
            Core_MDF_Claim_ID__c = String.valueOf(claim.Id),
            Core_MDF_Claim_Lookup_Id__c = claim.Id,
            Core_MDF_Channel_Program_txt__c = 'Retail Marketing Funds',
            Core_MDF_Budget_Type_nm__c = 'Retail MDF',
            Core_MDF_Region_SubRegion_txt__c = 'APJ-SA'
        );
        insert auditCase;

        Core_MDF_Scorecard__c scorecard = new Core_MDF_Scorecard__c(
            Core_MDF_Case_Id__c = auditCase.Id,
            Core_MDF_Attribution_Nbr__c = '1',
            Core_MDF_Engagement_Nbr__c = '1',
            Core_MDF_POP__c = '1',
            Core_MDF_Manual_Recovery_Amount_USD_Amt__c = 0
        );
        insert scorecard;
        scorecard = [SELECT Id, Core_MDF_Quarter__c, Core_MDF_Score_Nbr__c, Core_MDF_Virtual_Corp_Account_Id__c, Core_MDF_Claim_Amt__c, Core_MDF_Manual_Recovery_Amount_USD_Amt__c, Core_MDF_Max_Possible_Amt__c,
                           Core_MDF_Weighted_PV_Amt__c, Core_MDF_Case_Id__r.AccountId, Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c, Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c, Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c,
                           Core_MDF_Case_Id__r.Core_MDF_Region_SubRegion_txt__c, Core_MDF_Case_Id__r.Core_MDF_Claim_Lookup_Id__c FROM Core_MDF_Scorecard__c WHERE Id = :scorecard.Id];
        System.assertNotEquals(null, scorecard.Core_MDF_Score_Nbr__c, 'The scorecard must qualify for the batch query.');

        Core_MDF_Batch_IAH_Quarter_Audit audit = new Core_MDF_Batch_IAH_Quarter_Audit(scorecard.Core_MDF_Quarter__c);
        Id programId = scorecard.Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c;
        Id virtualCorpId = Id.valueOf(scorecard.Core_MDF_Virtual_Corp_Account_Id__c);
        Id nodeAccountId = scorecard.Core_MDF_Case_Id__r.AccountId;
        Account virtualCorp = [SELECT Core_MDF_Parent_Fund_Account__c FROM Account WHERE Id = :virtualCorpId];

        List<Core_MDF_Partnership_Score__c> currentScores = [SELECT Id FROM Core_MDF_Partnership_Score__c WHERE Core_MDF_Channel_Program_Id__c = :programId AND Core_MDF_Virtual_Corp_Account_Id__c = :virtualCorpId AND Core_MDF_Quarter_Year_Nm__c = :audit.quarter];
       
        Core_MDF_Partnership_Score__c currentScore;
        if (currentScores.isEmpty()) {
            currentScore = new Core_MDF_Partnership_Score__c(
                Core_MDF_Account_Id__c = virtualCorp.Core_MDF_Parent_Fund_Account__c,
                Core_MDF_Channel_Program_Id__c = programId,
                Core_MDF_Virtual_Corp_Account_Id__c = virtualCorpId,
                Core_MDF_Quarter_Year_Nm__c = audit.quarter,
                Core_MDF_Quarter_nm__c = audit.quarter.substring(0, 2),
                Core_MDF_Year_nm__c = audit.quarter.substring(3),
                Core_MDF_Zone_nm__c = 'A3',
                Core_MDF_External_Id__c = String.valueOf(programId) + String.valueOf(virtualCorpId) + audit.quarter
            );
            insert currentScore;
        } else { currentScore = currentScores[0]; }

        List<Core_MDF_Partnership_Score__c> previousScores = [SELECT Id FROM Core_MDF_Partnership_Score__c WHERE Core_MDF_Channel_Program_Id__c = :programId AND Core_MDF_Virtual_Corp_Account_Id__c = :virtualCorpId AND Core_MDF_Quarter_Year_Nm__c = :audit.previousQuarter];
        
        Core_MDF_Partnership_Score__c previousScore;
        if (previousScores.isEmpty()) {
            previousScore = new Core_MDF_Partnership_Score__c(
                Core_MDF_Account_Id__c = virtualCorp.Core_MDF_Parent_Fund_Account__c,
                Core_MDF_Channel_Program_Id__c = programId,
                Core_MDF_Virtual_Corp_Account_Id__c = virtualCorpId,
                Core_MDF_Quarter_Year_Nm__c = audit.previousQuarter,
                Core_MDF_Quarter_nm__c = audit.previousQuarter.substring(0, 2),
                Core_MDF_Year_nm__c = audit.previousQuarter.substring(3),
                Core_MDF_Zone_nm__c = 'A3',
                Core_MDF_External_Id__c = String.valueOf(programId) + String.valueOf(virtualCorpId) + audit.previousQuarter
            );
            insert previousScore;
        } else { previousScore = previousScores[0]; }

        List<Core_MDF_Partnership_Score_Detail__c> previousDetails = [SELECT Id FROM Core_MDF_Partnership_Score_Detail__c WHERE Core_MDF_Partnership_Score_Id__c = :previousScore.Id AND Core_MDF_Node_Account_Id__c = :nodeAccountId AND Core_MDF_Budget_Type_nm__c = 'Retail MDF' AND Core_MDF_Region_Cd__c = 'APJ'];
        
        Core_MDF_Partnership_Score_Detail__c previousDetail;
        if (previousDetails.isEmpty()) {
            previousDetail = new Core_MDF_Partnership_Score_Detail__c(
                Core_MDF_Partnership_Score_Id__c = previousScore.Id,
                Core_MDF_Node_Account_Id__c = nodeAccountId,
                Core_MDF_Budget_Type_nm__c = 'Retail MDF',
                Core_MDF_Region_Cd__c = 'APJ',
                Core_MDF_Carry_Over_Amt__c = 1000,
                Core_MDF_Recovered_Amt__c = 0,
                Core_MDF_External_Id__c = String.valueOf(programId) + String.valueOf(virtualCorpId) + audit.previousQuarter + 'Retail MDFAPJ'
            );
            insert previousDetail;
        } else { previousDetail = previousDetails[0]; }
        
        previousDetail = [SELECT Id, Core_MDF_Balance_Amount_Amt__c FROM Core_MDF_Partnership_Score_Detail__c WHERE Id = :previousDetail.Id];

        List<Core_MDF_Partnership_Score_Detail__c> currentDetails = [SELECT Id FROM Core_MDF_Partnership_Score_Detail__c WHERE Core_MDF_Partnership_Score_Id__c = :currentScore.Id AND Core_MDF_Node_Account_Id__c = :nodeAccountId AND Core_MDF_Budget_Type_nm__c = 'Retail MDF' AND Core_MDF_Region_Cd__c = 'APJ'];
        Core_MDF_Partnership_Score_Detail__c currentDetail;
        if (currentDetails.isEmpty()) {
            currentDetail = new Core_MDF_Partnership_Score_Detail__c(
                Core_MDF_Partnership_Score_Id__c = currentScore.Id,
                Core_MDF_Node_Account_Id__c = nodeAccountId,
                Core_MDF_Budget_Type_nm__c = 'Retail MDF',
                Core_MDF_Region_Cd__c = 'APJ',
                Core_MDF_Recovered_Amt__c = 0,
                Core_MDF_External_Id__c = String.valueOf(programId) + String.valueOf(virtualCorpId) + audit.quarter + 'Retail MDFAPJ'
            );
        } else { currentDetail = currentDetails[0]; 
               }
        currentDetail.Core_MDF_Partnership_Score_Detail_Id__c = previousDetail.Id;
        currentDetail.Core_MDF_Carry_Over_Amt__c = previousDetail.Core_MDF_Balance_Amount_Amt__c;
        if (currentDetail.Id == null) { insert currentDetail;
        } else { update currentDetail; }

        insert new Core_MDF_Recovery_Dashboard__c(
            Core_MDF_Scorecard_Id__c = scorecard.Id,
            Core_MDF_Partnership_Score_Id__c = currentScore.Id,
            Core_MDF_Partnership_Score_Detail_Id__c = currentDetail.Id,
            Core_MDF_Is_Active_Ind__c = true,
            Core_MDF_Claim_Amt__c = scorecard.Core_MDF_Claim_Amt__c,
            Core_MDF_Manual_Recovery_Amount_USD_Amt__c = scorecard.Core_MDF_Manual_Recovery_Amount_USD_Amt__c,
            Core_MDF_Max_Possible_Amt__c = scorecard.Core_MDF_Max_Possible_Amt__c,
            Core_MDF_Weighted_PV_Amt__c = scorecard.Core_MDF_Weighted_PV_Amt__c
        );

        Core_MDF_Batch_IAH_Quarter_Audit auditTwo = new Core_MDF_Batch_IAH_Quarter_Audit(scorecard.Core_MDF_Quarter__c);

        auditTwo.execute(null, new List<SObject>{scorecard});
        Database.executeBatch(new Core_MDF_Batch_IAH_Quarter_Audit(scorecard.Core_MDF_Quarter__c), 100);
        Test.stopTest();
    }

    @IsTest
    static void testNullQuarterAuditBatch() {
        Core_MDF_Batch_IAH_Quarter_Audit audit = new Core_MDF_Batch_IAH_Quarter_Audit(null);

        Test.startTest();
        Database.executeBatch(audit, 100);
        Test.stopTest();
    }
}