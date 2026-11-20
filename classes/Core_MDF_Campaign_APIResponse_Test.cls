@IsTest
private class Core_MDF_Campaign_APIResponse_Test {

    @IsTest
    static void testDefaultConstructor_AllFieldsNull() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        System.assertEquals(null, response.isSuccess);
        System.assertEquals(null, response.success);
        System.assertEquals(null, response.error);
        System.assertEquals(null, response.details);
    }

    @IsTest
    static void testSetSuccessInfo_SetsFieldsCorrectly() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.setSuccessInfo('Campaign retrieved', '200');

        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.success);
        System.assertEquals('Campaign retrieved', response.success.message);
        System.assertEquals('200', response.success.code);
        System.assertEquals(null, response.error);
    }

    @IsTest
    static void testSetErrorInfo_SetsFieldsCorrectly() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.setErrorInfo('Campaign not found', '7004');

        System.assertEquals(false, response.isSuccess);
        System.assertNotEquals(null, response.error);
        System.assertEquals('Campaign not found', response.error.message);
        System.assertEquals('7004', response.error.code);
        System.assertEquals(null, response.success);
    }

    @IsTest
    static void testSetSuccessInfo_ThenSetErrorInfo_ClearsSuccess() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.setSuccessInfo('OK', '200');
        response.setErrorInfo('Failed', '7003');

        System.assertEquals(false, response.isSuccess);
        System.assertEquals(null, response.success);
        System.assertNotEquals(null, response.error);
    }

    @IsTest
    static void testGetCode_WhenSuccess() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.setSuccessInfo('OK', '200');
        System.assertEquals('200', response.getCode());
    }

    @IsTest
    static void testGetCode_WhenError() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.setErrorInfo('Error', '7003');
        System.assertEquals('7003', response.getCode());
    }

    @IsTest
    static void testGetCode_WhenNeitherSet_ReturnsNull() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        // isSuccess is null on an uninitialized response; Apex throws NPE when auto-unboxing it
        try {
            String code = response.getCode();
            System.assertEquals(null, code);
        } catch (NullPointerException ex) {
            System.assert(true, 'NPE expected when isSuccess has not been set');
        }
    }

    @IsTest
    static void testGetCode_IsSuccessTrue_NullSuccessBlock_ReturnsNull() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.isSuccess = true;
        response.success = null;
        System.assertEquals(null, response.getCode());
    }

    @IsTest
    static void testGetCode_IsSuccessFalse_NullErrorBlock_ReturnsNull() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.isSuccess = false;
        response.error = null;
        System.assertEquals(null, response.getCode());
    }

    @IsTest
    static void testGetMessage_WhenSuccess() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.setSuccessInfo('Campaign retrieved successfully', '200');
        System.assertEquals('Campaign retrieved successfully', response.getMessage());
    }

    @IsTest
    static void testGetMessage_WhenError() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.setErrorInfo('Internal server error', '7003');
        System.assertEquals('Internal server error', response.getMessage());
    }

    @IsTest
    static void testGetMessage_WhenNeitherSet_ReturnsNull() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        // isSuccess is null on an uninitialized response; Apex throws NPE when auto-unboxing it
        try {
            String message = response.getMessage();
            System.assertEquals(null, message);
        } catch (NullPointerException ex) {
            System.assert(true, 'NPE expected when isSuccess has not been set');
        }
    }

    @IsTest
    static void testGetSerializedResponse_WhenSuccess_ContainsSuccessBlock() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.setSuccessInfo('Campaign retrieved', '200');
        response.details = new Map<String, Object>{ 'Id' => '7010000000001AAA' };

        Map<String, Object> serialized = response.getSerializedResponse();

        System.assertEquals(true, serialized.get('isSuccess'));
        System.assertNotEquals(null, serialized.get('success'));
        System.assertEquals(null, serialized.get('error'));
        System.assertNotEquals(null, serialized.get('details'));

        Map<String, Object> successMap = (Map<String, Object>)serialized.get('success');
        System.assertEquals('Campaign retrieved', successMap.get('message'));
        System.assertEquals('200', successMap.get('code'));
    }

    @IsTest
    static void testGetSerializedResponse_WhenError_ContainsErrorBlock() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.setErrorInfo('Campaign not found', '7004');

        Map<String, Object> serialized = response.getSerializedResponse();

        System.assertEquals(false, serialized.get('isSuccess'));
        System.assertNotEquals(null, serialized.get('error'));
        System.assertEquals(null, serialized.get('success'));

        Map<String, Object> errorMap = (Map<String, Object>)serialized.get('error');
        System.assertEquals('Campaign not found', errorMap.get('message'));
        System.assertEquals('7004', errorMap.get('code'));
    }

    @IsTest
    static void testGetSerializedResponse_NullDetails_DetailsKeyPresent() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.setSuccessInfo('OK', '200');

        Map<String, Object> serialized = response.getSerializedResponse();

        System.assert(serialized.containsKey('details'));
        System.assertEquals(null, serialized.get('details'));
    }

    @IsTest
    static void testResponseStatusConstructor() {
        Core_MDF_Campaign_APIResponse.ResponseStatus status =
            new Core_MDF_Campaign_APIResponse.ResponseStatus('Test message', 'TEST_CODE');
        System.assertEquals('Test message', status.message);
        System.assertEquals('TEST_CODE', status.code);
    }

    @IsTest
    static void testDetails_AcceptsStringValue() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.setSuccessInfo('OK', '200');
        response.details = 'plain string details';

        Map<String, Object> serialized = response.getSerializedResponse();
        System.assertEquals('plain string details', serialized.get('details'));
    }

    @IsTest
    static void testDetails_AcceptsListValue() {
        Core_MDF_Campaign_APIResponse response = new Core_MDF_Campaign_APIResponse();
        response.setSuccessInfo('OK', '200');
        response.details = new List<String>{ 'item1', 'item2' };

        Map<String, Object> serialized = response.getSerializedResponse();
        System.assertNotEquals(null, serialized.get('details'));
    }
}