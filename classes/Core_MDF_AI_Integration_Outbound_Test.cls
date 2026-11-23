@IsTest
private class Core_MDF_AI_Integration_Outbound_Test {
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
        }
        
        // One PIC Review question active (ALL programs/budgets) so fetchQuestionRecords returns something
        List<Core_MDF_PICReviewQuestion__c> questionList = new List<Core_MDF_PICReviewQuestion__c>();
        Core_MDF_PICReviewQuestion__c q1 = new Core_MDF_PICReviewQuestion__c();
        q1.Core_MDF_All_Budget_Types_Ind__c = true;
        q1.Core_MDF_All_Programs_Ind__c = true;
        q1.Core_MDF_EffectiveDate_dt__c = Date.today().addDays(-1);
        q1.Core_MDF_IneffectiveDate_dt__c = Date.today().addDays(10);
        q1.Core_MDF_Is_Active_ind__c = true;
        q1.Core_MDF_Question_File_Type_nm__c = 'Proof of Cost';
        q1.Core_MDF_Question_English_txt__c = 'Does POC show cost?';
        q1.Core_MDF_Sort_Order__c = 1;
        questionList.add(q1);
        
        Core_MDF_PICReviewQuestion__c q2 = new Core_MDF_PICReviewQuestion__c();
        q2.Core_MDF_Channel_Program__c = PROGRAM_CCF;
        q2.Core_MDF_Budget_Type_nm__c = BUDGET_TYPE_CCF;
        q2.Core_MDF_EffectiveDate_dt__c = Date.today().addDays(-1);
        q2.Core_MDF_IneffectiveDate_dt__c = Date.today().addDays(10);
        q2.Core_MDF_Is_Active_ind__c = true;
        q2.Core_MDF_Question_File_Type_nm__c = 'Proof of Cost';
        q2.Core_MDF_Question_English_txt__c = 'Does POE show cost?';
        q2.Core_MDF_Sort_Order__c = 2;
        questionList.add(q2);
        insert questionList;
        List<Core_MDF_PICReviewQuestion__c> subQuestionList = new List<Core_MDF_PICReviewQuestion__c>();
        Core_MDF_PICReviewQuestion__c q3 = new Core_MDF_PICReviewQuestion__c();
        q3.Core_MDF_Channel_Program__c = PROGRAM_CCF;
        q3.Core_MDF_Budget_Type_nm__c = BUDGET_TYPE_CCF;
        q3.Core_MDF_EffectiveDate_dt__c = Date.today().addDays(-1);
        q3.Core_MDF_IneffectiveDate_dt__c = Date.today().addDays(10);
        q3.Core_MDF_Is_Active_ind__c = true;
        q3.Core_MDF_Parent_Question__c=q2.id;
        q3.Core_MDF_Question_File_Type_nm__c = 'Proof of Cost';
        q3.Core_MDF_Question_English_txt__c = 'Does POE show cost on document?';
        q3.Core_MDF_Sort_Order__c = 3;
        subQuestionList.add(q3);
        insert subQuestionList;
        
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
    
    @IsTest
    static void test_generateAIResponse_insert_path_picPending() {
        // Query for the IDs needed for the test
        List<PartnerFundRequest> pfrList = [SELECT Id FROM PartnerFundRequest ORDER BY CreatedDate DESC LIMIT 1];
        List<Core_MDF_Bank__c> bankList = [SELECT Id FROM Core_MDF_Bank__c ORDER BY CreatedDate DESC LIMIT 1];
        User usr = [SELECT Id,Name FROM User where Email = 'sysadmin@example.com' LIMIT 1];
        Id pfrId = pfrList[0].Id;
        Id bankId = bankList[0].Id;
        
        // Insert path: oldClaimMap == null; newClaimMap has PIC Pending
        PartnerFundClaim claim = createBaseClaim(pfrId, bankId, 'AI Outbound Insert PIC Pending', 'PIC Pending', false, PROGRAM_CCF, BUDGET_TYPE_CCF);
        
        // Add one audit document linked to claim
        Core_MDF_Audit_Document__c doc = new Core_MDF_Audit_Document__c(
            Core_MDF_Claim__c = claim.Id,
            Core_MDF_Document_Types__c = 'Proof of Cost;Proof of execution;Proof of attribution',
            Core_MDF_App_Document_Types_nm__c ='Proof of Cost;Proof of execution;Proof of attribution',
            Core_MDF_Document_Title__c = 'Test Doc',
            Core_MDF_Old_Document_Id__c = 'APP-FILE-001'
        );
        insert doc;
        
        Test.startTest();
            system.runAs(usr){
                 Map<Id, PartnerFundClaim> newMapInput = new Map<Id, PartnerFundClaim>{ claim.Id => claim };
                Core_MDF_AI_Integration_Outbound.generateAIResponseForPICProcess(newMapInput, 'insert');
                }
                Test.stopTest();
                // Validate PIC Review staged and outbound queued via makeCDBCallout
                Core_MDF_PIC_Review__c createdReview = [SELECT Id, Core_MDF_Claim_ID_id__c, Core_MDF_AI_PIC_Review_Ind__c, Core_MDF_AI_CycleNumber_nbr__c, Core_MDF_CycleNumber_nbr__c
                                                        FROM Core_MDF_PIC_Review__c
                                                        WHERE Core_MDF_Claim_ID_id__c = :claim.Id
                                                        ORDER BY CreatedDate DESC
                                                        LIMIT 1];
                System.assertEquals(true, createdReview.Core_MDF_AI_PIC_Review_Ind__c, 'AI review indicator should be true for staged review');
                System.assertNotEquals(null, createdReview.Core_MDF_AI_CycleNumber_nbr__c, 'AI cycle should be computed');
                System.assertNotEquals(null, createdReview.Core_MDF_CycleNumber_nbr__c, 'Manual cycle should be computed');
            
    }
    
    @IsTest
    static void test_generateAIResponse_update_path_transition_to_picPending() {
        // Query for the IDs needed for the test
        List<PartnerFundRequest> pfrList = [SELECT Id FROM PartnerFundRequest ORDER BY CreatedDate DESC LIMIT 1];
        List<Core_MDF_Bank__c> bankList = [SELECT Id FROM Core_MDF_Bank__c ORDER BY CreatedDate DESC LIMIT 1];
        
        Id pfrId = pfrList[0].Id;
        Id bankId = bankList[0].Id;
        
        // Create two claims to exercise bulkified logic and both PIC history branches
        // Claim A: last review is MANUAL (expect next manual = prev+1, AI next = 1)
        PartnerFundClaim claimManual = createBaseClaim(pfrId, bankId, 'AI Outbound Update PIC Pending - ManualPrev', 'Submitted', false, PROGRAM_CCF, BUDGET_TYPE_CCF);
        Core_MDF_PIC_Review__c manualPrev = new Core_MDF_PIC_Review__c(
            Core_MDF_Claim_ID_id__c = claimManual.Id,
            Core_MDF_CycleNumber_nbr__c = 2,
            Core_MDF_AI_PIC_Review_Ind__c = false
        );
        insert manualPrev;
        
        // Claim B: last review is AI (expect manual stays as-is, AI next = prevAI+1)
        PartnerFundClaim claimAI =  createBaseClaim(pfrId, bankId, 'AI Outbound Update PIC Pending - ManualPrev', 'Submitted', false, PROGRAM_CCF, BUDGET_TYPE_CCF);
        Core_MDF_PIC_Review__c aiPrev = new Core_MDF_PIC_Review__c(
            Core_MDF_Claim_ID_id__c = claimAI.Id,
            Core_MDF_CycleNumber_nbr__c = 5,
            Core_MDF_AI_CycleNumber_nbr__c = 3,
            Core_MDF_AI_PIC_Review_Ind__c = true
        );
        insert aiPrev;
        
        // Transition both claims to PIC Pending
        claimManual.Core_MDF_Status__c = 'PIC Pending';
        claimAI.Core_MDF_Status__c = 'PIC Pending';
        update new List<PartnerFundClaim>{ claimManual, claimAI };
            
            // Build old/new maps for both claims
            Map<Id, PartnerFundClaim> oldMapInput = new Map<Id, PartnerFundClaim>{
                claimManual.Id => claimManual.clone(false,false,false,false),
                    claimAI.Id => claimAI.clone(false,false,false,false)
                    };
                        oldMapInput.get(claimManual.Id).Core_MDF_Status__c = 'Submitted';
        oldMapInput.get(claimAI.Id).Core_MDF_Status__c = 'Submitted';
        
        Map<Id, PartnerFundClaim> newMapInput = new Map<Id, PartnerFundClaim>{
            claimManual.Id => claimManual,
                claimAI.Id => claimAI
                };
                    
                    Test.startTest();
        Core_MDF_AI_Integration_Outbound.generateAIResponseForPICProcess(newMapInput, 'update');
        Test.stopTest();
        
        // Fetch the latest staged AI reviews for both claims
        Core_MDF_PIC_Review__c createdManualBased = [
            SELECT Id, Core_MDF_CycleNumber_nbr__c, Core_MDF_AI_CycleNumber_nbr__c, Core_MDF_AI_PIC_Review_Ind__c
            FROM Core_MDF_PIC_Review__c
            WHERE Core_MDF_Claim_ID_id__c = :claimManual.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(true, createdManualBased.Core_MDF_AI_PIC_Review_Ind__c, 'Staged review should be AI (manual-prev branch)');
        System.assertEquals(3, (Integer)createdManualBased.Core_MDF_CycleNumber_nbr__c, 'Manual next = prev(2)+1 for manual-prev branch');
        System.assertEquals(1, (Integer)createdManualBased.Core_MDF_AI_CycleNumber_nbr__c, 'AI next = 1 for first AI review after manual-prev');
        
        Core_MDF_PIC_Review__c createdAIBased = [
            SELECT Id, Core_MDF_CycleNumber_nbr__c, Core_MDF_AI_CycleNumber_nbr__c, Core_MDF_AI_PIC_Review_Ind__c
            FROM Core_MDF_PIC_Review__c
            WHERE Core_MDF_Claim_ID_id__c = :claimAI.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(true, createdAIBased.Core_MDF_AI_PIC_Review_Ind__c, 'Staged review should be AI (AI-prev branch)');
        //System.assertEquals(4, (Integer)createdAIBased.Core_MDF_AI_CycleNumber_nbr__c, 'AI next = prevAI(3)+1 = 4 for AI-prev branch');
    }
    
    @IsTest
    static void test_fetchClaimDocAndPICReviewDetails_retry_success_logs() {
        // Query for the IDs needed for the test
        List<PartnerFundRequest> pfrList = [SELECT Id FROM PartnerFundRequest ORDER BY CreatedDate DESC LIMIT 1];
        List<Core_MDF_Bank__c> bankList = [SELECT Id FROM Core_MDF_Bank__c ORDER BY CreatedDate DESC LIMIT 1];
        
        Id pfrId = pfrList[0].Id;
        Id bankId = bankList[0].Id;
        
        // Prepare data
        PartnerFundClaim claim = createBaseClaim(pfrId, bankId, 'AI Outbound Retry Claim - Success', 'PIC Pending', true, PROGRAM_CCF, BUDGET_TYPE_CCF);
        Core_MDF_PIC_Review__c priorAI = new Core_MDF_PIC_Review__c(
            Core_MDF_Claim_ID_id__c = claim.Id,
            Core_MDF_CycleNumber_nbr__c = 1,
            Core_MDF_AI_CycleNumber_nbr__c = 1,
            Core_MDF_AI_PIC_Review_Ind__c = true,
            Core_MDF_External_Id__c =  String.valueOf(claim.Id)+'1'
        );
        insert priorAI;
        String compositeKey = String.valueOf(claim.Id) + '-' + String.valueOf(priorAI.Id);
        Core_CDB_Integration_Log__c prevLog = new Core_CDB_Integration_Log__c(
            Core_Integration_Type__c = 'MDF AI PIC Review',
            Core_Record_Id__c = compositeKey,
            Core_Log_Status_Nm__c = 'Failed',
            Core_Integration_Direction_Nm__c = 'Outbound',
            Core_Retry_Number_Nbr__c = 2
        );
        insert prevLog;
        
        Map<Id, Map<Id, Core_CDB_Integration_Log__c>> claimIdToPicReviewIdToFinalCDBLog = new Map<Id, Map<Id, Core_CDB_Integration_Log__c>>{
            claim.Id => new Map<Id, Core_CDB_Integration_Log__c>{ priorAI.Id => prevLog }
        };
            Map <Id,Core_MDF_PIC_Review__c> picReviewMap1=new Map <Id,Core_MDF_PIC_Review__c> {priorAI.id => priorAI};
            Map<Id, PartnerFundClaim> claimMap = new Map<Id, PartnerFundClaim>{ claim.Id => claim };
                
                Map<String, String> compToJson = new Map<String, String>{
                    compositeKey => '{"sample":"payload1"}'
                        };
                            Map<String, Integer> prevRetry = new Map<String, Integer>{
                                compositeKey => 2
                                    };
                                        
                                        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessHttpMock());
        // Drive fetch path (builds JSON internally) and then explicitly call future once
        Core_MDF_AI_Integration_Outbound.fetchClaimDocAndPICReviewDetails(claimMap, claimIdToPicReviewIdToFinalCDBLog,picReviewMap1);
        Core_MDF_AI_Integration_Outbound.makeCDBCallout(compToJson, prevRetry);
        Test.stopTest();
        
        List<Core_CDB_Integration_Log__c> logs = [
            SELECT Id, Core_Record_Id__c, Core_Log_Status_Nm__c, Core_Retry_Number_Nbr__c, Core_Status_Code__c, Core_Status_Message__c,Core_Integration_Direction_Nm__c
            FROM Core_CDB_Integration_Log__c
            WHERE Core_Record_Id__c = :compositeKey
            ORDER BY CreatedDate DESC
        ];
        System.assert(!logs.isEmpty(), 'CDB logs should have been upserted');
        Boolean hasSuccess = false;
        for (Core_CDB_Integration_Log__c l : logs) {
            if (l.Core_Log_Status_Nm__c == 'Successful') hasSuccess = true;
            System.assertNotEquals(null, l.Core_Retry_Number_Nbr__c, 'Retry number must be populated');
            System.assertNotEquals(null, l.Core_Status_Message__c, 'Status message should be set');
        }
        System.assertEquals(true, hasSuccess, 'At least one success expected');
    }
    
    @IsTest
    static void test_fetchClaimDocAndPICReviewDetails_retry_failure_logs() {
        // Query for the IDs needed for the test
        List<PartnerFundRequest> pfrList = [SELECT Id FROM PartnerFundRequest ORDER BY CreatedDate DESC LIMIT 1];
        List<Core_MDF_Bank__c> bankList = [SELECT Id FROM Core_MDF_Bank__c ORDER BY CreatedDate DESC LIMIT 1];
        
        Id pfrId = pfrList[0].Id;
        Id bankId = bankList[0].Id;
        
        // Prepare data
        PartnerFundClaim claim = createBaseClaim(pfrId, bankId, 'AI Outbound Retry Claim - Failure', 'PIC Pending', true, PROGRAM_CCF, BUDGET_TYPE_CCF);
        Core_MDF_PIC_Review__c priorAI = new Core_MDF_PIC_Review__c(
            Core_MDF_Claim_ID_id__c = claim.Id,
            Core_MDF_CycleNumber_nbr__c = 1,
            Core_MDF_AI_CycleNumber_nbr__c = 1,
            Core_MDF_AI_PIC_Review_Ind__c = true,
            Core_MDF_External_Id__c =  String.valueOf(claim.Id)+'1'
        );
        insert priorAI;
        String compositeKey = String.valueOf(claim.Id) + '-' + String.valueOf(priorAI.Id);
        Core_CDB_Integration_Log__c prevLog = new Core_CDB_Integration_Log__c(
            Core_Integration_Type__c = 'MDF AI PIC Review',
            Core_Record_Id__c = compositeKey,
            Core_Log_Status_Nm__c = 'Failed',
            Core_Integration_Direction_Nm__c = 'Outbound',
            Core_Retry_Number_Nbr__c = 2
        );
        insert prevLog;
        
        Map<Id, Map<Id, Core_CDB_Integration_Log__c>> claimIdToPicReviewIdToFinalCDBLog = new Map<Id, Map<Id, Core_CDB_Integration_Log__c>>{
            claim.Id => new Map<Id, Core_CDB_Integration_Log__c>{ priorAI.Id => prevLog }
        };
        Map<Id, PartnerFundClaim> claimMap = new Map<Id, PartnerFundClaim>{ claim.Id => claim };
        
        // Build payload map and prevRetry map so makeCDBCallout computes newRetryCounter = 3
        Map<String, String> compToJson = new Map<String, String>{
            compositeKey => '{"sample":"payload2"}'
        };
        Map<String, Integer> prevRetry = new Map<String, Integer>{
            compositeKey => 2
        };
            Map<Id,Core_MDF_PIC_Review__c> picReviewMap = new  Map<Id,Core_MDF_PIC_Review__c>{priorAI.Id => priorAI};
        
        Test.startTest();
        // Force callout failure so isSuccess = false
        Test.setMock(HttpCalloutMock.class, new FailureHttpMock());
        Core_MDF_AI_Integration_Outbound.fetchClaimDocAndPICReviewDetails(claimMap, claimIdToPicReviewIdToFinalCDBLog,picReviewMap);
        Core_MDF_AI_Integration_Outbound.makeCDBCallout(compToJson, prevRetry);
        Test.stopTest();
        
        List<Core_CDB_Integration_Log__c> logs = [
            SELECT Id, Core_Record_Id__c, Core_Log_Status_Nm__c, Core_Retry_Number_Nbr__c, Core_Status_Code__c, Core_Status_Message__c,Core_Integration_Direction_Nm__c
            FROM Core_CDB_Integration_Log__c
            WHERE Core_Record_Id__c = :compositeKey
            ORDER BY CreatedDate DESC
        ];
        System.assert(!logs.isEmpty(), 'CDB logs should have been upserted');
        Boolean hasFailed = false;
        Boolean hasRetry3 = false;
        for (Core_CDB_Integration_Log__c l : logs) {
            if (l.Core_Log_Status_Nm__c == 'Failed') hasFailed = true;
            if (l.Core_Retry_Number_Nbr__c == 3) hasRetry3 = true; // ensure we exercised newRetryCounter == 3
            System.assertNotEquals(null, l.Core_Retry_Number_Nbr__c, 'Retry number must be populated');
            System.assertNotEquals(null, l.Core_Status_Message__c, 'Status message should be set');
        }
        System.assertEquals(true, hasFailed, 'At least one failure expected');
        System.assertEquals(true, hasRetry3, 'Expected a failure log at retry number 3 to cover the compositeKey branch');
    }
    
    @IsTest
    static void test_sendCDBPayload_success() {
        // sendCDBPayload performs a real HTTP callout (endpoint 'callout:CDBIntegration'),
        // so we must wrap it with startTest/stopTest to ensure the platform executes the callout in test context.
        Test.setMock(HttpCalloutMock.class, new SuccessHttpMock());
        Test.startTest();
        HttpResponse ok = Core_MDF_AI_Integration_Outbound.sendCDBPayload('{"k":"v"}');
        Test.stopTest();
        System.assertNotEquals(null, ok, 'Expected non-null response on 200/OK');
        System.assertEquals(200, ok.getStatusCode());
        System.assertEquals('OK', ok.getStatus());
    }
    
    @IsTest
    static void test_sendCDBPayload_failure() {
        Test.setMock(HttpCalloutMock.class, new FailureHttpMock());
        Test.startTest();
        HttpResponse notOk = Core_MDF_AI_Integration_Outbound.sendCDBPayload('{"k":"v"}');
        Test.stopTest();
        System.assertNotEquals(null, notOk, 'Even on failure, response is returned and handled by caller');
        System.assertEquals(500, notOk.getStatusCode());
        System.assertEquals('ERROR', notOk.getStatus());
    }
    
    @IsTest
    static void test_fetchQuestionRecords_branches_and_empty_inputs() {
        // Empty/Null input branch (synchronous, no DML and no start/stop needed)
        Map<Id, List<Core_MDF_AI_Integration_Outbound.QuestionsWrapper>> emptyMap =
            Core_MDF_AI_Integration_Outbound.fetchQuestionRecords(new List<PartnerFundClaim>());
        System.assertEquals(0, emptyMap.size(), 'Empty input should return empty map');
        
        
        String non3rdJson = '{"attributes":{"type":"PartnerFundClaim"},"Id":"a0Z000000000001AAA","Core_MDF_Program__c":"'+PROGRAM_CCF+'","Core_MDF_Budget_Type_Nm__c":"'+BUDGET_TYPE_CCF+'","Core_MDF_3rd_Party_POP_Doc_Required_Ind__c":false}';
        String thirdJson  = '{"attributes":{"type":"PartnerFundClaim"},"Id":"a0Z0000000000002AAA","Core_MDF_Program__c":"'+PROGRAM_CCF+'","Core_MDF_Budget_Type_Nm__c":"'+BUDGET_TYPE_CCF+'","Core_MDF_3rd_Party_POP_Doc_Required_Ind__c":true}';
        PartnerFundClaim non3rd = (PartnerFundClaim)JSON.deserialize(non3rdJson, PartnerFundClaim.class);
        PartnerFundClaim thirdParty = (PartnerFundClaim)JSON.deserialize(thirdJson, PartnerFundClaim.class);
        
        // Invoke the method under test without performing any DML to keep SOQL usage minimal
        Map<Id, List<Core_MDF_AI_Integration_Outbound.QuestionsWrapper>> qMap =
            Core_MDF_AI_Integration_Outbound.fetchQuestionRecords(new List<PartnerFundClaim>{ non3rd, thirdParty });
        
        System.assert(qMap.containsKey(non3rd.Id), 'Non-3rd party claim should have questions');
        System.assert(qMap.containsKey(thirdParty.Id), '3rd party claim should have questions');
    }
    
    
    @IsTest
    static void test_fetchCDBLogRecordsForRetry_end_to_end_flow() {
        // Query for the IDs needed for the test
        List<PartnerFundRequest> pfrList = [SELECT Id FROM PartnerFundRequest ORDER BY CreatedDate DESC LIMIT 1];
        List<Core_MDF_Bank__c> bankList = [SELECT Id FROM Core_MDF_Bank__c ORDER BY CreatedDate DESC LIMIT 1];
        
        Id pfrId = pfrList[0].Id;
        Id bankId = bankList[0].Id;
        
        
        
        
        
        // Create second claim with both manual and AI PIC reviews (only AI review should have CDB log)
        PartnerFundClaim claim2 = createBaseClaim(pfrId, bankId, 'Retry Invocable Claim 2', 'PIC Pending', false, PROGRAM_CCF, BUDGET_TYPE_CCF);
        claim2.Core_MDF_Status__c = 'PIC Pending';
        update claim2;
        // Create manual PIC review first
        Core_MDF_PIC_Review__c manualReview2 = new Core_MDF_PIC_Review__c(
            Core_MDF_Claim_ID_id__c = claim2.Id,
            Core_MDF_CycleNumber_nbr__c = 1,
            Core_MDF_AI_PIC_Review_Ind__c = false
        );
        insert manualReview2;
        
        // Create AI PIC review second (this should be the latest review)
        Core_MDF_PIC_Review__c aiReview2 = new Core_MDF_PIC_Review__c(
            Core_MDF_Claim_ID_id__c = claim2.Id,
            Core_MDF_CycleNumber_nbr__c = 2,
            Core_MDF_AI_CycleNumber_nbr__c = 1,
            Core_MDF_AI_PIC_Review_Ind__c = true
        );
        insert aiReview2;
        
        // Only create CDB log for the AI review (which is the latest)
        Core_CDB_Integration_Log__c cdb2 = new Core_CDB_Integration_Log__c(
            Core_Integration_Type__c = 'MDF AI PIC Review',
            Core_Record_Id__c = String.valueOf(claim2.Id) + '-' + String.valueOf(aiReview2.Id),
            Core_Log_Status_Nm__c = 'Failed',
            Core_Retry_Number_Nbr__c = 1
        );
        insert cdb2;
        
        // Create third claim with both reviews, but make the manual review the latest
        PartnerFundClaim claim3 = createBaseClaim(pfrId, bankId, 'Retry Invocable Claim 3', 'PIC Pending', false, PROGRAM_CCF, BUDGET_TYPE_CCF);
        claim3.Core_MDF_Status__c = 'PIC Pending';
        update claim3;
        // Create AI PIC review first
        Core_MDF_PIC_Review__c aiReview3 = new Core_MDF_PIC_Review__c(
            Core_MDF_Claim_ID_id__c = claim3.Id,
            Core_MDF_CycleNumber_nbr__c = 1,
            Core_MDF_AI_CycleNumber_nbr__c = 1,
            Core_MDF_AI_PIC_Review_Ind__c = true
        );
        insert aiReview3;
        
        // Create manual PIC review second (this should be the latest review)
        Core_MDF_PIC_Review__c manualReview3 = new Core_MDF_PIC_Review__c(
            Core_MDF_Claim_ID_id__c = claim3.Id,
            Core_MDF_CycleNumber_nbr__c = 2,
            Core_MDF_AI_PIC_Review_Ind__c = false
        );
        insert manualReview3;
        
        // Only create CDB log for the AI review (which is the first one)
        Core_CDB_Integration_Log__c cdb3 = new Core_CDB_Integration_Log__c(
            Core_Integration_Type__c = 'MDF AI PIC Review',
            Core_Record_Id__c = String.valueOf(claim3.Id) + '-' + String.valueOf(aiReview3.Id),
            Core_Log_Status_Nm__c = 'Failed',
            Core_Retry_Number_Nbr__c = 1
        );
        insert cdb3;
        
        // Drive retry fetch with plain list signature
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessHttpMock());
        Core_MDF_AI_Integration_Outbound.fetchCDBLogRecordsForRetry(new List<Core_CDB_Integration_Log__c>{ cdb2, cdb3 });
        Test.stopTest();
        
        // Verify that all records were processed correctly by querying all records once and putting them in a map
        List<Core_CDB_Integration_Log__c> allCDBLogs = [
            SELECT Id, Core_Record_Id__c, Core_Log_Status_Nm__c, Core_Retry_Number_Nbr__c, Core_Status_Code__c, Core_Status_Message__c,Core_Integration_Direction_Nm__c
            FROM Core_CDB_Integration_Log__c
            WHERE Core_Record_Id__c IN (:cdb2.Core_Record_Id__c, :cdb3.Core_Record_Id__c)
            ORDER BY CreatedDate DESC
        ];
        
        // Create a map for efficient lookup
        Map<String, Core_CDB_Integration_Log__c> cdbLogMap = new Map<String, Core_CDB_Integration_Log__c>();
        for (Core_CDB_Integration_Log__c log : allCDBLogs) {
            cdbLogMap.put(log.Core_Record_Id__c, log);
        }
        
        
        
        // Check second claim (AI review - should be processed)
        Core_CDB_Integration_Log__c latest2 = cdbLogMap.get(cdb2.Core_Record_Id__c);
        System.assertNotEquals(null, latest2, 'CDB log should exist for second claim');
        System.assertNotEquals(null, latest2.Core_Retry_Number_Nbr__c, 'Retry count should be set on retried call for second claim');
        System.assertNotEquals(null, latest2.Core_Log_Status_Nm__c, 'Log status should be populated for second claim');
        
        // Check third claim (AI review - should be processed)
        Core_CDB_Integration_Log__c latest3 = cdbLogMap.get(cdb3.Core_Record_Id__c);
        System.assertNotEquals(null, latest3, 'CDB log should exist for third claim');
        System.assertNotEquals(null, latest3.Core_Retry_Number_Nbr__c, 'Retry count should be set on retried call for third claim');
        System.assertNotEquals(null, latest3.Core_Log_Status_Nm__c, 'Log status should be populated for third claim');
    }
    
    @IsTest
    static void test_collectAndLogDbErrors() {
        // Test case 1: Empty maps (should not throw any exception)
        Core_MDF_AI_Integration_Outbound.collectAndLogDbErrors(
            null,
            null,
            'PIC_Review__c'
        );
        
        Core_MDF_AI_Integration_Outbound.collectAndLogDbErrors(
            new Map<String, List<Database.Error>>(),
            new Map<String, String>(),
            'PIC_Review__c'
        );
        
        // Test case 2: Valid error scenario with insert operation
        // Prepare invalid records
        Core_MDF_PIC_Review__c invalidPic = new Core_MDF_PIC_Review__c(
            Core_MDF_AI_PIC_Review_Ind__c = true,
            Core_MDF_CycleNumber_nbr__c  = 782827
            // Omit required fields to force validation error
        );
        List<Core_MDF_PIC_Review__c> toInsert = new List<Core_MDF_PIC_Review__c>{ invalidPic };
            
            Core_CDB_Integration_Log__c invalidCdbLog = new Core_CDB_Integration_Log__c(
                Core_Record_Id__c = 'claim456-789',
                Core_Log_Status_Nm__c = 'Error'
            );
        List<Core_CDB_Integration_Log__c> toUpsert = new List<Core_CDB_Integration_Log__c>{ invalidCdbLog };
            
            Database.SaveResult[] picResults;
        Database.UpsertResult[] upsertResults;
        
        Test.startTest();
        // Execute both DMLs within the same start/stop context
        picResults = Database.insert(toInsert, false);
        upsertResults = Database.upsert(toUpsert, Core_CDB_Integration_Log__c.Core_Record_Id__c, false);
        Test.stopTest();
        
        // Build error maps AFTER stopTest and then invoke collectAndLogDbErrors
        Map<String, List<Database.Error>> claimIdToInsertErrors = new Map<String, List<Database.Error>>();
        Map<String, String> claimIdToBaseMessage = new Map<String, String>();
        for (Integer i = 0; i < picResults.size(); i++) {
            if (!picResults[i].isSuccess()) {
                String recKey = String.valueOf(i);
                claimIdToInsertErrors.put(recKey, new List<Database.Error>(picResults[i].getErrors()));
                claimIdToBaseMessage.put(recKey, 'PIC Review insert failed for Claim: ' + recKey);
            }
        }
        Core_MDF_AI_Integration_Outbound.collectAndLogDbErrors(
            claimIdToInsertErrors,
            claimIdToBaseMessage,
            'PIC_Review__c'
        );
        
        Map<String, List<Database.Error>> compKeyToUpsertErrors = new Map<String, List<Database.Error>>();
        Map<String, String> compKeyToBaseMessage = new Map<String, String>();
        for (Integer i = 0; i < upsertResults.size(); i++) {
            if (!upsertResults[i].isSuccess()) {
                String compKey = toUpsert[i].Core_Record_Id__c;
                compKeyToUpsertErrors.put(compKey, new List<Database.Error>(upsertResults[i].getErrors()));
                compKeyToBaseMessage.put(compKey, 'CDB Integration Log upsert failed for record: ' + compKey);
            }
        }
        Core_MDF_AI_Integration_Outbound.collectAndLogDbErrors(
            compKeyToUpsertErrors,
            compKeyToBaseMessage,
            'Core_CDB_Integration_Log__c'
        );
        
        // Assertions after logs are created
        List<Core_Log_Entry__c> insertLogEntries = [
            SELECT Id, Core_Message__c, Core_sObjectType__c, Core_Details__c
            FROM Core_Log_Entry__c
            WHERE Core_sObjectType__c = 'PIC_Review__c'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assert(!insertLogEntries.isEmpty(), 'Expected a log entry to be created for PIC Review insert errors');
        
        List<Core_Log_Entry__c> upsertLogEntries = [
            SELECT Id, Core_Message__c, Core_sObjectType__c, Core_Details__c
            FROM Core_Log_Entry__c
            WHERE Core_sObjectType__c = 'Core_CDB_Integration_Log__c'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assert(!upsertLogEntries.isEmpty(), 'Expected a log entry to be created for CDB Log upsert errors');
    }
}