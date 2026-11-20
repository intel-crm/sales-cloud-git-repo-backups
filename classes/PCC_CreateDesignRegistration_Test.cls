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
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
         Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        User accOwner= [select id from User where UserRole.Name='Admin' limit 1];

        Account a2 = PRM_TestUtility.getAccount();
        a2.RecordTypeId = accountRecordTypeIntel;
        a2.Name='New Account';
        a2.Core_Account_Type__c ='Distributor';
        a2.Industry='Agriculture';
        a2.BillingCity='Goa';
        a2.BillingCountryCode='IND';
        a2.BillingStreet='4th Floor,New Road';
        a2.BillingPostalCode='110065';
        a2.BillingStateCode='KA';
        a2.Core_IPA_Partner_Role__c = 'Service Provider';
        a2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        a2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        a2.OwnerId=accOwner.id;
       // a2.Account_Record_Type__c='Intel Account';
        insert a2;
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = a2.Id;
        c1.Email='test.user@intel.com';
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_IPA_Partner_Role__c = 'Service Provider';
        c1.Email = 'test.diqhwqi@test.com';
        c1.MailingCountry= 'USA';
        insert c1;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        
        Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='Employee';
        ed1.Core_Display_Name__c='Employee';
        ed1.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed1;
        
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce.Core_Contact_Id__c=c1.Id;
        cce.Core_Entitlement_Id__c = ed1.id;
        cce.Core_Status__c='Complete';
        cce.Core_Selected__c = true;
        cce.Core_Source__c = 'Entitlement';
        insert cce;
        
        Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
        
        User partnerUser = new User(FirstName='MrTest',LastName='User',alias='t2user',Email='test.diqhwqi@test.com',IsActive = true,
                                    UserName='test2udwvgsr@xyz.com', ContactId=c1.Id,ProfileId=communityUsrProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London'/*, UserRoleId = r.id*/);
        
        insert partnerUser;
        
        Core_Design_Registration__c ddrRec1 = new  Core_Design_Registration__c();
        ddrRec1.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec1.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec1.Core_Vertical_Market_Nm__c='Education';
		ddrRec1.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec1.Core_Product_Application_Nm__c='Radar';
		ddrRec1.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec1.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec1.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec1.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec1.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec1.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec1.Core_End_Customer_Country_Nm__c='India';
        ddrRec1.PCC_End_Customer_Country__c='India';
		ddrRec1.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec1.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec1.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec1.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec1.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec1.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec1.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec1.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec1.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec1.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec1.Core_Production_End_Dt__c = system.today()+22;
        ddrRec1.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec1.Core_Design_Registration_Nm__c='Test DR Name Arrow9';
        ddrRec1.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec1.Core_External_Id__c='abcd001';
        ddrRec1.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        ddrRec1.Core_End_Customer_URL__c = 'Test';
        insert ddrRec1;        
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
         ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_External_Id__c='abcd002';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec;
        
        Core_Design_Registration__c ddrRec3 = new  Core_Design_Registration__c();
        ddrRec3.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec3.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec3.Core_Vertical_Market_Nm__c='Education';
		ddrRec3.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec3.Core_Product_Application_Nm__c='Radar';
		ddrRec3.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec3.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec3.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec3.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec3.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec3.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec3.Core_End_Customer_Country_Nm__c='India';
        ddrRec3.PCC_End_Customer_Country__c='India';
		ddrRec3.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec3.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec3.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec3.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec3.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec3.Core_End_Customer_Contact_Email_Txt__c='test.diqhwqi@test.com';
        ddrRec3.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec3.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec3.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec3.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec3.Core_Production_End_Dt__c = system.today()+22;
        ddrRec3.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec3.Core_Design_Registration_Nm__c='Test DR Name Arrow get4';
        ddrRec3.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec3.Core_External_Id__c='abcd003';
        ddrRec3.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        ddrRec3.Core_End_Customer_URL__c = 'Test';
        insert ddrRec3;
        
        Core_Design_Registration__c ddrRec4 = new  Core_Design_Registration__c();
        ddrRec4.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec4.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec4.Core_Vertical_Market_Nm__c='Education';
		ddrRec4.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec4.Core_Product_Application_Nm__c='Radar';
		ddrRec4.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec4.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec4.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec4.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec4.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec4.Core_End_Customer_Street_Addr_Line2_Txt__c='street11';
		ddrRec4.Core_End_Customer_Country_Nm__c='India';
        ddrRec4.PCC_End_Customer_Country__c='India';
		ddrRec4.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec4.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec4.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec4.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec4.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec4.Core_End_Customer_Contact_Email_Txt__c='test.diqhwqi@test.com';
        ddrRec4.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec4.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec4.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec4.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec4.Core_Production_End_Dt__c = system.today()+22;
        ddrRec4.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec4.Core_Design_Registration_Nm__c='Test DR Name Arrow update1';
        ddrRec4.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec4.Core_End_Customer_URL__c = 'Test';
		ddrRec4.Core_End_Customer_Contact_Email_Txt__c = 'Testelec.partneruser01@marketstar.com';
        ddrRec4.Core_External_Id__c='EXT09p90li';
        insert ddrRec4;

        List<Core_CustomMetadata_Object__c> cmos = new List<Core_CustomMetadata_Object__c>();
        Core_CustomMetadata_Object__c cmo1 = new Core_CustomMetadata_Object__c();
        cmo1.MasterLabel__c = 'MasterLabel';
        cmo1.DeveloperName__c = 'DeveloperName';
        cmo1.Field_1__c = 'PCC_Picklist_API_Name__c';
        cmo1.Field_2__c = 'PCC_Rfr_Picklist_Name__c';
        cmo1.Metadata_Name__c = 'PCC_DDR_Integration_MasterData__mdt';
        insert cmo1;

        Core_CustomMetadata_Object__c cmo2 = new Core_CustomMetadata_Object__c();
        cmo2.Header_row__c = cmo1.Id;
        cmo2.MasterLabel__c = 'Product Application';
        cmo2.DeveloperName__c = 'PAN';
        cmo2.Field_1__c = 'Core_Product_Application_Nm__c';
        cmo2.Field_2__c = 'PAN';
        cmo2.Metadata_Name__c = 'PCC_DDR_Integration_MasterData__mdt';
        cmos.add(cmo2);

        Core_CustomMetadata_Object__c cmo3 = new Core_CustomMetadata_Object__c();
        cmo3.Header_row__c = cmo1.Id;
        cmo3.MasterLabel__c = 'Vertical Market';
        cmo3.DeveloperName__c = 'VMN';
        cmo3.Field_1__c = 'Core_Vertical_Market_Nm__c';
        cmo3.Field_2__c = 'VMN';
        cmo3.Metadata_Name__c = 'PCC_DDR_Integration_MasterData__mdt';
        cmos.add(cmo3);
        insert cmos;
    }
    
       @isTest
    static void createDesignRegRecTest101(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"designRegistrationName":"Test requiredDW fieldwfefw", "productGroup":"FPGA/Power", "militaryAerospaceGvrnmtUseInd":"Yes", "verticalMarket":"Education", "productSegment":"Embedded / IOT", "productApplication":"BusinessDesktop", "opportunityVolume":"100", "partnerFAE":"Test FAE", "partnerFSR":"Test FSR", "endCustomerName":"Test ddr devint", "endCustomerAddress1":"12 Street 99", "endCustomerAddress2":"", "endCustomerCountry":"India", "endCustomerCity":"Bangalore", "endCustomerState":"Karnataka", "endCustomerPostalCode":"758854", "endCustomerContactTitle":"Mr.", "endCustomerContactName":"Test Electronics Partner User 01", "endCustomerContactEmail":"Testelec.partneruser01@marketstar.com", "endCustomerContactPhone":"7826499722", "manufacturingRegion":"ASMO", "designDecisionDate":"2025-07-05", "firstCustomerShipDate":"2025-07-24", "productionEndDate":"2025-08-24", "intelPlatform":"Agilex", "partnerFAEEmail":"test.diqhwqi@test.com", "externalId":"PKDWJDQ16321" }]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
        
    }
    
     @isTest
    static void createDesignRegRecTest1011(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"description":"TestDesp11","productGroup":"FPGA/Power", "militaryAerospaceGvrnmtUseInd":"Yes", "verticalMarket":"Education", "productSegment":"Embedded / IOT", "productApplication":"BusinessDesktop", "opportunityVolume":"100", "partnerFAE":"Test FAE", "partnerFSR":"Test FSR", "endCustomerName":"Test ddr devint", "endCustomerAddress1":"12 Street 99", "endCustomerAddress2":"", "endCustomerCountry":"India", "endCustomerCity":"Bangalore", "endCustomerState":"Karnataka", "endCustomerPostalCode":"758854", "endCustomerContactTitle":"Mr.", "endCustomerContactName":"Test Electronics Partner User 01", "endCustomerContactEmail":"Testelec.partneruser01@marketstar.com", "endCustomerContactPhone":"7826499722", "manufacturingRegion":"ASMO", "designDecisionDate":"2025-07-05", "firstCustomerShipDate":"2025-07-24", "productionEndDate":"2025-08-24", "intelPlatform":"Agilex", "partnerFAEEmail":"test.diqhwqi@test.com", "externalId":"PKDWdaJDQ16321","designRegistrationName":"TestName11" }]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
        
    }
     @isTest
    static void createDesignRegRecTest201(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"designRegistrationName":"Test requiredDW fieldwfefw", "verticalMarket":"Education", "productSegment":"Embedded / IOT", "productApplication":"Radar", "opportunityVolume":"100", "partnerFAE":"Test FAE", "partnerFSR":"Test FSR", "endCustomerName":"Test ddr devint", "endCustomerAddress1":"12 Street 99", "endCustomerAddress2":"", "endCustomerCountry":"India", "endCustomerCity":"Bangalore", "endCustomerState":"Karnataka", "endCustomerPostalCode":"758854", "endCustomerContactTitle":"Mr.", "endCustomerContactName":"Test Electronics Partner User 01", "endCustomerContactEmail":"Testelec.partneruser01@marketstar.com", "endCustomerContactPhone":"7826499722", "manufacturingRegion":"ASMO", "designDecisionDate":"2099-07-05", "firstCustomerShipDate":"2099-07-06", "productionEndDate":"2099-07-07", "intelPlatform":"Agilex", "partnerFAEEmail":"test.diqhwqi@test.com", "externalId":"PKDWJDQ1632da1","endCustomerUrl":"Test.com" }]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
        
    }
	@isTest 
    static void testGetDDRPicklistValues() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registrations/picklist/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('name', 'PAN');
        req.addParameter('parent', null); // Leave this blank to test getting all picklist values
        Assert.isNotNull(req);
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
        Assert.isNotNull(req);
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
        Assert.isNotNull(req);
        
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
        req.addParameter('parent', 'Embedded / IOT'); // Leave this blank to test getting all picklist values
        Assert.isNotNull(req);
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
        req.addParameter('parent', 'Embedded / IOT'); // Leave this blank to test getting all picklist values
        Assert.isNotNull(req);
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
        req.addParameter('parent', 'Embedded / IOT'); // Leave this blank to test getting all picklist values
        Assert.isNotNull(req);
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
        Assert.isNotNull(req);
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
        req.addParameter('parent', 'Embedded / IOT'); // Leave this blank to test getting all picklist values
        Assert.isNotNull(req);
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
        Assert.isNotNull(req);
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
        Assert.isNotNull(req);
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
    static void testGetDDRPicklistValuesNOParent() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registrations/picklist/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('name', 'PAN');
        req.addParameter('parent', ''); // Leave this blank to test getting all picklist values
        Assert.isNotNull(req);
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
        Assert.isNotNull(req);
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
      
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow8","description":createDesignRegRecTests","externalId":"MAPW0"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest 
    static void testgetDDRRecord1() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Product2 pr = new Product2();
        pr.Name = 'Test data';
        pr.IsActive = true;
        pr.Core_Design_Registration_Eligible_Ind__c = true;
        pr.Core_Avail_for_New_Designs__c = true;
        pr.Core_Sales_Visible_Flag__c = true;
        insert pr;
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.PCC_End_Customer_Country__c='India';
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
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec;        
        
        Core_Design_Registration_Product__c drProduct = new Core_Design_Registration_Product__c();
        drProduct.Core_Product_Id__c = pr.Id;
		drProduct.Core_Design_Registration_Id__c = ddrRec.Id;
		drProduct.Core_Full_Year_Qty__c= 1000;
		drProduct.Core_Retired_As_Of_Dt__c= Date.today();
		drProduct.Core_External_Id__c= '002uswLKJMgsi3HJK';
        drProduct.Core_Submission_Type__c = 'M2M';
		insert drProduct;
        
        Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
        pmam1.Ordering_Code__c = 'WX80550E52630V4';
        pmam1.Name = '949348';
        pmam1.L5_Product__c = pr.Id;
        insert pmam1;
        
 		PCC_DDR_L5_Product_Mapping__c dlpm = new PCC_DDR_L5_Product_Mapping__c();
        dlpm.PCC_Design_Registration__c = ddrRec.id;
        dlpm.PCC_Design_Registration_Product__c = drProduct.id;
        dlpm.PCC_Product_MM_Attribute_Mapping__c = pmam1.id;
        dlpm.PCC_MM_ID__c = pmam1.Name;
        dlpm.PCC_Ordering_Cd__c = pmam1.Ordering_Code__c;
        insert dlpm;
        
        req.requestUri = '/services/apexrest/v1.0/design-registration/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('id', ddrRec.Id);
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDesignRegistrationUtility_V1.getDDRRecordDetails();
        Test.stopTest();
    }
    @isTest 
    static void testgetDDRRecord2() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Product2 pr = new Product2();
        pr.Name = 'Test data';
        pr.IsActive = true;
        pr.Core_Design_Registration_Eligible_Ind__c = true;
        pr.Core_Avail_for_New_Designs__c = true;
        pr.Core_Sales_Visible_Flag__c = true;
        insert pr;
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec;        
        
        Core_Design_Registration_Product__c drProduct = new Core_Design_Registration_Product__c();
        drProduct.Core_Product_Id__c = pr.Id;
		drProduct.Core_Design_Registration_Id__c = ddrRec.Id;
		drProduct.Core_Full_Year_Qty__c= 1000;
		drProduct.Core_Retired_As_Of_Dt__c= Date.today();
		drProduct.Core_External_Id__c= '002uswLKJMgsi3HJK';
        drProduct.Core_Submission_Type__c = 'M2M';
		insert drProduct;
        
        Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
        pmam1.Ordering_Code__c = 'WX80550E52630V4';
        pmam1.Name = '949348';
        pmam1.L5_Product__c = pr.Id;
        insert pmam1;
        
 		PCC_DDR_L5_Product_Mapping__c dlpm = new PCC_DDR_L5_Product_Mapping__c();
        dlpm.PCC_Design_Registration__c = ddrRec.id;
        dlpm.PCC_Design_Registration_Product__c = drProduct.id;
        dlpm.PCC_Product_MM_Attribute_Mapping__c = pmam1.id;
        dlpm.PCC_MM_ID__c = pmam1.Name;
        dlpm.PCC_Ordering_Cd__c = pmam1.Ordering_Code__c;
        insert dlpm;
        
        req.requestUri = '/services/apexrest/v1.0/design-registration/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('id', ddrRec.Id);
        req.addParameter('type','DR');
        Assert.isNotNull(req);
        RestContext.request = req; 
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDesignRegistrationUtility_V1.getDDRRecordDetails();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest1(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow7","description":"createDesignRegRecTest2","externalId":"MAPWdiwhfelkfowhfeoiwhcueoqiwfheoiffohqwoifuegwfuihnqwgwqfyfguqwgfqcwgiydbwq0yd9ywfq1"}]');
         Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();

    }
    
    

    
    @isTest
    static void createDesignRegRecTest3(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","description":"createDesignRegRecTest3","externalId":"MAPW3"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecMoreThan25(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
		req.requestBody = Blob.valueOf('[{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"},{"productGroup":"Embedded/IOT"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest4(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow5","description":"createDesignRegRecTest4","externalId":"Mapfwp001"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest5(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"test.diqhwqi@test.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arro09994","description":"createDesignRegRecTest5","partnerFAEEmail":"test.diqhwqi@test.com","externalId":"abcd001"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    @isTest
    static void createDesignRegRecTestSameExtId(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"test.diqhwqi@test.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2053-06-24","firstCustomerShipDate":"2025-07-24","productionEndDate":"2025-07-24","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arro09994","description":"createDesignRegRecTest5","partnerFAEEmail":"test.diqhwqi@test.com","externalId":"abcd001"},[{"militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"test.diqhwqi@test.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arro09994","description":"createDesignRegRecTest5","partnerFAEEmail":"test.diqhwqi@test.com","externalId":"abcd001"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest55(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"test.diqhwqi@test.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arro09994","description":"createDesignRegRecTest5","partnerFAEEmail":"test.diqhwqi@test.com","externalId":"abcd001"},[{"militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"test.diqhwqi@test.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arro09994","description":"createDesignRegRecTest5","partnerFAEEmail":"test.diqhwqi@test.com","externalId":"abcd001"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    @isTest
    static void createDesignRegRecTest51(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2093-07-24","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow4","description":"createDesignRegRecTest5","externalId":"Mapfwp0021"},{"militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow4","description":"createDesignRegRecTest5","externalId":"Mapfwp0021"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    @isTest
    static void createDesignRegRecTest6(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow3","description":"createDesignRegRecTest6","externalId":"MAPW830"}]');
       Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest7(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMaret":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99iofewybf oibewhciwgaupob fwc ohvwqiygwqoibf fouwfo tw7iagfui auig ufqtw7gf iuwiqgw qqgw7tgwq gfawgfiqw7 gwuqigf 9wqtgufowgqifqgwqw ifgwiqgf wqogfiqwfiwagifgwiu7fwigfuwgiwgfic aohoq vewiugewvowifwoqgfqowfwiqbcwqhiq qooqaohfpqgfwqopwgeohfhqw oqogf oqwfuigwquigfiuwgfuwegfowgfo owfgouw qgfo fo","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow2","description":"createDesignRegRecTest7","externalId":"MAPfsW0"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        PCC_CreateDesignRegistrationUtility_V1.createDDRRecords('Design Registration');
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest8(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"Test DR Name Arrow1","description":"createDesignRegRecTest8","externalId":"MAPWcs0"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest9(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Educationdw","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest10(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"createdbyy":"hjj"},{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","partnerFAEEmail":"testr.io@mail.com","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest11(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest12(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDesignRegRecTest13(){

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","designRegistrationName":"TestName","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","externalId":"MAPWcc120"}]');
         Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    @isTest
    static void createDesignRegRecTest14(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    //past productionEndDate
    @isTest
    static void createDesignRegRecTest15(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    //past date
    @isTest
    static void createDesignRegRecTest16(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    //past date
    @isTest
    static void createDesignRegRecTest161(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2009-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    
    //past date
    @isTest
    static void createDesignRegRecTest162(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-23","intelPlatform":"Agilex","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    //invalid date
     @isTest
    static void createDesignRegRecTest17(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2099-06-24","firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","intelPlatform":"Agilex","designRegistrationName":abcd112"","description":"createDesignRegRecTest9","externalId":"MAPWcc0"}');
         Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.createDDRRecords();
        Test.stopTest();
    }
    //Checking past product date validation
    @isTest
    static void createDesignRegRecTest18(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","designDecisionDate":"2019-06-24","productionEndDate":"2019-06-26",firstCustomerShipDate":"2019-06-25","intelPlatform":"Agilex","designRegistrationName":"Test DR Name","description":"createDesignRegRecTest17","externalId":"MAPW83990"}]');
        Assert.isNotNull(req);
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
        req.addParameter('id','MAPWcc0');
         Assert.isNotNull(req);   
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDesignRegistration_V1.getDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void getDDRRecTest3(){

        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        //ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser02@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow get3';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec;        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('id',ddrRec.id);
          Assert.isNotNull(req);  
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDesignRegistration_V1.getDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void getDDRRecTestNoId(){

        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        //ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser02@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow get3';
       ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec;        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('id','');
            Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDesignRegistration_V1.getDDRRecords();
        Test.stopTest();
    }
    
     @isTest
    static void getDDRRecTestInvalidId(){

        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        //ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser02@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow get3';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';        
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec;        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('uniqueiD','fcwpoohfpowpPP');
            Assert.isNotNull(req);
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
            Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDesignRegistration_V1.getDDRRecords();
        Test.stopTest();
    }
    
     @isTest
    static void getDDRRecTest1(){

        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow get1';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';        
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('id', ddrRec.id);
            Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDesignRegistration_V1.getDDRRecords();
        Test.stopTest();
    }

    @isTest
    static void updateDesignRegRecTest1(){

        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow3';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_External_Id__c='Oph890lik';        
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","intelPlatform":"Agilex","designRegistrationName":happyflow1"","description":"createDesignRegRecTest9","recordId":"' + ddrRec.id + '}]');
             Assert.isNotNull(req);                          
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistrationUtility_V1.createDDRRecords('Update Design Registration');
        Test.stopTest();
    }  
    
    //wrong productapplication value
    @isTest
    static void updateDesignRegRecTest4(){

        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
       // ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow getml4';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_External_Id__c='Oph000li';        
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec;
        
        id recId=ddrRec.id;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Connected Home","productApplication":"Business Dektop","partnerFAEEmail":"test.diqhwqi@test.com","recordId":"' + recId + '"}]');
                                      
		Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistrationUtility_V1.createDDRRecords('Update Design Registration');
        Test.stopTest();
    }
    //ps and pd not null, wrog name in pd
    @isTest
    static void updateDesignRegRecTest2(){

        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Naklp0';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_External_Id__c='Opaoppppbcf0li';        
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec;
        
        id recId=ddrRec.id;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Business Dsektop","recordId":"' + recId+'"}]');
        Assert.isNotNull(req);                               
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistrationUtility_V1.createDDRRecords('Update Design Registration');
        Test.stopTest();
    }
    //ps and pd not null wrong value in ps
    @isTest
    static void updateDesignRegRecTest02(){

        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow getoop4';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_External_Id__c='Oph89jkl0li';        
        ddrRec.Core_End_Customer_URL__c = 'Test';
        ddrRec.Core_Design_Registration_Status_Nm__c = 'Draft';
        insert ddrRec;
        
        id recId=ddrRec.id;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"status":"Submitted","endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"ient Computing","productApplication":"Business Dsektop","recordId":"' + recId+'"}]');
      Assert.isNotNull(req);                             
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistrationUtility_V1.createDDRRecords('Update Design Registration');
        Test.stopTest();
    }
    //ps not null 
    @isTest
    static void updateDesignRegRecTest012(){

        List<Core_Design_Registration__c> validDRList = [SELECT Id,Core_Product_Group_Nm__c,Core_Military_Aerospace_Gvrnmt_Use_Ind__c,Core_Vertical_Market_Nm__c,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c,Core_External_Id__c,Core_Partner_FAE_Nm__c, Core_Partner_FSR_Nm__c,
                               Core_End_Customer_Nm__c,Core_End_Customer_Street_Addr_Line1_Txt__c,Core_End_Customer_Street_Addr_Line2_Txt__c,Core_End_Customer_Country_Nm__c,Core_End_Customer_Country_Subdivision_Nm__c,Core_End_Customer_Postal_Cd__c,
                               Core_End_Customer_City_Nm__c,Core_End_Customer_Contact_Title_Txt__c,Core_End_Customer_Contact_Phone_Txt__c,Core_End_Customer_Contact_Nm__c,Core_End_Customer_Contact_Email_Txt__c,Core_Manufacturing_Region_Cd__c,DDR_Partner_FAE_Email__c,
                               Core_Opportunity_Decision_Dt__c,Core_First_Customer_Ship_Dt__c,Core_Production_End_Dt__c,Core_Intel_Platform_Nm__c
                               FROM Core_Design_Registration__c limit 10];
        id recId=validDRList[0].id;
        id recId1=validDRList[1].id;
        id recId2=validDRList[2].id;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"status":"Submitted","endCustomerUrl":"Test.com","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"t Computing","recordId":"' + recId+'"},{"militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","recordId":"' + recId1+'"},{"verticalMarket":"Education","productApplication":"Business Mobility","recordId":"' + recId2+'"}]');
        Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistrationUtility_V1.createDDRRecords('Update Design Registration');
        Test.stopTest();
    }
    
     @isTest
    static void updateDesignRegRecTest5(){
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
ddrRec.PCC_End_Customer_Country__c='India';
        ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow3';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_External_Id__c='Oph890jkloppplik';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":" Computing","recordId":"' + ddrRec.id + '}]');
             Assert.isNotNull(req);                          
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistrationUtility_V1.createDDRRecords('Update Design Registration');
        Test.stopTest();
    }
    
     @isTest
    static void updateDesignRegRecTest6(){
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow8';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_External_Id__c='Oph89877790lij';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","partnerFAEEmail":"test.diqhwqi@test.com","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","":"2099-06-25","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","recordId":"' + ddrRec.id + '}]');

            Assert.isNotNull(req);                           
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistrationUtility_V1.createDDRRecords('Update Design Registration');
        Test.stopTest();
    }
    
     @isTest
    static void updateDesignRegRecTest7(){
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow update1900';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        //ddrRec.Core_External_Id__c='Oph890li';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAEEmail":"test.diqhwqi@test.com","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Arrow Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Arrow Electronics Partner User 01","endCustomerContactEmail":"arrowelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","intelPlatform":"Agilex","designRegistrationName":"","description":"createDesignRegRecTest9","recordId":"' + ddrRec.id +'"}]');
         Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    @isTest
    static void updateDesignRegRecTest10(){
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow update1';
       ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        //ddrRec.Core_External_Id__c='Oph8klop90li';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"designRegistrationName":"FSSW","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Test Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Test Electronics Partner User 01","endCustomerContactEmail":"Testelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","intelPlatform":"Agilex","partnerFAEEmail":"test.diqhwqi@test.com","recordId":"' + ddrRec.id +'"}]');
          Assert.isNotNull(req);                             
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void updateDesignRegRecTest101(){
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='street11';
		ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow update1';
       ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'Test';
		ddrRec.Core_End_Customer_Contact_Email_Txt__c = 'Testelec.partneruser01@marketstar.com';
        ddrRec.Core_External_Id__c='Oph8klop90li';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"designRegistrationName":"FSSW","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","productApplication":"Radar","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Test Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Test Electronics Partner User 01","endCustomerContactEmail":"Testelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","intelPlatform":"Agilex","partnerFAEEmail":"test.diqhwqi@test.com","recordId":"' + ddrRec.id +'"}]');
          Assert.isNotNull(req);                             
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void updateDesignRegRecTest102(){
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='street11';
		ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow update1';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'Test';
		ddrRec.Core_End_Customer_Contact_Email_Txt__c = 'Testelec.partneruser01@marketstar.com';
        ddrRec.Core_External_Id__c='Oph8klop90li';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"designRegistrationName":"FSSW","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productApplication":"Radar","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Test Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Test Electronics Partner User 01","endCustomerContactEmail":"Testelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO","intelPlatform":"Agilex","partnerFAEEmail":"test.diqhwqi@test.com","recordId":"' + ddrRec.id +'"}]');
          Assert.isNotNull(req);                             
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    
    @isTest
    static void updateDesignRegRecTest103(){
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='street11';
        ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.PCC_End_Customer_Country__c='India';
        ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow update1';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'Test';
		ddrRec.Core_End_Customer_Contact_Email_Txt__c = 'Testelec.partneruser01@marketstar.com';
        ddrRec.Core_External_Id__c='Oph8klop90li';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"designRegistrationName":"FSSW","militaryAerospaceGvrnmtUseInd":"Yes","verticalMarket":"Education","productSegment":"Embedded / IOT","opportunityVolume":"100","partnerFAE":"Test FAE","partnerFSR":"Test FSR","endCustomerName":"Test Electronics Account","endCustomerAddress1":"12 Street 99","endCustomerAddress2":"","endCustomerCountry":"India","endCustomerCity":"Bangalore","endCustomerState":"Karnataka","endCustomerPostalCode":"758854","endCustomerContactTitle":"Mr.","endCustomerContactName":"Test Electronics Partner User 01","endCustomerContactEmail":"Testelec.partneruser01@marketstar.com","endCustomerContactPhone":"7826499722","manufacturingRegion":"ASMO",intelPlatform":"Agilex","partnerFAEEmail":"test.diqhwqi@test.com","recordId":"' + ddrRec.id +'"}]');
         Assert.isNotNull(req);                              
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    //Testing for update methods to check first customer ship date should not be same as production date
     @isTest
    static void updateDesignRegRecTest105(){

        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='street11';
        ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='Testelec.partneruser01@testwbb.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow date';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'www.url.com';
		ddrRec.DDR_Partner_FAE_Email__c = 'testpcccontact@mail7.com';
        ddrRec.Core_External_Id__c='Oph8klop90';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-25","recordId":"' + ddrRec.id +'"}]');
         Assert.isNotNull(req);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    //Testing for date validation where first customer ship date is valid but product end date is given in payload
    @isTest
    static void updateDesignRegRecTest106(){

        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='street11';
ddrRec.Core_End_Customer_Country_Nm__c='India';	
        ddrRec.PCC_End_Customer_Country__c='India';
        ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='Testelec.partneruser01@testwbb.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today();
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow date';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'www.url.com';
		ddrRec.DDR_Partner_FAE_Email__c = 'testpcccontact@mail7.com';
        ddrRec.Core_External_Id__c='Oph8klop90';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"firstCustomerShipDate":"2099-06-25","productionEndDate":"2099-06-26","recordId":"' + ddrRec.id +'"}]');
        Assert.isNotNull(req);                               
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    //Testing for date validation where product end date is not provided in payload and first customer end date is equal to existing product end date
    @isTest
    static void updateDesignRegRecTest107(){

        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='street11';
ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.PCC_End_Customer_Country__c='India';
        ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='Testelec.partneruser01@testwbb.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today();
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow date';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'www.url.com';
		ddrRec.DDR_Partner_FAE_Email__c = 'testpcccontact@mail7.com';
        ddrRec.Core_External_Id__c='Oph8klop90';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"firstCustomerShipDate":"' + system.today()+22 +'","recordId":"' + ddrRec.id +'"}]');
          Assert.isNotNull(req);                             
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    //Testing date validation first customer end date is valid and production end date is not present in payload
     @isTest
    static void updateDesignRegRecTest108(){

        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='street11';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='Testelec.partneruser01@testwbb.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today();
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+2;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow date';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'www.url.com';
		ddrRec.DDR_Partner_FAE_Email__c = 'testpcccontact@mail7.com';
        ddrRec.Core_External_Id__c='Oph8klop9022';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"firstCustomerShipDate":"'+ system.today()+21 +'","description":"Description","recordId":"' + ddrRec.id +'"}]');
           Assert.isNotNull(req);                            
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    //Testing date validation product end date is after than decision date
     @isTest
    static void updateDesignRegRecTest109(){

        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='street11';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='Testelec.partneruser01@testwbb.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today();
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow date';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'www.url.com';
		ddrRec.DDR_Partner_FAE_Email__c = 'testpcccontact@mail7.com';
        ddrRec.Core_External_Id__c='Oph8klop90';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productionEndDate":"'+system.today()+21+'","description":"Description","recordId":"' + ddrRec.id +'"}]');
          Assert.isNotNull(req);                             
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    //Testing date validation for invalid date format
     @isTest
    static void updateDesignRegRecTest110(){

        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        //ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        //ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser02@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow get3';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"productionEndDate":"2019/12/12","description":"Description","recordId":"' + ddrRec.id +'"},{"firstCustomerShipDate":"2099","description":"Description","recordId":"' + ddrRec.id +'"}]');
              Assert.isNotNull(req);                         
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    
    //Testing for update methods to check decision date should not be editable
     @isTest
    static void updateDesignRegRecTest111(){
 		
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = '';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
        ddrRec.Core_Submission_Type__c='M2M';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Test Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='street11';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='Testelec.partneruser01@testwbb.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today();
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
       
        ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c='Yes';
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow update1';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'www.Test.com';
		ddrRec.DDR_Partner_FAE_Email__c = 'testpcccontact@mail7.com';
        ddrRec.Core_External_Id__c='Oph8klop9';

        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"designDecisionDate": "2099-09-11","recordId":"' + ddrRec.id +'"}]');
           Assert.isNotNull(req);                            
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    
     @isTest
    static void updateDesignRegRecTest1872(){
 		
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = '';
		ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec.Core_Vertical_Market_Nm__c='Education';
        ddrRec.Core_Submission_Type__c='M2M';
		ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
		ddrRec.Core_Product_Application_Nm__c='Radar';
		ddrRec.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec.Core_End_Customer_Nm__c='Test Electronics Account';
		ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='street11';
		ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.PCC_End_Customer_Country__c='India';
		ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='Testelec.partneruser01@testwbb.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today();
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        //ddrRec.Core_End_Customer_Account_Id__c=acc.Id;
        ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c='Yes';
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow update1';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'www.Test.com';
		ddrRec.DDR_Partner_FAE_Email__c = 'testpcccontact@mail7.com';
        ddrRec.Core_External_Id__c='Oph8klop9';
        Assert.isNotNull(ddrRec);
        insert ddrRec;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"verticalMarket": "","recordId":"' + ddrRec.id +'"}]');
        Assert.isNotNull(req);                      
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    

    
      @isTest
    static void checkBlankPayloadScn(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[]');
           Assert.isNotNull(req);                            
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDesignRegistration_V1.updateDDRRecords();
        Test.stopTest();
    }
    
}