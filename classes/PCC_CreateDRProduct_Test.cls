/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateDesignRegistration_Test 
Created Date        : June 2023
Function            : Test class for PCC_CreateDRProduct_Test
************************************************************************************************************************************************/

@isTest
public class PCC_CreateDRProduct_Test {
    
    @isTest 
    static void testgetDDRProductRecord2() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration-product/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('id', '002OJKHHEIIWIaaa');
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDDRProducts_V1.getDDRProductRecord();
        Test.stopTest();
    }
    
    @isTest 
    static void testgetDDRProductRecord3() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration-product/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('id', '');
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDDRProducts_V1.getDDRProductRecord();
        Test.stopTest();
    }
    
    @isTest 
    static void testgetDDRProductRecord4() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration-product/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('UniqueId', 'FSI002DDR');
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDDRProducts_V1.getDDRProductRecord();
        Test.stopTest();
    }
    
     @isTest 
    static void testgetDDRProductRecord5() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration-product/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDDRProducts_V1.getDDRProductRecord();
        Test.stopTest();
    }
    
    @isTest 
    static void testgetDDRProductRecord1() {
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
        
        Core_Design_Registration_Product__c drProduct = new Core_Design_Registration_Product__c();
        drProduct.Core_Product_Id__c = pr.Id;
		drProduct.Core_Design_Registration_Id__c = ddrRec.Id;
		drProduct.Core_Full_Year_Qty__c= 1000;
		drProduct.Core_Retired_As_Of_Dt__c= Date.today();
		drProduct.Core_External_Id__c= '002uswLKJMgsi3HJK';
		insert drProduct;
        
        req.requestUri = '/services/apexrest/v1.0/design-registration-product/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('id', drProduct.Id);
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDDRProducts_V1.getDDRProductRecord();
        Test.stopTest();
    }
    
    @isTest
    static void createDRProductTest1(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"designRegId":"a3D8A000000sdluUAA","retiredAsOf":"2023-09-09","Status":"guwd","externalId":"00JKGKLsdfghjmbvcKOL"},'+
                                       '{"designRegId":"a3D8A000000sdluUAA", "productId":"01t1J00000BQ2dWQAT", "quantity":"100","retiredAsOf":"2021-09-09","Status":"Pending","externalId":"00JKGlpjdlpHJOPOL"},'+
                                       '{"designRegId":"a3D8A000000sdlu","productId":"01t1J00000BQ2dWQAT","quantity":"100","retiredAsOf":"2015-12-31","abc":"Testing","externalId":"00GujKIOLHIUKdoeLK"},'+
                                       '{"designRegId":"a3D8A000000sdlu","productId":"01t1J00000BQ2dWQAT","quantity":"100","retiredAsOf":"20-12-2031","abc":"Testing","externalId":"00GujKIOLHIUKdoeLK"},'+
                                       '{"designRegId":"a3D8A000000sdlu","productId":"01t1J00000BQ2dWQAT","quantity":"100", "retiredAsOf":"2015-12-31","abc":"Testing","externalId":"00GujKIOLHIUKdoeLKOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDDRProducts_V1.createDDRProductRecords();
        Test.stopTest();
    }
    
    @isTest
    static void createDRProductTest2(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"designRegId":"a3D8A000000sdluUAA","retiredAsOf":"2023-09-09","Status":"guwd","externalId":"00JKGKLsdfghjmbvcKOL"}');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDDRProducts_V1.createDDRProductRecords();
        Test.stopTest();
    }

    
}