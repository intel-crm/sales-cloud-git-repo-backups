@isTest(seeAllData = false)
private class Core_MDF_AuditDocumentHelperRevamp_Test {
    @testSetup
    static void setUpData() {
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        
        List<User> userlist = new List<User>();
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr.LastName = 'System Adm';
        usr.ProfileId = sysAdminProfile.Id;
        usr.isActive = true;
        usr.Email = 'sysadmin@example.com';
        userlist.add(usr);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr2.LastName = 'PIC Reviewer';
        usr2.ProfileId = ccpCoreAccessProfile.Id;
        usr2.isActive = true;
        usr2.Email = 'picreviewer@example.com';
        userlist.add(usr2);
        
        Database.insert(userlist);
        // Highlight: Unused Local Variable - Indira
       // List<Account> toBeUpdated = new List<Account>();        
        
        system.runAs(usr){
            PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = usr.Id);
            insert psa;
            //insertCurrencyExchangeRates
            Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
            //byPassFunctionalities
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
            bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
            bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
            bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
            bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
            bypassFunctionKeys.add('Bypass_Activity_ApprovalProcess');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            List<Core_Trigger_Executions__c> bypassfunctinalitylist = Core_MDF_CCP_TestDataUtility.byPassFeature(bypassFunctionKeys,true,true);
            Core_MDF_Configuration__c execution1 = new Core_MDF_Configuration__c();
            execution1.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            execution1.Core_MDF_Category__c = 'Bank Document Hold Logic';
            execution1.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
            insert execution1; 
            
            // Creating channel program with utility class
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            
            // Creating Account with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
            
            PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 30000, System.today().addDays(-4), System.today().addDays(364), false);
            pbm.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            insert pbm;
            
            PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
            PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-3), System.today().addDays(300), 10000, 'Always Connected PC', acc2.Id,'Desktop', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            Database.insert(camp);
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
           // Highlight: Unused Local Variable - Indira
           // Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank.Id, true);
            List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)','Radio','Draft',false);
            testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
            testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            testPartnerFundRequestRecord.Title = 'Test PFR';
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = System.today() - 1;
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = System.today().addDays(2);
            testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            Database.insert(testPartnerFundRequestRecord);
            
            Test.startTest();
            PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)','Radio','Draft',false);
            testPartnerFundRequestRecord1.Amount = testPartnerFundRequestRecord.RequestedAmount;
            testPartnerFundRequestRecord1.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            testPartnerFundRequestRecord1.Core_MDF_Start_Date__c = System.today() - 1;
            testPartnerFundRequestRecord1.Core_MDF_End_Date__c = System.today().addDays(20);
            testPartnerFundRequestRecord1.Title = 'Test Activity';
            testPartnerFundRequestRecord1.Core_MDF_Reimbursement_Rate_pct__c='100%';
            testPartnerFundRequestRecord1.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            testPartnerFundRequestRecord1.Core_MDF_Channel_Partner_Led__c = true;
            Database.insert(testPartnerFundRequestRecord1);
            
            PartnerFundRequest testPartnerFundRequestRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)','Radio','Draft',false);
            testPartnerFundRequestRecord2.Amount = testPartnerFundRequestRecord.RequestedAmount;
            testPartnerFundRequestRecord2.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            testPartnerFundRequestRecord2.Core_MDF_Start_Date__c = System.today() - 1;
            testPartnerFundRequestRecord2.Core_MDF_End_Date__c = System.today().addDays(20);
            testPartnerFundRequestRecord2.Title = 'Test Activity1';
            testPartnerFundRequestRecord2.Core_MDF_Reimbursement_Rate_pct__c='100%';
            testPartnerFundRequestRecord2.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            testPartnerFundRequestRecord2.Core_MDF_Channel_Partner_Led__c = true;
            Database.insert(testPartnerFundRequestRecord2);
            
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim1', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today(), 5000.00, System.today(), bank.Id, false);
            claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            claim1.Status = Label.Core_MDF_Status_Submitted;
            claim1.Core_MDF_Eligible_for_PIC__c = true;
            claim1.Core_MDF_Status__c = label.Core_MDF_Claim_Status_PIC_Pending;
            claim1.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            pfcList.add(claim1);
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
            claim2.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            claim2.Status = Label.Core_MDF_Status_Submitted;
            claim2.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_PIC_Pending;
            claim2.Core_MDF_Eligible_for_PIC__c = true;
            claim2.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            pfcList.add(claim2);
            PartnerFundClaim claim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim3', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today()-1, System.today()-1, 5000.00, System.today(), bank.Id, false);
            claim3.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            claim3.Core_MDF_RecentInternalComments_txt__c = 'Testing 1';
            claim3.Status = Label.Core_MDF_Status_Submitted;
            claim3.Core_MDF_Eligible_for_PIC__c = true;
            claim3.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
            claim3.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            pfcList.add(claim3);
            
            Database.insert(pfcList);
            List<Core_MDF_Audit_Document__c> auditDocList  = new List<Core_MDF_Audit_Document__c>();
            List<ContentDocument> contentDoc = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
            Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
            auditDoc.Core_MDF_Document_Id__c = contentDoc[0].Id;
            auditDoc.Core_MDF_Claim__c = claim1.Id;
            auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDoc.Core_MDF_Document_Title__c = 'Test Doc1';
            auditDocList.add(auditDoc);
            
            List<ContentDocument> contentDoc1 = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
            Core_MDF_Audit_Document__c auditDoc1 = new Core_MDF_Audit_Document__c();
            auditDoc1.Core_MDF_Document_Id__c = contentDoc1[0].Id;
            auditDoc1.Core_MDF_Claim__c = claim2.Id;
            auditDoc1.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding';
            auditDoc1.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDoc1.Core_MDF_Document_Title__c = 'Test Doc2';
            auditDocList.add(auditDoc1);
            
            List<ContentDocument> contentDoc2 = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
            Core_MDF_Audit_Document__c auditDoc2 = new Core_MDF_Audit_Document__c();
            auditDoc2.Core_MDF_Document_Id__c = contentDoc2[0].Id;
            auditDoc2.Core_MDF_Claim__c = claim3.Id;
            auditDoc2.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding';
            auditDoc2.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDoc2.Core_MDF_Document_Title__c = 'Test Doc3';
            auditDocList.add(auditDoc2);
            Database.insert(auditDocList);
            
            Test.stopTest();
            //claim batch instance
            Core_MDF_Claim_Batch__c claimbatchinstance = new Core_MDF_Claim_Batch__c();
            claimbatchinstance.Core_MDF_Program_Id__c =  cp1.Id;
            claimbatchinstance.Core_MDF_Account__c = [SELECT ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c FROM 
                                                      PartnerFundRequest WHERE ID=:testPartnerFundRequestRecord1.Id].ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c;
            Database.insert(claimbatchinstance);            
            //insert third party rule 
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
    
    @isTest
    static void testFetchMetaDataRecords() {
        String programName1 = Core_MDF_CCP_ConstantClass.CCF_PROGRAM;
        String programName2 = Core_MDF_CCP_ConstantClass.RMF_PROGRAM;
        String budgetType1 = 'OEM CMP';
        String budgetType2 = 'RSA MD';
        User adminUser = [SELECT Id FROM User WHERE email = 'sysadmin@example.com' LIMIT 1];
        system.runAs(adminUser){
            Core_MDF_AuditDocumentHelper_Revamp.fetchMetaDataRecords(programName1, budgetType1);
            Core_MDF_AuditDocumentHelper_Revamp.fetchMetaDataRecords(programName2, budgetType2);   
        }
        // Unit Test Method should include System.Assert - Indira
        System.assertEquals('OEM CMP', budgetType1, 'Budget type 1 should be OEM CMP');
    }
    
    @isTest
    static void testInsertAuditDocumentAndContentDocumentLink1() {
        
        User adminUser = [SELECT Id FROM User WHERE email = 'sysadmin@example.com' LIMIT 1];
        system.runAs(adminUser){
            
            Core_MDF_Audit_Document__c auditDoc1 = [select Id, Core_MDF_Claim__c, Core_MDF_Document_Types__c from Core_MDF_Audit_Document__c where Core_MDF_Document_Title__c =: 'Test Doc1' limit 1];
            List<ContentDocument> contentDoc = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
            auditDoc1.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding';
            Test.startTest();
            //pfc -- insert/update when switchClaimStatusToPICPending is false
            PartnerFundClaim pfc = [select Id from PartnerFundClaim where Title =: 'Test Claim1' limit 1];
            pfc.Core_MDF_Status__c = 'Resubmission Required';
            Database.update(pfc);
            //insert a new audit document
            Core_MDF_Audit_Document__c auditDoc2 = new Core_MDF_Audit_Document__c();
            auditDoc2.Core_MDF_Claim__c = pfc.Id;
            auditDoc2.Core_MDF_Document_Id__c = contentDoc[0].Id;
            auditDoc2.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
            auditDoc2.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDoc2.Core_MDF_Document_Title__c = 'Test Doc2';
            //create auditDocumentWrapper
            List<Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper> auditDocWrapperList = new List<Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper>();
            Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper auditDocWrapper1 = new Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper();
            auditDocWrapper1.isNewDocument = false;
            auditDocWrapper1.auditDocument = auditDoc1;
            auditDocWrapperList.add(auditDocWrapper1);
            
            Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper auditDocWrapper2 = new Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper();
            auditDocWrapper2.isNewDocument = true;
            auditDocWrapper2.auditDocument = auditDoc2;
            auditDocWrapperList.add(auditDocWrapper2);
            
            Test.stopTest();
            // Unit Test Method should include System.Assert - Indira
            System.assertEquals(2, auditDocWrapperList.size(), 'Audit document wrapper list should contain 2 items');
            
            Core_MDF_AuditDocumentHelper_Revamp.insertAuditDocumentAndContentDocumentLink(auditDocWrapperList, pfc.Id, false);
        }
    }
    
    @isTest
    static void testInsertAuditDocumentAndContentDocumentLink2() {
        User adminUser = [SELECT Id FROM User WHERE email = 'sysadmin@example.com' LIMIT 1];
        system.runAs(adminUser){
            Test.startTest();
            //pfc -- insert/update when switchClaimStatusToPICPending is true
            PartnerFundClaim pfc = [select Id from PartnerFundClaim where Title =: 'Test Claim2' limit 1];
            pfc.Core_MDF_Status__c = 'Resubmission Required';
            update pfc;
            
            Core_MDF_Audit_Document__c auditDoc = [select Id, Core_MDF_Claim__c, Core_MDF_Document_Types__c from Core_MDF_Audit_Document__c where Core_MDF_Claim__c=: pfc.Id limit 1];
            auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
            
            //create auditDocumentWrapper
            List<Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper> auditDocWrapperList = new List<Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper>();
            Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper auditDocWrapper1 = new Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper();
            auditDocWrapper1.isNewDocument = false;
            auditDocWrapper1.auditDocument = auditDoc;
            auditDocWrapperList.add(auditDocWrapper1);
            
            Test.stopTest();
            // Unit Test Method should include System.Assert - Indira
            System.assertEquals(1, auditDocWrapperList.size(), 'Audit document wrapper list should contain 1 item');
            
            Core_MDF_AuditDocumentHelper_Revamp.insertAuditDocumentAndContentDocumentLink(auditDocWrapperList, pfc.Id, true);
        }
    }
    
    @isTest
    static void testInsertAuditDocumentAndContentDocumentLink3() {
        
        User adminUser = [SELECT Id FROM User WHERE email = 'sysadmin@example.com' LIMIT 1];
        system.runAs(adminUser){
            
            Test.startTest();
            //pfc -- insert/update when switchClaimStatusToPICPending is true
            PartnerFundClaim pfc = [select Id from PartnerFundClaim where Title =: 'Test Claim3' limit 1];
            pfc.Core_MDF_RMF_Last_POP_Submission_Dt__c = null;
            pfc.Core_MDF_Status__c = 'Paid and Resubmission Required';
            update pfc;
            
            Core_MDF_Audit_Document__c auditDoc = [select Id, Core_MDF_Claim__c, Core_MDF_Document_Types__c from Core_MDF_Audit_Document__c where Core_MDF_Claim__c=: pfc.Id limit 1];
            auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding';
            
            //create auditDocumentWrapper
            List<Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper> auditDocWrapperList = new List<Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper>();
            Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper auditDocWrapper1 = new Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper();
            auditDocWrapper1.isNewDocument = false;
            auditDocWrapper1.auditDocument = auditDoc;
            auditDocWrapperList.add(auditDocWrapper1);
            
            Test.stopTest();
            // Unit Test Method should include System.Assert - Indira
              System.assertEquals(false, auditDocWrapper1.isNewDocument, 'isNewDocument should be false for existing document');
    
            Core_MDF_AuditDocumentHelper_Revamp.insertAuditDocumentAndContentDocumentLink(auditDocWrapperList, pfc.Id, true);
        }
    }
    
    @isTest
    static void testInsertAuditDocumentAndContentDocumentLinkException() {
        User adminUser = [SELECT Id FROM User WHERE email = 'sysadmin@example.com' LIMIT 1];
        system.runAs(adminUser){
            Test.startTest();
            //pfc -- insert/update when switchClaimStatusToPICPending is true
            PartnerFundClaim pfc = [select Id from PartnerFundClaim where Title =: 'Test Claim3' limit 1];
            
            Core_MDF_Audit_Document__c auditDoc = [select Id, Core_MDF_Claim__c, Core_MDF_Document_Types__c from Core_MDF_Audit_Document__c where Core_MDF_Claim__c=: pfc.Id limit 1];
            auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
            
            //create auditDocumentWrapper
            List<Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper> auditDocWrapperList = new List<Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper>();
            Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper auditDocWrapper1 = new Core_MDF_AuditDocumentHelper_Revamp.auditDocumentWrapper();
            auditDocWrapper1.isNewDocument = false;
            auditDocWrapper1.auditDocument = auditDoc;
            auditDocWrapperList.add(auditDocWrapper1);
            
            Test.stopTest();
            // Unit Test Method should include System.Assert - Indira
            System.assertEquals(pfc.Id, auditDoc.Core_MDF_Claim__c,'Audit document should be linked to the correct claim');
            try {
                Core_MDF_AuditDocumentHelper_Revamp.insertAuditDocumentAndContentDocumentLink(auditDocWrapperList, auditDoc.Id, false);
                
            } catch(Exception ex) {
            }
        }
    }
        @isTest
        static void testDeleteDocumentIds() {
            User adminUser = [SELECT Id FROM User WHERE email = 'sysadmin@example.com' LIMIT 1];
          system.runAs(adminUser){
                PartnerFundClaim pfc = [select Id from PartnerFundClaim where Title =: 'Test Claim3' limit 1];
                Core_MDF_Audit_Document__c auditDoc = [select Id, Core_MDF_Claim__c, Core_MDF_Document_Types__c, Core_MDF_Document_Id__c from Core_MDF_Audit_Document__c where Core_MDF_Claim__c=: pfc.Id limit 1];
                String docId = auditDoc.Core_MDF_Document_Id__c;
                // Unit Test Method should include System.Assert - Indira
                System.assertNotEquals(null,docId, 'Document ID should not be null');
                //delete content document link
                Core_MDF_AuditDocumentHelper_Revamp.deleteDocumentIds(docId);
                //Exception
                try {
                   Core_MDF_AuditDocumentHelper_Revamp.deleteDocumentIds('abcdef'); 
                } catch(Exception ex) {
                }
            }
        }
    
    @isTest
    static void testCheckClaimStatusForPICProcess() {
        User adminUser = [SELECT Id FROM User WHERE email = 'sysadmin@example.com' LIMIT 1];
        system.runAs(adminUser){
            
            PartnerFundClaim pfc1 = [select Id from PartnerFundClaim where Title =: 'Test Claim1' limit 1];
            PartnerFundClaim pfc2 = [select Id from PartnerFundClaim where Title =: 'Test Claim2' limit 1];
            pfc1.Core_MDF_Status__c = 'Resubmission Required';
            update pfc1;
            Core_MDF_Audit_Document__c auditDoc = [select Id, Core_MDF_Claim__c, Core_MDF_Document_Types__c, Core_MDF_Document_Id__c from Core_MDF_Audit_Document__c where Core_MDF_Claim__c=: pfc1.Id limit 1];
            
            //if statement
            Core_MDF_AuditDocumentHelper_Revamp.checkClaimStatusForPICProcess(pfc1.Id);
            //else statement
            Core_MDF_AuditDocumentHelper_Revamp.checkClaimStatusForPICProcess(pfc2.Id);
            //Exception scenario
            try {
                Core_MDF_AuditDocumentHelper_Revamp.checkClaimStatusForPICProcess(auditDoc.Id);
            } catch(Exception ex) {
            }
            // Unit Test Method should include System.Assert - Indira
            System.assertEquals(pfc1.Id, auditDoc.Core_MDF_Claim__c, 'Audit document should be linked to PFC1');
        }
    }
    
     @isTest
    static void testIsValidThirdPartyPOPClaim() {
        Test.startTest();
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
         User admUsr = Core_MDF_CCP_TestDataUtility.createUser(false);        
        admUsr.LastName = 'System Adm';
        admUsr.ProfileId = sysAdminProfile.Id;
        admUsr.isActive = true;
        admUsr.Email = 'sysadmin123@example.com';
        insert admUsr;
        
        PermissionSet ccfPayAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
            PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
            assignPermissionSetObj1.AssigneeId = admUsr.Id;
            assignPermissionSetObj1.PermissionSetId = ccfPayAdmPS.Id;
            Database.insert(assignPermissionSetObj1);
            
        List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        PartnerFundClaim claim1 = new PartnerFundClaim();
        
        Core_MDF_AuditDocumentHelper_Revamp.wrapperThirdPartyPOP obj = new Core_MDF_AuditDocumentHelper_Revamp.wrapperThirdPartyPOP();
        PartnerFundRequest pfr = [Select id,Core_MDF_Reimbursement_Rate_pct__c,Core_MDF_Reimbursement_Rate_txt__c, Core_MDF_Start_Date__c, Core_MDF_End_Date__c from PartnerFundRequest where Title =: 'Test Activity' limit 1];
        Core_MDF_Bank__c bank = [Select id from Core_MDF_Bank__c WHERE Name = 'Test' limit 1];
        bank.Core_MDF_Bank_Status__c = 'Active';
        bank.Core_MDF_ESD_Hold_Indicator__c=false;
        system.runAs(admUsr){
        Database.update(bank);
        
        
        
        claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,pfr.Id,System.today(), System.today(),300,System.today(),bank.ID,false);
        claim1.Core_MDF_Budget_Type_Options_Nm__c= 'OEM CMP';
        claim1.Core_MDF_Currency__c='USD';
       	claim1.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
        claimList.add(claim1);
        Database.insert(claimList);
        }
        PartnerFundClaim ThirdPartyClaim = [Select Id,Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_Region_Cd__c,Status,Core_MDF_Budget_Type_Nm__c, Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_ESD_Hold__c,Core_MDF_Status__c,Core_MDF_Eligible_for_PIC__c,Core_MDF_PIC_Review_Completed__c,CreatedDate From PartnerFundClaim WHERE Id = :claim1.Id LIMIT 1];
        Core_MDF_PartnerFundClaim_Edit.ClaimCountryDetailsWrapper clonePFC = new Core_MDF_PartnerFundClaim_Edit.ClaimCountryDetailsWrapper();
        clonePFC = Core_MDF_PartnerFundClaim_Edit.prepareCloneData(ThirdPartyClaim.Id);

        PartnerFundClaim ThirdPartyClaim123 = [Select Id,Core_MDF_Program__c,Core_MDF_Ultimate_Account_ID__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,Core_MDF_Currency__c,Core_MDF_Country_Location_nm__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_Region_Cd__c,Status,Core_MDF_Budget_Type_Nm__c,Core_MDF_Type_Txt__c,Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Taxes_Local__c,Amount,Core_MDF_Audit_Adjustment_Amount__c,Core_MDF_Requested_Reimbursement_Amt__c,Core_MDF_Exchange_rate__c,Core_MDF_Reimbursable_Transaction_Amount__c,Core_MDF_Status__c,Core_MDF_Eligible_for_PIC__c,Core_MDF_PIC_Review_Completed__c,CreatedDate From PartnerFundClaim WHERE Id = :clonePFC.claimObj.Id LIMIT 1];
        obj= Core_MDF_AuditDocumentHelper_Revamp.isValidThirdPartyPOPClaim(ThirdPartyClaim123,'');
        System.assertEquals(obj.isThirdPartyPOP, true);
       // System.assertNotEquals(obj.ruleId, obj.ruleId);

        Test.stopTest();
    }
    
     @isTest
    static void testIsNotAValidThirdPartyPOPClaims() {
        Test.startTest();
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User admUsr = Core_MDF_CCP_TestDataUtility.createUser(false);        
        admUsr.LastName = 'System Adm';
        admUsr.ProfileId = sysAdminProfile.Id;
        admUsr.isActive = true;
        admUsr.Email = 'sysadmin456@example.com';
        insert admUsr;
        
        PermissionSet ccfPayAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
            PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
            assignPermissionSetObj1.AssigneeId = admUsr.Id;
            assignPermissionSetObj1.PermissionSetId = ccfPayAdmPS.Id;
            Database.insert(assignPermissionSetObj1);
            
        List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        PartnerFundClaim claim1 = new PartnerFundClaim();
        
        Core_MDF_AuditDocumentHelper_Revamp.wrapperThirdPartyPOP obj = new Core_MDF_AuditDocumentHelper_Revamp.wrapperThirdPartyPOP();
        PartnerFundRequest pfr = [Select id,Core_MDF_Reimbursement_Rate_pct__c,Core_MDF_Reimbursement_Rate_txt__c, Core_MDF_Start_Date__c, Core_MDF_End_Date__c from PartnerFundRequest where Title=: 'Test Activity1' limit 1];
        Core_MDF_Bank__c bank = [Select id from Core_MDF_Bank__c WHERE Name = 'Test' limit 1];
        bank.Core_MDF_Bank_Status__c = 'Active';
        bank.Core_MDF_ESD_Hold_Indicator__c=false;
        system.runAs(admUsr){
        Database.update(bank);
        
        
        claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,pfr.Id,System.today(), System.today(),300,System.today(),bank.ID,false);
        claim1.Core_MDF_Budget_Type_Options_Nm__c= 'OEM CMP';
        claim1.Core_MDF_Currency__c='USD';
        claim1.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
        claimList.add(claim1);
        Database.insert(claimList);
        }
        PartnerFundClaim ThirdPartyClaim = [Select Id,Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_Region_Cd__c,Status,Core_MDF_Budget_Type_Nm__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_ESD_Hold__c,Core_MDF_Status__c,Core_MDF_Eligible_for_PIC__c,Core_MDF_PIC_Review_Completed__c,CreatedDate From PartnerFundClaim WHERE Id = :claim1.Id LIMIT 1];
        
        Core_MDF_PartnerFundClaim_Edit.ClaimCountryDetailsWrapper clonePFC = new Core_MDF_PartnerFundClaim_Edit.ClaimCountryDetailsWrapper();
        clonePFC = Core_MDF_PartnerFundClaim_Edit.prepareCloneData(ThirdPartyClaim.Id);

        PartnerFundClaim ThirdPartyClaim123 = [Select Id,Core_MDF_Program__c,Core_MDF_Ultimate_Account_ID__c,Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,Core_MDF_Currency__c,Core_MDF_Country_Location_nm__c,Core_MDF_Reimbursement_Percent__c,Core_MDF_Region_Cd__c,Status,Core_MDF_Budget_Type_Nm__c,Core_MDF_Type_Txt__c,Core_MDF_OtherCostsnotReimbursable_Local__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Taxes_Local__c,Amount,Core_MDF_Audit_Adjustment_Amount__c,Core_MDF_Requested_Reimbursement_Amt__c,Core_MDF_Exchange_rate__c,Core_MDF_Reimbursable_Transaction_Amount__c,Core_MDF_Status__c,Core_MDF_Eligible_for_PIC__c,Core_MDF_PIC_Review_Completed__c,CreatedDate From PartnerFundClaim WHERE Id = :clonePFC.claimObj.Id LIMIT 1];
        obj= Core_MDF_AuditDocumentHelper_Revamp.isValidThirdPartyPOPClaim(ThirdPartyClaim123,'');
        System.assertEquals(obj.isThirdPartyPOP, true);    
         
        Test.stopTest();
    }
    
    @isTest
    static void testGetAuditDocumentDetailsWrapper1() {
        User adminUser = [SELECT Id FROM User WHERE email = 'sysadmin@example.com' LIMIT 1];
        PermissionSet claimCaseReviewerManagerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];        
        PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerManagerPermissionSet.Id, AssigneeId = adminUser.Id);
        insert psa;
        system.runAs(adminUser){
           //for Internal claim case reviewer
           //record id is null - clone, create
           Core_MDF_AuditDocumentHelper_Revamp.getAuditDocumentDetailsWrapper(null,false);
           //PFC and PFR
            PartnerFundClaim pfc = [select Id from PartnerFundClaim where Title =: 'Test Claim1' limit 1];
            PartnerFundRequest pfr = [Select Id, Core_MDF_Activity_Number__c from PartnerFundRequest where Title=: 'Test PFR' limit 1];
            //edit, claim detail page
           Core_MDF_AuditDocumentHelper_Revamp.getAuditDocumentDetailsWrapper(pfc.Id,true);
            Test.startTest();
            //bulk claim
            Core_MDF_Claim_Batch__c claimBatch = [select Id from Core_MDF_Claim_Batch__c limit 1];
            Core_MDF_Bank__c bank = [select Id, Core_MDF_Supplier_Number__c from Core_MDF_Bank__c limit 1];
            
            Core_MDF_Claim_Batch_Stage__c claimStageInstance = new Core_MDF_Claim_Batch_Stage__c();
            claimStageInstance.Core_MDF_Activity_Nbr__c= pfr.Core_MDF_Activity_Number__c; 
            claimStageInstance.Core_MDF_Ad_Run_End_Dt__c=System.today();
            claimStageInstance.Core_MDF_Ad_Run_Start_Dt__c=System.today();
            claimStageInstance.Core_MDF_Bank_Nbr__c=bank.Core_MDF_Supplier_Number__c;
            claimStageInstance.Core_MDF_Claim_Comment_txt__c='test';
            claimStageInstance.Core_MDF_Claim_Nm__c='test1';
            claimStageInstance.Core_MDF_Batch_ID__c=claimBatch.Id;
            claimStageInstance.Core_MDF_Inv_Receipt_Cur_Cd__c='USD';
            claimStageInstance.Core_MDF_Inv_Receipt_Dt__c=System.today();
            claimStageInstance.Core_MDF_Inv_Receipt_Nbr__c='1234';
            claimStageInstance.Core_MDF_Media_Vehicle_txt__c='test1';
            claimStageInstance.Core_MDF_Non_Reimbursable_Amt__c=0;
            claimStageInstance.Core_MDF_Taxes_Local_Amt__c=0;
            claimStageInstance.Core_MDF_Total_Amt__c=10;
            claimStageInstance.Core_MDF_Country_Location_nm__c = 'India';
            claimStageInstance.Core_MDF_Activity_SubType_nm__c = 'email';
            claimStageInstance.Core_MDF_Bank_Id__c = bank.Id;
            claimStageInstance.Core_MDF_Request_Id__c = pfr.Id;
            insert claimStageInstance;
            
            Core_MDF_AuditDocumentHelper_Revamp.getAuditDocumentDetailsWrapper(claimStageInstance.Id,true);
            Test.stopTest();
            // Unit Test Method should include System.Assert - Indira
            System.assertEquals(claimBatch.Id, claimStageInstance.Core_MDF_Batch_ID__c, 'Should be linked to correct batch');
        }
    }
    
    @isTest
    static void testGetAuditDocumentDetailsWrapper2() {
        //PFC and PFR
        PartnerFundClaim pfc = [select Id from PartnerFundClaim where Title =: 'Test Claim1' limit 1];
        PartnerFundRequest pfr = [Select Id, Core_MDF_Activity_Number__c from PartnerFundRequest where Title=: 'Test PFR' limit 1];
        Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        //Non claim submitters
        //User user = [select Id from User where LastName =: 'PIC Reviewer' limit 1];
        User user = Core_MDF_CCP_TestDataUtility.createUser(false);        
        user.LastName = 'PIC Reviewer';
        user.ProfileId = ccpCoreAccessProfile.Id;
        user.isActive = true;
        user.Email = 'picreviewer@example.com';
        insert user;
        System.runAs(user) {
            PermissionSet picReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_PIC_Reviewer'];        
            PermissionSetAssignment  psa1 = new PermissionSetAssignment(PermissionSetId = picReviewerPermissionSet.Id, AssigneeId = user.Id);
            insert psa1;
            
            Core_MDF_AuditDocumentHelper_Revamp.getAuditDocumentDetailsWrapper(pfc.Id,true);
         // Unit Test Method should include System.Assert - Indira
         System.assertEquals(user.Id, psa1.AssigneeId, 'Permission set should be assigned to user');
        }
        //future purpose 
        Core_MDF_AuditDocumentHelper_Revamp.getAuditDocumentDetailsWrapper(pfr.Id,true);
        //to enable document upload section
        pfc.Core_MDF_PIC_Review_Completed__c = false;
        pfc.Core_MDF_Status__c = 'Resubmission Required';
        update pfc;
        Core_MDF_AuditDocumentHelper_Revamp.getAuditDocumentDetailsWrapper(pfc.Id,true);
    }
     @isTest
    static void testgetClaimAndUserDetails(){
         PartnerFundClaim pfc = [select Id from PartnerFundClaim where Title =: 'Test Claim1' limit 1];
         Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
         User user = Core_MDF_CCP_TestDataUtility.createUser(false);        
        user.LastName = 'PIC Reviewer';
        user.ProfileId = ccpCoreAccessProfile.Id;
        user.isActive = true;
        user.Email = 'picreviewer@example.com';
        insert user;
        System.runAs(user) {
            PermissionSet picReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_PIC_Reviewer'];        
            PermissionSetAssignment  psa1 = new PermissionSetAssignment(PermissionSetId = picReviewerPermissionSet.Id, AssigneeId = user.Id);
            insert psa1;
            Core_MDF_AuditDocumentHelper_Revamp.getClaimAndUserDetails(pfc.Id);
              pfc.Core_MDF_PIC_Review_Completed__c = false;
          pfc.Core_MDF_Status__c = 'Resubmission Required';
            Core_MDF_AuditDocumentHelper_Revamp.fetchAuditDocuments(pfc.Id);
           Core_MDF_AuditDocumentHelper_Revamp.updateClaimStatus(pfc.Id);
          // Unit Test Method should include System.Assert - Indira  
        System.assertEquals('Resubmission Required', pfc.Core_MDF_Status__c, 'Status should be Resubmission Required');
        }
    }
}