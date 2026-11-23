/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_Quotelines_Test 
* Version     : 1.0 
* Created Date: 05 Nov 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         11/05/2020              Test class for Rest API to submit a QuoteLine
*****************************************************************************************************************************************/
@IsTest
public class Pricing_RestAPI_Quotelines_Test{
    
    @testSetup static void testSetup() {
        Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
        
        List<Product2> prodList = new List<Product2>();
        
        Product2 prod = new Product2();
        prod.Core_Product_Org__c = 'Sales';
        prod.Core_Product_Type__c = 'Processors';
        prod.Core_Sales_Visible_Flag__c  = True;
        prod.IsActive = True;
        prod.Core_Hierarchy_ID__c = '43';
        prod.Core_Group_Code_Short_Name__c = 'CCG';
        prod.Core_Processor_Number_Nm__c  = '6220';
        prod.Name = 'Product X';
        prodList.add(prod);
        
        Product2 prod1 = new Product2();
        prod1.Name = 'Write In Product';
        prod1.IsActive = True;
        prodList.add(prod1);
        
        Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c(
            Name = 'Product Z',
            Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
            RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_Data_Center')
        );
        insert prodList;
        insert cp;
        
        Pricing_Test_Utility.createPriceBook();
        
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();          
        System.runAs(lstUsers2[0])
        {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
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
            
            List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c =  acc.Id;
            quote.SBQQ__PrimaryContact__c = con.Id;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project';
            quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote.Pricing_End_Customer__c = uniEndCustomerL1.Id;
            quote.Pricing_Customer_Nm__c = 'FMH';
            quote.Pricing_Unified_Global_End_Customer_Nm__c = uniEndCustomerL2.Id;
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
            quote1.Pricing_Project_Name_Nm__c = 'Test Project1';
            quote1.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote1.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote1.Pricing_End_Customer__c = uniEndCustomerL1.Id;
            quote1.Pricing_Customer_Nm__c = 'FMH';
            quote1.Pricing_Unified_Global_End_Customer_Nm__c = uniEndCustomerL2.Id;
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
            quote2.Pricing_Project_Name_Nm__c = 'Test Project2';
            quote2.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote2.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote2.Pricing_End_Customer__c = uniEndCustomerL1.Id;
            quote2.Pricing_Customer_Nm__c = 'FMH';
            quote2.Pricing_Unified_Global_End_Customer_Nm__c = uniEndCustomerL2.Id;
            quote2.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote2.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote2.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote2.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote2.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote2.Pricing_Region_Nm__c = 'APJ';
            quotes.add(quote2);
            
            insert quotes;
            test.startTest();
            
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
            
            SBQQ__QuoteLine__c quoteLineob1 = new SBQQ__QuoteLine__c(); 
            quoteLineob1.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob1.Pricing_Product_Nm__c = prod.Id;
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
            
            
            test.stopTest();
            
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
            insert mList;  
            
            Set<Id> quoteIds = new Set<Id>{quote.Id, quote2.Id};
                List<Pricing_Comments__c> qComments = [SELECT id,name,Pricing_Answer__c FROM Pricing_Comments__c WHERE Pricing_Quote__c IN :quoteIds];
            for(Pricing_Comments__c qc : qComments){
                qc.Pricing_Answer__c = 'This is a test Answer. Test';
            }
            if(qComments.size() > 0){
                update qComments; 
            }
            
            Pricing_Publish_Quote.PublishTenderQuote(String.valueOf(quote2.Id));
        }
    }
    
    @isTest static void testDoPost() {
        SBQQ__Quote__c quote = [Select Id,Pricing_Project_Name_Nm__c from SBQQ__Quote__c quote where Pricing_Project_Name_Nm__c = :'Test Project1'];
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Product Z'];
        Product2 p = [Select Id from Product2 where Name = :'Product X'];
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com']; 
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/quotelines';
            request.addParameter('action', 'create');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"quoteId": "'+quote.Id+'","quoteLines": [{"productId": "'+p.Id+'","quoteLinePricingEndDate":"10/30/2029","quotelineReferenceID": "QL-001","writeInProduct": "","systemModel": "Test","noOfSystems": 10,"noOfCPUsPerSystem": 1,"singleSystemPrice": 100,"customerStdUnitPrice": 50,"requestedDiscountUnitPrice": 20,"additionalDiscount": 0,"competitorName": "Test","competitorSystemModel": "Test","competitorProductId": "'+cp.Id+'","competitorWriteInProduct": null,"competitorNoOfSystems": 1,"competitorNoOfCPUsPerSystem": 1,"competitorSingleSystemPrice": 8,"competitorAdditionalDiscount": 2,"additionalComment": null,"performanceMetrics": [{"performanceMetricsUsed": "Other","performanceMetricsReferenceId": "PM-003","weighting": 10,"intelScore": 10,"compScore": 3,"otherText": "Test"}]}]}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_Quotelines.doPost();
            system.debug('restResponse==>'+restResponse);
            system.assert(restResponse!=null);
            test.stopTest();
            request.requestBody = Blob.valueOf('{"quoteId": "'+quote.Id+'","quoteLines": [{"productId": "'+p.Id+'","quoteLinePricingEndDate":"10/30/2020","quotelineReferenceID": "QL-001","writeInProduct": "","systemModel": "Test","noOfSystems": 10,"noOfCPUsPerSystem": 1,"singleSystemPrice": 100,"customerStdUnitPrice": 50,"requestedDiscountUnitPrice": 20,"additionalDiscount": 0,"competitorName": "Test","competitorSystemModel": "Test","competitorProductId": "'+cp.Id+'","competitorWriteInProduct": null,"competitorNoOfSystems": 1,"competitorNoOfCPUsPerSystem": 1,"competitorSingleSystemPrice": 0,"competitorAdditionalDiscount": 2,"additionalComment": null,"performanceMetrics": [{"performanceMetricsUsed": "Other","performanceMetricsReferenceId": "PM-003","weighting": 10,"intelScore": 10,"compScore": 3,"otherText": "Test"}]}]}');
            Pricing_RestAPI_Response restResponse2 = Pricing_RestAPI_Quotelines.doPost();
            system.assert(restResponse2!=null);
        }
    } 
    
    @isTest static void testDoPost_statusChange() {
        SBQQ__QuoteLine__c quoteline = [Select Id from SBQQ__QuoteLine__c where Pricing_Status_Nm__c = 'Draft' limit 1];
        quoteline.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
        quoteline.Pricing_ECAP_Price_Amt__c = 1200;
        quoteline.Pricing_Approved_Unit_Qty__c = 10;
        quoteline.Pricing_Approved_End_Date_Dt__c = system.today()+1;
        update quoteline;
        test.startTest();
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com']; 
        system.runAs(usr){
            
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/quotelines';
            request.addParameter('action', 'statuschange');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"quoteLines": [{"quotelineReferenceID": "QL-001","wonLostComments":"dasda","status":"Lost","quotelineId":"'+quoteline.Id+'"}]}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_Quotelines.doPost();
            system.debug('restResponse==>'+restResponse);
            system.assert(restResponse!=null);
            test.stopTest();
        }
    } 
    
    @isTest static void testDoPost_submiterror() {
        SBQQ__Quote__c quote = [Select Id,Pricing_Project_Name_Nm__c from SBQQ__Quote__c quote where Pricing_Project_Name_Nm__c = :'Test Project2'];
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Product Z'];
        Product2 p = [Select Id from Product2 where Name = :'Product X'];
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/quotelines';
            request.addParameter('action', 'dasdas');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"quoteId": "'+quote.Id+'","quoteLines": [{"productId": "'+p.Id+'","quoteLinePricingEndDate":"10/30/2029","quotelineReferenceID": "QL-001","writeInProduct": "","systemModel": "Test","noOfSystems": 10,"noOfCPUsPerSystem": 1,"singleSystemPrice": 100,"customerStdUnitPrice": 50,"requestedDiscountUnitPrice": 20,"additionalDiscount": 0,"competitorName": "Test","competitorSystemModel": "Test","competitorProductId": "'+cp.Id+'","competitorWriteInProduct": null,"competitorNoOfSystems": 1,"competitorNoOfCPUsPerSystem": 1,"competitorSingleSystemPrice": 8,"competitorAdditionalDiscount": 2,"additionalComment": null,"performanceMetrics": [{"performanceMetricsUsed": "Other","performanceMetricsReferenceId": "PM-003","weighting": 10,"intelScore": 10,"compScore": 3,"otherText": "Test"}]}]}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_Quotelines.doPost();
            system.assert(restResponse!=null);
            request.addParameter('action', '');
            Pricing_RestAPI_Response restResponse1 = Pricing_RestAPI_Quotelines.doPost();
            system.assert(restResponse1!=null);
            test.stopTest();
        }
    }  
    
    @isTest static void testWithoutParams() {
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/quotelines?type=&id=';
            req.httpMethod = 'GET';
            req.addParameter('id', '');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Quotelines.doGet();
            system.assert(response!=null);
            test.stopTest();
        }
    }
    
    @isTest static void testWithRecordId() {
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            test.startTest();        
            List<SBQQ__Quote__c> quotes = [SELECT Id,Name From SBQQ__Quote__c LIMIT 1];
            List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id,Name,SBQQ__Quote__c From SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quotes[0].Id LIMIT 1];
            RestRequest req = new RestRequest();
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/quotelines?type=all&id=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'all');
            req.addParameter('id', String.valueOf(quoteLines[0].Id));
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Quotelines.doGet();
            system.assert(true);
            test.stopTest(); 
        }
    }
    
    @isTest static void testDoPatch() {
        SBQQ__Quote__c quote = [Select Id,Pricing_Project_Name_Nm__c from SBQQ__Quote__c quote where Pricing_Project_Name_Nm__c = :'Test Project1'];
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Product Z'];
        SBQQ__QuoteLine__c quoteline = [Select Id from SBQQ__QuoteLine__c where Pricing_Status_Nm__c = :'Draft' and SBQQ__Quote__c = :quote.Id limit 1];
        Product2 p = [Select Id from Product2 where Name = :'Product X'];
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com']; 
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/quotelines';
            request.addParameter('action', 'update');
            request.httpMethod = 'PATCH';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"quoteId": "'+quote.Id+'","quoteLines": [{"productId": "'+p.Id+'","quotelineId": "'+quoteline.Id+'","quoteLinePricingEndDate":"10/30/2029","quotelineReferenceID": "QL-001","writeInProduct": "","systemModel": "Test","noOfSystems": 10,"noOfCPUsPerSystem": 1,"singleSystemPrice": 100,"customerStdUnitPrice": 50,"requestedDiscountUnitPrice": 20,"additionalDiscount": 0,"competitorName": "Test","competitorSystemModel": "Test","competitorProductId": "'+cp.Id+'","competitorWriteInProduct": null,"competitorNoOfSystems": 1,"competitorNoOfCPUsPerSystem": 1,"competitorSingleSystemPrice": 8,"competitorAdditionalDiscount": 2,"additionalComment": null,"performanceMetrics": [{"performanceMetricsUsed": "Other","performanceMetricsReferenceId": "PM-003","weighting": 10,"intelScore": 10,"compScore": 3,"otherText": "Test"}]}]}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_Quotelines.doPatch();
            system.debug('restResponse==>'+restResponse);
            system.assert(restResponse.successContent!=null);
            
            request.requestBody = Blob.valueOf('{"quoteId": "'+quote.Id+'","quoteLines": [{"productId": "'+p.Id+'","quoteLinePricingEndDate":"10/30/2020","quotelineReferenceID": "QL-001","writeInProduct": "","systemModel": "Test","noOfSystems": 10,"noOfCPUsPerSystem": 1,"singleSystemPrice": 100,"customerStdUnitPrice": 50,"requestedDiscountUnitPrice": 20,"additionalDiscount": 0,"competitorName": "Test","competitorSystemModel": "Test","competitorProductId": "'+cp.Id+'","competitorWriteInProduct": null,"competitorNoOfSystems": 1,"competitorNoOfCPUsPerSystem": 1,"competitorSingleSystemPrice": 0,"competitorAdditionalDiscount": 2,"additionalComment": null,"performanceMetrics": [{"performanceMetricsUsed": "Other","performanceMetricsReferenceId": "PM-003","weighting": 10,"intelScore": 10,"compScore": 3,"otherText": "Test"}]}]}');
            Pricing_RestAPI_Response restResponse2 = Pricing_RestAPI_Quotelines.doPatch();
            system.assert(restResponse2!=null);
            test.stopTest();
        }
    }
    @isTest static void testDoPostCR() {
        SBQQ__QuoteLine__c quoteline = [Select Id,SBQQ__Quote__c from SBQQ__QuoteLine__c where Pricing_Status_Nm__c = 'Draft' limit 1];
        quoteline.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
        quoteline.Pricing_ECAP_Price_Amt__c = 1200;
        quoteline.Pricing_Approved_Unit_Qty__c = 10;
        quoteline.Pricing_Approved_End_Date_Dt__c = system.today()+1;
        update quoteline;
        test.startTest();
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com']; 
        system.runAs(usr){
            
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/quotelines';
            request.addParameter('action', 'changerequest');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"quoteId": "'+quoteline.SBQQ__Quote__c+'","quoteLines": [{"quotelineId": "'+quoteline.id+'","quotelineReferenceID": "001","quoteLinePricingEndDate": "12/12/3000","newQuantity": 120,"newRequestedDiscountUnitPrice": 1200,"additionalComment": "1123456789"}]}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_Quotelines.doPost();
            system.debug('restResponse==>'+restResponse);
            system.assert(restResponse!=null);
            test.stopTest();
        }
    }
    
/*    static testMethod void testGetSSD() {
        test.startTest();
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        Product2 prod = [Select Id from Product2 where name='Write In Product' Limit 1];
        List<SBQQ__Quote__c> quotes = [SELECT Id,Name From SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c(); 
        newQuoteLine.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_SSD_Quote_Line_Create);
        newQuoteLine.SBQQ__Quote__c = quotes[0].id;
        newQuoteLine.Pricing_End_Date_dt__c = System.today()+5;
        newQuoteLine.Pricing_Product_Nm__c = prod.Id;
        newQuoteLine.Pricing_Other_Product_Nm__c = 'test';
        newQuoteLine.Pricing_Req_Discounted_Unit_Price__c = 100;
        newQuoteLine.Pricing_Competitor_OEM_Nm__c = 'test';
        newQuoteLine.Pricing_Total_Volume_Qty__c = 10;
        newQuoteLine.Pricing_Comp_Product_Txt__c = 'Test';
        newQuoteLine.Pricing_Comp_Unit_Price_Amt__c = 100;
        newQuoteLine.Pricing_Comp_Density_Nbr__c = 10;
        newQuoteLine.Pricing_VolumeByQuarterAndReasoning_Txt__c = 'test';          
        insert newQuoteLine;
        test.stopTest();
        system.runAs(usr){
            RestRequest req = new RestRequest();
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/quotelines?type=all&id=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'all');
            req.addParameter('id', String.valueOf(newQuoteLine.Id));
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Quotelines.doGet();
            system.assert(true);
        }
    }
    
    static testMethod void testGetPMem() {
        test.startTest();
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        User usr1 = [SELECT id FROM User WHERE email='firstName@intel.com'];
        Product2 prod = [Select Id from Product2 where name='Write In Product' Limit 1];
        List<SBQQ__Quote__c> quotes = [SELECT Id,Name From SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
        system.runAs(usr1){
            newQuoteLine.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_PMem_Quote_Line_Create);
            newQuoteLine.SBQQ__Quote__c = quotes[0].id;
            newQuoteLine.Pricing_End_Date_dt__c = System.today()+5;
            newQuoteLine.Pricing_Product_Nm__c = prod.Id;
            newQuoteLine.Pricing_Other_Product_Nm__c = 'test';
            newQuoteLine.Pricing_Req_Discounted_Unit_Price__c = 100;
            newQuoteLine.Pricing_Competitor_OEM_Nm__c = 'test';
            newQuoteLine.Pricing_Total_Volume_Qty__c = 10;
            newQuoteLine.Pricing_Comp_Unit_Price_Amt__c = 100;
            newQuoteLine.Pricing_Comp_Density_Nbr__c = 10;
            newQuoteLine.Pricing_Systems_qty__c = 10;
            newQuoteLine.Pricing_CPUs_per_system_qty__c = 1;
            newQuoteLine.Pricing_CPU_Txt__c = 'Test';
            newQuoteLine.Pricing_DRAM_Density_Nbr__c = 10;
            newQuoteLine.Pricing_DRAM_per_System_qty__c = 1;
            newQuoteLine.Pricing_Competitor_Systems_Cnt__c = 5;
            newQuoteLine.Pricing_Comp_CPUs_per_system_Cnt__c = 1;
            newQuoteLine.Pricing_Approved_Unit_Dup_Qty__c = 10;
            insert newQuoteLine;
        }
        test.stopTest();
        system.runAs(usr){
            RestRequest req = new RestRequest();
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/quotelines?type=all&id=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'all');
            req.addParameter('id', String.valueOf(newQuoteLine.Id));
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Quotelines.doGet();
            system.assert(true);
        }
    }

static testMethod void testGetNIC() {
        test.startTest();
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        User usr1 = [SELECT id FROM User WHERE email='firstName@intel.com'];
        Product2 prod = [Select Id from Product2 where name='Write In Product' Limit 1];
        List<SBQQ__Quote__c> quotes = [SELECT Id,Name From SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
        system.runAs(usr1){
            newQuoteLine.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_NIC_Quote_Line_Create);
            newQuoteLine.SBQQ__Quote__c = quotes[0].id;
            newQuoteLine.Pricing_End_Date_dt__c = System.today()+5;
            newQuoteLine.Pricing_Product_Nm__c = prod.Id;
            newQuoteLine.Pricing_Other_Product_Nm__c = 'test';
            newQuoteLine.Pricing_Req_Discounted_Unit_Price__c = 100;
            newQuoteLine.Pricing_Competitor_OEM_Nm__c = 'test';
            newQuoteLine.Pricing_Total_Volume_Qty__c = 10;
            newQuoteLine.Pricing_Comp_Unit_Price_Amt__c = 100;
            newQuoteLine.Pricing_Comp_Density_Nbr__c = 10;
            newQuoteLine.Pricing_Systems_qty__c = 10;
            newQuoteLine.Pricing_CPUs_per_system_qty__c = 1;
            newQuoteLine.Pricing_CPU_Txt__c = 'Test';
            newQuoteLine.Pricing_DRAM_Density_Nbr__c = 10;
            newQuoteLine.Pricing_DRAM_per_System_qty__c = 1;
            newQuoteLine.Pricing_Competitor_Systems_Cnt__c = 5;
            newQuoteLine.Pricing_Comp_CPUs_per_system_Cnt__c = 1;
            newQuoteLine.Pricing_Approved_Unit_Dup_Qty__c = 10;
            insert newQuoteLine;
        }
        test.stopTest();
        system.runAs(usr){
            RestRequest req = new RestRequest();
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/quotelines?type=all&id=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'all');
            req.addParameter('id', String.valueOf(newQuoteLine.Id));
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Quotelines.doGet();
            system.assert(true);
        }
    }*/

    public static List<User> createSalesRepUser(String emailId){
        Set<String> profileNameSet=new Set<String>{Label.Pricing_Tender_Profiles_SalesRepBB};
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Pricing_Tender_PermissionSets_TenderUser];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name IN: profileNameSet]){
            userProfileIdSet.add(proId.Id);
        }
        
        List<User> lstUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        //System.runAs(thisUser){
        for(Id profileId : userProfileIdSet){
            User u1 = new User(Alias = 'newUser', Email= emailId,
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = profileId,
                               TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstNameSalesRep@Intel.com' + Math.floor(Math.random() * 1000));
            
            lstUser.add(u1);
            
        }
        insert lstUser;
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>();
        for(user userId : lstUser){
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = Pricing_Test_Utility.permissionRec.Id));
            permissionList.add(new PermissionSetAssignment(AssigneeId = userId.Id, PermissionSetId = ps1.Id));
        } 
        if(!permissionList.isEmpty()){
            insert permissionList;
        }
        //}  
        return lstUser;
    }
}