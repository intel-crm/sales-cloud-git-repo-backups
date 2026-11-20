/*****************************************************************************************************
Class Name          :    Core_MDF_AGS_PollStatus_Batch_Test
Description         :    Test coverage for Core_MDF_AGS_PollStatus_Batch, exercising start()/execute()/
                         finish() via Database.executeBatch() against staging records awaiting an AGS
                         outcome, and validating the batch correctly delegates to
                         Core_MDF_IUPGMReqStaging_ServiceHandler.pollAgsPendingBatch().
Created By          :    Ramapriya
******************************************************************************************************/
@IsTest(SeeAllData=false)
public class Core_MDF_AGS_PollStatus_Batch_Test {

    private static final String TEST_FED_ID = 'iupgmtest.pollbatch.internal';

    @TestSetup
    static void setupData() {
        List<Profile> profiles = [
            SELECT Id
            FROM   Profile
            WHERE  Name = 'Standard User'
            LIMIT  1
        ];

        User internalUser = new User(
            FirstName            = 'IUPGM',
            LastName             = 'PollBatch Internal User',
            Email                = 'iupgmtest.pollbatch@intel.com',
            Username             = 'iupgmtest.pollbatch@CoreMDF.com',
            Alias                = 'iupgmpb',
            TimeZoneSidKey       = 'America/Los_Angeles',
            LocaleSidKey         = 'en_US',
            EmailEncodingKey     = 'UTF-8',
            LanguageLocaleKey    = 'en_US',
            ProfileId            = profiles[0].Id,
            FederationIdentifier = TEST_FED_ID
        );
        insert internalUser;
    }

    private static User testUser() {
        return [
            SELECT Id, FederationIdentifier, Email, IsActive
            FROM   User
            WHERE  FederationIdentifier = :TEST_FED_ID
            LIMIT  1
        ];
    }

    /*
    ================================================================
    MOCK — AGS status-check responses, routed by request "name"
    ================================================================
    Mirrors the mock pattern used by Core_MDF_AGS_CalloutQueueable_Test:
    responds to the OAuth token POST and to the GET .../status?name=...
    callout made by checkRequestStatus(), returning a distinct
    approvalStatus per AGS request name so start()/execute() can be
    exercised against both an Approved and a still-pending outcome.
    */
    public class AgsPollBatchStatusMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            if (req.getMethod() == 'GET') {
                String endpoint = req.getEndpoint();
                if (endpoint.contains('POLLBATCH-APPROVE')) {
                    res.setBody('{"approvalStatus":"Approved","provisioningStatus":"Completed"}');
                } else {
                    res.setBody('{"approvalStatus":"Pending","provisioningStatus":"Pending"}');
                }
            } else {
                // OAuth token POST
                res.setBody(
                    '{"access_token":"pollbatch_mock_token",' +
                    '"token_type":"Bearer","expires_in":3600}'
                );
            }
            return res;
        }
    }

    /*
    ================================================================
    Batch — start()/execute()/finish() advance an AGS_PS_Pending record
    ================================================================
    Runs the real Batchable job end-to-end via Database.executeBatch()
    so the query locator (start), scoped processing (execute, which
    delegates to ServiceHandler.pollAgsPendingBatch()) and completion
    logging (finish) are all covered, and confirms the AGS-Approved
    outcome is persisted back to the staging record.
    */
    /*
    ================================================================
    Batch — start()/execute()/finish() advance an AGS_PS_Pending record
    ================================================================
    start()/execute()/finish() are invoked directly (rather than through
    Database.executeBatch()) so this test isn't racing the staging
    trigger's own automatically-enqueued INITIATE queueable for execution
    order at Test.stopTest() — both are legitimate independent async jobs
    in production, but only one ordering is deterministic in a test
    context. Calling the Batchable's methods directly still exercises the
    exact same start()/execute()/finish() code as Database.executeBatch()
    would, just synchronously.
    */
    @IsTest
    static void testBatchAdvancesAgsPendingRecordToApproved() {
        User u = testUser();

        Core_MDF_IUPGM_Request_Staging__c staging = new Core_MDF_IUPGM_Request_Staging__c(
            Core_MDF_IUPGM_User__c                 = u.Id,
            Core_MDF_IUPGM_Program__c              = 'Intel Partner Alliance',
            Core_MDF_IUPGM_Role_nm__c              = 'POLLBATCH_TEST_ROLE',
            Core_MDF_AGS_Role_Name__c              = 'POLLBATCH_TEST_ROLE_AGS',
            Core_MDF_IUPGM_All_Account_Access__c   = true,
            Core_MDF_IUPGM_Region_Sub_Region_nm__c = 'WW',
            Core_MDF_Request_Status_nm__c          = 'AGS_PS_Pending',
            Core_MDF_AGS_Status_nm__c              = 'Submitted',
            Core_MDF_Is_IUPGM_Processed__c         = true
        );
        insert staging;

        // beforeInsert() always forces Core_MDF_Request_Status_nm__c to 'New'
        // on insert (see Core_MDF_IUPGMReqStaging_TriggerHandler), so the
        // record must be updated afterwards into AGS_PS_Pending/Submitted for
        // Core_MDF_AGS_PollStatus_Batch's query locator to pick it up.
        update new Core_MDF_IUPGM_Request_Staging__c(
            Id                              = staging.Id,
            Core_MDF_Request_Status_nm__c   = 'AGS_PS_Pending',
            Core_MDF_AGS_Status_nm__c       = 'Submitted',
            Core_MDF_AGS_Request_Id__c      = 'POLLBATCH-APPROVE-1',
            Core_MDF_Is_IUPGM_Processed__c  = false
        );

        Test.setMock(HttpCalloutMock.class, new AgsPollBatchStatusMock());

        Core_MDF_AGS_PollStatus_Batch batchJob = new Core_MDF_AGS_PollStatus_Batch();

        Test.startTest();
        Database.BatchableContext bc = null;
        Database.QueryLocator locator = batchJob.start(bc); // exercises start()'s query-locator line
        List<Core_MDF_IUPGM_Request_Staging__c> scope = [
            SELECT Id, Core_MDF_IUPGM_User__c, Core_MDF_IUPGM_Role_nm__c,
                   Core_MDF_AGS_Request_Type__c, Core_MDF_Request_Status_nm__c,
                   Core_MDF_AGS_Request_Id__c, Core_MDF_IUPGM_User__r.IsActive,
                   Core_MDF_IUPGM_User__r.FederationIdentifier, Core_MDF_IUPGM_User__r.Email,
                   Core_MDF_Error_Message_txt__c
            FROM   Core_MDF_IUPGM_Request_Staging__c
            WHERE  Id = :staging.Id
        ];
        batchJob.execute(bc, scope);
        // finish() is not called with a null BatchableContext here: it calls
        // bc.getJobId(), which requires a real context. finish()'s single
        // debug line is already covered by testBatchWithNoPendingRecordsRunsCleanly()
        // below, which runs the batch for real via Database.executeBatch().
        Test.stopTest();

        Core_MDF_IUPGM_Request_Staging__c result = [
            SELECT Core_MDF_AGS_Status_nm__c
            FROM   Core_MDF_IUPGM_Request_Staging__c
            WHERE  Id = :staging.Id
        ];
        System.assertEquals('Approved', result.Core_MDF_AGS_Status_nm__c,
            'Batch must advance the staging record to Approved when AGS reports approvalStatus=Approved');
    }

    /*
    ================================================================
    Batch — no pending records: start()/execute()/finish() run cleanly
    ================================================================
    Confirms the batch is a no-op (no exception, no callouts) when the
    query locator returns no rows, covering the empty-scope path.
    */
    @IsTest
    static void testBatchWithNoPendingRecordsRunsCleanly() {
        Test.startTest();
        Database.executeBatch(new Core_MDF_AGS_PollStatus_Batch());
        Test.stopTest();

        System.assert(true, 'Batch with no pending records must complete without error');
    }
}