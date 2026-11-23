/**
 * @description       : Final optimized test class for Core_MDF_AuditDocumentHelper_Revamp
 * @author            : Shweta Pandey
 * @last modified on  : 03-13-2026
 **/
@isTest(seeAllData = false)
private class Core_MDF_AuditDocHelperRevampTest_New {
    
     // Static variables to cache frequently used records
    private static User adminUser;
    private static User picReviewerUser;
    private static List<PartnerFundClaim> testClaims;
    private static List<Core_MDF_Audit_Document__c> testAuditDocs;
    private static PartnerFundRequest testPFR;
    private static Core_MDF_Bank__c testBank;
    private static Core_MDF_Claim_Batch__c testClaimBatch;
    
    @testSetup
    static void setUpData() {
        // Create profiles - Query once and reuse
        Map<String, Profile> profileMap = new Map<String, Profile>();
        for(Profile p : [SELECT Id, Name FROM Profile WHERE Name IN ('System Administrator', 'CCP - Core Access')]) {
            profileMap.put(p.Name, p);
        }
        
        // Create users
        List<User> userlist = new List<User>();
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr.LastName = 'System Adm';
        usr.ProfileId = profileMap.get('System Administrator').Id;
        usr.isActive = true;
        usr.Email = 'sysadmin@example.com';
        userlist.add(usr);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr2.LastName = 'PIC Reviewer';
        usr2.ProfileId = profileMap.get('CCP - Core Access').Id;
        usr2.isActive = true;
        usr2.Email = 'picreviewer@example.com';
        userlist.add(usr2);
        
        Database.insert(userlist);
        
        // Setup data in system context
        system.runAs(usr){
            // Query permission sets once and cache
            Map<String, PermissionSet> permissionSetMap = new Map<String, PermissionSet>();
            for(PermissionSet ps : [SELECT Id, Name FROM PermissionSet WHERE Name IN (
                'Core_MDF_CCP_Internal_Claim_Case_Reviewer',
                'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager',
                'Core_MDF_CCP_Internal_PIC_Reviewer'
            )]) {
                permissionSetMap.put(ps.Name, ps);
            }
            
            // Assign permission sets
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            psaList.add(new PermissionSetAssignment(
                PermissionSetId = permissionSetMap.get('Core_MDF_CCP_Internal_Claim_Case_Reviewer').Id, 
                AssigneeId = usr.Id
            ));
            psaList.add(new PermissionSetAssignment(
                PermissionSetId = permissionSetMap.get('Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager').Id, 
                AssigneeId = usr.Id
            ));
            psaList.add(new PermissionSetAssignment(
                PermissionSetId = permissionSetMap.get('Core_MDF_CCP_Internal_PIC_Reviewer').Id, 
                AssigneeId = usr2.Id
            ));
            insert psaList;
            
            // Insert currency exchange rates
            Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
            
            // Bypass functionalities - Create all at once
            List<String> bypassFunctionKeys = new List<String>{
                'Bypass_Duplicate_Budget_Check', 'Bypass_GeoBased_Budget_Sharing', 'Bypass_Allocation_Reservation',
                'Bypass_GeoBased_Allocation_Sharing', 'Bypass_Duplicate_Bank_Check', 'Bypass_Bank_Internal_Sharing',
                'Bypass_Bank_External_Sharing', 'Bypass_Bank_ABM_Sharing', 'Bypass_ABM_Internal_Sharing',
                'Bypass_ABM_External_Sharing', 'Bypass_ABM_NodeGroup_Sharing', 'byPassShareUnshareCampaignRecord',
                'byPassCampaignAndRelatedRecords', 'Bypass_PaymentRun_Duplicate_Check', 'Bypass_Claims_Duplicate_Check',
                'Bypass_Claims_Sharing_Internal_Users', 'Bypass_ClaimAdjReq_Share_On_Owner_Chng',
                'Bypass_ClaimAdjReq_Share_Internal_Usrs', 'Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_ABM_Validation', 'Bypass_Claims_Sharing_Partner_Users',
                'Bypass_Payment_Doc_InvFileVAT_Validate', 'Bypass_Bank_Program_InActivation_Check',
                'Bypass_Activity_ApprovalProcess', 'Bypass_MDF_Budget_Access', 'Bypass_MDF_Budget_Access_Validation'
            };
            List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
            
            // Configuration record
            Core_MDF_Configuration__c execution1 = new Core_MDF_Configuration__c();
            execution1.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            execution1.Core_MDF_Category__c = 'Bank Document Hold Logic';
            execution1.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
            insert execution1; 
            
            // Create program and accounts
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
            
            PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 30000, System.today().addDays(-4), System.today().addDays(364), false);
            pbm.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            insert pbm;
            
            PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-3), System.today().addDays(300), 10000, 'Always Connected PC', acc2.Id,'Desktop', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            Database.insert(camp);
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            bank.Core_MDF_Bank_Status__c = 'Active';
            bank.Core_MDF_ESD_Hold_Indicator__c = false;
            update bank;
            
            Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank.Id, true);
            
            // Create partner fund requests - Bulk insert
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfaRecord,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)','Radio','Draft',false);
            testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
            testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            testPartnerFundRequestRecord.Title = 'Test PFR';
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = System.today() - 1;
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = System.today().addDays(2);
            testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            pfrList.add(testPartnerFundRequestRecord);
            
            PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfaRecord,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)','Radio','Draft',false);
            testPartnerFundRequestRecord1.Amount = testPartnerFundRequestRecord1.RequestedAmount;
            testPartnerFundRequestRecord1.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            testPartnerFundRequestRecord1.Core_MDF_Start_Date__c = System.today() - 1;
            testPartnerFundRequestRecord1.Core_MDF_End_Date__c = System.today().addDays(20);
            testPartnerFundRequestRecord1.Title = 'Test Activity';
            testPartnerFundRequestRecord1.Core_MDF_Reimbursement_Rate_pct__c='100%';
            testPartnerFundRequestRecord1.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            testPartnerFundRequestRecord1.Core_MDF_Channel_Partner_Led__c = true;
            pfrList.add(testPartnerFundRequestRecord1);
            
            PartnerFundRequest testPartnerFundRequestRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfaRecord,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)','Radio','Draft',false);
            testPartnerFundRequestRecord2.Amount = testPartnerFundRequestRecord2.RequestedAmount;
            testPartnerFundRequestRecord2.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            testPartnerFundRequestRecord2.Core_MDF_Start_Date__c = System.today() - 1;
            testPartnerFundRequestRecord2.Core_MDF_End_Date__c = System.today().addDays(20);
            testPartnerFundRequestRecord2.Title = 'Test Activity1';
            testPartnerFundRequestRecord2.Core_MDF_Reimbursement_Rate_pct__c='100%';
            testPartnerFundRequestRecord2.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            testPartnerFundRequestRecord2.Core_MDF_Channel_Partner_Led__c = true;
            pfrList.add(testPartnerFundRequestRecord2);
            
            Database.insert(pfrList);
            
            // Create claims - Bulk insert
            List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim1', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfrList[0].Id, System.today()-1, System.today(), 5000.00, System.today(), bank.Id, false);
            claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            claim1.Status = Label.Core_MDF_Status_Submitted;
            claim1.Core_MDF_Eligible_for_PIC__c = true;
            claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_PIC_Pending;
            pfcList.add(claim1);
            
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfrList[0].Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
            claim2.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            claim2.Status = Label.Core_MDF_Status_Submitted;
            claim2.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_PIC_Pending;
            claim2.Core_MDF_Eligible_for_PIC__c = true;
            pfcList.add(claim2);
            
            PartnerFundClaim claim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim3', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfrList[0].Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
            claim3.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            claim3.Core_MDF_RecentInternalComments_txt__c = 'Testing 1';
            claim3.Status = Label.Core_MDF_Status_Submitted;
            claim3.Core_MDF_Eligible_for_PIC__c = true;
            claim3.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
            pfcList.add(claim3);
            
            Database.insert(pfcList);
            
            // Create audit documents - Bulk insert with content documents
            List<Core_MDF_Audit_Document__c> auditDocList = new List<Core_MDF_Audit_Document__c>();
            List<ContentDocument> contentDocs = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
            
            for(Integer i = 0; i < 3; i++) {
                List<ContentDocument> singleContentDoc = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = singleContentDoc[0].Id;
                auditDoc.Core_MDF_Claim__c = pfcList[i].Id;
                auditDoc.Core_MDF_Document_Types__c = i == 0 ? 'Proof of Cost;Proof of Execution;Proof of Attribution' : 'Proof of Cost;Proof of Branding';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
                auditDoc.Core_MDF_Document_Title__c = 'Test Doc' + (i + 1);
                auditDocList.add(auditDoc);
            }
            Database.insert(auditDocList);
            
            // Create claim batch instance
            Core_MDF_Claim_Batch__c claimbatchinstance = new Core_MDF_Claim_Batch__c();
            claimbatchinstance.Core_MDF_Program_Id__c = cp1.Id;
            claimbatchinstance.Core_MDF_Account__c = acc1.Id;
            Database.insert(claimbatchinstance);
            
            // Insert third party rule 
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
    }
    
    // Helper method to get cached users
    private static User getAdminUser() {
        if(adminUser == null) {
            adminUser = [SELECT Id FROM User WHERE email = 'sysadmin@example.com' LIMIT 1];
        }
        return adminUser;
    }
    
    private static User getPicReviewerUser() {
        if(picReviewerUser == null) {
            picReviewerUser = [SELECT Id FROM User WHERE email = 'picreviewer@example.com' LIMIT 1];
        }
        return picReviewerUser;
    }
    
    // Helper method to get cached claims
    private static List<PartnerFundClaim> getTestClaims() {
        if(testClaims == null) {
            testClaims = [SELECT Id, Title, Core_MDF_Status__c FROM PartnerFundClaim ORDER BY Title];
        }
        return testClaims;
    }
    
    // Helper method to get cached audit documents
    private static List<Core_MDF_Audit_Document__c> getTestAuditDocs() {
        if(testAuditDocs == null) {
            testAuditDocs = [SELECT Id, Core_MDF_Claim__c, Core_MDF_Document_Types__c, Core_MDF_Document_Id__c, Core_MDF_Document_Title__c FROM Core_MDF_Audit_Document__c];
        }
        return testAuditDocs;
    }
    
    @isTest
    static void testFetchMetaDataRecords() {
        String programName1 = Core_MDF_CCP_ConstantClass.CCF_PROGRAM;
        String programName2 = Core_MDF_CCP_ConstantClass.RMF_PROGRAM;
        String budgetType1 = 'CCF 1.0';
        String budgetType2 = 'RSA MD';
        
        system.runAs(getAdminUser()){
            Test.startTest();
            Core_MDF_AuditDocumentHelper_Revamp.fetchMetaDataRecords(programName1, budgetType1);
            Core_MDF_AuditDocumentHelper_Revamp.fetchMetaDataRecords(programName2, budgetType2);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testInsertAuditDocumentAndContentDocumentLink() {
        system.runAs(getAdminUser()){
            Test.startTest();
            
            List<PartnerFundClaim> claims = getTestClaims();
            List<Core_MDF_Audit_Document__c> auditDocs = getTestAuditDocs();
            
            // Update claim status for first claim
            claims[0].Core_MDF_Status__c = 'Resubmission Required';
            update claims[0];
            
            // Create new content document for testing
            List<ContentDocument> contentDoc = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
            
            // Prepare audit document wrappers
            List<Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper> auditDocWrapperList = new List<Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper>();
            
            // Existing document wrapper
            Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper auditDocWrapper1 = new Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper();
            auditDocWrapper1.isNewDocument = false;
            auditDocWrapper1.auditDocument = auditDocs[0];
            auditDocWrapper1.auditDocument.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding';
            auditDocWrapperList.add(auditDocWrapper1);
            
            // New document wrapper
            Core_MDF_Audit_Document__c newAuditDoc = new Core_MDF_Audit_Document__c();
            newAuditDoc.Core_MDF_Claim__c = claims[0].Id;
            newAuditDoc.Core_MDF_Document_Id__c = contentDoc[0].Id;
            newAuditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
            newAuditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
            newAuditDoc.Core_MDF_Document_Title__c = 'Test Doc New';
            
            Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper auditDocWrapper2 = new Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper();
            auditDocWrapper2.isNewDocument = true;
            auditDocWrapper2.auditDocument = newAuditDoc;
            auditDocWrapperList.add(auditDocWrapper2);
            
            // Test the method
            Core_MDF_AuditDocumentHelper_Revamp.insertAuditDocumentAndContentDocumentLink(auditDocWrapperList, claims[0].Id, false);
            
            // Test different scenarios
            claims[1].Core_MDF_Status__c = 'Resubmission Required';
            update claims[1];
            
            List<Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper> auditDocWrapperList2 = new List<Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper>();
            Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper auditDocWrapper3 = new Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper();
            auditDocWrapper3.isNewDocument = false;
            auditDocWrapper3.auditDocument = auditDocs[1];
            auditDocWrapper3.auditDocument.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
            auditDocWrapperList2.add(auditDocWrapper3);
            
            Core_MDF_AuditDocumentHelper_Revamp.insertAuditDocumentAndContentDocumentLink(auditDocWrapperList2, claims[1].Id, true);
            
            // Test paid and resubmission required status
            claims[2].Core_MDF_RMF_Last_POP_Submission_Dt__c = null;
            claims[2].Core_MDF_Status__c = 'Paid and Resubmission Required';
            update claims[2];
            
            List<Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper> auditDocWrapperList3 = new List<Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper>();
            Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper auditDocWrapper4 = new Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper();
            auditDocWrapper4.isNewDocument = false;
            auditDocWrapper4.auditDocument = auditDocs[2];
            auditDocWrapperList3.add(auditDocWrapper4);
            
            Core_MDF_AuditDocumentHelper_Revamp.insertAuditDocumentAndContentDocumentLink(auditDocWrapperList3, claims[2].Id, true);
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testDeleteDocumentIds() {
        system.runAs(getAdminUser()){
            Test.startTest();
            
            List<Core_MDF_Audit_Document__c> auditDocs = getTestAuditDocs();
            String docId = auditDocs[0].Core_MDF_Document_Id__c;
            
            // Test successful deletion
            Core_MDF_AuditDocumentHelper_Revamp.deleteDocumentIds(docId);
            
            // Test exception scenario
            try {
               Core_MDF_AuditDocumentHelper_Revamp.deleteDocumentIds('abcdef'); 
            } catch(Exception ex) {
                // Expected exception
            }
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testCheckClaimStatusForPICProcessAndThirdPartyPOP() {
        system.runAs(getAdminUser()){
            Test.startTest();
            
            List<PartnerFundClaim> claims = getTestClaims();
            List<Core_MDF_Audit_Document__c> auditDocs = getTestAuditDocs();
            
            // Test checkClaimStatusForPICProcess method
            claims[0].Core_MDF_Status__c = 'Resubmission Required';
            update claims[0];
            
            Core_MDF_AuditDocumentHelper_Revamp.checkClaimStatusForPICProcess(claims[0].Id);
            Core_MDF_AuditDocumentHelper_Revamp.checkClaimStatusForPICProcess(claims[1].Id);
            
            // Exception scenario for checkClaimStatusForPICProcess
            try {
                Core_MDF_AuditDocumentHelper_Revamp.checkClaimStatusForPICProcess(auditDocs[0].Id);
            } catch(Exception ex) {
                // Expected exception
            }
            
            // Test isValidThirdPartyPOPClaim method - Positive case
            Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
            User admUsr = Core_MDF_CCP_TestDataUtility.createUser(false);        
            admUsr.LastName = 'System Adm Third Party';
            admUsr.ProfileId = sysAdminProfile.Id;
            admUsr.isActive = true;
            admUsr.Email = 'sysadmin123@example.com';
            insert admUsr;
            
            // Assign permission set to trigger third party logic
            PermissionSet ccfPayAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
            PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
            assignPermissionSetObj1.AssigneeId = admUsr.Id;
            assignPermissionSetObj1.PermissionSetId = ccfPayAdmPS.Id;
            Database.insert(assignPermissionSetObj1);
            
            // Get test data for third party validation
            PartnerFundRequest pfr = [SELECT Id, Core_MDF_Reimbursement_Rate_pct__c, Core_MDF_Reimbursement_Rate_txt__c, Core_MDF_Start_Date__c, Core_MDF_End_Date__c FROM PartnerFundRequest WHERE Title = 'Test Activity' LIMIT 1];
            Core_MDF_Bank__c bank = [SELECT Id FROM Core_MDF_Bank__c WHERE Name = 'Test' LIMIT 1];
            
            // Create claim that should trigger third party POP validation
            PartnerFundClaim thirdPartyClaim1;
            system.runAs(admUsr){
                // Update bank to active status
                bank.Core_MDF_Bank_Status__c = 'Active';
                bank.Core_MDF_ESD_Hold_Indicator__c = false;
                Database.update(bank);
                
                // Create claim with conditions that trigger third party POP
                thirdPartyClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Third Party Claim 1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 300, System.today(), bank.Id, false);
                thirdPartyClaim1.Core_MDF_Budget_Type_Options_Nm__c = 'OEM CMP';
                thirdPartyClaim1.Core_MDF_Currency__c = 'USD';
                thirdPartyClaim1.Core_MDF_Requested_Reimbursement_Amt__c = 500; // Amount > 1 to trigger third party rule
                insert thirdPartyClaim1;
            }
            
            // Query the claim with all required fields for isValidThirdPartyPOPClaim
            PartnerFundClaim thirdPartyClaimForValidation = [
                SELECT Id, Core_MDF_Program__c, Core_MDF_Ultimate_Account_ID__c, 
                       Core_MDF_3rd_Party_POP_Doc_Required_Ind__c, Core_MDF_Currency__c, 
                       Core_MDF_Country_Location_nm__c, Core_MDF_Reimbursement_Percent__c, 
                       Core_MDF_Region_Cd__c, Status, Core_MDF_Budget_Type_Options_Nm__c, 
                       Core_MDF_Type_Txt__c, Core_MDF_OtherCostsnotReimbursable_Local__c, 
                       Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_Taxes_Local__c, 
                       Amount, Core_MDF_Audit_Adjustment_Amount__c, 
                       Core_MDF_Requested_Reimbursement_Amt__c, Core_MDF_Exchange_rate__c, 
                       Core_MDF_Reimbursable_Transaction_Amount__c, Core_MDF_Status__c, 
                       Core_MDF_Eligible_for_PIC__c, Core_MDF_PIC_Review_Completed__c, CreatedDate 
                FROM PartnerFundClaim 
                WHERE Id = :thirdPartyClaim1.Id LIMIT 1
            ];
            
            // Test the isValidThirdPartyPOPClaim method directly - Positive case
            Core_MDF_AuditDocumentHelper_Revamp.wrapperThirdPartyPOP result1 = 
                Core_MDF_AuditDocumentHelper_Revamp.isValidThirdPartyPOPClaim(thirdPartyClaimForValidation, '');
            
            // Test with prepareCloneData scenario (as in original test)
            Core_MDF_PartnerFundClaim_Edit.ClaimCountryDetailsWrapper clonePFC = 
                Core_MDF_PartnerFundClaim_Edit.prepareCloneData(thirdPartyClaimForValidation.Id);
            
            PartnerFundClaim clonedClaim = [
                SELECT Id, Core_MDF_Program__c, Core_MDF_Ultimate_Account_ID__c, 
                       Core_MDF_3rd_Party_POP_Doc_Required_Ind__c, Core_MDF_Currency__c, 
                       Core_MDF_Country_Location_nm__c, Core_MDF_Reimbursement_Percent__c, 
                       Core_MDF_Region_Cd__c, Status, Core_MDF_Budget_Type_Options_Nm__c, 
                       Core_MDF_Type_Txt__c, Core_MDF_OtherCostsnotReimbursable_Local__c, 
                       Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_Taxes_Local__c, 
                       Amount, Core_MDF_Audit_Adjustment_Amount__c, 
                       Core_MDF_Requested_Reimbursement_Amt__c, Core_MDF_Exchange_rate__c, 
                       Core_MDF_Reimbursable_Transaction_Amount__c, Core_MDF_Status__c, 
                       Core_MDF_Eligible_for_PIC__c, Core_MDF_PIC_Review_Completed__c, CreatedDate 
                FROM PartnerFundClaim 
                WHERE Id = :clonePFC.claimObj.Id LIMIT 1
            ];
            
            
            // Test isValidThirdPartyPOPClaim method - Negative case
            // Create a second user and claim that should NOT trigger third party POP
            /*User admUsr2 = Core_MDF_CCP_TestDataUtility.createUser(false);        
            admUsr2.LastName = 'System Adm Third Party 2';
            admUsr2.ProfileId = sysAdminProfile.Id;
            admUsr2.isActive = true;
            admUsr2.Email = 'sysadmin456@example.com';
            insert admUsr2;
            
            PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
            assignPermissionSetObj2.AssigneeId = admUsr2.Id;
            assignPermissionSetObj2.PermissionSetId = ccfPayAdmPS.Id;
            Database.insert(assignPermissionSetObj2);
            
            // Create claim with amount that should NOT trigger third party POP
            PartnerFundRequest pfr2 = [SELECT Id FROM PartnerFundRequest WHERE Title = 'Test Activity1' LIMIT 1];
            PartnerFundClaim thirdPartyClaim2;
            
            system.runAs(admUsr2){
                thirdPartyClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Third Party Claim 2', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, pfr2.Id, System.today(), System.today(), 0.5, System.today(), bank.Id, false);
                thirdPartyClaim2.Core_MDF_Budget_Type_Options_Nm__c = 'MDF'; // Different budget type
                thirdPartyClaim2.Core_MDF_Currency__c = 'USD';
                thirdPartyClaim2.Core_MDF_Requested_Reimbursement_Amt__c = 5; // Amount <= 1, should not trigger third party rule
                insert thirdPartyClaim2;
            }
            
            // Query the second claim for validation
            PartnerFundClaim thirdPartyClaimForValidation2 = [
                SELECT Id, Core_MDF_Program__c, Core_MDF_Ultimate_Account_ID__c, 
                       Core_MDF_3rd_Party_POP_Doc_Required_Ind__c, Core_MDF_Currency__c, 
                       Core_MDF_Country_Location_nm__c, Core_MDF_Reimbursement_Percent__c, 
                       Core_MDF_Region_Cd__c, Status, Core_MDF_Budget_Type_Options_Nm__c, 
                       Core_MDF_Type_Txt__c, Core_MDF_OtherCostsnotReimbursable_Local__c, 
                       Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_Taxes_Local__c, 
                       Amount, Core_MDF_Audit_Adjustment_Amount__c, 
                       Core_MDF_Requested_Reimbursement_Amt__c, Core_MDF_Exchange_rate__c, 
                       Core_MDF_Reimbursable_Transaction_Amount__c, Core_MDF_Status__c, 
                       Core_MDF_Eligible_for_PIC__c, Core_MDF_PIC_Review_Completed__c, CreatedDate 
                FROM PartnerFundClaim 
                WHERE Id = :thirdPartyClaim2.Id LIMIT 1
            ];
            
            
            // Test with cloned data for negative case
            Core_MDF_PartnerFundClaim_Edit.ClaimCountryDetailsWrapper clonePFC2 = 
                Core_MDF_PartnerFundClaim_Edit.prepareCloneData(thirdPartyClaimForValidation2.Id);
            
            PartnerFundClaim clonedClaim2 = [
                SELECT Id, Core_MDF_Program__c, Core_MDF_Ultimate_Account_ID__c, 
                       Core_MDF_3rd_Party_POP_Doc_Required_Ind__c, Core_MDF_Currency__c, 
                       Core_MDF_Country_Location_nm__c, Core_MDF_Reimbursement_Percent__c, 
                       Core_MDF_Region_Cd__c, Status, Core_MDF_Budget_Type_Options_Nm__c, 
                       Core_MDF_Type_Txt__c, Core_MDF_OtherCostsnotReimbursable_Local__c, 
                       Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_Taxes_Local__c, 
                       Amount, Core_MDF_Audit_Adjustment_Amount__c, 
                       Core_MDF_Requested_Reimbursement_Amt__c, Core_MDF_Exchange_rate__c, 
                       Core_MDF_Reimbursable_Transaction_Amount__c, Core_MDF_Status__c, 
                       Core_MDF_Eligible_for_PIC__c, Core_MDF_PIC_Review_Completed__c, CreatedDate 
                FROM PartnerFundClaim 
                WHERE Id = :clonePFC2.claimObj.Id LIMIT 1
            ];
            */
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetAuditDocumentDetailsWrapper() {
        system.runAs(getAdminUser()){
            Test.startTest();
            
            List<PartnerFundClaim> claims = getTestClaims();
            PartnerFundRequest pfr = [SELECT Id, Core_MDF_Activity_Number__c FROM PartnerFundRequest WHERE Title = 'Test PFR' LIMIT 1];
            Core_MDF_Bank__c bank = [SELECT Id, Core_MDF_Supplier_Number__c FROM Core_MDF_Bank__c LIMIT 1];
            Core_MDF_Claim_Batch__c claimBatch = [SELECT Id FROM Core_MDF_Claim_Batch__c LIMIT 1];
            
            // Test with null record id (clone/create scenario)
            Core_MDF_AuditDocumentHelper_Revamp.getAuditDocumentDetailsWrapper(null,false);
            
            // Test with claim id (edit/detail page scenario)
            Core_MDF_AuditDocumentHelper_Revamp.getAuditDocumentDetailsWrapper(claims[0].Id,true);
            
            // Test bulk claim scenario
            Core_MDF_Claim_Batch_Stage__c claimStageInstance = new Core_MDF_Claim_Batch_Stage__c();
            claimStageInstance.Core_MDF_Activity_Nbr__c = pfr.Core_MDF_Activity_Number__c; 
            claimStageInstance.Core_MDF_Ad_Run_End_Dt__c = System.today();
            claimStageInstance.Core_MDF_Ad_Run_Start_Dt__c = System.today();
            claimStageInstance.Core_MDF_Bank_Nbr__c = bank.Core_MDF_Supplier_Number__c;
            claimStageInstance.Core_MDF_Claim_Comment_txt__c = 'test';
            claimStageInstance.Core_MDF_Claim_Nm__c = 'test1';
            claimStageInstance.Core_MDF_Batch_ID__c = claimBatch.Id;
            claimStageInstance.Core_MDF_Inv_Receipt_Cur_Cd__c = 'USD';
            claimStageInstance.Core_MDF_Inv_Receipt_Dt__c = System.today();
            claimStageInstance.Core_MDF_Inv_Receipt_Nbr__c = '1234';
            claimStageInstance.Core_MDF_Media_Vehicle_txt__c = 'test1';
            claimStageInstance.Core_MDF_Non_Reimbursable_Amt__c = 0;
            claimStageInstance.Core_MDF_Taxes_Local_Amt__c = 0;
            claimStageInstance.Core_MDF_Total_Amt__c = 10;
            claimStageInstance.Core_MDF_Country_Location_nm__c = 'India';
            claimStageInstance.Core_MDF_Activity_SubType_nm__c = 'email';
            claimStageInstance.Core_MDF_Bank_Id__c = bank.Id;
            claimStageInstance.Core_MDF_Request_Id__c = pfr.Id;
            insert claimStageInstance;
            
            Core_MDF_AuditDocumentHelper_Revamp.getAuditDocumentDetailsWrapper(claimStageInstance.Id,true);
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetClaimAndUserDetailsAndUpdateClaimStatus() {
        Test.startTest();
        
        List<PartnerFundClaim> claims = getTestClaims();
        
        System.runAs(getPicReviewerUser()) {
            Core_MDF_AuditDocumentHelper_Revamp.getClaimAndUserDetails(claims[0].Id);
            Core_MDF_AuditDocumentHelper_Revamp.fetchAuditDocuments(claims[0].Id);
        }
        
        system.runAs(getAdminUser()){
            claims[0].Core_MDF_PIC_Review_Completed__c = false;
            claims[0].Core_MDF_Status__c = 'Resubmission Required';
            update claims[0];
            Core_MDF_AuditDocumentHelper_Revamp.updateClaimStatus(claims[0].Id);
            
            claims[1].Core_MDF_Status__c = 'Resubmission Required';
            update claims[1];
            Core_MDF_AuditDocumentHelper_Revamp.updateClaimStatus(claims[1].Id);

            claims[2].Core_MDF_Status__c = 'Paid and Resubmission Required';
            update claims[2];
            Core_MDF_AuditDocumentHelper_Revamp.updateClaimStatus(claims[2].Id);
        }
        
        System.runAs(getPicReviewerUser()) {
            try {
                claims[0].Core_MDF_Status__c = 'Test Status';
                update claims[0];
            } catch(DmlException e) {
                System.assert(e.getMessage().contains('INSUFFICIENT_ACCESS'), 'Expected insufficient access error');
            }
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testFetchAuditDocuments() {
        system.runAs(getAdminUser()){
            Test.startTest();
            
            List<PartnerFundClaim> claims = getTestClaims();
            Boolean result = Core_MDF_AuditDocumentHelper_Revamp.fetchAuditDocuments(claims[0].Id);
            
            Test.stopTest();
        }
    } 
}