/****************************************************************************************************************************************
                                                 * Class Name  : Pricing_RestAPI_QuoteComments_Test
                                                 * Version     : 1.0
                                                 * Created Date: 29 October 2020
                                                 * Modification Log :
                                                 * Developer                 Date                  Description
                                                 * ---------------------------------------------------------------------------------------------------------------------------------------
                                                 * Team: Accenture         10/29/2020              Test class for Rest API to create Comments with no sections
                                                 *****************************************************************************************************************************************/
                                                @isTest
                                                public class Pricing_RestAPI_QuoteComments_Test {
                                                    
                                                    @testSetup static void testSetup() {
                                                        Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
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
                                                        RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c', 'Pricing_Data_Center')
                                                            );
                                                        
                                                        insert prodList;
                                                        insert cp;
                                                        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();
                                                        System.runAs(lstUsers2[0])
                                                        {
                                                            test.startTest();
                                                            Account acc = Pricing_Test_Utility.createAccount();
                                                            //Contact con = Pricing_Test_Utility.createContact(acc.Id);
                                                            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_Comments_test');
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
                                                    
                                                    
                                                    @isTest static void testSuccessResponse() {
                                                        User usr = [SELECT id FROM User WHERE email='Quote_Comments_test@noemail.com'];
                                                        system.runAs(usr){
                                                            test.startTest();
                                                            List<SBQQ__Quote__c> quote = [SELECT Id,Name From SBQQ__Quote__c LIMIT 1];
                                                            //RestRequest request = new RestRequest();
                                                            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
                                                            request.requestUri = '/services/apexrest/v1.0/quoterequest/quotecomments';
                                                            request.httpMethod = 'POST';
                                                            request.addHeader('Content-Type', 'application/json');
                                                    // request.requestBody = Blob.valueOf('{	"quoteId": "'+quote[0].Id+'",	"quoteComments": [		{			"question": "Is Intel currently used by the end-customer?  If not, who is the incumbent?",			"answer": "This is a test Message 1."		},		{			"question": "Deal description (i.e. end-customer background, explanation of project, future business opportunities, etc.)",			"answer": "This is a test Message 2."		}	]}');
                                            request.requestBody = Blob.valueOf('{	"quoteId": "'+quote[0].Id+'",	"quoteComments": [		{			"quoteCommentReferenceId": "QC-001",			"answer": "This is a test Message 1."		},		{			"quoteCommentReferenceId": "QC-002",			"answer": "This is a test Message 2."		}	]}');
                                            RestContext.request = request;
                                            RestResponse res = new RestResponse();
                                            RestContext.response= res;
                                            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuoteComments.doPost();
                                            system.assertEquals(restResponse.isSuccess, true);
                                            test.stopTest();
                                        }
                                    }
                                    
                                    @isTest static void testErrorResponse() {
                                        User usr = [SELECT id FROM User WHERE email='Quote_Comments_test@noemail.com'];
                                        system.runAs(usr){
                                            test.startTest();
                                            List<SBQQ__Quote__c> quotes = [SELECT Id,Name From SBQQ__Quote__c LIMIT 1];
                                            RestRequest request = new RestRequest();
                                            request.requestUri = '/services/apexrest/v1.0/quoterequest/quotecomments';
                                            request.httpMethod = 'POST';
                                            request.addHeader('Content-Type', 'application/json');
                                    //request.requestBody = Blob.valueOf('{"quoteId":"'+quotes[0].Id+'","quoteComments": [{"question": "Deal description (i.e. end-customer background, explanation of project, future business opportunities, etc.)***","answer": "Tfafafafafaffadaadgag"},{"question": "How will the systems be used?  What is the application & what benchmarks are being evaluated?","answer": "Tufquyfuqyfqfyqoifyoiq"},{"question": "Is Intel currently used by the end-customer?Â  If not, who is the incumbent?","answer": "e"},{"question": "Competition Assumptions (i.e. Discount amount, rationale for pricing request, etc.)","answer": "Tdiosadisaudoisudoisaudoiaud"}]}');
                            request.requestBody = Blob.valueOf('{	"quoteId": "'+quotes[0].Id+'",	"quoteComments": [		{			"quoteCommentReferenceId": "QC-001",			"answer": "test"		},		{			"quoteCommentReferenceId": "QC-002",			"answer": "test"		}	]}');
                            RestContext.request = request;
                            RestResponse res = new RestResponse();
                            RestContext.response= res;
                            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuoteComments.doPost();
                            system.assertEquals(restResponse.isSuccess, false);
                            test.stopTest();
                        }
                    }
                    
                    @isTest static void testUpdateComments_Success() {
                        User usr = [SELECT id FROM User WHERE email='Quote_Comments_test@noemail.com'];
                        system.runAs(usr){
                            test.startTest();
                            List<SBQQ__Quote__c> quote = [SELECT Id,Name From SBQQ__Quote__c LIMIT 1];
                            //RestRequest request = new RestRequest();
                            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
                            request.requestUri = '/services/apexrest/v1.0/quoterequest/quotecomments';
                            request.httpMethod = 'PATCH';
                            request.addHeader('Content-Type', 'application/json');
                    request.requestBody = Blob.valueOf('{	"quoteId": "'+quote[0].Id+'",	"quoteComments": [		{			"quoteCommentReferenceId": "QC-001",			"answer": "This is a test Message 1."		},		{			"quoteCommentReferenceId": "QC-002",			"answer": "This is a test Message 2."		}	]}');
                    RestContext.request = request;
                    RestResponse res = new RestResponse();
                    RestContext.response= res;
                    Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuoteComments.updateComments();
                    system.assertEquals(restResponse.isSuccess, true);
                    test.stopTest();
                }
            }
            
            @isTest static void testUpdateComment_Negative() {
                User usr = [SELECT id FROM User WHERE email='Quote_Comments_test@noemail.com'];
                system.runAs(usr){
                    test.startTest();
                    List<SBQQ__Quote__c> quotes = [SELECT Id,Name From SBQQ__Quote__c LIMIT 1];
                    RestRequest request = new RestRequest();
                    request.requestUri = '/services/apexrest/v1.0/quoterequest/quotecomments';
                    request.httpMethod = 'PATCH';
                    request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{	"quoteId": "'+quotes[0].Id+'",	"quoteComments": [		{			"quoteCommentReferenceId": "QC-001",			"answer": "test"		},		{			"quoteCommentReferenceId": "QC-002",			"answer": "Test"		}	]}');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_QuoteComments.updateComments();
            system.assertEquals(restResponse.isSuccess, false);
            test.stopTest();
        }
    }
    
    static testMethod void testDoGet() {
        User usr = [SELECT id FROM User WHERE email='Quote_Comments_test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            List<SBQQ__Quote__c> quotes = [SELECT Id,Name From SBQQ__Quote__c LIMIT 1];
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;
            req.requestUri='/services/apexrest/v1.0/quoterequest/quotecomments?id=';
            req.httpMethod = 'GET';
            req.addParameter('id', quotes[0].Id);
            RestContext.request = req;
            Pricing_RestAPI_Response response = Pricing_RestAPI_QuoteComments.doGet();
            system.assertEquals(response.code, '200');
            test.stopTest();
        }
    }
    
    static testMethod void testDoGetWithoutId() {
        User usr = [SELECT id FROM User WHERE email='Quote_Comments_test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;
            req.requestUri='/services/apexrest/v1.0/quoterequest/quotecomments';
            req.httpMethod = 'GET';
            RestContext.request = req;
            Pricing_RestAPI_Response response = Pricing_RestAPI_QuoteComments.doGet();
            //system.assertEquals(response.code, '200');
            // Verify response is not null
            System.assert(response != null, 'Response should not be null for doGet without ID');
            test.stopTest();
        }
    }
    static testMethod void testDoGet_Negative() {
        User usr = [SELECT id FROM User WHERE email='Quote_Comments_test@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;
            req.requestUri='/services/apexrest/v1.0/quoterequest/quotecomments?id=';
            req.httpMethod = 'GET';
            req.addParameter('id', 'asdasdw');
            RestContext.request = req;
            Pricing_RestAPI_Response response = Pricing_RestAPI_QuoteComments.doGet();
            system.assert(response!=null);
            test.stopTest();
        }
    }
}