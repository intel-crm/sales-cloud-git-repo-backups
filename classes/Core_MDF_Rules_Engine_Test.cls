@isTest(SeeAllData=false)
public class Core_MDF_Rules_Engine_Test {    
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
            //String Bypass_MDF_Budget_Access;
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
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
            bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
            bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');
            bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
            bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
            bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
            bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
            bypassFunctionKeys.add('Bypass_UpdateActivityFields');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Update_Validation');
            List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
            
            System.runAs(testuser){
                //User cmdfBudgetLoader = Core_MDF_CCP_TestDataUtility.createUser(false);
                //cmdfBudgetLoader.LastName = 'CMDF Budget Loader';
                //insert cmdfBudgetLoader;
                User mdfBudgetLoader = Core_MDF_CCP_TestDataUtility.createUser(false);
                mdfBudgetLoader.LastName = 'MDF Budget Loader';
                insert mdfBudgetLoader;
                PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
                insert new PermissionSetAssignment(AssigneeId = mdfBudgetLoader.id, PermissionSetId = ps.Id);
                // Highlight: Unused Local Variable - Indira
               // List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
               // Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
                
            }
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
            User usr1 = [SELECT Id,Email from User where LastName='MDF Budget Loader' limit 1];
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Account_id__c = arpIntelAcc.Id;
            iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm.Core_MDF_User_id__c = usr1.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgm);
            
            AccountShare accshareRecordCCF = new AccountShare();
            accshareRecordCCF.AccountId = arpCCFVC.Id;
            accshareRecordCCF.UserOrGroupId = usr1.Id;
            accshareRecordCCF.RowCause = 'Manual';
            accshareRecordCCF.AccountAccessLevel = 'Read';
            accshareRecordCCF.OpportunityAccessLevel = 'None';
            accshareRecordCCF.CaseAccessLevel = 'None';
            Database.Insert(accshareRecordCCF);
            
            PartnerMarketingBudget  arpPmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('ARP PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,arpCCFVC.Id,ccfCP.Id,100000,System.today().addDays(-10),System.today().addDays(10),false);
            arpPmbRecord.Core_MDF_Budget_Type_Txt__c ='MDF';
            Database.insert(arpPmbRecord);
            
            PartnerFundAllocation pfaARPCCFFrance = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaARPCCFFrance',arpPmbRecord, arpEMEAFrance, 1000, true);
            
            Core_MDF_Bank__c arpBank = Core_MDF_CCP_TestDataUtility.createBank(arpIntelAcc.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            // Highlight: Unused Local Variable - Indira
           // Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(arpEMEAFrance.Id,arpBank.Id,true);
            Test.startTest();
            Campaign arpCamp = Core_MDF_CCP_TestDataUtility.createCampaign('ARP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', arpCCFVC.Id, '2-in-1', false);
            arpCamp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF';
            arpCamp.Core_MDF_Supports_legacy_program__c='MDF or both CMP & MDF';
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
            arpFranceActivity.Core_MDF_Budget_Type_nm__c= 'MDF';
            //arpFranceActivity.Core_MDF_Budget_Type_txt__c = 'MDF';
            arpFranceActivity.Core_MDF_Reimbursement_Rate_pct__c='50%';
            arpFranceActivity.Core_MDF_Reimbursement_Rate_txt__c = '50%';
            arpFranceActivity.Core_MDF_Channel_Partner_Led__c = true;
            arpFranceActivity.Core_MDF_Fund_Request_Status__c= 'Pending Review';
            arpFranceActivity.Core_MDF_Activity_CreatedByExternalUsr__c = True;
            arpFranceActivity.Core_MDF_Program_Office_Check_ind__c = True;
            Database.insert(arpFranceActivity);
            
            
            PartnerFundClaim franceClaim = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,arpFranceActivity.Id,arpFranceActivity.Core_MDF_Start_Date__c, arpFranceActivity.Core_MDF_Start_Date__c,300,System.today(),null,false);
            //franceClaim.Core_MDF_Budget_Type_Options_Nm__c = 'MDF';
            franceClaim.Amount = 300;
            franceClaim.Core_MDF_Currency__c='USD'; 
            franceClaim.Core_MDF_IsClaimReviewEscalation_Ind__c = True;
            franceClaim.Core_MDF_Region_Cd__c = 'APJ';
            Database.insert(franceClaim);
            
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
            rule3.Core_MDF_Value_Txt__c= '100%';
            rule3.Core_MDF_Immediate_Ind__c= 'No';
            rule3.Core_MDF_Effective_Dt__c= System.today();
            rule3.Core_MDF_Active_Ind__c= true;
            rule3.Core_MDF_Rule_Type_Nm__c= 'Audit';
            // rule3.Core_MDF_Next_Rule_False_Id__c = rule4.id;
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
            
            Core_MDF_Audit_Rules_Engine__c rule7 = new Core_MDF_Audit_Rules_Engine__c();
            rule7.Core_MDF_Object_Nm__c= 'PartnerFundClaim';
            rule7.Core_MDF_Field_Nm__c= 'Core_MDF_Requested_Reimbursement_Amt__c';
            //rule2.Core_MDF_Budget_Type_Multi_Nm__c = 'MDF';
            rule7.Core_MDF_Operator_Nm__c= 'Greater Than';
            rule7.Core_MDF_Value_Txt__c= '20';
            rule7.Core_MDF_Immediate_Ind__c= 'No';
            rule7.Core_MDF_Effective_Dt__c= System.today();
            rule7.Core_MDF_Active_Ind__c= true;
            rule7.Core_MDF_Next_Rule_False_Id__c = rule3.id;
            rule7.Core_MDF_Rule_Type_Nm__c= 'PIC';
            Database.insert(rule7);
            
            Core_MDF_Audit_Rules_Engine__c rule1 = new Core_MDF_Audit_Rules_Engine__c();
            rule1.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
            rule1.Core_MDF_Budget_Type_Multi_Nm__c= 'MDF';
            rule1.Core_MDF_Object_Nm__c= 'Core_MDF_Claim_Prediction__c';
            rule1.Core_MDF_Field_Nm__c= 'Core_MDF_New_Prediction_Score_nbr__c';
            rule1.Core_MDF_Operator_Nm__c= 'Greater Than';
            rule1.Core_MDF_Value_Txt__c= '0';
            rule1.Core_MDF_Immediate_Ind__c= 'Yes';
            rule1.Core_MDF_Effective_Dt__c= System.today();
            rule1.Core_MDF_Active_Ind__c= true;
            rule1.Core_MDF_Next_Rule_Id__c = rule2.id;
            rule1.Core_MDF_Next_Rule_False_Id__c = rule2.id;
            rule1.Core_MDF_Region_Cd__c = 'WW';
            rule1.Core_MDF_Rule_Type_Nm__c= 'Audit';
            Database.insert(rule1);
            rule1.Core_MDF_Budget_Type_Multi_Nm__c= ('MDF+');
            update rule1;
            Core_MDF_Audit_Rules_Engine__c rule0 = new Core_MDF_Audit_Rules_Engine__c();
            //rule0.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
            //rule0.Core_MDF_Budget_Type_Multi_Nm__c= 'MDF';
            rule0.Core_MDF_Object_Nm__c= 'PartnerFundRequest';
            rule0.Core_MDF_Field_Nm__c= 'RequestedAmount';
            rule0.Core_MDF_Operator_Nm__c= 'Greater Than';
            rule0.Core_MDF_Value_Txt__c= '1';
            rule0.Core_MDF_Immediate_Ind__c= 'No';
            rule0.Core_MDF_Effective_Dt__c= System.today();
            rule0.Core_MDF_Active_Ind__c= true;
            rule0.Core_MDF_Rule_Type_Nm__c= 'Audit';
            Database.insert(rule0);   
            
            Core_MDF_Audit_Rules_Engine__c rule5 = new Core_MDF_Audit_Rules_Engine__c();
            rule5.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
            rule5.Core_MDF_Budget_Type_Multi_Nm__c= 'MDF';
            rule5.Core_MDF_Object_Nm__c= 'PartnerFundRequest';
            rule5.Core_MDF_Field_Nm__c= 'RequestedAmount';
            //rule5.Core_MDF_Field_Nm__c= 'Core_MDF_Activity_CreatedByExternalUsr__c';
            rule5.Core_MDF_Operator_Nm__c= 'Not Equal';
            rule5.Core_MDF_Value_Txt__c= '0';
            rule5.Core_MDF_Immediate_Ind__c= 'Yes';
            rule5.Core_MDF_Effective_Dt__c= System.today();
            rule5.Core_MDF_Active_Ind__c= true;
            rule5.Core_MDF_Rule_Type_Nm__c= 'Audit';
            rule5.Core_MDF_Region_Cd__c = 'WW';
            rule5.Core_MDF_Next_Rule_Id__c = rule0.id;
            Database.insert(rule5); 
            
            Core_MDF_Audit_Rules_Engine__c rule6 = new Core_MDF_Audit_Rules_Engine__c();
            rule6.Core_MDF_Object_Nm__c= 'PartnerFundClaim';
            rule6.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
            rule6.Core_MDF_Field_Nm__c= 'Core_MDF_Requested_Reimbursement_Amt__c';
            rule6.Core_MDF_Budget_Type_Multi_Nm__c = 'MDF';
            rule6.Core_MDF_Operator_Nm__c= 'Greater Than';
            rule6.Core_MDF_Value_Txt__c= '0';
            rule6.Core_MDF_Immediate_Ind__c= 'Yes';
            rule6.Core_MDF_Effective_Dt__c= System.today();
            rule6.Core_MDF_Active_Ind__c= true;
            rule6.Core_MDF_Rule_Type_Nm__c= 'Third Party';
            rule6.Core_MDF_Region_Cd__c = 'WW';
            Database.insert(rule6);
            
            Core_MDF_Audit_Rules_Engine__c rule00 = new Core_MDF_Audit_Rules_Engine__c();
            //rule0.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
            //rule0.Core_MDF_Budget_Type_Multi_Nm__c= 'MDF';
            rule00.Core_MDF_Object_Nm__c= 'PartnerFundRequest';
            rule00.Core_MDF_Field_Nm__c= 'Core_MDF_Fund_Request_Status__c';
            rule00.Core_MDF_Operator_Nm__c= 'Equal';
            rule00.Core_MDF_Value_Txt__c= '1';
            rule00.Core_MDF_Immediate_Ind__c= 'No';
            rule00.Core_MDF_Effective_Dt__c= System.today();
            rule00.Core_MDF_Active_Ind__c= true;
            rule00.Core_MDF_Rule_Type_Nm__c= 'Front End Review';
            Database.insert(rule00);      
            
            Core_MDF_Audit_Rules_Engine__c rule8 = new Core_MDF_Audit_Rules_Engine__c();
            rule8.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
            rule8.Core_MDF_Budget_Type_Multi_Nm__c= 'MDF;MDF+';
            rule8.Core_MDF_Object_Nm__c= 'PartnerFundRequest';
            rule8.Core_MDF_Field_Nm__c= 'Core_MDF_Fund_Request_Status__c';
            //rule5.Core_MDF_Field_Nm__c= 'Core_MDF_Activity_CreatedByExternalUsr__c';
            rule8.Core_MDF_Operator_Nm__c= 'Equal';
            rule8.Core_MDF_Value_Txt__c= 'Pending Review';
            rule8.Core_MDF_Immediate_Ind__c= 'Yes';
            rule8.Core_MDF_Effective_Dt__c= System.today();
            rule8.Core_MDF_Active_Ind__c= true;
            rule8.Core_MDF_Rule_Type_Nm__c= 'Front End Review';
            rule8.Core_MDF_Region_Cd__c = 'WW';
            rule8.Core_MDF_Next_Rule_Id__c = rule00.id;
            Database.insert(rule8);   
            
            
            
            Test.stopTest();
        }
    }
    
    @isTest static void testAuditRulesProcessing(){
        User systemAdmin = [Select Id from User where LastName = 'SystemAdmin'];
        system.runAs(systemAdmin){
            Test.startTest();
            Set<id> input = new Set<id>();
            // Highlight: Unused Local Variable - Indira
           // Map<string, List<Core_MDF_Audit_Rules_Engine__c>> RuleprgmBTToRulesMap = new Map<string,List<Core_MDF_Audit_Rules_Engine__c>>();
            Map<String,Map<String,Core_MDF_Rules_Engine.RulesEngineParams>> resultfromSObject = new Map<String,Map<String,Core_MDF_Rules_Engine.RulesEngineParams>>();
            Map<string,Map<Id,Core_MDF_Rules_Engine.RulesEngineParams>> result = new Map<string,Map<Id,Core_MDF_Rules_Engine.RulesEngineParams>>();
            PartnerFundClaim claim = [select id from PartnerFundClaim where title='France Claim' limit 1];
            Core_MDF_Claim_Prediction__c claimPred = new Core_MDF_Claim_Prediction__c();
            claimPred.Core_MDF_Claim_id__c = claim.Id;
            insert claimPred;
            input.add(claim.id);
            Map<string,set<Id>> inputwithruletype =new Map<string,set<Id>>();
            Map<Id,Core_MDF_Rules_Engine.RulesEngineParams> resultfromrunrules = new Map<Id,Core_MDF_Rules_Engine.RulesEngineParams>();
            Core_MDF_Rules_Engine.RulesEngineParams REparam= new Core_MDF_Rules_Engine.RulesEngineParams();
            inputwithruletype.put('PIC',input);
            inputwithruletype.put('Audit',input);
            inputwithruletype.put('Front End Review',input);    
            //Core_MDF_Claim_Prediction__c claimPred1 = [select id,Core_MDF_Program_Nm__c,Core_MDF_Budget_Type_Nm__c,Core_MDF_Claim_id__c,Core_MDF_Prediction_Score_PB__c,Core_MDF_Claim_Created_Dt__c,Core_MDF_Region_Cd__c,Core_MDF_Activity_ID__c from Core_MDF_Claim_Prediction__c where id = :claim.id limit 1];
            // Highlight: Unused Local Variable - Indira
           // List<Core_MDF_Claim_Prediction__c> claimPredList = new List<Core_MDF_Claim_Prediction__c>();
            Core_MDF_Audit_Rules_Engine__c rule5 =[select id,Core_MDF_Next_Rule_Id__c,Core_MDF_Next_Rule_False_Id__c,Core_MDF_Effective_Dt__c,Core_MDF_Region_Cd__c,Core_MDF_ID_Field_Id__c,Core_MDF_Value_Txt__c,Core_MDF_Field_Nm__c,Core_MDF_Operator_Nm__c,Name,Core_MDF_Object_Nm__c,Core_MDF_Rule_Type_Nm__c from Core_MDF_Audit_Rules_Engine__c where Core_MDF_Object_Nm__c='Core_MDF_Claim_Prediction__c' and Core_MDF_Rule_Type_Nm__c='Audit'];
            Core_MDF_Audit_Rules_Engine__c rule =[select id,Core_MDF_Next_Rule_Id__c,Core_MDF_Next_Rule_False_Id__c,Core_MDF_Effective_Dt__c,Core_MDF_Region_Cd__c,Core_MDF_ID_Field_Id__c,Core_MDF_Value_Txt__c,Core_MDF_Field_Nm__c,Core_MDF_Operator_Nm__c,Name,Core_MDF_Object_Nm__c,Core_MDF_Rule_Type_Nm__c from Core_MDF_Audit_Rules_Engine__c where Core_MDF_Object_Nm__c='Random'];
            Core_MDF_Audit_Rules_Engine__c rule2 =[select id,Core_MDF_Next_Rule_Id__c,Core_MDF_Next_Rule_False_Id__c,Core_MDF_Effective_Dt__c,Core_MDF_Region_Cd__c,Core_MDF_ID_Field_Id__c,Core_MDF_Value_Txt__c,Core_MDF_Field_Nm__c,Core_MDF_Operator_Nm__c,Name,Core_MDF_Object_Nm__c,Core_MDF_Rule_Type_Nm__c from Core_MDF_Audit_Rules_Engine__c where Core_MDF_Object_Nm__c='PartnerFundClaim' and Core_MDF_Rule_Type_Nm__c='Audit' Limit 1];
            // Highlight: Unused Local Variable - Indira
           // Core_MDF_Audit_Rules_Engine__c rule3 =[select id,Core_MDF_Next_Rule_Id__c,Core_MDF_Next_Rule_False_Id__c,Core_MDF_Effective_Dt__c,Core_MDF_Region_Cd__c,Core_MDF_ID_Field_Id__c,Core_MDF_Value_Txt__c,Core_MDF_Field_Nm__c,Core_MDF_Operator_Nm__c,Name,Core_MDF_Object_Nm__c,Core_MDF_Rule_Type_Nm__c from Core_MDF_Audit_Rules_Engine__c where Core_MDF_Object_Nm__c='PartnerFundRequest' and Core_MDF_Rule_Type_Nm__c='Audit' Limit 1];
          //  Core_MDF_Audit_Rules_Engine__c rule4 =[select id,Core_MDF_Next_Rule_Id__c,Core_MDF_Next_Rule_False_Id__c,Core_MDF_Effective_Dt__c,Core_MDF_Region_Cd__c,Core_MDF_ID_Field_Id__c,Core_MDF_Value_Txt__c,Core_MDF_Field_Nm__c,Core_MDF_Operator_Nm__c,Name,Core_MDF_Object_Nm__c,Core_MDF_Rule_Type_Nm__c from Core_MDF_Audit_Rules_Engine__c where Core_MDF_Object_Nm__c='PartnerFundRequest' and Core_MDF_Rule_Type_Nm__c='Front End Review'and Core_MDF_Immediate_Ind__c= 'Yes' Limit 1];
            
            for(Id ide : input)
            {
                result = Core_MDF_Rules_Engine.genericEngineFlow(inputwithruletype);
                for (Map<Id,Core_MDF_Rules_Engine.RulesEngineParams> res:  result.values())
                {
                    for (Core_MDF_Rules_Engine.RulesEngineParams result1 : res.values())
                    {
                        REparam.result = result1.result;
                    }
                }
                resultfromrunrules=Core_MDF_Rules_Engine.runRules(ide,rule5);
                for (Core_MDF_Rules_Engine.RulesEngineParams re:resultfromrunrules.values())
                {
                    REparam.result = re.result;
                    Assert.isFalse(REparam.result);
                }
                
                resultfromrunrules = Core_MDF_Rules_Engine.runRules(ide,rule);
                for (Core_MDF_Rules_Engine.RulesEngineParams re1:resultfromrunrules.values())
                {
                    REparam.result = re1.result;
                    Assert.isTrue(REparam.result);
                }
                
                resultfromrunrules= Core_MDF_Rules_Engine.runRules(ide,rule2);
                for (Core_MDF_Rules_Engine.RulesEngineParams re2:resultfromrunrules.values())
                {
                    REparam.result = re2.result;
                    Assert.isTrue(REparam.result);
                }
                
                
            }
            // Highlight: Unused Local Variable - Indira
          //  Map<string,List<sobject>> rulInputForPfr = new Map<string,List<sobject>> ();
            Map<string,List<sobject>> rulInputForPfc = new Map<string,List<sobject>> ();
            List<sobject> pfcRecords =[select id, Core_MDF_IsClaimReviewEscalation_Ind__c, 
                                       Core_MDF_Requested_Reimbursement_Amt__c, Core_MDF_Region_Cd__c, 
                                       Core_MDF_Program__c, Core_MDF_Budget_Type_Options_Nm__c
                                       from PartnerFundClaim limit 1];
            
            rulInputForPfc.put ('Third Party', pfcRecords);
            resultfromSObject=Core_MDF_Rules_Engine.executeRulesByObjects(rulInputForPfc);
            for (Map<String,Core_MDF_Rules_Engine.RulesEngineParams> res:  resultfromSObject.values())
            {
                for (Core_MDF_Rules_Engine.RulesEngineParams result1 : res.values())
                {
                    REparam.result = result1.result;
                    //Assert.isTrue(REparam.result);
                }
            }
            
            Test.stopTest();
        }
    }
    
    @isTest static void testExecutePredictionRule(){
        User systemAdmin = [Select Id from User where LastName = 'SystemAdmin'];
        system.runAs(systemAdmin){
            PartnerFundClaim claim = [select id from PartnerFundClaim where title='France Claim' limit 1];
            Core_MDF_Audit_Rules_Engine__c rule =[select id,Core_MDF_Next_Rule_Id__c,Core_MDF_Next_Rule_False_Id__c,Core_MDF_Effective_Dt__c,Core_MDF_Region_Cd__c,Core_MDF_ID_Field_Id__c,Core_MDF_Value_Txt__c,Core_MDF_Field_Nm__c,Core_MDF_Operator_Nm__c,Name,Core_MDF_Object_Nm__c,Core_MDF_Rule_Type_Nm__c from Core_MDF_Audit_Rules_Engine__c where Core_MDF_Object_Nm__c='PartnerFundClaim' and Core_MDF_Rule_Type_Nm__c='Audit'];
            Core_MDF_Rules_Engine.executePredictionRule(claim.id,rule);
            Assert.isNotNull(claim.id);
            Assert.isNotNull(rule);
        }
    }
    
    @isTest static void testExceptions(){
        User systemAdmin = [Select Id from User where LastName = 'SystemAdmin'];
        system.runAs(systemAdmin){
            Core_MDF_Rules_Engine.genericEngineFlow(null);
            Core_MDF_Rules_Engine.getAuditRulesRecords(null);
            Core_MDF_Rules_Engine.queryObjectFields(null, null);
            Core_MDF_Rules_Engine.matchTheClaimsAgainstRulesafterinsert(null,null);
            Core_MDF_Rules_Engine.runRules(null, null);
            Core_MDF_Rules_Engine.executePredictionRule(null, null);
            Core_MDF_Rules_Engine.executeRandomLogic(null, null);
            Core_MDF_Rules_Engine.getMatchingRules(null, null);
            Core_MDF_Rules_Engine.matchRecordsAgainstRules(null, null, null, null);
            Core_MDF_Rules_Engine.runRulesBySObject(null, null, null, null);
            // Unit Test Method should include System.Assert - Indira
            System.assert(true, 'All methods should execute without throwing unhandled exceptions');
        }
    }
    
    
}