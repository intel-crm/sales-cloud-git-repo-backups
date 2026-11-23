/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_SubmitQuotes_Test 
* Version     : 1.0 
* Created Date: 13 Nov 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         11/13/2020              Test class for Rest API to create or submit all 4 sections
*****************************************************************************************************************************************/
@isTest
public class Pricing_RestAPI_SubmitQuotes_Test {
    @testSetup 
    private static void createData(){
       /* Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
        Product2 prod = new Product2();
        prod.Core_Product_Org__c = 'Sales';
        prod.Core_Product_Type__c = 'Processors';
        prod.Core_Sales_Visible_Flag__c  = True;
        prod.IsActive = True;
        prod.Core_Hierarchy_ID__c = '43';
        prod.Core_Group_Code_Short_Name__c = 'CCG';
        prod.Name = 'Product X';
        
        Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c(
            Name = 'Product Z',
            Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z'
        );
        insert prod;
        insert cp;
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();          
        System.runAs(lstUsers2[0])
        {
            test.startTest();
            Account acc = Pricing_Test_Utility.createAccount();
            //Contact con = Pricing_Test_Utility.createContact(acc.Id);
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            //Pricing_Test_Utility.createAEUser();
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            test.stopTest();
        }        */
        
                
        Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
        Product2 prod = new Product2();
        prod.Core_Product_Org__c = 'Sales';
        prod.Core_Product_Type__c = 'Processors';
        prod.Core_Sales_Visible_Flag__c  = True;
        prod.IsActive = True;
        prod.Core_Hierarchy_ID__c = '43';
        prod.Core_Group_Code_Short_Name__c = 'CCG';
        prod.Name = 'Product X';
        
        Pricing_Test_Utility.createPriceBook();
        
        Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c(
            Name = 'Product Z',
            Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z'
        );
        insert prod;
        insert cp;
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();          
        System.runAs(lstUsers2[0])
        {
            test.startTest();
            Account acc = Pricing_Test_Utility.createAccount();
            //Contact con = Pricing_Test_Utility.createContact(acc.Id);
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            //Pricing_Test_Utility.createAEUser();
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            test.stopTest();
            
            Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = new Pricing_UnifiedEndCustomerAccountMapping__c();
            unifiedEndCustomer.name='Write In End Customer';
            insert unifiedEndCustomer;
            
            List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c =  acc.Id;
            quote.SBQQ__PrimaryContact__c = con.Id;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project';
            quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote.Pricing_Customer_Nm__c = 'FMH';
            quote.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
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
            quote1.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote1.Pricing_Customer_Nm__c = 'FMH';
            quote1.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote1.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote1.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
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
            quote2.Pricing_End_Customer__c=unifiedEndCustomer.id;
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
            //quoteLineob.Pricing_Other_Product_Nm__c='Test';
            quoteLineob.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob.Pricing_Systems_qty__c = 6; 
            quoteLineob.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLineob.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob.Pricing_Competetor_Product__c=cp.Id;
            //quoteLineob.Pricing_Other_Competitor_Product_Nm__c = 'Test';  
            quoteLineob.SBQQ__Quote__c = quote.Id;
            quoteLines.add(quoteLineob);
            //insert quoteLine;
            //quoteLines.add(quoteLineob);
            
            SBQQ__QuoteLine__c quoteLineob1 = new SBQQ__QuoteLine__c(); 
            quoteLineob1.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob1.Pricing_Product_Nm__c = prod.Id;
            //quoteLineob.SBQQ__Product__c = prod.Id;
            //quoteLineob1.Pricing_Other_Product_Nm__c='Test';
            quoteLineob1.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob1.Pricing_Systems_qty__c = 6; 
            quoteLineob1.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLineob1.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob1.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob1.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob1.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob1.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob1.Pricing_Competetor_Product__c=cp.Id;
            //quoteLineob1.Pricing_Other_Competitor_Product_Nm__c = 'Test';  
            quoteLineob1.SBQQ__Quote__c = quote1.Id;
            quoteLines.add(quoteLineob1);
            
            SBQQ__QuoteLine__c quoteLineob2 = new SBQQ__QuoteLine__c(); 
            quoteLineob2.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob2.Pricing_Product_Nm__c = prod.Id;
            //quoteLineob.SBQQ__Product__c = prod.Id;
            //quoteLineob2.Pricing_Other_Product_Nm__c='Test';
            quoteLineob2.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob2.Pricing_Systems_qty__c = 6; 
            quoteLineob2.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLineob2.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob2.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob2.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob2.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob2.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob2.Pricing_Competetor_Product__c=cp.Id;
            //quoteLineob2.Pricing_Other_Competitor_Product_Nm__c = 'Test';  
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
    @isTest static void testDoPost_Errors() {
        //RestRequest request = new RestRequest();
        //request.requestUri = 'https://intel--DEVINT3.salesforce.com/services/apexrest/v1.0/iqr/quotes';
        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/submitquote';
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{    "quoteDetails": {        "endCustomer": "Test 12313123",        "projectName": "IBM",        "application": "CSP",        "bidDecisionDate":"",        "pricingStartDate": "12/31/2020",        "pricingEndDate": "12/31/2020",        "endCustomerCountry": "India",        "referenceRequestID": "IQR-HPE-002",        "intelSalesRepEmail": "firstNameSalesRep@intel.com",        "intelAccountExecutiveEmail": "firstNameAE@intel.com",        "quoteLines": [            {                "productId": "01t1J00000AptvIQAR",               "quoteLinePricingEndDate": "12/31/2020",                "writeInProduct": "",				"quotelineReferenceID": "QL-002",               "systemModel": "Test",                "noOfSystems": 10,                "noOfCPUsPerSystem": 1,                "singleSystemPrice": 100,                "customerStdUnitPrice": 90,                "requestedDiscountUnitPrice": 2,                "additionalDiscount": 0,                "competitorName": "Test",                "competitorSystemModel": "Test",                "competitorProductId": "a8V2h0000004HXXEA2",                "competitorWriteInProduct": null,                "competitorNoOfSystems": 1,               "competitorNoOfCPUsPerSystem": 1,                "competitorSingleSystemPrice": 8,                "competitorAdditionalDiscount": 2,                "additionalComment": null,                "performanceMetrics": [                    {                        "performanceMetricsUsed": "Other",						"performanceMetricsReferenceId": "PM-003",                        "weighting": 10,                        "intelScore": 10,                        "compScore": 5,                        "otherText": "Test"                    },                    {                        "performanceMetricsUsed": "HPCG",						"performanceMetricsReferenceId": "PM-004",                       "weighting": 2,                        "intelScore": 2,                        "compScore": 5,                        "otherText": null                    }                ]            }        ],        "quoteComments": [{"quoteCommentReferenceId": "QC-001", "answer": "This is a test Message 1.## 123"},{"quoteCommentReferenceId": "QC-002","answer": "This is a test Message 2."},{"quoteCommentReferenceId": "QC-003","answer": "Test"},{"quoteCommentReferenceId": "QC-004","answer": "This is a test Message 3."}]   }}');
            RestContext.request = request;        
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_SubmitQuote.doPost();
            system.assert(restResponse.successContent==null);
            test.stopTest();
    	}
    }
    
    @isTest static void testDoPost_submitQuote() {
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Product Z'];
        Product2 p = [Select Id from Product2 where Name = :'Product X'];
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/submitquote';
            request.addParameter('action', 'submit');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{    "quoteDetails": {        "endCustomer": "Test 12313123",        "projectName": "IBM",        "application": "CSP",        "bidDecisionDate":"12/31/2020",        "pricingStartDate": "12/31/2020",        "pricingEndDate": "12/31/2020",        "endCustomerCountry": "India",        "referenceRequestID": "IQR-HPE-002",        "intelSalesRepEmail": "firstNameSalesRep@intel.com",        "intelAccountExecutiveEmail": "firstNameAE@intel.com",        "quoteLines": [            {                "productId": "'+p.Id+'",               "quoteLinePricingEndDate": "12/31/2020",                "writeInProduct": "",				"quotelineReferenceID": "QL-002",               "systemModel": "Test",                "noOfSystems": 10,                "noOfCPUsPerSystem": 1,                "singleSystemPrice": 100,                "customerStdUnitPrice": 90,                "requestedDiscountUnitPrice": 2,                "additionalDiscount": 0,                "competitorName": "Test",                "competitorSystemModel": "Test",                "competitorProductId": "'+cp.Id+'",                "competitorWriteInProduct": null,                "competitorNoOfSystems": 1,               "competitorNoOfCPUsPerSystem": 1,                "competitorSingleSystemPrice": 8,                "competitorAdditionalDiscount": 2,                "additionalComment": null,                "performanceMetrics": [                    {                        "performanceMetricsUsed": "Other",						"performanceMetricsReferenceId": "PM-003",                        "weighting": 10,                        "intelScore": 10,                        "compScore": 5,                        "otherText": "Test"                    },                    {                        "performanceMetricsUsed": "HPCG",						"performanceMetricsReferenceId": "PM-004",                       "weighting": 2,                        "intelScore": 2,                        "compScore": 5,                        "otherText": null                    }                ]            }        ],       "quoteComments": [{"quoteCommentReferenceId": "QC-001", "answer": "This is a test Message 1.## 123"},{"quoteCommentReferenceId": "QC-002","answer": "This is a test Message 2."},{"quoteCommentReferenceId": "QC-003","answer": "Test"},{"quoteCommentReferenceId": "QC-004","answer": "This is a test Message 3."}]  }}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_SubmitQuote.doPost();
            system.debug('restResponse ==>'+restResponse);
            system.assert(restResponse.successContent!=null);
            test.stopTest();
        }        
    }
    @isTest static void testDoPost_createQuote() {
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Product Z'];
        Product2 p = [Select Id from Product2 where Name = :'Product X'];
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/submitquote';
            request.addParameter('action', 'create');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{    "quoteDetails": {        "endCustomer": "Test 12313123",        "projectName": "IBM",        "application": "CSP",        "bidDecisionDate":"12/31/2020",        "pricingStartDate": "12/31/2020",        "pricingEndDate": "12/31/2020",        "endCustomerCountry": "India",        "referenceRequestID": "IQR-HPE-002",        "intelSalesRepEmail": "firstNameSalesRep@intel.com",        "intelAccountExecutiveEmail": "firstNameAE@intel.com",        "quoteLines": [            {                "productId": "'+p.Id+'",               "quoteLinePricingEndDate": "12/31/2020",                "writeInProduct": "",				"quotelineReferenceID": "QL-002",               "systemModel": "Test",                "noOfSystems": 10,                "noOfCPUsPerSystem": 1,                "singleSystemPrice": 100,                "customerStdUnitPrice": 90,                "requestedDiscountUnitPrice": 2,                "additionalDiscount": 0,                "competitorName": "Test",                "competitorSystemModel": "Test",                "competitorProductId": "'+cp.Id+'",                "competitorWriteInProduct": null,                "competitorNoOfSystems": 1,               "competitorNoOfCPUsPerSystem": 1,                "competitorSingleSystemPrice": 8,                "competitorAdditionalDiscount": 2,                "additionalComment": null,                "performanceMetrics": [                    {                        "performanceMetricsUsed": "Other",						"performanceMetricsReferenceId": "PM-003",                        "weighting": 10,                        "intelScore": 10,                        "compScore": 5,                        "otherText": "Test"                    },                    {                        "performanceMetricsUsed": "HPCG",						"performanceMetricsReferenceId": "PM-004",                       "weighting": 2,                        "intelScore": 2,                        "compScore": 5,                        "otherText": null                    }                ]            }        ],        "quoteComments": [{"quoteCommentReferenceId": "QC-001", "answer": "This is a test Message 1.## 123"},{"quoteCommentReferenceId": "QC-002","answer": "This is a test Message 2."},{"quoteCommentReferenceId": "QC-003","answer": "Test"},{"quoteCommentReferenceId": "QC-004","answer": "This is a test Message 3."}]    }}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_SubmitQuote.doPost();
            system.debug('restResponse ==>'+restResponse);
            system.assert(restResponse.successContent!=null); 
            test.stopTest();
        }        
    }
    @isTest static void testDoPost_WrongQuoteAction() {
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Product Z'];
        Product2 p = [Select Id from Product2 where Name = :'Product X'];
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/submitquote';
            request.addParameter('action', 'createTest');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{    "quoteDetails": {        "endCustomer": "Test 12313123",        "projectName": "IBM",        "application": "CSP",        "bidDecisionDate":"12/31/2020",        "pricingStartDate": "12/31/2020",        "pricingEndDate": "12/31/2020",        "endCustomerCountry": "India",        "referenceRequestID": "IQR-HPE-002",        "intelSalesRepEmail": "firstNameSalesRep@intel.com",        "intelAccountExecutiveEmail": "firstNameAE@intel.com",        "quoteLines": [            {                "productId": "01t1J00000AptvIQAR",               "quoteLinePricingEndDate": "12/31/2020",                "writeInProduct": "",				"quotelineReferenceID": "QL-002",               "systemModel": "Test",                "noOfSystems": 10,                "noOfCPUsPerSystem": 1,                "singleSystemPrice": 100,                "customerStdUnitPrice": 90,                "requestedDiscountUnitPrice": 2,                "additionalDiscount": 0,                "competitorName": "Test",                "competitorSystemModel": "Test",                "competitorProductId": "a8V2h0000004HXXEA2",                "competitorWriteInProduct": null,                "competitorNoOfSystems": 1,               "competitorNoOfCPUsPerSystem": 1,                "competitorSingleSystemPrice": 8,                "competitorAdditionalDiscount": 2,                "additionalComment": null,                "performanceMetrics": [                    {                        "performanceMetricsUsed": "Other",						"performanceMetricsReferenceId": "PM-003",                        "weighting": 10,                        "intelScore": 10,                        "compScore": 5,                        "otherText": "Test"                    },                    {                        "performanceMetricsUsed": "HPCG",						"performanceMetricsReferenceId": "PM-004",                       "weighting": 2,                        "intelScore": 2,                        "compScore": 5,                        "otherText": null                    }                ]            }        ],       "quoteComments": [{"quoteCommentReferenceId": "QC-001", "answer": "This is a test Message 1.## 123"},{"quoteCommentReferenceId": "QC-002","answer": "This is a test Message 2."},{"quoteCommentReferenceId": "QC-003","answer": "Test"},{"quoteCommentReferenceId": "QC-004","answer": "This is a test Message 3."}]   }}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_SubmitQuote.doPost();
            system.debug('restResponse ==>'+restResponse);
            system.assert(restResponse.successContent==null); 
            test.stopTest();
        }        
    }
    
}