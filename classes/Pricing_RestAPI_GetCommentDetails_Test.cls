@isTest
public class Pricing_RestAPI_GetCommentDetails_Test {

    @testSetup
    static void dataSetup(){
        Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
        Pricing_Test_Utility.createPriceBook();
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();          
        System.runAs(lstUsers2[0])
        {
            test.startTest();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
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
    
    static testMethod void testDoGet() {
      	User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        	system.runAs(usr){
                test.startTest();        
                List<Pricing_Comments__c> commentList = [Select Id from Pricing_Comments__c];
                RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
                RestResponse resp = RestContext.response;     
                req.requestUri='/services/apexrest/v1.0/quoterequest/getcommentdetails?id=';
                req.httpMethod = 'GET';
                req.addParameter('id', commentList[0].Id);
                RestContext.request = req;        
                Pricing_RestAPI_Response response = Pricing_RestAPI_GetCommentDetails.doGet();
                system.assertEquals(response.code, '200');
                test.stopTest();
 	}
}    
    static testMethod void testDoGet_Negative() {
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        system.runAs(usr){
            test.startTest();
            RestRequest req = (RestRequest)System.jSON.deserialize(Pricing_RestAPI_TestUtility.REQUEST_TEMPLATE, RestRequest.class);
            RestResponse resp = RestContext.response;     
            req.requestUri='/services/apexrest/v1.0/quoterequest/getcommentdetails?id=';
            req.httpMethod = 'GET';
            req.addParameter('id', 'asdasdw');
            RestContext.request = req;        
            Pricing_RestAPI_Response response = Pricing_RestAPI_GetCommentDetails.doGet();
            system.debug('response-->'+response);
            system.assert(response!=null);
            test.stopTest();
    	}
	}
}