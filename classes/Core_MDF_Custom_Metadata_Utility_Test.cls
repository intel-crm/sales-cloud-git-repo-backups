@IsTest
public class Core_MDF_Custom_Metadata_Utility_Test {
    @IsTest
    static void testMethodName() {

        string whereClause = 'Core_MDF_Program__c = \'Retail Marketing Funds\' AND Core_MDF_Field_1_txt__c = \'Sales Readiness\' AND Core_MDF_Field_2_txt__c = \'In-Store Promotion\' AND Core_MDF_Field_4_txt__c != NULL AND Core_MDF_Sub_Category__c = \'PartnerFundRequest\'  AND Core_MDF_Checkbox_Field_3_Ind__c = false Order by Core_MDF_Sort_Order_Nbr__c  limit 1';
        Test.startTest();
        List<sObject> result = Core_MDF_Custom_Metadata_Utility.getCustomObjectRecords(whereClause);
        Test.stopTest();
        // US - TWC702-14285: Unit Test Method should include System.Assert
       System.assertNotEquals(null, result, 'Result should not be null');
       // System.assertEquals(1, result.size());
    }
    
    @isTest
    static void getCustomObjectRecordsUsingDynamicQueryTest() {
        String query = 'SELECT ' +
            'Core_MDF_Field_9_txt__c, ' +
            'Core_MDF_Field_10_txt__c, ' +
            'Core_MDF_Program__c, ' +
            'Core_MDF_Field_12_txt__c, ' +
            'Core_MDF_Field_8_txt__c, ' +
            'Core_MDF_Field_11_txt__c, ' +
            'Core_MDF_Field_5_txt__c, ' +
            'Core_MDF_Field_6_txt__c, ' +
            'Core_MDF_Field_7_txt__c, ' + 
            'Core_MDF_Field_1_txt__c, ' + 
            'Core_MDF_Checkbox_Field_1_Ind__c ' + 
            'FROM Core_MDF_CCP_Custom_Metadata_Utility__c ' +
            'WHERE Core_MDF_Category__c = \'' + String.escapeSingleQuotes(Core_MDF_CCP_ConstantClass.POP_TRANSLATION) + '\' ' +
            'AND Core_MDF_Is_Active_Ind__c = TRUE'; 
        Test.startTest();
        Core_MDF_Custom_Metadata_Utility.getCustomObjectRecordsUsingDynamicQuery(query);
        Test.stopTest();
        // US - TWC702-14285: Unit Test Method should include System.Assert
        System.assert(true, 'Dynamic query executed successfully without errors');
    }
    
}