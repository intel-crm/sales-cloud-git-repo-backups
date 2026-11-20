/**
 * @description       : Test class for Core_MDF_ContentVersionDwnldUrlAPI
 * @author            : 
 * @group             : 
 * @last modified on  : 03-11-2026
 * @last modified by  : 
**/
@IsTest
private class Core_MDF_ContentVersionDwnldUrlAPI_Test {
    // Align setup with Core_MDF_AI_Integration_Outbound_Test using a System Admin user and full prerequisites
    private static final String API_URL = '/services/apexrest/mdf/cdb/contentVersionDownloadUrlAPI';
    private static final String USERNAME_BASE = 'sysadmindwn@example.com';
    private static final String PROGRAM_CCF = 'Client CoMarketing Fund';
    private static final String BUDGET_TYPE_CCF = 'OEM CMP';

    private class TestRefs {
        Id claimId;
        String requestUserName;
    }

    @TestSetup
    static void setupData() {
        // Create System Admin user mirroring AI Outbound test
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User adminUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        adminUser.LastName = 'System Adm';
        adminUser.ProfileId = sysAdminProfile.Id;
        adminUser.isActive = true;
        adminUser.Email = USERNAME_BASE;
        adminUser.Username = USERNAME_BASE;
        Database.insert(new List<User>{ adminUser });

        system.runAs(adminUser){
            // Assign required permission set
            List<PermissionSet> picReviewerPermissionSets = [
                SELECT Id, Name FROM PermissionSet
                WHERE Name IN ('Core_MDF_CCP_Internal_Claim_Case_Reviewer')
            ];
            if (!picReviewerPermissionSets.isEmpty()) {
                insert new PermissionSetAssignment(PermissionSetId = picReviewerPermissionSets[0].Id, AssigneeId = adminUser.Id);
            }

            // Bypass & configuration similar to AI test
            Core_MDF_Configuration__c mdfRecTypes = new Core_MDF_Configuration__c(
                Name='ALLOWED_PRG_FOR_RUS_NOTIF',
                Core_MDF_Value__c='Retail Marketing Funds,Intel Partner Alliance,Channel MDF,Co-GTM'
            );
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
            if (!transactions.isEmpty()) {
                Database.insert(transactions);
            }

            // Program, Accounts, Budget, Allocation, Campaign, Bank, ABM, PFR
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram(Core_MDF_CCP_ConstantClass.CCF_PROGRAM, PROGRAM_CCF, true);

            Account intelAcct = Core_MDF_CCP_TestDataUtility.createIntelAccount('CVDU Intel Acct', Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, true);
            Account partnerAcct = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CVDU Partner', cp.Id, Core_MDF_CCP_TestDataUtility.account_Record_Type, intelAcct.Id, true);

            Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();

            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget(
                'CVDU Budget',
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

            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('CVDU PFA', budget, partnerAcct, 10000, true);

            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign(
                'CVDU Camp',
                'Gaming',
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
            pfr.Core_MDF_Budget_Type_nm__c = BUDGET_TYPE_CCF;
            pfr.Core_MDF_Start_Date__c = System.today().addDays(-2);
            pfr.Core_MDF_End_Date__c = System.today();
            pfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            insert pfr;

            // Create PartnerFundClaim mirroring AI test
            PartnerFundClaim claim = createBaseClaim(pfr.Id, bank.Id, 'CVDU Claim', 'PIC Pending', false, PROGRAM_CCF, BUDGET_TYPE_CCF);

            // Create a real ContentVersion to obtain a valid Id for download URL API
            ContentVersion cv = new ContentVersion(
                Title = 'TestDoc',
                PathOnClient = 'TestDoc.txt',
                VersionData = Blob.valueOf('sample content')
            );
            insert cv;

            // Create audit documents
            Core_MDF_Audit_Document__c ad1 = new Core_MDF_Audit_Document__c(
                Core_MDF_Claim__c = claim.Id,
                Core_MDF_Old_Document_Id__c = 'APPFILE-VALID-1',
                Core_MDF_ContentVersion_Id__c = cv.Id,
                Core_MDF_SFT_File_Download_Ind__c = false,
                Core_MDF_Document_Types__c = 'Proof of Cost;Proof of execution;Proof of attribution',
            Core_MDF_App_Document_Types_nm__c ='Proof of Cost;Proof of execution;Proof of attribution',
            Core_MDF_Document_Title__c = 'Test Doc1'
            );
            Core_MDF_Audit_Document__c ad2 = new Core_MDF_Audit_Document__c(
                Core_MDF_Claim__c = claim.Id,
                Core_MDF_Old_Document_Id__c = 'APPFILE-NO-CV-1',
                Core_MDF_SFT_File_Download_Ind__c = false,
                Core_MDF_Document_Types__c = 'Proof of Cost;Proof of execution;Proof of attribution',
            Core_MDF_App_Document_Types_nm__c ='Proof of Cost;Proof of execution;Proof of attribution',
            Core_MDF_Document_Title__c = 'Test Doc2'
            );
            insert new List<Core_MDF_Audit_Document__c>{ ad1, ad2 };
        }
    }

    // Helper to build a base PartnerFundClaim similar to AI test
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
        claim.Core_MDF_Currency__c = 'USD';
        claim.Core_MDF_Reimbursable_TransactionAmt_Loc__c = 150;
        claim.Core_MDF_Total_Invoice_Amount_Local__c = 2500;
        claim.Core_MDF_Country_Location_nm__c = 'ALBANIA';
        claim.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
        claim.Core_MDF_Invoice_Number__c = '123456';
        claim.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
        claim.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
        claim.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c = isThirdParty;
        claim.Core_MDF_Status__c = statusForCoreMDFStatus;
        claim.Core_MDF_PIC_Review_Completed__c = false;
        insert claim;
        return claim;
    }

    private static TestRefs getRefs() {
        TestRefs r = new TestRefs();
        PartnerFundClaim c = [SELECT Id FROM PartnerFundClaim ORDER BY CreatedDate DESC LIMIT 1];
        User u = [SELECT Username FROM User WHERE Username = :USERNAME_BASE LIMIT 1];
        r.claimId = c.Id;
        r.requestUserName = u.Username;
        return r;
    }

    // Helper to invoke the REST resource
    private static RestResponse invoke(String bodyJson) {
        RestRequest req = new RestRequest();
        req.requestURI = API_URL;
        req.httpMethod = 'POST';
        if (bodyJson != null) {
            req.requestBody = Blob.valueOf(bodyJson);
        }
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        Core_MDF_ContentVersionDownloadUrlAPI.getContentVersionDownloadUrl();
        Test.stopTest();

        return RestContext.response;
    }

    // Helper to build JSON body
    private static String bodyJson(String recordId, List<String> appFileIds, String userName) {
        Map<String, Object> m = new Map<String, Object>();
        if (recordId != null) m.put('recordId', recordId);
        if (appFileIds != null) m.put('appFileIds', appFileIds);
        if (userName != null) m.put('userName', userName);
        return JSON.serialize(m);
    }

    @IsTest
    static void test_success_atLeastOneValidUrl_200_map() {
        TestRefs r = getRefs();
        List<String> ids = new List<String>{ 'APPFILE-VALID-1', 'APPFILE-NO-CV-1', 'APPFILE-NOT-EXIST' };

        RestResponse res = invoke(bodyJson(r.claimId, ids, r.requestUserName));
        System.assertEquals(200, res.statusCode, 'Expected 200 for at least one valid URL');

        String json = res.responseBody != null ? res.responseBody.toString() : null;
        System.assertNotEquals(null, json, 'Response body should not be null');

        Map<String, Object> out = (Map<String, Object>) System.JSON.deserializeUntyped(json);
        System.assert(out.containsKey('APPFILE-VALID-1'));
        System.assert(out.containsKey('APPFILE-NO-CV-1'));
        System.assert(out.containsKey('APPFILE-NOT-EXIST'));

        // For a valid entry, expect an object with url and title
        Map<String, Object> validEntry = (Map<String, Object>) out.get('APPFILE-VALID-1');
        System.assertNotEquals(null, validEntry, 'Valid entry should be an object');
        System.assert(validEntry.containsKey('url'), 'Valid entry should contain url');
        System.assert(validEntry.containsKey('title'), 'Valid entry should contain title');

        String validUrl = (String) validEntry.get('url');
        System.assertNotEquals(null, validUrl, 'url must not be null for valid entry');
        System.assertEquals(true, validUrl.startsWith('http'), 'Valid URL should start with http');

        // Missing entries should be null
        System.assertEquals('Document not found', out.get('APPFILE-NO-CV-1'), 'Missing doc should be null');
        System.assertEquals('Document not found', out.get('APPFILE-NOT-EXIST'), 'Missing doc should be null');
    }

    @IsTest
    static void test_noBody_400_ERROR01() {
        RestResponse res = invoke(null);
        System.assertEquals(400, res.statusCode);
        Map<String, Object> err = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(true, (Boolean) err.get('error'));
        System.assertEquals('Request body is required', (String) err.get('message'));
    }

    @IsTest
    static void test_invalidJson_400_ERROR02() {
        RestResponse res = invoke('{"claimId": "x", "appFileIds": [');
        System.assertEquals(400, res.statusCode);
        Map<String, Object> err = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(true, (Boolean) err.get('error'));
        System.assertEquals('Invalid JSON payload', (String) err.get('message'));
    }

    @IsTest
    static void test_blankClaim_400_ERROR03() {
        TestRefs r = getRefs();
        RestResponse res = invoke(bodyJson('', new List<String>{ 'X' }, r.requestUserName));
        System.assertEquals(400, res.statusCode);
        Map<String, Object> err = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('Claim ID / Case ID is required', (String) err.get('message'));
    }

    @IsTest
    static void test_nullAppFileIds_400_ERROR04() {
        TestRefs r = getRefs();
        RestResponse res = invoke(bodyJson(r.claimId, null, r.requestUserName));
        System.assertEquals(400, res.statusCode);
        Map<String, Object> err = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('AppFile IDs are required', (String) err.get('message'));
    }

    @IsTest
    static void test_emptyAppFileIds_400_ERROR04() {
        TestRefs r = getRefs();
        RestResponse res = invoke(bodyJson(r.claimId, new List<String>(), r.requestUserName));
        System.assertEquals(400, res.statusCode);
        Map<String, Object> err = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('AppFile IDs are required', (String) err.get('message'));
    }

    @IsTest
    static void test_blankUserName_400_ERROR05() {
        TestRefs r = getRefs();
        RestResponse res = invoke(bodyJson(r.claimId, new List<String>{ 'ANY' }, ''));
        System.assertEquals(400, res.statusCode);
        Map<String, Object> err = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('userName is required', (String) err.get('message'));
    }

    @IsTest
    static void test_unauthorizedUser_403_ERROR06() {
        TestRefs r = getRefs();

        // User without share to claim (so UserRecordAccess query yields empty)
        Profile std = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u2 = new User(
            FirstName = 'MDF',
            LastName = 'NoShare',
            Alias = 'mdfns',
            Email = 'mdf.noshare@example.com',
            Username = 'mdf.noshare@example.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = std.Id
        );
        insert u2;

        RestResponse res = invoke(bodyJson(r.claimId, new List<String>{ 'ANY' }, u2.Username));
        System.assertEquals(403, res.statusCode);
        Map<String, Object> err = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('User not authorized to access claim documents', (String) err.get('message'));
    }

    @IsTest
    static void test_noMatchingUserLike_403_ERROR06() {
        TestRefs r = getRefs();
        // Use a username that does not exist (LIKE will not find any active user)
        String nonExistentUser = 'nonexistent.user.like@example.com';
        RestResponse res = invoke(bodyJson(r.claimId, new List<String>{ 'ANY' }, nonExistentUser));
        System.assertEquals(403, res.statusCode, 'Expected 403 when username LIKE finds no users');
        Map<String, Object> err = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('User not authorized to access claim documents', (String) err.get('message'));
    }

    @IsTest
    static void test_noDocumentsFound_404_ERROR07() {
        TestRefs r = getRefs();

        // Ensure no valid doc URLs (no contentVersion ids) for the requested ids
        List<String> ids = new List<String>{ 'APPFILE-NO-CV-1', 'APPFILE-NOT-EXIST' };
        RestResponse res = invoke(bodyJson(r.claimId, ids, r.requestUserName));
        System.assertEquals(404, res.statusCode);
        Map<String, Object> err = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('No documents found for the provided appFileIds', (String) err.get('message'));
    }
}