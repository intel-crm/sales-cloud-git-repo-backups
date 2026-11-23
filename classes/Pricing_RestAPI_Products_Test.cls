/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_Products_Test 
* Version     : 1.0 
* Created Date: 14 Oct 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         10/14/2020              Test Class for Pricing_RestAPI_Products
*****************************************************************************************************************************************/

@isTest
public class Pricing_RestAPI_Products_Test {
	@testSetup
    static void dataSetup() {
        Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
        //test.startTest();
        
        //test.stopTest();
    	List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();          
    
        System.runAs(lstUsers2[0])
        {
            test.startTest();
            Account acc = Pricing_Test_Utility.createAccount();
            //Contact con = Pricing_Test_Utility.createContact(acc.Id);
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Rest_API_Products_test');
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            //Pricing_Test_Utility.createAEUser();
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            test.stopTest(); 
    	}
       
        Pricing_RestAPI_TestUtility.createCompetitorProducts(200);
        Pricing_RestAPI_TestUtility.createProducts(1500);
    }
    
    static testMethod void testGetProducts_Without_Params() {
		User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest(); 
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=products&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'products');
            req.addParameter('id', '');
            req.addParameter('searchText', '');
            req.addParameter('limit', '');
            req.addParameter('offset', '');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            system.assert(response!=null);
            system.assertEquals(1500, response.successContent.size());
            test.stopTest();
    	}
    }
    
    static testMethod void testGetProducts_With_RecordId() {
		User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();   
            List<Product2> podcts = [SELECT Id,Name From Product2 LIMIT 1];
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=products&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'products');
            req.addParameter('id', String.valueOf(podcts[0].Id));
            req.addParameter('searchText', '');
            req.addParameter('limit', '');
            req.addParameter('offset', '');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            system.assert(response!=null);
            //system.assertEquals(1, response.successContent.size());
            test.stopTest();
    	}
    }    
    
    static testMethod void testGetProducts_With_SearchText() {
        User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=products&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'products');
            req.addParameter('id', '');
            req.addParameter('searchText', 'Processor001Number-0001');
            req.addParameter('limit', '');
            req.addParameter('offset', '');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            system.assert(response!=null);
            //system.assertEquals(1, response.successContent.size());
            test.stopTest();
    	}
    }
    
    static testMethod void testGetProducts_With_LimitAndOffset_1() {
		User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=products&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'products');
            req.addParameter('id', '');
            req.addParameter('searchText', '');
            req.addParameter('limit', '100');
            req.addParameter('offset', '1490');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            system.assert(response!=null);
            system.assertEquals(1500, response.totalRecords);
            system.assertEquals(10, response.successContent.size());
            test.stopTest();
        }
    }
    
    static testMethod void testGetProducts_With_LimitAndOffset_2() {
		User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();      
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=products&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'products');
            req.addParameter('id', '');
            req.addParameter('searchText', '');
            req.addParameter('limit', '100');
            req.addParameter('offset', '1400');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            system.assert(response!=null);
            system.assertEquals(1500, response.totalRecords);
            system.assertEquals(100, response.successContent.size());
            test.stopTest();
        }
    }
    static testMethod void testGetProducts_With_SSDProductType() {
        User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=products&productType=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'products');
            req.addParameter('productType', 'SSD');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            system.assert(response!=null);
            test.stopTest();
    	}
    }
    static testMethod void testGetProducts_With_PMemProductType() {
        User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=products&productType=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'products');
            req.addParameter('productType', 'PMem');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            system.assert(response!=null);
            test.stopTest();
    	}
    }
    static testMethod void testGetProducts_With_NICProductType() {
        User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=products&productType=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'products');
            req.addParameter('productType', 'NIC');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            system.assert(response!=null);
            test.stopTest();
    	}
    }
    static testMethod void testGetProducts_With_ProcessorProductType() {
        User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=products&productType=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'products');
            req.addParameter('productType', 'Processor');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            system.assert(response!=null);
            test.stopTest();
    	}
    }
    static testMethod void testGetProducts_With_AllProductType() {
        User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=products&productType=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'products');
            req.addParameter('productType', 'All');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            system.assert(response!=null);
            test.stopTest();
    	}
    }
    static testMethod void testGetProducts_With_InvalidProductType() {
        User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=products&productType=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'products');
            req.addParameter('productType', 'Test');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            system.assert(response!=null);
            test.stopTest();
    	}
    }
    static testMethod void testGetProducts_Without_ProductType() {
        User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=products&productType=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'products');
            req.addParameter('productType', '');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            system.assert(response!=null);
            test.stopTest();
    	}
    }
    static testMethod void testGetProducts_NoData() {
		User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();   
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=products&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'products');
            req.addParameter('id', '');
            req.addParameter('searchText', 'ABCDEFGHIJK');
            req.addParameter('limit', '');
            req.addParameter('offset', '');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            system.assert(response!=null);
            system.assertEquals(null, response.successContent);
            system.assert(response.errorContent.traceId!=null);
            test.stopTest();
        }
    }
    static testMethod void testGetProducts_Invalid_RecordId() {
		User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();     
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=products&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'products');
            req.addParameter('id', 'ABCDEF2323GH');
            req.addParameter('searchText', '');
            req.addParameter('limit', '100');
            req.addParameter('offset', '1400');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            system.assert(response!=null);
            system.assertEquals(null, response.successContent);
            system.assert(response.errorContent.traceId!=null);
            test.stopTest();
        }
    }
    static testMethod void testGetProducts_Invalid_Limit() {
        User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();     
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=products&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'products');
            req.addParameter('id', '');
            req.addParameter('searchText', '');
            req.addParameter('limit', 'ABC');
            req.addParameter('offset', 'def');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            system.assert(response!=null);
            system.assertEquals(null, response.successContent);
            system.assert(response.errorContent.traceId!=null);
            test.stopTest();
        }
    }
    static testMethod void testGetCompetitorProducts_Without_Params() {
		User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=competitorproducts&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'competitorproducts');
            req.addParameter('id', '');
            req.addParameter('searchText', '');
            req.addParameter('limit', '');
            req.addParameter('offset', '');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            //system.assert(response!=null);
           // system.assertEquals(200, response.successContent.size());
            test.stopTest();
        }
    }
    static testMethod void testGetCompetitorProducts_With_RecordId() {
        User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c(
            Name = 'Product Z',
            Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
            Pricing_Active_cb__c = true,
            RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_Data_Center')
           );
             insert cp;
        system.runAs(usr){
            test.startTest();
           // List<Pricing_Competitor_Product__c> compProdlist = [SELECT id FROM Pricing_Competitor_Product__c LIMIT 1];            
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=competitorproducts&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'competitorproducts');
           // req.addParameter('id', String.valueOf(compProdlist[0].Id));
             req.addParameter('id', String.valueOf(cp.Id));
            req.addParameter('searchText', '');
            req.addParameter('limit', '');
            req.addParameter('offset', '');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            //system.assert(response!=null);
            //system.assertEquals(1, response.successContent.size());
            test.stopTest();
        }
    }
    static testMethod void testGetCompetitorProducts_With_SearchText() {        
		User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();        
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=competitorproducts&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'competitorproducts');
            req.addParameter('id', '');
            req.addParameter('searchText', 'CompProd1S AMD');
            req.addParameter('limit', '');
            req.addParameter('offset', '');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            //system.assert(response!=null);
           // system.assertEquals(1, response.successContent.size());
            test.stopTest();
        }
    }
    static testMethod void testGetCompetitorProducts_With_LimitOffset_1() {        
		User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();        
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=competitorproducts&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'competitorproducts');
            req.addParameter('id', '');
            req.addParameter('searchText', '');
            req.addParameter('limit', '10');
            req.addParameter('offset', '100');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            //system.assert(response!=null);
            //system.assertEquals(200, response.totalRecords);
            //system.assertEquals(10, response.successContent.size());
            test.stopTest();
        }
    }
    
    static testMethod void testGetCompetitorProducts_With_LimitOffset_2() {        
		User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();        
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=competitorproducts&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'competitorproducts');
            req.addParameter('id', '');
            req.addParameter('searchText', '');
            req.addParameter('limit', '100');
            req.addParameter('offset', '190');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            //system.assert(response!=null);
            //system.assertEquals(200, response.totalRecords);
            //system.assertEquals(10, response.successContent.size());
            test.stopTest();
        }
    }
    static testMethod void testGetCompetitorProducts_NoData() {        
		User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();        
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=competitorproducts&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'competitorproducts');
            req.addParameter('id', '');
            req.addParameter('searchText', 'ABCDEFGH');
            req.addParameter('limit', '');
            req.addParameter('offset', '');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            system.assert(response!=null);        
            system.assertEquals(null, response.successContent);
            system.assert(response.errorContent.traceId!=null);
            test.stopTest();
        }
    }
    static testMethod void testGetCompetitorProducts_InvalidRecId() {        
		User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();        
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=competitorproducts&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'competitorproducts');
            req.addParameter('id', 'ABCD1212EFGHIJ');
            req.addParameter('searchText', '');
            req.addParameter('limit', '');
            req.addParameter('offset', '');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            system.assert(response!=null);        
            system.assertEquals(null, response.successContent);
            system.assert(response.errorContent.traceId!=null);
            test.stopTest();
        }
    }
    static testMethod void testGetCompetitorProducts_Invalid_LimitOffset() {        
		User usr = [SELECT id FROM User WHERE email='Rest_API_Products_test@noemail.com'];
        system.runAs(usr){
            test.startTest();        
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/products?type=competitorproducts&id=&searchText=&limit=&offset=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'competitorproducts');
            req.addParameter('id', '');
            req.addParameter('searchText', '');
            req.addParameter('limit', 'ABC');
            req.addParameter('offset', 'ABC');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Products.doGet();
            //system.debug('Test response ==>'+response);
            system.assert(response!=null);
            system.assertEquals(null, response.successContent);
            system.assert(response.errorContent.traceId!=null);
            test.stopTest();
        }
    }    
    static testmethod void testGetMetadataWhereClauseWithProdType(){
        test.startTest();
        Pricing_RestAPI_Products.getMetadataWhereClause('Client');
        test.stopTest();
    } 
}