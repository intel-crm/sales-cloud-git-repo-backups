/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_Quotes_Test 
* Version     : 1.0 
* Created Date: 13 Nov 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         11/13/2020              Test class for Rest API to create or submit all 4 sections
*****************************************************************************************************************************************/
@isTest
public class Pricing_RestAPI_Quotes_Test{
    
    @testSetup 
    private static void createData(){
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
        
        Pricing_Test_Utility.createPriceBook();
        
        Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c(
            Name = 'Product Z',
            Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z',
            RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_Data_Center')
        );
        insert prodList;
        insert cp;
        system.debug('Time 111==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();
        
        
        System.runAs(lstUsers2[0])
        {                      
            system.debug('Time 222==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
            Account acc = Pricing_Test_Utility.createAccount();
            //Contact con = Pricing_Test_Utility.createContact(acc.Id);
            Contact con = Pricing_Test_Utility.createPrimaryContactAPI(acc.Id,1)[0];
            
            User usr = [SELECT id FROM User WHERE email='primarycontact0@noemail.com'];
            Group grp = new Group();
            grp.name = 'PG: Partner';
            grp.Type = 'Regular'; 
            Insert grp; 
            
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = usr.id;
            grpMem1.GroupId = grp.Id;
            Insert grpMem1;
            
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            //Pricing_Test_Utility.createAEUser();
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
            
            Id recId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            
            List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c =  acc.Id;
            quote.SBQQ__PrimaryContact__c = con.Id;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project';
            quote.RecordTypeId=recId;
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
            
            SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
            quote2.SBQQ__Account__c =  acc.Id;
            quote2.SBQQ__PrimaryContact__c = con.Id;
            quote2.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote2.Pricing_Project_Name_Nm__c = 'Test Project';
            quote2.RecordTypeId=recId;
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
            
            SBQQ__Quote__c quote3 = new SBQQ__Quote__c();
            quote3.SBQQ__Account__c =  acc.Id;
            quote3.SBQQ__PrimaryContact__c = con.Id;
            quote3.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote3.Pricing_Project_Name_Nm__c = 'Test Project';
            quote3.RecordTypeId=recId;
            quote3.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote3.Pricing_End_Customer__c = uniEndCustomerL1.Id;
            quote3.Pricing_Customer_Nm__c = 'FMH';
            quote3.Pricing_Unified_Global_End_Customer_Nm__c = uniEndCustomerL2.Id;
            quote3.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote3.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote3.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote3.Pricing_Intel_Response_Requested_By_Date__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote3.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote3.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote3.Pricing_Region_Nm__c = 'APJ';
            //insert quote;
            quotes.add(quote3);
            
            SBQQ__Quote__c quote4 = new SBQQ__Quote__c();
            quote4.SBQQ__Account__c =  acc.Id;
            quote4.SBQQ__PrimaryContact__c = con.Id;
            quote4.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote4.Pricing_Project_Name_Nm__c = 'Test Project';
            quote4.RecordTypeId=recId;
            quote4.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote4.Pricing_End_Customer__c = uniEndCustomerL1.Id;
            quote4.Pricing_Customer_Nm__c = 'FMH';
            quote4.Pricing_Unified_Global_End_Customer_Nm__c = uniEndCustomerL2.Id;
            quote4.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote4.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote4.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote4.Pricing_Intel_Response_Requested_By_Date__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote4.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote4.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote4.Pricing_Region_Nm__c = 'APJ';
            //insert quote;
            quotes.add(quote4);
            
            SBQQ__Quote__c quote5 = new SBQQ__Quote__c();
            quote5.SBQQ__Account__c =  acc.Id;
            quote5.SBQQ__PrimaryContact__c = con.Id;
            quote5.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote5.Pricing_Project_Name_Nm__c = 'Test Project';
            quote5.RecordTypeId=recId;
            quote5.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote5.Pricing_End_Customer__c = uniEndCustomerL1.Id;
            quote5.Pricing_Customer_Nm__c = 'FMH';
            quote5.Pricing_Unified_Global_End_Customer_Nm__c = uniEndCustomerL2.Id;
            quote5.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote5.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote5.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote5.Pricing_Intel_Response_Requested_By_Date__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote5.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote5.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote5.Pricing_Region_Nm__c = 'APJ';
            //insert quote;
            quotes.add(quote5);
            
            test.startTest();
            insert quotes;
            system.debug('Time 333==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
            
            Id qliRecId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>(); 
            SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
            quoteLineob.RecordTypeId=qliRecId;
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
            
            SBQQ__QuoteLine__c quoteLineob2 = new SBQQ__QuoteLine__c(); 
            quoteLineob2.RecordTypeId=qliRecId;
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
            
            system.debug('Time 444==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
            
            
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
            system.debug('Time 555==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
            
            Set<Id> quoteIds = new Set<Id>{quote.Id, quote2.Id};
                List<Pricing_Comments__c> qComments = [SELECT id,name,Pricing_Answer__c FROM Pricing_Comments__c WHERE Pricing_Quote__c IN :quoteIds];
            for(Pricing_Comments__c qc : qComments){
                qc.Pricing_Answer__c = 'This is a test Answer. Test';
            }
            if(qComments.size() > 0){
                update qComments; 
            }
            test.stopTest();
            system.debug('Time 666==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
            Pricing_Publish_Quote.PublishTenderQuote(String.valueOf(quote2.Id));
            
            
            system.debug('Time 777==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
        }
    }
    static testMethod void testWithoutParams() {
        User usr = [SELECT id FROM User WHERE email='primarycontact0@noemail.com'];
        system.runAs(usr){
            test.startTest();        
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/quotes?id=';
            req.httpMethod = 'GET';
            req.addParameter('id', '');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Quotes.doGet();
            system.assert(response!=null);
            test.stopTest();
        }
    }
    
    @isTest static void testDoPost_submitQuote() {
        
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Product Z'];
        Product2 p = [Select Id from Product2 where Name = :'Write In Product'];
        User usr = [SELECT id, AccountId FROM User WHERE email='primarycontact0@noemail.com'];
        List<User> salesRep1 = createSalesRepUser('testSalesRep1@intel.com');
        List<User> salesRep2 = createSalesRepUser('testSalesRep2@intel.com');
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
        System.runAs(lstUsers2[0])
        {
            Pricing_Test_Utility.createAccountTeamMember(usr.AccountId, salesRep1[0].Id);
            Pricing_Test_Utility.createAccountTeamMember(usr.AccountId, salesRep2[0].Id);
        }
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/quotes';
            request.addParameter('action', 'create');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            String salesRepEmails = salesRep1[0].Email+','+salesRep2[0].Email;
            request.requestBody = Blob.valueOf('{     "quoteDetails": {         "endCustomer": "Test 12313123",         "unifiedEndCustomerId": "",         "projectName": "IBM",         "application": "CSP",         "proposalDueDate": "12/12/3000",         "intelResponseRequestedDate": "12/12/3000",         "pricingStartDate": "12/12/3000",         "pricingEndDate": "12/12/3000",         "endCustomerCountry": "India",         "referenceRequestID": "IQR-HPE-002",         "intelSalesRepEmail": "testSalesRep2@intel.com",         "intelAccountExecutiveEmail": "firstNameAE@intel.com",         "quoteLines": [             {                 "productId": "'+p.Id+'",                 "quoteLinePricingEndDate": "12/12/3000",                 "writeInProduct": "test",                 "quotelineReferenceID": "001",                 "systemModel": "Test",                 "noOfSystems": 10,                 "noOfCPUsPerSystem": 1,                 "singleSystemPrice": 100,                 "customerStdUnitPrice": 90,                 "requestedDiscountUnitPrice": 2,                 "additionalDiscount": 0,                 "competitorName": "Test",                 "competitorSystemModel": "Test",                 "competitorProductId": "'+cp.Id+'",                 "competitorWriteInProduct": null,                 "competitorNoOfSystems": 1,                 "competitorNoOfCPUsPerSystem": 1,                 "competitorSingleSystemPrice": 8,                 "competitorAdditionalDiscount": 2,                 "additionalComment": null,                 "quoteLineType": "CPU",                 "performanceMetrics": [                     {                         "performanceMetricsUsed": "Other",                         "performanceMetricsReferenceId": "PM-003",                         "weighting": 10,                         "intelScore": 10,                         "compScore": 5,                         "otherText": "Test"                     }                 ]            }      ],         "quoteComments": [             {                 "quoteCommentReferenceId": "QC-001",                 "answer": "This is a test Message 1.## 123"             },             {                 "quoteCommentReferenceId": "QC-002",                 "answer": "This is a test Message 2."             },             {                 "quoteCommentReferenceId": "QC-003",                 "answer": "Test"             },             {                 "quoteCommentReferenceId": "QC-004",                 "answer": "This is a test Message 3."             }         ]     } }');
            //request.requestBody = Blob.valueOf('{    "quoteDetails": {        "endCustomer": "Test 12313123",        "projectName": "IBM",        "application": "CSP",        "proposalDueDate":"12/12/3000",        "pricingStartDate": "12/12/3000",        "pricingEndDate": "12/12/3000",        "endCustomerCountry": "India",        "referenceRequestID": "IQR-HPE-002",        "intelSalesRepEmail": "testSalesRep2@intel.com",        "intelAccountExecutiveEmail": "firstNameAE@intel.com" ,        "quoteLines": [            {                "productId": "'+p.Id+'",               "quoteLinePricingEndDate": "12/20/3000",                "writeInProduct": "",        "quotelineReferenceID": "QL-002",               "systemModel": "Test",                "noOfSystems": 10,                "noOfCPUsPerSystem": 1,                "singleSystemPrice": 100,                "customerStdUnitPrice": 90,                "requestedDiscountUnitPrice": 2,                "additionalDiscount": 0,                "competitorName": "Test",                "competitorSystemModel": "Test",                "competitorProductId": "'+cp.Id+'",                "competitorWriteInProduct": null,                "competitorNoOfSystems": 1,               "competitorNoOfCPUsPerSystem": 1,                "competitorSingleSystemPrice": 8,                "competitorAdditionalDiscount": 2,                "additionalComment": null,                "performanceMetrics": [                    {                        "performanceMetricsUsed": "Other",            "performanceMetricsReferenceId": "PM-003",                        "weighting": 10,                        "intelScore": 10,                        "compScore": 5,                        "otherText": "Test"                    },                    {                        "performanceMetricsUsed": "HPCG",            "performanceMetricsReferenceId": "PM-004",                       "weighting": 2,                        "intelScore": 2,                        "compScore": 5,                        "otherText": null                    }                ]            }        ],       "quoteComments": [{"quoteCommentReferenceId": "QC-001", "answer": "This is a test Message 1.## 123"},{"quoteCommentReferenceId": "QC-002","answer": "This is a test Message 2."},{"quoteCommentReferenceId": "QC-003","answer": "Test"},{"quoteCommentReferenceId": "QC-004","answer": "This is a test Message 3."}]  }}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            system.debug('Time 888==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_Quotes.doPost();
            system.debug('Time 999==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
            system.debug('restResponse ==>'+restResponse);
            //system.assert(restResponse.successContent!=null);
            system.assert(restResponse!=null);
            test.stopTest();
        }        
    }
    @isTest static void testDoPost_createQuote() {
        User usr = [SELECT id FROM User WHERE email='primarycontact0@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/quotes';
            request.addParameter('action', 'create');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"quoteDetails": {"endCustomer": "Test 12313123",  "unifiedEndCustomerId": "", "projectName": "IBM", "application": "CSP", "proposalDueDate": "12/12/3000","intelResponseRequestedDate": "12/12/3000", "pricingStartDate": "12/12/3000", "pricingEndDate": "12/12/3000", "endCustomerCountry": "India", "referenceRequestID": "IQR-HPE-002"  }}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_Quotes.doPost();
            system.debug('restResponse ==>'+restResponse);
            system.assert(restResponse.successContent!=null); 
            test.stopTest();
        }        
    }
    @isTest static void testDoPost_createQTM() {
        User usr = [SELECT id,AccountId FROM User WHERE email='primarycontact0@noemail.com'];
        SBQQ__Quote__c quoteObj = [Select Id from SBQQ__Quote__c limit 1];
        List<User> salesRep1 = createSalesRepUser('testQTMSalesRep1@intel.com');
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
        System.runAs(lstUsers2[0])
        {
            Pricing_Test_Utility.createAccountTeamMember(usr.AccountId, salesRep1[0].Id);
        }
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/quotes';
            request.addParameter('action', 'quoteteam');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"quoteId": "'+quoteObj.Id+'","quoteDetails": { "intelSalesRepEmail": "testQTMSalesRep1@intel.com","intelAccountExecutiveEmail": "","industryTechnologySpecialistEmail": ""}}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_Quotes.doPost();
            system.debug('restResponse ==>'+restResponse);
            system.assert(restResponse.successContent!=null); 
            test.stopTest();
        }        
    }
    @isTest static void testDoPost_WrongQuoteAction() {
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Product Z'];
        Product2 p = [Select Id from Product2 where Name = :'Product X'];
        User usr = [SELECT id FROM User WHERE email='primarycontact0@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/quotes';
            request.addParameter('action', 'createTest');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{    "quoteDetails": {        "endCustomer": "Test 12313123",        "projectName": "IBM",        "application": "CSP",        "proposalDueDate":"12/31/2020", "intelResponseRequestedDate": "12/12/3000",  "pricingStartDate": "12/31/2020",        "pricingEndDate": "12/31/2020",        "endCustomerCountry": "India",        "referenceRequestID": "IQR-HPE-002",        "intelSalesRepEmail": "firstNameSalesRep@intel.com",        "intelAccountExecutiveEmail": "firstNameAE@intel.com",        "quoteLines": [            {                "productId": "01t1J00000AptvIQAR",               "quoteLinePricingEndDate": "12/31/2020",                "writeInProduct": "",        "quotelineReferenceID": "QL-002",               "systemModel": "Test",                "noOfSystems": 10,                "noOfCPUsPerSystem": 1,                "singleSystemPrice": 100,                "customerStdUnitPrice": 90,                "requestedDiscountUnitPrice": 2,                "additionalDiscount": 0,                "competitorName": "Test",                "competitorSystemModel": "Test",                "competitorProductId": "a8V2h0000004HXXEA2",                "competitorWriteInProduct": null,                "competitorNoOfSystems": 1,               "competitorNoOfCPUsPerSystem": 1,                "competitorSingleSystemPrice": 8,                "competitorAdditionalDiscount": 2,                "additionalComment": null,                "performanceMetrics": [                    {                        "performanceMetricsUsed": "Other",            "performanceMetricsReferenceId": "PM-003",                        "weighting": 10,                        "intelScore": 10,                        "compScore": 5,                        "otherText": "Test"                    },                    {                        "performanceMetricsUsed": "HPCG",            "performanceMetricsReferenceId": "PM-004",                       "weighting": 2,                        "intelScore": 2,                        "compScore": 5,                        "otherText": null                    }                ]            }        ],       "quoteComments": [{"quoteCommentReferenceId": "QC-001", "answer": "This is a test Message 1.## 123"},{"quoteCommentReferenceId": "QC-002","answer": "This is a test Message 2."},{"quoteCommentReferenceId": "QC-003","answer": "Test"},{"quoteCommentReferenceId": "QC-004","answer": "This is a test Message 3."}]   }}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_Quotes.doPost();
            system.debug('restResponse ==>'+restResponse);
            system.assert(restResponse.successContent==null); 
            test.stopTest();
        }        
    }
    
    static testMethod void testWithRecordId() {
        User usr = [SELECT id FROM User WHERE email='primarycontact0@noemail.com'];
        system.runAs(usr){
            test.startTest();       
            List<SBQQ__Quote__c> quotes = [SELECT Id,Name From SBQQ__Quote__c LIMIT 1];
            RestRequest req = new RestRequest();
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/quotes?type=quote&id=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'quote');
            req.addParameter('id', String.valueOf(quotes[0].Id));
            //req.addParameter('id', 'a852h00000015IwAAI');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Quotes.doGet();
            system.assert(response != null);
            test.stopTest(); 
        }
    }
    
    static testMethod void testWithType() {
        User usr = [SELECT id FROM User WHERE email='primarycontact0@noemail.com'];
        system.runAs(usr){
            test.startTest();        
            List<SBQQ__Quote__c> quotes = [SELECT Id,Name From SBQQ__Quote__c LIMIT 1];
            RestRequest req = new RestRequest();
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/quotes?type=all&id=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'all');
            req.addParameter('id', String.valueOf(quotes[0].Id));
            //req.addParameter('id', 'a852h00000015IwAAI');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Quotes.doGet();
            system.assert(true);
            test.stopTest(); 
        }
    }
    
    @isTest static void testDoPost_getStatusQuote() {
        User usr = [SELECT id FROM User WHERE email='primarycontact0@noemail.com'];
        SBQQ__Quote__c quoteObj = [Select Id from SBQQ__Quote__c limit 1];
        system.runAs(usr){
            test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/quotes';
            request.addParameter('action', 'getStatus');
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{"quoteIds": [ "'+quoteObj.Id+'" ]}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_Quotes.doPost();
            system.debug('restResponse ==>'+restResponse);
            system.assert(restResponse.successContent!=null); 
            test.stopTest();
        }        
    }
    
    @isTest static void testDoPost_updateQuote() {
        Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = :'Product Z'];
        Product2 p = [Select Id from Product2 where Name = :'Product X'];
        SBQQ__Quote__c quoteObj = [Select Id from SBQQ__Quote__c limit 1];
        SBQQ__QuoteLine__c quotelineObj = [select id from SBQQ__QuoteLine__c where SBQQ__Quote__c = :quoteObj.Id limit 1];
        User usr = [SELECT id, AccountId FROM User WHERE email='primarycontact0@noemail.com'];
        system.runAs(usr){
            //test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/quotes';
            request.addParameter('action', 'update');
            request.httpMethod = 'PATCH';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{  "quoteId":"'+quoteObj.Id+'",  "quoteDetails": {        "endCustomer": "Test 12313123",  "unifiedEndCustomerId": "",    "projectName": "IBM",    "application": "CSP",    "proposalDueDate": "12/12/3000", "intelResponseRequestedDate": "12/12/3000", "pricingStartDate": "12/12/3000",    "pricingEndDate": "12/12/3000",    "endCustomerCountry": "India",    "referenceRequestID": "IQR-HPE-002",    "quoteLines": [            {      "quotelineId":"'+quotelineObj.id+'",          "productId": "'+p.Id+'",                "quoteLinePricingEndDate": "12/20/3000",                "writeInProduct": "",               "quotelineReferenceID": "QL-1211",                "systemModel": "Test",                "noOfSystems": 10,                "noOfCPUsPerSystem": 1,               "singleSystemPrice": 100,                "customerStdUnitPrice": 90,                "requestedDiscountUnitPrice": 2,                "additionalDiscount": 0,                "competitorName": "Test",                "competitorSystemModel": "Test",                "competitorProductId": "'+cp.Id+'",               "competitorWriteInProduct": "",                "competitorNoOfSystems": 10,                "competitorNoOfCPUsPerSystem": 1,                "competitorSingleSystemPrice": 80,                "competitorAdditionalDiscount": 20,                "additionalComment": null,                "performanceMetrics": [                    {                       "performanceMetricsUsed": "Other",                        "performanceMetricsReferenceId": "PM-001",                        "weighting": 10,                        "intelScore": 10,                        "compScore": 5,                        "otherText": "Test"                    }                ]            }        ],        "quoteComments": [            {                "quoteCommentReferenceId": "QC-001",                "answer": "This is a test Message 1.## 123"            },            {                "quoteCommentReferenceId": "QC-002",                "answer": "This is a test Message 2."            },            {                "quoteCommentReferenceId": "QC-003",                "answer": "Test"            },            {                "quoteCommentReferenceId": "QC-004",                "answer": "This is a test Message 3."            }        ]    }}');
            //request.requestBody = Blob.valueOf('{    "quoteDetails": {        "endCustomer": "Test 12313123",        "projectName": "IBM",        "application": "CSP",        "proposalDueDate":"12/12/3000",        "pricingStartDate": "12/12/3000",        "pricingEndDate": "12/12/3000",        "endCustomerCountry": "India",        "referenceRequestID": "IQR-HPE-002",        "intelSalesRepEmail": "testSalesRep2@intel.com",        "intelAccountExecutiveEmail": "firstNameAE@intel.com" ,        "quoteLines": [            {                "productId": "'+p.Id+'",               "quoteLinePricingEndDate": "12/20/3000",                "writeInProduct": "",        "quotelineReferenceID": "QL-002",               "systemModel": "Test",                "noOfSystems": 10,                "noOfCPUsPerSystem": 1,                "singleSystemPrice": 100,                "customerStdUnitPrice": 90,                "requestedDiscountUnitPrice": 2,                "additionalDiscount": 0,                "competitorName": "Test",                "competitorSystemModel": "Test",                "competitorProductId": "'+cp.Id+'",                "competitorWriteInProduct": null,                "competitorNoOfSystems": 1,               "competitorNoOfCPUsPerSystem": 1,                "competitorSingleSystemPrice": 8,                "competitorAdditionalDiscount": 2,                "additionalComment": null,                "performanceMetrics": [                    {                        "performanceMetricsUsed": "Other",            "performanceMetricsReferenceId": "PM-003",                        "weighting": 10,                        "intelScore": 10,                        "compScore": 5,                        "otherText": "Test"                    },                    {                        "performanceMetricsUsed": "HPCG",            "performanceMetricsReferenceId": "PM-004",                       "weighting": 2,                        "intelScore": 2,                        "compScore": 5,                        "otherText": null                    }                ]            }        ],       "quoteComments": [{"quoteCommentReferenceId": "QC-001", "answer": "This is a test Message 1.## 123"},{"quoteCommentReferenceId": "QC-002","answer": "This is a test Message 2."},{"quoteCommentReferenceId": "QC-003","answer": "Test"},{"quoteCommentReferenceId": "QC-004","answer": "This is a test Message 3."}]  }}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            test.startTest();
      system.debug('Time 1010==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());            
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_Quotes.doPatch();
            system.debug('Time 1111==>'+Limits.getCpuTime()+';;Queries==>'+Limits.getQueries());
            system.debug('restResponse ==>'+restResponse);
            system.assert(restResponse.successContent!=null);
            test.stopTest();
        }        
    }
    
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
    static testMethod void test_svdQuota() {
        User usr = [SELECT id FROM User WHERE email='primarycontact0@noemail.com'];
        system.runAs(usr){
            test.startTest();        
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/quotes?id=&type=';
            req.httpMethod = 'GET';
            req.addParameter('type', 'getsvdquota');
            req.addParameter('id', '');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_Quotes.doGet();
            system.assert(response!=null);
            test.stopTest();
        }
    }
}