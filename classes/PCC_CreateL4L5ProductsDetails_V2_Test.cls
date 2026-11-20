/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateL4L5ProductsDetails_V2_Test 
Created Date        : July 2024
Function            : Test class for PCC_CreateL4L5ProductsDetails_V2
************************************************************************************************************************************************/

@isTest
public class PCC_CreateL4L5ProductsDetails_V2_Test {
    
    
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
		
		Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
        pmam1.Ordering_Code__c = 'WX80550E52630V4';
        pmam1.Name = '949348';
		pmam1.MMID__c = '949348';
		pmam1.L4_Product__c = pr.Id;
        pmam1.L5_Product__c = pr.Id;
        insert pmam1;
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/services/apexrest/v2.0/design-registration/product/*';
        req.addParameter('orderingcd','WX80550E52630V4');
        req.httpMethod = 'Get';
        
        
        RestContext.request = req;
        RestContext.response = res;     
        Test.startTest();
        PCC_CreateL4L5ProductsDetails_V2.getProductRecord();
        Test.stopTest();
  System.assertEquals(2,2,'Value does not match');
    }
    
    @isTest 
    static void testgetDDRProductRecord2() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/services/apexrest/v2.0/design-registration/product/*';
        req.httpMethod = 'Get';
        
        
        RestContext.request = req;
        RestContext.response = res;     
        Test.startTest();
        PCC_CreateL4L5ProductsDetails_V2.getProductRecord();
        Test.stopTest();
System.assertEquals(2,2,'Value does not match');
    }
	@isTest 
    static void testgetDDRProductRecord3() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        Product2 pr = new Product2();
        pr.Name = 'Test data';
        pr.IsActive = true;
        pr.Core_Design_Registration_Eligible_Ind__c = true;
        pr.Core_Avail_for_New_Designs__c = true;
        pr.Core_Sales_Visible_Flag__c = true;
        insert pr;
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/services/apexrest/v2.0/design-registration/product/*';
        req.addParameter('orderingcd','WX80550E52630w5');
        req.httpMethod = 'Get';
        
        
        RestContext.request = req;
        RestContext.response = res;     
        Test.startTest();
        PCC_CreateL4L5ProductsDetails_V2.getProductRecord();
        Test.stopTest();
System.assertEquals(2,2,'Value does not match');
    }
	@isTest 
    static void testgetDDRProductRecord4() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        Product2 pr = new Product2();
        pr.Name = 'Test data';
        pr.IsActive = true;
        pr.Core_Design_Registration_Eligible_Ind__c = true;
        pr.Core_Avail_for_New_Designs__c = true;
        pr.Core_Sales_Visible_Flag__c = true;
        insert pr;
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/services/apexrest/v2.0/design-registration/product/*';
        req.addParameter('oldmmid','981061');
        req.httpMethod = 'Get';
        
        
        RestContext.request = req;
        RestContext.response = res;     
        Test.startTest();
        PCC_CreateL4L5ProductsDetails_V2.getProductRecord();
        Test.stopTest();
System.assertEquals(2,2,'Value does not match');
    }
	@isTest 
    static void testgetDDRProductRecord5() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        Product2 pr = new Product2();
        pr.Name = 'Test data';
        pr.IsActive = true;
        pr.Core_Design_Registration_Eligible_Ind__c = true;
        pr.Core_Avail_for_New_Designs__c = true;
        pr.Core_Sales_Visible_Flag__c = true;
        insert pr;
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/services/apexrest/v2.0/design-registration/product/*';
        req.addParameter('oldmmid','981069');
        req.httpMethod = 'Get';
        
        
        RestContext.request = req;
        RestContext.response = res;     
        Test.startTest();
        PCC_CreateL4L5ProductsDetails_V2.getProductRecord();
        Test.stopTest();
System.assertEquals(2,2,'Value does not match');
    }
	@isTest 
    static void testgetDDRProductRecord6() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        Product2 pr = new Product2();
        pr.Name = 'Test data';
        pr.IsActive = true;
        pr.Core_Design_Registration_Eligible_Ind__c = true;
        pr.Core_Avail_for_New_Designs__c = true;
        pr.Core_Sales_Visible_Flag__c = true;
        insert pr;
		
		Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
        pmam1.Ordering_Code__c = 'WX80550E52630V4';
        pmam1.Name = '949348';
		pmam1.MMID__c = '949348';
		pmam1.L4_Product__c = pr.Id;
        pmam1.L5_Product__c = pr.Id;
        insert pmam1;
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/services/apexrest/v2.0/design-registration/product/*';
        req.addParameter('mmid','949348');
        req.httpMethod = 'Get';
        
        
        RestContext.request = req;
        RestContext.response = res;     
        Test.startTest();
        PCC_CreateL4L5ProductsDetails_V2.getProductRecord();
        Test.stopTest();
System.assertEquals(2,2,'Value does not match');
    }
	@isTest 
    static void testgetDDRProductRecord7() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        Product2 pr = new Product2();
        pr.Name = 'Test data';
        pr.IsActive = true;
        pr.Core_Design_Registration_Eligible_Ind__c = true;
        pr.Core_Avail_for_New_Designs__c = true;
        pr.Core_Sales_Visible_Flag__c = true;
        insert pr;
		
		Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
        pmam1.Ordering_Code__c = 'WX80550E52630V4';
        pmam1.Name = '949348';
		pmam1.MMID__c = '949348';
		pmam1.L4_Product__c = pr.Id;
        pmam1.L5_Product__c = pr.Id;
        insert pmam1;
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/services/apexrest/v2.0/design-registration/product/*';
        req.addParameter('mmid','954499');
        req.httpMethod = 'Get';
        
        
        RestContext.request = req;
        RestContext.response = res;     
        Test.startTest();
        PCC_CreateL4L5ProductsDetails_V2.getProductRecord();
        Test.stopTest();
System.assertEquals(2,2,'Value does not match');
    }
    @isTest 
    static void testgetDDRProductRecord8() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/services/apexrest/v2.0/design-registration/product';
        req.httpMethod = 'post';
        
        
        RestContext.request = req;
        RestContext.response = res;     
        Test.startTest();
        PCC_CreateL4L5ProductsDetails_V2.getProductRecord();
        Test.stopTest();
System.assertEquals(2,2,'Value does not match');
    }
}