@IsTest(SeeAllData=false)
public class Core_MDF_IUPGMRoleRecomndService_Test {

    /*
    ================================================================
    TEST DATA HELPERS
    ================================================================
    */

    /**
     * Creates an in-memory MDT record.
     *
     * We do not insert Custom Metadata records.
     * The service only needs the records passed into recommend().
     */
    private static Core_MDF_IUPGM_Rule_Config__mdt createRole(
        String roleLabel,
        String program,
        String purpose,
        String keywords,
        String useCases
    ) {
        return new Core_MDF_IUPGM_Rule_Config__mdt(
            Core_MDF_Role_Label__c = roleLabel,
            Core_MDF_Program__c = program,
            Core_MDF_Role_Purpose__c = purpose,
            Core_MDF_Keywords__c = keywords,
            Core_MDF_Use_Cases__c = useCases,
            Core_MDF_Account_Required__c = false,
            Core_MDF_All_Accounts__c = 'Yes',
            Core_MDF_WW_Only__c = false,
            Core_MDF_Region_Options__c = 'APJ, EMEA, WW',
            Core_MDF_Budget_Required_When_False__c = false,
            Core_MDF_Approval_Region_Required__c = false,
            Core_MDF_Activity_Classification_Req__c = false
        );
    }

    private static List<Core_MDF_IUPGM_Rule_Config__mdt> createCandidates() {

        return new List<Core_MDF_IUPGM_Rule_Config__mdt>{
            createRole(
                'IPA Account Manager',
                'IPA',
                'Manage account access and account-related MDF activities',
                'account manager, account, MDF, manage',
                'Managing account access and MDF activities'
            ),
            createRole(
                'IPA Budget Approver',
                'IPA',
                'Approve MDF budgets and budget requests',
                'budget, approve, approval, MDF',
                'Approving MDF budget requests'
            ),
            createRole(
                'IPA Exception Reviewer',
                'IPA',
                'Review exceptions and unusual access requests',
                'exception, review, reviewer',
                'Reviewing exception requests'
            )
        };
    }


    /*
    ================================================================
    HTTP MOCK
    ================================================================
    */

    /**
     * Mock successful GenAI response.
     */
    private class GenAISuccessMock implements HttpCalloutMock {

        private String responseBody;

        GenAISuccessMock(String responseBody) {
            this.responseBody = responseBody;
        }

        public HttpResponse respond(HttpRequest req) {

            System.assertEquals(
                'POST',
                req.getMethod(),
                'GenAI callout should use POST'
            );

            System.assert(
                req.getEndpoint().contains('callout:Core_MDF_CCP_GenAI'),
                'Existing GenAI Named Credential should be used'
            );

            System.assertEquals(
                'application/json',
                req.getHeader('Content-Type'),
                'Request should be JSON'
            );

            System.assert(
                req.getBody().contains('messages'),
                'GenAI request should contain messages'
            );

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');

            res.setBody(
                '{"choices":[' +
                    '{"message":{' +
                        '"content":' +
                        JSON.serialize(responseBody) +
                    '}}' +
                ']}'
            );

            return res;
        }
    }


    /**
     * Mock non-200 response from GenAI.
     */
    private class GenAIErrorMock implements HttpCalloutMock {

        private Integer statusCode;

        GenAIErrorMock(Integer statusCode) {
            this.statusCode = statusCode;
        }

        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();

            res.setStatusCode(statusCode);
            res.setHeader('Content-Type', 'application/json');

            res.setBody(
                '{"error":{"message":"Mock GenAI failure"}}'
            );

            return res;
        }
    }


    /**
     * Mock response where the GenAI response structure is invalid.
     */
    private class GenAIMalformedEnvelopeMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();

            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');

            res.setBody(
                '{"choices":[]}'
            );

            return res;
        }
    }


    /*
    ================================================================
    SECTION 1 — INPUT VALIDATION
    ================================================================
    */

    @IsTest
    static void testRecommend_NullQuery() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            createCandidates();

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                null,
                candidates
            );

        Test.stopTest();

        System.assertEquals(
            false,
            result.success,
            'Null query should return success=false'
        );

        System.assertEquals(
            false,
            result.calloutSucceeded,
            'No callout should occur for invalid input'
        );

        System.assertEquals(
            'No query or candidate roles supplied.',
            result.errorMessage
        );

        System.assertEquals(
            0,
            result.recommendations.size(),
            'No recommendations should be returned'
        );
    }


    @IsTest
    static void testRecommend_BlankQuery() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            createCandidates();

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                '   ',
                candidates
            );

        Test.stopTest();

        System.assertEquals(false, result.success);
        System.assertEquals(false, result.calloutSucceeded);

        System.assertEquals(
            'No query or candidate roles supplied.',
            result.errorMessage
        );
    }


    @IsTest
    static void testRecommend_NullCandidates() {

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need budget approval access',
                null
            );

        Test.stopTest();

        System.assertEquals(false, result.success);
        System.assertEquals(false, result.calloutSucceeded);

        System.assertEquals(
            'No query or candidate roles supplied.',
            result.errorMessage
        );
    }


    @IsTest
    static void testRecommend_EmptyCandidates() {

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need budget approval access',
                new List<Core_MDF_IUPGM_Rule_Config__mdt>()
            );

        Test.stopTest();

        System.assertEquals(false, result.success);
        System.assertEquals(false, result.calloutSucceeded);

        System.assertEquals(
            'No query or candidate roles supplied.',
            result.errorMessage
        );
    }


    @IsTest
    static void testRecommend_AllCandidateLabelsNull() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            new List<Core_MDF_IUPGM_Rule_Config__mdt>{
                new Core_MDF_IUPGM_Rule_Config__mdt(
                    Core_MDF_Role_Label__c = null
                )
            };

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need access',
                candidates
            );

        Test.stopTest();

        System.assertEquals(false, result.success);
        System.assertEquals(false, result.calloutSucceeded);

        System.assertEquals(
            'No valid candidate roles to ground the model with.',
            result.errorMessage
        );
    }


    /*
    ================================================================
    SECTION 2 — SUCCESSFUL AI RECOMMENDATION
    ================================================================
    */

    @IsTest
    static void testRecommend_SuccessfulRecommendation() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            createCandidates();

        String aiContent =
            '{' +
                '"rewrittenQuery":"User needs MDF budget approval access",' +
                '"needsClarification":false,' +
                '"clarificationQuestion":null,' +
                '"recommendations":[' +
                    '{' +
                        '"roleLabel":"IPA Budget Approver",' +
                        '"confidence":0.95,' +
                        '"reason":"This role is responsible for approving MDF budget requests."' +
                    '}' +
                ']' +
            '}';

        Test.setMock(
            HttpCalloutMock.class,
            new GenAISuccessMock(aiContent)
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need to approve MDF budgets',
                candidates
            );

        Test.stopTest();

        System.assertEquals(
            true,
            result.calloutSucceeded,
            'Successful HTTP 200 + parseable JSON should set calloutSucceeded=true'
        );

        System.assertEquals(
            true,
            result.success,
            'Valid recommendation should set success=true'
        );

        System.assertEquals(
            'User needs MDF budget approval access',
            result.rewrittenQuery
        );

        System.assertEquals(
            false,
            result.needsClarification
        );

        System.assertEquals(
            1,
            result.recommendations.size()
        );

        Core_MDF_IUPGMRoleRecommendationService.RoleRecommendation rec =
            result.recommendations[0];

        System.assertEquals(
            'IPA Budget Approver',
            rec.roleLabel,
            'Returned label should be the verified MDT candidate label'
        );

        System.assertEquals(
            'IPA',
            rec.program
        );

        System.assertEquals(
            'Approve MDF budgets and budget requests',
            rec.purpose
        );

        System.assertEquals(
            Decimal.valueOf('0.95'),
            rec.confidence
        );

        System.assertEquals(
            'This role is responsible for approving MDF budget requests.',
            rec.reason
        );
    }


    /*
    ================================================================
    SECTION 3 — ROLE VALIDATION / ANTI-HALLUCINATION
    ================================================================
    */

    @IsTest
    static void testRecommend_HallucinatedRoleIsDropped() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            createCandidates();

        String aiContent =
            '{' +
                '"rewrittenQuery":"Need budget access",' +
                '"needsClarification":false,' +
                '"clarificationQuestion":null,' +
                '"recommendations":[' +
                    '{' +
                        '"roleLabel":"IPA Super Administrator",' +
                        '"confidence":0.99,' +
                        '"reason":"Mock hallucinated role"' +
                    '}' +
                ']' +
            '}';

        Test.setMock(
            HttpCalloutMock.class,
            new GenAISuccessMock(aiContent)
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need budget access',
                candidates
            );

        Test.stopTest();

        System.assertEquals(
            true,
            result.calloutSucceeded,
            'AI call itself succeeded'
        );

        System.assertEquals(
            false,
            result.success,
            'Unknown role must not result in a successful recommendation'
        );

        System.assertEquals(
            0,
            result.recommendations.size(),
            'Hallucinated role must be silently dropped'
        );
    }


    @IsTest
    static void testRecommend_MixedValidAndInvalidRoles() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            createCandidates();

        String aiContent =
            '{' +
                '"rewrittenQuery":"Need MDF access",' +
                '"needsClarification":false,' +
                '"clarificationQuestion":null,' +
                '"recommendations":[' +

                    '{' +
                        '"roleLabel":"Fake Role XYZ",' +
                        '"confidence":0.99,' +
                        '"reason":"Should be removed"' +
                    '},' +

                    '{' +
                        '"roleLabel":"IPA Account Manager",' +
                        '"confidence":0.88,' +
                        '"reason":"Valid candidate role"' +
                    '}' +

                ']' +
            '}';

        Test.setMock(
            HttpCalloutMock.class,
            new GenAISuccessMock(aiContent)
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need account access',
                candidates
            );

        Test.stopTest();

        System.assertEquals(
            true,
            result.calloutSucceeded
        );

        System.assertEquals(
            true,
            result.success
        );

        System.assertEquals(
            1,
            result.recommendations.size(),
            'Only the valid candidate should remain'
        );

        System.assertEquals(
            'IPA Account Manager',
            result.recommendations[0].roleLabel
        );
    }


    @IsTest
    static void testRecommend_RoleLabelCaseInsensitive() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            createCandidates();

        String aiContent =
            '{' +
                '"rewrittenQuery":"Need account management",' +
                '"needsClarification":false,' +
                '"clarificationQuestion":null,' +
                '"recommendations":[' +
                    '{' +
                        '"roleLabel":"ipa account manager",' +
                        '"confidence":0.91,' +
                        '"reason":"Matches account management use case"' +
                    '}' +
                ']' +
            '}';

        Test.setMock(
            HttpCalloutMock.class,
            new GenAISuccessMock(aiContent)
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need account management',
                candidates
            );

        Test.stopTest();

        System.assertEquals(true, result.success);
        System.assertEquals(1, result.recommendations.size());

        System.assertEquals(
            'IPA Account Manager',
            result.recommendations[0].roleLabel,
            'Original MDT label should be returned'
        );
    }


    /*
    ================================================================
    SECTION 4 — CLARIFICATION
    ================================================================
    */

    @IsTest
    static void testRecommend_NeedsClarificationWithRecommendations() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            createCandidates();

        String aiContent =
            '{' +
                '"rewrittenQuery":"User needs IPA access",' +
                '"needsClarification":true,' +
                '"clarificationQuestion":"Do you need account management or budget approval access?",' +
                '"recommendations":[' +
                    '{' +
                        '"roleLabel":"IPA Account Manager",' +
                        '"confidence":0.70,' +
                        '"reason":"Possible account-management match"' +
                    '},' +
                    '{' +
                        '"roleLabel":"IPA Budget Approver",' +
                        '"confidence":0.68,' +
                        '"reason":"Possible budget-approval match"' +
                    '}' +
                ']' +
            '}';

        Test.setMock(
            HttpCalloutMock.class,
            new GenAISuccessMock(aiContent)
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need IPA access',
                candidates
            );

        Test.stopTest();

        System.assertEquals(
            true,
            result.calloutSucceeded
        );

        System.assertEquals(
            true,
            result.success,
            'Recommendations exist even though clarification is required'
        );

        System.assertEquals(
            true,
            result.needsClarification
        );

        System.assertEquals(
            'Do you need account management or budget approval access?',
            result.clarificationQuestion
        );

        System.assertEquals(
            2,
            result.recommendations.size()
        );
    }


    /*
    ================================================================
    SECTION 5 — EMPTY AI RECOMMENDATION
    ================================================================
    */

    @IsTest
    static void testRecommend_AIReturnsNoRecommendations() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            createCandidates();

        String aiContent =
            '{' +
                '"rewrittenQuery":"User asks for unrelated functionality",' +
                '"needsClarification":false,' +
                '"clarificationQuestion":null,' +
                '"recommendations":[]' +
            '}';

        Test.setMock(
            HttpCalloutMock.class,
            new GenAISuccessMock(aiContent)
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need something unrelated',
                candidates
            );

        Test.stopTest();

        System.assertEquals(
            true,
            result.calloutSucceeded,
            'The AI was reached successfully'
        );

        System.assertEquals(
            false,
            result.success,
            'No recommendations means success=false'
        );

        System.assertEquals(
            0,
            result.recommendations.size()
        );

        System.assertEquals(
            'User asks for unrelated functionality',
            result.rewrittenQuery
        );
    }


    /*
    ================================================================
    SECTION 6 — MAXIMUM RECOMMENDATIONS
    ================================================================
    */

    @IsTest
    static void testRecommend_MaxFiveRecommendations() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            new List<Core_MDF_IUPGM_Rule_Config__mdt>();

        for (Integer i = 1; i <= 8; i++) {

            candidates.add(
                createRole(
                    'Test Role ' + i,
                    'IPA',
                    'Test role purpose ' + i,
                    'test keyword ' + i,
                    'Test use case ' + i
                )
            );
        }

        String aiContent =
            '{' +
                '"rewrittenQuery":"Test request",' +
                '"needsClarification":false,' +
                '"clarificationQuestion":null,' +
                '"recommendations":[' +

                    '{"roleLabel":"Test Role 1","confidence":0.91,"reason":"Reason 1"},' +
                    '{"roleLabel":"Test Role 2","confidence":0.90,"reason":"Reason 2"},' +
                    '{"roleLabel":"Test Role 3","confidence":0.89,"reason":"Reason 3"},' +
                    '{"roleLabel":"Test Role 4","confidence":0.88,"reason":"Reason 4"},' +
                    '{"roleLabel":"Test Role 5","confidence":0.87,"reason":"Reason 5"},' +
                    '{"roleLabel":"Test Role 6","confidence":0.86,"reason":"Reason 6"},' +
                    '{"roleLabel":"Test Role 7","confidence":0.85,"reason":"Reason 7"}' +

                ']' +
            '}';

        Test.setMock(
            HttpCalloutMock.class,
            new GenAISuccessMock(aiContent)
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'Test request',
                candidates
            );

        Test.stopTest();

        System.assertEquals(
            true,
            result.success
        );

        System.assertEquals(
            5,
            result.recommendations.size(),
            'Service must return at most five recommendations'
        );
    }


    /*
    ================================================================
    SECTION 7 — MALFORMED AI RESPONSE
    ================================================================
    */

    @IsTest
    static void testRecommend_MalformedAIJson() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            createCandidates();

        String aiContent =
            'This is not valid JSON at all';

        Test.setMock(
            HttpCalloutMock.class,
            new GenAISuccessMock(aiContent)
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need account access',
                candidates
            );

        Test.stopTest();

        System.assertEquals(
            false,
            result.success
        );

        System.assertEquals(
            false,
            result.calloutSucceeded,
            'Malformed AI content means the response could not be successfully parsed'
        );

        System.assertEquals(
            'Could not parse AI response as JSON.',
            result.errorMessage
        );

        System.assertEquals(
            0,
            result.recommendations.size()
        );
    }


    @IsTest
    static void testRecommend_AIJsonInsideMarkdownFence() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            createCandidates();

        String aiContent =
            '```json\n' +
            '{' +
                '"rewrittenQuery":"Need account access",' +
                '"needsClarification":false,' +
                '"clarificationQuestion":null,' +
                '"recommendations":[' +
                    '{' +
                        '"roleLabel":"IPA Account Manager",' +
                        '"confidence":0.93,' +
                        '"reason":"Matches account management"' +
                    '}' +
                ']' +
            '}' +
            '\n```';

        Test.setMock(
            HttpCalloutMock.class,
            new GenAISuccessMock(aiContent)
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need account access',
                candidates
            );

        Test.stopTest();

        System.assertEquals(
            true,
            result.success,
            'JSON wrapped in markdown fences should still be parsed'
        );

        System.assertEquals(
            1,
            result.recommendations.size()
        );

        System.assertEquals(
            'IPA Account Manager',
            result.recommendations[0].roleLabel
        );
    }


    /*
    ================================================================
    SECTION 8 — HTTP / CALLOUT FAILURE
    ================================================================
    */

    @IsTest
    static void testRecommend_GenAIHttp500() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            createCandidates();

        Test.setMock(
            HttpCalloutMock.class,
            new GenAIErrorMock(500)
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need budget approval',
                candidates
            );

        Test.stopTest();

        System.assertEquals(
            false,
            result.success,
            'HTTP 500 should fail recommendation'
        );

        System.assertEquals(
            false,
            result.calloutSucceeded,
            'Failed HTTP call should not be considered a successful callout'
        );

        System.assertEquals(
            'AI service returned no usable content.',
            result.errorMessage
        );

        System.assertEquals(
            0,
            result.recommendations.size()
        );
    }


    @IsTest
    static void testRecommend_GenAIEmptyChoices() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            createCandidates();

        Test.setMock(
            HttpCalloutMock.class,
            new GenAIMalformedEnvelopeMock()
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need budget approval',
                candidates
            );

        Test.stopTest();

        System.assertEquals(
            false,
            result.success
        );

        System.assertEquals(
            false,
            result.calloutSucceeded
        );

        System.assertEquals(
            'AI service returned no usable content.',
            result.errorMessage
        );
    }


    /*
    ================================================================
    SECTION 9 — NULL / INVALID CONFIDENCE
    ================================================================
    */

    @IsTest
    static void testRecommend_InvalidConfidenceDoesNotBreakRecommendation() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            createCandidates();

        String aiContent =
            '{' +
                '"rewrittenQuery":"Need account access",' +
                '"needsClarification":false,' +
                '"clarificationQuestion":null,' +
                '"recommendations":[' +
                    '{' +
                        '"roleLabel":"IPA Account Manager",' +
                        '"confidence":"not-a-number",' +
                        '"reason":"Valid role but invalid confidence"' +
                    '}' +
                ']' +
            '}';

        Test.setMock(
            HttpCalloutMock.class,
            new GenAISuccessMock(aiContent)
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need account access',
                candidates
            );

        Test.stopTest();

        System.assertEquals(
            true,
            result.success
        );

        System.assertEquals(
            1,
            result.recommendations.size()
        );

        System.assertEquals(
            'IPA Account Manager',
            result.recommendations[0].roleLabel
        );

        System.assertEquals(
            null,
            result.recommendations[0].confidence,
            'Invalid confidence should safely become null'
        );
    }


    @IsTest
    static void testRecommend_NullConfidence() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            createCandidates();

        String aiContent =
            '{' +
                '"rewrittenQuery":"Need account access",' +
                '"needsClarification":false,' +
                '"clarificationQuestion":null,' +
                '"recommendations":[' +
                    '{' +
                        '"roleLabel":"IPA Account Manager",' +
                        '"confidence":null,' +
                        '"reason":"Valid role"' +
                    '}' +
                ']' +
            '}';

        Test.setMock(
            HttpCalloutMock.class,
            new GenAISuccessMock(aiContent)
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need account access',
                candidates
            );

        Test.stopTest();

        System.assertEquals(true, result.success);
        System.assertEquals(1, result.recommendations.size());
        System.assertEquals(null, result.recommendations[0].confidence);
    }


    /*
    ================================================================
    SECTION 10 — NULL / INVALID RECOMMENDATION ITEMS
    ================================================================
    */

    @IsTest
    static void testRecommend_InvalidRecommendationEntriesAreSkipped() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            createCandidates();

        String aiContent =
            '{' +
                '"rewrittenQuery":"Need access",' +
                '"needsClarification":false,' +
                '"clarificationQuestion":null,' +
                '"recommendations":[' +

                    'null,' +

                    '"invalid string",' +

                    '{' +
                        '"roleLabel":null,' +
                        '"confidence":0.5,' +
                        '"reason":"No label"' +
                    '},' +

                    '{' +
                        '"roleLabel":"IPA Account Manager",' +
                        '"confidence":0.90,' +
                        '"reason":"Valid recommendation"' +
                    '}' +

                ']' +
            '}';

        Test.setMock(
            HttpCalloutMock.class,
            new GenAISuccessMock(aiContent)
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need access',
                candidates
            );

        Test.stopTest();

        System.assertEquals(
            true,
            result.success
        );

        System.assertEquals(
            1,
            result.recommendations.size()
        );

        System.assertEquals(
            'IPA Account Manager',
            result.recommendations[0].roleLabel
        );
    }


    /*
    ================================================================
    SECTION 11 — CANDIDATE LIMIT
    ================================================================
    */

    @IsTest
    static void testRecommend_OnlyFirst15CandidatesAreScoped() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            new List<Core_MDF_IUPGM_Rule_Config__mdt>();

        for (Integer i = 1; i <= 20; i++) {

            candidates.add(
                createRole(
                    'Role ' + i,
                    'IPA',
                    'Purpose ' + i,
                    'keyword ' + i,
                    'Use case ' + i
                )
            );
        }

        /*
         * Role 16 is deliberately returned by the mock.
         * It is NOT among the first 15 candidates sent to the model,
         * so the guardrail must reject it.
         */
        String aiContent =
            '{' +
                '"rewrittenQuery":"Test",' +
                '"needsClarification":false,' +
                '"clarificationQuestion":null,' +
                '"recommendations":[' +
                    '{' +
                        '"roleLabel":"Role 16",' +
                        '"confidence":0.99,' +
                        '"reason":"Should not be available to model"' +
                    '}' +
                ']' +
            '}';

        Test.setMock(
            HttpCalloutMock.class,
            new GenAISuccessMock(aiContent)
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'Test',
                candidates
            );

        Test.stopTest();

        System.assertEquals(
            true,
            result.calloutSucceeded
        );

        System.assertEquals(
            false,
            result.success,
            'Role 16 is outside the first 15 scoped candidates'
        );

        System.assertEquals(
            0,
            result.recommendations.size()
        );
    }


    /*
    ================================================================
    SECTION 12 — DUPLICATE ROLE LABEL
    ================================================================
    */

    @IsTest
    static void testRecommend_DuplicateRoleLabels() {

        List<Core_MDF_IUPGM_Rule_Config__mdt> candidates =
            new List<Core_MDF_IUPGM_Rule_Config__mdt>{

                createRole(
                    'IPA Account Manager',
                    'IPA',
                    'First purpose',
                    'account',
                    'First use case'
                ),

                createRole(
                    'IPA Account Manager',
                    'IPA',
                    'Second purpose',
                    'account',
                    'Second use case'
                )
            };

        String aiContent =
            '{' +
                '"rewrittenQuery":"Account access",' +
                '"needsClarification":false,' +
                '"clarificationQuestion":null,' +
                '"recommendations":[' +
                    '{' +
                        '"roleLabel":"IPA Account Manager",' +
                        '"confidence":0.95,' +
                        '"reason":"Account management"' +
                    '}' +
                ']' +
            '}';

        Test.setMock(
            HttpCalloutMock.class,
            new GenAISuccessMock(aiContent)
        );

        Test.startTest();

        Core_MDF_IUPGMRoleRecommendationService.RecommendationResult result =
            Core_MDF_IUPGMRoleRecommendationService.recommend(
                'I need account access',
                candidates
            );

        Test.stopTest();

        System.assertEquals(
            true,
            result.success
        );

        System.assertEquals(
            1,
            result.recommendations.size()
        );

        System.assertEquals(
            'IPA Account Manager',
            result.recommendations[0].roleLabel
        );
    }

}