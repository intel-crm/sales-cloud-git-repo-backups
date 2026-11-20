@IsTest
private class Core_MDF_PicklistAttributes_RestAPI_Test {
    static final String URI = '/services/apexrest/v1.0/partnercenter/attributesbyprogram';
    
    public class PicklistMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"controllingFields":[],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"MDF","label":"MDF Budget","active":true,"validFor":[]},' +
                        '{"value":"OEM CMP","label":"OEM CMP Budget","active":true,"validFor":[]},' +
                        '{"value":"MDF+","label":"MDF Plus Budget","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Program__c":{' +
                    '"controllerValues":{},' +
                    '"controllingFields":[],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Client","label":"Client","active":true,"validFor":[]},' +
                        '{"value":"Intel Partner Alliance","label":"Intel Partner Alliance","active":true,"validFor":[]},' +
                        '{"value":"Retail Marketing Funds","label":"Retail Marketing Funds","active":true,"validFor":[]},' +
                        '{"value":"Data Center CoMarketing Fund","label":"Datacenter","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"MDF":0,"OEM CMP":1,"MDF+":2},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Demand Gen","label":"Demand Generation","active":true,"validFor":[0,1,2]},' +
                        '{"value":"Marketing","label":"Marketing Activities","active":true,"validFor":[0]},' +
                        '{"value":"Training","label":"Training Programs","active":true,"validFor":[1]},' +
                        '{"value":"Events","label":"Events and Conferences","active":true,"validFor":[0,2]},' +
                        '{"value":"InactiveVal","label":"Inactive Value","active":false,"validFor":[0]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Sub_Category__c":{' +
                    '"controllerValues":{"Demand Gen":0,"Marketing":1,"Training":2,"Events":3},' +
                    '"controllingFields":["Core_MDF_Activity_Category__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Digital","label":"Digital Marketing","active":true,"validFor":[0,1]},' +
                        '{"value":"Print","label":"Print Media","active":true,"validFor":[1]},' +
                        '{"value":"Online","label":"Online Training","active":true,"validFor":[2,3]},' +
                        '{"value":"Webinar","label":"Webinar Sessions","active":true,"validFor":[0,2]},' +
                        '{"value":"Social","label":"Social Media","active":true,"validFor":[0,1,3]}' +
                    ']' +
                '},' +
                '"Core_MDF_Tactic__c":{' +
                    '"controllerValues":{"Digital":0,"Print":1,"Online":2,"Webinar":3,"Social":4},' +
                    '"controllingFields":["Core_MDF_Activity_Sub_Category__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"SEO","label":"Search Engine Optimization","active":true,"validFor":[0,4]},' +
                        '{"value":"SEM","label":"Search Engine Marketing","active":true,"validFor":[0]},' +
                        '{"value":"Brochure","label":"Brochure Design","active":true,"validFor":[1]},' +
                        '{"value":"Video","label":"Video Production","active":true,"validFor":[2,3]},' +
                        '{"value":"Email","label":"Email Campaign","active":true,"validFor":[0,4]}' +
                    ']' +
                '},' +
                '"Core_MDF_Program_Specific__c":{' +
                    '"controllerValues":{"Client":0,"Intel Partner Alliance":1,"Retail Marketing Funds":2,"Data Center CoMarketing Fund":3},' +
                    '"controllingFields":["Core_MDF_Program__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"ClientOpt1","label":"Client Option 1","active":true,"validFor":[0]},' +
                        '{"value":"ClientOpt2","label":"Client Option 2","active":true,"validFor":[0]},' +
                        '{"value":"IPAOpt1","label":"IPA Option 1","active":true,"validFor":[1]},' +
                        '{"value":"RetailOpt1","label":"Retail Option 1","active":true,"validFor":[2]},' +
                        '{"value":"DCOpt1","label":"DC Option 1","active":true,"validFor":[3]}' +
                    ']' +
                '},' +
                '"Core_MDF_Schema_Dep_Field__c":{' +
                    '"controllerValues":{"Demand Gen":0,"Marketing":1},' +
                    '"controllingFields":"Core_MDF_Activity_Category__c",' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"SchemaVal1","label":"Schema Value 1","active":true,"validFor":[]},' +
                        '{"value":"SchemaVal2","label":"Schema Value 2","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Test_Field__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":"Default",' +
                    '"values":[' +
                        '{"value":"Option1","label":"Option One","active":true,"validFor":[]},' +
                        '{"value":"Option2","label":"Option Two","active":true,"validFor":[]},' +
                        '{"value":"Option3","label":"Option Three","active":true,"validFor":[]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class EmptyMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class ErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Server Error');
            return res;
        }
    }
    
    public class NullBodyMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('');
            return res;
        }
    }
    
    @TestSetup
    static void setup() {
        insert new List<ChannelProgram>{
            new ChannelProgram(Name='Client',Core_MDF_Project_Platform__c='Test',Core_MDF_Technical_Program_Name__c='Client CoMarketing Fund'),
            new ChannelProgram(Name='Intel Partner Alliance',Core_MDF_Project_Platform__c='Test',Core_MDF_Technical_Program_Name__c='Intel Partner Alliance'),
            new ChannelProgram(Name='Retail Marketing Funds',Core_MDF_Project_Platform__c='Test',Core_MDF_Technical_Program_Name__c='Retail Marketing Funds'),
            new ChannelProgram(Name='Co-GTM',Core_MDF_Project_Platform__c='Test',Core_MDF_Technical_Program_Name__c='CoGTM'),
            new ChannelProgram(Name='Datacenter',Core_MDF_Project_Platform__c='Test',Core_MDF_Technical_Program_Name__c='Data Center CoMarketing Fund')
        };
    }
    
    static String prog() {
        for (ChannelProgram p : [SELECT Name FROM ChannelProgram WHERE Core_MDF_Project_Platform__c!=null LIMIT 10]) {
            try {
                List<Core_MDF_Custom_Label_Configration__mdt> m = [SELECT Core_MDF_Value_Txt__c,Core_MDF_Value2_Txt__c,Core_MDF_Value3_Txt__c,Core_MDF_Value4_Txt__c,Core_MDF_Value5_Txt__c FROM Core_MDF_Custom_Label_Configration__mdt WHERE DeveloperName='Core_MDF_ProgramRecordTypeMapping' LIMIT 1];
                if (!m.isEmpty()) {
                    String j = '';
                    if (m[0].Core_MDF_Value_Txt__c!=null) j+=m[0].Core_MDF_Value_Txt__c;
                    if (m[0].Core_MDF_Value2_Txt__c!=null) j+=m[0].Core_MDF_Value2_Txt__c;
                    if (m[0].Core_MDF_Value3_Txt__c!=null) j+=m[0].Core_MDF_Value3_Txt__c;
                    if (m[0].Core_MDF_Value4_Txt__c!=null) j+=m[0].Core_MDF_Value4_Txt__c;
                    if (m[0].Core_MDF_Value5_Txt__c!=null) j+=m[0].Core_MDF_Value5_Txt__c;
                    if (j.toLowerCase().contains(p.Name.toLowerCase())) return p.Name;
                }
            } catch(Exception e) {}
        }
        return 'Client';
    }
    
    static RestResponse get(Map<String,String> p) {
        RestRequest r = new RestRequest();
        r.requestURI = URI;
        r.httpMethod = 'GET';
        if (p != null) for (String k : p.keySet()) r.params.put(k, p.get(k));
        RestContext.request = r;
        RestContext.response = new RestResponse();
        Core_MDF_PicklistAttributes_RestAPI.getPicklistValues();
        return RestContext.response;
    }
    
    static RestResponse getPath(String n, Map<String,String> p) {
        RestRequest r = new RestRequest();
        r.requestURI = URI + '/' + (String.isBlank(n)?'':EncodingUtil.urlEncode(n,'UTF-8'));
        r.httpMethod = 'GET';
        if (p != null) for (String k : p.keySet()) r.params.put(k, p.get(k));
        RestContext.request = r;
        RestContext.response = new RestResponse();
        Core_MDF_PicklistAttributes_RestAPI.getPicklistValues();
        return RestContext.response;
    }
    
    @IsTest static void testNullParams() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        RestResponse r = get(null);
        Test.stopTest();
        System.assertNotEquals(null, r);
        System.assertNotEquals(null, r.responseBody);
    }

    @IsTest static void testInvalidParamKey() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'invalidParam'=>'value'});
        get(new Map<String,String>{'badParam1'=>'v1','badParam2'=>'v2'});
        Test.stopTest();
    }

    @IsTest static void testInvalidFieldDisplay() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'fielddisplay'=>'invalid'});
        get(new Map<String,String>{'fielddisplay'=>'xyz'});
        Test.stopTest();
    }

    @IsTest static void testInvalidProgram() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'NonExistent_XYZ_999'});
        get(new Map<String,String>{'programName'=>'   '});
        Test.stopTest();
    }

    @IsTest static void testEmptyProgram() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>''});
        Test.stopTest();
    }

    @IsTest static void testFieldDisplayLabelWithValidProgram() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label'});
        Test.stopTest();
    }
    
    @IsTest static void testFieldDisplayLabelCaseVariations() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'LABEL'});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'Label'});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'  label  '});
        Test.stopTest();
    }
    
    @IsTest static void testFieldDisplayLabelWithControllingValue() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label','controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label','controllingFieldValue'=>'OEM CMP'});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label','controllingFieldValue'=>'MDF+'});
        Test.stopTest();
    }
    
    @IsTest static void testFieldDisplayTechnicalName() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'technicalname'});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'TECHNICALNAME'});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'TechnicalName'});
        Test.stopTest();
    }

    @IsTest static void testControllingFieldValueBasic() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'controllingFieldValue'=>'MDF','orphan'=>''});
        get(new Map<String,String>{'controllingFieldValue'=>'Test','unknown'=>''});
        Test.stopTest();
    }
    
    @IsTest static void testControllingFieldValueWithProgram() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'OEM CMP'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'MDF+'});
        Test.stopTest();
    }
    
    @IsTest static void testControllingFieldValueVariants() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'MDF '});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'Value&Part'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'%26encoded'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'Test+Value'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'Test Value'});
        Test.stopTest();
    }
    
    @IsTest static void testInvalidControllingValue() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'InvalidCtrl999'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'XYZ_NOT_EXIST'});
        Test.stopTest();
    }

    @IsTest static void testUriPathExtraction() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        getPath('TestProgram', null);
        getPath('Program With Space', null);
        getPath('', null);
        getPath('Program%26Name', null);
        Test.stopTest();
    }
    
    @IsTest static void testUriEdgeCases() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        RestRequest r = new RestRequest();
        r.requestURI = URI + '/';
        r.httpMethod = 'GET';
        RestContext.request = r;
        RestContext.response = new RestResponse();
        Core_MDF_PicklistAttributes_RestAPI.getPicklistValues();
        
        r = new RestRequest();
        r.requestURI = URI + '//TestProg';
        r.httpMethod = 'GET';
        RestContext.request = r;
        RestContext.response = new RestResponse();
        Core_MDF_PicklistAttributes_RestAPI.getPicklistValues();
        
        r = new RestRequest();
        r.requestURI = URI + '/Test%2FProg';
        r.httpMethod = 'GET';
        RestContext.request = r;
        RestContext.response = new RestResponse();
        Core_MDF_PicklistAttributes_RestAPI.getPicklistValues();
        Test.stopTest();
    }
    
    @IsTest static void testValidProgramProcessing() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        Test.stopTest();
    }
    
    @IsTest static void testValidProgramWithAllParams() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label','controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'technicalname','controllingFieldValue'=>'OEM CMP'});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label','controllingFieldValue'=>'MDF+'});
        Test.stopTest();
    }
    
    @IsTest static void testValidProgramViaPath() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        getPath(p, null);
        getPath(p, new Map<String,String>{'fielddisplay'=>'label'});
        getPath(p.toLowerCase(), null);
        getPath(p, new Map<String,String>{'controllingFieldValue'=>'MDF'});
        getPath(p, new Map<String,String>{'fielddisplay'=>'label','controllingFieldValue'=>'MDF'});
        Test.stopTest();
    }

    @IsTest static void testClientProgram() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'Client'});
        get(new Map<String,String>{'programName'=>'client'});
        get(new Map<String,String>{'programName'=>'CLIENT'});
        get(new Map<String,String>{'programName'=>'Client','fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>'Client','controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>'Client','fielddisplay'=>'label','controllingFieldValue'=>'MDF'});
        Test.stopTest();
    }

    @IsTest static void testIPAProgram() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'Intel Partner Alliance'});
        get(new Map<String,String>{'programName'=>'intel partner alliance'});
        get(new Map<String,String>{'programName'=>'Intel Partner Alliance','fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>'Intel Partner Alliance','controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>'Intel Partner Alliance','fielddisplay'=>'label','controllingFieldValue'=>'MDF'});
        Test.stopTest();
    }

    @IsTest static void testRetailProgram() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'Retail Marketing Funds'});
        get(new Map<String,String>{'programName'=>'Retail Marketing Funds','fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>'Retail Marketing Funds','controllingFieldValue'=>'MDF'});
        Test.stopTest();
    }

    @IsTest static void testCoGTMProgram() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'Co-GTM'});
        get(new Map<String,String>{'programName'=>'Co-GTM','fielddisplay'=>'label'});
        Test.stopTest();
    }

    @IsTest static void testDatacenterProgram() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'Datacenter'});
        get(new Map<String,String>{'programName'=>'Datacenter','fielddisplay'=>'label'});
        Test.stopTest();
    }

    @IsTest static void testHttpError() {
        Test.setMock(HttpCalloutMock.class, new ErrorMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        Test.stopTest();
    }

    @IsTest static void testEmptyResponse() {
        Test.setMock(HttpCalloutMock.class, new EmptyMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        Test.stopTest();
    }
    
    @IsTest static void testNullBodyResponse() {
        Test.setMock(HttpCalloutMock.class, new NullBodyMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        Test.stopTest();
    }

    @IsTest static void testNullResponseInit() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        RestContext.request = null;
        RestContext.response = null;
        Test.startTest();
        Core_MDF_PicklistAttributes_RestAPI.getPicklistValues();
        Test.stopTest();
        System.assertNotEquals(null, RestContext.response);
    }

    @IsTest static void testProgramNotInCMDT() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        insert new ChannelProgram(Name='NewTestProg',Core_MDF_Project_Platform__c='Y');
        Test.startTest();
        get(new Map<String,String>{'programName'=>'NewTestProg'});
        Test.stopTest();
    }

    @IsTest static void testProgramWithoutPlatform() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        insert new ChannelProgram(Name='NoPlatformProg');
        Test.startTest();
        get(new Map<String,String>{'programName'=>'NoPlatformProg'});
        Test.stopTest();
    }
    
    @IsTest static void testProgramEdgeCases() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'   Test   '});
        get(new Map<String,String>{'programName'=>'LongProgramName1234567890'});
        get(new Map<String,String>{'programName'=>'Prog_123'});
        get(new Map<String,String>{'programName'=>'Prog-Name'});
        Test.stopTest();
    }

    @IsTest static void testMixedParams() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'fielddisplay'=>'label','bad'=>'val'});
        get(new Map<String,String>{'fielddisplay'=>'label','controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'unknownParam'=>''});
        Test.stopTest();
    }
    
    @IsTest static void testEmptyRequest() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        RestRequest r = new RestRequest();
        r.requestURI = URI;
        r.httpMethod = 'GET';
        RestContext.request = r;
        RestContext.response = new RestResponse();
        Test.startTest();
        Core_MDF_PicklistAttributes_RestAPI.getPicklistValues();
        Test.stopTest();
    }

    @IsTest static void testPathSpecialChars() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        getPath('Client', new Map<String,String>{'fielddisplay'=>'label'});
        getPath('Intel Partner Alliance', new Map<String,String>{'controllingFieldValue'=>'MDF'});
        getPath('Retail Marketing Funds', new Map<String,String>{'fielddisplay'=>'technicalname'});
        getPath('Intel Partner Alliance', new Map<String,String>{'fielddisplay'=>'label','controllingFieldValue'=>'MDF'});
        Test.stopTest();
    }

    @IsTest static void testConstants() {
        Test.startTest();
        System.assertEquals(Core_MDF_Attributes_RestAPIConstants.HTTP_200, Core_MDF_Attributes_RestAPIConstants.getHttpStatusByApiCode(Core_MDF_Attributes_RestAPIConstants.CODE_200));
        System.assertEquals(Core_MDF_Attributes_RestAPIConstants.HTTP_400, Core_MDF_Attributes_RestAPIConstants.getHttpStatusByApiCode(Core_MDF_Attributes_RestAPIConstants.CODE_1000_PROGRAM_NAME_REQUIRED));
        System.assertEquals(Core_MDF_Attributes_RestAPIConstants.HTTP_400, Core_MDF_Attributes_RestAPIConstants.getHttpStatusByApiCode(Core_MDF_Attributes_RestAPIConstants.CODE_1001_INVALID_PROGRAM_NAME));
        System.assertEquals(Core_MDF_Attributes_RestAPIConstants.HTTP_404, Core_MDF_Attributes_RestAPIConstants.getHttpStatusByApiCode(Core_MDF_Attributes_RestAPIConstants.CODE_1002_NO_PICKLIST_VALUES_FOUND));
        System.assertEquals(Core_MDF_Attributes_RestAPIConstants.HTTP_400, Core_MDF_Attributes_RestAPIConstants.getHttpStatusByApiCode(Core_MDF_Attributes_RestAPIConstants.CODE_1003_INVALID_PARAMETER_KEY));
        System.assertEquals(Core_MDF_Attributes_RestAPIConstants.HTTP_500, Core_MDF_Attributes_RestAPIConstants.getHttpStatusByApiCode(Core_MDF_Attributes_RestAPIConstants.CODE_1004_APPLICATION_ERROR));
        System.assertEquals(Core_MDF_Attributes_RestAPIConstants.HTTP_400, Core_MDF_Attributes_RestAPIConstants.getHttpStatusByApiCode(Core_MDF_Attributes_RestAPIConstants.CODE_1005_INVALID_FIELDDISPLAY_VALUE));
        System.assertEquals(Core_MDF_Attributes_RestAPIConstants.HTTP_400, Core_MDF_Attributes_RestAPIConstants.getHttpStatusByApiCode(Core_MDF_Attributes_RestAPIConstants.CODE_1006_INVALID_CONTROLLING_VALUE));
        System.assertEquals(Core_MDF_Attributes_RestAPIConstants.HTTP_500, Core_MDF_Attributes_RestAPIConstants.getHttpStatusByApiCode('UNKNOWN'));
        System.assertNotEquals(null, Core_MDF_Attributes_RestAPIConstants.HTTP_200);
        System.assertNotEquals(null, Core_MDF_Attributes_RestAPIConstants.HTTP_400);
        System.assertNotEquals(null, Core_MDF_Attributes_RestAPIConstants.HTTP_404);
        System.assertNotEquals(null, Core_MDF_Attributes_RestAPIConstants.HTTP_500);
        Test.stopTest();
    }

    @IsTest static void testFullCombinationsWithLabel() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label','controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label','controllingFieldValue'=>'OEM CMP'});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label','controllingFieldValue'=>'MDF+'});
        Test.stopTest();
    }
    
    @IsTest static void testAllProgramsWithLabel() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'Client','fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>'Intel Partner Alliance','fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>'Retail Marketing Funds','fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>'Co-GTM','fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>'Datacenter','fielddisplay'=>'label'});
        Test.stopTest();
    }
    
    @IsTest static void testAllProgramsWithLabelAndCtrlValue() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'Client','fielddisplay'=>'label','controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>'Intel Partner Alliance','fielddisplay'=>'label','controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>'Retail Marketing Funds','fielddisplay'=>'label','controllingFieldValue'=>'OEM CMP'});
        get(new Map<String,String>{'programName'=>'Co-GTM','fielddisplay'=>'label','controllingFieldValue'=>'MDF+'});
        get(new Map<String,String>{'programName'=>'Datacenter','fielddisplay'=>'label','controllingFieldValue'=>'MDF'});
        Test.stopTest();
    }

    @IsTest static void testPathWithLabel() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        getPath(p, new Map<String,String>{'fielddisplay'=>'label'});
        getPath(p, new Map<String,String>{'fielddisplay'=>'label','controllingFieldValue'=>'MDF'});
        getPath('Client', new Map<String,String>{'fielddisplay'=>'label'});
        getPath('Intel Partner Alliance', new Map<String,String>{'fielddisplay'=>'label'});
        Test.stopTest();
    }

    @IsTest static void testMultipleCtrlValues() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'OEM CMP'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'MDF+'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'MDF','fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'OEM CMP','fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'MDF+','fielddisplay'=>'label'});
        Test.stopTest();
    }

    @IsTest static void testProgramDependencyPaths() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'Client'});
        get(new Map<String,String>{'programName'=>'Intel Partner Alliance'});
        get(new Map<String,String>{'programName'=>'Retail Marketing Funds'});
        get(new Map<String,String>{'programName'=>'Datacenter'});
        Test.stopTest();
    }
    
    @IsTest static void testProgramDependencyWithControllingField() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'Client','controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>'Intel Partner Alliance','controllingFieldValue'=>'OEM CMP'});
        get(new Map<String,String>{'programName'=>'Retail Marketing Funds','controllingFieldValue'=>'MDF+'});
        get(new Map<String,String>{'programName'=>'Datacenter','controllingFieldValue'=>'MDF'});
        Test.stopTest();
    }
    
    @IsTest static void testProgramDependencyWithLabels() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'Client','fielddisplay'=>'label','controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>'Intel Partner Alliance','fielddisplay'=>'label','controllingFieldValue'=>'OEM CMP'});
        Test.stopTest();
    }
    
    @IsTest static void testFieldToFieldDependency() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label'});
        Test.stopTest();
    }
    
    @IsTest static void testChainedDependencies() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'Client','controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>'Client','controllingFieldValue'=>'MDF','fielddisplay'=>'label'});
        Test.stopTest();
    }
    
    @IsTest static void testSchemaFallback() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'Client'});
        get(new Map<String,String>{'programName'=>'Intel Partner Alliance'});
        Test.stopTest();
    }
    
    @IsTest static void testSchemaFallbackWithLabels() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'Client','fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>'Intel Partner Alliance','fielddisplay'=>'label'});
        Test.stopTest();
    }
    
    @IsTest static void testValidForFiltering() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'OEM CMP'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'MDF+'});
        Test.stopTest();
    }
    
    @IsTest static void testValidForWithLabelDisplay() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'MDF','fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'OEM CMP','fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'MDF+','fielddisplay'=>'label'});
        Test.stopTest();
    }
    
    @IsTest static void testDependencyIndexResolution() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        for (String prog : new List<String>{'Client','Intel Partner Alliance','Retail Marketing Funds','Co-GTM','Datacenter'}) {
            get(new Map<String,String>{'programName'=>prog});
            get(new Map<String,String>{'programName'=>prog,'controllingFieldValue'=>'MDF'});
        }
        Test.stopTest();
    }
    
    @IsTest static void testDependencyEdgeCases() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>''});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'  '});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'mdf'});
        Test.stopTest();
    }
    
    @IsTest static void testAllProgramsAllCtrlValues() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        List<String> progs = new List<String>{'Client','Intel Partner Alliance','Retail Marketing Funds','Co-GTM','Datacenter'};
        List<String> ctrlVals = new List<String>{'MDF','OEM CMP','MDF+'};
        for (String p : progs) {
            for (String c : ctrlVals) {
                get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>c});
            }
        }
        Test.stopTest();
    }
    
    @IsTest static void testAllProgramsAllCtrlValuesWithLabels() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        List<String> progs = new List<String>{'Client','Intel Partner Alliance','Retail Marketing Funds','Co-GTM','Datacenter'};
        List<String> ctrlVals = new List<String>{'MDF','OEM CMP','MDF+'};
        for (String p : progs) {
            for (String c : ctrlVals) {
                get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>c,'fielddisplay'=>'label'});
            }
        }
        Test.stopTest();
    }
    
    @IsTest static void testPathDependencyProcessing() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        getPath('Client', new Map<String,String>{'controllingFieldValue'=>'MDF'});
        getPath('Intel Partner Alliance', new Map<String,String>{'controllingFieldValue'=>'OEM CMP'});
        getPath('Retail Marketing Funds', new Map<String,String>{'controllingFieldValue'=>'MDF+'});
        getPath('Datacenter', new Map<String,String>{'controllingFieldValue'=>'MDF'});
        Test.stopTest();
    }
    
    @IsTest static void testPathDependencyWithLabels() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        getPath('Client', new Map<String,String>{'controllingFieldValue'=>'MDF','fielddisplay'=>'label'});
        getPath('Intel Partner Alliance', new Map<String,String>{'controllingFieldValue'=>'OEM CMP','fielddisplay'=>'label'});
        getPath('Retail Marketing Funds', new Map<String,String>{'controllingFieldValue'=>'MDF+','fielddisplay'=>'label'});
        Test.stopTest();
    }
    
    @IsTest static void testControllingFieldsMetadataArray() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'OEM CMP','fielddisplay'=>'label'});
        Test.stopTest();
    }
    
    @IsTest static void testControllingFieldsMetadataString() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label'});
        Test.stopTest();
    }
    
    @IsTest static void testSchemaDepMapWithRealFields() {
        Test.setMock(HttpCalloutMock.class, new RealFieldMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label'});
        Test.stopTest();
    }
    
    public class RealFieldMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"controllingFields":[],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"MDF","label":"MDF","active":true,"validFor":[]},' +
                        '{"value":"OEM CMP","label":"OEM CMP","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"MDF":0,"OEM CMP":1},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Demand Gen","label":"Demand Gen","active":true,"validFor":[]},' +
                        '{"value":"Marketing","label":"Marketing","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Sub_Category__c":{' +
                    '"controllerValues":{"Demand Gen":0,"Marketing":1},' +
                    '"controllingFields":["Core_MDF_Activity_Category__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Digital","label":"Digital","active":true,"validFor":[]},' +
                        '{"value":"Print","label":"Print","active":true,"validFor":[]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testBuildControllerMaps() {
        Test.setMock(HttpCalloutMock.class, new ControllerMapMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'Alpha'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'Beta'});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label'});
        Test.stopTest();
    }
    
    public class ControllerMapMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"controllingFields":[],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Alpha","label":"Alpha Label","active":true,"validFor":[]},' +
                        '{"value":"Beta","label":"Beta Label","active":true,"validFor":[]},' +
                        '{"value":"Gamma","label":"Gamma Label","active":false,"validFor":[]},' +
                        '{"value":"Delta","label":"Delta Label","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"Alpha":0,"Beta":1,"Gamma":2,"Delta":3},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Cat1","label":"Category 1","active":true,"validFor":[0,1]},' +
                        '{"value":"Cat2","label":"Category 2","active":true,"validFor":[1,2]},' +
                        '{"value":"Cat3","label":"Category 3","active":false,"validFor":[0]},' +
                        '{"value":"Cat4","label":"Category 4","active":true,"validFor":[2,3]},' +
                        '{"value":"Cat5","label":"Category 5","active":true,"validFor":[0,1,2,3]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testDependentFieldInference() {
        Test.setMock(HttpCalloutMock.class, new InferenceMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'Val1'});
        Test.stopTest();
    }
    
    public class InferenceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Val1","label":"Value 1","active":true,"validFor":[]},' +
                        '{"value":"Val2","label":"Value 2","active":true,"validFor":[]},' +
                        '{"value":"Val3","label":"Value 3","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"Val1":0,"Val2":1,"Val3":2},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Inferred1","label":"Inferred 1","active":true,"validFor":[0]},' +
                        '{"value":"Inferred2","label":"Inferred 2","active":true,"validFor":[1,2]},' +
                        '{"value":"Inferred3","label":"Inferred 3","active":true,"validFor":[0,1,2]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testMultipleControllingFieldsCandidates() {
        Test.setMock(HttpCalloutMock.class, new MultiCandidateMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'X1'});
        Test.stopTest();
    }
    
    public class MultiCandidateMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"X1","label":"X One","active":true,"validFor":[]},' +
                        '{"value":"X2","label":"X Two","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Program__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Y1","label":"Y One","active":true,"validFor":[]},' +
                        '{"value":"Y2","label":"Y Two","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"X1":0,"X2":1},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Dep1","label":"Dependent 1","active":true,"validFor":[0]},' +
                        '{"value":"Dep2","label":"Dependent 2","active":true,"validFor":[1]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testHtmlDecodedValues() {
        Test.setMock(HttpCalloutMock.class, new HtmlEncodedMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'Value&Amp'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'Value<Less'});
        Test.stopTest();
    }
    
    public class HtmlEncodedMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Value&amp;Amp","label":"Value &amp; Amp","active":true,"validFor":[]},' +
                        '{"value":"Value&lt;Less","label":"Value < Less","active":true,"validFor":[]},' +
                        '{"value":"Value&gt;More","label":"Value > More","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"Value&amp;Amp":0,"Value&lt;Less":1,"Value&gt;More":2},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"HtmlDep1","label":"Html Dep 1","active":true,"validFor":[0,1]},' +
                        '{"value":"HtmlDep2","label":"Html Dep 2","active":true,"validFor":[2]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testMissingValueKey() {
        Test.setMock(HttpCalloutMock.class, new MissingValueMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label'});
        Test.stopTest();
    }
    
    public class MissingValueMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Good1","label":"Good One","active":true,"validFor":[]},' +
                        '{"label":"No Value Key","active":true,"validFor":[]},' +
                        '{"value":"Good2","label":"Good Two","active":true,"validFor":[]},' +
                        '{"value":"","label":"Empty Value","active":true,"validFor":[]},' +
                        '{"value":null,"label":"Null Value","active":true,"validFor":[]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testNullControllerValues() {
        Test.setMock(HttpCalloutMock.class, new NullControllerMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        Test.stopTest();
    }
    
    public class NullControllerMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":null,' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"NullCtrl1","label":"Null Ctrl 1","active":true,"validFor":[]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testEmptyValuesArray() {
        Test.setMock(HttpCalloutMock.class, new EmptyValuesMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        Test.stopTest();
    }
    
    public class EmptyValuesMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":"Default",' +
                    '"values":[]' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[]' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testIndexMismatchInference() {
        Test.setMock(HttpCalloutMock.class, new IndexMismatchMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'MDF'});
        Test.stopTest();
    }
    
    public class IndexMismatchMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"MDF","label":"MDF","active":true,"validFor":[]},' +
                        '{"value":"OEM","label":"OEM","active":true,"validFor":[]},' +
                        '{"value":"IPA","label":"IPA","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Program__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Prog1","label":"Program 1","active":true,"validFor":[]},' +
                        '{"value":"Prog2","label":"Program 2","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"MDF":0,"OEM":1,"IPA":2},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Match1","label":"Match 1","active":true,"validFor":[0]},' +
                        '{"value":"Match2","label":"Match 2","active":true,"validFor":[1,2]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testStringBasedValidFor() {
        Test.setMock(HttpCalloutMock.class, new StringValidForMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'Ctrl1'});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label'});
        Test.stopTest();
    }
    
    public class StringValidForMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"controllingFields":[],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Ctrl1","label":"Controller 1","active":true,"validFor":[]},' +
                        '{"value":"Ctrl2","label":"Controller 2","active":true,"validFor":[]},' +
                        '{"value":"Ctrl3","label":"Controller 3","active":true,"validFor":[]},' +
                        '{"value":"Ctrl4","label":"Controller 4","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"Ctrl1":0,"Ctrl2":1,"Ctrl3":2,"Ctrl4":3},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Dep1","label":"Dep One","active":true,"validFor":"gA=="},' +
                        '{"value":"Dep2","label":"Dep Two","active":true,"validFor":"QA=="},' +
                        '{"value":"Dep3","label":"Dep Three","active":true,"validFor":"IA=="},' +
                        '{"value":"Dep4","label":"Dep Four","active":true,"validFor":"EA=="}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testMixedValidForTypes() {
        Test.setMock(HttpCalloutMock.class, new MixedValidForMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'C1'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'C2'});
        Test.stopTest();
    }
    
    public class MixedValidForMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"C1","label":"C One","active":true,"validFor":[]},' +
                        '{"value":"C2","label":"C Two","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"C1":0,"C2":1},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Mix1","label":"Mix One","active":true,"validFor":[0]},' +
                        '{"value":"Mix2","label":"Mix Two","active":true,"validFor":"QA=="},' +
                        '{"value":"Mix3","label":"Mix Three","active":true,"validFor":[0,1]},' +
                        '{"value":"Mix4","label":"Mix Four","active":true,"validFor":"gA=="}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testLargeControllerSet() {
        Test.setMock(HttpCalloutMock.class, new LargeControllerMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'V0'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'V7'});
        Test.stopTest();
    }
    
    public class LargeControllerMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"V0","label":"Value 0","active":true,"validFor":[]},' +
                        '{"value":"V1","label":"Value 1","active":true,"validFor":[]},' +
                        '{"value":"V2","label":"Value 2","active":true,"validFor":[]},' +
                        '{"value":"V3","label":"Value 3","active":true,"validFor":[]},' +
                        '{"value":"V4","label":"Value 4","active":true,"validFor":[]},' +
                        '{"value":"V5","label":"Value 5","active":true,"validFor":[]},' +
                        '{"value":"V6","label":"Value 6","active":true,"validFor":[]},' +
                        '{"value":"V7","label":"Value 7","active":true,"validFor":[]},' +
                        '{"value":"V8","label":"Value 8","active":true,"validFor":[]},' +
                        '{"value":"V9","label":"Value 9","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"V0":0,"V1":1,"V2":2,"V3":3,"V4":4,"V5":5,"V6":6,"V7":7,"V8":8,"V9":9},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"D0","label":"Dep 0","active":true,"validFor":[0,2,4,6,8]},' +
                        '{"value":"D1","label":"Dep 1","active":true,"validFor":[1,3,5,7,9]},' +
                        '{"value":"D2","label":"Dep 2","active":true,"validFor":[0,1,2,3]},' +
                        '{"value":"D3","label":"Dep 3","active":true,"validFor":[4,5,6,7,8,9]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testNullActiveFlag() {
        Test.setMock(HttpCalloutMock.class, new NullActiveMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label'});
        Test.stopTest();
    }
    
    public class NullActiveMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"NA1","label":"Null Active 1","validFor":[]},' +
                        '{"value":"NA2","label":"Null Active 2","active":null,"validFor":[]},' +
                        '{"value":"NA3","label":"Null Active 3","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"NA1":0,"NA2":1,"NA3":2},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"DepNA1","label":"Dep NA 1","validFor":[0,1]},' +
                        '{"value":"DepNA2","label":"Dep NA 2","active":null,"validFor":[1,2]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testAllProgramsWithDiffMocks() {
        Test.startTest();
        List<String> progs = new List<String>{'Client','Intel Partner Alliance','Retail Marketing Funds','Co-GTM','Datacenter'};
        
        Test.setMock(HttpCalloutMock.class, new RealFieldMock());
        for (String p : progs) {
            get(new Map<String,String>{'programName'=>p});
        }
        
        Test.setMock(HttpCalloutMock.class, new InferenceMock());
        for (String p : progs) {
            get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'Val1'});
        }
        
        Test.stopTest();
    }
    
    @IsTest static void testControllerFieldsNullInList() {
        Test.setMock(HttpCalloutMock.class, new NullInControllingFieldsMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        Test.stopTest();
    }
    
    public class NullInControllingFieldsMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"ListNull1","label":"List Null 1","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"ListNull1":0},' +
                    '"controllingFields":[null,"","Core_MDF_Controlling_Field_nm__c"," "],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"DepListNull","label":"Dep List Null","active":true,"validFor":[0]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testControllerValuesWithInvalidTypes() {
        Test.setMock(HttpCalloutMock.class, new InvalidControllerValuesMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'Str1'});
        Test.stopTest();
    }
    
    public class InvalidControllerValuesMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Str1","label":"String 1","active":true,"validFor":[]},' +
                        '{"value":"Str2","label":"String 2","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"Str1":"0","Str2":"1"},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"DepStr1","label":"Dep Str 1","active":true,"validFor":[0]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testAllHtmlEntities() {
        Test.setMock(HttpCalloutMock.class, new AllHtmlEntitiesMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'QuoteVal'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'AposVal'});
        Test.stopTest();
    }
    
    public class AllHtmlEntitiesMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Quote&quot;Val","label":"Quote Val","active":true,"validFor":[]},' +
                        '{"value":"Apos&#39;Val","label":"Apos Val","active":true,"validFor":[]},' +
                        '{"value":"Apos2&apos;Val","label":"Apos2 Val","active":true,"validFor":[]},' +
                        '{"value":"Mixed&amp;&lt;&gt;","label":"Mixed Value","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"Quote&quot;Val":0,"Apos&#39;Val":1,"Apos2&apos;Val":2,"Mixed&amp;&lt;&gt;":3},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Html&amp;Dep1","label":"Html Dep1","active":true,"validFor":[0,1]},' +
                        '{"value":"Html&quot;Dep2","label":"Html Dep2","active":true,"validFor":[2,3]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testNullFieldDetails() {
        Test.setMock(HttpCalloutMock.class, new NullFieldDetailsMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        Test.stopTest();
    }
    
    public class NullFieldDetailsMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":null' +
                '},' +
                '"Core_MDF_Activity_Category__c":null' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testPicklistFieldValuesNull() {
        Test.setMock(HttpCalloutMock.class, new NullPicklistFieldValuesMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        Test.stopTest();
    }
    
    public class NullPicklistFieldValuesMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"picklistFieldValues":null}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testDeepDependencyChain() {
        Test.setMock(HttpCalloutMock.class, new DeepChainMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'Root1'});
        Test.stopTest();
    }
    
    public class DeepChainMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"controllingFields":[],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Root1","label":"Root One","active":true,"validFor":[]},' +
                        '{"value":"Root2","label":"Root Two","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"Root1":0,"Root2":1},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"L1A","label":"Level 1 A","active":true,"validFor":[0]},' +
                        '{"value":"L1B","label":"Level 1 B","active":true,"validFor":[0,1]},' +
                        '{"value":"L1C","label":"Level 1 C","active":true,"validFor":[1]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Sub_Category__c":{' +
                    '"controllerValues":{"L1A":0,"L1B":1,"L1C":2},' +
                    '"controllingFields":["Core_MDF_Activity_Category__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"L2A","label":"Level 2 A","active":true,"validFor":[0,1]},' +
                        '{"value":"L2B","label":"Level 2 B","active":true,"validFor":[1,2]},' +
                        '{"value":"L2C","label":"Level 2 C","active":true,"validFor":[0,2]}' +
                    ']' +
                '},' +
                '"Core_MDF_Tactic__c":{' +
                    '"controllerValues":{"L2A":0,"L2B":1,"L2C":2},' +
                    '"controllingFields":["Core_MDF_Activity_Sub_Category__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"L3A","label":"Level 3 A","active":true,"validFor":[0]},' +
                        '{"value":"L3B","label":"Level 3 B","active":true,"validFor":[0,1]},' +
                        '{"value":"L3C","label":"Level 3 C","active":true,"validFor":[1,2]},' +
                        '{"value":"L3D","label":"Level 3 D","active":true,"validFor":[2]}' +
                    ']' +
                '},' +
                '"Core_MDF_Sub_Tactic__c":{' +
                    '"controllerValues":{"L3A":0,"L3B":1,"L3C":2,"L3D":3},' +
                    '"controllingFields":["Core_MDF_Tactic__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"L4A","label":"Level 4 A","active":true,"validFor":[0,1]},' +
                        '{"value":"L4B","label":"Level 4 B","active":true,"validFor":[2,3]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testMalformedJsonResponse() {
        Test.setMock(HttpCalloutMock.class, new MalformedJsonMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        Test.stopTest();
    }
    
    public class MalformedJsonMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{invalid json');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testProgramDependencyWithMDFValue() {
        Test.setMock(HttpCalloutMock.class, new ProgramDepMock());
        Test.startTest();
        get(new Map<String,String>{'programName'=>'Client'});
        get(new Map<String,String>{'programName'=>'Intel Partner Alliance'});
        get(new Map<String,String>{'programName'=>'Client','controllingFieldValue'=>'MDF'});
        get(new Map<String,String>{'programName'=>'Intel Partner Alliance','controllingFieldValue'=>'OEM CMP'});
        Test.stopTest();
    }
    
    public class ProgramDepMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"MDF","label":"MDF","active":true,"validFor":[]},' +
                        '{"value":"OEM CMP","label":"OEM CMP","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Program__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Client","label":"Client Program","active":true,"validFor":[]},' +
                        '{"value":"Intel Partner Alliance","label":"IPA Program","active":true,"validFor":[]},' +
                        '{"value":"Retail Marketing Funds","label":"Retail Program","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Program_Option__c":{' +
                    '"controllerValues":{"Client":0,"Intel Partner Alliance":1,"Retail Marketing Funds":2},' +
                    '"controllingFields":["Core_MDF_Program__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"ClientOnly","label":"Client Only Option","active":true,"validFor":[0]},' +
                        '{"value":"IPAOnly","label":"IPA Only Option","active":true,"validFor":[1]},' +
                        '{"value":"RetailOnly","label":"Retail Only Option","active":true,"validFor":[2]},' +
                        '{"value":"AllPrograms","label":"All Programs Option","active":true,"validFor":[0,1,2]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"MDF":0,"OEM CMP":1},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Cat1","label":"Category 1","active":true,"validFor":[0]},' +
                        '{"value":"Cat2","label":"Category 2","active":true,"validFor":[0,1]},' +
                        '{"value":"Cat3","label":"Category 3","active":true,"validFor":[1]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testDefaultValueProcessing() {
        Test.setMock(HttpCalloutMock.class, new DefaultValueMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'fielddisplay'=>'label'});
        Test.stopTest();
    }
    
    public class DefaultValueMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":{"value":"DefVal1"},' +
                    '"values":[' +
                        '{"value":"DefVal1","label":"Default Value 1","active":true,"validFor":[]},' +
                        '{"value":"DefVal2","label":"Default Value 2","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Test_Field__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":"SimpleDefault",' +
                    '"values":[' +
                        '{"value":"SimpleDefault","label":"Simple Default","active":true,"validFor":[]},' +
                        '{"value":"Other","label":"Other Value","active":true,"validFor":[]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testControllerIndexEdgeCases() {
        Test.setMock(HttpCalloutMock.class, new IndexEdgeMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'Ctrl1'});
        Test.stopTest();
    }
    
    public class IndexEdgeMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Ctrl1","label":"Ctrl 1","active":true,"validFor":[]},' +
                        '{"value":"Ctrl2","label":"Ctrl 2","active":true,"validFor":[]},' +
                        '{"value":"Ctrl3","label":"Ctrl 3","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"Ctrl1":0,"Ctrl2":5,"Ctrl3":10},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Dep1","label":"Dep 1","active":true,"validFor":[0]},' +
                        '{"value":"Dep2","label":"Dep 2","active":true,"validFor":[5]},' +
                        '{"value":"Dep3","label":"Dep 3","active":true,"validFor":[10]},' +
                        '{"value":"Dep4","label":"Dep 4","active":true,"validFor":[0,5,10]},' +
                        '{"value":"Dep5","label":"Dep 5","active":true,"validFor":[99]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testBlankWhitespaceValues() {
        Test.setMock(HttpCalloutMock.class, new BlankValuesMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'   '});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>''});
        Test.stopTest();
    }
    
    public class BlankValuesMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Valid1","label":"Valid One","active":true,"validFor":[]},' +
                        '{"value":"   ","label":"Whitespace Value","active":true,"validFor":[]},' +
                        '{"value":"Valid2","label":"Valid Two","active":true,"validFor":[]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testCaseSensitivity() {
        Test.setMock(HttpCalloutMock.class, new CaseSensitiveMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'lower'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'UPPER'});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'MixedCase'});
        Test.stopTest();
    }
    
    public class CaseSensitiveMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"lower","label":"Lowercase","active":true,"validFor":[]},' +
                        '{"value":"UPPER","label":"Uppercase","active":true,"validFor":[]},' +
                        '{"value":"MixedCase","label":"Mixed Case","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"lower":0,"UPPER":1,"MixedCase":2},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"DepLower","label":"Dep Lower","active":true,"validFor":[0]},' +
                        '{"value":"DepUpper","label":"Dep Upper","active":true,"validFor":[1]},' +
                        '{"value":"DepMixed","label":"Dep Mixed","active":true,"validFor":[2]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testComprehensivePaths() {
        Test.setMock(HttpCalloutMock.class, new PicklistMock());
        Test.startTest();
        List<String> allProgs = new List<String>{'Client','Intel Partner Alliance','Retail Marketing Funds','Co-GTM','Datacenter'};
        List<String> allCtrls = new List<String>{'MDF','OEM CMP','MDF+'};
        List<String> allDisplays = new List<String>{'label','technicalname',''};
        
        for (Integer i = 0; i < allProgs.size(); i++) {
            String prog = allProgs[i];
            String ctrl = allCtrls[Math.mod(i, allCtrls.size())];
            String display = allDisplays[Math.mod(i, allDisplays.size())];
            
            Map<String,String> params = new Map<String,String>{'programName'=>prog};
            if (String.isNotBlank(ctrl)) params.put('controllingFieldValue', ctrl);
            if (String.isNotBlank(display)) params.put('fielddisplay', display);
            get(params);
            getPath(prog, params);
        }
        Test.stopTest();
    }
        
    @IsTest static void testNullInValidForArray() {
        Test.setMock(HttpCalloutMock.class, new NullValidForMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'Ctrl1'});
        Test.stopTest();
    }
    
    public class NullValidForMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Ctrl1","label":"Controller 1","active":true,"validFor":[]},' +
                        '{"value":"Ctrl2","label":"Controller 2","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"Ctrl1":0,"Ctrl2":1},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Dep1","label":"Dep 1","active":true,"validFor":[null,0]},' +
                        '{"value":"Dep2","label":"Dep 2","active":true,"validFor":[0,null,1]},' +
                        '{"value":"Dep3","label":"Dep 3","active":true,"validFor":[1]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest static void testDuplicateValues() {
        Test.setMock(HttpCalloutMock.class, new DuplicateValuesMock());
        String p = prog();
        Test.startTest();
        get(new Map<String,String>{'programName'=>p});
        get(new Map<String,String>{'programName'=>p,'controllingFieldValue'=>'Same'});
        Test.stopTest();
    }
    
    public class DuplicateValuesMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = '{"picklistFieldValues":{' +
                '"Core_MDF_Controlling_Field_nm__c":{' +
                    '"controllerValues":{},' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Same","label":"Same Label","active":true,"validFor":[]},' +
                        '{"value":"same","label":"Lowercase Same","active":true,"validFor":[]},' +
                        '{"value":"SAME","label":"Uppercase Same","active":true,"validFor":[]}' +
                    ']' +
                '},' +
                '"Core_MDF_Activity_Category__c":{' +
                    '"controllerValues":{"Same":0,"same":1,"SAME":2},' +
                    '"controllingFields":["Core_MDF_Controlling_Field_nm__c"],' +
                    '"defaultValue":null,' +
                    '"values":[' +
                        '{"value":"Dup1","label":"Duplicate 1","active":true,"validFor":[0,1,2]},' +
                        '{"value":"Dup2","label":"Duplicate 2","active":true,"validFor":[0]}' +
                    ']' +
                '}' +
            '}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
}