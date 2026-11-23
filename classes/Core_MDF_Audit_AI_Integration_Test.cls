/****************************************************************************************************************************************************
 * Class Name      : Core_MDF_Audit_AI_Integration_Test
 * Version               : 1.0
 * Created Date          :  02-19-2026 
 * Modification Log      : 
 * Developer            Date             Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------
 * Shubhra/Sinduja     01-19-2026        Test class for Core_MDF_Audit_AI_Integration
 ******************************************************************************************************************************************************/
@isTest
public class Core_MDF_Audit_AI_Integration_Test {
    // Constants for program and budget type to avoid string literals
    private static final String PROGRAM_CCF = 'Client CoMarketing Fund';
    private static final String BUDGET_TYPE_CCF = 'OEM CMP';
    
       
    // Simple HTTP mock to control sendCDBPayload() outcome
    private class SuccessHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"result":"ok"}');
            return res;
        }
    }
    private class FailureHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setStatus('ERROR');
            res.setBody('{"result":"error"}');
            return res;
        }
    }
    
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
            
            List<PermissionSet> claimCaseReviewerPermissionSets = [SELECT Id, Name FROM PermissionSet where Name IN ('Core_MDF_CCP_Internal_Claim_Case_Reviewer')];
            PermissionSetAssignment  psa1 = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSets[0].Id, AssigneeId = usr.Id);
            List<PermissionSetAssignment>  psa = new List<PermissionSetAssignment>{psa1};
            insert psa;
            
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
             
            // Create program and accounts
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram(Core_MDF_CCP_ConstantClass.CCF_PROGRAM, PROGRAM_CCF, true);
            
            Account intelAcct = Core_MDF_CCP_TestDataUtility.createIntelAccount('AI Test Intel Acct', Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, true);
            Account partnerAcct = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('AI Test Partner', cp.Id, Core_MDF_CCP_TestDataUtility.account_Record_Type, intelAcct.Id, true);
            
            Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
            
            // Create budget
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
            budget.Core_MDF_Budget_Type_Txt__c = BUDGET_TYPE_CCF;
            insert budget;
            
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('AI Test PFA', budget, partnerAcct, 10000, true);
            
            // Create campaign
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign(
                'AI Test Camp',
                'Outcome-Based',
                'Intel® Core™ i7 Processor',
                'Yes',
                Core_MDF_CCP_TestDataUtility.campaign_RecordType_CCF,
                PROGRAM_CCF,
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
            
            // Create PartnerFundRequest
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
                'Audio',
                'Radio',
                'Draft',
                false
            );
            pfr.Amount = pfr.RequestedAmount;
            pfr.Core_MDF_Budget_Type_nm__c = BUDGET_TYPE_CCF;
            pfr.Core_MDF_Start_Date__c = System.today().addDays(-2);
            pfr.Core_MDF_End_Date__c = System.today();
            pfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            pfr.Core_MDF_Activity_Types__c = 'Outcome-Based';
            pfr.Core_MDF_ActivityCategory__c = 'Outcome-Based';
            insert pfr;
            
           	
             
            // Create PartnerFundClaim
            PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim(
                'AI Integration Test Claim',
                Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,
                pfr.Id,
                System.today().addDays(-2),
                System.today().addDays(-1),
                2500,
                System.today().addDays(-1),
                bank.Id,
                false
            );
            claim.Core_MDF_Currency__c = 'USD';
            claim.Core_MDF_Reimbursable_TransactionAmt_Loc__c = 150;
            claim.Core_MDF_Total_Invoice_Amount_Local__c = 2500;
            claim.Core_MDF_Country_Location_nm__c = 'ALBANIA';
            claim.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            claim.Core_MDF_Invoice_Number__c = '123456';
            claim.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            claim.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c = false;
            claim.Core_MDF_Status__c = 'Hold';
            insert claim;
            
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
            testCase.Core_MDF_Channel_Program_txt__c = PROGRAM_CCF;
            testCase.Core_MDF_Budget_Type_nm__c = BUDGET_TYPE_CCF;
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
            
            // Create Core_MDF_Scorecard__c
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
            
            // Link PartnerFundClaim to Case
            claim.Core_MDF_Claim_Review_Case__c = testCase.Id;
            update claim;
            
            // Create Core_MDF_Claim_Case_Checklist__c records
            List<Core_MDF_Claim_Case_Checklist__c> checklists = new List<Core_MDF_Claim_Case_Checklist__c>();
            for (Integer i = 1; i <= 3; i++) {
                Core_MDF_Claim_Case_Checklist__c checklist = new Core_MDF_Claim_Case_Checklist__c();
                checklist.Core_MDF_Case_ID__c = testCase.Id;
                checklist.Core_MDF_Case_Review_Findings__c = 'Test finding ' + i;
                checklist.Core_MDF_Checklist_Category__c = 'POP';
                checklist.Core_MDF_Checklist_Description__c = 'Description ' + i;
                checklist.Core_MDF_Checklist_Item__c = 'Item ' + i;
                checklist.Core_MDF_Claim_Case_Review_Findings__c = 'Activity date mismatch';
                checklists.add(checklist);
            }
            insert checklists;
            
            // Create Core_MDF_Audit_Document__c records
            // Add one audit document linked to claim
            Core_MDF_Audit_Document__c doc = new Core_MDF_Audit_Document__c(
                Core_MDF_Claim__c = claim.Id,
                Core_MDF_Document_Types__c = 'Proof of Cost;Proof of execution;Proof of attribution',
                Core_MDF_App_Document_Types_nm__c ='Proof of Cost;Proof of execution;Proof of attribution',
                Core_MDF_Document_Title__c = 'Test Doc',
                Core_MDF_Audit__c = testCase.Id
            );
            insert doc;
                 
             }
        
        
    }
     @isTest
    static void testBatchExecuteSuccess() {
        // Add debugging to check if records exist
        List<Case> testCases = [SELECT Id, RecordType.DeveloperName, Core_MDF_Status__c, Status,Core_MDF_Activity_Category__c
                               FROM Case 
                               WHERE RecordType.DeveloperName = 'Core_MDF_Audit' 
                               AND Core_MDF_Status__c = 'Under Review' 
                               AND Status = 'Open'];
        Set<Id> caseIdSet = new Set<Id>();
        
        System.debug('Test Case found: ' + testCases.size());
        for(Case caseRec : testCases) {
            System.debug('Test Case: ' + caseRec.Id + ', Activity Category: ' + caseRec.Core_MDF_Activity_Category__c);
            caseIdSet.add(caseRec.Id);
        }
        
        Test.startTest();
        
        // Mock successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'SUCCESS', '{"status":"success"}'));
        
        Core_MDF_Audit_AI_Integration batch = new Core_MDF_Audit_AI_Integration(caseIdSet);
        Database.executeBatch(batch, 1);
        
        Test.stopTest();
        
        // Verify CDB Integration Log was created
        List<Core_CDB_Integration_Log__c> logs = [SELECT Id, Core_Log_Status_Nm__c FROM Core_CDB_Integration_Log__c];
        System.assertEquals(1, logs.size());
    }
    
    @isTest
    static void testBatchExecuteFailure() {
        Test.startTest();
        
        // Mock failed HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'FAILED', '{"error":"Internal Server Error"}'));
        Set<Id> caseIdSet = new Set<Id>();
        List<Case> caseList = [SELECT Id FROM Case];
        for(Case caseRec: caseList){
            caseIdSet.add(caseRec.Id);
        }
        Core_MDF_Audit_AI_Integration batch = new Core_MDF_Audit_AI_Integration(caseIdSet);
        Database.executeBatch(batch, 5);
        
        Test.stopTest();
        
        // Verify CDB Integration Log was created with failed status
        List<Core_CDB_Integration_Log__c> logs = [SELECT Id, Core_Log_Status_Nm__c FROM Core_CDB_Integration_Log__c];
        System.assertEquals(1, logs.size());
        System.assertEquals('Failed', logs[0].Core_Log_Status_Nm__c);
    }
    
	@isTest
    public static void testDatabaseErrorHandlingAndRetryLogic() {
        // Get test case
        List<Case> testCases = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Core_MDF_Audit' LIMIT 1];
        Set<Id> caseIdSet = new Set<Id>();
        for(Case c : testCases) {
            caseIdSet.add(c.Id);
        }
        
        // Create existing failed log entries to simulate 2nd retry (so next will be 3rd)
        List<Core_CDB_Integration_Log__c> existingLogs = new List<Core_CDB_Integration_Log__c>();
        for(Id caseId : caseIdSet) {
            for(Integer i = 1; i <= 2; i++) {
                Core_CDB_Integration_Log__c log = new Core_CDB_Integration_Log__c();
                log.Core_Record_Id__c = String.valueOf(caseId);
                log.Core_Integration_Type__c = 'MDF AI Audit';
                log.Core_Log_Status_Nm__c = 'Failed';
                log.Core_Retry_Number_Nbr__c = i;
                log.Core_Status_Code__c = '500';
                log.Core_Status_Message__c = 'Failed';
                log.Core_Integration_Direction_Nm__c = 'Outbound';
                existingLogs.add(log);
            }
        }
        insert existingLogs;
        
        Test.startTest();
        
        // Mock failed HTTP response for 3rd retry (this will trigger scorecard update)
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'FAILED', '{"error":"Server Error"}'));
        
        // Execute batch 
       Core_MDF_Batch_RetryAICDBOutbound batchClass = new Core_MDF_Batch_RetryAICDBOutbound('MDF AI Audit');
       Database.executeBatch(batchClass, 5);
       
        
        Test.stopTest();
        
        // Verify scorecard was updated 
        List<Core_MDF_Scorecard__c> updatedScorecards = [SELECT Id, Core_MDF_AI_Processing_Status_Nm__c FROM Core_MDF_Scorecard__c WHERE Core_MDF_Case_Id__c IN :caseIdSet];
        
        // Verify CDB Integration Log was created for 3rd retry
        List<Core_CDB_Integration_Log__c> logs = [SELECT Id, Core_Log_Status_Nm__c, Core_Retry_Number_Nbr__c FROM Core_CDB_Integration_Log__c 
            WHERE Core_Record_Id__c IN :caseIdSet AND Core_Integration_Type__c = 'MDF AI Audit' ORDER BY Core_Retry_Number_Nbr__c DESC
        ];
        system.debug('TEST CLASS LOGS:'+logs);
        System.assertEquals('AI Processing Failed', updatedScorecards[0].Core_MDF_AI_Processing_Status_Nm__c,'Scorecard should be updated to AI Processing Failed after 3rd retry failure');

     }
    // Mock HTTP Response Generator for successful responses
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String status;
        private String body;
        
        public MockHttpResponseGenerator(Integer statusCode, String status, String body) {
            this.statusCode = statusCode;
            this.status = status;
            this.body = body;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setStatus(this.status);
            res.setBody(this.body);
            return res;
        }
    }
    
    // Mock HTTP Exception Generator
    public class MockHttpExceptionGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            throw new CalloutException('Mock callout exception');
        }
    }

}