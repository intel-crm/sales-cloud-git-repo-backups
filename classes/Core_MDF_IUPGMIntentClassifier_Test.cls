@IsTest(SeeAllData=false)
public class Core_MDF_IUPGMIntentClassifier_Test {

    /*
     * ============================================================
     * HTTP MOCK
     * ============================================================
     */

    private class GenAIMock implements HttpCalloutMock {

        private Integer statusCode;
        private String responseBody;

        GenAIMock(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
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
                req.getHeader('Content-Type')
            );

            System.assert(
                req.getBody().contains('messages'),
                'Request should contain GenAI messages'
            );

            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);

            return res;
        }
    }

    /*
     * ============================================================
     * RESPONSE HELPERS
     * ============================================================
     */

    private static String createAIResponse(String content) {

        return '{"choices":[' +
            '{"message":{' +
                '"content":' + JSON.serialize(content) +
            '}}' +
        ']}';
    }

    private static String validResponse(
        String intent,
        Decimal confidence,
        String sourceUser,
        String targetUser,
        String role,
        String program,
        Boolean needsClarification,
        String clarificationQuestion
    ) {

        Map<String, Object> response = new Map<String, Object>{
            'intent' => intent,
            'confidence' => confidence,
            'sourceUser' => sourceUser,
            'targetUser' => targetUser,
            'role' => role,
            'program' => program,
            'needsClarification' => needsClarification,
            'clarificationQuestion' => clarificationQuestion
        };

        return JSON.serialize(response);
    }

    private static void setSuccessMock(String aiContent) {

        Test.setMock(
            HttpCalloutMock.class,
            new GenAIMock(200, createAIResponse(aiContent))
        );
    }

    /*
     * ============================================================
     * SECTION 1 - INPUT VALIDATION
     * ============================================================
     */

    @IsTest
    static void testClassifyIntent_NullQuery() {

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(null);

        Test.stopTest();

        System.assertEquals(false, result.isValid);
        System.assertEquals('Empty query.', result.errorMessage);
        System.assertEquals(null, result.intent);
    }

    @IsTest
    static void testClassifyIntent_BlankQuery() {

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent('   ');

        Test.stopTest();

        System.assertEquals(false, result.isValid);
        System.assertEquals('Empty query.', result.errorMessage);
    }

    @IsTest
    static void testClassifyIntent_QueryExceedsMaximumLength() {

        String longQuery = '';

        for (Integer i = 0; i < 2001; i++) {
            longQuery += 'A';
        }

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(longQuery);

        Test.stopTest();

        System.assertEquals(false, result.isValid);

        System.assertEquals(
            'Query exceeds maximum length for classification.',
            result.errorMessage
        );

        System.assertEquals(null, result.intent);
    }

    /*
     * ============================================================
     * SECTION 2 - SUCCESSFUL INTENT CLASSIFICATION
     * ============================================================
     */

    @IsTest
    static void testClassifyIntent_CopyAccess() {

        String query =
            'Copy access from Ramapriya to Nandini for IPA CCF Operations Admin';

        String aiContent = validResponse(
            'COPY_ACCESS',
            0.96,
            'Ramapriya',
            'Nandini',
            'CCF Operations Admin',
            'IPA',
            false,
            null
        );

        setSuccessMock(aiContent);

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(query);

        Test.stopTest();

        System.assertEquals(true, result.isValid);
        System.assertEquals('COPY_ACCESS', result.intent);
        System.assertEquals(Decimal.valueOf('0.96'), result.confidence);

        System.assertEquals('Ramapriya', result.sourceUser);
        System.assertEquals('Nandini', result.targetUser);
        System.assertEquals('CCF Operations Admin', result.role);
        System.assertEquals('IPA', result.program);

        System.assertEquals(false, result.needsClarification);
    }

    @IsTest
    static void testClassifyIntent_GrantAccess() {

        String query = 'Grant John CCF Operations Admin access';

        setSuccessMock(
            validResponse(
                'GRANT',
                0.95,
                null,
                'John',
                'CCF Operations Admin',
                null,
                false,
                null
            )
        );

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(query);

        Test.stopTest();

        System.assertEquals(true, result.isValid);
        System.assertEquals('GRANT', result.intent);
        System.assertEquals('John', result.targetUser);
        System.assertEquals('CCF Operations Admin', result.role);
        System.assertEquals(null, result.sourceUser);
    }

    @IsTest
    static void testClassifyIntent_RevokeAccess() {

        String query = 'Revoke Ramapriya access to IPA';

        setSuccessMock(
            validResponse(
                'REVOKE',
                0.94,
                null,
                'Ramapriya',
                null,
                'IPA',
                false,
                null
            )
        );

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(query);

        Test.stopTest();

        System.assertEquals(true, result.isValid);
        System.assertEquals('REVOKE', result.intent);
        System.assertEquals('Ramapriya', result.targetUser);
        System.assertEquals('IPA', result.program);
    }

    @IsTest
    static void testClassifyIntent_ListAccess() {

        String query = 'Show me the access assigned to John';

        setSuccessMock(
            validResponse(
                'LIST_ACCESS',
                0.93,
                null,
                'John',
                null,
                null,
                false,
                null
            )
        );

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(query);

        Test.stopTest();

        System.assertEquals(true, result.isValid);
        System.assertEquals('LIST_ACCESS', result.intent);
        System.assertEquals('John', result.targetUser);
    }

    @IsTest
    static void testClassifyIntent_StatusAccess() {

        String query = 'Check the status of my latest request';

        setSuccessMock(
            validResponse(
                'STATUS_ACCESS',
                0.92,
                null,
                null,
                null,
                null,
                false,
                null
            )
        );

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(query);

        Test.stopTest();

        System.assertEquals(true, result.isValid);
        System.assertEquals('STATUS_ACCESS', result.intent);
        System.assertEquals(false, result.needsClarification);
    }

    /*
     * ============================================================
     * SECTION 3 - CLARIFICATION
     * ============================================================
     */

    @IsTest
    static void testClassifyIntent_ClarificationRequired() {

        String query = 'I need access';

        setSuccessMock(
            validResponse(
                'CLARIFY',
                0.90,
                null,
                null,
                null,
                null,
                true,
                'Which employee and role do you need access for?'
            )
        );

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(query);

        Test.stopTest();

        System.assertEquals(true, result.isValid);
        System.assertEquals('CLARIFY', result.intent);
        System.assertEquals(true, result.needsClarification);

        System.assertEquals(
            'Which employee and role do you need access for?',
            result.clarificationQuestion
        );
    }

    @IsTest
    static void testClassifyIntent_ClarificationWithOtherIntent() {

        String query = 'Grant me access';

        setSuccessMock(
            validResponse(
                'GRANT',
                0.75,
                null,
                null,
                null,
                null,
                true,
                'Which role do you need?'
            )
        );

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(query);

        Test.stopTest();

        System.assertEquals(true, result.isValid);
        System.assertEquals('GRANT', result.intent);
        System.assertEquals(true, result.needsClarification);
        System.assertEquals('Which role do you need?', result.clarificationQuestion);
    }

    /*
     * ============================================================
     * SECTION 4 - ENTITY VALIDATION
     * ============================================================
     */

    @IsTest
    static void testClassifyIntent_HallucinatedEntitiesAreDropped() {

        String query = 'Grant John access';

        setSuccessMock(
            validResponse(
                'GRANT',
                0.95,
                null,
                'John',
                'Super Administrator',
                'WW',
                false,
                null
            )
        );

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(query);

        Test.stopTest();

        System.assertEquals(true, result.isValid);
        System.assertEquals('John', result.targetUser);

        System.assertEquals(
            null,
            result.role,
            'Role not present in the original query must be dropped'
        );

        System.assertEquals(
            null,
            result.program,
            'Program not present in the original query must be dropped'
        );
    }

    @IsTest
    static void testClassifyIntent_EntityPunctuationIsCleaned() {

        String query = 'Grant access to john.smith@intel.com.';

        setSuccessMock(
            validResponse(
                'GRANT',
                0.95,
                null,
                'john.smith@intel.com.',
                null,
                null,
                false,
                null
            )
        );

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(query);

        Test.stopTest();

        System.assertEquals(true, result.isValid);

        System.assertEquals(
            'john.smith@intel.com',
            result.targetUser,
            'Wrapping punctuation should be removed from the entity'
        );
    }

    @IsTest
    static void testClassifyIntent_InvalidEntityType() {

        String query = 'Grant John access';

        Map<String, Object> response = new Map<String, Object>{
            'intent' => 'GRANT',
            'confidence' => 0.95,
            'sourceUser' => null,
            'targetUser' => 12345,
            'role' => null,
            'program' => null,
            'needsClarification' => false,
            'clarificationQuestion' => null
        };

        setSuccessMock(JSON.serialize(response));

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(query);

        Test.stopTest();

        System.assertEquals(false, result.isValid);

        System.assertEquals(
            'Invalid type for an optional field.',
            result.errorMessage
        );
    }

    /*
     * ============================================================
     * SECTION 5 - CONFIDENCE VALIDATION
     * ============================================================
     */

    @IsTest
    static void testClassifyIntent_ConfidenceZero() {

        setSuccessMock(
            validResponse(
                'LIST_ACCESS',
                0,
                null,
                null,
                null,
                null,
                false,
                null
            )
        );

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(
                'What access do I have?'
            );

        Test.stopTest();

        System.assertEquals(true, result.isValid);
        System.assertEquals(Decimal.valueOf('0'), result.confidence);
    }

    @IsTest
    static void testClassifyIntent_ConfidenceOne() {

        setSuccessMock(
            validResponse(
                'LIST_ACCESS',
                1,
                null,
                null,
                null,
                null,
                false,
                null
            )
        );

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(
                'What access do I have?'
            );

        Test.stopTest();

        System.assertEquals(true, result.isValid);
        System.assertEquals(Decimal.valueOf('1'), result.confidence);
    }

    @IsTest
    static void testClassifyIntent_ConfidenceOutOfRange() {

        String aiContent =
            '{"intent":"GRANT",' +
            '"confidence":1.5,' +
            '"needsClarification":false}';

        setSuccessMock(aiContent);

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(
                'Grant John access'
            );

        Test.stopTest();

        System.assertEquals(false, result.isValid);
        System.assertEquals('Invalid confidence value.', result.errorMessage);
    }

    @IsTest
    static void testClassifyIntent_MissingConfidence() {

        String aiContent =
            '{"intent":"GRANT",' +
            '"needsClarification":false}';

        setSuccessMock(aiContent);

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(
                'Grant John access'
            );

        Test.stopTest();

        System.assertEquals(false, result.isValid);

        System.assertEquals(
            'Missing mandatory field in AI response.',
            result.errorMessage
        );
    }

    /*
     * ============================================================
     * SECTION 6 - STRICT RESPONSE VALIDATION
     * ============================================================
     */

    @IsTest
    static void testClassifyIntent_UnsupportedIntent() {

        String aiContent =
            '{"intent":"DELETE_USER",' +
            '"confidence":0.95,' +
            '"needsClarification":false}';

        setSuccessMock(aiContent);

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(
                'Delete John'
            );

        Test.stopTest();

        System.assertEquals(false, result.isValid);
        System.assertEquals('Unsupported intent.', result.errorMessage);
    }

    @IsTest
    static void testClassifyIntent_InvalidNeedsClarificationType() {

        String aiContent =
            '{"intent":"GRANT",' +
            '"confidence":0.95,' +
            '"needsClarification":"false"}';

        setSuccessMock(aiContent);

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(
                'Grant John access'
            );

        Test.stopTest();

        System.assertEquals(false, result.isValid);

        System.assertEquals(
            'Invalid needsClarification type.',
            result.errorMessage
        );
    }

    @IsTest
    static void testClassifyIntent_InconsistentClarifyResponse() {

        String aiContent =
            '{"intent":"CLARIFY",' +
            '"confidence":0.95,' +
            '"needsClarification":false}';

        setSuccessMock(aiContent);

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(
                'I need help'
            );

        Test.stopTest();

        System.assertEquals(false, result.isValid);

        System.assertEquals(
            'Inconsistent CLARIFY response (needsClarification was not true).',
            result.errorMessage
        );
    }

    @IsTest
    static void testClassifyIntent_MissingMandatoryField() {

        String aiContent =
            '{"intent":"GRANT",' +
            '"confidence":0.95}';

        setSuccessMock(aiContent);

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(
                'Grant John access'
            );

        Test.stopTest();

        System.assertEquals(false, result.isValid);
        System.assertEquals(
            'Missing mandatory field in AI response.',
            result.errorMessage
        );
    }

    /*
     * ============================================================
     * SECTION 7 - JSON PARSING
     * ============================================================
     */

    @IsTest
    static void testClassifyIntent_MalformedAIJson() {

        setSuccessMock('This is not valid JSON');

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(
                'Grant John access'
            );

        Test.stopTest();

        System.assertEquals(false, result.isValid);

        System.assertEquals(
            'Malformed JSON from GenAI.',
            result.errorMessage
        );
    }

    @IsTest
    static void testClassifyIntent_JsonInsideMarkdownFence() {

        String aiContent =
            '```json\n' +
            '{"intent":"LIST_ACCESS",' +
            '"confidence":0.95,' +
            '"targetUser":"John",' +
            '"needsClarification":false}' +
            '\n```';

        setSuccessMock(aiContent);

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(
                'Show John access'
            );

        Test.stopTest();

        System.assertEquals(true, result.isValid);
        System.assertEquals('LIST_ACCESS', result.intent);
        System.assertEquals('John', result.targetUser);
    }

    @IsTest
    static void testClassifyIntent_EmptyChoices() {

        Test.setMock(
            HttpCalloutMock.class,
            new GenAIMock(200, '{"choices":[]}')
        );

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(
                'Grant John access'
            );

        Test.stopTest();

        System.assertEquals(false, result.isValid);
        System.assertEquals('No GenAI response.', result.errorMessage);
    }

    /*
     * ============================================================
     * SECTION 8 - HTTP FAILURE
     * ============================================================
     */

    @IsTest
    static void testClassifyIntent_GenAIHttp500() {

        Test.setMock(
            HttpCalloutMock.class,
            new GenAIMock(
                500,
                '{"error":{"message":"Mock GenAI failure"}}'
            )
        );

        Test.startTest();

        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(
                'Grant John access'
            );

        Test.stopTest();

        System.assertEquals(false, result.isValid);
        System.assertEquals('No GenAI response.', result.errorMessage);
    }

    @IsTest
    static void testClassifyIntent_MalformedResponseEnvelope() {

        Test.setMock(
            HttpCalloutMock.class,
            new GenAIMock(200, '{"invalid":"response"}')
        );

        Test.startTest();
        Core_MDF_IUPGMIntentClassifier.IntentResult result =
            Core_MDF_IUPGMIntentClassifier.classifyIntent(
                'Grant John access'
            );

        Test.stopTest();

        System.assertEquals(false, result.isValid);
        System.assertEquals('Intent classification failed.', result.errorMessage);
    }
}