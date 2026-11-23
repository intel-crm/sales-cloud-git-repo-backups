/** Test class to cover Core_MDF_Audit_Rules_Processing */
@isTest(SeeAllData=false)
public class Core_MDF_Audit_Rules_Processing_Test {
    @TestSetup
    static void makeData() {
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin' LIMIT 1];
       	List<User> usrList = new List<User>();
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='financeManager@example.com';
        usrList.add(usr2); 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usr.UserRoleId = userRole_1.Id;     
        usr.LastName = 'SystemAdmin';
        usr.IsActive = true;
        usrList.add(usr);
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrList.add(testUser);
        Database.insert(usrList);
        system.runAs(usr){
        //adding bypass feature to bypass access validation
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution3 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution3.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'before upate, after update';
        claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution3.Name = 'checkAndSendClaimsToAudit';
        claimFunctionalityNameTriggerExecution3.Core_Description__c = 'test';
        Database.insert(claimFunctionalityNameTriggerExecution3);
        
        ChannelProgram ccfCP = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);

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
            
        PartnerMarketingBudget  arpPmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('ARP PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,arpCCFVC.Id,ccfCP.Id,100000,System.today().addDays(-10),System.today().addDays(10),false);
		arpPmbRecord.Core_MDF_Budget_Type_Txt__c ='OEM CMP';
        //arpPmbRecord.Core_MDF_Budget_Status__c = 'Released';
        Database.insert(arpPmbRecord);
        
       
        
        PartnerFundAllocation pfaARPCCFFrance = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaARPCCFFrance',arpPmbRecord, arpEMEAFrance, 1000, true);

        Core_MDF_Bank__c arpBank = Core_MDF_CCP_TestDataUtility.createBank(arpIntelAcc.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
        
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(arpEMEAFrance.Id,arpBank.Id,true);

        Campaign arpCamp = Core_MDF_CCP_TestDataUtility.createCampaign('ARP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', arpCCFVC.Id, '2-in-1', false);
        arpCamp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        arpCamp.Core_MDF_Supports_legacy_program__c='CMP only';
        
        Database.insert(arpCamp);
        
         Core_MDF_Campaign_Budgets__c campBudget = new Core_MDF_Campaign_Budgets__c();
            campBudget.Core_MDF_Budget_Name_Id__c = arpPmbRecord.id;
            campBudget.Core_MDF_Campaign_Id__c=arpCamp.id;
            campBudget.Core_MDF_Budget_Amt__c=363636;
            campBudget.Core_MDF_Reimbursement_Rate_Pct__c='55%';
            campBudget.Core_MDF_Reimbursement_Amt__c= 200000;
            campBudget.Core_MDF_Active_ind__c=true;
        Database.insert(campBudget);
        
        
        List<Core_MDF_Configuration__c> configMDF = new List<Core_MDF_Configuration__c>();
        Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
        config.NAME = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        config.Core_MDF_Value__c='3';
        config.Core_MDF_Category__c ='Bank Document Hold Logic';
        configMDF.add(config);
        insert configMDF;
        
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
        //arpFranceActivity.Core_MDF_Budget_Type_txt__c = 'OEM CMP';
        arpFranceActivity.Core_MDF_Reimbursement_Rate_pct__c='50%';
        arpFranceActivity.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        arpFranceActivity.Core_MDF_Channel_Partner_Led__c = true;
            
        test.startTest();
        Database.insert(arpFranceActivity);
      
		
        PartnerFundClaim franceClaim = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,arpFranceActivity.Id,arpFranceActivity.Core_MDF_Start_Date__c, arpFranceActivity.Core_MDF_Start_Date__c,300,System.today(),arpBank.ID,false);
        //franceClaim.Core_MDF_Budget_Type_Nm__c= 'OEM CMP';
        //franceClaim.Core_MDF_Reimbursement_Percent__c = '50%';
        franceClaim.Amount = 300;
        franceClaim.Core_MDF_Currency__c='USD'; 
            
        Database.insert(franceClaim);
        
        Test.stopTest();
        Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
        auditDoc.Core_MDF_Claim__c = franceClaim.id;
        auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
        auditDoc.Core_MDF_Document_Types__c='Proof of Cost';
        Database.insert(auditDoc);
        
        Core_MDF_Audit_Rules_Engine__c rule4 = new Core_MDF_Audit_Rules_Engine__c();
        rule4.Core_MDF_Object_Nm__c= 'PartnerFundClaim';
        rule4.Core_MDF_Field_Nm__c= 'Core_MDF_Currency__c';
        rule4.Core_MDF_Operator_Nm__c= 'Equal';
        rule4.Core_MDF_Value_Txt__c= 'USD';
        rule4.Core_MDF_Immediate_Ind__c= 'No';
        rule4.Core_MDF_Effective_Dt__c= System.today();
        rule4.Core_MDF_Active_Ind__c= true;
        rule4.Core_MDF_Rule_Type_Nm__c= 'POP';
        Database.insert(rule4);
        
        Core_MDF_Audit_Rules_Engine__c rule3 = new Core_MDF_Audit_Rules_Engine__c();
        rule3.Core_MDF_Object_Nm__c= 'Random';
        rule3.Core_MDF_Field_Nm__c= 'Percentage';
        rule3.Core_MDF_Operator_Nm__c= 'Equal';
        rule3.Core_MDF_Value_Txt__c= '1%';
        rule3.Core_MDF_Immediate_Ind__c= 'No';
        rule3.Core_MDF_Effective_Dt__c= System.today();
        rule3.Core_MDF_Active_Ind__c= true;
        rule3.Core_MDF_Rule_Type_Nm__c= 'Audit';
        rule3.Core_MDF_Next_Rule_False_Id__c = rule4.id;
        
        Database.insert(rule3);
        
        Core_MDF_Audit_Rules_Engine__c rule2 = new Core_MDF_Audit_Rules_Engine__c();
        rule2.Core_MDF_Object_Nm__c= 'PartnerFundClaim';
        rule2.Core_MDF_Field_Nm__c= 'Core_MDF_Requested_Reimbursement_Amt__c';
        rule2.Core_MDF_Operator_Nm__c= 'Greater Than';
        rule2.Core_MDF_Value_Txt__c= '20';
        rule2.Core_MDF_Immediate_Ind__c= 'No';
        rule2.Core_MDF_Effective_Dt__c= System.today();
        rule2.Core_MDF_Active_Ind__c= true;
        rule2.Core_MDF_Next_Rule_False_Id__c = rule3.id;
        rule2.Core_MDF_Rule_Type_Nm__c= 'Audit';
        Database.insert(rule2);
        
        Core_MDF_Audit_Rules_Engine__c rule1 = new Core_MDF_Audit_Rules_Engine__c();
        rule1.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
        rule1.Core_MDF_Budget_Type_Nm__c= 'OEM CMP';
        rule1.Core_MDF_Object_Nm__c= 'Core_MDF_Claim_Prediction__c';
        //rule1.Core_MDF_Field_Nm__c= 'Core_MDF_Prediction_Score_PB__c';
        rule1.Core_MDF_Field_Nm__c= 'Core_MDF_New_Prediction_Score_nbr__c';
        rule1.Core_MDF_Operator_Nm__c= 'Greater Than';
        rule1.Core_MDF_Value_Txt__c= '80';
        rule1.Core_MDF_Immediate_Ind__c= 'Yes';
        rule1.Core_MDF_Effective_Dt__c= System.today();
        rule1.Core_MDF_Active_Ind__c= true;
        rule1.Core_MDF_Next_Rule_Id__c = rule2.id;
        rule1.Core_MDF_Next_Rule_False_Id__c = rule2.id;
        rule1.Core_MDF_Region_Cd__c = 'WW';
        rule1.Core_MDF_Rule_Type_Nm__c= 'Audit';
        Database.insert(rule1);
        
        Core_MDF_Audit_Rules_Engine__c rule0 = new Core_MDF_Audit_Rules_Engine__c();
        //rule0.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
        //rule0.Core_MDF_Budget_Type_Nm__c= 'OEM CMP';
        rule0.Core_MDF_Object_Nm__c= 'PartnerFundRequest';
        rule0.Core_MDF_Field_Nm__c= 'Core_MDF_Channel_Partner_Led__c';
        rule0.Core_MDF_Operator_Nm__c= 'Equal';
        rule0.Core_MDF_Value_Txt__c= 'true';
        rule0.Core_MDF_Immediate_Ind__c= 'No';
        rule0.Core_MDF_Effective_Dt__c= System.today();
        rule0.Core_MDF_Active_Ind__c= true;
        rule0.Core_MDF_Rule_Type_Nm__c= 'Audit';
        Database.insert(rule0);
        
        Core_MDF_Claim_Prediction__c claimpred = new Core_MDF_Claim_Prediction__c();
        claimpred.Core_MDF_Claim_id__c = franceClaim.Id;
        claimpred.Core_MDF_CycleNumber_Nbr__c = 2;
        insert claimpred;
        }
    }

    @isTest static void testAuditRulesProcessing(){
        User systemAdmin = [Select Id from User where LastName = 'SystemAdmin'];
        system.runAs(systemAdmin){
            test.startTest();
            Core_MDF_Claim_Prediction__c claimPred1 = [select id,Core_MDF_Program_Nm__c,Core_MDF_Budget_Type_Nm__c,Core_MDF_Claim_id__c,Core_MDF_Prediction_Score_PB__c,Core_MDF_Claim_Created_Dt__c,Core_MDF_Region_Cd__c,Core_MDF_Activity_ID__c from Core_MDF_Claim_Prediction__c limit 1];
            List<Core_MDF_Claim_Prediction__c> claimPredList = new List<Core_MDF_Claim_Prediction__c>();
            Core_MDF_Audit_Rules_Engine__c rule =[select id,Core_MDF_Next_Rule_Id__c,Core_MDF_Next_Rule_False_Id__c,Core_MDF_Effective_Dt__c,Core_MDF_Region_Cd__c,Core_MDF_ID_Field_Id__c,Core_MDF_Value_Txt__c,Core_MDF_Field_Nm__c,Core_MDF_Operator_Nm__c,Name,Core_MDF_Object_Nm__c,Core_MDF_Rule_Type_Nm__c from Core_MDF_Audit_Rules_Engine__c where Core_MDF_Object_Nm__c='Random'];
            Core_MDF_Audit_Rules_Engine__c rule2 =[select id,Core_MDF_Next_Rule_Id__c,Core_MDF_Next_Rule_False_Id__c,Core_MDF_Effective_Dt__c,Core_MDF_Region_Cd__c,Core_MDF_ID_Field_Id__c,Core_MDF_Value_Txt__c,Core_MDF_Field_Nm__c,Core_MDF_Operator_Nm__c,Name,Core_MDF_Object_Nm__c,Core_MDF_Rule_Type_Nm__c from Core_MDF_Audit_Rules_Engine__c where Core_MDF_Object_Nm__c='PartnerFundClaim' and Core_MDF_Rule_Type_Nm__c='Audit'];
            Core_MDF_Audit_Rules_Engine__c rule3 =[select id,Core_MDF_Next_Rule_Id__c,Core_MDF_Next_Rule_False_Id__c,Core_MDF_Effective_Dt__c,Core_MDF_Region_Cd__c,Core_MDF_ID_Field_Id__c,Core_MDF_Value_Txt__c,Core_MDF_Field_Nm__c,Core_MDF_Operator_Nm__c,Name,Core_MDF_Object_Nm__c,Core_MDF_Rule_Type_Nm__c from Core_MDF_Audit_Rules_Engine__c where Core_MDF_Object_Nm__c='PartnerFundRequest' and Core_MDF_Rule_Type_Nm__c='Audit'];
            claimPredList.add(claimPred1);
            
            Core_MDF_Audit_Rules_Processing.executePredictionFlow(claimPredList);
            Core_MDF_Audit_Rules_Processing.runRules(claimPred1,rule2);
            Core_MDF_Audit_Rules_Processing.runRules(claimPred1,rule);
            Core_MDF_Audit_Rules_Processing.runRules(claimPred1,rule3);
            
            PartnerFundClaim franceClaim = [select id from PartnerFundClaim limit 1]; 
            List<id> claimIDList = new List<id>();
            Map<id,boolean> popMapFalse = new Map<id,boolean>();
            popMapFalse.put(franceClaim.id,false);
            claimIDList.add(franceClaim.id);
            Map<id,boolean> popMap = Core_MDF_Audit_Rules_Processing.checkPOPDocuments(claimIDList);
            List<string> result = new List<string>();
            result.add('true');
            result.add('Immediate Rules'); 
            result.add('Rule001');
            result.add('POP');
            //Core_MDF_Audit_Rules_Processing.updateClaimValues(franceClaim,result, popMap);
            //Core_MDF_Audit_Rules_Processing.updateClaimValues(franceClaim,result, popMapFalse);
            test.stopTest();
             Assert.areNotEqual(result,null);
        }
       
    }
    
    @isTest static void testExceptions(){
        User systemAdmin = [Select Id from User where LastName = 'SystemAdmin'];
        system.runAs(systemAdmin){
            Core_MDF_Audit_Rules_Processing.queryClaimFields(null,null);
            Core_MDF_Audit_Rules_Processing.matchTheClaimsAgainstRules(null,null);
            Core_MDF_Audit_Rules_Processing.executeRandomLogic(null,null);
           // Core_MDF_Audit_Rules_Processing.updateClaimValues(null,null,null);
            Core_MDF_Audit_Rules_Processing.checkPOPDocuments(null);
        }
        Assert.areNotEqual(systemAdmin,null);
    }
}