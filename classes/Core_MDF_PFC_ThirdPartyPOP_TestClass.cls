/**************************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_ThirdPartyPOP_TestClass
* Version     : 1.0 
* Created Date: 14-1-2022
* Modification Log :
* Developer                   Date                     Description
* -------------------------------------------------------------------------------------------------------------------------------------------------
*INTEL-Areefa Banu            14-1-2022               Created to test PartnerFundClaim which is eligible for ThirdParty POP functionality. 
**************************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_PFC_ThirdPartyPOP_TestClass {
    @TestSetup
    static void makeData() {
       
        List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing'}, true, false));       
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Allocation_Reservation','Bypass_GeoBased_Allocation_Sharing'}, true, false));   
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Bank_Check','Bypass_Bank_Internal_Sharing',
                    'Bypass_Bank_External_Sharing','Bypass_Bank_Program_InActivation_Check','Bypass_Bank_ABM_Sharing'}, true, false));
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing'}, true, false));
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_MDF_Budget_Access','Bypass_MDF_Budget_Access_Validation'}, true, false));                   
        Database.insert(transactions);
        
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
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        insert grp;
        system.runAs(sysAdmUsr){
            
        /*GroupMember gm = new GroupMember();
        gm.GroupId = grp.Id;
        gm.UserOrGroupId = usr1.Id;
        insert gm;*/
        
        }   
        Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(arpIntelAcc.Id,'External',arpIntelAcc.Id,ccfCP.Id,'PGM_TEST',true);
        
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
        Core_MDF_Bank__c arpBank = new Core_MDF_Bank__c();
        arpBank = Core_MDF_CCP_TestDataUtility.createBank(arpIntelAcc.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
        arpBank.Core_MDF_Effective_Date__c= system.today().addDays(-2);
        System.runAs(sysAdmUsr){
        insert arpBank;
        }
        
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(arpEMEAFrance.Id,arpBank.Id,true);

        List<Campaign> campList = new List<Campaign>();
        Campaign arpCamp = Core_MDF_CCP_TestDataUtility.createCampaign('ARP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', arpCCFVC.Id, '2-in-1', false);
        arpCamp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        arpCamp.Core_MDF_Supports_legacy_program__c='MDF or both CMP & MDF';
        campList.add(arpCamp);
        Campaign arpCampLegacy = Core_MDF_CCP_TestDataUtility.createCampaign('ARP Legacy Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', arpCCFVC.Id, '2-in-1', false);
        arpCampLegacy.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
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
        insert configMDF;
        
        Test.startTest();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        PartnerFundRequest arpFranceActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(arpCamp.Id), 
                                                                                                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                  String.valueof(arpEMEAFrance.id),pfaARPCCFFrance,arpPmbRecord,'INDIA',
                                                                                                  'Consumer',
                                                                                                  'Desktop',
                                                                                                  'Intel® Core™ i5 Processor',
                                                                                                  'Broadcast',
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
        arpFranceActivity.Core_MDF_Reimbursement_Rate_pct__c='100%';
        arpFranceActivity.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        arpFranceActivity.Core_MDF_Channel_Partner_Led__c = true;
        
        PartnerFundRequest arpFranceActivityLegacy = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(arpCampLegacy.Id), 
                                                                                                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                  String.valueof(arpEMEAFrance.id),pfaARPCCFFranceLegacy,arpPmbLegacyRecord,'INDIA',
                                                                                                  'Consumer',
                                                                                                  'Desktop',
                                                                                                  'Intel® Core™ i5 Processor',
                                                                                                  'Broadcast',
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
        arpFranceActivityLegacy.Core_MDF_Budget_Type_nm__c= 'CCF 1.0';
        arpFranceActivityLegacy.Core_MDF_Reimbursement_Rate_pct__c='100%';
        arpFranceActivityLegacy.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        arpFranceActivityLegacy.Core_MDF_Channel_Partner_Led__c = true;
        pfrList.add(arpFranceActivityLegacy);
        pfrList.add(arpFranceActivity);
        Database.insert(pfrList);
        
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount aObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount bObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount cObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> listvar = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
        
        aObj.inputCurrency ='ZMK';
        aObj.inputAmount = 250.00;
        aObj.inputDate= System.today();
        bObj.inputCurrency ='INR';
        bObj.inputAmount = 300.00;
        bObj.inputDate= System.today();
        cObj.inputCurrency ='USD';
        cObj.inputAmount = 300.00;
        cObj.inputDate= System.today();
        listvar.add(aObj);
        listvar.add(bObj);
        listvar.add(cObj);
        Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(listvar);
        
        //List<Core_MDF_Audit_Rules_Engine__c> thirdPartyRuleList = new List<Core_MDF_Audit_Rules_Engine__c>();
        
        Core_MDF_Audit_Rules_Engine__c thirdPartyRule = new Core_MDF_Audit_Rules_Engine__c(); 
        thirdPartyRule.Core_MDF_Object_Nm__c= 'PartnerFundClaim';
        thirdPartyRule.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
        thirdPartyRule.Core_MDF_Field_Nm__c= 'Core_MDF_Requested_Reimbursement_Amt__c';
        thirdPartyRule.Core_MDF_Operator_Nm__c= 'Greater Than';
        thirdPartyRule.Core_MDF_Budget_Type_Multi_Nm__c= 'MDF;MDF+;OEM CMP';
        thirdPartyRule.Core_MDF_Value_Txt__c= '1';
        thirdPartyRule.Core_MDF_Immediate_Ind__c= 'Yes';
        thirdPartyRule.Core_MDF_Effective_Dt__c= System.today()-1;
        thirdPartyRule.Core_MDF_Active_Ind__c= true;
        thirdPartyRule.Core_MDF_Rule_Type_Nm__c= 'Third Party';
        thirdPartyRule.Core_MDF_Region_Cd__c = 'WW';
        Database.insert(thirdPartyRule);
       
    }
    
    @isTest static void validate3rdPartyPOPClaims1(){
    
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
        
        Core_MDF_PFC_ThirdPartyPOP.wrapperThirdPartyPOP obj = new Core_MDF_PFC_ThirdPartyPOP.wrapperThirdPartyPOP();
        PartnerFundRequest arpFranceActivity = [Select id,Core_MDF_Reimbursement_Rate_pct__c,Core_MDF_Reimbursement_Rate_txt__c, Core_MDF_Start_Date__c from PartnerFundRequest where Title = 'France Activity'];
        PartnerFundRequest arpFranceActivityLegacy = [Select id,Core_MDF_Reimbursement_Rate_pct__c,Core_MDF_Reimbursement_Rate_txt__c, Core_MDF_Start_Date__c from PartnerFundRequest where Title = 'France Activity Legacy'];
        Core_MDF_Bank__c arpBank = [Select id from Core_MDF_Bank__c WHERE Name = 'Test' limit 1];
        arpBank.Core_MDF_Bank_Status__c = 'Active';
        arpBank.Core_MDF_ESD_Hold_Indicator__c=false;
        
        System.runAs(sysAdmUsr){
        Database.update(arpBank);
        }
        
        List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        PartnerFundClaim franceClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,arpFranceActivity.Id,arpFranceActivity.Core_MDF_Start_Date__c, arpFranceActivity.Core_MDF_Start_Date__c,300,System.today(),arpBank.ID,false);
        franceClaim2.Core_MDF_Budget_Type_Options_Nm__c= 'OEM CMP';
        franceClaim2.Core_MDF_Currency__c='USD';
        claimList.add(franceClaim2);
        Database.insert(franceClaim2);
        Test.stopTest();
        PartnerFundClaim ThirdPartyClaim = [Select Id,Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_Region_Cd__c,Status,Core_MDF_Budget_Type_Nm__c,Core_MDF_ESD_Hold__c,Core_MDF_Status__c,Core_MDF_Eligible_for_PIC__c,Core_MDF_PIC_Review_Completed__c,CreatedDate From PartnerFundClaim WHERE Id = :franceClaim2.Id LIMIT 1];
        
        
        Core_MDF_PartnerFundClaim_Edit.ClaimCountryDetailsWrapper clonePFC = new Core_MDF_PartnerFundClaim_Edit.ClaimCountryDetailsWrapper();
        clonePFC = Core_MDF_PartnerFundClaim_Edit.prepareCloneData(ThirdPartyClaim.Id);

        PartnerFundClaim ThirdPartyClaim123 = [Select Id,Core_MDF_Program__c,Core_MDF_Ultimate_Account_ID__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,Core_MDF_Currency__c,Core_MDF_Country_Location_nm__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_Region_Cd__c,Status,Core_MDF_Budget_Type_Nm__c,Core_MDF_Type_Txt__c,Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Taxes_Local__c,Amount,Core_MDF_Audit_Adjustment_Amount__c,Core_MDF_Requested_Reimbursement_Amt__c,Core_MDF_Exchange_rate__c,Core_MDF_Reimbursable_Transaction_Amount__c,Core_MDF_Status__c,Core_MDF_Eligible_for_PIC__c,Core_MDF_PIC_Review_Completed__c,CreatedDate From PartnerFundClaim WHERE Id = :clonePFC.claimObj.Id LIMIT 1];
        obj= Core_MDF_PFC_ThirdPartyPOP.isValidThirdPartyPOPClaim(ThirdPartyClaim123);
        
        System.assertEquals(obj.isThirdPartyPOP, true);
        System.assertNotEquals(obj.ruleId, null);
        
        //List<PartnerFundClaim> claimList1 = new List<PartnerFundClaim>();
        //claimList1.add(ThirdPartyClaim123);            
        //database.insert(claimList1);
        //PartnerFundClaim ThirdPartyClaim456 = [Select Id,Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_Region_Cd__c,Status,Core_MDF_Budget_Type_Nm__c,Core_MDF_ESD_Hold__c,Core_MDF_Status__c,Core_MDF_Eligible_for_PIC__c,Core_MDF_PIC_Review_Completed__c,CreatedDate From PartnerFundClaim WHERE Id = :ThirdPartyClaim123.Id LIMIT 1];
       
        obj = Core_MDF_PFC_ThirdPartyPOP.isClaimFlagedForThirdPartyPOP(ThirdPartyClaim123.Id);
        System.assertEquals(obj.isThirdPartyPOP , false);
    }
    
    @isTest static void validate3rdPartyPOPExceptionClaims2(){
        
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
         
        Core_MDF_PFC_ThirdPartyPOP.wrapperThirdPartyPOP obj = new Core_MDF_PFC_ThirdPartyPOP.wrapperThirdPartyPOP();
        PartnerFundRequest arpFranceActivityLegacy = [Select id,Core_MDF_Reimbursement_Rate_pct__c,Core_MDF_Reimbursement_Rate_txt__c, Core_MDF_Start_Date__c from PartnerFundRequest where Title = 'France Activity Legacy'];
        Core_MDF_Bank__c arpBank = [Select id from Core_MDF_Bank__c WHERE Name = 'Test' limit 1];
        arpBank.Core_MDF_Bank_Status__c = 'Active';
        arpBank.Core_MDF_ESD_Hold_Indicator__c=false;
        system.runAs(sysAdmUsr){
        Database.update(arpBank);
        }
        
        List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        PartnerFundClaim franceClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,arpFranceActivityLegacy.Id,arpFranceActivityLegacy.Core_MDF_Start_Date__c, arpFranceActivityLegacy.Core_MDF_Start_Date__c,300,System.today(),arpBank.ID,false);
        franceClaim2.Core_MDF_Budget_Type_Options_Nm__c= 'OEM CMP';
        franceClaim2.Core_MDF_Currency__c='USD';
        claimList.add(franceClaim2);
        Database.insert(franceClaim2);
        Test.stopTest();
        PartnerFundClaim ThirdPartyClaim = [Select Id,Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,Core_MDF_Ultimate_Account_ID__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_Region_Cd__c,Status,Core_MDF_Budget_Type_Nm__c,Core_MDF_ESD_Hold__c,Core_MDF_Status__c,Core_MDF_Eligible_for_PIC__c,Core_MDF_PIC_Review_Completed__c,CreatedDate From PartnerFundClaim WHERE Id = :franceClaim2.Id LIMIT 1];
        
        Core_MDF_PartnerFundClaim_Edit.ClaimCountryDetailsWrapper clonePFC = new Core_MDF_PartnerFundClaim_Edit.ClaimCountryDetailsWrapper();
        clonePFC = Core_MDF_PartnerFundClaim_Edit.prepareCloneData(ThirdPartyClaim.Id);

        PartnerFundClaim ThirdPartyClaim123 = [Select Id,Core_MDF_Program__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Ultimate_Account_ID__c,Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,Core_MDF_Currency__c,Core_MDF_Country_Location_nm__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_Region_Cd__c,Status,Core_MDF_Budget_Type_Nm__c,Core_MDF_Type_Txt__c,Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Taxes_Local__c,Amount,Core_MDF_Audit_Adjustment_Amount__c,Core_MDF_Requested_Reimbursement_Amt__c,Core_MDF_Exchange_rate__c,Core_MDF_Reimbursable_Transaction_Amount__c,Core_MDF_Status__c,Core_MDF_Eligible_for_PIC__c,Core_MDF_PIC_Review_Completed__c,CreatedDate From PartnerFundClaim WHERE Id = :clonePFC.claimObj.Id LIMIT 1];
        obj= Core_MDF_PFC_ThirdPartyPOP.isValidThirdPartyPOPClaim(ThirdPartyClaim123);
        
        System.assertEquals(obj.isThirdPartyPOP, false);       
        
        
    }
}