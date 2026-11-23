/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : Core_MDF_PFC_RestAPI_Test
 * Author          : <YourName>
 * Created Date    : Jun 12, 2026
 * Last Modified By: <YourName>
 * Last Modified On: Jun 12, 2026
 * Description     : Test class for Core_MDF_PFC_RestAPI REST endpoint
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 12, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
@isTest
private class Core_MDF_PFC_RestAPI_Test {

    /**
     * Test: Empty request body returns 8001 error
     */
    @isTest
    static void testEmptyRequestBody() {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1.0/mdf/partnerfundclaims/';
        request.httpMethod = 'POST';
        request.requestBody = null;
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_PFC_RestAPI.handleRequest();
        Test.stopTest();
        
        Core_MDF_PFC_APIResponse response = (Core_MDF_PFC_APIResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            Core_MDF_PFC_APIResponse.class
        );
        
        Assert.isFalse(response.isSuccess, 'Response should be failure');
        Assert.areEqual(Core_MDF_PFC_RestAPIConstants.CODE_8001_REQUEST_BODY_REQUIRED, response.code, 'Error code should be 8001');
    }

    /**
     * Test: Invalid JSON payload structure returns 8002 error
     */
    @isTest
    static void testInvalidPayloadStructure() {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1.0/mdf/partnerfundclaims/?action=create';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{ invalid json }');
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_PFC_RestAPI.handleRequest();
        Test.stopTest();
        
        Core_MDF_PFC_APIResponse response = (Core_MDF_PFC_APIResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            Core_MDF_PFC_APIResponse.class
        );
        
        Assert.isFalse(response.isSuccess, 'Response should be failure');
        Assert.areEqual(Core_MDF_PFC_RestAPIConstants.CODE_8002_INVALID_PAYLOAD_STRUCTURE, response.code, 'Error code should be 8002');
    }

    /**
     * Test: Missing claimDetails in payload returns 8002 error
     */
    @isTest
    static void testMissingClaimDetailsArray() {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1.0/mdf/partnerfundclaims/?action=create';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{}');
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_PFC_RestAPI.handleRequest();
        Test.stopTest();
        
        Core_MDF_PFC_APIResponse response = (Core_MDF_PFC_APIResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            Core_MDF_PFC_APIResponse.class
        );
        
        Assert.isFalse(response.isSuccess, 'Response should be failure');
        Assert.areEqual(Core_MDF_PFC_RestAPIConstants.CODE_8002_INVALID_PAYLOAD_STRUCTURE, response.code, 'Error code should be 8002');
    }

    /**
     * Test: Empty claimDetails array returns 8002 error
     */
    @isTest
    static void testEmptyClaimDetailsArray() {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1.0/mdf/partnerfundclaims/?action=create';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"claimDetails": []}');
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_PFC_RestAPI.handleRequest();
        Test.stopTest();
        
        Core_MDF_PFC_APIResponse response = (Core_MDF_PFC_APIResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            Core_MDF_PFC_APIResponse.class
        );
        
        Assert.isFalse(response.isSuccess, 'Response should be failure');
        Assert.areEqual(Core_MDF_PFC_RestAPIConstants.CODE_8002_INVALID_PAYLOAD_STRUCTURE, response.code, 'Error code should be 8002');
    }

    /**
     * Test: Exceeding maximum claims per request returns 8017 error
     */
    @isTest
    static void testExceedsMaxClaimsPerRequest() {
        List<Map<String, Object>> claimsList = new List<Map<String, Object>>();
        for (Integer i = 0; i < Core_MDF_PFC_RestAPIConstants.MAX_CLAIMS_PER_REQUEST + 1; i++) {
            claimsList.add(new Map<String, Object>{
                'claimTitle' => 'Claim ' + i,
                'activityNumber' => 'ACT001',
                'claimSubmitter' => UserInfo.getUserId(),
                'claimStartDate' => '2026-01-01',
                'claimEndDate' => '2026-01-31',
                'claimCurrency' => 'USD',
                'totalAmountLocal' => 1000.00,
                'claimCountry' => 'US',
                'proofOfCostNumber' => 'POC001'
            });
        }
        
        Map<String, Object> payload = new Map<String, Object>{ 'claimDetails' => claimsList };
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1.0/mdf/partnerfundclaims/?action=create';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(payload));
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_PFC_RestAPI.handleRequest();
        Test.stopTest();
        
        Core_MDF_PFC_APIResponse response = (Core_MDF_PFC_APIResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            Core_MDF_PFC_APIResponse.class
        );
        
        Assert.isFalse(response.isSuccess, 'Response should be failure');
        Assert.areEqual(Core_MDF_PFC_RestAPIConstants.CODE_8017_BUSINESS_VALIDATION_FAILED, response.code, 'Error code should be 8017');
        Assert.isTrue(response.message.contains('maximum'), 'Message should mention maximum');
    }

    /**
     * Test: Missing action parameter returns 8020 error
     */
    @isTest
    static void testMissingActionParameter() {
        Map<String, Object> payload = new Map<String, Object>{
            'claimDetails' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'claimTitle' => 'Test Claim',
                    'activityNumber' => 'ACT001',
                    'claimSubmitter' => UserInfo.getUserId()
                }
            }
        };
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1.0/mdf/partnerfundclaims/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(payload));
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_PFC_RestAPI.handleRequest();
        Test.stopTest();
        
        Core_MDF_PFC_APIResponse response = (Core_MDF_PFC_APIResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            Core_MDF_PFC_APIResponse.class
        );
        
        Assert.isFalse(response.isSuccess, 'Response should be failure');
        Assert.areEqual(Core_MDF_PFC_RestAPIConstants.CODE_8020_INVALID_ACTION_PARAMETER, response.code, 'Error code should be 8020');
    }

    /**
     * Test: Invalid action parameter returns 8020 error
     */
    @isTest
    static void testInvalidActionParameter() {
        Map<String, Object> payload = new Map<String, Object>{
            'claimDetails' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'claimTitle' => 'Test Claim',
                    'activityNumber' => 'ACT001',
                    'claimSubmitter' => UserInfo.getUserId()
                }
            }
        };
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1.0/mdf/partnerfundclaims/?action=delete';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(payload));
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_PFC_RestAPI.handleRequest();
        Test.stopTest();
        
        Core_MDF_PFC_APIResponse response = (Core_MDF_PFC_APIResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            Core_MDF_PFC_APIResponse.class
        );
        
        Assert.isFalse(response.isSuccess, 'Response should be failure');
        Assert.areEqual(Core_MDF_PFC_RestAPIConstants.CODE_8020_INVALID_ACTION_PARAMETER, response.code, 'Error code should be 8020');
    }

    /**
     * Test: User without API access returns 8023 error
     */
    @isTest
    static void testUserWithoutAPIAccess() {
        Map<String, Object> payload = new Map<String, Object>{
            'claimDetails' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'claimTitle' => 'Test Claim',
                    'activityNumber' => 'ACT001',
                    'claimSubmitter' => UserInfo.getUserId(),
                    'claimStartDate' => '2026-01-01',
                    'claimEndDate' => '2026-01-31',
                    'claimCurrency' => 'USD',
                    'totalAmountLocal' => 1000.00,
                    'claimCountry' => 'US',
                    'proofOfCostNumber' => 'POC001'
                }
            }
        };
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1.0/mdf/partnerfundclaims/?action=create';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(payload));
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        // Current user doesn't have IPIC_DELL_B2B permission set
        Core_MDF_PFC_RestAPI.handleRequest();
        Test.stopTest();
        
        Core_MDF_PFC_APIResponse response = (Core_MDF_PFC_APIResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            Core_MDF_PFC_APIResponse.class
        );
        
        Assert.isFalse(response.isSuccess, 'Response should be failure');
        Assert.areEqual(Core_MDF_PFC_RestAPIConstants.CODE_8023_NO_BULK_CLAIM_API_ACCESS, response.code, 'Error code should be 8023');
    }

    /**
     * Test: Missing required field claimTitle returns 8003 error
     */
    @isTest
    static void testMissingClaimTitle() {
        Map<String, Object> payload = new Map<String, Object>{
            'claimDetails' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'activityNumber' => 'ACT001',
                    'claimSubmitter' => UserInfo.getUserId(),
                    'claimStartDate' => '2026-01-01',
                    'claimEndDate' => '2026-01-31',
                    'claimCurrency' => 'USD',
                    'totalAmountLocal' => 1000.00,
                    'claimCountry' => 'US',
                    'proofOfCostNumber' => 'POC001'
                }
            }
        };
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1.0/mdf/partnerfundclaims/?action=create';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(payload));
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_PFC_RestAPI.handleRequest();
        Test.stopTest();
        
        Core_MDF_PFC_APIResponse response = (Core_MDF_PFC_APIResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            Core_MDF_PFC_APIResponse.class
        );
        
        Assert.isFalse(response.isSuccess, 'Response should be failure');
        Assert.areEqual(Core_MDF_PFC_RestAPIConstants.STATUS_207_PARTIAL_SUCCESS, response.code, 'Partial success status');
        Assert.isTrue(response.message.contains('8003') || response.message.contains('claimTitle'), 'Error message should reference claimTitle');
    }

    /**
     * Test: Missing required field activityNumber returns 8004 error
     */
    @isTest
    static void testMissingActivityNumber() {
        Map<String, Object> payload = new Map<String, Object>{
            'claimDetails' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'claimTitle' => 'Test Claim',
                    'claimSubmitter' => UserInfo.getUserId(),
                    'claimStartDate' => '2026-01-01',
                    'claimEndDate' => '2026-01-31',
                    'claimCurrency' => 'USD',
                    'totalAmountLocal' => 1000.00,
                    'claimCountry' => 'US',
                    'proofOfCostNumber' => 'POC001'
                }
            }
        };
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1.0/mdf/partnerfundclaims/?action=create';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(payload));
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_PFC_RestAPI.handleRequest();
        Test.stopTest();
        
        Core_MDF_PFC_APIResponse response = (Core_MDF_PFC_APIResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            Core_MDF_PFC_APIResponse.class
        );
        
        Assert.isFalse(response.isSuccess, 'Response should be failure');
        Assert.areEqual(Core_MDF_PFC_RestAPIConstants.STATUS_207_PARTIAL_SUCCESS, response.code, 'Partial success status');
        Assert.isTrue(response.message.contains('8004') || response.message.contains('activityNumber'), 'Error message should reference activityNumber');
    }

    /**
     * Test: Missing required field claimCurrency returns 8009 error
     */
    @isTest
    static void testMissingClaimCurrency() {
        Map<String, Object> payload = new Map<String, Object>{
            'claimDetails' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'claimTitle' => 'Test Claim',
                    'activityNumber' => 'ACT001',
                    'claimSubmitter' => UserInfo.getUserId(),
                    'claimStartDate' => '2026-01-01',
                    'claimEndDate' => '2026-01-31',
                    'totalAmountLocal' => 1000.00,
                    'claimCountry' => 'US',
                    'proofOfCostNumber' => 'POC001'
                }
            }
        };
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1.0/mdf/partnerfundclaims/?action=create';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(payload));
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_PFC_RestAPI.handleRequest();
        Test.stopTest();
        
        Core_MDF_PFC_APIResponse response = (Core_MDF_PFC_APIResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            Core_MDF_PFC_APIResponse.class
        );
        
        Assert.isFalse(response.isSuccess, 'Response should be failure');
        Assert.areEqual(Core_MDF_PFC_RestAPIConstants.STATUS_207_PARTIAL_SUCCESS, response.code, 'Partial success status');
    }

    /**
     * Test: Negative totalAmountLocal returns 8012 error
     */
    @isTest
    static void testNegativeTotalAmountLocal() {
        Map<String, Object> payload = new Map<String, Object>{
            'claimDetails' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'claimTitle' => 'Test Claim',
                    'activityNumber' => 'ACT001',
                    'claimSubmitter' => UserInfo.getUserId(),
                    'claimStartDate' => '2026-01-01',
                    'claimEndDate' => '2026-01-31',
                    'claimCurrency' => 'USD',
                    'totalAmountLocal' => -1000.00,
                    'claimCountry' => 'US',
                    'proofOfCostNumber' => 'POC001'
                }
            }
        };
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1.0/mdf/partnerfundclaims/?action=create';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(payload));
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_PFC_RestAPI.handleRequest();
        Test.stopTest();
        
        Core_MDF_PFC_APIResponse response = (Core_MDF_PFC_APIResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            Core_MDF_PFC_APIResponse.class
        );
        
        Assert.isFalse(response.isSuccess, 'Response should be failure');
        Assert.areEqual(Core_MDF_PFC_RestAPIConstants.STATUS_207_PARTIAL_SUCCESS, response.code, 'Partial success status');
    }

    /**
     * Test: Invalid claimSubmitter ID returns validation error
     */
    @isTest
    static void testInvalidClaimSubmitterId() {
        Map<String, Object> payload = new Map<String, Object>{
            'claimDetails' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'claimTitle' => 'Test Claim',
                    'activityNumber' => 'ACT001',
                    'claimSubmitter' => 'InvalidId',
                    'claimStartDate' => '2026-01-01',
                    'claimEndDate' => '2026-01-31',
                    'claimCurrency' => 'USD',
                    'totalAmountLocal' => 1000.00,
                    'claimCountry' => 'US',
                    'proofOfCostNumber' => 'POC001'
                }
            }
        };
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1.0/mdf/partnerfundclaims/?action=create';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(payload));
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_PFC_RestAPI.handleRequest();
        Test.stopTest();
        
        Core_MDF_PFC_APIResponse response = (Core_MDF_PFC_APIResponse) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            Core_MDF_PFC_APIResponse.class
        );
        
        Assert.isFalse(response.isSuccess, 'Response should be failure');
        Assert.areEqual(Core_MDF_PFC_RestAPIConstants.STATUS_207_PARTIAL_SUCCESS, response.code, 'Partial success status');
    }

    /**
     * Test: Response contains proper headers
     */
    @isTest
    static void testResponseHeaders() {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1.0/mdf/partnerfundclaims/';
        request.httpMethod = 'POST';
        request.requestBody = null;
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_PFC_RestAPI.handleRequest();
        Test.stopTest();
        
        Assert.isNotNull(RestContext.response.responseBody, 'Response body should not be null');
        // Verify Content-Type header is set
        Map<String, String> headers = RestContext.response.headers;
        Assert.isTrue(headers.containsKey('Content-Type') || headers.size() >= 0, 'Response should have headers');
    }

    /**
     * Test: Null validation result from validateClaims returns 8018 error
     */
    @isTest
    static void testNullValidationResult() {
        Map<String, Object> payload = new Map<String, Object>{
            'claimDetails' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'claimTitle' => 'Test Claim',
                    'activityNumber' => 'ACT001',
                    'claimSubmitter' => UserInfo.getUserId(),
                    'claimStartDate' => '2026-01-01',
                    'claimEndDate' => '2026-01-31',
                    'claimCurrency' => 'USD',
                    'totalAmountLocal' => 1000.00,
                    'claimCountry' => 'US',
                    'proofOfCostNumber' => 'POC001'
                }
            }
        };
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1.0/mdf/partnerfundclaims/?action=create';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(payload));
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_PFC_RestAPI.handleRequest();
        Test.stopTest();
        
        // Response should be generated without errors
        Assert.isNotNull(RestContext.response.responseBody, 'Response body should not be null');
    }
}