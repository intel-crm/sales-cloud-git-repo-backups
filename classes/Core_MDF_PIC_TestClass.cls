/****************************************************************************************************************************************
* Class Name : Core_MDF_PIC_TestClass
* Version : 1.0
* Created Date: 09-01-2022
* Modification Log :
* Developer Date Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - Sarah Manuel 09/01/2022 Created to test Core_MDF_BatchtoPICClaim and Claim PIC Process.
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_PIC_TestClass {
    @TestSetup 
    static void makeData() {
       
       List<User> listUser = new List<User>();
        //creating system admin user
        User sysAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr.LastName = 'System Adm';
        listUser.add(sysAdmUsr);
        
        /*creating claim case user
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName='Claim Case User';
        usr.profile=ccpCoreProfile;
        listUser.add(usr); */
        
        Database.insert(listUser); 
        system.runAs(sysAdmUsr){
        PermissionSet ccfPayAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
            PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
            assignPermissionSetObj1.AssigneeId = sysAdmUsr.Id;
            assignPermissionSetObj1.PermissionSetId = ccfPayAdmPS.Id;
            insert assignPermissionSetObj1;
        }
        
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
        bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
        bypassFunctionKeys.add('Bypass_Allocation_Reservation');
        bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
        bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
        bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing');        
        bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
        bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
        bypassFunctionKeys.add('Bypass_PaymentRun_Duplicate_Check');
        /*bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
        bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
        bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');*/
        bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
        bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
        /*bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
        bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');*/
        bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
        //bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
        bypassFunctionKeys.add('Bypass_UpdateActivityFields');
        bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('Core_MDF_XMLToXLSGenerationFlag');
        bypassFunctionKeys.add('Core_MDF_StringToXLSGenerationFlag');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
        
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
        claimFunctionalityNameTriggerExecution.Core_Trigger_Events__c = 'after insert, after update';
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
       // executionList.add(claimFunctionalityNameTriggerExecution3);
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
        
        ChannelProgram ccfCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);

        Account arpIntelAcc = Core_MDF_CCP_TestDataUtility.createAccount ('ARP Test Account', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        arpIntelAcc.BillingCity = 'ARP City';         
        arpIntelAcc.BillingCountry= 'IND';
        arpIntelAcc.BillingStreet= 'ARP Street'; 
        Database.insert(arpIntelAcc);   

        Account arpCCFVC = Core_MDF_CCP_TestDataUtility.createAccount ('ARP CCF Virtual Corp', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        arpCCFVC.Core_MDF_Parent_Fund_Account__c = arpIntelAcc.Id;
        arpCCFVC.Core_MDF_CoMarketingActive__c = true;
        Database.insert(arpCCFVC);

        Account arpCCFEMEA = Core_MDF_CCP_TestDataUtility.createAccount ('ARP CCF EMEA', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        arpCCFEMEA.Core_MDF_Parent_Fund_Account__c = arpCCFVC.Id;
        Database.insert(arpCCFEMEA);

        Account arpEMEAFrance = Core_MDF_CCP_TestDataUtility.createAccount ('ARP CCF EMEA France', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        arpEMEAFrance.Core_MDF_Parent_Fund_Account__c = arpCCFEMEA.Id;
        arpEMEAFrance.Core_MDF_Auto_Transfer_Account__c = arpCCFVC.Id;
        arpEMEAFrance.Core_MDF_Enabled_Auto_Transfer__c = True;
        Database.insert(arpEMEAFrance);
        
        List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
        PartnerMarketingBudget  arpPmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('ARP PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,arpCCFVC.Id,ccfCP.Id,100000,System.today().addDays(-10),System.today().addDays(10),false);
        arpPmbRecord.Core_MDF_Budget_Type_Txt__c ='OEM CMP';
        
        PartnerMarketingBudget  arpPmbLegacyRecord = Core_MDF_CCP_TestDataUtility.createBudget('ARP PMB Legacy',Core_MDF_CCP_TestDataUtility.budget_Record_Type,arpCCFVC.Id,ccfCP.Id,100000,System.today().addDays(-10),System.today().addDays(10),false);
        arpPmbLegacyRecord.Core_MDF_Budget_Type_Txt__c ='OEM CMP';
        //arpPmbRecord.Core_MDF_Budget_Status__c = 'Released';
        budgetList.add(arpPmbRecord);
        budgetList.add(arpPmbLegacyRecord);
        Database.insert(budgetList);
        
       
        
        PartnerFundAllocation pfaARPCCFFrance = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaARPCCFFrance',arpPmbRecord, arpEMEAFrance, 1000, true);
        PartnerFundAllocation pfaARPCCFFranceLegacy = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaARPCCFFrance',arpPmbLegacyRecord, arpEMEAFrance, 1000, true);
        Core_MDF_Bank__c arpBank = Core_MDF_CCP_TestDataUtility.createBank(arpIntelAcc.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
        arpBank.Core_MDF_Effective_Date__c= system.today().addDays(-2);
        System.runAs(sysAdmUsr){
        insert arpBank;
        }
        
        // Highlight: Unused Local Variable - Indira
       // Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(arpEMEAFrance.Id,arpBank.Id,true);

        List<Campaign> campList = new List<Campaign>();
        Campaign arpCamp = Core_MDF_CCP_TestDataUtility.createCampaign('ARP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', arpCCFVC.Id, '2-in-1', false);
        arpCamp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        arpCamp.Core_MDF_Supports_legacy_program__c='MDF or both CMP & MDF';
        arpCamp.Core_MDF_Region_cd__c = 'APJ';
        campList.add(arpCamp);
        Campaign arpCampLegacy = Core_MDF_CCP_TestDataUtility.createCampaign('ARP Legacy Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', arpCCFVC.Id, '2-in-1', false);
        arpCampLegacy.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        arpCampLegacy.Core_MDF_Region_cd__c = 'APJ';
        campList.add(arpCampLegacy);
        Database.insert(campList);
        
        List<Core_MDF_Campaign_Budgets__c> campBudgetList = new List<Core_MDF_Campaign_Budgets__c>();
         Core_MDF_Campaign_Budgets__c campBudget = new Core_MDF_Campaign_Budgets__c();
            campBudget.Core_MDF_Budget_Name_Id__c = arpPmbRecord.id;
            campBudget.Core_MDF_Campaign_Id__c=arpCamp.id;
            campBudget.Core_MDF_Budget_Amt__c=363636;
            campBudget.Core_MDF_Reimbursement_Rate_Pct__c='55%';
            campBudget.Core_MDF_Reimbursement_Amt__c= 200000;
            campBudget.Core_MDF_Active_ind__c=true;
        campBudgetList.add(campBudget);
        
        Core_MDF_Campaign_Budgets__c campBudget2 = new Core_MDF_Campaign_Budgets__c();
            campBudget2.Core_MDF_Budget_Name_Id__c = arpPmbLegacyRecord.id;
            campBudget2.Core_MDF_Campaign_Id__c=arpCampLegacy.id;
            campBudget2.Core_MDF_Budget_Amt__c=363636;
            campBudget2.Core_MDF_Reimbursement_Rate_Pct__c='55%';
            campBudget2.Core_MDF_Reimbursement_Amt__c= 200000;
            campBudget2.Core_MDF_Active_ind__c=true;
        campBudgetList.add(campBudget2);
        Database.insert(campBudgetList);
        
         List<Core_MDF_Configuration__c> configMDF = new List<Core_MDF_Configuration__c>();
        Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
        config.NAME = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        config.Core_MDF_Value__c='3';
        config.Core_MDF_Category__c ='Bank Document Hold Logic';
        configMDF.add(config);
        
        Core_MDF_Configuration__c config1 = new Core_MDF_Configuration__c();
        config1.NAME = 'Core_MDF_SecondsToDelayPICBatch';
        config1.Core_MDF_Value__c='1';
        configMDF.add(config1);
        insert configMDF;
        
        Test.startTest();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        PartnerFundRequest arpFranceActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(arpCamp.Id), 
                                                                                                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                  String.valueof(arpEMEAFrance.id),pfaARPCCFFrance,arpPmbRecord,'INDIA',
                                                                                                  'Consumer',
                                                                                                  'Desktop',
                                                                                                  'Intel® Core™ i5 Processor',
                                                                                                  'Audio',
                                                                                                  'Podcast',
                                                                                                  'Draft',
                                                                                                  false);
                                                                                                  arpFranceActivity.Title = 'France Activity';
                                                                                                  arpFranceActivity.Core_MDF_Activity_Description__c = 'France Activity';
                                                                                                  arpFranceActivity.Core_MDF_Start_Date__c = System.today().addDays(-2);
                                                                                                  arpFranceActivity.Core_MDF_End_Date__c = System.today().addDays(+2);
                                                                                                  arpFranceActivity.RequestedAmount = 1000;
                                                                                                  arpFranceActivity.Core_MDF_pagespayingfor__c = 15;
                                                                                                  arpFranceActivity.Amount=1000;
        arpFranceActivity.Core_MDF_Budget_Type_nm__c= 'OEM CMP';
        //arpFranceActivity.Core_MDF_Budget_Type_txt__c = 'OEM CMP';
        arpFranceActivity.Core_MDF_Reimbursement_Rate_pct__c='50%';
        arpFranceActivity.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        arpFranceActivity.Core_MDF_Channel_Partner_Led__c = true;
        
        PartnerFundRequest arpFranceActivityLegacy = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(arpCampLegacy.Id), 
                                                                                                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                  String.valueof(arpEMEAFrance.id),pfaARPCCFFranceLegacy,arpPmbLegacyRecord,'INDIA',
                                                                                                  'Consumer',
                                                                                                  'Desktop',
                                                                                                  'Intel® Core™ i5 Processor',
                                                                                                  'Audio',
                                                                                                  'Podcast',
                                                                                                  'Draft',
                                                                                                  false);
                                                                                                  arpFranceActivityLegacy.Title = 'France Activity Legacy';
                                                                                                  arpFranceActivityLegacy.Core_MDF_Activity_Description__c = 'France Activity';
                                                                                                  arpFranceActivityLegacy.Core_MDF_Start_Date__c = System.today().addDays(-2);
                                                                                                  arpFranceActivityLegacy.Core_MDF_End_Date__c = System.today().addDays(+2);
                                                                                                  arpFranceActivityLegacy.RequestedAmount = 1000;
                                                                                                  arpFranceActivityLegacy.Core_MDF_pagespayingfor__c = 15;
                                                                                                  arpFranceActivityLegacy.Amount=1000;
        arpFranceActivityLegacy.Core_MDF_Budget_Type_nm__c= 'OEM CMP';
        //arpFranceActivityLegacy.Core_MDF_Budget_Type_txt__c = 'CCF 1.0';
        arpFranceActivityLegacy.Core_MDF_Reimbursement_Rate_pct__c='50%';
        arpFranceActivityLegacy.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        arpFranceActivityLegacy.Core_MDF_Channel_Partner_Led__c = true;
        pfrList.add(arpFranceActivityLegacy);
        pfrList.add(arpFranceActivity);
        Database.insert(pfrList);
        
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
        Database.insert(rule6);        
       
    }
    
    @isTest static void validatePICClaims1(){
        Test.startTest();
        
        User sysAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr.LastName = 'System Adm';
        insert sysAdmUsr;
        
        system.runAs(sysAdmUsr){
        PermissionSet ccfPayAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
            PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
            assignPermissionSetObj1.AssigneeId = sysAdmUsr.Id;
            assignPermissionSetObj1.PermissionSetId = ccfPayAdmPS.Id;
            insert assignPermissionSetObj1;
        }
        
        PartnerFundRequest arpFranceActivity = [Select id, Core_MDF_Start_Date__c from PartnerFundRequest where Title = 'France Activity'];
        PartnerFundRequest arpFranceActivityLegacy = [Select id, Core_MDF_Start_Date__c from PartnerFundRequest where Title = 'France Activity Legacy'];
        Core_MDF_Bank__c arpBank = [Select id from Core_MDF_Bank__c WHERE Name = 'Test' limit 1];
        arpBank.Core_MDF_Bank_Status__c = 'Hold';
        arpBank.Core_MDF_ESD_Hold_Indicator__c=true;
        system.runAs(sysAdmUsr){
        Database.update(arpBank);
        }
        
        List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        PartnerFundClaim franceClaim = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,arpFranceActivity.Id,arpFranceActivity.Core_MDF_Start_Date__c, arpFranceActivity.Core_MDF_Start_Date__c,700,System.today(),arpBank.ID,false);
        franceClaim.Core_MDF_Budget_Type_Options_Nm__c= 'OEM CMP';
        franceClaim.Core_MDF_Currency__c='USD';
        franceClaim.Core_MDF_Manaul_Audit_Staging_Ind__c = true;
        claimList.add(franceClaim);
        PartnerFundClaim franceClaimLegacy = Core_MDF_CCP_TestDataUtility.createClaim('France Claim Legacy', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,arpFranceActivityLegacy.Id,arpFranceActivityLegacy.Core_MDF_Start_Date__c, arpFranceActivityLegacy.Core_MDF_Start_Date__c,100,System.today(),arpBank.ID,false);
        franceClaimLegacy.Core_MDF_Budget_Type_Options_Nm__c= 'CCF 1.0';
        franceClaimLegacy.Core_MDF_Currency__c='USD';
       claimList.add(franceClaimLegacy);
        Database.insert(franceClaim);
        
        PartnerFundClaim reservedClaim12 = [Select Status,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_ESD_Hold__c,Core_MDF_Status__c,Core_MDF_Eligible_for_PIC__c,Core_MDF_PIC_Review_Completed__c From PartnerFundClaim WHERE Id = :franceClaim.Id LIMIT 1];
       // PartnerFundClaim reservedClaim2 = [Select Status,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_ESD_Hold__c,Core_MDF_Status__c,Core_MDF_Eligible_for_PIC__c,Core_MDF_PIC_Review_Completed__c From PartnerFundClaim WHERE Id = :franceClaimLegacy.Id LIMIT 1];
                System.assertEquals(reservedClaim12.Status, 'Submitted'); 
               // System.assertEquals(reservedClaim12.Core_MDF_Status__c, 'PIC Pending'); 
                System.assertEquals(reservedClaim12.Core_MDF_ESD_Hold__c, true);
                
                reservedClaim12.Core_MDF_PIC_Review_Completed__c = true;
                Database.update(reservedClaim12);
       // Highlight: Unused Local Variable - Indira
       // PartnerFundClaim reservedClaimUpdated2 = [Select Status, Core_MDF_Claim_Previous_Status__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_ESD_Hold__c,Core_MDF_Status__c,Core_MDF_Eligible_for_PIC__c From PartnerFundClaim WHERE Id = :franceClaim.Id LIMIT 1];
                
                //System.assertEquals(reservedClaim12.Core_MDF_Status__c, 'PIC Pending');
        Test.stopTest();
    }
    
    @isTest static void validatePICClaims2(){
        Test.startTest();
        
        User sysAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr.LastName = 'System Adm';
        insert sysAdmUsr;
        
        system.runAs(sysAdmUsr){
        PermissionSet ccfPayAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
            PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
            assignPermissionSetObj1.AssigneeId = sysAdmUsr.Id;
            assignPermissionSetObj1.PermissionSetId = ccfPayAdmPS.Id;
            insert assignPermissionSetObj1;
        }
        
        PartnerFundRequest arpFranceActivity = [Select id, Core_MDF_Start_Date__c from PartnerFundRequest where Title = 'France Activity'];
       // Highlight: Unused Local Variable - Indira
       // PartnerFundRequest arpFranceActivityLegacy = [Select id, Core_MDF_Start_Date__c from PartnerFundRequest where Title = 'France Activity Legacy'];
        Core_MDF_Bank__c arpBank = [Select id from Core_MDF_Bank__c WHERE Name = 'Test' limit 1];
        arpBank.Core_MDF_Bank_Status__c = 'Active';
        arpBank.Core_MDF_ESD_Hold_Indicator__c=false;
        
        system.runAs(sysAdmUsr){
        Database.update(arpBank);
        }
        // Highlight: Unused Local Variable - Indira
       // List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        PartnerFundClaim franceClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,arpFranceActivity.Id,arpFranceActivity.Core_MDF_Start_Date__c, arpFranceActivity.Core_MDF_Start_Date__c,300,System.today(),arpBank.ID,false);
        franceClaim2.Core_MDF_Budget_Type_Options_Nm__c= 'OEM CMP';
        franceClaim2.Core_MDF_Currency__c='USD';
        Database.insert(franceClaim2);
        //claimList.add(franceClaim);
        Test.stopTest();
        PartnerFundClaim reservedClaim11 = [Select Status,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_ESD_Hold__c,Core_MDF_Status__c,Core_MDF_Eligible_for_PIC__c,Core_MDF_PIC_Review_Completed__c From PartnerFundClaim WHERE Id = :franceClaim2.Id LIMIT 1];

                System.assertEquals(reservedClaim11.Status, 'Submitted'); 
                System.assertEquals(reservedClaim11.Core_MDF_Status__c, 'PIC Pending'); 
                System.assertEquals(reservedClaim11.Core_MDF_ESD_Hold__c, false);
               
                reservedClaim11.Core_MDF_PIC_Review_Completed__c = true;
                Database.update(reservedClaim11);
       // Highlight: Unused Local Variable - Indira
       // PartnerFundClaim reservedClaimUpdated = [Select Status,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_ESD_Hold__c,Core_MDF_Status__c,Core_MDF_Eligible_for_PIC__c From PartnerFundClaim WHERE Id = :franceClaim2.Id LIMIT 1];
             
        
    }
        
    @isTest static void validatePICClaims3(){
        Test.startTest();
        
        User sysAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr.LastName = 'System Adm';
        insert sysAdmUsr;
        
        system.runAs(sysAdmUsr){
        PermissionSet ccfPayAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
            PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
            assignPermissionSetObj1.AssigneeId = sysAdmUsr.Id;
            assignPermissionSetObj1.PermissionSetId = ccfPayAdmPS.Id;
            insert assignPermissionSetObj1;
        }
        // Highlight: Unused Local Variable - Indira
       // PartnerFundRequest arpFranceActivity = [Select id, Core_MDF_Start_Date__c from PartnerFundRequest where Title = 'France Activity'];
        PartnerFundRequest arpFranceActivityLegacy = [Select id, Core_MDF_Start_Date__c from PartnerFundRequest where Title = 'France Activity Legacy'];
        Core_MDF_Bank__c arpBank = [Select id from Core_MDF_Bank__c WHERE Name = 'Test' limit 1];
        arpBank.Core_MDF_Bank_Status__c = 'Active';
        arpBank.Core_MDF_ESD_Hold_Indicator__c=false;
        system.runAs(sysAdmUsr){
        Database.update(arpBank);
        }
       // Highlight: Unused Local Variable - Indira 
       // List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
                PartnerFundClaim franceClaimLegacy2 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim Legacy2', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,arpFranceActivityLegacy.Id,arpFranceActivityLegacy.Core_MDF_Start_Date__c, arpFranceActivityLegacy.Core_MDF_Start_Date__c,6000,System.today(),arpBank.ID,false);
        franceClaimLegacy2.Core_MDF_Budget_Type_Options_Nm__c= 'OEM CMP';
        franceClaimLegacy2.Core_MDF_Currency__c='USD';
        Database.insert(franceClaimLegacy2);
        Test.stopTest();
        PartnerFundClaim reservedClaim10 = [Select Status,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_ESD_Hold__c,Core_MDF_Status__c,Core_MDF_Eligible_for_PIC__c,Core_MDF_PIC_Review_Completed__c From PartnerFundClaim WHERE Id = :franceClaimLegacy2.Id LIMIT 1];
                System.assertEquals(reservedClaim10.Status, 'Submitted'); 
              //  System.assertEquals(reservedClaim.Core_MDF_Status__c, 'PIC Pending'); 
                System.assertEquals(reservedClaim10.Core_MDF_ESD_Hold__c, false);
    }
      @isTest static void validatePICClaims4(){
      
      Test.starttest();
      PartnerFundRequest arpFranceActivityLegacy = [Select id, Core_MDF_Start_Date__c from PartnerFundRequest where Title = 'France Activity Legacy'];
      Core_MDF_Bank__c arpBank = [Select id from Core_MDF_Bank__c WHERE Name = 'Test' limit 1];
      //List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        
        PartnerFundClaim franceClaimLegacy = Core_MDF_CCP_TestDataUtility.createClaim('France Claim Legacy', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,arpFranceActivityLegacy.Id,arpFranceActivityLegacy.Core_MDF_Start_Date__c, arpFranceActivityLegacy.Core_MDF_Start_Date__c,100,System.today(),arpBank.ID,false);
        franceClaimLegacy.Core_MDF_Budget_Type_Options_Nm__c= 'OEM CMP';
        franceClaimLegacy.Core_MDF_Currency__c='USD';
        franceClaimLegacy.Core_MDF_ESD_Hold__c=true;
        franceClaimLegacy.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c=true;
        //claimList.add(franceClaimLegacy);
        Database.insert(franceClaimLegacy);
        Core_MDF_PIC_Utility.addDelay();
        Core_MDF_PIC_Utility.isHoldApplicable(franceClaimLegacy);
        test.stoptest();
        // Unit Test Method should include System.Assert - Indira
        System.assertNotEquals(null, franceClaimLegacy.Id, 'France Claim Legacy should be created successfully');
      }   

    @isTest static void executeReturnsWhenNoClaimsAreProvided() {
        Integer dmlStatementsBeforeExecution = Limits.getDmlStatements();
        Test.startTest();
        new Core_MDF_BatchtoPICClaim(new List<PartnerFundClaim>()).execute(null);
        Test.stopTest();
        System.assertEquals(dmlStatementsBeforeExecution, Limits.getDmlStatements());
    }

    @isTest static void executeProcessesLegacyAuditResults() {
        disableAutomaticPICQueueable();
        PartnerFundRequest legacyRequest = [
            SELECT Id, Core_MDF_Start_Date__c
            FROM PartnerFundRequest
            WHERE Title = 'France Activity Legacy'
            LIMIT 1
        ];
        Core_MDF_Bank__c bank = [SELECT Id FROM Core_MDF_Bank__c WHERE Name = 'Test' LIMIT 1];
        Core_MDF_Audit_Rules_Engine__c auditRule = [
            SELECT Id
            FROM Core_MDF_Audit_Rules_Engine__c
            WHERE Core_MDF_Rule_Type_Nm__c = 'Audit'
                AND Core_MDF_Budget_Type_Multi_Nm__c = 'CCF 1.0'
            LIMIT 1
        ];
        auditRule.Core_MDF_Field_Nm__c = 'Core_MDF_Currency__c';
        auditRule.Core_MDF_Operator_Nm__c = 'Equal';
        auditRule.Core_MDF_Value_Txt__c = 'USD';
        update auditRule;

        PartnerFundClaim claimWithoutDocuments = Core_MDF_CCP_TestDataUtility.createClaim(
            'Legacy Claim Without Documents',
            Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,
            legacyRequest.Id,
            legacyRequest.Core_MDF_Start_Date__c,
            legacyRequest.Core_MDF_Start_Date__c,
            300,
            System.today(),
            bank.Id,
            false
        );
        claimWithoutDocuments.Core_MDF_Budget_Type_Options_Nm__c = 'CCF 1.0';
        claimWithoutDocuments.Core_MDF_Currency__c = 'USD';

        PartnerFundClaim claimWithDocuments = Core_MDF_CCP_TestDataUtility.createClaim(
            'Legacy Claim With Documents',
            Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,
            legacyRequest.Id,
            legacyRequest.Core_MDF_Start_Date__c,
            legacyRequest.Core_MDF_Start_Date__c,
            300,
            System.today(),
            bank.Id,
            false
        );
        claimWithDocuments.Core_MDF_Budget_Type_Options_Nm__c = 'CCF 1.0';
        claimWithDocuments.Core_MDF_Currency__c = 'USD';

        insert new List<PartnerFundClaim>{
            claimWithoutDocuments,
            claimWithDocuments
        };
        update new List<PartnerFundClaim>{
            new PartnerFundClaim(
                Id = claimWithoutDocuments.Id,
                Core_MDF_Budget_Type_Options_Nm__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CCF1_0')
            ),
            new PartnerFundClaim(
                Id = claimWithDocuments.Id,
                Core_MDF_Budget_Type_Options_Nm__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CCF1_0')
            )
        };

        List<Core_MDF_Audit_Document__c> documentsForClaimWithoutDocuments = [
            SELECT Id
            FROM Core_MDF_Audit_Document__c
            WHERE Core_MDF_Claim__c = :claimWithoutDocuments.Id
        ];
        delete documentsForClaimWithoutDocuments;

        Core_MDF_Audit_Document__c auditDocument = new Core_MDF_Audit_Document__c(
            Core_MDF_Claim__c = claimWithDocuments.Id,
            Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution',
            Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Execution;Proof of Attribution',
            Core_MDF_Document_Title__c = 'Audit proof documents'
        );
        insert auditDocument;
        delete [
            SELECT Id
            FROM Core_MDF_Audit_Document__c
            WHERE Core_MDF_Claim__c = :claimWithoutDocuments.Id
        ];
        Map<Id, Boolean> documentAvailability = Core_MDF_Audit_Rules_Processing.checkPOPDocuments(
            new List<Id>{claimWithoutDocuments.Id, claimWithDocuments.Id}
        );
        System.assertEquals(false, documentAvailability.get(claimWithoutDocuments.Id));
        System.assertEquals(true, documentAvailability.get(claimWithDocuments.Id));

        PartnerFundClaim legacyClaim = [
            SELECT Id, Core_MDF_Program__c, Core_MDF_Budget_Type_Options_Nm__c
            FROM PartnerFundClaim
            WHERE Id = :claimWithoutDocuments.Id
        ];
        System.assertEquals(
            Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name'),
            legacyClaim.Core_MDF_Program__c,
            'The claim program must use the CCF program label for legacy processing.'
        );
        System.assertEquals(
            Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CCF1_0'),
            legacyClaim.Core_MDF_Budget_Type_Options_Nm__c,
            'The claim budget type must use the legacy CCF value.'
        );
        System.assertEquals(true, Core_MDF_PIC_Utility.isLegacy(legacyClaim));
        Map<String, Map<Id, Core_MDF_Rules_Engine.RulesEngineParams>> auditResults =
            Core_MDF_Rules_Engine.genericEngineFlow(
                new Map<String, Set<Id>>{'Audit' => new Set<Id>{claimWithoutDocuments.Id}}
            );
        System.assertEquals(true, auditResults.get('Audit').get(claimWithoutDocuments.Id).result);

        Test.startTest();
        new Core_MDF_BatchtoPICClaim(new List<PartnerFundClaim>{
            claimWithoutDocuments,
            claimWithDocuments
        }).execute(null);
        Test.stopTest();

        Map<Id, PartnerFundClaim> processedClaims = new Map<Id, PartnerFundClaim>([
            SELECT Id, Core_MDF_Eligible_for_PIC__c, Core_MDF_Status__c,
                Core_MDF_Reprocess_Claim__c, Core_MDF_Claim_EvalInProgress_Ind__c
            FROM PartnerFundClaim
            WHERE Id IN :new Set<Id>{claimWithoutDocuments.Id, claimWithDocuments.Id}
        ]);

        System.assertEquals(true, processedClaims.get(claimWithoutDocuments.Id).Core_MDF_Eligible_for_PIC__c);
        System.assertEquals(
            Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_PendingDocs'),
            processedClaims.get(claimWithoutDocuments.Id).Core_MDF_Status__c
        );
        System.assertEquals(true, processedClaims.get(claimWithDocuments.Id).Core_MDF_Eligible_for_PIC__c);
        System.assertEquals(
            Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PIC_Pending'),
            processedClaims.get(claimWithDocuments.Id).Core_MDF_Status__c
        );
    }

    @isTest static void executeClearsFlagsWhenLegacyAuditRuleDoesNotMatch() {
        disableAutomaticPICQueueable();
        PartnerFundRequest legacyRequest = [
            SELECT Id, Core_MDF_Start_Date__c
            FROM PartnerFundRequest
            WHERE Title = 'France Activity Legacy'
            LIMIT 1
        ];
        Core_MDF_Bank__c bank = [SELECT Id FROM Core_MDF_Bank__c WHERE Name = 'Test' LIMIT 1];
        Core_MDF_Audit_Rules_Engine__c auditRule = [
            SELECT Id
            FROM Core_MDF_Audit_Rules_Engine__c
            WHERE Core_MDF_Rule_Type_Nm__c = 'Audit'
                AND Core_MDF_Budget_Type_Multi_Nm__c = 'CCF 1.0'
            LIMIT 1
        ];
        auditRule.Core_MDF_Field_Nm__c = 'Core_MDF_Budget_Type_Options_Nm__c';
        auditRule.Core_MDF_Operator_Nm__c = 'Equal';
        auditRule.Core_MDF_Value_Txt__c = 'A different budget type';
        update auditRule;

        PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim(
            'Legacy Claim Without Matching Audit Rule',
            Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,
            legacyRequest.Id,
            legacyRequest.Core_MDF_Start_Date__c,
            legacyRequest.Core_MDF_Start_Date__c,
            300,
            System.today(),
            bank.Id,
            false
        );
        claim.Core_MDF_Budget_Type_Options_Nm__c = 'CCF 1.0';
        claim.Core_MDF_Currency__c = 'USD';
        claim.Core_MDF_Reprocess_Claim__c = true;
        claim.Core_MDF_Claim_EvalInProgress_Ind__c = true;
        insert claim;
        update new PartnerFundClaim(
            Id = claim.Id,
            Core_MDF_Budget_Type_Options_Nm__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CCF1_0')
        );

        Test.startTest();
        new Core_MDF_BatchtoPICClaim(new List<PartnerFundClaim>{claim}).execute(null);
        Test.stopTest();

        PartnerFundClaim processedClaim = [
            SELECT Core_MDF_Reprocess_Claim__c, Core_MDF_Claim_EvalInProgress_Ind__c
            FROM PartnerFundClaim
            WHERE Id = :claim.Id
        ];
        System.assertEquals(false, processedClaim.Core_MDF_Reprocess_Claim__c);
        System.assertEquals(false, processedClaim.Core_MDF_Claim_EvalInProgress_Ind__c);
    }

    private static void disableAutomaticPICQueueable() {
        Core_Trigger_Executions__c picExecution = [
            SELECT Id, Core_Active__c
            FROM Core_Trigger_Executions__c
            WHERE Name = 'checkAndSendClaimsForPIC'
            LIMIT 1
        ];
        picExecution.Core_Active__c = false;
        update picExecution;
    }         
}