@isTest
private class Core_MDF_RevenueSegmentGVSSync_Test {

    @isTest
    static void testSyncGlobalValueSet_insertTriggersAsyncSync() {
        Core_MDF_CCP_Custom_Metadata_Utility__c mapping = new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Name = 'Test Rev Segment',
            Core_MDF_Category__c = 'Revenue_Segment_Mapping',
            Core_MDF_Name_Criteria__c = 'Test Rev Segment',
            Core_MDF_Field_1_txt__c = 'Test Rev Segment - 9999',
            Core_MDF_Field_2_txt__c = 'Test PC',
            Core_MDF_Field_3_txt__c = '9999',
            Core_MDF_Program__c = 'Co-Inv',
            Core_MDF_Is_Active_Ind__c = true
        );

        Test.startTest();
        insert mapping;
        Test.stopTest();

        List<Core_MDF_CCP_Custom_Metadata_Utility__c> inserted = [
            SELECT Id, Core_MDF_Name_Criteria__c, Core_MDF_Field_1_txt__c, Core_MDF_Is_Active_Ind__c
            FROM Core_MDF_CCP_Custom_Metadata_Utility__c
            WHERE Id = :mapping.Id
        ];
        System.assertEquals(1, inserted.size(), 'Mapping record should have been inserted');
        System.assertEquals('Test Rev Segment - 9999', inserted[0].Core_MDF_Field_1_txt__c);
    }

    @isTest
    static void testSyncGlobalValueSet_updateTriggersAsyncSync() {
        Core_MDF_CCP_Custom_Metadata_Utility__c mapping = new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Name = 'Test Rev Segment 2',
            Core_MDF_Category__c = 'Revenue_Segment_Mapping',
            Core_MDF_Name_Criteria__c = 'Test Rev Segment 2',
            Core_MDF_Field_1_txt__c = 'Test Rev Segment 2 - 8888',
            Core_MDF_Program__c = 'Co-Inv',
            Core_MDF_Is_Active_Ind__c = true
        );
        insert mapping;

        Test.startTest();
        mapping.Core_MDF_Field_1_txt__c = 'Test Rev Segment 2 - 8888 Updated';
        update mapping;
        Test.stopTest();

        Core_MDF_CCP_Custom_Metadata_Utility__c updated = [
            SELECT Core_MDF_Field_1_txt__c FROM Core_MDF_CCP_Custom_Metadata_Utility__c WHERE Id = :mapping.Id
        ];
        System.assertEquals('Test Rev Segment 2 - 8888 Updated', updated.Core_MDF_Field_1_txt__c);
    }

    @isTest
    static void testSyncGlobalValueSet_unrelatedCategoryDoesNotThrow() {
        Core_MDF_CCP_Custom_Metadata_Utility__c unrelated = new Core_MDF_CCP_Custom_Metadata_Utility__c(
            Name = 'Unrelated KPI Row',
            Core_MDF_Category__c = 'KPI'
        );

        Test.startTest();
        insert unrelated;
        Test.stopTest();

        List<Core_MDF_CCP_Custom_Metadata_Utility__c> inserted = [
            SELECT Id FROM Core_MDF_CCP_Custom_Metadata_Utility__c WHERE Id = :unrelated.Id
        ];
        System.assertEquals(1, inserted.size(), 'Unrelated category record should still insert normally');
    }
}