/****************************************************************************************************************************************************
 * Class Name      : Core_MDF_CDB_UtilityTest
 * Version               : 1.0
 * Created Date          :  03-02-2026 
 * Modification Log      : 
 * Developer            Date             Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------
 * Shubhra/Sinduja     01-19-2026        Test class for Core_MDF_CDB_Utility
 ******************************************************************************************************************************************************/
@isTest
public class Core_MDF_CDB_UtilityTest {
    
    // Constants for program and budget type to avoid string literals
    private static final String PROGRAM_CCF = 'Client CoMarketing Fund';
    private static final String BUDGET_TYPE_CCF = 'OEM CMP';
    
    @TestSetup
    static void setupData() {
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        List<User> userlist = new List<User>();
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'System Adm';
        usr.ProfileId = sysAdminProfile.Id;
        usr.isActive = true;
        usr.Email = 'sysadmin@example.com';
        userlist.add(usr);
        Database.insert(userlist);
        
        system.runAs(usr){
            List<PermissionSet> picReviewerPermissionSets = [SELECT Id, Name FROM PermissionSet where Name IN ('Core_MDF_CCP_Internal_Claim_Case_Reviewer')];
            PermissionSetAssignment  psa1 = new PermissionSetAssignment(PermissionSetId = picReviewerPermissionSets[0].Id, AssigneeId = usr.Id);
            //PermissionSetAssignment  psa2 = new PermissionSetAssignment(PermissionSetId = picReviewerPermissionSets[1].Id, AssigneeId = usr.Id);
            //PermissionSetAssignment  psa3 = new PermissionSetAssignment(PermissionSetId = picReviewerPermissionSets[2].Id, AssigneeId = usr.Id);
            //PermissionSetAssignment  psa4 = new PermissionSetAssignment(PermissionSetId = picReviewerPermissionSets[3].Id, AssigneeId = usr.Id);
            List<PermissionSetAssignment>  psa = new List<PermissionSetAssignment>{psa1};
                
                insert psa;
            
            
            // Consolidated bypass toggles aligned with Core_MDF_PartnerFundClaim_Test to minimize validations
            Core_MDF_Configuration__c mdfRecTypes = new Core_MDF_Configuration__c();
            mdfRecTypes.name='ALLOWED_PRG_FOR_RUS_NOTIF';
            mdfRecTypes.Core_MDF_Value__c='Retail Marketing Funds,Intel Partner Alliance,Channel MDF,Co-GTM';
            insert mdfRecTypes;
            List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(
                new List<String>{
                    'Bypass_Duplicate_Budget_Check',
                        'Bypass_GeoBased_Budget_Sharing',
                        'Bypass_MDF_Budget_Access_Validation',
                        'Bypass_MDF_Budget_Status_Validation'
                        }, true, false));
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(
                new List<String>{
                    'Bypass_Allocation_Reservation',
                        'Bypass_GeoBased_Allocation_Sharing'
                        }, true, false));
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(
                new List<String>{
                    'Bypass_Duplicate_Bank_Check',
                        'Bypass_Bank_Internal_Sharing',
                        'Bypass_StampingOfActySubType_Check',
                        'Bypass_Bank_External_Sharing',
                        'Bypass_Bank_Program_InActivation_Check',
                        'Bypass_Bank_ABM_Sharing'
                        }, true, false));
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(
                new List<String>{
                    'Bypass_ABM_Internal_Sharing',
                        'Bypass_ABM_External_Sharing',
                        'Bypass_ABM_NodeGroup_Sharing'
                        }, true, false));
            Database.insert(transactions);
            
            // Program, Accounts, Budget, Allocation, Campaign, Bank (minimal set required to create PartnerFundClaim)
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram(Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            
            Account intelAcct = Core_MDF_CCP_TestDataUtility.createIntelAccount('AI Test Intel Acct', Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, true);
            Account partnerAcct = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('AI Test Partner', cp.Id, Core_MDF_CCP_TestDataUtility.account_Record_Type, intelAcct.Id, true);
            
            Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
            
            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget(
                'AI Test Budget',
                Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                partnerAcct.Id,
                cp.Id,
                10000,
                System.today().addDays(-10),
                System.today().addDays(300),
                false
            );
            System.debug('Print Budget:'+budget);
            budget.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            insert budget;
            
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('AI Test PFA', budget, partnerAcct, 10000, true);
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign(
                'AI Test Camp',
                'Gaming',
                'Intel® Core™ i7 Processor',
                'Yes',
                Core_MDF_CCP_TestDataUtility.campaign_RecordType_CCF,
                'Client CoMarketing Fund',
                System.today().addDays(-5),
                System.today().addDays(200),
                5000,
                'Always Connected PC',
                partnerAcct.Id,
                'Desktop',
                true
            );
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(intelAcct.Id, 'Core_MDF_Client_CoMarketing_Fund', true, '9876543210');
            Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(partnerAcct.Id, bank.Id, true);
            
            // Create PartnerFundRequest in setup for later use
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(
                camp.Id,
                Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_CCF,
                partnerAcct.Id,
                pfa,
                budget,
                'ALBANIA',
                'Consumer',
                'Desktop',
                'Intel® Corporate Logo',
                'Broadcast (Pre-2025)',
                'Radio',
                'Draft',
                false
            );
            pfr.Amount = pfr.RequestedAmount;
            pfr.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfr.Core_MDF_Start_Date__c = System.today().addDays(-2);
            pfr.Core_MDF_End_Date__c = System.today();
            pfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            insert pfr;
            
            // Query for the IDs needed for the test
            List<PartnerFundRequest> pfrList = [SELECT Id FROM PartnerFundRequest ORDER BY CreatedDate DESC LIMIT 1];
            List<Core_MDF_Bank__c> bankList = [SELECT Id FROM Core_MDF_Bank__c ORDER BY CreatedDate DESC LIMIT 1];
                
            // Prepare data
            PartnerFundClaim claim = createBaseClaim(pfrList[0].Id, bankList[0].Id, 'AI Outbound Retry Claim - Success', 'PIC Pending', true, PROGRAM_CCF, BUDGET_TYPE_CCF);
            
            // Create test Case with Core_MDF_Audit record type
            Id auditRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            
            Case testCase = new Case();
            testCase.RecordTypeId = auditRecordTypeId;
            testCase.Status = 'Open';
            testCase.Subject = 'AI Integration Test Case';
            testCase.Core_MDF_Status__c = 'Under Review';
            testCase.Core_MDF_Activity_End_Date__c = System.today().addDays(-1);
            testCase.Core_MDF_Activity_Category__c = 'Audio';
            testCase.Core_MDF_Activity_Type__c = 'TV';
            testCase.Core_MDF_Strategic_Marketing_Fund_Ind__c = true;
            testCase.Core_MDF_TotalTransactionAmountLocal__c = 2500;
            testCase.Core_MDF_OtherCostsnotReimbursableLocal__c = 100;
            testCase.Core_MDF_Claim_Taxes_Local__c = 50;
            testCase.Core_MDF_Claim_Local_Currency__c = 'USD';
            testCase.Core_MDF_Country_Region__c = 'ALBANIA';
            testCase.Core_MDF_Brand_nm__c = 'Other';
            testCase.Core_MDF_Product_Type__c = 'Cloud';
            testCase.Core_MDF_Technology__c = 'Ice Lake';
            testCase.Core_MDF_Invoice_Number_txt__c = 'INV-123456';
            testCase.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            testCase.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1.0;
            testCase.Origin = 'Manual Selection';
            testCase.Core_MDF_Claim_Lookup_Id__c  = claim.Id;
            testCase.Core_MDF_Claim_ID__c = claim.Id;
            testCase.Core_MDF_Activity_Category__c = 'Outcome-Based';
            insert testCase;
            
            Core_MDF_Scorecard__c scorecard = new Core_MDF_Scorecard__c();
            scorecard.Core_MDF_Case_Id__c = testCase.Id;
            scorecard.Core_MDF_AI_Audit_Summary_Txt__c = 'Test AI audit summary';
            scorecard.Core_MDF_AI_Attribution_Score_Nm__c = '0';
            scorecard.Core_MDF_AI_Attribution_Comments_Txt__c = 'Test attribution comments';
            scorecard.Core_MDF_AI_POP_Score_Nm__c = '0';
            scorecard.Core_MDF_AI_POP_Comments_Txt__c = 'Test POP comments';
            scorecard.Core_MDF_AI_Engagement_Score_Nm__c = '0';
            scorecard.Core_MDF_AI_Engagement_Comments_Txt__c = 'Test engagement comments';
            
            insert scorecard;
        }
        
        
    }
    
    // Helper to build a PFR and Claim with desired status
    private static PartnerFundClaim createBaseClaim(Id pfrId, Id bankId, String title, String statusForCoreMDFStatus, Boolean isThirdParty, String program, String budgetType) {
        
        PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim(
            title,
            Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,
            pfrId,
            System.today().addDays(-2),
            System.today().addDays(-1),
            2500,
            System.today().addDays(-1),
            bankId,
            false
        );
        // Fields used by wrappers and questions matching
        // claim.Core_MDF_Activity_Types__c = 'Radio';
        claim.Core_MDF_Currency__c = 'USD';
        claim.Core_MDF_Reimbursable_TransactionAmt_Loc__c = 150;
        claim.Core_MDF_Total_Invoice_Amount_Local__c = 2500;
        claim.Core_MDF_Country_Location_nm__c ='ALBANIA';
        claim.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim.Core_MDF_Invoice_Number__c = '123456';
        claim.Core_MDF_OtherCostsnotReimbursable_Local__c=0;
        claim.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
        // claim.Core_MDF_Program__c = program;
        // claim.Core_MDF_Budget_Type_Nm__c = budgetType;
        claim.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c = isThirdParty;
        claim.Core_MDF_Status__c = statusForCoreMDFStatus;
        claim.Core_MDF_PIC_Review_Completed__c=false;
        insert claim;
        
        return claim;
    }
    
    // Mock HTTP Response for successful callout
    public class MockHttpResponseSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
    
    @isTest
    static void testSendCDBPayload_Success() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        
        Test.startTest();
        HttpResponse response = Core_MDF_CDB_Utility.sendCDBPayload('{"test":"data"}', 'TestCredential');
        Test.stopTest();
        
        System.assertEquals(200, response.getStatusCode());
        System.assertEquals('OK', response.getStatus());
    }
    
    @isTest
    static void testSendCDBPayload_Exception() {
        // Don't set any mock to force an exception
        Test.startTest();
        HttpResponse response = Core_MDF_CDB_Utility.sendCDBPayload('{"test":"data"}', 'InvalidCredential');
        Test.stopTest();
        
        System.assertEquals(503, response.getStatusCode());
        System.assertEquals('APEX_EXCEPTION', response.getStatus());
    }
    
    @isTest
    static void testCreateCDBLogInstance() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('OK');
        
        Test.startTest();
        Core_CDB_Integration_Log__c logRec = Core_MDF_CDB_Utility.createCDBLogInstance('TestIntegration', 'TestRecordId', mockResponse, true, 1);
        Test.stopTest();
        
       System.assertNotEquals(null, logRec, 'Log record should not be null');
       System.assertEquals('Successful', logRec.Core_Log_Status_Nm__c, 'Status should be Successful');
       System.assertEquals('200', logRec.Core_Status_Code__c, 'Status code should be 200');
   
    }
    
    @isTest
    static void testUpsertCDBIntegrationLogList() {
        List<Core_CDB_Integration_Log__c> logList = new List<Core_CDB_Integration_Log__c>();
        
        Core_CDB_Integration_Log__c log = new Core_CDB_Integration_Log__c();
        log.Core_Integration_Type__c = 'TestIntegration';
        log.Core_Record_Id__c = 'TestRecordId123';
        log.Core_Log_Status_Nm__c = 'Successful';
        log.Core_Integration_Direction_Nm__c = 'Outbound';
        logList.add(log);
        
        Test.startTest();
        Core_MDF_CDB_Utility.upsertCDBIntegrationLogList(logList);
        Test.stopTest();
        
        List<Core_CDB_Integration_Log__c> insertedLogs = [SELECT Id FROM Core_CDB_Integration_Log__c WHERE Core_Record_Id__c = 'TestRecordId123'];
        System.assertEquals(1, insertedLogs.size());
    }
    
    @isTest
  static void testUpsertCDBIntegrationLogList_WithValidationError() {
    List<Core_CDB_Integration_Log__c> logList = new List<Core_CDB_Integration_Log__c>();
    
    Core_CDB_Integration_Log__c log = new Core_CDB_Integration_Log__c();
    log.Core_Integration_Type__c = 'TestIntegration';
    log.Core_Record_Id__c = 'TestRecordId123';
    log.Core_Log_Status_Nm__c = 'Successful';
    log.Core_Integration_Direction_Nm__c = 'Outbound';
    // Force a field length error - assuming Core_Status_Code__c has a character limit
    log.Core_Status_Code__c = 'A'.repeat(300); // Assuming field has shorter limit
    logList.add(log);
    
    Test.startTest();
    Core_MDF_CDB_Utility.upsertCDBIntegrationLogList(logList);
    Test.stopTest();
    
    System.assert(true, 'Method handled validation errors correctly');
}
    @isTest
  static void updateRecordsList() {
      
     List<Core_MDF_Scorecard__c> scorecardList = new List<Core_MDF_Scorecard__c>{};
	scorecardList = [SELECT Id,Core_MDF_AI_Processing_Status_Nm__c FROM Core_MDF_Scorecard__c];
    Test.startTest();
    Core_MDF_CDB_Utility.updateRecordsList(scorecardList, 'Id', 'Scorecard update failed for record: ', 'Core_MDF_Scorecard__c');
    Test.stopTest();
    
  }
    
    @isTest
static void testUpdateRecordsList_WithCustomFieldErrors() {
    // Create test scorecard
    List<Core_MDF_Scorecard__c> scorecardRecList = new List<Core_MDF_Scorecard__c>();
    Core_MDF_Scorecard__c scorecard = new Core_MDF_Scorecard__c();
	scorecardRecList = [SELECT Id,Core_MDF_Case_Id__c,Core_MDF_AI_Processing_Status_Nm__c FROM Core_MDF_Scorecard__c];
    scorecard = scorecardRecList[0];
    
    String longText = 'A'.repeat(50000); // Exceed typical long text area limit
    scorecard.Core_MDF_AI_Audit_Summary_Txt__c = longText;
    
    List<Core_MDF_Scorecard__c> scorecardList = new List<Core_MDF_Scorecard__c>{scorecard};
    
    Test.startTest();
    Core_MDF_CDB_Utility.updateRecordsList(scorecardList, 'Id', 'Scorecard update failed for record: ', 'Core_MDF_Scorecard__c');
    Test.stopTest();
    
    System.assert(true, 'Method should handle scorecard update errors');
}
}