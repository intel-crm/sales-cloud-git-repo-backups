/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateDesignRegistration_Test
Version             : 
Created Date        : May 2023
Function            : Test class for PCC_CreateDesignRegistration
************************************************************************************************************************************************/

@isTest
public class PCC_CreateDesignRegistration_Test {
    @testSetup
    static void testSetUp(){
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Client Computing';
		ddrRec.Core_Product_Application_Nm__c='Business Desktop';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+20;
        ddrRec.Core_Production_End_Dt__c = system.today()+20;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_External_Id__c='Oph890lip';
        insert ddrRec;
    }
	@isTest 
    static void testGetDDRPicklistValues() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registrations/picklist/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('name', 'PAN');
        req.addParameter('parent', null); // Leave this blank to test getting all picklist values
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_GetDDRMasterData_V1.getDDRMasterData();
        Test.stopTest();
    }
    
    @isTest 
    static void testGetDDRPicklistValues1() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registrations/picklist/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('name', null);
        req.addParameter('parent', null); // Leave this blank to test getting all picklist values
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_GetDDRMasterData_V1.getDDRMasterData();
        Test.stopTest();
    }
    
    @isTest 
    static void testGetDDRPicklistValues2() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registrations/picklist/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('name', '');
        req.addParameter('parent', ''); // Leave this blank to test getting all picklist values
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_GetDDRMasterData_V1.getDDRMasterData();
        Test.stopTest();
    }
    

	@isTest 
    static void testGetDDRPicklistValues3() {
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registrations/picklist/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('name', 'PAN');
        req.addParameter('parent', 'Client Computing'); // Leave this blank to test getting all picklist values
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_GetDDRMasterData_V1.getDDRMasterData();
        Test.stopTest();
    }
    
    @isTest 
    static void testGetDDRPicklistValues4() {
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registrations/picklist/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('name', 'VMN');
        req.addParameter('parent', 'Client Computing'); // Leave this blank to test getting all picklist values
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_GetDDRMasterData_V1.getDDRMasterData();
        Test.stopTest();
    }
    
    @isTest 
    static void testGetDDRPicklistValues5() {
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registrations/picklist/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('name', null);
        req.addParameter('parent', 'Client Computing'); // Leave this blank to test getting all picklist values
        
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        PCC_GetDDRMasterData_V1.getDDRMasterData();
        Test.stopTest();
    }
    
     @isTest 
    static void testGetDDRPicklistValues6() {
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registrations/picklist/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('name', 'PAN');
        req.addParameter('parent', 'Client Data'); // Leave this blank to test getting all picklist values
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_GetDDRMasterData_V1.getDDRMasterData();
        Test.stopTest();
    }
    
     @isTest 
    static void testGetDDRPicklistValues7() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registrations/picklist/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('name', '1000');
        req.addParameter('parent', 'Client Computing'); // Leave this blank to test getting all picklist values
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        try{
            PCC_GetDDRMasterData_V1.getDDRMasterData();
        }catch(exception ex){
            System.debug('exception-->'+ex);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void testGetDDRPicklistValues8() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registrations/picklist/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('name', 'ALL');
        req.addParameter('parent', null); // Leave this blank to test getting all picklist values
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        try{
            PCC_GetDDRMasterData_V1.getDDRMasterData();
        }catch(exception ex){
            System.debug('exception-->'+ex);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void testGetDDRPicklistValues9() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registrations/picklist/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('fn', 'ALL');
        req.addParameter('parent', null); // Leave this blank to test getting all picklist values
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        try{
            PCC_GetDDRMasterData_V1.getDDRMasterData();
        }catch(exception ex){
            System.debug('exception-->'+ex);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void testGetDDRPicklistValues10() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registrations/picklist/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET'; // Leave this blank to test getting all picklist values
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        try{
            PCC_GetDDRMasterData_V1.getDDRMasterData();
        }catch(exception ex){
            System.debug('exception-->'+ex);
        }
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2023-06-24","firstCustomerShipDate":"2023-07-24","productionEndDate":"2023-07-24","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow8","description":createDesignRegRecTests","externalId":"MAPW0"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();

      //  System.assertEquals(200, res.statusCode, 'Expected status code 200');

      //  System.assertEquals('Successfully submitted all the records!!', res.responseBody.toString(), 'Unexpected response body');
    }
    
    @isTest
    static void createDesignRegRecTest1(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2023-06-24","firstCustomerShipDate":"2023-07-24","productionEndDate":"2023-07-24","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow7","description":"createDesignRegRecTest2","externalId":"MAPWdiwhfelkfowhfeoiwhcueoqiwfheoiffohqwoifuegwfuihnqwgwqfyfguqwgfqcwgiydbwq0yd9ywfq1"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();

     //   System.assertEquals(400, res.statusCode, 'Expected status code 400');
        
      /*  PCC_CreateDesignRegistrationUtility_V1.SalesforceError[] expectedErrors = new PCC_CreateDesignRegistrationUtility_V1.SalesforceError[]{new PCC_CreateDesignRegistrationUtility_V1.SalesforceError('BAD_REQUEST', 'Invalid Vertical Market')};
        System.assertEquals(JSON.serialize(expectedErrors), res.responseBody.toString(), 'Unexpected response body');*/
    }

    
    @isTest
    static void createDesignRegRecTest3(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2023-06-24","firstCustomerShipDate":"2023-07-24","productionEndDate":"2023-07-24","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow6","description":"createDesignRegRecTest3","externalId":"MAPW3"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        // PCC_CreateDesignRegistration_V1 registration = new PCC_CreateDesignRegistration_V1();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();

      //  System.assertEquals(400, res.statusCode, 'Expected status code 400');
        
      /*  PCC_CreateDesignRegistrationUtility_V1.SalesforceError[] expectedErrors = new PCC_CreateDesignRegistrationUtility_V1.SalesforceError[]{new PCC_CreateDesignRegistrationUtility_V1.SalesforceError('BAD_REQUEST', 'Invalid Vertical Market')};
        System.assertEquals(JSON.serialize(expectedErrors), res.responseBody.toString(), 'Unexpected response body');*/
    }
    
    @isTest
    static void createDesignRegRecTest4(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2023-06-24","firstCustomerShipDate":"2023-07-24","productionEndDate":"2023-07-24","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow5","description":"createDesignRegRecTest4","externalId":"Mapfwp001"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();

       // System.assertEquals(400, res.statusCode, 'Expected status code 400');
        
      /*  PCC_CreateDesignRegistrationUtility_V1.SalesforceError[] expectedErrors = new PCC_CreateDesignRegistrationUtility_V1.SalesforceError[]{new PCC_CreateDesignRegistrationUtility_V1.SalesforceError('BAD_REQUEST', 'Invalid Vertical Market')};
        System.assertEquals(JSON.serialize(expectedErrors), res.responseBody.toString(), 'Unexpected response body');*/
    }
    
    @isTest
    static void createDesignRegRecTest5(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2023-06-24","firstCustomerShipDate":"2023-07-24","productionEndDate":"2023-07-24","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow4","description":"createDesignRegRecTest5","externalId":"Mapfwp0021"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest51(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2023-06-24","firstCustomerShipDate":"2023-07-24","productionEndDate":"2023-07-24","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow4","description":"createDesignRegRecTest5","externalId":"Mapfwp0021"},{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2023-06-24","firstCustomerShipDate":"2023-07-24","productionEndDate":"2023-07-24","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow4","description":"createDesignRegRecTest5","externalId":"Mapfwp0021"}]');

        RestContext.request = req;
        RestContext.response = res;

       /* Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        PCC_CreateDesignRegistrationUtility_V1.createDDRRecords('Design Registration');
        Test.stopTest();*/
        
        /*RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2023-06-24","firstCustomerShipDate":"2023-07-24","productionEndDate":"2023-07-24","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow4","description":"createDesignRegRecTest5","externalId":"Mapfwp0021"}]');

        RestContext.request = req1;
        RestContext.response = res1;*/

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
        @isTest
    static void createDesignRegRecTest6(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2023-06-24","firstCustomerShipDate":"2023-07-24","productionEndDate":"2023-07-24","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow3","description":"createDesignRegRecTest6","externalId":"MAPW830"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
            @isTest
    static void createDesignRegRecTest7(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMaret":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99iofewybf oibewhciwgaupob fwc ohvwqiygwqoibf fouwfo tw7iagfui auig ufqtw7gf iuwiqgw qqgw7tgwq gfawgfiqw7 gwuqigf 9wqtgufowgqifqgwqw ifgwiqgf wqogfiqwfiwagifgwiu7fwigfuwgiwgfic aohoq vewiugewvowifwoqgfqowfwiqbcwqhiq qooqaohfpqgfwqopwgeohfhqw oqogf oqwfuigwquigfiuwgfuwegfowgfo owfgouw qgfo fo","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2023-06-24","firstCustomerShipDate":"2023-07-24","productionEndDate":"2023-07-24","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow2","description":"createDesignRegRecTest7","externalId":"MAPfsW0"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        PCC_CreateDesignRegistrationUtility_V1.createDDRRecords('Design Registration');
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest8(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2023-06-24","firstCustomerShipDate":"2023-07-24","productionEndDate":"2023-07-24","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow1","description":"createDesignRegRecTest8","externalId":"MAPWcs0"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest9(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Educationdw","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2025-06-24","firstCustomerShipDate":"2025-07-24","productionEndDate":"2025-07-24","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest10(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"06-24-2025","firstCustomerShipDate":"2025-07-24","productionEndDate":"2025-07-24","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest11(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2025-06-24","firstCustomerShipDate":"06-24-2025","productionEndDate":"2025-07-24","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest12(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2025-06-24","firstCustomerShipDate":"06-24-2025","productionEndDate":"07-23-2025","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest13(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2022-06-24","firstCustomerShipDate":"2025-06-25","productionEndDate":"07-23-2025","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    @isTest
    static void createDesignRegRecTest14(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2025-06-24","firstCustomerShipDate":"2022-06-25","productionEndDate":"2025-07-23","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    @isTest
    static void createDesignRegRecTest15(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2025-06-24","firstCustomerShipDate":"2025-06-24","productionEndDate":"2022-06-24","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest16(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2025-06-24","firstCustomerShipDate":"2025-06-24","productionEndDate":"2025-06-24","intelPlatform":"Agilex","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
     @isTest
    static void createDesignRegRecTest17(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Desktop","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2025-06-24","firstCustomerShipDate":"06-24-2025","productionEndDate":"07-23-2025","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void getDDRRecTest2(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('id', '002HGIKolokTEST');
            
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDesignRegistration_V1.getDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void getDDRRecTest3(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('UniqueId', 'FSI002DDR');
            
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDesignRegistration_V1.getDDRRecords();
        Test.stopTest();
    }
    
     @isTest
    static void getDDRRecTest4(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
            
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDesignRegistration_V1.getDDRRecords();
        Test.stopTest();
    }
    
     @isTest
    static void getDDRRecTest1(){
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Client Computing';
		ddrRec.Core_Product_Application_Nm__c='Business Desktop';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+20;
        ddrRec.Core_Production_End_Dt__c = system.today()+20;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        insert ddrRec;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('id', ddrRec.id);
            
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDesignRegistration_V1.getDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void updateDesignRegRecTest4(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Client Computing';
		ddrRec.Core_Product_Application_Nm__c='Business Desktop';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+20;
        ddrRec.Core_Production_End_Dt__c = system.today()+20;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_External_Id__c='Oph890li';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Connected Home","productApplication":"Business Desktop","recOrExtId":"Oph890lip"},{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Deskop","recOrExtId":"Oph890lip"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    
     @isTest
    static void updateDesignRegRecTest5(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Client Computing';
		ddrRec.Core_Product_Application_Nm__c='Business Desktop';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+20;
        ddrRec.Core_Production_End_Dt__c = system.today()+20;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_External_Id__c='Oph890li';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Deskop"}]');
                                       
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    
     @isTest
    static void updateDesignRegRecTest6(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Client Computing';
		ddrRec.Core_Product_Application_Nm__c='Business Desktop';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+20;
        ddrRec.Core_Production_End_Dt__c = system.today()+20;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_External_Id__c='Oph890li';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"YesNo","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Deskop"}]');
                                       
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    
     @isTest
    static void updateDesignRegRecTest7(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Client Computing';
		ddrRec.Core_Product_Application_Nm__c='Business Desktop';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+20;
        ddrRec.Core_Production_End_Dt__c = system.today()+20;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_External_Id__c='Oph890li';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT","militaryAerospaceGvrnmtUseInd":"YesNo","verticalMarket":"Education","productSegment":"Client Computing","productApplication":"Business Deskop"');
                                       
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    
     @isTest
    static void testWrapper(){
        PCC_Wrapper.PCC_ReqiredDRFieldsCheckWrapper prf = new PCC_Wrapper.PCC_ReqiredDRFieldsCheckWrapper();
        prf.mapFieldsToDrRec = null;
        prf.listDrRecsWithExtId = null;
        prf.mapExtIdToDRRec = null;
        
        
    }
   
}