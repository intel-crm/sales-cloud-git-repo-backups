@IsTest
private class Core_MDF_PFR_RestAPI_Constants_Test {

    @IsTest
    static void formatErrorReturnsInputForBlankTemplate() {
        System.assertEquals(null, Core_MDF_PFR_RestAPI_Constants.formatError(null, null), 'Null template should remain null');
        System.assertEquals('', Core_MDF_PFR_RestAPI_Constants.formatError('', null), 'Blank template should remain blank');
    }

    @IsTest
    static void formatErrorFallsBackToCodeWhenNoSettingExists() {
        System.assertEquals('9876', Core_MDF_PFR_RestAPI_Constants.formatError('ERR-9876', null), 'Unconfigured codes should normalize and return only the code');
    }

    @IsTest
    static void formatErrorUsesConfiguredMessageAndArguments() {
        insert new Core_MDF_External_API_Response_Codes__c(
            Name = 'Constants_Test_9231',
            Core_Code__c = '9231',
            Core_Message__c = 'Product ID is blank at position {0}',
            Core_Http_Status_Code__c = '400'
        );

        System.assertEquals(
            '9231: Product ID is blank at position 2',
            Core_MDF_PFR_RestAPI_Constants.formatError('ERR-9231', new List<String>{ '2' }),
            'Configured messages should be formatted with supplied arguments'
        );
    }

    @IsTest
    static void formatErrorUsesConfiguredMessageWithoutArguments() {
        insert new Core_MDF_External_API_Response_Codes__c(
            Name = 'Constants_Test_9241',
            Core_Code__c = '9241',
            Core_Message__c = 'All segments validated',
            Core_Http_Status_Code__c = '200'
        );

        System.assertEquals(
            '9241: All segments validated',
            Core_MDF_PFR_RestAPI_Constants.formatError('9241', null),
            'Configured messages without arguments should be returned without expected-value suffixes'
        );
    }

    @IsTest
    static void formatErrorAppendsExpectedValuesWhenMessageOmitsThem() {
        insert new Core_MDF_External_API_Response_Codes__c(
            Name = 'Constants_Test_9030',
            Core_Code__c = '9030',
            Core_Message__c = 'Invalid activity category {0}',
            Core_Http_Status_Code__c = '400'
        );

        String expectedValues = '1. Event\n2. Digital';
        String message = Core_MDF_PFR_RestAPI_Constants.formatError(
            '9030',
            new List<String>{ 'Bad Category', expectedValues }
        );

        System.assert(message.contains('9030: Invalid activity category Bad Category'), 'Formatted message should include configured text');
        System.assert(message.contains('Expected value:\n' + expectedValues), 'Expected values should be appended when missing from the configured message');
    }

    @IsTest
    static void staticConstantsExposeExpectedValues() {
        System.assertEquals('9001', Core_MDF_PFR_RestAPI_Constants.ERR_9001_NO_RECORDS, 'Core error constants should remain stable');
        System.assertEquals('Core_MDF_Client_CoMarketing_Fund', Core_MDF_PFR_RestAPI_Constants.RECORD_TYPE_CCF, 'CCF record type constant should remain stable');
        System.assertEquals(10, Core_MDF_PFR_RestAPI_Constants.MAX_SEGMENTS_PER_REQUEST, 'SPIF segment limit constant should remain stable');
        System.assert(Core_MDF_PFR_RestAPI_Constants.VALID_SPIF_BUDGET_TYPES.contains('MDF'), 'SPIF budget type set should include MDF');
    }
}