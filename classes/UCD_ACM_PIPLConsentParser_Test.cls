@isTest
private class UCD_ACM_PIPLConsentParser_Test {

    @isTest
    static void testParseJson_NormalScenario() {
        // Test normal scenario with valid JSON data
        String jsonData = '{"EmailId":"test@example.com","Data":[{"Cnsnt_Date":"2024-05-24 16:41:30.000","Cnsnt_Cd":"CNSNT_SHARE"}]}';

        UCD_ACM_PIPLConsentParser.RequestData requestData = new UCD_ACM_PIPLConsentParser.RequestData();
        requestData.jsonData = jsonData;

        List<UCD_ACM_PIPLConsentParser.RequestData> requestDataList = new List<UCD_ACM_PIPLConsentParser.RequestData>();
        requestDataList.add(requestData);

        List<UCD_ACM_PIPLConsentParser.OutputData> outputDataList = UCD_ACM_PIPLConsentParser.parseJson(requestDataList);

        System.assertEquals(1, outputDataList.size(), 'There should be one output data entry.');
        UCD_ACM_PIPLConsentParser.OutputData outputData = outputDataList[0];

        System.assertEquals('test@example.com', outputData.emailId, 'Email ID should match.');
        System.assertEquals(Datetime.newInstanceGmt(2024, 05, 24, 16, 41, 30), outputData.cnsntDate, 'Consent date should match.');
        System.assertEquals('CNSNT_SHARE', outputData.cnsntCode, 'Consent code should match.');
    }

    @isTest
    static void testParseJson_MissingFields() {
        // Test scenario with missing fields in JSON data
        String jsonData = '{"EmailId":"test@example.com","Data":[{}]}';

        UCD_ACM_PIPLConsentParser.RequestData requestData = new UCD_ACM_PIPLConsentParser.RequestData();
        requestData.jsonData = jsonData;

        List<UCD_ACM_PIPLConsentParser.RequestData> requestDataList = new List<UCD_ACM_PIPLConsentParser.RequestData>();
        requestDataList.add(requestData);

        List<UCD_ACM_PIPLConsentParser.OutputData> outputDataList = UCD_ACM_PIPLConsentParser.parseJson(requestDataList);

        System.assertEquals(1, outputDataList.size(), 'There should be one output data entry.');
        UCD_ACM_PIPLConsentParser.OutputData outputData = outputDataList[0];

        System.assertEquals('test@example.com', outputData.emailId, 'Email ID should match.');
        System.assertEquals(null, outputData.cnsntDate, 'Consent date should be null.');
        System.assertEquals(null, outputData.cnsntCode, 'Consent code should be null.');
    }

    @isTest
    static void testParseJson_NoDataField() {
        // Test scenario with no Data field in JSON data
        String jsonData = '{"EmailId":"test@example.com"}';

        UCD_ACM_PIPLConsentParser.RequestData requestData = new UCD_ACM_PIPLConsentParser.RequestData();
        requestData.jsonData = jsonData;

        List<UCD_ACM_PIPLConsentParser.RequestData> requestDataList = new List<UCD_ACM_PIPLConsentParser.RequestData>();
        requestDataList.add(requestData);

        List<UCD_ACM_PIPLConsentParser.OutputData> outputDataList = UCD_ACM_PIPLConsentParser.parseJson(requestDataList);

        System.assertEquals(1, outputDataList.size(), 'There should be one output data entry.');
        UCD_ACM_PIPLConsentParser.OutputData outputData = outputDataList[0];

        System.assertEquals('test@example.com', outputData.emailId, 'Email ID should match.');
        System.assertEquals(null, outputData.cnsntDate, 'Consent date should be null.');
        System.assertEquals(null, outputData.cnsntCode, 'Consent code should be null.');
    }

    @isTest
    static void testParseJson_EmptyDataList() {
        // Test scenario with empty Data list in JSON data
        String jsonData = '{"EmailId":"test@example.com","Data":[]}';

        UCD_ACM_PIPLConsentParser.RequestData requestData = new UCD_ACM_PIPLConsentParser.RequestData();
        requestData.jsonData = jsonData;

        List<UCD_ACM_PIPLConsentParser.RequestData> requestDataList = new List<UCD_ACM_PIPLConsentParser.RequestData>();
        requestDataList.add(requestData);

        List<UCD_ACM_PIPLConsentParser.OutputData> outputDataList = UCD_ACM_PIPLConsentParser.parseJson(requestDataList);

        System.assertEquals(1, outputDataList.size(), 'There should be one output data entry.');
        UCD_ACM_PIPLConsentParser.OutputData outputData = outputDataList[0];

        System.assertEquals('test@example.com', outputData.emailId, 'Email ID should match.');
        System.assertEquals(null, outputData.cnsntDate, 'Consent date should be null.');
        System.assertEquals(null, outputData.cnsntCode, 'Consent code should be null.');
    }

    // @isTest
    // static void testParseJson_InvalidJson() {
    //     // Test scenario with invalid JSON data
    //     String jsonData = 'Invalid JSON String';

    //     UCD_ACM_PIPLConsentParser.RequestData requestData = new UCD_ACM_PIPLConsentParser.RequestData();
    //     requestData.jsonData = jsonData;

    //     List<UCD_ACM_PIPLConsentParser.RequestData> requestDataList = new List<UCD_ACM_PIPLConsentParser.RequestData>();
    //     requestDataList.add(requestData);

    //     try {
    //         List<UCD_ACM_PIPLConsentParser.OutputData> outputDataList = UCD_ACM_PIPLConsentParser.parseJson(requestDataList);
    //         System.assert(false, 'An exception should have been thrown due to invalid JSON.');
    //     } catch (Exception e) {
    //         System.assert(true, 'An exception was expected due to invalid JSON.');
    //     }
    // }

    @isTest
    static void testConvertDatetimeStringToDatetime() {
        // Test normal scenario for converting datetime string to Datetime object
        String datetimeString = '2024-06-19T12:34:56Z';
        Datetime expectedDatetime = Datetime.newInstanceGmt(2024, 6, 19, 12, 34, 56);

        Datetime convertedDatetime = UCD_ACM_PIPLConsentParser.convertDatetimeStringToDatetime(datetimeString);

        System.assertEquals(expectedDatetime, convertedDatetime, 'Converted datetime should match.');
    }

    @isTest
    static void testConvertDatetimeStringToDatetime_InvalidFormat() {
        // Test scenario with invalid datetime format
        String datetimeString = 'Invalid Datetime String';

        try {
            Datetime convertedDatetime = UCD_ACM_PIPLConsentParser.convertDatetimeStringToDatetime(datetimeString);
            System.assert(false, 'An exception should have been thrown due to invalid datetime format.');
        } catch (Exception e) {
            System.assert(true, 'An exception was expected due to invalid datetime format.');
        }
    }

    @isTest
    static void testConvertDatetimeStringToDatetime_PartialDate() {
        // Test scenario with partial datetime string
        String datetimeString = '2024-06-19';

        try {
            Datetime convertedDatetime = UCD_ACM_PIPLConsentParser.convertDatetimeStringToDatetime(datetimeString);
            System.assert(false, 'An exception should have been thrown due to partial datetime string.');
        } catch (Exception e) {
            System.assert(true, 'An exception was expected due to partial datetime string.');
        }
    }
}