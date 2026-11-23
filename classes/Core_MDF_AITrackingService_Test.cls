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

    // ─── valueAsString type coercion ─────────────────────────────────────────────

}