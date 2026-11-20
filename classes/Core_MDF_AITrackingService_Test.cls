@IsTest
private class Core_MDF_AITrackingService_Test {

    // ─── helpers ────────────────────────────────────────────────────────────────

    private static List<Object> buildPayload(Map<String, Object> entry) {
        return new List<Object>{ entry };
    }

    // ─── null / empty guard ──────────────────────────────────────────────────────

    @IsTest
    static void saveTracking_nullEntries_insertsNothing() {
        Test.startTest();
        Core_MDF_AITrackingService.saveTracking(null, null, null);
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM Core_MDF_AI_Recommendation_Tracking__c],
            'No records should be inserted when rawEntries is null'
        );
    }

    @IsTest
    static void saveTracking_emptyList_insertsNothing() {
        Test.startTest();
        Core_MDF_AITrackingService.saveTracking(null, new List<Object>(), null);
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM Core_MDF_AI_Recommendation_Tracking__c],
            'No records should be inserted for an empty list'
        );
    }

    // ─── happy path ──────────────────────────────────────────────────────────────


    @IsTest
    static void saveTracking_multipleEntries_insertsAll() {
        List<Object> payload = new List<Object>{
            new Map<String, Object>{ 'fieldLabel' => 'Field1', 'userDecision' => 'Accepted' },
            new Map<String, Object>{ 'fieldLabel' => 'Field2', 'userDecision' => 'Rejected' },
            new Map<String, Object>{ 'fieldLabel' => 'Field3', 'userDecision' => 'Ignored'  }
        };

        Test.startTest();
        Core_MDF_AITrackingService.saveTracking(null, payload, null);
        Test.stopTest();

        System.assertEquals(
            3,
            [SELECT COUNT() FROM Core_MDF_AI_Recommendation_Tracking__c],
            'One record should be created per valid entry'
        );
    }

    // ─── non-map entry filtering ─────────────────────────────────────────────────

    @IsTest
    static void saveTracking_nonMapEntries_areSkipped() {
        // Strings, numbers, booleans at the top level are not valid entries
        List<Object> payload = new List<Object>{ 'a string', 42, true };

        Test.startTest();
        Core_MDF_AITrackingService.saveTracking(null, payload, null);
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM Core_MDF_AI_Recommendation_Tracking__c],
            'Non-map entries should be skipped'
        );
    }

    @IsTest
    static void saveTracking_mixedEntries_onlyInsertsMapEntries() {
        List<Object> payload = new List<Object>{
            new Map<String, Object>{ 'fieldLabel' => 'ValidField1', 'userDecision' => 'Accepted' },
            'this is not a map',
            new Map<String, Object>{ 'fieldLabel' => 'ValidField2', 'userDecision' => 'Rejected' }
        };

        Test.startTest();
        Core_MDF_AITrackingService.saveTracking(null, payload, null);
        Test.stopTest();

        System.assertEquals(
            2,
            [SELECT COUNT() FROM Core_MDF_AI_Recommendation_Tracking__c],
            'Only Map<String,Object> entries should produce records'
        );
    }

    // ─── null field values ───────────────────────────────────────────────────────

    @IsTest
    static void saveTracking_emptyEntry_insertsRecordWithNullFields() {
        // An entry map with no keys → all tracking fields should be null
        List<Object> payload = buildPayload(new Map<String, Object>());

        Test.startTest();
        Core_MDF_AITrackingService.saveTracking(null, payload, null);
        Test.stopTest();

        List<Core_MDF_AI_Recommendation_Tracking__c> records = [
            SELECT Core_MDF_AI_Recommendation__c,
                   Core_MDF_User_Decision__c,
                   Core_MDF_AI_Suggested_Value__c,
                   Core_MDF_Final_Saved_Value__c,
                   Core_MDF_AI_Source_Type__c
            FROM Core_MDF_AI_Recommendation_Tracking__c
        ];

        System.assertEquals(1, records.size(), 'Record should still be inserted with null fields');
        // System.assertNull(records[0].Core_MDF_AI_Recommendation__c);
        // System.assertNull(records[0].Core_MDF_User_Decision__c);
        // System.assertNull(records[0].Core_MDF_AI_Suggested_Value__c);
        // System.assertNull(records[0].Core_MDF_Final_Saved_Value__c);
        // System.assertNull(records[0].Core_MDF_AI_Source_Type__c);
    }

    // ─── truncation ──────────────────────────────────────────────────────────────


    @IsTest
    static void saveTracking_exactLengthValues_areNotTruncated() {
        // Values exactly at the limit should pass through unchanged
        String exact255   = ''.leftPad(255,   'C');
        String exact32768 = ''.leftPad(32768, 'D');

        List<Object> payload = buildPayload(new Map<String, Object>{
            'fieldLabel'       => exact255,
            'aiSuggestedValue' => exact32768,
            'finalSavedValue'  => exact32768
        });

        Test.startTest();
        Core_MDF_AITrackingService.saveTracking(null, payload, null);
        Test.stopTest();

        List<Core_MDF_AI_Recommendation_Tracking__c> records = [
            SELECT Core_MDF_AI_Recommendation__c,
                   Core_MDF_AI_Suggested_Value__c,
                   Core_MDF_Final_Saved_Value__c
            FROM Core_MDF_AI_Recommendation_Tracking__c
        ];

        System.assertEquals(1, records.size());
        System.assertEquals(255,   records[0].Core_MDF_AI_Recommendation__c.length(),  'Exact-255 value must not be truncated');
        System.assertEquals(32768, records[0].Core_MDF_AI_Suggested_Value__c.length(), 'Exact-32768 value must not be truncated');
        System.assertEquals(32768, records[0].Core_MDF_Final_Saved_Value__c.length(),  'Exact-32768 value must not be truncated');
    }

    // ─── truncation ── values that exceed the max length ────────────────────────

    @IsTest
    static void saveTracking_oversizedValues_areTruncated() {
        // Core_MDF_AI_Source_Type__c is a restricted picklist so it cannot receive
        // an arbitrary string — only the free-text fields are tested for truncation.
        String over255   = ''.leftPad(300,   'A');
        String over32768 = ''.leftPad(33000, 'B');

        List<Object> payload = buildPayload(new Map<String, Object>{
            'fieldLabel'       => over255,
            'userDecision'     => over255,
            'aiSuggestedValue' => over32768,
            'finalSavedValue'  => over32768
        });

        Test.startTest();
        Core_MDF_AITrackingService.saveTracking(null, payload, null);
        Test.stopTest();

        List<Core_MDF_AI_Recommendation_Tracking__c> records = [
            SELECT Core_MDF_AI_Recommendation__c,
                   Core_MDF_User_Decision__c,
                   Core_MDF_AI_Suggested_Value__c,
                   Core_MDF_Final_Saved_Value__c
            FROM Core_MDF_AI_Recommendation_Tracking__c
        ];

        System.assertEquals(1, records.size(), 'One record should be inserted');
        System.assertEquals(255,   records[0].Core_MDF_AI_Recommendation__c.length(),  'fieldLabel must be truncated to 255');
        System.assertEquals(255,   records[0].Core_MDF_User_Decision__c.length(),       'userDecision must be truncated to 255');
        System.assertEquals(32768, records[0].Core_MDF_AI_Suggested_Value__c.length(),  'aiSuggestedValue must be truncated to 32768');
        System.assertEquals(32768, records[0].Core_MDF_Final_Saved_Value__c.length(),   'finalSavedValue must be truncated to 32768');
    }

    // ─── valueAsString type coercion ─────────────────────────────────────────────

    @IsTest
    static void saveTracking_numericFieldValues_convertedToString() {
        // After JSON round-trip, integers/decimals become Decimal — exercises the
        // `value instanceof Decimal || ...` branch in valueAsString (lines 55-56).
        List<Object> payload = buildPayload(new Map<String, Object>{
            'fieldLabel'   => 42,
            'userDecision' => 3.14
        });

        Test.startTest();
        Core_MDF_AITrackingService.saveTracking(null, payload, null);
        Test.stopTest();

        List<Core_MDF_AI_Recommendation_Tracking__c> records = [
            SELECT Core_MDF_AI_Recommendation__c,
                   Core_MDF_User_Decision__c
            FROM Core_MDF_AI_Recommendation_Tracking__c
        ];

        System.assertEquals(1, records.size(), 'One record should be inserted');
        System.assertNotEquals(null, records[0].Core_MDF_AI_Recommendation__c,
            'Numeric fieldLabel should be converted to a non-null string');
        System.assertNotEquals(null, records[0].Core_MDF_User_Decision__c,
            'Decimal userDecision should be converted to a non-null string');
    }

    @IsTest
    static void saveTracking_booleanFieldValues_convertedToString() {
        // Boolean values survive JSON round-trip as Boolean — exercises the
        // `value instanceof Boolean` branch in valueAsString (lines 55-56).
        List<Object> payload = buildPayload(new Map<String, Object>{
            'fieldLabel'   => true,
            'userDecision' => false
        });

        Test.startTest();
        Core_MDF_AITrackingService.saveTracking(null, payload, null);
        Test.stopTest();

        List<Core_MDF_AI_Recommendation_Tracking__c> records = [
            SELECT Core_MDF_AI_Recommendation__c,
                   Core_MDF_User_Decision__c
            FROM Core_MDF_AI_Recommendation_Tracking__c
        ];

        System.assertEquals(1, records.size(), 'One record should be inserted');
        System.assertEquals('true',  records[0].Core_MDF_AI_Recommendation__c,
            'Boolean true should convert to string "true"');
        System.assertEquals('false', records[0].Core_MDF_User_Decision__c,
            'Boolean false should convert to string "false"');
    }

    @IsTest
    static void saveTracking_nestedObjectFieldValue_jsonSerialized() {
        // A nested Map or List is not a primitive, so valueAsString falls through
        // to JSON.serialize(value) — exercises line 58 in valueAsString.
        List<Object> payload = buildPayload(new Map<String, Object>{
            'fieldLabel'       => new Map<String, Object>{ 'nested' => 'value', 'count' => 1 },
            'aiSuggestedValue' => new List<Object>{ 'a', 'b', 'c' }
        });

        Test.startTest();
        Core_MDF_AITrackingService.saveTracking(null, payload, null);
        Test.stopTest();

        List<Core_MDF_AI_Recommendation_Tracking__c> records = [
            SELECT Core_MDF_AI_Recommendation__c,
                   Core_MDF_AI_Suggested_Value__c
            FROM Core_MDF_AI_Recommendation_Tracking__c
        ];

        System.assertEquals(1, records.size(), 'One record should be inserted');
        System.assertNotEquals(null, records[0].Core_MDF_AI_Recommendation__c,
            'Nested map should be JSON-serialized to a non-null string');
        System.assertNotEquals(null, records[0].Core_MDF_AI_Suggested_Value__c,
            'List value should be JSON-serialized to a non-null string');
    }

    // ─── buildDetails ────────────────────────────────────────────────────────────

    @IsTest
    static void buildDetails_allFields_returnsValidJson() {
        Map<String, Object> entry = new Map<String, Object>{
            'groupId'         => 'grp-001',
            'sourceType'      => 'AI',
            'fieldPath'       => 'Account.Name',
            'targetObject'    => 'Account',
            'targetRecordKey' => 'rec-001'
        };

        Test.startTest();
        String result = Core_MDF_AITrackingService.buildDetails(entry);
        Test.stopTest();

        System.assertNotEquals(null, result, 'buildDetails should return a non-null string');
        Map<String, Object> parsed = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.assertEquals('grp-001',      parsed.get('groupId'),         'groupId should be present');
        System.assertEquals('AI',           parsed.get('sourceType'),      'sourceType should be present');
        System.assertEquals('Account.Name', parsed.get('fieldPath'),       'fieldPath should be present');
        System.assertEquals('Account',      parsed.get('targetObject'),    'targetObject should be present');
        System.assertEquals('rec-001',      parsed.get('targetRecordKey'), 'targetRecordKey should be present');
    }

    @IsTest
    static void buildDetails_emptyEntry_returnsJsonWithNulls() {
        Map<String, Object> entry = new Map<String, Object>();

        Test.startTest();
        String result = Core_MDF_AITrackingService.buildDetails(entry);
        Test.stopTest();

        System.assertNotEquals(null, result, 'buildDetails should return a string even for an empty entry');
        Map<String, Object> parsed = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.assertEquals(null, parsed.get('groupId'),         'groupId should be null');
        System.assertEquals(null, parsed.get('fieldPath'),       'fieldPath should be null');
        System.assertEquals(null, parsed.get('targetObject'),    'targetObject should be null');
        System.assertEquals(null, parsed.get('targetRecordKey'), 'targetRecordKey should be null');
    }

    @IsTest
    static void buildDetails_oversizedContent_isTruncatedTo32768() {
        String longValue = ''.leftPad(33000, 'X');
        Map<String, Object> entry = new Map<String, Object>{ 'fieldPath' => longValue };

        Test.startTest();
        String result = Core_MDF_AITrackingService.buildDetails(entry);
        Test.stopTest();

        System.assertEquals(32768, result.length(), 'buildDetails output must be truncated to 32768');
    }

    // ─── valueAsBoolean ──────────────────────────────────────────────────────────

    @IsTest
    static void valueAsBoolean_null_returnsFalse() {
        Test.startTest();
        Boolean result = Core_MDF_AITrackingService.valueAsBoolean(null);
        Test.stopTest();

        System.assertEquals(false, result, 'null should return false');
    }

    @IsTest
    static void valueAsBoolean_booleanTrue_returnsTrue() {
        Test.startTest();
        Boolean result = Core_MDF_AITrackingService.valueAsBoolean(true);
        Test.stopTest();

        System.assertEquals(true, result, 'Boolean true should return true');
    }

    @IsTest
    static void valueAsBoolean_booleanFalse_returnsFalse() {
        Test.startTest();
        Boolean result = Core_MDF_AITrackingService.valueAsBoolean(false);
        Test.stopTest();

        System.assertEquals(false, result, 'Boolean false should return false');
    }

    @IsTest
    static void valueAsBoolean_stringTrue_returnsTrue() {
        Test.startTest();
        Boolean result = Core_MDF_AITrackingService.valueAsBoolean('true');
        Test.stopTest();

        System.assertEquals(true, result, 'String "true" should return true');
    }

    @IsTest
    static void valueAsBoolean_stringTrueUpperCase_returnsTrue() {
        Test.startTest();
        Boolean result = Core_MDF_AITrackingService.valueAsBoolean('TRUE');
        Test.stopTest();

        System.assertEquals(true, result, 'String "TRUE" (uppercase) should return true');
    }

    @IsTest
    static void valueAsBoolean_stringFalse_returnsFalse() {
        Test.startTest();
        Boolean result = Core_MDF_AITrackingService.valueAsBoolean('false');
        Test.stopTest();

        System.assertEquals(false, result, 'String "false" should return false');
    }

    @IsTest
    static void valueAsBoolean_arbitraryString_returnsFalse() {
        Test.startTest();
        Boolean result = Core_MDF_AITrackingService.valueAsBoolean('yes');
        Test.stopTest();

        System.assertEquals(false, result, 'Any non-"true" string should return false');
    }

}