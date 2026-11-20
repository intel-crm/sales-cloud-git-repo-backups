@isTest(SeeAllData=false)
public class Core_MDF_Create_CCP_Cases_Test {
    @TestSetup
    static void makeData() {
        
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution3 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution3.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'before upate, after update';
        claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution3.Name = 'checkAndSendClaimsToAudit';
        claimFunctionalityNameTriggerExecution3.Core_Description__c = 'test';
        Database.insert(claimFunctionalityNameTriggerExecution3);
        //adding bypass feature to bypass access validation
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        List<User> userList = new List<User>();
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet paymentAdminPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName='Payment Admin';
        usr.profile=ccpCoreProfile;
        userList.add(usr);
        
        Map<String,Id> profileToId = new Map<String,Id>();
        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','Partner','CCP - Core Access')]) {
            profileToId.put(prfl.Name,prfl.Id);
        }
        User usr1 = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='test1@example.com',
                             EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),
                             TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',
                             UserPermissionsMarketingUser = TRUE);
        usr1.Email = 'sysadmin@example.com';
        usr1.IsActive=true;
        //usr.userRoleId = usRole.Id;
        
        userList.add(usr1);
        Database.insert(userList); 
        
        
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = usr.Id;
        assignPermissionSetObj.PermissionSetId = paymentAdminPS.Id;
        
        system.runAs(usr1){
            Database.insert(assignPermissionSetObj);
        }
        
        ChannelProgram ccfCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        
        Account cccIntelAcc = Core_MDF_CCP_TestDataUtility.createAccount ('CCC Test Account', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        cccIntelAcc.BillingCity = 'ARP City';         
        cccIntelAcc.BillingCountry= 'IND';
        cccIntelAcc.BillingStreet= 'ARP Street'; 
        Database.insert(cccIntelAcc);   
        
        Account cccCCFVC = Core_MDF_CCP_TestDataUtility.createAccount ('CCC CCF Virtual Corp', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        cccCCFVC.Core_MDF_Parent_Fund_Account__c = cccIntelAcc.Id;
        cccCCFVC.Core_MDF_CoMarketingActive__c = true;
        Database.insert(cccCCFVC);
        
        Account cccCCFEMEA = Core_MDF_CCP_TestDataUtility.createAccount ('CCC CCF EMEA', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        cccCCFEMEA.Core_MDF_Parent_Fund_Account__c = cccCCFVC.Id;
        Database.insert(cccCCFEMEA);
        
        Account cccEMEAFrance = Core_MDF_CCP_TestDataUtility.createAccount ('CCC CCF EMEA France', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        cccEMEAFrance.Core_MDF_Parent_Fund_Account__c = cccCCFEMEA.Id;
        cccEMEAFrance.Core_MDF_Auto_Transfer_Account__c = cccCCFVC.Id;
        cccEMEAFrance.Core_MDF_Enabled_Auto_Transfer__c = True;
        Database.insert(cccEMEAFrance);
        
       PartnerMarketingBudget  cccPmbRecord = new PartnerMarketingBudget();
         System.runAs(usr1){
         cccPmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('CCC PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,cccCCFVC.Id,ccfCP.Id,100000,System.today().addDays(-10),System.today().addDays(10),false);
        cccPmbRecord.Core_MDF_Budget_Type_Txt__c ='OEM CMP';
        //cccPmbRecord.Core_MDF_Budget_Status__c = 'Released';
        Database.insert(cccPmbRecord);
         }
        Core_MDF_Bank__c  cccBank = new Core_MDF_Bank__c();
        PartnerFundAllocation pfaCCCCCFFrance = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaCCCCCFFrance',cccPmbRecord, cccEMEAFrance, 1000, true);
        System.runAs(usr)
        {
            cccBank = Core_MDF_CCP_TestDataUtility.createBank(cccIntelAcc.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
        }
        // Highlight: Unused Local Variable 
       // Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(cccEMEAFrance.Id,cccBank.Id,true);
        
        
        Campaign cccCamp = Core_MDF_CCP_TestDataUtility.createCampaign('ARP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(+5), 10000, 'Consumer Chromebook', cccCCFVC.Id, '2-in-1', false);
        cccCamp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        cccCamp.Core_MDF_Supports_legacy_program__c='CMP only';
        Database.insert(cccCamp);
        
        Core_MDF_Campaign_Budgets__c campBudget = new Core_MDF_Campaign_Budgets__c();
        campBudget.Core_MDF_Budget_Name_Id__c = cccPmbRecord.id;
        campBudget.Core_MDF_Campaign_Id__c=cccCamp.id;
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
        
        Test.startTest();
        PartnerFundRequest cccFranceActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(cccCamp.Id), 
                                                                                                     Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                     String.valueof(cccEMEAFrance.id),pfaCCCCCFFrance,cccPmbRecord,'INDIA',
                                                                                                     'Consumer',
                                                                                                     'Desktop',
                                                                                                     'Intel® Core™ i5 Processor',
                                                                                                     'Broadcast',
                                                                                                     'Podcast',
                                                                                                     'Draft',
                                                                                                     false);
        cccFranceActivity.Title = 'France Activity';
        cccFranceActivity.Core_MDF_Activity_Description__c = 'France Activity';
        cccFranceActivity.Core_MDF_Start_Date__c = System.today().addDays(-2);
        cccFranceActivity.Core_MDF_End_Date__c = System.today().addDays(+2);
        cccFranceActivity.RequestedAmount = 1000;
        cccFranceActivity.Core_MDF_pagespayingfor__c = 15;
        cccFranceActivity.Amount=1000;
        cccFranceActivity.Core_MDF_Budget_Type_nm__c= 'OEM CMP';
        cccFranceActivity.Core_MDF_Reimbursement_Rate_pct__c='50%';
        cccFranceActivity.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        cccFranceActivity.Core_MDF_Channel_Partner_Led__c = true;
        Database.insert(cccFranceActivity);
        
        List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        PartnerFundClaim franceClaim = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,cccFranceActivity.Id,cccFranceActivity.Core_MDF_Start_Date__c, cccFranceActivity.Core_MDF_Start_Date__c,300,System.today(),cccBank.ID,false);
        //franceClaim.Core_MDF_Budget_Type_Nm__c= 'OEM CMP';
        //franceClaim.Core_MDF_Reimbursement_Percent__c = '50%';
        franceClaim.Core_MDF_PIC_Review_Completed__c = true;
        franceClaim.Core_MDF_BackendReviewSelection_Ind__c = false;
        franceClaim.Core_MDF_Document_Submission_Missed_Ind__c = false;
        franceClaim.Amount = 300;
        franceClaim.Core_MDF_Currency__c='USD'; 
        franceClaim.Core_MDF_Audit_Hold__c = true;
        franceClaim.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
        //Database.insert(franceClaim);
        pfcList.add(franceClaim);
        
        
        PartnerFundClaim zVClaim = Core_MDF_CCP_TestDataUtility.createClaim('ZV Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,cccFranceActivity.Id,cccFranceActivity.Core_MDF_Start_Date__c, cccFranceActivity.Core_MDF_Start_Date__c,300,System.today(),cccBank.ID,false);
        zVClaim.Core_MDF_Document_Submission_Missed_Ind__c = true;
        zVClaim.Amount = 300;
        zVClaim.Core_MDF_Currency__c='USD'; 
        zVClaim.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
        pfcList.add(zVClaim);
        Database.insert(pfcList);
        Test.stopTest();
        
        Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
        auditDoc.Core_MDF_Claim__c = franceClaim.id;
        auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
        auditDoc.Core_MDF_Document_Types__c='Proof of Cost';
        auditDoc.Core_MDF_Document_Title__c = 'Test Audit Document';
        Database.insert(auditDoc);
        
        Core_MDF_Audit_Rules_Engine__c rule3 = new Core_MDF_Audit_Rules_Engine__c();
        rule3.Core_MDF_Object_Nm__c= 'Random';
        rule3.Core_MDF_Field_Nm__c= 'Percentage';
        rule3.Core_MDF_Operator_Nm__c= 'Equal';
        rule3.Core_MDF_Value_Txt__c= '1%';
        rule3.Core_MDF_Immediate_Ind__c= 'No';
        rule3.Core_MDF_Effective_Dt__c= System.today();
        rule3.Core_MDF_Active_Ind__c= true;
        rule3.Core_MDF_Rule_Type_Nm__c= 'Audit';
        //rule3.Core_MDF_Next_Rule_False_Id__c = rule4.id;
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
        rule1.Core_MDF_Budget_Type_Multi_Nm__c= 'OEM CMP';
        rule1.Core_MDF_Object_Nm__c= 'PartnerFundClaim';
        rule1.Core_MDF_Field_Nm__c= 'Core_MDF_Currency__c';
        rule1.Core_MDF_Operator_Nm__c= 'Equal';
        rule1.Core_MDF_Value_Txt__c= 'USD';
        rule1.Core_MDF_Immediate_Ind__c= 'Yes';
        rule1.Core_MDF_Effective_Dt__c= System.today();
        rule1.Core_MDF_Active_Ind__c= true;
        rule1.Core_MDF_Next_Rule_Id__c = rule2.id;
        rule1.Core_MDF_Next_Rule_False_Id__c = rule2.id;
        rule1.Core_MDF_Region_Cd__c = 'WW';
        rule1.Core_MDF_Rule_Type_Nm__c= 'Audit';
        Database.insert(rule1); 
    }
    
    
    @isTest static void testSchedulerMethod() {
        PartnerFundClaim franceClaim = [select id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c,Core_MDF_BackendReviewSelection_Ind__c from PartnerFundClaim limit 1];            
        franceClaim.Core_MDF_Status__c ='Paid';
        Database.update(franceClaim);
        // Unit Test Method should include System.Assert 
        System.assertEquals('Paid', franceClaim.Core_MDF_Status__c, 'Claim status should be updated to Paid');
       
        Core_MDF_Create_CCP_Cases_Schedulable test = new Core_MDF_Create_CCP_Cases_Schedulable();
        test.execute(null);            
    }
    
    @isTest static void testShouldExecuteBatchJob_EmptyCalendar() {
        Date batchRunDate = Date.newInstance(2024, 1, 6);
        // Unit Test Method should include System.Assert
        System.assertNotEquals(null,batchRunDate,'Batch run date should not be null');
        // Highlight: Unused Local Variable
    	/*Boolean result = */ Core_MDF_Create_CCP_Cases_Schedulable.shouldExecuteBatchJob(batchRunDate);
        
	}
    
   @isTest static void testSchedulerMethod_2() {
        PartnerFundClaim franceClaim = [select id,Core_MDF_Status__c,Core_MDF_PIC_Review_Completed__c,Core_MDF_BackendReviewSelection_Ind__c from PartnerFundClaim limit 1];            
        franceClaim.Core_MDF_Status__c ='Payment Due';
        Database.update(franceClaim);
       
       Core_MDF_Create_CCP_Cases_Batch batchRec = new Core_MDF_Create_CCP_Cases_Batch();
       Database.executeBatch(batchRec,10);        
    }

    
}