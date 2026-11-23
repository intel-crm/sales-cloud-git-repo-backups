/*******************************************************************
* Class Name: Core_MDF_CustomPicklistAPI_Test
* Description: Test class for Core_MDF_CustomPicklistAttributes_API
********************************************************************/
@IsTest
private class Core_MDF_CustomPicklistAPI_Test {
    @IsTest
    static void testGetPicklistValuesSuccessWithProgramFromPath() {
        String validProgramName = getAnyValidProgramName();
        System.assertNotEquals(null, validProgramName, 'Expected at least one valid program mapping for this API test.');

        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/mdf/attributesbyProgram/' + EncodingUtil.urlEncode(validProgramName, 'UTF-8');
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = null;

        Test.startTest();
        Core_MDF_CustomPicklistAttributes_API.getPicklistValues();
        Test.stopTest();

        System.assertNotEquals(null, RestContext.response, 'Expected API to initialize RestContext.response when null.');
        System.assertEquals(200, RestContext.response.statusCode);

        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(true, payload.get('isSuccess'));

        Map<String, Object> details = (Map<String, Object>) payload.get('details');
        System.assertNotEquals(null, details, 'Expected details in success response.');
        System.assertNotEquals(null, details.get('programName'), 'Expected canonical program name in details.');
        System.assertNotEquals(null, details.get('attributes'), 'Expected attributes map in details.');
    }

    @IsTest
    static void testGetPicklistValuesSuccessWithProgramFromQueryParam() {
        String validProgramName = getAnyValidProgramName();
        System.assertNotEquals(null, validProgramName, 'Expected at least one valid program mapping for this API test.');

        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/mdf/attributesbyprogram?programName=' + EncodingUtil.urlEncode(validProgramName, 'UTF-8');
        request.httpMethod = 'GET';

        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        Core_MDF_CustomPicklistAttributes_API.getPicklistValues();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);

        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(true, payload.get('isSuccess'));

        Map<String, Object> details = (Map<String, Object>) payload.get('details');
        System.assertNotEquals(null, details, 'Expected details in success response.');
        System.assertNotEquals(null, details.get('attributes'), 'Expected attributes map in details.');
    }

    @IsTest
    static void testGetPicklistValuesWithoutProgramReturnsBadRequest() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/mdf/attributesbyprogram';
        request.httpMethod = 'GET';

        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        Core_MDF_CustomPicklistAttributes_API.getPicklistValues();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);

        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(false, payload.get('isSuccess'));

        Map<String, Object> error = (Map<String, Object>) payload.get('error');
        System.assertEquals('1000', String.valueOf(error.get('code')));
        System.assertEquals('Invalid request : Program name is missing.', String.valueOf(error.get('message')));
    }

    @IsTest
    static void testGetPicklistValuesInvalidProgramReturnsBadRequest() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/mdf/attributesbyprogram?programName=InvalidProgramForAttributesApi';
        request.httpMethod = 'GET';

        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        Core_MDF_CustomPicklistAttributes_API.getPicklistValues();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);

        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(false, payload.get('isSuccess'));

        Map<String, Object> error = (Map<String, Object>) payload.get('error');
        System.assertEquals('1001', String.valueOf(error.get('code')));
    }

    private static String getAnyValidProgramName() {
        List<Core_MDF_Custom_Label_Configration__mdt> mappingRecords = [
            SELECT Core_MDF_Value_Txt__c, Core_MDF_Value2_Txt__c, Core_MDF_Value3_Txt__c, Core_MDF_Value4_Txt__c, Core_MDF_Value5_Txt__c
            FROM Core_MDF_Custom_Label_Configration__mdt
            WHERE DeveloperName = 'Core_MDF_ProgramRecordTypeMapping'
            LIMIT 1
        ];

        if (mappingRecords.isEmpty()) {
            return null;
        }

        String mappingJson = '';
        for (String chunk : new List<String>{
            mappingRecords[0].Core_MDF_Value_Txt__c,
            mappingRecords[0].Core_MDF_Value2_Txt__c,
            mappingRecords[0].Core_MDF_Value3_Txt__c,
            mappingRecords[0].Core_MDF_Value4_Txt__c,
            mappingRecords[0].Core_MDF_Value5_Txt__c
        }) {
            if (!String.isBlank(chunk)) {
                mappingJson += chunk;
            }
        }

        if (String.isBlank(mappingJson)) {
            return null;
        }

        Map<String, Object> programByRecordType = (Map<String, Object>) JSON.deserializeUntyped(mappingJson);
        if (programByRecordType == null || programByRecordType.isEmpty()) {
            return null;
        }

        for (String recordTypeDevName : programByRecordType.keySet()) {
            String programName = String.valueOf(programByRecordType.get(recordTypeDevName));
            if (!String.isBlank(programName)) {
                return programName.trim();
            }
        }

        return null;
    }
}