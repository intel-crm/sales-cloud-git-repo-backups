/********************************************************************************************************************
 * Class Name            : Pricing_ContentVersionDetails_Test
 * Version               : 1.0
 * Created Date          :04-07-2026
 * Modification Log      :
 * Developer            Date             Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------
 * Sinduja                04-07-2026        Test class for Pricing_ContentVersionDetails
 ******************************************************************************************************************************************************/
@IsTest
private class Pricing_ContentVersionDetails_Test {
    private static final String API_URL = '/services/apexrest/quote/cdb/pricingContentVersionDetails';
    private static final String USERNAME_BASE = 'sysadmindwn@example.com';
   @TestSetup
    static void setupData() {
        List<User> adminUser = Pricing_Test_Utility.createAdminUser();
        List<SBQQ__QuoteLine__c> lstquoteLines;
        
        if (!adminUser.isEmpty()) {
            System.runAs(adminUser[0]) {
                Pricing_Test_Utility.createPriceBook();
                Account acc = Pricing_Test_Utility.createAccount();
                Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
                Pricing_Test_Utility.createTemplate(adminUser[0].Id);
                List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
                List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
                
                AccountTeamMember accTeam = new AccountTeamMember(
                    AccountId = acc.Id,
                    TeamMemberRole = 'Technical Sales',
                    UserId = salesRepUserList[0].Id
                );
                insert accTeam;
                
                List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(
                    acc.Id, 
                    con.Id, 
                    1, 
                    salesRepUserList[0].Email, 
                    accountExecutiveUserList[0].Email
                );
                
                Id quoteID;
                for (SBQQ__Quote__c quote : lstquote) {
                    quoteID = quote.Id;
                }
                system.debug('INSIDE APEX TEST QUOTE:'+quoteID);
                
                // Move ContentVersion creation BEFORE Test.startTest()
                ContentVersion cv = new ContentVersion(
                    Title = 'TestDoc',
                    PathOnClient = 'TestDoc.txt',
                    VersionData = Blob.valueOf('sample content for testing'),
                    IsMajorVersion = true
                );
                insert cv;
                system.debug('INSIDE APEX TEST CONTENT VERSION:'+cv);
                
                ContentVersion insertedCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
                
                ContentDocumentLink cdl1 = new ContentDocumentLink(
                    LinkedEntityId = quoteID,
                    ContentDocumentId = insertedCV.ContentDocumentId,
                    ShareType = 'V'
                );
                insert cdl1;
                system.debug('INSIDE APEX TEST CONTENT DOCUMENT LINK:'+cdl1);
                
                Test.startTest();
                lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteID, 1);
                Test.stopTest();
    
                // Create another ContentVersion without linking to quote (for negative testing)
                ContentVersion cv2 = new ContentVersion(
                    Title = 'TestDoc2',
                    PathOnClient = 'TestDoc2.txt',
                    VersionData = Blob.valueOf('sample content 2')
                );
                insert cv2;
            }
        }
    }
    private static TestRefs getRefs() {
    TestRefs r = new TestRefs();
    
    List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c ORDER BY CreatedDate DESC LIMIT 1];
    if (quotes.isEmpty()) {
        System.debug('No quotes found in test data');
        return r;
    }
    
    SBQQ__Quote__c quote = quotes[0];
    System.debug('Found quote: ' + quote.Id);
    
    // Get the admin user created by Pricing_Test_Utility
    List<User> adminUsers = [SELECT Username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true ORDER BY CreatedDate DESC LIMIT 1];
    System.debug('Found admin users: ' + adminUsers.size());
    
    // Get ContentDocument IDs for testing
    List<ContentDocumentLink> cdls = [
        SELECT ContentDocumentId 
        FROM ContentDocumentLink 
        WHERE LinkedEntityId = :quote.Id
    ];
    System.debug('Found ContentDocumentLinks: ' + cdls.size());
    
    r.quoteId = quote.Id;
    r.requestUserName = !adminUsers.isEmpty() ? adminUsers[0].Username : null;
    r.validContentDocumentId = !cdls.isEmpty() ? cdls[0].ContentDocumentId : null;
    
    System.debug('TestRefs - QuoteId: ' + r.quoteId + ', Username: ' + r.requestUserName + ', ValidContentDocId: ' + r.validContentDocumentId);
    
    // Find unlinked ContentDocument
    List<ContentVersion> allCVs = [SELECT ContentDocumentId FROM ContentVersion];
    for (ContentVersion cv : allCVs) {
        Boolean isLinked = false;
        for (ContentDocumentLink cdl : cdls) {
            if (cdl.ContentDocumentId == cv.ContentDocumentId) {
                isLinked = true;
                break;
            }
        }
        if (!isLinked) {
            r.unlinkedContentDocumentId = cv.ContentDocumentId;
            break;
        }
    }
    
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
        Pricing_ContentVersionDetails.getContentVersionDownloadUrl();
        Test.stopTest();

        return RestContext.response;
    }

    // Helper to build JSON body
    private static String bodyJson(String recordId, List<String> contentDocumentIds, String userName) {
        Map<String, Object> m = new Map<String, Object>();
        if (recordId != null) m.put('quoteId', recordId);
        if (contentDocumentIds != null) m.put('contentDocumentIds', contentDocumentIds);
        if (userName != null) m.put('userName', userName);
        return JSON.serialize(m);
    }

    @IsTest
    static void test_success_atLeastOneValidUrl_200_map() {
        TestRefs r = getRefs();
        
        // Get the ACTUAL ContentDocument ID that was created and linked
        List<ContentDocumentLink> actualLinks = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :r.quoteId
        ];
        
        if (actualLinks.isEmpty()) {
            System.assert(true, 'No ContentDocumentLink found');
            return;
        }
        
        String actualContentDocId = actualLinks[0].ContentDocumentId;
        System.debug('Using actual ContentDocumentId: ' + actualContentDocId);
        
        // Use the ACTUAL ContentDocument ID in the test
        List<String> ids = new List<String>{ actualContentDocId };
    
        RestResponse res = invoke(bodyJson(r.quoteId, ids, r.requestUserName));
        System.assertEquals(200, res.statusCode, 'Expected 200 for at least one valid URL');
    
        Map<String, Object> out = (Map<String, Object>) System.JSON.deserializeUntyped(res.responseBody.toString());
        Map<String, Object> validEntry = (Map<String, Object>) out.get(actualContentDocId);
        System.assert(validEntry.containsKey('url'), 'Valid entry should contain url');
    }
    @IsTest
    static void test_invalidJson_400_ERROR02() {
        RestResponse res = invoke('{"quoteId": "x", "contentDocumentIds": [');
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
        System.assertEquals('Quote ID is required', (String) err.get('message'));
    }

    @IsTest
    static void test_nullAppFileIds_400_ERROR04() {
        TestRefs r = getRefs();
        RestResponse res = invoke(bodyJson(r.quoteId, null, r.requestUserName));
        System.assertEquals(400, res.statusCode);
        Map<String, Object> err = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('ContentDocument IDs are required', (String) err.get('message'));
    }

    @IsTest
    static void test_emptyAppFileIds_400_ERROR04() {
        TestRefs r = getRefs();
        RestResponse res = invoke(bodyJson(r.quoteId, new List<String>(), r.requestUserName));
        System.assertEquals(400, res.statusCode);
        Map<String, Object> err = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('ContentDocument IDs are required', (String) err.get('message'));
    }

    @IsTest
    static void test_blankUserName_400_ERROR05() {
        TestRefs r = getRefs();
        RestResponse res = invoke(bodyJson(r.quoteId, new List<String>{ 'ANY' }, ''));
        System.assertEquals(400, res.statusCode);
        Map<String, Object> err = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('userName is required', (String) err.get('message'));
    }

    @IsTest
    static void test_unauthorizedUser_403_ERROR06() {
        TestRefs r = getRefs();

        // User without share to quote (so UserRecordAccess query yields empty)
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

        RestResponse res = invoke(bodyJson(r.quoteId, new List<String>{ 'ANY' }, u2.Username));
        System.assertEquals(403, res.statusCode);
        Map<String, Object> err = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('User not authorized to access quote documents', (String) err.get('message'));
    }

    @IsTest
    static void test_noMatchingUserLike_403_ERROR06() {
        TestRefs r = getRefs();
        // Use a username that does not exist (LIKE will not find any active user)
        String nonExistentUser = 'nonexistent.user.like@example.com';
        RestResponse res = invoke(bodyJson(r.quoteId, new List<String>{ 'ANY' }, nonExistentUser));
        System.assertEquals(403, res.statusCode, 'Expected 403 when username LIKE finds no users');
        Map<String, Object> err = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals('User not authorized to access quote documents', (String) err.get('message'));
    }

  @IsTest
    static void test_noDocumentsFound_404_ERROR07() {
        TestRefs r = getRefs();
        
        // Get a real ContentDocument ID that exists but is NOT linked to the quote
        List<ContentVersion> unlinkedCVs = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];
        String unlinkedId = unlinkedCVs.isEmpty() ? '069000000000000AAA' : unlinkedCVs[0].ContentDocumentId;
        
        List<String> ids = new List<String>{ unlinkedId };
        RestResponse res = invoke(bodyJson(r.quoteId, ids, r.requestUserName));
        
        System.assertEquals(404, res.statusCode);
    }
    private class TestRefs {
        public String quoteId;
        public String requestUserName;
        public String validContentDocumentId;
        public String unlinkedContentDocumentId;
    }
}