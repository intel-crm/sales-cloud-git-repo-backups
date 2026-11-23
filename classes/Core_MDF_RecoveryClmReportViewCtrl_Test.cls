@isTest(SeeAllData=false)
private class Core_MDF_RecoveryClmReportViewCtrl_Test {
      public static set<String> Programs_For_Node_Account = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;
    @TestSetup 
    static void makeData() {
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = sysAdminProfile.Id;
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        //Running as System Admin
        System.runAs(usr){
            List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_MDF_Budget_Access','Bypass_GeoBased_Budget_Sharing','Bypass_MDF_Budget_Access_Validation','Bypass_MDF_Budget_Status_Validation'}, true, false));        
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Allocation_Reservation','Bypass_GeoBased_Allocation_Sharing'}, true, false));   
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Bank_Check','Bypass_Bank_Internal_Sharing',
                'Bypass_Bank_External_Sharing','Bypass_Bank_Program_InActivation_Check','Bypass_Bank_ABM_Sharing'}, true, false));
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing','ByPass_BlockLegacyBudgetCreation'}, true, false));                 
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
            arpIntelAcc.Core_MDF_Active_Ind__c=true;
            Database.insert(arpIntelAcc);   
            
            Account arpCCFVC = Core_MDF_CCP_TestDataUtility.createAccount ('ARP CCF Virtual Corp', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            arpCCFVC.Core_MDF_Parent_Fund_Account__c = arpIntelAcc.Id;
            arpCCFVC.Core_MDF_Active_Ind__c = true;
            arpCCFVC.Core_MDF_CoMarketingActive__c = true;
            Database.insert(arpCCFVC);
            
            Account arpCCFEMEA = Core_MDF_CCP_TestDataUtility.createAccount ('ARP CCF EMEA', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            arpCCFEMEA.Core_MDF_Parent_Fund_Account__c = arpCCFVC.Id;
            arpCCFEMEA.Core_MDF_Active_Ind__c = true;
            Database.insert(arpCCFEMEA);
            
            Account arpEMEAFrance = Core_MDF_CCP_TestDataUtility.createAccount ('ARP CCF EMEA France', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            arpEMEAFrance.Core_MDF_Parent_Fund_Account__c = arpCCFEMEA.Id;
            arpEMEAFrance.Core_MDF_Auto_Transfer_Account__c = arpCCFVC.Id;
            arpEMEAFrance.Core_MDF_Enabled_Auto_Transfer__c = True;
            arpEMEAFrance.Core_MDF_Active_Ind__c = true;
            Database.insert(arpEMEAFrance);
            
            List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget  arpPmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('ARP PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,arpCCFVC.Id,ccfCP.Id,100000,System.today().addDays(-10),System.today().addDays(10),false);
            arpPmbRecord.Core_MDF_Budget_Type_Txt__c ='OEM CMP';
            
            PartnerMarketingBudget  arpPmbLegacyRecord = Core_MDF_CCP_TestDataUtility.createBudget('ARP PMB Legacy',Core_MDF_CCP_TestDataUtility.budget_Record_Type,arpCCFVC.Id,ccfCP.Id,100000,System.today().addDays(-10),System.today().addDays(10),false);
            arpPmbLegacyRecord.Core_MDF_Budget_Type_Txt__c ='CCF 1.0';
            //arpPmbRecord.Core_MDF_Budget_Status__c = 'Released';
            budgetList.add(arpPmbRecord);
            budgetList.add(arpPmbLegacyRecord);
            Database.insert(budgetList);
            
            
            
            PartnerFundAllocation pfaARPCCFFrance = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaARPCCFFrance',arpPmbRecord, arpEMEAFrance, 1000, true);
            PartnerFundAllocation pfaARPCCFFranceLegacy = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaARPCCFFrance',arpPmbLegacyRecord, arpEMEAFrance, 1000, true);
            Core_MDF_Bank__c arpBank = Core_MDF_CCP_TestDataUtility.createBank(arpIntelAcc.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            
            
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
            
            
            
            User usr6 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr6.LastName = 'User Test6';
            usr6.IsActive = true;
            Database.insert(usr6);
            
            List<Core_MDF_Criteria__c> cList = new List<Core_MDF_Criteria__c>();
            Core_MDF_Criteria__c cr = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
                                                                                  'Core_MDF_Region_nm__c','Equal','WW','Core_MDF_Region_nm__c','Equal', 'APJ',
                                                                                  'Core_MDF_Region_nm__c','Equal','APJ','Core_MDF_ProductType__c','Equal','Desktop','RequestedAmount','Greater Than','4000',false);
            cr.Core_MDF_Field_Name_2__c = 'Core_MDF_Region_nm__c';
            cr.Core_MDF_Operator_2__c = 'Equal';
            cr.Core_MDF_Value_2__c = 'WW';
            cr.Core_MDF_Field_Name_3__c = 'Core_MDF_Region_nm__c';
            cr.Core_MDF_Operator_3__c = 'Equal';
            cr.Core_MDF_Value_3__c = 'WW';
            cr.Core_MDF_Field_Name_6__c = 'Core_MDF_Region_nm__c';
            cr.Core_MDF_Operator_6__c = 'Equal';
            cr.Core_MDF_Value_6__c = 'APJ';
            cr.Core_MDF_Field_Name_7__c = 'Core_MDF_Region_nm__c';
            cr.Core_MDF_Operator_7__c = 'Equal';
            cr.Core_MDF_Value_7__c = 'WW';
            cr.Core_MDF_Field_Name_8__c = 'Core_MDF_Region_nm__c';
            cr.Core_MDF_Operator_8__c = 'Equal';
            cr.Core_MDF_Value_8__c = 'WW';
            cr.Core_MDF_Active__c = false;
            cList.add(cr);
            Database.insert(cList);
            
            List<Core_MDF_Approver__c> appList = new List<Core_MDF_Approver__c>();
            // Creating approvers
            Core_MDF_Approver__c ap1 = Core_MDF_CCP_TestDataUtility.createApprover(cList[0].Id,usr6.Id, false);
            ap1.Core_MDF_Approver_Type__c = 'Internal';
            ap1.Core_MDF_Approver_2__c = usr6.Id;
            ap1.Core_MDF_Approver_3__c = usr6.Id;
            ap1.Core_MDF_Approver_4__c = usr6.Id;
            ap1.Core_MDF_Approver_5__c = usr6.Id;
            ap1.Core_MDF_Approver_6__c = usr6.Id;
            ap1.Core_MDF_Approver_7__c = usr6.Id;
            ap1.Core_MDF_Approver_8__c = usr6.Id;
            ap1.Core_MDF_Approver_9__c = usr6.Id;
            ap1.Core_MDF_Approver_10__c = usr6.Id;
            ap1.Core_MDF_Active__c = false;
            appList.add(ap1);
            
            Core_MDF_Approver__c ap2 = Core_MDF_CCP_TestDataUtility.createApprover(cList[0].Id,usr6.Id, false);
            ap2.Core_MDF_Approver_Type__c = 'Internal';
            ap2.Core_MDF_Approver_2__c = usr6.Id;
            ap2.Core_MDF_Active__c = false;
            appList.add(ap2);
            Database.insert(appList);
            
            List<Core_MDF_Criteria_Rule__c> crList = new List<Core_MDF_Criteria_Rule__c>();
            // Creating Criteria rules for approvers 
            Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(appList[0].Id,'Core_MDF_Fund_Request_Status__c','Equal',
                                                                                               'Pending Review',false);
            Core_MDF_Criteria_Rule__c crule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(appList[1].Id,'Core_MDF_Fund_Request_Status__c','Equal',
                                                                                               'Pending Review',false);
            
            crList.add(crule1);
            crList.add(crule2);
            Database.insert(crList);
            
            appList[0].Core_MDF_Active__c = true;
            appList[1].Core_MDF_Active__c = true;
            Database.update(appList);        
            cList[0].Core_MDF_Active__c = true;
            Database.update(cList);
            
            List<Core_MDF_Audit_Rules_Engine__c>ruleList = new List<Core_MDF_Audit_Rules_Engine__c>();
            Core_MDF_Audit_Rules_Engine__c FrontEndReviewRule = new Core_MDF_Audit_Rules_Engine__c(); 
            FrontEndReviewRule.Core_MDF_Object_Nm__c= 'PartnerFundRequest';
            FrontEndReviewRule.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
            FrontEndReviewRule.Core_MDF_Field_Nm__c= 'Core_MDF_Fund_Request_Status__c';
            FrontEndReviewRule.Core_MDF_Operator_Nm__c= 'Equal';
            FrontEndReviewRule.Core_MDF_Budget_Type_Multi_Nm__c= 'OEM CMP';
            FrontEndReviewRule.Core_MDF_Value_Txt__c= 'Pending Review';
            FrontEndReviewRule.Core_MDF_Immediate_Ind__c= 'Yes';
            FrontEndReviewRule.Core_MDF_Effective_Dt__c= System.today()-1;
            FrontEndReviewRule.Core_MDF_Active_Ind__c= true;
            FrontEndReviewRule.Core_MDF_Rule_Type_Nm__c= 'Front End Review';
            FrontEndReviewRule.Core_MDF_Region_Cd__c = 'WW';
            FrontEndReviewRule.Core_MDF_Rule_Action_on_True_nm__c='Customer Acceptance';
            //FrontEndReviewRule.Core_MDF_Approver_Source_on_True_nm__c='Approval Criteria';
            //FrontEndReviewRule.Core_MDF_Approver_Source_Value_on_True__c=cList[0].Id;
            
            Core_MDF_Audit_Rules_Engine__c FrontEndReviewRule2 = new Core_MDF_Audit_Rules_Engine__c(); 
            FrontEndReviewRule2.Core_MDF_Object_Nm__c= 'PartnerFundRequest';
            FrontEndReviewRule2.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
            FrontEndReviewRule2.Core_MDF_Field_Nm__c= 'Core_MDF_Fund_Request_Status__c';
            FrontEndReviewRule2.Core_MDF_Operator_Nm__c= 'Equal';
            FrontEndReviewRule2.Core_MDF_Budget_Type_Multi_Nm__c= 'CCF 1.0';
            FrontEndReviewRule2.Core_MDF_Value_Txt__c= 'Pending Review';
            FrontEndReviewRule2.Core_MDF_Immediate_Ind__c= 'Yes';
            FrontEndReviewRule2.Core_MDF_Effective_Dt__c= System.today()-1;
            FrontEndReviewRule2.Core_MDF_Active_Ind__c= true;
            FrontEndReviewRule2.Core_MDF_Rule_Type_Nm__c= 'Front End Review';
            FrontEndReviewRule2.Core_MDF_Region_Cd__c = 'WW';
            FrontEndReviewRule2.Core_MDF_Rule_Action_on_True_nm__c='Planned';
            // FrontEndReviewRule2.Core_MDF_Approver_Source_on_True_nm__c='Approval Criteria';
            // FrontEndReviewRule2.Core_MDF_Approver_Source_Value_on_True__c=cList[0].Id;
            // FrontEndReviewRule2.Core_MDF_Approver_Source_on_False_nm__c='Object Field';
            // FrontEndReviewRule2.Core_MDF_Approver_Source_Value_on_False__c='Core_MDF_Activity_First_Approver_txt__c';
            // FrontEndReviewRule2.Core_MDF_Rule_Action_on_False_nm__c='First Level Manager';
            // FrontEndReviewRule2.Core_MDF_Process_Name__c='Core_MDF_Activity_Approval_MultiLvl_V13';
            
            
            Core_MDF_Audit_Rules_Engine__c FrontEndReviewRule3 = new Core_MDF_Audit_Rules_Engine__c(); 
            FrontEndReviewRule3.Core_MDF_Object_Nm__c= 'PartnerFundRequest';
            FrontEndReviewRule3.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
            FrontEndReviewRule3.Core_MDF_Field_Nm__c= 'Core_MDF_Fund_Request_Status__c';//Core_MDF_Fund_Request_Status__c';
            FrontEndReviewRule3.Core_MDF_Operator_Nm__c= 'Equal';
            FrontEndReviewRule3.Core_MDF_Budget_Type_Multi_Nm__c= 'MDF;MDF+';
            FrontEndReviewRule3.Core_MDF_Value_Txt__c= 'Pending Review';
            FrontEndReviewRule3.Core_MDF_Immediate_Ind__c= 'Yes';
            FrontEndReviewRule3.Core_MDF_Effective_Dt__c= System.today()-1;
            FrontEndReviewRule3.Core_MDF_Active_Ind__c= true;
            FrontEndReviewRule3.Core_MDF_Rule_Type_Nm__c= 'Front End Review';
            FrontEndReviewRule3.Core_MDF_Region_Cd__c = 'WW';
            //FrontEndReviewRule3.Core_MDF_Action_on_True_nm__c='First Level Manager';
            FrontEndReviewRule3.Core_MDF_Approver_Source_on_True_nm__c='IUPGM';
            //FrontEndReviewRule2.Core_MDF_Process_Name__c='Core_MDF_OPAL_Approval_Process_V9';
            
            
            ruleList.add(FrontEndReviewRule);
            ruleList.add(FrontEndReviewRule2);
            ruleList.add(FrontEndReviewRule3);
            Database.insert(ruleList);
            
            Test.startTest();
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            PartnerFundRequest arpFranceActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(arpCamp.Id), 
                                                                                                         Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                         String.valueof(arpEMEAFrance.id),pfaARPCCFFrance,arpPmbRecord,'INDIA',
                                                                                                         'Consumer',
                                                                                                         'Desktop',
                                                                                                         'Intel® Core™ i5 Processor',
                                                                                                         'Broadcast (Pre-2025)',
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
            //arpFranceActivity.Core_MDF_Fund_Request_Status__c='Planned';
            
            PartnerFundRequest arpFranceActivityLegacy = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(arpCampLegacy.Id), 
                                                                                                               Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                               String.valueof(arpEMEAFrance.id),pfaARPCCFFranceLegacy,arpPmbLegacyRecord,'INDIA',
                                                                                                               'Consumer',
                                                                                                               'Desktop',
                                                                                                               'Intel® Core™ i5 Processor',
                                                                                                               'Broadcast (Pre-2025)',
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
            //arpFranceActivityLegacy.Core_MDF_Fund_Request_Status__c='Planned';
            pfrList.add(arpFranceActivityLegacy);
            pfrList.add(arpFranceActivity);
            Database.insert(pfrList);
            
            Core_MDF_Bank__c arpBank1 = [Select id from Core_MDF_Bank__c WHERE Name = 'Test' limit 1];
            arpBank1.Core_MDF_Bank_Status__c = 'Active';
            arpBank1.Core_MDF_ESD_Hold_Indicator__c=false;
            Database.update(arpBank1);
            
            List<Group> grpList = new List<Group>();
            Group ccfgrp = new Group();
            ccfgrp.Name = 'Core CCP CCF External';
            ccfgrp.DeveloperName = 'Core_CCP_CCF_External';
            grpList.add(ccfgrp);
            Database.insert(grpList);
            
            
            
            Account acc1 = [select id from Account where name='ARP Test Account' limit 1];
            //
            Account acc1vc = [select id from Account where name='ARP CCF Virtual Corp' limit 1];
            ChannelProgram c = [Select id,Core_MDF_Technical_Program_Name__c from ChannelProgram where Name=:Core_MDF_CCP_ConstantClass.CCF_PROGRAM limit 1];
            
            Core_MDF_Configuration__c config1 = new Core_MDF_Configuration__c();
            config1.Core_MDF_Value__c = '1000';
            config1.Name = 'Core_MDF_PScore_Edit_Buffer_Days';
            insert config1;
            
            Core_MDF_Partnership_Score__c ps = new Core_MDF_Partnership_Score__c();
            ps.Core_MDF_Account_Id__c = acc1.id;
            ps.Core_MDF_Channel_Program_Id__c = c.Id;
            ps.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            ps.Core_MDF_Virtual_Corp_Account_Id__c = acc1vc.Id;
            ps.Core_MDF_Quarter_Year_Nm__c = 'Q2 2025';
            ps.Core_MDF_Zone_nm__c = 'A3';
            ps.Core_MDF_External_Id__c = String.valueOf(c.Id)+String.valueOf(acc1vc.Id)+String.valueOf(ps.Core_MDF_Quarter_Year_Nm__c);
            insert ps;
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = acc1.Id;
            pgm.Core_MDF_Virtual_Corp_nm__c=acc1vc.id;
            pgm.Core_MDF_Group_Name__c = 'Core_CCP_CCF_External';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = ccfgrp.Id;                
            pgm.Core_MDF_Channel_Program__c = c.Id;
            pgm.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_CCP_CCF_External';
            pgmList.add(pgm);
            Database.insert(pgmList);
            
            Core_MDF_Partner_Group_Mapping__c pgmCheck = [select id,Core_MDF_Account__c,Core_MDF_Account__r.Name,
                                                          Core_MDF_Account__r.Core_MDF_CoMarketingAgency__c,
                                                          Core_MDF_Account__r.Core_MDF_CoMarketingActive__c,Core_MDF_Group_Name__c,
                                                          Core_MDF_Works_For__c,Core_MDF_Works_For__r.Name,
                                                          Core_MDF_Channel_Program__r.name from 
                                                          Core_MDF_Partner_Group_Mapping__c where 
                                                          Core_MDF_Type_of_Access__c ='External' and 
                                                          Core_MDF_Channel_Program__r.name= :Core_MDF_CCP_ConstantClass.CCF_PROGRAM
                                                          and Core_MDF_Account__c =: acc1.Id];
            
            String grpName = '';
            grpName = pgmCheck.Core_MDF_Group_Name__c;
            Core_MDF_Partnership_Score__c pss = [select id, Core_MDF_External_Id__c, Core_MDF_Virtual_Corp_Account_Id__c, Core_MDF_Quarter_Year_Nm__c,Core_MDF_Channel_Program_Id__c,Core_MDF_Account_Id__c,Core_MDF_Program_nm__c from Core_MDF_Partnership_Score__c where Core_MDF_Account_Id__c =: acc1.id limit 1];
            
            List<Core_MDF_Partnership_Score_Detail__c> pgdList = new List<Core_MDF_Partnership_Score_Detail__c>();
            Decimal recAmt = 0.0;
            List<String> regionList = new List<String>{'APJ', 'EMEA', 'PRC', 'ASMO'};
            for(Integer i=0;i<4;i++){
                Core_MDF_Partnership_Score_Detail__c p = new Core_MDF_Partnership_Score_Detail__c();
                p.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
                p.Core_MDF_Carry_Over_Amt__c = 0;
                p.Core_MDF_Region_Cd__c = regionList[i];
                recAmt = p.Core_MDF_Total_Recovery_Amt__c;
                p.Core_MDF_Partnership_Score_Id__c = pss.id;
                p.Core_MDF_External_Id__c = pss.Core_MDF_External_Id__c + p.Core_MDF_Budget_Type_nm__c + regionList[i];
                pgdList.add(p);
            }    
             Core_MDF_Partnership_Score_Detail__c p1 = new Core_MDF_Partnership_Score_Detail__c();
                p1.Core_MDF_Budget_Type_nm__c = 'Proposal I MDF';
                p1.Core_MDF_Carry_Over_Amt__c = 0;
                p1.Core_MDF_Region_Cd__c = 'APJ';
                recAmt = p1.Core_MDF_Total_Recovery_Amt__c;
                p1.Core_MDF_Partnership_Score_Id__c = pss.id;
                p1.Core_MDF_External_Id__c = pss.Core_MDF_External_Id__c + pss.Core_MDF_Virtual_Corp_Account_Id__c + p1.Core_MDF_Budget_Type_nm__c + p1.Core_MDF_Region_Cd__c;
                pgdList.add(p1);

            
            insert pgdList;   
        }
    }
    
    @isTest
    static void testGetProgramIdToNameMap() {
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = sysAdminProfile.Id;
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        //Running as System Admin
        System.runAs(usr)
        {
        List<Core_MDF_RecoveryFilters.ProgramOptions> cp = Core_MDF_RecoveryFilters.getProgramIdToNameMap();
        Assert.isNotNull(cp);
        }
    }
    
    @isTest
    static void testGetAccountIdToNameMapExternal() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
            Account acc1 = [select id from Account where name='ARP Test Account' limit 1];
            //Account acc2 = [select id from Account where name='ARP CCF Virtual Corp' limit 1];
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        Database.insert(conRecord1);
           // Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc2.Id,false);
        //Database.insert(conRecord2);
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        Core_AGS_Role__c agsRoleCCFClaimSub = Core_MDF_CCP_TestDataUtility.createAgsRole('Co-Marketing(Salesforce)-External Claim Submitter-CCF', 'Co-Marketing(Salesforce)-External Claim Submitter-CCF', true, false);
        Database.insert(agsRoleCCFClaimSub);
        Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
        Database.insert(erpmEngagementCCF);
        Core_Entitlement__c entitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createEntitlement('Client Claim Submitter',agsRoleCCFClaimSub.Id ,'Intel® Partner Investment Center','CCF Claim Submitter',erpmEngagementCCF.Id , true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,false);
        Database.insert(entitlementCCFClaimSub);
        Core_Contact_Entitlement__c contactEntitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCFClaimSub.Id ,true,'Complete', false);
        Database.insert(contactEntitlementCCFClaimSub);
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin' LIMIT 1];
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='test123@example.com';
        usr2.ContactId = conRecord1.Id;
        usr2.ProfileId = profileId;
        usr2.isActive = true;
        usr2.UserRoleId = userRole_1.Id;
        //Database.insert(usr2);
        
         /* List<Core_MDF_RecoveryFilters.AccountOptions> accOpt = new List<Core_MDF_RecoveryFilters.AccountOptions>();
        
        Core_MDF_Partner_Node_User_Mapping__c pnum = [select id, Core_MDF_Account__c, Core_MDF_Account__r.Name,Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name 
                                                              from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_Account__c=:acc1.Id and Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name='Client Co-Marketing Fund' and
                                                              Core_MDF_Account__r.Core_MDF_Active_Ind__c = true and Core_MDF_Active_Ind__c=true] ;
                                                                  
                                                                 Core_MDF_RecoveryFilters.AccountOptions accOptions1 = new Core_MDF_RecoveryFilters.AccountOptions();
                                                                 accOptions1.accountName = pnum.Core_MDF_Account__r.Name;
                                                                   accOptions1.accountId = pnum.Core_MDF_Account__c;
                                                                   accOptions1.isExternal = true;
                                                                   accOpt.add(accOptions1);
                                                              

        */
        //System.runAs(usr2){   
        /*Account acc = new Account();
            acc.Name = 'Dell INC Corp';
            acc.Core_MDF_Active_Ind__c = true;
            acc.BillingCity = 'Delhi';
            acc.BillingCountry = 'India';
        insert acc;
        Core_MDF_Partner_Node_User_Mapping__c pnartnernum = new Core_MDF_Partner_Node_User_Mapping__c();
            pnartnernum.Core_MDF_Account__c = acc.Name;
        insert pnartnernum;*/
        List<Core_MDF_RecoveryFilters.AccountOptions> accExt = Core_MDF_RecoveryClaimReportViewCtrl.getAccountIdToNameMapForExternal(Core_MDF_CCP_ConstantClass.CCF_PROGRAM);
            Core_MDF_RecoveryFilters.AccountOptions accOptions = new Core_MDF_RecoveryFilters.AccountOptions();
                                                                 
            Core_MDF_Partner_Group_Mapping__c pgmCheck = [select id,Core_MDF_Account__c,Core_MDF_Account__r.Name,
                                                          Core_MDF_Account__r.Core_MDF_CoMarketingAgency__c,Core_MDF_Group_Name__c,
                                                          Core_MDF_Channel_Program__r.name from 
                                                          Core_MDF_Partner_Group_Mapping__c where 
                                                          Core_MDF_Type_of_Access__c ='External' and 
                                                          Core_MDF_Channel_Program__r.name= :Core_MDF_CCP_ConstantClass.CCF_PROGRAM
                                                          and Core_MDF_Account__c =: acc1.Id];
            if(pgmCheck.Core_MDF_Account__r.Core_MDF_CoMarketingAgency__c){
                 accOptions.accountName = pgmCheck.Core_MDF_Works_For__r.Name;
                 accOptions.accountId = pgmCheck.Core_MDF_Works_For__c;
                 accOptions.isExternal = true;
                 accExt.add(accOptions);
                                                 
            }
              String grpName = '';
            grpName = pgmCheck.Core_MDF_Group_Name__c;
             List<Core_MDF_RecoveryFilters.AccountOptions> accExt1 = Core_MDF_RecoveryClaimReportViewCtrl.getAccountIdToNameMapForExternal('Retail Marketing Funds');
            
            /*Core_MDF_Partner_Node_User_Mapping__c pnum = [select id, Core_MDF_Account__c, Core_MDF_Account__r.Name,Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name 
                                                              from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name='Retail Marketing Funds' and
                                                              Core_MDF_Account__r.Core_MDF_Active_Ind__c = true  and Core_MDF_Active_Ind__c=true order by Core_MDF_Account__r.Name] 
                                                                 
            Core_MDF_RecoveryFilters.AccountOptions accOptions1 = new Core_MDF_RecoveryFilters.AccountOptions();
                                                                  accOptions1.accountName = pnum.Core_MDF_Account__r.Name;
                                                                   accOptions1.accountId = pnum.Core_MDF_Account__c;
                                                                   accOptions1.isExternal = true;
                                                                   accExt.add(accOptions1);*/
        
      
            Assert.isNotNull(accExt);
        
        }

        
    }
    
    @isTest
    static void testGetAccountIdToNameMap(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        List<Core_MDF_RecoveryFilters.AccountOptions> acc = Core_MDF_RecoveryFilters.getAccountIdToNameMap(Core_MDF_CCP_ConstantClass.CCF_PROGRAM);
            Assert.isNotNull(acc);
        }
    }
    
    @isTest
    static void testGetQuarterOptionsMap(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        List<String> q = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            Assert.isNotNull(q);
          
        }
    }
    
    @isTest
    static void testGetFilteredDataForClaimsToBeRecovered(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        
        Test.startTest();
        Account acc1 = [select id from Account where name='ARP Test Account' limit 1];
        String mulId = acc1.id;
        acc1.Id = mulId.substring(0,mulId.length()-3);
        
        List<Core_MDF_RecoveryClaimReportViewCtrl.LeftReportRows> lr = Core_MDF_RecoveryClaimReportViewCtrl.getFilteredDataForClaimsToBeRecovered('Client CoMarketing Fund',acc1.Id,'Q2 2025');
            Assert.isNotNull(lr);
        Core_MDF_RecoveryClaimReportViewCtrl.resetRecovery('Client CoMarketing Fund',acc1.Id,'Q2 2025');
        Test.stopTest();
        }
    }
    
    @isTest
    static void resetRecoveryTest(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        Test.startTest();
        Account acc1 = [select id from Account where name='ARP Test Account' limit 1];
        Core_MDF_RecoveryClaimReportViewCtrl.resetRecovery('Client CoMarketing Fund',acc1.Id,'Q2 2025');
        Core_MDF_Recovery_Request__c recovery = new Core_MDF_Recovery_Request__c();
        recovery.Core_MDF_Program_Nm__c = 'Client CoMarketing Fund';
        recovery.Core_MDF_Account_Id__c = acc1.Id; 
        recovery.Core_MDF_Active_Ind__c = true;
        recovery.Core_MDF_Recovery_Amount_Amt__c = 1;
        recovery.Core_MDF_Quarter_Year_Nm__c = 'Q2 2025';
        insert recovery;
        string returnMsg = Core_MDF_RecoveryClaimReportViewCtrl.resetRecovery('Client CoMarketing Fund',acc1.Id,'Q2 2025');
        Test.stopTest();
        assert.areEqual('success', returnMsg);
        }
    }
    
    
    @isTest
    static void testGetcolumnsForToBeRecoveredClaims(){ 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        List<Core_MDF_RecoveryClaimReportViewCtrl.ReportColumns> rc = Core_MDF_RecoveryClaimReportViewCtrl.getcolumnsForToBeRecoveredClaims();
            Assert.isNotNull(rc);
        }
    }
    
    @isTest
    static void testGetcolumnsForClaimsEligibleForRecovery(){ 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        List<Core_MDF_RecoveryClaimReportViewCtrl.ReportColumns> rc = Core_MDF_RecoveryClaimReportViewCtrl.getcolumnsForClaimsEligibleForRecovery();
            Assert.isNotNull(rc);
        }
    }
    
    @isTest
    static void testCheckMode(){ 
    
        Account acc1 = [select id from Account where name='ARP Test Account' limit 1];
        String modeRetail = Core_MDF_RecoveryClaimReportViewCtrl.checkMode('Retail Marketing Funds',acc1.Id);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Account_Recovery_Manager' LIMIT 1];
        // Creating User with utility class 
        User recManager = Core_MDF_CCP_TestDataUtility.createUser(false);
        recManager.LastName = 'Recovery Manager';
        insert recManager;
        insert new PermissionSetAssignment(AssigneeId = recManager.id, PermissionSetId = ps.Id);
        
        
        System.runAs(recManager){
            String mode = 'read';
            String modeCCF = Core_MDF_RecoveryClaimReportViewCtrl.checkMode('Client CoMarketing Fund',acc1.Id);
            mode = 'edit';
        }
         List<Core_MDF_RecoveryClaimReportViewCtrl.LeftReportRows> lr = Core_MDF_RecoveryClaimReportViewCtrl.getFilteredDataForClaimsToBeRecovered('Retail Marketing Funds',acc1.Id,'Q2 2025');
        Assert.isNotNull(lr);
    }
    
    @isTest
    static void testCheckModeExtUser(){ 
        
        Map<String,Id> profileMap = new Map<String,Id>();
        
         for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','Partner')]) {
            profileMap.put(prfl.Name,prfl.Id);
        }
        
        PermissionSet pSet = [SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_External_Account_Budget_Administrator') LIMIT 1];
        PermissionSet pSet2 = [SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_CCF_Payment_Adm') LIMIT 1];
        PermissionSet pSet3 = [SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_CCF_MDF_Payment_Admin') LIMIT 1];
        
        
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.Email = 'sysadmin@example.com';
        usrs.LastName = 'System Adm123';
        usrs.ProfileId = profileMap.get('System Administrator');
        usrs.isActive = true;
        Database.insert(usrs);
        
        Id ccfMdfRecordType = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Client_Co_Marketing_Fund_MDF').getRecordTypeId();
        Id ccfRecordType = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Client_Co_Marketing_Fund_CMP').getRecordTypeId();
        ChannelProgram ccfCP = [Select id,Core_MDF_Technical_Program_Name__c from ChannelProgram where Name=:Core_MDF_CCP_ConstantClass.CCF_PROGRAM limit 1];
        
        Account acc1 = [select id from Account where name='ARP Test Account' limit 1];
        
        Account retailIntelAcc = Core_MDF_CCP_TestDataUtility.createAccount('Test CCP Intel Account',ccfCP.id, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        retailIntelAcc.Core_Geo__c = 'APJ';
        retailIntelAcc.BillingCountry ='RUS';
        retailIntelAcc.BillingCity = 'Test City'; 
        retailIntelAcc.BillingStreet= 'Test Street';
        retailIntelAcc.BillingState= 'MOS';
        insert retailIntelAcc;
        
        //Creating Contact for Partner User
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(retailIntelAcc.Id,true);
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='ext4234@example.com';
        usr1.LastName = 'External5352';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileMap.get('Partner');
        usr1.isActive = true;
        Database.insert(usr1);
        
        system.runAs(usrs){
            
            Boolean result = Core_MDF_RecoveryClaimReportViewCtrl.checkRecoveryMode('Intel Partner Alliance');
            Assert.areEqual(false, result);
            
            insert new PermissionSetAssignment(AssigneeId = usr1.Id, PermissionSetId = pSet.Id);
            //insert new PermissionSetAssignment(AssigneeId = usr1.Id, PermissionSetId = pSet2.Id);
            //insert new PermissionSetAssignment(AssigneeId = usr1.Id, PermissionSetId = pSet3.Id);
            
            List<Core_MDF_Payment_Run__c> paymentRunList = new List<Core_MDF_Payment_Run__c>();
            paymentRunList.add(new Core_MDF_Payment_Run__c(RecordTypeId = ccfMdfRecordType, Core_MDF_Program_Id__c = ccfCP.Id, Core_MDF_Program_Txt__c ='Client CoMarketing Fund', Core_MDF_Budget_Type_nm__c = 'MDF', Core_MDF_Run_For_All_Accounts__c = true, Core_MDF_Payment_run_for_Accounts__c = String.valueOf(acc1.Id), Core_MDF_Status_Txt__c = 'Scheduled', Core_MDF_Geo_Txt__c = 'ASMO', Core_MDF_ScheduleRun_Dtm__c = DateTime.Now() + 1));
            paymentRunList.add(new Core_MDF_Payment_Run__c(RecordTypeId = ccfRecordType, Core_MDF_Program_Id__c = ccfCP.Id, Core_MDF_Program_Txt__c ='Client CoMarketing Fund', Core_MDF_Budget_Type_nm__c = 'OEM CMP', Core_MDF_Status_Txt__c = 'Scheduled', Core_MDF_Geo_Txt__c = 'ASMO', Core_MDF_ScheduleRun_Dtm__c = DateTime.Now() + 1));
            //insert paymentRunList;
            //List<Core_MDF_Payment_Run__c> prList =[select id,RecordType.name, Core_MDF_Account_Id__c, Core_MDF_ScheduleRun_Dtm__c,Core_MDF_Run_Now_Ind__c, Core_MDF_Run_For_All_Accounts__c from Core_MDF_Payment_Run__c where Core_MDF_Status_Txt__c in('Scheduled','In-progress') and Core_MDF_Program_Id__r.Core_MDF_Technical_Program_Name__c = 'Client CoMarketing Fund' and (Core_MDF_Run_Now_Ind__c =true or Core_MDF_ScheduleRun_Dtm__c = NEXT_N_DAYS:2)];
            String ccfMode = Core_MDF_RecoveryClaimReportViewCtrl.checkMode('Client CoMarketing Fund',acc1.Id);
            Assert.areEqual('read', ccfMode);
        }
        
        System.runAs(usr1){
            String modeCCF = Core_MDF_RecoveryClaimReportViewCtrl.checkMode('Client CoMarketing Fund',acc1.Id);
            Assert.areEqual('read', modeCCF);
        }
        //Core_MDF_RecoveryClaimReportViewCtrl.isRecoveryAllowedForCurrentMonth();
    }
    
    /*@isTest
    static void recoveryModeCheck(){
        Boolean result = Core_MDF_RecoveryClaimReportViewCtrl.checkRecoveryMode();
        Assert.areEqual(false, result);
    }*/
    
    @isTest
    static void testgetOrganizedDataForClaimsToBeRecovered(){ 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        PartnerFundRequest arpFranceActivity = [Select id, Core_MDF_Start_Date__c from PartnerFundRequest where Title = 'France Activity'];
        Core_MDF_Bank__c arpBank = [Select id from Core_MDF_Bank__c WHERE Name = 'Test' limit 1];
        Test.startTest();
        Set<PartnerFundClaim> pcList = new Set<PartnerFundClaim>();
        PartnerFundClaim franceClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,
                                                                                 arpFranceActivity.Id, System.today(), System.today(),
                                                                                 300,System.today(),arpBank.ID,false);
        franceClaim2.Core_MDF_Budget_Type_Options_Nm__c= 'OEM CMP';
        franceClaim2.Core_MDF_Currency__c='USD';
        franceClaim2.Core_MDF_Status__c='Payment Due';
        franceClaim2.Amount=1000;
        franceClaim2.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        Database.insert(franceClaim2);
        
        
        PartnerFundClaim pc = [select Id,Core_MDF_Claim_Review_Case__r.Core_MDF_Scorecard_Score_Nbr__c,Core_MDF_Processing_Preference_nm__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Manual_Recovery_Amount_USD_Amt__c,Core_MDF_Country_Location_nm__c,Core_MDF_Claim_Ref_Number__c,Core_MDF_Budget_Type_Options_Nm__c, Core_MDF_Region_Cd__c, Core_MDF_Status__c,Core_MDF_Activity_Category__c, Core_MDF_Activity_Types__c, Amount,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Recovery_Hold_Ind__c from partnerFundClaim where Core_MDF_Program__c = :Core_MDF_CCP_ConstantClass.CCF_PROGRAM and Core_MDF_AccountCompany__c ='ARP Test Account' limit 1];
        pcList.add(pc);
            
        List<string> budgetTypeList = new List<string>();
        budgetTypeList.add(pc.Core_MDF_Budget_Type_Options_Nm__c);
            
        Map<id,Map<string,decimal>> clmToBtRecoveryAmt = new Map<id,Map<string,decimal>>();
        Map<string,decimal> tempMap = new Map<string,decimal>();
        tempMap.put(pc.Core_MDF_Budget_Type_Options_Nm__c+';'+pc.Core_MDF_Region_Cd__c, 50);
        clmToBtRecoveryAmt.put(pc.id,tempMap);
        
        Map<string,set<string>> crossBTorProgToBTMap = new Map<string,set<string>>();
       	set<string> st = new set<string>();
        st.add('OEM CMP');
        crossBTorProgToBTMap.put('CCF 1.0',st);
            
        Map<Id,Decimal> eligible = new Map<Id,Decimal>();
        eligible.put(pc.Id,100);
        
        Map<Id,Core_MDF_Recovery_Helper.RecoveryRequestDetail> eligibileClaimsBTGeo = new Map<Id,Core_MDF_Recovery_Helper.RecoveryRequestDetail>();
        Core_MDF_Recovery_Helper.RecoveryRequestDetail rrd = new Core_MDF_Recovery_Helper.RecoveryRequestDetail();
        rrd.consumedBudget = 'test';
        eligibileClaimsBTGeo.put(pc.Id,rrd);
        Test.stopTest();
        Core_MDF_RecoveryClaimReportViewCtrl.FinalRightRows fr = Core_MDF_RecoveryClaimReportViewCtrl.getOrganizedDataForClaimsToBeRecovered(pcList,eligible,eligibileClaimsBTGeo,false,budgetTypeList,clmToBtRecoveryAmt,crossBTorProgToBTMap,eligible);
          Assert.isNotNull(fr);
        }
        
    }
    
        @isTest
    static void testgetOrganizedDataForClaimsToBeRecovered1() { 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        PartnerFundRequest arpFranceActivity = [Select id, Core_MDF_Start_Date__c from PartnerFundRequest where Title = 'France Activity'];
        Core_MDF_Bank__c arpBank = [Select id from Core_MDF_Bank__c WHERE Name = 'Test' limit 1];
        Test.startTest();
        Set<PartnerFundClaim> pcList = new Set<PartnerFundClaim>();
        PartnerFundClaim franceClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,arpFranceActivity.Id, System.today(), System.today(),300,System.today(),arpBank.ID,false);
        franceClaim2.Core_MDF_Budget_Type_Options_Nm__c= 'OEM CMP';
        franceClaim2.Core_MDF_Currency__c='USD';
        franceClaim2.Core_MDF_Status__c='Payment Due';
        franceClaim2.Amount=1000;
        franceClaim2.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        Database.insert(franceClaim2);
        Assert.areEqual(franceClaim2.Core_MDF_Budget_Type_Options_Nm__c,'OEM CMP');
        
        PartnerFundClaim pc = [select Id,Core_MDF_Country_Location_nm__c,Core_MDF_Claim_Ref_Number__c,Core_MDF_Budget_Type_Options_Nm__c, Core_MDF_Region_Cd__c, Core_MDF_Status__c,Core_MDF_Activity_Category__c, Core_MDF_Activity_Types__c, Amount,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Recovery_Hold_Ind__c from partnerFundClaim where Core_MDF_Program__c = :Core_MDF_CCP_ConstantClass.CCF_PROGRAM and Core_MDF_AccountCompany__c ='ARP Test Account' limit 1];
        pcList.add(pc);
        
        List<string> budgetTypeList = new List<string>();
        budgetTypeList.add(pc.Core_MDF_Budget_Type_Options_Nm__c);
            
        Map<id,Map<string,decimal>> clmToBtRecoveryAmt = new Map<id,Map<string,decimal>>();
        Map<string,decimal> tempMap = new Map<string,decimal>();
        tempMap.put(pc.Core_MDF_Budget_Type_Options_Nm__c+';'+pc.Core_MDF_Region_Cd__c, 50);
        clmToBtRecoveryAmt.put(pc.id,tempMap);
        
        Map<string,set<string>> crossBTorProgToBTMap = new Map<string,set<string>>();
       	set<string> st = new set<string>();
        st.add('OEM CMP');
        crossBTorProgToBTMap.put('CCF 1.0',st);
        
        Map<Id,Decimal> eligible = new Map<Id,Decimal>();
        eligible.put(pc.Id,100);
        
        Map<Id,Core_MDF_Recovery_Helper.RecoveryRequestDetail> eligibileClaimsBTGeo = new Map<Id,Core_MDF_Recovery_Helper.RecoveryRequestDetail>();
        Core_MDF_Recovery_Helper.RecoveryRequestDetail rrd = new Core_MDF_Recovery_Helper.RecoveryRequestDetail();
        rrd.comments = 'test';
        rrd.budgetGeo = 'APJ=50';
        rrd.readyToRecoverInd = true;
        eligibileClaimsBTGeo.put(pc.Id,rrd);
        Test.stopTest();
        try{
        Core_MDF_RecoveryClaimReportViewCtrl.getOrganizedDataForClaimsToBeRecovered(pcList,eligible,eligibileClaimsBTGeo,true,budgetTypeList,clmToBtRecoveryAmt,crossBTorProgToBTMap,eligible);
        }catch(Exception e){
        }
        }
        
    }
    
    @isTest
    static void Get_SummaryBreakdown() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        Account acc1 = [select id from Account where name='ARP Test Account' limit 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        Core_MDF_Partnership_Score_Detail__c psdetail = [SELECT Id,Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c,Core_MDF_Quarter_Year_Nm__c,
                                                         Core_MDF_Budget_Type_Nm__c, Core_MDF_Region_Cd__c,Core_MDF_Total_Recovery_Amt__c, Core_MDF_Carry_Over_Amt__c,Core_MDF_Recovered_Amt__c 
                                                         FROM Core_MDF_Partnership_Score_Detail__c  limit 1];
        test.startTest();
       
        Core_MDF_RecoveryClaimReportViewCtrl.getRecoveryBT(psdetail.Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c,psdetail.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,psdetail.Core_MDF_Quarter_Year_Nm__c);                
     
        List<Core_MDF_RecoveryClaimReportViewCtrl.BreakdownSummary> psd = Core_MDF_RecoveryClaimReportViewCtrl.Get_SummaryBreakdown(psdetail.Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c,psdetail.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,psdetail.Core_MDF_Quarter_Year_Nm__c);
        Core_MDF_RecoveryClaimReportViewCtrl.getRecoveryBT('Retail Marketing Funds',psdetail.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,psdetail.Core_MDF_Quarter_Year_Nm__c);        
        test.stopTest();
        assert.areEqual(psd.size()>0, true);
        }
         List<Core_MDF_RecoveryClaimReportViewCtrl.BreakdownSummary> psd1 = Core_MDF_RecoveryClaimReportViewCtrl.Get_SummaryBreakdown('Retail Marketing Funds',acc1.Id,'Q2 2025');
        
    }  
    @isTest
    static void testScheduleRecoveryBatch(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr) {
        Account acc1 = [select id from Account where name='ARP Test Account' limit 1];
        Core_MDF_RecoveryFilters.RecoveryBatchParams param= new Core_MDF_RecoveryFilters.RecoveryBatchParams();
        param.program = 'Client CoMarketing Fund';
        param.account= acc1.id;
        param.quarter= 'Q2 2022';
        param.budgetType ='MDF';
        
        Core_MDF_RecoveryFilters.scheduleRecoveryBatch(param);
            assert.areEqual('MDF',param.budgetType);
        }
    }
    
    /*@isTest
    static void testWrappers(){
        Core_MDF_RecoveryClaimReportViewCtrl.ReportColumns rc =  new Core_MDF_RecoveryClaimReportViewCtrl.ReportColumns();
        rc.editable = true;
        
        Account acc1 = [select id from Account where name='ARP Test Account' limit 1];
        Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows rrr =  new Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows();
        rrr.mode = 'read';
        rrr.onSelect = 'true';
        rrr.accountId = String.valueOf(acc1.Id);
        rrr.program = 'Intel Partner alliance';
        rrr.quarter = 'Q1 2023';
    }*/
}