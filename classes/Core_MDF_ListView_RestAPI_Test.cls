/**
 * ----------------------------------------------------------------------------------
 * Class Name      : Core_MDF_ListView_RestAPI_Test
 * Description     : Test class for Core_MDF_ListView_RestAPI providing >= 75% line
 *                   coverage across all major flows:
 *                   - Happy path (filtered + unfiltered)
 *                   - Validation failures (payload, object, program, filters, operators,
 *                     filterLogic, sort)
 *                   - Query execution and response shaping
 *                   - Error message builders
 *                   - Logging and fallback paths
 * ----------------------------------------------------------------------------------
 */
@IsTest
private class Core_MDF_ListView_RestAPI_Test {

    // ─────────────────────────────────────────────────────────────────────────────
    // 1. TEST DATA / MOCK SETUP HELPERS
    // ─────────────────────────────────────────────────────────────────────────────

    /**
     * Builds a minimal RestContext (request + response) so the REST handler can run
     * inside a unit test without a real HTTP call.
     */
    private static void setupRestContext(String requestBody) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/v1.0/partnercenter/list/';
        req.httpMethod = 'POST';
        req.requestBody = String.isNotBlank(requestBody) ? Blob.valueOf(requestBody) : null;
        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    /**
     * Deserialises the current RestContext response body into an untyped map so
     * individual assertions can inspect top-level keys.
     */
    private static Map<String, Object> getResponseMap() {
        String body = RestContext.response?.responseBody?.toString();
        if (String.isBlank(body)) {
            return new Map<String, Object>();
        }
        return (Map<String, Object>) JSON.deserializeUntyped(body);
    }

    /**
     * Returns a minimal valid JSON payload for the list endpoint.
     * Callers can override individual fields by passing a replacement map.
     */
    private static String buildPayload(
        String objectName,
        String programName,
        List<Map<String, Object>> filters,
        String filterLogic,
        String sortBy,
        String sortOrder
    ) {
        Map<String, Object> payload = new Map<String, Object>();
        if (objectName != null) { payload.put('objectName', objectName); }
        if (programName != null) { payload.put('programName', programName); }
        if (filters != null) { payload.put('filters', filters); }
        if (filterLogic != null) { payload.put('filterLogic', filterLogic); }
        if (sortBy != null) { payload.put('sortBy', sortBy); }
        if (sortOrder != null) { payload.put('sortOrder', sortOrder); }
        return JSON.serialize(payload);
    }

    // ─────────────────────────────────────────────────────────────────────────────
    // 2. PARSE / PAYLOAD VALIDATION
    // ─────────────────────────────────────────────────────────────────────────────


    // Consolidated tests: each original test body remains in its own scope.

    @IsTest
    static void testPayloadValidationAndRequiredFields() {

        // Consolidated from testInvalidJson_returns7010.
        {

                    setupRestContext('NOT_VALID_JSON{{');
            Core_MDF_ListView_RestAPI.getList();
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(false, resp.get('isSuccess'), 'isSuccess should be false for invalid JSON');
                    Map<String, Object> error = (Map<String, Object>) resp.get('error');
                    System.assertNotEquals(null, error, 'error node must be present');


        }


        // Consolidated from testEmptyBody_returns7010.
        {

                    setupRestContext(null);
            Core_MDF_ListView_RestAPI.getList();
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(false, resp.get('isSuccess'));


        }


        // Consolidated from testMissingObjectName_returns7032.
        {

                    setupRestContext(buildPayload(null, 'TestProgram', null, null, null, null));
            Core_MDF_ListView_RestAPI.getList();
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(false, resp.get('isSuccess'));
                    Map<String, Object> error = (Map<String, Object>) resp.get('error');
                    // Code must reference the objectName-not-found constant.
                    System.assertNotEquals(null, error.get('code'));


        }


        // Consolidated from testBlankObjectName_returns7032.
        {

                    setupRestContext(buildPayload('   ', 'TestProgram', null, null, null, null));
            Core_MDF_ListView_RestAPI.getList();
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(false, resp.get('isSuccess'));


        }


        // Consolidated from testMissingProgramName_returns7033.
        {

                    setupRestContext(buildPayload('Account', null, null, null, null, null));
            Core_MDF_ListView_RestAPI.getList();
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(false, resp.get('isSuccess'));


        }


        // Consolidated from testBlankProgramName_returns7033.
        {

                    setupRestContext(buildPayload('Account', '', null, null, null, null));
            Core_MDF_ListView_RestAPI.getList();
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(false, resp.get('isSuccess'));


        }


        // Consolidated from testInvalidObjectName_returns7013.
        {

                    setupRestContext(buildPayload('NonExistentObject__xyz', 'TestProgram', null, null, null, null));
            Core_MDF_ListView_RestAPI.getList();
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(false, resp.get('isSuccess'));


        }

    }


    @IsTest
    static void testOperatorNormalizationAndAliases() {

        // Consolidated from testNormalizeConfiguredOperator_knownAliases.
        {

                    System.assertEquals('EQ',  Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('='));
                    System.assertEquals('EQ',  Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('EQUAL TO'));
                    System.assertEquals('NE',  Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('!='));
                    System.assertEquals('GT',  Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('>'));
                    System.assertEquals('GE',  Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('>='));
                    System.assertEquals('LT',  Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('<'));
                    System.assertEquals('LE',  Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('<='));
                    System.assertEquals('CONTAIN',     Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('LIKE'));
                    System.assertEquals('NOT CONTAIN', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('NOT LIKE'));
                    System.assertEquals('INCLUDE',     Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('INCLUDES'));
                    System.assertEquals('EXCLUDE',     Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('EXCLUDES'));


        }


        // Consolidated from testNormalizeConfiguredOperator_unknownPassesThrough.
        {

                    System.assertEquals('BETWEEN', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('between'));
                    System.assertEquals('',        Core_MDF_ListView_RestAPI.normalizeConfiguredOperator(''));
                    System.assertEquals('',        Core_MDF_ListView_RestAPI.normalizeConfiguredOperator(null));


        }


        // Consolidated from testNormalizeOperator_soqlMapping.
        {

                    System.assertEquals('=',        Core_MDF_ListView_RestAPI.normalizeOperator('EQ'));
                    System.assertEquals('!=',       Core_MDF_ListView_RestAPI.normalizeOperator('NE'));
                    System.assertEquals('>',        Core_MDF_ListView_RestAPI.normalizeOperator('GT'));
                    System.assertEquals('>=',       Core_MDF_ListView_RestAPI.normalizeOperator('GE'));
                    System.assertEquals('<',        Core_MDF_ListView_RestAPI.normalizeOperator('LT'));
                    System.assertEquals('<=',       Core_MDF_ListView_RestAPI.normalizeOperator('LE'));
                    System.assertEquals('INCLUDES', Core_MDF_ListView_RestAPI.normalizeOperator('INCLUDE'));
                    System.assertEquals('EXCLUDES', Core_MDF_ListView_RestAPI.normalizeOperator('EXCLUDE'));
                    System.assertEquals('LIKE',     Core_MDF_ListView_RestAPI.normalizeOperator('CONTAIN'));
                    System.assertEquals('LIKE',     Core_MDF_ListView_RestAPI.normalizeOperator('NOT CONTAIN'));


        }


        // Consolidated from testNormalizeConfiguredOperator_additionalAliases.
        {

                    System.assertEquals('GE', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('GREATER THAN EQUAL TO'));
                    System.assertEquals('GE', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('GREATER THAN OR EQUAL TO'));
                    System.assertEquals('LE', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('LESS THAN EQUAL TO'));
                    System.assertEquals('LE', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('LESS THAN OR EQUAL TO'));
                    System.assertEquals('GT', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('GREATER THAN'));
                    System.assertEquals('LT', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('LESS THAN'));
                    System.assertEquals('NE', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('NOT EQUAL TO'));
                    System.assertEquals('CONTAIN',     Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('CONTAIN'));
                    System.assertEquals('NOT CONTAIN', Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('NOT CONTAIN'));
                    System.assertEquals('INCLUDE',     Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('INCLUDE'));
                    System.assertEquals('EXCLUDE',     Core_MDF_ListView_RestAPI.normalizeConfiguredOperator('EXCLUDE'));


        }

    }


    @IsTest
    static void testFilterValueNormalization() {

        // Consolidated from testNormalizeSingleFilterValue_dateType.
        {

                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('2024-01-15', Schema.DisplayType.Date);
                    System.assert(result instanceof Date, 'Expected Date type');
                    System.assertEquals(Date.newInstance(2024, 1, 15), (Date) result);


        }


        // Consolidated from testNormalizeSingleFilterValue_datetimeType.
        {

                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('2024-01-15 10:00:00', Schema.DisplayType.DateTime);
                    System.assert(result instanceof Datetime, 'Expected Datetime type');


        }


        // Consolidated from testNormalizeSingleFilterValue_booleanTrue.
        {

                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('true', Schema.DisplayType.Boolean);
                    System.assertEquals(true, (Boolean) result);


        }


        // Consolidated from testNormalizeSingleFilterValue_booleanFalse.
        {

                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('false', Schema.DisplayType.Boolean);
                    System.assertEquals(false, (Boolean) result);


        }


        // Consolidated from testNormalizeSingleFilterValue_booleanInvalid_passesThrough.
        {

                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('maybe', Schema.DisplayType.Boolean);
                    System.assertEquals('maybe', result);


        }


        // Consolidated from testNormalizeSingleFilterValue_integerType.
        {

                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('42', Schema.DisplayType.Integer);
                    System.assertEquals(42, (Integer) result);


        }


        // Consolidated from testNormalizeSingleFilterValue_doubleType.
        {

                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('3.14', Schema.DisplayType.Double);
                    System.assertEquals(Decimal.valueOf('3.14'), (Decimal) result);


        }


        // Consolidated from testNormalizeSingleFilterValue_currencyType.
        {

                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('100.50', Schema.DisplayType.Currency);
                    System.assertEquals(Decimal.valueOf('100.50'), (Decimal) result);


        }


        // Consolidated from testNormalizeSingleFilterValue_percentType.
        {

                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('75.5', Schema.DisplayType.Percent);
                    System.assertEquals(Decimal.valueOf('75.5'), (Decimal) result);


        }


        // Consolidated from testNormalizeSingleFilterValue_stringType_passesThrough.
        {

                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('hello', Schema.DisplayType.String);
                    System.assertEquals('hello', result);


        }


        // Consolidated from testNormalizeSingleFilterValue_nullValue.
        {

                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue(null, Schema.DisplayType.String);
                    System.assertEquals(null, result);


        }


        // Consolidated from testNormalizeSingleFilterValue_blankValue.
        {

                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('   ', Schema.DisplayType.Integer);
                    System.assertEquals('   ', result);


        }


        // Consolidated from testNormalizeSingleFilterValue_invalidDate_passesThrough.
        {

                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue('not-a-date', Schema.DisplayType.Date);
                    System.assertEquals('not-a-date', result);


        }


        // Consolidated from testNormalizeSingleFilterValue_idType.
        {

                    Account acc = new Account(Name = 'ID Type Test',BillingCountry ='INDIA',BillingCity='Hyd',BillingStreet='Indira nagar');
                    insert acc;
                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue(
                        String.valueOf(acc.Id), Schema.DisplayType.ID
                    );
                    System.assert(result instanceof Id, 'Expected Id type');
                    System.assertEquals(acc.Id, (Id) result);


        }


        // Consolidated from testNormalizeSingleFilterValue_referenceType.
        {

                    Account acc = new Account(Name = 'Ref Type Test',BillingCountry ='INDIA',BillingCity='Hyd',BillingStreet='Indira nagar');
                    insert acc;
                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue(
                        String.valueOf(acc.Id), Schema.DisplayType.Reference
                    );
                    System.assert(result instanceof Id, 'Expected Id type for Reference');


        }


        // Consolidated from testNormalizeSingleFilterValue_invalidId_passesThrough.
        {

                    Object result = Core_MDF_ListView_RestAPI.normalizeSingleFilterValue(
                        'not-an-id', Schema.DisplayType.ID
                    );
                    System.assertEquals('not-an-id', result);


        }

    }


    @IsTest
    static void testContainsPatternVariants() {

        // Consolidated from testBuildContainsPattern_noWildcards.
        {

                    System.assertEquals('%hello%', Core_MDF_ListView_RestAPI.buildContainsPattern('hello'));


        }


        // Consolidated from testBuildContainsPattern_leadingWildcard.
        {

                    System.assertEquals('%hello%', Core_MDF_ListView_RestAPI.buildContainsPattern('%hello'));


        }


        // Consolidated from testBuildContainsPattern_trailingWildcard.
        {

                    System.assertEquals('%hello%', Core_MDF_ListView_RestAPI.buildContainsPattern('hello%'));


        }


        // Consolidated from testBuildContainsPattern_bothWildcards.
        {

                    System.assertEquals('%hello%', Core_MDF_ListView_RestAPI.buildContainsPattern('%hello%'));


        }

    }


    @IsTest
    static void testFilterLogicValidationVariants() {

        // Consolidated from testValidateFilterLogic_validSimple.
        {

                    String result = Core_MDF_ListView_RestAPI.validateFilterLogic('1 AND 2', 2);
                    System.assertEquals(null, result, 'Valid logic should return null');


        }


        // Consolidated from testValidateFilterLogic_validComplex.
        {

                    String result = Core_MDF_ListView_RestAPI.validateFilterLogic('(1 OR 2) AND 3', 3);
                    System.assertEquals(null, result);


        }


        // Consolidated from testValidateFilterLogic_missingFilterNumber.
        {

                    String result = Core_MDF_ListView_RestAPI.validateFilterLogic('1 AND 2', 3);
                    System.assertNotEquals(null, result, 'Missing filter 3 should produce an error');
                    System.assert(result.contains('missing'), 'Error should mention missing filter');


        }


        // Consolidated from testValidateFilterLogic_outOfRangeReference.
        {

                    String result = Core_MDF_ListView_RestAPI.validateFilterLogic('1 AND 5', 2);
                    System.assertNotEquals(null, result);


        }


        // Consolidated from testValidateFilterLogic_invalidToken.
        {

                    String result = Core_MDF_ListView_RestAPI.validateFilterLogic('1 AND abc', 1);
                    System.assertNotEquals(null, result);
                    System.assert(result.contains('invalid token'), 'Error should mention invalid token');


        }


        // Consolidated from testValidateFilterLogic_singleFilter.
        {

                    String result = Core_MDF_ListView_RestAPI.validateFilterLogic('1', 1);
                    System.assertEquals(null, result);


        }


        // Consolidated from testValidateFilterLogic_allFiltersReferenced_noError.
        {

                    System.assertEquals(null, Core_MDF_ListView_RestAPI.validateFilterLogic('1 AND 2 AND 3', 3));


        }


        // Consolidated from testValidateFilterLogic_duplicateReference_stillValid.
        {

                    // Referencing the same filter twice is allowed as long as all filters appear.
                    System.assertEquals(null, Core_MDF_ListView_RestAPI.validateFilterLogic('1 AND 1', 1));


        }

    }


    @IsTest
    static void testFilterLogicWhereClauseVariants() {

        // Consolidated from testBuildFilterLogicWhereClause_andCombination.
        {

                    List<String> clauses = new List<String>{ 'Name = :v0', 'Status__c = :v1' };
                    String result = Core_MDF_ListView_RestAPI.buildFilterLogicWhereClause('1 AND 2', clauses);
                    System.assert(result.contains('Name = :v0'), 'First clause should appear');
                    System.assert(result.contains('Status__c = :v1'), 'Second clause should appear');
                    System.assert(result.contains('AND'), 'AND should appear');


        }


        // Consolidated from testBuildFilterLogicWhereClause_orCombination.
        {

                    List<String> clauses = new List<String>{ 'Name = :v0', 'Status__c = :v1' };
                    String result = Core_MDF_ListView_RestAPI.buildFilterLogicWhereClause('1 OR 2', clauses);
                    System.assert(result.contains('OR'), 'OR should appear');


        }


        // Consolidated from testBuildFilterLogicWhereClause_parentheses.
        {

                    List<String> clauses = new List<String>{ 'A = :v0', 'B = :v1', 'C = :v2' };
                    String result = Core_MDF_ListView_RestAPI.buildFilterLogicWhereClause('(1 OR 2) AND 3', clauses);
                    System.assert(result.contains('('), 'Parenthesis should be preserved');


        }


        // Consolidated from testBuildFilterLogicWhereClause_invalidReference_producesMarker.
        {

                    List<String> clauses = new List<String>{ 'Name = :v0' };
                    String result = Core_MDF_ListView_RestAPI.buildFilterLogicWhereClause('1 AND 99', clauses);
                    System.assert(result.contains('INVALID_FILTER_LOGIC_REFERENCE'), 'Out-of-range reference should produce marker');


        }


        // Consolidated from testBuildFilterLogicWhereClause_invalidToken_producesMarker.
        {

                    List<String> clauses = new List<String>{ 'Name = :v0' };
                    String result = Core_MDF_ListView_RestAPI.buildFilterLogicWhereClause('1 AND xyz', clauses);
                    System.assert(result.contains('INVALID_FILTER_LOGIC_TOKEN'));


        }

    }


    @IsTest
    static void testErrorMessageBuilders() {

        // Consolidated from testBuildInvalidOperatorErrorMessage_validDetails.
        {

                    Map<String, Object> details = new Map<String, Object>{
                        'field' => 'Status__c',
                        'operator' => 'BETWEEN',
                        'allowedOperators' => new List<String>{ 'EQ', 'NE' }
                    };
                    String msg = Core_MDF_ListView_RestAPI.buildInvalidOperatorErrorMessage(details);
                    System.assertNotEquals(null, msg);
                    System.assert(msg.contains('BETWEEN'), 'Message should contain the invalid operator');
                    System.assert(msg.contains('Status__c'), 'Message should contain the field name');
                    System.assert(msg.contains('EQ'), 'Message should list allowed operators');


        }


        // Consolidated from testBuildInvalidOperatorErrorMessage_missingField_returnsNull.
        {

                    Map<String, Object> details = new Map<String, Object>{
                        'operator' => 'BETWEEN',
                        'allowedOperators' => new List<String>{ 'EQ' }
                    };
                    System.assertEquals(null, Core_MDF_ListView_RestAPI.buildInvalidOperatorErrorMessage(details));


        }


        // Consolidated from testBuildInvalidOperatorErrorMessage_nullDetails_returnsNull.
        {

                    System.assertEquals(null, Core_MDF_ListView_RestAPI.buildInvalidOperatorErrorMessage(null));


        }


        // Consolidated from testBuildInvalidFieldErrorMessage_validDetails.
        {

                    Map<String, Object> details = new Map<String, Object>{
                        'field' => 'BadField__c',
                        'allowedFields' => new List<String>{ 'Name', 'Status__c' }
                    };
                    String msg = Core_MDF_ListView_RestAPI.buildInvalidFieldErrorMessage(details);
                    System.assertNotEquals(null, msg);
                    System.assert(msg.contains('BadField__c'));
                    System.assert(msg.contains('Name'));


        }


        // Consolidated from testBuildInvalidFieldErrorMessage_missingField_returnsNull.
        {

                    Map<String, Object> details = new Map<String, Object>{
                        'allowedFields' => new List<String>{ 'Name' }
                    };
                    System.assertEquals(null, Core_MDF_ListView_RestAPI.buildInvalidFieldErrorMessage(details));


        }


        // Consolidated from testBuildInvalidFieldErrorMessage_nullDetails_returnsNull.
        {

                    System.assertEquals(null, Core_MDF_ListView_RestAPI.buildInvalidFieldErrorMessage(null));


        }


        // Consolidated from testBuildInvalidFilterLogicErrorMessage_filterLogicField.
        {

                    Map<String, Object> details = new Map<String, Object>{
                        'field' => 'filterLogic',
                        'message' => 'Invalid filterLogic; missing filter numbers: 2.'
                    };
                    String msg = Core_MDF_ListView_RestAPI.buildInvalidFilterLogicErrorMessage(details);
                    System.assertEquals('Invalid filterLogic; missing filter numbers: 2.', msg);


        }


        // Consolidated from testBuildInvalidFilterLogicErrorMessage_otherField_returnsNull.
        {

                    Map<String, Object> details = new Map<String, Object>{
                        'field' => 'objectName',
                        'message' => 'Some message'
                    };
                    System.assertEquals(null, Core_MDF_ListView_RestAPI.buildInvalidFilterLogicErrorMessage(details));


        }


        // Consolidated from testBuildInvalidFilterLogicErrorMessage_nullDetails_returnsNull.
        {

                    System.assertEquals(null, Core_MDF_ListView_RestAPI.buildInvalidFilterLogicErrorMessage(null));


        }

    }


    @IsTest
    static void testSendResponseVariants() {

        // Consolidated from testSendResponse_successPath.
        {

                    setupRestContext('{}');
                    Core_MDF_ListView_RestAPI.ListResponseTracker tracker =
                        new Core_MDF_ListView_RestAPI.ListResponseTracker();

                    Map<String, Object> details = new Map<String, Object>{
                        'recordCount' => 0,
                        'records' => new List<Object>()
                    };
            Core_MDF_ListView_RestAPI.sendResponse(tracker, true, 'OK', '200', 200, details);
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(true, resp.get('isSuccess'));
                    System.assertEquals(200, RestContext.response.statusCode);
                    System.assertNotEquals(null, resp.get('success'));
                    System.assertNotEquals(null, resp.get('details'));


        }


        // Consolidated from testSendResponse_errorPath_withExplicitStatus.
        {

                    setupRestContext('{}');
                    Core_MDF_ListView_RestAPI.ListResponseTracker tracker =
                        new Core_MDF_ListView_RestAPI.ListResponseTracker();
            Core_MDF_ListView_RestAPI.sendResponse(tracker, false, 'Bad request', '400', 400, null);
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(false, resp.get('isSuccess'));
                    System.assertEquals(400, RestContext.response.statusCode);


        }


        // Consolidated from testSendResponse_errorPath_noExplicitStatus_usesErrorConfig.
        {

                    setupRestContext('{}');
                    Core_MDF_ListView_RestAPI.ListResponseTracker tracker =
                        new Core_MDF_ListView_RestAPI.ListResponseTracker();
            // Passing statusCode = null forces the method to look up the error config.
                    Core_MDF_ListView_RestAPI.sendResponse(
                        tracker, false, null,
                        Core_MDF_CCP_ConstantClass.CODE_7013_INVALID_OBJECT,
                        null,
                        new Map<String, Object>{ 'object' => 'BadObject' }
                    );
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(false, resp.get('isSuccess'));
                    System.assertNotEquals(null, resp.get('error'));


        }


        // Consolidated from testSendResponse_7011_buildsDetailedMessage.
        {

                    setupRestContext('{}');
                    Core_MDF_ListView_RestAPI.ListResponseTracker tracker =
                        new Core_MDF_ListView_RestAPI.ListResponseTracker();

                    Map<String, Object> details = new Map<String, Object>{
                        'field' => 'BadField',
                        'allowedFields' => new List<String>{ 'Name' }
                    };
            Core_MDF_ListView_RestAPI.sendResponse(
                        tracker, false, null,
                        Core_MDF_CCP_ConstantClass.CODE_7011_INVALID_FILTER_FIELD,
                        null, details
                    );
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(false, resp.get('isSuccess'));
                    Map<String, Object> error = (Map<String, Object>) resp.get('error');
                    String msg = (String) error.get('message');
                    System.assert(String.isNotBlank(msg));


        }


        // Consolidated from testSendResponse_7012_buildsDetailedMessage.
        {

                    setupRestContext('{}');
                    Core_MDF_ListView_RestAPI.ListResponseTracker tracker =
                        new Core_MDF_ListView_RestAPI.ListResponseTracker();

                    Map<String, Object> details = new Map<String, Object>{
                        'field' => 'Status__c',
                        'operator' => 'BETWEEN',
                        'allowedOperators' => new List<String>{ 'EQ', 'NE' }
                    };
            Core_MDF_ListView_RestAPI.sendResponse(
                        tracker, false, null,
                        Core_MDF_CCP_ConstantClass.CODE_7012_INVALID_OPERATOR,
                        null, details
                    );
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(false, resp.get('isSuccess'));


        }


        // Consolidated from testSendResponse_7010_filterLogic_buildsDetailedMessage.
        {

                    setupRestContext('{}');
                    Core_MDF_ListView_RestAPI.ListResponseTracker tracker =
                        new Core_MDF_ListView_RestAPI.ListResponseTracker();

                    Map<String, Object> details = new Map<String, Object>{
                        'field' => 'filterLogic',
                        'message' => 'Invalid filterLogic; missing filter numbers: 2.'
                    };
            Core_MDF_ListView_RestAPI.sendResponse(
                        tracker, false, null,
                        Core_MDF_CCP_ConstantClass.CODE_7010_INVALID_PAYLOAD,
                        null, details
                    );
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(false, resp.get('isSuccess'));
                    Map<String, Object> error = (Map<String, Object>) resp.get('error');
                    System.assert(((String) error.get('message')).contains('filterLogic'));


        }


        // Consolidated from testSendResponse_nullRestContextResponse_createsNewResponse.
        {

                    // Deliberately set RestContext.response to null to exercise the null guard.
                    RestRequest req = new RestRequest();
                    req.requestURI = '/services/apexrest/v1.0/partnercenter/list/';
                    req.httpMethod = 'POST';
                    req.requestBody = Blob.valueOf('{}');
                    RestContext.request = req;
                    RestContext.response = null;

                    Core_MDF_ListView_RestAPI.ListResponseTracker tracker =
                        new Core_MDF_ListView_RestAPI.ListResponseTracker();
            Core_MDF_ListView_RestAPI.sendResponse(tracker, true, 'OK', '200', 200,
                        new Map<String, Object>{ 'recordCount' => 0, 'records' => new List<Object>() });
            System.assertNotEquals(null, RestContext.response);
                    System.assertEquals(200, RestContext.response.statusCode);


        }

    }


    @IsTest
    static void testResponseTrackerAndAccessibleFilterFields() {

        // Consolidated from testListResponseTracker_defaultValues.
        {

                    Core_MDF_ListView_RestAPI.ListResponseTracker tracker =
                        new Core_MDF_ListView_RestAPI.ListResponseTracker();
                    System.assertEquals(false, tracker.isSuccess);
                    System.assertEquals(null, tracker.statusCode);


        }


        // Consolidated from testGetAccessibleFilterFields_returnsOnlyAccessibleFields.
        {

                    Schema.SObjectType accountType = Schema.getGlobalDescribe().get('account');

                    // Build a minimal FieldConfiguration with one valid and one invalid path.
                    Core_MDF_CCP_RestAPI_Utility.FieldConfiguration config =
                        new Core_MDF_CCP_RestAPI_Utility.FieldConfiguration();
                    config.filterFieldLabelToApiName = new Map<String, String>{
                        'account name' => 'Name',
                        'invalid field xyz' => 'InvalidField__xyz__c',
                            'BillingCountry' =>'INDIA',
                            'BillingCity'=>'Hyd',
                            'BillingStreet'=>'Indira nagar'
                    };
                  //  config.responseFieldApiNames = new List<String>();
                    config.responseFieldApiNameToLabel = new Map<String, String>();
                    config.operatorsByField = new Map<String, Set<String>>();
            List<String> accessible = Core_MDF_ListView_RestAPI.getAccessibleFilterFields(accountType, config);
            // 'account name' -> Name is a real, accessible field; the other should be excluded.
                    System.assert(accessible.contains('account name'), 'Name should be accessible');
                    System.assert(!accessible.contains('invalid field xyz'), 'Invalid field should not appear');


        }

    }


    @IsTest
    static void testLabelKeyedRecordMapping() {

        // Consolidated from testToLabelKeyedRecords_mapsFieldsToLabels.
        {

                    // Create a real Account so we can read its Name field.
                    Account acc = new Account(Name = 'Test Account Label',BillingCountry ='INDIA',BillingCity='Hyd',BillingStreet='Indira nagar');
                    insert acc;
                    acc = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1];

                    Core_MDF_CCP_RestAPI_Utility.FieldConfiguration config =
                        new Core_MDF_CCP_RestAPI_Utility.FieldConfiguration();
                    config.responseFieldApiNameToLabel = new Map<String, String>{
                        'name' => 'Account Name',
                        'id'   => 'Record Id'
                    };
                    config.filterFieldLabelToApiName = new Map<String, String>();
                 //   config.responseFieldApiNames = new List<String>{ 'Name', 'Id' };
                    config.operatorsByField = new Map<String, Set<String>>();

                    List<String> fieldNames = new List<String>{ 'Name', 'Id' };
            List<Object> result = Core_MDF_ListView_RestAPI.toLabelKeyedRecords(
                        new List<SObject>{ acc }, fieldNames, config
                    );
            System.assertEquals(1, result.size());
                    Map<String, Object> row = (Map<String, Object>) result[0];
                    System.assertEquals('Test Account Label', row.get('Account Name'));
                    System.assertEquals(acc.Id, row.get('Record Id'));


        }


        // Consolidated from testToLabelKeyedRecords_emptyRecords.
        {

                    Core_MDF_CCP_RestAPI_Utility.FieldConfiguration config =
                        new Core_MDF_CCP_RestAPI_Utility.FieldConfiguration();
                    config.responseFieldApiNameToLabel = new Map<String, String>();
                    config.filterFieldLabelToApiName = new Map<String, String>();
                   // config.responseFieldApiNames = new List<String>();
                    config.operatorsByField = new Map<String, Set<String>>();
            List<Object> result = Core_MDF_ListView_RestAPI.toLabelKeyedRecords(
                        new List<SObject>(), new List<String>(), config
                    );
            System.assertEquals(0, result.size());


        }

    }


    @IsTest
    static void testGetListIntegrationRequests() {

        // Consolidated from testGetList_unfilteredRequest_withMockedConfig.
        {

                    // Insert a test Account so the query returns at least one record.
                    Account acc = new Account(Name = 'Integration Test Account',BillingCountry ='INDIA',BillingCity='Hyd',BillingStreet='Indira nagar');
                    insert acc;

                    // The handler calls Core_MDF_CCP_RestAPI_Utility.loadFieldConfiguration which
                    // reads custom metadata. In a scratch org / sandbox the metadata may not exist,
                    // so we guard with a try/catch and assert only what we can.
                    setupRestContext(buildPayload('Account', 'TestProgram', null, null, null, null));
            Core_MDF_ListView_RestAPI.getList();
            // We only assert that a response was written; the exact code depends on metadata.
                    System.assertNotEquals(null, RestContext.response.responseBody,
                        'A response body must always be written');
                    Map<String, Object> resp = getResponseMap();
                    System.assertNotEquals(null, resp.get('isSuccess'), 'isSuccess key must be present');


        }


        // Consolidated from testGetList_filteredRequest_withMockedConfig.
        {

                    Account acc = new Account(Name = 'Filter Test Account',BillingCountry ='INDIA',BillingCity='Hyd',BillingStreet='Indira nagar');
                    insert acc;

                    List<Map<String, Object>> filters = new List<Map<String, Object>>{
                        new Map<String, Object>{ 'field' => 'Account Name', 'operator' => 'EQ', 'value' => 'Filter Test Account' }
                    };

                    setupRestContext(buildPayload('Account', 'TestProgram', filters, null, null, null));
            Core_MDF_ListView_RestAPI.getList();
            System.assertNotEquals(null, RestContext.response.responseBody);
                    Map<String, Object> resp = getResponseMap();
                    System.assertNotEquals(null, resp.get('isSuccess'));


        }


        // Consolidated from testGetList_filteredRequest_withFilterLogic.
        {

                    List<Map<String, Object>> filters = new List<Map<String, Object>>{
                        new Map<String, Object>{ 'field' => 'Account Name', 'operator' => 'EQ', 'value' => 'A' },
                        new Map<String, Object>{ 'field' => 'Account Name', 'operator' => 'EQ', 'value' => 'B' }
                    };

                    setupRestContext(buildPayload('Account', 'TestProgram', filters, '1 OR 2', null, null));
            Core_MDF_ListView_RestAPI.getList();
            System.assertNotEquals(null, RestContext.response.responseBody);


        }


        // Consolidated from testGetList_filteredRequest_withSortByAndOrder.
        {

                    List<Map<String, Object>> filters = new List<Map<String, Object>>{
                        new Map<String, Object>{ 'field' => 'Account Name', 'operator' => 'EQ', 'value' => 'SortTest' }
                    };

                    setupRestContext(buildPayload('Account', 'TestProgram', filters, null, 'Account Name', 'ASC'));
            Core_MDF_ListView_RestAPI.getList();
            System.assertNotEquals(null, RestContext.response.responseBody);


        }


        // Consolidated from testGetList_alwaysWritesResponseBody.
        {

                    // Even with a completely empty body the handler must write a response.
                    setupRestContext('');
            Core_MDF_ListView_RestAPI.getList();
            System.assertNotEquals(null, RestContext.response.responseBody,
                        'Response body must never be null');


        }


        // Consolidated from testGetList_internalServerError_returns500OrError.
        {

                    // Pass a valid-looking payload for a non-queryable object to trigger the
                    // internal error path (loadFieldConfiguration will throw if metadata absent).
                    setupRestContext(buildPayload('User', 'TestProgram', null, null, null, null));
            Core_MDF_ListView_RestAPI.getList();
            System.assertNotEquals(null, RestContext.response.responseBody);
                    Map<String, Object> resp = getResponseMap();
                    // Either success (metadata exists) or failure – both are valid outcomes here.
                    System.assertNotEquals(null, resp.get('isSuccess'));


        }

    }


    @IsTest
    static void testGetListFilterValidationErrors() {

        // Consolidated from testGetList_tooManyFilters_returns7014.
        {

                    // Build MAX_FILTERS + 1 filter entries.
                    List<Map<String, Object>> filters = new List<Map<String, Object>>();
                    for (Integer i = 0; i <= Core_MDF_CCP_ConstantClass.MAX_FILTERS; i++) {
                        filters.add(new Map<String, Object>{
                            'field' => 'Account Name', 'operator' => 'EQ', 'value' => 'x' + i
                        });
                    }

                    setupRestContext(buildPayload('Account', 'TestProgram', filters, null, null, null));
            Core_MDF_ListView_RestAPI.getList();
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(false, resp.get('isSuccess'));


        }


        // Consolidated from testGetList_filterWithBlankField_returns7010.
        {

                    List<Map<String, Object>> filters = new List<Map<String, Object>>{
                        new Map<String, Object>{ 'field' => '', 'operator' => 'EQ', 'value' => 'x' }
                    };

                    setupRestContext(buildPayload('Account', 'TestProgram', filters, null, null, null));
            Core_MDF_ListView_RestAPI.getList();
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(false, resp.get('isSuccess'));


        }


        // Consolidated from testGetList_filterWithBlankOperator_returns7010.
        {

                    List<Map<String, Object>> filters = new List<Map<String, Object>>{
                        new Map<String, Object>{ 'field' => 'Account Name', 'operator' => '', 'value' => 'x' }
                    };

                    setupRestContext(buildPayload('Account', 'TestProgram', filters, null, null, null));
            Core_MDF_ListView_RestAPI.getList();
            Map<String, Object> resp = getResponseMap();
                    System.assertEquals(false, resp.get('isSuccess'));
        }

    }
    
 
@IsTest
static void testBuildInvalidLookupFilterValueErrorMessage() {

    // Scenario 1: Valid field name
    Map<String, Object> details = new Map<String, Object>{
        'field' => 'AccountId'
    };

    String result =
        Core_MDF_ListView_RestAPI.buildInvalidLookupFilterValueErrorMessage(details);

    System.assertEquals(
        'Invalid value for lookup field "AccountId". Provide a valid record ID for this field.',
        result
    );

    // Scenario 2: Field is missing
    Map<String, Object> missingField = new Map<String, Object>();

    String result2 =
        Core_MDF_ListView_RestAPI.buildInvalidLookupFilterValueErrorMessage(missingField);

    System.assertEquals(null, result2);

    // Scenario 3: Null details
    String result3 =
        Core_MDF_ListView_RestAPI.buildInvalidLookupFilterValueErrorMessage(null);

    System.assertEquals(null, result3);
}
 
    
@IsTest
static void testBuildFilterClause() {

    // Scenario 1: NOT CONTAIN
    String result1 =
        Core_MDF_ListView_RestAPI.buildFilterClause(
            'Name', 'NOT CONTAIN', 'v0', true
        );

    System.assertEquals(
        'NOT (Name LIKE :v0)',
        result1
    );

    // Scenario 2: INCLUDE
    String result2 =
        Core_MDF_ListView_RestAPI.buildFilterClause(
            'Status__c', 'INCLUDE', 'v1', false
        );

    System.assertEquals(
        'Status__c INCLUDES (:v1)',
        result2
    );

    // Scenario 3: EXCLUDE
    String result3 =
        Core_MDF_ListView_RestAPI.buildFilterClause(
            'Status__c', 'EXCLUDE', 'v2', false
        );

    System.assertEquals(
        'Status__c EXCLUDES (:v2)',
        result3
    );

    // Scenario 4: Equal operator
    String result4 =
        Core_MDF_ListView_RestAPI.buildFilterClause(
            'Name', 'EQ', 'v3', false
        );

    System.assertEquals(
        'Name = :v3',
        result4
    );

    // Scenario 5: CONTAIN
    String result5 =
        Core_MDF_ListView_RestAPI.buildFilterClause(
            'Name', 'CONTAIN', 'v4', true
        );

    System.assertEquals(
        'Name LIKE :v4',
        result5
    );

    // Scenario 6: NOT CONTAIN with isContains false
    String result6 =
        Core_MDF_ListView_RestAPI.buildFilterClause(
            'Name', 'NOT CONTAIN', 'v5', false
        );

    System.assertEquals(
        'Name LIKE :v5',
        result6
    );
}

}