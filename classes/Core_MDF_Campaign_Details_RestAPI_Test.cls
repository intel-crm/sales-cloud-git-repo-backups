/**
 * @description Test class for Core_MDF_Campaign_Details_RestAPI
 * Tests REST API endpoints for campaign details retrieval
 */
@isTest
private class Core_MDF_Campaign_Details_RestAPI_Test {
    
    @testSetup
    static void setupTestData() {
        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            IsActive = true,
            Status = 'In Progress'
        );
        insert testCampaign;
        List<Core_MDF_Custom_Layout_Section__c> sections= new List<Core_MDF_Custom_Layout_Section__c>();
        Core_MDF_Custom_Layout_Section__c sec1 = new Core_MDF_Custom_Layout_Section__c(Core_MDF_Section_Name_txt__c='Section 1',Core_MDF_Object_Name_txt__c='Campaign',Core_MDF_No_Of_Columns_nm__c= '1', Core_MDF_Sequence_No_nbr__c= 1.0, Core_MDF_Field_View_nm__c = 'Detail Layout');
        sections.add(sec1);
        Database.insert(sections);
        List<Core_MDF_Custom_Layout_Configurations__c> configs = new List<Core_MDF_Custom_Layout_Configurations__c>();
        configs.add(new Core_MDF_Custom_Layout_Configurations__c(
      Core_MDF_Field_API_Name_txt__c='Core_MDF_Account__c',Core_MDF_User_Type_nm__c= 'Internal User',Core_MDF_Record_Type_Name_txt__c='Intel Partner Alliance',Core_MDF_Object_API_Name_txt__c='Campaign',Core_MDF_Section_id__c=sections[0].id, Core_MDF_Budget_Type_nm__c = 'Account Based',Core_MDF_Alignment_nm__c='Left',Core_MDF_Field_Label_txt__c='Account', Core_MDF_Filter_Criteria_txt__c = 'Core_MDF_Proposal_Based_Ind__c == False', Core_MDF_Active_Ind__c = true, Core_MDF_Record_Name_nm__c= 'Core_MDF_Account__r.Name', Core_MDF_Is_Lookup_Ind__c=true
        ));
        insert configs;
        
        List<Core_RestAPI_Response_Codes__c> responseCodes = new List<Core_RestAPI_Response_Codes__c>();
        responseCodes.add(new Core_RestAPI_Response_Codes__c(
            Name  = 'Campaign ID Empty',
            Core_Code__c = '7002',
            Core_Message__c = 'Campaign ID is empty or missing',
            Core_Http_Status_Code__c = '400',
            Core_Category__c = 'Campaign'
        ));
        responseCodes.add(new Core_RestAPI_Response_Codes__c(
            Name  = 'Invalid Campaign ID',
            Core_Code__c = '7004',
            Core_Message__c = 'Invalid Campaign ID format',
            Core_Http_Status_Code__c = '400',
            Core_Category__c = 'Campaign'
        ));
        responseCodes.add(new Core_RestAPI_Response_Codes__c(
            Name  = 'Invalid field Display',
            Core_Code__c = '7005',
            Core_Message__c = 'Invalid field display parameter: {value}',
            Core_Http_Status_Code__c = '400',
            Core_Category__c = 'Campaign'
        ));
        responseCodes.add(new Core_RestAPI_Response_Codes__c(
            Name  = 'Insufficient permission',
            Core_Code__c = '7008',
            Core_Message__c = 'Insufficient permissions to access campaign',
            Core_Http_Status_Code__c = '403',
            Core_Category__c = 'Campaign'
        ));
        insert responseCodes;
    }
    
    private static Campaign getTestCampaign() {
        return [SELECT Id, Name FROM Campaign WHERE Name = 'Test Campaign' LIMIT 1];
    }
    
    @isTest
    static void testValidCampaignRetrieval() {
        Campaign testCampaign = getTestCampaign();
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/' + testCampaign.Id;
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    @isTest
    static void testWithFieldDisplayLabel() {
        Campaign testCampaign = getTestCampaign();
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/' + testCampaign.Id + '?fieldDisplay=label';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    @isTest
    static void testWithFieldDisplayTechnical() {
        Campaign testCampaign = getTestCampaign();
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/' + testCampaign.Id + '?fieldDisplay=technicalname';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    @isTest
    static void testEmptyCampaignId() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    @isTest
    static void testInvalidCampaignIdFormat() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/invalidID123';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    @isTest
    static void testShortInvalidId() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/ABC123';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    @isTest
    static void testWrongObjectType() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/' + acc.Id;
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    @isTest
    static void testNonexistentCampaign() {
        String keyPrefix = Campaign.sObjectType.getDescribe().getKeyPrefix();
        String fakeId = keyPrefix + '000000000000001';
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/' + fakeId;
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assertEquals(403, RestContext.response.statusCode);
    }
    
    @isTest
    static void testInvalidFieldDisplayValue() {
        Campaign testCampaign = getTestCampaign();
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/' + testCampaign.Id + '?fieldDisplay=invalid';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    @isTest
    static void testInvalidQueryParameter() {
        Campaign testCampaign = getTestCampaign();
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/' + testCampaign.Id + '?invalidParam=value';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    @isTest
    static void testMultipleInvalidParams() {
        Campaign testCampaign = getTestCampaign();
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/' + testCampaign.Id + '?param1=val1&param2=val2';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    @isTest
    static void testSpecialCharactersInFieldDisplay() {
        Campaign testCampaign = getTestCampaign();
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/' + testCampaign.Id + '?fieldDisplay=label@123';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    @isTest
    static void testWithTrailingSlash() {
        Campaign testCampaign = getTestCampaign();
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/' + testCampaign.Id + '/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assert(RestContext.response != null);
    }
    
    @isTest
    static void testResponseStructure() {
        Campaign testCampaign = getTestCampaign();
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/' + testCampaign.Id;
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        String responseBody = RestContext.response.responseBody.toString();
        System.assert(responseBody.contains('isSuccess'));
    }
    
    @isTest
    static void testErrorResponseStructure() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        String responseBody = RestContext.response.responseBody.toString();
        System.assert(responseBody.contains('isSuccess'));
    }
    
    @isTest
    static void testCaseInsensitiveFieldDisplay() {
        Campaign testCampaign = getTestCampaign();
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/' + testCampaign.Id + '?fieldDisplay=LABEL';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    @isTest
    static void testExtendedCampaignId() {
        Campaign testCampaign = getTestCampaign();
        String extendedId = String.valueOf(testCampaign.Id) + '000';
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/' + extendedId;
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    @isTest
    static void testEmptyFieldDisplay() {
        Campaign testCampaign = getTestCampaign();
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/' + testCampaign.Id + '?fieldDisplay=';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    @isTest
    static void testWhitespaceInCampaignId() {
        Campaign testCampaign = getTestCampaign();
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1.0/partnercenter/campaign/  ' + testCampaign.Id + '  ';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        Core_MDF_Campaign_Details_RestAPI.getCampaignDetails();
        Test.stopTest();
        
        System.assert(RestContext.response != null);
    }
}