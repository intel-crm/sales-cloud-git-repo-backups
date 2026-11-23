/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_PerformanceMetrics_Test 
* Version     : 1.0 
* Created Date: 29 October 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         10/29/2020              Test class for Rest API to create Performance Metrics with no sections
*****************************************************************************************************************************************/
@IsTest
public class Pricing_RestAPI_PerformanceMetrics_Test {
    
       
    @testSetup static void testSetup() {
        List<Product2> prodList = new List<Product2>();
        Product2 prod = new Product2();
        prod.Core_Product_Org__c = 'Sales';
        prod.Core_Product_Type__c = 'Processors';
        prod.Core_Sales_Visible_Flag__c  = True;
        prod.IsActive = True;
        prod.Core_Group_Code_Short_Name__c = 'DCG~DCAI';
        prod.Core_Hierarchy_ID__c = '43';
        prod.Name = 'Product X';
        prod.Core_Processor_Number_Nm__c = 'test';
        prodList.add(prod);
        
        Product2 prod1 = new Product2();
        prod1.Name = 'Write In Product';
        prod1.IsActive = True;
        prodList.add(prod1);
        
        Pricing_Test_Utility.createPriceBook();
        
        Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c(
            Name = 'Product Z',
            Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
            RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_Data_Center'),
            Pricing_Active_cb__c = true
        );
        
        insert prodList;
        insert cp;
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();          
        System.runAs(lstUsers2[0])
        {
            test.startTest();
            Account acc = Pricing_Test_Utility.createAccount();
            //Contact con = Pricing_Test_Utility.createContact(acc.Id);
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Performance_Metrics_test_11');
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            //Pricing_Test_Utility.createAEUser();
            Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            Pricing_QuoteProgram_CAPSize__c capRec = new Pricing_QuoteProgram_CAPSize__c();
            capRec.Name = 'Test Account';
            capRec.Pricing_Account_Id__c = acc.Id;
            capRec.Pricing_Active_cb__c = true;
            capRec.Pricing_Small_Deal_CAP_size_Number__c = 300;
            insert capRec;  
            
            Pricing_UnifiedEndCustomerAccountMapping__c uniEndCustomerL1 = new Pricing_UnifiedEndCustomerAccountMapping__c();
            uniEndCustomerL1.Name = 'Write In End Customer';
            uniEndCustomerL1.Pricing_Active_cb__c = true;
            uniEndCustomerL1.Pricing_Account_Nm__c = acc.Id;
            uniEndCustomerL1.Pricing_Unified_EndCustomer_Id__c = '1111';
            insert uniEndCustomerL1;
            
            Pricing_UnifiedEndCustomerCountryMapping__c uniEndCustomerL2 = new Pricing_UnifiedEndCustomerCountryMapping__c();
            uniEndCustomerL2.Name = 'FMH';
            uniEndCustomerL2.Pricing_Unified_EndCustomer_Act_Mapping__c = uniEndCustomerL1.Id;
            uniEndCustomerL2.Pricing_Country_Nm__c = 'Afghanistan';
            uniEndCustomerL2.Pricing_Unified_Country_EndCustomer_Id__c = '2222';
            insert uniEndCustomerL2;
            test.stopTest();
            
            List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c =  acc.Id;
            quote.SBQQ__PrimaryContact__c = con.Id;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project';
            quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote.Pricing_Customer_Nm__c = 'FMH';
            quote.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_Intel_Response_Requested_By_Date__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote.Pricing_Region_Nm__c = 'APJ';
            //insert quote;
            quotes.add(quote);
            
            
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            quote1.SBQQ__Account__c =  acc.Id;
            quote1.SBQQ__PrimaryContact__c = con.Id;
            quote1.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote1.Pricing_Project_Name_Nm__c = 'Test Project';
            quote1.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote1.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote1.Pricing_Customer_Nm__c = 'FMH';
            quote1.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote1.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote1.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote1.Pricing_Intel_Response_Requested_By_Date__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote1.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote1.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote1.Pricing_Region_Nm__c = 'APJ';
            quotes.add(quote1);
            
            SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
            quote2.SBQQ__Account__c =  acc.Id;
            quote2.SBQQ__PrimaryContact__c = con.Id;
            quote2.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote2.Pricing_Project_Name_Nm__c = 'Test Project';
            quote2.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote2.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote2.Pricing_Customer_Nm__c = 'FMH';
            quote2.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote2.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote2.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote2.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote2.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote2.Pricing_Region_Nm__c = 'APJ';
            quotes.add(quote2);
            insert quotes;
            
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>(); 
            SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
            quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob.Pricing_Product_Nm__c = prod.Id;
            //quoteLineob.SBQQ__Product__c = prod.Id;
            quoteLineob.Pricing_Other_Product_Nm__c=null;
            quoteLineob.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob.Pricing_Systems_qty__c = 6; 
            quoteLineob.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLineob.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob.Pricing_Competetor_Product__c=cp.Id;
            quoteLineob.Pricing_Other_Competitor_Product_Nm__c = null;  
            quoteLineob.SBQQ__Quote__c = quote.Id;
            quoteLines.add(quoteLineob);
            //insert quoteLine;
            //quoteLines.add(quoteLineob);
            
            SBQQ__QuoteLine__c quoteLineob1 = new SBQQ__QuoteLine__c(); 
            quoteLineob1.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob1.Pricing_Product_Nm__c = prod.Id;
            //quoteLineob.SBQQ__Product__c = prod.Id;
            quoteLineob1.Pricing_Other_Product_Nm__c=null;
            quoteLineob1.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob1.Pricing_Systems_qty__c = 6; 
            quoteLineob1.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLineob1.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob1.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob1.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob1.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob1.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob1.Pricing_Competetor_Product__c=cp.Id;
            quoteLineob1.Pricing_Other_Competitor_Product_Nm__c = null;  
            quoteLineob1.SBQQ__Quote__c = quote1.Id;
            quoteLines.add(quoteLineob1);
            
            SBQQ__QuoteLine__c quoteLineob2 = new SBQQ__QuoteLine__c(); 
            quoteLineob2.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob2.Pricing_Product_Nm__c = prod.Id;
            //quoteLineob.SBQQ__Product__c = prod.Id;
            quoteLineob2.Pricing_Other_Product_Nm__c=null;
            quoteLineob2.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob2.Pricing_Systems_qty__c = 6; 
            quoteLineob2.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLineob2.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob2.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob2.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob2.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob2.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob2.Pricing_Competetor_Product__c=cp.Id;
            quoteLineob2.Pricing_Other_Competitor_Product_Nm__c = null;  
            quoteLineob2.SBQQ__Quote__c = quote2.Id;
            quoteLines.add(quoteLineob2);            
            insert quoteLines;
            
            
            List<Pricing_Performance_Metric__c> mList=new List<Pricing_Performance_Metric__c>();
            Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
            metrics.Pricing_Comp_SKU_Performance_Nbr__c=1;
            metrics.Pricing_Intel_SKU_Performance_Nbr__c=1;
            metrics.Pricing_Other_Nm__c='test';
            metrics.Pricing_Performance_Metric_Nm__c='Other';
            metrics.Pricing_Quote_Line__c=quoteLines[0].Id;
            metrics.Pricing_Weighting_Pct__c=10;
            mList.add(metrics);
            
            Pricing_Performance_Metric__c metrics1=new Pricing_Performance_Metric__c();
            metrics1.Pricing_Comp_SKU_Performance_Nbr__c=1;
            metrics1.Pricing_Intel_SKU_Performance_Nbr__c=1;
            metrics1.Pricing_Other_Nm__c='test';
            metrics1.Pricing_Performance_Metric_Nm__c='Other';
            metrics1.Pricing_Quote_Line__c=quoteLines[1].Id;
            metrics1.Pricing_Weighting_Pct__c=10;
            mList.add(metrics1);
            
            Pricing_Performance_Metric__c metrics2=new Pricing_Performance_Metric__c();
            metrics2.Pricing_Comp_SKU_Performance_Nbr__c=1;
            metrics2.Pricing_Intel_SKU_Performance_Nbr__c=1;
            metrics2.Pricing_Other_Nm__c='test';
            metrics2.Pricing_Performance_Metric_Nm__c='Other';
            metrics2.Pricing_Quote_Line__c=quoteLines[2].Id;
            metrics2.Pricing_Weighting_Pct__c=10;
            mList.add(metrics2);
            insert mList;   
            Pricing_Publish_Quote.PublishTenderQuote(String.valueOf(quote2.Id));
        }
    }
    
    
    @isTest static void testDoPost() {
        User usr = [SELECT id FROM User WHERE email='Performance_Metrics_test_11@noemail.com'];
        SBQQ__Quote__c quote = [Select Id,Name from SBQQ__Quote__c quote LIMIT 1];
        SBQQ__QuoteLine__c quoteLine=[Select Id, SBQQ__Quote__c from SBQQ__QuoteLine__c quoteLine where SBQQ__Quote__c = :quote.Id LIMIT 1];
        system.runAs(usr){
            test.startTest();            
            RestRequest request = new RestRequest();
            request.requestUri = '/services/apexrest/v1.0/quoterequest/performancemetrics';
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{	"quoteLineId":"'+quoteLine.Id+'",	"performanceMetrics":[{"performanceMetricsReferenceId":"PM-77","performanceMetricsUsed":"Other","weighting":"10","intelScore":10,"compScore":5,"otherText":"Test"},{"performanceMetricsReferenceId":"PM-87","performanceMetricsUsed":"HPCG","weighting":"10","intelScore":10,"compScore":5,"otherText":null}]}');
            RestContext.request = request;
            
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_PerformanceMetrics.doPost();
            system.assert(restResponse!=null);
            test.stopTest();
    	}
    }
    
    @isTest static void testDoPost_FailCase() {
		 User usr = [SELECT id FROM User WHERE email='Performance_Metrics_test_11@noemail.com'];
        SBQQ__Quote__c quote = [Select Id,Name from SBQQ__Quote__c quote LIMIT 1];
        SBQQ__QuoteLine__c quoteLine=[Select Id, SBQQ__Quote__c from SBQQ__QuoteLine__c quoteLine where SBQQ__Quote__c = :quote.Id LIMIT 1];
        system.runAs(usr){
            test.startTest();            
            RestRequest request = new RestRequest();
            request.requestUri = '/services/apexrest/v1.0/quoterequest/performancemetrics';
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{	"quoteLineId":"'+quoteLine.Id+'",	"performanceMetrics":[{"performanceMetricsReferenceId":"","performanceMetricsUsed":"XYZ","weighting":"10","intelScore":10,"compScore":5,"otherText":"Test"},{"performanceMetricsReferenceId":"","performanceMetricsUsed":"HPCG","weighting":"10","intelScore":-10,"compScore":-5,"otherText":null}]}');
            RestContext.request = request;
            
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_PerformanceMetrics.doPost();
            system.assertEquals(restResponse.isSuccess, false);
            test.stopTest();
    	}
   }
     
   static testMethod void testDoGet() {
		 User usr = [SELECT id FROM User WHERE email='Performance_Metrics_test_11@noemail.com'];
        system.runAs(usr){
            test.startTest();        
            List<Pricing_Performance_Metric__c> pmList = [Select Id from Pricing_Performance_Metric__c limit 1];
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            // Initialize response context explicitly; remove unused local variable
            RestContext.response = new RestResponse();
            req.requestUri='/services/apexrest/v1.0/quoterequest/performancemetrics?id=';
            req.httpMethod = 'GET';
            req.addParameter('id', pmList[0].Id);
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_PerformanceMetrics.doGet();
            system.assertEquals(response.code, '200');
            test.stopTest();
        }
    }
    
    static testMethod void testDoGet_Negative() {
		 User usr = [SELECT id FROM User WHERE email='Performance_Metrics_test_11@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            // Initialize response context explicitly; remove unused local variable
            RestContext.response = new RestResponse();
            req.requestUri='/services/apexrest/v1.0/quoterequest/performancemetrics?id=';
            req.httpMethod = 'GET';
            req.addParameter('id', 'asdasdw');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_PerformanceMetrics.doGet();
            system.assert(response!=null);
            test.stopTest();
    	}
    }
    	@isTest static void testSuccessUpdatePM() {
        User usr = [SELECT id FROM User WHERE email='Performance_Metrics_test_11@noemail.com'];
        system.runAs(usr){
            test.startTest();
            List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id,Name From SBQQ__QuoteLine__c LIMIT 1];
            List<Pricing_Performance_Metric__c> pmList = [Select Id,Name,Pricing_Quote_Line__c, Pricing_Performance_Metric_Nm__c,Pricing_Intel_SKU_Performance_Nbr__c,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Weighting_Pct__c,Pricing_Other_Nm__c from Pricing_Performance_Metric__c where Pricing_Quote_Line__c IN :quoteLineList];
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/performancemetrics';
            request.httpMethod = 'PATCH';
            request.addHeader('Content-Type', 'application/json');
           // request.requestBody = Blob.valueOf('{ "quoteLineId":"'+quoteLineList[0].Id+'", "performanceMetrics":[{"performanceMetricsUsed":"Other","weighting":10,"intelScore":10,"compScore":5,"otherText":"Test" }]}');
            request.requestBody = Blob.valueOf('{	"quoteLineId":"'+quoteLineList[0].Id+'",	"performanceMetrics":[{"performanceMetricsId" : "'+pmList[0].id+'","performanceMetricsReferenceId":"PM-77","performanceMetricsUsed":"Other","weighting":"10","intelScore":10,"compScore":5,"otherText":"Test"}]}');
            RestContext.request = request;        
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_PerformanceMetrics.updatePM();
            system.assertEquals(restResponse.isSuccess, true);
            test.stopTest();
    	}
    }
    
    @isTest static void testUpdatePM_Negative() {
        User usr = [SELECT id FROM User WHERE email='Performance_Metrics_test_11@noemail.com'];
        system.runAs(usr){
            test.startTest();
            List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id,Name From SBQQ__QuoteLine__c LIMIT 1];
            RestRequest request = new RestRequest();
            request.requestUri = '/services/apexrest/v1.0/quoterequest/performancemetrics';
            request.httpMethod = 'PATCH';
            request.addHeader('Content-Type', 'application/json');
            //request.requestBody = Blob.valueOf('{ "quoteLineId":"'+quoteLineList[0].Id+'", "performanceMetrics":[{"performanceMetricsUsed":"Other","weighting":0,"intelScore":-10,"compScore":-5,"otherText":"Test" }]}');
            request.requestBody = Blob.valueOf('{	"quoteLineId":"'+quoteLineList[0].Id+'",	"performanceMetrics":[{"performanceMetricsId" : "","performanceMetricsReferenceId":"","performanceMetricsUsed":"Other","weighting":"0","intelScore":-10,"compScore":-5,"otherText":"Test"},{"performanceMetricsId" : "","performanceMetricsReferenceId":"","performanceMetricsUsed":"HPCG","weighting":"10","intelScore":10,"compScore":5,"otherText":null}]}');
            RestContext.request = request;        
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_PerformanceMetrics.updatePM();
            system.assertEquals(restResponse.isSuccess, false);
            test.stopTest();
    	}
    }
}