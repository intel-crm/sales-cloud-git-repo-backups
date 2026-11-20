/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-31-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_RestAPI_ClaimsData_Test {
    //Setting up Test Data
    @testSetup
    public static void setUpData(){
        List<User> adminUser = Pricing_Test_Utility.createAdminUser();
        //List<User> adminUser2 = Pricing_Test_Utility.createAdminUser2();
        Contact con;
        List<User> accountExecutiveUserList;
        List<User> salesRepUserList;
        System.runAs(adminUser[0]){
            
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
            
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            Pricing_Test_Utility.createTemplate(adminUser[0].id);
            accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            
            User partnerUser = Pricing_Test_Utility.createPartnerAdminUser(acc.Id);
            Pricing_QuoteLineController.getDocumentId(Label.Pricing_Tender_T_C_Document);
        }
        
        User partnerUser = [SELECT Id, FirstName, ContactId  FROM User WHERE Email='partner@noemail.com' LIMIT 1];
        Account acc =  [SELECT Id from Account LIMIT 1];
        System.runAs(adminUser[0]){
            Document document;            
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.Name = Label.Pricing_IQR_Intel_Logo;
            document.FolderId = userinfo.getuserid();
            insert document;
            Test.startTest();
            List<SBQQ__Quote__c> quotes = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);            
                List<SBQQ__QuoteLine__c> quoteLines = Pricing_Test_Utility.createQuoteLines(quotes[0].Id, 1);
            Test.stopTest();
        }
    }
    
   @isTest
   public static void testSuccess(){
        SBQQ__QuoteLine__C quoteLine = [SELECT Id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
       System.runAs(adminUser){
           quoteLine.Pricing_Status_Nm__c = 'Approved';
           quoteLine.Pricing_Deal_RFQ_Id__c = '1234';
           
           update quoteLine;
       }
       test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/claimsdata';
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{     "Header": {         "xid": "48b9e55d-a45e-8e77-c3da-f8a01bc3a381",         "target_system": "Tender",         "source_system": "MyDeals",         "action": "UpdateClaims"     },     "claims": [         {             "creditVolume": "1",             "creditDollars": "1",             "debitVolume": "1",             "debitDollars": "1",             "lastCreditOrDebitDate": "12/31/2033",             "dealId": "1234",             "quoteLineNumber":  "'+quoteLine.Pricing_Quote_Line_Number__c+'"         }     ] }');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_ClaimsData.doPost();
            system.assert(restResponse!=null); 
            test.stopTest();
   }
    
   @isTest
   public static void testException(){
        SBQQ__QuoteLine__C quoteLine = [SELECT Id,Pricing_Quote_Line_Number__c from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
       System.runAs(adminUser){
           quoteLine.Pricing_Status_Nm__c = 'Approved';
           quoteLine.Pricing_Deal_RFQ_Id__c = '1234';
           
           update quoteLine;
       }
       test.startTest();
            RestRequest request = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            request.requestUri = '/services/apexrest/v1.0/quoterequest/claimsdata';
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json');
            request.requestBody = Blob.valueOf('{      "claims": [         {             "creditVolume": "1",             "creditDollars": "1",             "debitVolume": "1",             "debitDollars": "1",             "lastCreditOrDebitDate": "12/31/2033",             "dealId": "1234",             "quoteLineNumber":  "'+quoteLine.Pricing_Quote_Line_Number__c+'"         }     ] }');
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response= res;
            Pricing_RestAPI_Response restResponse = Pricing_RestAPI_ClaimsData.doPost();
            system.assert(restResponse!=null); 
            test.stopTest();
   }
}